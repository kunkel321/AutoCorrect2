#Requires AutoHotkey v2.0
#SingleInstance Force
; ============================================================================
; SettingsDashboard -- a friendlier companion to Tools\SettingsManager.ahk.  Lives in Tools\.
; Based on VitaKaninen's "SettingsManager-Mockup v2.ahk" (Nov 2026), reworked by Steve + Claude.
;
; Reads  ..\Data\acSettings.ini          your values
;        ..\Data\acSettings.default.ini  the shipped defaults (reset arrows, "Changed from default")
;        ..\Data\acSettingsMetadata.json the Settings Manager's labels and help (the (i) buttons,
;                                        the "More settings" section, and what to restart)
;        ..\Data\colorThemeSettings.ini  colors
; Writes  ..\Data\acSettings.ini, on Apply / OK: only the keys you changed, one IniWrite each (so
;         comments, key order and everything else stay as they are).  Before the first save of a
;         session it copies the ini to ..\Debug\Backups\.  Then it offers to restart the programs
;         that read the changed keys (the json's "restart" field), but only ones already running.
;
;   Run:   AutoHotkey64.exe SettingsDashboard.ahk  [/list] [/light | /dark] [/noini]
;   Test:  hold Ctrl while starting it (or add /test after the script path).  It builds the
;          window without showing it, checks every row's geometry, exercises each control type,
;          and writes a report with ini coverage to ..\Debug\SettingsDashboard_test.txt, then
;          opens that file.
;
; How the two tools split the work:
;   Settings Manager  = the "back end": every ini key, by [Section] and Key name, as stored.
;   Settings Dashboard = the "front end": the same keys grouped by task, in plain words,
;                        with every description visible and real controls.
;   Each dashboard row shows its [Section] Key (turn off with /noini or the checkbox), so
;   nothing is hidden from people who want to learn the ini.  The (i) at the right of a row
;   shows the Settings Manager's full help for that key.
;
; Keeping up with new ini keys:  any key in acSettings.ini that DefineSettings() doesn't place
; shows up by itself under "More settings", typed and described from acSettingsMetadata.json.
; So a new key never goes missing -- it just lands in "More" until it gets a proper home.
; Keys that a tool saves from its own window (TOOL_OWNED below) are deliberately left out.
;
; Layout notes (from mockup 2): every row lives in ONE scrolling child window (P).  A view
; (a section, Essentials, the whole list, Changed from default, a search) is only a filter:
; Reflow() hides the rows that don't match and moves the rest up.  BuildGui records each
; control's offset inside its row (r.pos) and Reflow() moves by those, so scrolling can't
; make them drift.  Never name a local variable like a function here (Ctl, Add, ...).
; Column budget inside the panel:  controls CX..RX-44,  (i) at RX-42,  reset arrow at RX-20.
; ============================================================================

global VERSION := "1.2  (11-26-2026)"    ; bump with every change, so a screenshot shows which build it is
global TEST := false, MODE := "paged", SHOWINI := true

; ── DPI awareness (same as ScreenSnip) ────────────────────────────────────────
; By default AutoHotkey's windows are system-DPI-aware.  Moved to a monitor with a different
; scale, Windows shrank the window's frame but not the controls inside it, so the right edge
; was cut off.  Per-monitor (v1) windows are never resized by Windows on a DPI change, so the
; window keeps its pixel size there (it looks bigger on a lower-scaled monitor, but complete).
; Must run before any Gui is created: a window keeps the awareness it was created with.
try DllCall("SetThreadDpiAwarenessContext", "Ptr", -3, "Ptr")     ; -3 = PER_MONITOR_AWARE
for a in A_Args {
    if a = "/test"
        TEST := true
    if a = "/list"
        MODE := "list"
    if a = "/noini"
        SHOWINI := false
}
if GetKeyState("Ctrl")                  ; Ctrl held while launching = self-test
    TEST := true
global TestFile := A_ScriptDir "\..\Debug\SettingsDashboard_test.txt"
if TEST
    OnError((e, *) => (TestOut("ERROR: " e.Message " (line " e.Line ")`n" e.Stack "`n"), ExitApp(1)))

global IniPath  := A_ScriptDir "\..\Data\acSettings.ini"
global DefPath  := A_ScriptDir "\..\Data\acSettings.default.ini"
global MetaPath := A_ScriptDir "\..\Data\acSettingsMetadata.json"
global SMPath   := A_ScriptDir "\..\Tools\SettingsManager"          ; .exe (portable pair) or .ahk
; Keys a tool writes back from its own window (window size, last-used checkboxes...).  Changing
; them here would only be overwritten, so they are not shown -- the Settings Manager still has them.
global TOOL_OWNED := ["^HotkeyHub\.", "^BulkFunctionizer\.", "^HotstringAuditor\.", "^ConflictingStringLocator\.(?!EditorCmd$)"]
global THEME := LoadTheme()
global META := LoadMeta()
global DPI := A_ScreenDPI / 96
global ROWS := [], ALL := [], BYKEY := Map(), SECS := [], SECMAP := Map(), SLIDERS := Map(), MOREKEYS := []
global CURSEC := "", CURGRP := 0, CURGRPTITLE := ""
global G, P, NavLB, SearchEd, TitleTxt, DescTxt, StatusTxt, LogPrev := 0, AcPrev := 0
global VIEW := "", QUERY := "", SHOWN := 0, SCROLLY := 0, VIRTH := 0
global IniTime := FileExist(IniPath) ? FileGetTime(IniPath, "M") : "", BackedUp := false
global WinOuterW := 0, WinOuterH := 0          ; outer size once shown (see KeepSize)
global WINW := 960, WINH := 650                         ; the main window's client size
global PX := 245, PY := 76, PW := 705, PH := 522        ; the scrolling panel, in the main window (PW includes its scroll bar)
global X0 := 10, CX := 400, RX := 680                   ; columns inside the panel: labels, controls, right edge
global SOUNDS := ["HotstringHelper.BeepOnStartup", "ACSystem.BeepOnCorrection", "ACSystem.BeepOnCapFix"
    , "HotstringHelper.BeepOnAppend", "HotstringHelper.BeepOnFunctionCheck", "ACSystem.BeepOnContextLog", "MCLogger.BeepEachHotString"]

DefineSettings()
AddLeftovers()
BuildGui()
if TEST {
    RunSelfTest()
    ExitApp(0)
}
if MODE = "list"
    NavLB.Choose(2)
GoNav()
G.Show("w" WINW " h" WINH)
RememberSize()

; ============================================================================
; SETTINGS.  DefSec starts a section, DefGrp a titled group in it, Add a setting.
; Types:  toggle slider number ddl combo seg hotkey text file color
;         list (comma list)  words (checkbox grid)  flags (hotstring options)  bppreview
;         cbtn (Control Panel button: a line of the table row)   hidden (written, no control)
; Extra props: min max step unit fmt opts dep(parent key) restart w
;              ess (also shown under Essentials)   link (key a flags row's X box also sets)
;              onset (function called after the value changes)
; The 'def' passed to Add is only a fallback: the real default comes from acSettings.default.ini.
; 'restart' is only needed for keys the metadata json doesn't cover (it names what to restart).
; ============================================================================
DefineSettings() {
    ; ---------------------------------------------------------------- Corrections
    DefSec("corr", "Corrections", "How AutoCorrect behaves while you type.")
    DefGrp("Where it is switched off", "AutoCorrect stays silent in these programs and windows: games, terminals, code editors.  (To pause it everywhere, untick 'Enable AutoCorrections' in the tray menu.)")
    Add("list", "ACSystem.AppSkiplist", "Programs where AutoCorrect stays off", "Matched by the program's file name.", "", {pick: "exe", ess: 1})
    Add("list", "ACSystem.WinSkiplist", "Windows where it stays off", "Matched by any part of the window title.", "Hotstring Quick Lookup,Hotstring Helper", {pick: "title"})
    DefGrp("Backspacing an autocorrection", "When you backspace a word AutoCorrect just changed, AutoCorrect2 takes it as a sign that the hotstring was wrong.")
    Add("slider", "ACSystem.BackspaceWindow", "Count it as a mistake if I backspace within", "The autocorrection is marked as backspaced in the AutoCorrect log.  Fast typists may want this shorter.", 500, {min: 100, max: 3000, step: 100, fmt: "sec"})
    Add("toggle", "ACSystem.SuppressAfterBackspace", "Then pause that hotstring so I can retype the word", "The same hotstring won't fire again straight away.", 1, {ess: 1})
    Add("slider", "ACSystem.SuppressSeconds", "Pause it for", "", 8, {min: 1, max: 60, step: 1, unit: "seconds", dep: "ACSystem.SuppressAfterBackspace"})
    DefGrp("Double capitals", "Fixes words typed with Shift held too long: THe -> The.")
    Add("slider", "ACSystem.CapFixTimeoutMs", "Wait this long for the third letter", "If you let go of Shift slowly, raise this.", 500, {min: 100, max: 3000, step: 100, fmt: "sec"})
    Add("toggle", "ACSystem.CapFixTwoLetterWords", "Also fix two-letter words", "TO -> To, MY -> My.  Can be annoying if you type acronyms like IT.", 1)
    Add("words", "ACSystem.CapFixTwoLetterList", "Two-letter words to fix", "", "OF,TO,IN,IT,IS,AS,AT,WE,HE,BY,ON,BE,NO,MY,DO,GO,UP,IF,AN", {dep: "ACSystem.CapFixTwoLetterWords"})
    DefGrp("Extra hotstring sets")
    Add("toggle", "HotstringHelper.EnableDiacriticHotstrings", "Add accents to borrowed words", "cafe -> café,  naive -> naïve,  Bjorn -> Bjørn.  (Includes\DiacriticHotstrings.ahk)", 1, {ess: 1, restart: "AutoCorrect2.exe"})

    ; ---------------------------------------------------------------- Sounds
    DefSec("sound", "Sounds", "Every beep in the suite, in one place.  (In the ini these sit in three different sections.)")
    PushRow({kind: "extra", x: "soundbtns"})
    Add("toggle", "ACSystem.BeepOnCorrection", "Beep on every autocorrection", "", 1, {ess: 1})
    Add("toggle", "ACSystem.BeepOnCapFix", "Beep when a double capital is fixed", "e.g. THe -> The", 1)
    Add("toggle", "HotstringHelper.BeepOnStartup", "Beep when AutoCorrect2 starts or reloads", "Confirms the script restarted.", 1)
    Add("toggle", "HotstringHelper.BeepOnAppend", "Beep when a hotstring I just added is ready to use", "", 1)
    Add("toggle", "HotstringHelper.BeepOnFunctionCheck", "Beep when Hotstring Helper's 'Function' box is ticked", "", 1)
    Add("toggle", "ACSystem.BeepOnContextLog", "Beep when a backspaced autocorrection's context is logged", "Needs the AutoCorrect log turned on (Logging section).", 0, {dep: "ACSystem.EnableLogging"})
    Add("toggle", "MCLogger.BeepEachHotString", "Manual Correction Logger: beep when it catches a manual correction", "", 1)

    ; ---------------------------------------------------------------- Logging
    DefSec("log", "Logging", "AutoCorrect2 can log every autocorrection it makes, in the AutoCorrect log.  The AutoCorrect Log Analyzer uses that log to find hotstrings that misfire, so the more you log, the better it can tune your library.  (The Manual Correction Logger keeps a separate log: see Tools.)")
    Add("toggle", "ACSystem.EnableLogging", "Keep an AutoCorrect log", "Master switch: everything else in this section needs it on.  Off also hides the AutoCorrect log buttons in the Control Panel.", 1, {ess: 1})
    DefGrp("What goes in the AutoCorrect log")
    Add("toggle", "ACSystem.LogRuleLocation", "Which library and line the hotstring is on", "BP:311 = line 311 of your personal library, AC:4146 = the autocorrect library.", 1, {dep: "ACSystem.EnableLogging"})
    Add("toggle", "ACSystem.LogExtendedDetail", "The time and the word that changed", "", 1, {dep: "ACSystem.EnableLogging"})
    Add("toggle", "ACSystem.LogActiveExe", "The program it happened in", "Handy for finding a game's real name for the skip list.", 1, {dep: "ACSystem.EnableLogging"})
    PushRow({kind: "extra", x: "logpreview"})
    Add("toggle", "ACSystem.LogCapFixes", "Log double-capital fixes in the AutoCorrect log too", "", 1, {dep: "ACSystem.EnableLogging"})
    DefGrp("Backspace context", "When you backspace an autocorrection, the words around it are saved (in the Backspace context log) so you can see what you were typing.")
    Add("number", "ACSystem.PrecedingWordCount", "Words to keep from before the autocorrection", "", 8, {min: 0, max: 20, unit: "words", dep: "ACSystem.EnableLogging"})
    Add("number", "ACSystem.FollowingWordCount", "Words to wait for after it", "", 6, {min: 0, max: 20, unit: "words", dep: "ACSystem.EnableLogging"})
    Add("number", "ACSystem.FollowingWordTimeout", "Stop waiting after", "", 12, {min: 1, max: 60, unit: "seconds", dep: "ACSystem.EnableLogging"})

    ; ---------------------------------------------------------------- Adding hotstring rules
    DefSec("hh", "Adding hotstring rules", "Hotstring Helper (HH) is the window that adds new hotstrings to your libraries.  Open it with Win+H, or select a word or some text first to fill it in.  HH guesses from the selection whether you are making an autocorrect hotstring (one word) or a boilerplate (longer text), and starts the form with the settings below.")
    DefGrp("New AutoCorrect hotstring rules")
    Add("flags", "HotstringHelper.DefaultAutoCorrectOpts", "Starting options", "", "B0X*", {link: "HotstringHelper.MakeAcFuncByDefault"})
    Add("hidden", "HotstringHelper.MakeAcFuncByDefault", "", "", 1)
    Add("toggle", "HotstringHelper.AcLogByDefault", "Log  -- write each use to the AutoCorrect log", "f()'s second parameter.  Leave on: the Log Analyzer can only judge hotstrings that are logged.", 1, {dep: "HotstringHelper.MakeAcFuncByDefault"})
    Add("toggle", "HotstringHelper.AcPasteByDefault", "Paste  -- send the replacement by clipboard paste", "f()'s third parameter.  Normally off: for short words, typing is quicker.", 0, {dep: "HotstringHelper.MakeAcFuncByDefault"})
    Add("toggle", "HotstringHelper.AutoCommentWithFreqAndStats", "Add a 'Web Freq | Fixes X words' comment", "How common the fixed words are on the web, and how many words the hotstring fixes.  Only on f() hotstrings.  Used by the Hotstring Stats report (Ctrl+F3).", 1)
    PushRow({kind: "extra", x: "acpreview"})
    Add("toggle", "HotstringHelper.AutoEnterNewEntry", "Type the fixed word into my document after adding", "", 1)
    Add("toggle", "HotstringHelper.SpellCheckReplacement", "Spell-check the Replacement box", "Misspellings turn red; right-click for suggestions.", 1)
    DefGrp("New boilerplate hotstring rules", "Boilerplates expand a short trigger into longer text: addresses, signatures, stock paragraphs.")
    Add("toggle", "HotstringHelper.SeparateLibForBoilerplates", "Keep boilerplates in my personal library", "Adds AC / BP choices to Hotstring Helper.  BP hotstrings go to PersonalHotstrings.ahk.", 1)
    Add("flags", "HotstringHelper.DefaultBoilerPlateOpts", "Starting options", "", "B0X", {link: "HotstringHelper.MakeBpFuncByDefault"})
    Add("hidden", "HotstringHelper.MakeBpFuncByDefault", "", "", 1)
    Add("toggle", "HotstringHelper.BpLogByDefault", "Log  -- write each use to the AutoCorrect log", "f()'s second parameter.  Usually off: boilerplates are used on purpose, so there's nothing to tune.", 0, {dep: "HotstringHelper.MakeBpFuncByDefault"})
    Add("toggle", "HotstringHelper.BpPasteByDefault", "Paste  -- send the replacement by clipboard paste", "f()'s third parameter.  Faster and more reliable for long or multi-line text.", 0, {dep: "HotstringHelper.MakeBpFuncByDefault"})
    Add("text", "HotstringHelper.BoilerplatePrefix", "Start the suggested trigger with", "A prefix keeps boilerplates from firing by accident.", ";", {w: 60})
    Add("text", "HotstringHelper.BoilerplateSuffix", "End it with", "", "", {w: 60})
    Add("number", "HotstringHelper.FirstLettersToInclude", "Suggested trigger: at most this many letters", "The first letter of each word, up to this many.  0 = no suggestion.", 5, {min: 0, max: 20, unit: "letters"})
    Add("number", "HotstringHelper.MinWordLength", "Skip words this short or shorter", "With 2: 'we', 'it' and 'a' are skipped.", 2, {min: 0, max: 10, unit: "letters"})
    Add("bppreview", "_bpPreview", "Try it: type a sample", "", "Thank you for your business, we appreciate it")
    DefGrp("When the Hotstring Helper window opens")
    Add("number", "HotstringHelper.MaxClipLength", "Fill the form from the clipboard if it is shorter than", "Longer clipboard text is ignored.  0 = no limit.", 2000, {min: 0, max: 10000, unit: "characters"})
    Add("toggle", "HotstringHelper.EmptyFormDefaults", "Start an empty form with the AutoCorrect defaults", "Options, Function, Log and Paste as set above.  Off = every box starts blank.", 1)
    Add("ddl", "HotstringHelper.InitialFocusTarget", "Put the cursor in", "", "auto", {opts: [["auto", "Best guess (auto)"], ["options", "Options box"], ["trigger", "Trigger box"], ["replacement", "Replacement box"], ["comment", "Comment box"]]})
    Add("toggle", "HotstringHelper.AutoOpenExamPane", "Open the Exam Pane when I load an existing hotstring", "", 1)
    Add("toggle", "HotstringHelper.RememberWindowPosition", "Reopen where I last put it", "Off = centred every time.  (Tray menu > Reset HH Window Position forgets the spot.)", 1)
    DefGrp("Hotstring Helper window size and text")
    Add("slider", "HotstringHelper.DefaultFontSize", "Hotstring Helper text size", "", 11, {min: 8, max: 13, step: 1, unit: "pt", ess: 1})
    Add("slider", "HotstringHelper.LargeFontSize", "Large text size", "When the boxes are toggled to large with Ctrl+Up / Ctrl+Down (or Ctrl+mouse wheel).", 15, {min: 8, max: 16, step: 1, unit: "pt"})
    Add("number", "HotstringHelper.DefaultWidth", "Window width", "", 366, {min: 366, max: 1000, unit: "px"})
    Add("slider", "HotstringHelper.WidthSizeIncrease", "'Make Bigger' adds this much width", "", 500, {min: 0, max: 600, step: 25, unit: "px"})
    Add("slider", "HotstringHelper.HeightSizeIncrease", "... and this much height", "", 400, {min: 0, max: 600, step: 25, unit: "px"})
    Add("toggle", "HotstringHelper.AutoBigReplBox", "Enlarge the Replacement box by itself for long text", "", 1)
    Add("number", "HotstringHelper.AutoBigLineLimit", "when it has more lines than", "", 5, {min: 2, max: 10, unit: "lines", dep: "HotstringHelper.AutoBigReplBox"})
    Add("number", "HotstringHelper.AutoBigCharLimit", "or a line longer than", "", 40, {min: 10, max: 120, unit: "characters", dep: "HotstringHelper.AutoBigReplBox"})
    Add("slider", "HotstringHelper.ExamPaneListHeight", "Exam Pane list height", "", 350, {min: 100, max: 600, step: 10, unit: "px"})

    ; ---------------------------------------------------------------- Shortcuts
    DefSec("keys", "Shortcuts", "Click a box and press the new key combination.  Tick Win to add the Windows key.  Clashes are flagged in red.  Hotkey Hub (Shift+Alt+Q) lists every shortcut in the suite.")
    Add("hotkey", "Hotkeys.HotstringHelperActivationHotkey", "Open Hotstring Helper", "", "#h", {ess: 1})
    Add("hotkey", "Hotkeys.HotkeyHubHotkey", "Show Hotkey Hub", "", "+!q")
    Add("hotkey", "Hotkeys.LastTriggerHk", "Show the last three hotstrings that fired", "", "!F3")
    Add("hotkey", "Hotkeys.StringReportHk", "Hotstring stats report", "", "^F3")
    Add("hotkey", "Hotkeys.AutoCorrect2EditThisScriptHk", "Open AutoCorrect2.ahk in my editor", "", "+^e")
    Add("hotkey", "Hotkeys.SystemUpTimeHk", "Show how long the PC has been on", "", "!+u")
    Add("hotkey", "Hotkeys.ACLogAnalyzerHk", "Analyze the AutoCorrect log", "", "!^+q")
    Add("hotkey", "Hotkeys.MCLoggerRunAnalysisHotkey", "Analyze the Manual Correction log", "", "#^+q")
    Add("hotkey", "Hotkeys.MCLoggerSneakPeekHotkey", "Peek at what MCLogger has collected", "", "#+q")
    Add("hotkey", "Hotkeys.NonWordFlagHk", "Flag the selected word as not a real word", "For cleaning the Exam Pane word list (Non-Word List).  Blank = no shortcut.", "")
    Add("hotkey", "Hotkeys.NonWordManagerHk", "Open the Non-Word List", "Also on a Control Panel button.  Blank = no shortcut.", "")

    ; ---------------------------------------------------------------- Buttons and menus
    DefSec("menus", "Buttons and menus", "What appears in the Control Panel beside Hotstring Helper, and in the tray menu.")
    DefGrp("Control Panel buttons", "Tick the buttons to show.  Whether Hotstring Helper stays open or closes after a button is clicked: select its row and use the choice just below, or right-click the row.  Some buttons only appear when their tool is installed." (SHOWINI ? "   " Chr(0xB7) "   [ControlButtons]" : ""))
    members := []
    for b in [["OpenLibrary", "HotString Library"], ["PersonalHotstrings", "Personal Hotstrings File"], ["ACLog", "AutoCorrection Log"]
            , ["ACLogContinuous", "AutoCorrection Continuous Log"], ["ACAnalyze", "Analyze AutoCorrection Log"], ["BSLog", "Backspace Context Log"]
            , ["RemovedHS", "Removed HotStrings List"], ["MCLog", "Manual Correction Log"], ["MCLogContinuous", "MC Log Continuous"]
            , ["MCAnalyze", "Analyze Manual Correction Log"], ["Report", "Report HotStrings and Potential Fixes"], ["SettingsMan", "Configuration Settings Manager"]
            , ["SettingsDash", "Settings Dashboard"], ["HotkeyHub", "Hotkey Reference Tool (Hotkey Hub)"], ["Suggester", "Hotstring Suggester Tool"]
            , ["HsAnalyzer", "Hotstring Analyzer Tool"], ["HsAuditor", "Hotstring Auditor (firing-order scan)"], ["ExtractMisspellings", "Extract Potential Misspellings"]
            , ["TypoInvaders", "Play TypoInvaders"], ["ConflictLocator", "Conflicting String Locator Tool"], ["Updater", "Check GitHub for Updates"]
            , ["LibraryMerge", "Merge a Newer AutoCorrect Library"], ["BulkFunctionizer", "Functionize Hotstrings"], ["NonWords", "Non-Word List"]
            , ["OpenFolder", "Go to AutoCorrect2 Folder"], ["GitHub", "Go to GitHub Repository"], ["Theme", "Change Color Theme"]]
        members.Push(Add("cbtn", "ControlButtons." b[1], b[2], "", "1,stay"))
    t := PushRow({kind: "table", members: members})
    for m in members
        t.hay .= " " m.label " " m.key
    DefGrp("Tray menu", "Tick the items to show when you right-click the AutoCorrect2 tray icon.  The top item (opens Hotstring Helper) and 'Exit Script' always show.")
    for item in [["EditThisScript", "Edit This Script"], ["HotstringLibrary", "Hotstring Library"], ["AutoCorrectLog", "Open AutoCorrect Log"]
               , ["ResetHHWindowPosition", "Reset HH Window Position"], ["SettingsManager", "Open Settings Manager"], ["SettingsDashboard", "Open Settings Dashboard"]
               , ["CheckForUpdates", "Check for Updates"], ["RestartScript", "Restart Script"], ["OpenFolder", "Open AutoCorrect2 Folder"]
               , ["GitHub", "Go to GitHub Repository"], ["PrinterTool", "Run Printer Tool"], ["Calendar", "Show Calendar"]
               , ["SystemUpTime", "System Up Time"], ["ListLinesDebug", "List Lines Debug"], ["EnableAutoCorrections", "Enable AutoCorrections  (the on/off switch)"]
               , ["StartWithWindows", "Start with Windows"]]
        Add("toggle", "TrayMenu." item[1], item[2], "", 1, {restart: "AutoCorrect2.exe"})
    DefGrp("Optional modules", "Extra tools that load with AutoCorrect2.")
    Add("toggle", "HotstringHelper.EnableHotStrQuickLookup", "Hotstring Quick Lookup", "Select a whole hotstring and press a shortcut to see its stats.", 1)
    Add("toggle", "HotstringHelper.EnableDragTools", "Drag Tools", "Right-click-and-drag gestures.  Turn off if your file manager already uses right-drag.", 1)
    Add("toggle", "HotstringHelper.EnableMoveResizeTools", "Move or resize any window", "Ctrl+Alt+left-drag moves a window from anywhere; Ctrl+Alt+right-drag resizes it.", 1)

    ; ---------------------------------------------------------------- Tools
    DefSec("tools", "Tools", "Settings of the separate tools in the suite.  (Tools that remember their own options -- Hotkey Hub, Bulk Functionizer, Hotstring Auditor -- save them from their own windows.)")
    DefGrp("Manual Correction Logger", "Watches for words you fix by hand (not the ones AutoCorrect fixes), so you can turn them into new hotstrings.  It is a separate program, Core\MCLogger.exe, and does NOT start when AutoCorrect2 starts: run it yourself, or put a shortcut to it in your Windows Startup folder.")
    Add("toggle", "MCLogger.ShowEachHotString", "Show a tooltip when it catches a manual correction", "", 1)
    Add("number", "MCLogger.SaveIntervalMinutes", "Save to disk every", "", 10, {min: 1, max: 120, unit: "minutes"})
    Add("number", "MCLogger.IntervalsBeforeStopping", "Go idle after this many quiet saves", "It wakes up again on the next manual correction.", 2, {min: 1, max: 20, unit: "saves"})
    Add("seg", "MCLogger.SendToHH", "'Append' sends the hotstring to", "", 1, {opts: [[1, "Hotstring Helper"], [0, "The library"]]})
    Add("seg", "MCLogger.KeepReportOpen", "After 'Cull and Append'", "", 1, {opts: [[1, "Keep the list open"], [0, "Close it"]]})
    Add("toggle", "MCLogger.HighlightCulled", "Highlight rows already culled", "", 1)
    Add("toggle", "MCLogger.SaveFullToClipboard", "Also copy the full report to the clipboard", "Replaces whatever was on the clipboard.", 1)
    Add("slider", "MCLogger.AgeOfOldSingles", "'Remove old singletons' removes entries older than", "For the 'Remove old singletons' button in the Manual Correction analysis report: it deletes entries logged only once that are older than this.", 90, {min: 30, max: 365, step: 5, unit: "days"})
    Add("slider", "MCLogger.LetterOverlapMin", "While logging, skip pairs sharing fewer letters than", "Checked as each manual correction is caught (not later, in the analysis), so abandoned fragments that aren't real typos never reach the Manual Correction log.", 40, {min: 0, max: 100, step: 5, unit: "%"})
    Add("slider", "MCLogger.AdjacentKeyMin", "... unless this many of the differing letters are neighbouring keys", "Also while logging.  Only for a pair of the same length.", 60, {min: 0, max: 100, step: 5, unit: "%"})
    DefGrp("AutoCorrect Log Analyzer", "Gives each hotstring in the AutoCorrect log a Weight, so the ones you keep backspacing rise to the top of the list.")
    Add("slider", "ACLogAnalyzer.FreqImportance", "Weight: how much the number of backspaces counts", "At 0, a hotstring's Weight is just the share of its autocorrections you backspaced (backspaced vs. kept).  Higher values also add points for how many times it was backspaced, so a hotstring backspaced 20 times ranks above one backspaced once at the same share.", 10, {min: 0, max: 50, step: 1, unit: ""})
    Add("number", "ACLogAnalyzer.IgnoreFewerThan", "Ignore hotstrings backspaced this many times or fewer", "", 0, {min: 0, max: 5, unit: "times"})
    Add("toggle", "ACLogAnalyzer.PinToTop", "Keep the window on top", "", 1)
    Add("toggle", "ACLogAnalyzer.CopyHotstringOnSelect", "Copy a hotstring to the clipboard when I select it", "Then press your Hotstring Helper shortcut to edit it.", 1)
    dates := []
    for f in ["MM-dd-yyyy", "dd-MM-yyyy", "yyyy-MM-dd", "dd/MM/yyyy", "MMM d, yyyy"]
        dates.Push([f, FormatTime(, f) "     (" f ")"])
    Add("ddl", "ACLogAnalyzer.CullDateFormat", "Date format for culled items", "", "MM-dd-yyyy", {opts: dates})
    Add("number", "ACLogAnalyzer.StartLine", "Skip the first lines of the AutoCorrect log when scanning it", "The log's header lines.", 7, {min: 1, max: 1000, unit: "lines"})
    DefGrp("Conflicting String Locator")
    Add("text", "ConflictingStringLocator.EditorCmd", "Command to open a file at a line", "Used by its 'go to' links.  Use {file} and {line}.", 'code -g "{file}:{line}"', {w: 230})

    ; ---------------------------------------------------------------- Files and advanced
    DefSec("adv", "Files and advanced", "Rarely needs changing.  File names are relative to the AutoCorrect2 folders.")
    DefGrp("Editor and file manager")
    Add("ddl", "_editorPreset", "Text editor", "Picking one fills in the two lines below.", EditorGuess()
        , {opts: [["vscode", "VS Code"], ["npp", "Notepad++"], ["notepad", "Notepad"], ["custom", "Another editor (fill in below)"]], onset: EditorPreset, ess: 1})
    Add("file", "Shared.DefaultEditor", "Editor program", "", "Notepad.exe")
    Add("text", "Shared.EditorCmd", "Command to open a file at a line", "Use {file} and {line}.  Blank = worked out from the editor program.", "", {w: 230})
    Add("file", "Files.FileManagerPath", "File manager", "Blank = Windows Explorer.", "")
    DefGrp("Libraries", "Both names are also #Include lines in AutoCorrect2.ahk: change both, or AutoCorrect2 won't find them.")
    Add("file", "Files.HotstringLibrary", "Autocorrect library", "", "AutoCorrectHotstrings.ahk")
    Add("file", "Files.BoilerplateHotstringLibrary", "Personal (boilerplate) library", "", "PersonalHotstrings.ahk")
    Add("file", "Files.NewTemporaryHotstrLib", "Where the Updater saves a new library", "", "AutoCorrectHotstrings (1).ahk")
    Add("file", "Files.RemovedHsFile", "Removed hotstrings list", "Hotstring Helper warns if you add one of these again.", "RemovedHotstrings.txt")
    DefGrp("Logs and word lists")
    Add("file", "Files.AutoCorrectsLogFile", "AutoCorrect log", "", "AutoCorrectsLog.txt")
    Add("file", "Files.ACLogContinuousFile", "AutoCorrect log (never trimmed)", "", "ACLogContinuous.txt")
    Add("file", "Files.ErrContextLog", "Backspace context log", "", "ErrContextLog.txt")
    Add("file", "Files.MCLogFile", "Manual correction log", "", "ManualCorrectionsLog.txt")
    Add("file", "Files.MCLogContinuous", "Manual correction log (never trimmed)", "", "MCLogContinuous.txt")
    Add("file", "Files.WordListFile", "Word list", "Used by the Exam Pane and validity checks.", "ExamPaneWordList253k.txt")
    Add("file", "Files.FrequencyListFile", "Word frequency list", "Used for the Web Freq comments.", "unigram_freq_list_filtered_102k.csv")
    DefGrp("Suite programs", "The names of the suite's own programs.  Only change these if you renamed a file.")
    Add("file", "Files.AutoCorrect2Script", "AutoCorrect2 script", "", "AutoCorrect2.ahk")
    Add("file", "Files.ACLogAnalyzer", "AutoCorrect Log Analyzer", "", "ACLogAnalyzer.exe")
    Add("file", "Files.MCLoggerPath", "Manual Correction Logger", "", "MCLogger.exe")
    Add("file", "Files.SettingsManager", "Settings Manager", "", "SettingsManager.exe")
    DefGrp("Report colors", "Good/bad colors used in reports and progress bars.")
    Add("color", "Shared.LightGreen", "Green on dark themes", "", "b8f3ab")
    Add("color", "Shared.DarkGreen", "Green on light themes", "", "0d3803")
    Add("color", "Shared.LightRed", "Red on dark themes", "", "fd7c73")
    Add("color", "Shared.DarkRed", "Red on light themes", "", "B90012")
    DefGrp("Troubleshooting", "Leave these off unless you are tracking down a problem.")
    Add("toggle", "HotstringHelper.CODE_ERROR_LOG", "Log AutoCorrect2's script errors to a file", "", 0)
    Add("toggle", "HotstringHelper.CODE_DEBUG_LOG", "Detailed debug log", "Very verbose: only while tracking a problem.", 0)
    Add("toggle", "ACLogAnalyzer.EnableErrorLogging", "AutoCorrect Log Analyzer: log its own errors", "", 1)
    Add("toggle", "MCLogger.DebugFilterLog", "Manual Correction Logger: save the filtered-out pairs to a file", "", 1)
}

; Any key in the user's acSettings.ini that DefineSettings() didn't place, and that no tool
; owns, gets a plain row in "More settings", typed and labelled from the metadata json.
AddLeftovers() {
    if !FileExist(IniPath)
        return
    for sec in StrSplit(IniRead(IniPath), "`n") {
        sec := Trim(sec)
        for line in StrSplit(IniRead(IniPath, sec), "`n") {
            if !(p := InStr(line, "="))
                continue
            key := sec "." Trim(SubStr(line, 1, p - 1))
            if !BYKEY.Has(key) && !IsToolOwned(key)
                MOREKEYS.Push(key)
        }
    }
    if !MOREKEYS.Length
        return
    DefSec("more", "More settings", "Settings this dashboard has no page for yet -- usually ones added in a recent update.  They are listed here automatically, with the Settings Manager's descriptions.")
    for key in MOREKEYS {
        mt := META.Has(key) ? META[key] : {label: StrSplit(key, ".")[2], help: "", type: "text", min: "", max: "", restart: ""}
        desc := FirstSentence(mt.help)
        switch mt.type {
        case "boolean": Add("toggle", key, mt.label, desc, 0)
        case "integer": Add("number", key, mt.label, desc, 0, {min: mt.min = "" ? 0 : mt.min, max: mt.max = "" ? 99999 : mt.max, unit: ""})
        case "hotkey":  Add("hotkey", key, mt.label, desc, "")
        case "color":   Add("color", key, mt.label, desc, "000000")
        case "file":    Add("file", key, mt.label, desc, "")
        default:        Add("text", key, mt.label, desc, "", {w: 230})
        }
    }
}
IsToolOwned(key) {
    for re in TOOL_OWNED
        if key ~= re
            return true
    return false
}
FirstSentence(t) {
    t := Trim(RegExReplace(t, "\s+", " "))
    return RegExMatch(t, "^.{20,180}?[.!?](?=\s|$)", &m) ? m[0] : SubStr(t, 1, 180)
}

DefSec(id, title, desc) {
    global CURSEC, CURGRP, CURGRPTITLE
    o := {id: id, title: title, desc: desc}
    SECS.Push(o), SECMAP[id] := o
    CURSEC := id, CURGRP := 0, CURGRPTITLE := ""
    o.row := PushRow({kind: "sec", label: title})
}
DefGrp(title, desc := "") {
    global CURGRP, CURGRPTITLE
    CURGRPTITLE := title
    r := PushRow({kind: "grp", label: title, desc: desc})
    CURGRP := ROWS.Length, r.grp := CURGRP
}
DefNote(text) => PushRow({kind: "note", label: text})

PushRow(r) {
    r.sec := CURSEC, r.grp := (r.kind = "sec") ? -1 : CURGRP
    r.ctrls := [], r.pos := [], r.h := 0, r.y := 0, r.vis := false, r.show := false
    if !r.HasProp("s")
        r.s := ""
    r.hay := (CURSEC != "" ? SECMAP[CURSEC].title : "") " " CURGRPTITLE
    ROWS.Push(r)
    return r
}

Add(type, key, label, desc, def, extra := "") {
    s := {type: type, key: key, label: label, desc: desc, def: def, sec: CURSEC, dep: "", ctrls: []
        , restart: "", ess: 0, link: ""}
    if IsObject(extra)
        for k, v in extra.OwnProps()
            s.%k% := v
    if SubStr(key, 1, 1) != "_" {
        s.def := DefaultFor(key, def)                 ; the shipped default wins over the fallback
        if s.restart = "" && META.Has(key)
            s.restart := META[key].restart
    }
    s.value := SubStr(key, 1, 1) = "_" ? def : ReadIni(key, s.def)
    s.orig := s.value
    ALL.Push(s), BYKEY[key] := s
    if type != "hidden" && type != "cbtn" {
        s.r := PushRow({kind: "set", s: s})
        s.r.hay .= " " label " " desc " " key " " s.link (META.Has(key) ? " " META[key].label : "")   ; Settings Manager names find it too
    }
    return s
}

ReadIni(key, def, file := IniPath) {
    parts := StrSplit(key, ".")
    if parts.Length != 2 || !FileExist(file)
        return def
    return IniRead(file, parts[1], parts[2], def)
}
DefaultFor(key, fallback) => ReadIni(key, fallback, DefPath)

OpenIni(*) {
    if FileExist(IniPath)
        Run('"' IniPath '"')
    else
        MsgBox("acSettings.ini was not found:`n" IniPath "`n`nThe dashboard is showing default values.", "Settings Dashboard", "Icon!")
}
OpenSettingsManager(*) {
    for ext in [".exe", ".ahk"]
        if FileExist(SMPath ext) {
            Run('"' SMPath ext '"', A_ScriptDir "\..\Tools")
            return
        }
    MsgBox("The Settings Manager was not found in the Tools folder.", "Settings Dashboard", "Icon!")
}

; The Settings Manager's metadata, read with regexes: the file is close to JSON but not strict
; (stray commas), and the dashboard only needs a few string and number fields from each block.
LoadMeta() {
    m := Map()
    if !FileExist(MetaPath)
        return m
    txt := FileRead(MetaPath, "UTF-8")
    pos := 1
    while pos := RegExMatch(txt, 's)"(\w+\.\w+)"\s*:\s*\{(.*?)\n\s*\}', &b, pos) {
        o := {label: JStr(b[2], "label"), help: JStr(b[2], "help"), type: JStr(b[2], "type"), restart: JStr(b[2], "restart")}
        o.min := RegExMatch(b[2], '"min"\s*:\s*(-?\d+)', &n) ? Integer(n[1]) : ""
        o.max := RegExMatch(b[2], '"max"\s*:\s*(-?\d+)', &n) ? Integer(n[1]) : ""
        o.restartPath := o.restart                    ; e.g. ..\Core\AutoCorrect2.exe, relative to Tools\
        SplitPath(o.restart, &exeName)
        o.restart := exeName
        m[b[1]] := o
        pos += b.Len
    }
    return m
}
JStr(block, field) {
    if !RegExMatch(block, '"' field '"\s*:\s*"((?:\\.|[^"\\])*)"', &v)
        return ""
    t := StrReplace(v[1], "\\", Chr(1))
    t := StrReplace(StrReplace(StrReplace(t, "\n", "`n"), '\"', '"'), "\t", "`t")
    return StrReplace(t, Chr(1), "\")
}

; "[ACSystem] BackspaceWindow" -- the row's home in the ini, shown under its description.
IniTag(s) {
    if !SHOWINI || SubStr(s.key, 1, 1) = "_" || !InStr(s.key, ".")
        return ""
    p := StrSplit(s.key, ".")
    return "[" p[1] "] " p[2] (s.link != "" ? " + " StrSplit(s.link, ".")[2] : "")
}
DescText(s) => (tag := IniTag(s)) = "" ? s.desc : s.desc = "" ? tag : s.desc "   " Chr(0xB7) "   " tag

; Shows the Settings Manager's full help for a key.
ShowHelp(s) {
    mt := META[s.key]
    p := StrSplit(s.key, ".")
    MsgBox(mt.help "`n`n----------`nIn acSettings.ini:  [" p[1] "]  " p[2] "=" s.value
        . "`nDefault:  " s.def (mt.restart != "" ? "`nTakes effect after restarting:  " mt.restart : ""), mt.label, "Iconi Owner" G.Hwnd)
}

; Which editor preset matches the current DefaultEditor/EditorCmd.  EditorCmd wins: it is what
; AutoCorrect2 actually runs when it is set.
EditorGuess() {
    cmd := ReadIni("Shared.EditorCmd", ""), ed := ReadIni("Shared.DefaultEditor", "Notepad.exe")
    probe := cmd != "" ? cmd : ed
    return InStr(probe, "Code.exe") ? "vscode" : InStr(probe, "notepad++") ? "npp" : (probe ~= "i)^`"?notepad(\.exe)?") ? "notepad" : "custom"
}

LoadTheme() {
    t := {form: "E5E4E2", font: "1F1F1F", list: "FFFFFF"}
    f := A_ScriptDir "\..\Data\colorThemeSettings.ini"
    if FileExist(f)                          ; a missing file or a non-hex value keeps the default
        for k in ["form", "font", "list"]
            if RegExMatch(IniRead(f, "ColorSettings", k "Color", ""), "i)^(?:0x)?([0-9A-F]{6})$", &m)
                t.%k% := m[1]
    t.mode := "mine"
    for a in A_Args
        if a = "/light"
            t.form := "F3F3F3", t.font := "1F1F1F", t.list := "FFFFFF", t.mode := "light"
        else if a = "/dark"
            t.form := "2B2B2B", t.font := "E6E6E6", t.list := "1F1F1F", t.mode := "dark"
    t.dim := Blend(t.font, t.form, 0.25)        ; hints and ini names: secondary, but still easy to read
    t.bad := "E0504A"
    t.dark := IsDark(t.form)
    return t
}
Blend(a, b, k) {
    out := ""
    loop 3 {
        i := (A_Index - 1) * 2 + 1
        ca := Integer("0x" SubStr(a, i, 2)), cb := Integer("0x" SubStr(b, i, 2))
        out .= Format("{:02X}", Round(ca + (cb - ca) * k))
    }
    return out
}
IsDark(col) {
    col := Integer("0x" col)
    return (0.299 * ((col >> 16) & 0xFF) + 0.587 * ((col >> 8) & 0xFF) + 0.114 * (col & 0xFF)) < 128
}

; ============================================================================
; GUI
; ============================================================================
BuildGui() {
    global G, P, NavLB, SearchEd, TitleTxt, DescTxt, StatusTxt
    G := Gui("+0x02000000", "AutoCorrect2 Settings Dashboard  v" VERSION)     ; WS_CLIPCHILDREN
    G.BackColor := THEME.form
    G.OnEvent("Close", (*) => CloseDashboard())
    G.SetFont("s10 norm c" THEME.font, "Segoe UI")

    SearchEd := G.Add("Edit", "x10 y12 w225 Background" THEME.list)
    SendMessage(0x1501, 1, StrPtr("Search every setting..."), SearchEd)     ; EM_SETCUEBANNER
    SearchEd.OnEvent("Change", (*) => SetTimer(DoSearch, -200))
    names := ["Essentials"]
    for o in SECS
        names.Push(o.title)
    names.Push("Changed from default")
    G.SetFont("s11")
    NavLB := G.Add("ListBox", "x10 y46 w225 r" names.Length " Choose1 Background" THEME.list, names)
    NavLB.OnEvent("Change", OnNav)
    G.SetFont("s10 bold")
    G.Add("Text", "x10 y+18", "Layout")
    G.SetFont("norm")
    G.Add("Radio", "x10 y+6 Group" (MODE = "paged" ? " Checked" : ""), "One section at a time").OnEvent("Click", (*) => SetMode("paged"))
    G.Add("Radio", "x10 y+6" (MODE = "list" ? " Checked" : ""), "One long list").OnEvent("Click", (*) => SetMode("list"))
    G.SetFont("bold")
    G.Add("Text", "x10 y+18", "Preview colors")
    G.SetFont("norm")
    for i, o in [["mine", "My color theme"], ["light", "Light"], ["dark", "Dark"]]
        G.Add("Radio", "x10 y+6" (i = 1 ? " Group" : "") (THEME.mode = o[1] ? " Checked" : ""), o[2]).OnEvent("Click", ThemeHandler(o[1]))
    G.SetFont("bold")
    G.Add("Text", "x10 y+18", "For ini users")
    G.SetFont("norm")
    G.Add("CheckBox", "x10 y+6 w225" (SHOWINI ? " Checked" : ""), "Show ini names on each row").OnEvent("Click", (ct, *) => Relaunch(THEME.mode, ct.Value))

    G.SetFont("s15 bold c" THEME.font)
    TitleTxt := G.Add("Text", "x" (PX + X0) " y8 w680")
    G.SetFont("s9 norm c" THEME.dim)
    DescTxt := G.Add("Text", "x" (PX + X0) " y42 w680 h32")
    G.SetFont("s10 norm c" THEME.font)
    G.Add("Button", "x10 y610 w112 h30", "Settings Manager").OnEvent("Click", OpenSettingsManager)
    G.Add("Button", "x127 y610 w108 h30", "Open the .ini").OnEvent("Click", OpenIni)
    StatusTxt := G.Add("Text", "x" (PX + X0) " y617 w400")
    ; Cancel = the Windows convention: drop what wasn't applied, and close.  No question asked --
    ; dropping the changes is what the button says.  (One row at a time: its reset arrow.)
    G.Add("Button", "x675 y610 w80 h30", "Cancel").OnEvent("Click", (*) => ExitApp())
    G.Add("Button", "x765 y610 w80 h30", "Apply").OnEvent("Click", (*) => ApplyAll(false))
    G.Add("Button", "x855 y610 w80 h30", "OK").OnEvent("Click", (*) => ApplyAll(true))

    ; The scrolling panel: a child window (WS_CHILD, not WS_POPUP) with a vertical scroll bar.
    P := Gui("+Parent" G.Hwnd " -Caption +0x40000000 -0x80000000 +0x200000 +E0x10000")
    P.BackColor := THEME.form
    P.MarginX := 0, P.MarginY := 0
    FLabel()
    y := 0
    for r in ROWS {
        bottom := BuildRow(r, y)
        r.h := bottom - y
        for ct in r.ctrls {
            ct.GetPos(&cx, &cy)
            r.pos.Push([cx, cy - y])
        }
        y := bottom
    }
    P.Show("x" PX " y" PY " w" PW " h" PH " NoActivate")
    ; Show takes w as the client width and adds the scroll bar outside it (17 px past PW, half of it
    ; beyond the main window's edge).  Set the outer size, so the bar sits inside PW.
    DllCall("SetWindowPos", "Ptr", P.Hwnd, "Ptr", 0, "Int", Round(PX * DPI), "Int", Round(PY * DPI)
        , "Int", Round(PW * DPI), "Int", Round(PH * DPI), "UInt", 0x14)    ; SWP_NOZORDER | SWP_NOACTIVATE

    ; Dark style for push buttons only: checkboxes and radios share class "Button", and
    ; DarkMode_Explorer draws their text black.  ctrl.Type tells them apart.
    if THEME.dark {
        for win in [G, P]
            for hwnd, ctrl in win
                if ctrl.Type = "Button"
                    DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
        DllCall("uxtheme\SetWindowTheme", "Ptr", P.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)     ; its scroll bar
    }
    OnMessage(0x0114, OnHScroll)    ; slider readout while dragging
    OnMessage(0x0115, OnVScroll)    ; the panel's scroll bar
    OnMessage(0x020A, OnWheel)      ; wheel scrolls the panel, even over a slider or list
    OnMessage(0x02E0, (w, l, m, hwnd) => (hwnd = G.Hwnd ? SetTimer(KeepSize, -50) : 0))  ; WM_DPICHANGED
    OnMessage(0x0232, (w, l, m, hwnd) => (hwnd = G.Hwnd ? SetTimer(KeepSize, -50) : 0))  ; WM_EXITSIZEMOVE: a drag ended
    UpdateBP(), UpdateLogPreview(), CheckClashes(), UpdateStatus()
}

FLabel() => P.SetFont("s10 norm c" THEME.font, "Segoe UI")
FDesc() => P.SetFont("s9 norm c" THEME.dim, "Segoe UI")
FHead() => P.SetFont("s10 bold c" THEME.font, "Segoe UI")

; Add a control to row r (and to setting s, so it greys out with it).
Ctl(r, s, type, opts, text := "") {
    ct := P.Add(type, opts " Hidden", text)
    r.ctrls.Push(ct)
    if IsObject(s)
        s.ctrls.Push(ct)
    return ct
}
TextBottom(ct) {
    ct.GetPos(, &ty, , &th)
    return ty + th
}
Suffix(s) => ""          ; (mockup 2 marked reload-needed and proposed keys here; Apply now names what restarts)

BuildRow(r, y) {
    switch r.kind {
    case "sec":
        Ctl(r, "", "Text", Format("x{} y{} w{} h1 Background{}", X0, y + 10, RX - X0, THEME.dim))
        P.SetFont("s13 bold c" THEME.font, "Segoe UI")
        b := TextBottom(Ctl(r, "", "Text", Format("x{} y{} w{}", X0, y + 18, RX - X0), r.label))
        FLabel()
        return b + 4
    case "grp":
        FHead()
        b := TextBottom(Ctl(r, "", "Text", Format("x{} y{} w{}", X0, y + 12, RX - X0), r.label))
        if r.desc != "" {
            FDesc()
            b := TextBottom(Ctl(r, "", "Text", Format("x{} y{} w{}", X0, b + 2, RX - X0), r.desc))
        }
        FLabel()
        return b + 10
    case "note":
        FDesc()
        b := TextBottom(Ctl(r, "", "Text", Format("x{} y{} w{}", X0, y + 14, RX - X0), r.label))
        FLabel()
        return b + 12
    case "extra":
        return r.x = "soundbtns" ? BuildSoundBtns(r, y) : r.x = "acpreview" ? BuildAcPreview(r, y) : BuildLogPreview(r, y)
    case "table":
        return BuildTable(r, y)
    }
    return BuildSetting(r, r.s, y)
}

; Label + description on the left; returns the y below them.
LabelBlock(r, s, x, y, w := 0) {
    w := w ? w : CX - x - 12
    bottom := TextBottom(Ctl(r, s, "Text", "x" x " y" (y + 3) " w" w, s.label Suffix(s)))
    if (d := DescText(s)) != "" {
        FDesc()
        bottom := TextBottom(Ctl(r, s, "Text", "x" x " y" (bottom + 1) " w" w, d))
        FLabel()
    }
    return bottom
}

BuildSetting(r, s, y) {
    ; Indented under its parent -- but only when the parent is in the same section.  (A
    ; Sounds row that needs the AutoCorrect log on still greys out, but isn't indented.)
    x := X0 + (s.dep != "" && BYKEY.Has(s.dep) && BYKEY[s.dep].sec = s.sec ? 24 : 0)
    switch s.type {
    case "toggle":
        cb := Ctl(r, s, "CheckBox", "x" x " y" y " w" (RX - x - 48) (s.value ? " Checked" : ""), s.label Suffix(s))
        cb.OnEvent("Click", (ct, *) => SetVal(s, ct.Value))
        s.main := cb
        bottom := y + 22
        if (d := DescText(s)) != "" {
            FDesc()
            bottom := TextBottom(Ctl(r, s, "Text", "x" (x + 20) " y" (y + 22) " w" (RX - x - 68), d))
            FLabel()
        }
        AddReset(r, s, y)
        return bottom + 12
    case "slider":
        bottom := LabelBlock(r, s, x, y)
        sl := Ctl(r, s, "Slider", Format("x{} y{} w150 h28 NoTicks Range{}-{} Line{} Page{}", CX, y, s.min, s.max, s.step, s.step * 5), s.value)
        sl.OnEvent("Change", (*) => SliderMoved(s, true))
        s.main := sl, SLIDERS[sl.Hwnd] := s
        s.valTxt := Ctl(r, s, "Text", Format("x{} y{} w80", CX + 156, y + 4), FmtVal(s, s.value))
        AddReset(r, s, y)
        return Max(bottom, y + 30) + 12
    case "number":
        bottom := LabelBlock(r, s, x, y)
        ed := Ctl(r, s, "Edit", Format("x{} y{} w75 r1 Number Right Background{}", CX, y, THEME.list), s.value)
        Ctl(r, s, "UpDown", Format("Range{}-{} 0x80", s.min, s.max), s.value)
        ed.OnEvent("Change", (ct, *) => SetVal(s, ct.Value))
        s.main := ed
        Ctl(r, s, "Text", Format("x{} y{} w140", CX + 85, y + 3), s.unit)
        AddReset(r, s, y)
        return Max(bottom, y + 26) + 12
    case "ddl":
        bottom := LabelBlock(r, s, x, y)
        labels := [], idx := 1
        for i, o in s.opts {
            labels.Push(o[2])
            if "" o[1] = "" s.value
                idx := i
        }
        dd := Ctl(r, s, "DropDownList", Format("x{} y{} w230 Choose{}", CX, y, idx), labels)
        dd.OnEvent("Change", (ct, *) => SetVal(s, s.opts[ct.Value][1]))
        s.main := dd
        AddReset(r, s, y)
        return Max(bottom, y + 28) + 12
    case "combo":
        bottom := LabelBlock(r, s, x, y)
        cb := Ctl(r, s, "ComboBox", Format("x{} y{} w230", CX, y), s.opts)
        cb.Text := s.value
        cb.OnEvent("Change", (ct, *) => SetVal(s, ct.Text))
        s.main := cb
        AddReset(r, s, y)
        return Max(bottom, y + 28) + 12
    case "seg":
        bottom := LabelBlock(r, s, x, y)
        s.radios := []
        for i, o in s.opts {
            rb := Ctl(r, s, "Radio", (i = 1 ? "Group x" CX " y" (y + 3) : "x+14 yp") ("" o[1] = "" s.value ? " Checked" : ""), o[2])
            rb.OnEvent("Click", SegHandler(s, o[1]))
            s.radios.Push(rb)
        }
        s.main := s.radios[1]
        AddReset(r, s, y)
        return Max(bottom, y + 26) + 12
    case "hotkey":
        bottom := LabelBlock(r, s, x, y)
        hk := Ctl(r, s, "Hotkey", Format("x{} y{} w150", CX, y), StrReplace(s.value, "#"))
        win := Ctl(r, s, "CheckBox", "x+10 yp+3" (InStr(s.value, "#") ? " Checked" : ""), "Win")
        s.main := hk, s.win := win
        upd := (*) => SetVal(s, (win.Value ? "#" : "") hk.Value)
        hk.OnEvent("Change", upd), win.OnEvent("Click", upd)
        P.SetFont("s9 norm c" THEME.bad)
        s.warn := Ctl(r, s, "Text", Format("x{} y{} w230", CX, y + 27), "")
        FLabel()
        AddReset(r, s, y)
        return Max(bottom, y + 44) + 6
    case "text":
        bottom := LabelBlock(r, s, x, y)
        ed := Ctl(r, s, "Edit", Format("x{} y{} w{} r1 Background{}", CX, y, s.HasProp("w") ? s.w : 150, THEME.list), s.value)
        ed.OnEvent("Change", (ct, *) => SetVal(s, ct.Value))
        s.main := ed
        AddReset(r, s, y)
        return Max(bottom, y + 26) + 12
    case "file":
        bottom := LabelBlock(r, s, x, y)
        ed := Ctl(r, s, "Edit", Format("x{} y{} w158 r1 Background{}", CX, y, THEME.list), s.value)
        ed.OnEvent("Change", (ct, *) => SetVal(s, ct.Value))
        Ctl(r, s, "Button", "x+6 yp-1 w72 h26", "Browse...").OnEvent("Click", (*) => BrowseFile(s))
        s.main := ed
        AddReset(r, s, y)
        return Max(bottom, y + 28) + 10
    case "color":
        bottom := LabelBlock(r, s, x, y)
        ed := Ctl(r, s, "Edit", Format("x{} y{} w80 r1 Limit6 Background{}", CX, y, THEME.list), s.value)
        ed.OnEvent("Change", (ct, *) => (StrLen(ct.Value) = 6 ? SetVal(s, ct.Value) : 0))
        s.sw := Ctl(r, s, "Text", Format("x+8 yp w28 h24 Border Background{}", s.value), "")
        Ctl(r, s, "Button", "x+8 yp-1 w80 h26", "Pick...").OnEvent("Click", (*) => PickColor(s))
        s.main := ed
        AddReset(r, s, y)
        return Max(bottom, y + 28) + 12
    case "bppreview":
        bottom := LabelBlock(r, s, x, y)
        ed := Ctl(r, s, "Edit", Format("x{} y{} w230 r1 Background{}", CX, y, THEME.list), s.value)
        ed.OnEvent("Change", (ct, *) => (s.value := ct.Value, UpdateBP()))
        s.main := ed
        s.out := PreviewBox(r, Max(bottom, y + 28) + 6, "With these settings, it becomes this boilerplate hotstring:", 3)
        return TextBottom(s.out) + 14
    case "list":
        bottom := LabelBlock(r, s, x, y, RX - x - 48)
        items := SplitList(s.value)
        lb := Ctl(r, s, "ListBox", Format("x{} y{} w400 r{} Background{}", x, bottom + 6, Max(4, Min(12, items.Length)), THEME.list), items)
        s.main := lb
        Ctl(r, s, "Button", Format("x{} y{} w190 h28", x + 410, bottom + 6), "Add...").OnEvent("Click", (*) => ListAdd(s))
        Ctl(r, s, "Button", "xp y+6 w190 h28", "Remove selected").OnEvent("Click", (*) => ListRemove(s))
        Ctl(r, s, "Button", "xp y+6 w190 h28", s.pick = "exe" ? "Pick a running program..." : "Pick an open window...").OnEvent("Click", (*) => ListPick(s))
        AddReset(r, s, y)
        return Max(TextBottom(lb), bottom + 6 + 3 * 34) + 14
    case "words":
        bottom := LabelBlock(r, s, x, y)
        words := SplitList(s.value)
        for w in SplitList(s.def "," "OR,SO,ME,AM,OK,MY,DO,GO,UP,IF,AN")
            if !HasVal(words, w)
                words.Push(w)
        s.boxes := []
        for i, w in words {
            col := Mod(i - 1, 8), row := (i - 1) // 8
            cb := Ctl(r, s, "CheckBox", Format("x{} y{} w62", x + 20 + col * 66, bottom + 8 + row * 26) (InStr("," s.value ",", "," w ",") ? " Checked" : ""), w)
            cb.OnEvent("Click", (*) => SetVal(s, CollectWords(s)))
            s.boxes.Push(cb)
        }
        s.main := s.boxes[1]
        AddReset(r, s, y)
        return bottom + 8 + Ceil(words.Length / 8) * 26 + 10
    case "flags":
        bottom := LabelBlock(r, s, x, y)
        s.boxes := Map()
        for i, f in FLAGS() {
            col := Mod(i - 1, 2), row := (i - 1) // 2
            cb := Ctl(r, s, "CheckBox", Format("x{} y{} w300", x + 20 + col * 305, bottom + 6 + row * 25), f[2])
            cb.OnEvent("Click", (*) => SetVal(s, CollectFlags(s)))
            s.boxes[f[1]] := cb
        }
        s.main := s.boxes["X"]
        RefreshCtl(s)
        AddReset(r, s, y)
        return bottom + 6 + Ceil(FLAGS().Length / 2) * 25 + 10
    }
    return y
}

SegHandler(s, v) => (*) => SetVal(s, v)
ThemeHandler(mode) => (*) => (mode != THEME.mode ? Relaunch(mode) : 0)
; Colors and row heights are fixed when controls are created, so a theme change or the
; [Section] Key switch restarts the window, so unsaved changes are offered for saving first.
; (AHK names are case-insensitive: a parameter called showIni would BE the global SHOWINI
; inside this function, so its default would refer to itself.  Hence the "new" prefixes.)
Relaunch(newTheme := "", newShowIni := "") {
    if !AskToSave("The window restarts to apply this.")
        return
    newTheme := newTheme = "" ? THEME.mode : newTheme
    newShowIni := newShowIni = "" ? SHOWINI : newShowIni
    args := (newTheme = "mine" ? "" : " /" newTheme) (MODE = "list" ? " /list" : "") (newShowIni ? "" : " /noini")
    Run('"' A_AhkPath '" "' A_ScriptFullPath '"' args)
    ExitApp()
}

; The f() box stands for B0 and X together: f() does its own backspacing (only as many
; characters as it must), so B0 never makes sense on its own, nor X without f().
FLAGS() => [["X", "Run as a function, f()   (options B0X)"], ["*", "Fire right away, without space or punctuation"]
          , ["?", "Also fire inside other words"], ["C", "Match upper/lower case exactly"]
          , ["O", "Drop the space/punctuation that triggered it"]]

AddReset(r, s, y) {
    if META.Has(s.key) && META[s.key].help != "" {
        P.SetFont("s11 norm c" THEME.dim, "Segoe UI Symbol")
        info := Ctl(r, "", "Text", Format("x{} y{} w18 Center", RX - 42, y + 1), Chr(0x24D8))     ; (i)
        info.OnEvent("Click", (*) => ShowHelp(s))
    }
    P.SetFont("s12 norm c" THEME.dim, "Segoe UI Symbol")
    arrow := Ctl(r, "", "Text", Format("x{} y{} w20 Center", RX - 20, y), Chr(0x21BA))
    FLabel()
    arrow.OnEvent("Click", (*) => ResetVal(s))
    s.reset := arrow
}

BuildSoundBtns(r, y) {
    Ctl(r, "", "Button", Format("x{} y{} w120 h28", X0, y + 6), "Turn all on").OnEvent("Click", (*) => AllSounds(1))
    Ctl(r, "", "Button", "x+8 yp w120 h28", "Turn all off").OnEvent("Click", (*) => AllSounds(0))
    return y + 48
}
AllSounds(v) {
    for k in SOUNDS {
        s := BYKEY[k], s.value := v
        RefreshCtl(s), SetVal(s, v)
    }
}

BuildLogPreview(r, y) {
    global LogPrev
    FDesc()
    Ctl(r, "", "Text", Format("x{} y{} w400", X0 + 24, y), "With those ticked, a line in the AutoCorrect log looks like this:")
    P.SetFont("s9 norm c" THEME.font, "Consolas")
    LogPrev := Ctl(r, "", "Text", Format("x{} y{} w{} h34 Background{}", X0 + 24, y + 20, RX - X0 - 54, THEME.list), "")
    FLabel()
    return y + 68
}
UpdateLogPreview() {
    if !IsObject(LogPrev)
        return
    line := FormatTime(, "yyyy-MM-dd") ' -- :B0X*:nothign::f("nothing")'
    if BYKEY["ACSystem.LogRuleLocation"].value
        line .= "    BP:311"
    if BYKEY["ACSystem.LogExtendedDetail"].value
        line .= "    " FormatTime(, "HH:mm:ss") "    nothign -> nothing"
    if BYKEY["ACSystem.LogActiveExe"].value
        line .= "    [notepad.exe]"
    LogPrev.Text := line
}

; A boxed, monospaced sample line, like the AutoCorrect log preview.  Returns the text control.
PreviewBox(r, y, caption, lines := 2) {
    FDesc()
    Ctl(r, "", "Text", Format("x{} y{} w{}", X0 + 24, y, RX - X0 - 54), caption)
    P.SetFont("s9 norm c" THEME.font, "Consolas")
    box := Ctl(r, "", "Text", Format("x{} y{} w{} h{} Background{}", X0 + 24, y + 20, RX - X0 - 54, lines * 15 + 4, THEME.list), "")
    FLabel()
    return box
}
BuildAcPreview(r, y) {
    global AcPrev
    AcPrev := PreviewBox(r, y, "With these settings, a new AutoCorrect hotstring looks like this:")
    return TextBottom(AcPrev) + 14
}

; One hotstring line the way Hotstring Helper writes it (see AutoCorrect2.ahk, the f()
; branch of the append code): f() gets ", 0" / ", 0, 1" / ", 1, 1" only when Log / Paste
; differ from f()'s defaults (log=1, paste=0); the Web Freq comment only goes on f() lines.
HsLine(opts, trig, repl, isFunc, log, paste, comment := "") {
    if !isFunc
        return ":" opts ":" trig "::" repl
    extra := (log && !paste) ? "" : (!log && !paste) ? ", 0" : (!log && paste) ? ", 0, 1" : ", 1, 1"
    return ":" opts ":" trig '::f("' repl '"' extra ")" (comment != "" ? " `; " comment : "")
}

; Hotstring Helper's suggested boilerplate trigger (AutoCorrect2.ahk, the boilerplate
; branch): the FIRST LETTER of each word LONGER than MinWordLength, until there are
; FirstLettersToInclude letters; lower-cased; between the prefix and suffix.
BpTrigger(text) {
    n := BYKEY["HotstringHelper.FirstLettersToInclude"].value, m := BYKEY["HotstringHelper.MinWordLength"].value
    initials := ""
    if IsNumber(n) && n > 0
        Loop Parse, StrReplace(text, "`n", " "), A_Space, A_Tab {
            if StrLen(A_LoopField) > m
                initials .= SubStr(A_LoopField, 1, 1)
            if StrLen(initials) >= n
                break
        }
    return BYKEY["HotstringHelper.BoilerplatePrefix"].value StrLower(initials) BYKEY["HotstringHelper.BoilerplateSuffix"].value
}

; Fills DefaultEditor and EditorCmd from one choice.  The command shapes are the ones
; AutoCorrect2.ahk builds itself when EditorCmd is blank.
EditorPreset(s) {
    static T := Map(
        "vscode", ["C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe", '"<exe>" -r -g "{file}:{line}"'],
        "npp", ["C:\Program Files\Notepad++\notepad++.exe", '"<exe>" -n{line} "{file}"'],
        "notepad", ["notepad.exe", '"<exe>" "{file}"'])
    if !T.Has(s.value)
        return
    for key, v in Map("Shared.DefaultEditor", T[s.value][1], "Shared.EditorCmd", StrReplace(T[s.value][2], "<exe>", T[s.value][1])) {
        o := BYKEY[key], o.value := v
        RefreshCtl(o), SetVal(o, v)
    }
}

BuildTable(r, y) {
    ; The stays-open / closes choice sits ABOVE the list, so it is on screen while you work
    ; at the top of it; right-clicking a row offers the same choices.
    Ctl(r, "", "Text", Format("x{} y{}", X0, y + 5), "After the selected button is clicked, Hotstring Helper:")
    rs := Ctl(r, "", "Radio", "Group x+12 yp Disabled", "stays open")
    rc := Ctl(r, "", "Radio", "x+14 yp Disabled", "closes")
    lv := Ctl(r, "", "ListView", Format("x{} y{} w{} r{} Checked -Multi NoSortHdr Background{}", X0, y + 30, RX - X0 - 10, r.members.Length, THEME.list)
        , ["Button", "After a click, Hotstring Helper..."])
    for i, s in r.members {
        parts := StrSplit(s.value, ",", " ")
        lv.Add(parts[1] ? "Check" : "", s.label, AfterText(parts))
        s.lvrow := i, s.lv := lv
    }
    lv.ModifyCol(1, 390), lv.ModifyCol(2, 240)
    lv.OnEvent("ItemCheck", (l, row, chk) => (m := r.members[row], SetVal(m, (chk ? 1 : 0) "," After(m))))
    lv.OnEvent("ItemSelect", TableSelect.Bind(r, rs, rc))
    lv.OnEvent("ContextMenu", TableMenu.Bind(r, rs, rc))
    rs.OnEvent("Click", (*) => TableAfter(r, lv, "stay"))
    rc.OnEvent("Click", (*) => TableAfter(r, lv, "close"))
    return TextBottom(lv) + 12
}
TableMenu(r, rs, rc, lv, row, isRightClick, x, y) {
    if !row
        return
    lv.Modify(row, "Select Focus")
    TableSelect(r, rs, rc, lv, row, true)
    s := r.members[row], shown := !!StrSplit(s.value, ",", " ")[1]
    m := Menu()
    m.Add("Show this button", (*) => (lv.Modify(row, shown ? "-Check" : "Check"), SetVal(s, (shown ? 0 : 1) "," After(s))))
    m.Add()
    m.Add("Hotstring Helper stays open", (*) => (TableAfter(r, lv, "stay"), rs.Value := 1, rc.Value := 0))
    m.Add("Hotstring Helper closes", (*) => (TableAfter(r, lv, "close"), rs.Value := 0, rc.Value := 1))
    if shown
        m.Check("Show this button")
    m.Check(After(s) = "stay" ? "Hotstring Helper stays open" : "Hotstring Helper closes")
    m.Show()
}
After(s) => (parts := StrSplit(s.value, ",", " "), parts.Length > 1 && parts[2] = "close" ? "close" : "stay")
AfterText(parts) => !parts[1] ? "(hidden)" : (parts.Length > 1 && parts[2] = "close") ? "closes" : "stays open"
TableSelect(r, rs, rc, lv, row, selected) {
    if !selected || !row
        return
    rs.Enabled := rc.Enabled := true
    rs.Value := After(r.members[row]) = "stay", rc.Value := !rs.Value
}
TableAfter(r, lv, after) {
    if !(row := lv.GetNext())
        return
    s := r.members[row]
    SetVal(s, StrSplit(s.value, ",", " ")[1] "," after)
}

; ============================================================================
; Views: which rows show, and where
; ============================================================================
RowMatches(r) {
    switch VIEW {
    case "all": return true
    case "ess": return r.kind = "set" && r.s.ess
    case "search": return !!InStr(r.hay, QUERY)
    case "changed":
        if r.kind = "table" {
            for m in r.members
                if IsMod(m)
                    return true
            return false
        }
        return SubStr(r.s.key, 1, 1) != "_" && (IsMod(r.s) || (r.s.link != "" && IsMod(BYKEY[r.s.link])))
    }
    return r.sec = VIEW
}

Reflow() {
    global VIRTH, SHOWN
    multi := !SECMAP.Has(VIEW)                       ; more than one section can show
    grpAny := Map(), secAny := Map(), SHOWN := 0
    for r in ROWS {
        r.show := (r.kind = "set" || r.kind = "table") && RowMatches(r)
        if r.show
            grpAny[r.sec "|" r.grp] := 1, secAny[r.sec] := 1, SHOWN += 1
    }
    for r in ROWS
        switch r.kind {
        case "grp", "extra": r.show := VIEW != "ess" && grpAny.Has(r.sec "|" r.grp)
        case "note": r.show := (VIEW = r.sec || VIEW = "all")
        case "sec": r.show := multi && secAny.Has(r.sec)
        }
    ScrollTo(0)
    SendMessage(0x000B, 0, 0, P)                     ; WM_SETREDRAW off while rows move
    y := 2
    for r in ROWS {
        if r.show {
            for i, ct in r.ctrls
                ct.Move(r.pos[i][1], y + r.pos[i][2])
            if !r.vis
                for ct in r.ctrls
                    ct.Visible := true
            r.vis := true, r.y := y, y += r.h
            if r.kind = "set" && r.s.HasProp("reset")
                r.s.reset.Visible := IsMod(r.s)
        } else if r.vis {
            for ct in r.ctrls
                ct.Visible := false
            r.vis := false
        }
    }
    VIRTH := y + 14
    SendMessage(0x000B, 1, 0, P)
    DllCall("RedrawWindow", "Ptr", P.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x485)   ; invalidate + erase + children + frame
    SetScroll()
    ApplyDeps()
}

ShowView(id, q := "") {
    global VIEW, QUERY
    VIEW := id, QUERY := q
    Reflow()
    n := SHOWN " setting" (SHOWN = 1 ? "" : "s")
    switch id {
    case "ess":
        TitleTxt.Text := "Essentials"
        DescTxt.Text := "The handful most people change.  Each one also sits in its own section; the list on the left and the search box reach everything else."
    case "all":
        TitleTxt.Text := "All settings"
        DescTxt.Text := "Every section in one list.  The names on the left jump to a section."
    case "changed":
        TitleTxt.Text := "Changed from default"
        DescTxt.Text := SHOWN ? n " differ" (SHOWN = 1 ? "s" : "") " from the shipped defaults (acSettings.default.ini).  The arrow at the right of a row puts the default back." : "Everything is at its default."
    case "search":
        TitleTxt.Text := "Search: " q
        DescTxt.Text := SHOWN ? n " matched, in names, descriptions and ini key names." : "Nothing matches."
    default:
        TitleTxt.Text := SECMAP[id].title, DescTxt.Text := SECMAP[id].desc
    }
}

OnNav(*) {
    SearchEd.Value := ""
    GoNav()
}
GoNav() {
    i := NavLB.Value ? NavLB.Value : 1
    if i = 1
        ShowView("ess")
    else if i = SECS.Length + 2
        ShowView("changed")
    else if MODE = "list" {
        if VIEW != "all"
            ShowView("all")
        ScrollTo(Round(SECS[i - 1].row.y * DPI))
    } else
        ShowView(SECS[i - 1].id)
}
SetMode(m) {
    global MODE := m
    SearchEd.Value := ""
    GoNav()
}
DoSearch() {
    q := Trim(SearchEd.Value)
    if q = ""
        GoNav()
    else
        ShowView("search", q)
}

; ---------------------------------------------------------------- scrolling (pixels)
ClientH() {
    rc := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", P.Hwnd, "Ptr", rc)
    return NumGet(rc, 12, "Int")
}
SetScroll() {
    si := Buffer(28, 0)                               ; SCROLLINFO: range + page + pos
    NumPut("UInt", 28, "UInt", 0x7, "Int", 0, "Int", Max(Round(VIRTH * DPI) - 1, 0), "UInt", ClientH(), "Int", SCROLLY, si)
    DllCall("SetScrollInfo", "Ptr", P.Hwnd, "Int", 1, "Ptr", si, "Int", 1)
}
ScrollTo(y) {
    global SCROLLY
    y := Max(0, Min(y, Round(VIRTH * DPI) - ClientH()))
    if y != SCROLLY {
        DllCall("ScrollWindow", "Ptr", P.Hwnd, "Int", 0, "Int", SCROLLY - y, "Ptr", 0, "Ptr", 0)
        SCROLLY := y
    }
    SetScroll()
}
; In the long list, the section under the top edge is the one highlighted on the left.
SyncNav() {
    if VIEW != "all"
        return
    idx := 2
    for i, o in SECS
        if Round(o.row.y * DPI) <= SCROLLY + 60
            idx := i + 1
    if NavLB.Value != idx
        NavLB.Choose(idx)
}
OnVScroll(wParam, lParam, msg, hwnd) {
    if hwnd != P.Hwnd
        return
    page := ClientH()
    switch wParam & 0xFFFF {
    case 0: ScrollTo(SCROLLY - 40)
    case 1: ScrollTo(SCROLLY + 40)
    case 2: ScrollTo(SCROLLY - page + 40)
    case 3: ScrollTo(SCROLLY + page - 40)
    case 4, 5:
        si := Buffer(28, 0)
        NumPut("UInt", 28, "UInt", 0x10, si)          ; SIF_TRACKPOS
        DllCall("GetScrollInfo", "Ptr", P.Hwnd, "Int", 1, "Ptr", si)
        ScrollTo(NumGet(si, 24, "Int"))
    case 6: ScrollTo(0)
    case 7: ScrollTo(Round(VIRTH * DPI))
    }
    SyncNav()
    return 0
}
; Keeping the window its own size on a monitor with a different scale.
; Moved to such a monitor, the window's FRAME was shrunk to that monitor's scale while the
; controls inside kept their size, so the right edge was cut off.  (Neither answering
; WM_GETDPISCALEDSIZE / WM_DPICHANGED nor per-monitor awareness stopped it.)  So: note the
; outer size once shown, and after a scale change or the end of a drag, put it back if it
; changed.  The thread is switched to per-monitor mode for the measuring: a timer started
; during a drag runs system-aware, where GetWindowRect gives scaled, not physical, pixels
; (see ScreenSnip's SnipDpiEnter).  The window has no +Resize, so any other size is wrong.
OuterSize(&w, &h) {
    rc := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", G.Hwnd, "Ptr", rc)
    w := NumGet(rc, 8, "Int") - NumGet(rc, 0, "Int"), h := NumGet(rc, 12, "Int") - NumGet(rc, 4, "Int")
}
RememberSize() {
    global WinOuterW, WinOuterH
    prev := DpiEnter()
    OuterSize(&WinOuterW, &WinOuterH)
    DpiLeave(prev)
}
KeepSize() {
    if !WinOuterW
        return
    prev := DpiEnter()
    OuterSize(&w, &h)
    if w != WinOuterW || h != WinOuterH
        DllCall("SetWindowPos", "Ptr", G.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", WinOuterW, "Int", WinOuterH
            , "UInt", 0x16)                            ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
    DpiLeave(prev)
}
DpiEnter() {
    prev := 0
    try prev := DllCall("SetThreadDpiAwarenessContext", "Ptr", -3, "Ptr")
    return prev
}
DpiLeave(prev) {
    if prev
        try DllCall("SetThreadDpiAwarenessContext", "Ptr", prev, "Ptr")
}
S16(v) => v > 0x7FFF ? v - 0x10000 : v
OnWheel(wParam, lParam, msg, hwnd) {
    mx := S16(lParam & 0xFFFF), my := S16((lParam >> 16) & 0xFFFF)
    rc := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", P.Hwnd, "Ptr", rc)
    if mx < NumGet(rc, 0, "Int") || mx >= NumGet(rc, 8, "Int") || my < NumGet(rc, 4, "Int") || my >= NumGet(rc, 12, "Int")
        return
    try {
        if WinGetClass(hwnd) = "ComboBox" && SendMessage(0x0157, 0, 0, hwnd)     ; an open drop-down keeps the wheel
            return
    }
    ScrollTo(SCROLLY - Round(S16((wParam >> 16) & 0xFFFF) / 120 * 90))
    SyncNav()
    return 0
}

; ============================================================================
; Values
; ============================================================================
SetVal(s, v) {
    s.value := v
    switch s.type {
    case "cbtn": s.lv.Modify(s.lvrow, , , AfterText(StrSplit(v, ",", " ")))
    case "flags":
        if s.link != ""
            BYKEY[s.link].value := InStr(v, "X", true) ? 1 : 0
    case "color": s.sw.Opt("Background" v), s.sw.Redraw()
    case "hotkey": CheckClashes()
    }
    if s.HasProp("reset") && s.r.vis
        s.reset.Visible := IsMod(s)
    if InStr(s.key, "HotstringHelper.")
        UpdateBP()
    if InStr(s.key, "ACSystem.Log")
        UpdateLogPreview()
    if s.HasProp("onset")
        (s.onset)(s)
    ApplyDeps()
    UpdateStatus()
}

ResetVal(s) {
    s.value := s.def
    RefreshCtl(s)
    SetVal(s, s.def)
}

; Push s.value back into its controls (reset / cancel / a control that sets another).
RefreshCtl(s) {
    switch s.type {
    case "toggle": s.main.Value := !!s.value
    case "slider": s.main.Value := s.value, s.valTxt.Text := FmtVal(s, s.value)
    case "number", "text", "file", "color", "bppreview": s.main.Value := s.value
    case "combo": s.main.Text := s.value
    case "ddl":
        for i, o in s.opts
            if "" o[1] = "" s.value
                s.main.Choose(i)
    case "seg":
        for i, o in s.opts
            s.radios[i].Value := ("" o[1] = "" s.value)
    case "hotkey": s.main.Value := StrReplace(s.value, "#"), s.win.Value := !!InStr(s.value, "#")
    case "list":
        s.main.Delete(), s.main.Add(SplitList(s.value))
    case "words":
        for cb in s.boxes
            cb.Value := !!InStr("," s.value ",", "," cb.Text ",")
    case "flags":
        set := ParseFlags(s.value)
        for f, cb in s.boxes
            cb.Value := set.Has(f)
    case "cbtn":
        parts := StrSplit(s.value, ",", " ")
        s.lv.Modify(s.lvrow, parts[1] ? "Check" : "-Check", , AfterText(parts))
    }
}

IsMod(s) => s.type = "hotkey" ? HkNorm(s.value) != HkNorm(s.def) : ("" s.value) !== ("" s.def) && !(IsNumber(s.value) && IsNumber(s.def) && s.value = s.def)
Changed(s) => s.type = "hotkey" ? HkNorm(s.value) != HkNorm(s.orig) : ("" s.value) !== ("" s.orig)

HkNorm(h) {
    mods := ""
    for m in ["#", "^", "!", "+"]
        if RegExMatch(h, "^[#^!+<>*~$]*\Q" m "\E")
            mods .= m
    return mods StrLower(RegExReplace(h, "^[#^!+<>*~$]+"))
}

FmtVal(s, v) => (s.HasProp("fmt") && s.fmt = "sec") ? Format("{:.1f} seconds", v / 1000) : v (s.HasProp("unit") && s.unit != "" ? " " s.unit : "")

SliderMoved(s, final := false) {
    v := Round(s.main.Value / s.step) * s.step
    v := Max(s.min, Min(s.max, v))
    if final
        s.main.Value := v
    s.valTxt.Text := FmtVal(s, v)
    if "" v != "" s.value
        SetVal(s, v)
}
OnHScroll(wParam, lParam, msg, hwnd) {
    if SLIDERS.Has(lParam)
        SliderMoved(SLIDERS[lParam])
}

ApplyDeps() {
    for s in ALL
        if s.dep != "" {
            on := !!BYKEY[s.dep].value
            for ct in s.ctrls
                ct.Enabled := on
        }
}

CheckClashes() {
    for s in ALL
        if s.type = "hotkey" {
            msg := ""
            for o in ALL
                if o != s && o.type = "hotkey" && HkNorm(o.value) = HkNorm(s.value) && s.value != ""
                    msg := "Same as '" o.label "'"
            s.warn.Text := msg
        }
}

ParseFlags(v) {
    set := Map()
    if InStr(v, "B0", true) && InStr(v, "X", true)
        set["X"] := 1
    for f in ["*", "?", "C", "O"]
        if InStr(v, f, true)
            set[f] := 1
    return set
}
; Ticking f() writes B0X; options the boxes don't manage (K10, SI, T...) are kept.
CollectFlags(s) {
    out := s.boxes["X"].Value ? "B0X" : ""
    for f in ["*", "?", "C", "O"]
        if s.boxes[f].Value
            out .= f
    rest := StrReplace(StrReplace(s.value, "B0", "", true), "X", "", true)
    for f in ["*", "?", "C", "O"]
        rest := StrReplace(rest, f, "", true)
    return out rest
}
CollectWords(s) {
    out := ""
    for cb in s.boxes
        if cb.Value
            out .= (out = "" ? "" : ",") cb.Text
    return out
}

; Both "Adding hotstring rules" previews: the AutoCorrect sample line, and the boilerplate
; made from the sample text.  Called whenever a [HotstringHelper] value changes.
UpdateBP() {
    if IsObject(AcPrev) {
        isF := ParseFlags(HV("HotstringHelper.DefaultAutoCorrectOpts")).Has("X")
        AcPrev.Text := HsLine(HV("HotstringHelper.DefaultAutoCorrectOpts"), "becuase", "because", isF
            , HV("HotstringHelper.AcLogByDefault"), HV("HotstringHelper.AcPasteByDefault")
            , HV("HotstringHelper.AutoCommentWithFreqAndStats") ? "Web Freq 211.43 | Fixes 2 words" : "")
    }
    if BYKEY.Has("_bpPreview") && BYKEY["_bpPreview"].HasProp("out") {
        text := HV("_bpPreview")
        isF := ParseFlags(HV("HotstringHelper.DefaultBoilerPlateOpts")).Has("X")
        BYKEY["_bpPreview"].out.Text := HsLine(HV("HotstringHelper.DefaultBoilerPlateOpts"), BpTrigger(text), text, isF
            , HV("HotstringHelper.BpLogByDefault"), HV("HotstringHelper.BpPasteByDefault"))
    }
}

HV(key) => BYKEY[key].value
SplitList(v) {
    out := []
    for item in StrSplit(v, ",", " `t")
        if item != ""
            out.Push(item)
    return out
}
HasVal(arr, v) {
    for item in arr
        if item = v
            return true
    return false
}
JoinList(arr) {
    out := ""
    for item in arr
        out .= (A_Index = 1 ? "" : ",") item
    return out
}
ListAdd(s, v := "") {
    if v = "" {
        res := InputBox(s.pick = "exe" ? "Program file name, e.g. MyGame.exe" : "Part of the window title", "Add", "w320 h120")
        if res.Result != "OK"
            return
        v := Trim(StrReplace(res.Value, ","))
    }
    arr := SplitList(s.value)
    if v = "" || HasVal(arr, v)
        return
    arr.Push(v), s.main.Add([v])
    SetVal(s, JoinList(arr))
}
ListRemove(s) {
    if !(i := s.main.Value)
        return
    arr := SplitList(s.value), arr.RemoveAt(i), s.main.Delete(i)
    SetVal(s, JoinList(arr))
}
ListPick(s) {
    seen := Map(), m := Menu()
    for hwnd in WinGetList() {
        try {
            if !(WinGetStyle(hwnd) & 0x10000000) || hwnd = G.Hwnd      ; visible windows only
                continue
            v := s.pick = "exe" ? WinGetProcessName(hwnd) : WinGetTitle(hwnd)
        } catch
            continue
        if v = "" || seen.Has(v) || v = "explorer.exe"
            continue
        seen[v] := 1
        m.Add(v, ((val, *) => ListAdd(s, val)).Bind(v))
    }
    if !seen.Count
        m.Add("(nothing found)", (*) => 0), m.Disable("(nothing found)")
    m.Show()
}
BrowseFile(s) {
    f := FileSelect(3, A_ScriptDir "\..", "Choose a file for: " s.label)
    if f = ""
        return
    s.main.Value := f
    SetVal(s, f)
}
PickColor(s) {
    static cust := Buffer(64, 0)
    cc := Buffer(A_PtrSize * 9, 0)
    NumPut("UInt", cc.Size, cc, 0)
    NumPut("Ptr", G.Hwnd, cc, A_PtrSize)
    rgb := Integer("0x" s.value)
    NumPut("UInt", ((rgb & 0xFF) << 16) | (rgb & 0xFF00) | ((rgb >> 16) & 0xFF), cc, 3 * A_PtrSize)
    NumPut("Ptr", cust.Ptr, cc, 4 * A_PtrSize)
    NumPut("UInt", 0x3, cc, 5 * A_PtrSize)                    ; CC_RGBINIT | CC_FULLOPEN
    if !DllCall("comdlg32\ChooseColorW", "Ptr", cc)
        return
    bgr := NumGet(cc, 3 * A_PtrSize, "UInt")
    v := Format("{:02x}{:02x}{:02x}", bgr & 0xFF, (bgr >> 8) & 0xFF, (bgr >> 16) & 0xFF)
    s.main.Value := v
    SetVal(s, v)
}

; ============================================================================
; Footer
; ============================================================================
ChangedList() {
    out := []
    for s in ALL
        if SubStr(s.key, 1, 1) != "_" && Changed(s)
            out.Push(s)
    return out
}
UpdateStatus() {
    n := ChangedList().Length
    StatusTxt.Text := n ? n " unsaved change" (n = 1 ? "" : "s") : "No unsaved changes"
}
ApplyAll(close) {
    global IniTime, BackedUp
    ch := ChangedList()
    if TEST || !ch.Length {
        if !ch.Length && !close
            MsgBox("No changes to save.", "Settings Dashboard", "Iconi Owner" G.Hwnd)
        if close
            ExitApp()
        return true
    }
    ; Something else (the Settings Manager, an editor) saved the ini since we read it.  Only
    ; the keys changed here get written, so its other edits survive -- but say so.
    if FileExist(IniPath) && IniTime != "" && FileGetTime(IniPath, "M") != IniTime
        && MsgBox("acSettings.ini was changed by another program after the Settings Dashboard opened."
            . "`n`nSave anyway?  Only the settings you changed here are written; everything else in the file stays as it is now."
            , "Settings Dashboard", "YesNo Icon! Owner" G.Hwnd) != "Yes"
        return false
    if !BackedUp && FileExist(IniPath) {
        try {
            DirCreate(A_ScriptDir "\..\Debug\Backups")
            FileCopy(IniPath, A_ScriptDir "\..\Debug\Backups\acSettings_" FormatTime(, "yyyyMMdd_HHmmss") ".ini", 1)
            BackedUp := true
        }
    }
    restarts := Map(), failed := ""
    for s in ch {
        parts := StrSplit(s.key, ".")
        try {
            IniWrite(IniValue(s.value), IniPath, parts[1], parts[2])
            s.orig := s.value
            if s.restart != ""
                restarts[s.restart] := 1
        } catch as e
            failed .= "`n[" parts[1] "] " parts[2] ":  " e.Message
    }
    IniTime := FileExist(IniPath) ? FileGetTime(IniPath, "M") : ""
    UpdateStatus()
    if failed != ""
        MsgBox("These settings could not be saved:" failed, "Settings Dashboard", "Iconx Owner" G.Hwnd)
    OfferRestarts(restarts)
    if close && failed = ""
        ExitApp()
    return failed = ""
}

; Restart the programs that read the saved keys -- only the ones already running (the others
; read the ini when they next start).  Each is a renamed AutoHotkey.exe with #SingleInstance
; Force, so running it again replaces the running copy.
OfferRestarts(restarts) {
    running := []
    for exe in restarts
        if ProcessExist(exe) && (path := FindProgram(exe)) != ""
            running.Push(path)
    if !running.Length
        return
    names := ""
    for path in running {
        SplitPath(path, &n)
        names .= "`n   " n
    }
    if MsgBox("Saved.  These programs need a restart to use the new settings:" names "`n`nRestart them now?"
        , "Settings Dashboard", "YesNo Iconi Owner" G.Hwnd) != "Yes"
        return
    for path in running {
        SplitPath(path, , &dir)
        try Run('"' path '"', dir)
    }
}
FindProgram(exe) {
    if InStr(exe, "\")
        return FileExist(A_ScriptDir "\" exe) ? A_ScriptDir "\" exe : ""
    for dir in ["\..\Core\", "\..\Tools\", "\"]
        if FileExist(A_ScriptDir dir exe)
            return A_ScriptDir dir exe
    return ""
}

; Unsaved changes: Yes saves, No drops them, Cancel stays.  Returns false for Cancel.
AskToSave(why := "") {
    if TEST || !(n := ChangedList().Length)
        return true
    r := MsgBox((why != "" ? why "`n`n" : "") "Save your " n " unsaved change" (n = 1 ? "" : "s") " first?"
        , "Settings Dashboard", "YesNoCancel Icon? Owner" G.Hwnd)
    if r = "Cancel"
        return false
    return r = "No" || ApplyAll(false)
}
CloseDashboard() {
    if AskToSave()
        ExitApp()
    return true                                     ; true = keep the window open
}

; IniRead strips one pair of outer quotes, so a value that holds quotes of its own (EditorCmd)
; must be written back wrapped in an extra pair, or the next read loses them.
IniValue(v) => InStr(v, '"') ? '"' v '"' : v

CancelAll() {
    for s in ChangedList() {
        s.value := s.orig
        RefreshCtl(s)
        SetVal(s, s.orig)
    }
}

; ============================================================================
; /test -- build-only self check (the window is never shown)
; ============================================================================
RunSelfTest() {
    global MODE
    out := Format("{} rows, {} settings ({} with no control of their own)`n", ROWS.Length, ALL.Length, ALL.Length - CountKind("set"))
    views := ["ess"]
    for o in SECS
        views.Push(o.id)
    views.Push("all"), views.Push("changed")
    for v in views {
        ShowView(v)
        out .= Format("{:-8} {:3} settings   height {:5}`n", v, SHOWN, VIRTH)
    }
    ; geometry: nothing past the right edge, no two controls of a row on top of each other,
    ; no checkbox narrower than its caption
    ShowView("all")
    problems := 0
    for r in ROWS {
        name := r.kind = "set" ? r.s.key : r.kind " " (r.HasProp("label") ? SubStr(r.label, 1, 30) : "")
        rects := []
        for ct in r.ctrls {
            ct.GetPos(&bx, &by, &bw, &bh)
            if bx + bw > PW - 17
                out .= "WIDE     " name "  " ct.Type " ends at " (bx + bw) "`n", problems += 1
            if by + bh > r.y + r.h + 1
                out .= "TALL     " name "  " ct.Type " ends " (by + bh - r.y - r.h) " below its row`n", problems += 1
            if ct.Type != "UpDown"
                rects.Push([bx, by, bw, bh, ct.Type])
            if ct.Type = "CheckBox" && ct.Text != "" {
                probe := P.Add("Text", "Hidden", ct.Text)
                probe.GetPos(, , &tw)
                if tw + 22 > bw
                    out .= "CLIPPED  " name "  '" ct.Text "' needs " (tw + 22) ", has " bw "`n", problems += 1
            }
        }
        for i, a in rects
            for j, b in rects
                if j > i && a[1] < b[1] + b[3] && b[1] < a[1] + a[3] && a[2] < b[2] + b[4] && b[2] < a[2] + a[4]
                    out .= "OVERLAP  " name "  " a[5] " / " b[5] "`n", problems += 1
    }
    ; the panel with its scroll bar must lie inside the main window (the window itself is not shown here, so compare with WINW/WINH)
    rc := Buffer(16)
    DllCall("GetWindowRect", "Ptr", P.Hwnd, "Ptr", rc)
    DllCall("MapWindowPoints", "Ptr", 0, "Ptr", G.Hwnd, "Ptr", rc, "UInt", 2)
    pr := NumGet(rc, 8, "Int"), pb := NumGet(rc, 12, "Int")
    out .= Format("panel outer edge: right {} of {}, bottom {} of {}`n", pr, Round(WINW * DPI), pb, Round(WINH * DPI))
    if pr > Round(WINW * DPI) || pb > Round(WINH * DPI)
        out .= "OUTSIDE  the scrolling panel hangs past the main window`n", problems += 1
    out .= "geometry problems: " problems "`n"
    NavLB.GetPos(, &ny, , &nh)
    out .= "nav list bottom: " (ny + nh) "`n"

    ; exercise each control type's change path
    SetVal(BYKEY["ACSystem.SuppressAfterBackspace"], 0)
    out .= "dep greys child: " (!BYKEY["ACSystem.SuppressSeconds"].main.Enabled ? "ok" : "FAIL") "`n"
    ResetVal(BYKEY["ACSystem.BackspaceWindow"])
    out .= "slider reset: " BYKEY["ACSystem.BackspaceWindow"].valTxt.Text "`n"
    s := BYKEY["Hotkeys.SystemUpTimeHk"], SetVal(s, "^F3"), CheckClashes()
    out .= "clash: " s.warn.Text "`n"
    s := BYKEY["HotstringHelper.DefaultAutoCorrectOpts"], s.boxes["X"].Value := 0, SetVal(s, CollectFlags(s))
    out .= "flags: " s.value "   linked MakeAcFuncByDefault=" BYKEY["HotstringHelper.MakeAcFuncByDefault"].value
        . "   Log box greyed: " (!BYKEY["HotstringHelper.AcLogByDefault"].main.Enabled ? "ok" : "FAIL") "`n"
    out .= "ac preview, no f(): " AcPrev.Text "`n"
    s.boxes["X"].Value := 1, SetVal(s, CollectFlags(s))
    out .= "ac preview, f(): " AcPrev.Text "`n"
    out .= "bp: " BYKEY["_bpPreview"].out.Text "`n"
    out .= "log line: " LogPrev.Text "`n"
    s := BYKEY["ACSystem.LogActiveExe"], s.value := 0, RefreshCtl(s), SetVal(s, 0)
    out .= "log line, no exe: " LogPrev.Text "`n"
    AllSounds(0)
    n := 0
    for k in SOUNDS
        n += !BYKEY[k].value
    out .= "all sounds off: " n " of " SOUNDS.Length "`n"
    s := BYKEY["_editorPreset"], s.value := "notepad", RefreshCtl(s), SetVal(s, "notepad")
    out .= "editor preset: " BYKEY["Shared.DefaultEditor"].value "  |  " BYKEY["Shared.EditorCmd"].value "`n"
    SetVal(BYKEY["ControlButtons.Suggester"], "1,close")
    ShowView("search", "beep"), out .= "search 'beep': " SHOWN "`n"
    ShowView("search", "MakeAcFuncByDefault"), out .= "search 'MakeAcFuncByDefault': " SHOWN "`n"
    ShowView("search", "Typo"), out .= "search 'Typo' (a Control Panel button): " SHOWN "`n"
    ShowView("changed"), out .= "changed view: " SHOWN "`n"
    MODE := "list", NavLB.Choose(5), GoNav()
    out .= Format("list mode, jump to section 4: view {}  scroll {}  (section at {})`n", VIEW, SCROLLY, Round(SECS[4].row.y * DPI))
    ScrollTo(999999), SyncNav()
    out .= "scrolled to the end: nav shows item " NavLB.Value " of " (SECS.Length + 2) "`n"
    out .= "status: " StatusTxt.Text "`n"
    CancelAll()
    out .= "after cancel: " StatusTxt.Text "`n"
    out .= CoverageReport()
    TestOut(out)
}
; Which ini keys the dashboard places, which fell through to "More settings", which no tool
; owns but the json doesn't describe, and which placed keys the ini no longer has.
CoverageReport() {
    out := "`n---- ini coverage ----`n", iniKeys := Map(), owned := 0
    if FileExist(IniPath)
        for sec in StrSplit(IniRead(IniPath), "`n")
            for line in StrSplit(IniRead(IniPath, Trim(sec)), "`n")
                if p := InStr(line, "=")
                    iniKeys[Trim(sec) "." Trim(SubStr(line, 1, p - 1))] := 1
    for k in iniKeys
        owned += IsToolOwned(k)
    placed := 0, stale := "", nojson := ""
    for s in ALL
        if SubStr(s.key, 1, 1) != "_" {
            placed += 1
            if !iniKeys.Has(s.key)
                stale .= "   " s.key "`n"
            if !META.Has(s.key)
                nojson .= "   " s.key "`n"
        }
    out .= Format("ini keys {}  |  placed by the dashboard {} (incl. {} in More settings)  |  owned by a tool, not shown {}`n", iniKeys.Count, placed, MOREKEYS.Length, owned)
    for k in MOREKEYS
        out .= "MORE     " k "`n"
    if stale != ""
        out .= "Placed here but missing from acSettings.ini (stale, or not added yet):`n" stale
    if nojson != ""
        out .= "Not described in acSettingsMetadata.json (no (i) button):`n" nojson
    return out
}
; A renamed AutoHotkey.exe has no console, so the report goes to a file, which is then opened.
TestOut(text) {
    try FileDelete(TestFile)
    FileAppend("SettingsDashboard self-test  " FormatTime(, "yyyy-MM-dd HH:mm") "`n`n" text, TestFile, "UTF-8")
    Run('notepad.exe "' TestFile '"')
}
CountKind(kind) {
    n := 0
    for r in ROWS
        n += r.kind = kind
    return n
}
