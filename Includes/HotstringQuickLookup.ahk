/*
=====================================================
        HOTSTRING QUICK LOOKUP TOOL
            Version: 11-23-2025
=====================================================

Allows quick lookup of individual hotstrings from the AutoCorrectsLog.txt file.
Shows how many times each hotstring was kept (--) vs backspaced (<<).  Also
allows user to view associated ErrContextLog entries, if any.

Usage:
  - Paste or type a hotstring (from library or log format)
  - Or: Select text in editor, press Ctrl+Shift+Q to auto-populate
  - Click Search or press Enter to look up
  - If no text selected when hotkey pressed, opens blank GUI with instructions

To use call: HotstringQuickLookup.ShowGui()

Dependencies: 
-AutoCorrectsLog.ahk
-ErrContextLog.txt
-acSettings.ini
-ColorThemeSettings.ini
*/

; Gets #Include'ed in AutoCorrect2.ahk, so comment-out Auto Exe section.
; #Requires AutoHotkey v2.0+
; #SingleInstance 
; ^Esc::ExitApp()

; ======= Global Hotkey Setup =======

; Hotkey: Ctrl+Shift+Q - Grab selected text and populate the lookup tool
^+q:: {
    try {
        ; Copy selected text to clipboard
        SoundBeep()
        A_Clipboard := ""
        Send("^c")
        Sleep(150)
        
        selectedText := A_Clipboard
        
        ; Show the GUI
        HotstringQuickLookup.ShowGui()
        
        if (selectedText = "") {
            ; No text selected - show helpful message
            HotstringQuickLookup.ResultText.Text := "Select a hotstring from your library and press Ctrl+Shift+Q to populate and search, or paste one here and click Search."
            return
        }
        
        HotstringQuickLookup.HotstringEdit.Text := selectedText
        
        ; Try to parse the hotstring
        parsed := HotstringQuickLookup.ParseHotstring(selectedText)
        
        ; Only auto-search if parsing was successful
        if (parsed != "")
            HotstringQuickLookup.Search()
        else
            ; If parsing fails, show guidance message
            HotstringQuickLookup.ResultText.Text := 'Could not parse hotstring. Please check the format and try again.`n`nExpected formats:`n  Library: :B0X*:trigger::f("replacement")`n  Log: :options:trigger::replacement'
        
    } catch Error as err {
        MsgBox("HOTKEY ERROR: " err.Message "`n`nLine: " err.What)
    }
}

; ======= Class Definition =======

class HotstringQuickLookup {
    ; ======= Configuration Property =======
    ; Loads configuration from acSettings.ini and constructs file paths
    ; Returns: Object with ACLog path and SettingsFile path
    static Config {
        get {
            ; Try multiple possible paths for settings file
            ; Since script is in Includes\ folder, Data is one level up (sibling folder)
            possiblePaths := [
                "..\Data\acSettings.ini",              ; From Includes\ subfolder (main path)
                "..\..\Data\acSettings.ini",           ; If nested differently
                A_ScriptDir "\Data\acSettings.ini",
                A_ScriptDir "\..\Data\acSettings.ini"
            ]
            
            settingsFile := ""
            for path in possiblePaths {
                if FileExist(path) {
                    settingsFile := path
                    break
                }
            }
            
            if (settingsFile = "") {
                MsgBox("Settings file not found. Tried:`n" 
                    . possiblePaths[1] "`n"
                    . possiblePaths[2] "`n"
                    . possiblePaths[3] "`n`n"
                    . "Make sure acSettings.ini exists in your Data folder.`n`n"
                    . "Script location: " A_ScriptDir)
                return {}
            }
            
            ; Read the filename from acSettings.ini, then construct the proper path
            logFileName := IniRead(settingsFile, "Files", "AutoCorrectsLogFile", "AutoCorrectsLog.txt")
            ; Strip any existing path prefixes - just get the filename
            logFileName := RegExReplace(logFileName, ".*\\", "")
            
            config := {
                ACLog: "..\Data\" logFileName,
                SettingsFile: settingsFile
            }
            
            return config
        }
    }
    
    static hqlGui := ""
    static HotstringEdit := ""
    static ResultText := ""
    static IsSearching := false
    static ShowContextBtn := ""
    static CurrentTrigger := ""
    static CurrentReplacement := ""
    static ContextLines := []
    static ListColor := ""
    
