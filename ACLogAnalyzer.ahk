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
        FreqImportance: 30,         ; Importance of high-frequency items (0-50, 0=not important)
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

; ======= Enhanced Suggestion Feature for ACLogAnalyzer with Word Frequency =======
/*
This code enhances the "Suggest" button functionality for ACLogAnalyzer.
It integrates the word frequency functionality from wordFrequencyTotaller.ahk
to display web frequency data for suggested hotstring fixes.

When a user selects an errant hotstring and clicks "Suggest", this code will:
1. Analyze the problematic hotstring
2. Generate variations by adding letters to the beginning/end
3. Evaluate each variation for matches, misspellings, and validity issues
4. Calculate web frequency data for each suggestion
5. Present results in a dashboard interface with frequency information
*/

class HotstringSuggester {
    static SuggestGui := ""
    static ProgressGui := ""
    static LoadedWordList := []
    static CurrentHotstring := ""
    static Suggestions := []
    static WordListPath := ""
    static FreqDataFile := "WordListsForHH\unigram_freq_list_filtered_88k.csv"
    static WordFreqMap := Map()
    static CommonLetters := "etaoinsrhdlucmfywgpbvkjxqz" ; Most common letters in English
    static Config := {
        FormColor: "Default",      ; Will be set based on ACLogAnalyzer config
        FontColor: "Default",      ; Will be set based on ACLogAnalyzer config
        ProgressColor: "c1b7706",  ; Will be set based on ACLogAnalyzer config
        ListColor: "Default"       ; Will be set based on ACLogAnalyzer config
    }
    static FreqDataLoaded := false
    
    ; Initialize the suggester with necessary data
    static Init(hotstring, wordListPath) {
        ; Import configuration from ACLogAnalyzer if it exists in global scope
        if (IsSet(ACLogAnalyzer) && IsObject(ACLogAnalyzer)) {
            try {
                ; Import color settings
                this.Config.FormColor := ACLogAnalyzer.FormColor
                this.Config.FontColor := ACLogAnalyzer.FontColor
                this.Config.ListColor := ACLogAnalyzer.ListColor
                this.Config.RadioColor := ACLogAnalyzer.RadioColor
                this.Config.ProgressColor := ACLogAnalyzer.ProgressColor
            } catch {
                ; Use defaults if ACLogAnalyzer config not available
            }
        }
        
        ; Create a progress indicator - start at 0%
        progress := this._ShowSimpleProgress("Analyzing hotstring...", 
            "Generating suggestions for " hotstring "`nThis may take a moment...")
        
        this.CurrentHotstring := hotstring
        this.WordListPath := wordListPath
        this.Suggestions := []
        
        ; Update to 10% - Starting analysis
        progress.bar.Value := 10
        progress.gui.Title := "Loading word list..."
        
        if (this.LoadedWordList.Length = 0) {
            this._LoadWordList()
        }
        
        ; Update to 20% - Loading frequency data
        progress.bar.Value := 20
        progress.gui.Title := "Loading frequency data..."
        
        if (!this.FreqDataLoaded) {
            this._LoadWordFrequencies(this.FreqDataFile)
        }
        
        ; Update to 30% - Parsing hotstring
        progress.bar.Value := 30
        progress.gui.Title := "Parsing hotstring..."
        
        ; Parse the hotstring to extract components
        hsInfo := this._ParseHotstring(hotstring)
        
        ; Generate suggestions based on the hotstring type
        if (hsInfo) {
            ; Update to 60% - Generating suggestions
            progress.bar.Value := 60
            progress.gui.Title := "Analyzing letter patterns..."
            
            this._GenerateSuggestions(hsInfo, progress)
            
            ; Update to 90% - Preparing dashboard
            progress.bar.Value := 90
            progress.gui.Title := "Preparing results..."
            
            ; Close progress window
            if progress && IsObject(progress.gui)
                progress.gui.Destroy()
                
            this._ShowSuggestionDashboard(hsInfo)
        } else {
            MsgBox("Could not parse the hotstring: " hotstring)
            if progress && IsObject(progress.gui)
                progress.gui.Destroy()
        }
    }
    
