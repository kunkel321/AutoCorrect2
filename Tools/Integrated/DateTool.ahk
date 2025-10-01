#SingleInstance
#Requires AutoHotkey v2+

;  Gets included with AutoCorrect2 via #Include.
;  But it is okay to run this as a stand-alone app, if preferred.  

;======== DateTool-H =========================================================
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=124254

; The 'H' is for 'Holidays.'   Version: 9-28-2025
; A simple popup calendar that has US Holidays in bold font.
; Original calendar-with-bolded-dates v1 code by PhiLho
; https://www.autohotkey.com/board/topic/13441-monthcal-setdaystate/
; Original IsHoliday function (v1) by TidBit.
; https://www.autohotkey.com/boards/viewtopic.php?t=77312

; The two were integrated (v1) by Just Me.
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=117399&p
; Entire code converted to AHK v2 by Just Me.
; https://www.autohotkey.com/boards/viewtopic.php?f=82&t=123895
; ToolTipOptions Class (also by Just Me) added later, see below.
; Feb-2025 
; -Added support for alternate date format as recommended by delio.
; -Changes to isHoliday function, holiday report scriptlets, by kunkel321.
; March 2025 
; -CaptInsano added support for 'Original_year' which shows holiday's age. 
; -CaptInsano-led enhancement of hotstring options, weeks, months, years,
; 2-digit numbers support, "next Tuesday", etc, and onboard help.
; https://www.autohotkey.com/boards/viewtopic.php?p=599890#p599834

