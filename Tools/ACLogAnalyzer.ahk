/*
=====================================================
            AUTO CORRECTION LOG ANALYZER
                Updated: 11-8-2025 
=====================================================
Determines frequency of items in AutoCorrects Log file, then sorts by frequency (or weight).
Date not factored in sort. Reports the top X hotstrings that were immediately followed
by 'Backspace' (<<), and how many times they were used without backspacing (--).
Sort by one or the other, or sort by "weight". 

Intended for use with kunkel321's
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
    ; Static configuration - Load from acSettings.ini
    static Config {
        get {
            settingsFile := "..\Data\acSettings.ini"
            
            ; Verify settings file exists
            if !FileExist(settingsFile) {
                MsgBox(settingsFile " was not found. Please run AutoCorrect2 first to create the file.")
                ExitApp
            }
            
            ; Build config object from ini file
            config := {
                FreqImportance: Integer(IniRead(settingsFile, "ACLogAnalyzer", "FreqImportance", 25)),
                IgnoreFewerThan: Integer(IniRead(settingsFile, "ACLogAnalyzer", "IgnoreFewerThan", 0)),
                CopyHotstringOnSelect: Integer(IniRead(settingsFile, "ACLogAnalyzer", "CopyHotstringOnSelect", 1)),
                PinToTop: Integer(IniRead(settingsFile, "ACLogAnalyzer", "PinToTop", 1)) = 1,
                EnableErrorLogging: Integer(IniRead(settingsFile, "ACLogAnalyzer", "EnableErrorLogging", 1)),
                StartLine: Integer(IniRead(settingsFile, "ACLogAnalyzer", "StartLine", 7)),
                CullDateFormat: IniRead(settingsFile, "ACLogAnalyzer", "CullDateFormat", "MM-dd-yyyy"),
                EditorPath: "",
                ScriptFiles: {
                    ACScript:       "..\Core\" IniRead(settingsFile, "Files", "AutoCorrect2Script", "..\Core\AutoCorrect2.ahk"),
                    HSLibrary:      "..\Core\" IniRead(settingsFile, "Files", "HotstringLibrary", "..\Core\HotstringLib.ahk"),
                    ACLog:          "..\Data\" IniRead(settingsFile, "Files", "AutoCorrectsLogFile", "..\Data\AutoCorrectsLog.txt"),
                    ErrContLog:     "..\Data\" IniRead(settingsFile, "Files", "ErrContextLog", "..\Data\ErrContextLog.txt"),
                    RemovedHsFile:  "..\Data\" IniRead(settingsFile, "Files", "RemovedHsFile", "..\Data\RemovedHotstrings.txt")
                }
            }
            
            return config
        }
    }

    ; State tracking properties
    static ReportArray := []
    static ParsedItems := []  ; Structured data for ListView: {hotstring, bs, ok, total, weight}
    static ReportListView := ""  ; Reference to the ListView control
    static PinCheckbox := ""     ; Reference to the pin checkbox
    static HelpButton := ""      ; Reference to the help button
    static ActionButtons := Map()  ; Map of action buttons
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
        TraySetIcon("..\Resources\Icons\AcAnalysis.ico")
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
            if FileExist("..\Data\colorThemeSettings.ini") {
                settingsFile := "..\Data\colorThemeSettings.ini"
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
        return "Analysis Report"
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
            ; Skip items with too few backspaces
            if (bsTally <= this.Config.IgnoreFewerThan)
                return ""
            
            ; Calculate weight using the formula
            weight := Round((bsTally / (bsTally + okTally) * 100) + bsTally * (this.Config.FreqImportance * 0.1), 1)
            return weight " is weight for ->`t" Format("{1}<< and {2}-- `tfor {3}`n", bsTally, okTally, oStr)
        } catch Error as err {
            LogError("Error in FormatReportLine: " err.Message)
            return ""
        }
    }

    ; Prepare the final report
    static PrepareReport(report) {
        try {
            ; Load context log content for reference
            this.ContextLogContent := FileExist(this.Config.ScriptFiles.ErrContLog) ? 
                FileRead(this.Config.ScriptFiles.ErrContLog) : ""
            
            ; Sort report by number (descending)
            sortedReport := Sort(Sort(report, "/U"), "NR")
            
            ; Extract all entries for display in ListView (no limit)
            trunkReport := ""
            Loop Parse sortedReport, "`n" {
                if (A_LoopField = "")
                    continue
                
                ; Format entry as-is (no context count needed for ListView)
                trunkReport .= A_LoopField "`n"
            }
            
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
        guiTitle := "AC Analysis Report"
        this.ACAGui := Gui(this.Config.PinToTop ? "+AlwaysOnTop" : "", guiTitle)
        this.ACAGui.SetFont("s12 " (this.FontColor ? "c" this.FontColor : ""))
        this.ACAGui.BackColor := this.FormColor
        
        ; Add checkbox for "Stay on top" and help button
        this.PinCheckbox := this.ACAGui.Add("CheckBox", "Checked" (this.Config.PinToTop ? "1" : "0"), "Stay on top of other windows")
        this.PinCheckbox.OnEvent("Click", (GuiCtrlObj, GuiEvent) => this.ToggleAlwaysOnTop(GuiCtrlObj))
        
        ; Add help button to the right
        this.HelpButton := this.ACAGui.Add("Button", "x+290 y20 w25 h20", "?")
        this.HelpButton.OnEvent("Click", (*) => ACLogAnalyzerHelpSystem.ShowHelp(true))
        
        ; Add static text (reset to left margin)
        this.ACAGui.Add("Text", "xm y+-8", "Selecting an item saves it to clipboard. Right-click for context.")
        
        ; Parse and display items in ListView
        this.ParseReportItems()
        this.CreateListView()
        
        ; Create action buttons
        this.CreateActionButtons()
        
        ; Show the GUI
        this.ACAGui.Show("AutoSize")
        this.ACAGui.OnEvent("Escape", (*) => ExitApp())
    }

    ; Toggle the always-on-top property
    static ToggleAlwaysOnTop(GuiCtrlObj) {
        if (GuiCtrlObj.Value) {
            WinSetAlwaysOnTop(1, "AC Analysis Report")
            this.Config.PinToTop := true
        } else {
            WinSetAlwaysOnTop(0, "AC Analysis Report")
            this.Config.PinToTop := false
        }
    }

    ; Parse report items into structured data for ListView display
    static ParseReportItems() {
        this.ParsedItems := []
        
        try {
            for idx, reportItem in this.ReportArray {
                parsed := this.ParseReportItem(reportItem)
                if (parsed)
                    this.ParsedItems.Push(parsed)
            }
        } catch Error as err {
            LogError("Error parsing report items: " err.Message)
        }
    }

    ; Parse a single report item into structured data
    ; Format: "weight is weight for ->[TAB]BS [context] << and OK -- [TAB]for :hotstring"
    ;   or:   "BS [context] << and OK -- [TAB]for :hotstring"
    static ParseReportItem(reportItem) {
        try {
            weight := ""
            data := reportItem
            
            ; Extract weight if present
            if (InStr(data, " is weight for ->")) {
                parts := StrSplit(data, " is weight for ->")
                weight := Trim(parts[1])
                data := Trim(parts[2])
            }
            
            ; Extract hotstring - look for "for :" (tab or space before it)
            ; The format is: "...-- [TAB]for :hotstring"
            forPos := 0
            if (InStr(data, "for :")) {
                forPos := InStr(data, "for :")
            }
            
            if (forPos = 0)
                return ""
            
            hotstring := Trim(SubStr(data, forPos + 4))  ; Skip "for " (4 chars)
            
            ; Extract counts from the beginning part
            ; Format: "3 [context] << and 1-- "
            countPart := Trim(SubStr(data, 1, forPos - 1))  ; Get everything before "for"
            
            bs := 0
            ok := 0
            
            ; Parse BS count (number before <<)
            if (InStr(countPart, "<<")) {
                bsPart := StrSplit(countPart, "<<")[1]
                bsMatch := RegExMatch(bsPart, "(\d+)", &m)
                if (bsMatch)
                    bs := m[1]
            }
            
            ; Parse OK count (number between "and" and "--")
            if (InStr(countPart, "--")) {
                okPart := StrSplit(countPart, "--")[1]
                okMatch := RegExMatch(okPart, "and\s+(\d+)", &m)
                if (okMatch)
                    ok := m[1]
            }
            
            total := bs + ok
            
            return {
                hotstring: hotstring,
                bs: bs,
                ok: ok,
                total: total,
                weight: weight
            }
        } catch Error as err {
            LogError("Error parsing report item: " err.Message)
            return ""
        }
    }

    ; Create ListView with parsed report items
    static CreateListView() {
        try {
            ; Create ListView with columns (always include weight)
            lvOptions := "w540 r20 Grid Sorted"
            if (this.ListColor)
                lvOptions .= " Background" this.ListColor
            
            this.ReportListView := this.ACAGui.Add("ListView", "y+10 " lvOptions,
                ["Hotstring", "BS", "OK", "Total", "Weight"])
            
            ; Set column widths
            this.ReportListView.ModifyCol(1, 250)  ; Hotstring
            this.ReportListView.ModifyCol(2, 60)   ; BS
            this.ReportListView.ModifyCol(3, 60)   ; OK
            this.ReportListView.ModifyCol(4, 60)   ; Total
            this.ReportListView.ModifyCol(5, 80)   ; Weight
            this.ReportListView.ModifyCol(2, "Integer Right")
            this.ReportListView.ModifyCol(3, "Integer Right")
            this.ReportListView.ModifyCol(4, "Integer Right")
            this.ReportListView.ModifyCol(5, "Float Right")
            
            ; Populate ListView with items (show all with weight)
            for idx, item in this.ParsedItems {
                this.ReportListView.Add(, item.hotstring, item.bs, item.ok, item.total, item.weight)
            }
            
            ; Add event handlers
            this.ReportListView.OnEvent("ItemSelect", this.OnListViewSelect.Bind(this))
            this.ReportListView.OnEvent("ContextMenu", this.OnListViewContext.Bind(this))
            
            ; Select first item by default
            if (this.ParsedItems.Length > 0)
                this.ReportListView.Modify(1, "Select Focus")
                
        } catch Error as err {
            LogError("Error creating ListView: " err.Message)
            MsgBox("Error creating ListView: " err.Message)
        }
    }

    ; Create action buttons
    static CreateActionButtons() {
        buttons := [
            {label: "Send to HH", callback: this.SendToHH.Bind(this)},
            {label: "Cull", callback: this.CullFromLog.Bind(this)},
            {label: "Lookup", callback: this.GoToHS.Bind(this)},
            {label: "Context", callback: this.SeeContext.Bind(this)},
            {label: "Suggest", callback: SuggestAlternativesHandler},
            {label: "Edit", callback: (*) => Run(this.Config.EditorPath " " A_ScriptName)},
            {label: "Close", callback: (*) => ExitApp()}
        ]
        
        this.ActionButtons := Map()  ; Clear and reinitialize
        for idx, btn in buttons {
            ; All buttons in one row with spacing
            buttonOpts := (idx > 1 ? "x+5 " : "y+10 ")
            newBtn := this.ACAGui.Add("Button", buttonOpts, btn.label)
            newBtn.OnEvent("Click", btn.callback)
            this.ActionButtons[btn.label] := newBtn  ; Store reference
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

        myACFileBaseName := StrSplit(this.Config.ScriptFiles.ACScript, ".ahk")[1]

        ;msgbox 'script file: ' myACFileBaseName
        
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

    static GoToHS(*) {
        result := this.ProcessSelectedItem()
        if (!result)
            return

        this.WorkingItem := result.workingItem
        selItemArr := StrSplit(this.WorkingItem, ":")
        selItemTrigger := selItemArr[2] ":" selItemArr[3] "::"

        hsLibPath := this.Config.ScriptFiles.HSLibrary
        hsLibFilename := StrSplit(hsLibPath, "\").Pop()
        
        try {
            if !WinExist(hsLibFilename) {
                Run(this.Config.EditorPath ' "' hsLibPath '"')
                Sleep(1500)
            }
            
            if !WinWait(hsLibFilename, , 5)     
                throw Error("Timeout waiting for HotstringLib window to open")
            
            WinActivate(hsLibFilename)  
            
            if !WinWaitActive(hsLibFilename, , 3)  
                throw Error("Failed to activate HotstringLib window")
            
            Sleep(400)  
            
            SendInput("^f")
            Sleep(300)
            SendInput(selItemTrigger)
            
        } catch Error as err {
            LogError("Error going to HS: " err.Message)
            MsgBox("Error finding hotstring in library: " err.Message)
        }

        this.ACAGui.Show()
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
                
            this.ContextGui := Gui("+AlwaysOnTop")
            this.ContextGui.SetFont("s15 " (this.FontColor ? "c" this.FontColor : ""))
            this.ContextGui.BackColor := this.FormColor
            
            ; Use an Edit control so text is selectable, but make it look like a label
            this.ContextGui.Add("Edit", "-VScroll ReadOnly -E0x200 -WantReturn -TabStop Background" this.FormColor, 
                "Context of item -- " selItemTrigger "`n======================`n" contextItems)
            
            this.ContextGui.AddButton(, "Open Log").OnEvent("Click", (*) => (this.ContextGui.Destroy(), Run(this.Config.ScriptFiles.ErrContLog), this.ACAGui.Show()))
            
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
            
        this.ConfirmGui := Gui("+AlwaysOnTop")
        this.ConfirmGui.SetFont("s12 " (this.FontColor ? "c" this.FontColor : ""))
        this.ConfirmGui.BackColor := this.FormColor
        
        ; Get the formatted item for display
        if (this.Config.WeighItems = 1) {
            if (InStr(selectedItem, "is weight for ->"))
                selectedItem := StrSplit(selectedItem, "is weight for ->	")[2]
        }
        
        this.ConfirmGui.AddText(, "Confirm culling item...`n" selectedItem "`n")
        
        ; Add checkbox for removing strings (always checked)
        remCheck := this.ConfirmGui.AddCheckbox("Checked1", 
            "Add to Removed Strings list.")
        
        ; Add notes section
        txtAddNotes := this.ConfirmGui.AddText(, "Add optional notes to culled item.")
        
        notesEditOptions := " -ReadOnly Background" this.ListColor
            
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
            if (selItemTrigger != "" && FileExist(this.Config.ScriptFiles.ErrContLog)) {
                ; Read and rewrite context log file without the culled item's contexts
                contextFileContents := FileRead(this.Config.ScriptFiles.ErrContLog)
                newContextContents := ""
                
                for contextLine in StrSplit(contextFileContents, "`n") {
                    if (contextLine != "") {
                        if (!InStr(contextLine, selItemTrigger))
                            newContextContents .= contextLine "`n"
                    }
                }
                
                try {
                    FileDelete(this.Config.ScriptFiles.ErrContLog)
                    while (FileExist(this.Config.ScriptFiles.ErrContLog))
                        Sleep(10)
                        
                    FileAppend(newContextContents, this.Config.ScriptFiles.ErrContLog)
                    ;Debug("Removed " selItemTrigger " entries from context log")
                } catch Error as err {
                    LogError("Error rewriting context log: " err.Message)
                    ; Continue anyway as the main log was updated successfully
                }
            }
            
            SoundBeep()
            
            ; Remove the item from the ListView (visual update without regenerating)
            try {
                selectedRow := this.ReportListView.GetNext()
                if (selectedRow > 0) {
                    this.ReportListView.Delete(selectedRow)
                    
                    ; Select next item if available, or previous item
                    itemCount := this.ReportListView.GetCount()
                    if (selectedRow <= itemCount) {
                        this.ReportListView.Modify(selectedRow, "Select Focus")
                    } else if (itemCount > 0) {
                        this.ReportListView.Modify(itemCount, "Select Focus")
                    }
                }
            } catch Error as err {
                LogError("Error removing item from ListView: " err.Message)
            }
            
            ; Close the confirmation GUI
            this.ConfirmGui.Destroy()
            
            ; Show the main GUI again without regenerating the report
            this.ACAGui.Show()
            
        } catch Error as err {
            LogError("Error culling item: " err.Message)
            MsgBox("Error culling item: " err.Message)
        }
    }

    ; Helper Methods =======

    ; Detect which control currently has focus
    static GetFocusedControl() {
        try {
            if this.PinCheckbox.Focused
                return "PinCheckbox"
            if this.HelpButton.Focused
                return "HelpButton"
            if this.ReportListView.Focused
                return "ListView"
        } catch {
            ; Control not found or not focused
        }
        
        ; Check action buttons
        for buttonLabel, buttonCtrl in this.ActionButtons {
            try {
                if buttonCtrl.Focused
                    return "Button_" buttonLabel
            } catch {
                continue
            }
        }
        
        return ""
    }

    ; Process the selected ListView item
    static ProcessSelectedItem() {
        try {
            ; Get selected row from ListView
            rowNum := this.ReportListView.GetNext()
            
            if (rowNum = 0) {
                MsgBox("Nothing selected.")
                return false
            }
            
            ; Get hotstring from first column of selected row
            hotstring := this.ReportListView.GetText(rowNum, 1)
            
            if (hotstring = "") {
                MsgBox("Could not extract hotstring.")
                return false
            }
            
            return {workingItem: hotstring, fullItemName: hotstring}
        } catch Error as err {
            LogError("Error processing selected item: " err.Message)
            MsgBox("Error processing selected item: " err.Message)
            return false
        }
    }

    ; Handle ListView item selection - copy hotstring to clipboard
    static OnListViewSelect(ctrl, *) {
        try {
            if (!this.Config.CopyHotstringOnSelect)
                return
            
            rowNum := ctrl.GetNext()
            if (rowNum = 0)
                return
            
            ; Get hotstring from first column
            hotstring := this.ReportListView.GetText(rowNum, 1)
            
            if (hotstring != "") {
                A_Clipboard := hotstring
                ToolTip("Hotstring copied: " hotstring)
                SetTimer(() => ToolTip(), -1500)
            }
        } catch Error as err {
            LogError("Error in OnListViewSelect: " err.Message)
        }
    }

    ; Handle ListView right-click for context menu
    static OnListViewContext(ctrl, item, *) {
        ; Select the right-clicked item
        if (item > 0) {
            this.ReportListView.Modify(item, "Select Focus")
        }
        ; Use existing context menu handler
        this.SeeContext()
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
    ;FileAppend("Sending to Suggester: " hotstringPart "`n", "..\Data\suggester_bridge_log.txt")
    
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

        ; Keep the main GUI open
        ACLogAnalyzer.ACAGui.Show()

    } catch Error as err {
        FileAppend("Error running Suggester: " err.Message "`n", "..\Data\suggester_bridge_log.txt")
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
        FileAppend("Error processing selected item: " err.Message "`n", "..\Data\suggester_bridge_log.txt")
        MsgBox("Error processing selected item: " err.Message)
        return false
    }
}

; Assign the handler to ACLogAnalyzer
ACLogAnalyzer.SuggestAlternatives := SuggestAlternativesHandler

; ======= Utility Functions =======

; Error logging function - respects EnableErrorLogging config
LogError(message) {
    if (ACLogAnalyzer.Config.EnableErrorLogging)
        FileAppend("ErrLog: " FormatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Data\acla_error_debug_log.txt")
}

; ======= Help System =======
#HotIf WinActive("AC Analysis Report")
F1::ACLogAnalyzerHelpSystem.ShowHelp()
#HotIf

class ACLogAnalyzerHelpSystem {
    static helpTexts := Map()
    static helpGui := 0
    
    ; Initialize help texts
    static Init() {
        this.helpTexts["ListView"] := "This is the Analysis Report ListView showing all analyzed hotstrings.`n`nColumns:`n- Hotstring: The hotstring from your library.  The f() function components are removed to make it easier to see.`n- BS: Number of times the item was followed by backspace within one second when logged (error indicator).`n- OK: Number of times it was logged without backspacing within one second (usefulness indicator).`n- Total: Total occurrences (BS + OK)`n- Weight: A calculated score indicating problem likelihood (higher = more problematic).  See code for adjusting weight parameters.`n`nClick a column header to sort by that column.`nSelect an item to copy the hotstring to clipboard.  Once the item is on the clipboard, you can press the HotstringHelper hotkey (Win-H) to open the item in hh.`nRight-click an item for context about what was being typed just before and after the Backspaced items were logged. This is a shortcut alternative to pressing the Context button."
        
        this.helpTexts["PinCheckbox"] := "Controls whether the Analysis Report window stays on top of other windows.`n`nWhen checked, this window will remain visible even when other applications are in focus.`n`nDefault setting can be configured in the Config section."
        
        this.helpTexts["HelpButton"] := "Click this button to show general help about the AC Log Analyzer.`n`nYou can also press F1 while focusing on any control to get specific help about that control."
        
        this.helpTexts["SendToHH"] := "Sends the selected hotstring to HotstringHelper2 for editing or analysis.`n`nThis allows you to quickly jump to editing a problematic hotstring.  Note that this button will relaunch AutoCorrect2.exe with the hotstring as a parameter.  A more efficient way to open the hotstring in HotstringHelper is to click the item (thus saving it to the clipboard), then immediately evoke HH with the hotkey (Win-H)."
        
        this.helpTexts["CullButton"] := "Removes the selected hotstring from your AutoCorrection log file and also removes the row from the listview.`n`nCulled items are also optionally added to the RemovedHotstrings file to prevent accidentally re-adding them later.`n`nThis is useful for removing hotstrings that are causing more harm than good (frequent backspaces).  You'll want to remove the item from the AutoCorrectsLog.txt file and also remove it from your HotstringsLib.ahk file"
        
        this.helpTexts["LookupButton"] := "Opens your HotString Library file in the configured editor and jumps to the selected hotstring using Ctrl+F.`n`nThis allows you to view and edit, or remove, the hotstring directly in context with your full library.  You'll want to remove it from the AutoCorrectsLog.txt file and also remove it from your HotstringsLib.ahk file."
        
        this.helpTexts["ContextButton"] := "Shows context logs for the selected hotstring.`n`nThis displays additional details about when and how the hotstring was used, helping you understand the typing context in which it occurs."
        
        this.helpTexts["SuggestButton"] := "Launches the Hotstring Suggester tool for the selected item.`n`nThis tool helps generate related hotstrings or variations based on the current entry, useful for analyzing patterns.  The Suggester tool won't send items back to the AC Analysis Report, but you'll be able to send hotstrings from the Suggester to HotstringHelper."
        
        this.helpTexts["Edit"] := "Opens this script file in your configured editor, allowing you to modify settings and configuration.`n`nChanges require restarting the script to take effect."
        
        this.helpTexts["Close"] := "Closes the AC Log Analyzer window and exits the program."
    }
    
    static ShowHelp(showGeneral := false) {
        ; Destroy existing help window if open
        if IsObject(this.helpGui)
            this.helpGui.Destroy()
        
        ; Determine help text based on context
        helpText := ""
        helpTitle := "AC Analyzer Help"
        
        if (showGeneral) {
            helpTitle := "AC Log Analyzer - Help"
            helpText := "`t`t`tWelcome to the AC Log Analyzer!`n`nThis tool is part of the package from https://github.com/kunkel321/AutoCorrect2. It analyzes your AutoCorrection log file and generates a report of logged hotstrings.  After logging many of your autocorrections via the f() functionality of AutoCorrect2.ahk, you can systematically determine which items are problematic and modify or remove them.`n`nPress F1 while focusing on a control for specific help.  Press Tab or Shift-Tab to move between controls without clicking them.`n`nPlease see the AutoCorrect2 User Manual for more information.  In-Code Configuration:`n- Adjust FreqImportance (0-50) to control the importance of occurence-frequency vs. just the OK-to-BS ratios, in weight calculation`n- Toggle error logging on/off`n- Set default 'Stay on top' behavior."
        } else {
            ; Get the currently focused control
            focusedControl := ACLogAnalyzer.GetFocusedControl()
            
            if (focusedControl && this.helpTexts.Has(focusedControl)) {
                helpText := this.helpTexts[focusedControl]
                helpTitle := "Help - " focusedControl
            } else if (InStr(focusedControl, "Button_")) {
                ; Extract button label from control name
                buttonLabel := SubStr(focusedControl, 8)  ; Remove "Button_" prefix
                helpTitle := "Help - " buttonLabel " Button"
                
                ; Provide help based on button label
                switch buttonLabel {
                    case "Send to HH":
                        helpText := this.helpTexts["SendToHH"]
                    case "Cull":
                        helpText := this.helpTexts["CullButton"]
                    case "Lookup":
                        helpText := this.helpTexts["LookupButton"]
                    case "Context":
                        helpText := this.helpTexts["ContextButton"]
                    case "Suggest":
                        helpText := this.helpTexts["SuggestButton"]
                    default:
                        helpText := "Button: " buttonLabel "`n`nPress F1 while focusing on a specific control for detailed help."
                }
            }
        }
        
        ; Fallback to general help if no specific text found
        if (helpText = "") {
            helpTitle := "AC Log Analyzer - Help"
            helpText := "Welcome to the AC Log Analyzer!`n`nThis tool is part of the package from https://github.com/kunkel321/AutoCorrect2. It analyzes your AutoCorrection log file and generates a report of logged hotstrings.  After logging many of your autocorrections via the f() functionality of AutoCorrect2.ahk, you can systematically determine which items are problematic and modify or remove them.`n`nPress F1 while focusing on a control for specific help.  Press Tab or Shift-Tab to move between buttons.`n`nPlease see the AutoCorrect2 User Manual for more information.  In-Code Configuration:`n- Adjust FreqImportance (0-50) to control the importance of occurence-frequency vs. just the OK-to-BS ratios, in weight calculation`n- Toggle error logging on/off`n- Set default 'Stay on top' behavior"
        }
        
        ; Create help GUI
        this.helpGui := Gui("AlwaysOnTop", helpTitle)
        this.helpGui.SetFont("s10", "Courier New")
        fontColor := ACLogAnalyzer.FontColor != "" ? "c" SubStr(ACLogAnalyzer.FontColor, -6) : ""
        this.helpGui.SetFont(fontColor)
        this.helpGui.BackColor := ACLogAnalyzer.FormColor
        
        ; Use an Edit control for selectable text
        this.helpGui.Add("Edit", "w700 h300 -VScroll ReadOnly -E0x200 -WantReturn -TabStop Background" ACLogAnalyzer.FormColor, helpText)
        
        ; Add close button
        closeBtn := this.helpGui.AddButton("Default", "Close")
        closeBtn.OnEvent("Click", (*) => this.helpGui.Destroy())
        
        ; Show the help window
        this.helpGui.Show()
        
        ; Set up event handlers
        this.helpGui.OnEvent("Escape", (*) => this.helpGui.Destroy())
    }
}

; Initialize help system
ACLogAnalyzerHelpSystem.Init()

; ======= Main Execution =======
; Run the analyzer when script is executed directly
if (A_ScriptName = "ACLogAnalyzer.ahk") {
    ACLogAnalyzer.Run()
}

fontColor := ACLogAnalyzer.fontColor
formColor := ACLogAnalyzer.formColor
listColor := ACLogAnalyzer.listColor

; End of the part that Steve Kunkel321 made... 

; .QQQQQQQQQQQQQQQQ...QQQQQQQQQQQQQQQQ..............QQQQQQQ...
; QQQQQQQQQQQQQQQQQ..QQQQQQQQQQQQQQQQQ...........QQQQQQQQQQ...
; QQQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ.........QQQQQQQQQQQ....
; QQQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ........QQQQQQQQQ..QQQQQ
; QQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ........QQQQQQQQ...QQQQQQQ
; QQQQQQQQQQQQQ.....QQQQQQQQQQQQQQ..........QQQQQQQ...QQQQQQQQQ
; .....QQQQQQQQ...........QQQQQQQQ.........QQQQQQQ....QQQQQQQQQQ
; .....QQQQQQQQ...........QQQQQQQQ........QQQQQQQQ....QQQQQQQQQQ
; ....QQQQQQQQQ..........QQQQQQQQQ........QQQQQQQ.....QQQQQQQQQQQ
; ....QQQQQQQQ...........QQQQQQQQ........QQQQQQQQ......QQQQQQQQQQ
; ....QQQQQQQQ...........QQQQQQQQ.......QQQQQQQQ.......QQQQQQQQQQ
; ...QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQ........QQQQQQQQ
; ...QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ........QQQQQQQQ
; ...QQQQQQQQ...........QQQQQQQQ.......QQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ.........QQQQQQ
; .QQQQQQQQQQ.........QQQQQQQQQQ......QQQQQQQQQ.........QQQQQQ
; .QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQQ........QQQQQQ.
; .QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQQQ.......QQQQQQ.
; QQQQQQQQQQ.........QQQQQQQQQQ.......QQQQQQQQQQ......QQQQQQ..
; QQQQQQQQQ..........QQQQQQQQQ.........QQQQQQQQQ......QQQQQQ..
; QQQQQQQQQ..........QQQQQQQQQ.........QQQQQQQQQQ....QQQQQQ...
; QQQQQQQQQ..........QQQQQQQQQ..........QQQQQQQQQQ.QQQQQQQ....
; QQQQQQQQ...........QQQQQQQQ............QQQQQQQQQQQQQQQQ.....
; QQQQQQQ............QQQQQQQ..............QQQQQQQQQQQQQ.......
; .QQQQQ..............QQQQQ.................QQQQQQQQQ.........
;                       Class ToolTipOptions - 2023-09-10 
;                                      Just Me
;           https://www.autohotkey.com/boards/viewtopic.php?f=83&t=113308
; ==============================================================================
; ==============================================================================
; ==============================================================================
; ----------------------------------------------------------------------------------------------------------------------

ToolTipOptions.Init()
ToolTipOptions.SetFont("s14", "Calibri")
ToolTipOptions.SetMargins(5,5,5,5) ; Left, Top, Right, Bottom
ToolTipOptions.SetColors("0x" SubStr(ListColor, -6), "0x" SubStr(FontColor, -6))

; ----------------------------------------------------------------------------------------------------------------------

; ======================================================================================================================
; ToolTipOptions        -  additional options for ToolTips
;
; Tooltip control       -> https://learn.microsoft.com/en-us/windows/win32/controls/tooltip-control-reference
; TTM_SETMARGIN         = 1050
; TTM_SETTIPBKCOLOR     = 1043
; TTM_SETTIPTEXTCOLOR   = 1044
; TTM_SETTITLEW         = 1057
; WM_SETFONT            = 0x30
; SetClassLong()        -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclasslongw
; ======================================================================================================================
Class ToolTipOptions {
   ; -------------------------------------------------------------------------------------------------------------------
   Static HTT := DllCall("User32.dll\CreateWindowEx", "UInt", 8, "Str", "tooltips_class32", "Ptr", 0, "UInt", 3
                       , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0)
   Static SWP := CallbackCreate(ObjBindMethod(ToolTipOptions, "_WNDPROC_"), , 4) ; subclass window proc
   Static OWP := 0                                                               ; original window proc
   Static ToolTips := Map()
   ; -------------------------------------------------------------------------------------------------------------------
   Static BkgColor := ""
   Static TktColor := ""
   Static Icon := ""
   Static Title := ""
   Static HFONT := 0
   Static Margins := ""
   ; -------------------------------------------------------------------------------------------------------------------
   Static Call(*) => False ; do not create instances
   ; -------------------------------------------------------------------------------------------------------------------
   ; Init()          -  Initialize some class variables and subclass the tooltip control.
   ; -------------------------------------------------------------------------------------------------------------------
   Static Init() {
      If (This.OWP = 0) {
         This.BkgColor := ""
         This.TktColor := ""
         This.Icon := ""
         This.Title := ""
         This.Margins := ""
         If (A_PtrSize = 8)
            This.OWP := DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.SWP, "UPtr")
         Else
            This.OWP := DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.SWP, "UInt")
         OnExit(ToolTipOptions._EXIT_, -1)
         Return This.OWP
      }
      Else
         Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ;  Reset()        -  Close all existing tooltips, delete the font object, and remove the tooltip's subclass.
   ; -------------------------------------------------------------------------------------------------------------------
   Static Reset() {
      If (This.OWP != 0) {
         For HWND In This.ToolTips.Clone()
            DllCall("DestroyWindow", "Ptr", HWND)
        This.ToolTips.Clear()
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := 0
         If (A_PtrSize = 8)
            DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.OWP, "UPtr")
         Else
            DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.OWP, "UInt")
         This.OWP := 0
         Return True
      }
      Else
         Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetColors()     -  Set or remove the text and/or the background color for the tooltip.
   ; Parameters:
   ;     BkgColor    -  color value like used in Gui, Color, ...
   ;     TxtColor    -  see above.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetColors(BkgColor := "", TxtColor := "") {
      This.BkgColor := BkgColor = "" ? "" : BGR(BkgColor)
      This.TxtColor := TxtColor = "" ? "" : BGR(TxtColor)
      BGR(Color, Default := "") { ; converts colors to BGR
         ; HTML Colors (BGR)
         Static HTML := {AQUA:   0x00FFFF, BLACK: 0x000000, BLUE:   0x0000FF, FUCHSIA: 0xFF00FF, GRAY:  0x808080,
                         GREEN:  0x008000, LIME:  0x00FF00, MAROON: 0x800000, NAVY:    0x000080, OLIVE: 0x808000,
                         PURPLE: 0x800080, RED:   0xFF0000, SILVER: 0xC0C0C0, TEAL:    0x008080, WHITE: 0xFFFFFF,
                         YELLOW: 0xFFFF00 }
         If IsInteger(Color)
            Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
         Return HTML.HasProp(Color) ? HTML.%Color% : Default
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetFont()       -  Set or remove the font used by the tooltip.
   ; Parameters:
   ;     FntOpts     -  font options like Gui.SetFont(Options, ...)
   ;     FntName     -  font name like Gui.SetFont(..., Name)
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetFont(FntOpts := "", FntName := "") {
      Static HDEF := DllCall("GetStockObject", "Int", 17, "UPtr") ; DEFAULT_GUI_FONT
      Static LOGFONTW := 0
      If (FntOpts = "") && (FntName = "") {
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := 0
         LOGFONTW := 0
      }
      Else {
         If (LOGFONTW = 0) {
            LOGFONTW := Buffer(92, 0)
            DllCall("GetObject", "Ptr", HDEF, "Int", 92, "Ptr", LOGFONTW)
         }
         HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
         LOGPIXELSY := DllCall("GetDeviceCaps", "Ptr", HDC, "Int", 90, "Int")
         DllCall("ReleaseDC", "Ptr", HDC, "Ptr", 0)
         If (FntOpts != "") {
            For Opt In StrSplit(RegExReplace(Trim(FntOpts), "\s+", " "), " ") {
               Switch StrUpper(Opt) {
                  Case "BOLD":      NumPut("Int", 700, LOGFONTW, 16)
                  Case "ITALIC":    NumPut("Char",  1, LOGFONTW, 20)
                  Case "UNDERLINE": NumPut("Char",  1, LOGFONTW, 21)
                  Case "STRIKE":    NumPut("Char",  1, LOGFONTW, 22)
                  Case "NORM":      NumPut("Int", 400, "Char", 0, "Char", 0, "Char", 0, LOGFONTW, 16)
                  Default:
                     O := StrUpper(SubStr(Opt, 1, 1))
                     V := SubStr(Opt, 2)
                     Switch O {
                        Case "C":
                           Continue ; ignore the color option
                        Case "Q":
                           If !IsInteger(V) || (Integer(V) < 0) || (Integer(V) > 5)
                              Throw ValueError("Option Q must be an integer between 0 and 5!", -1, V)
                           NumPut("Char", Integer(V), LOGFONTW, 26)
                        Case "S":
                           If !IsNumber(V) || (Number(V) < 1) || (Integer(V) > 255)
                              Throw ValueError("Option S must be a number between 1 and 255!", -1, V)
                           NumPut("Int", -Round(Integer(V + 0.5) * LOGPIXELSY / 72), LOGFONTW)
                        Case "W":
                           If !IsInteger(V) || (Integer(V) < 1) || (Integer(V) > 1000)
                              Throw ValueError("Option W must be an integer between 1 and 1000!", -1, V)
                           NumPut("Int", Integer(V), LOGFONTW, 16)
                        Default:
                           Throw ValueError("Invalid font option!", -1, Opt)
                     }
                  }
               }
            }
         NumPut("Char", 1, "Char", 4, "Char", 0, LOGFONTW, 23) ; DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS
         NumPut("Char", 0, LOGFONTW, 27) ; FF_DONTCARE
         If (FntName != "")
            StrPut(FntName, LOGFONTW.Ptr + 28, 32)
         If !(HFONT := DllCall("CreateFontIndirectW", "Ptr", LOGFONTW, "UPtr"))
            Throw OSError()
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := HFONT
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetMargins()    -  Set or remove the margins used by the tooltip
   ; Parameters:
   ;     L, T, R, B  -  left, top, right, and bottom margin in pixels.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetMargins(L := 0, T := 0, R := 0, B := 0) {
      If ((L + T + R + B) = 0)
         This.Margins := 0
      Else {
         This.Margins := Buffer(16, 0)
         NumPut("Int", L, "Int", T, "Int", R, "Int", B, This.Margins)
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetTitle()      -  Set or remove the title and/or the icon displayed on the tooltip.
   ; Parameters:
   ;     Title       -  string to be used as title.
   ;     Icon        -  icon to be shown in the ToolTip.
   ;                    This can be the number of a predefined icon (1 = info, 2 = warning, 3 = error
   ;                    (add 3 to display large icons on Vista+) or a HICON handle.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetTitle(Title := "", Icon := "") {
      Switch {
         Case (Title = "") && (Icon != ""):
            This.Icon := Icon
            This.Title := " "
         Case (Title != "") && (Icon = ""):
            This.Icon := 0
            This.Title := Title
         Default:
            This.Icon := Icon
            This.Title := Title
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; For internal use only!
   ; -------------------------------------------------------------------------------------------------------------------
   Static _WNDPROC_(hWnd, uMsg, wParam, lParam) {
      ; WNDPROC -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
      Switch uMsg {
         Case 0x0411: ; TTM_TRACKACTIVATE - just handle the first message after the control has been created
            If This.ToolTips.Has(hWnd) && (This.ToolTips[hWnd] = 0) {
               If (This.BkgColor != "")
                  SendMessage(1043, This.BkgColor, 0, hWnd)                ; TTM_SETTIPBKCOLOR
               If (This.TxtColor != "")
                  SendMessage(1044, This.TxtColor, 0, hWnd)                ; TTM_SETTIPTEXTCOLOR
               If This.HFONT
                  SendMessage(0x30, This.HFONT, 0, hWnd)                   ; WM_SETFONT
               If (Type(This.Margins) = "Buffer")
                  SendMessage(1050, 0, This.Margins.Ptr, hWnd)             ; TTM_SETMARGIN
               If (This.Icon != "") || (This.Title != "")
                  SendMessage(1057, This.Icon, StrPtr(This.Title), hWnd)   ; TTM_SETTITLE
               This.ToolTips[hWnd] := 1
            }
         Case 0x0001: ; WM_CREATE
            DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "Ptr", 0, "Ptr", StrPtr(""))
            This.ToolTips[hWnd] := 0
         Case 0x0002: ; WM_DESTROY
            This.ToolTips.Delete(hWnd)
      }
      Return DllCall(This.OWP, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Static _EXIT_(*) {
      If (ToolTipOptions.OWP != 0)
         ToolTipOptions.Reset()
   }
}
; ============= Bottom of TOOLTIP OPTIONS CLASS ===============
