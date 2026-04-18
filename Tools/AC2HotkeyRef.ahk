#SingleInstance Force
#Requires AutoHotkey v2.0

/*******************************************************************************
Title:      AutoCorrect2 Hotkey Reference
Author:     Kunkel321
Tool Used:  Claude AI
Version:    4-18-2026

Purpose:    Cheatsheet ListView of all hotkeys defined across the
AutoCorrect2 suite.  Sources:
    1. Running AHK scripts in the AutoCorrect2 folder tree
        (scanned for hotkey lines + #HotIf context)
    2. [Hotkeys] section of acSettings.ini
        (labels and source script sourced from acSettingsMetadata.json)

Scanning note:
    Scripts are only detected if they are currently running AND set up in
    "portable" style -- i.e. a renamed AutoHotkey.exe paired with a same-named
    .ahk file in the same folder.  This is the standard AC2 suite layout.
    If you want non-AC2 scripts to appear under "Scan All", they must also
    follow this portable pattern.  See the AHK docs for details:
    https://www.autohotkey.com/docs/v2/Program.htm#portability
    It is okay if the .exe is a compiled version of your script, but the 
    same-named .ahk file must be in the folder with it. 

Columns: Hotkey | Action | Context (#HotIf) | Source
* Hotkey column shows Friendly names "Ctrl+Alt+D" or raw AHK symbols "^!d".
* Action column shows any code or comments on the same line as the hotkey.
* Context column shows the WinActive() condition for hotkeys wrapped in
    #HotIf directives OR runtime HotIfWinActive calls.  If an inline comment
    is found on the #HotIf / HotIfWinActive line, that is used as the label;
    otherwise the WinActive() / HotIfWinActive argument is shown.
    A bare "#HotIf" or HotIfWinActive "" (context reset) correctly clears
    context for subsequent hotkeys, even when it has a trailing comment.
    Only the first WinActive() argument is shown on multi-condition lines.
    Config.Var names have "Config." stripped for readability.
* Source column shows the .ahk filename the hotkey lives in.
    For INI-defined hotkeys, the source is derived from the metadata
    "restart" field or by stripping the trailing "Hk"/"Hotkey" from the
    key name.  When such a row is selected, the statusbar shows:
    "Showing X of Y hotkeys.  --  Hotkey defined in acSettings.ini"
* "Show Hidden" checkbox reveals hotkeys tagged with "; hide"
* "Scan All" checkbox rescans all running portable AHK scripts system-wide
    instead of only those inside the AutoCorrect2\ folder tree.
* "Refresh" button rescans running scripts using the current Scan All setting.
    Useful for picking up scripts that were started after this tool launched.
* "Export Cheatsheet" button generates an HTML table of the current filtered 
    view and opens it in the default browser (printable as PDF via Ctrl+P).
* GUI is resizable; ListView columns redistribute proportionally.
* Double-click or Enter sends the selected hotkey.  The tool closes, then
    waits up to 5 s for the previously active window to regain focus before
    sending the key — so you can look up a hotkey while working in Notepad
    and it will be delivered there automatically.  Context-specific hotkeys
    only work in their target window.
* This tool's activation hotkey is read from acSettings.ini:
    Hotkeys.AC2HotkeyRefHotkey (default: !+k)
* Tip: Press Tab to jump to the list, then use arrow keys to navigate,
    or type (or press down arrow) in the filter box to narrow results.
* Tip: See also User Options and IgnoreList, below.
* Note: If tool is called while another app is active, tool will attempt to 
    wait until previous window is open before sending hotkey.
*******************************************************************************/ 

