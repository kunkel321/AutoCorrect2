/*
=====================================================
            AUTO CORRECTION LOG ANALYZER
                Updated:  4-7-2025 
=====================================================
Determines frequency of items in AutoCorrects Log file, then sorts by frequency (or weight).
Date not factored in sort. Reports the top X hotstrings that were immediately followed
by 'Backspace' (<<), and how many times they were used without backspacing (--).
Sort by one or the other, or sort by "weight". Intended for use with kunkel321's
'AutoCorrect for v2,' specifically, the f-function of that script. Items are reported 
in a GUI with radio buttons. User can:
- Go to the item in HotStringLibrary
- Open it in HotStringHelper2
- See context logs for the item
- Cull the item from the log
- Get suggestions for fixing problematic "word-middle" hotstrings

Items culled from ACLog file will get added to the RemovedHotStrings file.
This helps avoid inadvertently "re-adding" them later.
*/

#SingleInstance Force
#Requires AutoHotkey v2+

; Emergency kill switch
^Esc::ExitApp


; ======= Main Class Definition =======
class ACLogAnalyzer {
    ; Static configuration properties
    static Config := {
        ShowX: 24,                  ; Show this many top results in report
        SortByBS: 1,                ; Sort by "Backspaced" items (1) or "Kept" items (0)?
        WeighItems: 1,              ; Attempt to weight items based on how problematic they are (1=yes)
        FreqImportance: 5,         ; Importance of high-frequency items (0-50, 0=not important)
        IgnoreFewerThan: 2,         ; Minimum threshold for consideration when weighing
        AddFulltoClipBrd: 1,        ; Send full report to clipboard as well?
        ScriptFiles: {
            ACScript: "AutoCorrect2.ahk",    ; Main script file
            HSLibrary: "HotstringLib.ahk",   ; Hotstring library file
            ACLog: "AutoCorrectsLog.txt",    ; Main autocorrection log file
            ErrLog: "ErrContextLog.txt",     ; Context log file
            RemovedHsFile: "RemovedHotstrings.txt"  ; Removed hotstrings file
        },
        StartLine: 7,               ; Skip lines before this in log file
        CullDateFormat: "MM-dd-yyyy",  ; Date format for culled items
        EditorPath: ""              ; Will be set during initialization
    }

    ; State tracking properties
    static ReportArray := []
    static WorkingItem := " (No lookup history)"
    static ContextLogContent := ""
    static ACAGui := ""
    static ProgressGui := ""
    static ContextGui := ""
    static ConfirmGui := ""

    ; Visual properties (set during initialization)
    static FontColor := "Default"
    static ListColor := "Default"
    static FormColor := "Default"
    static RadioColor := "Blue"
    static ProgressColor := "c1b7706"

    static SuggestAlternatives := ""  ; Will be assigned later
    ; ======= Public Methods =======

    ; Entry point for the analyzer
    static Run() {
        this.Initialize()
        this.CreateRemovedHsFileIfNeeded()
        this.Main()
    }

    ; Initialize settings and properties
    static Initialize() {
        this.LoadThemeSettings()
        this.SetEditorPath()
        TraySetIcon(A_ScriptDir "\icons\AcAnalysis.ico")
    }

    ; Main processing function
    static Main() {
        try {
            if FileExist(this.Config.ScriptFiles.ACLog) {
                allStrings := FileRead(this.Config.ScriptFiles.ACLog)
            } else {
                MsgBox("File '" this.Config.ScriptFiles.ACLog "' not found... There must be a log file to analyze. Now exiting.")
                ExitApp()
            }

            totalLines := StrSplit(allStrings, "`n").Length
            progressObj := this.CreateProgressGui(totalLines)
            report := this.ProcessLines(allStrings, totalLines, progressObj)
            progressObj.gui.Destroy()
            
            this.ReportArray := this.PrepareReport(report)
            this.ShowAnalysisResults()
        } catch Error as err {
            LogError("Error in ACLogAnalyzer.Main: " err.Message)
            MsgBox("An error occurred during analysis:`n" err.Message)
            ExitApp()
        }
    }

