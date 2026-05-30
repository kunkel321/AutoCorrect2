#SingleInstance
#Requires AutoHotkey v2.0
Persistent

; ==============================================================================
; The Manual Correction Logger -- MCLogger 
; ==============================================================================
; Author: Kunkel321
; Tool Used: Claude AI
; Version: 5-27-2026 
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
; Thanks to Mikeyww who helped with the original inputHook code and to Just Me, 
; who wrote the ToolTipOptions class.
; ==============================================================================
; Related tool:  Users of MS Word VBA may be interested in the code here
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=120220&start=180#p605321
; Which monitors the correction (via r-click) of misspelled words and logs them
; to the same ManualCorrectionsLog.txt file.
; ==============================================================================

#Include "..\Includes\AcMsgBox.ahk" ; For custom msgbox system. Required.

;========= LOAD SETTINGS FROM INI ============================================
settingsFile := "..\Data\acSettings.ini" ; Required
SettingsManager := "..\Tools\SettingsManager.exe" ; Optional (appears on systray menu)

; Ensure settings file exists.
if !FileExist(settingsFile) {
	acMsgBox.show(settingsFile " was not found.  You probably need to get`nit from github.com/kunkel321/autocorrect2`n`nNow exiting")
   ExitApp
}

; Load settings from INI file.  
MCLogFile := "..\Data\" IniRead(settingsFile, "Files", "MCLogFile", "ManualCorrectionsLog.txt")
MCLogContinuous := "..\Data\" IniRead(settingsFile, "Files", "MCLogContinuous", "MCLogContinuous.txt")
myAutoCorrectLibrary := IniRead(settingsFile, "Files", "HotstringLibrary", "HotstringLib.ahk")
RemovedHsFile := "..\Data\" IniRead(settingsFile, "Files", "RemovedHsFile", "Data\RemovedHotstrings.txt")
myAutoCorrectScript := IniRead(settingsFile, "Files", "MyAutoCorrectScript", "AutoCorrect2.ahk")
WordListFile := "..\Data\" IniRead(settingsFile, "Files", "WordListFile", "GitHubComboList249k.txt")

MCLoggerRunAnalysisHotkey := IniRead(settingsFile, "HotKeys", "MCLoggerRunAnalysisHotkey", "#^+q")
MCLoggerSneakPeekHotkey := IniRead(settingsFile, "HotKeys", "MCLoggerSneakPeekHotkey", "#+q")

LightGreen := "c" IniRead(settingsFile, "Shared", "LightGreen", "b8f3ab")
DarkGreen := "c" IniRead(settingsFile, "Shared", "DarkGreen", "0d3803")

showEachHotString := IniRead(settingsFile, "MCLogger", "ShowEachHotString", 1)
beepEachHotString := IniRead(settingsFile, "MCLogger", "BeepEachHotString", 1)
saveIntervalMinutes := IniRead(settingsFile, "MCLogger", "SaveIntervalMinutes", 10)
IntervalsBeforeStopping := IniRead(settingsFile, "MCLogger", "IntervalsBeforeStopping", 2)
SendToHH := IniRead(settingsFile, "MCLogger", "SendToHH", 1)
SaveFulltoClipBrd := IniRead(settingsFile, "MCLogger", "SaveFullToClipboard", 1)
AgeOfOldSingles := IniRead(settingsFile, "MCLogger", "AgeOfOldSingles", 90)
KeepReportOpen := IniRead(settingsFile, "MCLogger", "KeepReportOpen", 1)
; Typo-plausibility thresholds (used by IsTypoOfReplacement).
; LetterOverlapMin: percentage (0-100) of replacement letters that must appear
;   in the trigger for Test A to pass.  Default 40 (40%).
; AdjacentKeyMin: percentage (0-100) of *differing* positions that must be
;   QWERTY-adjacent for Test B to pass (same-length pairs only).  Default 60 (60%).
LetterOverlapMin := IniRead(settingsFile, "MCLogger", "LetterOverlapMin", 40)
AdjacentKeyMin   := IniRead(settingsFile, "MCLogger", "AdjacentKeyMin",   60)
; DebugFilterLog: set to 1 to log filtered-out items to Debug\MCLogger_Filtered.tsv.
; Each line records the item and the filter stage that rejected it.
DebugFilterLog := IniRead(settingsFile, "MCLogger", "DebugFilterLog", 0)