; MARK: Help
;======== Directions for Use: Date Hotstrings ==================================
sHSHelp :=
    (
        "
Keystroke format    [Alt+;d|;d][d|-][##][d|we|mo|yr|u|m|t|w|r|f|s] followed by {Space}, {Enter}, or {Period(.)}
;d | Alt+;d         Invokes the date tool hotstring. Starting with ; will insert the standard date format.
                    Starting with Alt+; will insert the alternate date format. 
d|-                 Optional.  Include to go backwards in time. Blank = forwards in time.
##                  Optional.  Up to 2 digits to add or subtract vs. today.  Blank or 0 = today.
d|we|mo|yr|         Optional.  If blank, assumes days. Increment by days, weeks, months, or years.
u|m|t|w|r|f|s                  Or by weekdays (u=Sun, m=Mon, t=Tue, w=Wed, r=Thu, f=Fri, s=Sat).
    
Examples:
Keystroke   Date Code   Date Result (vs Today)
---------   ---------   ----------------------
;d          Blank       Today
;d0         0           Today
;d10d       10d         Adds 10 days 
;d10        10          Adds 10 days
;dd10d      d10d        Subtracts 10 days
;d-10d      -10d        Subtracts 10 days
;dd10we     d10we       Subtracts 10 weeks
;d2yr       2yr         Adds 2 years
;dw         w           Wednesday of this week (this Wednesday)
;d0w        0w          Wednesday of this week (this Wednesday)
;d1r        1r          Thursday next week (next Thursday)
;d4m        4m          Monday in four weeks
;d-2t       -2t         Tuesday of the week before last

;dh         h           Summons the help GUI."
    )

;======== Directions for Use: Popup Calendar ===================================
sMCHelp :=
    (
        "
Alt+Shift+D ---> Show calendar.
Bold dates have holidays.  Click to show holiday (if enabled).
Press h (while calendar is active) ---> Toggle list of holidays for shown months.
Press t (while calendar is active) ---> Go to today.
Press 1-5 (while calendar is active) ---> Show this many months.
Double-click a date, or press Enter  ---> Type date.
D-click/Enter while holding Alt key ---> Type date with alternate format.
D-Click/Enter while holding Shift key ---> Show menu of scriptlet holiday report tools.

Calendar appears placed over active window.
Waits for window to be active again before typing date.

See IsHoliday() function, for array of custom holidays and how to add
your own custom holidays. Please remove any personal dates, and add your own.

Known issue: With MonthCal, clicking next/last month arrows too fast enters
the date, rather than just scrolling dates. Gets read as 'double-click.'

Press F1 while monthCal is showing ----> Summons the help GUI."
    )

; ==============================================================================
; Caveat: Claude AI was used in several places, so reuse the code with cauton.

; ==============================================================================
; GET RID OF this #HotIf section if you are using DateTool as a stand-alone app. 
MyAutoCorrectFileName := "..\Core\AutoCorrect2.exe" ; <------- CHANGE To NAME of your AutoCorrect script?
#HotIf WinActive("DateTool.ahk",) ; Can't use A_Var here.
^s:: ; Because this tool is #Included in AutoCorrect2, reload ac2 upon save. hide
{	Send("^s") ; Save me.
	MsgBox("Reloading...", "", "T0.3")
	Sleep(250)
	If FileExist(MyAutoCorrectFileName) {
        Run MyAutoCorrectFileName
        MsgBox(MyAutoCorrectFileName " reloaded.") ; Pops up then disappears super-quickly because of the reload.
    }
    else {
        Reload
        MsgBox(A_ScriptName " reloaded.") ; Pops up then disappears super-quickly because of the reload.
    }
}
#HotIf

; MARK: User Options
; ========================================================
guiTitle := "DateTool-H"            ; change title if desired
monthCalHotkey := "!+d"             ; Hotkey: Alt+Shift+D.  Change as desired. 
; if monthCalHotkey is changed here, must also update RunDateTool() in AutoCorrect2.ahk. 
; TypeOutFormat := "dd-MMM-yyyy"       ; preferred date format for typing date in edit field
TypeOutFormat := "M-d-yyyy"         ; preferred date format for typing date in edit field
TypeOutAltFormat := "yyyy-MM-dd"    ; alternate preferred date format for typing
HolidayListFormat := "MMM-dd"       ; preferred date format for popup list
MonthCount := 3                     ; default number of months to display vertically
ShowHotstringToolTips := 1          ; shows a popup with info about entered date (1 = yes / 0 = no)
; See ShowToolTip() function for more customization options.
MenuReportsAsToolTips := 1          ; show menu reports as tooltips (1 = tooltip / 0 = msgbox)
ShowSingleHoliday := 1              ; show holiday when click on day (1 = yes / 0 = no)
ReportToolTipTimeout := 20          ; reports tooltips disappear after this many seconds.
sAddOptions := ""
; sAddOptions := sAddOptions . "4 "    ; adds the week numbers to the calendar
; sAddOptions := sAddOptions . "8 "    ; prevents circling today's date
; sAddOptions := sAddOptions . "16 "   ; prevents showing today's date at bottom
ERROR_LOG := 1  ; The log functions are at the very bottom of this file. 
DEBUG_LOG := 0  ; 1 = yes log, 0 = no don't
; User Note: If you have many holidays defined, the menu reports can be quite large,
; so have 'MenuReportsAsToolTips:=0' or have a small font for tooltips (next section.)
; ==============================================================================

if FileExist("..\Data\colorThemeSettings.ini") {
    settingsFile := "..\Data\colorThemeSettings.ini"
    ; --- Get current theme colors from ini file.
    formColor := IniRead(settingsFile, "ColorSettings", "formColor")
    ;fontColor := IniRead(settingsFile, "ColorSettings", "fontColor")
}
else { ; Ini file not there, so use these colors instead.
    formColor := "E5E4E2"   ; for ToolTip font and cal border... Won't affect monthCal
    ;fontColor := "0x1F1F1F" ; for ToolTip font... Won't affect monthCal
}

;======== ToolTip User Options =================================================
ToolTipOptions.Init() ; Do not move.
ToolTipOptions.SetFont("s13", "Calibri") ; Change as desired.
ToolTipOptions.SetMargins(5, 5, 5, 5) ; Left, Top, Right, Bottom.
;ToolTipOptions.SetColors(formColor, fontColor) ; background, font : Use this for theme colors.
ToolTipOptions.SetColors("Default", "Default") ; background, font

; MARK: Hotstring/Hotkey 
;===================================================================

:?*B0:;d:: {
    global sMode := "standard"
    sFormat := TypeOutFormat
    SendDateHS(sFormat, sMode)
}

!;:: { ; hide
    global sMode := "alternate"
    sFormat := TypeOutAltFormat
    SendDateHS(sFormat, sMode)
}

KeysReturn(sOptions := "", sEnd := "{Any}") {
    ih := InputHook(sOptions)
    ih.KeyOpt(sEnd, "E")
    ih.Start()
    ih.Wait()
    aKeyRet := [ih.Input,ih.EndReason,ih.EndKey]
    return aKeyRet
}

SendDateHS(sFormat, sMode) {
    if sMode = "alternate" { ;for alternate format, first need to check if it's ;d or ;other
        sTest := KeysReturn("L1", "{Any}")[1]
        if sTest = "d" {
            SendInput(";d")
        } else {
            ; User pressed Alt+; followed by something other than "d"
            SendInput(";" sTest)
            return
        }
    }
    aInput := KeysReturn("L5 V1 I2", "{Space}{Enter}.") ; max is 5 characters to return e.g. '-10we'.
    sInput := aInput[1]
    sEnd := aInput[2]
    sEndKey := aInput[3]
    if sInput = "h" { ;help is called
        SendInput("{BackSpace 4}")
        myHSgui := Gui("AlwaysOnTop", "DateTool Hotstring Help")
        myHSgui.SetFont("s10", "Courier New")
        myHSgui.Add("Text", , sHSHelp)
        myHSgui.Show
        myHSgui.OnEvent("Escape", (*) => myHSgui.Hide())
        return
    }
    MyDate := GetMyDate(sInput, sFormat)
    ; Check if the result is the original input (indicating an error or invalid character)
    if (MyDate = ";d" sInput) {
        if sMode = "standard" { ; Do nothing - leave the original input in place
            return
        } else { ; In alternate mode, just send "d" since we haven't sent ";d" yet
            SendInput("d" sInput)
            return
        }
    }
    iInput := StrLen(sInput)
    if sEnd = "Max" ;change # of backspaces and include the EndKey depending on how KeysReturn was ended.
        SendInput("{backspace " iInput + 2 "}" MyDate "{" sEndKey "}")  ; +2 for ";d"
    if sEnd = "EndKey"
        SendInput("{backspace " iInput + 3 "}" MyDate "{" sEndKey "}")  ; +3 for ";d plus ending character"
}

GetMyDate(sCode, sFormat := "MM-dd-yyyy") {
    ; Store current date components
    Y := SubStr(A_Now, 1, 4)
    M := SubStr(A_Now, 5, 2)
    D := SubStr(A_Now, 7, 2)
    
    ; Debug log
    DTDebug("GetMyDate input: " sCode)
    
    ; Check for invalid characters upfront
    ; Valid characters: digits, period indicators (d, we, mo, yr), weekdays (u, m, t, w, r, f, s), and "-"
    validChars := "0123456789dwemoryrumtwrfs-"
    
    ; Check each character in the input
    for i, char in StrSplit(sCode) {
        if (!InStr(validChars, char)) {
            DTDebug("Invalid character detected: " char)
            return ";d" sCode  ; Return the original input without processing
        }
    }
    
    ; Check for subtraction indicator
    iBack := 0
    sDateOpts := sCode
    if SubStr(sDateOpts, 1, 1) = "-" || SubStr(sDateOpts, 1, 1) = "d" {
        iBack := 1
        sDateOpts := SubStr(sDateOpts, 2)
    }
    
    ; Initialize variables
    isWeekday := false
    weekdayChar := ""
    numericPart := ""
    sPeriod := "d"  ; Default to days
    
    ; Parse the input
    len := StrLen(sDateOpts)
    
    ; CRITICAL FIX: Check for 2-character period indicators FIRST
    if (len >= 2) {
        lastTwo := SubStr(sDateOpts, len-1, 2)
        
        if (lastTwo = "we" || lastTwo = "mo" || lastTwo = "yr") {
            ; This is a period indicator, not a weekday
            if (lastTwo = "we")
                sPeriod := "we"  ; weeks
            else if (lastTwo = "mo")
                sPeriod := "mo"  ; months
            else if (lastTwo = "yr")
                sPeriod := "yr"  ; years
                
            numericPart := SubStr(sDateOpts, 1, len - 2)
            
            ; Handle empty numeric part
            if (numericPart = "")
                numericPart := "0"
                
            ; Convert to number
            try {
                iOff := numericPart + 0
                if (iBack)
                    iOff := -iOff
            } catch Error as err {
                iOff := 0
            }
            
            DTDebug("Parsed period indicator: " lastTwo ", numericPart: " numericPart ", iOff: " iOff)
        }
        ; Not a 2-character period, continue with other checks
        else if (len = 1) {
            lastChar := sDateOpts
            
            ; Check if it's a weekday
            if InStr("umtwrfs", lastChar) {
                isWeekday := true
                weekdayChar := lastChar
                numericPart := "0"  ; This week
                iOff := 0
                DTDebug("Parsed single weekday: " weekdayChar)
            } else {
                ; Just a number, assume days
                try {
                    iOff := lastChar + 0
                    if (iBack)
                        iOff := -iOff
                } catch Error as err {
                    iOff := 0
                }
                DTDebug("Parsed single digit: iOff=" iOff)
            }
        } 
        else {
            ; Check if last character is 'd' for days
            lastChar := SubStr(sDateOpts, len, 1)
            
            if (lastChar = "d") {
                sPeriod := "d"   ; days
                numericPart := SubStr(sDateOpts, 1, len - 1)
                DTDebug("Parsed days indicator: d, numericPart: " numericPart)
            }
            ; Check if last character is a weekday indicator
            else if InStr("umtwrfs", lastChar) {
                isWeekday := true
                weekdayChar := lastChar
                numericPart := SubStr(sDateOpts, 1, len - 1)
                DTDebug("Parsed weekday: " weekdayChar ", numericPart: " numericPart)
            } else {
                ; No recognized indicator, assume entire string is numeric for days
                sPeriod := "d"
                numericPart := sDateOpts
                DTDebug("Parsed numeric only: " numericPart)
            }
            
            ; Handle empty numeric part
            if (numericPart = "")
                numericPart := "0"
                
            ; Convert to number
            try {
                iOff := numericPart + 0
                if (iBack)
                    iOff := -iOff
            } catch Error as err {
                iOff := 0
            }
        }
    } else if (len = 1) {
        ; Handle single character case (e.g., "f" for Friday)
        lastChar := sDateOpts
        
        ; Check if it's a weekday
        if InStr("umtwrfs", lastChar) {
            isWeekday := true
            weekdayChar := lastChar
            numericPart := "0"  ; This week
            iOff := 0
            DTDebug("Parsed single weekday: " weekdayChar)
        } else {
            ; Just a number, assume days
            try {
                iOff := lastChar + 0
                if (iBack)
                    iOff := -iOff
            } catch Error as err {
                iOff := 0
            }
            DTDebug("Parsed single digit: iOff=" iOff)
        }
    } else {
        ; Empty input, assume today
        iOff := 0
        DTDebug("Empty input, using today")
    }
    
    DTDebug("Final parsing: sPeriod=" sPeriod ", iOff=" iOff ", isWeekday=" isWeekday)
    
    ; Calculate the date based on the period and offset
    try {
        if (isWeekday) {
            ; Map weekday character to day of week (1-7)
            targetDay := 0
            switch weekdayChar {
                case "u": targetDay := 1  ; Sunday
                case "m": targetDay := 2  ; Monday
                case "t": targetDay := 3  ; Tuesday
                case "w": targetDay := 4  ; Wednesday
                case "r": targetDay := 5  ; Thursday
                case "f": targetDay := 6  ; Friday
                case "s": targetDay := 7  ; Saturday
                default: throw Error("Invalid weekday", -1)
            }
            
            ; Get current day of week
            currentDay := A_WDay
            
            ; Calculate days to add/subtract based on offset
            if (iOff = 0) {
                ; For "this week" (current week)
                daysToAdd := (targetDay - currentDay)
                
                ; If the target day has already passed this week, keep it in the past
                ; This means using negative days to go backwards
                ; We don't want to wrap to next week
                
                DTDebug("This week calculation: targetDay=" targetDay ", currentDay=" currentDay ", raw diff=" daysToAdd)
            }
            else {
                ; For any other offset (next week, 2 weeks from now, etc.)
                
                ; Start from same day of week as today
                daysToAdd := 0
                
                ; Add the appropriate number of weeks
                daysToAdd += (iOff * 7)
                
                ; Adjust to target day within that week
                dayDiff := (targetDay - currentDay)
                daysToAdd += dayDiff
                
                DTDebug("Future week calculation: targetDay=" targetDay ", currentDay=" currentDay ", weekOffset=" iOff ", dayDiff=" dayDiff)
            }
            
            DTDebug("Weekday calculation: target day=" targetDay ", current day=" currentDay ", final days to add=" daysToAdd)
            
            ; Calculate the target date
            DatePicked := DateAdd(A_Now, daysToAdd, "D")
            DTDebug("Weekday calculation result: final date=" DatePicked)
        } else {
            ; Handle standard date formats
            switch sPeriod {
                case "d":
                    DatePicked := DateAdd(A_Now, iOff, "D")
                    DTDebug("Days calculation: iOff=" iOff ", final date=" DatePicked)
                    
                case "we":  ; weeks
                    DatePicked := DateAdd(A_Now, iOff * 7, "D")
                    DTDebug("Weeks calculation: iOff=" iOff ", final date=" DatePicked)
                    
                case "yr":  ; years
                    ; SPECIAL HANDLING FOR YEARS - Don't use DateAdd
                    DTDebug("Year calculation: iOff=" iOff)
                    
                    ; Directly modify the year components
                    newYear := Integer(Y) + iOff
                    DTDebug("New year: " newYear)
                    
                    ; Build the new date
                    YearDate := newYear . M . D
                    
                    ; Handle leap year edge case (Feb 29 in non-leap years)
                    if (M = "02" && D = "29" && !((Mod(newYear, 4) = 0 && Mod(newYear, 100) != 0) || Mod(newYear, 400) = 0))
                        YearDate := newYear . "0228"
                    
                    ; Add the time portion
                    DatePicked := YearDate . SubStr(A_Now, 9)
                    DTDebug("Final year date: " DatePicked)
                    
                case "mo":  ; months
                    ; Calculate target month and year
                    targetMonth := Integer(M) + iOff
                    yearOffset := 0
                    
                    while (targetMonth > 12) {
                        targetMonth -= 12
                        yearOffset++
                    }
                    
                    while (targetMonth < 1) {
                        targetMonth += 12
                        yearOffset--
                    }
                    
                    newYear := Integer(Y) + yearOffset
                    newMonth := Format("{:02d}", targetMonth)
                    
                    ; Build the new date
                    MonthDate := newYear . newMonth . D
                    
                    ; Handle month length issues (e.g., Jan 31 -> Feb 28)
                    dayInMonth := DaysInMonth(targetMonth, newYear)
                    if (Integer(D) > dayInMonth)
                        MonthDate := newYear . newMonth . Format("{:02d}", dayInMonth)
                    
                    ; Add the time portion
                    DatePicked := MonthDate . SubStr(A_Now, 9)
                    DTDebug("Months calculation: new month=" newMonth ", new year=" newYear ", final date=" DatePicked)
                    
                default:
                    DatePicked := DateAdd(A_Now, iOff, "D")
                    DTDebug("Default calculation: iOff=" iOff ", final date=" DatePicked)
            }
        }
    } catch Error as err {
        DTLogError("Date calculation error: " err.Message)
        return ";d" sCode
    }
    
    ; Format the date and display tooltip
    try {
        MyDate := FormatTime(DatePicked, sFormat)
        DTDebug("Final formatted date: " MyDate)
        
        If (ShowHotstringToolTips) { ; User can disable tooltip function altogether, is desired.
            ; Only pass targetDay if it's a weekday format
            if (isWeekday)
                ShowToolTip(DatePicked, iOff, sPeriod, sCode, sFormat, isWeekday, targetDay)
            else
                ShowToolTip(DatePicked, iOff, sPeriod, sCode, sFormat, isWeekday)
        }
            
        return MyDate
    } catch Error as err {
        DTLogError("Date formatting error: " err.Message)
        return ";d" sCode
    }
}

; Helper function to determine days in a month
DaysInMonth(month, year) {
    static daysPerMonth := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    if (month = 2 && ((Mod(year, 4) = 0 && Mod(year, 100) != 0) || Mod(year, 400) = 0))
        return 29  ; February in a leap year
    
    return daysPerMonth[month]
}

ShowToolTip(sDatePicked, iOff, sPeriod, sCode, sFormat, isWeekday := false, targetDay := 0) {
    ; Configuration options
    EmbedKeysInTip := 1 ; e.g. [ ; d 3 w e ]
    EmbedHolidayInTip := 1
    EmbedContextInTip := 1 ; e.g. next week, last month, etc
    EmbedDateInTip := 0
    MultiLineTip := 1
    
    ; Get date components
    Y := SubStr(A_Now, 1, 4)
    mY := SubStr(sDatePicked, 1, 4)
    
    ; Default format for display
    baseDate := FormatTime(sDatePicked, sFormat)
    
    If (EmbedContextInTip) {
        ; Create context-specific format based on period type
        if (isWeekday) {
            ; Get weekday name
            weekdayName := FormatTime(sDatePicked, "dddd")
            
            ; Weekday format with appropriate context
            if (iOff = 0) {
                contextLabel := " this week"
            } else if (iOff = 1) {
                contextLabel := " next week"
            } else if (iOff = 2) {
                contextLabel := " after next"
            } else if (iOff > 2) {
                contextLabel := " in " iOff " weeks"
            } else if (iOff = -1) {
                contextLabel := " last week"
            } else if (iOff = -2) {
                contextLabel := " week before last"
            } else {
                contextLabel := " " (-iOff) " weeks ago"
            }
            
            formattedDate := weekdayName contextLabel
        }
        else if (sPeriod = "mo") {
            ; Month format
            if (iOff = 0)
                contextLabel := " (this month)"
            else if (iOff = 1)
                contextLabel := " (next month)"
            else if (iOff > 1)
                contextLabel := " (in " iOff " months)"
            else if (iOff = -1)
                contextLabel := " (last month)"
            else
                contextLabel := " (" (-iOff) " months ago)"
                
            formattedDate := FormatTime(sDatePicked, "MMMM yyyy") contextLabel
        }
        else if (sPeriod = "yr") {
            ; Year format
            yearDiff := mY - Y
            if (yearDiff = 0)
                contextLabel := " (this year)"
            else if (yearDiff = 1)
                contextLabel := " (next year)"
            else if (yearDiff > 1)
                contextLabel := " (in " yearDiff " years)"
            else if (yearDiff = -1)
                contextLabel := " (last year)"
            else
                contextLabel := " (" (-yearDiff) " years ago)"
                
            formattedDate := FormatTime(sDatePicked, "yyyy") contextLabel
        }
        else if (sPeriod = "we") {
            ; Week format
            if (iOff = 0)
                contextLabel := " (this week)"
            else if (iOff = 1)
                contextLabel := " (next week)"
            else if (iOff = 2)
                contextLabel := " (week after next)"
            else if (iOff > 2)
                contextLabel := " (in " iOff " weeks)"
            else if (iOff = -1)
                contextLabel := " (last week)"
            else if (iOff = -2)
                contextLabel := " (week before last)"
            else
                contextLabel := " (" (-iOff) " weeks ago)"
                
            formattedDate := "Week of " FormatTime(sDatePicked, "MMM d") contextLabel
        }
        else {
            ; Day format (default) - FIX: Use iOff directly instead of DateDiff
            if (iOff = 0)
                contextLabel := " (today)"
            else if (iOff = 1)
                contextLabel := " (tomorrow)"
            else if (iOff > 1 && iOff <= 7)
                contextLabel := " (in " iOff " days)"
            else if (iOff > 7 && iOff <= 14)
                contextLabel := " (next week)"
            else if (iOff > 14)
                contextLabel := " (in " Round(iOff/7) " weeks)"
            else if (iOff = -1)
                contextLabel := " (yesterday)"
            else if (iOff >= -7 && iOff < -1)
                contextLabel := " (" (-iOff) " days ago)"
            else if (iOff >= -14 && iOff < -7)
                contextLabel := " (last week)"
            else
                contextLabel := " (" Round((-iOff)/7) " weeks ago)"
                
            formattedDate := FormatTime(sDatePicked, "dddd, MMM d") contextLabel
        }
    }
    else { ; EmbedContextInTip = 0
        if (isWeekday) ; Get weekday name
            formattedDate := FormatTime(sDatePicked, "dddd")
        else if (sPeriod = "mo") ; Month format
            formattedDate := FormatTime(sDatePicked, "MMMM yyyy") 
        else if (sPeriod = "yr") ; Year format
            formattedDate := FormatTime(sDatePicked, "yyyy") 
        else if (sPeriod = "we") ; Week format
            formattedDate := "Week of " FormatTime(sDatePicked, "MMM d") 
        else ; Day format (default)
            formattedDate := FormatTime(sDatePicked, "dddd, MMM d")
    }

    ; Check if it's a weekend
    DayOfWeek := FormatTime(sDatePicked, "dddd")
    WeekEndPrefix := (DayOfWeek = "Saturday" || DayOfWeek = "Sunday") ? "WEEKEND --> " : ""

    ; Build tooltip text based on configuration options
    sTip := ""
    
    ; Add keys if enabled
    if (EmbedKeysInTip) {
        sTipArr := StrSplit("[;d" sCode "]")
        for char in sTipArr
            sTip .= char " " ; Space them out for easier viewing.
        If (sMode = "alternate")
            sTip := StrReplace(sTip, "`;", "Alt + `;") ; If Alt was pressed, indicate so.
        ; Add separator based on multiline setting
        if (MultiLineTip)
            sTip .= Chr(10) ; Chr(10) is 'newline.'
        else
            sTip .= " "
    }

    ; Add holiday if enabled
    if (EmbedHolidayInTip) && (isHoliday(sDatePicked) != ""){
        sTip .= HoliTip := isHoliday(sDatePicked)
        ; Add separator based on multiline setting
        if (MultiLineTip)
            sTip .= Chr(10)
        else
            sTip .= " ---> "
    }
    
    ; Add formatted date with weekend indicator
    sTip .= WeekEndPrefix formattedDate
    
    ; Add base date format if enabled
    if (EmbedDateInTip) {
        ; Add separator based on multiline setting
        if (MultiLineTip)
            sTip .= Chr(10)
        else
            sTip .= " | "
            
        sTip .= baseDate
    }
    
    if CaretGetPos(&ttx, &tty)
        ToolTip(sTip, ttx + 10, tty + 25, "3")
    
    SetTimer () => ToolTip(, , , "3"), -3500  ; Disable tooltip in this many milisecs.
}

; MARK: MonthCal GUI
;======== Global Variables. Don't change =======================================
TargetWindow := 0, MCGUI := 0, hlYear := A_YYYY, hlMonth := A_MM
HolidayList := "", toggle := false  ; Variable to keep track of tooltip state
; ===================================================================

Hotkey(monthCalHotkey, MCRemake) ; Show DateTool - H
MCRemake(*) {
    local X, Y, W, H
    global MCGUI, TargetWindow
    if (MCGUI) {
        MCGUIClose() ; Causes hotkey to work like toggle.
        return
    }
    TargetWindow := WinExist("A") ; First try to get active window
    
    validWindow := false 
    if (TargetWindow) { ; Check if we have a valid window and it's not the taskbar
        try {
            windowClass := WinGetClass("A")
            validWindow := windowClass && !InStr(windowClass, "Shell_") && windowClass != "Progman"
        } catch {
            validWindow := false
        }
    }

    if (validWindow) {
        WinGetPos(&X, &Y, &W, &H, TargetWindow)
        X := X + (W * 0.30)
        Y := Y + (H * 0.04)
        MCGUI := Gui("-MinimizeBox +LastFound +ToolWindow +Owner" TargetWindow, guiTitle)
    } else { ; Default position when taskbar is active or no window exists
        X := A_ScreenWidth / 2 - 150  ; Center horizontally
        Y := 200 ; near top
        MCGUI := Gui("+AlwaysOnTop -MinimizeBox +LastFound +ToolWindow", guiTitle)
    }
    
    MCGUI.OnEvent("Close", MCGUIClose)
    MCGUI.OnEvent("Escape", MCGUIClose)
    MCGUI.BackColor := formColor
    OnMessage(0x004E, WM_NOTIFY)        ; needs to be called on control creation
    MCGUI.AddMonthCal("r" MonthCount " +0x01 vMC " sAddOptions)
    OnMessage(0x004E, WM_NOTIFY, 0)
    MCGUI["MC"].OnNotify(-747, MCN_GETDAYSTATE)
    if (ShowSingleHoliday = 1)
        MCGUI["MC"].OnEvent("Change", HandleDateChange)
    Set_CS_DBLCLKS(MCGUI["MC"].Hwnd)    ; needed to get WM_LBUTTONDBLCLK notifications for clicks on a MonthCal
    MCGUI.Show("x" X " y" Y)
    OnMessage(0x0203, WM_LBUTTONDBLCLK)
    OnMessage(0x0100, WM_KEYDOWN)
}

; ===================================================================
HandleDateChange(*) {
    ShowOneHoliday() ; Handle single holiday tooltip
    ; Clear menu report tooltips if enabled
    if MenuReportsAsToolTips {
        ; Clear tooltips 3-6 (leaving 1-2 for other features)
        loop 4 {
            ToolTip(, , , A_Index + 2)
        }
    }
}

; MARK: MonthCal Nav.
; ===================================================================
#HotIf WinActive(guiTitle)
ALt & Enter:: SendDateAlt() ; For alt format date entry. hide
+Enter:: ShowHolidayMenu() ; Shift+Enter to show menu. hide
h:: doToggle() ; Calls function to popup list of holidays.  hide
t:: MCGUI["MC"].Value := A_Now ; Hotkey for 'Go to today.' hide
1:: ; hide
2:: ; hide
3:: ; hide
4:: ; hide
5:: ChangeMCNumber() ; Shows this many months. (1-5) ; hide
F1::monthCalHelp() ; hide
#HotIf
; ===================================================================

monthCalHelp(*) {
    myMCgui := Gui("AlwaysOnTop", "DateTool monthCal Help")
    myMCgui.SetFont("s10", "Courier New")
    myMCgui.Add("Text", , sMCHelp)
    myMCgui.Show
    myMCgui.OnEvent("Escape", (*) => myMCgui.Hide())
    return
}

ChangeMCNumber(*) ; Reopens calendar with specified number of months.
{
    global MonthCount := A_ThisHotKey
    global DefaultDate := MCGUI["MC"].Value ; Remember selected day, when changing monthcount.
    MCGuiClose()
    MCRemake()
}
; ===================================================================

IsMouseOverMC(*) {
    mX := 0, mY := 0
    global isOver := 0
    WinGetPos(&cX, &cY, &cW, &cH, guiTitle)
    MouseGetPos(&mX, &mY)
    IsOver := (mX > 0 and mX < cW and mY > 0 and mY < cH) ? 1 : 0
}

ShowOneHoliday(*) {
    if isHoliday(MCGUI["MC"].Value) != "" {
        IsMouseOverMC()
        if IsOver = 1
            tooltip(isHoliday(MCGUI["MC"].Value), , , "2")
        else tooltip(isHoliday(MCGUI["MC"].Value), 60, -10, "2")
    }
    else tooltip(, , , "2")
}
; ===================================================================

doToggle(*) ; Toggles popup list of holidays.
{
    global toggle
    if (toggle)
        ToolTip(, , , "1") ; Hide the tooltip
    else HolidayNames()
    toggle := !toggle  ; Switch the toggle state
}
; ===================================================================

HolidayNames(*) ; Generate list of dates/names of holidays for shown months.
{
    thisDay := hlYear hlMonth "02000000"
    monIndex := 0, rStart := 0, rEnd := 0
    loop MonthCount + 1 {
        while monIndex < MonthCount + 1 {
            thisDay := DateAdd(thisDay, 1, "D")
            if SubStr(thisDay, 7, 2) = "01" {
                monIndex++
                if monIndex = 1 and SubStr(thisDay, 7, 2) = "01"
                    rStart := thisDay
                if monIndex = MonthCount + 1 and SubStr(thisDay, 7, 2) = "01"
                    rEnd := thisDay
            }
        }
    }
    thisDay := rStart
    global HolidayList := ""
    loop DateDiff(rEnd, rStart, "Days") {
        if IsHoliday(thisDay) != ""
            HolidayList .= FormatTime(thisDay, HolidayListFormat) "`t" IsHoliday(thisDay) "`n"
        thisDay := DateAdd(thisDay, 1, "D")
    }
    ToolTip(HolidayList, 275, 100, "1") ; <--- Adjust position of tooltip here.
}
; ===================================================================

MCGuiClose(*) {
    global MCGUI
    MCGUI.Destroy()
    MCGUI := 0
    OnMessage(0x0203, WM_LBUTTONDBLCLK, 0)
    OnMessage(0x0100, WM_KEYDOWN, 0)
    ToolTip(, , , "1") ; close H List tooltip if it's showing
    ToolTip(, , , "2") ; close one day tooltip if it's showing
    global toggle := false
}
; ===================================================================

WM_KEYDOWN(W, *) {
    if (W = 0x0D) { ; VK_RETURN => ENTER key
        SendDateCal()
        return 0
    }
}
; ===================================================================

WM_LBUTTONDBLCLK(*) {
    local CtrlHwnd := 0
    MouseGetPos(, , , &CtrlHwnd, 2)
    if (CtrlHwnd = MCGUI["MC"].Hwnd) {
        if GetKeyState("Shift") {
            ToolTip(, , , "2")  ; Clear the holiday tooltip
            ShowHolidayMenu()
        } else {
            SendDateCal()
        }
        return 0
    }
}

ShowHolidayMenu() {
    try {
        ; Clear any existing report tooltips
        if MenuReportsAsToolTips {
            ToolTip(, , , "3")  ; Clear menu report tooltip
        }

        ; Verify we have a valid date selected
        if !MCGUI["MC"].Value {
            MsgBox("No date selected!")
            return
        }

        ; Get the holiday for the selected date
        selectedDate := MCGUI["MC"].Value
        holidayText := isHoliday(selectedDate)
        
        ; Create the menu
        holidayMenu := Menu()
        
        ; Add holiday-specific items only if holidays exist
        if holidayText {
            ; Split the holiday text into individual holidays
            holidays := StrSplit(holidayText, "`n")
            
            ; Add menu items for each individual holiday
            for holiday in holidays {
                if holiday {  ; Skip empty entries
                    holidayMenu.Add("Show Future Dates for '" holiday "'", ShowHolidayDatesHandler)
                    holidayMenu.Add("Jump to Next Year's '" holiday "'", NavigateToNextOccurrenceHandler)
                    holidayMenu.Add()  ; Add a separator after each holiday's entries
                }
            }
        }

        ; Add general items always
        holidayMenu.Add("Show All Holidays in " FormatTime(selectedDate, "yyyy"), ShowYearHolidays)
        holidayMenu.Add("Show " FormatTime(selectedDate, "MMMM") " Holidays (20 Years)", ShowMonthHolidays)
        holidayMenu.Add("Copy Holiday List for Custom Date Range...", ShowDateRangeHolidays)
        
        ; Get the mouse position
        MouseGetPos(&mX, &mY)

        ; Show the menu at mouse position
        holidayMenu.Show(mX, mY)
    } catch Error as err {
        MsgBox("Error showing menu: " err.Message)
    }
}

; Handler functions to pass the specific holiday to the actual functions
ShowHolidayDatesHandler(ItemName, ItemPos, MyMenu) {
    ; Extract the holiday name from the menu item text
    holiday := RegExReplace(ItemName, "^Show Future Dates for '|'$", "")
    ShowHolidayDates(holiday)
}

NavigateToNextOccurrenceHandler(ItemName, ItemPos, MyMenu) {
    ; Extract the holiday name from the menu item text
    holiday := RegExReplace(ItemName, "^Jump to Next Year's '|'$", "")
    NavigateToNextOccurrence(holiday)
}

; ===================================================================
; Process the MCN_GETDAYSTATE notification
; https://learn.microsoft.com/en-us/windows/win32/controls/mcn-getdaystate
; The first notification is sent while the GuiControl is created.
; -------------------------------------------------------------------
WM_NOTIFY(W, L, *) { ; first notification
    if (NumGet(L, A_PtrSize * 2, "Int") = -747)
        return MCN_GETDAYSTATE("DUMMY", L)
}
; -------------------------------------------------------------------
MCN_GETDAYSTATE(MC, L) {
    static OffHwnd := 0,
        OffCode := OffHwnd + (A_PtrSize * 2),
        OffYear := OffCode + A_PtrSize,
        OffMonth := OffYear + 2,
        OffCount := OffMonth + 14,
        OffArray := OffCount + A_PtrSize
    local Year, Month, MonthCount, Addr, CurrentDate, BoldDays, I
    Year := NumGet(L + OffYear, "UShort")
    Month := NumGet(L + OffMonth, "UShort")
    MonthCount := NumGet(L + OffCount, "Int")
    global hlYear := Year
    global hlMonth := SubStr("0" . Month, -2) ; pad
    Addr := NumGet(L + OffArray, "UPtr")
    CurrentDate := Format("{:}{:02}01000000", Year, Month)
    loop MonthCount {
        BoldDays := 0
        loop DIM(CurrentDate) {
            I := A_Index - 1
            if (IsHoliday(CurrentDate) != "") {
                BoldDays |= 1 << I
            }
            CurrentDate := DateAdd(CurrentDate, 1, "D")
        }
        NumPut("UInt", BoldDays, Addr)
        Addr += 4
        CurrentDate := SubStr(CurrentDate, 1, 6) . "01000000"
    }
    if (!toggle) {
        ToolTip(, , , "1")  ; Hide the tooltip
    }
    else {
        HolidayNames()
    } ; Updates tooltip when scrolling months.
    return 1
}
; ===================================================================
Set_CS_DBLCLKS(HWND) {
    ; GCL_STYLE = -26, CS_DBLCLKS = 0x0008
    if (A_PtrSize = 8)
        return DllCall("SetClassLongPtrW", "Ptr", HWND, "Int", -26, "Ptr", 0x0008)
    return DllCall("SetClassLongW", "Ptr", HWND, "Int", -26, "Ptr", 0x0008)
}
; ===================================================================
DIM(Date) { ; get the number of days in the month of Date
    Date := DateAdd(SubStr(Date, 1, 6), 31, "D")
    Date := DateAdd(SubStr(Date, 1, 6), -1, "D")
    return (SubStr(Date, 7, 2) + 0)
}
; ===================================================================
SendDateCal() {
    if !GetKeyState("Alt")
        local Date := FormatTime(MCGUI["MC"].Value, TypeOutFormat)
    else
        local Date := FormatTime(MCGUI["MC"].Value, TypeOutAltFormat)
    MCGUIClose()
    WinActivate(TargetWindow)
    if !WinWaitActive(TargetWindow, , 1)
        return
    SendInput(Date)
    ;SoundBeep ; Temporary send notification.
}

SendDateAlt() {
    local Date := FormatTime(MCGUI["MC"].Value, TypeOutAltFormat)
    MCGUIClose()
    WinActivate(TargetWindow)
    if !WinWaitActive(TargetWindow, , 1)
        return
    SendInput(Date)
    ;SoundBeep ; Temporary send notification.
}

; ===================================================================
; Function Name: isHoliday, (see links at top of code)
; Original Author: tidbit, Jun 11, 2020
; Converted to AHK v2 by just me, Dec 12, 2023
; Tweaked using AI by kunkel321, Feb 22, 2025
; -- got rid of 'Business only' parameter
; -- added beginning and end year
; -- added "nearest weekday" option
; CaptInsano added 'orginal_year' feature, mar 13, 2025
; ===================================================================
IsHoliday(YYYYMMDDHHMISS := "", StopAtFirst := 0) {
    static Eastern := Map()
    local TStamp := (YYYYMMDDHHMISS = "") ? A_Now : YYYYMMDDHHMISS
    ; not a valid timestamp
    if !IsTime(TStamp)
        return -1
    local Out := "" ; return a string of all possible events today
    ; grab more data than needed. safety first.
    local Date := StrSplit(FormatTime(TStamp, "yyyy|MM|dd|MMMM|dddd"), "|")
    Date.Push(Substr(FormatTime(TStamp, "YWeek"), 5))
    Date.Push(FormatTime(TStamp, "YDay"))
    Date := { Year: Date[1], Mon: Date[2], Day: Date[3], MonN: Date[4], DayN: Date[5], DayY: Date[7], WeekY: Date[6] }
    ; Leap-year
    local IsLeap := (((Mod(Date.Year, 4) = 0) && (Mod(Date.Year, 100) != 0)) || (Mod(Date.Year, 400) = 0))
    ; Easter... Amazing. Thank you, "Nature" Journal - 1876
    local EDay, EMon
    if Eastern.Has(Date.Year) {
        EDay := Eastern[Date.Year].EDay
        EMon := Eastern[Date.Year].EMon
    }
    else {
        EasterSunday(Date.Year, &EMon, &EDay)
        Eastern[Date.Year] := { EDay: EDay, EMon: EMon }
    }

    ; MARK: Holiday Define.
    ; single space delimited, strictly
    ; ["month day-day dayName", "Day Text", start_year, end_year, original_year]
    ; if "dayName" = "absolute", "month" becomes "isLeapYear", and "day-day" is a number between 1-366
    ; if "dayName" = "nearest", the holiday moves to nearest weekday when falling on weekend
    ; start_year and end_year are optional. If only one year is specified, it's treated as a single-year event
    ; original_year is optional and formatted as 'YYYY'.  If included, it will add '(n)' where n is the number of years since original, i.e. age
    local Dates := [
        ["01 01", "New Year's Day"],
        ; E.g. MLK day is always a Monday in Jan, and always falls from the 15th to the 21st.
        ["01 15-21 Monday", "MLK Jr. Day"],
        ["02 02", "Groundhog Day"],
        ;["02 10", "Someone's Birthday", , , 2011], ; Example Feb 13 birthday (with age shown)
        ; E.g. Valentines Day is always second month, 14th day.
        ["02 14", "Valentines Day"],
        ["02 15-21 Monday", "Presidents Day"],
        ["02 29", "Leap Day"],
        ["03 08-14 Sunday", "Daylight Savings Begins"], ; Second Sunday in March (Spring Ahead/Loose hour of sleep)
        ["03 14", "Pi Day"],
        ["03 17", "St. Patrick's Day"],
        ; Years make it a single (or double)-year event.  Remove after it's used.
        ;["03 14", "Lunar Eclipse", 2025],
        ["03 20", "Spring Equinox", 2025, 2026],
        ;["03 17-21", "Spring Break", 2025],
        ["04 15", "Tax Day"],
        ["05 08-14 Sunday", "Mother's Day"],
        ["05 25-31 Monday", "Memorial Day"],
        ; Juneteenth is celebrated on the 19th, or the nearest weekday (M or F) if the 19th is a weekend.
        ["06 19 nearest", "Juneteenth", , , 1866],
        ["06 15-21 Sunday", "Father's Day"],
        ["06 21", "Summer Solstice", 2026],
        ["07 04", "Independence Day", , , 1776],
        ["08 25", "Anniversary", , , 2000], ;       <---------- Specific to kunkel321, remove.
        ["09 01-07 Monday", "Labor Day"],
        ["09 22", "Autumn Equinox", 2025, 2026], ; Happens on same date both years, so...
        ["10 31", "Halloween"],
        ["11 01-07 Sunday", "Daylight Savings Ends"], ; First Sunday in November (Fall Behind/Gain hour of sleep)
        ["11 11 nearest", "Veterans Day"],
        ["11 22-28 Thursday", "Thanksgiving Day"],
        ["12 21", "Winter Solstice", 2025, 2026], ; Same date both years.
        ["12 25", "Christmas Day"],
        [EMon " " EDay, "Easter"] ; No comma after last array element :)
    ]

    local Stop := 0, Holiday, Stamp, Range, TTT, IsBetween
    for Day In Dates {
        ; Check year range if specified
        if (Day.Length = 3 or Day.Length = 4) {
            ; If only one year is specified, treat it as both start and end year
            local StartYear := Day[3]
            local EndYear := (Day.Length >= 4) ? Day[4] : StartYear

            ; Skip if current year is outside the range
            if (Date.Year < StartYear || Date.Year > EndYear)
                continue
        }

        Holiday := Day[2] ; give it a nicer name
        Stamp := StrSplit(Day[1], " ")
        while Stamp.Length < 3
            Stamp.Push("")

        if (Stamp[3] = "nearest") {
            ; Handle holidays that move to nearest weekday
            Range := [Stamp[2], Stamp[2]] ; Single date

            ; Create a timestamp for the actual holiday date
            local HolidayDate := Date.Year Stamp[1] Stamp[2]
            local HolidayDayName := FormatTime(HolidayDate, "dddd")

            ; Determine observed date based on day of week
            if (HolidayDayName = "Saturday") {
                ; Move to Friday
                local NewDay := Format("{:02}", Stamp[2] - 1)
                if (Date.Mon = Stamp[1] && Date.Day = NewDay)
                    Out .= Holiday "`n", Stop := 1
            }
            else if (HolidayDayName = "Sunday") {
                ; Move to Monday
                local NewDay := Format("{:02}", Stamp[2] + 1)
                if (Date.Mon = Stamp[1] && Date.Day = NewDay)
                    Out .= Holiday "`n", Stop := 1
            }
            else {
                ; Regular weekday - use actual date
                if (Date.Mon = Stamp[1] && Date.Day = Stamp[2])
                    Out .= Holiday "`n", Stop := 1
            }
        }
        else if (Stamp[3] = "absolute") {
            Range := [Stamp[2], Stamp[2]]
            if (IsLeap = Stamp[1] && Date.DayY = Stamp[2])
                Out .= Holiday "`n", Stop := 1
        }
        else {
            if Day.Length = 5 { ;age is called for
                iAge := Date.year - Day[5]
                Holiday .= " (" iAge ")"
            }
            Range := StrSplit(Stamp[2], "-")
            if Range.Length = 1
                Range.Push(Range[1])

            ; set a temp var to blank if a weekday wasn't specified.
            ; Otherwise check if the specified day is today
            TTT := (Stamp[3] = "") ? "" : Date.DayN
            IsBetween := (Date.Day >= Range[1] && Date.Day <= Range[2])
            if (Date.Mon = Stamp[1] && IsBetween = 1 && TTT = Stamp[3])
                Out .= Holiday "`n", Stop := 1
        }
        if (StopAtFirst = 1 && Stop = 1)
            return Trim(Out, "`r`n `t")
    }
    return Trim(Out, "`r`n `t")

}