    ; ======= Initialization Methods =======

    ; Load visual theme settings
    static LoadThemeSettings() {
        try {
            if FileExist("colorThemeSettings.ini") {
                settingsFile := "colorThemeSettings.ini"
                this.FontColor := IniRead(settingsFile, "ColorSettings", "fontColor")
                this.ListColor := IniRead(settingsFile, "ColorSettings", "listColor")
                this.FormColor := IniRead(settingsFile, "ColorSettings", "formColor")

                ; Calculate contrasting colors based on background brightness
                formColor := "0x" SubStr(this.FormColor, -6)
                r := (formColor >> 16) & 0xFF
                g := (formColor >> 8) & 0xFF
                b := formColor & 0xFF
                brightness := (r * 299 + g * 587 + b * 114) / 1000
                this.RadioColor := brightness > 128 ? "Blue" : "0x00FFFF"
                this.ProgressColor := brightness > 128 ? "c248d0c" : "c60fc3d"
            }
        } catch Error as err {
            LogError("Error loading theme settings: " err.Message)
            ; Default colors will be used
        }
    }

    ; Set the editor path based on current user
    static SetEditorPath() {
        defaultPath := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
        
        if FileExist(defaultPath) {
            this.Config.EditorPath := defaultPath
        } else {
            this.Config.EditorPath := "Notepad.exe"  ; Fallback to Notepad
        }
    }

    ; Create RemovedHotstrings file if it doesn't exist
    static CreateRemovedHsFileIfNeeded() {
        if !FileExist(this.Config.ScriptFiles.RemovedHsFile) {
            remFileHeader := "
            (
            This is a list of AutoCorrect hotstrings that were manually removed from the HotstringLib.ahk.  
            They were removed because an analysis report from the AutoCorrectsLog file indicated that 
            the autocorrection was 'Backspaced' more than it was kept. The MCLogger tool and the 
            HotString Helper tool each will check this list to avoid re-adding them to your HotstringLib.ahk list.
            =======================================
            )"
            
            try {
                FileAppend(remFileHeader, this.Config.ScriptFiles.RemovedHsFile)
            } catch Error as err {
                LogError("Error creating RemovedHotstrings file: " err.Message)
            }
        }
    }

    ; ======= Analysis Methods =======

    ; Create the progress GUI
    static CreateProgressGui(totalLines) {
        pg := Gui()
        pg.Opt("-MinimizeBox +AlwaysOnTop +Owner")
        pg.BackColor := this.FormColor
        myProgress := pg.Add("Progress", "w400 h30 c" this.ProgressColor " Background" this.FormColor " Range0-" totalLines, "0")

        reportType := this.GetReportTypeDescription()
        pg.Title := reportType "  Percent complete: 0 %."
        pg.Show()
        
        return {gui: pg, progress: myProgress, reportType: reportType}
    }

    ; Get description of current report type
    static GetReportTypeDescription() {
        if (this.Config.WeighItems = 1) && (this.Config.SortByBS = 1)
            return "Top " this.Config.ShowX " weighted errant"
        else if (this.Config.SortByBS = 1)
            return "Top " this.Config.ShowX " backspaced errant"
        else
            return "Top " this.Config.ShowX " kept"
    }

    ; Process lines from the log file
    static ProcessLines(allStrings, totalLines, progressObj) {
        report := ""
        try {
            Loop Parse allStrings, "`n`r" {
                progressObj.progress.Value += 1
                progressObj.gui.Title := progressObj.reportType " autocorrects.  Percent complete: " Round((progressObj.progress.Value/totalLines)*100) "%."
                
                ; Skip lines before start line
                if (A_Index < this.Config.StartLine)
                    continue
                
                oStr := SubStr(A_LoopField, 15)
                okTally := 1, bsTally := 1  ; Start at 1 to avoid division by zero
                
                Loop Parse allStrings, "`n`r" {
                    iStr := SubStr(A_LoopField, 15)
                    if (iStr = oStr) {
                        if (SubStr(A_LoopField, 12, 2) = "--")
                            okTally++
                        if (SubStr(A_LoopField, 12, 2) = "<<")
                            bsTally++
                    }
                }
                
                reportLine := this.FormatReportLine(bsTally, okTally, oStr)
                if (reportLine)
                    report .= reportLine
                
                ; Replace processed strings to avoid duplicates
                allStrings := StrReplace(allStrings, oStr, "Cap fix")
            }
        } catch Error as err {
            LogError("Error processing log lines: " err.Message)
            MsgBox("Error processing log lines: " err.Message)
        }
        
        return report
    }

