#SingleInstance
#Requires AutoHotkey v2.0
Persistent

; ==============================================================================
; The Manual Correction Logger -- MCLogger --   Version 5-4-2024
; ==============================================================================
; By Kunkel321, but inputHook based on Mike's here at: 
; https://www.autohotkey.com/boards/viewtopic.php?p=560556#p560556
; A script to run in the background all the time and log your typing
; errors and manual corrections, formatting the viable ones into ahk hotstrings,
; so that repeating typo patterns can later be identified and potentially
; added as new AutoCorrect library items.  The analysis repor is a GUI form that
; can export the new hotstring to Hotstring Helper 2.0, or merely append it to 
; the bottom of the AutoCorrect file.  The typoCache variable ignores 
; non-letters (because those are not needed for typing corrections).  "End keys"
; are Space (~) and Backspace (<).  The script watches for the pattern "...<. ~" 
; and then saves the corresponding hotstring for logging.  The log gets saved to 
; file every X minutes. The log also saves to file on exit.  Moving the cursor 
; or left-clicking resets the cache and closes the tooltip. 
; ==============================================================================

;========= TOOLTIP COLORS ======================================================
; The iniReads are specific to Steve's computer -- If you see them, he forgot to remove them.
lColor := IniRead("WayText\wtFiles\Settings.ini", "MainSettings", "ListColor", "Default")
gColor := iniread("WayText\wtFiles\Settings.ini", "MainSettings", "GUIcolor", "Default")
fColor := iniread("WayText\wtFiles\Settings.ini", "MainSettings", "FontColor", "Default")
;-----------------
ListColor := strReplace(subStr(lColor, -6), "efault", "Default")
gColor := strReplace(subStr(gColor, -6), "efault", "Default")
FontColor := strReplace(subStr(fColor, -6), "efault", "Default")

If not FileExist("WayText\wtFiles\Settings.ini") {
   Global ListColor := "Default"
   Global FontColor := "Default"
   Global gColor := "Default"
}

