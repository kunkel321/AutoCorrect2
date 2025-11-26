/*
=====================================================
        HOTSTRING LIBRARY STATISTICS ANALYZER
                Version: 11-26-2025
=====================================================

Made by kunkel321, using Claude AI, for the AutoCorrect2 Suite.
            github.com/kunkel321/autocorrect2 

Analyzes usage statistics for all hotstrings in HotstringLib.ahk
(between "MARK: No Sort" and "MARK: End Main List" sections).

Reports statistics from AutoCorrectsLog.txt showing:
- How many times each hotstring was backspaced (<<)
- How many times each hotstring was kept (--)

Displays results in a ListView that can be sorted by clicking column headers.
Items are shown in clean format: :Options:Trigger::Replacement

Intended for use with kunkel321's AutoCorrect for v2.

Dependencies:
- HotstringLib.ahk
- AutoCorrectsLog.txt
- acSettings.ini
- ColorThemeSettings.ini

Recommend keeping this file in AutoCorrect2\Tools\
*/

#SingleInstance Force
#Requires AutoHotkey v2+

; ======= Main Class Definition =======
class HotstringLibStats {
    
    ; ======= Configuration Property =======
    ; Loads configuration from acSettings.ini
    static Config {
        get {
            settingsFile := "..\Data\acSettings.ini"
            
            if !FileExist(settingsFile) {
                MsgBox(settingsFile " was not found. Please run AutoCorrect2 first to create the file.")
                ExitApp
            }
            
            config := {
                HotstringLibraryFile: "..\Core\" IniRead(settingsFile, "Files", "HotstringLibrary", "..\Core\HotstringLib.ahk"),
                AutoCorrectsLogFile: "..\Data\" IniRead(settingsFile, "Files", "AutoCorrectsLogFile", "..\Data\AutoCorrectsLog.txt"),
                SettingsFile: settingsFile
            }
            
            return config
        }
    }
    
    ; ======= Static Properties =======
    static LSGui := ""
    static ReportListView := ""
    static LibraryItems := []  ; Array of {hotstring, trigger, replacement, bs, ok}
    static FontColor := "Default"
    static ListColor := "Default"
    static FormColor := "Default"
    
