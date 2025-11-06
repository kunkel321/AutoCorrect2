#SingleInstance
#Requires AutoHotkey v2.0
Persistent

; ==============================================================================
; The Manual Correction Logger -- MCLogger 
; ==============================================================================
; Author: Kunkel321
; Tool Used: Claude AI
; Version: 11-2-2025 
; Get latest version here: https://github.com/kunkel321/AutoCorrect2
; A script to run in the background all the time and log your typing
; errors and manual corrections, formatting the viable ones into ahk hotstrings,
; so that repeating typo patterns can later be identified and potentially
; added as new AutoCorrect library items.  The analysis report is a GUI form that
; can export the new hotstring to Hotstring Helper 2.0, or merely append it to 
; the bottom of the AutoCorrect file.  The typoCache variable ignores 
; non-letters (because those are not needed for typing corrections).  "End keys"
; are Space (~) and Backspace (<).  The script watches for the pattern "...<. ~" 
; and then saves the corresponding hotstring for logging.  The log gets saved to 
; file every X minutes. The log also saves to file on exit.  Moving the cursor 
; or left-clicking resets the cache and closes the tooltip. 
; PLEASE NOTE that MCLogger shares acSettings.ini with several other tools, though
; the other tools don't need to be present for MCLogger to work.
; See also the WinSysTray context menu for other commands. 
; Thanks to Mikeyww who helped with the original inputHook code.
; ==============================================================================
; Related tool:  Users of MS Word VBA may be interested in the code here
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=120220&start=180#p605321
; Which monitors the correction (via r-click) of misspelled words and logs them
; to the same ManualCorrectionsLog.txt file.
; ==============================================================================

;========= LOAD SETTINGS FROM INI ============================================
settingsFile := "..\Data\acSettings.ini"

; Ensure settings file exists.
if !FileExist(settingsFile) {
	MsgBox(settingsFile " was not found.  Please run AutoCorrect2.exe first, to create the file, then try again.`n`nNow exiting")
   ExitApp
}

; Load settings from INI file.  
showEachHotString := IniRead(settingsFile, "MCLogger", "ShowEachHotString", 1)
beepEachHotString := IniRead(settingsFile, "MCLogger", "BeepEachHotString", 1)
saveIntervalMinutes := IniRead(settingsFile, "MCLogger", "SaveIntervalMinutes", 10)
IntervalsBeforeStopping := IniRead(settingsFile, "MCLogger", "IntervalsBeforeStopping", 2)
MCLogFile := "..\Data\" IniRead(settingsFile, "Files", "MCLogFile", "ManualCorrectionsLog.txt")
myAutoCorrectLibrary := IniRead(settingsFile, "Files", "HotstringLibrary", "HotstringLib.ahk")
RemovedHsFile := "..\Data\" IniRead(settingsFile, "Files", "RemovedHsFile", "Data\RemovedHotstrings.txt")
myAutoCorrectScript := IniRead(settingsFile, "Path", "MyAutoCorrectScript", "AutoCorrect2.ahk")
SendToHH := IniRead(settingsFile, "MCLogger", "SendToHH", 1)
runAnalysisHotkey := IniRead(settingsFile, "MCLogger", "RunAnalysisHotkey", "#^+q")
sneakPeekHotkey := IniRead(settingsFile, "MCLogger", "SneakPeekHotkey", "#+q")
SaveFulltoClipBrd := IniRead(settingsFile, "MCLogger", "SaveFullToClipboard", 1)
AgeOfOldSingles := IniRead(settingsFile, "MCLogger", "AgeOfOldSingles", 90)
KeepReportOpen := IniRead(settingsFile, "MCLogger", "KeepReportOpen", 1)
WordListFile := "..\Data\" IniRead(settingsFile, "Files", "WordListFile", "GitHubComboList249k.txt")
LightGreen := "c" IniRead(settingsFile, "Shared", "LightGreen", "b8f3ab")
DarkGreen := "c" IniRead(settingsFile, "Shared", "DarkGreen", "0d3803")


; Convert string values to integers where needed
showEachHotString := Integer(showEachHotString)
beepEachHotString := Integer(beepEachHotString)
saveIntervalMinutes := Integer(saveIntervalMinutes)
IntervalsBeforeStopping := Integer(IntervalsBeforeStopping)
SendToHH := Integer(SendToHH)
SaveFulltoClipBrd := Integer(SaveFulltoClipBrd)
AgeOfOldSingles := Integer(AgeOfOldSingles)
KeepReportOpen := Integer(KeepReportOpen)

