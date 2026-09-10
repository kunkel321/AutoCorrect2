#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Settings Manager - Standalone GUI for editing INI configuration files
; Version: 9-9-2026
; 
; A dedicated GUI application for viewing and editing INI settings with
; metadata-driven features: type-specific editing, auto-generation, validation,
; and quick navigation to properties in your preferred editor.
;
; QUICK START:
; ============================================================================
; 1. UPDATE CONFIGURATION (see below):
;    - Change AppName, IniFileName, MetadataFileName, ExpectedDataDir
;    - Set EditorCmd (optional, auto-detects VS Code)
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
; FLOAT:             { "type": "float", "min": 0, "max": 1, "decimals": 2 }
;                    Edit box + slider. "decimals" (default 2) sets both the
;                    slider step (10^-decimals) and the saved formatting, so
;                    0.6 is written back as 0.60.
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
;   - Integer: Whole numbers
;   - Float:   Numbers containing a decimal point
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
; RESIZABLE HELP PANE: The gray bar between the Settings list and the help pane
;   can be dragged up or down to trade space between them. Double-click the bar
;   to snap back to the startup split. The startup split is set by the
;   HELP_PANE_PCT variable below (percent of the middle area given to help);
;   it is intentionally not saved, so every launch starts at that percentage.
;
; RESIZABLE WINDOW: The whole dialog can be dragged to any size, down to the
;   MIN_W x MIN_H floor set below. The section tree keeps its width and the
;   button row keeps its height; everything else absorbs the change -- the
;   ListView, the help pane, and the Value column all grow with the window.
;   The divider keeps the PROPORTION it had rather than a fixed pixel height,
;   so both panes grow together. See GUI_Size() to change that.
;
; SEARCH / FILTER: The box in the top right narrows the display as you type.
;   Sections with no matches drop out of the tree, and non-matching keys drop
;   out of the list, so what is left on screen is exactly what matched. The
;   match is case-insensitive and covers the key name, the value, and (unless
;   SEARCH_INCLUDE_HELP is turned off below) the metadata label and help text.
;   A section whose NAME matches shows all of its keys. Esc or the X button
;   clears the filter; Ctrl+F jumps to the box. Filtering only changes what is
;   displayed -- nothing is edited, hidden permanently, or written to disk.
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

; ----------------------------------------------------------------------------
; "Go To" button — command used to open the metadata JSON AT the selected key.
;
; Two placeholders are substituted: {file} (full path) and {line} (line number).
; The key's line is found by scanning the JSON at click time, so it stays right
; even after the file has been edited behind SettingsManager's back.
;
; LEAVE BLANK to auto-detect VS Code (per-user install, then Program Files,
; then `code` on PATH) and use its -r -g form. Set it explicitly to use a
; different editor. Unlike the INI-stored EditorCmd used elsewhere in the
; suite, this is an AHK string literal, so it needs NO extra pair of quotes —
; write it exactly as you would type it at a command prompt. Single-quoted
; here so the double quotes around the paths can be typed literally.
;
; Replace <user> with your Windows user name, and correct any version-numbered
; folders for your install.
;
; VS Code (per-user install) — also VS Code Insiders, VSCodium, Cursor and
; Windsurf; same flags, different exe:
;   '"C:\Users\<user>\AppData\Local\Programs\Microsoft VS Code\Code.exe" -r -g "{file}:{line}"'
;
; VS Code (system-wide install):
;   '"C:\Program Files\Microsoft VS Code\Code.exe" -r -g "{file}:{line}"'
;
; Notepad++:
;   '"C:\Program Files\Notepad++\notepad++.exe" -n{line} "{file}"'
;
; SciTE / SciTE4AutoHotkey — the file name MUST come before -goto:, since SciTE
; processes arguments left to right and the file has to be open first:
;   '"C:\Program Files\AutoHotkey\SciTE\SciTE.exe" "{file}" -goto:{line}'
;
; Sublime Text:
;   '"C:\Program Files\Sublime Text\sublime_text.exe" "{file}:{line}"'
;
; UltraEdit / UEStudio:
;   '"C:\Program Files\IDM Computer Solutions\UltraEdit\uedit64.exe" "{file}" -l{line}'
;
; EmEditor — the switch is a lowercase L, and EmEditor's options are case
; sensitive:
;   '"C:\Program Files\EmEditor\EmEditor.exe" "{file}" /l {line}'
;
; jEdit:
;   '"C:\Program Files\jEdit\jedit.exe" "{file}" +line:{line}'
;
; gVim — the vim91 folder name changes with each version:
;   '"C:\Program Files\Vim\vim91\gvim.exe" +{line} "{file}"'
;
; JetBrains IDEs — swap idea64.exe for pycharm64.exe, webstorm64.exe,
; rider64.exe, etc:
;   '"C:\Program Files\JetBrains\IntelliJ IDEA\bin\idea64.exe" --line {line} "{file}"'
;
; Emacs — requires a running Emacs server; the version folder varies:
;   '"C:\Program Files\Emacs\emacs-30.1\bin\emacsclientw.exe" -n +{line} "{file}"'
;
; Windows Notepad — has no goto-line switch, so {line} is simply left out and
; the file opens at the top:
;   '"C:\Windows\System32\notepad.exe" "{file}"'
;
; Editors with no known goto-line switch (TextPad, EditPlus, PSPad, AkelPad)
; can use that plain-open form too, substituting only {file}. Omitting {line}
; is supported everywhere — the line number is simply reported in a tooltip
; instead, so you can jump to it yourself.
; ----------------------------------------------------------------------------
EditorCmd := ""  ; Leave blank to auto-detect VS Code, or set your own command

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
helpLabel := ""
sectionMap := Map()  ; Maps TreeView ItemID to section name

; ----------------------------------------------------------------------------
; Splitter (draggable divider between the TreeView/ListView and the help pane)
; ----------------------------------------------------------------------------

; ==== TUNABLE ================================================================
; Percentage of the splittable area given to the help region at startup.
; The help region is everything below the divider: the divider bar itself, the
; "Help for: ..." label, and the help pane. Bigger number = taller help pane and
; a shorter TreeView/ListView. 26 reproduces the old fixed layout.
; Clamped to the MIN_LIST / MIN_HELP limits below, so silly values are safe.
HELP_PANE_PCT := 40
; =============================================================================

; Layout constants. All values are Gui layout units (AHK scales them by DPI).
; Anything that used to be a fixed Y coordinate is now derived from the live
; window height instead -- see the geometry functions further down.
SPLIT_H   := 5            ; Visual thickness of the divider bar
SPLIT_GRAB := 3           ; Extra pixels above/below the bar that still "grab"
MARGIN    := 10           ; Outer margin on all four sides
TREE_W    := 150          ; Width of the Sections TreeView (does not change)
COL_GAP   := 10           ; Gap between the TreeView and the ListView
TOP_ROW_Y := 6            ; Top edge of the search box
SEARCH_H  := 26           ; Height of the search box
LIST_TOP  := 38           ; Top edge of the TreeView and ListView
BTN_H     := 30           ; Height of the buttons along the bottom
STATUS_H  := 20           ; Height of the "(Double-click to edit...)" text
BOTTOM_GAP := 8           ; Gap between the help pane and the status text
MIN_LIST  := 120          ; Smallest allowed TreeView/ListView height
MIN_HELP  := 40           ; Smallest allowed help pane height
LABEL_H   := 22           ; Height reserved for the help label above the pane
SPLIT_GAP := 5            ; Gap between the divider and the help label

