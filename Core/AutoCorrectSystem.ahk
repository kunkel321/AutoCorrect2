; This is AutoCorrectSystem.ahk
; Part of the AutoCorrect2 system
; Contains the logger and backspace detection functionality and other things
; Version: 10-27-2025 

;===============================================================================
;                         AutoCorrect System Module
;===============================================================================
; Master switch to enable/disable logging globally
; Setting this to 0 in the acSettings.ini file will:
; 1. Disable the autocorrection log (AutoCorrectsLog.txt)
; 2. Disable the backspace context logger (ErrContextLog.txt)
; 3. Skip all logging operations but maintain other functionality
; This can improve performance and reduce disk writes for users
; who don't need the logging features


; Logger file paths are set in Class Config in AutoCorrect2.ahk.
If Config.EnableLogging {
    If not FileExist(Config.AutoCorrectsLogFile)
        FileAppend("This will be the log of all autocorrections.`n", Config.AutoCorrectsLogFile)
    If not FileExist(Config.ErrContextLog)
        FileAppend(
            "This will be the log of extended context information for backspaced autocorrections.`n"
            "Date Y-M-D`titem`t`t`tcontext`n"
            "===============================================", Config.ErrContextLog)
}

;================== Variable Declarations ======================================
Global IsRecent := 0  ; Flag to track if a hot string was recently triggered
Global lastTrigger := "No triggers logged yet." ; Tracks the last used trigger

;===============================================================================
; The main autocorrection logger f() function
; This function is called by all the f-style hotstrings in the library
;===============================================================================
f(replace := "") {
    static HSInputBuffer := InputBuffer()
    HSInputBuffer.Start()
    
    trigger := A_ThisHotkey
    endchar := A_EndChar
    Global lastTrigger := StrReplace(trigger, "B0X", "") "::" replace ; Set 'lastTrigger' before removing options and colons.
    
    trigger := SubStr(trigger, inStr(trigger, ":",,,2)+1) ; Use everything to right of 2nd colon. 
    TrigLen := StrLen(trigger) + StrLen(endchar) ; Determine number of backspaces needed.
    
    ; Rarify: Only remove and replace rightmost necessary chars.  
    trigArr := StrSplit(trigger)
    replArr := StrSplit(replace)
    endCh := StrLen(endchar)
    ignorLen := 0
    
    ; Find matching left substring to optimize replacement
    Loop Min(trigArr.Length, replArr.Length) {
        If (trigArr[A_Index] == replArr[A_Index]) ; The double equal (==) makes it case-sensitive. 
            ignorLen++
        else 
            break
    }
    
    replace := SubStr(replace, (ignorLen+1))
    replace := StrReplace(replace, "'", "`'")
    endchar := StrReplace(endchar, "!", "{!}")
    SendInput("{BS " (TrigLen - ignorLen) "}" replace endchar) ; Type replacement and endchar. 
    
    HSInputBuffer.Stop()
    If (Config.BeepOnAutoCorrection = 1)
        SoundBeep(900, 60) ; Notification of replacement.
        
    ; Only set up logging if it's enabled
    if (Config.EnableLogging = 1) {
        SetTimer(keepText.bind(LastTrigger), -1)
        ; For onBsLogger function.
        Global IsRecent := 1 ; Set IsRecent, then change back in 1 second.
        setTimer (*) => IsRecent := 0, -1000 ; run only once, in 1 second.
    }
}

;===============================================================================
; Automatically logs (if enabled) if an autocorrect happens, and if the 
; user presses Backspace within the specified timeout
;===============================================================================
#MaxThreadsPerHotkey 5 ; Allow up to 5 instances of the function.
keepText(KeepForLog, *) {       
    KeepForLog := StrReplace(KeepForLog, "`n", "``n") ; Fixes triggers spanning two lines.
    global lih := InputHook("B V I1 E T1", "{Backspace}") ; "logger input hook." T is time-out. T1 = 1 second.
    lih.Start()
    lih.Wait()
    
    ; Determine hyphen style based on whether Backspace was pressed
    hyphen := (lih.EndKey = "Backspace") ? " << " : " -- "
    
    ; Log the autocorrection with timestamp and hyphen style
    FileAppend("`n" A_YYYY "-" A_MM "-" A_DD hyphen KeepForLog, Config.AutoCorrectsLogFile)
}
#MaxThreadsPerHotkey 1