    ; Format a line for the report based on configuration
    static FormatReportLine(bsTally, okTally, oStr) {
        try {
            if (this.Config.SortByBS = 1) {
                if (this.Config.WeighItems = 1) {
                    ; Skip items with too few backspaces
                    if (bsTally <= this.Config.IgnoreFewerThan)
                        return ""
                    
                    ; Calculate weight using the formula
                    weight := Round((bsTally / (bsTally + okTally) * 100) + bsTally * (this.Config.FreqImportance * 0.1), 1)
                    return weight " is weight for ->`t" Format("{1}<< and {2}-- `tfor {3}`n", bsTally, okTally, oStr)
                } else {
                    return Format("{1}<< and {2}-- `tfor {3}`n", bsTally, okTally, oStr)
                }
            } else {
                return Format("{1}-- and {2}<< `tfor {3}`n", okTally, bsTally, oStr)
            }
        } catch Error as err {
            LogError("Error in FormatReportLine: " err.Message)
            return ""
        }
    }

    ; Prepare the final report
    static PrepareReport(report) {
        try {
            ; Load context log content for reference
            this.ContextLogContent := FileExist(this.Config.ScriptFiles.ErrLog) ? 
                FileRead(this.Config.ScriptFiles.ErrLog) : ""
            
            ; Sort report by number (descending)
            sortedReport := Sort(Sort(report, "/U"), "NR")
            
            ; Extract top entries for display
            trunkReport := ""
            Loop Parse sortedReport, "`n" {
                if (A_Index <= this.Config.ShowX && A_LoopField != "") {
                    ; Add context count if available
                    contextCount := " [" this.CountContextItems(A_LoopField) "] "
                    contextCount := StrReplace(contextCount, "[0]", "[_]")
                    
                    ; Format entry
                    loopFldArr := StrSplit(A_LoopField, "<<")
                    thisLoopFld := loopFldArr[1] contextCount "<<" loopFldArr[2]
                    trunkReport .= thisLoopFld "`n"
                } else if (A_Index > this.Config.ShowX) {
                    break
                }
            }
            
            ; Copy to clipboard if configured
            if (this.Config.AddFulltoClipBrd = 1)
                A_Clipboard := sortedReport
            
            return StrSplit(RTrim(trunkReport, "`n"), "`n")
        } catch Error as err {
            LogError("Error preparing report: " err.Message)
            return []
        }
    }

    ; Count context items for a given log entry
    static CountContextItems(logEntry) {
        contextItemCount := 0
        
        try {
            selItemArr := StrSplit(logEntry, ":")
            selItemTrigger := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]
            
            Loop Parse this.ContextLogContent, "`n" {
                if InStr(A_LoopField, selItemTrigger)
                    contextItemCount++
            }
        } catch Error as err {
            LogError("Error counting context items: " err.Message)
        }
        