; Convert string values to integers where needed
showEachHotString := Integer(showEachHotString)
beepEachHotString := Integer(beepEachHotString)
saveIntervalMinutes := Integer(saveIntervalMinutes)
IntervalsBeforeStopping := Integer(IntervalsBeforeStopping)
SendToHH := Integer(SendToHH)
SaveFulltoClipBrd := Integer(SaveFulltoClipBrd)
AgeOfOldSingles := Integer(AgeOfOldSingles)
KeepReportOpen := Integer(KeepReportOpen)
LetterOverlapMin := Integer(LetterOverlapMin) / 100
AdjacentKeyMin   := Integer(AdjacentKeyMin)   / 100
DebugFilterLog   := Integer(DebugFilterLog)

; Build the debug log path.  The Debug\ folder is created on first write if absent.
FilteredLogFile := A_ScriptDir "\..\Debug\MCLogger_Filtered.tsv"

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
progBarGreen := brightness > 128 ? DarkGreen  : LightGreen  ; The color of the progress bar.

;--- create systray menu ----
mclAppIcon := "..\Resources\Icons\JustLog.ico"
TraySetIcon(mclAppIcon) ; A fun homemade "log" icon that Steve made.
appName := StrReplace(A_ScriptName, ".ahk") ; Assign the name of this file as "appName".
mclMenu := A_TrayMenu ; Tells script to use this when right-click system tray icon.
mclMenu.Delete ; Removes all of the defalt memu items, so we can add our own. 
mclMenu.Add(appName, (*) => False) ; Shows name of app at top of menu.
mclMenu.SetIcon(appName, mclAppIcon) 
mclMenu.Add("Log and Reload Script", (*) => Reload())
mclMenu.SetIcon("Log and Reload Script", "..\Resources\Icons\data_backup-Brown.ico")
mclMenu.Add("Edit This Script", EditThisScript)
mclMenu.SetIcon("Edit This Script", "..\Resources\Icons\edit-Brown.ico")
mclMenu.Add("Open " MCLogFile, (*) => Run(MCLogFile))
mclMenu.SetIcon("Open " MCLogFile, "..\Resources\Icons\TxtFile-Brown.ico")
If FileExist(SettingsManager) { ; Only add to menu if SM found.
   mclMenu.Add("Open " SettingsManager, (*) => Run(SettingsManager))
   mclMenu.SetIcon("Open " SettingsManager, "..\Resources\Icons\Settings-blue.ico")
}
mclMenu.Add("Analyze Manual Corrections", runAnalysis)
mclMenu.SetIcon("Analyze Manual Corrections", "..\Resources\Icons\search-Brown.ico")
mclMenu.Add("Start with Windows", StartUpMCL)
if FileExist(A_Startup "\" appName ".lnk")
   mclMenu.Check("Start with Windows")
mclMenu.Add("List Lines Debug", (*) => ListLines())
mclMenu.SetIcon("List Lines Debug", "..\Resources\Icons\ListLines-Brown.ico")
mclMenu.Add("Exit Script", (*) => ExitApp())
mclMenu.SetIcon("Exit Script", "..\Resources\Icons\exit-Brown.ico")
mclMenu.SetColor("C29A6A") ; #CD853F is "Peru"
mclMenu.Default := appName ; Make default so it will be blank.
;---- end of menu creation --- 

; This function is only accessed via the systray menu item.  It toggles adding/removing
; link to this script in Windows Start up folder. 
StartUpMCL(*) { ; Start with windows? 
	if FileExist(A_Startup "\" appName ".lnk") {
      FileDelete(A_Startup "\" appName ".lnk")
		acMsgBox.show("Manual Correction Logger will NO LONGER auto start with Windows.",, 4096)
	}
	Else {	
      FileCreateShortcut(A_WorkingDir "\" appName ".exe", A_Startup "\" appName ".lnk"
      , A_WorkingDir, "", "", A_ScriptDir "\" mclAppIcon) ; Change icon if needed.
		acMsgBox.show("Manual Correction Logger will auto start with Windows.",, 4096)
	}
   Reload()
}

; Make sure AHK editor is assigned.  Use Notepad otherwise.
If not FileExist(MyAhkEditorPath) {
	acMsgBox.show("This error means that the variable 'MyAhkEditorPath' has"
	"`nnot been assigned a valid path for an editor."
	"`nTherefore Notepad will be used as a substite.")
	MyAhkEditorPath := "Notepad.exe"
}

; Make sure word list is there. Change name of word list subfolder, if desired. 
If not FileExist(WordListFile) {
	acMsgBox.show("This error means that the big list of comparison words at:`n" WordListFile
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
	acMsgBox.show("This error means that the exsiting library of hotstrings "
	"`nwas not found.`n`nMust assign a file to variable, such as`n"
	"myAutoCorrectLibrary := `"HotstringLib.ahk`"`nfor script to work.`n`nNow exiting.")
	ExitApp
}
AcFileContents := Fileread(myAutoCorrectLibrary)
If FileExist(RemovedHsFile)
   AcFileContents .= "`n" Fileread(RemovedHsFile)
;msgbox "AcFileContents:`n`n" AcFileContents

#HotIf WinActive("MCLogger.ahk") ; MCLogger-specific
$^s:: ; Save and reload MCLogger script. ; hide 
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
If (MCLoggerSneakPeekHotkey != "")
   HotKey(MCLoggerSneakPeekHotkey, peekToolTip)
peekToolTip(*) { ; sneak-a-peek at working variables.
   peekVar :=
   (
      'Current typoCache:`n' typoCache
      '`n============================'
      '`nCurrent Saved up Text:`n' savedUpText
   )
   ToolTip(peekVar "`n(also saved to clipboard)"
      ,,,7)
   A_Clipboard := peekVar
}

; These are not "window-specific".  They will clear the cache of "watched" 
; key-presses, no matter what app you are working in.   This is important, because 
; we only are interested in typing patterns that are created from an uninterrupted
; string of keypresses.  If the user uses the arrows to go back in a word, or 
; clicks in it, that string will be broken... So we need to "start over" the 
; keypress watching.  
~Esc::      ; MCLogger code ; hide
~LButton::  ; User clicked somewhere, ; hide
~Up::	      ; Or moved the cursor, so... ; hide
~Down::	   ; Clear cache to start over  ; hide
~Left::     ; To avoid having unrelated text  ; hide
~Right::    ; processes as a single word.  ; hide
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
RegEx := "(?<trig>[A-Za-z\.']{3,})(?<midspace>~?)(?<back>[<]+)(?<repl>[A-Za-z\.']+)[ \~]+"
; regex is watching for pattern ...<.~
; midspace captures an optional ~ between the trigger and backspaces (Pattern B: space typed before correcting)

; This function filters-out non-letter characters.  
; Allow period (for end of sentence) and apostrophe (for contractions) though.
; Note: space is intentionally excluded — Space is routed through tih_EndChar as vk=32.
tih_Char(tih, char) {
	Global typoCache
	if (RegExMatch(char, "[A-Za-z\.']+")) { ; Only use letters, period, apostrophe.
		typoCache .= char
   }
}

CoordMode 'ToolTip', 'Screen'
CoordMode 'Caret', 'Screen'

; When Backspace or Space is pressed, this function is called.
; Two correction patterns are recognized:
;   Pattern A (classic):  word<<<repl~   (corrected before hitting Space)
;   Pattern B (new):      word~<<<repl~  (Space typed first, then backspaced and corrected)
; On a non-matching Space the cache is NOT cleared, allowing Pattern B to accumulate.
; A length cap prevents the cache from growing unbounded during normal typing.
; Once a match is found, the trigger and replacement are extrapolated, validity-checked,
; and (if valid) appended with a datestamp to the "Saved up Text" variable for logging.
tih_EndChar(tih, vk, sc) {
   Global typoCache .= vk = 8 ? '<' : '~'   ; '<' for Backspace, '~' for Space

   ; Length cap: if cache grows too long without a match, keep only the last 60 chars.
   ; This prevents runaway growth during normal typing with many spaces.
   if StrLen(typoCache) > 120
      typoCache := SubStr(typoCache, -59)   ; keep last 60 chars

   If !RegExMatch(typoCache, RegEx, &out)   ; watch for pattern ...<.~
      return  ; No match yet — leave cache intact so Pattern B can accumulate.

   ; ---- A match was found.  Determine which pattern. ----
   ; If midspace captured a ~ it is Pattern B: the user hit Space after finishing the typo,
   ; then backspaced into the word.  That BS consumed the space rather than a typed letter,
   ; so subtract 1 from the effective backspace count used in reconstruction.
   rawTrig        := out.trig
   cleanTrig      := rawTrig                          ; trig group no longer swallows the mid-space
   spacesBs       := (out.midspace = "~") ? 1 : 0    ; 1 = Pattern B (space before BSs), 0 = Pattern A
   trigLen        := StrLen(cleanTrig)
   BsLen          := StrLen(out.back)
   replLen        := StrLen(out.repl)
   effectiveBsLen := BsLen - spacesBs                ; BSs that actually deleted typed letters

   if (spacesBs > 0) {
      ; Pattern B: the full trigger word was definitely typed (user pressed Space after it),
      ; so newTrig is always cleanTrig — no reconstruction needed.
      newTrig       := cleanTrig
      ; newRepl reconstruction uses effectiveBsLen instead of raw BsLen.
      FirstPartTrig := SubStr(cleanTrig, 1, trigLen - effectiveBsLen)
      newRepl       := FirstPartTrig . out.repl
   }
   else {
      ; Pattern A: classic behavior, unchanged.
      if (replLen > BsLen) { ; Replacement longer than BSs — part of trigger is hiding in repl.
         LastPartRepl := SubStr(out.repl, '-' (replLen - BsLen))
         newTrig := rawTrig . LastPartRepl
      }
      else { ; BSs >= repl length — entire trigger was typed before backspacing began.
         newTrig := rawTrig
      }
      FirstPartTrig := SubStr(rawTrig, 1, trigLen - BsLen)
      newRepl       := FirstPartTrig . out.repl
   }

   newTrig := Trim(newTrig, " .")
   newRepl := Trim(newRepl, " .")

   ; Sanity check: bail out if reconstruction produced something degenerate.
   if (newTrig = "" || newRepl = "" || newTrig = newRepl || effectiveBsLen < 1) {
      typoCache := ""
      return
   }

   ; Run all five validity filters (cheapest checks first).
   ; See PassesAllFilters() below for the full logic.
   filterReason := ""
   if !PassesAllFilters(newTrig, newRepl, &filterReason) {
      if (DebugFilterLog = 1)
         LogFilteredItem(newTrig, newRepl, filterReason)
      typoCache := ""
      setTimer ClearToolTip, -2000
      return
   }

   ; --- Check 5: not a repeat of the immediately preceding logged entry ---
   ; Kept here (not in PassesAllFilters) because savedUpText is a live global
   ; that belongs to the caller's domain, not the filter function's.
   newHs := A_YYYY "-" A_MM "-" A_DD " -- ::" newTrig "::" newRepl
   lastSavedHS := SubStr(savedUpText, 1, InStr(savedUpText, '`n'))
   If InStr(lastSavedHS, newTrig) {   ; Don't save duplicate of one just saved.
      if (DebugFilterLog = 1)
         LogFilteredItem(newTrig, newRepl, "Duplicate of previous entry")
      typoCache := ""
      setTimer ClearToolTip, -2000
      return
   }

   ; --- All checks passed — log it ---
   keepText(newHs)
   If (showEachHotString = 1) {
      If CaretGetPos(&mcx, &mcy)
         ToolTip "::" newTrig "::" newRepl, mcx-15, mcy-100, 6   ; <--- LOCATION of tooltip is set here.
      Else
         ToolTip "::" newTrig "::" newRepl, (A_ScreenWidth/2), 10, 6
   }
   If (beepEachHotString = 1)
      soundBeep(1600, 120)   ; announcement of capture.
   typoCache := ""               ; Clear var to start over.
   setTimer ClearToolTip, -2000  ; Clear tooltip after 2 sec.
}

ClearToolTip(*) { 
	ToolTip ,,,6 ; The 6 is an arbitrary identifier.  
}

; -----------------------------------------------------------------------
; LogFilteredItem(trig, repl, reason)
; Called only when DebugFilterLog = 1.  Appends one TSV line to
; Debug\MCLogger_Filtered.tsv so filtered-out pairs can be reviewed.
; Columns:  Timestamp | Hotstring | Filter reason
; The Debug\ folder is created automatically if it does not exist.
; -----------------------------------------------------------------------
LogFilteredItem(trig, repl, reason) {
   global FilteredLogFile
   if !DirExist(SubStr(FilteredLogFile, 1, InStr(FilteredLogFile, "\",, -1) - 1))
      DirCreate(SubStr(FilteredLogFile, 1, InStr(FilteredLogFile, "\",, -1) - 1))
   stamp := A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min
   line  := stamp "`t" "::" trig "::" repl "`t" reason "`n"
   FileAppend(line, FilteredLogFile, "UTF-8")
}

; -----------------------------------------------------------------------
; PassesAllFilters(newTrig, newRepl)
; Returns true only if the trig/repl pair clears all four validity gates.
; Checks are ordered cheapest-first so expensive scans are skipped early.
;
;   Check 1 & 2 — Word-list membership (single O(n) pass, early exit):
;     repl must be a real word; trig must NOT be a real word.
;     The most common disqualifier, so it runs first.
;
;   Check 3 — Plausible typo (O(word-length), very cheap):
;     Filters out "changed my mind" fragments like analr->other
;     while preserving genuine typos including whole-hand shift errors
;     like hyno->jump.  Runs before the expensive library scan.
;
;   Check 4 — No conflict with existing AC library or removed list:
;     The most expensive check (loops the full library).  Only reached
;     by pairs that passed all prior filters.
; -----------------------------------------------------------------------
PassesAllFilters(newTrig, newRepl, &filterReason := "") {
   global wordListArray, AcFileContents

   ; --- Checks 1 & 2: word-list membership, single pass with early exit ---
   trigRealWord := 0, replRealWord := 0
   for item in wordListArray {
      w := Trim(item, "`n`r ")
      if (w = newRepl)
         replRealWord := 1
      if (w = newTrig)
         trigRealWord := 1
      if (replRealWord and trigRealWord)
         break   ; Both flags set — no need to scan further.
   }
   if (replRealWord = 0) {
      filterReason := "Repl not a word"
      return false
   }
   if (trigRealWord = 1) {
      filterReason := "Trig is a real word"
      return false
   }

   ; --- Check 3: plausible typo (letter overlap or adjacent-key shift) ---
   if !IsTypoOfReplacement(newTrig, newRepl) {
      filterReason := "Low similarity (not a plausible typo)"
      return false
   }

   ; --- Check 4: no conflict with existing AC library or removed list ---
   ; Mirrors HotstringHelper's ValidateTriggerString — four conflict types.
   Loop Parse, AcFileContents, "`n", "`r" {
      if (SubStr(Trim(A_LoopField, " `t"), 1, 1) != ":") and (SubStr(A_LoopField, 1, 7) != "Removed")
         continue   ; Skip non-hotstring lines.
      if RegExMatch(A_LoopField, "i):(?P<Opts>[^:]*):(?P<Trig>[^:]+)", &loo) {
         libOpts := loo.Opts
         libTrig := Trim(loo.Trig)
         if (newTrig = libTrig) {
            filterReason := "Exact duplicate in library"
            return false
         }
         if InStr(libOpts, "*") and InStr(libOpts, "?")
            and InStr(newTrig, libTrig) {
            filterReason := "Word-middle conflict with :*?:" libTrig
            return false
         }
         if InStr(libOpts, "?") and !InStr(libOpts, "*")
            and StrLen(libTrig) < StrLen(newTrig)
            and (SubStr(newTrig, -StrLen(libTrig)) = libTrig) {
            filterReason := "Word-ending conflict with :?:" libTrig
            return false
         }
         if InStr(libOpts, "*") and !InStr(libOpts, "?")
            and StrLen(libTrig) < StrLen(newTrig)
            and (SubStr(newTrig, 1, StrLen(libTrig)) = libTrig) {
            filterReason := "Word-beginning conflict with :*:" libTrig
            return false
         }
      }
   }
   return true
}

; -----------------------------------------------------------------------
; IsTypoOfReplacement(trig, repl)
; Returns true if trig is a plausible mistyping of repl.
; Either of two tests is sufficient to pass:
;
;   Test A — Letter overlap:
;     At least 40% of the replacement's letters appear in the trigger
;     (multiset intersection).  Covers normal typos: transpositions,
;     extra/missing letters, vowel swaps, suffix confusion, etc.
;
;   Test B — Adjacent-key shift (same-length pairs only):
;     At least 60% of the positions where the two strings differ are
;     QWERTY-adjacent key pairs.  Covers one-handed or partial-hand
;     shift errors, e.g.:
;       hyno  -> jump   (every letter shifted — whole right-hand shift)
;       vurm  -> burn   (mixed: some letters correct, some adjacent-key)
;     The 60% threshold allows for the correct-hand letters that land
;     right while the shifted hand produces adjacent-key errors.
;
; Pairs that fail BOTH tests are treated as abandoned fragments
; (user changed their mind mid-word) and filtered out.
; -----------------------------------------------------------------------
IsTypoOfReplacement(trig, repl) {
   global LetterOverlapMin, AdjacentKeyMin
   trig := StrLower(trig)
   repl := StrLower(repl)

   ; --- Test A: shared-letter fraction (multiset) ---
   trigCounts := Map()
   Loop StrLen(trig) {
      ch := SubStr(trig, A_Index, 1)
      if RegExMatch(ch, "[a-z]")
         trigCounts[ch] := trigCounts.Has(ch) ? trigCounts[ch] + 1 : 1
   }
   matched := 0, replLetters := 0
   Loop StrLen(repl) {
      ch := SubStr(repl, A_Index, 1)
      if RegExMatch(ch, "[a-z]") {
         replLetters++
         if trigCounts.Has(ch) and trigCounts[ch] > 0 {
            matched++
            trigCounts[ch]--   ; consume so each trig letter matches at most once
         }
      }
   }
   if (replLetters > 0) and ((matched / replLetters) >= LetterOverlapMin)
      return true   ; Test A passes — plausible normal typo.

   ; --- Test B: adjacent-key shift (same length required) ---
   if StrLen(trig) != StrLen(repl)
      return false   ; Different lengths + low overlap = abandoned fragment.

   adjacent := Map(
      "q","wa",    "w","qase",  "e","wsdr",  "r","edft",
      "t","rfgy",  "y","tghu",  "u","yhji",  "i","ujko",
      "o","iklp",  "p","ol",
      "a","qwsz",  "s","awedxz","d","serfcx","f","drtgvc",
      "g","ftyhbv","h","gyujnb","j","huikmn","k","jiolm",
      "l","kop",
      "z","asx",   "x","zsdc",  "c","xdfv",  "v","cfgb",
      "b","vghn",  "n","bhjm",  "m","njk"
   )
   diffTotal := 0, diffAdjacent := 0
   Loop StrLen(trig) {
      tc := SubStr(trig, A_Index, 1)
      rc := SubStr(repl, A_Index, 1)
      if (tc = rc)
         continue   ; Correct-hand letters that landed right — ignore.
      diffTotal++
      if RegExMatch(tc, "[a-z]") and RegExMatch(rc, "[a-z]")
         and ((adjacent.Has(tc) and InStr(adjacent[tc], rc))
           or (adjacent.Has(rc) and InStr(adjacent[rc], tc)))
         diffAdjacent++
   }
   ; At least one diff, and >= AdjacentKeyMin of diffs are adjacent-key pairs.
   return (diffTotal > 0) and ((diffAdjacent / diffTotal) >= AdjacentKeyMin)
}

logIsRunning := 0, savedUpText := '', intervalCounter := 0 
saveIntervalMinutes := saveIntervalMinutes*60*1000 ; convert to miliseconds.

; There's no point running the logger if no text has been saved up...  
; So don't run timer when script starts.  Run it when logging starts. 
keepText(newHs) {
   global savedUpText .= strLower(newHs) '`n'
   global intervalCounter := 0  	; Reset the counter since we're adding new text
   If logIsRunning = 0  			; only start the timer it it is not already running.
      setTimer Appender, saveIntervalMinutes  	; call function every X minutes.
}

OnExit Appender 	; Also append one more time on exit. 

; Gets called by timer, or by onExit.
Appender(*) { 
   savedUpText := sort(savedUpText, "U") ; A second mechanism for unduping. 
   FileAppend savedUpText, MCLogFile         ; The log that gets scanned by this script.
   FileAppend savedUpText, MCLogContinuous   ; A static duplicate of the log, for other analyses.
   global savedUpText := ''  		; clear each time, since text has been logged.
	global logIsRunning := 1  		; set to 1 so we don't keep resetting the timer.
   global intervalCounter += 1 	; Increments here, but resets in other locations. 
   If (intervalCounter >= IntervalsBeforeStopping) { ; Check if no text has been kept for X intervals
      setTimer Appender, 0  		; Turn off the timer
         global logIsRunning := 0  	; Indicate that the timer is no longer running
      global intervalCounter := 0 ; Reset the counter for safety
   }
}

; This gets called from the hotkey, the menu item, or command line switch.  
; It creates two different GUI forms.  The first is a progress bar that shows 
; the progress of a frequency analysis which checks which potential hotstrings 
; have been logged multiple times. The second GUI is a ListView which shows 
; the items with occurrence count and hotstring.
if (A_Args.Length > 0) ; Check if a command line argument is present.
	runAnalysis() ; If present, open run analysis immediately. 

If (MCLoggerRunAnalysisHotkey != "")
   Hotkey(MCLoggerRunAnalysisHotkey, runAnalysis)  ; Change hotkey above, if desired. 
   
runAnalysis(*) {
	AllStrs := FileRead(MCLogFile)   ; ahk file... Know thyself. 
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
	For item in strSplit(Report, "`n") {
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
   
   ; Calculate DeltaString color based on form brightness (already calculated at startup, line 101)
   deltaColor := brightness > 128 ? "191970" : "00FFFF"  ; Dark blue for light background, light cyan for dark background
   
   ; Add DeltaString control to show visual comparison of trigger/replacement
   ; Styling: s15 bold, aligned with list, contrasting blue color, same background as form
   global DeltaStringCtrl := cl.Add('Text', 'x90 y+10 w300 h25 Background' formColor ' c' deltaColor, '')
   DeltaStringCtrl.SetFont('s15')
   cl.SetFont('s12 c' fontColor)
   
   ; Create ListView with 2 columns: Count and Hotstring (sortable by default)
   global lv := cl.Add("ListView", "x10 y+10 w400 h500 Grid Background" listColor " vLvSel", ["Count", "Hotstring"])
   lv.OnEvent("ContextMenu", LvContextMenu)
   lv.OnEvent("ItemSelect", LvItemSelect)
   
   ; Add rows to ListView
   for item in lvReportData {
      lv.Add(, item.Count, item.Hotstring)
   }
   
   ; Set column widths
   lv.ModifyCol(1, 60)  ; Count column
   lv.ModifyCol(2, 330) ; Hotstring column

   cl.SetFont('s10 c' FontColor)
   Global BUchkBox := cl.Add('Checkbox', 'w400 y+8','Make backup of ' MCLogFile ' first')
	
   cl.SetFont('s11')
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

; ListView item select event - generate and display DeltaString
LvItemSelect(GuiCtrlObj, Item, IsSelected) {
   if !IsSelected || Item = 0
      return
   
   selectedHotstring := lvReportData[Item].Hotstring
   
   ; Parse the hotstring to extract trigger and replacement
   ; Format is typically: ::trigger::replacement
   ; But we need to handle various formats
   triggerText := ""
   replacementText := ""
   
   ; Try to parse the hotstring
   ; Look for the pattern ::trigger::replacement
   parts := StrSplit(selectedHotstring, "::")
   
   if parts.Length >= 3 {
      triggerText := parts[2]
      replacementText := parts[3]
   }
   
   ; Generate and display the DeltaString
   if triggerText != "" && replacementText != "" {
      deltaString := GenerateDeltaString(triggerText, replacementText)
      DeltaStringCtrl.Value := deltaString
   } else {
      DeltaStringCtrl.Value := ""
   }
}

CullOnlyFunc(*) {
   newFileContent := "", selItemName := ""
   global trunkReport
   global lv
   
   selectedRow := lv.GetNext(0)
   If selectedRow = 0 { ; No ListView item selected. 
      acMsgBox.show 'Nothing selected.'
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
      acMsgBox.show 'Nothing selected.'
      Return   ; Abort function. 
   }

   selItemName := lvReportData[selectedRow].Hotstring

   ; Make backup if checkbox is checked  
   If (BUchkBox.Value = 1)
      FileCopy(MCLogFile, myLogFileBaseName '-BU-' A_Now '.txt', 1)

   ; Append to autocorrect library
   If SendToHH = 1 ; If =1, send to HotStr Helper via command line.
      Run myACFileBaseName '.exe /script ' myAutoCorrectScript ' "' selItemName '"'
   Else ; Otherwise, just append to bottom. 
   {
      FileAppend("`n" selItemName, myAutoCorrectLibrary)
      acMsgBox.show("Item appended to library: " selItemName)
   }
   
   If KeepReportOpen = 1
      cl.Show() ; Show gui form again.
   Else {
      cl.Destroy() 
      trunkReport := []
   }
}

; This gets called from the button at the bottom of the report gui form.
; There are multiple loops.  The first loop extracts all of the frequency report items that
; have a freq of 1.  (I.e. single-occurence items.) The log date is ignored for this purpose. 
; The next loop looks at the dates of the log items and extracts only the old ones. 
; The third loop extract items that occur in both lists (I.e. Old items that are single-occurence.)
; The last loop goes through the list of "old singletons" and removes each from the log file.  
; The old log file list deleted, and a new one made.  
RemoveOldFunc(Report,*) {
   Result := acMsgBox.show( "Pressing OK will immediately remove all logged items that are older than " AgeOfOldSingles " days, and have only one occurence.  There is no undo. But a backup of " MCLogFile " will be made automatically.`n`nContinue?`n`n(Note: The number of days `'" AgeOfOldSingles "`' can be changed in the acSettings.ini file, or with the SettingsManager tool.)","Remove Old Singles" , 1)
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
         acMsgBox.show  "No single-occurence strings " AgeOfOldSingles " days-old were found in " myLogFileBaseName ". No changes were made, so backup of the log was made either."
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
         acMsgBox.show oldSinsRemoved " old single-occurence strings have been removed from " myLogFileBaseName ". A backup of the log was first made."
      }
   }
   else { ; User pressed Cancel button
      ; Report dialog remains open for further action
      Return
   }
}

; This only gets called from the listview in the report dialog.  If a listview item is selected 
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
     acMsgBox.show 'Nothing selected.'
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
      Run myACFileBaseName '.exe /script ' myAutoCorrectScript ' "' selItemName '"'
   Else ; Otherwise, just append to bottom. 
   {
      FileAppend("`n" selItemName, myAutoCorrectLibrary) ; Put culled item at bottom of ac file.
      acMsgBox.show("Item appended to library and culled from log: " selItemName)
   }

   If KeepReportOpen = 1 ; Remove list after clicking 'Cull and Append'?
      cl.Show() ; Show gui form again.
   Else {
      cl.Destroy() 
      trunkReport := []
   }
}

; ==============================================================================
; GenerateDeltaString()
; ==============================================================================
; Generates a visual representation of the differences between trigger and 
; replacement strings. This helps visualize what parts are common and what 
; parts constitute the error and fix.
; 
; Format: beginning [ typo | fix ] ending
; ==============================================================================
GenerateDeltaString(triggerText, replacementText) {
   beginning := ""
   typo := ""
   fix := ""
   ending := ""
   
   triggerLength := StrLen(triggerText)
   replacementLength := StrLen(replacementText)
   
   ; If trigger and replacement are identical
   if triggerText = replacementText {
      return "[ " triggerText " ]"
   }
   
   ; Find matching prefix
   i := 1
   while i <= triggerLength && i <= replacementLength 
         && SubStr(triggerText, i, 1) = SubStr(replacementText, i, 1) {
      beginning .= SubStr(triggerText, i, 1)
      i++
   }
   
   ; Find matching suffix (working backwards)
   j := 0
   while j < triggerLength - i + 1 && j < replacementLength - i + 1 
         && SubStr(triggerText, triggerLength - j, 1) = SubStr(replacementText, replacementLength - j, 1) {
      ending := SubStr(triggerText, triggerLength - j, 1) . ending
      j++
   }
   
   ; Extract the differing middle parts
   typo := SubStr(triggerText, i, triggerLength - i - j + 1)
   fix := SubStr(replacementText, i, replacementLength - i - j + 1)
   
   return beginning " [ " typo " | " fix " ] " ending
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