    ; Load word frequencies from CSV file
    static _LoadWordFrequencies(filePath) {
        try {
            ; Clear existing data
            this.WordFreqMap.Clear()
            
            ; Check if file exists
            if (!FileExist(filePath)) {
                Debug("Frequency data file not found: " filePath)
                return false
            }
            
            ; Process the file directly from disk, one line at a time
            wordCount := 0
            duplicateCount := 0
            skippedLines := 0
            
            ; Open the file for reading
            file := FileOpen(filePath, "r")
            if (!file) {
                Debug("Could not open frequency data file: " filePath)
                return false
            }
            
            ; Read line by line
            while !file.AtEOF {
                line := file.ReadLine()
                
                ; Skip empty lines
                if (line = "" || line = "`r")
                    continue
                
                ; Split the line into word and frequency
                commaPos := InStr(line, ",")
                if (commaPos) {
                    word := Trim(SubStr(line, 1, commaPos - 1))
                    freqStr := Trim(SubStr(line, commaPos + 1))
                    
                    ; Skip lines with empty frequencies
                    if (word = "" || freqStr = "") {
                        skippedLines++
                        continue
                    }
                    
                    ; Convert frequency to number
                    freq := Number(freqStr)
                    if (freq = 0 && freqStr != "0") {
                        skippedLines++
                        continue
                    }
                    
                    ; Convert word to lowercase for consistency
                    word := StrLower(word)
                    
                    ; Check for duplicates
                    if (this.WordFreqMap.Has(word)) {
                        duplicateCount++
                        ; For duplicates, add the frequencies together
                        this.WordFreqMap[word] += freq
                    } else {
                        ; Add new word
                        this.WordFreqMap[word] := freq
                        wordCount++
                    }
                }
            }
            
            ; Close the file
            file.Close()
            
            Debug("Word frequency data loaded - Words: " wordCount)
            
            this.FreqDataLoaded := true
            return true
        }
        catch Error as err {
            Debug("Error loading frequency data: " err.Message)
            return false
        }
    }
    
    ; Parse the hotstring to extract options, trigger, and replacement
    static _ParseHotstring(hotstring) {
        ; Extract components using regex (handles both regular and function-based hotstrings)
        hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<fCom>\h*;\h*(?:\bFIXES\h*\d+\h*WORDS?\b)?(?:\h;)?\h*(?<mCom>.*))?$"
        
