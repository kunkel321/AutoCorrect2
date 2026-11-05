; This is AutoCorrectSystem.ahk
; Part of the AutoCorrect2 system
; Contains the logger and backspace detection functionality and other things
; Version: 8-5-2026
; 8-3-2026 restructure: keepText() is now the single source of truth for
; "Backspace pressed after autocorrection."  When its InputHook ends with
; Backspace, it calls BackspaceContextLogger.NotifyBackspaced() directly.
; The context logger's own InputHook (bsih) no longer detects the Backspace
; itself -- it only maintains the word cache and collects following words.
; This fixes several ways the <<-marked items could be missed by the context
; log (bsih deaf-window during hook restart, digit-filter veto, IsRecent
; timing skew, and the waitingForExtra lockout).

;===============================================================================
;                         AutoCorrect System Module
;===============================================================================
; Master switch to enable/disable logging globally
; Setting this to 0 in the acSettings.ini file will:
; 1. Disable the autocorrection log (AutoCorrectsLog.txt)
; 2. Disable the 'continuous' autocorrection log (ACLogContinuous.txt)
; 3. Disable the backspace context logger (ErrContextLog.txt)
; 4. Skip all logging operations but maintain other functionality
; This can improve performance and reduce disk writes for users
; who don't need the logging features


; Logger file paths are set in Class Config in AutoCorrect2.ahk.
If Config.EnableLogging {
    If not FileExist(Config.AutoCorrectsLogFile)
        FileAppend(
            "========== AUTO CORRECTION LOG =============`n"
            "Intended for use with kunkel321's 'AutoCorrect for v2' package.  Log of all autocorrects sent via f(unction). YYYY-MM-DD date format. ‘<<’ indicates that Backspace was pressed right after, ‘--’ indicates that it was not.  The ACLogAnalyzer tool reads from this, and culls items from it.`n"
            "=======================================`n", Config.AutoCorrectsLogFile)
    If not FileExist(Config.ACLogContinuousFile)
        FileAppend(
            "===== CONTINUOUS AUTO CORRECTION LOG =======`n"
            "Intended for use with kunkel321's 'AutoCorrect for v2' package.  Log of all autocorrects sent via f(unction).  YYYY-MM-DD date format. ‘<<’ indicates that Backspace was pressed right after, ‘--’ indicates that it was not.  The ACLogStatistics tool reads from this.  Items are NEVER CULLED from this file.  This will allow an accurate measure of BS-to-Kept ratios over time.`n"
            "=======================================`n", Config.ACLogContinuousFile)
    If not FileExist(Config.ErrContextLog)
        FileAppend(
            "This will be the log of extended context information for backspaced autocorrections.`n"
            "Date Y-M-D`titem`t`t`tcontext`n"
            "===============================================", Config.ErrContextLog)
}

;================== Variable Declarations ======================================
Global IsRecent := 0  ; Flag to track if a hot string was recently triggered.
; NOTE 8-3-2026: IsRecent is no longer read by BackspaceContextLogger (keepText
; notifies it directly now).  Still set/reset in f() in case anything else in
; the suite references it.  Safe to remove if nothing does.
Global lastTrigger := ""  ; Tracks the last used trigger (see recentTriggers for display)
Global recentTriggers := []                      ; Rolling cache of last 3 triggers (not saved to INI)
; Backspace-undo suppression: rule text -> A_TickCount of the Backspace that undid it.
; While an entry is younger than Config.SuppressSeconds, f() leaves that rule's
; trigger alone so the user can type e.g. "UE4SS" past a :*:ue::eu rule.
Global SuppressedRules := Map()

; Name of the focused process, or "" if Windows can't resolve one (focus is
; mid-transition, or a fullscreen game owns input).  WinGetProcessName("A")
; throws in those cases and this gets called from inside #HotIf evaluations,
; where an uncaught throw must never escape.
ActiveExeName() {
    try return WinGetProcessName("A")
    catch
        return ""
}

