#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "..\Includes\DpiKeepSize.ahk"   ; keeps its windows their size across monitors with different scales

/*******************************************************************************
Title:      Hotkey Hub  --  hotkey cheatsheet, launcher, and conflict finder
Author:     Stephen Kunkel321
Tool Used:  Claude AI
Version:    11-27-2026
Repository: https://github.com/kunkel321/AutoCorrect2

A merge of HotKeyTool.ahk (icons, .lnk app launching, systray/startup) and
AC2HotkeyRef.ahk (#HotIf Context column, Show Hidden, Scan All, INI hotkeys,
Export Cheatsheet).  HotKeyToolCacheMaker.ahk is no longer needed -- icons come
straight from the exe files and are cached in the background, and the .lnk scan
itself is cached to disk.

The user-facing documentation lives in HotkeyHubHelpText, just below, so that
there is one copy of it rather than two.  Press F1 in the window, or pick
Help / About from the systray menu, to read it without opening this file.

Notes for anyone editing this script:
  * Running scripts are found by enumerating hidden AutoHotkey main windows
    (their titles are the script paths) rather than by a WMI process query.
    That is much faster and works when the scripts are elevated and this tool
    is not.  WMI remains as a fallback.
  * Nothing blocks the GUI.  The window appears immediately; the script scan,
    the shortcut scan and icon extraction all run in timer slices afterwards.
  * App rows live in App.appRows, hotkey rows in App.hotkeyRows, and
    FinishBuild is the single place the two are merged into App.entries.
    Call it after changing either half.
  * Icon lookup for a script-row hotkey checks, in order: an  icon:  tag on
    the hotkey's own comment line (e.hkIconSpec), the central [HotkeyIcons]
    section of HotkeyHub_icons.ini (App.hotkeyIcons, keyed by
    NormalizeHK(hotkey)), a  ; HotkeyHubIcon:  line anywhere in the file
    (e.iconPath / e.iconNum, whole-file), then the central [Icons] section
    (App.scriptIcons, keyed by file name).  See IconFor() and
    ResolveHotkeyIconSpec().
*******************************************************************************/

; The help text shown by F1 and by the systray menu.  Keep it plain ASCII and
; make sure no line begins with a ")" -- that would end the continuation
; section early.
HotkeyHubHelpText := "
(
Hotkey Hub -- hotkey cheatsheet, launcher, and conflict finder
Part of the AutoCorrect2 suite.
Author: kunkel321  |  AI Tool: Claude (Anthropic)  |  Version: 11-27-2026
Repository: https://github.com/kunkel321/AutoCorrect2

OVERVIEW
One searchable list of every hotkey you actually have running, plus your favourite applications.  Pick a row and press Enter: hotkeys are sent to whatever window you were in before this opened, applications are launched. Press Esc to hide again -- the tool keeps running in the systray.

THREE KINDS OF ROW
  Script   Hotkeys parsed out of running, portably-run AHK scripts -- that is,
           a renamed copy of AutoHotkey.exe sitting beside a same-named .ahk
           file.  Files pulled in with #Include are followed too.
  INI      Hotkeys stored in acSettings.ini under [Hotkeys], labelled from
           acSettingsMetadata.json.
  App      Shortcuts (.lnk) from your favourites folders and the Start Menu.
           Enter runs these instead of sending a hotkey.

ABOUT SENDING HOTKEYS
Enter or double-click on a Script or INI row replays that hotkey's own keystrokes into whatever window was active before this opened.  Many of your hotkeys only do something inside one particular app, or only once some other condition already holds -- a #HotIf context, a mode the target script is in, text already selected, and so on.  Sent from here into the wrong window or state, a hotkey like that does nothing at all, or something you did not expect.  The Context (#HotIf) column and the Source column are your best clues for which window a hotkey actually needs.  Treat this tool as a reference and a launcher, not a guarantee that every row does something useful when sent.

Windows also blocks a non-elevated program from sending keystrokes into a window running as Administrator.  If this window's title bar does not say (admin) and the window you switched from was itself elevated, the send can silently do nothing at all -- no error, the keys just never arrive.  Run this tool as Administrator too if you regularly work in elevated windows.

THE FILTER BOX
Type several words to AND them together: 'date tool' finds rows matching both. Prefix a word with - to exclude it, so 'snip -angle' drops the angle ones.

Two or more characters search the whole row -- hotkey, action, context and source file.  A SINGLE character searches the raw hotkey only, so typing d finds !+d and ^d rather than every row with a d somewhere in its description. One character is nearly always a key you are hunting for, and the word Shift in the friendly name would otherwise make f match half the list.  Since applications have no hotkey, a one-character search never matches one; type two characters to find an app by name.

Presets, from the drop-down or typed:
  *conflicts   only hotkeys defined more than once
  *apps        only application rows
  *scripts     only hotkeys from script files
  *ini         only hotkeys from acSettings.ini
  *used        only rows you have actually used
Every source file name and every #HotIf context is added to that list
automatically.  Alt+Down opens it.

THE MODIFIER BOXES     ^ Ctrl    ! Alt    + Shift    # Win
Each one clicks through three states:

  greyed   '^ Ctrl'      don't care -- where they start
  ticked   '^ Ctrl'      must contain
  empty    '^ no Ctrl'   must NOT contain

Requiring is order-independent, which is the one thing the filter box cannot do: !+d and +!d are the same hotkey typed two ways.  Extra modifiers are allowed, so requiring Alt and Shift shows ^!+d as well as !+d.  Add 'no Ctrl' and that ^!+d drops out.  Set all four to 'no' and you are left with the bare keys -- F1, Esc, Space and so on.

The boxes AND with the filter box, so to find !+d specifically: require Alt and Shift, then type d.  Any box off greyed hides the application rows, since an application has no hotkey to match.

CLEAR
Empties the filter box, returns all four modifier boxes to greyed, and puts the cursor back in the filter box.  It deliberately leaves the four view toggles alone -- those are settings rather than a search.

THE VIEW TOGGLES
  Show hidden      Include hotkeys whose in-line comment contains the word
                   hide, plus commented-out hotkey stubs.
  Apps             Include the application rows.
  Scan all         Off: only scripts running from the AutoCorrect2 folder.
                   On: every running portably-run AHK script on the system.
  Friendly names   Ctrl+Alt+D rather than ^!d, in the list and in exports.
These four are remembered in acSettings.ini and can also be edited in
SettingsManager.

COLUMNS AND SORTING
Click a column header to sort by it, click again to reverse, and a third time to go back to scan order.  The choice is remembered.

The Used column counts how often you have sent or run each row, so sorting by it floats your real workhorses to the top.  Combine that with the *used preset to see only the rows you have ever touched.

CONFLICTS
Any hotkey defined more than once in the same #HotIf context is flagged with [dup] in the Action column.  Select one and the status bar names the other script and line number; the *conflicts preset shows just those.  Hotkeys in different #HotIf contexts are not conflicts, since only one is ever live. 

RIGHT-CLICK A ROW
Send the hotkey or run the application, copy the hotkey, copy the whole row, open the defining file at the exact line in your editor, or open the file's folder in Explorer.

EXPORT
The Export button offers an HTML cheatsheet that opens in your browser and prints nicely with Ctrl+P, a Markdown file, a CSV file, or the visible rows straight to the clipboard.  Whatever the filter and the modifier boxes are currently showing is what gets exported.

KEYS
  Enter or double-click   send the hotkey, or run the application
  Down and Up             move between the filter box and the list
  Ctrl+F                  jump back to the filter box
  F5                      rescan everything
  Ctrl+E                  export the HTML cheatsheet
  F1                      this help
  Esc                     hide the window; the tool stays in the systray

ICONS
Hotkeys from a script show that script's icon, if it has been told which one. There is no way to read the icon out of a running script, so it has to be named -- in either of two places.

The central map, Data\HotkeyHub_icons.ini, is usually the easier one, since it is a single file rather than an edit to every script:

  [Icons]
  AutoCorrect2.ahk = Resources\Icons\Psicon.ico
  DateTool.ahk     = Resources\Icons\calendar-Blue.ico
  MCLogger.ahk     = Resources\Icons\JustLog.ico
  SomeTool.ahk     = shell32.dll, 44

Keys are file names, so #Include'd files get their own entry rather than inheriting whatever their parent uses.  Relative paths resolve against the AutoCorrect2 folder; absolute paths and bare library names work too, and a trailing , N picks an icon out of a .dll or .exe.

Pick 'Write icon map template' from the systray menu and every script being scanned is written into that file, commented out and ready for paths.

The other place is a line inside the script itself, which wins over the map:

  ; HotkeyHubIcon: ..\Resources\Icons\calendar-Blue.ico

There a relative path resolves against the file the line sits in.  This one travels with the script, so it is the better choice for anything you share.

Scripts named in none of the places on this page show the generic AutoHotkey icon, which is a perfectly reasonable place to leave them.  Set Cfg.useScriptIcons := 0 near the top of HotkeyHub.ahk to use that icon for everything and skip the lookup.

PER-HOTKEY ICONS
The two places above are per script file.  A single hotkey can have its own icon instead, which wins over both of them -- handy for a hotkey that just launches one particular app, so it shows that app's icon rather than the generic AHK one.

Central map: add a [HotkeyIcons] section to the same Data\HotkeyHub_icons.ini, keyed by the hotkey itself rather than by file name:

  [HotkeyIcons]
  !+s  = ZMatrix.exe
  !q   = Resources\Icons\sticky.ico
  ^!+d = shell32.dll, 44

Modifiers can be typed in any order, same as everywhere else in this tool. If the value matches the exe or the display name of one of your App rows, that app's own icon is reused; otherwise it is treated as an icon spec exactly like the [Icons] section above -- so a plain path to a .ico, resolved against the AutoCorrect2 folder, works too, with or without a trailing , N.

In-line: add  icon:<name or path>  at the end of the hotkey's own comment. This one travels with the script, so it wins over the central [HotkeyIcons] map as well:

  !+s::Run('ZMatrix.exe')  ; Launch ZMatrix screensaver  icon:ZMatrix.exe
  !q::ShowStickyNotes()    ; Show sticky notes  icon:Resources\Icons\sticky.ico

MAKING YOUR OWN HOTKEYS LOOK GOOD HERE
Put a descriptive in-line comment on each hotkey line -- that comment is what the Action column shows and what the filter searches.  Without one, the list falls back to showing the code itself, which is rarely as readable.

Include the word hide in that comment to keep a hotkey out of the list unless Show hidden is ticked.  Useful for hotkeys that exist only as plumbing.  An  icon:<name or path>  tag, see PER-HOTKEY ICONS above, gives that one hotkey its own icon.

WHERE THINGS LIVE
This script sits in AutoCorrect2\Tools\ beside its renamed HotkeyHub.exe.  It finds the suite root by walking up from itself looking for Data\acSettings.ini, so nothing is hard-coded.

  Data\acSettings.ini  [HotkeyHub]   settings: toggles, sort, window position
  Data\acSettings.ini  [Hotkeys]     HotkeyHubHotkey = the activation hotkey
  Data\HotkeyHub_icons.ini           which icon each script or hotkey shows
  Data\HotkeyHub_usage.ini           how often each row has been used
  Data\HotkeyHub_apps.tsv            cached shortcut scan, safe to delete
  Debug\HotkeyHub_export.md / .csv   exports, when you ask for them

The last two are disposable -- delete them and they rebuild.  Run this outside the suite, with no Data folder next door, and everything falls back to sitting beside the script instead.

COLOURS
Taken from Data\colorThemeSettings.ini, which ColorThemeIntegrator writes, so this tool matches the rest of the suite.  Fallback colours are set near the top of the script if that file is missing.

TUNING
The USER OPTIONS section at the top of HotkeyHub.ahk holds the rest: which folders are scanned for scripts and for shortcuts, which files are skipped, the font size, the editor command used by the right-click menu, and how long the shortcut cache stays fresh.
)"


; ==============================================================================
;  1.  USER OPTIONS
; ==============================================================================
Cfg := {}

; ---- Appearance --------------------------------------------------------------
; A_IsAdmin is a built-in v2 var -- true when this script (and therefore its
; renamed .exe pair) is running elevated.  Appended here, same convention as
; ScreenSnip, since it affects whether sent keystrokes reach an elevated
; window -- see ABOUT SENDING HOTKEYS in HotkeyHubHelpText below.
Cfg.guiTitle        := A_UserName "'s Hotkey Hub" (A_IsAdmin ? " (admin)" : "")  ; Title bar text.
Cfg.guiWidth        := 940      ; Starting width.  Overridden by remembered size.
Cfg.maxRows         := 24       ; Rows shown before the list scrolls.
Cfg.fontSize        := 11       ; 8-12 recommended.
Cfg.trans           := 255      ; 0 = invisible, 255 = opaque.
Cfg.appIcon         := "imageres.dll,95"   ; Systray icon.  Blue circle with a '?'.
Cfg.showUsedColumn  := 1        ; 0 = drop the "Used" column entirely.
Cfg.useScriptIcons  := 1        ; 1 = each script's hotkeys use that script's own
                                ; systray icon, read from its running window.
                                ; 0 = the generic AHK icon for all of them.