        return contextItemCount
    }

    ; ======= UI Methods =======

    ; Show the analysis results GUI
    static ShowAnalysisResults() {
        this.WorkingItem := " (No lookup history)"
        this.ACAGui := Gui(, "AC Analysis Report")
        this.ACAGui.SetFont("s12 " (this.FontColor ? "c" this.FontColor : ""))
        this.ACAGui.BackColor := this.FormColor
        
        ; Add heading text based on report type
        if (this.Config.WeighItems = 1) && (this.Config.SortByBS = 1)
            this.ACAGui.AddText(, "The " this.Config.ShowX " highest weighted problem items are below.`nAnalyze in HH and Cull separately. Culling adds`nitem to " this.Config.ScriptFiles.RemovedHsFile " file.")
        else if (this.Config.SortByBS = 1)
            this.ACAGui.AddText(, "The " this.Config.ShowX " most frequently Backspaced items are below.`nAnalyze in HH and Cull separately. Culling adds`nitem to " this.Config.ScriptFiles.RemovedHsFile " file.")
        else
            this.ACAGui.AddText(, "The " this.Config.ShowX " most frequently KEPT items are below.`nYOU PROBABLY DON'T WANT TO CHANGE THESE!")
        
        this.ACAGui.AddText("y+2", "(Select an item and right-click for context.)")
        
        ; Set color for radio buttons
        this.ACAGui.SetFont("c" this.RadioColor)
        
        ; Create radio buttons and action buttons
        this.CreateRadioButtons()
        this.CreateActionButtons()
        
        ; Show the GUI
        this.ACAGui.Show("yCenter x" (A_ScreenWidth/2) " AutoSize")
        WinSetAlwaysOnTop(1, "A")
        this.ACAGui.OnEvent("Escape", (*) => ExitApp())
    }

    ; Create radio buttons for each report item
    static CreateRadioButtons() {
        if (this.ReportArray.Length = 0) {
            this.ACAGui.Add("Text", "w300", "No items to display.")
            return
        }
        
        for idx, citem in this.ReportArray {
            ; Remove weight if using weighted sorting
            if (this.Config.WeighItems = 1) && (this.Config.SortByBS = 1)
                citem := StrSplit(citem, " is weight for ->`t")[2]
            
            ; First radio is selected by default
            options := (idx = 1) ? "vRadioGrp" : "xs y+5"
            radioBtn := this.ACAGui.Add("Radio", options, "Found " citem)
            radioBtn.OnEvent("ContextMenu", this.SeeContext.Bind(this))
        }
    }

    ; Create action buttons
    static CreateActionButtons() {
        buttons := [
            {label: "Send to HH", callback: this.SendToHH.Bind(this)},
            {label: "Cull From Log", callback: this.CullFromLog.Bind(this)},
            {label: "Edit Script", callback: (*) => Run(this.Config.EditorPath " " A_ScriptName)},
            {label: "See in Lib", callback: this.GoToHS.Bind(this)},
            {label: "See Context", callback: this.SeeContext.Bind(this)},
            ; New Suggest button for planned feature
            {label: "Suggest", callback: SuggestAlternativesHandler},
            {label: "Close Tool", callback: (*) => ExitApp()}
        ]
        
        for idx, btn in buttons {
            buttonOpts := (idx > 1 ? "x+5 " : "") (idx = 4 ? " xm y+5 " : "")
            newBtn := this.ACAGui.Add("Button", buttonOpts, btn.label)
            newBtn.OnEvent("Click", btn.callback)
        }
    }

    ; ======= Action Button Handlers =======

    ; Send the selected item to HotString Helper
    static SendToHH(*) {
        result := this.ProcessSelectedItem()
        if (!result)
            return

        this.WorkingItem := result.workingItem
        selItemArr := StrSplit(this.WorkingItem, ":")
        workingItem := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]

        myACFileBaseName := StrSplit(this.Config.ScriptFiles.ACScript, ".")[1]
        
        try {
            if (!FileExist(myACFileBaseName . ".exe")) {
                MsgBox("Error: " myACFileBaseName ".exe not found in the current directory.")
                return
            }
            
            Run(myACFileBaseName ".exe /script " this.Config.ScriptFiles.ACScript " " workingItem)
            this.ACAGui.Show()
        } catch Error as err {
            LogError("Error sending to HH: " err.Message)
            MsgBox("Error sending to HotString Helper: " err.Message)
        }
    }

    ; Go to the selected item in HotString Library
    static GoToHS(*) {
        result := this.ProcessSelectedItem()
        if (!result)
            return

        this.WorkingItem := result.workingItem
        selItemArr := StrSplit(this.WorkingItem, ":")
        selItemTrigger := selItemArr[2] ":" selItemArr[3] "::"
        
        try {
            if !WinExist(this.Config.ScriptFiles.HSLibrary)
                Run(this.Config.EditorPath " " this.Config.ScriptFiles.HSLibrary)
            
            WinWait(this.Config.ScriptFiles.HSLibrary)
            WinActivate(this.Config.ScriptFiles.HSLibrary)
            SendInput("^f")
            Sleep(200)
            SendInput(selItemTrigger)
            this.ACAGui.Show()
        } catch Error as err {
            LogError("Error going to HS: " err.Message)
            MsgBox("Error finding hotstring in library: " err.Message)
        }
    }

    ; Show context information for the selected item
    static SeeContext(*) {
        result := this.ProcessSelectedItem()
        if (!result)
            return

        this.WorkingItem := result.workingItem
        selItemArr := StrSplit(this.WorkingItem, ":")
        selItemTrigger := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]
        
        contextItems := ""
        
        try {
            if (!InStr(this.ContextLogContent, selItemTrigger)) {
                contextItems := "No context found for this item."
            } else {
                Loop Parse this.ContextLogContent, "`n" {
                    if (InStr(A_LoopField, selItemTrigger)) {
                        thisItem := StrSplit(A_LoopField, "`t---> ")[2]
                        contextItems .= thisItem "`n"
                    }
                }
            }

            ; Close existing context GUI if open
            if (IsObject(this.ContextGui))
                this.ContextGui.Destroy()
                
            this.ContextGui := Gui()
            this.ContextGui.SetFont("s15 " (this.FontColor ? "c" this.FontColor : ""))
            this.ContextGui.BackColor := this.FormColor
            
            ; Use an Edit control so text is selectable, but make it look like a label
            this.ContextGui.Add("Edit", "-VScroll ReadOnly -E0x200 -WantReturn -TabStop Background" this.FormColor, 
                "Context of item -- " selItemTrigger "`n======================`n" contextItems)
            
            this.ContextGui.AddButton(, "Open Log").OnEvent("Click", (*) => (this.ContextGui.Destroy(), Run(this.Config.ScriptFiles.ErrLog), this.ACAGui.Show()))
            
            closeBtn := this.ContextGui.AddButton("x+4", "Close This")
            closeBtn.OnEvent("Click", (*) => (this.ContextGui.Destroy(), this.ACAGui.Show()))
            
            this.ContextGui.Show()
            closeBtn.Focus()  ; Move focus to close button
        } catch Error as err {
            LogError("Error showing context: " err.Message)
            MsgBox("Error showing context: " err.Message)
        }
    }

    ; Cull the selected item from the log
    static CullFromLog(*) {
        result := this.ProcessSelectedItem()
        if (!result)
            return

        selectedItem := result.workingItem
        fullItemName := result.fullItemName
        
        ; Check if working on different item
        ; if (this.WorkingItem != selectedItem && this.WorkingItem != " (No lookup history)") {
        if not InStr(selectedItem, this.WorkingItem) && (this.WorkingItem != " (No lookup history)") {
            if (MsgBox("Warning: Different items detected`nYou were working on: " this.WorkingItem 
                "`nBut you're culling: " selectedItem "`n`nDo you want to continue?", "Item Mismatch", 4) != "Yes") {
                this.ACAGui.Show()
                return
            }
        }
        
        ; Close existing confirm GUI if open
        if (IsObject(this.ConfirmGui))
            this.ConfirmGui.Destroy()
            
        this.ConfirmGui := Gui()
        this.ConfirmGui.SetFont("s12 " (this.FontColor ? "c" this.FontColor : ""))
        this.ConfirmGui.BackColor := this.FormColor
        
        ; Get the formatted item for display
        if (this.Config.SortByBS = 1 && this.Config.WeighItems = 1) {
            selectedItem := StrSplit(selectedItem, "is weight for ->	")[2]
        }
        
        this.ConfirmGui.AddText(, "Confirm culling item...`n" selectedItem "`n")
        
        ; Add checkbox for removing strings
        remCheck := this.ConfirmGui.AddCheckbox(this.Config.SortByBS = 1 ? "Checked1" : "Checked0", 
            "Add to Removed Strings list.")
        
        ; Add notes section
        txtAddNotes := this.ConfirmGui.AddText(, "Add optional notes to culled item.")
        txtAddNotes.Visible := (this.Config.SortByBS = 1)
        
        notesEditOptions := this.Config.SortByBS = 1 ? 
            " -ReadOnly Background" this.ListColor : 
            " +ReadOnly Background" this.FormColor
            
        confirmNotes := this.ConfirmGui.AddEdit("w305 " notesEditOptions, "Replaced with less-trimmed versions")
        confirmNotes.Focus()
        ; Add buttons
        this.ConfirmGui.AddButton("w150", "Cull Item").OnEvent("Click", 
            (*) => this.DoCullItem(selectedItem, remCheck.Value, confirmNotes.Value))
            
        this.ConfirmGui.AddButton("w150 x+5", "Cancel").OnEvent("Click", 
            (*) => (this.ConfirmGui.Destroy(), this.ACAGui.Show()))
        
        ; Add event for checkbox
        remCheck.OnEvent("Click", (*) => this.ToggleNotesVisibility(remCheck, confirmNotes, txtAddNotes))
        
        this.ConfirmGui.Show()
    }

    ; Toggle notes visibility based on checkbox state
    static ToggleNotesVisibility(remCheck, confirmNotes, txtAddNotes) {
        if (remCheck.Value = 0) {
            confirmNotes.Opt(" +ReadOnly Background" this.FormColor)
            confirmNotes.Text := ""
            txtAddNotes.Visible := false
        } else {
            confirmNotes.Opt(" -ReadOnly Background" this.ListColor)
            txtAddNotes.Visible := true
        }
    }

    ; Actually cull the item from the log
    static DoCullItem(itemToCull, addToRemoved, notes) {
        try {
            if (notes && notes != "")
                itemToCull .= " (" notes ")"
                
            if (addToRemoved) {
                cullItemAndDate := "Removed " FormatTime(A_Now, this.Config.CullDateFormat) " -> " itemToCull "`n"
                FileAppend(cullItemAndDate, this.Config.ScriptFiles.RemovedHsFile)
            }
            
            ; Extract hotstring trigger and replacement for matching context log entries
            selItemArr := StrSplit(itemToCull, ":")
            selItemTrigger := ""
            
            ; Make sure we have enough parts to form a valid hotstring trigger
            if (selItemArr.Length >= 5) {
                ; selItemTrigger := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]
                selItemTrigger := ":" selItemArr[3] "::"
            }
            
            ; Read and rewrite main log file without the culled item
            thisFileContents := FileRead(this.Config.ScriptFiles.ACLog)
            newFileContents := ""
            
            for scriptLine in StrSplit(thisFileContents, "`n") {
                if (scriptLine != "") {
                    if (!InStr(itemToCull, SubStr(scriptLine, 15)))
                        newFileContents .= scriptLine "`n"
                }
            }
            
            FileDelete(this.Config.ScriptFiles.ACLog)
            while (FileExist(this.Config.ScriptFiles.ACLog))
                Sleep(10)
                    
            FileAppend(newFileContents, this.Config.ScriptFiles.ACLog)
            
            ; Now handle the context log if the trigger is valid
            if (selItemTrigger != "" && FileExist(this.Config.ScriptFiles.ErrLog)) {
                ; Read and rewrite context log file without the culled item's contexts
                contextFileContents := FileRead(this.Config.ScriptFiles.ErrLog)
                newContextContents := ""
                
                for contextLine in StrSplit(contextFileContents, "`n") {
                    if (contextLine != "") {
                        if (!InStr(contextLine, selItemTrigger))
                            newContextContents .= contextLine "`n"
                    }
                }
                
                try {
                    FileDelete(this.Config.ScriptFiles.ErrLog)
                    while (FileExist(this.Config.ScriptFiles.ErrLog))
                        Sleep(10)
                        
                    FileAppend(newContextContents, this.Config.ScriptFiles.ErrLog)
                    Debug("Removed " selItemTrigger " entries from context log")
                } catch Error as err {
                    LogError("Error rewriting context log: " err.Message)
                    ; Continue anyway as the main log was updated successfully
                }
            }
            
            SoundBeep()
            
            this.ConfirmGui.Destroy()
            ExitApp()
        } catch Error as err {
            LogError("Error culling item: " err.Message)
            MsgBox("Error culling item: " err.Message)
        }
    }

    ; ======= Helper Methods =======

    ; Process the selected radio item
    static ProcessSelectedItem() {
        try {
            selectedItem := this.ACAGui.Submit()
            
            if (selectedItem.RadioGrp = 0) {
                MsgBox("Nothing selected.")
                this.ACAGui.Show()
                return false
            }
            
            fullItemName := this.ReportArray[selectedItem.RadioGrp]
            workingItem := this.ExtractItemName(fullItemName)
            
            return {workingItem: workingItem, fullItemName: fullItemName}
        } catch Error as err {
            LogError("Error processing selected item: " err.Message)
            MsgBox("Error processing selected item: " err.Message)
            return false
        }
    }

    ; Extract the item name from the selected report line
    static ExtractItemName(selItemName) {
        try {
            splitStr := this.Config.SortByBS ? "-- for" : "<< for"
            parts := StrSplit(selItemName, splitStr)
            return Trim(parts[parts.Length], " `n`r")  ; Always take the last part
        } catch Error as err {
            LogError("Error extracting item name: " err.Message)
            return selItemName  ; Return original if there's an error
        }
    }
}