;===============================================================================
; The main autocorrection logger f() function
; This function is called by all the f-style hotstrings in the library
; "replace" param is mandatory.  Log and paste are optional. 
;===============================================================================
f(replace := "", log := 1, paste := 0) {
    static HSInputBuffer := InputBuffer()
    HSInputBuffer.Start()

    trigger := A_ThisHotkey
    endchar := A_EndChar
    Global lastTrigger := StrReplace(trigger, "B0X", "") "::" replace

    ; Capture the focused .exe now, before any focus change, for the log line.
    activeExe := Config.LogActiveExe ? ActiveExeName() : ""
    ruleHotkey := trigger ; ":opts:trig" exactly as written in the library -- RuleLocation()'s key

    ; Backspace-undo suppression.  If the user backspaced this same rule less than
    ; SuppressSeconds ago, do nothing: every library rule is B0, so the typed text
    ; is still intact on screen.  A different rule on the same word is unaffected.
    Global SuppressedRules
    if (Config.SuppressAfterBackspace && SuppressedRules.Has(lastTrigger)
        && (A_TickCount - SuppressedRules[lastTrigger]) < Config.SuppressSeconds * 1000) {
        HSInputBuffer.Stop()
        trigOnly := SubStr(trigger, InStr(trigger, ":",,,2)+1)
        if (log && Config.EnableLogging = 1)
            SetTimer(keepText.bind(lastTrigger, trigOnly, "", activeExe, "~~", ruleHotkey), -1)
        return
    }

    ; Maintain rolling cache of last 3 triggers (resets on script restart; not saved to INI)
    Global recentTriggers
    recentTriggers.Push(lastTrigger)
    if (recentTriggers.Length > 3)
        recentTriggers.RemoveAt(1)

    trigger := SubStr(trigger, inStr(trigger, ":",,,2)+1)
    TrigLen := StrLen(trigger) + StrLen(endchar)
    origReplace := replace ; Rarify below strips the shared prefix; the log wants the whole word.

    If paste {
        SendInput("{BS " TrigLen "}")
        clipSaved := ClipboardAll()
        A_Clipboard := replace
        if ClipWait(0.5)  {
            Send "^v" ; Where the magic happens...
            Sleep 150
        }
        A_Clipboard := clipSaved
    } Else {
        ; Rarify: Only remove and replace rightmost necessary chars.
        trigArr := StrSplit(trigger)
        replArr := StrSplit(replace)
        ignorLen := 0

        Loop Min(trigArr.Length, replArr.Length) {
            If (trigArr[A_Index] == replArr[A_Index])
                ignorLen++
            else
                break
        }

        replace := SubStr(replace, (ignorLen+1))
        replace := StrReplace(replace, "'", "`'")
        endchar := StrReplace(endchar, "!", "{!}")
        SendInput("{BS " (TrigLen - ignorLen) "}" replace endchar)
    }

    HSInputBuffer.Stop()

    If (Config.BeepOnAutoCorrection = 1)
        SoundBeep(900, 60)

    if (log && Config.EnableLogging = 1) {
        SetTimer(keepText.bind(LastTrigger, trigger, origReplace, activeExe, "", ruleHotkey), -1)
        Global IsRecent := 1
        setTimer (*) => IsRecent := 0, -(Config.BackspaceWindow)
    } else if Config.SuppressAfterBackspace {
        ; Unlogged rules (f(r, 0)) still get backspace suppression: keepText() is
        ; what records it, and it never runs for them.
        SetTimer(WatchBackspace.bind(lastTrigger), -1)
    }
}