; Extract basenames from file paths for backup file creation
myLogFileBaseName := SubStr(MCLogFile, 1, InStr(MCLogFile, ".", , -1) - 1)
myACFileBaseName := SubStr(myAutoCorrectScript, 1, InStr(myAutoCorrectScript, ".", , -1) - 1)

; Determine editor path
MyAhkEditorPath := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
if !FileExist(MyAhkEditorPath)
	MyAhkEditorPath := "Notepad.exe"

; ==============================================================================
; Look for colorThemeSettings file and, if found, use color assignment. 
If FileExist("..\Data\colorThemeSettings.ini") {
   ctSettingsFile := "..\Data\colorThemeSettings.ini"
   ; --- Get current colors from ini file. 
   fontColor := IniRead(ctSettingsFile, "ColorSettings", "fontColor")
   listColor := IniRead(ctSettingsFile, "ColorSettings", "listColor")
   formColor := IniRead(ctSettingsFile, "ColorSettings", "formColor")
}
Else { ; Ini file not there, so use these colors instead. 
   fontColor := "1F1F1F", listColor := "FFFFFF", formColor := "E5E4E2"
}

; Calculate contrasting text color for better readability of progress bar.
formColor := "0x" subStr(formColor, -6) ; Make sure the hex value appears as a number, rather than a string. 
r := (formColor >> 16) & 0xFF, g := (formColor >> 8) & 0xFF, b := formColor & 0xFF
brightness := (r * 299 + g * 587 + b * 114) / 1000
progBarGreen := brightness > 128 ? DarkGreen  : LightGreen  ; The color of the radio buttons in the gui form.

;--- create systray menu ----
TraySetIcon("..\Resources\Icons\JustLog.ico") ; A fun homemade "log" icon that Steve made.
mclMenu := A_TrayMenu ; Tells script to use this when right-click system tray icon.
mclMenu.Delete ; Removes all of the defalt memu items, so we can add our own. 
mclMenu.Add("Log and Reload Script", (*) => Reload())
mclMenu.SetIcon("Log and Reload Script", "..\Resources\Icons\data_backup-Brown.ico")
mclMenu.Add("Edit This Script", EditThisScript)
mclMenu.SetIcon("Edit This Script", "..\Resources\Icons\edit-Brown.ico")
mclMenu.Add("Open " MCLogFile, (*) => Run(MCLogFile))
mclMenu.SetIcon("Open " MCLogFile, "..\Resources\Icons\TxtFile-Brown.ico")
mclMenu.Add("Open " settingsFile, (*) => Run(settingsFile))
mclMenu.SetIcon("Open " settingsFile, "..\Resources\Icons\TxtFile-Brown.ico")
mclMenu.Add("Analyze Manual Corrections", runAnalysis)
mclMenu.SetIcon("Analyze Manual Corrections", "..\Resources\Icons\search-Brown.ico")
mclMenu.Add("Start with Windows", StartUpMCL)
if FileExist(A_Startup "\MCLogger.lnk")
   mclMenu.Check("Start with Windows")
mclMenu.Add("List Lines Debug", (*) => ListLines())
mclMenu.SetIcon("List Lines Debug", "..\Resources\Icons\ListLines-Brown.ico")
mclMenu.Add("Exit Script", (*) => ExitApp())
mclMenu.SetIcon("Exit Script", "..\Resources\Icons\exit-Brown.ico")
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
If not FileExist(WordListFile) {
	MsgBox("This error means that the big list of comparison words at:`n" WordListFile
	"`nwas not found.`n`nMust assign a word list file to variable, such as`n"
	"WordListFile := 'MyWordList.txt'`nfor script to work.`n`nNow exiting.")
	ExitApp
}
WordList := FileRead(wordListFile) ; Get word list into variable.
wordListArray := strSplit(WordList, "`n") ; Segment variable into array.