; Fallback colors, used only when Data\colorThemeSettings.ini has no value for
; one.  Note: It's okay to set all three to := "Default"
Cfg.defForm         := "9f9f9f" ; window background
Cfg.defList         := "d4d1c5" ; ListView / ComboBox background
Cfg.defFont         := "2e1500" ; text 


; ---- Behaviour ---------------------------------------------------------------
Cfg.mainHotkey      := "!+q"    ; Alt+Shift+Q.  Overridden by acSettings.ini if present.
Cfg.showOnStartup   := 1        ; 1 = show the window at launch.
Cfg.stickyFilter    := 0        ; 1 = keep the filter text between showings.
Cfg.rememberPos     := 1        ; 1 = remember window size/position.
Cfg.trackUsage      := 1        ; 1 = count sends/runs in the Used column.
Cfg.markConflicts   := 1        ; 1 = flag hotkeys defined more than once.
Cfg.commentedHidden := 1        ; 1 = treat "; ^!d::..." stubs as hidden rows.
Cfg.focusWaitSecs   := 5        ; Seconds to wait for the target window to return.
Cfg.startupBeep     := 1        ; 1 = two beeps when the scan finishes.

; ---- What to scan ------------------------------------------------------------
Cfg.scanRoots       := []       ; Folders whose running scripts get scanned.
                                ; Empty = just the AutoCorrect2 folder found below.
                                ; The old HotKeyTool scanned all of D:\AutoHotkey.
                                ; To get that back, name the wider folder here --
                                ; or just tick "Scan all" in the GUI, which is
                                ; remembered.  Example:
                                ; Cfg.scanRoots := ["D:\AutoHotkey\MasterScript"]
Cfg.ignoreList      := ["AutoCorrectHotstrings.ahk"   ; Files never scanned.
                       ; , "PersonalHotstrings.ahk"
                       , "HotkeyHub.ahk"
                       , "AC2HotkeyRef.ahk"
                       , "HotKeyTool.ahk"
                       , "acMsgBox.ahk"
                       , "ColorThemeIntegrator.ahk"]

Cfg.includeApps     := 1        ; 1 = add .lnk shortcuts to the list.
Cfg.lnkFolders      := ["D:\PortableApps\FavePortableLinks"   ; <-- Steve's PC
                       , "D:\AutoHotkey\AHK FaveLinks"        ; <-- Steve's PC
                       , "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
                       , "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"]
Cfg.lnkRecursive    := 1        ; 1 = include subfolders of the above.
Cfg.hideUninstallers := 1       ; 1 = skip "Uninstall ..." shortcuts.
Cfg.appCacheHours   := 24       ; Refresh the cached .lnk scan after this many hours.

; The bare modifier symbols that used to live here are gone -- the checkboxes
; beside the filter box do that job properly now, without caring what order the
; modifiers were typed in.
Cfg.preDefinedFilters := ["*conflicts", "*apps", "*scripts", "*ini", "*used"
                       , "NirSoft", "SysInternals", "Portables"]

Cfg.modBoxWidth     := 0        ; Width of each modifier checkbox.  0 = size from
                                ; the font.  Raise it if a label looks clipped.
Cfg.clearBtnWidth   := 60       ; Width of the Clear button beside them.

; ---- The F1 help window ------------------------------------------------------
Cfg.helpFontName    := "Courier New"   ; Monospace: parts of the help are in columns.
Cfg.helpFontSize    := 11
Cfg.helpWidth       := 700      ; Starting size.  The window is resizable.
Cfg.helpHeight      := 620

; ---- Editor used by the "Open source at line" context-menu item ---------------
Cfg.editorCmd       := 'code -g "{file}:{line}"'   ; VSCode.  {file} and {line} get swapped in.

; ---- Toggle defaults (remembered in HotkeyHub.ini after the first run) --------
Cfg.showHidden      := 0
Cfg.scanAll         := 0        ; 1 = scan every running AHK script, not just scanRoots.
Cfg.friendlyNames   := 1        ; 1 = "Ctrl+Alt+D",  0 = "^!d".
Cfg.showApps        := 1

; ---- Tuning ------------------------------------------------------------------
Cfg.iconBudget      := 40       ; Icons extracted during one list refresh.
Cfg.iconChunk       := 50       ; Icons extracted per background timer tick.
Cfg.lnkChunk        := 40       ; Shortcuts resolved per background timer tick.
Cfg.actionMaxLen    := 110      ; Action text is truncated to this.

; ==============================================================================
;  2.  STATE  (one object, so no function ever has to declare a global)
; ==============================================================================
App := {}
App.entries   := []          ; hotkeyRows + appRows, in scan order
App.hotkeyRows := []         ; script + INI rows

App.view      := []          ; the same objects, in current sort order
App.gui       := 0
App.ready     := 0
App.il        := 0           ; ImageList handle
App.iconMap   := Map()       ; "path|num" => image list index
App.iconQueue := []
App.iconPos   := 1
App.iconBudget := 0
App.iconAhk   := 0
App.iconIni   := 0
App.iconApp   := 0
App.scriptIcons := Map()     ; script file name => [icon path, icon number]
App.hotkeyIcons := Map()     ; NormalizeHK(hotkey) => raw [HotkeyIcons] spec
App.sortCol   := 0
App.sortDesc  := 0
App.conflicts := 0
App.prevWin   := 0
App.prevTitle := ""
App.usage     := Map()
App.lnkQueue  := []
App.lnkPos    := 1
App.appRows   := []
App.status    := "Starting..."
App.sbH       := 24
App.lvTop     := 120
App.filterList := [""]

; Modifier filter.  Each box is a three-state checkbox:
;
;    -1  indeterminate  don't care        "^ Ctrl"      <-- the startup state
;     1  checked        must contain      "^ Ctrl"
;     0  unchecked      must NOT contain  "^ no Ctrl"
;
; Indeterminate means undetermined, so that's the one that stands for "I haven't
; said anything about Ctrl".  Ticked reads as "with", empty as "without" -- and
; the empty state spells out "no", since an empty box is what most checkboxes
; look like when they mean nothing at all.
;
; Windows' own 3-state cycle is 0 -> 1 -> -1, which from this starting point
; would offer exclude before require.  OnModClick overrides it so clicking goes
; ignore -> require -> exclude -> ignore, putting the common case first.
;
; Requiring is order-independent -- the thing a text search can't do, since !+d
; and +!d are the same hotkey written two ways.  Listed in the order
; FriendlyHotkey writes them, so the boxes read like the Hotkey column.
App.modIgnore := -1
App.modNeed   := 1
App.modBan    := 0
App.modSyms   := ["^", "!", "+", "#"]
App.modNames  := ["Ctrl", "Alt", "Shift", "Win"]
App.modOn     := Map("^", -1, "!", -1, "+", -1, "#", -1)
App.modBoxes  := []
App.modW      := 85

; ==============================================================================
;  3.  PATHS, THEME, SAVED SETTINGS
; ==============================================================================
App.appName      := StrReplace(A_ScriptName, ".ahk")
App.ac2Root      := FindAC2Root()
App.dataDir      := App.ac2Root "\Data"
App.iniPath      := App.dataDir "\acSettings.ini"
App.jsonPath     := App.dataDir "\acSettingsMetadata.json"
App.themePath    := App.dataDir "\colorThemeSettings.ini"
; Settings live in the suite's own acSettings.ini under [HotkeyHub], so
; SettingsManager can edit them alongside everything else.  Usage counts and the
; shortcut cache are accumulated DATA, not settings -- they get their own files
; in Data\ so they don't clutter the settings editor.
; If the AC2 Data folder isn't there (running this outside the suite), keep
; everything beside the script instead so nothing is written into thin air.
App.inSuite      := DirExist(App.dataDir) ? true : false
App.storeDir     := App.inSuite ? App.dataDir : A_ScriptDir
App.settingsPath := App.inSuite ? App.iniPath : A_ScriptDir "\" App.appName ".ini"
App.settingsSect := "HotkeyHub"                                ; its section
App.usagePath    := App.storeDir "\" App.appName "_usage.ini"
App.appCachePath := App.storeDir "\" App.appName "_apps.tsv"
App.iconMapPath  := App.storeDir "\" App.appName "_icons.ini"

; Markdown / CSV exports land here.  The HTML cheatsheet always goes to A_Temp
; and opens in the browser, so it never accumulates.
App.exportDir := (App.inSuite && DirExist(App.ac2Root "\Debug"))
               ? App.ac2Root "\Debug" : A_ScriptDir

if (Cfg.scanRoots.Length = 0)
    Cfg.scanRoots := [App.ac2Root]

Theme := {}
Theme.font := NormalizeColor(IniGet(App.themePath, "ColorSettings", "fontColor"), Cfg.defFont)
Theme.list := NormalizeColor(IniGet(App.themePath, "ColorSettings", "listColor"), Cfg.defList)
Theme.form := NormalizeColor(IniGet(App.themePath, "ColorSettings", "formColor"), Cfg.defForm)
Theme.fontOpt := "c" Theme.font        ; the Gui option form

; Read one key, returning "" for a missing file, section or key.
IniGet(file, section, key) {
    if !FileExist(file)
        return ""
    v := ""
    try v := IniRead(file, section, key, "")
    catch as err
        return ""
    return Trim(v)
}

; Turn whatever the theme file holds into exactly 6 hex digits.
; Accepts 00233A, 0x00233A, #00233A, c00233A, and short forms like 233A.
;
; The old AC2HotkeyRef / HotKeyTool line for this was
;     fontColor := "c" SubStr(fontColor, -5)
; with a comment claiming SubStr(x, -5) grabs the last 6 characters.  It grabs
; the last FIVE -- a negative start position counts back from the end, so -5 is
; the 5th character from the end, not the 6th.  Any color whose first hex digit
; wasn't 0 silently lost that digit:  FFFFFF became FFFFF, which AHK reads as
; 0x0FFFFF -- bright cyan.  Colors like 00233A survived only because dropping a
; leading zero changes nothing.  That's why a light theme came out cyan.
NormalizeColor(raw, fallback) {
    s := Trim(raw)
    if (s = "")
        return fallback
    ; Strip one leading prefix, but only when it can't be a real hex digit.
    if (SubStr(s, 1, 2) = "0x" || SubStr(s, 1, 2) = "0X")
        s := SubStr(s, 3)
    else if (SubStr(s, 1, 1) = "#")
        s := SubStr(s, 2)
    else if (StrLen(s) = 7 && (SubStr(s, 1, 1) = "c" || SubStr(s, 1, 1) = "C"))
        s := SubStr(s, 2)              ; "cCC0000" -> "CC0000", but "CC0000" is left alone
    s := RegExReplace(s, "[^0-9A-Fa-f]", "")
    if (s = "")
        return fallback
    if (StrLen(s) > 6)
        s := SubStr(s, StrLen(s) - 5)  ; last 6, written so the arithmetic is visible
    while (StrLen(s) < 6)
        s := "0" s                     ; pad on the left: 233A -> 00233A
    return StrUpper(s)
}

LoadSettings()
LoadUsage()

; The activation hotkey can live in acSettings.ini so Settings Manager can edit it.
if FileExist(App.iniPath) {
    hk := IniRead(App.iniPath, "Hotkeys", "HotkeyHubHotkey", "")
    if (hk = "")
        hk := IniRead(App.iniPath, "Hotkeys", "AC2HotkeyRefHotkey", "")
    if (hk != "")
        Cfg.mainHotkey := hk
}

; ==============================================================================
;  4.  TRAY
; ==============================================================================
iconA := Cfg.appIcon, iconB := ""
if InStr(Cfg.appIcon, ",")
    iconA := StrSplit(Cfg.appIcon, ",")[1], iconB := StrSplit(Cfg.appIcon, ",")[2]
try TraySetIcon(iconA, iconB = "" ? 1 : iconB)