;===============================================================================
; Automatically logs (if enabled) if an autocorrect happens, and if the 
; user presses Backspace within the specified timeout
;===============================================================================
; Log line format -- the first 14 characters are fixed, because every analysis
; tool (ACLogAnalyzer, ACLogStatistics, ACHotstringsStats, HotstringAnalyzer,
; TypoInvaders) reads the date from columns 1-10, the marker from 12-13 and the
; hotstring from column 15 up to the first TAB.  Everything after that TAB is
; optional detail those tools ignore (LogRuleLocation / LogExtendedDetail / LogActiveExe):
;   YYYY-MM-DD -- :opts:trig::repl<TAB>BP:311<TAB>HH:MM:SS<TAB>typed -> result<TAB>[exe]
; Markers:  --  kept   <<  backspaced within BackspaceWindow   ~~  suppressed
; (rule skipped because the user backspaced it moments ago, see f()).
; trigText / replText are the bare trigger and full replacement, used to work
; out the whole word that changed.  activeExe is "" unless LogActiveExe is on.
; ruleHotkey is the raw ":opts:trig", looked up by RuleLocation(); location, if
; given, is used instead (the caps fix has no library line: SYS:<its line here>).
#MaxThreadsPerHotkey 5 ; Allow up to 5 instances of the function.
keepText(KeepForLog, trigText := "", replText := "", activeExe := "", marker := "", ruleHotkey := "", location := "", *) {       
    Global SuppressedRules
    ruleKey := KeepForLog ; Unescaped -- must match the key f() looks up in SuppressedRules.
    KeepForLog := StrReplace(KeepForLog, "`n", "``n") ; Fixes triggers spanning two lines.
    KeepForLog := StrReplace(KeepForLog, "`t", "``t") ; A TAB would end the hotstring field for every log reader.

    ; Work out the whole word that changed.  WordArr holds words the context
    ; logger has already cached (endchar-triggered rules); bsih.Input holds the
    ; partial word still being typed (* rules fire before an endchar).
    beforeWord := trigText
    afterWord  := replText
    trigLen    := StrLen(trigText)
    if (trigLen && marker = "") {
        found := false
        ; A * rule (and the caps fix) fires before the end char, so its word is not
        ; cached yet: the cached ones are all earlier words, and one can end the same
        ; way ("the" for a THe fix).  Only bsih.Input has it.
        wordArr := RegExMatch(ruleHotkey, "^:[^:]*\*") ? [] : BackspaceContextLogger.WordArr
        Loop wordArr.Length {
            entry := wordArr[wordArr.Length - A_Index + 1] ; most recent first
            bracketPos := InStr(entry, "[")
            if !bracketPos
                continue
            fullWord := SubStr(entry, 1, bracketPos - 1)
            if (StrLen(fullWord) >= trigLen && SubStr(fullWord, -trigLen) = trigText) {
                beforeWord := fullWord
                afterWord  := SubStr(fullWord, 1, -trigLen) . replText
                found := true
                break
            }
        }
        if !found {
            ; bsih.Input is everything typed since the last Space/Tab/Enter/BS
            ; the hook saw, which can include earlier lines.  Keep only the
            ; trailing run of non-whitespace -- the word actually being typed.
            rawInput := ""
            try rawInput := BackspaceContextLogger.bsih.Input
            if RegExMatch(rawInput, "\S+$", &m) && StrLen(m[0]) >= trigLen && SubStr(m[0], -trigLen) = trigText {
                beforeWord := m[0]
                afterWord  := SubStr(m[0], 1, -trigLen) . replText
            }
        }
    }
    if !Config.LogRuleLocation
        location := ""
    else if (location = "" && ruleHotkey != "") {
        location := RuleLocation(ruleHotkey)
        if (location = "")
            location := "unknown" ; in neither library -- still says so, rather than a missing field
    }
    detail := location != "" ? "`t" location : ""
    if Config.LogExtendedDetail
        detail .= "`t" A_Hour ":" A_Min ":" A_Sec "`t" StrReplace(StrReplace(beforeWord " -> " afterWord, "`n", "``n"), "`t", "``t")
    if (activeExe != "")
        detail .= "`t[" activeExe "]"

    ; Suppressed: nothing was sent, so there is no Backspace to wait for.
    if (marker = "~~") {
        logEntry := "`n" A_YYYY "-" A_MM "-" A_DD " ~~ " KeepForLog (location != "" ? "`t" location : "") (Config.LogExtendedDetail ? "`t" A_Hour ":" A_Min ":" A_Sec "`t" beforeWord " (suppressed)" : "") (activeExe != "" ? "`t[" activeExe "]" : "")
        FileAppend(logEntry, Config.AutoCorrectsLogFile)
        FileAppend(logEntry, Config.ACLogContinuousFile)
        return
    }
    ; lih is LOCAL on purpose (was global).  With overlapping instances, a global
    ; lih gets overwritten by the newer instance's hook, so the older instance
    ; would read EndKey from the WRONG hook after Wait() returned (false '--').
    lih := InputHook("B V I1 E T" (Config.BackspaceWindow / 1000), "{Backspace}") ; "logger input hook." T is time-out. BackspaceWindow is in ms (e.g. 500 = 0.5s).
    lih.Start()
    lih.Wait()
    
    ; Determine hyphen style based on whether Backspace was pressed
    wasBackspaced := (lih.EndKey = "Backspace")
    hyphen := wasBackspaced ? " << " : " -- "

    ; Single source of truth for the context logger: if this correction got
    ; backspaced, tell BackspaceContextLogger directly.  (It no longer detects
    ; the Backspace on its own, so << in the main logs and entries in
    ; ErrContextLog.txt can never disagree about WHETHER to log.)
    ; Notify before the FileAppends so following-word collection starts promptly.
    if wasBackspaced
        BackspaceContextLogger.NotifyBackspaced(KeepForLog)
    if wasBackspaced
        SuppressedRules[ruleKey] := A_TickCount ; see f(): mutes this rule for SuppressSeconds
    
    ; Log the autocorrection with timestamp and hyphen style
    logEntry := "`n" A_YYYY "-" A_MM "-" A_DD hyphen KeepForLog detail
    FileAppend(logEntry, Config.AutoCorrectsLogFile) ; For ACLogAnalyzer. Gets culled from.
    FileAppend(logEntry, Config.ACLogContinuousFile) ; For ACLogStatistics. Never gets culled. 
}
#MaxThreadsPerHotkey 1

; keepText()'s Backspace watch without the log line, for corrections f() does
; not log.  Same window, same SuppressedRules key.
WatchBackspace(ruleKey) {
    Global SuppressedRules
    lih := InputHook("B V I1 E T" (Config.BackspaceWindow / 1000), "{Backspace}")
    lih.Start()
    lih.Wait()
    if (lih.EndKey = "Backspace")
        SuppressedRules[ruleKey] := A_TickCount
}