;========= LOGGER OPTIONS ====================================================== 
saveIntervalMinutes := 10     ; Collect the log items in RAM, then save to disc this often. 
IntervalsBeforeStopping := 2  ; Stop collecting, if no new pattern matches for this many intervals.
; (Script will automatically restart the log intervals next time there's a match.)

;=====File=Name=Assignments=====================================================
WordListFile := 'GitHubComboList249k.txt' ; Mostly from github: Copyright (c) 2020 Wordnik
myLogFile := "MCLog.txt"
myAutoCorrectFile := "AutoCorrect2.ahk"

;========= LOG ANALYSIS OPTIONS ================================================
runAnalysisHotkey := "#^+q"   ; Change hotkey if desired.
sneakPeekHotkey := "!q"       ; Change hotkey if desired.
ShowX :=  6                   ; Show max of top X results. 
SendToHH := 0                ; Export directly to HotSting Helper. 1=yes / 0=no 

MyAhkEditorPath := "C:\Users\steve\AppData\Local\Programs\Microsoft VS Code\Code.exe" ; <--- specific to Steve's setup. Put path to your editor.

;--- create systray menu ----
TraySetIcon("icons/JustLog.ico") ; A fun homemade "log" icon that Steve made.
mclMenu := A_TrayMenu ; Tells script to use this when right-click system tray icon.
mclMenu.Delete ; Removes all of the defalt memu items, so we can add our own. 
mclMenu.Add("Log and Reload Script", (*) => Reload())
mclMenu.SetIcon("Log and Reload Script", "icons/data_backup-Brown.ico")
mclMenu.Add("Edit This Script", EditThisLog)
mclMenu.SetIcon("Edit This Script", "icons/edit-Brown.ico")
mclMenu.Add("Open " myLogFile, (*) => Run(myLogFile))
;mclMenu.SetIcon("Open " myLogFile, "icons/edit-Brown.ico")
mclMenu.Add("Analyze Manual Corrections", runAnalysis)
mclMenu.SetIcon("Analyze Manual Corrections", "icons/search-Brown.ico")
mclMenu.Add("Start with Windows", StartUpMCL)
if FileExist(A_Startup "\MCLogger.lnk")
   mclMenu.Check("Start with Windows")
mclMenu.Add("List Lines Debug", (*) => ListLines())
mclMenu.SetIcon("List Lines Debug", "icons/ListLines-Brown.ico")
mclMenu.Add("Exit Script", (*) => ExitApp())
mclMenu.SetIcon("Exit Script", "icons/exit-Brown.ico")
mclMenu.SetColor("C29A6A") ; #CD853F is "Peru"
;---- end of menu creation --- 

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

#HotIf WinActive("MCLogger.ahk") ; Allow "window-specific" hotkey action.
$^s::  ; hotkey "falls through" to next function
#HotIf ; Turn off "window-specific" stuff.
SaveAndReload(*) ; Save, but also reload script in RAM.
{  Send "^s"
   Reload()
}

; For opening this script (not usually needed, since the log is in a separate file).
EditThisLog(*)
{	Try
      Run(MyAhkEditorPath " " A_ScriptDir "\" myLogFile)
	Catch
		Run myLogFile
}

; This function pops up a tooltip to show (1) the currently captured key presse cache 
; and (2) the list of items that will get appended to the log file at the end of the 
; next save interval (or when this script is exited/reloaded). 
HotKey sneakPeekHotkey, peekToolTip
peekToolTip(*) ; sneak-a-peek at working variables.
{   ToolTip(
      'Current typoCache:`n' typoCache
      '`n============================'
      '`nCurrent Saved up Text:`n' savedUpText
      ,,,7)
}

; These are not "window-specific".  They will will clear the cache of "watched" 
; key-presses, no matter what app you are working in.   This is important, because 
; we only are interested in typing patterns that are created from an uninterrupted
; string of keypresses.  If the user uses the arrows to go back in a word, or 
; clicks in it, that string will be broken... So we need to "start over" the 
; keypress watching.  
~Esc::
~LButton:: 					; User clicked somewhere,
~Up::	   					; Or moved the cursor, so...
~Down::						; Clear cache to start over. 
~Left::
~Right::
{	Global typoCache := "" 
   ToolTip(,,,7)        ; Remove (only) 'sneak peek' tooltip, if showing. 
}

soundBeep(1600, 75) 
soundBeep(1700, 50) ; startup announcement

; This creates the inputHook that actually watches the keypresses. 
tih := InputHook('L0 V I2'), typoCache := ""
tih.OnChar  := tih_Char
tih.OnKeyUp := tih_EndChar
tih.KeyOpt('{BS}{Space}', '+N')
tih.Start
RegEx := "(?<trig>[A-Za-z\. ]{3,})(?<back>[<]+)(?<repl>[A-Za-z\.]+)[ \~]+"

; This function filters-out non-letter characters.  
tih_Char(tih, char) {
	Global typoCache
	if (RegExMatch(char, "[A-Za-z\. ]")) ; Only use letters. 
		typoCache .= char
}

; When Backspace or Space is pressed, this function is called. 
; The function uses logic to exprapolate an entire hotstring trigger and replacement
; from the parts of each that were typed.   The hotstring is checked to make sure
; it matches the format ::misspelling::actual word.  The potential hotstring is 
; shown in a tooltip, and appended with a datestamp, then added to the "Saved up Text"
; variable to be logged at the end of the next interval. 
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
               ToolTip "::" newTrig "::" newRepl, mcx-15, mcy+80, 6 ; <--- LOCATION of tooltip is set here.
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

OnExit Appender 	; Also append one more time on exit. 

; Gets called by timer, or by onExit.
Appender(*) 
{  savedUpText := sort(savedUpText, "U") ; A second mechanism for unduping. 
   FileAppend savedUpText, myLogFile
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

; This gets called from the hotkey or the menu item.  It creates two different GUI
; forms.  THe first is a progress bar that shows the progress of a frequency analysis
; which checks which potential hotstrings have been logged multiple times. The 
; second GUI is a dynamic group of radio buttons, which shows the top X most frequent.
Hotkey runAnalysisHotkey, runAnalysis  ; Change hotkey above, if desired. 
runAnalysis(*)
{
	AllStrs := FileRead(myLogFile)   ; ahk file... Know thyself. 
	oStr := "", iStr := "", Report := ""

	TotalLines := StrSplit(AllStrs, "`n").Length ; Determines number of lines for Prog Bar range.
	pg := Gui()
	pg.Opt("-MinimizeBox +alwaysOnTop +Owner")
   pg.SetFont('s12 c' FontColor)
   pg.BackColor := gColor
   pg.Add("text", "", "Determining frequency of each hotstring...  [Esc to stop]")
	MyProgress := pg.Add("Progress", "w400 h30 cGreen Range0-" . TotalLines, "0")
	pg.Title := "Percent complete: 0 %." ; Starting title (immediately gets updated below.)
	pg.Show()
  ; pg.onEvent("Escape", (*) => pg.Hide())

	Loop parse AllStrs, "`n`r"
	{	MyProgress.Value += 1
      IF GetKeyState("Esc") ; If Esc key is pressed. 
      {  pg.Destroy() ; Remove progress bar.
         Return ; Stop function
      }
		pg.Title :=  "Percent complete: " Round((MyProgress.Value/TotalLines)*100) "%." ; For progress bar.
		If (not inStr(A_LoopField, "::")) ; Skip these.
			Continue
		Tally := 0
		oStr := A_LoopField     ; o is "outer loop"
		oStr := SubStr(oStr, 14)
		oStr := trim(oStr, " `t") 
		Loop parse AllStrs, "`n`r" {
			If (not inStr(A_LoopField, "::")) ; Skip these.
				Continue
			iStr := A_LoopField  ; i is "inner loop"
			iStr := SubStr(iStr, 14)
			iStr := trim(iStr, " `t") 
			; msgbox 'Current LoopFields`n`noutter`t' oStr '`ninner`t' iStr 
			If iStr = oStr { 
				Tally++
			}
		}
		Report .=  Tally " of ⟹ " oStr "`n" 
		AllStrs := strReplace(AllStrs, oStr, "xxx") ; Replace it with 'xxx' so we don't keep finding it.
	}
	global trunkReport := []
	Report := Sort(Sort(Report, "/U"), "NR") ; U is 'remove duplicates.' NR is 'numeric' and 'reverse sort.'
	For idx, item in strSplit(Report, "`n")
		If (idx <= ShowX) and subStr(item, 1, 1) != "1"  ; Only use first X lines; hide singletons.
			 trunkReport.Push(item "`n")
		else break
	pg.Destroy() ; Remove progress bar.

	global cl := Gui()  ; "cl" for "Cull"
   cl.SetFont('s12 c' FontColor)
   cl.BackColor := gColor
	cl.Add('text','','The ' ShowX ' most frequent items are below.`nChoose an item to Cull from ' myLogFile '`nand Append to ' myAutoCorrectFile '?')
	For citem in trunkReport {
      If A_Index = 1
         cl.Add('radio', ' vRadioGrp', "Found " citem)
      Else
         cl.Add('radio', 'xs yp+28', "Found " citem)
	}
	cl.Add('button', 'w160','Cull and Append').OnEvent('Click', CullerAppender)
	cl.Add('button', ' x+4 w120','Cancel').OnEvent('Click', (*) => cl.Hide())
	cl.Show()
}

; This only gets called from the radio button Gui form.  If a radio item is selected 
; all occurences are removed from the log file, and the new items is appended to 
; autocorrect file.  Optionally, the item is sent directly to the HotString Helper 2
; form.  (Need 5-4-2024 or newer version of AutoCorrect2).
CullerAppender(*)
{  newFileContent := "", selItemName := ""
   global trunkReport
	global selectedItem := cl.Submit()
   If selectedItem.RadioGrp = 0 ; No radio button selected. 
   {  MsgBox 'Nothing selected.'
      cl.Show() ; Show gui form again.
      Return   ; Abort function. 
   }
   For cName in trunkReport
      If selectedItem.RadioGrp = A_Index 
         selItemName := cName
   selItemName := Trim(StrSplit(selItemName, " of ⟹ ")[2], "`n`r")

   for line in StrSplit(FileRead(myLogFile), "`n") {
      If  (inStr(line, selItemName))
         Continue
      Else
         newFileContent .= line "`n"
   }

   FileDelete myLogFile ; Delete the file so we can remake it.
   FileAppend(newFileContent, myLogFile) ; Remake the file with the (now culled) string.
   
   If SendToHH = 1 ; If =1, send to HotStr Helper via command line.
   {  myACFileBaseName := StrSplit(myAutoCorrectFile, ".")[1]
      Run myACFileBaseName ".exe /script " myAutoCorrectFile " " selItemName
   }
   Else ; Otherwise, just append to bottom. 
      FileAppend("`n" selItemName, myAutoCorrectFile) ; Put culled item at bottom of ac file. 
   ;SoundBeep
   cl.Destroy() 
   trunkReport := []
}

; This function is only accessed via the systray menu item.  It toggles adding/removing
; link to this script in Windows Start up folder. 
StartUpMCL(*) ; Start with windows? 
{	if FileExist(A_Startup "\MCLogger.lnk")
	{	FileDelete(A_Startup "\MCLogger.lnk")
		MsgBox("Manual Correction Logger will NO LONGER auto start with Windows.",, 4096)
	}
	Else 
	{	FileCreateShortcut(A_WorkingDir "\MCLogger.exe", A_Startup "\MCLogger.lnk")
		MsgBox("Manual Correction Logger will auto start with Windows.",, 4096)
	}
   Reload()
}

; End of the part that Steve Kunkel321 made... 

; .QQQQQQQQQQQQQQQQ...QQQQQQQQQQQQQQQQ..............QQQQQQQ...
; QQQQQQQQQQQQQQQQQ..QQQQQQQQQQQQQQQQQ...........QQQQQQQQQQ...
; QQQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ.........QQQQQQQQQQQ....
; QQQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ........QQQQQQQQQ..QQQQQ
; QQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ........QQQQQQQQ...QQQQQQQ
; QQQQQQQQQQQQQ.....QQQQQQQQQQQQQQ..........QQQQQQQ...QQQQQQQQQ
; .....QQQQQQQQ...........QQQQQQQQ.........QQQQQQQ....QQQQQQQQQQ
; .....QQQQQQQQ...........QQQQQQQQ........QQQQQQQQ....QQQQQQQQQQ
; ....QQQQQQQQQ..........QQQQQQQQQ........QQQQQQQ.....QQQQQQQQQQQ
; ....QQQQQQQQ...........QQQQQQQQ........QQQQQQQQ......QQQQQQQQQQ
; ....QQQQQQQQ...........QQQQQQQQ.......QQQQQQQQ.......QQQQQQQQQQ
; ...QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQ........QQQQQQQQ
; ...QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ........QQQQQQQQ
; ...QQQQQQQQ...........QQQQQQQQ.......QQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ.........QQQQQQ
; .QQQQQQQQQQ.........QQQQQQQQQQ......QQQQQQQQQ.........QQQQQQ
; .QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQQ........QQQQQQ.
; .QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQQQ.......QQQQQQ.
; QQQQQQQQQQ.........QQQQQQQQQQ.......QQQQQQQQQQ......QQQQQQ..
; QQQQQQQQQ..........QQQQQQQQQ.........QQQQQQQQQ......QQQQQQ..
; QQQQQQQQQ..........QQQQQQQQQ.........QQQQQQQQQQ....QQQQQQ...
; QQQQQQQQQ..........QQQQQQQQQ..........QQQQQQQQQQ.QQQQQQQ....
; QQQQQQQQ...........QQQQQQQQ............QQQQQQQQQQQQQQQQ.....
; QQQQQQQ............QQQQQQQ..............QQQQQQQQQQQQQ.......
; .QQQQQ..............QQQQQ.................QQQQQQQQQ.........
;                       Class ToolTipOptions - 2023-09-10 
;                                      Just Me
;           https://www.autohotkey.com/boards/viewtopic.php?f=83&t=113308
; ==============================================================================
; ==============================================================================
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
; ============= Bottom of TOOLTIP OPTIONS CLASS ===============
