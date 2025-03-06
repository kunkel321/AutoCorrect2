; AutoCorrectSystem.ahk
; Part of the AutoCorrect2 system
; Contains the logger and backspace detection functionality
; Version: 3-5-2025

;===============================================================================
;                         AutoCorrect System Module
;===============================================================================

; Configuration parameters - can be set from main script
Global IsRecent := 0            ; Flag to track if a hot string was recently triggered
Global lastTrigger := "No triggers logged yet." ; Tracks the last used trigger

; Logger file paths - these should match settings in the main script
AutoCorrectsLogFile := A_ScriptDir "\AutoCorrectsLog.txt"
ErrContextLog := A_ScriptDir "\ErrContextLog.txt"

; Create log files if they don't exist
If not FileExist(AutoCorrectsLogFile)
    FileAppend("This will be the log of all autocorrections.`n", AutoCorrectsLogFile)
If not FileExist(ErrContextLog)
    FileAppend(
        "This will be the log of extended context information for backspaced autocorrections.`n"
        "Date Y-M-D`titem`t`t`tcontext`n"
        "===============================================", ErrContextLog)

;===============================================================================
;                    Autocorrection Logger Settings
;===============================================================================
beepOnCorrection := 1        ; Beep when the f() function is used.

;===============================================================================
;                  Backspace Context Logger Settings
;===============================================================================
precedingWordCount := 6      ; Cache this many words for context logging.
followingWordCount := 5     ; Wait for this many additional words before logging.
beepOnContexLog := 1         ; Beep when an "on BS" error is logged.

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
    SendInput("{BS " (TrigLen - ignorLen) "}" replace StrReplace(endchar, "!", "{!}")) ; Type replacement and endchar. 
    
    HSInputBuffer.Stop()
    If (beepOnCorrection = 1)
        SoundBeep(900, 60) ; Notification of replacement.
        
    SetTimer(keepText.bind(LastTrigger), -1)

    ; For onBsLogger function.
    Global IsRecent := 1 ; Set IsRecent, then change back in 1 second.
    setTimer (*) => IsRecent := 0, -1000 ; run only once, in 1 second.
}

;===============================================================================
; Automatically logs if an autocorrect happens, and if the user presses 
; Backspace within the specified timeout
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
    FileAppend("`n" A_YYYY "-" A_MM "-" A_DD hyphen KeepForLog, AutoCorrectsLogFile)
}
#MaxThreadsPerHotkey 1

;===============================================================================
; Backspace Context Logger
; Constantly keeps a cache of the last several words typed. If an autocorrection 
; is logged, and backspace is pressed within timeout, the cached words AND 
; the next X words are logged to help identify misfires.
;===============================================================================
class BackspaceContextLogger {
    static WordArr := []
    static waitingForExtra := false
    static extraWordsCount := 0
    static LogEntry := ""
    static timeoutTimer := 0
    static bsih := 0
    static isRunning := false
    
    ; Start the logger
    static Start() {
        if (this.isRunning)
            return
            
        this.isRunning := true
        
        ; Initialize the input hook for backspace context logging
        this.bsih := InputHook("B V I1 E", "{Space}{Backspace}{Tab}{Enter}")
        
        ; Start the logger loop in a new thread
        SetTimer(() => this.LoggerLoop(), -50)
    }
    
    ; Process and format the log entry
    static LogContent() {
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
        ; Use the global lastTrigger variable
        global lastTrigger
        formattedTrigger := StrReplace(lastTrigger, "`n", "``n") ; Fix multiline triggers
        
        ; Add tabs based on length to align columns
        tabs := StrLen(formattedTrigger) > 14 ? "`t" : "`t`t"
        
        ; Write to the log file
        FileAppend(dateStamp " << " formattedTrigger tabs "---> " this.LogEntry, ErrContextLog)
        
        ; Play sound notification if enabled
        If (beepOnContexLog = 1)
            SoundBeep(600, 200), SoundBeep(400, 200)
        
        ; Reset state
        this.LogEntry := ""
        this.waitingForExtra := false
        this.extraWordsCount := 0
        this.WordArr := []
        
        ; Clear the timeout timer
        SetTimer(this.timeoutTimer, 0)
    }
    