;===============================================================================
; Backspace Context Logger
; Constantly keeps a cache of the last several words typed. If an autocorrection 
; is logged, and backspace is pressed within timeout, the cached words AND 
; the next X words are logged to help identify misfires. Doesn't cache/log digits.
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
            
            ; Play sound notification if enabled
            If (Config.beepOnContextLog = 1)
                SoundBeep(600, 200), SoundBeep(400, 200)
        }
        catch as e {
            FileAppend("Error in LogContent: " e.Message "`n", "..\Data\error_log.txt")
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

                    ; Skip digit-only input
                    If RegExMatch(this.bsih.Input, "\d")
                        continue
                        
                    If (this.waitingForExtra) {
                        If (this.bsih.EndKey = "Space") {
                            this.extraWordsCount++
                            this.WordArr.Push(this.bsih.Input "]" this.bsih.EndKey "]")
                            
                            ; Maintain limited history
                            If (this.WordArr.Length > (Config.precedingWordCount + Config.followingWordCount))
                                this.WordArr.RemoveAt(1)
                            
                            ; Log when we have enough following words
                            If (this.extraWordsCount > Config.followingWordCount) {
                                this.LogContent()
                            }
                        }
                    } 
                    else {
                        this.WordArr.Push(this.bsih.Input "[" this.bsih.EndKey "[")
                        
                        ; Maintain limited history
                        If (this.WordArr.Length > Config.precedingWordCount)
                            this.WordArr.RemoveAt(1)
                            
                        ; Check if this is a backspace within a recent autocorrection
                        If (this.bsih.EndKey = "Backspace" && IsRecent = 1) {
                            this.waitingForExtra := true
                            
                            ; CAPTURE the trigger at this moment (before it gets overwritten by next autocorrection)
                            global lastTrigger
                            this.capturedTrigger := lastTrigger
                            
                            ; CRITICAL FIX: Cancel any existing timeout timer before creating new one
                            ; This prevents unreferenced timer objects from accumulating
                            if (this.timeoutTimer) {
                                try {
                                    SetTimer(this.timeoutTimer, 0)
                                }
                                catch {
                                    ; Timer may have already fired; that's okay
                                }
                            }
                            
                            ; Set timeout to log after 8 seconds even if not enough words
                            this.timeoutTimer := ObjBindMethod(this, "LogContent")
                            SetTimer(this.timeoutTimer, -8000)
                        }
                    }
                }
                catch as e {
                    ; CRITICAL FIX: Reset state on error to prevent stuck state
                    ; If we don't reset here, the logger could stay in "waiting" mode permanently,
                    ; causing every subsequent keystroke to be logged
                    FileAppend("Error in BackspaceContextLogger loop: " e.Message "`n", "..\Data\error_log.txt")
                    
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
            ; Log outer error and mark as not running so we can restart if needed
            FileAppend("Critical error in BackspaceContextLogger: " e.Message "`n", "..\Data\error_log.txt")
            this.isRunning := false
        }
    }
}

; ; DEBUG HOTKEY: Press Ctrl+Shift+D to toggle BackspaceContextLogger debug mode
; ^+d::BackspaceContextLogger.ToggleDebug()



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

!+F3::StringAndFixReport("lastTrigger")  ; Alt+Shift+F3: Show last used trigger
^F3::StringAndFixReport()                ; Ctrl+F3: Show statistics report

global caller := ""
StringAndFixReport(caller := "Button") {
    ; Handle different cases based on caller parameter
    if (caller = "lastTrigger") {
        if (Config.EnableLogging = 0) {
            thisMessage := "*Logging is currently disabled*`nEnable logging by setting`nConfig.EnableLogging := 1`nin AutoCorrectSystem.ahk"
        } else {
            thisMessage := "Last logged trigger:`n`n" lastTrigger
        }
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
            '`n Autocorrect hotstring stats.'
            '`n================================'
            '`n    Regular Autocorrects:`t' numberFormat(regulars)
            '`n    Word Beginnings:`t`t' numberFormat(begins)
            '`n    Word Middles:`t`t' numberFormat(middles)
            '`n    Word Ends:`t`t' numberFormat(ends)
            '`n================================'
            '`n   Total Entries:`t`t' numberFormat(entries)
            '`n   Potential Fixes:`t`t' numberFormat(fixes)
            '`n   Web Freq Billions:`t`t' numberFormat(Round(freq/1000,2))
            )
        }
        catch Error as err {
            thisMessage := "Could not read hotstring library`n" err.Message
            LogError("StringAndFixReport: " err.Message)
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

fix_consecutive_caps()
fix_consecutive_caps() {
; Hotstring only works if CapsLock is off.
	HotIf (*) => !GetKeyState("CapsLock", "T")
	loop 26 {
		char1 := Chr(A_Index + 64)
		loop 26 {
			char2 := Chr(A_Index + 64)
			; Create hotstring for every possible combination of two letter capital letters.
            ;If (char1 char2 != "CO")
			Hotstring(":*?CXB0Z:" char1 char2, fix.Bind(char1, char2))
		}
	}
	HotIf
	; Third letter is checked using InputHook.
	fix(char1, char2, *) {
		;ih := InputHook("V I101 L1")
		ih := InputHook("V I101 L1 T.3")
		ih.OnEnd := OnEnd
		ih.Start()
		OnEnd(ih) {
			char3 := ih.Input
			if (char3 ~= "[A-Z]")  ; If char is UPPERcase alpha.
				Hotstring "Reset"
			else if (char3 ~= "[a-z]")  ; If char is lowercase alpha.
			|| ((char3 = A_Space && char1 char2 ~= "OF|TO|IN|IT|IS|AS|AT|WE|HE|BY|ON|BE|NO") && Config.CapFixTwoLetterWords)
			{	SendInput("{BS 2}" StrLower(char2) char3)
                If Config.BeepOnCapFix {
                    SoundBeep(800, 80) ; Case fix announcent. 
                }
			}
		}
	}
}