tm := A_TrayMenu
tm.Delete()
App.trayLabel := App.appName (A_IsAdmin ? " (admin)" : "")   ; same convention as ScreenSnip
tm.Add(App.trayLabel, (*) => ShowHub())
tm.Add()
tm.Add("Help / About  (F1)", (*) => ShowHubHelp())
tm.Add("Rescan now  (F5)", (*) => RescanAll())
tm.Add("Rebuild app list", (*) => RefreshApps(true))
tm.Add("Write icon map template", (*) => WriteIconMapTemplate())
tm.Add("Export cheatsheet", (*) => ExportHtml())
tm.Add()
tm.Add("Start with Windows", (*) => ToggleStartup())
if FileExist(A_Startup "\" App.appName ".lnk")
    tm.Check("Start with Windows")
tm.Add("Edit this script", (*) => OpenPathInEditor(A_ScriptFullPath, 1))
tm.Add()
tm.AddStandard()
tm.Default := App.trayLabel

; ==============================================================================
;  5.  BUILD THE GUI, THEN SCAN IN THE BACKGROUND
; ==============================================================================
BuildGui()
App.ready := 1

if Cfg.showOnStartup
    ShowHub()

try Hotkey(Cfg.mainHotkey, (*) => ShowHub(), "On")
catch as err
    MsgBox("Could not register the activation hotkey `"" Cfg.mainHotkey "`".`n`n" err.Message
         , App.appName, 4096)

SetTimer(InitialScan, -60)   ; let the window paint first
return

; ==============================================================================
;  6.  SCAN ORCHESTRATION
; ==============================================================================
InitialScan() {
    SetStatus("Scanning running scripts...")
    LoadAppCache()              ; instant if we have one
    BuildScriptAndIniEntries()
    FinishBuild()
    if (Cfg.includeApps && AppCacheIsStale())
        SetTimer(StartAppScan, -150)
    else
        StartIconPrewarm()
    if Cfg.startupBeep
        SoundBeep(900, 120), SoundBeep(1150, 120)
}

RescanAll() {
    SetStatus("Rescanning...")
    LoadAppCache()
    BuildScriptAndIniEntries()
    FinishBuild()
    StartIconPrewarm()
}

; Rebuild the script + INI rows only.  App rows live in App.appRows and are
; merged by FinishBuild, so it no longer matters whether the shortcut cache was
; loaded before or after this ran.
;
; It used to append App.appRows itself, which meant callers had to load the
; cache FIRST or the apps were silently dropped -- and InitialScan did it in the
; wrong order.  With a fresh cache nothing rebuilt afterwards, so apps never
; showed at startup, while [Refresh] worked because by then App.appRows had
; been filled by the previous pass.
BuildScriptAndIniEntries() {
    LoadIconMap()
    rows := []
    for path in GetRunningScripts()
        ParseScriptHotkeys(path, rows)
    for e in GetIniHotkeys()
        rows.Push(e)
    App.hotkeyRows := rows
}

; The single place App.entries is assembled, from whatever the two halves
; currently hold.  Call it after changing either one.
FinishBuild() {
    entries := []
    for e in App.hotkeyRows
        entries.Push(e)
    for e in App.appRows
        entries.Push(e)
    App.entries := entries

    for i, e in App.entries {
        e.idx  := i
        e.used := App.usage.Has(UsageKey(e)) ? App.usage[UsageKey(e)] : 0
    }
    App.conflicts := Cfg.markConflicts ? MarkConflicts(App.entries) : 0
    BuildFilterList()
    ApplySort()
    UpdateList()
}

; ==============================================================================
;  7.  FINDING RUNNING SCRIPTS
;      Primary method: every AHK script owns a hidden main window of class
;      "AutoHotkey" whose title starts with the script's own path.  That is far
;      faster than a WMI process query and it still works when the script is
;      elevated and this tool is not.
; ==============================================================================
GetRunningScripts() {
    found := Map()
    prevDHW := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    try {
        for hwnd in WinGetList("ahk_class AutoHotkey") {
            title := ""
            try title := WinGetTitle(hwnd)
            if (title = "")
                continue
            path := ""
            if RegExMatch(title, "i)^(.+?\.ahk)\b", &m)
                path := m[1]
            else if RegExMatch(title, "i)^(.+?\.exe)\b", &m)
                path := RegExReplace(m[1], "i)\.exe$", ".ahk")
            if (path != "" && FileExist(path))
                found[path] := 1
        }
    } finally {
        DetectHiddenWindows(prevDHW)
    }

    if (found.Count = 0)            ; fallback for odd setups
        for path in GetRunningScriptsWmi()
            found[path] := 1

    ; Chase #Include'd files, and what those include in turn -- AutoCorrect2.ahk
    ; includes AutoCorrectSystem.ahk, which pulls in more again.  Each file is
    ; read once; the depth cap is just a guard against an include cycle.
    scanned := Map()
    Loop 6 {
        pending := []
        for p in MapKeys(found)
            if !scanned.Has(p)
                pending.Push(p)
        if (pending.Length = 0)
            break
        for p in pending {
            scanned[p] := 1
            for inc in GetIncludes(p)
                if !found.Has(inc)
                    found[inc] := 1
        }
    }

    ; Scope + ignore-list filtering.
    out := []
    for path in MapKeys(found) {
        if (path = A_ScriptFullPath)
            continue
        if !Cfg.scanAll && !InRoots(path)
            continue
        skip := false
        for ig in Cfg.ignoreList {
            if InStr(path, ig) {
                skip := true
                break
            }
        }
        if !skip
            out.Push(path)
    }
    return out
}

GetRunningScriptsWmi() {
    out := []
    try {
        q := ComObject("WbemScripting.SWbemLocator").ConnectServer()
             .ExecQuery("Select Name, ExecutablePath from Win32_Process")
        for proc in q {
            exePath := proc.ExecutablePath
            if !exePath
                continue
            ahkPath := RegExReplace(exePath, "i)\.exe$", ".ahk")
            if FileExist(ahkPath)
                out.Push(ahkPath)
        }
    } catch as err {
        ; WMI unavailable -- nothing more we can do here.
    }
    return out
}

InRoots(path) {
    for root in Cfg.scanRoots
        if (root != "" && InStr(path, root, false) = 1)
            return true
    return false
}

; Pull #Include targets out of a script.  The forms AC2 actually uses:
;
;     #Include "*i ..\Includes\DateTool.ahk"   ; comment      <-- *i INSIDE quotes
;         #Include "*i ..\Includes\DragTools.ahk"             <-- indented, in #HotIf
;     #Include *i PersonalHotstrings.ahk                      <-- *i outside
;     #Include ..\Includes\Foo.ahk   ; comment                <-- bare, commented
;     #IncludeAgain "Bar.ahk"
;
; The earlier version pulled the path out with one regex whose character class
; forbade "*", so every  "*i path"  form -- which is all of AC2's optional
; includes -- silently matched nothing.  Unwrapping the quotes first and only
; then dropping the *i marker handles both orders.
GetIncludes(path) {
    out := []
    txt := ""
    try txt := FileRead(path)
    catch as err
        return out
    SplitPath path, , &dir
    Loop Parse txt, "`n", "`r" {
        line := Trim(A_LoopField)
        if !RegExMatch(line, "i)^#Include(?:Again)?\s+(.+)$", &m)
            continue
        arg := Trim(m[1])

        if (SubStr(arg, 1, 1) = '"') {          ; quoted: take what's inside
            if RegExMatch(arg, '^"([^"]*)"', &qm)
                arg := qm[1]
            else
                arg := SubStr(arg, 2)
        } else {                                ; bare: drop a trailing comment
            arg := RegExReplace(arg, "\s+;.*$", "")
        }
        arg := Trim(arg)
        arg := Trim(RegExReplace(arg, "i)^\*i\b", ""))   ; now the *i comes off

        if (arg = "" || SubStr(arg, 1, 1) = "<")         ; <Lib> include
            continue
        if !RegExMatch(arg, "i)\.ahk$")                  ; a folder, not a file
            continue

        arg := StrReplace(arg, "%A_ScriptDir%", dir)
        arg := StrReplace(arg, "%A_LineFile%", path)
        if !RegExMatch(arg, "^([A-Za-z]:|\\\\)")         ; relative to this file
            arg := dir "\" arg
        arg := NormalizePath(arg)                        ; collapse the ..\ bits
        if FileExist(arg)
            out.Push(arg)
    }
    return out
}

; Collapse ..\ and .\ so the same file can't show up twice under two spellings
; (once as ...\Core\..\Includes\DateTool.ahk and once as ...\Includes\DateTool.ahk).
NormalizePath(p) {
    buf := Buffer(1040, 0)
    len := DllCall("GetFullPathNameW", "Str", p, "UInt", 520, "Ptr", buf, "Ptr", 0, "UInt")
    if (len > 0 && len < 520)
        return StrGet(buf, "UTF-16")
    return p
}

; ==============================================================================
;  8.  PARSING A SCRIPT FOR HOTKEYS
; ==============================================================================
ParseScriptHotkeys(path, entries) {
    txt := ""
    try txt := FileRead(path)
    catch as err
        return
    if (txt = "")
        return

    SplitPath path, &fname, &fdir
    ; Optional per-file override, anywhere in the file:
    ;     ; HotkeyHubIcon: ..\Resources\Icons\calendar-Blue.ico
    ;     ; HotkeyHubIcon: shell32.dll, 44
    ; Takes priority over the central map in Data\HotkeyHub_icons.ini.
    ovrPath := "", ovrNum := 1
    if RegExMatch(txt, "im)^\s*;\s*HotkeyHubIcon\s*:\s*(.+)$", &om) {
        parsed := ParseIconSpec(om[1], fdir)   ; relative to the file it sits in
        ovrPath := parsed[1], ovrNum := parsed[2]
    }

    lines   := StrSplit(txt, "`n", "`r")
    ctx     := ""
    inBlock := false

    Loop lines.Length {
        lineNo := A_Index
        line   := Trim(lines[lineNo])
        if (line = "")
            continue

        ; ---- /* block comments */ ----
        if (!inBlock && SubStr(line, 1, 2) = "/*") {
            inBlock := !InStr(SubStr(line, 3), "*/")
            continue
        }
        if (inBlock) {
            if InStr(line, "*/")
                inBlock := false
            continue
        }

        ; ---- #HotIf context ----
        if RegExMatch(line, "i)^#HotIf\b") {
            ctx := ParseContext(line, "i)^#HotIf\s*(;.*)?$")
            continue
        }
        ; ---- runtime HotIfWinActive context (class-based scripts) ----
        if RegExMatch(line, "i)^HotIfWinActive\b") {
            ctx := ParseContext(line, 'i)^HotIfWinActive\s*(?:`"`")?\s*(;.*)?$')
            continue
        }

        ; ---- hotkey line? ----
        p := InStr(line, "::")
        if (!p)
            continue
        left  := Trim(SubStr(line, 1, p - 1))
        right := Trim(SubStr(line, p + 2))

        commented := false
        if (SubStr(left, 1, 1) = ";") {
            commented := true
            left := Trim(LTrim(left, "; `t"))
        }
        if !IsHotkeyDef(left)
            continue

        SplitComment(right, &code, &comment)
        hidden := RegExMatch(comment, "i)\bhide\b") ? true : false

        ; An  icon:<name or path>  tag at the end of the hotkey's own
        ; in-line comment names an icon just for this hotkey -- see
        ; ResolveHotkeyIconSpec().  Cut out before the comment becomes the
        ; Action text, same as the "hide" keyword above.
        hkIconSpec := ""
        if RegExMatch(comment, "i)^(.*?)\bicon:\s*(.+)$", &im) {
            hkIconSpec := Trim(im[2])
            comment := Trim(im[1])
        }

        action := Trim(RegExReplace(comment, "i)\bhide\b", ""))
        if (action = "")
            action := code
        if (action = "" || action = "{")
            action := PeekAction(lines, lineNo)
        action := Trim(action, " `t{")
        if (StrLen(action) > Cfg.actionMaxLen)
            action := SubStr(action, 1, Cfg.actionMaxLen - 3) "..."

        e := {}
        e.kind      := "script"
        e.hk        := left
        e.action    := action
        e.ctx       := ctx
        e.src       := fname
        e.path      := path
        e.dir       := ""
        e.args      := ""
        e.line      := lineNo
        e.iconPath  := ovrPath
        e.iconNum   := ovrNum
        e.hkIconSpec := hkIconSpec
        e.commented := commented
        e.hidden    := hidden || (commented && Cfg.commentedHidden)
        e.conflict  := false
        e.dupWith   := ""
        e.used      := 0
        e.idx       := 0
        entries.Push(e)
    }
}