; Handler function for the Suggest button in ACLogAnalyzer
; This is the only function that needs to be exposed
SuggestAlternativesHandler(*) {
    ; This function will be called from ACLogAnalyzer when the Suggest button is clicked
    
    ; Extract the selected hotstring from ACLogAnalyzer's state
    result := ProcessSelectedItem()
    if (!result)
        return
        
    ; Extract just the hotstring part
    fullItem := result.workingItem
    
    selItemArr := StrSplit(result.workingItem, ":")
    hotstringPart := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]
    
    ; Log what we're sending to the suggester
    FileAppend("Sending to Suggester: " hotstringPart "`n", "suggester_bridge_log.txt")
    
    ; Run the Suggester tool with the hotstring as a parameter
    try {
        ; Check if Suggester.exe exists
        if FileExist("Suggester.exe") {
            Run('Suggester.exe /script Suggester.ahk "' hotstringPart '"')
            ;Run("Suggester.exe " hotstringPart)
        }
        else {
            MsgBox("Error: Suggester tool not found. Make sure Suggester.exe or Suggester.ahk is in the current directory.")
        }
    } catch Error as err {
        FileAppend("Error running Suggester: " err.Message "`n", "suggester_bridge_log.txt")
        MsgBox("Error launching Suggester tool: " err.Message)
    }
}