    ; Regex to parse hotstrings from library (handles f() function format and basic format)
    static HsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<Comm>\h+;.+)?$"
    
    ; ======= Public Methods =======
    
    ; Entry point - Run the analyzer
    static Run() {
        this.Initialize()
        this.Main()
    }
    
    ; Initialize settings and properties
    static Initialize() {
        this.LoadThemeSettings()
        TraySetIcon("..\Resources\Icons\AcAnalysis.ico")
    }
    
    ; Main processing function
    static Main() {
        try {
            ; Verify library file exists
            if !FileExist(this.Config.HotstringLibraryFile) {
                MsgBox("File '" this.Config.HotstringLibraryFile "' not found.")
                ExitApp
            }
            
            ; Parse hotstrings from library
            this.ParseLibraryItems()
            
            ; Load usage statistics from log
            this.LoadLogStatistics()
            
            ; Display results
            this.ShowResults()
            
        } catch Error as err {
            MsgBox("An error occurred:`n" err.Message)
            ExitApp
        }
    }
    
    ; ======= Library Parsing =======
    
    ; Parse hotstrings from HotstringLib.ahk between the markers
    static ParseLibraryItems() {
        try {
            content := FileRead(this.Config.HotstringLibraryFile)
            
            ; Find the start and end markers
            startMarker := "; MARK: No Sort"
            endMarker := "; MARK: End Main List"
            
            startPos := InStr(content, startMarker)
            endPos := InStr(content, endMarker)
            
            if (startPos = 0 || endPos = 0) {
                MsgBox("Could not find library markers. Looking for:`n'" startMarker "'`nand`n'" endMarker "'")
                return
            }
            
            ; Extract the section between markers
            startPos += StrLen(startMarker)
            section := SubStr(content, startPos, endPos - startPos)
            
            ; Parse each line
            this.LibraryItems := []
            Loop Parse section, "`n`r" {
                line := Trim(A_LoopField)
                
                ; Skip empty lines and comments
                if (line = "" || SubStr(line, 1, 1) = ";")
                    continue
                
                ; Try to parse as hotstring
                parsed := this.ParseHotstring(line)
                if (parsed != "") {
                    item := {
                        hotstring: this.BuildCleanHotstring(parsed.Opts, parsed.Trigger, parsed.Replacement),
                        trigger: parsed.Trigger,
                        replacement: parsed.Replacement,
                        bs: 0,
                        ok: 0
                    }
                    this.LibraryItems.Push(item)
                }
            }
            
        } catch Error as err {
            MsgBox("Error parsing library: " err.Message)
        }
    }
    
    ; Parse a single hotstring line
    ; Returns object with Opts, Trigger, Replacement, or empty string if parsing fails
    static ParseHotstring(line) {
        if (RegExMatch(line, this.HsRegex, &match)) {
            replacement := Trim(match.Repl)
            ; Strip surrounding quotes if present (from f() function format)
            if (SubStr(replacement, 1, 1) = '"' && SubStr(replacement, -1) = '"')
                replacement := SubStr(replacement, 2, StrLen(replacement) - 2)
            
            return {
                Opts: match.Opts,
                Trigger: match.Trig,
                Replacement: replacement
            }
        }
        return ""
    }
    
    ; Build clean hotstring format from parsed components
    ; Removes B0X from options since it's only for f() function support
    static BuildCleanHotstring(opts, trigger, replacement) {
        cleanOpts := RegExReplace(opts, "B0X", "")
        return ":" cleanOpts ":" trigger "::" replacement
    }
    
    ; ======= Log Statistics Loading =======
    
    ; Load statistics from AutoCorrectsLog.txt and match against library items
    static LoadLogStatistics() {
        try {
            if !FileExist(this.Config.AutoCorrectsLogFile)
                return  ; No log file means all items will show 0/0
            
            logContent := FileRead(this.Config.AutoCorrectsLogFile)
            
            ; Build a Map for quick lookup: key = "trigger::replacement" value = {bs, ok}
            logStats := Map()
            
            Loop Parse logContent, "`n`r" {
                line := A_LoopField
                
                if (StrLen(line) < 15)
                    continue
                
                ; Extract action type (-- or <<) at position 12, length 2
                actionType := SubStr(line, 12, 2)
                
                ; Extract hotstring starting at position 15
                logHotstring := SubStr(line, 15)
                
                ; Parse the log hotstring
                parsed := this.ParseHotstring(logHotstring)
                if (parsed = "")
                    continue
                
                ; Build key for lookup
                key := parsed.Trigger "::" Trim(parsed.Replacement)
                
                ; Initialize or update stats
                if (!logStats.Has(key)) {
                    logStats[key] := {bs: 0, ok: 0}
                }
                
                if (actionType = "--") {
                    logStats[key].ok++
                } else if (actionType = "<<") {
                    logStats[key].bs++
                }
            }
            
            ; Update library items with statistics
            for idx, item in this.LibraryItems {
                key := item.trigger "::" item.replacement
                if (logStats.Has(key)) {
                    stats := logStats[key]
                    item.bs := stats.bs
                    item.ok := stats.ok
                }
            }
            
        } catch Error as err {
            ; Silently continue - log may not exist yet
        }
    }
    
    ; ======= Results Display =======
    
    ; Create and show the results GUI with ListView
    static ShowResults() {
        try {
            this.LSGui := Gui()
            this.LSGui.Title := "Hotstring Library Statistics"
            this.LSGui.Opt("+AlwaysOnTop")
            
            ; Set fonts and colors
            this.LSGui.SetFont("s11", "Segoe UI")
            if (this.FormColor != "Default")
                this.LSGui.BackColor := this.FormColor
            
            if (this.FontColor != "Default")
                this.LSGui.SetFont("c" this.FontColor)
            
            ; Title text
            this.LSGui.Add("Text", "w470 h20", "Library Statistics: " this.LibraryItems.Length " items found")
            
            ; Create ListView
            this.CreateListView()
            
            ; Create button bar
            this.CreateButtonBar()
            
            ; Event handlers
            this.LSGui.OnEvent("Escape", (*) => ExitApp())
            
            ; Show GUI
            this.LSGui.Show("AutoSize")
            
        } catch Error as err {
            MsgBox("Error displaying results: " err.Message)
            ExitApp
        }
    }
    
    ; Create the ListView with library items
    static CreateListView() {
        try {
            lvOptions := "w550 r25 Grid"
            if (this.ListColor != "Default")
                lvOptions .= " Background" this.ListColor
            
            this.ReportListView := this.LSGui.Add("ListView", "y+5 " lvOptions,
                ["Hotstring", "BS", "OK"])
            
            ; Set column widths
            this.ReportListView.ModifyCol(1, 350)  ; Hotstring
            this.ReportListView.ModifyCol(2, 60)   ; BS
            this.ReportListView.ModifyCol(3, 60)   ; OK
            
            ; Set column alignment
            this.ReportListView.ModifyCol(2, "Integer Right")
            this.ReportListView.ModifyCol(3, "Integer Right")
            
            ; Populate with items in library order
            for idx, item in this.LibraryItems {
                this.ReportListView.Add(, item.hotstring, item.bs, item.ok)
            }
            
            ; Add double-click handler to copy to clipboard
            this.ReportListView.OnEvent("DoubleClick", this.OnDoubleClick.Bind(this))
            
            ; Select first item
            if (this.LibraryItems.Length > 0)
                this.ReportListView.Modify(1, "Select Focus")
            
        } catch Error as err {
            MsgBox("Error creating ListView: " err.Message)
        }
    }
    
    ; Create action buttons
    static CreateButtonBar() {
        buttons := [
            {label: "Copy", callback: this.CopySelected.Bind(this)},
            {label: "Close", callback: (*) => ExitApp()}
        ]
        
        for idx, btn in buttons {
            buttonOpts := (idx > 1 ? "x+5 " : "y+10 ")
            newBtn := this.LSGui.Add("Button", buttonOpts "w80 h30", btn.label)
            newBtn.OnEvent("Click", btn.callback)
        }
    }
    
    ; ======= Event Handlers =======
    
    ; Double-click handler - copy hotstring to clipboard
    static OnDoubleClick(GuiCtrlObj, Item) {
        if (Item > 0 && Item <= this.LibraryItems.Length) {
            hotstring := this.LibraryItems[Item].hotstring
            A_Clipboard := hotstring
            ToolTip("Copied: " hotstring)
            SetTimer(() => ToolTip(), 2000)
        }
    }
    
    ; Copy button handler
    static CopySelected(*) {
        selectedRow := this.ReportListView.GetNext(0)
        if (selectedRow > 0 && selectedRow <= this.LibraryItems.Length) {
            hotstring := this.LibraryItems[selectedRow].hotstring
            A_Clipboard := hotstring
            ToolTip("Copied: " hotstring)
            SetTimer(() => ToolTip(), 2000)
        }
    }
    
    ; ======= Theme Loading =======
    
    ; Load visual theme settings from colorThemeSettings.ini
    static LoadThemeSettings() {
        try {
            themeFile := ""
            if FileExist("..\Data\colorThemeSettings.ini")
                themeFile := "..\Data\colorThemeSettings.ini"
            else if FileExist("..\..\Data\colorThemeSettings.ini")
                themeFile := "..\..\Data\colorThemeSettings.ini"
            
            if (themeFile != "") {
                this.FontColor := IniRead(themeFile, "ColorSettings", "fontColor", "Default")
                this.ListColor := IniRead(themeFile, "ColorSettings", "listColor", "Default")
                this.FormColor := IniRead(themeFile, "ColorSettings", "formColor", "Default")
            }
        } catch Error {
            ; Use defaults silently
        }
    }
}

; ======= Execution =======
HotstringLibStats.Run()
