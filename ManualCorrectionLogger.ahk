#SingleInstance
#Requires AutoHotkey v2.0
Persistent
; By Kunkel321, but inputHook based on Mike's here at: 
; https://www.autohotkey.com/boards/viewtopic.php?p=560556#p560556
; A script to run in the background all the time and log your typing
; errors and corrections, formatting the viable ones into ahk hotstrings,
; so that repeating typo patterns can later be identified and potentially
; added as new AutoCorrect library items.  The typoCache variable ignores
; non-letters (because those are not needed for typing corrections).  End 
; keys are Space (~) and Backspace (<).  The script watches for the 
; pattern "...<. ~" and then saves the corresponding hotstring
; for logging.  The log gets saved to file every X minutes. 
; The log also saves to file on exit.
; Moving the cursor or left-clicking resets the cache. 
; 3-26-2024 version.  

TraySetIcon("icons/JustLog.ico") ; A fun homemade "log" icon that Steve made.
tMenu := A_TrayMenu ; Tells script to use this when right-click system tray icon.
tMenu.Delete ; Removes all of the defalt memu items, so we can add our own. 
;tMenu.Add("Log and Reload Script", (*) => Reload())
tMenu.Add("Log and Reload Script", JustReload)
tMenu.SetIcon("Log and Reload Script", "icons/data_backup-Brown.ico")
tMenu.Add("Edit This Script", EditThisLog)
tMenu.SetIcon("Edit This Script", "icons/edit-Brown.ico")
tMenu.Add("Analyze Manual Corrections", runAnalysis)
tMenu.SetIcon("Analyze Manual Corrections", "icons/search-Brown.ico")
tMenu.Add("Exit Script", (*) => ExitApp())
tMenu.SetIcon("Exit Script", "icons/exit-Brown.ico")
tMenu.SetColor("C29A6A") ; #CD853F is "Peru"

;========= TOOLTIP COLORS ======================================================
; The iniReads are specific to Steve's computer -- If you see them, he forgot to remove them.
lColor := IniRead("WayText\wtFiles\Settings.ini", "MainSettings", "ListColor", "Default")
fColor := iniread("WayText\wtFiles\Settings.ini", "MainSettings", "FontColor", "Default")
;-----------------
ListColor := strReplace(subStr(lColor, -6), "efault", "Default")
FontColor := strReplace(subStr(fColor, -6), "efault", "Default")

If not FileExist("WayText\wtFiles\Settings.ini") {
   ListColor := "Default"
   FontColor := "Default"
}

