#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Settings Manager - Standalone GUI for editing INI configuration files
; Version: 11-22-2025
; 
; A dedicated GUI application for viewing and editing INI settings with
; metadata-driven features: type-specific editing, auto-generation, validation,
; and quick navigation to properties in your preferred editor.
;
; QUICK START:
; ============================================================================
; 1. UPDATE CONFIGURATION (see below):
;    - Change AppName, IniFileName, MetadataFileName, ExpectedDataDir
;    - Set EditorPath (optional, auto-detects VS Code)
;
; 2. RUN: If metadata file doesn't exist, script offers to auto-generate
;    skeleton based on INI structure
;
; 3. USE: Double-click to edit settings, Validate Metadata to sync JSON,
;    Go To to jump to properties in your editor
;
; ============================================================================
; METADATA FIELD TYPES
; ============================================================================
;
; TEXT (default):    { "label": "...", "help": "...", "type": "text" }
;
; INTEGER:           { "type": "integer", "min": 0, "max": 100 }
;
; BOOLEAN:           { "type": "boolean", "options": ["0=Off", "1=On"] }
;
; FILE:              { "type": "file", "filter": "Text Files (*.txt)|*.txt" }
;
; COLOR:             { "type": "color" }  (uses Windows color picker)
;
; HOTKEY:            { "type": "hotkey" }  (examples: #h, ^+h, F12)
;
; LIST:              { "type": "list", "validation": "option1|option2|..." }
;
; OPTIONAL FIELDS (all types):
;   - "default": Default value if key missing from INI
;   - "restart": Path to .exe to restart when this setting changes
;
; ============================================================================
; SPECIAL FEATURES
; ============================================================================
;
; AUTO-DETECTION: New metadata types are detected from INI values
;   - Boolean: 0 or 1 values
;   - Integer: Numeric values
;   - Color: Hex color patterns
;   - Hotkey: Common hotkey patterns
;   - File: Common file extensions (.ahk, .exe, .txt, .csv)
;   - Text: Default for everything else
;
; MULTI-LINE HELP: Use \n in JSON for line breaks
;   Example: "help": "Line 1\nLine 2\nLine 3"
;
; COMMENTS IN JSON: Add "_Comment" key for documentation (optional)
;
; ============================================================================
; GUI BUTTONS & WORKFLOW
; ============================================================================
;
; EDIT:               Edit selected setting (type-specific dialog)
;
; VALIDATE METADATA:  Check INI/JSON sync and fix mismatches
;                     - Detects new keys to add
;                     - Detects orphaned keys to remove
;                     - One-click update preserves all customizations
;
; GO TO:              Jump to selected property in your editor
;                     - Opens metadata file
;                     - Searches for the property key
;                     - Perfect for customizing newly-added metadata
;
; OPEN INI FILE:      Open INI file in default editor
;
; RELOAD:             Discard unsaved changes
;
; SAVE:               Write changes to INI file
;
; ============================================================================

; ============================================================================
; CONFIGURATION - Customize for different projects
; ============================================================================
AppName := "AutoCorrect2 Settings Manager"
IniFileName := "acSettings.ini"
MetadataFileName := "acSettingsMetadata.json"
ExpectedDataDir := "..\Data"  ; Relative path to expected data directory

; Path to your preferred editor. Will be used by "Go To" button to open metadata file.
; If path is blank or invalid, defaults to VS Code.
; Examples: "C:\Program Files\Notepad++\notepad++.exe"
;           "C:\Program Files\Microsoft VS Code\Code.exe"
EditorPath := ""  ; Leave blank to auto-detect VS Code, or set your own path

; ============================================================================
; Global variables
iniPath := ""
metadataPath := ""
allSettings := Map()
originalSettings := Map()
settingsMetadata := Map()  ; Stores metadata for each setting
sectionOrder := Array()  ; Track order of sections as they appear in INI
keyOrder := Map()  ; Track order of keys per section: keyOrder[section] = [key1, key2, ...]
currentSection := ""
isDirty := false
mainGui := ""
lvSettings := ""
tvSections := ""
helpPane := ""
sectionMap := Map()  ; Maps TreeView ItemID to section name

; Font and color settings
DefaultFontSize := "s11"
FormColor := "E5E4E2"
FontColor := "c1F1F1F"
ListColor := "FFFFFF"

; Set tray icon
TraySetIcon("shell32.dll", 70)

; ============================================================================
; COLOR PICKER FUNCTION based on work by Teadrinker
; ============================================================================

ValidateAndInitializeEditorPath() {
    global EditorPath
    
    ; If EditorPath is blank or file doesn't exist, try to find VS Code
    if (EditorPath = "" || !FileExist(EditorPath)) {
        ; Try default VS Code location
        defaultVSCode := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
        
        if (FileExist(defaultVSCode)) {
            EditorPath := defaultVSCode
        } else {
            ; If still not found, try Program Files location
            altVSCode := "C:\Program Files\Microsoft VS Code\Code.exe"
            if (FileExist(altVSCode)) {
                EditorPath := altVSCode
            } else {
                ; Last resort: try to find it in PATH or just use "code"
                EditorPath := "code"
            }
        }
    }
}

ChooseColor(initColor := 0, hWnd := 0, customColorsArr := '', flags := 3) { 
    ; flags: CC_RGBINIT = 1, CC_FULLOPEN = 2, CC_PREVENTFULLOPEN = 4
    static init := false, customColors := '', CHOOSECOLOR := '', staticColorsArr := ''
         , RGB_BGR := color => (color & 0xFF) << 16 | color & 0xFF00 | color >> 16
    
    if !init {
        init := true
        if !IsObject(customColorsArr) {
            customColorsArr := []
        }
        staticColorsArr := customColorsArr
        staticColorsArr.Length := 16
        customColors := Buffer(64)
        Loop 16 {
            clr := staticColorsArr.Has(A_Index) && IsInteger(staticColorsArr[A_Index])
                ? RGB_BGR(staticColorsArr[A_Index] & 0xFFFFFF) : 0xFFFFFF
            NumPut('UInt', clr, customColors, (A_Index - 1) * 4)
        }
        CHOOSECOLOR := Buffer(A_PtrSize * 9)
        NumPut('Ptr', customColors.ptr, NumPut('Ptr', CHOOSECOLOR.size, CHOOSECOLOR) + A_PtrSize * 3)
    }
    NumPut('Ptr', hWnd, CHOOSECOLOR, A_PtrSize)
    NumPut('UInt', RGB_BGR(initColor), CHOOSECOLOR, A_PtrSize * 3)
    NumPut('UInt', flags, CHOOSECOLOR, A_PtrSize * 5)
    res := DllCall('Comdlg32\ChooseColor', 'Ptr', CHOOSECOLOR)
    Loop 16 {
        staticColorsArr[A_Index] := RGB_BGR(NumGet(customColors, (A_Index - 1) * 4, 'UInt'))
    }
    if (res) {
        color := NumGet(CHOOSECOLOR, A_PtrSize * 3, 'UInt')
        return Format("{:06X}", RGB_BGR(color))  ; Convert BGR to RGB and return without 0x prefix
    } else {
        return ""
    }
}

; ============================================================================
; FONT AND COLOR LOADING
; ============================================================================

LoadFontAndColors(iniFilePath) {
    global DefaultFontSize, FormColor, FontColor, ListColor
    
    ; Load font size from acSettings.ini
    if FileExist(iniFilePath) {
        fontSize := IniRead(iniFilePath, "HotstringHelper", "DefaultFontSize", "11")
        DefaultFontSize := "s" fontSize
    }
    
    ; Load theme colors from colorThemeSettings.ini
    colorThemeFile := "..\Data\colorThemeSettings.ini"
    if FileExist(colorThemeFile) {
        FormColor := IniRead(colorThemeFile, "ColorSettings", "formColor", "E5E4E2")
        FontColor := "c" IniRead(colorThemeFile, "ColorSettings", "fontColor", "1F1F1F")
        ListColor := IniRead(colorThemeFile, "ColorSettings", "listColor", "FFFFFF")
    } else {
        ; Use defaults if theme file doesn't exist
        FormColor := "E5E4E2"
        FontColor := "c1F1F1F"
        ListColor := "FFFFFF"
    }
}

; ============================================================================
; TYPE-SPECIFIC EDIT DIALOGS
; ============================================================================

EditBoolean(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings, DefaultFontSize, FormColor, FontColor, settingsMetadata
    
    editGui := Gui()
    editGui.Opt("+AlwaysOnTop +4096")
    editGui.Title := "Edit Boolean Setting"
    editGui.BackColor := FormColor
    editGui.SetFont(DefaultFontSize " " FontColor)
    
    editGui.Add("Text", "x10 y10 w300 h20", section "." key)
    editGui.Add("Text", "x10 y35 w300 h40", "Select a value:")
    
    ; Determine initial selection
    initialVal := (originalValue = "1" || originalValue = "true") ? 1 : (originalValue = "0" || originalValue = "false" ? 0 : "")
    
    ; Get custom labels from metadata if available
    metadata := GetMetadata(section, key)
    label0 := "Disabled (0)"
    label1 := "Enabled (1)"
    
    if (metadata.Has("options") && metadata["options"].Length >= 2) {
        options := metadata["options"]
        ; Parse options like "0=Disabled" and "1=Enabled"
        for opt in options {
            parts := StrSplit(opt, "=")
            if (parts.Length = 2) {
                if (parts[1] = "0") {
                    label0 := parts[2]
                } else if (parts[1] = "1") {
                    label1 := parts[2]
                }
            }
        }
    }
    
    radio1 := editGui.Add("Radio", "x30 y80 w200 h30 vBoolValue", label1)
    radio2 := editGui.Add("Radio", "x30 y115 w200 h30", label0)
    
    if (initialVal = 1) {
        radio1.Value := 1
    } else {
        radio2.Value := 1
    }
    
    btnOK := editGui.Add("Button", "x120 y160 w80 h30 Default", "OK")
    btnCancel := editGui.Add("Button", "x210 y160 w80 h30", "Cancel")
    
    EditDlg_OK(GuiCtrlObj, Info) {
        submitted := editGui.Submit(0)
        newValue := radio1.Value ? "1" : "0"
        fullKey := section "." key
        
        allSettings[fullKey] := newValue
        lvSettings.Modify(lvSettings.GetNext(0), , key, newValue)
        isDirty := true
        
        editGui.Destroy()
        ToolTip("Setting updated")
        SetTimer(() => ToolTip(), 1000)
    }
    
    EditDlg_Cancel(GuiCtrlObj, Info) {
        editGui.Destroy()
    }
    
    btnOK.OnEvent("Click", EditDlg_OK)
    btnCancel.OnEvent("Click", EditDlg_Cancel)
    
    editGui.Show("w330 h210")
}

EditColor(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings
    
    ; Convert hex value to integer for the color picker
    colorVal := "0x" originalValue
    
    pickedColor := ChooseColor(colorVal, mainGui.Hwnd)
    
    if (pickedColor != "") {
        fullKey := section "." key
        allSettings[fullKey] := pickedColor
        lvSettings.Modify(lvSettings.GetNext(0), , key, pickedColor)
        isDirty := true
        ToolTip("Color updated: " pickedColor)
        SetTimer(() => ToolTip(), 1000)
    }
}

EditFile(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings, settingsMetadata
    
    ; Get filter from metadata if available
    metadata := GetMetadata(section, key)
    filter := metadata.Has("filter") ? metadata["filter"] : "All Files (*.*)"
    
    result := FileSelect(1, originalValue, "Select file for " key, filter)
    
    if (result != "") {
        fullKey := section "." key
        allSettings[fullKey] := result
        lvSettings.Modify(lvSettings.GetNext(0), , key, result)
        isDirty := true
        ToolTip("File path updated")
        SetTimer(() => ToolTip(), 1000)
    }
}

EditInteger(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings, settingsMetadata, DefaultFontSize, FormColor, FontColor
    
    metadata := GetMetadata(section, key)
    minVal := metadata.Has("min") ? metadata["min"] : 0
    maxVal := metadata.Has("max") ? metadata["max"] : 999999
    
    editGui := Gui()
    editGui.Opt("+AlwaysOnTop +4096")
    editGui.Title := "Edit Integer Setting"
    editGui.BackColor := FormColor
    editGui.SetFont(DefaultFontSize " " FontColor)
    
    editGui.Add("Text", "x10 y10 w300 h20", section "." key)
    
    rangeText := ""
    if (metadata.Has("min") && metadata.Has("max")) {
        rangeText := " (Range: " minVal " to " maxVal ")"
    }
    editGui.Add("Text", "x10 y35 w300 h20", "Value:" rangeText)
    
    ; Add Edit and UpDown controls
    editGui.Add("Edit", "x10 y60 w250 h25 Number vIntValue", originalValue)
    editGui.Add("UpDown", "x260 y60 w30 h25 Range" minVal "-" maxVal, originalValue)
    
    btnOK := editGui.Add("Button", "x120 y100 w80 h30 Default", "OK")
    btnCancel := editGui.Add("Button", "x210 y100 w80 h30", "Cancel")
    
    EditDlg_OK(GuiCtrlObj, Info) {
        submitted := editGui.Submit(0)
        newValue := submitted.IntValue
        
        ; Validate range
        if (newValue < minVal) {
            MsgBox("Value must be at least " minVal, "Invalid Value", "Iconx")
            return
        }
        if (newValue > maxVal) {
            MsgBox("Value must be at most " maxVal, "Invalid Value", "Iconx")
            return
        }
        
        fullKey := section "." key
        allSettings[fullKey] := newValue
        lvSettings.Modify(lvSettings.GetNext(0), , key, newValue)
        isDirty := true
        
        editGui.Destroy()
        ToolTip("Setting updated")
        SetTimer(() => ToolTip(), 1000)
    }
    
    EditDlg_Cancel(GuiCtrlObj, Info) {
        editGui.Destroy()
    }
    
    btnOK.OnEvent("Click", EditDlg_OK)
    btnCancel.OnEvent("Click", EditDlg_Cancel)
    
    editGui.Show("w330 h160")
}

EditHotkey(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings, DefaultFontSize, FormColor, FontColor
    
    editGui := Gui()
    editGui.Opt("+AlwaysOnTop +4096")
    editGui.Title := "Edit Hotkey Setting"
    editGui.BackColor := FormColor
    editGui.SetFont(DefaultFontSize " " FontColor)
    
    editGui.Add("Text", "x10 y10 w300 h20", section "." key)
    editGui.Add("Text", "x10 y35 w400 h40", "Enter the hotkey combination (e.g., Ctrl+H, F12)`nNote: Use the Win checkbox below to include the Win key")
    
    ; Determine if Win key is present and prepare hotkey value without Win prefix
    hasWinKey := InStr(originalValue, "#") > 0
    hotkeyValue := StrReplace(originalValue, "#", "")
    
    hotkeyCtrl := editGui.Add("Hotkey", "x10 y80 w300 h25 vHotkeyValue", hotkeyValue)
    winCheckbox := editGui.Add("Checkbox", "x10 y110 w250 h25 vWinKey", "Include Win Key")
    
    ; Pre-check Win Key if "#" was present
    if (hasWinKey) {
        winCheckbox.Value := 1
    }
    
    btnOK := editGui.Add("Button", "x120 y150 w80 h30 Default", "OK")
    btnCancel := editGui.Add("Button", "x210 y150 w80 h30", "Cancel")
    
    EditDlg_OK(GuiCtrlObj, Info) {
        submitted := editGui.Submit(0)
        hotkey := submitted.HotkeyValue
        includeWin := submitted.WinKey
        
        if (hotkey = "") {
            MsgBox("Please enter a hotkey", "Invalid Hotkey", "Iconx")
            return
        }
        
        ; Add Win key prefix if checked
        if (includeWin) {
            hotkey := "#" hotkey
        }
        
        fullKey := section "." key
        allSettings[fullKey] := hotkey
        lvSettings.Modify(lvSettings.GetNext(0), , key, hotkey)
        isDirty := true
        
        editGui.Destroy()
        ToolTip("Hotkey updated: " hotkey)
        SetTimer(() => ToolTip(), 1500)
    }
    
    EditDlg_Cancel(GuiCtrlObj, Info) {
        editGui.Destroy()
    }
    
    btnOK.OnEvent("Click", EditDlg_OK)
    btnCancel.OnEvent("Click", EditDlg_Cancel)
    
    editGui.Show("w450 h200")
}

EditText(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings, DefaultFontSize, FormColor, FontColor, ListColor, settingsMetadata
    
    editGui := Gui()
    editGui.Opt("+AlwaysOnTop +4096")
    editGui.Title := "Edit Text Setting"
    editGui.BackColor := FormColor
    editGui.SetFont(DefaultFontSize " " FontColor)
    
    editGui.Add("Text", "x10 y10 w380 h20", section "." key)
    editGui.Add("Edit", "x10 y35 w380 h100 vTextValue Background" ListColor, originalValue)
    
    btnOK := editGui.Add("Button", "x150 y145 w80 h30 Default", "OK")
    btnCancel := editGui.Add("Button", "x240 y145 w80 h30", "Cancel")
    
    EditDlg_OK(GuiCtrlObj, Info) {
        submitted := editGui.Submit(0)
        newValue := submitted.TextValue
        
        ; Check for validation rules
        metadata := GetMetadata(section, key)
        if (metadata.Has("validation")) {
            validationPattern := metadata["validation"]
            
            ; Allow empty values
            if (newValue != "") {
                ; Remove all valid options and see what's left
                remainingInvalid := RegExReplace(newValue, validationPattern, "")
                
                if (remainingInvalid != "") {
                    ; Found invalid characters
                    MsgBox("Invalid characters found: " remainingInvalid "`n`nMust match pattern: " validationPattern, "Validation Error", "Iconx 4096")
                    return
                }
            }
        }
        
        fullKey := section "." key
        allSettings[fullKey] := newValue
        lvSettings.Modify(lvSettings.GetNext(0), , key, newValue)
        isDirty := true
        
        editGui.Destroy()
        ToolTip("Setting updated")
        SetTimer(() => ToolTip(), 1000)
    }
    
    EditDlg_Cancel(GuiCtrlObj, Info) {
        editGui.Destroy()
    }
    
    btnOK.OnEvent("Click", EditDlg_OK)
    btnCancel.OnEvent("Click", EditDlg_Cancel)
    
    editGui.Show("w400 h200")
}

EditList(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings, DefaultFontSize, FormColor, FontColor, ListColor, settingsMetadata
    
    ; Get metadata to retrieve the list items
    metadata := GetMetadata(section, key)
    
    if (!metadata.Has("validation") || metadata["validation"] = "") {
        MsgBox("List type requires a 'validation' field with pipe-delimited items", "Configuration Error", "Iconx 4096")
        return
    }
    
    ; Parse the pipe-delimited items
    validationStr := metadata["validation"]
    listItems := StrSplit(validationStr, "|")
    
    ; Create the dialog
    editGui := Gui()
    editGui.Opt("+AlwaysOnTop +4096")
    editGui.Title := "Select from List"
    editGui.BackColor := FormColor
    editGui.SetFont(DefaultFontSize " " FontColor)
    
    editGui.Add("Text", "x10 y10 w350 h20", section "." key)
    editGui.Add("Text", "x10 y35 w350 h20", "Select an option:")
    
    ; Create ListBox with the items
    listBox := editGui.Add("ListBox", "x10 y60 w350 h150 vSelectedItem Background" ListColor, listItems)
    
    ; Pre-select the current value if it exists in the list
    if (originalValue != "") {
        selectedIndex := 0
        for i, item in listItems {
            if (item = originalValue) {
                selectedIndex := i
                break
            }
        }
        if (selectedIndex > 0) {
            listBox.Value := selectedIndex
        }
    }
    
    btnOK := editGui.Add("Button", "x120 y220 w80 h30 Default", "OK")
    btnCancel := editGui.Add("Button", "x210 y220 w80 h30", "Cancel")
    
    EditDlg_OK(GuiCtrlObj, Info) {
        submitted := editGui.Submit(0)
        
        if (submitted.SelectedItem = "") {
            MsgBox("Please select an item from the list", "No Selection", "Iconx 4096")
            return
        }
        
        fullKey := section "." key
        allSettings[fullKey] := submitted.SelectedItem
        lvSettings.Modify(lvSettings.GetNext(0), , key, submitted.SelectedItem)
        isDirty := true
        
        editGui.Destroy()
        ToolTip("Setting updated")
        SetTimer(() => ToolTip(), 1000)
    }
    
    EditDlg_Cancel(GuiCtrlObj, Info) {
        editGui.Destroy()
    }
    
    btnOK.OnEvent("Click", EditDlg_OK)
    btnCancel.OnEvent("Click", EditDlg_Cancel)
    
    editGui.Show("w370 h280")
}

; ============================================================================
; JSON ESCAPE SEQUENCE PROCESSOR
; ============================================================================

ProcessJSONEscapes(str) {
    ; Handle JSON escape sequences in the correct order
    ; First, replace escaped backslashes with a placeholder to avoid conflicts
    str := StrReplace(str, "\\", "<<<BACKSLASH>>>")
    ; Then process other escape sequences
    str := StrReplace(str, "\n", "`n")     ; Newline
    str := StrReplace(str, "\r", "`r")     ; Carriage return
    str := StrReplace(str, "\t", "`t")     ; Tab
    str := StrReplace(str, '\"', '"')      ; Escaped quote
    ; Finally, restore escaped backslashes
    str := StrReplace(str, "<<<BACKSLASH>>>", "\")
    return str
}

; ============================================================================
; METADATA SKELETON GENERATION
; ============================================================================

DetectFieldType(value) {
    ; Type detection order: Boolean -> Integer -> Color -> Hotkey -> File -> Text
    
    ; 1. BOOLEAN: Must be exactly "0" or "1"
    if (value = "0" || value = "1") {
        return "boolean"
    }
    
    ; 2. INTEGER: Only digits (and optional leading minus)
    if (RegExMatch(value, "^-?\d+$")) {
        return "integer"
    }
    
    ; 3. COLOR: Exactly 6 hex digits
    if (RegExMatch(value, "^[0-9A-Fa-f]{6}$")) {
        return "color"
    }
    
    ; 4. HOTKEY: Contains hotkey modifiers or function keys
    ; Hotkey patterns: # (Win), ^ (Ctrl), ! (Alt), + (Shift), or F1-F24, or other keys
    if (InStr(value, "#") || InStr(value, "^") || InStr(value, "!") || InStr(value, "+")) {
        return "hotkey"
    }
    ; Check for function keys F1-F24
    if (RegExMatch(value, "^F(1|2|[0-9]|1[0-9]|2[0-4])$")) {
        return "hotkey"
    }
    ; Check for common special keys
    if (value ~= "i)^(Enter|Tab|Escape|Backspace|Delete|Home|End|PgUp|PgDn|Up|Down|Left|Right|LCtrl|RCtrl|LAlt|RAlt|LShift|RShift|LWin|RWin)$") {
        return "hotkey"
    }
    
    ; 5. FILE: Smart detection
    ; Pattern: Name.extension where extension is 3+ alphanumeric chars, not a TLD
    ; Exclude common TLDs: com, org, edu, net, gov, io, co, uk, etc.
    ; Also reject if multiple file patterns exist
    
    ; Check for file pattern: something.extension
    filePattern := "\.([a-zA-Z0-9]{3,})"
    fileMatches := Array()
    match := ""  ; Initialize for RegExMatch
    pos := 1
    while (pos := RegExMatch(value, filePattern, &match, pos)) {
        ext := match[1]
        fileMatches.Push(ext)
        pos += StrLen(match[0])
    }
    
    ; If we found exactly one file pattern, validate it's not a URL/TLD
    if (fileMatches.Length = 1) {
        ext := fileMatches[1]
        ; Common TLDs and web patterns to exclude
        tlds := "com|org|edu|net|gov|io|co|uk|us|de|fr|jp|cn|au|ca|ru|br|in|info|biz|xyz|site|online|shop|app|dev|cloud"
        if (!RegExMatch(ext, "^(" tlds ")$", , 1)) {
            return "file"
        }
    }
    
    ; 6. TEXT: Default fallback
    return "text"
}

GetMinMaxForInteger(value) {
    ; If value <= 50, use 0-100
    ; If value > 50, use 0 to value*1.5 rounded up to nearest 10
    
    numValue := Integer(value)
    
    if (numValue <= 50) {
        return { min: 0, max: 100 }
    }
    
    ; Calculate max as value * 1.5, rounded up to nearest 10
    maxValue := numValue * 1.5
    maxValue := Ceil(maxValue / 10) * 10
    
    return { min: 0, max: maxValue }
}

GenerateMetadataSkeleton() {
    global sectionOrder, keyOrder, allSettings
    
    quote := chr(34)  ; Double quote character
    json := "{"
    isFirst := true
    
    ; Add comment as first entry
    json .= "`n  " quote "_Comment" quote ": " quote 
    json .= "Auto-detected field types: text, boolean, integer, color, hotkey, file, or list. "
    json .= "Review and customize labels and help text. Boolean types can have custom 0/1 labels. "
    json .= "Integer types have auto-calculated min/max ranges. Text types can have regex validation. "
    json .= "List types require pipe-delimited options in validation field." quote
    isFirst := false
    
    for section in sectionOrder {
        if keyOrder.Has(section) {
            for key in keyOrder[section] {
                if !isFirst
                    json .= ","
                isFirst := false
                
                fullKey := section "." key
                value := ""
                
                if allSettings.Has(fullKey) {
                    value := allSettings[fullKey]
                }
                
                ; Use enhanced type detection
                fieldType := DetectFieldType(value)
                
                json .= "`n  " quote fullKey quote ": {"
                json .= "`n    " quote "label" quote ": " quote key quote ","
                json .= "`n    " quote "help" quote ": " quote "Help for " key " goes here" quote ","
                json .= "`n    " quote "type" quote ": " quote fieldType quote
                
                ; Add type-specific fields
                switch fieldType {
                    case "boolean":
                        json .= ","
                        json .= "`n    " quote "options" quote ": ["
                        json .= "`n      " quote "0=Disabled" quote ","
                        json .= "`n      " quote "1=Enabled" quote
                        json .= "`n    ]"
                    
                    case "integer":
                        range := GetMinMaxForInteger(value)
                        json .= ","
                        json .= "`n    " quote "min" quote ": " range.min ","
                        json .= "`n    " quote "max" quote ": " range.max
                    
                    case "color":
                        json .= ","
                        json .= "`n    " quote "validation" quote ": " quote "^[0-9A-Fa-f]{6}$" quote
                    
                    case "file":
                        json .= ","
                        ; Try to guess file type from extension
                        if (InStr(value, ".ahk")) {
                            json .= "`n    " quote "filter" quote ": " quote "AHK Files (*.ahk)|*.ahk" quote
                        } else if (InStr(value, ".exe")) {
                            json .= "`n    " quote "filter" quote ": " quote "Executables (*.exe)|*.exe" quote
                        } else if (InStr(value, ".txt")) {
                            json .= "`n    " quote "filter" quote ": " quote "Text Files (*.txt)|*.txt" quote
                        } else if (InStr(value, ".csv")) {
                            json .= "`n    " quote "filter" quote ": " quote "CSV Files (*.csv)|*.csv" quote
                        } else {
                            json .= "`n    " quote "filter" quote ": " quote "All Files (*.*)|*.*" quote
                        }
                }
                
                json .= "`n  }"
            }
        }
    }
    
    json .= "`n}"
    return json
}

CheckAndGenerateMetadata(metadataPath) {
    global mainGui
    fileInfo := FileExist(metadataPath)
    shouldGenerate := false
    
    if (fileInfo = "") {
        ; File doesn't exist
        result := MsgBox("No metadata file found.`n`nWould you like to generate a skeleton metadata file`nbased on the sections and keys in your INI file?`n`nThe metadata file will be a .JSON file and will be created`nin the same folder as your INI file.`n`nYou can then customize the labels and help text.",
            "Generate Metadata?", "YesNo Icon? 4096")
        shouldGenerate := (result = "Yes")
    } 
    else if (fileInfo = "A") {
        ; File exists, check if it's empty
        if (FileGetSize(metadataPath) = 0) {
            result := MsgBox("Metadata file is empty.`n`nWould you like to generate a skeleton metadata file`nbased on the sections and keys in your INI file?`n`nThe metadata file will be a .JSON file and will be created`nin the same folder as your INI file.`n`nYou can then customize the labels and help text.",
                "Generate Metadata?", "YesNo Icon? 4096")
            shouldGenerate := (result = "Yes")
        }
    }
    
    if (shouldGenerate) {
        metadataJson := GenerateMetadataSkeleton()
        try {
            if FileExist(metadataPath)
                FileDelete(metadataPath)
            FileAppend(metadataJson, metadataPath)
            ToolTip("Metadata skeleton created: " metadataPath)
            SetTimer(() => ToolTip(), 2000)
            return true
        } catch as err {
            MsgBox("Error creating metadata file: " err.What, "Error", "Iconx 4096")
            return false
        }
    }
    
    return false
}

ValidateMetadata() {
    global allSettings, iniPath, mainGui
    
    ; Get all INI keys
    iniKeys := Map()
    for fullKey in allSettings {
        iniKeys[fullKey] := true
    }
    
    ; Find missing keys (in INI but not in JSON)
    missingKeys := FindMissingKeys()
    
    ; Find unused keys (in JSON but not in INI)
    unusedKeys := FindUnusedKeys()
    
    ; Build report
    report := "=== Metadata Validation Report ===`n`n"
    report .= "INI Keys: " iniKeys.Count "`n"
    report .= "JSON Keys: (will be calculated)`n`n"
    
    if (missingKeys.Length > 0) {
        report .= "❌ MISSING IN JSON (" missingKeys.Length " keys):`n"
        for key in missingKeys {
            report .= "  • " key "`n"
        }
        report .= "`n"
    }
    
    if (unusedKeys.Length > 0) {
        report .= "⚠ UNUSED IN JSON (" unusedKeys.Length " keys):`n"
        report .= "  (These keys are in JSON but not in INI)`n"
        for key in unusedKeys {
            report .= "  • " key "`n"
        }
        report .= "`n"
    }
    
    if (missingKeys.Length = 0 && unusedKeys.Length = 0) {
        report .= "✓ All keys are in sync!`n"
    }
    
    ; If there are changes needed, offer to fix them
    if (missingKeys.Length > 0 || unusedKeys.Length > 0) {
        report .= "`nPress 'Yes' to correct the JSON file,"
        report .= "`nor 'No' to ignore."
        
        result := MsgBox(report, "Metadata Validation Report", "YesNo Icon! 4096")
        
        if (result = "Yes") {
            jsonPath := SubStr(iniPath, 1, InStr(iniPath, "\", , -1) - 1) "\" "acSettingsMetadata.json"
            
            ; Proceed with merge to add missing keys and remove unused keys
            if MergeKeysIntoJSON(missingKeys, unusedKeys, jsonPath) {
                summaryMsg := "Metadata updated successfully!`n`n"
                
                if (missingKeys.Length > 0) {
                    summaryMsg .= "Added: " missingKeys.Length " new keys`n"
                }
                if (unusedKeys.Length > 0) {
                    summaryMsg .= "Removed: " unusedKeys.Length " unused keys`n"
                }
                
                summaryMsg .= "`nSettings will now be reloaded."
                
                MsgBox(summaryMsg, "Success", "Icon! 4096")
                
                ; Reload everything
                Btn_Reload()
            } else {
                MsgBox("Error updating metadata. Changes were not saved.", "Error", "Iconx 4096")
            }
        } else {
            ; User clicked No - just copy report to clipboard
            A_Clipboard := report
            ToolTip("Report copied to clipboard")
            SetTimer(() => ToolTip(), 2000)
        }
    } else {
        ; All in sync - just show report
        MsgBox(report, "Metadata Validation Report", "Icon! 4096")
        
        ; Copy to clipboard for convenience
        A_Clipboard := report
        ToolTip("Report copied to clipboard")
        SetTimer(() => ToolTip(), 2000)
    }
}

quote(str) {
    return chr(34) str chr(34)
}

FindMissingKeys() {
    ; Returns array of keys in INI but not in JSON
    global iniPath
    
    missingKeys := Array()
    
    jsonPath := SubStr(iniPath, 1, InStr(iniPath, "\", , -1) - 1) "\" "acSettingsMetadata.json"
    
    if !FileExist(jsonPath) {
        return missingKeys  ; All keys are "missing" if no JSON exists
    }
    
    ; Read JSON and search for each INI key
    try {
        jsonContent := FileRead(jsonPath)
        
        ; Get all INI keys and check if each exists in JSON
        for fullKey in allSettings {
            searchPattern := quote(fullKey) ":"
            if !InStr(jsonContent, searchPattern) {
                missingKeys.Push(fullKey)
            }
        }
    } catch as err {
        MsgBox("Error reading JSON file: " err.What, "Error", "Iconx")
    }
    
    return missingKeys
}

FindUnusedKeys() {
    ; Returns array of keys in JSON but not in INI
    global iniPath, allSettings
    
    unusedKeys := Array()
    
    jsonPath := SubStr(iniPath, 1, InStr(iniPath, "\", , -1) - 1) "\" "acSettingsMetadata.json"
    
    if !FileExist(jsonPath) {
        return unusedKeys
    }
    
    try {
        jsonContent := FileRead(jsonPath)
        
        ; Find all properties in JSON that match the "Section.Key": pattern
        regex := '"([^"]+)"\s*:\s*\{'
        pos := 1
        while (pos := RegExMatch(jsonContent, regex, &match, pos)) {
            fullKey := match[1]
            
            ; Skip special entries like _Comment
            if !InStr(fullKey, "_") {
                if !allSettings.Has(fullKey) {
                    unusedKeys.Push(fullKey)
                }
            }
            
            pos += StrLen(match[0])
        }
    } catch as err {
        MsgBox("Error reading JSON file: " err.What, "Error", "Iconx")
    }
    
    return unusedKeys
}

GenerateMetadataObject(fullKey, fieldType, value) {
    ; Generates a metadata object (the value part only, not the key)
    ; Returns: { "label": ..., "help": ..., "type": ... }
    ; This is used for proper JSON reconstruction
    q := chr(34)
    
    ; Extract just the key name for label
    keyName := SubStr(fullKey, InStr(fullKey, ".") + 1)
    
    obj := "{`n    "
    obj .= q "label" q ": " q keyName q ",`n    "
    obj .= q "help" q ": " q "Help for " keyName " goes here" q ",`n    "
    obj .= q "type" q ": " q fieldType q
    
    ; Add type-specific fields
    switch fieldType {
        case "boolean":
            obj .= ",`n    " q "options" q ": [`n"
            obj .= "      " q "0=Disabled" q ",`n"
            obj .= "      " q "1=Enabled" q "`n"
            obj .= "    ]"
        
        case "integer":
            range := GetMinMaxForInteger(value)
            obj .= ",`n    " q "min" q ": " range.min ",`n"
            obj .= "    " q "max" q ": " range.max
        
        case "color":
            obj .= ",`n    " q "validation" q ": " q "^[0-9A-Fa-f]{6}$" q
        
        case "file":
            obj .= ",`n    " q "filter" q ": " q
            if (InStr(value, ".ahk")) {
                obj .= "AHK Files (*.ahk)|*.ahk"
            } else if (InStr(value, ".exe")) {
                obj .= "Executables (*.exe)|*.exe"
            } else if (InStr(value, ".csv")) {
                obj .= "CSV Files (*.csv)|*.csv"
            } else if (InStr(value, ".txt")) {
                obj .= "Text Files (*.txt)|*.txt"
            } else {
                obj .= "All Files (*.*)|*.*"
            }
            obj .= chr(34)
    }
    
    obj .= "`n  }"
    
    return obj
}

GenerateMetadataEntryAsString(fullKey, fieldType, value) {
    ; Generates a single metadata property as formatted JSON string
    q := chr(34)
    
    ; Extract just the key name for label
    keyName := SubStr(fullKey, InStr(fullKey, ".") + 1)
    
    entry := q fullKey q ": {`n"
    entry .= "      " q "label" q ": " q keyName q ",`n"
    entry .= "      " q "help" q ": " q "Help for " keyName " goes here" q ",`n"
    entry .= "      " q "type" q ": " q fieldType q
    
    ; Add type-specific fields
    switch fieldType {
        case "boolean":
            entry .= ",`n      " q "options" q ": [`n"
            entry .= "        " q "0=Disabled" q ",`n"
            entry .= "        " q "1=Enabled" q "`n"
            entry .= "      ]"
        
        case "integer":
            range := GetMinMaxForInteger(value)
            entry .= ",`n      " q "min" q ": " range.min ",`n"
            entry .= "      " q "max" q ": " range.max
        
        case "color":
            entry .= ",`n      " q "validation" q ": " q "^[0-9A-Fa-f]{6}$" q
        
        case "file":
            entry .= ",`n      " q "filter" q ": " q
            if (InStr(value, ".ahk")) {
                entry .= "AHK Files (*.ahk)|*.ahk"
            } else if (InStr(value, ".exe")) {
                entry .= "Executables (*.exe)|*.exe"
            } else if (InStr(value, ".csv")) {
                entry .= "CSV Files (*.csv)|*.csv"
            } else if (InStr(value, ".txt")) {
                entry .= "Text Files (*.txt)|*.txt"
            } else {
                entry .= "All Files (*.*)|*.*"
            }
            entry .= chr(34)
    }
    
    entry .= "`n    }"
    
    return entry
}

MergeKeysIntoJSON(missingKeys, unusedKeys, jsonPath) {
    ; Merges new keys into JSON, removes unused keys, maintains INI order
    ; Uses robust regex-based parsing instead of fragile string splitting
    global sectionOrder, keyOrder, allSettings, mainGui
    
    ; Read existing JSON
    if !FileExist(jsonPath) {
        MsgBox("JSON file not found: " jsonPath, "Error", "Iconx 4096")
        return false
    }
    
    originalJson := FileRead(jsonPath)
    
    ; Parse existing properties using regex - handles both strings and objects
    ; Regex matches: "key": "string" or "key": {...}
    existingProps := Map()
    
    regex := '"([^"]+)"\s*:\s*(?:(\{(?:[^{}]|(?:\{[^{}]*\}))*\})|("[^"]*"))'
    pos := 1
    
    while (pos := RegExMatch(originalJson, regex, &match, pos)) {
        keyName := match[1]
        fullValue := match[0]  ; Complete "key": value
        
        ; Extract just the value part (everything after the colon)
        colonPos := InStr(fullValue, ":")
        valueContent := SubStr(fullValue, colonPos + 1)
        valueContent := Trim(valueContent)
        
        existingProps[keyName] := valueContent
        pos += StrLen(match[0])
    }
    
    ; Build new JSON with consistent formatting (no extra blank lines)
    newJson := "{"
    isFirst := true
    
    ; Add special _Comment property first if it exists (it's a string, not an object)
    if (existingProps.Has("_Comment")) {
        newJson .= "`n  " quote("_Comment") ": " existingProps["_Comment"]
        isFirst := false
    }
    
    ; For each section in INI order, add all keys
    for section in sectionOrder {
        if keyOrder.Has(section) {
            for key in keyOrder[section] {
                fullKey := section "." key
                
                ; Check if this key should be removed (unused)
                shouldRemove := false
                for unusedKey in unusedKeys {
                    if (unusedKey = fullKey) {
                        shouldRemove := true
                        break
                    }
                }
                if (shouldRemove) {
                    continue
                }
                
                ; Add comma separator if not first property
                if (!isFirst) {
                    newJson .= ","
                }
                isFirst := false
                newJson .= "`n  "
                
                if (existingProps.Has(fullKey)) {
                    ; Existing property - reconstruct as "key": value
                    newJson .= quote(fullKey) ": " existingProps[fullKey]
                } else {
                    ; Check if this is a missing key that needs to be added
                    isNew := false
                    for missingKey in missingKeys {
                        if (missingKey = fullKey) {
                            isNew := true
                            break
                        }
                    }
                    
                    if (isNew) {
                        ; Generate new property using type detection
                        value := allSettings[fullKey]
                        fieldType := DetectFieldType(value)
                        objContent := GenerateMetadataObject(fullKey, fieldType, value)
                        newJson .= quote(fullKey) ": " objContent
                    }
                }
            }
        }
    }
    
    newJson .= "`n}"
    
    ; Backup original file
    backupPath := jsonPath ".backup"
    try {
        if FileExist(backupPath) {
            FileDelete(backupPath)
        }
        FileCopy(jsonPath, backupPath)
    } catch as err {
        MsgBox("Warning: Could not create backup: " err.What, "Backup Warning", "Icon!")
    }
    
    ; Delete old file and write new one
    try {
        FileDelete(jsonPath)
        FileAppend(newJson, jsonPath)
        return true
    } catch as err {
        MsgBox("Error writing JSON file: " err.What, "Error", "Iconx 4096")
        ; Try to restore from backup
        if FileExist(backupPath) {
            FileCopy(backupPath, jsonPath)
        }
        return false
    }
}

ShowManageMissingKeysDialog(missingKeys, unusedKeys) {
    ; Shows dialog for user to choose what to do with missing/unused keys
    global mainGui
    
    message := "=== Metadata Management ===" . "`n`n"
    
    if (missingKeys.Length > 0) {
        message .= "NEW KEYS TO ADD (" missingKeys.Length "):`n"
        for key in missingKeys {
            message .= "  • " key "`n"
        }
        message .= "`n"
    }
    
    if (unusedKeys.Length > 0) {
        message .= "UNUSED KEYS TO REMOVE (" unusedKeys.Length "):`n"
        for key in unusedKeys {
            message .= "  • " key "`n"
        }
        message .= "`n"
    }
    
    if (missingKeys.Length = 0 && unusedKeys.Length = 0) {
        MsgBox("All metadata is already in sync!`n`nNo changes needed.", "Metadata Sync", "Icon!" "4096")
        return "Cancel"
    }
    
    message .= "New keys will be auto-detected with appropriate types.`n"
    message .= "Your existing metadata will be preserved.`n`n"
    message .= "Proceed with these changes?"
    
    result := MsgBox(message, "Manage Metadata", "YesNo Icon?" "4096")
    return result
}

Btn_ManageMissingKeys(GuiCtrlObj := "", Info := "") {
    global mainGui, metadataPath, iniPath
    
    missingKeys := FindMissingKeys()
    unusedKeys := FindUnusedKeys()
    
    if (missingKeys.Length = 0 && unusedKeys.Length = 0) {
        MsgBox("All metadata is already in sync!`n`nNo changes needed.", "Metadata Sync", "Icon!" "4096")
        return
    }
    
    ; Show dialog
    result := ShowManageMissingKeysDialog(missingKeys, unusedKeys)
    
    if (result = "Yes") {
        ; Proceed with merge
        jsonPath := SubStr(iniPath, 1, InStr(iniPath, "\", , -1) - 1) "\" "acSettingsMetadata.json"
        
        if MergeKeysIntoJSON(missingKeys, unusedKeys, jsonPath) {
            MsgBox("Metadata updated successfully!`n`n"
                . "Added: " missingKeys.Length " new keys`n"
                . "Removed: " unusedKeys.Length " unused keys`n`n"
                . "Settings will now be reloaded.",
                "Success", "Icon!" "4096")
            
            ; Reload everything
            Btn_Reload()
        } else {
            MsgBox("Error updating metadata. Changes were not saved.", "Error", "Iconx 4096")
        }
    }
}

LoadMetadata(filePath) {
    global settingsMetadata
    
    if !FileExist(filePath) {
        return 0
    }
    
    try {
        content := FileRead(filePath)
        entriesLoaded := 0
        
        ; Split by lines for easier parsing
        lines := StrSplit(content, "`n")
        
        currentKey := ""
        currentMetadata := Map()
        arrayItems := ""
        currentArrayField := ""
        
        for lineNum, line in lines {
            line := Trim(line)
            
            ; Skip empty lines and opening/closing braces
            if (line = "" || line = "{" || line = "}" || line = "},")
                continue
            
            ; Check for key line: "Section.Key": {
            if (InStr(line, '": {')) {
                ; Save previous entry if exists
                if (currentKey != "") {
                    settingsMetadata[currentKey] := currentMetadata
                    entriesLoaded++
                }
                
                ; Extract the key
                startPos := 1
                endPos := InStr(line, '": {')
                if (startPos > 0 && endPos > 0) {
                    currentKey := SubStr(line, startPos + 1, endPos - startPos - 1)
                    currentMetadata := Map()
                    arrayItems := ""
                    currentArrayField := ""
                }
                continue
            }
            
            ; Parse field lines: "fieldname": "value" or "fieldname": value
            if (InStr(line, '": ')) {
                colonPos := InStr(line, '": ')
                if (colonPos > 0) {
                    fieldName := SubStr(line, 2, colonPos - 2)  ; Skip opening quote
                    valueStart := colonPos + 3
                    valueStr := SubStr(line, valueStart)
                    
                    ; Remove trailing comma if present
                    valueStr := RegExReplace(valueStr, ",$", "")
                    
                    ; Parse the value
                    if (SubStr(valueStr, 1, 1) = '"') {
                        ; String value: extract between quotes
                        valueStr := SubStr(valueStr, 2)
                        endQuote := InStr(valueStr, '"')
                        if (endQuote > 0) {
                            value := SubStr(valueStr, 1, endQuote - 1)
                            ; Process JSON escape sequences
                            value := ProcessJSONEscapes(value)
                            currentMetadata[fieldName] := value
                        }
                    } else if (SubStr(valueStr, 1, 1) = "[") {
                        ; Array value (for options) - start of array
                        arrayItems := Array()
                        currentArrayField := fieldName
                        continue
                    } else if (currentArrayField != "" && IsObject(arrayItems)) {
                        ; We're inside an array, collect items
                        trimmed := Trim(valueStr)
                        if (SubStr(trimmed, 1, 1) = '"') {
                            ; Extract string value from array item
                            endQuote := InStr(trimmed, '"', , 2)
                            if (endQuote > 0) {
                                arrayItem := SubStr(trimmed, 2, endQuote - 2)
                                arrayItems.Push(arrayItem)
                            }
                        }
                        if (InStr(trimmed, "]")) {
                            ; End of array
                            currentMetadata[currentArrayField] := arrayItems
                            arrayItems := ""
                            currentArrayField := ""
                        }
                        continue
                    } else {
                        ; Numeric or boolean value
                        endPos := InStr(valueStr, ",")
                        if (endPos = 0)
                            endPos := StrLen(valueStr) + 1
                        value := Trim(SubStr(valueStr, 1, endPos - 1))
                        currentMetadata[fieldName] := value
                    }
                }
            }
            
            ; Handle array items if we're inside an array
            if (currentArrayField != "" && IsObject(arrayItems)) {
                trimmed := Trim(line)
                if (SubStr(trimmed, 1, 1) = '"') {
                    ; Extract string value from array item
                    endQuote := InStr(trimmed, '"', , 2)
                    if (endQuote > 0) {
                        arrayItem := SubStr(trimmed, 2, endQuote - 2)
                        arrayItems.Push(arrayItem)
                    }
                }
                if (InStr(trimmed, "]")) {
                    ; End of array
                    currentMetadata[currentArrayField] := arrayItems
                    arrayItems := ""
                    currentArrayField := ""
                }
            }
        }
        
        ; Save last entry
        if (currentKey != "") {
            settingsMetadata[currentKey] := currentMetadata
            entriesLoaded++
        }
        
        return entriesLoaded
        
    } catch as err {
        MsgBox("Error loading metadata: " err.What, "Error", "Iconx")
        return 0
    }
}

GetMetadata(section, key) {
    global settingsMetadata
    fullKey := section "." key
    if settingsMetadata.Has(fullKey) {
        return settingsMetadata[fullKey]
    }
    return Map()  ; Return empty map if not found
}

FindINIFile() {
    global IniFileName, ExpectedDataDir
    ; Look for INI file - portable app structure
    possiblePaths := [
        ExpectedDataDir "\" IniFileName,
        A_ScriptDir "\" IniFileName,
        A_ScriptDir "\Data\" IniFileName
    ]
    
    for path in possiblePaths {
        if FileExist(path) {
            return path
        }
    }
    
    return ""
}

LoadINIFile(filePath) {
    global sectionOrder, keyOrder
    if !FileExist(filePath) {
        return false
    }
    
    try {
        content := FileRead(filePath)
        currentSection := ""
        sectionOrder := Array()  ; Reset section order tracking
        keyOrder := Map()  ; Reset key order tracking
        
        ; Split by newlines and process each line
        lines := StrSplit(content, "`n")
        
        for line in lines {
            ; Remove carriage returns and trim whitespace
            line := StrReplace(line, "`r", "")
            line := Trim(line)
            
            ; Skip empty lines and comment lines
            if (line = "" || SubStr(line, 1, 1) = ";") {
                continue
            }
            
            ; Check for section header: [SectionName]
            if (SubStr(line, 1, 1) = "[" && InStr(line, "]") > 1) {
                closePos := InStr(line, "]")
                if (closePos = StrLen(line)) {
                    currentSection := SubStr(line, 2, closePos - 2)
                    ; Track this section in order of appearance
                    sectionOrder.Push(currentSection)
                    ; Initialize key order array for this section
                    if !keyOrder.Has(currentSection)
                        keyOrder[currentSection] := Array()
                    continue
                }
            }
            
            ; Parse key=value pairs (only if we have a current section)
            if (currentSection != "") {
                eqPos := InStr(line, "=")
                if (eqPos > 1) {  ; Must have content before the =
                    key := Trim(SubStr(line, 1, eqPos - 1))
                    value := Trim(SubStr(line, eqPos + 1))
                    
                    ; Skip if key is empty (malformed line)
                    if (key != "") {
                        fullKey := currentSection "." key
                        allSettings[fullKey] := value
                        originalSettings[fullKey] := value
                        ; Track this key in order
                        keyOrder[currentSection].Push(key)
                    }
                }
            }
        }
        
        return true
    } catch as err {
        MsgBox("Error loading INI file: " err.What, "Error", "Iconx")
        return false
    }
}

GetSections() {
    global sectionOrder
    
    return sectionOrder
}

GetSectionSettings(section) {
    global keyOrder, allSettings
    settings := Map()
    
    ; Use tracked key order if available
    if keyOrder.Has(section) {
        for key in keyOrder[section] {
            fullKey := section "." key
            if allSettings.Has(fullKey)
                settings[key] := allSettings[fullKey]
        }
    }
    
    return settings
}

SaveINIFile() {
    global isDirty, iniPath, allSettings, originalSettings, mainGui
    
    try {
        output := ""
        sections := GetSections()
        modifiedKeys := Array()  ; Track which keys were modified
        
        ; Read original file to preserve comments and structure
        if FileExist(iniPath) {
            content := FileRead(iniPath)
            currentSection := ""
            processedKeys := Map()
            
            ; Process existing content, updating values as needed
            loop parse content, "`n" {
                line := A_LoopField
                trimmedLine := Trim(line)
                
                ; Handle section headers
                if (SubStr(trimmedLine, 1, 1) = "[" && SubStr(trimmedLine, -1) = "]") {
                    currentSection := SubStr(trimmedLine, 2, -1)
                    output .= line "`n"
                    continue
                }
                
                ; Preserve comments and empty lines
                if (trimmedLine = "" || SubStr(trimmedLine, 1, 1) = ";") {
                    output .= line "`n"
                    continue
                }
                
                ; Handle key=value pairs
                if (currentSection != "") {
                    eqPos := InStr(trimmedLine, "=")
                    if (eqPos > 0) {
                        key := Trim(SubStr(trimmedLine, 1, eqPos - 1))
                        fullKey := currentSection "." key
                        
                        if allSettings.Has(fullKey) {
                            newValue := allSettings[fullKey]
                            oldValue := originalSettings.Has(fullKey) ? originalSettings[fullKey] : ""
                            
                            ; Check if value changed
                            if (newValue != oldValue) {
                                modifiedKeys.Push(fullKey)
                            }
                            
                            ; Update with new value
                            output .= key "=" newValue "`n"
                            processedKeys[fullKey] := true
                        } else {
                            ; Keep original line
                            output .= line "`n"
                        }
                        continue
                    }
                }
                
                output .= line "`n"
            }
            
            ; Add any new keys that weren't in the original file
            for fullKey, value in allSettings {
                if !processedKeys.Has(fullKey) {
                    parts := StrSplit(fullKey, ".")
                    if (parts.Length = 2) {
                        section := parts[1]
                        key := parts[2]
                        
                        ; Add section header if not present
                        if !InStr(output, "[" section "]") {
                            output .= "`n[" section "]`n"
                        }
                        
                        output .= key "=" value "`n"
                        modifiedKeys.Push(fullKey)
                    }
                }
            }
        } else {
            ; Create new file from scratch
            for section in sections {
                output .= "[" section "]`n"
                settings := GetSectionSettings(section)
                for key, value in settings {
                    output .= key "=" value "`n"
                    fullKey := section "." key
                    modifiedKeys.Push(fullKey)
                }
                output .= "`n"
            }
        }
        
        ; Trim trailing newlines to prevent accumulation
        output := RTrim(output, "`r`n")
        
        ; Write to file
        FileDelete(iniPath)
        FileAppend(output, iniPath)
        isDirty := false
        
        ; Synchronize originalSettings with the newly saved state
        ; This ensures the next save compares against the previously-saved state
        for key, value in allSettings {
            originalSettings[key] := value
        }
        
        ; Check for restart requirements
        if (modifiedKeys.Length > 0) {
            CheckAndHandleRestarts(modifiedKeys)
        }
        
        return true
    } catch as err {
        MsgBox("Error saving file: " err.What, "Error", "Iconx")
        return false
    }
}

; ============================================================================
; GUI CREATION AND EVENT HANDLERS
; ============================================================================

CreateGUI() {
    global mainGui, lvSettings, tvSections, iniPath, currentSection, sectionMap, allSettings, helpPane, helpLabel, metadataPath, DefaultFontSize, FormColor, FontColor, ListColor, AppName
    
    mainGui := Gui()
    mainGui.Opt("+AlwaysOnTop")
    mainGui.Title := AppName
    mainGui.OnEvent("Close", GUI_Close)
    
    ; Set font and background color for entire GUI
    mainGui.BackColor := FormColor
    mainGui.SetFont(DefaultFontSize " " FontColor)
    
    ; Sections TreeView
    mainGui.Add("Text", "x10 y10 w150 h20", "Sections:")
    tvSections := mainGui.Add("TreeView", "x10 y30 w150 h370 vSectionTree Background" ListColor)
    tvSections.OnEvent("ItemSelect", Tree_ItemSelect)
    
    ; Settings ListView
    mainGui.Add("Text", "x170 y10 w570 h20", "Settings")
    lvSettings := mainGui.Add("ListView", "x170 y30 w570 h370 vSettingsList"
        . " Grid AltSubmit Checked Background" ListColor, ["Setting", "Value"])
    lvSettings.ModifyCol(1, 250)
    lvSettings.ModifyCol(2, 330)
    lvSettings.OnEvent("ContextMenu", List_ContextMenu)
    lvSettings.OnEvent("DoubleClick", List_DoubleClick)
    lvSettings.OnEvent("ItemSelect", List_ItemSelect)
    
    ; Help pane at bottom
    mainGui.Add("Text", "x10 y410 w730 h2 cGray")
    helpLabel := mainGui.Add("Text", "x10 y415 w730 h20 vHelpLabel", "Select a setting for help")
    helpPane := mainGui.Add("Edit", "x10 y435 w730 h110 ReadOnly vHelpPane Background" ListColor, "")
    helpPane.Value := "Select an item and press Go To to open it in your preferred editor."
    
    
    ; Status bar
    mainGui.Add("Text", "x10 y550 w730 h20 cGray c909090", "(Double-click to edit | Right-click to copy)")
    
    ; Button row
    btnEdit := mainGui.Add("Button", "x10 y575 w80 h30", "Edit")
    btnEdit.OnEvent("Click", Btn_Edit)
    
    btnValidate := mainGui.Add("Button", "x100 y575 w150 h30", "Validate Metadata")
    btnValidate.OnEvent("Click", Btn_ValidateMetadata)
    
    btnGoTo := mainGui.Add("Button", "x260 y575 w80 h30", "Go To")
    btnGoTo.OnEvent("Click", Btn_GoTo)
    
    btnOpenINI := mainGui.Add("Button", "x390 y575 w100 h30", "Open INI File")
    btnOpenINI.OnEvent("Click", Btn_OpenINI)
    
    btnReload := mainGui.Add("Button", "x500 y575 w80 h30", "Reload")
    btnReload.OnEvent("Click", Btn_Reload)
    
    btnSave := mainGui.Add("Button", "x590 y575 w60 h30", "Save")
    btnSave.OnEvent("Click", Btn_Save)
    
    btnExit := mainGui.Add("Button", "x660 y575 w60 h30", "Exit")
    btnExit.OnEvent("Click", Btn_Exit)
    
    ; Populate sections with ItemID tracking
    sections := GetSections()
    sectionMap := Map()  ; Reset the map
    firstItemID := 0
    lastItemID := 0
    for section in sections {
        ; Add each section after the previous one to preserve order
        if (lastItemID = 0) {
            ; First item - just add it
            ItemID := tvSections.Add(section)
        } else {
            ; Add after the last item we added
            ItemID := tvSections.Add(section, , lastItemID)
        }
        sectionMap[ItemID] := section
        lastItemID := ItemID
        if (firstItemID = 0) {
            firstItemID := ItemID
        }
    }
    
    ; Select first section (use actual ItemID, not 1)
    if (firstItemID != 0) {
        Tree_ItemSelect(tvSections, firstItemID)
    }
    
    mainGui.Show("w750 h615")
}

Tree_ItemSelect(GuiCtrlObj, Item) {
    global lvSettings, currentSection, sectionMap, helpPane, keyOrder, allSettings
    
    if (Item = 0) {
        return
    }
    
    ; Get section name from the sectionMap using the ItemID
    if sectionMap.Has(Item) {
        currentSection := sectionMap[Item]
    } else {
        return  ; ItemID not found in map (happens on initial call with Item=1)
    }
    
    ; Load settings for this section
    lvSettings.Delete()
    
    ; Reset help pane when switching sections
    helpLabel.Value := "Select a setting for help"
    helpPane.Value := ""
    
    if (currentSection != "") {
        ; Iterate through keys in the order they appear in the INI file
        if keyOrder.Has(currentSection) {
            for key in keyOrder[currentSection] {
                fullKey := currentSection "." key
                if allSettings.Has(fullKey) {
                    value := allSettings[fullKey]
                    lvSettings.Add(, key, value)
                }
            }
        }
    }
}

List_DoubleClick(GuiCtrlObj, Item) {
    if (Item > 0) {
        EditSetting(Item)
    }
}

List_ItemSelect(GuiCtrlObj, Item, IsSelected) {
    global lvSettings, currentSection, helpPane, helpLabel, settingsMetadata
    
    ; Only update when an item is selected, not when deselected
    if (Item <= 0 || !IsSelected) {
        return
    }
    
    key := lvSettings.GetText(Item, 1)
    if (key = "") {
        helpPane.Value := ""
        helpLabel.Value := ""
        return
    }
    
    ; Get metadata for this setting
    metadata := GetMetadata(currentSection, key)
    
    ; Update label with "Help for: [label]"
    if (metadata.Has("label")) {
        helpLabel.Value := "Help for: " metadata["label"]
    } else {
        helpLabel.Value := "Help for: " key
    }
    
    ; Show only help text in editbox
    if (metadata.Has("help")) {
        helpPane.Value := metadata["help"]
    } else {
        helpPane.Value := "(No help available for this setting)"
    }
}

List_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
    if (Item <= 0) {
        return
    }
    
    MyContextMenu := Menu()
    MyContextMenu.Add("Edit", Edit_MenuItem)
    MyContextMenu.Add("Copy Value", Copy_MenuItem)
    MyContextMenu.Show(X, Y)
}

Edit_MenuItem(ItemName, ItemPos, MyMenu) {
    global lvSettings
    item := lvSettings.GetNext(0, "F")
    if (item > 0) {
        EditSetting(item)
    }
}

Copy_MenuItem(ItemName, ItemPos, MyMenu) {
    global lvSettings
    item := lvSettings.GetNext(0, "F")
    if (item > 0) {
        value := lvSettings.GetText(item, 2)
        A_Clipboard := value
        ToolTip("Copied: " value)
        SetTimer(() => ToolTip(), 2000)
    }
}

; ============================================================================
; BUTTON EVENT HANDLERS
; ============================================================================

Btn_OpenINI(GuiCtrlObj := "", Info := "") {
    global iniPath
    
    if (iniPath = "") {
        ToolTip("No INI file loaded")
        SetTimer(() => ToolTip(), 2000)
        return
    }
    
    ; Try to open with the default editor
    try {
        Run(iniPath)
    } catch as err {
        ; If that fails, try Notepad
        Run("Notepad.exe " iniPath)
    }
}

Btn_Edit(GuiCtrlObj := "", Info := "") {
    global lvSettings
    item := lvSettings.GetNext(0, "Checked")  ; Try to find checked item first
    if (item = 0) {
        item := lvSettings.GetNext(0)  ; Otherwise get first selected item
    }
    if (item > 0) {
        EditSetting(item)
    } else {
        ToolTip("Please select an item to edit (click a row in the list)")
        SetTimer(() => ToolTip(), 2000)
    }
}

Btn_ValidateMetadata(GuiCtrlObj := "", Info := "") {
    ValidateMetadata()
}

Btn_GoTo(GuiCtrlObj := "", Info := "") {
    global lvSettings, currentSection, metadataPath, EditorPath
    
    ; Check if an item is selected
    item := lvSettings.GetNext(0, "Checked")
    if (item = 0) {
        item := lvSettings.GetNext(0)  ; Get first selected item
    }
    
    if (item = 0) {
        ToolTip("Please select a setting first")
        SetTimer(() => ToolTip(), 2000)
        return
    }
    
    ; Get the key name from the selected row
    keyName := lvSettings.GetText(item, 1)
    if (keyName = "" || currentSection = "") {
        ToolTip("Error: Could not determine setting location")
        SetTimer(() => ToolTip(), 2000)
        return
    }
    
    ; Construct the full key
    fullKey := currentSection "." keyName
    
    ; Check if metadata file exists
    if (!FileExist(metadataPath)) {
        ToolTip("Metadata file not found: " metadataPath)
        SetTimer(() => ToolTip(), 3000)
        return
    }
    
    ; Open the file in editor
    try {
        Run(EditorPath " " chr(34) metadataPath chr(34))
    } catch as err {
        ToolTip("Error opening editor: " err.What)
        SetTimer(() => ToolTip(), 3000)
        return
    }
    
    ; Wait for editor to open and settle
    Sleep(800)
    
    ; Try to activate the editor window (works for most editors)
    WinActivate("ahk_exe Code.exe")  ; For VS Code
    Sleep(200)
    
    ; Open Find dialog
    Send("^f")
    Sleep(300)
    
    ; Type the search string in quotes to match JSON format exactly
    ; Using single quotes to wrap double quotes is cleaner in AHK v2
    searchString := '"' fullKey '"'
    SendText(searchString)
    
    Sleep(200)
    
    ; Press Enter to find the first occurrence
    Send("{Enter}")
    
    ToolTip("Found: " fullKey)
    SetTimer(() => ToolTip(), 2000)
}

EditSetting(itemRow) {
    global currentSection, lvSettings, settingsMetadata
    
    key := lvSettings.GetText(itemRow, 1)
    originalValue := lvSettings.GetText(itemRow, 2)
    
    if (key = "") {
        ToolTip("Error: Could not get key name")
        SetTimer(() => ToolTip(), 2000)
        return
    }
    
    ; Get metadata to determine type
    metadata := GetMetadata(currentSection, key)
    type := metadata.Has("type") ? metadata["type"] : "text"
    
    ; Dispatch to appropriate edit function based on type
    switch type {
        case "boolean":
            EditBoolean(currentSection, key, originalValue)
        case "color":
            EditColor(currentSection, key, originalValue)
        case "file":
            EditFile(currentSection, key, originalValue)
        case "integer":
            EditInteger(currentSection, key, originalValue)
        case "hotkey":
            EditHotkey(currentSection, key, originalValue)
        case "list":
            EditList(currentSection, key, originalValue)
        case "text":
            EditText(currentSection, key, originalValue)
        default:
            ; Fallback to generic text edit
            EditText(currentSection, key, originalValue)
    }
}

Btn_Exit(GuiCtrlObj := "", Info := "") {
    global mainGui, isDirty
    
    ; Check for unsaved changes before exiting
    if isDirty {
        result := MsgBox("You have unsaved changes. Exit anyway?", "Unsaved Changes", "YesNo Icon! 4096")
        if (result = "No") {
            return  ; Don't exit if user says No
        }
    }
    
    ExitApp  ; Exit the script completely
}

Btn_Reload(GuiCtrlObj := "", Info := "") {
    global allSettings, originalSettings, iniPath, lvSettings, tvSections, isDirty, currentSection, mainGui, sectionMap, sectionOrder, keyOrder
    
    if isDirty {
        result := MsgBox("You have unsaved changes. Reload anyway?", "Unsaved Changes", "YesNo Icon! 4096")
        if (result = "No") {
            return
        }
    }
    
    allSettings := Map()
    originalSettings := Map()
    
    if LoadINIFile(iniPath) {
        lvSettings.Delete()
        tvSections.Delete()
        
        sections := GetSections()
        sectionMap := Map()  ; Reset the map
        
        firstItemID := 0
        lastItemID := 0
        for section in sections {
            ; Add each section after the previous one to preserve order
            if (lastItemID = 0) {
                ItemID := tvSections.Add(section)
            } else {
                ItemID := tvSections.Add(section, , String(lastItemID))
            }
            sectionMap[ItemID] := section
            lastItemID := ItemID
            if (firstItemID = 0) {
                firstItemID := ItemID
            }
        }
        
        isDirty := false
        
        if (sections.Length > 0) {
            currentSection := sections[1]
            Tree_ItemSelect(tvSections, firstItemID)
        }
        
        ToolTip("Settings reloaded")
        SetTimer(() => ToolTip(), 2000)
    }
}

Btn_Save(GuiCtrlObj := "", Info := "") {
    global mainGui
    if SaveINIFile() {
        ; Note: SaveINIFile now handles restart prompts internally
        ToolTip("Settings saved successfully")
        SetTimer(() => ToolTip(), 2000)
    }
}

GUI_Close(GuiObj) {
    global isDirty, mainGui
    
    if isDirty {
        result := MsgBox("You have unsaved changes. Exit anyway?", "Unsaved Changes", "YesNo Icon! 4096")
        if (result = "No") {
            return 1  ; Prevent closing
        }
    }
    
    ExitApp
}

CheckAndHandleRestarts(modifiedKeys) {
    global mainGui, settingsMetadata
    
    appsToRestart := Array()
    
    ; Check metadata for each modified key
    for fullKey in modifiedKeys {
        ; Parse section and key from fullKey (format: "section.key")
        parts := StrSplit(fullKey, ".")
        if (parts.Length = 2) {
            section := parts[1]
            key := parts[2]
            metadata := GetMetadata(section, key)
            
            ; Check if this setting requires a restart
            if (metadata.Has("restart")) {
                restartPath := metadata["restart"]
                if (restartPath != "") {
                    ; Check if we already have this path queued
                    found := false
                    for app in appsToRestart {
                        if (app = restartPath) {
                            found := true
                            break
                        }
                    }
                    if (!found) {
                        appsToRestart.Push(restartPath)
                    }
                }
            }
        }
    }
    
    ; If there are apps to restart, prompt user
    if (appsToRestart.Length > 0) {
        ShowRestartDialog(appsToRestart)
    }
}

ShowRestartDialog(appsToRestart) {
    global mainGui
    
    appList := ""
    for app in appsToRestart {
        if (appList != "") {
            appList .= "`n"
        }
        appList .= "  • " app
    }
    
    result := MsgBox("The following application(s) need to be restarted for changes to take effect:`n`n" 
        . appList 
        . "`n`nRestart now?", 
        "Restart Required", 
        "YesNo Icon! 4096")
    
    if (result = "Yes") {
        launchCount := 0
        failedApps := Array()
        
        for app in appsToRestart {
            try {
                Run(app)
                launchCount++
            } catch as err {
                failedApps.Push(app " (Error: " err.What ")")
            }
        }
        
        if (failedApps.Length > 0) {
            failList := ""
            for failApp in failedApps {
                failList .= "  • " failApp "`n"
            }
            MsgBox("Successfully restarted: " launchCount " app(s)`n`nFailed to restart:`n" failList, 
                "Restart Partial", "Iconx 4096")
        } else if (launchCount > 0) {
            ToolTip("Application(s) restarted successfully")
            SetTimer(() => ToolTip(), 2000)
        }
    }
}

; ============================================================================
; TRAY MENU
; ============================================================================

SetupTrayMenu() {
    A_TrayMenu.Add("Select INI File", Tray_SelectFile)
    A_TrayMenu.Add("Reload Settings", Tray_Reload)
    A_TrayMenu.Add("Manage Metadata Keys", Tray_ManageMetadata)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit", Tray_Exit)
}

Tray_SelectFile(ItemName, ItemPos, MyMenu) {
    global iniPath, allSettings, originalSettings, mainGui, lvSettings, tvSections, currentSection, sectionMap, metadataPath, settingsMetadata, sectionOrder, keyOrder, IniFileName, MetadataFileName
    
    result := FileSelect(1, , "Select " IniFileName " file", "INI Files (*.ini)")
    
    if (result != "") {
        iniPath := result
        allSettings := Map()
        originalSettings := Map()
        settingsMetadata := Map()
        keyOrder := Map()
        
        if LoadINIFile(iniPath) {
            ; Try to find metadata file in same directory as INI
            dataDir := SubStr(iniPath, 1, InStr(iniPath, "\", , -1) - 1)
            metadataPath := dataDir "\" MetadataFileName
            
            ; Check if we need to generate a metadata skeleton
            CheckAndGenerateMetadata(metadataPath)
            
            ; Load metadata (optional)
            LoadMetadata(metadataPath)
            
            if (mainGui != "") {
                mainGui.Destroy()
            }
            CreateGUI()
        } else {
            MsgBox("Error loading file: " result, "Load Error")
        }
    }
}

Tray_Reload(ItemName, ItemPos, MyMenu) {
    Btn_Reload()
}

Tray_ManageMetadata(ItemName, ItemPos, MyMenu) {
    Btn_ManageMissingKeys()
}

Tray_Exit(ItemName, ItemPos, MyMenu) {
    ExitApp
}

; ============================================================================
; MAIN EXECUTION
; ============================================================================

; Initialize editor path (with fallback to VS Code)
ValidateAndInitializeEditorPath()

; Find INI file
iniPath := FindINIFile()

if (iniPath = "") {
    MsgBox("Could not find " IniFileName " file.`n`n"
        . "Expected location: " ExpectedDataDir "\" IniFileName "`n`n"
        . "Please use the tray menu to select the file manually.",
        "INI File Not Found", "Icon!")
    
    ; Setup tray menu for file selection
    SetupTrayMenu()
} else {
    ; Load settings
    if LoadINIFile(iniPath) {
        ; Load font and color settings
        LoadFontAndColors(iniPath)
        
        ; Try to find metadata file in same directory as INI
        dataDir := SubStr(iniPath, 1, InStr(iniPath, "\", , -1) - 1)
        metadataPath := dataDir "\" MetadataFileName
        
        ; Check if we need to generate a metadata skeleton
        CheckAndGenerateMetadata(metadataPath)
        
        ; Load metadata (optional)
        LoadMetadata(metadataPath)
        
        CreateGUI()
        SetupTrayMenu()
    } else {
        MsgBox("Error loading INI file: " iniPath, "Load Error")
        ExitApp
    }
}