; A bare "#HotIf" / HotIfWinActive "" clears the context.  An in-line comment on
; the directive line is used as the label; otherwise the WinActive() argument is.
ParseContext(line, barePattern) {
    if RegExMatch(line, barePattern)
        return ""
    if RegExMatch(line, ";\s*(.+)$", &cm)
        return Trim(cm[1])
    if RegExMatch(line, "i)WinActive\((?:`"([^`"]+)`"|'([^']+)'|([\w.]+))\s*\)", &hm) {
        c := (hm[1] != "") ? hm[1] : (hm[2] != "") ? hm[2] : hm[3]
        return Trim(RegExReplace(c, "^Config\.", ""))
    }
    if RegExMatch(line, 'i)^HotIfWinActive\s+`"([^`"]+)`"', &am)
        return Trim(am[1])
    return ""
}

; Is the text to the left of "::" actually a hotkey definition?
; Allows modifier prefixes, a word key (Space, F5, vk1B), a single punctuation
; key (/ \ [ ]), an "a & b" combination, and a trailing " up".
IsHotkeyDef(s) {
    static pat := "i)^[#!^+<>*~$]{0,6}(?:\w+|[^\s\w])"
                . "(?:\s*&\s*[#!^+<>*~$]{0,6}(?:\w+|[^\s\w]))?(?:\s+up)?$"
    if (s = "" || StrLen(s) > 40)
        return false
    return RegExMatch(s, pat) ? true : false
}

; Split a line into code and in-line comment, ignoring semicolons inside quotes.
SplitComment(s, &code, &comment) {
    code := s, comment := ""
    inS := false, inD := false
    Loop StrLen(s) {
        ch := SubStr(s, A_Index, 1)
        if (ch = '"' && !inS)
            inD := !inD
        else if (ch = "'" && !inD)
            inS := !inS
        else if (ch = ";" && !inS && !inD) {
            prev := (A_Index > 1) ? SubStr(s, A_Index - 1, 1) : " "
            if (A_Index = 1 || prev = " " || prev = "`t") {
                code    := Trim(SubStr(s, 1, A_Index - 1))
                comment := Trim(SubStr(s, A_Index + 1))
                break
            }
        }
    }
}

; For "^!d::" with the body on following lines, borrow a label from below.
PeekAction(lines, lineNo) {
    Loop 3 {
        i := lineNo + A_Index
        if (i > lines.Length)
            break
        nxt := Trim(lines[i])
        if (nxt = "" || nxt = "{" || SubStr(nxt, 1, 2) = "/*")
            continue
        if (SubStr(nxt, 1, 1) = ";")
            return Trim(LTrim(nxt, "; `t"))
        SplitComment(nxt, &c, &cm)
        return (cm != "") ? cm : c
    }
    return ""
}

; ==============================================================================
;  9.  HOTKEYS DEFINED IN acSettings.ini
; ==============================================================================
GetIniHotkeys() {
    out := []
    if !FileExist(App.iniPath)
        return out

    meta := LoadJsonMetadata(App.jsonPath)
    section := ""
    try section := IniRead(App.iniPath, "Hotkeys")
    catch as err
        return out

    ; Keys whose metadata has no "restart" field to derive a source from.
    sourceOverrides := Map("ACLogAnalyzerHk", "AutoCorrect2.ahk")

    for pair in StrSplit(section, "`n") {
        pair := Trim(pair)
        if (pair = "" || SubStr(pair, 1, 1) = ";")
            continue
        eqPos := InStr(pair, "=")
        if !eqPos
            continue
        keyName := Trim(SubStr(pair, 1, eqPos - 1))
        hkValue := Trim(SubStr(pair, eqPos + 1))
        if (hkValue = "" || keyName = "HotkeyHubHotkey" || keyName = "AC2HotkeyRefHotkey")
            continue

        metaKey := "Hotkeys." keyName
        label := meta.Has(metaKey) ? meta[metaKey]["label"] : ""
        if (label = "")
            label := keyName

        source := ""
        if sourceOverrides.Has(keyName)
            source := sourceOverrides[keyName]
        if (source = "" && meta.Has(metaKey)) {
            restartVal := meta[metaKey]["restart"]
            if (restartVal != "") {
                SplitPath restartVal, &rBase
                source := RegExReplace(rBase, "i)\.exe$", ".ahk")
            }
        }
        if (source = "")
            source := RegExReplace(keyName, "i)(Hotkey|Hk)$", "") ".ahk"

        e := {}
        e.kind      := "ini"
        e.hk        := hkValue
        e.action    := label
        e.ctx       := ""
        e.src       := source
        e.path      := App.iniPath
        e.dir       := ""
        e.args      := ""
        e.line      := 0
        e.iconPath  := ""
        e.iconNum   := 1
        e.hkIconSpec := ""
        e.commented := false
        e.hidden    := false
        e.conflict  := false
        e.dupWith   := ""
        e.used      := 0
        e.idx       := 0
        out.Push(e)
    }
    return out
}

; Hand-rolled JSON key extractor -- same approach SettingsManager uses.
LoadJsonMetadata(jsonPath) {
    meta := Map()
    if !FileExist(jsonPath)
        return meta
    raw := ""
    try raw := FileRead(jsonPath)
    catch as err
        return meta

    pos := 1
    while RegExMatch(raw, '"([\w.]+)"\s*:\s*\{', &km, pos) {
        entryKey   := km[1]
        blockStart := km.Pos + km.Len
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
        label := "", help := "", restart := ""
        if RegExMatch(block, '"label"\s*:\s*"((?:[^"\\]|\\.)*)"', &lm)
            label := lm[1]
        if RegExMatch(block, '"help"\s*:\s*"((?:[^"\\]|\\.)*)"', &hm)
            help := RegExReplace(hm[1], "\\n", "`n")
        if RegExMatch(block, '"restart"\s*:\s*"((?:[^"\\]|\\.)*)"', &rm)
            restart := rm[1]
        meta[entryKey] := Map("label", label, "help", help, "restart", restart)
        pos := km.Pos + 1
    }
    return meta
}

; ==============================================================================
; 10.  APP (.lnk) ROWS  --  disk cached, scanned in background slices
; ==============================================================================
AppCacheIsStale() {
    if !FileExist(App.appCachePath)
        return true
    try {
        age := DateDiff(A_Now, FileGetTime(App.appCachePath, "M"), "Minutes")
        return (age > Cfg.appCacheHours * 60)
    } catch as err {
        return true
    }
}

LoadAppCache() {
    App.appRows := []
    if (!Cfg.includeApps || !FileExist(App.appCachePath))
        return
    txt := ""
    try txt := FileRead(App.appCachePath, "UTF-8")
    catch as err
        return
    Loop Parse txt, "`n", "`r" {
        if (A_LoopField = "")
            continue
        f := StrSplit(A_LoopField, "`t")
        if (f.Length < 6)
            continue
        App.appRows.Push(MakeAppRow(f[1], f[2], f[3], f[4], f[5], f[6]))
    }
}

SaveAppCache() {
    txt := ""
    for e in App.appRows
        txt .= e.action "`t" e.path "`t" e.args "`t" e.dir "`t" e.iconPath "`t" e.iconNum "`n"
    try {
        if FileExist(App.appCachePath)
            FileDelete(App.appCachePath)
        FileAppend(txt, App.appCachePath, "UTF-8")
    } catch as err {
        ; A read-only folder just means no cache; not worth interrupting anyone.
    }
}

MakeAppRow(name, target, args, dir, iconPath, iconNum) {
    e := {}
    e.kind      := "app"
    e.hk        := ""
    e.action    := name
    e.ctx       := ""
    SplitPath target, &tBase
    e.src       := tBase
    e.path      := target
    e.dir       := dir
    e.args      := args
    e.line      := 0
    e.iconPath  := (iconPath != "" && FileExist(iconPath)) ? iconPath : target
    e.iconNum   := (IsInteger(iconNum) && Integer(iconNum) > 0) ? Integer(iconNum) : 1
    e.hkIconSpec := ""
    e.commented := false
    e.hidden    := false
    e.conflict  := false
    e.dupWith   := ""
    e.used      := 0
    e.idx       := 0
    return e
}

RefreshApps(force := false) {
    if !Cfg.includeApps {
        MsgBox("App rows are turned off (Cfg.includeApps := 0).", App.appName, 4096)
        return
    }
    if (force || AppCacheIsStale())
        StartAppScan()
}

StartAppScan() {
    App.lnkQueue := []
    App.lnkPos   := 1
    recurse := Cfg.lnkRecursive ? "R" : ""
    for folder in Cfg.lnkFolders {
        if !DirExist(folder)
            continue
        Loop Files, folder "\*.lnk", recurse {
            if (Cfg.hideUninstallers
                && (InStr(A_LoopFileName, "Uninstall ")
                 || InStr(A_LoopFileName, "Uninstall.")
                 || InStr(A_LoopFileName, "Uninstall)")))
                continue
            App.lnkQueue.Push(A_LoopFileFullPath)
        }
    }
    App.appRows := []
    SetStatus("Scanning " App.lnkQueue.Length " shortcuts...")
    SetTimer(AppScanTick, 25)
}

AppScanTick() {
    static seen := Map()
    if (App.lnkPos = 1)
        seen := Map()
    n := 0
    while (App.lnkPos <= App.lnkQueue.Length && n < Cfg.lnkChunk) {
        lnk := App.lnkQueue[App.lnkPos]
        App.lnkPos++, n++
        target := "", dir := "", args := "", desc := "", icon := "", iconNum := 1
        try FileGetShortcut(lnk, &target, &dir, &args, &desc, &icon, &iconNum)
        catch as err
            continue
        if (target = "" || !FileExist(target))
            continue
        SplitPath lnk, , , , &nameNoExt
        key := StrLower(nameNoExt "|" target)
        if seen.Has(key)
            continue
        seen[key] := 1
        App.appRows.Push(MakeAppRow(Clean(nameNoExt), target, Clean(args), dir
                                  , icon = "" ? "" : icon, iconNum))
    }
    if (App.lnkPos <= App.lnkQueue.Length) {
        SetStatus("Scanning shortcuts...  " App.lnkPos " of " App.lnkQueue.Length)
        return
    }
    SetTimer(AppScanTick, 0)
    SaveAppCache()
    FinishBuild()          ; App.appRows changed; the hotkey rows are untouched,
    StartIconPrewarm()     ; so there's no need to re-read every script again
}

Clean(s) {
    return Trim(StrReplace(StrReplace(StrReplace(s, "`t", " "), "`r", " "), "`n", " "))
}

; ==============================================================================
; 11.  CONFLICT DETECTION
; ==============================================================================
MarkConflicts(entries) {
    groups := Map()
    for e in entries {
        e.conflict := false
        e.dupWith  := ""
        if (e.kind = "app" || e.hidden)
            continue
        norm := NormalizeHK(e.hk)
        if (norm = "")
            continue
        k := norm "|" StrLower(e.ctx)
        if !groups.Has(k)
            groups[k] := []
        groups[k].Push(e)
    }
    count := 0
    for k, arr in groups {
        if (arr.Length < 2)
            continue
        for e in arr {
            others := ""
            for o in arr {
                if (o.idx != e.idx)
                    others .= (others = "" ? "" : ", ") o.src (o.line ? " line " o.line : "")
            }
            e.conflict := true
            e.dupWith  := others
            count++
        }
    }
    return count
}

; "^!d", "!^D", "$^!d" and "<^!d" all normalize to the same thing.
NormalizeHK(hk) {
    s := Trim(hk)
    s := RegExReplace(s, "[~*$<>]", "")
    if (s = "")
        return ""
    mods := ""
    for m in ["#", "^", "!", "+"]
        if InStr(s, m)
            mods .= m
    key := RegExReplace(s, "^[#^!+]+", "")
    key := RegExReplace(key, "\s+", " ")
    return mods StrLower(Trim(key))
}

; ==============================================================================
; 12.  GUI
; ==============================================================================
BuildGui() {
    g := Gui("+Resize +MinSize700x320", Cfg.guiTitle)
    DpiKeepSize.Watch(g)   ; keep its size across monitors with different scales
    g.MarginX := 10, g.MarginY := 10
    g.BackColor := Theme.form
    g.SetFont("s" Cfg.fontSize " " Theme.fontOpt)

    g.lbl := g.Add("Text", "xm ym w" Cfg.guiWidth " h" (Cfg.fontSize * 2 + 6)
                 , "Filter, then press Enter -- or double-click a row.   F1 = help")

    ; --- Row 1:  filter box, then the modifier boxes pinned to the right -------
    ; Created near where the layout pass will put them.  Controls built far from
    ; their final spot leave their first paint stranded behind whatever ends up
    ; on top of it.
    ; Wide enough for the longest label, which is the exclude form "+ no Shift".
    App.modW := Cfg.modBoxWidth ? Cfg.modBoxWidth : (Cfg.fontSize * 5 + 30)
    modsW := App.modSyms.Length * App.modW + (App.modSyms.Length - 1) * 6
           + 8 + Cfg.clearBtnWidth
    startFilterW := Cfg.guiWidth - modsW - 10
    if (startFilterW < 160)
        startFilterW := 160
    g.filter := g.Add("ComboBox", "xm w" startFilterW " Background" Theme.list, App.filterList)

    App.modBoxes := []
    for i, sym in App.modSyms {
        opt := (i = 1) ? "x+10 yp+3 w" App.modW : "x+6 yp w" App.modW
        cb := g.Add("CheckBox", "Check3 " opt " " Theme.fontOpt " Background" Theme.form
                  , ModLabel(i, App.modIgnore))
        cb.Value := App.modIgnore          ; start greyed = nothing said yet
        cb.OnEvent("Click", OnModClick.Bind(i, sym))
        App.modBoxes.Push(cb)
    }
    g.btnClear := g.Add("Button", "x+8 yp-3 w" Cfg.clearBtnWidth, "Clear")
    g.btnClear.OnEvent("Click", (*) => ClearFilters())

    ; --- Row 2:  view toggles, then the buttons pinned to the right -----------
    g.cbHidden   := g.Add("CheckBox", "xm y+12 " Theme.fontOpt " Background" Theme.form, "Show hidden")
    g.cbApps     := g.Add("CheckBox", "x+14 yp " Theme.fontOpt " Background" Theme.form, "Apps")
    g.cbScanAll  := g.Add("CheckBox", "x+14 yp " Theme.fontOpt " Background" Theme.form, "Scan all")
    g.cbFriendly := g.Add("CheckBox", "x+14 yp " Theme.fontOpt " Background" Theme.form, "Friendly names")
    g.cbHidden.Value   := Cfg.showHidden
    g.cbApps.Value     := Cfg.showApps
    g.cbScanAll.Value  := Cfg.scanAll
    g.cbFriendly.Value := Cfg.friendlyNames

    g.btnRefresh := g.Add("Button", "x+20 yp-4 w90", "Refresh")
    g.btnExport  := g.Add("Button", "x+6 yp w110", "Export")

    cols := ["Hotkey", "Action", "Context (#HotIf)", "Source", "Used", "Idx"]
    g.lv := g.Add("ListView", "xm y+10 w" Cfg.guiWidth " h" (Cfg.maxRows * 20)
                            . " Grid Background" Theme.list, cols)

    g.SetFont("s" (Cfg.fontSize - 1))
    g.sb := g.Add("StatusBar")
    g.SetFont("s" Cfg.fontSize " " Theme.fontOpt)

    g.filter.OnEvent("Change", (*) => UpdateList())
    g.btnRefresh.OnEvent("Click", (*) => RescanAll())
    g.btnExport.OnEvent("Click", (*) => ShowExportMenu())
    g.cbHidden.OnEvent("Click", (*) => ToggleOption("showHidden", g.cbHidden.Value))
    g.cbApps.OnEvent("Click", (*) => ToggleOption("showApps", g.cbApps.Value))
    g.cbScanAll.OnEvent("Click", (*) => ToggleScanAll(g.cbScanAll.Value))
    g.cbFriendly.OnEvent("Click", (*) => ToggleOption("friendlyNames", g.cbFriendly.Value))
    g.lv.OnEvent("DoubleClick", (*) => ActivateFocusedRow())
    g.lv.OnEvent("ItemSelect", (*) => OnItemSelect())
    g.lv.OnEvent("ColClick", OnColClick)
    g.lv.OnEvent("ContextMenu", OnListContext)
    g.OnEvent("Escape", (*) => HideHub())
    g.OnEvent("Close",  (*) => HideHub())
    g.OnEvent("Size",   OnGuiSize)

    try WinSetTransparent(Cfg.trans, g)

    g.lv.GetPos(, &lvY)
    App.lvTop := lvY
    App.gui := g

    ; Window-local keys.  Registered against this GUI only, so nothing is
    ; hooked system-wide.
    HotIfWinActive("ahk_id " g.Hwnd)
    Hotkey("Enter",       (*) => OnEnter(), "On")
    Hotkey("NumpadEnter", (*) => OnEnter(), "On")
    Hotkey("Down",        (*) => OnArrow("Down"), "On")
    Hotkey("Up",          (*) => OnArrow("Up"), "On")
    Hotkey("^f",          (*) => g.filter.Focus(), "On")
    Hotkey("F5",          (*) => RescanAll(), "On")
    Hotkey("^e",          (*) => ExportHtml(), "On")
    Hotkey("F1",          (*) => ShowHubHelp(), "On")
    HotIfWinActive()
}

ShowHub() {
    g := App.gui
    if !g
        return
    if WinActive("ahk_id " g.Hwnd) {          ; toggle off
        HideHub()
        return
    }
    App.prevWin   := WinExist("A")
    App.prevTitle := ""
    try App.prevTitle := WinGetTitle("ahk_id " App.prevWin)
    g.lbl.Text := "Filter, then Enter -- or double-click.   F1 = help.    Target:  "
                . (App.prevTitle = "" ? "(none)" : App.prevTitle)
    if !Cfg.stickyFilter {
        g.filter.Text := ""
        ClearModFilter()        ; the modifier boxes clear with the text box
        UpdateList()
    }
    opt := "w" (Cfg.guiWidth + 28)
    if (Cfg.rememberPos && App.savedW > 300)
        opt := "x" App.savedX " y" App.savedY " w" App.savedW " h" App.savedH
    g.Show(opt)
    g.filter.Focus()
}

HideHub() {
    g := App.gui
    if !g
        return
    SaveWindowPos()
    g.Hide()
}

SaveWindowPos() {
    if !Cfg.rememberPos
        return
    g := App.gui
    try {
        g.GetPos(&x, &y)
        g.GetClientPos(, , &w, &h)
        if (x > -3000 && y > -3000 && x < 12000 && y < 12000 && w > 300) {
            ; Only touch the shared acSettings.ini when something actually moved.
            if (x = App.savedX && y = App.savedY && w = App.savedW && h = App.savedH)
                return
            App.savedX := x, App.savedY := y, App.savedW := w, App.savedH := h
            IniWrite(x, App.settingsPath, App.settingsSect, "WinX")
            IniWrite(y, App.settingsPath, App.settingsSect, "WinY")
            IniWrite(w, App.settingsPath, App.settingsSect, "WinW")
            IniWrite(h, App.settingsPath, App.settingsSect, "WinH")
        }
    } catch as err {
        ; Not worth bothering anyone about.
    }
}

OnGuiSize(g, MinMax, W, H) {
    if (MinMax = -1 || !App.ready)
        return
    static WM_SETREDRAW := 0x000B
    static RDW_INVALIDATE := 0x0001, RDW_ERASE := 0x0004
    static RDW_ALLCHILDREN := 0x0080, RDW_UPDATENOW := 0x0100

    DllCall("user32\SendMessageW", "Ptr", g.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)

    m := 10
    innerW := W - 2 * m
    if (innerW < 300)
        innerW := 300

    g.lbl.Move(, , innerW)

    ; Row 1 -- modifier boxes and Clear pinned right, filter box takes the rest.
    n := App.modBoxes.Length
    g.btnClear.GetPos(, &clrY, &clrW)
    modsW := n * App.modW + (n - 1) * 6 + 8 + clrW
    modX  := m + innerW - modsW
    fw    := modX - m - 10
    if (fw < 140) {                 ; very narrow window: let the boxes overlap
        fw   := 140                 ; the gap rather than push off-screen
        modX := m + fw + 10
    }
    g.filter.Move(, , fw)
    x := modX
    for cb in App.modBoxes {
        cb.GetPos(, &cy)
        cb.Move(x, cy, App.modW)
        x += App.modW + 6
    }
    g.btnClear.Move(x + 2, clrY)

    ; Row 2 -- buttons pinned right.
    g.btnExport.GetPos(, &ey, &ew)
    g.btnRefresh.GetPos(, &ry, &rw)
    exX := m + innerW - ew
    rfX := exX - 6 - rw
    g.btnExport.Move(exX, ey)
    g.btnRefresh.Move(rfX, ry)

    ; Measure the status bar rather than guessing -- its height varies with DPI.
    sbh := 0
    try g.sb.GetPos(, , , &sbh)
    if (sbh > 8)
        App.sbH := sbh

    listH := H - App.lvTop - App.sbH - m
    if (listH < 80)
        listH := 80
    g.lv.Move(, , innerW, listH)
    SizeColumns(innerW)

    DllCall("user32\SendMessageW", "Ptr", g.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
    ; RDW_ERASE is what clears the background a control has just vacated.
    ; Without it the moved buttons leave their old frames painted behind the
    ; ComboBox.  UPDATENOW repaints immediately rather than queueing, so a fast
    ; drag doesn't stack up half-finished frames.
    DllCall("RedrawWindow", "Ptr", g.Hwnd, "Ptr", 0, "Ptr", 0
          , "UInt", RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN | RDW_UPDATENOW)
}

SizeColumns(innerW) {
    lv := App.gui.lv
    usedW := Cfg.showUsedColumn ? 52 : 0
    ; Only subtract scrollbar width when the ListView actually has one, otherwise
    ; the shortfall shows up as an empty gridded strip past the last column.
    static WS_VSCROLL := 0x200000, GWL_STYLE := -16
    barW := 0
    try {
        style := DllCall("GetWindowLongPtrW", "Ptr", lv.Hwnd, "Int", GWL_STYLE, "Ptr")
        if (style & WS_VSCROLL)
            barW := SysGet(2)               ; SM_CXVSCROLL
    }
    avail := innerW - usedW - barW - 4
    if (avail < 260)
        avail := 260
    c1 := Round(avail * 0.21)
    c2 := Round(avail * 0.37)
    c3 := Round(avail * 0.20)
    c4 := avail - c1 - c2 - c3
    lv.ModifyCol(1, c1)
    lv.ModifyCol(2, c2)
    lv.ModifyCol(3, c3)
    lv.ModifyCol(4, c4)
    lv.ModifyCol(5, usedW)
    lv.ModifyCol(6, 0)                  ; hidden: index into App.entries
}

; ==============================================================================
; 13.  LIST POPULATION, FILTERING, SORTING
; ==============================================================================
UpdateList() {
    g := App.gui
    if (!g || !App.ready)
        return
    filter := g.filter.Text
    lv := g.lv
    lv.Opt("-Redraw")
    lv.Delete()
    App.iconBudget := Cfg.iconBudget

    shown := 0, total := 0
    for e in App.view {
        if !PassesGates(e)
            continue
        total++
        if !MatchFilter(e, filter)
            continue
        disp   := DisplayHotkey(e)
        action := (e.conflict ? "[dup] " : "") e.action
        usedTx := (Cfg.showUsedColumn && e.used > 0) ? e.used : ""
        ico    := IconFor(e)
        lv.Add(ico ? "Icon" ico : "", disp, action, e.ctx, e.src, usedTx, e.idx)
        shown++
    }
    lv.Opt("+Redraw")
    App.shown := shown, App.total := total   ; set before Modify, which fires ItemSelect
    if (shown > 0)
        lv.Modify(1, "Select Focus")
    ; The row count decides whether there's a scrollbar, which decides the
    ; column widths -- so re-measure now that the rows are in.
    try {
        lv.GetPos(, , &lvW)
        SizeColumns(lvW)
    }
    SetStatus("")
}

PassesGates(e) {
    if (e.hidden && !Cfg.showHidden)
        return false
    if (e.kind = "app" && !Cfg.showApps)
        return false
    return true
}

; Which modifiers a hotkey definition actually uses, as a set of symbols.
; Only the prefix is examined, so "+::" (a hotkey on the Shift key itself)
; correctly reports no modifiers rather than claiming Shift.
HotkeyMods(hk) {
    s := Trim(LTrim(hk, "; `t"))
    s := RegExReplace(s, "[~*$<>]", "")
    prefix := ""
    while (StrLen(s) > 1 && SubStr(s, 1, 1) ~= "[#!^+]") {
        prefix .= SubStr(s, 1, 1)
        s := SubStr(s, 2)
    }
    out := ""
    for sym in App.modSyms
        if InStr(prefix, sym)
            out .= sym
    return out
}

; Every REQUIRED modifier must be present and every EXCLUDED one absent.
; Modifiers left alone are ignored, so requiring Alt+Shift still shows ^!+d --
; "hotkeys with Alt and Shift in them", extras allowed.  Add "no Ctrl" and that
; same ^!+d drops out.  Setting all four to exclude leaves the bare keys: F1,
; Esc, Space and friends.
PassesModFilter(e) {
    need := "", ban := ""
    for sym in App.modSyms {
        v := App.modOn[sym]
        if (v = App.modNeed)
            need .= sym
        else if (v = App.modBan)
            ban .= sym
    }
    if (need = "" && ban = "")
        return true
    if (e.kind = "app")     ; apps have no hotkey, so they can't match one
        return false
    have := HotkeyMods(e.hk)
    Loop Parse need
        if !InStr(have, A_LoopField)
            return false
    Loop Parse ban
        if InStr(have, A_LoopField)
            return false
    return true
}

; "^ Ctrl" while ignored or required, "^ no Ctrl" while excluded.  The checkbox
; glyph alone can't say which way an empty box is meant to read.
ModLabel(i, state) {
    return App.modSyms[i] (state = App.modBan ? " no " : " ") App.modNames[i]
}

; Windows has already advanced the box by the time this runs; reassigning is
; what gives us our own cycle order rather than the built-in one.
NextModState(cur) {
    if (cur = App.modIgnore)
        return App.modNeed
    if (cur = App.modNeed)
        return App.modBan
    return App.modIgnore
}

OnModClick(i, sym, ctrl, *) {
    next := NextModState(App.modOn[sym])
    App.modOn[sym] := next
    ctrl.Value := next
    ctrl.Text  := ModLabel(i, next)
    UpdateList()
}

ClearModFilter() {
    for sym in App.modSyms
        App.modOn[sym] := App.modIgnore
    for i, cb in App.modBoxes {
        cb.Value := App.modIgnore
        cb.Text  := ModLabel(i, App.modIgnore)
    }
}

; The Clear button.  Resets the two things that narrow the list -- the text and
; the modifier boxes -- and leaves the view toggles (Show hidden, Apps, Scan
; all, Friendly names) alone, since those are settings rather than a search.
ClearFilters() {
    g := App.gui
    if !g
        return
    g.filter.Text := ""
    ClearModFilter()
    UpdateList()
    g.filter.Focus()
}

MatchFilter(e, filter) {
    if !PassesModFilter(e)
        return false
    f := Trim(filter)
    if (f = "")
        return true
    if (SubStr(f, 1, 1) = "*") {
        p := StrLower(SubStr(f, 2))
        if (p = "conflicts")
            return e.conflict
        if (p = "apps")
            return e.kind = "app"
        if (p = "scripts")
            return e.kind = "script"
        if (p = "ini")
            return e.kind = "ini"
        if (p = "used")
            return e.used > 0
        ; not a preset -- fall through and treat it as plain text
    }
    hay := FilterHaystack(e)
    for term in StrSplit(f, " ") {
        if (term = "")
            continue
        neg := (SubStr(term, 1, 1) = "-")
        if neg {
            term := SubStr(term, 2)
            if (term = "")
                continue
        }
        if (TermHits(e, hay, term) != !neg)
            return false
    }
    return true
}

; What a typed term is searched against.
;
; The full file path used to be in here, which meant every row carried
; "D:\AutoHotkey\..." -- so typing  d  matched all 812 rows via the drive
; letter.  The Source column shows the basename and that's what's worth
; searching; the path is reachable from the right-click menu instead.  The kind
; ("script" / "ini" / "app") came out too, since the *scripts / *ini / *apps
; presets do that job without making every row match  s ,  c ,  r  and so on.
FilterHaystack(e) {
    return e.hk " " DisplayHotkey(e) " " e.action " " e.ctx " " e.src
         . (e.conflict ? " conflict dup" : "")
}

; A single character is almost always the key of a hotkey rather than something
; to find in the row's text -- "Shift" alone would make every Shift hotkey match
; a search for  f .  So one character is matched against the raw hotkey only:
; "!+d" for the  d  case.  It's the raw form deliberately, not the friendly one,
; because "Alt+Shift+D" contains a, l, t, s, h, i and f before you even reach
; the key.  Two or more characters search everything, as before.
;
; Side effect worth knowing: App rows have no hotkey, so a one-character search
; never matches one.  Type two characters to find an app by name.
TermHits(e, hay, term) {
    if (StrLen(term) = 1)
        return InStr(e.hk, term) ? true : false
    return InStr(hay, term) ? true : false
}

DisplayHotkey(e) {
    if (e.kind = "app")
        return "App"
    return Cfg.friendlyNames ? FriendlyHotkey(e.hk) : e.hk
}

; !+d -> Alt+Shift+D      ^F5 -> Ctrl+F5      #e -> Win+E
FriendlyHotkey(hkRaw) {
    s := Trim(LTrim(hkRaw, "; `t"))
    key := RegExReplace(s, "^[!+^#~*&$<>]+", "")
    if (key = "")               ; e.g. "+::" -- the modifier IS the key
        return s
    return (InStr(s, "^") ? "Ctrl+"  : "")
         . (InStr(s, "!") ? "Alt+"   : "")
         . (InStr(s, "+") ? "Shift+" : "")
         . (InStr(s, "#") ? "Win+"   : "")
         . StrUpper(SubStr(key, 1, 1)) SubStr(key, 2)
}

OnColClick(lv, col, *) {
    if (col < 1 || col > 5)
        return
    if (col = App.sortCol) {
        if !App.sortDesc
            App.sortDesc := 1
        else
            App.sortCol := 0, App.sortDesc := 0      ; third click = scan order
    } else {
        App.sortCol := col, App.sortDesc := 0
    }
    SaveSetting("SortCol",  App.sortCol)
    SaveSetting("SortDesc", App.sortDesc)
    ApplySort()
    UpdateList()
}

ApplySort() {
    if (!App.sortCol) {
        App.view := App.entries.Clone()
        return
    }
    view := MergeSortBy(App.entries.Clone(), CompareEntries.Bind(App.sortCol))
    if App.sortDesc
        view := ReverseArray(view)
    App.view := view
}

CompareEntries(col, a, b) {
    switch col {
        case 1: return StrCompare(DisplayHotkey(a), DisplayHotkey(b), false)
        case 2: return StrCompare(a.action, b.action, false)
        case 3: return StrCompare(a.ctx, b.ctx, false)
        case 4: return StrCompare(a.src, b.src, false)
        case 5: return b.used - a.used            ; most-used first by default
    }
    return 0
}

; AHK v2 has no Array.Sort, and a stable merge sort keeps ties in scan order.
MergeSortBy(arr, cmp) {
    if (arr.Length <= 1)
        return arr
    mid := arr.Length // 2
    left := [], right := []
    Loop mid
        left.Push(arr[A_Index])
    Loop arr.Length - mid
        right.Push(arr[mid + A_Index])
    left  := MergeSortBy(left, cmp)
    right := MergeSortBy(right, cmp)
    out := [], i := 1, j := 1
    while (i <= left.Length && j <= right.Length) {
        if (cmp(left[i], right[j]) <= 0)
            out.Push(left[i]), i++
        else
            out.Push(right[j]), j++
    }
    while (i <= left.Length)
        out.Push(left[i]), i++
    while (j <= right.Length)
        out.Push(right[j]), j++
    return out
}

ReverseArray(arr) {
    out := []
    i := arr.Length
    while (i >= 1)
        out.Push(arr[i]), i--
    return out
}

BuildFilterList() {
    seenSrc := Map(), seenCtx := Map()
    srcs := [], ctxs := []
    for e in App.entries {
        if (e.kind != "app" && e.src != "" && !seenSrc.Has(e.src)) {
            seenSrc[e.src] := 1
            srcs.Push(e.src)
        }
        if (e.ctx != "" && !seenCtx.Has(e.ctx)) {
            seenCtx[e.ctx] := 1
            ctxs.Push(e.ctx)
        }
    }
    list := [""]
    for s in Cfg.preDefinedFilters
        list.Push(s)
    for s in srcs
        list.Push(s)
    for s in ctxs
        list.Push(s)
    App.filterList := list
    if App.gui {
        cur := App.gui.filter.Text
        App.gui.filter.Delete()
        App.gui.filter.Add(list)
        App.gui.filter.Text := cur
    }
}

; ==============================================================================
; 14.  ICONS  (no separate cache-maker tool needed)
; ==============================================================================
EnsureImageList() {
    if App.il
        return
    App.il := IL_Create(120, 60, false)     ; small (16x16) icons
    App.gui.lv.SetImageList(App.il)
    App.iconAhk := SafeIlAdd(A_AhkPath, 1)
    if !App.iconAhk
        App.iconAhk := SafeIlAdd("imageres.dll", 64)
    App.iconIni := SafeIlAdd("imageres.dll", 68)
    App.iconApp := SafeIlAdd("shell32.dll", 3)
}

SafeIlAdd(path, num) {
    idx := 0
    try idx := IL_Add(App.il, path, num)
    return idx ? idx : 0
}

IconFor(e) {
    EnsureImageList()
    if (e.kind = "ini")
        return App.iconIni

    if (e.kind = "script") {
        if !Cfg.useScriptIcons
            return App.iconAhk
        ; 1. an  icon:  tag on the hotkey's own comment line -- travels with
        ;    the script, so it wins over everything else.
        if (e.hkIconSpec != "") {
            spec := ResolveHotkeyIconSpec(e.hkIconSpec)
            if (spec[1] != "")
                return CachedFileIcon(spec[1], spec[2], App.iconAhk)
        }
        ; 2. the central per-hotkey map, [HotkeyIcons] in HotkeyHub_icons.ini
        hkKey := NormalizeHK(e.hk)
        if (hkKey != "" && App.hotkeyIcons.Has(hkKey)) {
            spec := ResolveHotkeyIconSpec(App.hotkeyIcons[hkKey])
            if (spec[1] != "")
                return CachedFileIcon(spec[1], spec[2], App.iconAhk)
        }
        ; 3. a  ; HotkeyHubIcon:  line anywhere in the file, for the whole file
        if (e.iconPath != "")
            return CachedFileIcon(e.iconPath, e.iconNum, App.iconAhk)
        ; 4. otherwise the central per-file map, [Icons], keyed by file name
        key := StrLower(e.src)
        if App.scriptIcons.Has(key) {
            spec := App.scriptIcons[key]
            return CachedFileIcon(spec[1], spec[2], App.iconAhk)
        }
        ; 5. otherwise the generic AutoHotkey icon
        return App.iconAhk
    }

    return CachedFileIcon(e.iconPath, e.iconNum, App.iconApp)
}

; ------------------------------------------------------------------------------
; The central icon map:  Data\HotkeyHub_icons.ini
;
;     [Icons]
;     AutoCorrect2.ahk = Resources\Icons\Psicon.ico
;     DateTool.ahk     = Resources\Icons\calendar-Blue.ico
;     MCLogger.ahk     = Resources\Icons\JustLog.ico, 1
;
; Keyed by file name, so #Include'd files get their own entry.  Relative paths
; resolve against the AutoCorrect2 root; absolute paths and bare library names
; like shell32.dll work too.  One file to edit rather than fifteen scripts --
; and a  ; HotkeyHubIcon:  line inside a script still overrides its entry here.
;
; "Write icon map template" on the systray menu fills this in with every script
; currently being scanned, commented out and ready to have paths pasted in.
; ------------------------------------------------------------------------------
LoadIconMap() {
    App.scriptIcons := Map()
    App.hotkeyIcons := Map()
    if !FileExist(App.iconMapPath)
        return

    section := ""
    try section := IniRead(App.iconMapPath, "Icons")
    catch as err
        section := ""       ; missing [Icons] section -- [HotkeyIcons] below may still be there
    for pair in StrSplit(section, "`n") {
        pair := Trim(pair)
        if (pair = "" || SubStr(pair, 1, 1) = ";")
            continue
        eqPos := InStr(pair, "=")
        if !eqPos
            continue
        name := Trim(SubStr(pair, 1, eqPos - 1))
        spec := Trim(SubStr(pair, eqPos + 1))
        if (name = "" || spec = "")
            continue
        parsed := ParseIconSpec(spec, App.ac2Root)
        if (parsed[1] != "")
            App.scriptIcons[StrLower(name)] := parsed
    }

    ; [HotkeyIcons] -- same file, keyed by the hotkey itself rather than by
    ; the script file name.  Values are stored raw and resolved lazily by
    ; ResolveHotkeyIconSpec(), since a value naming an App row can't be
    ; resolved until App.appRows is built.
    hkSection := ""
    try hkSection := IniRead(App.iconMapPath, "HotkeyIcons")
    catch as err
        hkSection := ""
    for pair in StrSplit(hkSection, "`n") {
        pair := Trim(pair)
        if (pair = "" || SubStr(pair, 1, 1) = ";")
            continue
        eqPos := InStr(pair, "=")
        if !eqPos
            continue
        name := Trim(SubStr(pair, 1, eqPos - 1))
        spec := Trim(SubStr(pair, eqPos + 1))
        if (name = "" || spec = "")
            continue
        norm := NormalizeHK(name)
        if (norm != "")
            App.hotkeyIcons[norm] := spec
    }
}

; A [HotkeyIcons] value, or an inline  icon:  tag, is resolved two ways:
; if it matches the exe or the display name of one of the App rows, that
; app's own (already-resolved) icon is reused; otherwise it is treated as
; an icon spec exactly like the [Icons] section -- a path, a bare library
; name, optionally ", N".  Returns ["", 1] when spec is empty.
ResolveHotkeyIconSpec(spec) {
    spec := Trim(spec)
    if (spec = "")
        return ["", 1]
    low := StrLower(spec)
    for a in App.appRows {
        if (StrLower(a.src) = low || StrLower(a.action) = low)
            return [a.iconPath, a.iconNum]
    }
    return ParseIconSpec(spec, App.ac2Root)
}

; Turns "Resources\Icons\clock-Blue.ico, 2" into ["<resolved path>", 2].
; A path is resolved against baseDir; a bare name such as shell32.dll is left
; alone so Windows finds it on the system path.
ParseIconSpec(spec, baseDir) {
    num := 1
    spec := Trim(spec)
    if RegExMatch(spec, "^(.+?)\s*,\s*(\d+)$", &sm)
        spec := Trim(sm[1]), num := Integer(sm[2])
    spec := Trim(spec, " `t`"'")
    if (spec = "")
        return ["", 1]
    if (InStr(spec, "\") && !RegExMatch(spec, "^([A-Za-z]:|\\\\)"))
        spec := NormalizePath(baseDir "\" spec)
    return [spec, num]
}

; Writes every scanned script into the map file, commented out, keeping any
; entries already there.  Then opens it so the paths can be filled in.
WriteIconMapTemplate() {
    have := Map()
    if FileExist(App.iconMapPath) {
        section := ""
        try section := IniRead(App.iconMapPath, "Icons")
        for pair in StrSplit(section, "`n") {
            eqPos := InStr(pair, "=")
            if eqPos
                have[StrLower(Trim(SubStr(pair, 1, eqPos - 1)))] := 1
        }
    }

    seen := Map(), missing := []
    for e in App.hotkeyRows {
        if (e.kind != "script" || e.src = "")
            continue
        k := StrLower(e.src)
        if (seen.Has(k) || have.Has(k))
            continue
        seen[k] := 1
        missing.Push(e.src)
    }

    if (missing.Length = 0 && FileExist(App.iconMapPath)) {
        MsgBox("Every scanned script already has an entry in:`n`n" App.iconMapPath
             , App.appName, 4096)
        OpenPathInEditor(App.iconMapPath, 1)
        return
    }

    txt := ""
    if !FileExist(App.iconMapPath) {
        txt := "; " App.appName " icon map"
             . "`n; One entry per script file name.  Relative paths resolve against"
             . "`n;   " App.ac2Root
             . "`n; A trailing , N picks an icon number out of a .dll or .exe."
             . "`n; Uncomment a line and set its path.  Press F5 in " App.appName " after."
             . "`n`n[Icons]`n"
    }
    for name in missing
        txt .= ";" name "=Resources\Icons\.ico`n"

    try {
        FileAppend(txt, App.iconMapPath, "UTF-8")
    } catch as err {
        MsgBox("Could not write:`n`n" App.iconMapPath "`n`n" err.Message, App.appName, 4096)
        return
    }
    OpenPathInEditor(App.iconMapPath, 1)
}

CachedFileIcon(path, num, fallback) {
    key := path "|" num
    if App.iconMap.Has(key)
        return App.iconMap[key]
    if (App.iconBudget <= 0)              ; keep the refresh snappy
        return fallback
    App.iconBudget--
    idx := SafeIlAdd(path, num)
    App.iconMap[key] := idx ? idx : fallback
    return App.iconMap[key]
}


; Walk every app row in the background so icons are ready before they're needed.
StartIconPrewarm() {
    EnsureImageList()
    App.iconQueue := []
    App.iconPos := 1
    seen := Map()
    for e in App.entries {
        if (e.kind != "app")
            continue
        key := e.iconPath "|" e.iconNum
        if (App.iconMap.Has(key) || seen.Has(key))
            continue
        seen[key] := 1
        App.iconQueue.Push(e)
    }
    if (App.iconQueue.Length = 0)
        return
    SetTimer(IconPrewarmTick, 40)
}

IconPrewarmTick() {
    n := 0
    while (App.iconPos <= App.iconQueue.Length && n < Cfg.iconChunk) {
        e := App.iconQueue[App.iconPos]
        App.iconPos++, n++
        key := e.iconPath "|" e.iconNum
        if App.iconMap.Has(key)
            continue
        idx := SafeIlAdd(e.iconPath, e.iconNum)
        App.iconMap[key] := idx ? idx : App.iconApp
    }
    if (App.iconPos > App.iconQueue.Length) {
        SetTimer(IconPrewarmTick, 0)
        UpdateList()                       ; repaint with the real icons
    }
}

; ==============================================================================
; 15.  STATUS BAR
; ==============================================================================
SetStatus(extra) {
    if (!App.gui || !App.ready)
        return
    txt := "  Showing " App.shown " of " App.total
    need := "", ban := ""
    for i, sym in App.modSyms {
        v := App.modOn[sym]
        if (v = App.modNeed)
            need .= (need = "" ? "" : "+") App.modNames[i]
        else if (v = App.modBan)
            ban .= (ban = "" ? "" : "+") App.modNames[i]
    }
    if (need != "" || ban != "") {
        txt .= "   |   "
             . (need != "" ? need : "any")
             . (ban != "" ? ", no " ban : "")
    }
    if (App.conflicts > 0)
        txt .= "   |   " App.conflicts " conflict" (App.conflicts = 1 ? "" : "s")
    if Cfg.showHidden
        txt .= "   |   incl. hidden"
    if (extra != "")
        txt .= "   |   " extra
    try App.gui.sb.SetText(txt)
}

OnItemSelect() {
    e := FocusedEntry()
    if !e
        return
    detail := ""
    switch e.kind {
        case "app":    detail := e.path
        case "ini":    detail := "Defined in acSettings.ini"
        case "script": detail := e.src " line " e.line
                     . (e.commented ? "  (commented out)" : "")
    }
    if e.conflict
        detail .= "   ||   ALSO DEFINED IN: " e.dupWith
    SetStatus(detail)
}

; ==============================================================================
; 16.  ACTIVATION  (send a hotkey, or run an app)
; ==============================================================================
FocusedEntry() {
    g := App.gui
    if !g
        return 0
    row := g.lv.GetNext(0, "F")
    if (row <= 0)
        row := g.lv.GetNext(0)
    if (row <= 0)
        return 0
    idx := g.lv.GetText(row, 6)
    if (idx = "" || !IsInteger(idx))
        return 0
    idx := Integer(idx)
    if (idx < 1 || idx > App.entries.Length)
        return 0
    return App.entries[idx]
}

ActivateFocusedRow() {
    e := FocusedEntry()
    if !e
        return
    Activate(e)
}

Activate(e) {
    HideHub()
    BumpUsage(e)

    if (e.kind = "app") {
        if !FileExist(e.path) {
            MsgBox("That file no longer exists:`n`n" e.path, App.appName, 4096)
            return
        }
        cmd := (e.args != "") ? '"' e.path '" ' e.args : e.path
        try Run(cmd, e.dir != "" ? e.dir : "")
        catch as err
            MsgBox("Could not run:`n`n" e.path "`n`n" err.Message, App.appName, 4096)
        return
    }

    keys := SendableHotkey(e.hk)
    if (keys = "") {
        MsgBox("This one can't be sent as keystrokes:`n`n" e.hk, App.appName, 4096)
        return
    }
    if (App.prevWin && WinExist("ahk_id " App.prevWin)) {
        if WinWaitActive("ahk_id " App.prevWin, , Cfg.focusWaitSecs)
            SendInput(keys)
        else
            MsgBox("The target window never came back to the front, so nothing was sent.`n`n"
                 . App.prevTitle, App.appName, 4096)
    } else
        SendInput(keys)
}

; Turn a hotkey definition into something SendInput can actually use.
; Strips the hook prefixes ~ * $ < > and braces multi-character key names,
; so F5, Space, and NumpadAdd all send correctly.
SendableHotkey(hk) {
    s := Trim(LTrim(hk, "; `t"))
    s := RegExReplace(s, "[~*$<>]", "")
    if InStr(s, "&")                       ; "a & b" combos can't be replayed
        return ""
    ; Strip leading modifier symbols, but never the last character -- "+::" is a
    ; hotkey on the Shift key itself, not a modifier with nothing after it.
    mods := ""
    while (StrLen(s) > 1 && SubStr(s, 1, 1) ~= "[#!^+]") {
        mods .= SubStr(s, 1, 1)
        s := SubStr(s, 2)
    }
    key := Trim(s)
    if (key = "")
        return ""
    if (StrLen(key) > 1 || InStr("{}^!+#", key))
        key := "{" key "}"
    return mods key
}

BumpUsage(e) {
    if !Cfg.trackUsage
        return
    e.used := e.used + 1
    k := UsageKey(e)
    App.usage[k] := e.used
    try IniWrite(e.used, App.usagePath, "Usage", k)
}

UsageKey(e) {
    k := e.kind "_" e.src "_" (e.kind = "app" ? e.action : e.hk)
    k := RegExReplace(k, "[^\w]", "_")
    return SubStr(k, 1, 60)
}

; ==============================================================================
; 17.  KEYBOARD HELPERS
; ==============================================================================
; Enter activates the focused row -- unless the filter's drop-down is open, in
; which case Enter belongs to the drop-down for choosing an item.
OnEnter() {
    g := App.gui
    if !g
        return
    if ComboIsOpen(g.filter) {
        Send("{Enter}")
        return
    }
    ActivateFocusedRow()
}

OnArrow(dir) {
    g := App.gui
    if !g
        return
    hFocus := 0
    try hFocus := g.FocusedCtrl.Hwnd        ; compare HWNDs, not objects
    if (hFocus = g.filter.Hwnd && !ComboIsOpen(g.filter)) {
        ; In the filter box with the drop-down closed: Down enters the list.
        if (dir = "Down") {
            g.lv.Focus()
            if (g.lv.GetCount() > 0 && g.lv.GetNext(0, "F") <= 0)
                g.lv.Modify(1, "Select Focus")
            return
        }
    }
    else if (hFocus = g.lv.Hwnd && dir = "Up" && g.lv.GetNext(0, "F") = 1) {
        ; At the top of the list: Up goes back to the filter box.
        g.filter.Focus()
        return
    }
    Send("{" dir "}")      ; otherwise let the focused control have it
}

; True while the filter ComboBox's drop-down list is showing, so the arrow keys
; are left alone for picking an item out of it.
ComboIsOpen(ctrl) {
    static CB_GETDROPPEDSTATE := 0x0157
    return DllCall("user32\SendMessageW", "Ptr", ctrl.Hwnd
                 , "UInt", CB_GETDROPPEDSTATE, "Ptr", 0, "Ptr", 0) ? true : false
}

; ==============================================================================
; 18.  CONTEXT MENU
; ==============================================================================
OnListContext(lv, item, isRight, x, y) {
    if (item > 0)
        lv.Modify(item, "Select Focus")
    e := FocusedEntry()
    if !e
        return
    m := Menu()
    m.Add(e.kind = "app" ? "Run" : "Send hotkey", (*) => Activate(e))
    m.Add()
    if (e.kind != "app")
        m.Add("Copy hotkey", (*) => A_Clipboard := e.hk)
    m.Add("Copy row", (*) => CopyRow(e))
    m.Add()
    if (e.kind = "script" && e.line > 0)
        m.Add("Open source at line " e.line, (*) => OpenPathInEditor(e.path, e.line))
    else if (e.kind = "ini")
        m.Add("Open acSettings.ini", (*) => OpenPathInEditor(e.path, 1))
    m.Add("Open file location", (*) => OpenLocation(e))
    m.Show()
}

CopyRow(e) {
    A_Clipboard := DisplayHotkey(e) "`t" e.action "`t" e.ctx "`t" e.src
}

OpenPathInEditor(path, line) {
    if !FileExist(path) {
        MsgBox("File not found:`n`n" path, App.appName, 4096)
        return
    }
    cmd := StrReplace(StrReplace(Cfg.editorCmd, "{file}", path), "{line}", line)
    try {
        Run(cmd)
        return
    } catch as err {
        try Run('notepad.exe "' path '"')
        catch as err2
            MsgBox("Could not open:`n`n" path, App.appName, 4096)
    }
}

OpenLocation(e) {
    target := e.path
    if !FileExist(target) {
        MsgBox("File not found:`n`n" target, App.appName, 4096)
        return
    }
    try Run('explorer.exe /select,"' target '"')
    catch as err
        MsgBox("Could not open the folder for:`n`n" target, App.appName, 4096)
}

; ==============================================================================
; 19.  EXPORT
; ==============================================================================
ShowExportMenu() {
    m := Menu()
    m.Add("HTML cheatsheet  (opens in browser)", (*) => ExportHtml())
    m.Add("Markdown file", (*) => ExportText("md"))
    m.Add("CSV file", (*) => ExportText("csv"))
    m.Add()
    m.Add("Copy visible rows to clipboard", (*) => CopyVisible())
    m.Show()
}

; Everything currently passing the gates and the filter, in display order.
VisibleEntries() {
    out := []
    filter := App.gui ? App.gui.filter.Text : ""
    for e in App.view {
        if (PassesGates(e) && MatchFilter(e, filter))
            out.Push(e)
    }
    return out
}

CopyVisible() {
    rows := VisibleEntries()
    txt := "Hotkey`tAction`tContext`tSource`n"
    for e in rows
        txt .= DisplayHotkey(e) "`t" e.action "`t" e.ctx "`t" e.src "`n"
    A_Clipboard := txt
    ToolTip("Copied " rows.Length " rows.")
    SetTimer(() => ToolTip(), -1500)
}

ExportText(kind) {
    rows := VisibleEntries()
    txt := ""
    if (kind = "md") {
        txt := "# " Cfg.guiTitle "`n`n"
             . "_" rows.Length " hotkeys -- generated " FormatTime(, "yyyy-MM-dd HH:mm") "_`n`n"
             . "| Hotkey | Action | Context | Source |`n|---|---|---|---|`n"
        for e in rows
            txt .= "| " MdCell(DisplayHotkey(e)) " | " MdCell(e.action)
                 . " | " MdCell(e.ctx) " | " MdCell(e.src) " |`n"
    } else {
        txt := "Hotkey,Action,Context,Source,Kind,Used`n"
        for e in rows
            txt .= CsvCell(DisplayHotkey(e)) "," CsvCell(e.action) "," CsvCell(e.ctx)
                 . "," CsvCell(e.src) "," CsvCell(e.kind) "," e.used "`n"
    }
    path := App.exportDir "\" App.appName "_export." kind
    try {
        if FileExist(path)
            FileDelete(path)
        FileAppend(txt, path, "UTF-8")
    } catch as err {
        MsgBox("Could not write:`n`n" path "`n`n" err.Message, App.appName, 4096)
        return
    }
    try Run('explorer.exe /select,"' path '"')
    catch as err
        MsgBox("Saved to:`n`n" path, App.appName, 4096)
}

MdCell(s) {
    return StrReplace(StrReplace(s, "|", "\|"), "`n", " ")
}

CsvCell(s) {
    s := StrReplace(s, '"', '""')
    return '"' StrReplace(StrReplace(s, "`n", " "), "`r", "") '"'
}

ExportHtml() {
    rows := VisibleEntries()
    filter := App.gui ? Trim(App.gui.filter.Text) : ""

    body := ""
    count := 0
    for e in rows {
        cls := (Mod(count, 2) = 0) ? "even" : "odd"
        if e.conflict
            cls .= " dup"
        body .= "      <tr class='" cls "'><td>" HtmlEsc(DisplayHotkey(e)) "</td>"
              . "<td>" HtmlEsc(e.action) "</td>"
              . "<td>" HtmlEsc(e.ctx) "</td>"
              . "<td>" HtmlEsc(e.src) "</td>"
              . "<td class='kind'>" HtmlEsc(e.kind) "</td></tr>`n"
        count++
    }

    filterNote := (filter != "") ? " &mdash; filtered by: <em>" HtmlEsc(filter) "</em>" : ""
    notes := count " rows"
    if (App.conflicts > 0)
        notes .= " &nbsp;|&nbsp; " App.conflicts " conflicting hotkeys (shaded)"
    if Cfg.showHidden
        notes .= " &nbsp;|&nbsp; including hidden"

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
  tr.dup  td { background: #fff3cd; }
  tr:hover td { background: #dff0ff; }
  td:first-child { white-space: nowrap; font-weight: 600; color: #003E67; }
  td.kind { color: #888; font-size: 11px; text-transform: uppercase; }
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
  <div class='meta'>{{NOTES}} &nbsp;|&nbsp; Generated: {{DATE}}</div>
  <table>
    <thead>
      <tr><th>Hotkey</th><th>Action</th><th>Context (#HotIf)</th><th>Source</th><th>Type</th></tr>
    </thead>
    <tbody>
{{ROWS}}    </tbody>
  </table>
  <div class='footer no-print'>Print this page (Ctrl+P) to save as PDF or send to printer.</div>
</body>
</html>
)"
    html := StrReplace(html, "{{TITLE}}",       Cfg.guiTitle)
    html := StrReplace(html, "{{FILTER_NOTE}}", filterNote)
    html := StrReplace(html, "{{NOTES}}",       notes)
    html := StrReplace(html, "{{DATE}}",        FormatTime(, "yyyy-MM-dd HH:mm"))
    html := StrReplace(html, "{{ROWS}}",        body)

    path := A_Temp "\" App.appName "_Export.html"
    try {
        if FileExist(path)
            FileDelete(path)
        FileAppend(html, path, "UTF-8")
        Run(path)
    } catch as err {
        MsgBox("Export failed: " err.Message "`n`nPath: " path, App.appName, 4096)
    }
}

HtmlEsc(s) {
    s := StrReplace(s, "&", "&amp;")
    s := StrReplace(s, "<", "&lt;")
    return StrReplace(s, ">", "&gt;")
}

; ==============================================================================
; 20.  OPTIONS / SETTINGS PERSISTENCE
; ==============================================================================
; Cfg property name  ->  the key name written into acSettings.ini [HotkeyHub].
; Keep these in step with the entries in acSettingsMetadata.json.
SettingKey(name) {
    static keys := Map("showHidden",    "ShowHidden"
                     , "showApps",      "ShowApps"
                     , "scanAll",       "ScanAll"
                     , "friendlyNames", "FriendlyNames")
    return keys.Has(name) ? keys[name] : name
}

ToggleOption(name, value) {
    Cfg.%name% := value
    SaveSetting(SettingKey(name), value)
    UpdateList()
}

ToggleScanAll(value) {
    Cfg.scanAll := value
    SaveSetting("ScanAll", value)
    RescanAll()
}

SaveSetting(key, value) {
    try IniWrite(value, App.settingsPath, App.settingsSect, key)
    catch as err
        LogIssue("Could not save " key ": " err.Message)
}

; Read an integer from [HotkeyHub], tolerating a missing key or junk value.
GetSetting(key, default) {
    v := default
    try v := IniRead(App.settingsPath, App.settingsSect, key, default)
    catch as err
        return default
    return IsInteger(v) ? Integer(v) : default
}

LoadSettings() {
    App.savedX := 0, App.savedY := 0, App.savedW := 0, App.savedH := 0
    App.shown := 0, App.total := 0
    if !FileExist(App.settingsPath)
        return
    Cfg.showHidden    := GetSetting("ShowHidden",    Cfg.showHidden)
    Cfg.showApps      := GetSetting("ShowApps",      Cfg.showApps)
    Cfg.scanAll       := GetSetting("ScanAll",       Cfg.scanAll)
    Cfg.friendlyNames := GetSetting("FriendlyNames", Cfg.friendlyNames)
    App.sortCol       := GetSetting("SortCol",  0)
    App.sortDesc      := GetSetting("SortDesc", 0)
    App.savedX        := GetSetting("WinX", 0)
    App.savedY        := GetSetting("WinY", 0)
    App.savedW        := GetSetting("WinW", 0)
    App.savedH        := GetSetting("WinH", 0)
}

LoadUsage() {
    App.usage := Map()
    if !FileExist(App.usagePath)
        return
    section := ""
    try section := IniRead(App.usagePath, "Usage")
    catch as err
        return
    for pair in StrSplit(section, "`n") {
        eqPos := InStr(pair, "=")
        if !eqPos
            continue
        k := Trim(SubStr(pair, 1, eqPos - 1))
        v := Trim(SubStr(pair, eqPos + 1))
        if (k != "" && IsInteger(v))
            App.usage[k] := Integer(v)
    }
}

; ==============================================================================
; 21.  MISC HELPERS
; ==============================================================================
MapKeys(m) {
    out := []
    for k, v in m
        out.Push(k)
    return out
}

; Shows HotkeyHubHelpText in a minimal scrollable window.
; Reachable from the systray menu, or F1 while the Hotkey Hub window is focused.
ShowHubHelp(*) {
    static helpWin := ""
    if IsObject(helpWin) {
        try {                       ; bring the existing window forward
            helpWin.Show()
            return
        } catch as err {
            helpWin := ""           ; it was closed; fall through and rebuild
        }
    }
    helpWin := Gui("+Resize +MinSize480x320", App.appName " -- Help / About")
    helpWin.BackColor := Theme.form
    helpWin.SetFont("s" Cfg.helpFontSize " " Theme.fontOpt, Cfg.helpFontName)

    ; Monospace and a fixed width matter here: the help text lays a few things
    ; out in columns that only line up in a fixed-pitch font.
    ed := helpWin.Add("Edit", "x8 y8 w" Cfg.helpWidth " h" Cfg.helpHeight
                            . " +ReadOnly +Multi +VScroll -E0x200 Background" Theme.list
                    , HotkeyHubHelpText)
    ed.SetFont("s" Cfg.helpFontSize " " Theme.fontOpt, Cfg.helpFontName)

    closeBtn := helpWin.Add("Button", "x8 y+8 w90", "Close")
    closeBtn.OnEvent("Click", (*) => helpWin.Destroy())
    helpWin.OnEvent("Escape", (*) => helpWin.Destroy())
    helpWin.OnEvent("Close",  (*) => helpWin.Destroy())
    helpWin.OnEvent("Size", OnHelpSize.Bind(ed, closeBtn))
    helpWin.Show()
    closeBtn.Focus()                ; so the caret isn't blinking in the text
}

OnHelpSize(ed, closeBtn, g, MinMax, W, H) {
    if (MinMax = -1)
        return
    btnH := 34
    ed.Move(, , W - 16, H - 16 - btnH)
    closeBtn.GetPos(, , &bw, &bh)
    closeBtn.Move(8, H - bh - 8)
}

; Non-fatal problems (a settings write that didn't take, say).  Surfaced in the
; status bar rather than a MsgBox, so nothing interrupts a lookup.
LogIssue(msg) {
    if (App.ready && App.gui)
        SetStatus("!! " msg)
}

; Walk up from this script looking for an AutoCorrect2\Data\acSettings.ini.
FindAC2Root() {
    dir := A_ScriptDir
    Loop 5 {
        if FileExist(dir "\Data\acSettings.ini")
            return dir
        if FileExist(dir "\AutoCorrect2\Data\acSettings.ini")
            return dir "\AutoCorrect2"
        pos := InStr(dir, "\", , -1)
        if (pos < 3)
            break
        parent := SubStr(dir, 1, pos - 1)
        if (parent = "" || parent = dir)
            break
        dir := parent
    }
    return A_ScriptDir
}

ToggleStartup() {
    lnk := A_Startup "\" App.appName ".lnk"
    if FileExist(lnk) {
        try FileDelete(lnk)
        A_TrayMenu.Uncheck("Start with Windows")
        MsgBox(App.appName " will no longer start with Windows.", App.appName, 4096)
        return
    }
    exe := A_ScriptDir "\" App.appName ".exe"     ; portable pair, if there is one
    target := FileExist(exe) ? exe : A_AhkPath
    args   := FileExist(exe) ? "" : '"' A_ScriptFullPath '"'
    try {
        FileCreateShortcut(target, lnk, A_ScriptDir, args, App.appName, iconA, "", iconB)
        A_TrayMenu.Check("Start with Windows")
        MsgBox(App.appName " will start with Windows.", App.appName, 4096)
    } catch as err {
        MsgBox("Could not create the startup shortcut.`n`n" err.Message, App.appName, 4096)
    }
}