        if (RegExMatch(hotstring, hsRegex, &match)) {
            result := {
                options: match.Opts,
                trigger: match.Trig,
                replacement: StrReplace(match.Repl, '"', ''),
                comment: match.mCom
            }
            
            ; Determine the type of hotstring based on options
            result.isBeginning := InStr(result.options, "*") && !InStr(result.options, "?")
            result.isEnding := !InStr(result.options, "*") && InStr(result.options, "?")
            result.isMiddle := InStr(result.options, "*") && InStr(result.options, "?")
            
            return result
        }
        return false
    }
    
    ; Load the word list for analysis
    static _LoadWordList() {
        if (!FileExist(this.WordListPath)) {
            MsgBox("Word list file not found: " this.WordListPath)
            return
        }
        
        try {
            this.LoadedWordList := []
            Loop Read, this.WordListPath {
                this.LoadedWordList.Push(A_LoopReadLine)
            }
        } catch Error as err {
            Debug("Error loading word list: " err.Message)
        }
    }
                
    static _GenerateSuggestions(hsInfo, progress := 0) {
        ; Check if this is a regular hotstring with no wildcards
        if (!hsInfo.isMiddle && !hsInfo.isBeginning && !hsInfo.isEnding) {
            MsgBox("This is a regular exact-match hotstring without wildcards. Suggestions aren't relevant in this case as the hotstring only matches one specific word.", "No Suggestions Available", 64)
            return
        }

        ; Update progress to 65% - Finding matches
        if (progress && IsObject(progress.bar))
            progress.bar.Value := 65, progress.gui.Title := "Finding words containing the replacement..."

        ; First, find actual words containing the replacement
        matchInfo := this._AnalyzeMatchingWords(hsInfo)
        
        ; Update progress to 75% - Generating suggestions
        if (progress && IsObject(progress.bar))
            progress.bar.Value := 75, progress.gui.Title := "Creating suggestions..."
        
        ; Create suggestions based on the match analysis
        this._CreateSuggestionsFromAnalysis(hsInfo, matchInfo)
        
        ; Add the original as reference
        this._AddOriginalAsSuggestion(hsInfo)
        
        ; Update progress to 85% - Calculating frequencies
        if (progress && IsObject(progress.bar))
            progress.bar.Value := 85, progress.gui.Title := "Calculating web frequencies..."
            
        ; Calculate web frequencies for all suggestions
        this._CalculateFrequenciesForSuggestions()
    }

    ; Analyze words to find patterns and letter frequencies
    static _AnalyzeMatchingWords(hsInfo) {
        ; Structure to collect analysis data
        matchInfo := {
            words: [],             ; Words containing the replacement
            preceding: Map(),      ; Letters preceding the replacement
            following: Map(),      ; Letters following the replacement
            variations: Map()      ; Fixes count for each variation
        }
        
        lcReplacement := StrLower(hsInfo.replacement)
        
        ; Scan the word list to find matching words and collect letter frequencies
        for idx, word in this.LoadedWordList {
            ; Convert to lowercase for case-insensitive matching
            lcWord := StrLower(word)
            
            ; Skip if replacement isn't in the word
            if (!InStr(lcWord, lcReplacement))
                continue
                
            ; Add to matching words list
            matchInfo.words.Push(word)
            
            ; Find all occurrences and analyze surrounding letters
            pos := 1
            while (pos := InStr(lcWord, lcReplacement, , pos)) {
                ; Check letter before replacement
                if (pos > 1) {
                    beforeLetter := SubStr(lcWord, pos-1, 1)
                    if (beforeLetter ~= "[a-z]") {
                        ; Increment frequency count
                        matchInfo.preceding[beforeLetter] := matchInfo.preceding.Has(beforeLetter) ? 
                                                        matchInfo.preceding[beforeLetter] + 1 : 1
                                                        
                        ; Create a key for this variation (preceding letter + replacement)
                        variationKey := beforeLetter . lcReplacement
                        matchInfo.variations[variationKey] := matchInfo.variations.Has(variationKey) ?
                                                            matchInfo.variations[variationKey] + 1 : 1
                    }
                }
                
                ; Check letter after replacement
                afterPos := pos + StrLen(lcReplacement)
                if (afterPos <= StrLen(lcWord)) {
                    afterLetter := SubStr(lcWord, afterPos, 1)
                    if (afterLetter ~= "[a-z]") {
                        ; Increment frequency count
                        matchInfo.following[afterLetter] := matchInfo.following.Has(afterLetter) ? 
                                                    matchInfo.following[afterLetter] + 1 : 1
                                                    
                        ; Create a key for this variation (replacement + following letter)
                        variationKey := lcReplacement . afterLetter
                        matchInfo.variations[variationKey] := matchInfo.variations.Has(variationKey) ?
                                                        matchInfo.variations[variationKey] + 1 : 1
                    }
                }
                
                pos += StrLen(lcReplacement)
            }
        }
        
        return matchInfo
    }
    
    ; Create suggestions based on analysis
    static _CreateSuggestionsFromAnalysis(hsInfo, matchInfo) {
        ; Create suggestions from preceding letters (for middle/ending hotstrings)
        if (hsInfo.isMiddle || hsInfo.isEnding) {
            this._CreatePrecedingLetterSuggestions(hsInfo, matchInfo)
        }
        
        ; Create suggestions from following letters (for middle/beginning hotstrings)
        if (hsInfo.isMiddle || hsInfo.isBeginning) {
            this._CreateFollowingLetterSuggestions(hsInfo, matchInfo)
        }
    }
    
    ; Create suggestions by adding letters to the beginning
    static _CreatePrecedingLetterSuggestions(hsInfo, matchInfo) {
        ; Sort preceding letters by frequency
        precedingLetters := matchInfo.preceding
        
        ; Take up to 5 most common letters
        count := 0
        for beforeLetter, frequency in precedingLetters {
            ; Create new trigger and replacement
            newTrigger := beforeLetter . hsInfo.trigger
            newReplacement := beforeLetter . hsInfo.replacement
            
            ; Get fix count for this variation
            variationKey := beforeLetter . StrLower(hsInfo.replacement)
            fixCount := matchInfo.variations.Has(variationKey) ? matchInfo.variations[variationKey] : 0
            
            ; Only add if it fixes at least one word
            if (fixCount > 0) {
                description := "Add '" beforeLetter "' to beginning"
                if (frequency > 3)
                    description .= "   >>>---->"
                    
                this._AddSuggestion(hsInfo.options, newTrigger, newReplacement, description, fixCount)
                
                count++
                if (count >= 5)
                    break
            }
        }
    }
    
    ; Create suggestions by adding letters to the end
    static _CreateFollowingLetterSuggestions(hsInfo, matchInfo) {
        ; Sort following letters by frequency
        followingLetters := matchInfo.following
        
        ; Take up to 5 most common letters
        count := 0
        for afterLetter, frequency in followingLetters {
            ; Create new trigger and replacement
            newTrigger := hsInfo.trigger . afterLetter
            newReplacement := hsInfo.replacement . afterLetter
            
            ; Get fix count for this variation
            variationKey := StrLower(hsInfo.replacement) . afterLetter
            fixCount := matchInfo.variations.Has(variationKey) ? matchInfo.variations[variationKey] : 0
            
            ; Only add if it fixes at least one word
            if (fixCount > 0) {
                description := "Add '" afterLetter "' to end"
                if (frequency > 3)
                    description .= "   >>>---->"
                    
                this._AddSuggestion(hsInfo.options, newTrigger, newReplacement, description, fixCount)
                
                count++
                if (count >= 5)
                    break
            }
        }
    }
    
    ; Add the original hotstring as a reference suggestion
    static _AddOriginalAsSuggestion(hsInfo) {
        ; Count original fixes
        fixCount := this._CountFixesForSuggestion(hsInfo.options, hsInfo.trigger, hsInfo.replacement)
        
        ; Add to suggestions list
        this._AddSuggestion(hsInfo.options, hsInfo.trigger, hsInfo.replacement, "Original", fixCount)
    }
    
    ; Helper method to add a suggestion to the list
    static _AddSuggestion(options, trigger, replacement, description, fixCount) {
        this.Suggestions.Push({
            options: options,
            trigger: trigger,
            replacement: replacement,
            description: description,
            fixCount: fixCount,
            hotstring: ":" options ":" trigger "::" replacement,
            webFrequency: 0  ; Will be calculated later
        })
    }

    ; Helper method to check if a suggestion would fix at least one word
    static _CountFixesForSuggestion(options, trigger, replacement) {
        return this._FindMatches(replacement, options).Length
    }
    
    ; Calculate web frequencies for all suggestions
    static _CalculateFrequenciesForSuggestions() {
        ; Skip if frequency data not loaded
        if (!this.FreqDataLoaded) {
            Debug("Frequency data not loaded, skipping frequency calculations")
            return
        }
        
        ; Process each suggestion
        for idx, suggestion in this.Suggestions {
            ; Call the frequency calculation function for the replacement
            webFreq := this._CalculateHotstringFrequency(suggestion)
            
            ; Update the suggestion object with the frequency
            suggestion.webFrequency := webFreq
        }
    }
    
    ; Calculate frequency for a single hotstring suggestion
    static _CalculateHotstringFrequency(suggestion) {
        ; Parse the replacement to determine hotstring type
        hsInfo := {
            replacement: suggestion.replacement,
            isBeginning: InStr(suggestion.options, "*") && !InStr(suggestion.options, "?"),
            isEnding: !InStr(suggestion.options, "*") && InStr(suggestion.options, "?"),
            isMiddle: InStr(suggestion.options, "*") && InStr(suggestion.options, "?")
        }
        
        ; Find matching words based on the hotstring type
        matchingWords := this._FindMatchesForFrequency(hsInfo)
        
        ; Calculate total frequency
        totalFreq := 0
        
        for idx, word in matchingWords {
            if (this.WordFreqMap.Has(word))
                totalFreq += this.WordFreqMap[word]
        }
        
        return totalFreq
    }
    
    ; Find matches for frequency calculation
    static _FindMatchesForFrequency(hsInfo) {
        matches := []
        lcReplacement := StrLower(hsInfo.replacement)
        
        if (!lcReplacement || !this.WordFreqMap.Count)
            return matches
        
        ; Iterate through the word frequency map to find matches
        for word, freq in this.WordFreqMap {
            ; Skip processing if word is empty
            if (word = "")
                continue
                
            if (hsInfo.isMiddle && InStr(word, lcReplacement)) {
                matches.Push(word)
            } else if (hsInfo.isBeginning && SubStr(word, 1, StrLen(lcReplacement)) = lcReplacement) {
                matches.Push(word)
            } else if (hsInfo.isEnding) {
                ; Check if the word ends with the replacement
                wordLength := StrLen(word)
                replLength := StrLen(lcReplacement)
                
                if (wordLength >= replLength) {
                    endPortion := SubStr(word, wordLength - replLength + 1)
                    if (endPortion = lcReplacement) {
                        matches.Push(word)
                    }
                }
            } else if (!hsInfo.isBeginning && !hsInfo.isEnding && !hsInfo.isMiddle && word = lcReplacement) {
                matches.Push(word)
            }
        }
        
        return matches
    }
    
    ; Helper method to convert a Map to a string for debugging
    static _MapToString(map) {
        result := ""
        for key, value in map
            result .= key . ":" . value . ", "
        return RTrim(result, ", ")
    }
    
    ; Find matches for a word pattern based on options
    static _FindMatches(word, options) {
        matches := []
        isBeginning := InStr(options, "*") && !InStr(options, "?")
        isEnding := !InStr(options, "*") && InStr(options, "?")
        isMiddle := InStr(options, "*") && InStr(options, "?")
        
        for dictWord in this.LoadedWordList {
            if (isMiddle && InStr(dictWord, word)) {
                matches.Push(dictWord)
            } else if (isBeginning && InStr(SubStr(dictWord, 1, StrLen(word)), word)) {
                matches.Push(dictWord)
            } else if (isEnding && InStr(SubStr(dictWord, -StrLen(word)), word)) {
                matches.Push(dictWord)
            } else if (!isBeginning && !isEnding && !isMiddle && dictWord = word) {
                matches.Push(dictWord)
            }
        }
        
        return matches
    }
    
    ; Format web frequency for display
    static _FormatWebFrequency(freq) {
        ; Return 0 if frequency is 0
        if (freq = 0)
            return "0"
            
        ; Format in millions with 2 decimal places
        return Format("{:.2f}m", freq / 1000000)
    }
    
    static _ShowSimpleProgress(title, message := "Processing...") {
        ; Create a simple progress GUI
        progressGui := Gui("+AlwaysOnTop -MinimizeBox -SysMenu")
        
        ; Use theme colors
        progressGui.BackColor := this.Config.FormColor
        progressGui.SetFont("s12 c" (this.Config.FontColor ? this.Config.FontColor : ""))
        progressGui.Title := title
        
        progressGui.Add("Text", "w300 Center", message)
        
        ; Use theme color for progress bar
        progressBar := progressGui.Add("Progress", "w300 h20 c" this.Config.ProgressColor " Background" this.Config.FormColor " Range0-100", 0)
        
        progressGui.Show("AutoSize")
        
        return {gui: progressGui, bar: progressBar}
    }
    
    static _ShowSuggestionDashboard(hsInfo) {
        ; Create new suggestion window
        this.SuggestGui := Gui()
        this.SuggestGui.SetFont("s12 c" (this.Config.FontColor ? this.Config.FontColor : ""))
        this.SuggestGui.BackColor := this.Config.FormColor
        
        ; Calculate total width based on column widths
        totalWidth := 650 ; Increased to add space for frequency column
        
        ; Title and original hotstring info - adjusted width to match ListView
        this.SuggestGui.Add("Text", "w" totalWidth, "Original hotstring: " . this.CurrentHotstring)
        this.SuggestGui.Add("Text", "y+5", "Type: " . (hsInfo.isMiddle ? "Word-Middle" : 
                                            hsInfo.isBeginning ? "Word-Beginning" : 
                                            hsInfo.isEnding ? "Word-Ending" : "Regular"))
        
        ; Create a ListView with four columns (added Web Freq column)
        columnHeaders := ["Suggestion", "Description", "Fixes", "Web Freq"]
        
        ; Use list color for ListView background
        listViewOpts := "w" totalWidth " r15 Grid"
        if (this.Config.ListColor)
            listViewOpts .= " Background" this.Config.ListColor
            
        listView := this.SuggestGui.Add("ListView", listViewOpts, columnHeaders)
        
        ; Set column widths
        listView.ModifyCol(1, 175)  ; Suggestion
        listView.ModifyCol(2, 250)  ; Description
        listView.ModifyCol(3, 75)   ; Fixes
        listView.ModifyCol(4, 100)  ; Web Frequency
        
        ; Populate the ListView with frequency data
        for idx, suggestion in this.Suggestions {
            ; Format the web frequency
            formattedFreq := this._FormatWebFrequency(suggestion.webFrequency)
            
            ; Add suggestion to the ListView
            listView.Add(, 
                suggestion.hotstring,
                suggestion.description,
                suggestion.fixCount,
                formattedFreq
            )
        }
        
        ; Set numeric sort for Fixes and Web Freq columns
        listView.ModifyCol(3, "Integer")  ; Sort Fixes column as numbers
        listView.ModifyCol(4, "Float")    ; Sort Web Freq column as numbers
        
        ; Add text and selected suggestion edit box with theme colors
        this.SuggestGui.Add("Text", "y+10", "Selected suggestion:")
        
        ; Use theme color for edit control background - same width as ListView
        editOpts := "w" totalWidth " ReadOnly"
        if (this.Config.ListColor)
            editOpts .= " Background" this.Config.ListColor
            
        selectedHs := this.SuggestGui.Add("Edit", editOpts, "")
        
        ; Add action buttons - centered within total width
        buttonY := "y+10"
        buttonWidth := 180
        buttonSpacing := (totalWidth - (buttonWidth * 3)) / 2  ; Space between buttons
        
        sendToHHButton := this.SuggestGui.Add("Button", buttonY " w" buttonWidth, "Send to HH")
        sendToHHButton.OnEvent("Click", this._SendToHotStringHelperHandler.Bind(this, selectedHs))
        
        copyButton := this.SuggestGui.Add("Button", "x+" buttonSpacing " w" buttonWidth, "Copy to Clipboard")
        copyButton.OnEvent("Click", this._CopyToClipboardHandler.Bind(this, selectedHs))
        
        closeButton := this.SuggestGui.Add("Button", "x+" buttonSpacing " w" buttonWidth, "Close")
        closeButton.OnEvent("Click", this._CloseGuiHandler.Bind(this))
        
        ; Update selected hotstring when item is selected
        listView.OnEvent("ItemSelect", this._ItemSelectHandler.Bind(this, listView, selectedHs))
        
        ; Double-click to select and send to HH
        listView.OnEvent("DoubleClick", this._DoubleClickHandler.Bind(this, listView))
        
        ; Show the GUI
        this.SuggestGui.Show("AutoSize")
        
        ; Select the first item by default
        if (this.Suggestions.Length > 0) {
            listView.Modify(1, "Select Focus")
            selectedHs.Value := this.Suggestions[1].hotstring
        }
    }

    ; Handler functions for button events
    static _SendToHotStringHelperHandler(selectedHs, *) {
        this._SendToHotStringHelper(selectedHs.Value)
    }
    
    static _CopyToClipboardHandler(selectedHs, *) {
        this._CopyToClipboard(selectedHs.Value)
    }
    
    static _CloseGuiHandler(*) {
        this.SuggestGui.Hide()  ; Hide instead of destroy
        
        ; Show the main ACLogAnalyzer GUI if it exists
        if (IsSet(ACLogAnalyzer) && IsObject(ACLogAnalyzer) && IsObject(ACLogAnalyzer.ACAGui))
            ACLogAnalyzer.ACAGui.Show()
    }
    
    static _ItemSelectHandler(listView, selectedHs, ctrl, *) {
        rowNum := ctrl.GetNext()
        if (rowNum > 0) {
            ; Get the hotstring value directly from the ListView row
            selectedHs.Value := listView.GetText(rowNum, 1)  ; Column 1 contains the hotstring
        }
    }
    
    static _DoubleClickHandler(listView, ctrl, *) {
        rowNum := ctrl.GetNext()
        if (rowNum > 0) {
            ; Get the hotstring value directly from the ListView row
            hotstring := listView.GetText(rowNum, 1)  ; Column 1 contains the hotstring
            this._SendToHotStringHelper(hotstring)
        }
    }
    
    static _SendToHotStringHelper(hotstring) {
        if (!hotstring)
            return
        
        ; Try different approaches to get the script name
        myACFileBaseName := ""
        try {
            ; First try using ACLogAnalyzer if it exists
            if (IsSet(ACLogAnalyzer) && IsObject(ACLogAnalyzer) && ACLogAnalyzer.HasOwnProp("Config") 
                && ACLogAnalyzer.Config.HasOwnProp("ScriptFiles") && ACLogAnalyzer.Config.ScriptFiles.HasOwnProp("ACScript")) {
                myACFileBaseName := StrSplit(ACLogAnalyzer.Config.ScriptFiles.ACScript, ".")[1]
            } 
            ; Fall back to "AutoCorrect2" which is the standard name
            else {
                myACFileBaseName := "AutoCorrect2"
            }
        } catch {
            ; Absolute fallback
            myACFileBaseName := "AutoCorrect2"
        }
        
        try {
            if (!FileExist(myACFileBaseName . ".exe")) {
                MsgBox("Error: " myACFileBaseName ".exe not found in the current directory.")
                return
            }
            
            Run(myACFileBaseName ".exe /script " ACLogAnalyzer.Config.ScriptFiles.ACScript " " hotstring)
        } catch Error as err {
            Debug("Error sending to HotString Helper: " err.Message)
            
            ; Show the GUI again if there was an error
            this.SuggestGui.Show()
        }
    }
    
    ; Copy the selected suggestion to clipboard
    static _CopyToClipboard(hotstring) {
        if (!hotstring)
            return
            
        A_Clipboard := hotstring
        ToolTip("Copied to clipboard!")
        
        ; Use anonymous function for timer
        SetTimer(() => ToolTip(), -2000)
    }
}