; Startup size, and the smallest the window may be dragged to.
START_W := 750
START_H := 615
MIN_W   := 620
MIN_H   := 460

; Live client size of the window, in layout units. Kept up to date by
; GUI_Size(). Seeded with the startup size because the first LayoutMain() runs
; before Show(), and therefore before the first Size event arrives.
winW := START_W
winH := START_H

splitter := ""            ; The divider control itself
splitY   := 0             ; Current top edge of the divider, in layout units.
                          ; Set for real by CreateGUI() via ClampSplit().
splitPct := HELP_PANE_PCT ; Share of the splittable area given to the help
                          ; region, as a percent. This -- not splitY -- is what
                          ; survives a window resize, so the two panes keep
                          ; their proportions as the window grows and shrinks.
                          ; Deliberately not persisted -- resets every launch.

; ----------------------------------------------------------------------------
; Search / filter
; ----------------------------------------------------------------------------

; ==== TUNABLE ================================================================
; Whether a hit in the metadata "label" or "help" text counts as a match. On by
; default: the help text is where the human-readable wording lives, so it finds
; things the key names alone never would. The trade-off is that a row can show
; up with nothing visibly matching in either column, because the match was in
; the help pane text. Set to false if that gets noisy.
SEARCH_INCLUDE_HELP := true
SEARCH_MIN_CHARS    := 2    ; Fewer characters than this is treated as no filter
SEARCH_DEBOUNCE     := 200  ; ms of idle typing before the filter is applied
; =============================================================================

searchBox := ""           ; The Edit control you type the filter into
searchCount := ""         ; "12 matches in 4 sections" label beside it
btnClearSearch := ""      ; The little X button
statusText := ""          ; The line above the button row
lblSections := ""         ; "Sections:" heading
lblSettings := ""         ; "Settings" heading
btnRow := Array()         ; [{ctrl, x, w}, ...] for the bottom button row
searchText := ""          ; The filter currently in force ("" means show all)
filteredSections := Array()   ; Sections surviving the filter, in INI order
STATUS_DEFAULT_TEXT := "(Double-click to edit | Right-click to copy)"

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