; ---------- User options -----------------------------------------------------
guiTitle        := "AutoCorrect2 Hotkey Reference (Cheatsheet)"
guiWidth        := 820 ; wider than HH default - this is a reference tool
maxRows         := 26  ; Max number of rows in listVew
fontSize        := 12  ; 8-12 recommended
trans           := 255 ; 0 = transparent, 255 = opaque
filterWidth     := 280 ; Width of filter comboBox
StickyFilter    := 0   ; 0 = clear filter each time gui is shown
ScanAllRunning  := 0   ; 0 = AC2 folder only (default)  | 1 = all running AHK scripts
ShowOnStartup   := 1   ; 1 = show GUI immediately on launch  | 0 = wait for hotkey
FriendlyNames   := 1   ; 1 = show "Ctrl+Alt+D"  | 0 = show raw AHK symbols "^!d"

; ---------- Scripts to skip when scanning ------------------------------------
; Tip: Comment-out a line to temporarily allow scanning.
ignoreList := ["HotstringLib"
            ; , "PersonalHotstrings"
             , "AC2HotkeyRef.ahk"
             , "acMsgBox.ahk"
             , "ColorThemeInt.ahk"]

; ---------- Path resolution --------------------------------------------------
; This script lives in AutoCorrect2\Tools\, so the AC2 root is one level up.
; Use string trimming rather than ".." which AHK does not normalize.
ac2Root   := SubStr(A_ScriptDir, 1, InStr(A_ScriptDir, "\",, -1) - 1)
dataDir   := ac2Root "\Data"
iniPath   := dataDir "\acSettings.ini"
jsonPath  := dataDir "\acSettingsMetadata.json"

; ---------- Read activation hotkey from INI ----------------------------------
; Default !+k  (Alt+Shift+K).  Add  Hotkeys.AC2HotkeyRefHotkey=!+k  to INI.
mainHotkey := "!+k"
If FileExist(iniPath)
    mainHotkey := IniRead(iniPath, "Hotkeys", "AC2HotkeyRefHotkey", "!+k")

; WinSysTray icon assignment
TraySetIcon("C:\Windows\System32\imageres.dll", 95) ; In Win 10 it's a blue circle with a '?'.

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

; ==============================================================================
; FUNCTION: GetScriptNames
; Find all running AHK processes, optionally limited to ac2Root.
; Only includes a script if the matching .ahk file actually exists on disk
; (guards against compiled-only exes with no .ahk counterpart).
; Then chases any #Include'd .ahk files.
; ==============================================================================
GetScriptNames(ac2Root, ignoreList, scanAll := 0) {
    processlist := ComObject("WbemScripting.SWbemLocator")
                   .ConnectServer().ExecQuery(
                   "Select Name, ExecutablePath from Win32_Process")

    scriptNames := []
    for process in processlist {
        exePath := process.ExecutablePath
        if !exePath
            continue
        ; Scope check: AC2 folder only, or all running processes
        if (!scanAll && InStr(exePath, ac2Root, 0) != 1)
            continue
        ahkPath := StrReplace(exePath, ".exe", ".ahk")
        ; Skip compiled-only exes that have no matching .ahk file
        if !FileExist(ahkPath)
            continue
        scriptNames.Push(ahkPath)
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
; Parse .ahk files for hotkey lines.  Track #HotIf and HotIfWinActive context.
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
            ; A bare "#HotIf" (with or without a trailing comment) clears context.
            ; Otherwise, use the inline comment as label, or the WinActive() argument.
            if RegExMatch(line, "i)^#HotIf\b") {
                ; Bare #HotIf: nothing after it except optional whitespace/comment
                if RegExMatch(line, "i)^#HotIf\s*(;.*)?$")
                    currentHotIf := ""
                ; Has inline comment on a conditional line  e.g.  #HotIf WinActive(x) ; MyWindow
                else if RegExMatch(line, ";\s*(.+)$", &cm)
                    currentHotIf := Trim(cm[1])
                else if RegExMatch(line, "i)WinActive\((?:`"([^`"]+)`"|'([^']+)'|([\w.]+))\s*\)", &hm) {
                    ctx := (hm[1] != "") ? hm[1] : (hm[2] != "") ? hm[2] : hm[3]
                    currentHotIf := Trim(RegExReplace(ctx, "^Config\.", ""))
                } else
                    currentHotIf := ""  ; non-WinActive condition, treat as global
            }

            ; Track runtime HotIfWinActive context (used by class-based scripts).
            ; HotIfWinActive ""  or  HotIfWinActive  (bare) clears context.
            ; Inline comment is used as label; otherwise the argument string is shown.
            ;   e.g.  HotIfWinActive "ahk_id " this.Hwnd ; Hotstring Helper
            ;         -> currentHotIf := "Hotstring Helper"
            if RegExMatch(line, "i)^HotIfWinActive\b") {
                ; Bare call or empty-string argument -> clear context
                if RegExMatch(line, 'i)^HotIfWinActive\s*(`"`")?(\s*(;.*)?)?$')
                    currentHotIf := ""
                ; Inline comment present -> use it as the label
                else if RegExMatch(line, ";\s*(.+)$", &cm)
                    currentHotIf := Trim(cm[1])
                ; No comment -> grab the first quoted argument as the label
                else if RegExMatch(line, 'HotIfWinActive\s+`"([^`"]+)`"', &hm)
                    currentHotIf := Trim(hm[1])
                else
                    currentHotIf := ""  ; unrecognised form, treat as global
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
            ; Strip leading "; " from commented-out hotkey stubs, e.g.:
            ;   ; !+d:: Show DateTool      ->  hkRaw becomes "!+d"
            hkRaw   := LTrim(hkRaw, "; ")
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

            hotkeys.Push(hkRaw "|" action "|" currentHotIf "|" fname "|" isHidden "|0")
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

        result.Push(hkValue "|" label "||" source "||1")   ; context always blank; col6=isIni
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
; FUNCTION: FriendlyHotkey
; Convert AHK modifier symbols to human-readable names.
; e.g.  !+d  ->  Alt+Shift+D     ^F5  ->  Ctrl+F5     #e  ->  Win+E
; The raw AHK string is preserved in a hidden ListView column for SendInput.
; ==============================================================================
FriendlyHotkey(hkRaw) {
    ; Strip leading "; " from commented-out hotkey stubs
    s := LTrim(hkRaw, "; ")
    ; Get the key name by stripping all leading modifier symbols
    key := RegExReplace(s, "^[!+^#~*&$]+")
    return (InStr(s, "^") ? "Ctrl+"  : "")
         . (InStr(s, "!") ? "Alt+"   : "")
         . (InStr(s, "+") ? "Shift+" : "")
         . (InStr(s, "#") ? "Win+"   : "")
         . StrUpper(SubStr(key, 1, 1)) . SubStr(key, 2)
}

; ==============================================================================
; BUILD DATA
; ==============================================================================
scriptNames := GetScriptNames(ac2Root, ignoreList, ScanAllRunning)
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
GuiReady    := 0
prevWinHwnd := 0   ; HWND of window active before this tool was shown
myRef       := CreateGui()

SoundBeep 900, 200
SoundBeep 1100, 200

if ShowOnStartup
    ShowRef()

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

    colW1 := 150   ; Hotkey (friendly names need more room)
    colW2 := 280   ; Action
    colW3 := 175   ; Context (#HotIf)
    colW4 := guiWidth - colW1 - colW2 - colW3 - 4   ; Source

    g.Add("Text", "+wrap w" guiWidth,
        "Enter or Double-Click to send hotkey.  Note: Context-specific hotkeys "
        . "(see Context column) only work in their target window and others are "
        . "irrelevant when sent from this Hotkey Reference application.")

    ; Filter row: [ComboBox ~~~~~~~~~~~] [Show Hidden] [Scan All] [Refresh] [Export]
    ; Widths sized for fontSize 12; smaller fonts will have more ComboBox room.
    g.hkFilter   := g.Add("ComboBox", "w" filterWidth " Background" listColor, filterList)
    g.chkHidden  := g.Add("CheckBox", "x+8 yp+2 " fontColor " Background" formColor, "Show Hidden")
    g.chkScanAll := g.Add("CheckBox", "x+8 yp " fontColor " Background" formColor, "Scan All")
    g.chkScanAll.Value := ScanAllRunning
    g.btnRefresh := g.Add("Button", "x+8 yp-8", "Refresh")
    g.btnExport  := g.Add("Button", "x+8 yp",  "Export Cheatsheet")
    g.btnExport.OnEvent( "Click", (*) => ExportHtml(hotkeys, g.hkFilter.Text, showHidden))
    g.btnRefresh.OnEvent("Click", (*) => RescanHotkeys(g))

    g.SetFont("s" fontSize - 1)
    g.StatBar := g.Add("StatusBar",,)
    g.SetFont("s" fontSize " " fontColor)

    rows := (hotkeys.Length <= maxRows) ? hotkeys.Length : maxRows
    g.hkList := g.Add("ListView",
        "xm w" guiWidth " h" rows * 20 " Background" listColor,
        ["Hotkey", "Action", "Context (#HotIf)", "Source", "RawHK", "IsIni"])
    g.hkList.ModifyCol(1, colW1)
    g.hkList.ModifyCol(2, colW2)
    g.hkList.ModifyCol(3, colW3)
    g.hkList.ModifyCol(4, colW4)
    g.hkList.ModifyCol(5, 0)   ; hidden - raw AHK hotkey string
    g.hkList.ModifyCol(6, 0)   ; hidden - "1" if defined in acSettings.ini

    UpdateList(g.hkList, hotkeys, g.StatBar, g.hkFilter.Text, showHidden)

    g.hkFilter.OnEvent("Change",
        (*) => UpdateList(g.hkList, hotkeys, g.StatBar, g.hkFilter.Text, showHidden))
    g.chkHidden.OnEvent( "Click", (*) => OnHiddenToggle(g))
    g.chkScanAll.OnEvent("Click", (*) => RescanHotkeys(g))
    g.hkList.OnEvent("DoubleClick", (*) => RunHotkey(g.hkList, g))
    g.hkList.OnEvent("ItemSelect",
        (*) => OnItemSelect(g.hkList, g.StatBar, hotkeys, g.hkFilter.Text, showHidden))
    g.OnEvent("Escape", (*) => g.Hide())
    g.OnEvent("Size",   (*) => OnGuiSize(g))

    GuiReady := 1
    return g
}

; ---------- Rescan: rebuild hotkey list from currently running scripts -------
RescanHotkeys(g) {
    global hotkeys, ScanAllRunning, filterList, hotIfContexts, scriptBasenames, modFilters
    ScanAllRunning := g.chkScanAll.Value
    g.StatBar.SetText("  Scanning...")
    scriptNames := GetScriptNames(ac2Root, ignoreList, ScanAllRunning)
    hotkeys     := GetHotkeys(scriptNames)
    iniHotkeys  := GetIniHotkeys(iniPath, jsonPath)
    hotkeys.Push(iniHotkeys*)
    ; Rebuild filter combobox list
    hotIfContexts   := GetUniqueHotIfContexts(hotkeys)
    scriptBasenames := GetScriptBasenames(hotkeys)
    filterList := [""]
    for s in scriptBasenames
        filterList.Push(s)
    for c in hotIfContexts
        filterList.Push(c)
    for m in modFilters
        filterList.Push(m)
    g.hkFilter.Delete()
    g.hkFilter.Add(filterList)   ; Add() takes the whole array at once
    g.hkFilter.Text := ""
    UpdateList(g.hkList, hotkeys, g.StatBar, "", showHidden)
}

; ---------- Row selection: append INI hint to statusbar ----------------------
OnItemSelect(hkList, StatBar, hotkeys, filter, showHidden) {
    selectedRow := hkList.GetNext(0, "F")
    if (selectedRow <= 0)
        return
    count := 0
    total := 0
    for item in hotkeys {
        parts       := StrSplit(item, "|")
        isHiddenVal := (parts.Length >= 5) ? parts[5] : "0"
        if (!showHidden && isHiddenVal = "1")
            continue
        total++
        if (filter = "" || InStr(item, filter, 0))
            count++
    }
    statusText := "  Showing " count " of " total " hotkeys."
                . (showHidden ? "  (including hidden)" : "")
    if (hkList.GetText(selectedRow, 6) = "1")
        statusText .= "  --  Hotkey defined in acSettings.ini"
    StatBar.SetText(statusText)
}

; ---------- Checkbox toggle --------------------------------------------------
OnHiddenToggle(g) {
    global showHidden
    showHidden := g.chkHidden.Value
    UpdateList(g.hkList, hotkeys, g.StatBar, g.hkFilter.Text, showHidden)
}

; ---------- Resize handler ---------------------------------------------------
OnGuiSize(g) {
    g.GetClientPos(,, &cw, &ch)
    innerW := cw - 28   ; match the +28 margin used in Show()

    ; Only the ListView resizes - filter row controls are fixed width
    reserved := 120
    listH := ch - reserved
    if (listH < 60)
        listH := 60
    g.hkList.Move(,, innerW, listH)

    ; Redistribute visible column widths proportionally
    colW1 := 150
    colW2 := Round((innerW - colW1) * 0.44)
    colW3 := Round((innerW - colW1) * 0.30)
    colW4 := innerW - colW1 - colW2 - colW3 - 4
    g.hkList.ModifyCol(1, colW1)
    g.hkList.ModifyCol(2, colW2)
    g.hkList.ModifyCol(3, colW3)
    g.hkList.ModifyCol(4, colW4)
    g.hkList.ModifyCol(5, 0)   ; keep hidden
    g.hkList.ModifyCol(6, 0)   ; keep hidden
}

; ---------- Show / toggle GUI ------------------------------------------------
ShowRef() {
    global showHidden, prevWinHwnd
    if WinActive(guiTitle) {
        myRef.Hide()
        return
    }
    ; Remember which window was active so RunHotkey can return focus to it.
    prevWinHwnd := WinExist("A")
    if !StickyFilter {
        myRef.hkFilter.Text := ""
        UpdateList(myRef.hkList, hotkeys, myRef.StatBar, "", showHidden)
    }
    myRef.Show("w" guiWidth + 28)
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
            isIni  := (parts.Length >= 6) ? parts[6] : "0"
            hkList.Add("", FriendlyNames ? FriendlyHotkey(hk) : hk, action, ctx, src, hk, isIni)
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
    global prevWinHwnd
    g.Hide()
    selectedRow := hkList.GetNext(0, "F")
    if (selectedRow <= 0)
        return
    thisKey := hkList.GetText(selectedRow, 5)   ; col 5 = raw AHK string
    ; Wrap word-like key names in braces e.g. Space -> {Space}
    if RegExMatch(thisKey, "i).*?[a-z]{2,}")
        thisKey := RegExReplace(thisKey, "i)(.*?)([a-z]{2,})", "$1{$2}")
    ; Wait up to 5 s for the previous window to become active, then send.
    ; WinWaitActive returns the HWND on success, 0 on timeout (v2 style).
    if (prevWinHwnd && WinExist("ahk_id " prevWinHwnd)) {
        if WinWaitActive("ahk_id " prevWinHwnd,, 5)
            SendInput thisKey
    } else
        SendInput thisKey   ; fallback: no saved window, send immediately
}

; ---------- Export visible hotkeys to HTML table and open in browser ----------
ExportHtml(hotkeys, filter, showHidden := 0) {

    ; Build table rows from the same filtered view shown in the ListView
    rows := ""
    count := 0
    for item in hotkeys {
        parts    := StrSplit(item, "|")
        isHidden := (parts.Length >= 5) ? parts[5] : "0"
        if (!showHidden && isHidden = "1")
            continue
        if (filter != "" && !InStr(item, filter, 0))
            continue
        hk     := (parts.Length >= 1) ? parts[1] : ""
        action := (parts.Length >= 2) ? parts[2] : ""
        ctx    := (parts.Length >= 3) ? parts[3] : ""
        src    := (parts.Length >= 4) ? parts[4] : ""
        dispHk := FriendlyNames ? FriendlyHotkey(hk) : hk
        ; Escape HTML special chars
        dispHk := StrReplace(StrReplace(dispHk, "&", "&amp;"), "<", "&lt;")
        action := StrReplace(StrReplace(action, "&", "&amp;"), "<", "&lt;")
        ctx    := StrReplace(StrReplace(ctx,    "&", "&amp;"), "<", "&lt;")
        src    := StrReplace(StrReplace(src,    "&", "&amp;"), "<", "&lt;")
        rowClass := (Mod(count, 2) = 0) ? "even" : "odd"
        rows .= "      <tr class='" rowClass "'>"
             . "<td>" dispHk "</td><td>" action "</td>"
             . "<td>" ctx "</td><td>" src "</td></tr>`n"
        count++
    }

    filterNote := (filter != "") ? " — filtered by: <em>" filter "</em>" : ""
    hiddenNote := showHidden ? " (including hidden)" : ""
    genDate    := FormatTime(, "yyyy-MM-dd HH:mm")

    html := "<!DOCTYPE html>
(
<html lang='en'>
<head>
<meta charset='UTF-8'>
<title>{{TITLE}}</title>
<style>
  body { font-family: Segoe UI, Arial, sans-serif; font-size: 13px;
         background: #f4f4f4; color: #222; margin: 0; padding: 16px; }
  h1   { font-size: 18px; margin-bottom: 4px; }
  .meta { font-size: 11px; color: #555; margin-bottom: 12px; }
  table { border-collapse: collapse; width: 100%; background: #fff;
          box-shadow: 0 1px 3px rgba(0,0,0,.15); }
  th   { background: #003E67; color: #31FFE7; padding: 7px 10px;
         text-align: left; font-size: 12px; letter-spacing: .04em; }
  td   { padding: 5px 10px; vertical-align: top; }
  tr.even td { background: #f0f7ff; }
  tr.odd  td { background: #ffffff; }
  tr:hover td { background: #dff0ff; }
  td:first-child { white-space: nowrap; font-weight: 600; color: #003E67; }
  .footer { font-size: 10px; color: #888; margin-top: 10px; text-align: right; }
  @media print {
    body { background: #fff; padding: 0; }
    table { box-shadow: none; }
    tr:hover td { background: inherit; }
    .no-print { display: none; }
  }
</style>
</head>
<body>
  <h1>{{TITLE}}{{FILTER_NOTE}}</h1>
  <div class='meta'>{{COUNT}} hotkeys{{HIDDEN_NOTE}} &nbsp;|&nbsp; Generated: {{DATE}}</div>
  <table>
    <thead>
      <tr><th>Hotkey</th><th>Action</th><th>Context (#HotIf)</th><th>Source</th></tr>
    </thead>
    <tbody>
{{ROWS}}    </tbody>
  </table>
  <div class='footer no-print'>Print this page (Ctrl+P) to save as PDF or send to printer.</div>
</body>
</html>
)"
    html := StrReplace(html, "{{TITLE}}",       guiTitle)
    html := StrReplace(html, "{{FILTER_NOTE}}", filterNote)
    html := StrReplace(html, "{{HIDDEN_NOTE}}", hiddenNote)
    html := StrReplace(html, "{{COUNT}}",       count)
    html := StrReplace(html, "{{DATE}}",        genDate)
    html := StrReplace(html, "{{ROWS}}",        rows)

    reportPath := A_Temp "\AC2HotkeyRef_Export.html"
    try if FileExist(reportPath)
        FileDelete(reportPath)
    try {
        FileAppend(html, reportPath)
        Run(reportPath)
    } catch Error as e {
        MsgBox("Export failed: " e.Message "`n`nPath: " reportPath)
    }
}