    ; The main logger loop
    static LoggerLoop() {
        try {
            Loop {
                try {
                    this.bsih.Start()
                    this.bsih.Wait()
                    
                    ; Skip digit-only input
                    If RegExMatch(this.bsih.Input, "\d")
                        continue
                        
                    If (this.waitingForExtra) {
                        If (this.bsih.EndKey = "Space") {
                            this.extraWordsCount++
                            this.WordArr.Push(this.bsih.Input "]" this.bsih.EndKey "]")
                            
                            ; Log when we have enough following words
                            If (this.extraWordsCount > followingWordCount) {
                                this.LogContent()
                            }
                        }
                    } 
                    else {
                        this.WordArr.Push(this.bsih.Input "[" this.bsih.EndKey "[")
                        
                        ; Maintain limited history
                        If (this.WordArr.Length > precedingWordCount)
                            this.WordArr.RemoveAt(1)
                            
                        ; Check if this is a backspace within a recent autocorrection
                        If (this.bsih.EndKey = "Backspace" && IsRecent = 1) {
                            this.waitingForExtra := true
                            
                            ; Set timeout to log after 8 seconds even if not enough words
                            this.timeoutTimer := ObjBindMethod(this, "LogContent")
                            SetTimer(this.timeoutTimer, -8000)
                        }
                    }
                }
                catch as e {
                    ; If there's an error, log it and continue
                    FileAppend("Error in BackspaceContextLogger loop: " e.Message "`n", A_ScriptDir "\error_log.txt")
                    Sleep(100)
                }
            }
        }
        catch as e {
            ; Log outer error and mark as not running so we can restart if needed
            FileAppend("Critical error in BackspaceContextLogger: " e.Message "`n", A_ScriptDir "\error_log.txt")
            this.isRunning := false
        }
    }
}

;===============================================================================
; Input Buffer Class
; Used to buffer user input for keyboard capture
;===============================================================================
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

StringAndFixReport(caller := "Button") {
    ; Handle different cases based on caller parameter
    if (caller = "lastTrigger") {
        thisMessage := "Last logged trigger:`n`n" lastTrigger
        buttPos := ""
        windowTitle := "Last Triggered Hotstring"
    }
    else { 
        ; Generate hotstring statistics report
        try {
            HsLibContents := FileRead(Config.HotstringLibrary)
            thisOptions := "", regulars := 0, begins := 0, middles := 0, ends := 0, fixes := 0, entries := 0
            
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
            '`n Autocorrect hotstring totals.'
            '`n================================'
            '`n    Regular Autocorrects:`t' numberFormat(regulars)
            '`n    Word Beginnings:`t`t' numberFormat(begins)
            '`n    Word Middles:`t`t' numberFormat(middles)
            '`n    Word Ends:`t`t' numberFormat(ends)
            '`n================================'
            '`n   Total Entries:`t`t' numberFormat(entries)
            '`n   Potential Fixes:`t`t' numberFormat(fixes) 
            )
        }
        catch as e {
            thisMessage := "Could not read hotstring library`n" e.Message
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

; Extra thing not really related to AutoCorrect2.
;##################### WINDOW MOVER ##########################
^!Lbutton:: ; Ctrl+Alt+Left Mouse Click to drag a window
{
	SetWinDelay(-1) ; Sets time between moves. -1 = no time
	CoordMode("Mouse", "Screen")
	WinGetPos(&BwX, &BwY, , , "A") ; Begin window X Y coord.
	WinRestore("A") ; Unmaximizes window.
	MouseGetPos(&BmX, &BmY) ; Begin mouse X Y coord
	while GetKeyState("Lbutton", "P") ; While left mouse button is held down.
	{	MouseGetPos(&CmX, &CmY) ; Keep getting current mouse X Y
		WinMove((BwX+CmX-BmX), (BwY+CmY-BmY), , , "A")
	} 
	SetWinDelay 100
	CoordMode("Mouse", "Window") ; Put back, because window is mostly the default.
Return
}
