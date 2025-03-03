;#SingleInstance
;#Requires AutoHotkey v2+

;  Gets included with AutoCorrect2 via #Include.

;======== DatePicker-H =========================================================
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=124254

; The 'H' is for 'Holidays.'   Version: 3-3-2025.
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
; 2-21-2025 Added support for alternate date format as recommended by delio.
; 2-22-2025 Several changes to isHoliday function by kunkel321, using AI
; 2-23-2025 Added holiday report scriptlets menu.  Again,, AI code.  Use with caution.

; Known issue:  With MonthCal, clicking next/last month arrows too fast enters 
; the date, rather than just scrolling dates. (Gets read as 'double click.')

;======== Directions for Use: Date HotStrings===================================
; For today, type ";d0" (semicolon dee zero) into edit field.
; For future dates, type ";dX" where X is 1-9.
; For previous dates, type ";ddX" where X is 1-9.
; Information ToolTip shows for X seconds.  
; Note:  Press Alt+; inplace of ; for the alternate date format.
;        example: Press Alt+;, then d, then 2, for day after tomorrow.

;======== Directions for Use: Popup Calendar ===================================
; Alt+Shift+D ----> Show calendar.
; Press h (while calendar is active) ----> toggle list of holidays for shown months.
; Press t (while calendar is active) ----> go to today.
; Press 1-5 (while calendar is active) ----> Show this many months.
; Double-click a date, or press Enter, to type it.
; D-click/Enter while holding Alt key for alternate date format.
; D-Click/Enter while holding Shift key for menu of scriptlet holiday report tools.
; Calendar appears placed over active window.
; Waits for window to be active again before typing date.

; See IsHoliday() function, below, for array of custom holidays and how to add 
; your own custom holidays. Please remove any personal dates, and add your own.

; ==============================================================================
;^Esc::ExitApp ; Ctrl+Esc to just kill the whole ding dang script. hide

MyAutoCorrectFileName := "AutoCorrect2.exe" ; <------- CHANGE To NAME of your AutoCorrect script? 
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

;======== Calendar User Options ================================================
guiTitle := "DateTool-H"         ; change title if desired 
monthCalHotkey := "!+d"          ; Hotkey: Alt+Shift+D.  Change as desired. 
TypeOutFormat := "M-d-yyyy"      ; preferred date format for typing date in edit field
TypeOutAltFormat := "yyyy-MM-dd" ; alternate preferred date format for typing 
HolidayListFormat := "MMM-dd"    ; preferred date format for popup list
MonthCount := 3                  ; default number of months to display vertically
ShowSingleHoliday := 1           ; show holiday when click on day (1 = yes / 0 = no)
MenuReportsAsToolTips := 1       ; show menu reports as tooltips (1 = tooltip / 0 = msgbox)
ReportToolTipTimeout := 20       ; reports tooltips disappear after this many seconds.
; User Note: If you have many holidays defined, the menu reports can be quite large,
; so have 'MenuReportsAsToolTips:=0' or have a small font for tooltips (next section.) 
; ==============================================================================

