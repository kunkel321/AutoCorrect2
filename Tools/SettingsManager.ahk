#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; AutoCorrect2 Settings Manager - Standalone Application
; Version: 1.0 | Date: 2025-11-02
; 
; A dedicated GUI application for editing AutoCorrect2 Suite INI settings
; Run this independently to view/edit all configuration settings
; ============================================================================

; ============================================================================
; CONFIGURATION - Customize for different projects
; ============================================================================
AppName := "AutoCorrect2 Settings Manager"
IniFileName := "acSettings.ini"
MetadataFileName := "acSettingsMetadata.json"
ExpectedDataDir := "..\Data"  ; Relative path to expected data directory

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
; COLOR PICKER FUNCTION
; ============================================================================

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
    editGui.Opt("+AlwaysOnTop +Owner" mainGui.Hwnd)
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
    editGui.Opt("+AlwaysOnTop +Owner" mainGui.Hwnd)
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
    editGui.Opt("+AlwaysOnTop +Owner" mainGui.Hwnd)
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
    editGui.Opt("+AlwaysOnTop +Owner" mainGui.Hwnd)
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
                    MsgBox("Invalid characters found: " remainingInvalid "`n`nMust match pattern: " validationPattern, "Validation Error", "Iconx Owner" mainGui.Hwnd)
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

GenerateMetadataSkeleton() {
    global sectionOrder, keyOrder, allSettings
    
    quote := chr(34)  ; Double quote character
    json := "{"
    isFirst := true
    
    ; Add comment as first entry
    json .= "`n  " quote "_Comment" quote ": " quote 
    json .= "Please review and adjust field types as needed. Default type is 'text'. "
    json .= "Change to: file, integer, boolean, color, or hotkey as appropriate. "
    json .= "Boolean types can have custom 0/1 labels. Text types can have regex validation rules. "
    json .= "A sample JSON file can be found at https://github.com/kunkel321/AutoCorrect2 In the Data folder. "
    json .= "Feel free to remove this _Comment if desired." quote
    isFirst := false
    
    for section in sectionOrder {
        if keyOrder.Has(section) {
            for key in keyOrder[section] {
                if !isFirst
                    json .= ","
                isFirst := false
                
                fullKey := section "." key
                
                ; Detect type based on value
                fieldType := "text"
                if allSettings.Has(fullKey) {
                    value := allSettings[fullKey]
                    if (value = "0" || value = "1") {
                        fieldType := "boolean"
                    }
                }
                
                json .= "`n  " quote fullKey quote ": {"
                json .= "`n    " quote "label" quote ": " quote key quote ","
                json .= "`n    " quote "help" quote ": " quote "Help for " key " goes here" quote ","
                json .= "`n    " quote "type" quote ": " quote fieldType quote
                
                ; Add options for boolean types
                if (fieldType = "boolean") {
                    json .= ","
                    json .= "`n    " quote "options" quote ": ["
                    json .= "`n      " quote "0=Disabled" quote ","
                    json .= "`n      " quote "1=Enabled" quote
                    json .= "`n    ]"
                }
                
                json .= "`n  }"
            }
        }
    }
    
    json .= "`n}"
    return json
}

CheckAndGenerateMetadata(metadataPath) {
    fileInfo := FileExist(metadataPath)
    shouldGenerate := false
    
    if (fileInfo = "") {
        ; File doesn't exist
        result := MsgBox("No metadata file found.`n`nWould you like to generate a skeleton metadata file`nbased on the sections and keys in your INI file?`n`nThe metadata file needs to be a .JSON file and needs assigned to the MetadatFileName variable at the top of the SettingsManager.ahk code. The file will be created in the same folder as your INI file.`n`nYou can then customize the labels and help text.",
            "Generate Metadata?", "YesNo Icon?")
        shouldGenerate := (result = "Yes")
    } 
    else if (fileInfo = "A") {
        ; File exists, check if it's empty
        if (FileGetSize(metadataPath) = 0) {
            result := MsgBox("Metadata file is empty.`n`nWould you like to generate a skeleton in the file`nbased on the sections and keys in your INI file?`n`nYou can then customize the labels and help text.",
                "Generate Metadata?", "YesNo Icon?")
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
            MsgBox("Error creating metadata file: " err.What, "Error", "Iconx")
            return false
        }
    }
    
    return false
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
    global isDirty, iniPath, allSettings
    
    try {
        output := ""
        sections := GetSections()
        
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
                            ; Update with new value
                            output .= key "=" allSettings[fullKey] "`n"
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
    helpPane.Value := ""
    
    
    ; Status bar
    mainGui.Add("Text", "x10 y550 w730 h20 cGray c909090", "(Double-click to edit | Right-click to copy)")
    
    ; Button row
    btnEdit := mainGui.Add("Button", "x10 y575 w80 h30", "Edit")
    btnEdit.OnEvent("Click", Btn_Edit)
    
    mainGui.Add("Text", "x100 y575 w280 h30")  ; Spacer
    
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
        result := MsgBox("You have unsaved changes. Exit anyway?", "Unsaved Changes", "YesNo Icon! Owner" mainGui.Hwnd)
        if (result = "No") {
            return  ; Don't exit if user says No
        }
    }
    
    ExitApp  ; Exit the script completely
}

Btn_Reload(GuiCtrlObj := "", Info := "") {
    global allSettings, originalSettings, iniPath, lvSettings, tvSections, isDirty, currentSection, mainGui, sectionMap, sectionOrder, keyOrder
    
    if isDirty {
        result := MsgBox("You have unsaved changes. Reload anyway?", "Unsaved Changes", "YesNo Icon! Owner" mainGui.Hwnd)
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
        MsgBox("Settings saved successfully!", "Success", "Iconi Owner" mainGui.Hwnd)
    }
}

GUI_Close(GuiObj) {
    global isDirty, mainGui
    
    if isDirty {
        result := MsgBox("You have unsaved changes. Exit anyway?", "Unsaved Changes", "YesNo Icon! Owner" mainGui.Hwnd)
        if (result = "No") {
            return 1  ; Prevent closing
        }
    }
    
    ExitApp
}

; ============================================================================
; TRAY MENU
; ============================================================================

SetupTrayMenu() {
    A_TrayMenu.Add("Select INI File", Tray_SelectFile)
    A_TrayMenu.Add("Reload Settings", Tray_Reload)
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

Tray_Exit(ItemName, ItemPos, MyMenu) {
    ExitApp
}

; ============================================================================
; MAIN EXECUTION
; ============================================================================

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