; Handler function for the Suggest button in ACLogAnalyzer
SuggestAlternativesHandler(*) {
    result := ACLogAnalyzer.ProcessSelectedItem()
    if (!result)
        return
        
    ; Extract just the hotstring part
    fullItem := result.workingItem
    
    ; Check if it has weight information and format with "for"
    if InStr(fullItem, "is weight for ->") {
        ; Extract just the hotstring part
        hotstringPart := RegExReplace(fullItem, ".*for\s+(.*)$", "$1")
    }
    else if InStr(fullItem, "<<") || InStr(fullItem, "--") {
        ; Extract just the hotstring part
        hotstringPart := RegExReplace(fullItem, ".*for\s+(.*)$", "$1")
    }
    else {
        ; Assume it's already just the hotstring
        hotstringPart := fullItem
    }
    
    hotstringPart := Trim(hotstringPart)
    ACLogAnalyzer.WorkingItem := hotstringPart
    
    ; Hide the main report GUI instead of closing it
    if (IsObject(ACLogAnalyzer.ACAGui))
        ACLogAnalyzer.ACAGui.Hide()
    
    ; Create progress indicator and analyze
    try {
        ; Get word list path
        wordListPath := A_ScriptDir "\WordListsForHH\GitHubComboList249k.txt"
        
        ; Initialize the suggester
        HotstringSuggester.Init(hotstringPart, wordListPath)
    } catch Error as err {
        Debug("Error initializing Suggestion feature: " err.Message)
        
        ; Show the main report GUI again if there was an error
        if (IsObject(ACLogAnalyzer.ACAGui))
            ACLogAnalyzer.ACAGui.Show()
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