; Fill in EditorCmd when the user left it blank, by locating VS Code and
; wrapping its path in the -r -g form:
;   -r  reuse the existing window instead of opening a second one
;   -g  "go to" — the file:line syntax that follows
; Falls back to the bare `code` shim on PATH, which covers installs in unusual
; folders. That last resort is NOT verified with FileExist (it's a .cmd on the
; PATH, not an absolute path), so it may still fail at Run() time — Btn_GoTo
; catches that and degrades to opening the file with its default handler.
ResolveEditorCmd() {
    global EditorCmd

    if (Trim(EditorCmd) != "")
        return

    ; A_AppData is Roaming; VS Code's per-user install lives under Local, so
    ; that one is read from the environment rather than derived with a "\.."
    ; traversal, which would work for FileExist but bake an ugly path into the
    ; command line.
    localApp := EnvGet("LOCALAPPDATA")

    candidates := [
        (localApp != "" ? localApp "\Programs\Microsoft VS Code\Code.exe" : ""),
        "C:\Program Files\Microsoft VS Code\Code.exe",
        "C:\Program Files (x86)\Microsoft VS Code\Code.exe"
    ]

    for path in candidates {
        if (path != "" && FileExist(path)) {
            EditorCmd := '"' path '" -r -g "{file}:{line}"'
            return
        }
    }

    EditorCmd := 'code -r -g "{file}:{line}"'
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
    
    ; Load theme colors from colorThemeSettings.ini (optional; AC2 suite only).
    ; Anchored to A_ScriptDir for the same reason as FindINIFile above.
    colorThemeFile := A_ScriptDir "\..\Data\colorThemeSettings.ini"
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

EditFloat(section, key, originalValue) {
    ; Decimal editor. Deliberately NOT an Edit with the Number option -- that
    ; style rejects the decimal point itself. A Slider is paired with the Edit
    ; because most float settings here are 0.0-1.0 blend factors, where dragging
    ; is more natural than typing. The Slider works in integer "ticks", so the
    ; value is scaled by 10^decimals in both directions.
    global mainGui, allSettings, isDirty, lvSettings, settingsMetadata, DefaultFontSize, FormColor, FontColor, ListColor
    
    metadata := GetMetadata(section, key)
    minVal := metadata.Has("min") ? Float(metadata["min"]) : 0.0
    maxVal := metadata.Has("max") ? Float(metadata["max"]) : 1.0
    decimals := metadata.Has("decimals") ? Integer(metadata["decimals"]) : 2
    if (decimals < 1)
        decimals := 1
    if (decimals > 6)
        decimals := 6
    
    scale := 10 ** decimals
    fmt := "{:." decimals "f}"
    
    editGui := Gui()
    editGui.Opt("+AlwaysOnTop +4096")
    editGui.Title := "Edit Decimal Setting"
    editGui.BackColor := FormColor
    editGui.SetFont(DefaultFontSize " " FontColor)
    
    editGui.Add("Text", "x10 y10 w360 h20", section "." key)
    editGui.Add("Text", "x10 y35 w360 h20"
        , "Value (range " Format(fmt, minVal) " to " Format(fmt, maxVal) "):")
    
    valueEdit := editGui.Add("Edit", "x10 y60 w120 h25 vFloatValue Background" ListColor, originalValue)
    
    ; Slider spans the range in 10^decimals steps
    startTick := Round(Float(originalValue != "" ? originalValue : minVal) * scale)
    if (startTick < Round(minVal * scale))
        startTick := Round(minVal * scale)
    if (startTick > Round(maxVal * scale))
        startTick := Round(maxVal * scale)
    
    slider := editGui.Add("Slider", "x140 y60 w230 h30 NoTicks vFloatSlider"
        . " Range" Round(minVal * scale) "-" Round(maxVal * scale), startTick)
    
    SyncFromSlider(GuiCtrlObj, Info) {
        valueEdit.Value := Format(fmt, slider.Value / scale)
    }
    
    SyncFromEdit(GuiCtrlObj, Info) {
        typed := Trim(valueEdit.Value)
        if RegExMatch(typed, "^[+-]?(\d+(\.\d*)?|\.\d+)$") {
            tick := Round(Float(typed) * scale)
            if (tick >= Round(minVal * scale) && tick <= Round(maxVal * scale))
                slider.Value := tick
        }
    }
    
    slider.OnEvent("Change", SyncFromSlider)
    valueEdit.OnEvent("Change", SyncFromEdit)
    
    btnOK := editGui.Add("Button", "x200 y105 w80 h30 Default", "OK")
    btnCancel := editGui.Add("Button", "x290 y105 w80 h30", "Cancel")
    
    EditDlg_OK(GuiCtrlObj, Info) {
        submitted := editGui.Submit(0)
        newValue := Trim(submitted.FloatValue)
        
        ; Must look like a number. Note the leading "." form (.5) is accepted
        ; here but normalized to 0.50 below.
        if !RegExMatch(newValue, "^[+-]?(\d+(\.\d*)?|\.\d+)$") {
            MsgBox("'" newValue "' is not a valid decimal number.", "Invalid Value", "Iconx 4096")
            return
        }
        
        numValue := Float(newValue)
        
        if (numValue < minVal) {
            MsgBox("Value must be at least " Format(fmt, minVal), "Invalid Value", "Iconx 4096")
            return
        }
        if (numValue > maxVal) {
            MsgBox("Value must be at most " Format(fmt, maxVal), "Invalid Value", "Iconx 4096")
            return
        }
        
        ; Normalize to a fixed number of decimals so the INI stays tidy and
        ; values like .5 or 0.5 are written consistently as 0.50
        newValue := Format(fmt, numValue)
        
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
    
    editGui.Show("w385 h150")
}

EditHotkey(section, key, originalValue) {
    global mainGui, allSettings, isDirty, lvSettings, DefaultFontSize, FormColor, FontColor
    
    editGui := Gui()
    editGui.Opt("+AlwaysOnTop +4096")
    editGui.Title := "Edit Hotkey Setting"
    editGui.BackColor := FormColor
    editGui.SetFont(DefaultFontSize " " FontColor)
    
    editGui.Add("Text", "x10 y10 w400 h20", section "." key)
    editGui.Add("Text", "x10 y32 w400", "Enter the hotkey combination (e.g., Ctrl+H, F12)`nOr leave blank for no hotkey`nNote: Use the Win checkbox below to include the Win key")
    
    ; Determine if Win key is present and prepare hotkey value without Win prefix
    hasWinKey := InStr(originalValue, "#") > 0
    hotkeyValue := StrReplace(originalValue, "#", "")
    
    hotkeyCtrl := editGui.Add("Hotkey", "x10 y+10 w300 h25 vHotkeyValue", hotkeyValue)
    winCheckbox := editGui.Add("Checkbox", "x10 y+4 w250 h25 vWinKey", "Include Win Key")
    
    ; Pre-check Win Key if "#" was present
    if (hasWinKey) {
        winCheckbox.Value := 1
    }
    
    btnOK := editGui.Add("Button", "x120 y155 w80 h30 Default", "OK")
    btnCancel := editGui.Add("Button", "x210 y155 w80 h30", "Cancel")
    
    EditDlg_OK(GuiCtrlObj, Info) {
        submitted := editGui.Submit(0)
        hotkey := submitted.HotkeyValue
        includeWin := submitted.WinKey
        
        ; Allow empty hotkey (no hotkey assigned)
        if (hotkey != "") {
            ; Add Win key prefix if checked
            if (includeWin) {
                hotkey := "#" hotkey
            }
        } else {
            ; Empty hotkey is valid - means "no hotkey assigned"
            includeWin := 0
        }
        
        fullKey := section "." key
        allSettings[fullKey] := hotkey
        displayValue := (hotkey = "") ? "(none)" : hotkey
        lvSettings.Modify(lvSettings.GetNext(0), , key, displayValue)
        isDirty := true
        
        editGui.Destroy()
        ToolTip("Hotkey updated: " displayValue)
        SetTimer(() => ToolTip(), 1500)
    }
    
    EditDlg_Cancel(GuiCtrlObj, Info) {
        editGui.Destroy()
    }
    
    btnOK.OnEvent("Click", EditDlg_OK)
    btnCancel.OnEvent("Click", EditDlg_Cancel)
    
    editGui.Show("w450 h210")
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
    
    ; 2b. FLOAT: digits with a decimal point (0.55, 1.20, .5, -2.0)
    ; Must be tested before FILE, or a value like 1.234 is mistaken for a
    ; filename with a ".234" extension.
    if (RegExMatch(value, "^-?(\d+\.\d*|\.\d+)$")) {
        return "float"
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

GetMinMaxForFloat(value) {
    ; Decimal settings in this suite are nearly always either a 0.0-1.0
    ; fraction (blend strengths, confidence scores) or a small multiplier.
    ; Also reports how many decimal places the sample value carries, so the
    ; saved value can keep its formatting (0.60 stays 0.60, not 0.6).
    
    decimals := 2
    if (dotPos := InStr(value, ".")) {
        decimals := StrLen(value) - dotPos
        if (decimals < 1)
            decimals := 1
        if (decimals > 6)
            decimals := 6
    }
    
    numValue := Float(value)
    
    if (numValue <= 1.0)
        return { min: 0, max: 1, decimals: decimals }
    
    maxValue := Ceil(numValue * 2)
    return { min: 0, max: maxValue, decimals: decimals }
}

GetMinMaxForInteger(value) {
    ; If value <= 50, use 0-100
    ; If value > 50, use 0 to value*1.5 rounded up to nearest 10
    
    ; Guard: a mistyped decimal would make Integer() throw
    if !RegExMatch(value, "^-?\d+$")
        return { min: 0, max: 100 }
    
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
                    
                    case "float":
                        range := GetMinMaxForFloat(value)
                        json .= ","
                        json .= "`n    " quote "min" quote ": " range.min ","
                        json .= "`n    " quote "max" quote ": " range.max ","
                        json .= "`n    " quote "decimals" quote ": " range.decimals
                    
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
    global allSettings, iniPath, mainGui, metadataPath
    
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
            jsonPath := metadataPath  ; was hard-coded to the AutoCorrect2 filename
            
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
    global iniPath, allSettings, metadataPath
    
    missingKeys := Array()
    
    jsonPath := metadataPath  ; was hard-coded to the AutoCorrect2 filename
    
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
    global iniPath, allSettings, metadataPath
    
    unusedKeys := Array()
    
    jsonPath := metadataPath  ; was hard-coded to the AutoCorrect2 filename
    
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
        
        case "float":
            range := GetMinMaxForFloat(value)
            obj .= ",`n    " q "min" q ": " range.min ",`n"
            obj .= "    " q "max" q ": " range.max ",`n"
            obj .= "    " q "decimals" q ": " range.decimals
        
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
        
        case "float":
            range := GetMinMaxForFloat(value)
            entry .= ",`n      " q "min" q ": " range.min ",`n"
            entry .= "      " q "max" q ": " range.max ",`n"
            entry .= "      " q "decimals" q ": " range.decimals
        
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
        jsonPath := metadataPath  ; was hard-coded to the AutoCorrect2 filename
        
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
            ; Trim() alone leaves the `r of a CRLF file attached, which would
            ; end up glued to numeric fields (min/max/decimals) and break them.
            line := Trim(line, " `t`r`n")
            
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
                        ; String value: extract between quotes, skipping escaped quotes (\")
                        valueStr := SubStr(valueStr, 2)
                        endQuote := 0
                        searchPos := 1
                        Loop {
                            foundPos := InStr(valueStr, '"', , searchPos)
                            if (foundPos = 0)
                                break
                            ; Check if this quote is escaped (preceded by backslash)
                            if (foundPos > 1 && SubStr(valueStr, foundPos - 1, 1) = "\") {
                                searchPos := foundPos + 1  ; Skip past this escaped quote
                                continue
                            }
                            endQuote := foundPos
                            break
                        }
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
    ; Look for INI file - portable app structure.
    ; A relative ExpectedDataDir is resolved against A_ScriptDir, NOT against
    ; A_WorkingDir. When another script launches this one with Run(), the
    ; working directory is inherited from the launcher, so a bare "..\Data"
    ; would point somewhere else entirely.
    dataDir := ExpectedDataDir
    if !RegExMatch(dataDir, "^([A-Za-z]:|\\\\)")     ; not already absolute
        dataDir := A_ScriptDir "\" dataDir
    
    possiblePaths := [
        dataDir "\" IniFileName,
        A_ScriptDir "\" IniFileName,
        A_ScriptDir "\Data\" IniFileName
    ]
    
    for path in possiblePaths {
        if FileExist(path) {
            ; Normalize to a full path so metadataPath is derived correctly
            loop files path
                return A_LoopFileFullPath
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

; Appends every key of `section` that has not been written yet to outLines.
; Called just before we leave a section (i.e. when the next [Header] is reached
; and again at end of file) so that keys which are new to the INI land inside
; their own section instead of being dumped at the bottom of the file.
; Any blank lines that were sitting at the end of the section are lifted off
; first and put back afterwards, so the file keeps its blank-line spacing.
FlushSectionKeys(section, outLines, processedKeys, modifiedKeys) {
    global allSettings, originalSettings, keyOrder
    
    if (section = "" || !keyOrder.Has(section))
        return
    
    ; Collect the keys still owed to this section, in INI order
    pending := Array()
    for key in keyOrder[section] {
        fullKey := section "." key
        if (!processedKeys.Has(fullKey) && allSettings.Has(fullKey))
            pending.Push(key)
    }
    if (pending.Length = 0)
        return
    
    ; Lift trailing blank lines so new keys go above them, not after
    trailing := Array()
    while (outLines.Length > 0 && Trim(outLines[outLines.Length]) = "") {
        trailing.InsertAt(1, outLines.Pop())
    }
    
    for key in pending {
        fullKey := section "." key
        outLines.Push(key "=" allSettings[fullKey])
        processedKeys[fullKey] := true
        modifiedKeys.Push(fullKey)
    }
    
    for blank in trailing {
        outLines.Push(blank)
    }
}

SaveINIFile() {
    global isDirty, iniPath, allSettings, originalSettings, mainGui, keyOrder
    
    try {
        sections := GetSections()
        modifiedKeys := Array()  ; Track which keys were modified
        processedKeys := Map()   ; fullKeys already written out
        outLines := Array()      ; The new file, one entry per line
        
        ; Read original file to preserve comments and structure
        if FileExist(iniPath) {
            content := FileRead(iniPath)
            currentSection := ""
            
            ; Process existing content, updating values as needed.
            ; NOTE: the third parameter of Loop Parse strips the carriage return
            ; from a CRLF file. Trim() does NOT remove `r -- it only removes
            ; spaces and tabs -- and leaving the `r attached was what made the
            ; "]" test below fail on every section header, which in turn left
            ; currentSection empty, skipped every key update, and dumped the
            ; whole settings map at the bottom of the file on every save.
            loop parse content, "`n", "`r" {
                line := A_LoopField
                trimmedLine := Trim(line)
                
                ; Handle section headers
                if (SubStr(trimmedLine, 1, 1) = "[" && SubStr(trimmedLine, -1) = "]") {
                    ; Finish the section we are leaving before starting the new one
                    FlushSectionKeys(currentSection, outLines, processedKeys, modifiedKeys)
                    currentSection := SubStr(trimmedLine, 2, -1)
                    outLines.Push(line)
                    continue
                }
                
                ; Preserve comments and empty lines
                if (trimmedLine = "" || SubStr(trimmedLine, 1, 1) = ";") {
                    outLines.Push(line)
                    continue
                }
                
                ; Handle key=value pairs
                if (currentSection != "") {
                    eqPos := InStr(trimmedLine, "=")
                    if (eqPos > 1) {
                        key := Trim(SubStr(trimmedLine, 1, eqPos - 1))
                        fullKey := currentSection "." key
                        
                        if (allSettings.Has(fullKey) && !processedKeys.Has(fullKey)) {
                            newValue := allSettings[fullKey]
                            oldValue := originalSettings.Has(fullKey) ? originalSettings[fullKey] : ""
                            
                            ; Check if value changed
                            if (newValue != oldValue) {
                                modifiedKeys.Push(fullKey)
                            }
                            
                            ; Update with new value
                            outLines.Push(key "=" newValue)
                            processedKeys[fullKey] := true
                        } else {
                            ; Unknown key, or a stray duplicate we already wrote.
                            ; Keep the original line so nothing is silently lost.
                            outLines.Push(line)
                        }
                        continue
                    }
                }
                
                outLines.Push(line)
            }
            
            ; Finish the final section of the file
            FlushSectionKeys(currentSection, outLines, processedKeys, modifiedKeys)
            
            ; Any section that is not in the file at all gets appended whole
            for section in sections {
                needsHeader := false
                for key in (keyOrder.Has(section) ? keyOrder[section] : Array()) {
                    if (!processedKeys.Has(section "." key) && allSettings.Has(section "." key)) {
                        needsHeader := true
                        break
                    }
                }
                if (needsHeader) {
                    outLines.Push("")
                    outLines.Push("[" section "]")
                    FlushSectionKeys(section, outLines, processedKeys, modifiedKeys)
                }
            }
        } else {
            ; Create new file from scratch
            for section in sections {
                outLines.Push("[" section "]")
                settings := GetSectionSettings(section)
                for key, value in settings {
                    outLines.Push(key "=" value)
                    fullKey := section "." key
                    processedKeys[fullKey] := true
                    modifiedKeys.Push(fullKey)
                }
                outLines.Push("")
            }
        }
        
        ; Join with CRLF -- the Windows INI convention, and what the
        ; GetPrivateProfileString API (IniRead) expects.
        output := ""
        for outLine in outLines {
            output .= outLine "`r`n"
        }
        
        ; Trim trailing newlines to prevent accumulation, then end with exactly one
        output := RTrim(output, "`r`n") "`r`n"
        
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
    global splitter, splitY, SPLIT_H, LIST_TOP, MARGIN, TREE_W, COL_GAP, TOP_ROW_Y, SEARCH_H
    global searchBox, searchCount, btnClearSearch, statusText, btnRow, lblSections, lblSettings
    global winW, winH, START_W, START_H, MIN_W, MIN_H, STATUS_DEFAULT_TEXT

    mainGui := Gui()
    mainGui.Opt("+AlwaysOnTop +Resize +MinSize" MIN_W "x" MIN_H)
    mainGui.Title := AppName
    mainGui.OnEvent("Close", GUI_Close)
    mainGui.OnEvent("Size", GUI_Size)

    ; Set font and background color for entire GUI
    mainGui.BackColor := FormColor
    mainGui.SetFont(DefaultFontSize " " FontColor)

    winW := START_W
    winH := START_H

    ; NOTE ON COORDINATES: every x/y/w/h below is a placeholder. LayoutMain() is
    ; called at the end of this function and again on every resize, and it is
    ; the single authority on where anything sits. Change positions there, not
    ; here -- editing these numbers has no lasting effect.

    ; --- Top row: the two column headings, and the search box on the right ---
    lblSections := mainGui.Add("Text", "x10 y12 w150 h20", "Sections:")
    lblSettings := mainGui.Add("Text", "x170 y12 w100 h20", "Settings")
    searchCount := mainGui.Add("Text", "x280 y12 w200 h20 Right", "")

    searchBox := mainGui.Add("Edit", "x490 y" TOP_ROW_Y " w200 h" SEARCH_H
        . " vSearchBox Background" ListColor, "")
    searchBox.OnEvent("Change", Search_Changed)
    SetCueBanner(searchBox, "Filter settings...")

    btnClearSearch := mainGui.Add("Button", "x694 y" TOP_ROW_Y " w26 h" SEARCH_H, "X")
    btnClearSearch.OnEvent("Click", Btn_ClearSearch)

    ; Sections TreeView
    tvSections := mainGui.Add("TreeView", "x10 y" LIST_TOP " w150 h370 vSectionTree Background" ListColor)
    tvSections.OnEvent("ItemSelect", Tree_ItemSelect)

    ; Settings ListView. Column 2 is re-widened to fill the control by
    ; StretchValueColumn() during every layout pass, so 330 is just a starting
    ; point; column 1 keeps whatever width you drag it to.
    lvSettings := mainGui.Add("ListView", "x170 y" LIST_TOP " w570 h370 vSettingsList"
        . " Grid AltSubmit Checked Background" ListColor, ["Setting", "Value"])
    lvSettings.ModifyCol(1, 250)
    lvSettings.ModifyCol(2, 330)
    lvSettings.OnEvent("ContextMenu", List_ContextMenu)
    lvSettings.OnEvent("DoubleClick", List_DoubleClick)
    lvSettings.OnEvent("ItemSelect", List_ItemSelect)

    ; Draggable splitter between the TreeView/ListView above and the help pane below
    splitter := mainGui.Add("Text", "x10 y420 w730 h" SPLIT_H " Background909090")

    ; Help pane at bottom
    helpLabel := mainGui.Add("Text", "x10 y445 w730 h20 vHelpLabel", "Select a setting for help")
    helpPane := mainGui.Add("Edit", "x10 y467 w730 h75 ReadOnly vHelpPane Background" ListColor, "")
    helpPane.Value := "Select an item and press Go To to open it in your preferred editor."

    ; Status bar. Doubles as the "you are currently filtered" warning line.
    statusText := mainGui.Add("Text", "x10 y550 w730 h20 c909090", STATUS_DEFAULT_TEXT)

    ; Button row. Each button's X offset and width are recorded so LayoutMain()
    ; can slide the whole row down on a resize without re-deriving them.
    btnRow := Array()
    AddRowButton(10,  80,  "Edit",              Btn_Edit)
    AddRowButton(100, 150, "Validate Metadata", Btn_ValidateMetadata)
    AddRowButton(260, 80,  "Go To",             Btn_GoTo)
    AddRowButton(390, 100, "Open INI File",     Btn_OpenINI)
    AddRowButton(500, 80,  "Reload",            Btn_Reload)
    AddRowButton(590, 60,  "Save",              Btn_Save)
    AddRowButton(660, 60,  "Exit",              Btn_Exit)

    ; Fill the section tree and select the first section. With no search text
    ; in force this shows every section, exactly as it always did.
    RebuildTree()

    ; Apply the initial split (clamped, in case HELP_PANE_PCT is out of range),
    ; then hook the mouse messages that drive dragging.
    splitY := ClampSplit(SplitDefault())
    LayoutMain()
    OnMessage(0x0201, Splitter_LButtonDown)   ; WM_LBUTTONDOWN - start a drag
    OnMessage(0x0020, Splitter_SetCursor)     ; WM_SETCURSOR - show the resize cursor

    mainGui.Show("w" START_W " h" START_H)
}

; Adds one button to the bottom row and records the geometry LayoutMain needs.
AddRowButton(x, w, caption, handler) {
    global mainGui, btnRow, BTN_H

    ctrl := mainGui.Add("Button", "x" x " y575 w" w " h" BTN_H, caption)
    ctrl.OnEvent("Click", handler)
    btnRow.Push({ctrl: ctrl, x: x, w: w})
}

; Grey prompt text shown inside an Edit control while it is empty.
SetCueBanner(ctrl, text) {
    static EM_SETCUEBANNER := 0x1501
    DllCall("user32\SendMessageW", "Ptr", ctrl.Hwnd, "UInt", EM_SETCUEBANNER,
            "Ptr", 1, "WStr", text)
}

; ============================================================================
; SEARCH / FILTER
; ============================================================================
;
; Typing in the search box narrows BOTH levels of the display: the TreeView is
; rebuilt to show only sections holding at least one match, and the ListView
; shows only the matching keys inside whichever section is selected. What is
; left on screen is exactly the set of matches.
;
; Nothing is destroyed by this. The filter is applied when the tree and list are
; populated, and clearing the box puts everything back untouched. allSettings,
; keyOrder and sectionOrder are never modified, so Save, Validate and Go To
; behave identically whether a filter is in force or not.
;
; A section whose NAME matches passes all of its keys through, so typing part of
; a section name shows that whole section.
; ============================================================================

; Called on every keystroke. The real work is deferred by SEARCH_DEBOUNCE ms so
; a fast typist doesn't trigger one full tree rebuild per character. Each new
; keystroke resets the timer, so only the pause at the end of typing costs
; anything.
Search_Changed(GuiCtrlObj := "", Info := "") {
    global SEARCH_DEBOUNCE
    SetTimer(ApplySearchFilter, -SEARCH_DEBOUNCE)
}

ApplySearchFilter() {
    global searchBox, searchText, SEARCH_MIN_CHARS

    raw := Trim(searchBox.Value)

    ; A single character matches nearly everything, which makes the display
    ; flicker for no benefit, so treat it as "no filter yet".
    if (StrLen(raw) < SEARCH_MIN_CHARS)
        raw := ""

    if (raw = searchText)        ; nothing actually changed
        return

    searchText := raw
    RebuildTree()
    UpdateSearchStatus()
}

; True when this key should be visible under the current filter.
MatchesSearch(section, key) {
    global allSettings, searchText, SEARCH_INCLUDE_HELP

    if (searchText = "")
        return true

    ; InStr is case-insensitive by default in v2, which is what we want here.
    if InStr(key, searchText) || InStr(section, searchText)
        return true

    fullKey := section "." key
    if (allSettings.Has(fullKey) && InStr(allSettings[fullKey], searchText))
        return true

    if (SEARCH_INCLUDE_HELP) {
        md := GetMetadata(section, key)
        if (md.Has("label") && InStr(md["label"], searchText))
            return true
        if (md.Has("help") && InStr(md["help"], searchText))
            return true
    }

    return false
}

; True when a section should stay in the tree under the current filter.
SectionHasMatch(section) {
    global keyOrder, searchText

    if (searchText = "")
        return true
    if InStr(section, searchText)
        return true
    if keyOrder.Has(section) {
        for key in keyOrder[section] {
            if MatchesSearch(section, key)
                return true
        }
    }
    return false
}

; How many keys in a section survive the current filter.
SectionMatchCount(section) {
    global keyOrder

    n := 0
    if keyOrder.Has(section) {
        for key in keyOrder[section] {
            if MatchesSearch(section, key)
                n++
        }
    }
    return n
}

; Rebuilds the TreeView from scratch, skipping sections with no matches.
; A TreeView has no way to hide an item, so a rebuild is the only option -- and
; it is cheap here, since the section list is short.
;
; The section that was selected stays selected if it survives the filter;
; otherwise the first surviving section is selected instead, so the ListView
; always shows something as long as anything matched at all.
RebuildTree() {
    global tvSections, lvSettings, helpLabel, helpPane, sectionMap, currentSection
    global filteredSections

    prevSection := currentSection
    filteredSections := Array()
    sectionMap := Map()

    tvSections.Opt("-Redraw")
    tvSections.Delete()

    firstID := 0, targetID := 0
    for section in GetSections() {
        if !SectionHasMatch(section)
            continue
        filteredSections.Push(section)

        ; A plain Add appends to the end of the root, which is what preserves
        ; the INI's own section order.
        ItemID := tvSections.Add(section)
        sectionMap[ItemID] := section

        if (firstID = 0)
            firstID := ItemID
        if (section = prevSection)
            targetID := ItemID
    }
    tvSections.Opt("+Redraw")
    tvSections.Redraw()

    selectID := targetID ? targetID : firstID
    if (selectID) {
        ; Modify raises ItemSelect on its own, but calling the handler directly
        ; as well guarantees the ListView is populated -- and a second pass over
        ; a couple of dozen rows costs nothing.
        tvSections.Modify(selectID, "Select Vis")
        Tree_ItemSelect(tvSections, selectID)
    } else {
        ; Filter matched nothing anywhere.
        currentSection := ""
        lvSettings.Delete()
        helpLabel.Value := "No matches"
        helpPane.Value := ""
    }
}

; Refreshes the counter beside the search box and the status line underneath.
; The status line turns red while a filter is in force -- the whole risk of
; filtering is forgetting you are filtered and concluding a key doesn't exist.
UpdateSearchStatus() {
    global searchCount, statusText, searchText, filteredSections, STATUS_DEFAULT_TEXT

    if (searchText = "") {
        searchCount.Value := ""
        statusText.Value := STATUS_DEFAULT_TEXT
        try statusText.SetFont("c909090")
        searchCount.Redraw()
        statusText.Redraw()
        return
    }

    total := 0
    for section in filteredSections
        total += SectionMatchCount(section)

    secs := filteredSections.Length
    searchCount.Value := total . " " . (total = 1 ? "match" : "matches")
        . " in " . secs . " " . (secs = 1 ? "section" : "sections")
    statusText.Value := "Filtered by '" . searchText
        . "' - press Esc or click X to show everything"
    try statusText.SetFont("cC00000")
    searchCount.Redraw()
    statusText.Redraw()
}

; Empties the search box and restores the full tree and list.
ClearSearch() {
    global searchBox, searchText

    if (searchBox.Value = "" && searchText = "")
        return

    searchBox.Value := ""
    searchText := ""
    SetTimer(ApplySearchFilter, 0)   ; cancel any pending debounced pass
    RebuildTree()
    UpdateSearchStatus()
}

Btn_ClearSearch(GuiCtrlObj := "", Info := "") {
    global searchBox
    ClearSearch()
    try searchBox.Focus()
}

; Ctrl+F target: focus the box and select whatever is in it, so typing replaces
; the previous search instead of appending to it.
FocusSearch() {
    global searchBox
    try {
        searchBox.Focus()
        SendMessage(0x00B1, 0, -1, searchBox)   ; EM_SETSEL, select all
    }
}

; ============================================================================
; LAYOUT AND SPLITTER
; ============================================================================
;
; LayoutMain() is the single authority on where every control sits. It runs once
; at startup, on every window resize, and on every tick of a divider drag. The
; coordinates passed to Gui.Add() in CreateGUI() are placeholders only.
;
; The vertical model, top to bottom:
;
;     TOP_ROW_Y   headings + search box            (fixed to the top)
;     LIST_TOP    TreeView / ListView              (absorbs the slack)
;     splitY      the divider                      (dragged, or proportional)
;                 help label + help pane           (absorbs the slack)
;     StatusY()   status text                      (fixed to the bottom)
;     ButtonRowY  button row                       (fixed to the bottom)
;
; Horizontally the TreeView keeps TREE_W; the ListView, divider, help label,
; help pane and status text all stretch to the window width.
; ============================================================================

; ----------------------------------------------------------------------------
; Geometry. These used to be constants computed once at load. Now that the
; window can be resized, everything anchored to the bottom edge has to be
; derived from the live client height instead.
; ----------------------------------------------------------------------------

; Top edge of the button row.
ButtonRowY() {
    global winH, MARGIN, BTN_H
    return winH - MARGIN - BTN_H
}

; Top edge of the "(Double-click to edit...)" status text.
StatusY() {
    global STATUS_H
    return ButtonRowY() - STATUS_H - 5
}

; Bottom edge of the splittable area -- everything below this is fixed.
SplitBottom() {
    global BOTTOM_GAP
    return StatusY() - BOTTOM_GAP
}

; Total height shared by the list region and the help region.
SplitAvail() {
    global LIST_TOP
    return SplitBottom() - LIST_TOP
}

; Where the divider sits at HELP_PANE_PCT, for the current window height.
; This is what a double-click on the bar snaps back to.
SplitDefault() {
    global HELP_PANE_PCT
    return SplitBottom() - Round(SplitAvail() * HELP_PANE_PCT / 100)
}

; Suspends or resumes painting for one window. WM_SETREDRAW does NOT propagate
; to child controls, so each control that gets resized has to be bracketed
; individually or it repaints itself mid-move.
SetRedraw(hwnd, on) {
    static WM_SETREDRAW := 0x000B
    DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", WM_SETREDRAW,
            "Ptr", on ? 1 : 0, "Ptr", 0)
}

; Widens the Value column so the ListView never shows dead space to the right
; of it. Deliberately done with LVM_* messages in PHYSICAL pixels rather than
; ModifyCol, which would drag the layout-unit-versus-pixel question into it.
; Column 1 is read rather than set, so a width you have dragged is preserved.
StretchValueColumn() {
    global lvSettings
    static LVM_GETCOLUMNWIDTH := 0x101D, LVM_SETCOLUMNWIDTH := 0x101E
    static LVSCW_AUTOSIZE_USEHEADER := -2

    ; On the LAST column of a report-mode ListView, LVSCW_AUTOSIZE_USEHEADER is
    ; documented to mean "fill whatever client width is left over". Letting
    ; Windows do the arithmetic is the whole point here: measuring the client
    ; rect ourselves and subtracting column 1 gets the vertical scrollbar wrong.
    ; GetClientRect only stops counting those 17-odd pixels once Windows has
    ; actually drawn the scrollbar, and during a resize it hasn't yet -- so the
    ; columns come out a hair too wide and the ListView grows a horizontal
    ; scrollbar it doesn't need.
    DllCall("user32\SendMessageW", "Ptr", lvSettings.Hwnd,
            "UInt", LVM_SETCOLUMNWIDTH, "Ptr", 1, "Ptr", LVSCW_AUTOSIZE_USEHEADER)

    ; That sizes to the header text if the header is wider than the space left,
    ; which on a very narrow window would be worse than nothing. Floor it.
    got := DllCall("user32\SendMessageW", "Ptr", lvSettings.Hwnd,
                   "UInt", LVM_GETCOLUMNWIDTH, "Ptr", 1, "Ptr", 0)
    if (got < 60) {
        DllCall("user32\SendMessageW", "Ptr", lvSettings.Hwnd,
                "UInt", LVM_SETCOLUMNWIDTH, "Ptr", 1, "Ptr", 60)
    }
}

; Recomputes the layout after the window has been resized.
;
; The divider keeps its PROPORTION (splitPct) rather than the help pane keeping
; a fixed pixel height, so a taller window gives both regions more room. If you
; would rather the list absorb all of the growth and the help pane stay put,
; replace the splitY line below with:
;
;     splitY := ClampSplit(SplitBottom() - oldHelpHeight)
;
; ...keeping oldHelpHeight from before winH was updated.
GUI_Size(GuiObj, MinMax, W, H) {
    global winW, winH, splitY, splitPct, splitter, btnRow

    if (MinMax = -1)                  ; minimized: nothing worth laying out
        return
    ; The first Size event arrives from inside Show(). Everything exists by then,
    ; but bail out safely if that ever stops being true -- btnRow is the last
    ; thing CreateGUI builds, so a populated btnRow means the rest is there too.
    if (!IsObject(splitter) || btnRow.Length = 0)
        return

    ; The W and H parameters are NOT used, deliberately. AHK has already applied
    ; DPI scaling to them by the time they arrive, so on a 125% display they are
    ; layout units, not pixels -- dividing them by A_ScreenDPI/96 the way
    ; CursorClientY() does to a ScreenToClient result shrinks the layout a second
    ; time and leaves a fat dead band down the right and bottom of the window.
    ;
    ; GetClientRect has no such ambiguity: it always returns physical pixels, so
    ; the conversion to layout units is always exactly one division. Measuring
    ; here rather than trusting the parameters also means this keeps working if
    ; AHK ever changes what it passes.
    scale := A_ScreenDPI / 96
    rc := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", GuiObj.Hwnd, "Ptr", rc)
    winW := Round(NumGet(rc, 8, "Int") / scale)     ; right
    winH := Round(NumGet(rc, 12, "Int") / scale)    ; bottom

    splitY := ClampSplit(SplitBottom() - Round(SplitAvail() * splitPct / 100))
    LayoutMain(0, true)
}

LayoutMain(prevSplitY := 0, fullRedraw := false) {
    global mainGui, tvSections, lvSettings, splitter, helpLabel, helpPane
    global lblSections, lblSettings, searchBox, searchCount, btnClearSearch
    global statusText, btnRow
    global splitY, SPLIT_H, SPLIT_GAP, LIST_TOP, LABEL_H, MARGIN, TREE_W, COL_GAP
    global TOP_ROW_Y, SEARCH_H, winW, winH
    static RDW_INVALIDATE := 0x0001, RDW_ERASE := 0x0004
    static RDW_FRAME := 0x0400, RDW_ALLCHILDREN := 0x0080

    ; --- horizontal -----------------------------------------------------------
    rightX := MARGIN + TREE_W + COL_GAP        ; left edge of the ListView
    fullW  := winW - MARGIN * 2                ; width of the full-width controls
    lvW    := winW - rightX - MARGIN
    if (lvW < 120)
        lvW := 120

    ; Search box and its clear button hug the right edge.
    clearX  := winW - MARGIN - 26
    searchX := clearX - 4 - 200
    if (searchX < rightX + 60)                 ; very narrow window: let it shrink
        searchX := rightX + 60
    searchW := clearX - 4 - searchX
    if (searchW < 60)
        searchW := 60

    ; The match counter takes whatever is left between "Settings" and the box.
    countX := rightX + 105
    countW := searchX - 8 - countX
    if (countW < 20)
        countW := 20

    ; --- vertical -------------------------------------------------------------
    listH := splitY - LIST_TOP - 8
    if (listH < 10)
        listH := 10
    helpY := splitY + SPLIT_H + SPLIT_GAP
    helpH := SplitBottom() - (helpY + LABEL_H)
    if (helpH < 10)
        helpH := 10

    ; Freeze the form and every control whose size changes, move everything,
    ; then thaw. DllCall rather than SendMessage: AHK's SendMessage does window
    ; matching that can fail for a window that isn't shown yet.
    resized := [tvSections, lvSettings, helpPane, splitter, helpLabel,
                statusText, searchCount]
    SetRedraw(mainGui.Hwnd, false)
    for ctrl in resized
        SetRedraw(ctrl.Hwnd, false)

    lblSections.Move(MARGIN, 12, TREE_W)
    lblSettings.Move(rightX, 12, 100)
    searchCount.Move(countX, 12, countW)
    searchBox.Move(searchX, TOP_ROW_Y, searchW, SEARCH_H)
    btnClearSearch.Move(clearX, TOP_ROW_Y, 26, SEARCH_H)

    tvSections.Move(MARGIN, LIST_TOP, TREE_W, listH)
    lvSettings.Move(rightX, LIST_TOP, lvW, listH)
    splitter.Move(MARGIN, splitY, fullW)
    helpLabel.Move(MARGIN, helpY, fullW)
    helpPane.Move(MARGIN, helpY + LABEL_H, fullW, helpH)
    statusText.Move(MARGIN, StatusY(), fullW)

    btnY := ButtonRowY()
    for b in btnRow
        b.ctrl.Move(b.x, btnY, b.w)

    for ctrl in resized
        SetRedraw(ctrl.Hwnd, true)
    SetRedraw(mainGui.Hwnd, true)

    ; The ListView now has its final width, so the Value column can take up the
    ; slack. Has to happen after the thaw or the header doesn't repaint.
    StretchValueColumn()

    ; Repaint each resized control in full, frame included. RDW_FRAME is the
    ; important one: scrollbars live in the non-client area, so without it the
    ; ListView's horizontal scrollbar stays painted at every position it passed
    ; through during the drag.
    for ctrl in resized
        DllCall("RedrawWindow", "Ptr", ctrl.Hwnd, "Ptr", 0, "Ptr", 0,
                "UInt", RDW_INVALIDATE | RDW_ERASE | RDW_FRAME)

    ; Now the form background behind them. RDW_ERASE is required here or the old
    ; client-edge borders of the TreeView/ListView and the previous positions of
    ; the divider stay on screen as ghost lines.
    ;
    ; Dragging the divider only dirties a narrow band, and erasing the whole
    ; window on every tick of a drag would flicker -- so that case restricts the
    ; dirty rect to the rows that actually changed, from the higher of the old
    ; and new divider positions down to the bottom of the help pane. A window
    ; resize moves everything, so it passes fullRedraw and repaints the lot.
    ; No RDW_ALLCHILDREN in the drag case: the children were handled explicitly
    ; just above.
    ;
    ; GetClientRect gives left/right in PHYSICAL pixels, so the top/bottom we
    ; substitute have to be scaled from layout units the same way.
    rc := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", mainGui.Hwnd, "Ptr", rc)
    if (!fullRedraw) {
        scale := A_ScreenDPI / 96
        dirtyTop := (prevSplitY ? Min(prevSplitY, splitY) : LIST_TOP) - 12
        NumPut("Int", Round(dirtyTop * scale), rc, 4)
        NumPut("Int", Round((SplitBottom() + 4) * scale), rc, 12)
    }

    DllCall("RedrawWindow", "Ptr", mainGui.Hwnd, "Ptr", rc, "Ptr", 0,
            "UInt", RDW_INVALIDATE | RDW_ERASE | (fullRedraw ? RDW_ALLCHILDREN : 0))
}

; Constrains a proposed divider position to the MIN_LIST / MIN_HELP limits.
ClampSplit(y) {
    global SPLIT_H, SPLIT_GAP, LIST_TOP, MIN_LIST, MIN_HELP, LABEL_H
    
    minY := LIST_TOP + MIN_LIST
    maxY := SplitBottom() - MIN_HELP - LABEL_H - SPLIT_GAP - SPLIT_H
    if (maxY < minY)          ; Window too short for both minimums; favor the list
        maxY := minY
    return Round(Max(minY, Min(maxY, y)))
}

; Moves the divider, relayouting only if the position actually changed.
;
; A move the user made (dragging the bar, or double-clicking it to snap back)
; also records the new proportion in splitPct, which is what a later window
; resize restores the split from. Pass remember := false for a move that should
; not become the new remembered proportion.
SetSplit(newY, remember := true) {
    global splitY, splitPct
    
    newY := ClampSplit(newY)
    if (newY != splitY) {
        prevY := splitY
        splitY := newY
        avail := SplitAvail()
        if (remember && avail > 0)
            splitPct := Round((SplitBottom() - splitY) / avail * 100)
        LayoutMain(prevY)     ; Pass the old position so the repaint band covers it
    }
}

; Cursor Y relative to the Gui's client area, converted to Gui layout units.
; ScreenToClient returns physical pixels; AHK's Move()/Add() coordinates are
; scaled by A_ScreenDPI/96 (the Gui does not use -DPIScale), so the two have to
; be reconciled or the divider drifts away from the cursor on a high-DPI screen.
CursorClientY() {
    global mainGui
    pt := Buffer(8, 0)
    DllCall("GetCursorPos", "Ptr", pt)
    DllCall("ScreenToClient", "Ptr", mainGui.Hwnd, "Ptr", pt)
    return NumGet(pt, 4, "Int") * 96 / A_ScreenDPI
}

; True when the cursor is over the divider bar (plus a small grab margin).
OverSplitter() {
    global splitY, SPLIT_H, SPLIT_GRAB
    y := CursorClientY()
    return (y >= splitY - SPLIT_GRAB && y <= splitY + SPLIT_H + SPLIT_GRAB)
}

Splitter_LButtonDown(wParam, lParam, msg, hwnd) {
    global mainGui, splitY
    static lastClick := 0
    
    ; The divider is a plain Static with no SS_NOTIFY, so it is hit-transparent
    ; and the click arrives at the parent window. Ignore clicks anywhere else.
    if (hwnd != mainGui.Hwnd || !OverSplitter())
        return
    
    ; Second click inside the system double-click interval snaps back to default.
    ; Detected by hand rather than via WM_LBUTTONDBLCLK so it does not depend on
    ; the Gui window class carrying CS_DBLCLKS.
    dblTime := DllCall("GetDoubleClickTime", "UInt")
    if (A_TickCount - lastClick < dblTime) {
        lastClick := 0
        SetSplit(SplitDefault())
        return 0
    }
    lastClick := A_TickCount
    
    grabOffset := CursorClientY() - splitY
    DllCall("SetCapture", "Ptr", mainGui.Hwnd)
    while GetKeyState("LButton", "P") {
        SetSplit(CursorClientY() - grabOffset)
        Sleep(10)
    }
    DllCall("ReleaseCapture")
    return 0
}

Splitter_SetCursor(wParam, lParam, msg, hwnd) {
    global mainGui
    if (hwnd != mainGui.Hwnd || !OverSplitter())
        return
    static IDC_SIZENS := 32645
    DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", IDC_SIZENS, "Ptr"))
    return 1   ; Halt further processing so the class cursor doesn't override
}

Tree_ItemSelect(GuiCtrlObj, Item) {
    global lvSettings, currentSection, sectionMap, helpPane, helpLabel, keyOrder, allSettings
    
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
        ; Iterate through keys in the order they appear in the INI file,
        ; skipping any that the search box is currently filtering out.
        ; MatchesSearch() returns true for everything when the box is empty, so
        ; this is a no-op in the unfiltered case.
        if keyOrder.Has(currentSection) {
            for key in keyOrder[currentSection] {
                if !MatchesSearch(currentSection, key)
                    continue
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

; Scan a metadata JSON for the line that OPENS the given entry, i.e.
;     "Section.Key": {
; Returns the 1-based line number, or 0 if not found.
;
; The file is re-read on every call rather than line numbers being cached at
; load time, because the whole point of the button is to go and edit the file —
; so by the second click the cached numbers would be stale.
;
; The match is anchored to the start of the trimmed line, which is what keeps a
; key NAME appearing inside some other entry's help text from stealing the
; jump: a help line always begins with "help", never with the key. JSON string
; values can't contain a raw newline (they use \n), so every line is
; self-contained and a line-at-a-time scan is safe here.
FindKeyLineInJson(filePath, fullKey) {
    if !FileExist(filePath)
        return 0

    try {
        content := FileRead(filePath)
    } catch {
        return 0
    }

    needle := '"' fullKey '": {'

    lineNum := 0
    loop parse content, "`n", "`r" {
        lineNum++
        if (SubStr(Trim(A_LoopField), 1, StrLen(needle)) = needle)
            return lineNum
    }

    return 0
}

Btn_GoTo(GuiCtrlObj := "", Info := "") {
    global lvSettings, currentSection, metadataPath, EditorCmd
    
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
    
    ; Locate the entry. A miss is not an error worth blocking on -- the key may
    ; genuinely have no metadata yet (see the Manage Missing Keys dialog), so
    ; the file still opens, just at the top.
    lineNum := FindKeyLineInJson(metadataPath, fullKey)
    notice := (lineNum > 0)
        ? fullKey "  (line " lineNum ")"
        : fullKey " has no entry yet - opening at top of file"
    if (lineNum = 0)
        lineNum := 1
    
    ; Build the command. Editors without a goto-line switch simply have no
    ; {line} in their template, so the substitution is a harmless no-op there.
    cmd := StrReplace(EditorCmd, "{file}", metadataPath)
    cmd := StrReplace(cmd, "{line}", lineNum)
    
    try {
        Run(cmd)
        ToolTip(notice)
        SetTimer(() => ToolTip(), 3000)
    } catch as err {
        ; The configured editor could not be launched -- most likely a stale
        ; path in EditorCmd, or the `code` PATH shim not being present. Rather
        ; than leaving the person with nothing, hand the file to whatever is
        ; associated with .json and report the line so they can jump manually.
        try {
            Run(metadataPath)
            ToolTip("Could not run EditorCmd - opened with the default app.`n"
                . fullKey " is on line " lineNum)
            SetTimer(() => ToolTip(), 5000)
        } catch {
            ToolTip("Could not open the metadata file.`n" err.Message)
            SetTimer(() => ToolTip(), 5000)
        }
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
        case "float":
            EditFloat(currentSection, key, originalValue)
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
        isDirty := false
        
        ; RebuildTree() handles the tree, the sectionMap, the ListView and the
        ; search filter in one go, and keeps you on the same section when it
        ; still exists after the reload.
        RebuildTree()
        UpdateSearchStatus()
        
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

; Fill in EditorCmd if it was left blank (auto-detects VS Code)
ResolveEditorCmd()

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

; ============================================================================
; HOTKEYS
; ============================================================================
; Both are scoped to this script's own window, so they do nothing while any
; other application is in front, and nothing while one of the edit dialogs is
; up (those are separate Gui windows with their own HWNDs).
;
; Escape is taken here rather than through the Gui's Escape event so it never
; reaches the window's default handling. There is no tray command to bring the
; window back once it is hidden, so "Esc hides the GUI" would be a dead end.
;
; The IsObject() guard matters: mainGui is still an empty string until
; CreateGUI() runs, and && short-circuits before .Hwnd would be touched.
#HotIf IsObject(mainGui) && WinActive("ahk_id " mainGui.Hwnd)
Escape::ClearSearch()
^f::FocusSearch()
#HotIf