EasterSunday(Year, &Month, &Day) {
    A := Mod(Year, 19),
    B := Floor(Year / 100),
    C := Mod(Year, 100),
    D := Floor(B / 4),
    E := Mod(B, 4),
    F := Floor((B + 8) / 25),
    G := Floor((B - F + 1) / 3),
    H := Mod(((19 * A) + B - D - G + 15), 30),
    I := Floor(C / 4),
    K := Mod(C, 4),
    L := Mod((32 + (2 * E) + (2 * I) - H - K), 7),
    M := Floor((A + (11 * H) + (22 * L)) / 451),
    Month := Format("{:02}", Floor((H + L + (7 * M) + 114) / 31)),
    Day := Format("{:02}", Mod((H + L - (7 * M) + 114), 31) + 1)
}

;####################################################################
; MARK: ToolTip Options
; Below is another tool...  Also made by by Just Me !!! :)
; ========== Class ToolTipOptions - 2023-09-10 ==================
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=113308
; ----------------------------------------------------------------------------------------------------------------------
;ToolTipOptions.Init()
; ----------------------------------------------------------------------------------------------------------------------
;ToolTipOptions.SetFont("s14", "Calibri")
;ToolTipOptions.SetMargins(5,5,5,5) ; Left, Top, Right, Bottom
;ToolTipOptions.SetTitle("Title" , 4)
;ToolTipOptions.SetColors("Default", "Default")
;ToolTipOptions.SetColors("0xFFFFF0", "0x800000")
;ToolTip("Hello world!")
; ----------------------------------------------------------------------------------------------------------------------