if FileExist("colorThemeSettings.ini") {
   settingsFile := "colorThemeSettings.ini"
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
ToolTipOptions.SetFont("s12", "Calibri") ; Change as desired.
ToolTipOptions.SetMargins(5,5,5,5) ; Left, Top, Right, Bottom.
;ToolTipOptions.SetColors(formColor, fontColor) ; background, font : Use this for theme colors.
ToolTipOptions.SetColors("Default", "Default") ; background, font

;=========== Hotstrings ========================================================
; Warning:  The below StrReplace expects these hotstrings to have THESE names.  Edit with caution.
:?*:;dd9:: ; For entering dates.
:?*:;dd8:: ; all start with {semicolon}
:?*:;dd7:: ; ddn = in the past, n days.
:?*:;dd6:: ; dn = future by n days.
:?*:;dd5::
:?*:;dd4::
:?*:;dd3::
:?*:;dd2::
:?*:;dd1:: ; yesterday
:?*:;d0:: ; ;d0 = today
:?*:;d1:: ; tomorrow
:?*:;d2:: ; day after tomorrow
:?*:;d3:: ; etc.
:?*:;d4::
:?*:;d5::
:?*:;d6::
:?*:;d7::
:?*:;d8::
:?*:;d9:: {
   nOffset := StrReplace(A_ThisHotkey, ":?*:;d", "") ; Remove first 'd' and other stuff.
   nOffset := StrReplace(nOffset, "d", "-") ; If second 'd' present, change to -.
   dateString(nOffset, 0) ; second par is 0=normal format, 1=alt format
}

; Code for when Alt key is used with semicolon.
!;:: ; hide from hotkey tool
startHook(*) {
	Global dtih := InputHook('L4 V I2')
	dtih.OnChar := dtih_Char
	dtih.Start
}

dtih_Char(dtih, char) {
	Global Chars .= char
   If RegExMatch(Chars, "(d|dd)[0-9]") {
      nOffset := StrReplace(Chars, "dd", "-") ; 'dd' means past date, so neg offset
      nOffset := StrReplace(nOffset, "d", "") ; if 'd' present, remove.
      dateString(nOffset, 1) ; second par is 0=normal format, 1=alt format
		dtih.Stop
		Chars := ""
	}
	Else If (StrLen(Chars) > 3) {
		dtih.Stop
		Chars := ""
	}
}

dateString(nOffset, AltForm) {
   DatePicked := DateAdd(A_Now, nOffset, "D") ; Puts offset into date format.
   ShowToolTip(nOffset, DatePicked)

   If (AltForm = 0) {
      MyDate := FormatTime(DatePicked, TypeOutFormat)
      SendInput(MyDate)   ; This types out the date.
   }
   Else {
      MyDate := FormatTime(DatePicked, TypeOutAltFormat)
      ;msgbox "myDate " MyDate "`ndatePicked " DatePicked "`nnOffset " nOffset
      SendInput("{BS " StrLen(nOffset)+1 "}")    ; This backspaces the 'd0'
      SendInput(MyDate)   ; This types out the date.
   }
} 

;======= Date HotString ToolTip =======================================
ShowToolTip(nOffset, DatePicked)
{  dateOffset := DatePicked
   vNow := SubStr(A_Now, 1, 8)
   dateOffset := DateDiff(dateOffset, vNow, "days")
   WdayArr := [6,5,4,3,2,1,0] ; Determine days until Saturday, for suffixes below.
   daysTillSat := WdayArr[A_Wday]
   fromSat := -1 * (daysTillSat - dateOffset)
   MySuffix := ""
   if (nOffset = 0)
      MySuffix := " -- Today"
   ; Use Saturday this week as a constant in determining the following suffixes.
   if (fromSat > 0)
      MySuffix := " next week"
   if (fromSat > 8)
      MySuffix := ", week after next"
   if (fromSat < -7)
      MySuffix := " last week"
   if (fromSat < -14)
      MySuffix := ", week before last"
   DatePicked := DateAdd(DatePicked, 0, "D") ; Puts it in proper date format.
   HoliTip := (isHoliday(DatePicked) != "")? isHoliday(DatePicked) . " ---> " : ""
   DayOfWeek := FormatTime(DatePicked, "dddd")
   WeekEndTip := (DayOfWeek = "Saturday") || (DayOfWeek = "Sunday")? "Weekend ---> " : ""
   If CaretGetPos(&ttx, &tty) 
      ToolTip(HoliTip "" WeekEndTip "" DayOfWeek "" MySuffix, ttx+10, tty+25, "3") ; Set location of tooltip here.
   SetTimer () => ToolTip(,,,"3"), -2500 ; Disable tooltip in this many milisecs.
   DatePicked := ""
   nOffset := ""
} 

;======== Global Variables. Don't change =======================================
TargetWindow := 0, MCGUI := 0, hlYear := A_YYYY, hlMonth := A_MM
HolidayList := "", toggle := false  ; Variable to keep track of tooltip state

; ===================================================================

Hotkey(monthCalHotkey, MCRemake) ; Show DateTool - H
MCRemake(*) 
{ ; Hotkey is Alt+Shift+D
   Local X, Y, W, H
   Global MCGUI, TargetWindow
   If (MCGUI)
      Return
   If (TargetWindow := WinExist("A")) {
      WinGetPos(&X, &Y, &W, &H, TargetWindow)
   	X := X + (W * 0.30)
   	Y := Y + (H * 0.04)
      MCGUI := Gui("-MinimizeBox +LastFound +ToolWindow +Owner" TargetWindow, guiTitle)
      ; MCGUI := Gui("-MinimizeBox +LastFound -caption +Owner" TargetWindow, guiTitle)
      ;MCGUI.SetFont("s14") ; <--- optional thicker border
      MCGUI.OnEvent("Close", MCGUIClose)
      MCGUI.OnEvent("Escape", MCGUIClose)
      MCGUI.BackColor := formColor
      OnMessage(0x004E, WM_NOTIFY)        ; needs to be called on control creation
      MCGUI.AddMonthCal("r" MonthCount " +0x01 vMC")
      OnMessage(0x004E, WM_NOTIFY, 0)
      MCGUI["MC"].OnNotify(-747, MCN_GETDAYSTATE)
      If (ShowSingleHoliday = 1)
         MCGUI["MC"].OnEvent("Change", HandleDateChange)
      Set_CS_DBLCLKS(MCGUI["MC"].Hwnd)    ; needed to get WM_LBUTTONDBLCLK notifications for clicks on a MonthCal
      MCGUI.Show("x" X " y" Y)
      OnMessage(0x0203, WM_LBUTTONDBLCLK)
      OnMessage(0x0100, WM_KEYDOWN)
   }
}

; ===================================================================
HandleDateChange(*) {
   ShowOneHoliday() ; Handle single holiday tooltip
   ; Clear menu report tooltips if enabled
   if MenuReportsAsToolTips {
      ; Clear tooltips 3-6 (leaving 1-2 for other features)
      loop 4 {
         ToolTip(,,, A_Index + 2)
      }
   }
}

; ===================================================================
#HotIf WinActive(guiTitle)
ALt & Enter::SendDateAlt() ; For alt format date entry. hide
+Enter::ShowHolidayMenu() ; Shift+Enter to show menu. hide
h::doToggle() ; Calls function to popup list of holidays.  hide
t::MCGUI["MC"].Value := A_Now ; Hotkey for 'Go to today.' hide
1:: ; hide
2:: ; hide
3:: ; hide
4:: ; hide
5:: ; ChangeM  CNumber() ; Shows this many months. (1-5) ; hide
#HotIf 
; ===================================================================

ChangeMCNumber(*) ; Reopens calendar with specified number of months. 
{  Global MonthCount := A_ThisHotKey
   Global DefaultDate := MCGUI["MC"].Value ; Remember selected day, when changing monthcount.
   MCGuiClose()
   MCRemake() 
}
; ===================================================================

IsMouseOverMC(*) {
   mX := 0, mY := 0 
   Global isOver := 0
   WinGetPos(&cX, &cY, &cW, &cH, guiTitle)
   MouseGetPos(&mX, &mY)
   IsOver := (mX > 0 and mX < cW and mY > 0 and mY < cH)? 1 : 0
}

ShowOneHoliday(*)
{  If isHoliday(MCGUI["MC"].Value) != "" {
      IsMouseOverMC()
      If IsOver = 1
         tooltip(isHoliday(MCGUI["MC"].Value),,,"2")
      Else tooltip(isHoliday(MCGUI["MC"].Value),60,-10,"2")
   }
   Else tooltip(,,,"2")
}
; ===================================================================

doToggle(*) ; Toggles popup list of holidays.
{  global toggle
   if (toggle) 
      ToolTip(,,,"1") ; Hide the tooltip
   else HolidayNames()
   toggle := !toggle  ; Switch the toggle state
}
; ===================================================================

HolidayNames(*) ; Generate list of dates/names of holidays for shown months. 
{  thisDay := hlYear hlMonth "02000000"
   monIndex := 0, rStart := 0, rEnd := 0
   loop MonthCount+1 {
      While monIndex < MonthCount+1 {
         thisDay := DateAdd(thisDay, 1, "D")
         If SubStr(thisDay, 7, 2) = "01" {
         monIndex++
         if monIndex = 1 and SubStr(thisDay, 7, 2) = "01"
            rStart := thisDay
         if monIndex = MonthCount+1 and SubStr(thisDay, 7, 2) = "01"
            rEnd := thisDay
         }
      }
   }
   thisDay := rStart
   Global HolidayList := ""
   Loop DateDiff(rEnd, rStart, "Days") {
      If IsHoliday(thisDay) != "" 
         HolidayList .= FormatTime(thisDay, HolidayListFormat) "`t" IsHoliday(thisDay) "`n"
      thisDay := DateAdd(thisDay, 1, "D")
   } ToolTip(HolidayList, 275, 100, "1") ; <--- Adjust position of tooltip here.
}
; ===================================================================

MCGuiClose(*) {
   Global MCGUI
   MCGUI.Destroy()
   MCGUI := 0
   OnMessage(0x0203, WM_LBUTTONDBLCLK, 0)
   OnMessage(0x0100, WM_KEYDOWN, 0)
   ToolTip(,,,"1") ; close H List tooltip if it's showing
   ToolTip(,,,"2") ; close one day tooltip if it's showing
   Global toggle := false 
}
; ===================================================================
WM_KEYDOWN(W, *) {
   If (W = 0x0D) { ; VK_RETURN => ENTER key
      SendDate()
      Return 0
   }
}
; ===================================================================
WM_LBUTTONDBLCLK(*) {
   Local CtrlHwnd := 0
   MouseGetPos( , , , &CtrlHwnd, 2)
   If (CtrlHwnd = MCGUI["MC"].Hwnd) {
      if GetKeyState("Shift") {
         ToolTip(,,,"2")  ; Clear the holiday tooltip
         ShowHolidayMenu()
      } else {
         SendDate()
      }
      Return 0
   }
}

ShowHolidayMenu() {
   try {
      ; Clear any existing report tooltips
      if MenuReportsAsToolTips {
         ToolTip(,,,"3")  ; Clear menu report tooltip
      }
      
      ; Verify we have a valid date selected
      if !MCGUI["MC"].Value {
         MsgBox("No date selected!")
         return
      }
      
      ; Get the holiday for the selected date
      selectedDate := MCGUI["MC"].Value
      holiday := isHoliday(selectedDate)
      
      ; Create the menu
      holidayMenu := Menu()
      
      ; Add holiday-specific items only if a holiday is selected
      if holiday {
         holidayMenu.Add("Show Future Dates for '" holiday "'", ShowHolidayDates)
         holidayMenu.Add("Jump to Next Year's '" holiday "'", NavigateToNextOccurrence)
         holidayMenu.Add()  ; Add a separator
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

; ===================================================================
; Process the MCN_GETDAYSTATE notification
; https://learn.microsoft.com/en-us/windows/win32/controls/mcn-getdaystate
; The first notification is sent while the GuiControl is created.
; -------------------------------------------------------------------
WM_NOTIFY(W, L, *) { ; first notification
   If (NumGet(L, A_PtrSize * 2, "Int") = -747)
      Return MCN_GETDAYSTATE("DUMMY", L)
}
; -------------------------------------------------------------------
MCN_GETDAYSTATE(MC, L) {
   Static OffHwnd := 0,
         OffCode := OffHwnd + (A_PtrSize * 2),
         OffYear := OffCode + A_PtrSize,
         OffMonth := OffYear + 2,
         OffCount := OffMonth + 14,
         OffArray := OffCount + A_PtrSize
   Local Year, Month, MonthCount, Addr, CurrentDate, BoldDays, I
   Year := NumGet(L + OffYear, "UShort")
   Month := NumGet(L + OffMonth, "UShort")
   MonthCount := NumGet(L + OffCount, "Int")
   Global hlYear := Year
   Global hlMonth := SubStr("0" . Month, -2) ; pad
   Addr := NumGet(L + OffArray, "UPtr")
   CurrentDate := Format("{:}{:02}01000000", Year, Month)
   Loop MonthCount {
      BoldDays := 0
      Loop DIM(CurrentDate) {
         I := A_Index - 1
         If (IsHoliday(CurrentDate) != "") {
            BoldDays |= 1 << I
         }
         CurrentDate := DateAdd(CurrentDate, 1, "D")
      }
      NumPut("UInt", BoldDays, Addr)
      Addr += 4
      CurrentDate := SubStr(CurrentDate, 1, 6) . "01000000"
   }
   if (!toggle) {
      ToolTip(,,,"1")  ; Hide the tooltip
   } 
   else {
      HolidayNames()
   } ; Updates tooltip when scrolling months.
   Return 1
}
; ===================================================================
Set_CS_DBLCLKS(HWND) {
   ; GCL_STYLE = -26, CS_DBLCLKS = 0x0008
   If (A_PtrSize = 8)
      Return DllCall("SetClassLongPtrW", "Ptr", HWND, "Int", -26, "Ptr", 0x0008)
   Return DllCall("SetClassLongW", "Ptr", HWND, "Int", -26, "Ptr", 0x0008)
}
; ===================================================================
DIM(Date) { ; get the number of days in the month of Date
   Date := DateAdd(SubStr(Date, 1, 6), 31, "D")
   Date := DateAdd(SubStr(Date, 1, 6), -1, "D")
   Return (SubStr(Date, 7, 2) + 0)
}
; ===================================================================
SendDate() {
   If !GetKeyState("Alt")
      Local Date := FormatTime(MCGUI["MC"].Value, TypeOutFormat)
   Else 
      Local Date := FormatTime(MCGUI["MC"].Value, TypeOutAltFormat)
   MCGUIClose()
   WinActivate(TargetWindow)
   If !WinWaitActive(TargetWindow, , 1)
      Return
   SendInput(Date)
   ;SoundBeep ; Temporary send notification.
}

SendDateAlt() {
   Local Date := FormatTime(MCGUI["MC"].Value, TypeOutAltFormat)
   MCGUIClose()
   WinActivate(TargetWindow)
   If !WinWaitActive(TargetWindow, , 1)
      Return
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
; ===================================================================
IsHoliday(YYYYMMDDHHMISS := "", StopAtFirst := 0) {
   Static Eastern := Map()
   Local TStamp:=(YYYYMMDDHHMISS = "") ? A_Now : YYYYMMDDHHMISS
   ; not a valid timestamp
   If !IsTime(TStamp)
      Return -1
   Local Out := "" ; return a string of all possible events today
   ; grab more data than needed. safety first.
   Local Date := StrSplit(FormatTime(TStamp, "yyyy|MM|dd|MMMM|dddd"), "|")
   Date.Push(Substr(FormatTime(TStamp, "YWeek"), 5))
   Date.Push(FormatTime(TStamp, "YDay"))
   Date := {Year: Date[1], Mon: Date[2], Day: Date[3], MonN: Date[4], DayN: Date[5], DayY: Date[7], WeekY: Date[6]}
   ; Leap-year
   Local IsLeap := (((Mod(Date.Year, 4) = 0) && (Mod(Date.Year, 100) != 0)) || (Mod(Date.Year, 400) = 0))
   ; Easter... Amazing. Thank you, "Nature" Journal - 1876
   Local EDay, EMon
   If Eastern.Has(Date.Year) {
      EDay := Eastern[Date.Year].EDay
      EMon := Eastern[Date.Year].EMon
   }
   Else {
      EasterSunday(Date.Year, &EMon, &EDay)
      Eastern[Date.Year] := {EDay: EDay, EMon: EMon}
   }

   ; single space delimited, strictly
   ; ["month day-day dayName", "Day Text", start_year, end_year]
   ; if "dayName" = "absolute", "month" becomes "isLeapYear", and "day-day" is a number between 1-366
   ; if "dayName" = "nearest", the holiday moves to nearest weekday when falling on weekend
   ; start_year and end_year are optional. If only one year is specified, it's treated as a single-year event
   Local Dates := [
      ["01 01", "New Year's Day"],
      ; E.g. MLK day is always a Monday in Jan, and always falls from the 15th to the 21st. 
      ["01 15-21 Monday", "MLK Jr. Day"],
      ["02 02", "Groundhog Day"],
      ; E.g. Valentines Day is always second month, 14th day. 
      ["02 14", "Valentines Day"],
      ["02 15-21 Monday", "Presidents Day"],
      ["02 29", "Leap Day"],
      ["03 08-14 Sunday", "Daylight Savings Begins"], ; Second Sunday in March (Spring Ahead/Loose hour of sleep)
      ["03 14", "Pi Day"],
      ["03 17", "St. Patrick's Day"],
      ; Years make it a single (or double)-year event.  Remove after it's used. 
      ["03 14", "Lunar Eclipse", 2025, 2025], 
      ["03 20", "Spring Equinox", 2025, 2025],
      ["04 07-11", "Spring Break", 2025, 2025],
      ["04 22", "Earth Day"],
      ["04 22-30 Friday", "Arbor Day"],
      ["05 01", "May Day"],
      ["05 08-14 Sunday", "Mother's Day"],
      ["05 25-31 Monday", "Memorial Day"],
      ; Juneteenth is celebrated on the 19th, or the nearest weekday (M or F) if the 19th is a weekend. 
      ["06 19 nearest", "Juneteenth"],
      ["06 15-21 Sunday", "Father's Day"],
      ["06 20", "Summer Solstice", 2025, 2025],
      ["06 21", "Summer Solstice", 2026, 2026],
      ["07 04", "Independence Day"],
      ["08 25", "Anniversary"], ;       <---------- Specific to kunkel321, remove.
      ["09 01-07 Monday", "Labor Day"],
      ["09 22", "Autumn Equinox", 2025, 2026], ; Happens on same date both years, so...
      ["10 08-15 Monday", "Indigenous Peoples Day"],
      ["10 31", "Halloween"],
      ["11 01-07 Sunday", "Daylight Savings Ends"], ; First Sunday in November (Fall Behind/Gain hour of sleep)
      ["11 11 nearest", "Veterans Day"],
      ["11 22-28 Thursday", "Thanksgiving Day"],
      ["12 21", "Winter Solstice", 2025, 2026], ; Same date both years.
      ["12 25", "Christmas Day"],
      [ EMon " " EDay, "Easter"] ; No comma after last array element :)
   ]

   Local Stop := 0, Holiday, Stamp, Range, TTT, IsBetween
   For Day In Dates {
      ; Check year range if specified
      If (Day.Length >= 3) {
         ; If only one year is specified, treat it as both start and end year
         Local StartYear := Day[3]
         Local EndYear := (Day.Length >= 4) ? Day[4] : StartYear
         
         ; Skip if current year is outside the range
         If (Date.Year < StartYear || Date.Year > EndYear)
               Continue
      }
         
      Holiday := Day[2] ; give it a nicer name
      Stamp := StrSplit(Day[1], " ")
      While Stamp.Length < 3
         Stamp.Push("")

      If (Stamp[3] = "nearest") {
         ; Handle holidays that move to nearest weekday
         Range := [Stamp[2], Stamp[2]] ; Single date
         
         ; Create a timestamp for the actual holiday date
         Local HolidayDate := Date.Year Stamp[1] Stamp[2]
         Local HolidayDayName := FormatTime(HolidayDate, "dddd")
         
         ; Determine observed date based on day of week
         If (HolidayDayName = "Saturday") {
               ; Move to Friday
               Local NewDay := Format("{:02}", Stamp[2] - 1)
               If (Date.Mon = Stamp[1] && Date.Day = NewDay)
                  Out .= Holiday "`n", Stop := 1
         }
         Else If (HolidayDayName = "Sunday") {
               ; Move to Monday
               Local NewDay := Format("{:02}", Stamp[2] + 1)
               If (Date.Mon = Stamp[1] && Date.Day = NewDay)
                  Out .= Holiday "`n", Stop := 1
         }
         Else {
               ; Regular weekday - use actual date
               If (Date.Mon = Stamp[1] && Date.Day = Stamp[2])
                  Out .= Holiday "`n", Stop := 1
         }
      }
      Else If (Stamp[3] = "absolute") {
         Range := [Stamp[2], Stamp[2]]
         If (IsLeap = Stamp[1] && Date.DayY = Stamp[2])
               Out .= Holiday "`n", Stop := 1
      }
      Else {
         Range := StrSplit(Stamp[2], "-")
         If Range.Length = 1
               Range.Push(Range[1])
               
         ; set a temp var to blank if a weekday wasn't specified.
         ; Otherwise check if the specified day is today
         TTT := (Stamp[3] = "") ? "" : Date.DayN
         IsBetween := (Date.Day >= Range[1] && Date.Day <= Range[2])
         If (Date.Mon = Stamp[1] && IsBetween = 1 && TTT = Stamp[3])
               Out .= Holiday "`n", Stop := 1
      }

      If (StopAtFirst = 1 && Stop = 1)
         Return Trim(Out, "`r`n `t")
   }
   Return Trim(Out, "`r`n `t")
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
   L := Mod((32  +(2 * E) + (2 * I) - H - K), 7),
   M := Floor((A + (11 * H) + (22 * L)) / 451),
   Month := Format("{:02}", Floor((H + L +(7 * M) + 114) / 31)),
   Day := Format("{:02}", Mod((H + L - (7 * M) + 114), 31) + 1)
}

;####################################################################

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
Class ToolTipOptions {
   ; -------------------------------------------------------------------------------------------------------------------
   Static HTT := DllCall("User32.dll\CreateWindowEx", "UInt", 8, "Str", "tooltips_class32", "Ptr", 0, "UInt", 3
                       , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0)
   Static SWP := CallbackCreate(ObjBindMethod(ToolTipOptions, "_WNDPROC_"), , 4) ; subclass window proc
   Static OWP := 0                                                               ; original window proc
   Static ToolTips := Map()
   ; -------------------------------------------------------------------------------------------------------------------
   Static BkgColor := ""
   Static TktColor := ""
   Static Icon := ""
   Static Title := ""
   Static HFONT := 0
   Static Margins := ""
   ; -------------------------------------------------------------------------------------------------------------------
   Static Call(*) => False ; do not create instances
   ; -------------------------------------------------------------------------------------------------------------------
   ; Init()          -  Initialize some class variables and subclass the tooltip control.
   ; -------------------------------------------------------------------------------------------------------------------
   Static Init() {
      If (This.OWP = 0) {
         This.BkgColor := ""
         This.TktColor := ""
         This.Icon := ""
         This.Title := ""
         This.Margins := ""
         If (A_PtrSize = 8)
            This.OWP := DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.SWP, "UPtr")
         Else
            This.OWP := DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.SWP, "UInt")
         OnExit(ToolTipOptions._EXIT_, -1)
         Return This.OWP
      }
      Else
         Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ;  Reset()        -  Close all existing tooltips, delete the font object, and remove the tooltip's subclass.
   ; -------------------------------------------------------------------------------------------------------------------
   Static Reset() {
      If (This.OWP != 0) {
         For HWND In This.ToolTips.Clone()
            DllCall("DestroyWindow", "Ptr", HWND)
        This.ToolTips.Clear()
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := 0
         If (A_PtrSize = 8)
            DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.OWP, "UPtr")
         Else
            DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.OWP, "UInt")
         This.OWP := 0
         Return True
      }
      Else
         Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetColors()     -  Set or remove the text and/or the background color for the tooltip.
   ; Parameters:
   ;     BkgColor    -  color value like used in Gui, Color, ...
   ;     TxtColor    -  see above.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetColors(BkgColor := "", TxtColor := "") {
      This.BkgColor := BkgColor = "" ? "" : BGR(BkgColor)
      This.TxtColor := TxtColor = "" ? "" : BGR(TxtColor)
      BGR(Color, Default := "") { ; converts colors to BGR
         ; HTML Colors (BGR)
         Static HTML := {AQUA:   0x00FFFF, BLACK: 0x000000, BLUE:   0x0000FF, FUCHSIA: 0xFF00FF, GRAY:  0x808080,
                         GREEN:  0x008000, LIME:  0x00FF00, MAROON: 0x800000, NAVY:    0x000080, OLIVE: 0x808000,
                         PURPLE: 0x800080, RED:   0xFF0000, SILVER: 0xC0C0C0, TEAL:    0x008080, WHITE: 0xFFFFFF,
                         YELLOW: 0xFFFF00 }
         If IsInteger(Color)
            Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
         Return HTML.HasProp(Color) ? HTML.%Color% : Default
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetFont()       -  Set or remove the font used by the tooltip.
   ; Parameters:
   ;     FntOpts     -  font options like Gui.SetFont(Options, ...)
   ;     FntName     -  font name like Gui.SetFont(..., Name)
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetFont(FntOpts := "", FntName := "") {
      Static HDEF := DllCall("GetStockObject", "Int", 17, "UPtr") ; DEFAULT_GUI_FONT
      Static LOGFONTW := 0
      If (FntOpts = "") && (FntName = "") {
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := 0
         LOGFONTW := 0
      }
      Else {
         If (LOGFONTW = 0) {
            LOGFONTW := Buffer(92, 0)
            DllCall("GetObject", "Ptr", HDEF, "Int", 92, "Ptr", LOGFONTW)
         }
         HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
         LOGPIXELSY := DllCall("GetDeviceCaps", "Ptr", HDC, "Int", 90, "Int")
         DllCall("ReleaseDC", "Ptr", HDC, "Ptr", 0)
         If (FntOpts != "") {
            For Opt In StrSplit(RegExReplace(Trim(FntOpts), "\s+", " "), " ") {
               Switch StrUpper(Opt) {
                  Case "BOLD":      NumPut("Int", 700, LOGFONTW, 16)
                  Case "ITALIC":    NumPut("Char",  1, LOGFONTW, 20)
                  Case "UNDERLINE": NumPut("Char",  1, LOGFONTW, 21)
                  Case "STRIKE":    NumPut("Char",  1, LOGFONTW, 22)
                  Case "NORM":      NumPut("Int", 400, "Char", 0, "Char", 0, "Char", 0, LOGFONTW, 16)
                  Default:
                     O := StrUpper(SubStr(Opt, 1, 1))
                     V := SubStr(Opt, 2)
                     Switch O {
                        Case "C":
                           Continue ; ignore the color option
                        Case "Q":
                           If !IsInteger(V) || (Integer(V) < 0) || (Integer(V) > 5)
                              Throw ValueError("Option Q must be an integer between 0 and 5!", -1, V)
                           NumPut("Char", Integer(V), LOGFONTW, 26)
                        Case "S":
                           If !IsNumber(V) || (Number(V) < 1) || (Integer(V) > 255)
                              Throw ValueError("Option S must be a number between 1 and 255!", -1, V)
                           NumPut("Int", -Round(Integer(V + 0.5) * LOGPIXELSY / 72), LOGFONTW)
                        Case "W":
                           If !IsInteger(V) || (Integer(V) < 1) || (Integer(V) > 1000)
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
         If (FntName != "")
            StrPut(FntName, LOGFONTW.Ptr + 28, 32)
         If !(HFONT := DllCall("CreateFontIndirectW", "Ptr", LOGFONTW, "UPtr"))
            Throw OSError()
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := HFONT
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetMargins()    -  Set or remove the margins used by the tooltip
   ; Parameters:
   ;     L, T, R, B  -  left, top, right, and bottom margin in pixels.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetMargins(L := 0, T := 0, R := 0, B := 0) {
      If ((L + T + R + B) = 0)
         This.Margins := 0
      Else {
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
   Static SetTitle(Title := "", Icon := "") {
      Switch {
         Case (Title = "") && (Icon != ""):
            This.Icon := Icon
            This.Title := " "
         Case (Title != "") && (Icon = ""):
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
   Static _WNDPROC_(hWnd, uMsg, wParam, lParam) {
      ; WNDPROC -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
      Switch uMsg {
         Case 0x0411: ; TTM_TRACKACTIVATE - just handle the first message after the control has been created
            If This.ToolTips.Has(hWnd) && (This.ToolTips[hWnd] = 0) {
               If (This.BkgColor != "")
                  SendMessage(1043, This.BkgColor, 0, hWnd)                ; TTM_SETTIPBKCOLOR
               If (This.TxtColor != "")
                  SendMessage(1044, This.TxtColor, 0, hWnd)                ; TTM_SETTIPTEXTCOLOR
               If This.HFONT
                  SendMessage(0x30, This.HFONT, 0, hWnd)                   ; WM_SETFONT
               If (Type(This.Margins) = "Buffer")
                  SendMessage(1050, 0, This.Margins.Ptr, hWnd)             ; TTM_SETMARGIN
               If (This.Icon != "") || (This.Title != "")
                  SendMessage(1057, This.Icon, StrPtr(This.Title), hWnd)   ; TTM_SETTITLE
               This.ToolTips[hWnd] := 1
            }
         Case 0x0001: ; WM_CREATE
            DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "Ptr", 0, "Ptr", StrPtr(""))
            This.ToolTips[hWnd] := 0
         Case 0x0002: ; WM_DESTROY
            This.ToolTips.Delete(hWnd)
      }
      Return DllCall(This.OWP, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Static _EXIT_(*) {
      If (ToolTipOptions.OWP != 0)
         ToolTipOptions.Reset()
   }
}
; ------------------------- End of Just Me's ToolTipOptions class ------------------------------------------------------

; The below functions are called from the popup menu that appears when Shift+Clicking 
; a monthCal date, or upon Shift+Enter, when monthCal gui is active.  The first
; two functions only appear if the selected date is a holiday. 
ShowHolidayDates(*) {
   ; Get the holiday name from the clicked date
   selectedDate := MCGUI["MC"].Value
   holiday := isHoliday(selectedDate)
   
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
                  thReport .= thisFormDate . ": " . checkHoliday . "`n"
               }
         }
         loopDate := DateAdd(loopDate, 1, "days")
      }
      
      ShowReport(title, thReport)
   } catch Error as err {
      MsgBox("Error processing dates: " err.Message)
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

NavigateToNextOccurrence(*) {
   try {
      selectedDate := MCGUI["MC"].Value
      currentYear := FormatTime(selectedDate, "yyyy")
      holiday := isHoliday(selectedDate)
      
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
         MsgBox("No occurrence found in next 2 years.")
      }
   } catch Error as err {
      MsgBox("Error navigating to next occurrence: " err.Message)
   }
}

; This function gets called from the above scriptlets. 
ShowReport(title, content, tooltipNum := 3) {
   if MenuReportsAsToolTips {
      ; Get the mouse position for tooltip placement
      MouseGetPos(&mX, &mY)
      ToolTip(title "`n`n" content, mX + 20, mY + 20, tooltipNum)
      ; Auto-hide tooltip after 30 seconds
      SetTimer () => ToolTip(,,,tooltipNum), ReportToolTipTimeout * 1000
   } else {
      MsgBox(title "`n`n" content)
   }
}