    ; Regex to parse hotstrings made by AndyMBody.
    static HsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<Comm>\h+;.+)?$"
    
    ; ======= Public Methods =======
    
    ; ======= GUI Creation and Display =======
    ; Creates and shows the main Hotstring Quick Lookup GUI
    ; If GUI already exists, just shows it again (restores if hidden)
    ; Sets up all controls, event handlers, and applies theme colors
    static ShowGui() {
        if (this.hqlGui != "") {
            this.hqlGui.Show()
            return
        }
        
        this.hqlGui := Gui()
        this.hqlGui.Title := "Hotstring Quick Lookup"
        this.hqlGui.Opt("+AlwaysOnTop")
        
        ; Load theme if available
        this.LoadThemeSettings()
        
        ; Set fonts and colors
        this.hqlGui.SetFont("s12", "Segoe UI")
        
        ; Title
        this.hqlGui.Add("Text", "w480 h25", "Enter a hotstring to look up:")
        
        ; Input box
        this.HotstringEdit := this.hqlGui.Add("Edit", "w480 h30 -Multi", "")
        
        ; Apply listColor as background to edit box if available
        if (this.ListColor != "")
            this.HotstringEdit.Opt("+Background" this.ListColor)
        
        ; Search button
        searchBtn := this.hqlGui.Add("Button", "w100 h30 Default", "Search")
        searchBtn.OnEvent("Click", (*) => this.Search())
        
        ; Show Context button (initially disabled, enables when context exists)
        this.ShowContextBtn := this.hqlGui.Add("Button", "w130 h30 x+5 Disabled", "Show Context")
        this.ShowContextBtn.OnEvent("Click", (*) => this.ShowContextPopup())
        
        ; Clear button
        clearBtn := this.hqlGui.Add("Button", "w70 h30 x+5", "Clear")
        clearBtn.OnEvent("Click", (*) => this.Clear())
        
        ; Cancel button
        cancelBtn := this.hqlGui.Add("Button", "w70 h30 x+5", "Cancel")
        cancelBtn.OnEvent("Click", (*) => this.hqlGui.Hide())
        
        ; Results area - use xs to reset to left margin on new line
        this.hqlGui.Add("Text", "xs w480 h20", "Results:")
        this.ResultText := this.hqlGui.Add("Edit", "w480 h160 Multi ReadOnly", "")
        
        ; Apply listColor as background to results edit box if available
        if (this.ListColor != "")
            this.ResultText.Opt("+Background" this.ListColor)
        
        this.hqlGui.OnEvent("Close", (*) => (this.hqlGui := ""))
        this.hqlGui.OnEvent("Escape", (*) => this.hqlGui.Hide())
        
        this.hqlGui.Show("w512 h330")
    }
    
    ; ======= Search Functionality =======
    ; Searches the AutoCorrectsLog for the hotstring in the input field
    ; Parses the input, validates format, loads context data, and displays results
    ; Updates Show Context button state based on whether context is available
    static Search() {
        if (this.IsSearching)
            return
            
        this.IsSearching := true
        
        try {
            ; Get the input text
            inputText := Trim(this.HotstringEdit.Text)
            
            if (inputText = "") {
                this.ResultText.Text := "Select a hotstring from your library and press Ctrl+Shift+Q to populate and search, or paste one here and click Search."
                return
            }
            
            ; Parse the hotstring
            parsed := this.ParseHotstring(inputText)
            
            if (parsed = "") {
                debugMsg := 'Could not parse hotstring. Please check the format and try again.`n`nExpected formats:`n  Library: :B0X*:trigger::f("replacement")`n  Log: :options:trigger::replacement'
                this.ResultText.Text := debugMsg
                return
            }
            
            ; Search the log file
            result := this.LookupInLog(parsed.Trigger, parsed.Replacement)
            
            ; Store for context lookup
            this.CurrentTrigger := parsed.Trigger
            this.CurrentReplacement := parsed.Replacement
            
            ; Load context data
            this.LoadContextData()
            
            ; Add context count to results if context exists
            if (this.ContextLines.Length > 0) {
                result .= "`r`nContext occurrences: " this.ContextLines.Length
                this.ShowContextBtn.Enabled := true  ; Enable the button
            } else {
                this.ShowContextBtn.Enabled := false  ; Disable the button
            }
            
            this.ResultText.Text := result
            
        } catch Error as err {
            this.ResultText.Text := "Error: " err.Message
        } finally {
            this.IsSearching := false
        }
    }
    
    ; ======= Parsing Methods =======
    ; Parses a hotstring in either library or log format and extracts trigger/replacement
    ; Parameters: inputText - String containing the hotstring to parse
    ; Returns: Object with Trigger and Replacement properties, or empty string if parse fails
    ; Supports both :B0X*:trigger::f("replacement") (library) and :options:trigger::replacement (log) formats
    static ParseHotstring(inputText) {
        ; Trim and clean up the input
        inputText := Trim(inputText)
        
        ; Remove inline comments (anything after ;)
        commentPos := InStr(inputText, ";")
        if (commentPos > 0)
            inputText := Trim(SubStr(inputText, 1, commentPos - 1))
        
        ; First, try the regex that handles library format with f()
        if RegExMatch(inputText, this.HsRegex, &match) {
            ; Strip surrounding quotes from replacement if present
            repl := match.Repl
            if (SubStr(repl, 1, 1) = '"' && SubStr(repl, -1) = '"')
                repl := SubStr(repl, 2, -1)
            
            return {
                Trigger: match.Trig,
                Replacement: repl
            }
        }
        
        ; If that fails, try direct hotstring format (from log file)
        ; Format: :options:trigger::replacement
        if RegExMatch(inputText, "(?Jim)^:(?<Opts>[^:]*):(?<Trig>[^:]+)::(?<Repl>.+)$", &match) {
            return {
                Trigger: match.Trig,
                Replacement: Trim(match.Repl)
            }
        }
        
        ; If still no match, return empty
        return ""
    }
    
    ; ======= Log File Lookup =======
    ; Searches AutoCorrectsLog.txt for entries matching the trigger and replacement
    ; Parameters: trigger - The hotstring trigger to search for, replacement - The replacement text
    ; Returns: Formatted string with occurrence counts, success rate, and last occurrence date
    ; Also stores results in class properties for use by other methods
    static LookupInLog(trigger, replacement) {
        logFile := this.Config.ACLog
        
        if !FileExist(logFile) {
            return "Log file not found: " logFile
        }
        
        try {
            logContent := FileRead(logFile)
            
            ; Initialize counters
            keptCount := 0
            backspacedCount := 0
            lastOccurrence := ""
            
            ; Parse each line
            Loop Parse logContent, "`n`r" {
                line := A_LoopField
                
                ; Extract hotstring from log line (format: YYYY-MM-DD -- :options:trigger::replacement)
                ; The hotstring data starts at position 15
                if (StrLen(line) >= 15) {
                    logHotstring := SubStr(line, 15)
                    actionType := SubStr(line, 12, 2)  ; "--" or "<<"
                    
                    ; Check if this log entry matches our search
                    if (this.MatchesLog(trigger, replacement, logHotstring)) {
                        if (actionType = "--") {
                            keptCount++
                        } else if (actionType = "<<") {
                            backspacedCount++
                        }
                        lastOccurrence := SubStr(line, 1, 10)  ; Extract date (YYYY-MM-DD)
                    }
                }
            }
            
            ; Format results
            totalCount := keptCount + backspacedCount
            
            if (totalCount = 0) {
                return "No matches found in log file."
            }
            
            successRate := Round((keptCount / totalCount) * 100, 1)
            
            result := "Total occurrences: " totalCount "`r`n"
                   . "  ✓ Kept (--): " keptCount "`r`n"
                   . "  ✗ Backspaced (<<): " backspacedCount "`r`n"
                   . "  Success rate: " successRate "%`n`n"
                   . "  Last occurrence: " lastOccurrence
            
            return result
            
        } catch Error as err {
            return "Error reading log file: " err.Message
        }
    }
    
    ; ======= Log Entry Matching =======
    ; Checks if a log file entry matches the current search criteria (trigger and replacement)
    ; Parameters: trigger - The trigger to match, replacement - The replacement to match, logEntry - The log line to check
    ; Returns: true if entry matches, false otherwise
    static MatchesLog(trigger, replacement, logEntry) {
        ; Log entry format: :options:trigger::replacement
        ; We need to check if trigger and replacement match
        
        ; Extract trigger and replacement from log entry
        logParsed := this.ParseHotstring(logEntry)
        
        if (logParsed = "")
            return false
        
        ; Compare trigger (exact match)
        if (logParsed.Trigger != trigger)
            return false
        
        ; Compare replacement (trim whitespace for comparison)
        if (Trim(logParsed.Replacement) != Trim(replacement))
            return false
        
        return true
    }
    
    ; ======= Clear Method =======
    ; Clears all input and output fields, resets button states
    ; Empties the hotstring input field, results display, and context button state
    static Clear() {
        this.HotstringEdit.Text := ""
        this.ResultText.Text := ""
        this.ShowContextBtn.Enabled := false
        this.ContextLines := []
    }
    
    ; ======= Context Data Loading =======
    ; Loads context entries from ErrContextLog.txt matching the current trigger/replacement
    ; Searches for lines containing the hotstring and extracts only the context portion (after --->)
    ; Results stored in CurrentTrigger, CurrentReplacement, and ContextLines properties
    static LoadContextData() {
        ; Load context lines for current trigger/replacement from ErrContextLog
        this.ContextLines := []
        
        contextLogFile := "..\Data\ErrContextLog.txt"
        
        if !FileExist(contextLogFile)
            return
        
        try {
            contextContent := FileRead(contextLogFile)
            
            ; Build search string in log format
            searchStr := ":" this.CurrentTrigger "::" this.CurrentReplacement
            
            Loop Parse contextContent, "`n`r" {
                if InStr(A_LoopField, searchStr) {
                    ; Extract only the part after ---> (the context text)
                    arrowPos := InStr(A_LoopField, "--->")
                    if (arrowPos > 0) {
                        contextText := Trim(SubStr(A_LoopField, arrowPos + 4))
                        this.ContextLines.Push(contextText)
                    }
                }
            }
        } catch Error as err {
            ; Silently fail
        }
    }
    
    ; ======= Context Display Popup =======
    ; Creates and displays a popup GUI showing all context entries for the current hotstring
    ; Applies the same theme colors as the main GUI for consistency
    ; Popup is closable via Escape key or the close button
    static ShowContextPopup() {
        if (this.ContextLines.Length = 0) {
            MsgBox("No context data available.")
            return
        }
        
        ; Create context display GUI
        contextGui := Gui()
        contextGui.Opt("+AlwaysOnTop")
        contextGui.SetFont("s12", "Segoe UI")
        
        ; Apply theme colors if available
        try {
            themeFile := FileExist("..\Data\colorThemeSettings.ini") ? "..\Data\colorThemeSettings.ini" 
                      : FileExist("..\..\Data\colorThemeSettings.ini") ? "..\..\Data\colorThemeSettings.ini" 
                      : ""
            
            if (themeFile != "") {
                fontColor := IniRead(themeFile, "ColorSettings", "fontColor", "")
                listColor := IniRead(themeFile, "ColorSettings", "listColor", "")
                formColor := IniRead(themeFile, "ColorSettings", "formColor", "")
                
                if (fontColor != "")
                    contextGui.SetFont("c" fontColor)
                if (formColor != "")
                    contextGui.BackColor := formColor
            }
        } catch Error {
            ; Use defaults
        }
        
        ; Title
        titleCtrl := contextGui.Add("Text", "w728 h30", "Context of item -- :" this.CurrentTrigger "::" this.CurrentReplacement)
        
        ; Context text box
        contextBox := contextGui.Add("Edit", "w728 h350 Multi ReadOnly", "")
        
        ; Apply listColor as background to context edit box if available
        if (this.ListColor != "")
            contextBox.Opt("+Background" this.ListColor)
        
        ; Build context display text
        contextText := ""
        for line in this.ContextLines {
            contextText .= line "`r`n"
        }
        contextBox.Text := contextText
        
        contextGui.OnEvent("Escape", (*) => contextGui.Destroy())
        contextGui.Show("w760 h420")
        
        ; Set focus on title text to deselect the edit box content
        titleCtrl.Focus()
    }
    
    ; ======= Theme Application =======
    ; Loads color theme settings from colorThemeSettings.ini and applies to the main GUI
    ; Reads fontColor and formColor settings and updates GUI appearance accordingly
    ; Silently fails and uses defaults if theme file is not found
    static LoadThemeSettings() {
        try {
            themeFile := FileExist("..\Data\colorThemeSettings.ini") ? "..\Data\colorThemeSettings.ini" 
                      : FileExist("..\..\Data\colorThemeSettings.ini") ? "..\..\Data\colorThemeSettings.ini" 
                      : ""
            
            if (themeFile != "") {
                settingsFile := themeFile
                fontColor := IniRead(settingsFile, "ColorSettings", "fontColor", "")
                listColor := IniRead(settingsFile, "ColorSettings", "listColor", "")
                formColor := IniRead(settingsFile, "ColorSettings", "formColor", "")
                
                if (fontColor != "")
                    this.hqlGui.SetFont("c" fontColor)
                if (formColor != "")
                    this.hqlGui.BackColor := formColor
                
                ; Store listColor for use in edit controls
                if (listColor != "")
                    this.ListColor := listColor
            }
        } catch Error {
            ; Silently fail - use defaults
        }
    }
}