; ======================================================================================================================
; ToolTipOptions        -  additional options for ToolTips
;
; Tooltip control       -> https://learn.microsoft.com/en-us/windows/win32/controls/tooltip-control-reference
; TTM_SETMARGIN         = 1050
; TTM_SETTIPBKCOLOR     = 1043
; TTM_SETTIPTEXTCOLOR   = 1044
; TTM_SETTITLEW         = 1057
; WM_SETFONT            = 0x30
; SetClassLong()        -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclasslongw
; ======================================================================================================================
class ToolTipOptions {
    ; -------------------------------------------------------------------------------------------------------------------
    static HTT := DllCall("User32.dll\CreateWindowEx", "UInt", 8, "Str", "tooltips_class32", "Ptr", 0, "UInt", 3
        , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0)
    static SWP := CallbackCreate(ObjBindMethod(ToolTipOptions, "_WNDPROC_"), , 4) ; subclass window proc
    static OWP := 0                                                               ; original window proc
    static ToolTips := Map()
    ; -------------------------------------------------------------------------------------------------------------------
    static BkgColor := ""
    static TktColor := ""
    static Icon := ""
    static Title := ""
    static HFONT := 0
    static Margins := ""
    ; -------------------------------------------------------------------------------------------------------------------
    static Call(*) => False ; do not create instances
    ; -------------------------------------------------------------------------------------------------------------------
    ; Init()          -  Initialize some class variables and subclass the tooltip control.
    ; -------------------------------------------------------------------------------------------------------------------
    static Init() {
        if (This.OWP = 0) {
            This.BkgColor := ""
            This.TktColor := ""
            This.Icon := ""
            This.Title := ""
            This.Margins := ""
            if (A_PtrSize = 8)
                This.OWP := DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.SWP, "UPtr")
            else
                This.OWP := DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.SWP, "UInt")
            OnExit(ToolTipOptions._EXIT_, -1)
            return This.OWP
        }
        else
            return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ;  Reset()        -  Close all existing tooltips, delete the font object, and remove the tooltip's subclass.
    ; -------------------------------------------------------------------------------------------------------------------
    static Reset() {
        if (This.OWP != 0) {
            for HWND In This.ToolTips.Clone()
                DllCall("DestroyWindow", "Ptr", HWND)
            This.ToolTips.Clear()
            if This.HFONT
                DllCall("DeleteObject", "Ptr", This.HFONT)
            This.HFONT := 0
            if (A_PtrSize = 8)
                DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.OWP, "UPtr")
            else
                DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.OWP, "UInt")
            This.OWP := 0
            return True
        }
        else
            return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; SetColors()     -  Set or remove the text and/or the background color for the tooltip.
    ; Parameters:
    ;     BkgColor    -  color value like used in Gui, Color, ...
    ;     TxtColor    -  see above.
    ; -------------------------------------------------------------------------------------------------------------------
    static SetColors(BkgColor := "", TxtColor := "") {
        This.BkgColor := BkgColor = "" ? "" : BGR(BkgColor)
        This.TxtColor := TxtColor = "" ? "" : BGR(TxtColor)
        BGR(Color, Default := "") { ; converts colors to BGR
            ; HTML Colors (BGR)
            static HTML := { AQUA: 0x00FFFF, BLACK: 0x000000, BLUE: 0x0000FF, FUCHSIA: 0xFF00FF, GRAY: 0x808080,
                GREEN: 0x008000, LIME: 0x00FF00, MAROON: 0x800000, NAVY: 0x000080, OLIVE: 0x808000,
                PURPLE: 0x800080, RED: 0xFF0000, SILVER: 0xC0C0C0, TEAL: 0x008080, WHITE: 0xFFFFFF,
                YELLOW: 0xFFFF00 }
            if IsInteger(Color)
                return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
            return HTML.HasProp(Color) ? HTML.%Color% : Default
        }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; SetFont()       -  Set or remove the font used by the tooltip.
    ; Parameters:
    ;     FntOpts     -  font options like Gui.SetFont(Options, ...)
    ;     FntName     -  font name like Gui.SetFont(..., Name)
    ; -------------------------------------------------------------------------------------------------------------------
    static SetFont(FntOpts := "", FntName := "") {
        static HDEF := DllCall("GetStockObject", "Int", 17, "UPtr") ; DEFAULT_GUI_FONT
        static LOGFONTW := 0
        if (FntOpts = "") && (FntName = "") {
            if This.HFONT
                DllCall("DeleteObject", "Ptr", This.HFONT)
            This.HFONT := 0
            LOGFONTW := 0
        }
        else {
            if (LOGFONTW = 0) {
                LOGFONTW := Buffer(92, 0)
                DllCall("GetObject", "Ptr", HDEF, "Int", 92, "Ptr", LOGFONTW)
            }
            HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
            LOGPIXELSY := DllCall("GetDeviceCaps", "Ptr", HDC, "Int", 90, "Int")
            DllCall("ReleaseDC", "Ptr", HDC, "Ptr", 0)
            if (FntOpts != "") {
                for Opt In StrSplit(RegExReplace(Trim(FntOpts), "\s+", " "), " ") {
                    switch StrUpper(Opt) {
                        case "BOLD": NumPut("Int", 700, LOGFONTW, 16)
                        case "ITALIC": NumPut("Char", 1, LOGFONTW, 20)
                        case "UNDERLINE": NumPut("Char", 1, LOGFONTW, 21)
                        case "STRIKE": NumPut("Char", 1, LOGFONTW, 22)
                        case "NORM": NumPut("Int", 400, "Char", 0, "Char", 0, "Char", 0, LOGFONTW, 16)
                        Default:
                            O := StrUpper(SubStr(Opt, 1, 1))
                            V := SubStr(Opt, 2)
                            switch O {
                                case "C":
                                    continue ; ignore the color option
                                case "Q":
                                    if !IsInteger(V) || (Integer(V) < 0) || (Integer(V) > 5)
                                        Throw ValueError("Option Q must be an integer between 0 and 5!", -1, V)
                                    NumPut("Char", Integer(V), LOGFONTW, 26)
                                case "S":
                                    if !IsNumber(V) || (Number(V) < 1) || (Integer(V) > 255)
                                        Throw ValueError("Option S must be a number between 1 and 255!", -1, V)
                                    NumPut("Int", -Round(Integer(V + 0.5) * LOGPIXELSY / 72), LOGFONTW)
                                case "W":
                                    if !IsInteger(V) || (Integer(V) < 1) || (Integer(V) > 1000)
                                        Throw ValueError("Option W must be an integer between 1 and 1000!", -1, V)
                                    NumPut("Int", Integer(V), LOGFONTW, 16)
                                Default:
                                    Throw ValueError("Invalid font option!", -1, Opt)
                            }
                    }
                }
            }
            NumPut("Char", 1, "Char", 4, "Char", 0, LOGFONTW, 23) ; DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS
            NumPut("Char", 0, LOGFONTW, 27) ; FF_DONTCARE
            if (FntName != "")
                StrPut(FntName, LOGFONTW.Ptr + 28, 32)
            if !(HFONT := DllCall("CreateFontIndirectW", "Ptr", LOGFONTW, "UPtr"))
                Throw OSError()
            if This.HFONT
                DllCall("DeleteObject", "Ptr", This.HFONT)
            This.HFONT := HFONT
        }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; SetMargins()    -  Set or remove the margins used by the tooltip
    ; Parameters:
    ;     L, T, R, B  -  left, top, right, and bottom margin in pixels.
    ; -------------------------------------------------------------------------------------------------------------------
    static SetMargins(L := 0, T := 0, R := 0, B := 0) {
        if ((L + T + R + B) = 0)
            This.Margins := 0
        else {
            This.Margins := Buffer(16, 0)
            NumPut("Int", L, "Int", T, "Int", R, "Int", B, This.Margins)
        }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; SetTitle()      -  Set or remove the title and/or the icon displayed on the tooltip.
    ; Parameters:
    ;     Title       -  string to be used as title.
    ;     Icon        -  icon to be shown in the ToolTip.
    ;                    This can be the number of a predefined icon (1 = info, 2 = warning, 3 = error
    ;                    (add 3 to display large icons on Vista+) or a HICON handle.
    ; -------------------------------------------------------------------------------------------------------------------
    static SetTitle(Title := "", Icon := "") {
        switch {
            case (Title = "") && (Icon != ""):
                This.Icon := Icon
                This.Title := " "
            case (Title != "") && (Icon = ""):
                This.Icon := 0
                This.Title := Title
            Default:
                This.Icon := Icon
                This.Title := Title
        }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; For internal use only!
    ; -------------------------------------------------------------------------------------------------------------------
    static _WNDPROC_(hWnd, uMsg, wParam, lParam) {
        ; WNDPROC -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
        switch uMsg {
            case 0x0411: ; TTM_TRACKACTIVATE - just handle the first message after the control has been created
                if This.ToolTips.Has(hWnd) && (This.ToolTips[hWnd] = 0) {
                    if (This.BkgColor != "")
                        SendMessage(1043, This.BkgColor, 0, hWnd)                ; TTM_SETTIPBKCOLOR
                    if (This.TxtColor != "")
                        SendMessage(1044, This.TxtColor, 0, hWnd)                ; TTM_SETTIPTEXTCOLOR
                    if This.HFONT
                        SendMessage(0x30, This.HFONT, 0, hWnd)                   ; WM_SETFONT
                    if (Type(This.Margins) = "Buffer")
                        SendMessage(1050, 0, This.Margins.Ptr, hWnd)             ; TTM_SETMARGIN
                    if (This.Icon != "") || (This.Title != "")
                        SendMessage(1057, This.Icon, StrPtr(This.Title), hWnd)   ; TTM_SETTITLE
                    This.ToolTips[hWnd] := 1
                }
            case 0x0001: ; WM_CREATE
                DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "Ptr", 0, "Ptr", StrPtr(""))
                This.ToolTips[hWnd] := 0
            case 0x0002: ; WM_DESTROY
                This.ToolTips.Delete(hWnd)
        }
        return DllCall(This.OWP, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "UInt")
    }
    ; -------------------------------------------------------------------------------------------------------------------
    static _EXIT_(*) {
        if (ToolTipOptions.OWP != 0)
            ToolTipOptions.Reset()
    }
}
; ------------------------- End of Just Me's ToolTipOptions class ------------------------------------------------------

; MARK: Scriptlets
; The below functions are called from the popup menu that appears when Shift+Clicking
; a monthCal date, or upon Shift+Enter, when monthCal gui is active.  The first
; two functions only appear if the selected date is a holiday.
; Modified to accept a specific holiday name
ShowHolidayDates(holiday := "") {
    ; If no holiday provided, try to get it from the selected date
    if (holiday = "") {
        selectedDate := MCGUI["MC"].Value
        holiday := isHoliday(selectedDate)
        ; If there are multiple holidays, just use the first one
        if InStr(holiday, "`n")
            holiday := StrSplit(holiday, "`n")[1]
    }

    ; Set up the year range
    syYear := A_Year  ; Start from current year
    eyYear := syYear + 20  ; Look ahead 20 years
    thReport := ""
    title := "Occurrences of " . holiday . "`nbetween " . syYear . " and " . eyYear
    loopDate := syYear . "0101000000"  ; Start from January 1st of start year

    try {
        while true {
            ; Check if we've exceeded our end year
            currentYear := Integer(FormatTime(loopDate, "yyyy"))
            if (currentYear > eyYear)
                break

            if (checkHoliday := isHoliday(loopDate)) {
                if InStr(checkHoliday, holiday) {
                    thisFormDate := FormatTime(loopDate, "ddd yyyy MMM dd")
                    thReport .= thisFormDate . ": " . holiday . "`n"
                }
            }
            loopDate := DateAdd(loopDate, 1, "days")
        }

        ShowReport(title, thReport)
    } catch Error as err {
        MsgBox("Error processing dates: " err.Message)
    }
}

; Modified to accept a specific holiday name
NavigateToNextOccurrence(holiday := "") {
    try {
        selectedDate := MCGUI["MC"].Value
        currentYear := FormatTime(selectedDate, "yyyy")
        
        ; If no holiday provided, try to get it from the selected date
        if (holiday = "") {
            holiday := isHoliday(selectedDate)
            ; If there are multiple holidays, just use the first one
            if InStr(holiday, "`n")
                holiday := StrSplit(holiday, "`n")[1]
        }

        ; Start checking from next year
        checkDate := currentYear + 1 . FormatTime(selectedDate, "MM") . "01"
        found := false

        ; Look ahead up to 2 years
        loop 730 {
            if (checkHoliday := isHoliday(checkDate)) {
                if InStr(checkHoliday, holiday) {
                    ; Navigate to the date
                    MCGUI["MC"].Value := checkDate
                    found := true
                    break
                }
            }
            checkDate := DateAdd(checkDate, 1, "days")
        }

        if !found {
            MsgBox("No occurrence of '" holiday "' found in next 2 years.")
        }
    } catch Error as err {
        MsgBox("Error navigating to next occurrence: " err.Message)
    }
}

ShowYearHolidays(*) {
    try {
        ; Get the year from the selected date
        selectedDate := MCGUI["MC"].Value
        selectedYear := FormatTime(selectedDate, "yyyy")

        ; Start with January 1st of selected year
        tyDate := selectedYear . "0101"
        title := "Holidays for " . selectedYear
        content := ""

        loop 365 { ; Will mis 'New Year's Eve' on Leapyears.  Do we care?
            if (holiday := isHoliday(tyDate)) {
                ftyDate := FormatTime(tyDate, "ddd MMM dd")
                content .= ftyDate . ": " . holiday . "`n"
            }
            tyDate := DateAdd(tyDate, 1, "days")
        }

        ShowReport(title, content, 4)
    } catch Error as err {
        MsgBox("Error getting year holidays: " err.Message)
    }
}

ShowMonthHolidays(*) {
    ; Get the month from the selected date
    selectedDate := MCGUI["MC"].Value
    selectedMonth := FormatTime(selectedDate, "MM")
    monthReport := ""
    ; Start from current year
    startYear := A_Year
    daysInMonth := 31  ; Maximum days in a month
    title := "  For Month " . FormatTime(selectedDate, "MMMM")

    try {
        loop 20 {
            myDate := startYear . selectedMonth
            loop daysInMonth {
                if (holiday := isHoliday(myDate)) {
                    myFDate := FormatTime(myDate, "yyyy MMM dd ddd")
                    monthReport .= myFDate . ": " . holiday . "`n"
                }
                myDate := DateAdd(myDate, 1, "days")
            }
            startYear++
        }

        ShowReport(title, monthReport)
    } catch Error as err {
        MsgBox("Error checking month holidays: " err.Message)
    }
}

ShowDateRangeHolidays(*) {
    try {
        selectedDate := MCGUI["MC"].Value
        defaultEnd := DateAdd(selectedDate, 90, "days")

        ; Format dates for input box default text
        startStr := FormatTime(selectedDate, "yyyy-MM-dd")
        endStr := FormatTime(defaultEnd, "yyyy-MM-dd")

        ; Get date range from user
        if !(userInput := InputBox(
            "Enter date range (YYYY-MM-DD to YYYY-MM-DD)",
            "Date Range",
            "w300 h130",
            startStr " to " endStr
        ).Value) {
            return
        }

        ; Parse input
        dates := StrSplit(userInput, " to ")
        if dates.Length != 2 {
            MsgBox("Invalid input format!")
            return
        }

        ; Convert string dates to proper format
        try {
            dateParts1 := StrSplit(dates[1], "-")
            dateParts2 := StrSplit(dates[2], "-")

            if (dateParts1.Length != 3 || dateParts2.Length != 3) {
                throw Error("Invalid date format")
            }

            startDate := dateParts1[1] dateParts1[2] dateParts1[3]
            endDate := dateParts2[1] dateParts2[2] dateParts2[3]
        } catch Error as err {
            MsgBox("Invalid date format. Please use YYYY-MM-DD")
            return
        }

        ; Generate report
        rangeReport := "Holidays from " dates[1] " to " dates[2] "`n`n"
        currentDate := startDate
        endStamp := endDate

        ; Calculate number of days between dates
        dayCount := DateDiff(endStamp, startDate, "days")

        loop dayCount + 1 {  ; +1 to include the end date
            if (holiday := isHoliday(currentDate)) {
                rangeReport .= FormatTime(currentDate, "ddd yyyy MMM dd") ": " holiday "`n"
            }
            currentDate := DateAdd(currentDate, 1, "days")
        }

        A_Clipboard := rangeReport
        SoundBeep  ; Signal completion3-20-2025
    } catch Error as err {
        MsgBox("Error processing date range: " err.Message)
    }
}

; This function gets called from the above scriptlets.
ShowReport(title, content, tooltipNum := 3) {
    if MenuReportsAsToolTips {
        ; Get the mouse position for tooltip placement
        MouseGetPos(&mX, &mY)
        ToolTip(title "`n`n" content, mX + 20, mY + 20, tooltipNum)
        ; Auto-hide tooltip after 30 seconds
        SetTimer () => ToolTip(, , , tooltipNum), ReportToolTipTimeout * 1000
    } else {
        MsgBox(title "`n`n" content)
    }
}

; MARK: DEBUGGING FUNC.
; Helper functions for conditional logging
DTLogError(message) {
    if (ERROR_LOG) {
        FileAppend("ErrLog: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Data\Datetool_error_debug_log.txt")
    }
}
DTDebug(message) {
    if (DEBUG_LOG) {
        FileAppend("Debug: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Data\Datetool_error_debug_log.txt")
    }
}
; MARK: END