;========= LOGGER OPTIONS ====================================================== 
saveIntervalMinutes := 10     ; Collect the log items in RAM, then save to disc this often. 
IntervalsBeforeStopping := 2  ; Stop collecting, if no new pattern matches for this many intervals.
; (Script will automatically restart the log intervals next time there's a match.)
;=====List=of=words=use=to=confirm=replacement=validity=========================
WordListFile := 'GitHubComboList249k.txt' ; Mostly from github: Copyright (c) 2020 Wordnik

;========= LOG ANALYSIS OPTIONS ================================================
; !!! If you add/remove lines of code, change value of startLine, as needed !!!
runAnalysisHotkey := "#^+q"   ; Change hotkey if desired.
sneakPeekHotkey := "!q"       ; Change hotkey if desired.
ShowX := 30                   ; Show max of top X results. 

MyAhkEditorPath := SubStr(A_Temp, 1, -4) "\Programs\Microsoft VS Code\Code.exe" 
; Make sure AHK editor is assigned.  Use Notepad otherwise.
If not FileExist(MyAhkEditorPath) {
	MsgBox("This error means that the variable 'MyAhkEditorPath' has"
	"`nnot been assigned a valid path for an editor."
	"`nTherefore Notepad will be used as a substite.")
	MyAhkEditorPath := "Notepad.exe"
}

; Make sure word list is there. Change name of word list subfolder, if desired. 
WordListPath := A_ScriptDir '\WordListsForHH\' WordListFile
If not FileExist(WordListPath) {
	MsgBox("This error means that the big list of comparison words at:`n" WordListPath
	"`nwas not found.`n`nMust assign a word list file to variable, such as`n"
	"WordListFile := 'MyWordList.txt'`nfor script to work.`n`nNow exiting.")
	ExitApp
}
WordList := FileRead(wordListPath) ; Get word list into variable.
wordListArray := strSplit(WordList, "`n") ; Segment variable into array.

#HotIf WinActive("ManualCorrectionLogger.ahk")
!+r::  ; hotkey "falls through" to next function
#HotIf
JustReload(*)
{   Reload()
}

!+l::
EditThisLog(*)
{	thisScript := StrReplace(A_ScriptFullPath, ".exe", ".ahk")
	Try
      Run(MyAhkEditorPath " " thisScript)
	Catch
		msgbox 'Cannot run ' thisScript
}

;===============================================================================
HotKey sneakPeekHotkey, peekToolTip
peekToolTip(*) ; sneak-a-peek at working variables.
{   ToolTip(
      'Current typoCache:`n' typoCache
      '`n============================'
      '`nCurrent Saved up Text:`n' savedUpText
      ,,,7)
}

~Esc::
~LButton:: 					; User clicked somewhere,
~Up::	   					; Or moved the cursor, so...
~Down::						; Clear cache to start over. 
~Left::
~Right::
{	Global typoCache := "" 
   ToolTip(,,,5)        ; Remove (only) 'report' tooltip, if showing. 
   ToolTip(,,,7)        ; Remove (only) 'sneak peek' tooltip, if showing. 
}
soundBeep(1600, 75) 
soundBeep(1700, 50) ; startup announcement

tih := InputHook('L0 V I2'), typoCache := ""
tih.OnChar  := tih_Char
tih.OnKeyUp := tih_EndChar
tih.KeyOpt('{BS}{Space}', '+N')
tih.Start
RegEx := "(?<trig>[A-Za-z\. ]{3,})(?<back>[<]+)(?<repl>[A-Za-z\.]+)[ \~]+"

tih_Char(tih, char) {
	Global typoCache
	if (RegExMatch(char, "[A-Za-z\. ]")) ; Only use letters. 
		typoCache .= char
}

tih_EndChar(tih, vk, sc) {
	Global typoCache .= vk = 8? '<' : '~' 		; use '<' for Backspace, '~' for Space
	If RegExMatch(typoCache, RegEx, &out) { 	; watch for pattern ..<<. ~
   	trigLen := strLen(out.trig) 			   ; number of chars in trigger
		BsLen := strLen(out.back) 				   ; number of chars in BS...  
		replLen := strLen(out.repl) 			   ; number of chars in replacement
		If (replLen > BsLen) { ; replacement longer than number of BSs, so part of trigger missing.
			LastPartRepl := subStr(out.repl,'-' replLen-BsLen)
			newTrig := out.trig LastPartRepl 
		}
		Else { ; replacement same length as number of BSs, so entire trigger was entered.
			newTrig := out.trig
		}
      newTrig := trim(newTrig, " .")
		; first part of replacement str will always be missing, so add first part of trig str. 
		FirstPartTrig := subStr(out.trig, 1, trigLen-BsLen)
		newRepl := FirstPartTrig out.repl
      newRepl := trim(newRepl, " .")

		trigRealWord := 0, replRealWord := 0 ; Declare variables so code will work.
		for item in wordListArray ; The list of dictionary words, via above text file lookup. 
		{	If trim(item, "`n`r ") = newTrig
				trigRealWord := 1
			If trim(item, "`n`r ") = newRepl
				replRealWord := 1
		}
      ; msgbox newTrig ' and ' newRepl
		If (trigRealWord = 0) and (replRealWord = 1) { ; Ensure replacement is a word, and trigger is not. 
			newHs := A_YYYY "-" A_MM "-" A_DD " -- ::" newTrig "::" newRepl 
         lastSavedHS := subStr(savedUpText, 1, inStr(savedUpText, '`n'))
         If not inStr(lastSavedHS, newTrig) ; Don't save duplicate of one just saved.
         {  keepText(newHs) ; All validity criteria met, so save for appending.
            If CaretGetPos(&mcx, &mcy)
               ToolTip "::" newTrig "::" newRepl, mcx+10, mcy+25, 6
            Else
               ToolTip "::" newTrig "::" newRepl,,, 6
            soundBeep(1200, 200)       ; announcement of capture.	
         }
		}
		typoCache := ""               ; Clear var to start over. 
		setTimer ClearToolTip, -2000  ; Clear tooltip after 2 sec.
	}
}

ClearToolTip(*)
{	ToolTip ,,,6 ; The 6 is an arbitrary identifier.  
}

logIsRunning := 0
savedUpText := ''
intervalCounter := 0  					; Initialize the counter
saveIntervalMinutes := saveIntervalMinutes*60*1000 ; convert to miliseconds.

; There's no point running the logger if no text has been saved up...  
; So don't run timer when script starts.  Run it when logging starts. 
keepText(newHs)
{  global savedUpText .= strLower(newHs) '`n'
   newHs := ''
   global intervalCounter := 0  	; Reset the counter since we're adding new text
   If logIsRunning = 0  			; only start the timer it it is not already running.
      setTimer Appender, saveIntervalMinutes  	; call function every X minutes.
}

; Gets called by timer, or by onExit.
Appender(*) 
{  savedUpText := sort(savedUpText, "U") ; A second mechanism for unduping. 
   FileAppend savedUpText, A_ScriptName
   global savedUpText := ''  		; clear each time, since text has been logged.
	global logIsRunning := 1  		; set to 1 so we don't keep resetting the timer.
   global intervalCounter += 1 	; Increments here, but resets in other locations. 
   If (intervalCounter >= IntervalsBeforeStopping) ; Check if no text has been kept for X intervals
   {   setTimer Appender, 0  		; Turn off the timer
         global logIsRunning := 0  	; Indicate that the timer is no longer running
      global intervalCounter := 0 ; Reset the counter for safety
   }
	;soundBeep 800, 800 ; <----------------------------------- Announcement to ensure the log is logging.  Remove later. 
	;soundBeep 600, 800
}

OnExit Appender 					         ; Also append one more time on exit. 
; trunkReport := ""

Hotkey runAnalysisHotkey, runAnalysis  ; Change hotkey above, if desired. 
runAnalysis(*)
{
	AllStrs := FileRead(A_ScriptName)   ; ahk file... Know thyself. 
	oStr := "", iStr := "", Report := ""

	TotalLines := StrSplit(AllStrs, "`n").Length ; Determines number of lines for Prog Bar range.
	pg := Gui()
	pg.Opt("-MinimizeBox +alwaysOnTop +Owner")
	MyProgress := pg.Add("Progress", "w400 h30 cGreen Range0-" . TotalLines, "0")
	pg.Title := "Percent complete: 0 %." ; Starting title (immediately gets updated below.)
	pg.Show()

	Loop parse AllStrs, "`n`r"
	{	MyProgress.Value += 1
		pg.Title :=  "Percent complete: " Round((MyProgress.Value/TotalLines)*100) "%." ; For progress bar.
		If (A_Index < startLine) || (not inStr(A_LoopField, "::")) ; Skip these.
			Continue
		Tally := 0
		oStr := A_LoopField     ; o is "outer loop"
		oStr := SubStr(oStr, 14)
		oStr := trim(oStr, " `t") 
		Loop parse AllStrs, "`n`r" {
			If (A_Index < startLine) || (not inStr(A_LoopField, "::")) ; Skip these.
				Continue
			iStr := A_LoopField  ; i is "inner loop"
			iStr := SubStr(iStr, 14)
			iStr := trim(iStr, " `t") 
			; msgbox 'Current LoopFields`n`noutter`t' oStr '`ninner`t' iStr 
			If iStr = oStr { 
				Tally++
			}
		}
		Report .=  Tally " " oStr "`n" 
		AllStrs := strReplace(AllStrs, oStr, "xxx") ; Replace it with 'xxx' so we don't keep finding it.
	}

	Report := Sort(Sort(Report, "/U"), "NR") ; U is 'remove duplicates.' NR is 'numeric' and 'reverse sort.'
	For idx, item in strSplit(Report, "`n")
		If (idx <= ShowX) and subStr(item, 1, 1) != "1"  ; Only use first X lines; hide singletons.
			global trunkReport .= item "`n"
		else break

	pg.Destroy() ; Remove progress bar.
	;msgbox trunkReport, "Manual Correct Report"
   A_Clipboard := "Manual Correct Report`n=====================`n" TrunkReport
	ToolTip("Manual Correct Report`n" trunkReport,,,5)
   trunkReport := ""
}
; End of the part that Steve Kunkel321 made... 

; ==============================================================================
;                       Class ToolTipOptions - 2023-09-10 
;                                      Just Me
;           https://www.autohotkey.com/boards/viewtopic.php?f=83&t=113308
; ==============================================================================

; ----------------------------------------------------------------------------------------------------------------------
ToolTipOptions.Init()
ToolTipOptions.SetFont("s14", "Calibri")
ToolTipOptions.SetMargins(5,5,5,5) ; Left, Top, Right, Bottom
ToolTipOptions.SetColors("0x" ListColor, "0x" FontColor)

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
         Static HTML := {AQUA:   0xFFFF00, BLACK: 0x000000, BLUE:   0xFF0000, FUCHSIA: 0xFF00FF, GRAY:  0x808080,
                         GREEN:  0x008000, LIME:  0x00FF00, MAROON: 0x000080, NAVY:    0x800000, OLIVE: 0x008080,
                         PURPLE: 0x800080, RED:   0x0000FF, SILVER: 0xC0C0C0, TEAL:    0x808000, WHITE: 0xFFFFFF,
                         YELLOW: 0x00FFFF}
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
; ============= Bottom of TOOLTIP OPTIONS CLASS ===============

startLine := A_LineNumber + 5 ; Gets line number where first hotstring is. 
/*
================================================================
Capture Date	Formatted Hotstring				
================================================================
2024-03-07 -- ::forgorren::forgotten
2024-03-07 -- ::checge::change
2024-03-07 -- ::thet::that 
2024-03-07 -- ::qualigy::qualify 
2024-03-07 -- ::rrevaluation::reevaluation 
2024-03-07 -- ::complteed::completed 
2024-03-07 -- ::conltnues::continues 
2024-03-07 -- ::recognised::recognized 
2024-03-07 -- ::givted::gifted 
2024-03-07 -- ::resuts::resets
2024-03-07 -- ::rhis::this
2024-03-07 -- ::tidferent::different
2024-03-07 -- ::upd::up
2024-03-07 -- ::mycui::mygui
2024-03-07 -- ::anoepen::aneopen
2024-03-07 -- ::wither::either
2024-03-07 -- ::countries::countries
2024-03-07 -- ::aggecting::affecting
2024-03-07 -- ::dingg::doing
2024-03-07 -- ::thouhhg::though
2024-03-07 -- ::botton::button
2024-03-07 -- ::burron::button
2024-03-07 -- ::rclit::right
2024-03-07 -- ::hostsrings::hotstrings
2024-03-07 -- ::complteed::completed
2024-03-07 -- ::gatting::sending
2024-03-07 -- ::permession::permission
2024-03-07 -- ::sceudlee::schedule
2024-03-07 -- ::rbuttoon::rbutton
2024-03-07 -- ::indicd::indeed
2024-03-07 -- ::duect::duct
2024-03-07 -- ::prevntt::prevent
2024-03-07 -- ::whows::shows
2024-03-07 -- ::mich::much
2024-03-07 -- ::inclided::inclined
2024-03-07 -- ::reoo::room
2024-03-07 -- ::fellreport::fullreport
2024-03-07 -- ::paris::pairs
2024-03-07 -- ::heoefully::hopefully
2024-03-07 -- ::emberency::emergency
2024-03-07 -- ::mesbox::msgbox
2024-03-07 -- ::sodld::solid
2024-03-07 -- ::atyuhotkey::autohotkey
2024-03-07 -- ::particalar::particular
2024-03-07 -- ::arleady::already
2024-03-07 -- ::going::doing
2024-03-07 -- ::eyte::eye
2024-03-07 -- ::iinite::invite
2024-03-07 -- ::seot::sort
2024-03-07 -- ::calrify::clarify
2024-03-07 -- ::witch::which
2024-03-07 -- ::wnow::snow
2024-03-07 -- ::youuld::should
2024-03-07 -- ::theer::other
2024-03-07 -- ::tallerating::tollerating
2024-03-07 -- ::tro::to
2024-03-07 -- ::textdity::validity
2024-03-07 -- ::invation::invasion
2024-03-07 -- ::possilbe::possible
2024-03-07 -- ::feild::field
2024-03-07 -- ::dterminee::determine
2024-03-07 -- ::nthh::ngth
2024-03-07 -- ::strl::tool
2024-03-07 -- ::baskspace::backspace
2024-03-07 -- ::leterr::letter
2024-03-07 -- ::chahed::cached
2024-03-07 -- ::cashe::cache
2024-03-07 -- ::minues::minutes
2024-03-07 -- ::wrining::writing
2024-03-07 -- ::stript::script
2024-03-07 -- ::selectible::selectable
2024-03-07 -- ::synyax::syntax
2024-03-07 -- ::winactivace::winactivate
2024-03-07 -- ::omee::some
2024-03-07 -- ::differente::difference
2024-03-07 -- ::nothr::noter
2024-03-07 -- ::opytios::options
2024-03-07 -- ::reconn::reckon
2024-03-07 -- ::weil::will
2024-03-07 -- ::exle::else
2024-03-07 -- ::apri.::april
2024-03-07 -- ::qualigf::qualify
2024-03-07 -- ::haivng::having
2024-03-07 -- ::hji::him
2024-03-07 -- ::interstinng::interesting
2024-03-07 -- ::thi::the
2024-03-07 -- ::aprtil::april
2024-03-07 -- ::seld::held
2024-03-07 -- ::threefore::therefore
2024-03-07 -- ::annaul::annual
2024-03-07 -- ::weil::will
2024-03-07 -- ::bewween::between
2024-03-07 -- ::aparnt::parent
2024-03-07 -- ::remobe::remove
2024-03-07 -- ::youch::touch
2024-03-07 -- ::boeore::before
2024-03-07 -- ::unlil::until
2024-03-07 -- ::surgery::surgery
2024-03-07 -- ::onee::once
2024-03-07 -- ::sais::says
2024-03-07 -- ::cometimes::sometimes
2024-03-07 -- ::multiplep::multistep
2024-03-07 -- ::pensil::pencil
2024-03-07 -- ::participale::participate
2024-03-07 -- ::colloeting::collecting
2024-03-07 -- ::partern::pattern
2024-03-07 -- ::defuult::default
2024-03-07 -- ::stcipt::stript
2024-03-07 -- ::whih::such
2024-03-07 -- ::ren::run
2024-03-07 -- ::scvrit::script
2024-03-07 -- ::whenher::whether
2024-03-07 -- ::fikl::file
2024-03-07 -- ::assineed::assigned
2024-03-07 -- ::uses::used
2024-03-07 -- ::seletted::selected
2024-03-07 -- ::needeed::needed
2024-03-07 -- ::anye::have
2024-03-07 -- ::vuew::view
2024-03-07 -- ::analuze::analyze
2024-03-07 -- ::spreng::spring
2024-03-07 -- ::proprietyry::proprietary
2024-03-07 -- ::noee::note
2024-03-07 -- ::arros::arrow
2024-03-07 -- ::degault::default
2024-03-07 -- ::commo::comma
2024-03-07 -- ::endts::exits
2024-03-07 -- ::multile::multple
2024-03-07 -- ::ruch::ruth
2024-03-07 -- ::audryy::audrey
2024-03-07 -- ::regardeing::regarding
2024-03-07 -- ::fino::info
2024-03-07 -- ::vagure::vague
2024-03-07 -- ::ktrsten::kristen
2024-03-07 -- ::welcoee::welcome
2024-03-07 -- ::unlass::unless
2024-03-07 -- ::wekkday::weekday
2024-03-07 -- ::strady::steady
2024-03-07 -- ::consern::concern
2024-03-07 -- ::motrr::motor
2024-03-07 -- ::meoth::month
2024-03-08 -- ::eamil::email
2024-03-08 -- ::precess::process
2024-03-08 -- ::therr::there
2024-03-08 -- ::esamples::examples
2024-03-08 -- ::paosible::possible
2024-03-08 -- ::somehaw::somehow
2024-03-08 -- ::sertain::certain
2024-03-08 -- ::varaable::variable
2024-03-08 -- ::languege::language
2024-03-08 -- ::tha::the
2024-03-09 -- ::liee::like
2024-03-09 -- ::heree::there
2024-03-11 -- ::chande::change
2024-03-11 -- ::surprixed::surprized
2024-03-11 -- ::embecded::embedded
2024-03-11 -- ::somma::comma
2024-03-11 -- ::chag::char
2024-03-11 -- ::respictful::respectful
2024-03-11 -- ::awesomet::awesome
2024-03-11 -- ::sciende::science
2024-03-11 -- ::cty::cy
2024-03-11 -- ::peovbem::problem
2024-03-11 -- ::highewr::higher
2024-03-11 -- ::thet::that
2024-03-11 -- ::thet::that
2024-03-11 -- ::stfff::stuff
2024-03-11 -- ::ther::this
2024-03-11 -- ::thrie::three
2024-03-11 -- ::serervising::supervising
2024-03-11 -- ::repla::reply
2024-03-11 -- ::practiuums::practicums
2024-03-11 -- ::attaact::attract
2024-03-11 -- ::poerions::portions
2024-03-12 -- ::commuiucation::communication
2024-03-12 -- ::narritively::narratively
2024-03-12 -- ::adhs::adhd
2024-03-12 -- ::theugh::though
2024-03-12 -- ::swugest::suggest
2024-03-12 -- ::comprheension::comprehension
2024-03-12 -- ::befow::below
2024-03-12 -- ::provent::prevent
2024-03-12 -- ::contincency::contingency
2024-03-12 -- ::turrsday::thursday
2024-03-12 -- ::moim::mom
2024-03-12 -- ::proibles::problems
2024-03-13 -- ::oritgnally::originally
2024-03-13 -- ::aournd::around
2024-03-13 -- ::comminication::communication
2024-03-13 -- ::servie::served
2024-03-13 -- ::prohgam::program
2024-03-13 -- ::strudture::structure
2024-03-13 -- ::thatn::than
2024-03-13 -- ::speciale::special
2024-03-13 -- ::bordiring::bordering
2024-03-13 -- ::tha::the
2024-03-13 -- ::loger::lower
2024-03-13 -- ::commenications::communications
2024-03-13 -- ::assignemnts::assignments
2024-03-13 -- ::staygin::staying
2024-03-13 -- ::sedd::send
2024-03-13 -- ::okat::okay
2024-03-13 -- ::duscuss::discuss
2024-03-13 -- ::tomorrww::tomorrow
2024-03-13 -- ::facotr::factor
2024-03-13 -- ::invovves::involves
2024-03-13 -- ::attempte::attempts
2024-03-13 -- ::somehhere::somewhere
2024-03-13 -- ::heppens::happens
2024-03-13 -- ::havpen::happen
2024-03-13 -- ::writt::right
2024-03-13 -- ::suppored::supposed
2024-03-14 -- ::posswibl::possible
2024-03-14 -- ::congrol::control
2024-03-14 -- ::glithh::glitch
2024-03-14 -- ::mayy::mary
2024-03-14 -- ::embaace::embrace
2024-03-14 -- ::styphen::stephen
2024-03-14 -- ::somethigg::something
2024-03-14 -- ::disabilitiy::disability
2024-03-14 -- ::regall::recall
2024-03-15 -- ::texintg::testing
2024-03-15 -- ::devence::defence
2024-03-15 -- ::inforaation::information
2024-03-15 -- ::stups::stops
2024-03-15 -- ::hase::have
2024-03-15 -- ::qeustion::question
2024-03-15 -- ::restarks::restarts
2024-03-15 -- ::restrrting::restarting
2024-03-15 -- ::clikk::click
2024-03-15 -- ::cuyrently::currently
2024-03-15 -- ::reoove::remove
2024-03-15 -- ::tiiltip::tooltip
2024-03-15 -- ::forgor::forgot
2024-03-16 -- ::portntially::potentially
2024-03-16 -- ::reuularly::regularly
2024-03-16 -- ::eyestght::eyesight
2024-03-16 -- ::stainning::beginning
2024-03-16 -- ::renuw::renew
2024-03-16 -- ::tyh::the
2024-03-16 -- ::reappli::reapply
2024-03-16 -- ::unfortunetely::unfortunately
2024-03-16 -- ::resson::reason
2024-03-16 -- ::keypoard::keyboard
2024-03-16 -- ::tnan::than
2024-03-16 -- ::fole::file
2024-03-16 -- ::thise::these
2024-03-16 -- ::jsut::just
2024-03-16 -- ::mechanizm::mechanism
2024-03-17 -- ::rivvon::ribbon
2024-03-17 -- ::mguite::remote
2024-03-17 -- ::calrify::clarify
2024-03-17 -- ::degugged::debugged
2024-03-17 -- ::optioj::option
2024-03-17 -- ::prolpted::prompted
2024-03-17 -- ::rhaner::rather
2024-03-17 -- ::tyo::to
2024-03-17 -- ::lunnching::launching
2024-03-17 -- ::adbanced::advanced
2024-03-17 -- ::consept::concept
2024-03-17 -- ::scoolls::scrolls
2024-03-17 -- ::selectionns::selections
2024-03-18 -- ::starnge::strange
2024-03-18 -- ::thresfer::transfer
2024-03-18 -- ::grariels::gabriels
2024-03-18 -- ::apprrently::apparently
2024-03-18 -- ::desition::dei
2024-03-18 -- ::hase::have
2024-03-18 -- ::outht::ought
2024-03-18 -- ::palnning::planning
2024-03-18 -- ::referrel::referral
2024-03-18 -- ::specd::sped
2024-03-18 -- ::thay::they
2024-03-18 -- ::voivemail::voicemail
2024-03-18 -- ::wook::week
2024-03-18 -- ::faxtor::factor
2024-03-18 -- ::promary::primary
2024-03-18 -- ::secdodary::secondary
2024-03-18 -- ::har::had
2024-03-18 -- ::hav::had
2024-03-18 -- ::hwht::what
2024-03-18 -- ::lafk::lack
2024-03-18 -- ::signaurres::signatures
2024-03-18 -- ::academodations::accommodations
2024-03-18 -- ::appli::apply
2024-03-18 -- ::becween::between
2024-03-18 -- ::charactiristics::characteristics
2024-03-18 -- ::connitive::cognitive
2024-03-18 -- ::diabnosis::diagnosis
2024-03-18 -- ::dicatual::dividual
2024-03-18 -- ::discuessed::discussed
2024-03-18 -- ::essage::essay
2024-03-18 -- ::finel::final
2024-03-18 -- ::haddwritten::handwritten
2024-03-18 -- ::hainvg::having
2024-03-18 -- ::imporaant::important
2024-03-18 -- ::livi::levi
2024-03-18 -- ::neeeded::needed
2024-03-18 -- ::notewrrthy::noteworthy
2024-03-18 -- ::nubmer::number
2024-03-18 -- ::pressssing::processing
2024-03-18 -- ::reedback::feedback
2024-03-18 -- ::proicss::process
2024-03-18 -- ::okat::okay
2024-03-19 -- ::taht::that
2024-03-19 -- ::dayt::day
2024-03-19 -- ::oiuy::out
2024-03-19 -- ::chjane::change
2024-03-19 -- ::jaskson::jackson
2024-03-19 -- ::reschudule::reschedule
2024-03-19 -- ::uposible::possible
2024-03-19 -- ::yestdrday::yesterday
2024-03-19 -- ::cdoe::code
2024-03-19 -- ::paotal::portal
2024-03-19 -- ::pelase::please
2024-03-19 -- ::pleras::please
2024-03-19 -- ::remormat::reformat
2024-03-19 -- ::wrotn::wrong
2024-03-19 -- ::evaluatioj::evaluation
2024-03-19 -- ::wrip::wrap
2024-03-19 -- ::koww::know
2024-03-19 -- ::ravan::raven
2024-03-19 -- ::tomrorww::tomorrow
2024-03-19 -- ::annd::and
2024-03-19 -- ::atherr::gather
2024-03-19 -- ::invasiee::invasive
2024-03-19 -- ::oneting::testing
2024-03-19 -- ::tolk::told
2024-03-19 -- ::waleady::already
2024-03-19 -- ::wqit::with
2024-03-19 -- ::mct::mcs
2024-03-19 -- ::percon::person
2024-03-19 -- ::rour::tour
2024-03-19 -- ::ver::re
2024-03-19 -- ::actullly::actually
2024-03-19 -- ::aprooximation::approximation
2024-03-19 -- ::tartet::target
2024-03-19 -- ::amdinistration::administration
2024-03-19 -- ::balue::value
2024-03-19 -- ::ignote::ignore
2024-03-19 -- ::supposrd::supposed
2024-03-20 -- ::aeaa::area
2024-03-20 -- ::attendence::attendance
2024-03-20 -- ::datye::date
2024-03-20 -- ::developmantal::developmental
2024-03-20 -- ::discrict::district
2024-03-20 -- ::expir::end
2024-03-20 -- ::perfett::perfect
2024-03-20 -- ::unremakkable::unremarkable
2024-03-20 -- ::marth::march
2024-03-20 -- ::strrted::started
2024-03-20 -- ::reoommended::recommended
2024-03-20 -- ::wrtiing::writing
2024-03-20 -- ::drafyt::draft
2024-03-20 -- ::pring::bring
2024-03-20 -- ::comforaable::comfortable
2024-03-20 -- ::accuming::assuming
2024-03-20 -- ::elibible::eligible
2024-03-20 -- ::lla::all
2024-03-20 -- ::protextions::protections
2024-03-20 -- ::referrad::referred
2024-03-20 -- ::sould::would
2024-03-21 -- ::wask::work
2024-03-21 -- ::conta::fell
2024-03-21 -- ::precticum::practicum
2024-03-21 -- ::queater::quarter
2024-03-21 -- ::schhol::school
2024-03-21 -- ::capuured::captured
2024-03-21 -- ::nubmer::number
2024-03-21 -- ::concider::consider
2024-03-21 -- ::modelye::modeled
2024-03-21 -- ::scprpt::script
2024-03-21 -- ::thi::the
2024-03-21 -- ::abstratt::abstract
2024-03-21 -- ::allke::alike
2024-03-21 -- ::alsoe::alone
2024-03-21 -- ::audioory::auditory
2024-03-21 -- ::defuulting::defaulting
2024-03-21 -- ::ditit::digit
2024-03-21 -- ::eveect::effect
2024-03-21 -- ::expaain::explain
2024-03-21 -- ::fomr::from
2024-03-21 -- ::inv::is
2024-03-21 -- ::pictyue::picture
2024-03-21 -- ::similariey::similarity
2024-03-21 -- ::visiol::visual
2024-03-21 -- ::vovabulary::vocabulary
2024-03-21 -- ::attandance::attendance
2024-03-21 -- ::internentions::interventions
2024-03-21 -- ::progruss::progress
2024-03-21 -- ::viiion::vision
2024-03-21 -- ::iniond::second
2024-03-21 -- ::proviously::previously
2024-03-21 -- ::thas::this
2024-03-21 -- ::dasc::dash
2024-03-21 -- ::dass::dash
2024-03-21 -- ::gutus::gurus
2024-03-21 -- ::interswting::interesting
2024-03-21 -- ::nerr::near
2024-03-21 -- ::ourt::or
2024-03-21 -- ::renuwal::renewal
2024-03-21 -- ::actua::is
2024-03-21 -- ::withh::which
2024-03-21 -- ::confirmeng::confirming
2024-03-21 -- ::dietrict::district
2024-03-21 -- ::progessors::professors
2024-03-21 -- ::suggicient::sufficient
2024-03-21 -- ::tratning::training
2024-03-21 -- ::thit::that
2024-03-21 -- ::sooled::solved
2024-03-21 -- ::caet::cert
2024-03-21 -- ::memver::member
2024-03-21 -- ::renuwal::renewal
2024-03-22 -- ::butause::because
2024-03-22 -- ::anicdotal::anecdotal
2024-03-22 -- ::conterence::conference
2024-03-22 -- ::optimictic::optimistic
2024-03-22 -- ::responde::response
2024-03-22 -- ::surrests::suggests
2024-03-22 -- ::vecotr::vector
2024-03-22 -- ::pereect::perfect
2024-03-22 -- ::abee::able
2024-03-22 -- ::analssis::analysis
2024-03-22 -- ::assedsed::assessed
2024-03-22 -- ::autitor::auditor
2024-03-22 -- ::difficulti::difficulty
2024-03-22 -- ::disctactibility::distractibility
2024-03-22 -- ::exseption::exception
2024-03-22 -- ::exxay::essay
2024-03-22 -- ::itesm::items
2024-03-22 -- ::mements::moments
2024-03-22 -- ::performatnc::performance
2024-03-22 -- ::pictree::picture
2024-03-22 -- ::progreas::progress
2024-03-22 -- ::provess::process
2024-03-22 -- ::socres::scores
2024-03-22 -- ::socving::solving
2024-03-22 -- ::subbering::suffering
2024-03-22 -- ::subrests::subtests
2024-03-22 -- ::subrraction::subtraction
2024-03-22 -- ::thery::thy
2024-03-22 -- ::inguired::inquired
2024-03-22 -- ::leaerrship::leadership
2024-03-22 -- ::stedunts::students
2024-03-22 -- ::whi::who
2024-03-22 -- ::godd::good
2024-03-22 -- ::couldbe::could be
2024-03-22 -- ::criterian::criterion
2024-03-22 -- ::proiided::provided
2024-03-22 -- ::condication::condition
2024-03-22 -- ::completio::complete
2024-03-22 -- ::evavaluation::reevaluation
2024-03-22 -- ::everyene::everyone
2024-03-22 -- ::benn::been
2024-03-22 -- ::hareey::harley
2024-03-22 -- ::ocyober::october
2024-03-22 -- ::renuwal::renewal
2024-03-22 -- ::harelys::harleys
2024-03-22 -- ::timedut::timeout
2024-03-22 -- ::waty::way
2024-03-23 -- ::falue::value
2024-03-23 -- ::sattement::statement
2024-03-23 -- ::sheck::check
2024-03-23 -- ::strainge::strange
2024-03-23 -- ::whtt::what
2024-03-23 -- ::appaar::appear
2024-03-23 -- ::toolpip::tooltip
2024-03-23 -- ::charaster::character
2024-03-23 -- ::porbably::probably
2024-03-23 -- ::belowl::below
2024-03-23 -- ::aleeady::already
2024-03-23 -- ::thirsday::thursday
2024-03-23 -- ::ascually::actually
2024-03-23 -- ::mazn::main
2024-03-23 -- ::commett::comment
2024-03-23 -- ::embadding::embedding
2024-03-23 -- ::irrue::issue
2024-03-23 -- ::mamory::memory
2024-03-23 -- ::notiing::nothing
2024-03-23 -- ::thes::this
2024-03-23 -- ::ioon::ion
2024-03-23 -- ::opf::of
2024-03-23 -- ::pasteng::pasting
2024-03-23 -- ::resubbitted::resubmitted
2024-03-23 -- ::uplodaing::uploading
2024-03-24 -- ::cretit::credit
2024-03-24 -- ::ths::the
2024-03-25 -- ::desided::decided
2024-03-25 -- ::adcocates::advocates
2024-03-25 -- ::animmsity::animosity
2024-03-25 -- ::anticipace::anticipate
2024-03-25 -- ::begween::between
2024-03-25 -- ::caseings::meetings
2024-03-25 -- ::contuniing::continuing
2024-03-25 -- ::dfay::day
2024-03-25 -- ::everyeon::everyone
2024-03-25 -- ::hav::had
2024-03-25 -- ::hou::our
2024-03-25 -- ::manuy::many
2024-03-25 -- ::oion::oon
2024-03-25 -- ::parntt::parent
2024-03-25 -- ::poraal::portal
2024-03-25 -- ::possile::possible
2024-03-25 -- ::sonn::soon
2024-03-25 -- ::suamitting::submitting
2024-03-25 -- ::suiciee::suicide
2024-03-25 -- ::thie::this
2024-03-25 -- ::antyiipate::anticipate
2024-03-25 -- ::certganly::certainly
2024-03-25 -- ::melisaa::melissa
2024-03-25 -- ::qualigy::qualify
2024-03-25 -- ::raddom::random
2024-03-25 -- ::sytssm::system
2024-03-25 -- ::thesae::these
2024-03-25 -- ::witl::will
2024-03-25 -- ::sleection::selection
2024-03-25 -- ::butause::because
2024-03-25 -- ::makker::marker
2024-03-25 -- ::seledctd::selected
2024-03-25 -- ::sorre::store
2024-03-25 -- ::highling::coloring
2024-03-25 -- ::partiuclar::particular
2024-03-26 -- ::chenging::changing
2024-03-26 -- ::borwse::browse
2024-03-26 -- ::checkbbx::checkbox
2024-03-26 -- ::disagvantages::disadvantages
2024-03-26 -- ::esitor::editor
2024-03-26 -- ::glithh::glitch
2024-03-26 -- ::luachh::launch
2024-03-26 -- ::natmd::named
2024-03-26 -- ::sutup::setup
2024-03-26 -- ::tio::to
2024-03-26 -- ::assached::attached
2024-03-26 -- ::opne::one
2024-03-26 -- ::remonder::reminder
2024-03-26 -- ::romorrow::tomorrow
2024-03-26 -- ::comparixon::comparison
2024-03-26 -- ::phenomenol::phenomenal
2024-03-26 -- ::reem::room
2024-03-26 -- ::expreced::expected
2024-03-26 -- ::laases::lasses
2024-03-26 -- ::reaeing::reading
2024-03-26 -- ::suuports::supports
2024-03-26 -- ::abobv::above
2024-03-26 -- ::appli::apply
2024-03-26 -- ::carltet::scarlet
2024-03-26 -- ::chackbox::checkbox
2024-03-26 -- ::condereration::consideration
2024-03-27 -- ::fiel::file
2024-03-27 -- ::hareeys::harleys
2024-03-27 -- ::scarelt::scarlet
2024-03-27 -- ::adulty::adults
2024-03-27 -- ::apparettly::apparently
2024-03-27 -- ::cloass::class
2024-03-27 -- ::conserning::concerning
2024-03-27 -- ::deificulties::difficulties
2024-03-27 -- ::derression::depression
2024-03-27 -- ::diffiuulties::difficulties
2024-03-27 -- ::dreression::depression
2024-03-27 -- ::eleatted::elevated
2024-03-27 -- ::ewee::were
2024-03-27 -- ::exceltion::exception
2024-03-27 -- ::hige::hide
2024-03-27 -- ::hith::high
2024-03-27 -- ::intneralizing::internalizing
2024-03-27 -- ::proclems::problems
2024-03-27 -- ::ratss::rates
2024-03-27 -- ::sch::she
2024-03-27 -- ::socoal::social
2024-03-27 -- ::somatication::somatization
2024-03-27 -- ::subgest::suggest
2024-03-27 -- ::adulks::adults
2024-03-27 -- ::anyse::these
2024-03-27 -- ::arentts::parents
2024-03-27 -- ::ces::ts
2024-03-27 -- ::chacks::checks
2024-03-27 -- ::eggect::effect
2024-03-27 -- ::estrem::esteem
2024-03-27 -- ::graies::grades
2024-03-27 -- ::helfful::helpful
2024-03-27 -- ::locas::locus
2024-03-27 -- ::migtt::might
2024-03-27 -- ::monady::monday
2024-03-27 -- ::peett::peers
2024-03-27 -- ::poasible::possible
2024-03-27 -- ::preferencial::preferential
2024-03-27 -- ::preiatrician::pediatrician
2024-03-27 -- ::procects::projects
2024-03-27 -- ::sociel::social
2024-03-27 -- ::suggess::success
2024-03-27 -- ::inslude::include
2024-03-27 -- ::dounds::sounds
2024-03-27 -- ::linke::link
2024-03-28 -- ::longhear::longhair
2024-03-28 -- ::baet::best
2024-03-28 -- ::coee::code
2024-03-28 -- ::componenet::components
2024-03-28 -- ::deccription::description
2024-03-28 -- ::improesse::impressed
2024-03-28 -- ::intervect::interject
2024-03-28 -- ::rabiit::rabbit
2024-03-28 -- ::someimmes::sometimes
2024-03-28 -- ::workouounds::workarounds
2024-03-28 -- ::tunine::tuning
2024-03-28 -- ::orrors::errors
2024-03-28 -- ::regall::recall
2024-03-28 -- ::learing::leaving
2024-03-28 -- ::kidda::kinda
2024-03-28 -- ::boildrplate::boilerplate
2024-03-28 -- ::butfer::buffer
2024-03-28 -- ::buyfered::buffered
2024-03-28 -- ::enteres::entries
2024-03-28 -- ::keyt::keys
2024-03-28 -- ::pastss::pastes
2024-03-28 -- ::practive::practice
2024-03-28 -- ::reade::reate
2024-03-28 -- ::relevatt::relevant
2024-03-28 -- ::saye::have
2024-03-28 -- ::sedctio::section
2024-03-28 -- ::strar::start
2024-03-28 -- ::summariesd::summarized
2024-03-28 -- ::teped::typed
2024-03-28 -- ::wrok::work
2024-03-28 -- ::bellify::qualify
2024-03-28 -- ::continion::condition
2024-03-28 -- ::doubyt::doubt
2024-03-28 -- ::evalaluation::reevaluation
2024-03-28 -- ::indicatss::indicates
2024-03-28 -- ::joal::joel
2024-03-28 -- ::sloser::closer
2024-03-28 -- ::totephone::telephone
2024-03-28 -- ::wehn::when
2024-03-28 -- ::wfil::will
2024-03-28 -- ::auot::auto
2024-03-28 -- ::boilerplace::boilerplate
2024-03-28 -- ::coee::code
2024-03-28 -- ::condected::conducted
2024-03-28 -- ::doenside::downside
2024-03-28 -- ::exabtly::exactly
2024-03-28 -- ::reevlluation::reevaluation
2024-03-28 -- ::vanella::vanilla
2024-03-28 -- ::bewtwen::between
2024-03-28 -- ::butfer::buffer
2024-03-28 -- ::cannt::cat
2024-03-28 -- ::capuured::captured
2024-03-28 -- ::charaster::character
2024-03-28 -- ::contant::content
2024-03-28 -- ::eash::each
2024-03-28 -- ::messgge::message
2024-03-28 -- ::pag::chrome
2024-03-28 -- ::pastss::pastes
2024-03-28 -- ::refeeshes::refreshes
2024-03-28 -- ::tepe::type
2024-03-28 -- ::faxility::facility
2024-03-28 -- ::unorthodax::unorthodox
2024-03-28 -- ::wheveer::whether
2024-03-28 -- ::sendle::level
2024-03-28 -- ::clich::click
2024-03-28 -- ::discuvered::discovered
2024-03-28 -- ::useht::right
2024-03-28 -- ::howweer::however
2024-03-28 -- ::unreasonsive::unresponsive
2024-03-28 -- ::mabye::maybe
2024-03-28 -- ::funciionality::functionality
2024-03-28 -- ::posty::reply
2024-03-28 -- ::situraion::situation
2024-03-29 -- ::fiil::fill
2024-03-29 -- ::dayes::dates
2024-03-29 -- ::agerr::after
2024-03-29 -- ::eaiil::email
2024-03-29 -- ::innuire::inquire
2024-03-29 -- ::rist::rest
2024-03-29 -- ::actaally::actually
2024-03-29 -- ::chacned::changed
2024-03-29 -- ::disrecard::disregard
2024-03-29 -- ::exaansion::expansion
2024-03-29 -- ::expret::expect
2024-03-29 -- ::mathod::method
2024-03-29 -- ::personallly::personally
2024-03-29 -- ::reallye::realize
2024-03-29 -- ::slach::slash
2024-03-29 -- ::solod::solid
2024-03-29 -- ::wrip::wrap
2024-03-29 -- ::explaiation::explanation
2024-03-29 -- ::perposes::purposes
2024-03-29 -- ::repla::reply
2024-03-29 -- ::relaod::reload
2024-03-29 -- ::rescarted::restarted
2024-03-29 -- ::thei::they
2024-03-29 -- ::defaag::defrag
2024-03-29 -- ::entionn::unction
2024-03-29 -- ::cherm::charm
2024-03-29 -- ::techiical::technical
2024-03-29 -- ::replycement::replacement
2024-03-29 -- ::comeares::compares
2024-03-29 -- ::trnning::turning
2024-03-29 -- ::ein::ing
2024-03-29 -- ::replaed::related
2024-03-29 -- ::scheuuled::scheduled
2024-03-30 -- ::analyings::analyzing
2024-03-30 -- ::eash::each
2024-03-30 -- ::enrirely::entirely
2024-03-30 -- ::limmitd::limited
2024-03-30 -- ::nood::need
2024-03-30 -- ::resard::regard
2024-03-30 -- ::technocogy::technology
2024-03-30 -- ::thares::theres
2024-03-30 -- ::calculare::calculate
2024-03-30 -- ::enoufh::enough
2024-03-30 -- ::abxoe::above
2024-03-30 -- ::assigneent::assignment
2024-03-30 -- ::bould::could
2024-03-30 -- ::tim::tie
2024-03-31 -- ::apppeas::appears
2024-03-31 -- ::scritping::scripting
2024-03-31 -- ::thate::these
2024-03-31 -- ::autoor::author
2024-03-31 -- ::convereed::converted
2024-03-31 -- ::soundl::sounds
2024-03-31 -- ::ione::ions
2024-03-31 -- ::mentione::mentions
2024-03-31 -- ::sapce::space
2024-03-31 -- ::cahhe::cache
2024-03-31 -- ::diecusses::discusses
2024-03-31 -- ::heae::here
2024-03-31 -- ::tha::nd
2024-03-31 -- ::deterinne::determine
2024-03-31 -- ::hife::hide
2024-03-31 -- ::msgsage::message
2024-03-31 -- ::tartet::target
2024-03-31 -- ::thes::this
2024-03-31 -- ::tri::trigger
2024-03-31 -- ::whowing::showing
2024-03-31 -- ::rethinging::rethinking
2024-03-31 -- ::unchacked::unchecked