; We'll check for the existence of the ACLibrary.  We won't check for the "Removed Strings"
; file though, because some people might not use that.  If the file exists, it will also
; get used for the "existing items" validity check.
If not FileExist(myAutoCorrectLibrary) {
	MsgBox("This error means that the exsiting library of hotstrings "
	"`nwas not found.`n`nMust assign a file to variable, such as`n"
	"myAutoCorrectLibrary := `"HotstringLib.ahk`"`nfor script to work.`n`nNow exiting.")
	ExitApp
}
AcFileContents := Fileread(myAutoCorrectLibrary)
If FileExist(RemovedHsFile)
   AcFileContents .= "`n" Fileread(RemovedHsFile)
;msgbox "AcFileContents:`n`n" AcFileContents

#HotIf WinActive("MCLogger.ahk") ; Allow "window-specific" hotkey action.
$^s:: ; hide 
SaveAndReload(*) { ; Save, but also reload script in RAM.
   Send "^s"
   sleep 500
   Reload()
}
#HotIf ; Turn off "window-specific" stuff.

; For opening this script (not usually needed, since the log is in a separate file).
EditThisScript(*) {
	Try
      Run(MyAhkEditorPath " " A_ScriptFullPath)
	Catch
		Run A_ScriptFullPath
}

; This function pops up a tooltip to show: (1) the currently captured key press cache 
; and, (2) the list of items that will get appended to the log file at the end of the 
; next save interval (or when this script is exited/reloaded). 
HotKey sneakPeekHotkey, peekToolTip
peekToolTip(*) { ; sneak-a-peek at working variables.
   ToolTip(
      'Current typoCache:`n' typoCache
      '`n============================'
      '`nCurrent Saved up Text:`n' savedUpText
      ,,,7)
}

; These are not "window-specific".  They will clear the cache of "watched" 
; key-presses, no matter what app you are working in.   This is important, because 
; we only are interested in typing patterns that are created from an uninterrupted
; string of keypresses.  If the user uses the arrows to go back in a word, or 
; clicks in it, that string will be broken... So we need to "start over" the 
; keypress watching.  
~Esc::  ; hide
~LButton:: 					; User clicked somewhere, ; hide
~Up::	   					; Or moved the cursor, so... ; hide
~Down::						; Clear cache to start over.  ; hide
~Left:: ; hide
~Right:: ; hide
{	Global typoCache := "" 
   ToolTip(,,,7)        ; Remove (only) 'sneak peek' tooltip, if showing. 
   ToolTip(,,,8)        ; Right-click notificiation.
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
; regex is watching for pattern ...<.~

; This function filters-out non-letter characters.  
tih_Char(tih, char) {
	Global typoCache
	if (RegExMatch(char, "[A-Za-z\. ]")) { ; Only use letters. 
		typoCache .= char
   }
}

CoordMode 'ToolTip', 'Screen'
CoordMode 'Caret', 'Screen'

; When Backspace or Space is pressed, this function is called. 
; The function uses logic to exprapolate an entire hotstring trigger and replacement
; from the parts of each that were typed.   The hotstring is checked to make sure
; it matches the format ::misspelling::actual word.  The potential hotstring is
; shown in a tooltip, and appended with a datestamp, then added to the "Saved up Text"
; variable to be logged at the end of the next interval. 
tih_EndChar(tih, vk, sc) {
	Global typoCache .= vk = 8? '<' : '~' 		; use '<' for Backspace, '~' for Space
	If RegExMatch(typoCache, RegEx, &out) 	   ; watch for pattern ...<.~
   {	trigLen := strLen(out.trig) 			   ; number of chars in trigger
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
		for item in wordListArray { ; The list of dictionary words, via above text file lookup. 
			If trim(item, "`n`r ") = newTrig
				trigRealWord := 1
			If trim(item, "`n`r ") = newRepl
				replRealWord := 1
		}

      global duplicateFound := 0
      Loop Parse, AcFileContents, "`n", "`r"  ; Compares trigger to existing AC library and Removed items list. 
      { 	If (SubStr(trim(A_LoopField, " `t"), 1,1) != ":") and (SubStr(A_LoopField, 1,7) != "Removed")
            continue ; Will skip non-hotstring lines, so the regex isn't used as much.
         If RegExMatch(A_LoopField, "i):(?P<Opts>[^:]+)*:(?P<Trig>[^:]+)", &loo)  ; loo is "current loopfield"
         {	If InStr(newTrig, loo.Trig) and InStr(loo.Opts, "?") and InStr(loo.Opts, "*") ; Word middle match
            || (newTrig == loo.Trig) { ; or Exact match  
               global duplicateFound := 1
               ; SoundBeep 1800, 200 ; temporary for debuggin
               ; SoundBeep 2200, 200 ; temporary for debuggin
               Break
            }
         }
         Else ; not a regex match, so go to next loop.
            continue 
      }		

      ;msgbox newTrig ' and ' newRepl '`n`ndupefound? ' duplicateFound
		If (trigRealWord = 0) and (replRealWord = 1) and (duplicateFound = 0) { ; Ensure replacement is a word, and trigger is not. 
			newHs := A_YYYY "-" A_MM "-" A_DD " -- ::" newTrig "::" newRepl 
         lastSavedHS := subStr(savedUpText, 1, inStr(savedUpText, '`n'))
         If not inStr(lastSavedHS, newTrig) ; Don't save duplicate of one just saved.
         {  keepText(newHs) ; All validity criteria met, so save for appending.
            If (showEachHotString = 1) {
               If CaretGetPos(&mcx, &mcy)
                  ToolTip "::" newTrig "::" newRepl, mcx-15, mcy-100, 6 ; <--- LOCATION of tooltip is set here.
               Else 
                  ToolTip "::" newTrig "::" newRepl, (A_ScreenWidth/2), 10, 6
            }
            If (beepEachHotString = 1)
               soundBeep(1200, 200)       ; announcement of capture.	
         }
		}
		typoCache := ""               ; Clear var to start over. 
		setTimer ClearToolTip, -2000  ; Clear tooltip after 2 sec.
	}
}

ClearToolTip(*) { 
	ToolTip ,,,6 ; The 6 is an arbitrary identifier.  
}

logIsRunning := 0, savedUpText := '', intervalCounter := 0 
saveIntervalMinutes := saveIntervalMinutes*60*1000 ; convert to miliseconds.

; There's no point running the logger if no text has been saved up...  
; So don't run timer when script starts.  Run it when logging starts. 
keepText(newHs) {
   global savedUpText .= strLower(newHs) '`n'
   newHs := ''
   global intervalCounter := 0  	; Reset the counter since we're adding new text
   If logIsRunning = 0  			; only start the timer it it is not already running.
      setTimer Appender, saveIntervalMinutes  	; call function every X minutes.
}

OnExit Appender 	; Also append one more time on exit. 

; Gets called by timer, or by onExit.
Appender(*) { 
   savedUpText := sort(savedUpText, "U") ; A second mechanism for unduping. 
   FileAppend savedUpText, MCLogFile
   global savedUpText := ''  		; clear each time, since text has been logged.
	global logIsRunning := 1  		; set to 1 so we don't keep resetting the timer.
   global intervalCounter += 1 	; Increments here, but resets in other locations. 
   If (intervalCounter >= IntervalsBeforeStopping) { ; Check if no text has been kept for X intervals
      setTimer Appender, 0  		; Turn off the timer
         global logIsRunning := 0  	; Indicate that the timer is no longer running
      global intervalCounter := 0 ; Reset the counter for safety
   }
	;soundBeep 800, 800 ; <----------------------------------- Announcement to ensure the log is logging.  Remove later. 
	;soundBeep 600, 800
}

; This gets called from the hotkey, the menu item, or command line switch.  
; It creates two different GUI forms.  The first is a progress bar that shows 
; the progress of a frequency analysis which checks which potential hotstrings 
; have been logged multiple times. The second GUI is a ListView which shows 
; the items with occurrence count and hotstring.
if (A_Args.Length > 0) ; Check if a command line argument is present.
	runAnalysis() ; If present, open run analysis immediately. 
Hotkey(runAnalysisHotkey, runAnalysis)  ; Change hotkey above, if desired. 

runAnalysis(*) {
	AllStrs := FileRead(MCLogFile)   ; ahk file... Know thyself. 
	oStr := "", iStr := "" 
   Global Report := "", origAllStrs := AllStrs

	TotalLines := StrSplit(AllStrs, "`n").Length ; Determines number of lines for Prog Bar range.
	pg := Gui()
	pg.Opt("-MinimizeBox +alwaysOnTop +Owner")
   pg.SetFont('s12 c' fontColor)
   pg.BackColor := formColor
   pg.Add("text", "", "Determining frequency of each hotstring...  [Esc to stop]")
	MyProgress := pg.Add("Progress", "w400 h30 c" progBarGreen " Range0-" TotalLines " Background" listColor, "0")
	pg.Title := "Percent complete: 0 %." ; Starting title (immediately gets updated below.)
	pg.Show()

	Loop parse AllStrs, "`n`r" ; <<<<<<<<<<<<<<<<< SINGLE PASS LOOP START
	{	MyProgress.Value += 1
      If GetKeyState("Esc") { ; If Esc key is pressed. 
         pg.Destroy() ; Remove progress bar.
         Return ; Stop function
      }
		pg.Title :=  "Percent complete: " Round((MyProgress.Value/TotalLines)*100) "%." ; For progress bar.
		If (not inStr(A_LoopField, "::")) ; Skip these.
			Continue
		
		; Extract the hotstring part (skip the date and " -- ")
		; First trim the line to remove any leading/trailing spaces
		trimmedLine := trim(A_LoopField)
		hotstring := SubStr(trimmedLine, 14)
		hotstring := trim(hotstring, " `t")
		
		; Use a Map to tally occurrences
		if !IsSet(tallyMap)
			tallyMap := Map()
		
		if tallyMap.Has(hotstring)
			tallyMap[hotstring]++
		else
			tallyMap[hotstring] := 1
	}  ; <<<<<<<<<<<<<<<<< SINGLE PASS LOOP END
	
	; Build Report from the Map
	For hotstring, count in tallyMap {
		Report .= count " of ⟹ " hotstring "`n"
	}
	
	global trunkReport := []
	global lvReportData := []  ; Data structure to hold ListView row info
	Report := Sort(Sort(Report, "/U"), "NR") ; U is 'remove duplicates.' NR is 'numeric' and 'reverse sort.'
	For idx, item in strSplit(Report, "`n") {
		If item != ""  ; Skip empty lines
         {
            parts := StrSplit(item, " of ⟹ ")
            if parts.Length = 2 && parts[1] != ""
            {
               count := Trim(parts[1])
               hotstring := Trim(parts[2])
               trunkReport.Push(item "`n")
               lvReportData.Push({Count: count, Hotstring: hotstring})
            }
         }
   }
	pg.Destroy() ; Remove progress bar.

   fullReport := '' ; Must delare this, or blank log file causes error in below loop.
   If (SaveFulltoClipBrd = 1) { ; Also Save to clipboard? 
      For item in strSplit(Report, "`n")
      {  If not SubStr(item, 1, 1) = 0
            fullReport .= StrReplace(item, '⟹ ','') . '`n'
      }
      A_Clipboard := fullReport
   }

   ; ===debug===
   ; items := ""
   ; for item in trunkReport
   ;    items .= item "`n"
   ; MsgBox items
   ; =========

	global cl := Gui()  ; "cl" for "Culled"
   cl.SetFont('s12 c' fontColor)  
   cl.BackColor := formColor
	cl.Add('text','w400 wrap','Analysis complete. The most frequent items are shown below. Select an item then right-click to copy, or use buttons below to cull/append.')
   
   ; Create ListView with 2 columns: Count and Hotstring (sortable by default)
   global lv := cl.Add("ListView", "x10 y+8 w400 h550 Grid Background" listColor " vLvSel", ["Count", "Hotstring"])
   lv.OnEvent("ContextMenu", LvContextMenu)
   
   ; Add rows to ListView
   for idx, item in lvReportData {
      lv.Add(, item.Count, item.Hotstring)
   }
   
   ; Set column widths
   lv.ModifyCol(1, 60)  ; Count column
   lv.ModifyCol(2, 330) ; Hotstring column

   cl.SetFont('s12 c' FontColor)
   Global BUchkBox := cl.Add('Checkbox', 'w400 y+8','Make backup of ' MCLogFile ' first')
	
   cl.SetFont('s10')
   cl.Add('button', 'w200 x10 y+5', 'Cull from Log').OnEvent('Click', CullOnlyFunc)
   cl.Add('button', 'x+10 w190 yp', 'Append').OnEvent('Click', AppendOnlyFunc)

   cl.Add('button', 'w200 x10 y+5','Cull and Append').OnEvent('Click', CullerAppender)
   cl.Add('button', 'x+10 w190 yp','Cancel').OnEvent('Click', (*) => cl.Hide())
   
   cl.Add('Button', 'w402 x10 y+8','Remove old singletons').OnEvent("click", RemoveOldFunc.Bind(Report))
      
	cl.Show('x' (A_ScreenWidth / 2) + 250) ; Show slightly to right of center (leaves room for HH2).
   cl.onEvent("Escape", (*) => cl.Destroy())
}

; ListView context menu - right-click to copy hotstring
LvContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
   if Item = 0  ; No item selected
      return
   selectedHotstring := lvReportData[Item].Hotstring
   A_Clipboard := selectedHotstring
   ToolTip("Copied to clipboard: " selectedHotstring, , , 5)
   SetTimer(() => ToolTip(,,,5), -2000)
}

CullOnlyFunc(*) {
   newFileContent := "", selItemName := ""
   global trunkReport
   global lv
   
   selectedRow := lv.GetNext(0)
   If selectedRow = 0 { ; No ListView item selected. 
      MsgBox 'Nothing selected.'
      Return   ; Abort function. 
   }

   selItemName := lvReportData[selectedRow].Hotstring

   ; Make backup if checkbox is checked
   If (BUchkBox.Value = 1)
      FileCopy(MCLogFile, myLogFileBaseName '-BU-' A_Now '.txt', 1)

   ; Remove selected item from log file
   for line in StrSplit(FileRead(MCLogFile), "`n") {
      If (inStr(line, selItemName))
         Continue
      Else
         newFileContent .= line "`n"
   }
   newFileContent := Trim(newFileContent, "`n ") "`n " ; Ensure exactly one empty line at the bottom. 
   FileDelete MCLogFile ; Delete the file so we can remake it.
   FileAppend(newFileContent, MCLogFile) ; Remake the file with the (now culled) string.

   ToolTip("Item culled from log: " selItemName, , , 9)
   SetTimer(() => ToolTip(,,,9), -3000) ; Clear tooltip after 3 seconds 
   
   If KeepReportOpen = 1
      cl.Show() ; Show gui form again.
   Else {
      cl.Destroy() 
      trunkReport := []
   }
}

AppendOnlyFunc(*) {
   selItemName := ""
   global trunkReport
   global lv
   
   selectedRow := lv.GetNext(0)
   If selectedRow = 0 { ; No ListView item selected. 
      MsgBox 'Nothing selected.'
      Return   ; Abort function. 
   }

   selItemName := lvReportData[selectedRow].Hotstring

   ; Make backup if checkbox is checked  
   If (BUchkBox.Value = 1)
      FileCopy(MCLogFile, myLogFileBaseName '-BU-' A_Now '.txt', 1)

   ; Append to autocorrect library
   If SendToHH = 1 ; If =1, send to HotStr Helper via command line.
      Run myACFileBaseName ".exe /script " myAutoCorrectScript " " selItemName
   Else ; Otherwise, just append to bottom. 
   {
      FileAppend("`n" selItemName, myAutoCorrectLibrary)
      MsgBox("Item appended to library: " selItemName)
   }
   
   If KeepReportOpen = 1
      cl.Show() ; Show gui form again.
   Else {
      cl.Destroy() 
      trunkReport := []
   }
}

; This gets called from the button at the bottom of the radio button gui form.
; There are multiple loops.  The first loop extracts all of the frequency report items that
; have a freq of 1.  (I.e. single-occurence items.) The log date is ignored for this purpose. 
; The next loop looks at the dates of the log items and extracts only the old ones. 
; The third loop extract items that occur in both lists (I.e. Old items that are single-occurence.)
; The last loop goes through the list of "old singletons" and removes each from the log file.  
; The old log file list deleted, and a new one made.  
RemoveOldFunc(Report,*) {
   Result := MsgBox( "Pressing OK will immediately remove all logged items that are older than " AgeOfOldSingles " days, and have only one occurence.  There is no undo. But a backup of " MCLogFile " will be made automatically.`n`nContinue?`n`n(Note: The number of days `'" AgeOfOldSingles "`' can be changed near the top of the " A_ScriptName " code.)","Remove Old Singles" , 32+1)
   if (Result = "OK") { ; User pressed OK button.
      cl.Destroy()
      Singletons := "", oldItems := "", oldSingletons := "", oldSinsRemoved := 0
      Global origAllStrs
      
      For item in strSplit(Report, "`n") { ; Loop through frequency report. 
         If (SubStr(item, 1, 1) = 1) and (!IsNumber(SubStr(item, 2, 1))) ; Make a list of items with freq = 1, "singletons"
            Singletons .= StrReplace(item, '1 of ⟹ ','') . '`n'
      } 

      tooOld := FormatTime(DateAdd(A_Now, - AgeOfOldSingles, "Days"), "yyyyMMdd")  ; Get today's date.
      For item in StrSplit(origAllStrs, "`n") { ; Make list of items older than X days.
         trimmedItem := trim(item)  ; Remove leading/trailing spaces
         If  not IsNumber(SubStr(trimmedItem, 1, 1))
            Continue
         Else {  
            loopDay := StrReplace(SubStr(trimmedItem, 1, 10), "-")
            If Integer(tooOld) < Integer(loopDay)
               Continue
            Else
               oldItems .= trimmedItem "`n"
         }
      }

      For oldItem in StrSplit(oldItems, "`n") { ; find ones present in both lists. "Old Singletons"
         For SingItem in StrSplit(Singletons, "`n") {  
            Try If InStr(oldItem, SingItem)
               oldSingletons .= oldItem "`n"
         }
      }
      
      If (oldSingletons = "") {
         MsgBox  "No single-occurence strings " AgeOfOldSingles " days-old were found in " myLogFileBaseName ". No changes were made, so backup of the log was made either."
         Return
      }
      Else {
         For osItem in StrSplit(oldSingletons, "`n") ; Remove old singletons from original list.
         {  origAllStrs := StrReplace(origAllStrs, "`n" osItem "`n", "`n")
            oldSinsRemoved++
         }
         ;A_Clipboard := origAllStrs
         FileCopy(MCLogFile, myLogFileBaseName '-BeforeRemovingOldSinglesBU-' A_Now '.txt', 1) ; Make a backup first.
         Sleep 500 ; Just to be safe. 
         FileDelete MCLogFile ; Delete the file so we can remake it.
         FileAppend(origAllStrs, MCLogFile) ; Remake the file with the (now culled) string.
         MsgBox oldSinsRemoved " old single-occurence strings have been removed from " myLogFileBaseName ". A backup of the log was first made."
      }
   }
}

; This only gets called from the radio button Gui form.  If a radio item is selected 
; all occurences are removed from the log file, and the new items is appended to 
; autocorrect file.  Optionally, the item is sent directly to the HotString Helper 2
; form.  (Need 5-4-2024 or newer version of AutoCorrect2).  A backup is made if above 
; BUchkBox is checked.
CullerAppender(*) { 
   newFileContent := "", selItemName := ""
   global trunkReport
   global lv
   
   selectedRow := lv.GetNext(0)
   If selectedRow = 0 { ; No ListView item selected. 
     MsgBox 'Nothing selected.'
      cl.Show() ; Show gui form again.
      Return   ; Abort function. 
   }

   selItemName := lvReportData[selectedRow].Hotstring

   ; Always cull from log (since this is "Cull and Append")
   for line in StrSplit(FileRead(MCLogFile), "`n") { ; Process and remove duplicates.
      If (inStr(line, selItemName))
         Continue
      Else
         newFileContent .= line "`n"
   }
   newFileContent := Trim(newFileContent, "`n ") "`n " ; Ensure exactly one empty line at the bottom. 
   FileDelete MCLogFile ; Delete the file so we can remake it.
   FileAppend(newFileContent, MCLogFile) ; Remake the file with the (now culled) string.
   
   If (BUchkBox.Value = 1)
      FileCopy(MCLogFile, myLogFileBaseName '-BU-' A_Now '.txt', 1)
   
   ; Always append to library (since this is "Cull and Append")
   If SendToHH = 1 ; If =1, send to HotStr Helper via command line.
      Run myACFileBaseName ".exe /script " myAutoCorrectScript " " selItemName
   Else ; Otherwise, just append to bottom. 
   {
      FileAppend("`n" selItemName, myAutoCorrectLibrary) ; Put culled item at bottom of ac file.
      MsgBox("Item appended to library and culled from log: " selItemName)
   }

   If KeepReportOpen = 1 ; Remove list after clicking 'Cull and Append'?
      cl.Show() ; Show gui form again.
   Else {
      cl.Destroy() 
      trunkReport := []
   }
}

; This function is only accessed via the systray menu item.  It toggles adding/removing
; link to this script in Windows Start up folder. 
StartUpMCL(*) { ; Start with windows? 
	if FileExist(A_Startup "\MCLogger.lnk")
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
ToolTipOptions.SetColors("0x" SubStr(ListColor, -6), "0x" SubStr(FontColor, -6))

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