; Helper function to process the selected item from ACLogAnalyzer
; This mimics the ProcessSelectedItem function in ACLogAnalyzer
ProcessSelectedItem() {
    ; First check if ACLogAnalyzer is available in the global scope
    if !(IsSet(ACLogAnalyzer) && IsObject(ACLogAnalyzer)) {
        MsgBox("ACLogAnalyzer not found. This script should be run from within ACLogAnalyzer.")
        return false
    }
    
    try {
        ; Call ACLogAnalyzer's ProcessSelectedItem method
        return ACLogAnalyzer.ProcessSelectedItem()
    } catch Error as err {
        FileAppend("Error processing selected item: " err.Message "`n", "suggester_bridge_log.txt")
        MsgBox("Error processing selected item: " err.Message)
        return false
    }
}

; Assign the handler to ACLogAnalyzer
ACLogAnalyzer.SuggestAlternatives := SuggestAlternativesHandler

; ======= Utility Functions =======

; Helper functions for conditional logging
LogError(message) {
    FileAppend("ErrLog: " FormatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "acla_error_debug_log.txt") ; acla -- Auto Correction Log Analyzer.
}

Debug(message) {
    FileAppend("Debug: " FormatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "acla_error_debug_log.txt")
}

; ======= Main Execution =======
; Run the analyzer when script is executed directly
if (A_ScriptName = "ACLogAnalyzer.ahk") {
    ACLogAnalyzer.Run()
}
