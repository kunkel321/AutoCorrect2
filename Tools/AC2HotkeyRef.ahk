#SingleInstance Force
#Requires AutoHotkey v2.0

; ==============================================================================
; Title:      AC2HotkeyRef - AutoCorrect2 Hotkey Reference
; Author:     Kunkel321
; Tool Used:  Claude AI
; Version:    2025-03-31
; Location:   AutoCorrect2\Tools\AC2HotkeyRef.ahk
; Purpose:    Cheatsheet ListView of all hotkeys defined across the
;             AutoCorrect2 suite.  Sources:
;               1. Running AHK scripts in the AutoCorrect2 folder tree
;                  (scanned for hotkey lines + #HotIf context)
;               2. [Hotkeys] section of acSettings.ini
;                  (labels and source script sourced from acSettingsMetadata.json)
;             Columns: Hotkey | Action | Context (#HotIf) | Source
;             - Context column shows the WinActive() condition for hotkeys
;               wrapped in #HotIf directives.  Only the first WinActive()
;               argument is shown on multi-condition lines.
;               Config.Var names have "Config." stripped for readability.
;             - Source column shows the .ahk filename the hotkey lives in.
;               For INI hotkeys, derived from the metadata "restart" field or
;               by stripping the trailing "Hk"/"Hotkey" from the key name.
;             - "Show Hidden" checkbox reveals hotkeys tagged with "; hide"
;               (hidden by default for original HotKeyTool compatibility).
;             - GUI is resizable; columns redistribute proportionally.
;             - Double-click or Enter sends the selected hotkey.
;               Note: context-specific hotkeys only work in their target window.
;             - Tip: Press Tab to jump to list, then use down arrow to navigate.
;             - Activation hotkey read from acSettings.ini:
;               Hotkeys.AC2HotkeyRefHotkey (default: !+k)
; ==============================================================================

TraySetIcon("C:\Windows\System32\imageres.dll", 95) ; In Win 10 it's a blue circle with a '?'.

; ---------- Path resolution --------------------------------------------------
; This script lives in AutoCorrect2\Tools\, so the AC2 root is one level up.
; Use string trimming rather than ".." which AHK does not normalize.
ac2Root   := SubStr(A_ScriptDir, 1, InStr(A_ScriptDir, "\",, -1) - 1)
dataDir   := ac2Root "\Data"
iniPath   := dataDir "\acSettings.ini"
jsonPath  := dataDir "\acSettingsMetadata.json"

; Colour theme (optional) - same pattern as HotKeyTool
themeFile := dataDir "\colorThemeSettings.ini"
If FileExist(themeFile) {
    fontColor := IniRead(themeFile, "ColorSettings", "fontColor", "31FFE7")
    listColor := IniRead(themeFile, "ColorSettings", "listColor", "003E67")
    formColor := IniRead(themeFile, "ColorSettings", "formColor", "00233A")
} Else {
    formColor := "00233A", listColor := "003E67", fontColor := "31FFE7"
}
; Ensure exactly one leading 'c' followed by exactly 6 hex digits.
; SubStr(x, -5) grabs the last 6 chars, safely stripping any 0x/c/# prefix.
fontColor := "c" SubStr(fontColor, -5)

; ---------- User options -----------------------------------------------------
guiTitle    := "AC2 Hotkey Reference"
guiWidth    := 720      ; wider than HH default - this is a reference tool
guiHeight   := 400      ; starting height
maxRows     := 26       ; Used for height of listview
fontSize    := 12       ; 8-12 recommended
trans       := 255      ; Max (255) is fully opaque
StickyFilter := 0       ; Clear filter box on each show

; ---------- Read activation hotkey from INI ----------------------------------
; Default !+k  (Alt+Shift+K).  Add  Hotkeys.AC2HotkeyRefHotkey=!+k  to INI.
mainHotkey := "!+k"
If FileExist(iniPath)
    mainHotkey := IniRead(iniPath, "Hotkeys", "AC2HotkeyRefHotkey", "!+k")

; ---------- Scripts to skip when scanning ------------------------------------
ignoreList := ["HotstringLib"
             , "PersonalHotstrings"
             , "AC2HotkeyRef.ahk"
             , "acMsgBox.ahk"
             , "ColorThemeInt.ahk"]

; ==============================================================================
; FUNCTION: GetScriptNames
; Find all running AHK processes whose exe path starts with ac2Root,
; then chase any #Include'd .ahk files.
; ==============================================================================
GetScriptNames(ac2Root, ignoreList) {
    processlist := ComObject("WbemScripting.SWbemLocator")
                   .ConnectServer().ExecQuery(
                   "Select Name, ExecutablePath from Win32_Process")

    scriptNames := []
    for process in processlist {
        ; Case-insensitive compare (WMI paths may differ in case from A_ScriptDir)
        if (process.ExecutablePath
        && InStr(process.ExecutablePath, ac2Root, 0) == 1) {
            scriptNames.Push(StrReplace(process.ExecutablePath, ".exe", ".ahk"))
        }
    }

    ; Chase #Include lines
    for item in scriptNames {
        try loop read item {
            if SubStr(A_LoopReadLine, 1, 9) = "#Include " {
                if RegExMatch(A_LoopReadLine,
                              '#Include\s+"([^"]+\.ahk)"', &m) {
                    SplitPath item,, &dir
                    incFile := StrReplace(m[1], "*i ", "")
                    scriptNames.Push(dir "\" incFile)
                }
            }
        }
    }

    ; Filter ignore list
    filtered := []
    for sname in scriptNames {
        ok := true
        for ig in ignoreList {
            if InStr(sname, ig) {
                ok := false
                break
            }
        }
        if ok
            filtered.Push(sname)
    }
    return filtered
}

; ==============================================================================
; FUNCTION: GetHotkeys
; Parse .ahk files for hotkey lines.  Track #HotIf context.
; Returns array of pipe-delimited strings:
;   hotkey | action | context | source
; ==============================================================================
GetHotkeys(scriptNames) {
    hotkeys := []
    for item in scriptNames {
        SplitPath item, &fname
        currentHotIf := ""
        try loop read item {
            line := Trim(A_LoopReadLine)

            ; Track #HotIf context FIRST (before any 'continue' skips).
            ; Grabs the first WinActive() argument on the line.
            if RegExMatch(line, "i)^#HotIf\b") {
                if RegExMatch(line, "i)WinActive\((?:`"([^`"]+)`"|'([^']+)'|([\w.]+))\s*\)", &hm) {
                    ctx := (hm[1] != "") ? hm[1] : (hm[2] != "") ? hm[2] : hm[3]
                    ctx := RegExReplace(ctx, "^Config\.", "")  ; Config.HHWindowTitle -> HHWindowTitle
                    currentHotIf := Trim(ctx)
                } else
                    currentHotIf := ""  ; bare #HotIf or non-WinActive condition
            }

            ; Hotkey line detection (same rules as HotKeyTool, but we keep
            ; "; hide" items flagged rather than discarding them entirely).
            if !InStr(line, "::")
                continue
            colonCount := StrLen(line) - StrLen(StrReplace(line, ":"))
            if (colonCount != 2)
                continue
            if InStr(line, "'") || InStr(line, '"')
                continue

            ; Flag lines marked ; hide  (shown only when checkbox is checked)
            isHidden := InStr(line, "hide") ? "1" : "0"

            ; Split on ::  ->  left=hotkey definition, right=comment/action
            parts   := StrSplit(line, "::")
            hkRaw   := Trim(parts[1])
            comment := Trim(parts[2])

            ; Extract inline comment (after  ;  on the right side)
            action := ""
            if InStr(comment, ";") {
                action := Trim(SubStr(comment, InStr(comment, ";") + 1))
                ; Strip the word "hide" from the displayed action text
                action := Trim(RegExReplace(action, "\bhide\b", ""))
            }
            ; If no comment, use the raw right side (may be blank)
            if (action = "")
                action := comment

            hotkeys.Push(hkRaw "|" action "|" currentHotIf "|" fname "|" isHidden)
        }
    }
    return hotkeys
}

; ==============================================================================
; FUNCTION: LoadJsonMetadata
; Hand-rolled JSON key extractor - reuses the same approach as SettingsManager.
; Returns a Map of  "Section.Key" => {label, help, restart}
; ==============================================================================
LoadJsonMetadata(jsonPath) {
    meta := Map()
    if !FileExist(jsonPath)
        return meta

    raw := FileRead(jsonPath)

    ; Walk through top-level keys
    pos := 1
    while RegExMatch(raw, '"([\w.]+)"\s*:\s*\{', &km, pos) {
        entryKey := km[1]
        blockStart := km.Pos + km.Len
        ; Find matching closing brace (simple depth counter)
        depth := 1
        i := blockStart
        while (i <= StrLen(raw) && depth > 0) {
            ch := SubStr(raw, i, 1)
            if (ch = "{")
                depth++
            else if (ch = "}")
                depth--
            i++
        }
        block := SubStr(raw, blockStart, i - blockStart - 1)

        label   := ""
        help    := ""
        restart := ""

        if RegExMatch(block, '"label"\s*:\s*"((?:[^"\\]|\\.)*)"', &lm)
            label := lm[1]
        if RegExMatch(block, '"help"\s*:\s*"((?:[^"\\]|\\.)*)"', &hm2)
            help := RegExReplace(hm2[1], "\\n", "`n")
        if RegExMatch(block, '"restart"\s*:\s*"((?:[^"\\]|\\.)*)"', &rm)
            restart := rm[1]

        meta[entryKey] := Map("label", label, "help", help, "restart", restart)
        pos := km.Pos + 1
    }
    return meta
}

; ==============================================================================
; FUNCTION: GetIniHotkeys
; Read [Hotkeys] section from INI, look up labels/restart in metadata JSON.
; Returns same pipe-delimited format as GetHotkeys():
;   hotkey | action | context | source
; ==============================================================================
GetIniHotkeys(iniPath, jsonPath) {
    result := []
    if !FileExist(iniPath)
        return result

    meta := LoadJsonMetadata(jsonPath)

    ; Read entire [Hotkeys] section as "key=value\nkey=value..."
    try {
        section := IniRead(iniPath, "Hotkeys")
    } catch {
        return result
    }

    for pair in StrSplit(section, "`n") {
        pair := Trim(pair)
        if (pair = "" || SubStr(pair, 1, 1) = ";")
            continue
        eqPos := InStr(pair, "=")
        if !eqPos
            continue
        keyName := Trim(SubStr(pair, 1, eqPos - 1))
        hkValue := Trim(SubStr(pair, eqPos + 1))

        ; Skip our own tool's hotkey - it's meta, not useful in the list
        if (keyName = "AC2HotkeyRefHotkey")
            continue

        metaKey := "Hotkeys." keyName

        ; --- Label (Action column) ---
        label := ""
        if meta.Has(metaKey)
            label := meta[metaKey]["label"]
        if (label = "")
            label := keyName   ; fallback

        ; --- Source ---
        ; Explicit overrides for keys with no 'restart' field in metadata.
        ; Key = INI key name, Value = source .ahk filename.
        sourceOverrides := Map(
            "ACLogAnalyzerHk", "AutoCorrect2.ahk"
        )

        ; Priority 1: explicit override
        source := ""
        if sourceOverrides.Has(keyName)
            source := sourceOverrides[keyName]

        ; Priority 2: restart field  e.g. "..\\Core\\MCLogger.exe" -> "MCLogger.ahk"
        if (source = "" && meta.Has(metaKey)) {
            restartVal := meta[metaKey]["restart"]
            if (restartVal != "") {
                SplitPath restartVal, &rBase
                source := StrReplace(rBase, ".exe", ".ahk")
            }
        }
        ; Priority 3: strip trailing Hk / Hotkey from key name
        if (source = "") {
            source := RegExReplace(keyName, "(?i)(Hotkey|Hk)$", "")
            source := source ".ahk"
        }

        result.Push(hkValue "|" label "||" source)   ; context always blank
    }
    return result
}

; ==============================================================================
; FUNCTION: GetUniqueHotIfContexts
; Pull all non-blank Context values from hotkey array for filter list.
; ==============================================================================
GetUniqueHotIfContexts(hotkeys) {
    seen := Map()
    out  := []
    for item in hotkeys {
        parts := StrSplit(item, "|")
        ctx   := (parts.Length >= 3) ? parts[3] : ""
        if (ctx != "" && !seen.Has(ctx)) {
            seen[ctx] := 1
            out.Push(ctx)
        }
    }
    return out
}

; ==============================================================================
; FUNCTION: GetScriptBasenames
; Pull unique source (col 4) values for the filter combobox.
; ==============================================================================
GetScriptBasenames(hotkeys) {
    seen := Map()
    out  := []
    for item in hotkeys {
        parts := StrSplit(item, "|")
        src   := (parts.Length >= 4) ? parts[4] : ""
        if (src != "" && !seen.Has(src)) {
            seen[src] := 1
            out.Push(src)
        }
    }
    return out
}

; ==============================================================================
; BUILD DATA
; ==============================================================================
scriptNames := GetScriptNames(ac2Root, ignoreList)
hotkeys     := GetHotkeys(scriptNames)
iniHotkeys  := GetIniHotkeys(iniPath, jsonPath)
hotkeys.Push(iniHotkeys*)   ; merge INI hotkeys in

; Build combobox filter list:
;   blank | script names | #HotIf window names | modifier-symbol filters
hotIfContexts  := GetUniqueHotIfContexts(hotkeys)
scriptBasenames := GetScriptBasenames(hotkeys)
modFilters      := ["#", "^", "!", "+", "^!", "^+", "!+"]

filterList := [""]
for s in scriptBasenames
    filterList.Push(s)
for c in hotIfContexts
    filterList.Push(c)
for m in modFilters
    filterList.Push(m)

; ==============================================================================
; GUI
; ==============================================================================
GuiReady := 0
myRef    := CreateGui()

SoundBeep 900, 200
SoundBeep 1100, 200

Hotkey mainHotkey, ShowRefWrapper

ShowRefWrapper(*) {
    ShowRef()
}

; ---------- Create GUI -------------------------------------------------------
CreateGui() {
    global myRef, GuiReady, showHidden

    showHidden := 0   ; default: hide the ; hide items

    g := Gui(, guiTitle)
    g.SetFont("s" fontSize " " fontColor)
    g.BackColor := formColor
    WinSetTransparent(trans, g)
    g.Opt("+Resize +MinSize" guiWidth "x200")   ; resizable, min width = default width

    colW1 := 65    ; Hotkey  (narrower)
    colW2 := 280   ; Action
    colW3 := 175   ; Context (#HotIf)
    colW4 := guiWidth - colW1 - colW2 - colW3 - 4   ; Source

    g.Add("Text", "+wrap w" guiWidth,
        "Type in Filter box to Filter list.  Enter or Double-Click to send hotkey.  Note: Context-specific hotkeys "
        . "(see Context column) only work in their target window and others are "
        . "irrelevant when sent from this Hotkey Reference application.")

    ; Filter combobox + "Show Hidden" checkbox on the same row
    cbxW := 120   ; width reserved for checkbox
    g.hkFilter := g.Add("ComboBox",
        "w" (guiWidth - cbxW - 20) " Background" listColor, filterList)
    g.chkHidden := g.Add("CheckBox",
        "x+20 yp+2 w" cbxW " c" fontColor " Background" formColor,
        "Show Hidden")

    g.SetFont("s" fontSize - 1)
    g.StatBar := g.Add("StatusBar",,)
    g.SetFont("s" fontSize " " fontColor)

    rows := (hotkeys.Length <= maxRows) ? hotkeys.Length : maxRows
    g.hkList := g.Add("ListView",
        "xm w" guiWidth " h" rows * 20 " Background" listColor,
        ["Hotkey", "Action", "Context (#HotIf)", "Source"])
    g.hkList.ModifyCol(1, colW1)
    g.hkList.ModifyCol(2, colW2)
    g.hkList.ModifyCol(3, colW3)
    g.hkList.ModifyCol(4, colW4)

    UpdateList(g.hkList, hotkeys, g.StatBar, g.hkFilter.Text, showHidden)

    g.hkFilter.OnEvent("Change",
        (*) => UpdateList(g.hkList, hotkeys, g.StatBar, g.hkFilter.Text, showHidden))
    g.chkHidden.OnEvent("Click", (*) => OnHiddenToggle(g))
    g.hkList.OnEvent("DoubleClick",
        (*) => RunHotkey(g.hkList, g))
    g.OnEvent("Escape", (*) => g.Hide())
    g.OnEvent("Size", (*) => OnGuiSize(g))

    GuiReady := 1
    return g
}

; ---------- Checkbox toggle --------------------------------------------------
OnHiddenToggle(g) {
    global showHidden
    showHidden := g.chkHidden.Value
    UpdateList(g.hkList, hotkeys, g.StatBar, g.hkFilter.Text, showHidden)
}

; ---------- Resize handler ---------------------------------------------------
OnGuiSize(g) {
    ; Get new client area dimensions
    g.GetClientPos(,, &cw, &ch)
    innerW := cw - 28   ; match the +28 margin used in Show()

    cbxW := 120
    ; Reposition/resize filter combobox and checkbox
    g.hkFilter.Move(,, innerW - cbxW - 20)
    g.chkHidden.Move(innerW - cbxW + 8,)

    ; Reserve space for: label (~22px) + filter (~26px) + gaps (~20px) + statusbar (~24px) + padding
    reserved := 100
    listH := ch - reserved
    if (listH < 60)
        listH := 60
    g.hkList.Move(, , innerW, listH)

    ; Redistribute column widths proportionally
    colW1 := 65
    colW2 := Round((innerW - colW1) * 0.44)
    colW3 := Round((innerW - colW1) * 0.30)
    colW4 := innerW - colW1 - colW2 - colW3 - 4
    g.hkList.ModifyCol(1, colW1)
    g.hkList.ModifyCol(2, colW2)
    g.hkList.ModifyCol(3, colW3)
    g.hkList.ModifyCol(4, colW4)
}

; ---------- Show / toggle GUI ------------------------------------------------
ShowRef() {
    global showHidden
    if WinActive(guiTitle) {
        myRef.Hide()
        return
    }
    if !StickyFilter {
        myRef.hkFilter.Text := ""
        UpdateList(myRef.hkList, hotkeys, myRef.StatBar, "", showHidden)
    }
    myRef.Show("w" guiWidth + 28 " h" guiHeight)
    myRef.hkFilter.Focus()
}

; ---------- Populate / filter ListView ---------------------------------------
UpdateList(hkList, hotkeys, StatBar, filter, showHidden := 0) {
    hkList.Delete()
    count := 0
    total := 0
    for item in hotkeys {
        parts    := StrSplit(item, "|")
        isHidden := (parts.Length >= 5) ? parts[5] : "0"
        if (!showHidden && isHidden = "1")
            continue
        total++
        if (filter = "" || InStr(item, filter, 0)) {
            hk     := (parts.Length >= 1) ? parts[1] : ""
            action := (parts.Length >= 2) ? parts[2] : ""
            ctx    := (parts.Length >= 3) ? parts[3] : ""
            src    := (parts.Length >= 4) ? parts[4] : ""
            hkList.Add("", hk, action, ctx, src)
            count++
        }
    }
    if (count > 0)
        hkList.Modify(1, "Select Focus")
    StatBar.SetText("  Showing " count " of " total " hotkeys."
        . (showHidden ? "  (including hidden)" : ""))
}

; ---------- Enter key sends hotkey -------------------------------------------
~Enter:: {
    global GuiReady, showHidden
    try if GuiReady = 1
        if (myRef.FocusedCtrl == myRef.hkFilter)
        || (myRef.FocusedCtrl == myRef.hkList)
            RunHotkey(myRef.hkList, myRef)
}

; ---------- Send hotkey to previously active window --------------------------
RunHotkey(hkList, g) {
    g.Hide()
    selectedRow := hkList.GetNext(0, "F")
    if (selectedRow <= 0)
        return
    thisKey := hkList.GetText(selectedRow, 1)
    ; Wrap word-like key names in braces e.g. Space -> {Space}
    if RegExMatch(thisKey, "i).*?[a-z]{2,}")
        thisKey := RegExReplace(thisKey, "i)(.*?)([a-z]{2,})", "$1{$2}")
    SendInput thisKey
}