; Where a rule lives, for the log: ":opts:trig" -> "BP:311" / "AC:4146" ("" if not
; found, e.g. the caps fix's synthetic rules).  BP is scanned first -- it is included
; first, so its copy of a duplicate is the one that fires.  The index is rebuilt only
; when either library changes on disk (HH appends new rules), so this runs from
; keepText()'s timer, after the correction has been sent.
RuleLocation(ruleHotkey) {
    static index := Map(), loose := Map(), stamp := ""
    libs := [["BP", Config.BoilerplateHotstringLibrary], ["AC", Config.HotstringLibrary]]
    now := ""
    for lib in libs
        try now .= FileGetTime(lib[2]) FileGetSize(lib[2]) "|"
    if (now != stamp) {
        index := Map(), loose := Map(), stamp := now
        for lib in libs {
            try Loop Read lib[2] {
                if RegExMatch(A_LoopReadLine, "^\s*(:[^:\s]*:.+?)::", &m) && !index.Has(m[1]) {
                    index[m[1]] := lib[1] ":" A_Index
                    if !loose.Has(k := RuleLooseKey(m[1]))
                        loose[k] := lib[1] ":" A_Index
                }
            }
        }
    }
    if index.Has(ruleHotkey)
        return index[ruleHotkey]
    return loose.Get(RuleLooseKey(ruleHotkey), "")
}

; ":opts:trig" with the options sorted: a rule HH registered live can spell its
; options in another order than the line it appended (B0X*? vs *?B0X).
RuleLooseKey(ruleHotkey) {
    if !RegExMatch(ruleHotkey, "^:([^:]*):(.*)$", &m)
        return ruleHotkey
    return Sort(RegExReplace(StrUpper(m[1]), "(.)", "$1`n")) ":" m[2]
}

;===============================================================================
; Backspace Context Logger
; Constantly keeps a cache of the last several words typed. If an autocorrection 
; is logged, and backspace is pressed within timeout, the cached words AND 
; the next X words are logged to help identify misfires. Doesn't cache digit-words.
; 8-3-2026: Detection of "Backspace after autocorrection" now comes from
; keepText() calling NotifyBackspaced() -- the same hook that decides << vs --
; in the main logs.  The bsih hook below only caches words, so its brief
; stop/restart gaps can no longer cause missed context entries.
;===============================================================================
class BackspaceContextLogger {
    static WordArr := []
    static waitingForExtra := false
    static extraWordsCount := 0
    static LogEntry := ""
    static timeoutTimer := 0
    static bsih := 0
    static isRunning := false
    static capturedTrigger := ""
    static DebugMode := false
    static DebugTimer := 0
    
    ; Start the logger
    static Start() {
        ; Don't start if logging is disabled globally
        if (Config.EnableLogging = 0)
            return

        if (this.isRunning)
            return
            
        this.isRunning := true
        
        ; Initialize the input hook for backspace context logging
        this.bsih := InputHook("B V I1 E", "{Space}{Backspace}{Tab}{Enter}")
        
        ; Start the logger loop in a new thread
        SetTimer(() => this.LoggerLoop(), -50)
    }
    
    ; Called by keepText() when Backspace was pressed within the window after an
    ; autocorrection.  Begins (or restarts) a context capture for that trigger.
    static NotifyBackspaced(trigger) {
        if (Config.EnableLogging = 0)
            return
        
        ; If a previous capture is still collecting following words, flush it
        ; NOW so this new event isn't lost.  (Previously a second backspaced
        ; correction during the collection window was silently dropped.)
        ; The flushed entry just has fewer following words than usual.
        if (this.waitingForExtra)
            this.LogContent()  ; its finally block resets all capture state
        
        this.capturedTrigger := trigger
        this.extraWordsCount := 0
        this.waitingForExtra := true
        
        ; Cancel any lingering timeout timer before creating a new one.
        ; (LogContent's finally already does this if we flushed, but be safe.)
        if (this.timeoutTimer) {
            try SetTimer(this.timeoutTimer, 0)
            this.timeoutTimer := 0
        }
        
        ; Set timeout to log even if not enough following words arrive.
        ; Honors Config.FollowingWordTimeout (in seconds); falls back to 8s if misconfigured.
        timeoutSec := Config.FollowingWordTimeout
        if (!IsNumber(timeoutSec) || timeoutSec <= 0)
            timeoutSec := 8
        this.timeoutTimer := ObjBindMethod(this, "LogContent")
        SetTimer(this.timeoutTimer, -Integer(timeoutSec * 1000))
    }
    
    ; ; Toggle debug mode on/off
    ; static ToggleDebug() {
    ;     this.DebugMode := !this.DebugMode
        
    ;     if (this.DebugMode) {
    ;         ; Start debug tooltip updates every 500ms
    ;         this.DebugTimer := ObjBindMethod(this, "UpdateDebugTooltip")
    ;         SetTimer(this.DebugTimer, 500)
    ;         ToolTip("DEBUG MODE ON - BackspaceContextLogger")
    ;         SetTimer(() => ToolTip(), -2000)
    ;     } else {
    ;         ; Stop debug tooltip updates
    ;         if (this.DebugTimer) {
    ;             SetTimer(this.DebugTimer, 0)
    ;             this.DebugTimer := 0
    ;         }
    ;         ToolTip()
    ;     }
    ; }
    
    ; ; Update debug tooltip with current state
    ; static UpdateDebugTooltip() {
    ;     if (!this.DebugMode)
    ;         return
        
    ;     ; Build the preceding words display
    ;     precedingWords := ""
    ;     for word in this.WordArr {
    ;         precedingWords .= word " "
    ;     }
    ;     if (precedingWords = "")
    ;         precedingWords := "(none)"
        
    ;     debugText := "=== BackspaceContextLogger Debug ==="
    ;         . "`nPreceding words: " precedingWords
    ;         . "`nCaptured trigger: " this.capturedTrigger
    ;         . "`nWaiting for extra: " (this.waitingForExtra ? "YES" : "NO")
    ;         . "`nFollowing words captured: " this.extraWordsCount
    ;         . "`nTo be logged: " (this.waitingForExtra ? "YES - collecting context" : "NO - caching only")
        
    ;     ToolTip(debugText)
    ; }
    
    ; Process and format the log entry
    static LogContent() {
        try {
            ; Skip logging if globally disabled
            if (Config.EnableLogging = 0) {
                this.waitingForExtra := false
                this.extraWordsCount := 0
                this.WordArr := []
                this.capturedTrigger := ""
                if (this.timeoutTimer) {
                    SetTimer(this.timeoutTimer, 0)
                    this.timeoutTimer := 0
                }
                return
            }
            if !this.waitingForExtra  ; Don't proceed if we're no longer waiting
                return
                
            this.LogEntry := ""
            For wArr in this.WordArr {
                this.LogEntry .= wArr
            }
            
            ; Format the log entry with nicer symbols
            this.LogEntry := StrReplace(this.LogEntry, "]Space]", "] - ]")
            this.LogEntry := StrReplace(this.LogEntry, "]Backspace]", "] < ]")
            this.LogEntry := StrReplace(this.LogEntry, "[Space[", "[ - [")
            this.LogEntry := StrReplace(this.LogEntry, "[Backspace[", "[ < [")
            
            ; Remove doubles
            this.LogEntry := StrReplace(this.LogEntry, "[[", "[")
            this.LogEntry := StrReplace(this.LogEntry, "]]", "]")
            this.LogEntry := StrReplace(this.LogEntry, "  ", " ")

            ; Create the log entry with date stamp
            dateStamp := "`n" A_YYYY "-" A_MM "-" A_DD
            
            ; Use the captured trigger (not the current global one, which may have been overwritten)
            formattedTrigger := StrReplace(this.capturedTrigger, "`n", "``n") ; Fix multiline triggers
            
            ; Add tabs based on length to align columns
            tabs := StrLen(formattedTrigger) > 14 ? "`t" : "`t`t"
            
            ; Write to the log file
            FileAppend(dateStamp " << " formattedTrigger tabs "---> " this.LogEntry, Config.ErrContextLog)
            
            ; Play sound notification if enabled.  Fired via one-shot timer so
            ; the ~400ms of synchronous beeping doesn't block the calling thread
            ; (which may be the LoggerLoop, delaying the bsih hook restart).
            If (Config.beepOnContextLog = 1)
                SetTimer((*) => (SoundBeep(600, 200), SoundBeep(400, 200)), -1)
        }
        catch as e {
            ; Was FileAppend to '..\Data\error_log.txt' -- a path that doesn't
            ; exist relative to the script dir, so the append itself threw and
            ; the error was never recorded.  Use the suite's LogError() helper
            ; (defined in AutoCorrect2.ahk) instead, guarded with try.
            try LogError("BackspaceContextLogger.LogContent: " e.Message)
        }
        finally {
            ; CRITICAL: Always reset state, even if there's an error
            ; This prevents the logger from getting stuck in "waiting" mode
            this.LogEntry := ""
            this.waitingForExtra := false
            this.extraWordsCount := 0
            this.WordArr := []
            this.capturedTrigger := ""
            
            ; CRITICAL: Always cancel existing timeout timer
            if (this.timeoutTimer) {
                SetTimer(this.timeoutTimer, 0)
                this.timeoutTimer := 0
            }
        }
    }
    
    ; The main logger loop
    static LoggerLoop() {
        try {
            Loop {
                try {
                    ; CRITICAL FIX: Stop InputHook before restarting it
                    ; This prevents state corruption from repeated Start/Wait calls on same object
                    if (A_Index > 1) {
                        try {
                            this.bsih.Stop()
                        }
                        catch {
                            ; If Stop() fails, create a new InputHook
                            this.bsih := InputHook("B V I1 E", "{Space}{Backspace}{Tab}{Enter}")
                        }
                    }
                    
                    Sleep(5)  ; Brief pause to allow InputHook cleanup
                    
                    this.bsih.Start()
                    this.bsih.Wait()

                    ; Digit filter: words containing digits are not CACHED, but
                    ; (unlike before) they no longer veto anything else -- the
                    ; old 'continue' here could skip Backspace detection entirely.
                    ; Detection now lives in NotifyBackspaced(), so this only
                    ; governs what goes into the word cache.
                    hasDigit := RegExMatch(this.bsih.Input, "\d")
                        
                    If (this.waitingForExtra) {
                        If (this.bsih.EndKey = "Space") {
                            ; Count every Space-ended word toward the following-
                            ; word quota (even digit-words, though those aren't
                            ; cached) so the capture completes promptly.
                            this.extraWordsCount++
                            If !hasDigit {
                                this.WordArr.Push(this.bsih.Input "]" this.bsih.EndKey "]")
                                
                                ; Maintain limited history
                                If (this.WordArr.Length > (Config.precedingWordCount + Config.followingWordCount))
                                    this.WordArr.RemoveAt(1)
                            }
                            
                            ; Log when we have enough following words
                            If (this.extraWordsCount > Config.followingWordCount) {
                                this.LogContent()
                            }
                        }
                        Else If (this.bsih.EndKey = "Backspace" && !hasDigit) {
                            ; Record further backspacing during collection (shows
                            ; as ' < ' in the entry).  Doesn't count toward the
                            ; following-word quota.
                            this.WordArr.Push(this.bsih.Input "]" this.bsih.EndKey "]")
                            If (this.WordArr.Length > (Config.precedingWordCount + Config.followingWordCount))
                                this.WordArr.RemoveAt(1)
                        }
                    } 
                    else If !hasDigit {
                        this.WordArr.Push(this.bsih.Input "[" this.bsih.EndKey "[")
                        
                        ; Maintain limited history
                        If (this.WordArr.Length > Config.precedingWordCount)
                            this.WordArr.RemoveAt(1)
                    }
                }
                catch as e {
                    ; CRITICAL FIX: Reset state on error to prevent stuck state
                    ; If we don't reset here, the logger could stay in "waiting" mode permanently,
                    ; causing every subsequent keystroke to be logged.
                    ; NOTE: the old FileAppend to '..\Data\error_log.txt' threw
                    ; (bad path), which killed this loop permanently with no
                    ; trace -- the likely 'silent death' failure mode.
                    try LogError("BackspaceContextLogger loop: " e.Message)
                    
                    this.waitingForExtra := false
                    this.extraWordsCount := 0
                    this.WordArr := []
                    this.capturedTrigger := ""
                    if (this.timeoutTimer) {
                        try {
                            SetTimer(this.timeoutTimer, 0)
                        }
                        catch {
                            this.timeoutTimer := 0
                        }
                        
                    }
                    
                    Sleep(100)
                }
            }
        }
        catch as e {
            ; Mark as not running FIRST (the old code logged first, and since the
            ; log path was bad, the FileAppend threw and isRunning stayed true --
            ; so Start() refused to ever restart the dead logger).
            this.isRunning := false
            try LogError("BackspaceContextLogger critical: " e.Message)
            ; Attempt an automatic restart after a short delay.
            SetTimer(() => this.Start(), -1000)
        }
    }
}

; ; DEBUG HOTKEY: Press Ctrl+Shift+D to toggle BackspaceContextLogger debug mode
; ^+d::BackspaceContextLogger.ToggleDebug() ; hide



;================================================================================================
/* InputBuffer Class by Descolada https://www.autohotkey.com/boards/viewtopic.php?f=83&t=122865
 * Note:  The mouse-relevant parts were removed by kunkel321, via ChatGPT4.
 * InputBuffer can be used to buffer user input for keyboard, mouse, or both at once. 
 * The default InputBuffer (via the main class name) is keyboard only, but new instances
 * can be created via InputBuffer().
 * 
 * InputBuffer(keybd := true, mouse := false, timeout := 0)
 *      Creates a new InputBuffer instance. If keybd/mouse arguments are numeric then the default 
 *      InputHook settings are used, and if they are a string then they are used as the Option 
 *      arguments for InputHook and HotKey functions. Timeout can optionally be provided to call
 *      InputBuffer.Stop() automatically after the specified amount of milliseconds (as a failsafe).
 * 
 * InputBuffer.Start()               => initiates capturing input
 * InputBuffer.Release()             => releases buffered input and continues capturing input
 * InputBuffer.Stop(release := true) => releases buffered input and then stops capturing input
 * InputBuffer.ActiveCount           => current number of Start() calls
 *                                      Capturing will stop only when this falls to 0 (Stop() decrements it by 1)
 * InputBuffer.SendLevel             => SendLevel of the InputHook
 *                                      InputBuffers default capturing SendLevel is A_SendLevel+2, 
 *                                      and key release SendLevel is A_SendLevel+1.
 * InputBuffer.IsReleasing           => whether Release() is currently in action
 * InputBuffer.Buffer                => current buffered input in an array
 */
;================================================================================================

class InputBuffer {
    Buffer := []
    SendLevel := A_SendLevel + 2
    ActiveCount := 0
    IsReleasing := 0
    
    static __New() => this.DefineProp("Default", {value:InputBuffer()})
    static __Get(Name, Params) => this.Default.%Name%
    static __Set(Name, Params, Value) => this.Default.%Name% := Value
    static __Call(Name, Params) => this.Default.%Name%(Params*)

    __New(keybd := true, timeout := 0) {
        if !keybd
            throw Error("Keyboard input type must be specified")
            
        this.Timeout := timeout
        this.Keybd := keybd

        if keybd {
            if keybd is String {
                if RegExMatch(keybd, "i)I *(\d+)", &lvl)
                    this.SendLevel := Integer(lvl[1])
            }
            this.InputHook := InputHook(keybd is String ? keybd : "I" (this.SendLevel) " L0 *")
            this.InputHook.NotifyNonText  := true
            this.InputHook.VisibleNonText := false
            this.InputHook.OnKeyDown      := this.BufferKey.Bind(this,,,, "Down")
            this.InputHook.OnKeyUp        := this.BufferKey.Bind(this,,,, "Up")
            this.InputHook.KeyOpt("{All}", "N S")
        }
        this.HotIfIsActive := this.GetActiveCount.Bind(this)
    }

    BufferKey(ih, VK, SC, UD) => (this.Buffer.Push(Format("{{1} {2}}", GetKeyName(Format("vk{:x}sc{:x}", VK, SC)), UD)))

    Start() {
        this.ActiveCount += 1
        SetTimer(this.Stop.Bind(this), -this.Timeout)
        if this.ActiveCount > 1
            return
        this.Buffer := []
        if this.Keybd
            this.InputHook.Start()
    }

    Release() {
        if this.IsReleasing
            return []

        sent := []
        this.IsReleasing := 1
        
        ; Try to send all keystrokes, then check if any more were added
        PrevSendLevel := A_SendLevel
        SendLevel this.SendLevel - 1
        
        while this.Buffer.Length {
            key := this.Buffer.RemoveAt(1)
            sent.Push(key)
            Send(key)
        }
        
        SendLevel PrevSendLevel
        this.IsReleasing := 0
        return sent
    }

    Stop(release := true) {
        if !this.ActiveCount
            return
            
        sent := release ? this.Release() : []
        
        if --this.ActiveCount
            return
            
        if this.Keybd
            this.InputHook.Stop()
            
        return sent
    }

    GetActiveCount(HotkeyName) => this.ActiveCount
}

;===============================================================================
; Reports information about hotstrings or displays the last used trigger
; Can be called with:
; - "Button" (default): Shows statistics about hotstring usage
; - "lastTrigger": Shows the last used trigger
;===============================================================================

Hotkey(Config.LastTriggerHk, (*) => StringAndFixReport("lastTrigger"))  ; Default: Alt+F3
Hotkey(Config.StringReportHk, (*) => StringAndFixReport())              ; Default: Ctrl+F3

StringAndFixReport(caller := "Button") {
    ; Handle different cases based on caller parameter
    if (caller = "lastTrigger") {
        Global recentTriggers
        if (recentTriggers.Length = 0) {
            thisMessage := "No f-wrapped hotstrings triggered yet this session."
        } else {
            ; Build numbered list of recent triggers, newest last (most recent at bottom)
            ; Truncate each entry: max 100 chars on first line, max 10 lines total
            TruncateTrigger(entry) {
                lines := StrSplit(entry, "`n")
                totalLines := lines.Length
                firstLine := lines[1]

                ; Truncate the first line if over 100 chars
                truncatedFirst := (StrLen(firstLine) > 100) ? SubStr(firstLine, 1, 100) "…" : firstLine

                ; Build display: up to 10 lines
                if (totalLines <= 1) {
                    return truncatedFirst
                }
                displayLines := [truncatedFirst]
                shownLines := Min(totalLines, 10)
                Loop shownLines - 1  ; already added line 1 above
                    displayLines.Push("        " lines[A_Index + 1])
                result := ""
                for i, ln in displayLines
                    result .= (i = 1 ? "" : "`n") ln
                if (totalLines > 10)
                    result .= "`n        […+" (totalLines - 10) " more lines]"
                return result
            }

            ; Show oldest → newest so the most recent is at the bottom
            thisMessage := "Recent Hotstrings:`n"
            Loop recentTriggers.Length {
                i := A_Index
                ; Display number counts down from oldest: 3, 2, 1  (1 = most recent)
                displayNum := recentTriggers.Length - i + 1
                entry := recentTriggers[i]
                thisMessage .= "`n" displayNum ".  " TruncateTrigger(entry)
            }
        }
        ; Append logging-disabled notice as a footnote, not as a replacement
        if (Config.EnableLogging = 0)
            thisMessage .= "`n`n*(Logging is currently disabled — trigger cache is still active.)*"
        buttPos := ""
        windowTitle := "Last Triggered Hotstring"
    }
    else { 
        ; Generate hotstring statistics report
        try {
            HsLibContents := FileRead(Config.HotstringLibrary)
            thisOptions := "", regulars := 0, begins := 0, middles := 0, ends := 0, fixes := 0, entries := 0, freq := 0
            
            Loop Parse HsLibContents, '`n' {
                If SubStr(Trim(A_LoopField),1,1) != ':'
                    continue
                    
                entries++
                thisOptions := SubStr(Trim(A_LoopField), 1, InStr(A_LoopField, ':',,,2)) ; get options part of hotstring
                
                If InStr(thisOptions, '*') and InStr(thisOptions, '?')
                    middles++
                Else If InStr(thisOptions, '*')
                    begins++
                Else If InStr(thisOptions, '?')
                    ends++
                Else
                    regulars++
                    
                If RegExMatch(A_LoopField, 'Fixes\h*\K\d+', &fn) ; Extract fix count from comments  
                    fixes += fn[]
                    
                ; Extract web frequency value from comments
                If RegExMatch(A_LoopField, 'Web Freq\h*\K[\d\.]+', &wf)
                    freq += wf[]
            }
            
            ; Format numbers with commas
            numberFormat(num) {
                formattedNum := num
                Loop 5 {    ; '5' to prevent endless loop
                    oldNum := formattedNum
                    formattedNum := RegExReplace(formattedNum, "(\d)(\d{3}(\,|$))", "$1,$2") 
                    if (formattedNum == oldNum) ; If no more changes, exit the loop
                        break
                }
                return formattedNum
            }
            
            thisMessage := ( 
            'The ' Config.HotstringLibrary ' component of`n'
            Config.ScriptName ' contains the following '
            '`nhotstring stats as of ' A_MMMM ' ' A_DD ', ' A_YYYY '.'
            '`n================================'
            '`n    Regular Autocorrects:`t' numberFormat(regulars)
            '`n *  Word Beginnings:`t`t' numberFormat(begins)
            '`n *? Word Middles:`t`t' numberFormat(middles)
            '`n ?  Word Ends:`t`t' numberFormat(ends)
            '`n================================'
            '`n   Total Entries:`t`t' numberFormat(entries)
            '`n   Potential Fixes:`t`t' numberFormat(fixes)
            '`n   Web Freq Billions:`t`t' numberFormat(Round(freq/1000,2))
            )
        }
        catch Error as err {
            thisMessage := "Could not read hotstring library`n" err.Message
            LogError("StringAndFixReport: " err.Message) ; LogError function is in AutoCorrect2.ahk
        }
        
        buttPos := "x90"
        windowTitle := "Hotstring Statistics"
    }

    ; Create the GUI report window
    fixRepGui := Gui(, windowTitle)
    fixRepGui.SetFont(Config.FontColor)
    fixRepGui.SetFont(Config.LargeFontSize)
    fixRepGui.BackColor := Config.FormColor
    
    ; Use an Edit control for selectable text, styled as a label
    editBackgroundOption := "Background" Config.FormColor
    fixRepGui.Add('Edit', '-VScroll ReadOnly -E0x200 -WantReturn -TabStop ' editBackgroundOption, thisMessage)
    
    ; Add control buttons
    closeBtn := fixRepGui.AddButton(buttPos, "Close")
    fixRepGui.AddButton("x+8", "Copy Text").OnEvent("Click", (*) => A_Clipboard := thisMessage)
    
    ; Show the GUI
    fixRepGui.Show("x" A_ScreenWidth/10) ; Appear to the left side
    
    ; Set up event handlers
    closeBtn.Focus() ; Move focus to the close button to avoid highlighting text
    closeBtn.OnEvent("click", (*) => fixRepGui.Destroy())
    fixRepGui.OnEvent("Escape", (*) => fixRepGui.Destroy())
    
    return fixRepGui ; Return the GUI object for reference
}

; ==============================================================================
;       AUto-COrrect TWo COnsecutive CApitals
; This version by forum user Ntepa. Updated 8-7-2023.
; https://www.autohotkey.com/boards/viewtopic.php?p=533067#p533067
; Minor edits added by kunkel321 2-7-2024

#Hotstring Z0 ; <--- Experimental.  Turns off allowing key presses to count toward multiple hotstring triggers. 

fix_consecutive_caps()
fix_consecutive_caps() {
; Hotstring only works if CapsLock is off.
	; These are created with Hotstring(), so the textual
	; "#HotIf AutoCorrectionsActivelyRunning()" around the library include does
	; NOT cover them -- without the second condition all 676 caps-fix
	; hotstrings stay live in skiplisted apps and when autocorrect is toggled off.
	HotIf (*) => !GetKeyState("CapsLock", "T") && AutoCorrectionsActivelyRunning()
	loop 26 {
		char1 := Chr(A_Index + 64)
		loop 26 {
			char2 := Chr(A_Index + 64)
			; Create hotstring for every possible combination of two letter capital letters.
            ;If (char1 char2 != "CO")
			Hotstring(":*?CXB0Z0:" char1 char2, fix.Bind(char1, char2)) ; Z0: keep "BA" in the recognizer, so "sical" in BAsical is not a word start
		}
	}
	HotIf
	; Third letter is checked using InputHook.
	fix(char1, char2, *) {
		activeExe := Config.LogActiveExe ? ActiveExeName() : ""
		; ih := InputHook("V I101 L1")
		ih := InputHook("V I101 L1 T" Config.CapFixTimeoutMs / 1000) ; upstream: fixed T.3
		ih.OnEnd := OnEnd
		ih.Start()
		OnEnd(ih) {
			char3 := ih.Input
			if (char3 ~= "[A-Z]")  ; If char is UPPERcase alpha.
				Hotstring "Reset"
			else if (char3 ~= "[a-z]")  ; If char is lowercase alpha.
			|| ((char3 = A_Space && char1 char2 ~= "i)^(" RegExReplace(Config.CapFixTwoLetterList, "[\s,]+", "|") ")$") && Config.CapFixTwoLetterWords)
			{	SendInput("{BS 2}" StrLower(char2) char3)
                If Config.BeepOnCapFix {
                    SoundBeep(800, 80) ; Case fix announcent. 
                }
                ; Log it like any other correction.  The rule text is synthetic
                ; (there is no :*?C:TH::Th line in the library) but it is a valid
                ; hotstring, so the log tools parse it and the Backspace watch
                ; in keepText() gives it << / -- like everything else.
                If (Config.EnableLogging = 1 && Config.LogCapFixes)
                    SetTimer(keepText.bind(":*?C:" char1 char2 "::" char1 StrLower(char2)
                        , Trim(char1 char2 char3), Trim(char1 StrLower(char2) char3), activeExe
                        , "", ":*?C:" char1 char2, "SYS:" A_LineNumber), -1) ; SYS = this file
			}
		}
	}
}

#Hotstring Z ; turn it back on. 
