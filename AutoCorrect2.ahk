#SingleInstance
SetWorkingDir(A_ScriptDir)
SetTitleMatchMode("RegEx")
#Requires AutoHotkey v2+
;------------------------------------------------------------------------------

; Startup anouncement
SoundBeep(900, 200)
SoundBeep(1200, 100)

;------------------------------------------------------------------------------
;       AUto-COrrect TWo COnsecutive CApitals
; This version by forum user Ntepa. Updated 8-7-2023.
; https://www.autohotkey.com/boards/viewtopic.php?p=533067#p533067
;------------------------------------------------------------------------------

Run "CaseCorrector.exe"
; Decided to have CaseCorrector as a separate script, so that it would use its own process. 

;------------------------------------------------------------------------------
;      Hotstring Helper - Multi line
; By Kunkel321, with much help from forum members and others. Version 9-4-2023
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=114688
; A version of Hotstring Helper that will support block multi-line replacements.
; Customization options are present throughout, and are flagged as such.
; Needs AHK v2. Partly auto-converted from v1, partly rewritten.
; Please get a copy of AutoHotkey.exe (v2) and rename it to match the name of this
; script file, so that the .exe and the .ahk have the same name, in the same folder.
; DO NOT COMPILE, or the Append command won't work. The Gui stays in RAM, but gets
; repopulated upon hotkey press. HotStrings will be appended (added) by the
; script at the bottom.Remove these comments as desired.
;------------------------------------------------------------------------------

;==Change=colors=as=desired========================
GuiColor := "F0F8FF" ; "F0F8FF" is light blue
FontColor := "003366" ; "003366" is dark blue
;==================================================

Global hFactor := 0 ; Don't change size here.  Change in TogSize() function, below.
Global wFactor := 0 ; Don't change here.  Change in TogSize() function.
;hhFormName := "Hotstring Helper -- Multi-Line" ; Change here, if desired.

hh := Gui('', "Hotstring Helper -- Multi-Line")
hh.Opt("-MinimizeBox +alwaysOnTop")
hh.BackColor := GuiColor
FontColor := FontColor != "" ? " c" . FontColor : ""
hh.SetFont("s11" . FontColor)
; -----  Trigger string parts
hh.AddText('y4 w30', 'Options')
hh.AddText('vTrigStrLbl x+20 w250', 'Trigger String')
hh.AddEdit('vMyDefaultOpts yp+20 xm+10 w30 h24')
DefHotStr := hh.AddEdit('vDefHotStr x+28 w' . wFactor + 250, '')
; ----- Replacement string parts
hh.AddText('xm', 'Enter Replacement String')
hh.SetFont('s9')
hh.AddButton('vSizeTog x+5 yp-5 h8 +notab', 'Make Bigger').OnEvent("Click", TogSize)
hh.AddButton('vSymTog x+5 h8 +notab', '+ Symbols').OnEvent("Click", TogSym)
hh.SetFont('s11')
RepStr := hh.AddEdit('vRepStr +Wrap y+1 xs h' . hFactor + 100 . ' w' . wFactor + 320, '')
ComLbl := hh.AddText('xm y' . hFactor + 182, 'Enter Comment')

(AsFunc := hh.AddCheckbox('vAsFunc x+' wFactor + 79, "function")).OnEvent("Click", hhBoxAsFunction)

hh.SetFont("s11 cGreen")
ComStr := hh.AddEdit('vComStr xs y' . hFactor + 200 . ' w' . wFactor + 315)
; ---- Buttons
(ButApp := hh.AddButton('xm y' . hFactor + 234, '&Append')).OnEvent("Click", hhButtonAppend)
(ButVal := hh.AddButton('+notab x+5 y' . hFactor + 234, '&Validate')).OnEvent("Click", hhButtonValidate)
(ButSpell := hh.AddButton('+notab x+5 y' . hFactor + 234, '&Spell')).OnEvent("Click", hhButtonSpell)
(ButOpen := hh.AddButton('+notab x+5 y' . hFactor + 234, '&Open')).OnEvent("Click", hhButtonOpen)
(ButCancel := hh.AddButton('+notab x+5 y' . hFactor + 234, '&Cancel')).OnEvent("Click", hhButtonCancel)

#h::   ; HotString Helper activation hotkey-combo (not string) is Win+h. Change if desired.
{ MyDefaultOpts := ""
	DefaultHotStr := ""
	Global myPrefix := ""
	Global mySuffix := ""
	Global ClipboardOld := ClipboardAll() ; Save and put back later.
	A_Clipboard := ""  ; Must start off blank for detection to work.
	Send("^c") ; Copy selected text.
	Errorlevel := !ClipWait(0.3) ; Wait for clipboard to contain text.
	If !InStr(A_Clipboard, "`n") ; Only trim NON multi line text strings.
		A_Clipboard := Trim(A_Clipboard) ; Because MS Word keeps leaving spaces.

	; If white space present in selected text, probably not an Autocorrect entry.
	If (InStr(A_Clipboard, " ") || InStr(A_Clipboard, "`n"))
	{
		;=======Change=options=for=MULTI=word=entry=options=and=trigger=strings=as=desired==============
		MyDefaultOpts := ""    ; PreEnter these multi-word hotstring options; "*" = end char not needed, etc.
		myPrefix := ";"        ; Optional character that you want suggested at the beginning of each hotstring.
		addFirstLetters := 5   ; Add first letter of this many words. (5 recommended; 0 = don't use feature.)
		tooSmallLen := 2      ; Only first letters from words longer than this. (Moot if addFirstLetters = 0)
		mySuffix := ""         ; An empty string "" means don't use feature.
		;===========================================================one=more=below=======================
		If (addFirstLetters > 0)
		{ LBLhotstring := "Edit trigger string as needed"
			initials := "" ; Initials will be the first letter of each word as a hotstring suggestion.
			HotStrSug := StrReplace(A_Clipboard, "`n", " ") ; Unwrap, but only for hotstr suggestion.
			Loop Parse, HotStrSug, A_Space
			{ If (Strlen(A_LoopField) > tooSmallLen) ; Check length of each word, ignore if N letters.
				initials := initials . SubStr(A_LoopField, ("1") < 1 ? ("1") - 1 : ("1"), "1")
				If (StrLen(initials) = addFirstLetters) ; stop looping if hotstring is N chars long.
					break
			}
			initials := StrLower(initials)
			DefaultHotStr := myPrefix . initials . mySuffix ; Append preferred prefix or suffix, as defined above, to initials.
		}
		else 
		{	LBLhotstring := "Add a trigger string"
			DefaultHotStr := myPrefix . mySuffix ; Use prefix and/or suffix as needed, but no initials.
		}
	}
	Else If (A_Clipboard = "")
		LBLhotstring := "Add a trigger string"
	else
	{ LBLhotstring := "Add misspelled word"
		DefaultHotStr := A_Clipboard ; No spaces found so assume it's a mispelling autocorrect entry: no pre/suffix.
		;===============Change=options=AUTOCORRECT=words=as=desired======================================
		myDefaultOpts := ""    ; PreEnter these (single-word) autocorrect options; "T" = raw text mode, etc.
		;================================================================================================
	}
	hh['MyDefaultOpts'].value := MyDefaultOpts
	hh['TrigStrLbl'].value := LBLhotstring
	hh['DefHotStr'].value := DefaultHotStr
	hh['RepStr'].value := A_Clipboard
	hh['RepStr'].Opt("-Readonly")
	ButApp.Enabled := true
	hh.Show('Autosize')
} ; bottom of hotkey function

TogSize(*)
{ If (hh['SizeTog'].text = "Make Bigger") {
	hh['SizeTog'].text := "Make Smaller"
	; ======Change=size=of=GUI=when="Make Bigger"=is=envoked========
	hFactor := 200 ; Height of Replacement box, Y pos of things below it.
	wFactor := 200 ; Width of 3 of the edit boxes.
	;===============================================================
	SubTogSize(hFactor, wFactor)
	hh.Show('Autosize Center')
	return
}
If (hh['SizeTog'].text = "Make Smaller") {
	hh['SizeTog'].text := "Make Bigger"
	SubTogSize(0, 0)
	hh.Show('Autosize')
	return
}
SubTogSize(hFactor, wFactor)
{
	DefHotStr.Move(, , wFactor + 250,)
	RepStr.Move(, , wFactor + 320, hFactor + 100)
	ComLbl.Move(, hFactor + 182, ,)

	; AsFunc := (hh.AddCheckbox('vAsFunc x+' wFactor + 79, "function"))

	AsFunc.Move(, hFactor + 182, ,)
	ComStr.move(, hFactor + 200, wFactor + 315,)
	ButApp.Move(, hFactor + 234, ,)
	ButVal.Move(, hFactor + 234, ,)
	ButSpell.Move(, hFactor + 234, ,)
	ButOpen.Move(, hFactor + 234, ,)
	ButCancel.Move(, hFactor + 234, ,)
}
}

TogSym(*)
{ ;====assign=symbolss=for="show symb"=button=================================
	myPilcrow := "¶"    ; Okay to change symb here if desired.
	myDot := "• "       ; adding a space allows more natural wrapping.
	myTab := " -> "
	;===========================================================================
	If (hh['SymTog'].text = "+ Symbols") {
		hh['SymTog'].text := "- Symbols"
		RepStr := hh['RepStr'].text
		RepStr := StrReplace(StrReplace(RepStr, "`r`n", "`n"), "`n", myPilcrow . "`n") ; Pilcrow for Enter
		RepStr := StrReplace(RepStr, A_Space, myDot) ; middle dot for Space
		RepStr := StrReplace(RepStr, A_Tab, myTab) ; space arrow space for Tab
		hh['RepStr'].value := RepStr
		hh['RepStr'].Opt("+Readonly")
		ButApp.Enabled := false
		hh.Show('Autosize')
		return
	}
	If (hh['SymTog'].text = "- Symbols") {
		hh['SymTog'].text := "+ Symbols"
		RepStr := hh['RepStr'].text
		RepStr := StrReplace(RepStr, myPilcrow . "`r", "`r") ; Have to use `r ... weird.
		RepStr := StrReplace(RepStr, myDot, A_Space)
		RepStr := StrReplace(RepStr, myTab, A_Tab)
		hh['RepStr'].value := RepStr
		hh['RepStr'].Opt("-Readonly")
		ButApp.Enabled := true
		hh.Show('Autosize')
		return
	}
}

#HotIf WinActive("Hotstring Helper -- Multi-Line") ; Allows window-specific hotkeys.
{
	$Enter:: ; When Enter is pressed, but only in this GUI. "$" prevents accidental Enter key loop.
	{ If (hh['SymTog'].text = "Hide Symb")
		return
		Else if RepStr.Focused {
			Send("{Enter}") ; Just normal typing; Enter yields Enter key press.
			Return
		}
		Else {
			hhButtonAppend() ; Replacement box not focused, so press Append button.
			return
		}
	}
	Esc::
	{ hh.Hide()
		A_Clipboard := ClipboardOld
	}
}
#HotIf ; Turn off window-specific behavior.

hhButtonAppend(*)
{ tMyDefaultOpts := hh['MyDefaultOpts'].text
	tDefHotStr := hh['DefHotStr'].text
	tRepStr := hh['RepStr'].text
	ValidationFunction(tMyDefaultOpts, tDefHotStr, tRepStr)
	If Not InStr(CombinedValidMsg, "-Okay.", , , 3)
	{    ; Msg doesn't have three occurrences of "-Okay."
		msgResult := MsgBox(CombinedValidMsg "`n`n####################`nContinue Anyway?", "VALIDATION", "OC 4096")
		if (msgResult = "OK") {
			Appendit(tMyDefaultOpts, tDefHotStr, tRepStr) ; not valid, but user chose to continue anyway
			return
		}
		else
			return ; not valid, and user cancelled
	}
	else { ; no validation problems found
		Appendit(tMyDefaultOpts, tDefHotStr, tRepStr)
		return
	}
}

hhButtonValidate(*)
{ tMyDefaultOpts := hh['MyDefaultOpts'].text
	tDefHotStr := hh['DefHotStr'].text
	tRepStr := hh['RepStr'].text
	ValidationFunction(tMyDefaultOpts, tDefHotStr, tRepStr)
	MsgBox("Validation Results`n#################`n" . CombinedValidMsg, , 4096)
	Return
}

ValidationFunction(tMyDefaultOpts, tDefHotStr, tRepStr)
{ Global CombinedValidMsg
	ThisFile := Fileread(A_ScriptName) ; Save these contents to variable 'ThisFile'.
	; ThisFile := Fileread("S:\AutoHotkey\MasterScript\MasterScript.ahk") ; <---- CHANGE later
	If (tMyDefaultOpts = "") ; If options box is empty, skip regxex check.
		validOpts := "Okay."
	else { ;===== Make sure hotstring options are valid ========
		NeedleRegEx := "(\*|B0|\?|SI|C|K[0-9]{1,3}|SE|X|SP|O|R|T)" ; These are in the AHK docs I swear!!!
		WithNeedlesRemoved := RegExReplace(tMyDefaultOpts, NeedleRegEx, "") ; Remove all valid options from var.

		If (WithNeedlesRemoved = "") ; If they were all removed...
			validOpts := "Okay."
		else { ; Some characters from the Options box were not recognized.
			OptTips := " ; Just a block text assignement to var
		(
	Don't include the colons.
	..from AHK v1 docs...
	* - ending char not needed
	? - trigger inside other words
	B0 - no backspacing
	SI - send input mode
	C - case-sensitive
	K(n) - set key delay
	SE - send event mode
	X - execute command
	SP - send play mode
	O - omit end char
	R - send raw
	T - super raw
		)"
	validOpts := "Invalid Hotsring Options found.`n---> " . WithNeedlesRemoved . "`n`n`tTips:`n" . OptTips
		}
	}
	;==== Make sure hotstring box content is valid ========
	validHot := "" ; Reset to empty each time.
	If (tDefHotStr = "") || (tDefHotStr = myPrefix) || (tDefHotStr = mySuffix) || InStr(tDefHotStr, ":")
		validHot := "HotString box should not be empty.`n-Don't include colons."
	else ; No colons, and not empty. Good. Now check for duplicates.
		Loop Parse, ThisFile, "`n", "`r" ; Check line-by-line.
			If instr(A_LoopField, ":" . tDefHotStr . "::") { ; If line contains tDefHotStr...
				validHot := "DUPLICATE FOUND`nAt Line " . A_Index . ":`n " . A_LoopField
				break
			}
	If (validHot = "") ; If variable didn't get set in loop, then no duplicates found
		validHot := "Okay."
	;==== Make sure replacement string box content is valid ===========
	If (tRepStr = "") || (SubStr(tRepStr, ("1") < 1 ? ("1") - 1 : ("1"), "1") == ":") ; If Replacement box empty, or first char is ":"
		validRep := "Replacement string box should not be empty.`n-Don't include the colons."
	else
		validRep := "Okay."
	; Concatenate the three above validity checks.
	CombinedValidMsg := "OPTIONS BOX `n-" . validOpts . "`n`nHOTSTRING BOX `n-" . validHot . "`n`nREPLACEMENT BOX `n-" . validRep
	Return CombinedValidMsg ; return result for use is Append or Validation functions.
} ; end of validation func

hhBoxAsFunction(*)
{	If (hh['AsFunc'].value = 1) 
		hh['MyDefaultOpts'].value := "XB0" hh['MyDefaultOpts'].value
	else
		hh['MyDefaultOpts'].value := StrReplace(hh['MyDefaultOpts'].value, "XB0", "")
}

Appendit(tMyDefaultOpts, tDefHotStr, tRepStr)
{ WholeStr := ""
	tMyDefaultOpts := hh['MyDefaultOpts'].text
	tDefHotStr := hh['DefHotStr'].text
	tRepStr := hh['RepStr'].text
	tComStr := hh['ComStr'].text
	If (tComStr != "")
		tComStr := " `; " . tComStr

	If (hh['AsFunc'].value = 0) {  ; Make into f(unction) box unchecked, so make normal hotstring.
		If InStr(tRepStr, "`n")
			WholeStr := ":" . tMyDefaultOpts . ":" . tDefHotStr . "::" . tComStr . "`n(`n" . tRepStr . "`n)"
		Else
			WholeStr := ":" . tMyDefaultOpts . ":" . tDefHotStr . "::" . tRepStr . tComStr
	}
	Else { ; Make into f(unction) box checked, so format like function.
		If InStr(tRepStr, "`n")
			WholeStr := ':' tMyDefaultOpts . ':' . tDefHotStr . '::f(" ' . tComStr . '`n(`n' . tRepStr . '`n)", A_ThisHotkey, A_EndChar)'
		Else
			WholeStr := ':' tMyDefaultOpts ':' tDefHotStr '::f("' tRepStr '", A_ThisHotkey, A_EndChar)' tComStr
	}

	FileAppend("`n" WholeStr, A_ScriptFullPath) ; 'n makes sure it goes on a new line.
	Reload() ; relaod the script so the new hotstring will be ready for use.
}  ; Newly added hotstrings will be way at the bottom.

hhButtonSpell(*) ; Called is "Spell" because "Spell Check" is too long.
{ tRepStr := hh['RepStr'].text
	If (tRepStr = "")
		MsgBox("Replacement Text not found.", , 4096)
	else {
		googleSugg := GoogleAutoCorrect(tRepStr) ; Calls below function
		If (googleSugg = "")
			MsgBox("No suggestions found.", , 4096)
		Else {
			msgResult := MsgBox(googleSugg "`n`n######################`nChange Replacement Text?", "Google Suggestion", "OC 4096")
			if (msgResult = "OK")
				hh['RepStr'].value := googleSugg
			else
				return
		}
	}
}

GoogleAutoCorrect(word)
{ 	; Original by TheDewd, converted to v2 by Mikeyww.
	; autohotkey.com/boards/viewtopic.php?f=82&t=120143
	objReq := ComObject('WinHttp.WinHttpRequest.5.1')
	objReq.Open('GET', 'https://www.google.com/search?q=' word)
	objReq.SetRequestHeader('User-Agent'
		, 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)')
	objReq.Send(), HTML := objReq.ResponseText
	If RegExMatch(HTML, 'value="(.*?)"', &A)
		If RegExMatch(HTML, ';spell=1.*?>(.*?)<\/a>', &B)
			Return B[1] || A[1]
}

hhButtonOpen(*)
{  	; Open this file and go to the bottom so you can see your Hotstrings.
	hh.Hide()
	A_Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
	Edit()
	WinWaitActive(A_ScriptName) ; Wait for the script to be open in text editor.
	Sleep(250)
	Send("{Ctrl Down}{End}{Ctrl Up}{Home}") ; Navigate to the bottom.
}

hhButtonCancel(*)
{ hh.Hide()
	A_Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
}


;==============================


; ...................QQQQQ........................QQQQ.........................................
; ...................QQQQQQ.......................QQQQ.........................................
; ..................QQQQQQQ.......................QQQQ.........................................
; ..................QQQQQQQQ......................QQQQ.........................................
; ..................QQQQQQQQ......................QQQQ.........................................
; .................QQQQQQQQQQ.....QQQQ.....QQQQ.QQQQQQQQQ...QQQQQQQQ...........................
; .................QQQQQQQQQQ.....QQQQQ...QQQQQ.QQQQQQQQQ..QQQQQQQQQQQ.........................
; ................QQQQQ.QQQQQQ....QQQQQ...QQQQQ...QQQQ....QQQQQQ.QQQQQQ........................
; ................QQQQQ..QQQQQ....QQQQQ...QQQQQ...QQQQ....QQQQQ...QQQQQ........................
; ...............QQQQQQ..QQQQQ....QQQQQ...QQQQQ...QQQQ...QQQQQ.....QQQQQ.......................
; ...............QQQQQ....QQQQQ...QQQQQ...QQQQQ...QQQQ...QQQQQ.....QQQQQ......QQQQQQQQ.........
; ...............QQQQQQQQQQQQQQ...QQQQQ...QQQQQ...QQQQ...QQQQQ.....QQQQQ......QQQQQQQQ.........
; ..............QQQQQQQQQQQQQQQQ..QQQQQ...QQQQQ...QQQQ...QQQQQ.....QQQQQ......QQQQQQQQ.........
; ..............QQQQQ......QQQQQ..QQQQQ...QQQQQ...QQQQ...QQQQQ.....QQQQQ.......................
; .............QQQQQ.......QQQQQ..QQQQQ...QQQQQ...QQQQ....QQQQQ...QQQQQ........................
; .............QQQQQ........QQQQQ.QQQQQQ.QQQQQQ...QQQQQQQ.QQQQQQ.QQQQQQ........................
; .............QQQQQ........QQQQQ.QQQQQQQQQQQQQ...QQQQQQQQ.QQQQQQQQQQQ.........................
; ....QQQQQQQQ.QQQQ..........QQQ...QQQQQQQQQQQQ....QQQQQQQ..QQQQQQQQQ...................QQQQ...
; ..QQQQQQQQQQQQ........................................................................QQQQ...
; .QQQQQQQQQQQQQQ.......................................................................QQQQ...
; QQQQQQQ..QQQQQQ.......................................................................QQQQ...
; QQQQQ.....QQQQQQ......................................................................QQQQ...
; QQQQQ......QQQQQ....QQQQQQQQ.....QQQQQQQQQQ.QQQQQQQQQQ....QQQQQQQQ.......QQQQQQQQ...QQQQQQQQQ
; QQQQ........QQQ....QQQQQQQQQQQ...QQQQQQQQQQQQQQQQQQQQQQ.QQQQQQQQQQQ....QQQQQQQQQQQ..QQQQQQQQQ
; QQQQ..............QQQQQQ.QQQQQQ..QQQQQQQQQQQQQQQQQQQQQQQQQQQQ.QQQQQQ...QQQQQ.QQQQQQ...QQQQ...
; QQQQ..............QQQQQ...QQQQQ..QQQQQQ.QQQ.QQQQQQ.QQQ.QQQQQ...QQQQQ..QQQQQ....QQQQ...QQQQ...
; QQQQ.............QQQQQ.....QQQQQ.QQQQQ......QQQQQ......QQQQ.....QQQQ..QQQQ.....QQQQ...QQQQ...
; QQQQ........QQQ..QQQQQ.....QQQQQ.QQQQQ......QQQQQ.....QQQQQQQQQQQQQQQQQQQQ............QQQQ...
; QQQQ........QQQQ.QQQQQ.....QQQQQ.QQQQQ......QQQQQ.....QQQQQQQQQQQQQQ.QQQQQ............QQQQ...
; QQQQ.......QQQQQ.QQQQQ.....QQQQQ.QQQQQ......QQQQQ.....QQQQQ..........QQQQQ.......Q....QQQQ...
; QQQQQ.....QQQQQQ.QQQQQ.....QQQQQ.QQQQQ......QQQQQ......QQQQ......QQQ..QQQQ.....QQQQ...QQQQ...
; QQQQQQQ..QQQQQQ...QQQQQ...QQQQQ..QQQQQ......QQQQQ......QQQQQ....QQQQ..QQQQQ....QQQQ...QQQQ...
; .QQQQQQQQQQQQQQ...QQQQQQ.QQQQQQ..QQQQQ......QQQQQ......QQQQQQ..QQQQQ..QQQQQQ.QQQQQQ...QQQQQQQ
; ..QQQQQQQQQQQQ.....QQQQQQQQQQQ...QQQQQ......QQQQQ.......QQQQQQQQQQQ....QQQQQQQQQQQ....QQQQQQQ
;~ AutoCorrects -- Table of ContentsQQQ.......QQQQ..........QQQQQQQQ.......QQQQQQQQ......QQQQQQ
;~ f(unction) definition with constant logger
;~ On-Backspace Logger
;~ Fix-counter
;~ Replacement nullifiers
;~ ==Word Parts===
; :*: - Word Beginnings
; :*?C: - Word Middles w/Case Sensitive
; :*C: - Word Beginnings w/Case Sensitive
; :: - Single-match
; :*?: - Word Middles 
; :?: - Word Endings
; :?C: - Word Endings w/Case Sensitive
; :C: - Single-match w/Case Sensitive
;~ -Multi-fix items are commented with " ; Fixes N misspellings"
;~ -warning: several items break obscure words.  These are commented with " ; Misspells xxx" with an explanation.
;~ -as of 10-6-2023, ~5097 items, >300k potential fixes. 
;~ ================
;~ Accented non English Items (with definitions)
;~ Capatalize Dates
;~ School Psych Items
;~ Recently Added Items
;########################################################################################

lastTrigger := "none yet" ; incase no autocorrects have been made
!+F3:: MsgBox(lastTrigger, "Trigger", 0) ; Peek at last trigger. 
!+l:: Run("LogOfErrors.ahk") ; View log of corrections that prompted backspacing. 
!^l:: Run("allTriggersLogged.ahk") ; View log of all autocorrections. 

; Mikeyww's idea to use a one-line function call. Cool.
; www.autohotkey.com/boards/viewtopic.php?f=76&t=120745
f(replace := "", trigger := "", endchar := "") ; All the one-line autocorrects call this f(unction).
{	A_Clipboard := ""
	Global lastTrigger := StrReplace(trigger, "XB0", "") "::" replace ; set 'lastTrigger' before removing options and colons.
	trigger := SubStr(trigger, inStr(trigger, ":",,,2)+1) ; use everything to right of 2nd colon. 
	TrigLen := StrLen(trigger) + StrLen(endchar) ; determine number of backspaces needed.
 	
	; Only select and replace rightmost necessary chars.  
	trigL := StrSplit(trigger)
	replL := StrSplit(replace)
	Global ignorLen := 0
	Loop Min(trigL.Length, replL.Length) ; find matching left substring.
	{	If (trigL[A_Index] = replL[A_Index])
			ignorLen++
		else
			break
	}

	; select trigger that was just typed and get trigger text
	SendInput("{Shift down}{Left " (TrigLen - ignorLen) "}{Shift up}{Ctrl down}x{Ctrl up}") 

	ClipWait(1)
	replace := SubStr(replace, (ignorLen+1))
	If IsUpper(SubStr(A_Clipboard,1,1)) ; assess leftmost char
		replace := StrUpper(SubStr(replace,1,1)) SubStr(replace,2) ; make sentence case
	SendInput(replace endchar) ; Type replacemement and endchar. 
		
	FileAppend(A_MM A_DD " -- " lastTrigger . "`n", "allTriggersLogged.ahk") ; Logs all autocorrects. 
	Global IsRecent := 1 ; Set IsRecent, then change back in x second(s).
	setTimer TriggerRecency, -2000 ; run only once, in x second(s). 
	replace := "" ; Reset to blank string.
	SoundBeep(900, 60) ; Notification of replacement.
	;SoundBeep(1000, 40)
}

TriggerRecency() ; Gets called by above x-second timer. 
{	Global IsRecent := 0 ; no longer recent
}

Global IsRecent := 0 ; Start blank
OnBSLogger() ; Run at script startup.
OnBSLogger() ; Automatically logs if an autocorrect happens, then I press Backspace within one second. 
{ 	WordArr := []
	EndKeys := "{Space}{Backspace}{Tab}{Enter}"
	lih := InputHook("B V I1 E", EndKeys) ; "logger input hook"
	Loop
	{	lih.Start(), lih.Wait()
		If !RegExMatch(lih.Input, "\d") ; Don't record strings with numbers.
		{ ; Exclude digits to avoid logging passwords and bank numbers. LOL.
			WordArr.Push(lih.Input "{" lih.EndKey "}")
			; ToolTip(lih.Input " & " lih.EndKey)
			If (WordArr.Length > 7) ; Use bigger number to capture more context.
				WordArr.RemoveAt(1)
			If (lih.EndKey = "Backspace" && IsRecent = 1) {
				For Idx, wArr in WordArr {
					LogEntry .= WordArr[Idx]
				}
				LogEntry := StrReplace(LogEntry, "{Space}", "{-}")
				LogEntry := StrReplace(LogEntry, "{Backspace}", "{<-}")
				LogEntry := StrReplace(LogEntry, "{Enter}", "{e}")
				SoundBeep(900, 333)
				WinStamp := StrSplit(WinGetTitle("A"), " - ") ; Only use text on right of hyphen.  Too long otherwise...
				Stamp := "On: " A_MM "-" A_DD "-" A_YYYY "; In: "  WinStamp[2] ; Change date order according to locale.
				FileAppend("`n`n" Stamp "`n-last typing----> " LogEntry "`n-last replace---> " lastTrigger, "LogOfErrors.ahk")
				Sleep(100)
			}
		}
	}
}

;###############################################
^F3:: ; How many potential word fixes are there in the autocorrect items?
{	list := FileRead(A_ScriptFullPath)
	sum := 0
	Loop Parse list, '`n' ; mikeyww wrote this too.  
		If RegExMatch(A_LoopField, 'Fixes\h*\K\d+', &n)
			sum += n[]
	MsgBox sum, 'Sum', 64
}
;###############################################


; Example improvements
;	:*:hwi::whi ; Fix 310 words
;	:?C:hc::ch ; Fix 446 words ; :C: so not to break THC or LHC
; vs ::hwihc::which


; Trigger strings to nullify the potential misspellings that are indicated. 
:B0:Savitr:: ; (Important Hindu god) Here for :?:itr::it, which corrects 366 words.
:B0:Vaisyas:: ; (A member of the mercantile and professional Hindu caste.) Here for :?:syas::says, which corrects 12 words.
:B0:Wheatley:: ; (a fictional artificial intelligence from the Portal franchise) Here for :?:atley::ately, which corrects 162 words.
:B0:arraign:: ; Here for :?:ign::ing, which corrects 11384 words. (This is from the 2007 AutoCorrect script.)
:B0:bialy:: ; (Flat crusty-bottomed onion roll) Here for :?:ialy::ially, which corrects 244 words.
:B0:callsign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:champaign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:coign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:condign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:consign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:coreign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:cosign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:countersign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:deign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:deraign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:eloign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:ensign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:feign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:indign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:kc:: ; (thousand per second). Here for :?:kc::ck, which corrects 610 words.
:B0:malign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:miliary:: ; Here for :?:miliary::military, which corrects 4 words.
:B0:minyanim:: ; (The quorum required by Jewish law to be present for public worship) Here for :?:anim::anism, which corrects 123 words.
:B0:pfennig:: ; (100 pfennigs formerly equaled 1 DeutscheÂ Mark in Germany). Here for :?:nig::ing, which corrects 11414 words.
:B0:reign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:sice:: ; (The number six at dice) Here for :?:sice::sive, which corrects 166 words.
:B0:sign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:verisign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:align:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:assign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:benign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:campaign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:design:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:foreign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:resign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:sovereign:: ; Here for :?:ign::ing, which corrects 11384 words.
/*
Unfortunately, it doesn't work if other the multi-fix item has :*: in the options.  So these can't be nullified.  
If you hope to ever type any of these words, locate the corresponding autocorrect item and delete it. 
:B0:Ahvenanmaa:: ; also :Jahvey:, :Wahvey:, :Yahve:, :Yahveh: (Hebrew names for God.) Here for :?*:ahve::have, which corrects 47 words.
:B0:Basra:: ; (An oil city in Iraq) Here for :?*:asr::ase, which corrects 698 words.
:B0:Datapoint:: ; For username Datapoint. Here for :?*:apoint::appoint, which corrects 30 words.
:B0:Dennstaedtia:: ; (fern), Hoffmannsthal, (poet) Here for :?*:nnst::nst, which corrects 729 words.
:B0:Gadiformes:: ; (Cods, haddocks, grenadiers) Here for :?*:adif::atif, which corrects 50 words.
:B0:Illecebrum:: ; (Species of plan in Europe) Here for :?*:lece::lesce, which corrects 52 words.
:B0:Mephitinae:: ; (skunk), also :neritina: (snail) Here for :?*:itina::itiona, which corrects 79 words.
:B0:Minkowski:: ; (German mathematician) Here for :?*:nkow::know, which corrects 66 words.
:B0:Mulloidichthys:: ; a genus of Mullidae. Here for :*:dicht::dichot, which corrects 18 words.
:B0:Ondaatje:: ; (Canadian writer) Here for :?*:tje::the, which corrects 2176 words.
:B0:Phalangiidae:: ; (type of Huntsman spider) Here for :?*:giid::good, which corrects 31 words.
:B0:Prosecco:: ; (Italian wine) and recco (abbrev. for Reconnaissance) Here for :?*:ecco::eco, which corrects 994 words.
:B0:Pycnanthemum:: ; (mint), and Tridacna (giant clam).+ Here for :?*:cna::can, which corrects 1019 words.
:B0:Scincella:: ; (A reptile genus of Scincidae) Here for :?*:scince::science, which corrects 25 words.
:B0:Scirpus:: ; (Rhizomatous perennial grasslike herbs) Here for :?*:cirp::crip, which corrects 126 words.
:B0:Taoiseach:: ; (The prime minister of the Irish Republic) Here for :?*:seach::search, which corrects 25 words.
:B0:accroides:: ; (An alcohol-soluble resin) Here for :?*:accro::acro, which corrects 145 words.
:B0:ammeter:: ; (electrician's tool). Here for :*:amme::ame, which corrects 341 words.
:B0:braaivleis:: ; (Type of S. Affrican BBQ) Here for :?*:ivle::ivel, which corrects 589 words.
:B0:brodiaea:: ; (a type of plant) Here for :?*:brod::broad, which corrects 55 words.
:B0:ceviche:: ; (South American seafood dish) Here for :?*:cev::ceiv, which corrects 82 words.
:B0:darshan:: ; ((Hinduism - being in the presence of the divine or holy person or image) Here for :?*:rshan::rtion, which corrects 84 words.
:B0:emcee:: ; (host at formal occasion) Here for :?*:emce::ence, which corrects 775 words.
:B0:gaol:: ; British spelling of jail Here for :*:gaol::goal, which corrects 22 words.
:B0:grama:: ; (Pasture grass of plains of South America and western North America) Here for :?*:grama::gramma, which corrects 72 words.
:B0:indite:: ; (Produce a literaryÂ work) Here for :?*:indite::indict, which corrects 22 words.
:B0:itraconazole:: ; (Antifungal drug). Here for :*:itr::it, which corrects 101 words.
:B0:lisente:: ; (100 lisente equal 1 loti in Lesotho, S. Afterica) Here for :?*:lisen::licen, which corrects 34 words.
:B0:pemphigous:: ; (a skin disease) Here for :?*:igous::igious, which corrects 23 words.
:B0:seviche:: ; (South American dish of raw fish) Here for :?*:sevic::servic, which corrects 25 words.
:B0:spritual:: ; (A light spar that crosses a fore-and-aft sail diagonally) Here for :?*:spritual::spiritual, which corrects 31 words.
:B0:spycatcher:: ; (secret spy stuff) Here for :?*:spyc::psyc, which corrects 192 words.
:B0:unfeasable:: ; (archaic, no longer used) Here for :?*:feasable::feasible, which corrects 11 words.
:B0:vicomte:: ; (French nobleman) Here for :?*C:comt::cont, which corrects 587 words.
*/
{	return  ; This makes the above hotstrings do nothing so that they override the indicated rules below.
}
:*:pinon::piñon  ; noun any of several low-growing pines of western North America (must be above ":?*:pinon::pion ; Corrects 44 words")

#Hotstring Z ; The Z causes the end char to be reset after each activation. 

:XB0*:Buddist::f("Buddhist", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:Hatian::f("Haitian", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:Naploeon::f("Napoleon", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:Napolean::f("Napoleon", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:Pennyslvania::f("Pennsylvania", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:Queenland::f("Queensland", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:a ab::f("an ab", A_ThisHotkey, A_EndChar)
:XB0*:a ac::f("an ac", A_ThisHotkey, A_EndChar)
:XB0*:a ad::f("an ad", A_ThisHotkey, A_EndChar)
:XB0*:a af::f("an af", A_ThisHotkey, A_EndChar)
:XB0*:a ag::f("an ag", A_ThisHotkey, A_EndChar)
:XB0*:a al::f("an al", A_ThisHotkey, A_EndChar)
:XB0*:a am::f("an am", A_ThisHotkey, A_EndChar)
:XB0*:a an::f("an an", A_ThisHotkey, A_EndChar)
:XB0*:a ap::f("an ap", A_ThisHotkey, A_EndChar)
:XB0*:a as::f("an as", A_ThisHotkey, A_EndChar)
:XB0*:a av::f("an av", A_ThisHotkey, A_EndChar)
:XB0*:a aw::f("an aw", A_ThisHotkey, A_EndChar)
:XB0*:a ea::f("an ea", A_ThisHotkey, A_EndChar)
:XB0*:a ef::f("an ef", A_ThisHotkey, A_EndChar)
:XB0*:a ei::f("an ei", A_ThisHotkey, A_EndChar)
:XB0*:a el::f("an el", A_ThisHotkey, A_EndChar)
:XB0*:a em::f("an em", A_ThisHotkey, A_EndChar)
:XB0*:a en::f("an en", A_ThisHotkey, A_EndChar)
:XB0*:a ep::f("an ep", A_ThisHotkey, A_EndChar)
:XB0*:a eq::f("an eq", A_ThisHotkey, A_EndChar)
:XB0*:a es::f("an es", A_ThisHotkey, A_EndChar)
:XB0*:a et::f("an et", A_ThisHotkey, A_EndChar)
:XB0*:a ex::f("an ex", A_ThisHotkey, A_EndChar)
:XB0*:a ic::f("an ic", A_ThisHotkey, A_EndChar)
:XB0*:a id::f("an id", A_ThisHotkey, A_EndChar)
:XB0*:a ig::f("an ig", A_ThisHotkey, A_EndChar)
:XB0*:a il::f("an il", A_ThisHotkey, A_EndChar)
:XB0*:a im::f("an im", A_ThisHotkey, A_EndChar)
:XB0*:a in::f("an in", A_ThisHotkey, A_EndChar)
:XB0*:a ir::f("an ir", A_ThisHotkey, A_EndChar)
:XB0*:a is::f("an is", A_ThisHotkey, A_EndChar)
:XB0*:a oa::f("an oa", A_ThisHotkey, A_EndChar)
:XB0*:a ob::f("an ob", A_ThisHotkey, A_EndChar)
:XB0*:a oi::f("an oi", A_ThisHotkey, A_EndChar)
:XB0*:a ol::f("an ol", A_ThisHotkey, A_EndChar)
:XB0*:a op::f("an op", A_ThisHotkey, A_EndChar)
:XB0*:a or::f("an or", A_ThisHotkey, A_EndChar)
:XB0*:a os::f("an os", A_ThisHotkey, A_EndChar)
:XB0*:a ot::f("an ot", A_ThisHotkey, A_EndChar)
:XB0*:a ou::f("an ou", A_ThisHotkey, A_EndChar)
:XB0*:a ov::f("an ov", A_ThisHotkey, A_EndChar)
:XB0*:a ow::f("an ow", A_ThisHotkey, A_EndChar)
:XB0*:a ud::f("an ud", A_ThisHotkey, A_EndChar)
:XB0*:a ug::f("an ug", A_ThisHotkey, A_EndChar)
:XB0*:a ul::f("an ul", A_ThisHotkey, A_EndChar)
:XB0*:a um::f("an um", A_ThisHotkey, A_EndChar)
:XB0*:a un::f("an un", A_ThisHotkey, A_EndChar)
:XB0*:a up::f("an up", A_ThisHotkey, A_EndChar)
:XB0*:abandonned::f("abandoned", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:abcense::f("absence", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:abera::f("aberra", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:abondon::f("abandon", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:abreviat::f("abbreviat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:absail::f("abseil", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:abscen::f("absen", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:absense::f("absence", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:acclimit::f("acclimat", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:accomd::f("accommod", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:accordeon::f("accordion", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:accordian::f("accordion", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:achei::f("achie", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:achiv::f("achiev", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:aciden::f("acciden", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:ackward::f("awkward", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:acord::f("accord", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:acquite::f("acquitte", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:acuse::f("accuse", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:adbandon::f("abandon", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:adhear::f("adher", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:adheran::f("adheren", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:adresa::f("addressa", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:adress::f("address", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:adves::f("advers", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:afair::f("affair", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:afficianado::f("aficionado", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:afficionado::f("aficionado", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:agani::f("again", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:aggregious::f("egregious", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:agian::f("again", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:agina::f("again", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:agriev::f("aggriev", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:aiport::f("airport", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:aledg::f("alleg", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0*:alege::f("allege", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:alegien::f("allegian", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:algebraical::f("algebraic", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:alientat::f("alienat", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:alledg::f("alleg", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0*:allivia::f("allevia", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:allopon::f("allophon", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:alse::f("else", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:alterior::f("ulterior", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:alternit::f("alternat", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:alusi::f("allusi", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:amalgom::f("amalgam", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:amature::f("amateur", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:amme::f("ame", A_ThisHotkey, A_EndChar) ; Fixes 341 words, Misspells ammeter (electrician's tool).
:XB0*:ammuse::f("amuse", A_ThisHotkey, A_EndChar) ; Fixes 6 words.
:XB0*:amoung::f("among", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:amung::f("among", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:amunition::f("ammunition", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:an large::f("a large", A_ThisHotkey, A_EndChar) 
:XB0*:analag::f("analog", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0*:anarchim::f("anarchism", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:andd::f("and", A_ThisHotkey, A_EndChar) ; Fixes 73 words
:XB0*:androgenous::f("androgynous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:anih::f("annih", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:aniv::f("anniv", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:anonim::f("anonym", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*:anoyance::f("annoyance", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:ansal::f("nasal", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0*:ansest::f("ancest", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:antartic::f("antarctic", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:anthrom::f("anthropom", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0*:anual::f("annual", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:anul::f("annul", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:aproxim::f("approxim", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:aquaduct::f("aqueduct", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:aquir::f("acquir", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:arbouret::f("arboret", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:archiac::f("archaic", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:archtyp::f("archetyp", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:areod::f("aerod", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:ariv::f("arriv", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:armistace::f("armistice", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:arogan::f("arrogan", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:arren::f("arran", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:arrou::f("arou", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:artc::f("artic", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0*:artical::f("article", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:artifical::f("artificial", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:artillar::f("artiller", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:asetic::f("ascetic", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:asphyxa::f("asphyxia", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:assasin::f("assassin", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:assesment::f("assessment", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:asside::f("aside", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:assisnat::f("assassinat", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:assistent::f("assistant", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:assit::f("assist", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:assualt::f("assault", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:asum::f("assum", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*:athenean::f("Athenian", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:atn::f("ant", A_ThisHotkey, A_EndChar) ; Fixes 704 words
:XB0*:atorne::f("attorne", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:attourne::f("attorne", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:attroci::f("atroci", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:auromat::f("automat", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0*:austrailia::f("Australia", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:authorative::f("authoritative", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:authoritive::f("authoritative", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:autochtonous::f("autochthonous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:autocton::f("autochthon", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:autorit::f("authorit", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:autsim::f("autism", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:auxilar::f("auxiliar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:auxillar::f("auxiliar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:auxilliar::f("auxiliar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:avalance::f("avalanche", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:avati::f("aviati", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:averagee::f("average", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:aywa::f("away", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:bananna::f("banana", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:bandonn::f("abandon", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:bandwith::f("bandwidth", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:bankrupc::f("bankruptc", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:banrupt::f("bankrupt", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:barb wire::f("barbed wire", A_ThisHotkey, A_EndChar)  ; Fixes 2 words
:XB0*:beachead::f("beachhead", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:beastia::f("bestia", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:begginer::f("beginner", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:beggining::f("beginning", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:begining::f("beginning", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:bellweather::f("bellwether", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:bergamont::f("bergamot", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:beseig::f("besieg", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:beteen::f("between", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:betwen::f("between", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:beut::f("beaut", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0*:beween::f("between", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:bewteen::f("between", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:bigining::f("beginning", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:biginning::f("beginning", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:billingual::f("bilingual", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:bizzare::f("bizarre", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:blaim::f("blame", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:blitzkreig::f("Blitzkrieg", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:bodydbuilder::f("bodybuilder", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:boyan::f("buoyan", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:brasillian::f("Brazilian", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:breakthough::f("breakthrough", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:brillan::f("brillian", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:brocolli::f("broccoli", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:buddah::f("Buddha", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:buoan::f("buoyan", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:bve::f("be", A_ThisHotkey, A_EndChar) ; Fixes 1565 words
:XB0*:cacus::f("caucus", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:calaber::f("caliber", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:calander::f("calendar", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:calender::f("calendar", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:califronia::f("California", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:caligra::f("calligra", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:cambrige::f("Cambridge", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:camoflag::f("camouflag", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:candidiat::f("candidat", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:cannota::f("connota", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:cansel::f("cancel", A_ThisHotkey, A_EndChar) ; Fixes 21 words ; Added be Steve
:XB0*:cantalop::f("cantaloup", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:carniver::f("carnivor", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:carree::f("caree", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:carrib::f("Carib", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:carthogr::f("cartogr", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:casion::f("caisson", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:cassawor::f("cassowar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:cassowarr::f("cassowar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:casulat::f("casualt", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:catapillar::f("caterpillar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:catapiller::f("caterpillar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:catepillar::f("caterpillar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:caterpilar::f("caterpillar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:caterpiller::f("caterpillar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:catterpilar::f("caterpillar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:catterpillar::f("caterpillar", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:caucasion::f("Caucasian", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:ceasa::f("Caesa", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:cemetar::f("cemeter", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:champang::f("champagn", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:chauffer::f("chauffeur", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:choclat::f("chocolat", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:chuch::f("church", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0*:ciel::f("ceil", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:cilind::f("cylind", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:cirtu::f("citru", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:colate::f("collate", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*:colea::f("collea", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:collaber::f("collabor", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:collos::f("coloss", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:comande::f("commande", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:comando::f("commando", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:comback::f("comeback", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:comdem::f("condem", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:commadn::f("command", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:commemerat::f("commemorat", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:commerorat::f("commemorat", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:compair::f("compare", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:comparit::f("comparat", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:competion::f("competition", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:compona::f("compone", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:compulsar::f("compulsor", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:compulser::f("compulsor", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:concensu::f("consensu", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:conciet::f("conceit", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:condamn::f("condemn", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:condemm::f("condemn", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:conesencu::f("consensu", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:confidental::f("confidential", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:congradulat::f("congratulat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:coniv::f("conniv", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:conneticut::f("Connecticut", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:conot::f("connot", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:conquerer::f("conqueror", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:consorci::f("consorti", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:consulan::f("consultan", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:consulten::f("consultan", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:copy or report::f("copy of report", A_ThisHotkey, A_EndChar)
:XB0*:copy or signed::f("copy of signed", A_ThisHotkey, A_EndChar)
:XB0*:corosi::f("corrosi", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:correpond::f("correspond", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:corridoor::f("corridor", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:coucil::f("council", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:coudl::f("could", A_ThisHotkey, A_EndChar)
:XB0*:councellor::f("counselor", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:counr::f("countr", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:creeden::f("creden", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:creme::f("crème", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:critere::f("criteri", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:critiz::f("criticiz", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:crucifiction::f("crucifixion", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:culimi::f("culmi", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:curriculm::f("curriculum", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:cyclind::f("cylind", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:dacquiri::f("daiquiri", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:dael::f("deal", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0*:dakiri::f("daiquiri", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:dalmation::f("dalmatian", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:deafult::f("default", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:decathalon::f("decathlon", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:definan::f("defian", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:delapidat::f("dilapidat", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:deleri::f("deliri", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:derogit::f("derogat", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:descripter::f("descriptor", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:desease::f("disease", A_ThisHotkey, A_EndChar) ; Fixes 5 words.
:XB0*:desica::f("desicca", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:desinte::f("disinte", A_ThisHotkey, A_EndChar) ; Fixes 24 words.
:XB0*:desktiop::f("desktop", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:desorder::f("disorder", A_ThisHotkey, A_EndChar) ; Fixes 8 words.
:XB0*:desorient::f("disorient", A_ThisHotkey, A_EndChar) ; Fixes 10 words.
:XB0*:desparat::f("desperat", A_ThisHotkey, A_EndChar) ; Fixes 6 words.
:XB0*:dessicat::f("desiccat", A_ThisHotkey, A_EndChar) ; Fixes 9 words.
:XB0*:deteoriat::f("deteriorat", A_ThisHotkey, A_EndChar) ; Fixes 6 words.
:XB0*:deteriat::f("deteriorat", A_ThisHotkey, A_EndChar) ; Fixes 6 words.
:XB0*:deterioriat::f("deteriorat", A_ThisHotkey, A_EndChar) ; Fixes 6 words.
:XB0*:detrement::f("detriment", A_ThisHotkey, A_EndChar) ; Fixes 5 words.
:XB0*:devaste::f("devastate", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:devestat::f("devastat", A_ThisHotkey, A_EndChar) ; Fixes 9 words.
:XB0*:devistat::f("devastat", A_ThisHotkey, A_EndChar) ; Fixes 9 words.
:XB0*:diablic::f("diabolic", A_ThisHotkey, A_EndChar) ; Fixes 4 words.
:XB0*:diast::f("disast", A_ThisHotkey, A_EndChar) ; Fixes 5 words.
:XB0*:dicht::f("dichot", A_ThisHotkey, A_EndChar) ; Fixes 18 words.  Misspells "Mulloidichthys" a genus of Mullidae (goatfishes or red mullets).
:XB0*:diconnect::f("disconnect", A_ThisHotkey, A_EndChar) ; Fixes 9 words.
:XB0*:diffcult::f("difficult", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:dificult::f("difficult", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:diminuit::f("diminut", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:dimunit::f("diminut", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:diphtong::f("diphthong", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:diplomanc::f("diplomac", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:diptheria::f("diphtheria", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:dipthong::f("diphthong", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:disasterous::f("disastrous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:disatisf::f("dissatisf", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:disatrous::f("disastrous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:diseminat::f("disseminat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:dispair::f("despair", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:dispele::f("dispelle", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:dispicab::f("despicab", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:dispite::f("despite", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:disproportiate::f("disproportionate", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:dissag::f("disag", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:dissap::f("disap", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0*:dissar::f("disar", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0*:dissob::f("disob", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:divinition::f("divination", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:double header::f("doubleheader", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:draughtm::f("draughtsm", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:elphant::f("elephant", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:embezell::f("embezzl", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:emblamatic::f("emblematic", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:emial::f("email", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:eminat::f("emanat", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:emite::f("emitte", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:emn::f("enm", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:emphysyma::f("emphysema", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:empirial::f("imperial", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:emporer::f("emperor", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:enb::f("eng", A_ThisHotkey, A_EndChar) ; Fixes 103 words, but misspells Enbrel (Trade name for a genetically engineered anti-TNF compound for treating  rheumatoid arthritis). 
:XB0*:enchanc::f("enhanc", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:encylop::f("encyclop", A_ThisHotkey, A_EndChar) ; Fixes 16 word
:XB0*:endevors::f("endeavors", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:endolithe::f("endolith", A_ThisHotkey, A_EndChar) ; Fixes 2 words (which are not in WordWeb)
:XB0*:ened::f("need", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0*:english::f("English", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:enlargment::f("enlargement", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:enlish::f("English", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:enourmous::f("enormous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:enscons::f("ensconc", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:enteratin::f("entertain", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:entrepeneur::f("entrepreneur", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:enviorment::f("environment", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:enviorn::f("environ", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:envirom::f("environm", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:envrion::f("environ", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:epidsod::f("episod", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:epsiod::f("episod", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:equitor::f("equator", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:eral::f("real", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0*:eratic::f("erratic", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:erest::f("arrest", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:errupt::f("erupt", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:escta::f("ecsta", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:esle::f("else", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:europian::f("European", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:eurpean::f("European", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:eurpoean::f("European", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:evenhtual::f("eventual", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:evental::f("eventual", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:evential::f("eventual", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:excede::f("exceed", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:excelen::f("excellen", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:excellan::f("excellen", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:exection::f("execution", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:exelen::f("excellen", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:exellen::f("excellen", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:exerbat::f("exacerbat", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:exerpt::f("excerpt", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:exerternal::f("external", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:exhalt::f("exalt", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:exhibt::f("exhibit", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0*:exibit::f("exhibit", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0*:exilera::f("exhilara", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:exlud::f("exclud", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:exonorat::f("exonerat", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:expeiment::f("experiment", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:explainat::f("explanat", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:expropiat::f("expropriat", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:exteme::f("extreme", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:extraterrestial::f("extraterrestrial", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:extravagent::f("extravagant", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:extrordinar::f("extraordinar", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:eyar::f("year", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:faciliat::f("facilitat", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:facillitat::f("facilitat", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:facinat::f("fascinat", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:faetur::f("featur", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:fleed::f("freed", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:forhe::f("forehe", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:fortell::f("foretell", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:foundar::f("foundr", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:fouth::f("fourth", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:fransiscan::f("Franciscan", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:froniter::f("frontier", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:fued::f("feud", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0*:fuhrer::f("Führer", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:furner::f("funer", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:futhe::f("furthe", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:fwe::f("few", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:ganst::f("gangst", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:gaol::f("goal", A_ThisHotkey, A_EndChar) ; Fixes 22 words ; Misspells British spelling of "jail"
:XB0*:gauren::f("guaran", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:geneolog::f("genealog", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:gerat::f("great", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:girat::f("gyrat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:gloabl::f("global", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:gnaww::f("gnaw", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:gouvener::f("governor", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:governer::f("governor", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:graet::f("great", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:grafitti::f("graffiti", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:gridle::f("griddle", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:guage::f("gauge", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:guerrila::f("guerrilla", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:guidlin::f("guidelin", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:gutteral::f("guttural", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:haemorrage::f("haemorrhage", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:halarious::f("hilarious", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:halp::f("help", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0*:hapen::f("happen", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:harasm::f("harassm", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:harassement::f("harassment", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:hda::f("had", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0*:headquarer::f("headquarter", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:headquater::f("headquarter", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:helment::f("helmet", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:hemmorhage::f("hemorrhage", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:hesista::f("hesita", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*:hge::f("he", A_ThisHotkey, A_EndChar) ; Fixes 1607 words
:XB0*:hieght::f("height", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:hlep::f("help", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0*:holliday::f("holiday", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:hosit::f("hoist", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:hsa::f("has", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0*:hte::f("the", A_ThisHotkey, A_EndChar) ; Fixes 402 words
:XB0*:hti::f("thi", A_ThisHotkey, A_EndChar) ; Fixes 186 words
:XB0*:hwi::f("whi", A_ThisHotkey, A_EndChar) ; Fixes 310 words
:XB0*:hwo::f("who", A_ThisHotkey, A_EndChar) ; Fixes 76 words
:XB0*:hygein::f("hygien", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:hyjack::f("hijack", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:iconclas::f("iconoclas", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:idae::f("idea", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0*:idealogi::f("ideologi", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:illegim::f("illegitim", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:illegitma::f("illegitima", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:illieg::f("illeg", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0*:ilog::f("illog", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:ilu::f("illu", A_ThisHotkey, A_EndChar) ; Fixes 61 words
:XB0*:iman::f("immin", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:imcom::f("incom", A_ThisHotkey, A_EndChar) ; Fixes 78 words
:XB0*:imigra::f("immigra", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:immida::f("immedia", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:immidia::f("immedia", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:immunosupress::f("immunosuppress", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:impecab::f("impecca", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:impressa::f("impresa", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:improvision::f("improvisation", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:inagura::f("inaugura", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:inate::f("innate", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:inaugure::f("inaugurate", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:inbalance::f("imbalance", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:incread::f("incred", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:indefineab::f("undefinab", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:independan::f("independen", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:indesp::f("indisp", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:indigine::f("indigen", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0*:inevatibl::f("inevitabl", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:inevitib::f("inevitab", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:inevititab::f("inevitab", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:inmigra::f("immigra", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:inocenc::f("innocenc", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:inofficial::f("unofficial", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:inot::f("into", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0*:inpen::f("impen", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:interelat::f("interrelat", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:intertain::f("entertain", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:intial::f("initial", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0*:intrument::f("instrument", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*:intrust::f("entrust", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:inumer::f("innumer", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:inventer::f("inventor", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:ireleven::f("irrelevan", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:iresistabl::f("irresistibl", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:iresistib::f("irresistib", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:iritab::f("irritab", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:iritat::f("irritat", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:itr::f("it", A_ThisHotkey, A_EndChar) ; Fixes 101 words, but misspells itraconazole (Antifungal drug). 
:XB0*:jeapard::f("jeopard", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:jouney::f("journey", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:lable::f("label", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:lasoo::f("lasso", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:lazer::f("laser", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:leage::f("league", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:lefr::f("left", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:leran::f("learn", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:leutenan::f("lieutenan", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:levle::f("level", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0*:lias::f("liais", A_ThisHotkey, A_EndChar) ; Fixes 6 words, Case-sensitive to not misspell Lias (One of the Jurrasic periods.)
:XB0*:libell::f("libel", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:lible::f("libel", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:librer::f("librar", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:liesure::f("leisure", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:liev::f("live", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0*:liquif::f("liquef", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:lsat::f("last", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:lsit::f("list", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0*:lveo::f("love", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0*:lvoe::f("love", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0*:lybia::f("Libya", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:maginc::f("magic", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:magnificien::f("magnificen", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:magol::f("magnol", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:manisf::f("manif", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:marrtyr::f("martyr", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0*:masterbat::f("masturbat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:mataph::f("metaph", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:mechandi::f("merchandi", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:mercentil::f("mercantil", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:mesag::f("messag", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:meterolog::f("meteorolog", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:micos::f("micros", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0*:milion::f("million", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:milleni::f("millenni", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:minsitr::f("ministr", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:mirrorr::f("mirror", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:miscellanious::f("miscellaneous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:miscellanous::f("miscellaneous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:mischeivous::f("mischievous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:mischevious::f("mischievous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:mischievious::f("mischievous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:misdameanor::f("misdemeanor", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:misdemenor::f("misdemeanor", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:misouri::f("Missouri", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:mispell::f("misspell", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:misteri::f("mysteri", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:monestar::f("monaster", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:monicker::f("moniker", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:monkie::f("monkey", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:montain::f("mountain", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:montyp::f("monotyp", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:movei::f("movie", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:muncipal::f("municipal", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:munnicipal::f("municipal", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:muscician::f("musician", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:myraid::f("myriad", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:mysogyn::f("misogyn", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:mysterous::f("mysterious", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:naieve::f("naive", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:necessiat::f("necessitat", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:neglib::f("negligib", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:negligab::f("negligib", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:negociab::f("negotiab", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:nkwo::f("know", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0*:norhe::f("northe", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0*:northen::f("northern", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:northereast::f("northeast", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:noteri::f("notori", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:nothern::f("northern", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:notive::f("notice", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:nowe::f("now", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:nto::f("not", A_ThisHotkey, A_EndChar) ; Fixes 116 words
:XB0*:numbero::f("numero", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:nutur::f("nurtur", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:nver::f("never", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:nwe::f("new", A_ThisHotkey, A_EndChar) ; Fixes 123 words
:XB0*:nwo::f("now", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:obess::f("obsess", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:obssess::f("obsess", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:ocasion::f("occasion", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:ocass::f("occas", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:occaison::f("occasion", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:occation::f("occasion", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:octohedr::f("octahedr", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:ocuntr::f("countr", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:ocur::f("occur", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:offce::f("office", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:onot::f("not", A_ThisHotkey, A_EndChar) ; Fixes 116 words
:XB0*:oponen::f("opponen", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:opose::f("oppose", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:oposi::f("opposi", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:oppositit::f("opposit", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:opre::f("oppre", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:optmiz::f("optimiz", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:optomi::f("optimi", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:orthag::f("orthog", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0*:oublish::f("publish", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:oustanding::f("outstanding", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:overwelm::f("overwhelm", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:owudl::f("would", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:owuld::f("would", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:oximoron::f("oxymoron", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:palist::f("Palest", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:pamflet::f("pamphlet", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:pamplet::f("pamphlet", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:pantomine::f("pantomime", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:paranthe::f("parenthe", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:parrakeet::f("parakeet", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:pastural::f("pastoral", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:peageant::f("pageant", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:peculure::f("peculiar", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:pedestrain::f("pedestrian", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:pensle::f("pencil", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:peom::f("poem", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:perade::f("parade", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:peretrat::f("perpetrat", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:peripathetic::f("peripatetic", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:peristen::f("persisten", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:perjer::f("perjur", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:perjorative::f("pejorative", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:perpindicular::f("perpendicular", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:persan::f("person", A_ThisHotkey, A_EndChar) ; Fixes 55 words
:XB0*:perseveren::f("perseveran", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:persue::f("pursue", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:persui::f("pursui", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:philipi::f("Philippi", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:pilgrimm::f("pilgrim", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:plagar::f("plagiar", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0*:plateu::f("plateau", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:playright::f("playwright", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:playwrite::f("playwright", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:plebicit::f("plebiscit", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:pomot::f("promot", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:posthomous::f("posthumous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:potra::f("portra", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:practioner::f("practitioner", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:prairy::f("prairie", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:prarie::f("prairie", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:preample::f("preamble", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:precurser::f("precursor", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:preferra::f("prefera", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:premei::f("premie", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:premillenial::f("premillennial", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:preminen::f("preeminen", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:premissio::f("permissio", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:prepart::f("preparat", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:prepera::f("prepara", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:presed::f("presid", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:presitg::f("prestig", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:prevers::f("pervers", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:primativ::f("primitiv", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:primordal::f("primordial", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:principial::f("principal", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:prinici::f("princi", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:privt::f("privat", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0*:procede::f("proceed", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:proceding::f("proceeding", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:proceedur::f("procedur", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:profesor::f("professor", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:profilic::f("prolific", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:progid::f("prodig", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:promiscous::f("promiscuous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:pronomial::f("pronominal", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:propoga::f("propaga", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0*:proseletyz::f("proselytiz", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:protruberanc::f("protuberanc", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:pseudonyn::f("pseudonym", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:puch::f("push", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0*:pumkin::f("pumpkin", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:puritannic::f("puritanic", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:purpot::f("purport", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:pysci::f("psychi", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:quantat::f("quantit", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:quess::f("guess", A_ThisHotkey, A_EndChar) ; Fixes 14 words 
:XB0*:quinessen::f("quintessen", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:quize::f("quizze", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:racaus::f("raucous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:raed::f("read", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0*:rasberr::f("raspberr", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:reasea::f("resea", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:recie::f("recei", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:reciv::f("receiv", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:recomen::f("recommen", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:recommed::f("recommend", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:reconaissance::f("reconnaissance", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:reconize::f("recognize", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:recuit::f("recruit", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:recurran::f("recurren", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:redicu::f("ridicu", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:refedend::f("referend", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:refridgera::f("refrigera", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:refusla::f("refusal", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:reher::f("rehear", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:reica::f("reinca", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:reknown::f("renown", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:reliz::f("realiz", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:remenant::f("remnant", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:remenic::f("reminisc", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:reminent::f("remnant", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:remines::f("reminis", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:reminsc::f("reminisc", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:reminsic::f("reminisc", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:rendevous::f("rendezvous", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:rendezous::f("rendezvous", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:renewl::f("renewal", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:repid::f("rapid", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:repon::f("respon", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:reprtoire::f("repertoire", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:repubi::f("republi", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:requr::f("requir", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:resaura::f("restaura", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:resembe::f("resemble", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:resevoir::f("reservoir", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:resignement::f("resignation", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:resignment::f("resignation", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:resse::f("rese", A_ThisHotkey, A_EndChar) ; Fixes 98 words
:XB0*:ressurrect::f("resurrect", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:restara::f("restaura", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:restaurati::f("restorati", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:resteraunt::f("restaurant", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:restraunt::f("restaurant", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:resturant::f("restaurant", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:resturaunt::f("restaurant", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:retalitat::f("retaliat", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:retrun::f("return", A_ThisHotkey, A_EndChar) ; Fixes 10 words 
:XB0*:reult::f("result", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:reveral::f("reversal", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:rfere::f("refere", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0*:rockerfeller::f("Rockefeller", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:rococco::f("rococo", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:role call::f("roll call", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:roll play::f("role play", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:roomate::f("roommate", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:rucupera::f("recupera", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:rulle::f("rule", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:rumer::f("rumor", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:russina::f("Russian", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:russion::f("Russian", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:rythem::f("rhythm", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:rythm::f("rhythm", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:sacrelig::f("sacrileg", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:sacrifical::f("sacrificial", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:safegard::f("safeguard", A_ThisHotkey, A_EndChar) ; added by steve
:XB0*:salery::f("salary", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:sandwhich::f("sandwich", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:sargan::f("sergean", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:sargean::f("sergean", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:saterday::f("Saturday", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:saxaphon::f("saxophon", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:say la v::f("c'est la vie", A_ThisHotkey, A_EndChar)
:XB0*:scandanavia::f("Scandinavia", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:scaricit::f("scarcit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:scavang::f("scaveng", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:scrutinit::f("scrutin", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:scuptur::f("sculptur", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:secceed::f("seced", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:secrata::f("secreta", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:seguoy::f("segue", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:seh::f("she", A_ThisHotkey, A_EndChar) ; Fixes 236 words
:XB0*:seinor::f("senior", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:senari::f("scenari", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:senc::f("sens", A_ThisHotkey, A_EndChar) ; Fixes 107 words
:XB0*:sentan::f("senten", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:sepina::f("subpoena", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:sergent::f("sergeant", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:set back::f("setback", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:shamen::f("shaman", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:short coming::f("shortcoming", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:shoudl::f("should", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:shreak::f("shriek", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:side affect::f("side effect", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:side kick::f("sidekick", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sideral::f("sidereal", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:siez::f("seiz", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:simetr::f("symmetr", A_ThisHotkey, A_EndChar) ; Fixes 18 words 
:XB0*:site line::f("sight line", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sneek::f("sneak", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:socit::f("societ", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:sofware::f("software", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:soilder::f("soldier", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:solatar::f("solitar", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:soliders::f("soldiers", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:soliliqu::f("soliloqu", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:somtime::f("sometime", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sophmore::f("sophomore", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sorceror::f("sorcerer", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sorround::f("surround", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:sould::f("should", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:sountrack::f("soundtrack", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sourth::f("south", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0*:souvenier::f("souvenir", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:soveit::f("soviet", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*:sovereignit::f("sovereignt", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:speciman::f("specimen", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:spendour::f("splendour", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sportscar::f("sports car", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:sppech::f("speech", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*:squared inch::f("square inch", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:squared kilometer::f("square kilometer", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:squared meter::f("square meter", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:squared mile::f("square mile", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:stale mat::f("stalemat", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:staring role::f("starring role", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:starring roll::f("starring role", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:stilus::f("stylus", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:stpo::f("stop", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0*:strenous::f("strenuous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:strike out::f("strikeout", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:strnad::f("strand", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:stroy::f("story", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:struggel::f("struggle", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:strugl::f("struggl", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:stuggl::f("struggl", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:subjudgation::f("subjugation", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:subsidar::f("subsidiar", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:subsiduar::f("subsidiar", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:subsquen::f("subsequen", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:substace::f("substance", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:substatia::f("substantia", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:substitud::f("substitut", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:substract::f("subtract", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0*:subtance::f("substance", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:suburburban::f("suburban", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:succedd::f("succeed", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:succede::f("succeede", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:suceed::f("succeed", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:sucide::f("suicide", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:sucidial::f("suicidal", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:sudent::f("student", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:sufferag::f("suffrag", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:sumar::f("summar", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:suop::f("soup", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:superce::f("superse", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:supliment::f("supplement", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:surplant::f("supplant", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:surrepetitious::f("surreptitious", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:surreptious::f("surreptitious", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:surrond::f("surround", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:surroud::f("surround", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:surrunder::f("surrender", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:surveilen::f("surveillan", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:swiming::f("swimming", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:synagouge::f("synagogue", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:synph::f("symph", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0*:syrap::f("syrup", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:tabacco::f("tobacco", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:tatoo::f("tattoo", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:telelev::f("telev", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:televiz::f("televis", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:televsion::f("television", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:temerature::f("temperature", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:temperment::f("temperament", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:temperture::f("temperature", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:tenacle::f("tentacle", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:termoil::f("turmoil", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:testomon::f("testimon", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:thansk::f("thanks", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:thegovernment::f("the government", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:there final::f("their final", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:thge::f("the", A_ThisHotkey, A_EndChar) ; Fixes 402 words
:XB0*:thier::f("their", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:thisyear::f("this year", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:thna::f("than", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0*:thne::f("then", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:threee::f("three", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:threshhold::f("threshold", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:thrid::f("third", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:thror::f("thor", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0*:thsi::f("this", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0*:thta::f("that", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:tiem::f("time", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0*:time out::f("timeout", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:timeschedule::f("time schedule", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:timne::f("time", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0*:tiome::f("time", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0*:tobbaco::f("tobacco", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:todya::f("today", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:tolkein::f("Tolkien", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:tommorow::f("tomorrow", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:tommorrow::f("tomorrow", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:tomorow::f("tomorrow", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:tortise::f("tortoise", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:traffice::f("trafficke", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:trafic::f("traffic", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0*:trancend::f("transcend", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:transcendan::f("transcenden", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0*:transend::f("transcend", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:transferin::f("transferrin", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:translater::f("translator", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:transpora::f("transporta", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:tremelo::f("tremolo", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:triathalon::f("triathlon", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:triguer::f("trigger", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:triolog::f("trilog", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:tthe::f("the", A_ThisHotkey, A_EndChar) ; Fixes 402 words
:XB0*:tust::f("trust", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0*:tution::f("tuition", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:twelth::f("twelfth", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:tyo::f("to", A_ThisHotkey, A_EndChar) ; Fixes 1110 words
:XB0*:tyrrani::f("tyranni", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0*:ubiquitious::f("ubiquitous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:ubli::f("publi", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0*:uise::f("use", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0*:ukran::f("Ukrain", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:ulser::f("ulcer", A_ThisHotkey, A_EndChar) ; Fixes 12 words 
:XB0*:unanym::f("unanim", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:under go::f("undergo", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:under rate::f("underrate", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:under take::f("undertake", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:underat::f("underrat", A_ThisHotkey, A_EndChar) ; Fixes 4 words 
:XB0*:undreground::f("underground", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:uneccesar::f("unnecessar", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:unecessar::f("unnecessar", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:unequalit::f("inequalit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:unihabit::f("uninhabit", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:univeral::f("universal", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0*:univerist::f("universit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:univerit::f("universit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:universti::f("universit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:univesit::f("universit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:unkow::f("unknow", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0*:unliek::f("unlike", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:unotice::f("unnotice", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:unplease::f("displease", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:unuseable::f("unusable", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:vaccum::f("vacuum", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:vacinit::f("vicinit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:vaguar::f("vagar", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:vaiet::f("variet", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:varit::f("variet", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:vasall::f("vassal", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:vehicule::f("vehicle", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:vengance::f("vengeance", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:vengence::f("vengeance", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:verfication::f("verification", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:vermillion::f("vermilion", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:versitilat::f("versatilit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:versitlit::f("versatilit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:vetween::f("between", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:vigour::f("vigor", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:villian::f("villain", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:villifi::f("vilifi", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:villify::f("vilify", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:villin::f("villain", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0*:vincinit::f("vicinit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:virutal::f("virtual", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0*:visabl::f("visibl", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:vistor::f("visitor", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:vitor::f("victor", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:vocal chord::f("vocal cord", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:volcanoe::f("volcano", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:voley::f("volley", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0*:vriet::f("variet", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:vulnerablilit::f("vulnerabilit", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:wardobe::f("wardrobe", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:whn::f("when", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:whould::f("would", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:wich::f("which", A_ThisHotkey, A_EndChar) ; Fixes 3 words, Case-sensitive to not misspell Wichita.
:XB0*:widesread::f("widespread", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0*:wih::f("whi", A_ThisHotkey, A_EndChar) ; Fixes 310 words
:XB0*:withdrawl::f("withdrawal", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0*:withold::f("withhold", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0*:worsten::f("worsen", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:woudl::f("would", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:wreckless::f("reckless", A_ThisHotkey, A_EndChar) ; Fixes 3 words 
:XB0*:xoom::f("zoom", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0*:yatch::f("yacht", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0*:yelow::f("yellow", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0*:yera::f("year", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*:yotube::f("youtube", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0*:yrea::f("year", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0*?:alell::f("allel", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0*?:alsitic::f("alistic", A_ThisHotkey, A_EndChar) ; Fixes 98 words
:XB0*?:onvertab::f("onvertib", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0*?:sucess::f("success", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*?C:balen::f("balan", A_ThisHotkey, A_EndChar) ; Fixes 45 words.  Case-sensitive to not misspell Balenciaga (Spanish fashion designer). 
:XB0*?C:beng::f("being", A_ThisHotkey, A_EndChar) ; Fixes 7 words. Case-sensitive to not misspell, Bengali. 
:XB0*?C:hiesm::f("theism", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0*C:aquit::f("acquit", A_ThisHotkey, A_EndChar) ; Fixes 10 words.  Case-sensitive to not misspell Aquitaine (A region of southwestern France between Bordeaux and the Pyrenees)
:XB0*C:carmel::f("caramel", A_ThisHotkey, A_EndChar) ; Fixes 12 words.  Case-sensitive to not misspell Carmelite (Roman Catholic friar)
:XB0*C:carrer::f("career", A_ThisHotkey, A_EndChar) ; Fixes 8 words.  Case-sensitive to not misspell Carrere (A famous architect) 
:XB0*C:ehr::f("her", A_ThisHotkey, A_EndChar) ; Fixes 233 words, Made case sensitive so not to misspell Ehrenberg (a Russian novelist) or Ehrlich (a German scientist)
:XB0*C:herat::f("heart", A_ThisHotkey, A_EndChar) ; Fixes 63 words, Case-sensitive to not misspell Herat (a city in Afganistan).
:XB0*C:hsi::f("his", A_ThisHotkey, A_EndChar) ; Fixes 95 words, Case-sensitive to not misspell Hsian (a city in China)
:XB0*C:ime::f("imme", A_ThisHotkey, A_EndChar) ; Fixes 35 words, Case-sensitive to not misspell IMEI (International Mobile Equipment Identity)
:XB0*C:yoru::f("your", A_ThisHotkey, A_EndChar) ; Fixes 4 words, case sensitive to not misspell Yoruba (A Nigerian langue) 
:XB0:EDB::f("EBD", A_ThisHotkey, A_EndChar)
:XB0:Feburary::f("February", A_ThisHotkey, A_EndChar) 
:XB0:Isaax ::f("Isaac", A_ThisHotkey, A_EndChar)
:XB0:Israelies::f("Israelis", A_ThisHotkey, A_EndChar) 
:XB0:Janurary::f("January", A_ThisHotkey, A_EndChar) 
:XB0:Januray::f("January", A_ThisHotkey, A_EndChar) 
:XB0:Montnana::f("Montana", A_ThisHotkey, A_EndChar) 
:XB0:Novermber::f("November", A_ThisHotkey, A_EndChar) 
:XB0:Parri::f("Patti", A_ThisHotkey, A_EndChar)
:XB0:Sacremento::f("Sacramento", A_ThisHotkey, A_EndChar)
:XB0:Straight of::f("Strait of", A_ThisHotkey, A_EndChar) ; geography
:XB0:ToolTop::f("ToolTip", A_ThisHotkey, A_EndChar)
:XB0:a English::f("an English", A_ThisHotkey, A_EndChar)
:XB0:a FM::f("an FM", A_ThisHotkey, A_EndChar)
:XB0:a Internet::f("an Internet", A_ThisHotkey, A_EndChar)
:XB0:a MRI::f("an MRI", A_ThisHotkey, A_EndChar)
:XB0:a businessmen::f("a businessman", A_ThisHotkey, A_EndChar)
:XB0:a businesswomen::f("a businesswoman", A_ThisHotkey, A_EndChar)
:XB0:a consortia::f("a consortium", A_ThisHotkey, A_EndChar)
:XB0:a criteria::f("a criterion", A_ThisHotkey, A_EndChar)
:XB0:a dominate::f("a dominant", A_ThisHotkey, A_EndChar)
:XB0:a falling out::f("a falling-out", A_ThisHotkey, A_EndChar)
:XB0:a firemen::f("a fireman", A_ThisHotkey, A_EndChar)
:XB0:a flagella::f("a flagellum", A_ThisHotkey, A_EndChar)
:XB0:a forward by::f("a foreword by", A_ThisHotkey, A_EndChar)
:XB0:a freshmen::f("a freshman", A_ThisHotkey, A_EndChar)
:XB0:a fungi::f("a fungus", A_ThisHotkey, A_EndChar)
:XB0:a gunmen::f("a gunman", A_ThisHotkey, A_EndChar)
:XB0:a heir::f("an heir", A_ThisHotkey, A_EndChar)
:XB0:a herb::f("an herb", A_ThisHotkey, A_EndChar)
:XB0:a honest::f("an honest", A_ThisHotkey, A_EndChar)
:XB0:a honor::f("an honor", A_ThisHotkey, A_EndChar)
:XB0:a hour::f("an hour", A_ThisHotkey, A_EndChar)
:XB0:a larvae::f("a larva", A_ThisHotkey, A_EndChar)
:XB0:a lock up::f("a lockup", A_ThisHotkey, A_EndChar)
:XB0:a lose::f("a loss", A_ThisHotkey, A_EndChar)
:XB0:a manufacture::f("a manufacturer", A_ThisHotkey, A_EndChar)
:XB0:a nuclei::f("a nucleus", A_ThisHotkey, A_EndChar)
:XB0:a numbers of::f("a number of", A_ThisHotkey, A_EndChar)
:XB0:a ocean::f("an ocean", A_ThisHotkey, A_EndChar)
:XB0:a offensive::f("an offensive", A_ThisHotkey, A_EndChar)
:XB0:a official::f("an official", A_ThisHotkey, A_EndChar)
:XB0:a one of the::f("one of the", A_ThisHotkey, A_EndChar)
:XB0:a only a::f("only a", A_ThisHotkey, A_EndChar)
:XB0:a parentheses::f("a parenthesis", A_ThisHotkey, A_EndChar)
:XB0:a phenomena::f("a phenomenon", A_ThisHotkey, A_EndChar)
:XB0:a protozoa::f("a protozoon", A_ThisHotkey, A_EndChar)
:XB0:a pupae::f("a pupa", A_ThisHotkey, A_EndChar)
:XB0:a radii::f("a radius", A_ThisHotkey, A_EndChar)
:XB0:a renown::f("a renowned", A_ThisHotkey, A_EndChar)
:XB0:a resent::f("a recent", A_ThisHotkey, A_EndChar)
:XB0:a run in::f("a run-in", A_ThisHotkey, A_EndChar)
:XB0:a set back::f("a set-back", A_ThisHotkey, A_EndChar)
:XB0:a set up::f("a setup", A_ThisHotkey, A_EndChar)
:XB0:a several::f("several", A_ThisHotkey, A_EndChar)
:XB0:a simple as::f("as simple as", A_ThisHotkey, A_EndChar)
:XB0:a spermatozoa::f("a spermatozoon", A_ThisHotkey, A_EndChar)
:XB0:a statesmen::f("a statesman", A_ThisHotkey, A_EndChar)
:XB0:a strata::f("a stratum", A_ThisHotkey, A_EndChar)
:XB0:a taxa::f("a taxon", A_ThisHotkey, A_EndChar)
:XB0:a two months::f("a two-month", A_ThisHotkey, A_EndChar)
:XB0:a urban::f("an urban", A_ThisHotkey, A_EndChar)
:XB0:a vertebrae::f("a vertebra", A_ThisHotkey, A_EndChar)
:XB0:a women::f("a woman", A_ThisHotkey, A_EndChar)
:XB0:a work out::f("a workout", A_ThisHotkey, A_EndChar)
:XB0:about it's::f("about its", A_ThisHotkey, A_EndChar)
:XB0:about they're::f("about their", A_ThisHotkey, A_EndChar)
:XB0:about who to::f("about whom to", A_ThisHotkey, A_EndChar)
:XB0:about who's::f("about whose", A_ThisHotkey, A_EndChar)
:XB0:abouta::f("about a", A_ThisHotkey, A_EndChar) 
:XB0:aboutit::f("about it", A_ThisHotkey, A_EndChar) 
:XB0:above it's::f("above its", A_ThisHotkey, A_EndChar)
:XB0:abutts::f("abuts", A_ThisHotkey, A_EndChar)
:XB0:accidently::f("accidentally", A_ThisHotkey, A_EndChar)
:XB0:according a::f("according to a", A_ThisHotkey, A_EndChar)
:XB0:accordingto::f("according to", A_ThisHotkey, A_EndChar) 
:XB0:across it's::f("across its", A_ThisHotkey, A_EndChar)
:XB0:adres::f("address", A_ThisHotkey, A_EndChar) 
:XB0:affect on::f("effect on", A_ThisHotkey, A_EndChar)
:XB0:affect upon::f("effect upon", A_ThisHotkey, A_EndChar)
:XB0:affects of::f("effects of", A_ThisHotkey, A_EndChar)
:XB0:after along time::f("after a long time", A_ThisHotkey, A_EndChar)
:XB0:after awhile::f("after a while", A_ThisHotkey, A_EndChar)
:XB0:after been::f("after being", A_ThisHotkey, A_EndChar)
:XB0:after it's::f("after its", A_ThisHotkey, A_EndChar)
:XB0:after quite awhile::f("after quite a while", A_ThisHotkey, A_EndChar)
:XB0:agains::f("against", A_ThisHotkey, A_EndChar)
:XB0:against it's::f("against its", A_ThisHotkey, A_EndChar)
:XB0:against who::f("against whom", A_ThisHotkey, A_EndChar)
:XB0:againstt he::f("against the", A_ThisHotkey, A_EndChar) 
:XB0:aginst::f("against", A_ThisHotkey, A_EndChar)
:XB0:agre::f("agree", A_ThisHotkey, A_EndChar)
:XB0:agree in principal::f("agree in principle", A_ThisHotkey, A_EndChar)
:XB0:agreement in principal::f("agreement in principle", A_ThisHotkey, A_EndChar)
:XB0:ahjk::f("ahk", A_ThisHotkey, A_EndChar)
:XB0:airbourne::f("airborne", A_ThisHotkey, A_EndChar) 
:XB0:aircrafts'::f("aircraft's", A_ThisHotkey, A_EndChar) 
:XB0:aircrafts::f("aircraft", A_ThisHotkey, A_EndChar) 
:XB0:airplane hanger::f("airplane hangar", A_ThisHotkey, A_EndChar)
:XB0:airporta::f("airports", A_ThisHotkey, A_EndChar) 
:XB0:airrcraft::f("aircraft", A_ThisHotkey, A_EndChar) 
:XB0:albiet::f("albeit", A_ThisHotkey, A_EndChar)
:XB0:all for not::f("all for naught", A_ThisHotkey, A_EndChar) 
:XB0:all it's::f("all its", A_ThisHotkey, A_EndChar) 
:XB0:all though::f("although", A_ThisHotkey, A_EndChar) 
:XB0:all tolled::f("all told", A_ThisHotkey, A_EndChar) 
:XB0:allegedy::f("allegedly", A_ThisHotkey, A_EndChar)
:XB0:allegely::f("allegedly", A_ThisHotkey, A_EndChar)
:XB0:allot of::f("a lot of", A_ThisHotkey, A_EndChar) 
:XB0:allready::f("already", A_ThisHotkey, A_EndChar)
:XB0:alltime::f("all-time", A_ThisHotkey, A_EndChar) 
:XB0:alma matter::f("alma mater", A_ThisHotkey, A_EndChar) 
:XB0:almots::f("almost", A_ThisHotkey, A_EndChar)
:XB0:along it's::f("along its", A_ThisHotkey, A_EndChar) 
:XB0:along side::f("alongside", A_ThisHotkey, A_EndChar) 
:XB0:along time::f("a long time", A_ThisHotkey, A_EndChar) 
:XB0:alongside it's::f("alongside its", A_ThisHotkey, A_EndChar) 
:XB0:alot::f("a lot", A_ThisHotkey, A_EndChar) 
:XB0:also know as::f("also known as", A_ThisHotkey, A_EndChar) 
:XB0:also know by::f("also known by", A_ThisHotkey, A_EndChar) 
:XB0:also know for::f("also known for", A_ThisHotkey, A_EndChar) 
:XB0:alter boy::f("altar boy", A_ThisHotkey, A_EndChar) 
:XB0:alter server::f("altar server", A_ThisHotkey, A_EndChar) 
:XB0:althought::f("although", A_ThisHotkey, A_EndChar) 
:XB0:altoug::f("althoug", A_ThisHotkey, A_EndChar)
:XB0:alway::f("always", A_ThisHotkey, A_EndChar) 
:XB0:am loathe to::f("am loath to", A_ThisHotkey, A_EndChar) 
:XB0:amid it's::f("amid its", A_ThisHotkey, A_EndChar) 
:XB0:amidst it's::f("amidst its", A_ThisHotkey, A_EndChar) 
:XB0:amin::f("main", A_ThisHotkey, A_EndChar)
:XB0:among it's::f("among it", A_ThisHotkey, A_EndChar) 
:XB0:among others things::f("among other things", A_ThisHotkey, A_EndChar) 
:XB0:amongst it's::f("amongst its", A_ThisHotkey, A_EndChar) 
:XB0:amongst one of the::f("amongst the", A_ThisHotkey, A_EndChar) 
:XB0:amongst others things::f("amongst other things", A_ThisHotkey, A_EndChar) 
:XB0:an British::f("a British", A_ThisHotkey, A_EndChar) 
:XB0:an Canadian::f("a Canadian", A_ThisHotkey, A_EndChar) 
:XB0:an European::f("a European", A_ThisHotkey, A_EndChar) 
:XB0:an Hawaiian::f("a Hawaiian", A_ThisHotkey, A_EndChar) 
:XB0:an Malaysian::f("a Malaysian", A_ThisHotkey, A_EndChar) 
:XB0:an Scottish::f("a Scottish", A_ThisHotkey, A_EndChar) 
:XB0:an USB::f("a USB", A_ThisHotkey, A_EndChar) 
:XB0:an Unix::f("a Unix", A_ThisHotkey, A_EndChar) 
:XB0:an affect::f("an effect", A_ThisHotkey, A_EndChar) 
:XB0:an alumnae of::f("an alumna of", A_ThisHotkey, A_EndChar) 
:XB0:an alumni of::f("an alumnus of", A_ThisHotkey, A_EndChar) 
:XB0:an another::f("another", A_ThisHotkey, A_EndChar) 
:XB0:an antennae::f("an antenna", A_ThisHotkey, A_EndChar) 
:XB0:an film::f("a film", A_ThisHotkey, A_EndChar) 
:XB0:an half::f("a half", A_ThisHotkey, A_EndChar) 
:XB0:an halt::f("a halt", A_ThisHotkey, A_EndChar) 
:XB0:an hand::f("a hand", A_ThisHotkey, A_EndChar) 
:XB0:an head::f("a head", A_ThisHotkey, A_EndChar) 
:XB0:an heart::f("a heart", A_ThisHotkey, A_EndChar) 
:XB0:an helicopter::f("a helicopter", A_ThisHotkey, A_EndChar) 
:XB0:an hero::f("a hero", A_ThisHotkey, A_EndChar) 
:XB0:an high::f("a high", A_ThisHotkey, A_EndChar) 
:XB0:an historian::f("a historian", A_ThisHotkey, A_EndChar) 
:XB0:an historic::f("a historic", A_ThisHotkey, A_EndChar) 
:XB0:an historical::f("a historical", A_ThisHotkey, A_EndChar) 
:XB0:an history::f("a history", A_ThisHotkey, A_EndChar) 
:XB0:an hospital::f("a hospital", A_ThisHotkey, A_EndChar) 
:XB0:an hotel::f("a hotel", A_ThisHotkey, A_EndChar) 
:XB0:an humanitarian::f("a humanitarian", A_ThisHotkey, A_EndChar) 
:XB0:an law::f("a law", A_ThisHotkey, A_EndChar) 
:XB0:an lawyer::f("a lawyer", A_ThisHotkey, A_EndChar) 
:XB0:an local::f("a local", A_ThisHotkey, A_EndChar) 
:XB0:an new::f("a new", A_ThisHotkey, A_EndChar) 
:XB0:an nine::f("a nine", A_ThisHotkey, A_EndChar) 
:XB0:an ninth::f("a ninth", A_ThisHotkey, A_EndChar) 
:XB0:an non::f("a non", A_ThisHotkey, A_EndChar) 
:XB0:an number::f("a number", A_ThisHotkey, A_EndChar) 
:XB0:an other::f("another", A_ThisHotkey, A_EndChar) 
:XB0:an pair::f("a pair", A_ThisHotkey, A_EndChar) 
:XB0:an player::f("a player", A_ThisHotkey, A_EndChar) 
:XB0:an popular::f("a popular", A_ThisHotkey, A_EndChar) 
:XB0:an pre-::f("a pre-", A_ThisHotkey, A_EndChar) 
:XB0:an second::f("a second", A_ThisHotkey, A_EndChar) 
:XB0:an series::f("a series", A_ThisHotkey, A_EndChar) 
:XB0:an seven::f("a seven", A_ThisHotkey, A_EndChar) 
:XB0:an seventh::f("a seventh", A_ThisHotkey, A_EndChar) 
:XB0:an six::f("a six", A_ThisHotkey, A_EndChar) 
:XB0:an sixteen::f("a sixteen", A_ThisHotkey, A_EndChar) 
:XB0:an sixth::f("a sixth", A_ThisHotkey, A_EndChar) 
:XB0:an song::f("a song", A_ThisHotkey, A_EndChar) 
:XB0:an special::f("a special", A_ThisHotkey, A_EndChar) 
:XB0:an species::f("a species", A_ThisHotkey, A_EndChar) 
:XB0:an specific::f("a specific", A_ThisHotkey, A_EndChar) 
:XB0:an statement::f("a statement", A_ThisHotkey, A_EndChar) 
:XB0:an ten::f("a ten", A_ThisHotkey, A_EndChar) 
:XB0:an union::f("a union", A_ThisHotkey, A_EndChar) 
:XB0:an unit::f("a unit", A_ThisHotkey, A_EndChar) 
:XB0:anarchistm::f("anarchism", A_ThisHotkey, A_EndChar)
:XB0:and so fourth::f("and so forth", A_ThisHotkey, A_EndChar) 
:XB0:andone::f("and one", A_ThisHotkey, A_EndChar) 
:XB0:androgeny::f("androgyny", A_ThisHotkey, A_EndChar)
:XB0:andt he::f("and the", A_ThisHotkey, A_EndChar) 
:XB0:andteh::f("and the", A_ThisHotkey, A_EndChar) 
:XB0:anothe::f("another", A_ThisHotkey, A_EndChar)
:XB0:another criteria::f("another criterion", A_ThisHotkey, A_EndChar) 
:XB0:another words::f("in other words", A_ThisHotkey, A_EndChar) 
:XB0:anti-semetic::f("anti-Semitic", A_ThisHotkey, A_EndChar) 
:XB0:antiapartheid::f("anti-apartheid", A_ThisHotkey, A_EndChar) 
:XB0:any another::f("another", A_ThisHotkey, A_EndChar) 
:XB0:any resent::f("any recent", A_ThisHotkey, A_EndChar) 
:XB0:any where::f("anywhere", A_ThisHotkey, A_EndChar) 
:XB0:anyother::f("any other", A_ThisHotkey, A_EndChar) 
:XB0:anytying::f("anything", A_ThisHotkey, A_EndChar)
:XB0:apart form::f("apart from", A_ThisHotkey, A_EndChar) 
:XB0:apon::f("upon", A_ThisHotkey, A_EndChar)
:XB0:archimedian::f("Archimedean", A_ThisHotkey, A_EndChar)
:XB0:are aloud to::f("are allowed to", A_ThisHotkey, A_EndChar) 
:XB0:are build::f("are built", A_ThisHotkey, A_EndChar) 
:XB0:are dominate::f("are dominant", A_ThisHotkey, A_EndChar) 
:XB0:are drew::f("are drawn", A_ThisHotkey, A_EndChar) 
:XB0:are it's::f("are its", A_ThisHotkey, A_EndChar) 
:XB0:are know::f("are known", A_ThisHotkey, A_EndChar) 
:XB0:are lain::f("are laid", A_ThisHotkey, A_EndChar) 
:XB0:are lead by::f("are led by", A_ThisHotkey, A_EndChar) 
:XB0:are loathe to::f("are loath to", A_ThisHotkey, A_EndChar) 
:XB0:are meet::f("are met", A_ThisHotkey, A_EndChar) 
:XB0:are ran by::f("are run by", A_ThisHotkey, A_EndChar) 
:XB0:are renown::f("are renowned", A_ThisHotkey, A_EndChar) 
:XB0:are set-up::f("are set up", A_ThisHotkey, A_EndChar) 
:XB0:are setup::f("are set up", A_ThisHotkey, A_EndChar) 
:XB0:are shutdown::f("are shut down", A_ThisHotkey, A_EndChar) 
:XB0:are shutout::f("are shut out", A_ThisHotkey, A_EndChar) 
:XB0:are suppose to::f("are supposed to", A_ThisHotkey, A_EndChar) 
:XB0:are the dominate::f("are the dominant", A_ThisHotkey, A_EndChar) 
:XB0:are use to::f("are used to", A_ThisHotkey, A_EndChar) 
:XB0:aready::f("already", A_ThisHotkey, A_EndChar) 
:XB0:arised::f("arose", A_ThisHotkey, A_EndChar) 
:XB0:arn't::f("aren't", A_ThisHotkey, A_EndChar) 
:XB0:arond::f("around", A_ThisHotkey, A_EndChar)
:XB0:aroud::f("around", A_ThisHotkey, A_EndChar) 
:XB0:around it's::f("around its", A_ThisHotkey, A_EndChar) 
:XB0:arund::f("around", A_ThisHotkey, A_EndChar)
:XB0:as a resulted::f("as a result", A_ThisHotkey, A_EndChar) 
:XB0:as apposed to::f("as opposed to", A_ThisHotkey, A_EndChar) 
:XB0:as back up::f("as backup", A_ThisHotkey, A_EndChar) 
:XB0:as oppose to::f("as opposed to", A_ThisHotkey, A_EndChar) 
:XB0:asfar::f("as far", A_ThisHotkey, A_EndChar) 
:XB0:aside form::f("aside from", A_ThisHotkey, A_EndChar) 
:XB0:aside it's::f("aside its", A_ThisHotkey, A_EndChar) 
:XB0:aslo::f("also", A_ThisHotkey, A_EndChar)
:XB0:assume the reigns::f("assume the reins", A_ThisHotkey, A_EndChar) 
:XB0:assume the roll::f("assume the role", A_ThisHotkey, A_EndChar) 
:XB0:aswell::f("as well", A_ThisHotkey, A_EndChar) 
:XB0:at it's::f("at its", A_ThisHotkey, A_EndChar) 
:XB0:at of::f("at or", A_ThisHotkey, A_EndChar) 
:XB0:at the alter::f("at the altar", A_ThisHotkey, A_EndChar) 
:XB0:at the reigns::f("at the reins", A_ThisHotkey, A_EndChar) 
:XB0:at then end::f("at the end", A_ThisHotkey, A_EndChar) 
:XB0:atheistical::f("atheistic", A_ThisHotkey, A_EndChar)
:XB0:atleast::f("at least", A_ThisHotkey, A_EndChar) 
:XB0:atmospher::f("atmosphere", A_ThisHotkey, A_EndChar)
:XB0:attened::f("attended", A_ThisHotkey, A_EndChar)
:XB0:authorites::f("authorities", A_ThisHotkey, A_EndChar) 
:XB0:avengence::f("a vengeance", A_ThisHotkey, A_EndChar)
:XB0:averag::f("average", A_ThisHotkey, A_EndChar)
:XB0:away form::f("away from", A_ThisHotkey, A_EndChar) 
:XB0:baceause::f("because", A_ThisHotkey, A_EndChar) 
:XB0:back and fourth::f("back and forth", A_ThisHotkey, A_EndChar) 
:XB0:back drop::f("backdrop", A_ThisHotkey, A_EndChar) 
:XB0:back fire::f("backfire", A_ThisHotkey, A_EndChar) 
:XB0:back in forth::f("back and forth", A_ThisHotkey, A_EndChar) 
:XB0:back peddle::f("backpedal", A_ThisHotkey, A_EndChar) 
:XB0:back round::f("background", A_ThisHotkey, A_EndChar) 
:XB0:badly effected::f("badly affected", A_ThisHotkey, A_EndChar) 
:XB0:baited breath::f("bated breath", A_ThisHotkey, A_EndChar) 
:XB0:baled out::f("bailed out", A_ThisHotkey, A_EndChar) 
:XB0:baling out::f("bailing out", A_ThisHotkey, A_EndChar) 
:XB0:bare in mind::f("bear in mind", A_ThisHotkey, A_EndChar) 
:XB0:barily::f("barely", A_ThisHotkey, A_EndChar)
:XB0:basic principal::f("basic principle", A_ThisHotkey, A_EndChar) 
:XB0:be apart of::f("be a part of", A_ThisHotkey, A_EndChar) 
:XB0:be build::f("be built", A_ThisHotkey, A_EndChar) 
:XB0:be cause::f("because", A_ThisHotkey, A_EndChar) 
:XB0:be drew::f("be drawn", A_ThisHotkey, A_EndChar) 
:XB0:be it's::f("be its", A_ThisHotkey, A_EndChar) 
:XB0:be know as::f("be known as", A_ThisHotkey, A_EndChar) 
:XB0:be lain::f("be laid", A_ThisHotkey, A_EndChar) 
:XB0:be lead by::f("be led by", A_ThisHotkey, A_EndChar) 
:XB0:be loathe to::f("be loath to", A_ThisHotkey, A_EndChar) 
:XB0:be make::f("be made", A_ThisHotkey, A_EndChar)
:XB0:be ran::f("be run", A_ThisHotkey, A_EndChar) 
:XB0:be rebuild::f("be rebuilt", A_ThisHotkey, A_EndChar) 
:XB0:be rode::f("be ridden", A_ThisHotkey, A_EndChar) 
:XB0:be send::f("be sent", A_ThisHotkey, A_EndChar) 
:XB0:be set-up::f("be set up", A_ThisHotkey, A_EndChar) 
:XB0:be setup::f("be set up", A_ThisHotkey, A_EndChar) 
:XB0:be shutdown::f("be shut down", A_ThisHotkey, A_EndChar) 
:XB0:be use to::f("be used to", A_ThisHotkey, A_EndChar) 
:XB0:be ware::f("beware", A_ThisHotkey, A_EndChar) 
:XB0:beacuse::f("because", A_ThisHotkey, A_EndChar)
:XB0:became it's::f("became its", A_ThisHotkey, A_EndChar) 
:XB0:became know::f("became known", A_ThisHotkey, A_EndChar) 
:XB0:becames::f("became", A_ThisHotkey, A_EndChar)
:XB0:becaus::f("because", A_ThisHotkey, A_EndChar)
:XB0:because of it's::f("because of its", A_ThisHotkey, A_EndChar) 
:XB0:becausea::f("because a", A_ThisHotkey, A_EndChar) 
:XB0:becauseof::f("because of", A_ThisHotkey, A_EndChar) 
:XB0:becausethe::f("because the", A_ThisHotkey, A_EndChar) 
:XB0:becauseyou::f("because you", A_ThisHotkey, A_EndChar) 
:XB0:beccause::f("because", A_ThisHotkey, A_EndChar) 
:XB0:becouse::f("because", A_ThisHotkey, A_EndChar) 
:XB0:becuse::f("because", A_ThisHotkey, A_EndChar)
:XB0:been accustom to::f("been accustomed to", A_ThisHotkey, A_EndChar) 
:XB0:been build::f("been built", A_ThisHotkey, A_EndChar) 
:XB0:been it's::f("been its", A_ThisHotkey, A_EndChar) 
:XB0:been know::f("been known", A_ThisHotkey, A_EndChar) 
:XB0:been lain::f("been laid", A_ThisHotkey, A_EndChar) 
:XB0:been lead by::f("been led by", A_ThisHotkey, A_EndChar) 
:XB0:been loathe to::f("been loath to", A_ThisHotkey, A_EndChar) 
:XB0:been mislead::f("been misled", A_ThisHotkey, A_EndChar) 
:XB0:been ran::f("been run", A_ThisHotkey, A_EndChar) 
:XB0:been rebuild::f("been rebuilt", A_ThisHotkey, A_EndChar) 
:XB0:been rode::f("been ridden", A_ThisHotkey, A_EndChar) 
:XB0:been send::f("been sent", A_ThisHotkey, A_EndChar) 
:XB0:been set-up::f("been set up", A_ThisHotkey, A_EndChar) 
:XB0:been setup::f("been set up", A_ThisHotkey, A_EndChar) 
:XB0:been show on::f("been shown on", A_ThisHotkey, A_EndChar) 
:XB0:been shutdown::f("been shut down", A_ThisHotkey, A_EndChar) 
:XB0:been use to::f("been used to", A_ThisHotkey, A_EndChar) 
:XB0:before hand::f("beforehand", A_ThisHotkey, A_EndChar) 
:XB0:began it's::f("began its", A_ThisHotkey, A_EndChar) 
:XB0:beggin::f("begin", A_ThisHotkey, A_EndChar)
:XB0:beggins::f("begins", A_ThisHotkey, A_EndChar) 
:XB0:behind it's::f("behind its", A_ThisHotkey, A_EndChar) 
:XB0:being build::f("being built", A_ThisHotkey, A_EndChar) 
:XB0:being it's::f("being its", A_ThisHotkey, A_EndChar) 
:XB0:being lain::f("being laid", A_ThisHotkey, A_EndChar) 
:XB0:being lead by::f("being led by", A_ThisHotkey, A_EndChar) 
:XB0:being loathe to::f("being loath to", A_ThisHotkey, A_EndChar) 
:XB0:being ran::f("being run", A_ThisHotkey, A_EndChar) 
:XB0:being rode::f("being ridden", A_ThisHotkey, A_EndChar) 
:XB0:being set-up::f("being set up", A_ThisHotkey, A_EndChar) 
:XB0:being setup::f("being set up", A_ThisHotkey, A_EndChar) 
:XB0:being show on::f("being shown on", A_ThisHotkey, A_EndChar) 
:XB0:being shutdown::f("being shut down", A_ThisHotkey, A_EndChar) 
:XB0:being use to::f("being used to", A_ThisHotkey, A_EndChar) 
:XB0:beligum::f("belgium", A_ThisHotkey, A_EndChar) 
:XB0:belived::f("believed", A_ThisHotkey, A_EndChar) 
:XB0:belives::f("believes", A_ThisHotkey, A_EndChar) 
:XB0:below it's::f("below its", A_ThisHotkey, A_EndChar) 
:XB0:beneath it's::f("beneath its", A_ThisHotkey, A_EndChar) 
:XB0:beside it's::f("beside its", A_ThisHotkey, A_EndChar) 
:XB0:besides it's::f("besides its", A_ThisHotkey, A_EndChar) 
:XB0:better know as::f("better known as", A_ThisHotkey, A_EndChar) 
:XB0:better know for::f("better known for", A_ThisHotkey, A_EndChar) 
:XB0:better then::f("better than", A_ThisHotkey, A_EndChar) 
:XB0:between I and::f("between me and", A_ThisHotkey, A_EndChar) 
:XB0:between he and::f("between him and", A_ThisHotkey, A_EndChar) 
:XB0:between it's::f("between its", A_ThisHotkey, A_EndChar) 
:XB0:between they and::f("between them and", A_ThisHotkey, A_EndChar) 
:XB0:beyond it's::f("beyond its", A_ThisHotkey, A_EndChar) 
:XB0:bicep::f("biceps", A_ThisHotkey, A_EndChar) 
:XB0:both it's::f("both its", A_ThisHotkey, A_EndChar) 
:XB0:both of it's::f("both of its", A_ThisHotkey, A_EndChar) 
:XB0:both of them is::f("both of them are", A_ThisHotkey, A_EndChar) 
:XB0:both of who::f("both of whom", A_ThisHotkey, A_EndChar) 
:XB0:brake away::f("break away", A_ThisHotkey, A_EndChar) 
:XB0:breakthroughts::f("breakthroughs", A_ThisHotkey, A_EndChar)
:XB0:breath fire::f("breathe fire", A_ThisHotkey, A_EndChar) 
:XB0:brethen::f("brethren", A_ThisHotkey, A_EndChar) 
:XB0:bretheren::f("brethren", A_ThisHotkey, A_EndChar) 
:XB0:brew haha::f("brouhaha", A_ThisHotkey, A_EndChar) 
:XB0:brimestone::f("brimstone", A_ThisHotkey, A_EndChar) 
:XB0:britian::f("Britain", A_ThisHotkey, A_EndChar) 
:XB0:brittish::f("British", A_ThisHotkey, A_EndChar) 
:XB0:broacasted::f("broadcast", A_ThisHotkey, A_EndChar) 
:XB0:broady::f("broadly", A_ThisHotkey, A_EndChar) 
:XB0:by it's::f("by its", A_ThisHotkey, A_EndChar) 
:XB0:by who's::f("by whose", A_ThisHotkey, A_EndChar) 
:XB0:byt he::f("by the", A_ThisHotkey, A_EndChar) 
:XB0:cafe::f("café", A_ThisHotkey, A_EndChar) 
:XB0:callipigian::f("callipygian", A_ThisHotkey, A_EndChar)
:XB0:can backup::f("can back up", A_ThisHotkey, A_EndChar) 
:XB0:can been::f("can be", A_ThisHotkey, A_EndChar) 
:XB0:can blackout::f("can black out", A_ThisHotkey, A_EndChar) 
:XB0:can breath::f("can breathe", A_ThisHotkey, A_EndChar) 
:XB0:can checkout::f("can check out", A_ThisHotkey, A_EndChar) 
:XB0:can playback::f("can play back", A_ThisHotkey, A_EndChar) 
:XB0:can setup::f("can set up", A_ThisHotkey, A_EndChar) 
:XB0:can tryout::f("can try out", A_ThisHotkey, A_EndChar) 
:XB0:can workout::f("can work out", A_ThisHotkey, A_EndChar) 
:XB0:can't breath::f("can't breathe", A_ThisHotkey, A_EndChar) 
:XB0:can't of::f("can't have", A_ThisHotkey, A_EndChar) 
:XB0:cant::f("can't", A_ThisHotkey, A_EndChar) 
:XB0:capetown::f("Cape Town", A_ThisHotkey, A_EndChar) 
:XB0:carcas::f("carcass", A_ThisHotkey, A_EndChar) 
:XB0:carnege::f("Carnegie", A_ThisHotkey, A_EndChar) 
:XB0:carnige::f("Carnegie", A_ThisHotkey, A_EndChar) 
:XB0:celcius::f("Celsius", A_ThisHotkey, A_EndChar)
:XB0:cementary::f("cemetery", A_ThisHotkey, A_EndChar) 
:XB0:centruy::f("century", A_ThisHotkey, A_EndChar) 
:XB0:centuties::f("centuries", A_ThisHotkey, A_EndChar) 
:XB0:centuty::f("century", A_ThisHotkey, A_EndChar) 
:XB0:certain extend::f("certain extent", A_ThisHotkey, A_EndChar) 
:XB0:cervial::f("cervical", A_ThisHotkey, A_EndChar) 
:XB0:chalk full::f("chock-full", A_ThisHotkey, A_EndChar) 
:XB0:changed it's::f("changed its", A_ThisHotkey, A_EndChar) 
:XB0:charistics::f("characteristics", A_ThisHotkey, A_EndChar) 
:XB0:childrens::f("children's", A_ThisHotkey, A_EndChar) 
:XB0:chock it up::f("chalk it up", A_ThisHotkey, A_EndChar) 
:XB0:chocked full::f("chock-full", A_ThisHotkey, A_EndChar) 
:XB0:chomping at the bit::f("champing at the bit", A_ThisHotkey, A_EndChar) 
:XB0:choosen::f("chosen", A_ThisHotkey, A_EndChar) 
:XB0:cincinatti::f("Cincinnati", A_ThisHotkey, A_EndChar) 
:XB0:cincinnatti::f("Cincinnati", A_ThisHotkey, A_EndChar) 
:XB0:clera::f("clear", A_ThisHotkey, A_EndChar) 
:XB0:cliant::f("client", A_ThisHotkey, A_EndChar) 
:XB0:closed it's::f("closed its", A_ThisHotkey, A_EndChar) 
:XB0:closer then::f("closer than", A_ThisHotkey, A_EndChar) 
:XB0:co-incided::f("coincided", A_ThisHotkey, A_EndChar) 
:XB0:colum::f("column", A_ThisHotkey, A_EndChar) 
:XB0:commandoes::f("commandos", A_ThisHotkey, A_EndChar) 
:XB0:commonly know as::f("commonly known as", A_ThisHotkey, A_EndChar) 
:XB0:commonly know for::f("commonly known for", A_ThisHotkey, A_EndChar) 
:XB0:confids::f("confides", A_ThisHotkey, A_EndChar)
:XB0:construction sight::f("construction site", A_ThisHotkey, A_EndChar) 
:XB0:controvercy::f("controversy", A_ThisHotkey, A_EndChar)
:XB0:controvery::f("controversy", A_ThisHotkey, A_EndChar)
:XB0:coudn't::f("couldn't", A_ThisHotkey, A_EndChar) 
:XB0:could backup::f("could back up", A_ThisHotkey, A_EndChar) 
:XB0:could breath::f("could breathe", A_ThisHotkey, A_EndChar) 
:XB0:could setup::f("could set up", A_ThisHotkey, A_EndChar) 
:XB0:could workout::f("could work out", A_ThisHotkey, A_EndChar) 
:XB0:couldn't breath::f("couldn't breathe", A_ThisHotkey, A_EndChar) 
:XB0:countires::f("countries", A_ThisHotkey, A_EndChar)
:XB0:criteria is::f("criteria are", A_ThisHotkey, A_EndChar) 
:XB0:criteria was::f("criteria were", A_ThisHotkey, A_EndChar) 
:XB0:criterias::f("criteria", A_ThisHotkey, A_EndChar) 
:XB0:daed::f("dead", A_ThisHotkey, A_EndChar)
:XB0:daily regiment::f("daily regimen", A_ThisHotkey, A_EndChar) 
:XB0:dardenelles::f("Dardanelles", A_ThisHotkey, A_EndChar)
:XB0:darker then::f("darker than", A_ThisHotkey, A_EndChar) 
:XB0:deciding on how::f("deciding how", A_ThisHotkey, A_EndChar) 
:XB0:decomposit::f("decompose", A_ThisHotkey, A_EndChar) 
:XB0:decomposited::f("decomposed", A_ThisHotkey, A_EndChar) 
:XB0:decompositing::f("decomposing", A_ThisHotkey, A_EndChar) 
:XB0:decomposits::f("decomposes", A_ThisHotkey, A_EndChar) 
:XB0:decress::f("decrees", A_ThisHotkey, A_EndChar) 
:XB0:deep-seeded::f("deep-seated", A_ThisHotkey, A_EndChar) 
:XB0:delusionally::f("delusionary", A_ThisHotkey, A_EndChar) 
:XB0:demographical::f("demographic", A_ThisHotkey, A_EndChar) 
:XB0:depending of::f("depending on", A_ThisHotkey, A_EndChar) 
:XB0:depends of::f("depends on", A_ThisHotkey, A_EndChar) 
:XB0:deside::f("decide", A_ThisHotkey, A_EndChar) 
:XB0:despite of::f("despite", A_ThisHotkey, A_EndChar) 
:XB0:devels::f("delves", A_ThisHotkey, A_EndChar) 
:XB0:diamons::f("diamonds", A_ThisHotkey, A_EndChar)
:XB0:didint::f("didn't", A_ThisHotkey, A_EndChar) 
:XB0:didn't fair::f("didn't fare", A_ThisHotkey, A_EndChar) 
:XB0:didnot::f("did not", A_ThisHotkey, A_EndChar) 
:XB0:didnt::f("didn't", A_ThisHotkey, A_EndChar) 
:XB0:dieties::f("deities", A_ThisHotkey, A_EndChar)
:XB0:diety::f("deity", A_ThisHotkey, A_EndChar) 
:XB0:different tact::f("different tack", A_ThisHotkey, A_EndChar) 
:XB0:different to::f("different from", A_ThisHotkey, A_EndChar) 
:XB0:difficulity::f("difficulty", A_ThisHotkey, A_EndChar) 
:XB0:diffuse the::f("defuse the", A_ThisHotkey, A_EndChar) 
:XB0:direct affect::f("direct effect", A_ThisHotkey, A_EndChar) 
:XB0:discontentment::f("discontent", A_ThisHotkey, A_EndChar) 
:XB0:discus a::f("discuss a ", A_ThisHotkey, A_EndChar) 
:XB0:discus all::f("discuss all ", A_ThisHotkey, A_EndChar) 
:XB0:discus any::f("discuss any ", A_ThisHotkey, A_EndChar) 
:XB0:discus the::f("discuss the ", A_ThisHotkey, A_EndChar) 
:XB0:discus this::f("discuss this ", A_ThisHotkey, A_EndChar) 
:XB0:disparingly::f("disparagingly", A_ThisHotkey, A_EndChar)
:XB0:dispell::f("dispel", A_ThisHotkey, A_EndChar)
:XB0:dispells::f("dispels", A_ThisHotkey, A_EndChar) 
:XB0:do to::f("due to", A_ThisHotkey, A_EndChar) 
:XB0:docrines::f("doctrines", A_ThisHotkey, A_EndChar)
:XB0:doe snot::f("does not", A_ThisHotkey, A_EndChar) ; *could* be legitimate... but very unlikely!
:XB0:doen't::f("doesn't", A_ThisHotkey, A_EndChar) 
:XB0:dolling out::f("doling out", A_ThisHotkey, A_EndChar) 
:XB0:dominate player::f("dominant player", A_ThisHotkey, A_EndChar) 
:XB0:dominate role::f("dominant role", A_ThisHotkey, A_EndChar) 
:XB0:don't no::f("don't know", A_ThisHotkey, A_EndChar) 
:XB0:dont::f("don't", A_ThisHotkey, A_EndChar) 
:XB0:door jam::f("doorjamb", A_ThisHotkey, A_EndChar) 
:XB0:dosen't::f("doesn't", A_ThisHotkey, A_EndChar) 
:XB0:dosn't::f("doesn't", A_ThisHotkey, A_EndChar) 
:XB0:doub::f("doubt", A_ThisHotkey, A_EndChar) 
:XB0:down it's::f("down its", A_ThisHotkey, A_EndChar) 
:XB0:down side::f("downside", A_ThisHotkey, A_EndChar) 
:XB0:drunkeness::f("drunkenness", A_ThisHotkey, A_EndChar) 
:XB0:due to it's::f("due to its", A_ThisHotkey, A_EndChar) 
:XB0:dukeship::f("dukedom", A_ThisHotkey, A_EndChar) 
:XB0:dum::f("dumb", A_ThisHotkey, A_EndChar) 
:XB0:dumbell::f("dumbbell", A_ThisHotkey, A_EndChar) 
:XB0:during it's::f("during its", A_ThisHotkey, A_EndChar) 
:XB0:during they're::f("during their", A_ThisHotkey, A_EndChar) 
:XB0:each phenomena::f("each phenomenon", A_ThisHotkey, A_EndChar) 
:XB0:ealier::f("earlier", A_ThisHotkey, A_EndChar) 
:XB0:earlies::f("earliest", A_ThisHotkey, A_EndChar) 
:XB0:earnt::f("earned", A_ThisHotkey, A_EndChar) 
:XB0:ect::f("etc", A_ThisHotkey, A_EndChar) 
:XB0:eiter::f("either", A_ThisHotkey, A_EndChar) 
:XB0:elast::f("least", A_ThisHotkey, A_EndChar) 
:XB0:eles::f("eels", A_ThisHotkey, A_EndChar) 
:XB0:eluded to::f("alluded to", A_ThisHotkey, A_EndChar) 
:XB0:embargos::f("embargoes", A_ThisHotkey, A_EndChar) 
:XB0:embarras::f("embarrass", A_ThisHotkey, A_EndChar)
:XB0:en mass::f("en masse", A_ThisHotkey, A_EndChar) 
:XB0:enameld::f("enamelled", A_ThisHotkey, A_EndChar) 
:XB0:enought::f("enough", A_ThisHotkey, A_EndChar) 
:XB0:eventhough::f("even though", A_ThisHotkey, A_EndChar) 
:XB0:everthing::f("everything", A_ThisHotkey, A_EndChar) 
:XB0:everytime::f("every time", A_ThisHotkey, A_EndChar) 
:XB0:everyting::f("everything", A_ThisHotkey, A_EndChar) 
:XB0:excell::f("excel", A_ThisHotkey, A_EndChar)
:XB0:excells::f("excels", A_ThisHotkey, A_EndChar)
:XB0:exectued::f("executed", A_ThisHotkey, A_EndChar)
:XB0:exemple::f("example", A_ThisHotkey, A_EndChar)
:XB0:exerciese::f("exercises", A_ThisHotkey, A_EndChar)
:XB0:existince::f("existence", A_ThisHotkey, A_EndChar)
:XB0:expatriot::f("expatriate", A_ThisHotkey, A_EndChar)
:XB0:expeditonary::f("expeditionary", A_ThisHotkey, A_EndChar)
:XB0:expell::f("expel", A_ThisHotkey, A_EndChar)
:XB0:expells::f("expels", A_ThisHotkey, A_EndChar)
:XB0:experienc::f("experience", A_ThisHotkey, A_EndChar)
:XB0:explaning::f("explaining", A_ThisHotkey, A_EndChar)
:XB0:extered::f("exerted", A_ThisHotkey, A_EndChar)
:XB0:extermist::f("extremist", A_ThisHotkey, A_EndChar)
:XB0:extract punishment::f("exact punishment", A_ThisHotkey, A_EndChar)
:XB0:extract revenge::f("exact revenge", A_ThisHotkey, A_EndChar)
:XB0:extradiction::f("extradition", A_ThisHotkey, A_EndChar)
:XB0:extrememly::f("extremely", A_ThisHotkey, A_EndChar)
:XB0:extremeophile::f("extremophile", A_ThisHotkey, A_EndChar)
:XB0:extremly::f("extremely", A_ThisHotkey, A_EndChar)
:XB0:eyasr::f("years", A_ThisHotkey, A_EndChar)
:XB0:eye brow::f("eyebrow", A_ThisHotkey, A_EndChar)
:XB0:eye lash::f("eyelash", A_ThisHotkey, A_EndChar)
:XB0:eye lid::f("eyelid", A_ThisHotkey, A_EndChar)
:XB0:eye sight::f("eyesight", A_ThisHotkey, A_EndChar)
:XB0:eye sore::f("eyesore", A_ThisHotkey, A_EndChar)
:XB0:eyt::f("yet", A_ThisHotkey, A_EndChar)
:XB0:facia::f("fascia", A_ThisHotkey, A_EndChar)
:XB0:facilites::f("facilities", A_ThisHotkey, A_EndChar)
:XB0:faired as well::f("fared as well", A_ThisHotkey, A_EndChar)
:XB0:faired badly::f("fared badly", A_ThisHotkey, A_EndChar)
:XB0:faired better::f("fared better", A_ThisHotkey, A_EndChar)
:XB0:faired far::f("fared far", A_ThisHotkey, A_EndChar)
:XB0:faired less::f("fared less", A_ThisHotkey, A_EndChar)
:XB0:faired little::f("fared little", A_ThisHotkey, A_EndChar)
:XB0:faired much::f("fared much", A_ThisHotkey, A_EndChar)
:XB0:faired no better::f("fared no better", A_ThisHotkey, A_EndChar)
:XB0:faired poorly::f("fared poorly", A_ThisHotkey, A_EndChar)
:XB0:faired quite::f("fared quite", A_ThisHotkey, A_EndChar)
:XB0:faired rather::f("fared rather", A_ThisHotkey, A_EndChar)
:XB0:faired slightly::f("fared slightly", A_ThisHotkey, A_EndChar)
:XB0:faired somewhat::f("fared somewhat", A_ThisHotkey, A_EndChar)
:XB0:faired well::f("fared well", A_ThisHotkey, A_EndChar)
:XB0:faired worse::f("fared worse", A_ThisHotkey, A_EndChar)
:XB0:familes::f("families", A_ThisHotkey, A_EndChar)
:XB0:fanatism::f("fanaticism", A_ThisHotkey, A_EndChar)
:XB0:farenheit::f("Fahrenheit", A_ThisHotkey, A_EndChar)
:XB0:farther then::f("farther than", A_ThisHotkey, A_EndChar)
:XB0:faster then::f("faster than", A_ThisHotkey, A_EndChar)
:XB0:febuary::f("February", A_ThisHotkey, A_EndChar)
:XB0:femail::f("female", A_ThisHotkey, A_EndChar)
:XB0:feromone::f("pheromone", A_ThisHotkey, A_EndChar)
:XB0:fianlly::f("finally", A_ThisHotkey, A_EndChar)
:XB0:ficed::f("fixed", A_ThisHotkey, A_EndChar)
:XB0:fiercly::f("fiercely", A_ThisHotkey, A_EndChar)
:XB0:fightings::f("fighting", A_ThisHotkey, A_EndChar)
:XB0:figure head::f("figurehead", A_ThisHotkey, A_EndChar)
:XB0:filled a lawsuit::f("filed a lawsuit", A_ThisHotkey, A_EndChar)
:XB0:finaly::f("finally", A_ThisHotkey, A_EndChar)
:XB0:firey::f("fiery", A_ThisHotkey, A_EndChar)
:XB0:flag ship::f("flagship", A_ThisHotkey, A_EndChar)
:XB0:flemmish::f("Flemish", A_ThisHotkey, A_EndChar)
:XB0:florescent::f("fluorescent", A_ThisHotkey, A_EndChar)
:XB0:flourescent::f("fluorescent", A_ThisHotkey, A_EndChar)
:XB0:fo::f("of", A_ThisHotkey, A_EndChar)
:XB0:follow suite::f("follow suit", A_ThisHotkey, A_EndChar)
:XB0:following it's::f("following its", A_ThisHotkey, A_EndChar)
:XB0:for all intensive purposes::f("for all intents and purposes", A_ThisHotkey, A_EndChar)
:XB0:for along time::f("for a long time", A_ThisHotkey, A_EndChar)
:XB0:for awhile::f("for a while", A_ThisHotkey, A_EndChar)
:XB0:for he and::f("for him and", A_ThisHotkey, A_EndChar)
:XB0:for quite awhile::f("for quite a while", A_ThisHotkey, A_EndChar)
:XB0:for way it's::f("for what it's", A_ThisHotkey, A_EndChar)
:XB0:fora::f("for a", A_ThisHotkey, A_EndChar)
:XB0:forbad::f("forbade", A_ThisHotkey, A_EndChar)
:XB0:fore ground::f("foreground", A_ThisHotkey, A_EndChar)
:XB0:forego her::f("forgo her", A_ThisHotkey, A_EndChar)
:XB0:forego his::f("forgo his", A_ThisHotkey, A_EndChar)
:XB0:forego their::f("forgo their", A_ThisHotkey, A_EndChar)
:XB0:foreward::f("foreword", A_ThisHotkey, A_EndChar)
:XB0:forgone conclusion::f("foregone conclusion", A_ThisHotkey, A_EndChar)
:XB0:formalhaut::f("Fomalhaut", A_ThisHotkey, A_EndChar)
:XB0:formelly::f("formerly", A_ThisHotkey, A_EndChar)
:XB0:forsaw::f("foresaw", A_ThisHotkey, A_EndChar)
:XB0:forunner::f("forerunner", A_ThisHotkey, A_EndChar)
:XB0:free reign::f("free rein", A_ThisHotkey, A_EndChar)
:XB0:fro::f("for", A_ThisHotkey, A_EndChar)
:XB0:frome::f("from", A_ThisHotkey, A_EndChar)
:XB0:fromt he::f("from the", A_ThisHotkey, A_EndChar)
:XB0:fulfil::f("fulfill", A_ThisHotkey, A_EndChar)
:XB0:fulfiled::f("fulfilled", A_ThisHotkey, A_EndChar)
:XB0:full compliment of::f("full complement of", A_ThisHotkey, A_EndChar)
:XB0:funguses::f("fungi", A_ThisHotkey, A_EndChar)
:XB0:gae::f("game", A_ThisHotkey, A_EndChar)
:XB0:galatic::f("galactic", A_ThisHotkey, A_EndChar)
:XB0:galations::f("Galatians", A_ThisHotkey, A_EndChar)
:XB0:gameboy::f("Game Boy", A_ThisHotkey, A_EndChar)
:XB0:ganes::f("games", A_ThisHotkey, A_EndChar)
:XB0:gauarana::f("guarana", A_ThisHotkey, A_EndChar)
:XB0:gave advise::f("gave advice", A_ThisHotkey, A_EndChar)
:XB0:genialia::f("genitalia", A_ThisHotkey, A_EndChar)
:XB0:gentlemens::f("gentlemen's", A_ThisHotkey, A_EndChar)
:XB0:get setup::f("get set up", A_ThisHotkey, A_EndChar)
:XB0:get use to::f("get used to", A_ThisHotkey, A_EndChar)
:XB0:geting::f("getting", A_ThisHotkey, A_EndChar)
:XB0:gets it's::f("gets its", A_ThisHotkey, A_EndChar)
:XB0:getting use to::f("getting used to", A_ThisHotkey, A_EndChar)
:XB0:ghandi::f("Gandhi", A_ThisHotkey, A_EndChar)
:XB0:give advise::f("give advice", A_ThisHotkey, A_EndChar)
:XB0:gives advise::f("gives advice", A_ThisHotkey, A_EndChar)
:XB0:glamourous::f("glamorous", A_ThisHotkey, A_EndChar)
:XB0:godd::f("good", A_ThisHotkey, A_EndChar)
:XB0:going threw::f("going through", A_ThisHotkey, A_EndChar)
:XB0:got ran::f("got run", A_ThisHotkey, A_EndChar)
:XB0:got setup::f("got set up", A_ThisHotkey, A_EndChar)
:XB0:got shutdown::f("got shut down", A_ThisHotkey, A_EndChar)
:XB0:got shutout::f("got shut out", A_ThisHotkey, A_EndChar)
:XB0:grammer::f("grammar", A_ThisHotkey, A_EndChar)
:XB0:grat::f("great", A_ThisHotkey, A_EndChar)
:XB0:greater then::f("greater than", A_ThisHotkey, A_EndChar)
:XB0:greif::f("grief", A_ThisHotkey, A_EndChar)
:XB0:ground work::f("groundwork", A_ThisHotkey, A_EndChar)
:XB0:guadulupe::f("Guadalupe", A_ThisHotkey, A_EndChar)
:XB0:guatamala::f("Guatemala", A_ThisHotkey, A_EndChar)
:XB0:guatamalan::f("Guatemalan", A_ThisHotkey, A_EndChar)
:XB0:guest stared::f("guest-starred", A_ThisHotkey, A_EndChar)
:XB0:guilia::f("Giulia", A_ThisHotkey, A_EndChar)
:XB0:guiliani::f("Giuliani", A_ThisHotkey, A_EndChar)
:XB0:guilio::f("Giulio", A_ThisHotkey, A_EndChar)
:XB0:guiness::f("Guinness", A_ThisHotkey, A_EndChar)
:XB0:guiseppe::f("Giuseppe", A_ThisHotkey, A_EndChar)
:XB0:gunanine::f("guanine", A_ThisHotkey, A_EndChar) ; It's in bat poop.  LOL
:XB0:gusy::f("guys", A_ThisHotkey, A_EndChar)
:XB0:habaeus::f("habeas", A_ThisHotkey, A_EndChar)
:XB0:habeus::f("habeas", A_ThisHotkey, A_EndChar)
:XB0:habsbourg::f("Habsburg", A_ThisHotkey, A_EndChar)
:XB0:had arose::f("had arisen", A_ThisHotkey, A_EndChar)
:XB0:had awoke::f("had awoken", A_ThisHotkey, A_EndChar)
:XB0:had became::f("had become", A_ThisHotkey, A_EndChar)
:XB0:had began::f("had begun", A_ThisHotkey, A_EndChar)
:XB0:had being::f("had been", A_ThisHotkey, A_EndChar)
:XB0:had broke::f("had broken", A_ThisHotkey, A_EndChar)
:XB0:had brung::f("had brought", A_ThisHotkey, A_EndChar)
:XB0:had came::f("had come", A_ThisHotkey, A_EndChar)
:XB0:had chose::f("had chosen", A_ThisHotkey, A_EndChar)
:XB0:had comeback::f("had come back", A_ThisHotkey, A_EndChar)
:XB0:had cut-off::f("had cut off", A_ThisHotkey, A_EndChar)
:XB0:had did::f("had done", A_ThisHotkey, A_EndChar)
:XB0:had drank::f("had drunk", A_ThisHotkey, A_EndChar)
:XB0:had drew::f("had drawn", A_ThisHotkey, A_EndChar)
:XB0:had drove::f("had driven", A_ThisHotkey, A_EndChar)
:XB0:had fell::f("had fallen", A_ThisHotkey, A_EndChar)
:XB0:had flew::f("had flown", A_ThisHotkey, A_EndChar)
:XB0:had forbad::f("had forbidden", A_ThisHotkey, A_EndChar)
:XB0:had forbade::f("had forbidden", A_ThisHotkey, A_EndChar)
:XB0:had gave::f("had given", A_ThisHotkey, A_EndChar)
:XB0:had grew::f("had grown", A_ThisHotkey, A_EndChar)
:XB0:had it's::f("had its", A_ThisHotkey, A_EndChar)
:XB0:had knew::f("had known", A_ThisHotkey, A_EndChar)
:XB0:had know::f("had known", A_ThisHotkey, A_EndChar)
:XB0:had lead for::f("had led for", A_ThisHotkey, A_EndChar)
:XB0:had lead the::f("had led the", A_ThisHotkey, A_EndChar)
:XB0:had lead to::f("had led to", A_ThisHotkey, A_EndChar)
:XB0:had meet::f("had met", A_ThisHotkey, A_EndChar)
:XB0:had mislead::f("had misled", A_ThisHotkey, A_EndChar)
:XB0:had overcame::f("had overcome", A_ThisHotkey, A_EndChar)
:XB0:had overran::f("had overrun", A_ThisHotkey, A_EndChar)
:XB0:had overtook::f("had overtaken", A_ThisHotkey, A_EndChar)
:XB0:had plead::f("had pleaded", A_ThisHotkey, A_EndChar)
:XB0:had ran::f("had run", A_ThisHotkey, A_EndChar)
:XB0:had rang::f("had rung", A_ThisHotkey, A_EndChar)
:XB0:had rode::f("had ridden", A_ThisHotkey, A_EndChar)
:XB0:had runaway::f("had run away", A_ThisHotkey, A_EndChar)
:XB0:had sang::f("had sung", A_ThisHotkey, A_EndChar)
:XB0:had send::f("had sent", A_ThisHotkey, A_EndChar)
:XB0:had set-up::f("had set up", A_ThisHotkey, A_EndChar)
:XB0:had setup::f("had set up", A_ThisHotkey, A_EndChar)
:XB0:had shook::f("had shaken", A_ThisHotkey, A_EndChar)
:XB0:had shut-down::f("had shut down", A_ThisHotkey, A_EndChar)
:XB0:had shutdown::f("had shut down", A_ThisHotkey, A_EndChar)
:XB0:had shutout::f("had shut out", A_ThisHotkey, A_EndChar)
:XB0:had sowed::f("had sown", A_ThisHotkey, A_EndChar)
:XB0:had spend::f("had spent", A_ThisHotkey, A_EndChar)
:XB0:had spoke::f("had spoken", A_ThisHotkey, A_EndChar)
:XB0:had sprang::f("had sprung", A_ThisHotkey, A_EndChar)
:XB0:had swam::f("had swum", A_ThisHotkey, A_EndChar)
:XB0:had threw::f("had thrown", A_ThisHotkey, A_EndChar)
:XB0:had throve::f("had thriven", A_ThisHotkey, A_EndChar)
:XB0:had thunk::f("had thought", A_ThisHotkey, A_EndChar)
:XB0:had to much::f("had too much", A_ThisHotkey, A_EndChar)
:XB0:had to used::f("had to use", A_ThisHotkey, A_EndChar)
:XB0:had took::f("had taken", A_ThisHotkey, A_EndChar)
:XB0:had tore::f("had torn", A_ThisHotkey, A_EndChar)
:XB0:had undertook::f("had undertaken", A_ThisHotkey, A_EndChar)
:XB0:had underwent::f("had undergone", A_ThisHotkey, A_EndChar)
:XB0:had went::f("had gone", A_ThisHotkey, A_EndChar)
:XB0:had woke::f("had woken", A_ThisHotkey, A_EndChar)
:XB0:had wore::f("had worn", A_ThisHotkey, A_EndChar)
:XB0:had wrote::f("had written", A_ThisHotkey, A_EndChar)
:XB0:hadbeen::f("had been", A_ThisHotkey, A_EndChar)
:XB0:hadn't went::f("hadn't gone", A_ThisHotkey, A_EndChar)
:XB0:haev::f("have", A_ThisHotkey, A_EndChar)
:XB0:half and hour::f("half an hour", A_ThisHotkey, A_EndChar)
:XB0:hallowean::f("Halloween", A_ThisHotkey, A_EndChar)
:XB0:hand the reigns::f("hand the reins", A_ThisHotkey, A_EndChar)
:XB0:happend::f("happened", A_ThisHotkey, A_EndChar)
:XB0:happended::f("happened", A_ThisHotkey, A_EndChar)
:XB0:happenned::f("happened", A_ThisHotkey, A_EndChar)
:XB0:harases::f("harasses", A_ThisHotkey, A_EndChar)
:XB0:has arose::f("has arisen", A_ThisHotkey, A_EndChar)
:XB0:has awoke::f("has awoken", A_ThisHotkey, A_EndChar)
:XB0:has bore::f("has borne", A_ThisHotkey, A_EndChar)
:XB0:has broke::f("has broken", A_ThisHotkey, A_EndChar)
:XB0:has brung::f("has brought", A_ThisHotkey, A_EndChar)
:XB0:has build::f("has built", A_ThisHotkey, A_EndChar)
:XB0:has came::f("has come", A_ThisHotkey, A_EndChar)
:XB0:has chose::f("has chosen", A_ThisHotkey, A_EndChar)
:XB0:has cut-off::f("has cut off", A_ThisHotkey, A_EndChar)
:XB0:has did::f("has done", A_ThisHotkey, A_EndChar)
:XB0:has drank::f("has drunk", A_ThisHotkey, A_EndChar)
:XB0:has drew::f("has drawn", A_ThisHotkey, A_EndChar)
:XB0:has drove::f("has driven", A_ThisHotkey, A_EndChar)
:XB0:has fell::f("has fallen", A_ThisHotkey, A_EndChar)
:XB0:has flew::f("has flown", A_ThisHotkey, A_EndChar)
:XB0:has forbad::f("has forbidden", A_ThisHotkey, A_EndChar)
:XB0:has forbade::f("has forbidden", A_ThisHotkey, A_EndChar)
:XB0:has gave::f("has given", A_ThisHotkey, A_EndChar)
:XB0:has having::f("as having", A_ThisHotkey, A_EndChar)
:XB0:has it's::f("has its", A_ThisHotkey, A_EndChar)
:XB0:has lead the::f("has led the", A_ThisHotkey, A_EndChar)
:XB0:has lead to::f("has led to", A_ThisHotkey, A_EndChar)
:XB0:has meet::f("has met", A_ThisHotkey, A_EndChar)
:XB0:has mislead::f("has misled", A_ThisHotkey, A_EndChar)
:XB0:has overcame::f("has overcome", A_ThisHotkey, A_EndChar)
:XB0:has plead::f("has pleaded", A_ThisHotkey, A_EndChar)
:XB0:has ran::f("has run", A_ThisHotkey, A_EndChar)
:XB0:has rang::f("has rung", A_ThisHotkey, A_EndChar)
:XB0:has sang::f("has sung", A_ThisHotkey, A_EndChar)
:XB0:has set-up::f("has set up", A_ThisHotkey, A_EndChar)
:XB0:has setup::f("has set up", A_ThisHotkey, A_EndChar)
:XB0:has shook::f("has shaken", A_ThisHotkey, A_EndChar)
:XB0:has spoke::f("has spoken", A_ThisHotkey, A_EndChar)
:XB0:has sprang::f("has sprung", A_ThisHotkey, A_EndChar)
:XB0:has swam::f("has swum", A_ThisHotkey, A_EndChar)
:XB0:has threw::f("has thrown", A_ThisHotkey, A_EndChar)
:XB0:has throve::f("has thrived", A_ThisHotkey, A_EndChar)
:XB0:has thunk::f("has thought", A_ThisHotkey, A_EndChar)
:XB0:has took::f("has taken", A_ThisHotkey, A_EndChar)
:XB0:has trod::f("has trodden", A_ThisHotkey, A_EndChar)
:XB0:has undertook::f("has undertaken", A_ThisHotkey, A_EndChar)
:XB0:has underwent::f("has undergone", A_ThisHotkey, A_EndChar)
:XB0:has went::f("has gone", A_ThisHotkey, A_EndChar)
:XB0:has woke::f("has woken", A_ThisHotkey, A_EndChar)
:XB0:has wrote::f("has written", A_ThisHotkey, A_EndChar)
:XB0:hasbeen::f("has been", A_ThisHotkey, A_EndChar)
:XB0:hasnt::f("hasn't", A_ThisHotkey, A_EndChar)
:XB0:have drank::f("have drunk", A_ThisHotkey, A_EndChar)
:XB0:have it's::f("have its", A_ThisHotkey, A_EndChar)
:XB0:have lead to::f("have led to", A_ThisHotkey, A_EndChar)
:XB0:have mislead::f("have misled", A_ThisHotkey, A_EndChar)
:XB0:have ran::f("have run", A_ThisHotkey, A_EndChar)
:XB0:have rang::f("have rung", A_ThisHotkey, A_EndChar)
:XB0:have sang::f("have sung", A_ThisHotkey, A_EndChar)
:XB0:have setup::f("have set up", A_ThisHotkey, A_EndChar)
:XB0:have sprang::f("have sprung", A_ThisHotkey, A_EndChar)
:XB0:have swam::f("have swum", A_ThisHotkey, A_EndChar)
:XB0:have took::f("have taken", A_ThisHotkey, A_EndChar)
:XB0:have underwent::f("have undergone", A_ThisHotkey, A_EndChar)
:XB0:have went::f("have gone", A_ThisHotkey, A_EndChar)
:XB0:havebeen::f("have been", A_ThisHotkey, A_EndChar)
:XB0:haviest::f("heaviest", A_ThisHotkey, A_EndChar)
:XB0:having became::f("having become", A_ThisHotkey, A_EndChar)
:XB0:having began::f("having begun", A_ThisHotkey, A_EndChar)
:XB0:having being::f("having been", A_ThisHotkey, A_EndChar)
:XB0:having it's::f("having its", A_ThisHotkey, A_EndChar)
:XB0:having ran::f("having run", A_ThisHotkey, A_EndChar)
:XB0:having sang::f("having sung", A_ThisHotkey, A_EndChar)
:XB0:having setup::f("having set up", A_ThisHotkey, A_EndChar)
:XB0:having swam::f("having swum", A_ThisHotkey, A_EndChar)
:XB0:having took::f("having taken", A_ThisHotkey, A_EndChar)
:XB0:having underwent::f("having undergone", A_ThisHotkey, A_EndChar)
:XB0:having went::f("having gone", A_ThisHotkey, A_EndChar)
:XB0:hay day::f("heyday", A_ThisHotkey, A_EndChar)
:XB0:he begun::f("he began", A_ThisHotkey, A_EndChar)
:XB0:he let's::f("he lets", A_ThisHotkey, A_EndChar)
:XB0:he plead::f("he pleaded", A_ThisHotkey, A_EndChar)
:XB0:he seen::f("he saw", A_ThisHotkey, A_EndChar)
:XB0:he use to::f("he used to", A_ThisHotkey, A_EndChar)
:XB0:he's drank::f("he drank", A_ThisHotkey, A_EndChar)
:XB0:head gear::f("headgear", A_ThisHotkey, A_EndChar)
:XB0:head quarters::f("headquarters", A_ThisHotkey, A_EndChar)
:XB0:head stone::f("headstone", A_ThisHotkey, A_EndChar)
:XB0:head wear::f("headwear", A_ThisHotkey, A_EndChar)
:XB0:healthercare::f("healthcare", A_ThisHotkey, A_EndChar)
:XB0:heared::f("heard", A_ThisHotkey, A_EndChar)
:XB0:heathy::f("healthy", A_ThisHotkey, A_EndChar)
:XB0:heidelburg::f("Heidelberg", A_ThisHotkey, A_EndChar)
:XB0:heigher::f("higher", A_ThisHotkey, A_EndChar)
:XB0:held the reigns::f("held the reins", A_ThisHotkey, A_EndChar)
:XB0:helf::f("held", A_ThisHotkey, A_EndChar)
:XB0:hellow::f("hello", A_ThisHotkey, A_EndChar)
:XB0:help and make::f("help to make", A_ThisHotkey, A_EndChar)
:XB0:helpfull::f("helpful", A_ThisHotkey, A_EndChar)
:XB0:herf::f("href", A_ThisHotkey, A_EndChar) 
:XB0:heroe::f("hero", A_ThisHotkey, A_EndChar)
:XB0:heros::f("heroes", A_ThisHotkey, A_EndChar)
:XB0:hersuit::f("hirsute", A_ThisHotkey, A_EndChar)
:XB0:hesaid::f("he said", A_ThisHotkey, A_EndChar)
:XB0:heterogenous::f("heterogeneous", A_ThisHotkey, A_EndChar)
:XB0:hewas::f("he was", A_ThisHotkey, A_EndChar)
:XB0:hier::f("heir", A_ThisHotkey, A_EndChar)
:XB0:higer::f("higher", A_ThisHotkey, A_EndChar)
:XB0:higest::f("highest", A_ThisHotkey, A_EndChar)
:XB0:higher then::f("higher than", A_ThisHotkey, A_EndChar)
:XB0:himselv::f("himself", A_ThisHotkey, A_EndChar)
:XB0:hinderance::f("hindrance", A_ThisHotkey, A_EndChar)
:XB0:hinderence::f("hindrance", A_ThisHotkey, A_EndChar)
:XB0:hindrence::f("hindrance", A_ThisHotkey, A_EndChar)
:XB0:hipopotamus::f("hippopotamus", A_ThisHotkey, A_EndChar)
:XB0:his resent::f("his recent", A_ThisHotkey, A_EndChar) ; not good for 'her' 
:XB0:hismelf::f("himself", A_ThisHotkey, A_EndChar)
:XB0:hit the breaks::f("hit the brakes", A_ThisHotkey, A_EndChar)
:XB0:hitsingles::f("hit singles", A_ThisHotkey, A_EndChar)
:XB0:hold onto::f("hold on to", A_ThisHotkey, A_EndChar)
:XB0:hold the reigns::f("hold the reins", A_ThisHotkey, A_EndChar)
:XB0:holding the reigns::f("holding the reins", A_ThisHotkey, A_EndChar)
:XB0:holds the reigns::f("holds the reins", A_ThisHotkey, A_EndChar)
:XB0:homestate::f("home state", A_ThisHotkey, A_EndChar)
:XB0:hone in on::f("home in on", A_ThisHotkey, A_EndChar)
:XB0:honed in::f("homed in", A_ThisHotkey, A_EndChar)
:XB0:honory::f("honorary", A_ThisHotkey, A_EndChar)
:XB0:honourarium::f("honorarium", A_ThisHotkey, A_EndChar)
:XB0:honourific::f("honorific", A_ThisHotkey, A_EndChar)
:XB0:hotter then::f("hotter than", A_ThisHotkey, A_EndChar)
:XB0:house hold::f("household", A_ThisHotkey, A_EndChar)
:XB0:housr::f("hours", A_ThisHotkey, A_EndChar)
:XB0:how ever::f("however", A_ThisHotkey, A_EndChar)
:XB0:howver::f("however", A_ThisHotkey, A_EndChar)
:XB0:http:\\::f("http://", A_ThisHotkey, A_EndChar) 
:XB0:httpL::f("http:", A_ThisHotkey, A_EndChar) 
:XB0:humer::f("humor", A_ThisHotkey, A_EndChar)
:XB0:huminoid::f("humanoid", A_ThisHotkey, A_EndChar)
:XB0:humoural::f("humoral", A_ThisHotkey, A_EndChar)
:XB0:husban::f("husband", A_ThisHotkey, A_EndChar)
:XB0:hydropile::f("hydrophile", A_ThisHotkey, A_EndChar)
:XB0:hydropilic::f("hydrophilic", A_ThisHotkey, A_EndChar)
:XB0:hydropobe::f("hydrophobe", A_ThisHotkey, A_EndChar)
:XB0:hydropobic::f("hydrophobic", A_ThisHotkey, A_EndChar)
:XB0:hypocracy::f("hypocrisy", A_ThisHotkey, A_EndChar)
:XB0:hypocrasy::f("hypocrisy", A_ThisHotkey, A_EndChar)
:XB0:hypocricy::f("hypocrisy", A_ThisHotkey, A_EndChar)
:XB0:hypocrit::f("hypocrite", A_ThisHotkey, A_EndChar)
:XB0:hypocrits::f("hypocrites", A_ThisHotkey, A_EndChar)
:XB0:i snot::f("is not", A_ThisHotkey, A_EndChar)
:XB0:i"m::f("I'm", A_ThisHotkey, A_EndChar)
:XB0:i;d::f("I'd", A_ThisHotkey, A_EndChar)
:XB0:idealogy::f("ideology", A_ThisHotkey, A_EndChar)
:XB0:identifers::f("identifiers", A_ThisHotkey, A_EndChar)
:XB0:ideosyncratic::f("idiosyncratic", A_ThisHotkey, A_EndChar)
:XB0:idesa::f("ideas", A_ThisHotkey, A_EndChar)
:XB0:idiosyncracy::f("idiosyncrasy", A_ThisHotkey, A_EndChar)
:XB0:if is::f("it is", A_ThisHotkey, A_EndChar)
:XB0:if was::f("it was", A_ThisHotkey, A_EndChar)
:XB0:ifb y::f("if by", A_ThisHotkey, A_EndChar)
:XB0:ifi t::f("if it", A_ThisHotkey, A_EndChar)
:XB0:ift he::f("if the", A_ThisHotkey, A_EndChar)
:XB0:ift hey::f("if they", A_ThisHotkey, A_EndChar)
:XB0:ignorence::f("ignorance", A_ThisHotkey, A_EndChar)
:XB0:ihaca::f("Ithaca", A_ThisHotkey, A_EndChar)
:XB0:iits the::f("it's the", A_ThisHotkey, A_EndChar)
:XB0:illess::f("illness", A_ThisHotkey, A_EndChar)
:XB0:illicited::f("elicited", A_ThisHotkey, A_EndChar)
:XB0:ilness::f("illness", A_ThisHotkey, A_EndChar)
:XB0:imagin::f("imagine", A_ThisHotkey, A_EndChar)
:XB0:imaginery::f("imaginary", A_ThisHotkey, A_EndChar)
:XB0:imminent domain::f("eminent domain", A_ThisHotkey, A_EndChar)
:XB0:impedence::f("impedance", A_ThisHotkey, A_EndChar)
:XB0:in affect::f("in effect", A_ThisHotkey, A_EndChar)
:XB0:in along time::f("in a long time", A_ThisHotkey, A_EndChar)
:XB0:in anyway::f("in any way", A_ThisHotkey, A_EndChar)
:XB0:in awhile::f("in a while", A_ThisHotkey, A_EndChar)
:XB0:in edition to::f("in addition to", A_ThisHotkey, A_EndChar)
:XB0:in lu of::f("in lieu of", A_ThisHotkey, A_EndChar)
:XB0:in masse::f("en masse", A_ThisHotkey, A_EndChar)
:XB0:in parenthesis::f("in parentheses", A_ThisHotkey, A_EndChar)
:XB0:in placed::f("in place", A_ThisHotkey, A_EndChar)
:XB0:in principal::f("in principle", A_ThisHotkey, A_EndChar)
:XB0:in quite awhile::f("in quite a while", A_ThisHotkey, A_EndChar)
:XB0:in regards to::f("in regard to", A_ThisHotkey, A_EndChar)
:XB0:in stead of::f("instead of", A_ThisHotkey, A_EndChar)
:XB0:in tact::f("intact", A_ThisHotkey, A_EndChar)
:XB0:in the long-term::f("in the long term", A_ThisHotkey, A_EndChar)
:XB0:in the short-term::f("in the short term", A_ThisHotkey, A_EndChar)
:XB0:in titled::f("entitled", A_ThisHotkey, A_EndChar)
:XB0:in vein::f("in vain", A_ThisHotkey, A_EndChar)
:XB0:inbetween::f("between", A_ThisHotkey, A_EndChar)
:XB0:incase of::f("in case of", A_ThisHotkey, A_EndChar)
:XB0:incidently::f("incidentally", A_ThisHotkey, A_EndChar)
:XB0:incuding::f("including", A_ThisHotkey, A_EndChar)
:XB0:indentical::f("identical", A_ThisHotkey, A_EndChar)
:XB0:indictement::f("indictment", A_ThisHotkey, A_EndChar)
:XB0:infact::f("in fact", A_ThisHotkey, A_EndChar)
:XB0:infered::f("inferred", A_ThisHotkey, A_EndChar)
:XB0:infinit::f("infinite", A_ThisHotkey, A_EndChar)
:XB0:influented::f("influenced", A_ThisHotkey, A_EndChar)
:XB0:ingreediants::f("ingredients", A_ThisHotkey, A_EndChar)
:XB0:inperson::f("in-person", A_ThisHotkey, A_EndChar)
:XB0:insectiverous::f("insectivorous", A_ThisHotkey, A_EndChar)
:XB0:inspite::f("in spite", A_ThisHotkey, A_EndChar)
:XB0:int he::f("in the", A_ThisHotkey, A_EndChar)
:XB0:inteh::f("in the", A_ThisHotkey, A_EndChar)
:XB0:interbread::f("interbred", A_ThisHotkey, A_EndChar)
:XB0:intered::f("interred", A_ThisHotkey, A_EndChar)
:XB0:interm::f("interim", A_ThisHotkey, A_EndChar)
:XB0:internation::f("international", A_ThisHotkey, A_EndChar)
:XB0:interrim::f("interim", A_ThisHotkey, A_EndChar)
:XB0:interrugum::f("interregnum", A_ThisHotkey, A_EndChar)
:XB0:interum::f("interim", A_ThisHotkey, A_EndChar)
:XB0:intervines::f("intervenes", A_ThisHotkey, A_EndChar)
:XB0:into affect::f("into effect", A_ThisHotkey, A_EndChar)
:XB0:into it's::f("into its", A_ThisHotkey, A_EndChar)
:XB0:introdued::f("introduced", A_ThisHotkey, A_EndChar)
:XB0:inwhich::f("in which", A_ThisHotkey, A_EndChar)
:XB0:irregardless::f("regardless", A_ThisHotkey, A_EndChar)
:XB0:is also know::f("is also known", A_ThisHotkey, A_EndChar)
:XB0:is consider::f("is considered", A_ThisHotkey, A_EndChar)
:XB0:is front of::f("in front of", A_ThisHotkey, A_EndChar)
:XB0:is it's::f("is its", A_ThisHotkey, A_EndChar)
:XB0:is know::f("is known", A_ThisHotkey, A_EndChar)
:XB0:is lead by::f("is led by", A_ThisHotkey, A_EndChar)
:XB0:is loathe to::f("is loath to", A_ThisHotkey, A_EndChar)
:XB0:is ran by::f("is run by", A_ThisHotkey, A_EndChar)
:XB0:is renown for::f("is renowned for", A_ThisHotkey, A_EndChar)
:XB0:is schedule to::f("is scheduled to", A_ThisHotkey, A_EndChar)
:XB0:is set-up::f("is set up", A_ThisHotkey, A_EndChar)
:XB0:is setup::f("is set up", A_ThisHotkey, A_EndChar)
:XB0:is use to::f("is used to", A_ThisHotkey, A_EndChar)
:XB0:is were::f("is where", A_ThisHotkey, A_EndChar)
:XB0:isnt::f("isn't", A_ThisHotkey, A_EndChar)
:XB0:it begun::f("it began", A_ThisHotkey, A_EndChar)
:XB0:it lead to::f("it led to", A_ThisHotkey, A_EndChar)
:XB0:it self::f("itself", A_ThisHotkey, A_EndChar)
:XB0:it set-up::f("it set up", A_ThisHotkey, A_EndChar)
:XB0:it setup::f("it set up", A_ThisHotkey, A_EndChar)
:XB0:it snot::f("it's not", A_ThisHotkey, A_EndChar)
:XB0:it spend::f("it spent", A_ThisHotkey, A_EndChar)
:XB0:it use to::f("it used to", A_ThisHotkey, A_EndChar)
:XB0:it was her who::f("it was she who", A_ThisHotkey, A_EndChar)
:XB0:it was him who::f("it was he who", A_ThisHotkey, A_EndChar)
:XB0:it weighted::f("it weighed", A_ThisHotkey, A_EndChar)
:XB0:it weights::f("it weighs", A_ThisHotkey, A_EndChar)
:XB0:it' snot::f("it's not", A_ThisHotkey, A_EndChar)
:XB0:it's current::f("its current", A_ThisHotkey, A_EndChar)
:XB0:it's end::f("its end", A_ThisHotkey, A_EndChar)
:XB0:it's entire::f("its entire", A_ThisHotkey, A_EndChar)
:XB0:it's entirety::f("its entirety", A_ThisHotkey, A_EndChar)
:XB0:it's final::f("its final", A_ThisHotkey, A_EndChar)
:XB0:it's first::f("its first", A_ThisHotkey, A_EndChar)
:XB0:it's former::f("its former", A_ThisHotkey, A_EndChar)
:XB0:it's goal::f("its goal", A_ThisHotkey, A_EndChar)
:XB0:it's name::f("its name", A_ThisHotkey, A_EndChar)
:XB0:it's own::f("its own", A_ThisHotkey, A_EndChar)
:XB0:it's performance::f("its performance", A_ThisHotkey, A_EndChar)
:XB0:it's source::f("its source", A_ThisHotkey, A_EndChar)
:XB0:it's successor::f("its successor", A_ThisHotkey, A_EndChar)
:XB0:it's tail::f("its tail", A_ThisHotkey, A_EndChar)
:XB0:it's test::f("its test", A_ThisHotkey, A_EndChar)
:XB0:it's theme::f("its theme", A_ThisHotkey, A_EndChar)
:XB0:it's timeslot::f("its timeslot", A_ThisHotkey, A_EndChar)
:XB0:it's toll::f("its toll", A_ThisHotkey, A_EndChar)
:XB0:it's total::f("its total", A_ThisHotkey, A_EndChar)
:XB0:it's user::f("its user", A_ThisHotkey, A_EndChar)
:XB0:it's website::f("its website", A_ThisHotkey, A_EndChar)
:XB0:itis::f("it is", A_ThisHotkey, A_EndChar)
:XB0:its a::f("it's a", A_ThisHotkey, A_EndChar)
:XB0:its the::f("it's the", A_ThisHotkey, A_EndChar)
:XB0:itwas::f("it was", A_ThisHotkey, A_EndChar)
:XB0:iunior::f("junior", A_ThisHotkey, A_EndChar)
:XB0:japanes::f("Japanese", A_ThisHotkey, A_EndChar)
:XB0:jaques::f("jacques", A_ThisHotkey, A_EndChar)
:XB0:jewelery::f("jewelry", A_ThisHotkey, A_EndChar) 
:XB0:jive with::f("jibe with", A_ThisHotkey, A_EndChar)
:XB0:johanine::f("Johannine", A_ThisHotkey, A_EndChar)
:XB0:jorunal::f("journal", A_ThisHotkey, A_EndChar)
:XB0:jospeh::f("Joseph", A_ThisHotkey, A_EndChar)
:XB0:journied::f("journeyed", A_ThisHotkey, A_EndChar)
:XB0:journies::f("journeys", A_ThisHotkey, A_EndChar)
:XB0:juadaism::f("Judaism", A_ThisHotkey, A_EndChar)
:XB0:juadism::f("Judaism", A_ThisHotkey, A_EndChar)
:XB0:key note::f("keynote", A_ThisHotkey, A_EndChar)
:XB0:klenex::f("kleenex", A_ThisHotkey, A_EndChar)
:XB0:knifes::f("knives", A_ThisHotkey, A_EndChar)
:XB0:knive::f("knife", A_ThisHotkey, A_EndChar)
:XB0:labratory::f("laboratory", A_ThisHotkey, A_EndChar)
:XB0:lack there of::f("lack thereof", A_ThisHotkey, A_EndChar)
:XB0:laid ahead::f("lay ahead", A_ThisHotkey, A_EndChar)
:XB0:laid dormant::f("lay dormant", A_ThisHotkey, A_EndChar)
:XB0:laid empty::f("lay empty", A_ThisHotkey, A_EndChar)
:XB0:larg::f("large", A_ThisHotkey, A_EndChar)
:XB0:larger then::f("larger than", A_ThisHotkey, A_EndChar)
:XB0:largley::f("largely", A_ThisHotkey, A_EndChar)
:XB0:largst::f("largest", A_ThisHotkey, A_EndChar)
:XB0:lastr::f("last", A_ThisHotkey, A_EndChar)
:XB0:lastyear::f("last year", A_ThisHotkey, A_EndChar)
:XB0:laughing stock::f("laughingstock", A_ThisHotkey, A_EndChar)
:XB0:lavae::f("larvae", A_ThisHotkey, A_EndChar)
:XB0:law suite::f("lawsuit", A_ThisHotkey, A_EndChar)
:XB0:lay low::f("lie low", A_ThisHotkey, A_EndChar)
:XB0:layed off::f("laid off", A_ThisHotkey, A_EndChar)
:XB0:layed::f("laid", A_ThisHotkey, A_EndChar)
:XB0:laying around::f("lying around", A_ThisHotkey, A_EndChar)
:XB0:laying awake::f("lying awake", A_ThisHotkey, A_EndChar)
:XB0:laying low::f("lying low", A_ThisHotkey, A_EndChar)
:XB0:lays atop::f("lies atop", A_ThisHotkey, A_EndChar)
:XB0:lays beside::f("lies beside", A_ThisHotkey, A_EndChar)
:XB0:lays in::f("lies in", A_ThisHotkey, A_EndChar)
:XB0:lays low::f("lies low", A_ThisHotkey, A_EndChar)
:XB0:lays near::f("lies near", A_ThisHotkey, A_EndChar)
:XB0:lays on::f("lies on", A_ThisHotkey, A_EndChar)
:XB0:lead by::f("led by", A_ThisHotkey, A_EndChar)
:XB0:lead roll::f("lead role", A_ThisHotkey, A_EndChar)
:XB0:leading roll::f("leading role", A_ThisHotkey, A_EndChar)
:XB0:lefted::f("left", A_ThisHotkey, A_EndChar)
:XB0:less dominate::f("less dominant", A_ThisHotkey, A_EndChar)
:XB0:less that::f("less than", A_ThisHotkey, A_EndChar)
:XB0:less then::f("less than", A_ThisHotkey, A_EndChar)
:XB0:lesser then::f("less than", A_ThisHotkey, A_EndChar)
:XB0:libary::f("library", A_ThisHotkey, A_EndChar)
:XB0:libitarianisn::f("libertarianism", A_ThisHotkey, A_EndChar)
:XB0:licence::f("license", A_ThisHotkey, A_EndChar)
:XB0:life time::f("lifetime", A_ThisHotkey, A_EndChar)
:XB0:liftime::f("lifetime", A_ThisHotkey, A_EndChar)
:XB0:lighter then::f("lighter than", A_ThisHotkey, A_EndChar)
:XB0:lightyear::f("light year", A_ThisHotkey, A_EndChar)
:XB0:lightyears::f("light years", A_ThisHotkey, A_EndChar)
:XB0:line of site::f("line of sight", A_ThisHotkey, A_EndChar)
:XB0:line-of-site::f("line-of-sight", A_ThisHotkey, A_EndChar)
:XB0:linnaena::f("linnaean", A_ThisHotkey, A_EndChar)
:XB0:lions share::f("lion's share", A_ThisHotkey, A_EndChar)
:XB0:litature::f("literature", A_ThisHotkey, A_EndChar)
:XB0:lonelyness::f("loneliness", A_ThisHotkey, A_EndChar)
:XB0:loose to::f("lose to", A_ThisHotkey, A_EndChar)
:XB0:loosing effort::f("losing effort", A_ThisHotkey, A_EndChar)
:XB0:loosing record::f("losing record", A_ThisHotkey, A_EndChar)
:XB0:loosing season::f("losing season", A_ThisHotkey, A_EndChar)
:XB0:loosing streak::f("losing streak", A_ThisHotkey, A_EndChar)
:XB0:loosing team::f("losing team", A_ThisHotkey, A_EndChar)
:XB0:loosing the::f("losing the", A_ThisHotkey, A_EndChar)
:XB0:loosing to::f("losing to", A_ThisHotkey, A_EndChar)
:XB0:lot's of::f("lots of", A_ThisHotkey, A_EndChar)
:XB0:lower that::f("lower than", A_ThisHotkey, A_EndChar)
:XB0:lower then::f("lower than", A_ThisHotkey, A_EndChar)
:XB0:maching::f("matching", A_ThisHotkey, A_EndChar)
:XB0:mackeral::f("mackerel", A_ThisHotkey, A_EndChar)
:XB0:made it's::f("made its", A_ThisHotkey, A_EndChar)
:XB0:magasine::f("magazine", A_ThisHotkey, A_EndChar)
:XB0:magizine::f("magazine", A_ThisHotkey, A_EndChar)
:XB0:maintance::f("maintenance", A_ThisHotkey, A_EndChar)
:XB0:major roll::f("major role", A_ThisHotkey, A_EndChar)
:XB0:make due::f("make do", A_ThisHotkey, A_EndChar)
:XB0:make it's::f("make its", A_ThisHotkey, A_EndChar)
:XB0:malcom::f("Malcolm", A_ThisHotkey, A_EndChar)
:XB0:maltesian::f("Maltese", A_ThisHotkey, A_EndChar)
:XB0:managerial reigns::f("managerial reins", A_ThisHotkey, A_EndChar)
:XB0:massachussets::f("Massachusetts", A_ThisHotkey, A_EndChar)
:XB0:massachussetts::f("Massachusetts", A_ThisHotkey, A_EndChar)
:XB0:massmedia::f("mass media", A_ThisHotkey, A_EndChar)
:XB0:materalists::f("materialist", A_ThisHotkey, A_EndChar)
:XB0:mathematican::f("mathematician", A_ThisHotkey, A_EndChar)
:XB0:matheticians::f("mathematicians", A_ThisHotkey, A_EndChar)
:XB0:mean while::f("meanwhile", A_ThisHotkey, A_EndChar)
:XB0:mear::f("mere", A_ThisHotkey, A_EndChar)
:XB0:medievel::f("medieval", A_ThisHotkey, A_EndChar)
:XB0:mediteranean::f("Mediterranean", A_ThisHotkey, A_EndChar)
:XB0:meerkrat::f("meerkat", A_ThisHotkey, A_EndChar)
:XB0:melieux::f("milieux", A_ThisHotkey, A_EndChar)
:XB0:membranaphone::f("membranophone", A_ThisHotkey, A_EndChar)
:XB0:menally::f("mentally", A_ThisHotkey, A_EndChar)
:XB0:menat::f("meant", A_ThisHotkey, A_EndChar)
:XB0:messanger::f("messenger", A_ThisHotkey, A_EndChar)
:XB0:messenging::f("messaging", A_ThisHotkey, A_EndChar)
:XB0:michagan::f("Michigan", A_ThisHotkey, A_EndChar)
:XB0:micheal::f("Michael", A_ThisHotkey, A_EndChar)
:XB0:might of::f("might have", A_ThisHotkey, A_EndChar)
:XB0:miligram::f("milligram", A_ThisHotkey, A_EndChar)
:XB0:millepede::f("millipede", A_ThisHotkey, A_EndChar)
:XB0:miniscule::f("minuscule", A_ThisHotkey, A_EndChar)
:XB0:ministery::f("ministry", A_ThisHotkey, A_EndChar)
:XB0:minor roll::f("minor role", A_ThisHotkey, A_EndChar)
:XB0:minstries::f("ministries", A_ThisHotkey, A_EndChar)
:XB0:minstry::f("ministry", A_ThisHotkey, A_EndChar)
:XB0:minumum::f("minimum", A_ThisHotkey, A_EndChar)
:XB0:misfourtunes::f("misfortunes", A_ThisHotkey, A_EndChar)
:XB0:missen::f("mizzen", A_ThisHotkey, A_EndChar)
:XB0:missle::f("missile", A_ThisHotkey, A_EndChar)
:XB0:mistery::f("mystery", A_ThisHotkey, A_EndChar)
:XB0:moderm::f("modem", A_ThisHotkey, A_EndChar)
:XB0:mohammedans::f("muslims", A_ThisHotkey, A_EndChar)
:XB0:moil::f("mohel", A_ThisHotkey, A_EndChar)
:XB0:momento::f("memento", A_ThisHotkey, A_EndChar)
:XB0:monolite::f("monolithic", A_ThisHotkey, A_EndChar)
:XB0:more dominate::f("more dominant", A_ThisHotkey, A_EndChar)
:XB0:more of less::f("more or less", A_ThisHotkey, A_EndChar)
:XB0:more often then::f("more often than", A_ThisHotkey, A_EndChar)
:XB0:more resent::f("more recent", A_ThisHotkey, A_EndChar)
:XB0:more that::f("more than", A_ThisHotkey, A_EndChar)
:XB0:more then::f("more than", A_ThisHotkey, A_EndChar)
:XB0:moreso::f("more so", A_ThisHotkey, A_EndChar)
:XB0:most dominate::f("most dominant", A_ThisHotkey, A_EndChar)
:XB0:most populace::f("most populous", A_ThisHotkey, A_EndChar)
:XB0:most resent::f("most recent", A_ThisHotkey, A_EndChar)
:XB0:muhammadan::f("muslim", A_ThisHotkey, A_EndChar)
:XB0:multipled::f("multiplied", A_ThisHotkey, A_EndChar)
:XB0:multiplers::f("multipliers", A_ThisHotkey, A_EndChar)
:XB0:must of::f("must have", A_ThisHotkey, A_EndChar)
:XB0:mute point::f("moot point", A_ThisHotkey, A_EndChar)
:XB0:mysef::f("myself", A_ThisHotkey, A_EndChar)
:XB0:mysefl::f("myself", A_ThisHotkey, A_EndChar)
:XB0:myu::f("my", A_ThisHotkey, A_EndChar)
:XB0:nad::f("and", A_ThisHotkey, A_EndChar)
:XB0:napoleonian::f("Napoleonic", A_ThisHotkey, A_EndChar)
:XB0:nation wide::f("nationwide", A_ThisHotkey, A_EndChar)
:XB0:nazereth::f("Nazareth", A_ThisHotkey, A_EndChar)
:XB0:near by::f("nearby", A_ThisHotkey, A_EndChar)
:XB0:neither criteria::f("neither criterion", A_ThisHotkey, A_EndChar)
:XB0:neither phenomena::f("neither phenomenon", A_ThisHotkey, A_EndChar)
:XB0:nestin::f("nesting", A_ThisHotkey, A_EndChar)
:XB0:neverthless::f("nevertheless", A_ThisHotkey, A_EndChar)
:XB0:new comer::f("newcomer", A_ThisHotkey, A_EndChar)
:XB0:newletters::f("newsletters", A_ThisHotkey, A_EndChar)
:XB0:newyorker::f("New Yorker", A_ThisHotkey, A_EndChar)
:XB0:niether::f("neither", A_ThisHotkey, A_EndChar)
:XB0:nightime::f("nighttime", A_ThisHotkey, A_EndChar)
:XB0:nineth::f("ninth", A_ThisHotkey, A_EndChar)
:XB0:ninteenth::f("nineteenth", A_ThisHotkey, A_EndChar)
:XB0:ninties::f("nineties", A_ThisHotkey, A_EndChar) ; fixed from "1990s": could refer to temperatures too.
:XB0:ninty::f("ninety", A_ThisHotkey, A_EndChar)
:XB0:no where to::f("nowhere to", A_ThisHotkey, A_EndChar)
:XB0:nontheless::f("nonetheless", A_ThisHotkey, A_EndChar)
:XB0:noone::f("no one", A_ThisHotkey, A_EndChar)
:XB0:note worthy::f("noteworthy", A_ThisHotkey, A_EndChar)
:XB0:noth::f("north", A_ThisHotkey, A_EndChar)
:XB0:noticable::f("noticeable", A_ThisHotkey, A_EndChar)
:XB0:noticably::f("noticeably", A_ThisHotkey, A_EndChar)
:XB0:notwhithstanding::f("notwithstanding", A_ThisHotkey, A_EndChar)
:XB0:noveau::f("nouveau", A_ThisHotkey, A_EndChar)
:XB0:nowdays::f("nowadays", A_ThisHotkey, A_EndChar)
:XB0:nuisanse::f("nuisance", A_ThisHotkey, A_EndChar)
:XB0:nusance::f("nuisance", A_ThisHotkey, A_EndChar)
:XB0:obstacal::f("obstacle", A_ThisHotkey, A_EndChar)
:XB0:of it's kind::f("of its kind", A_ThisHotkey, A_EndChar)
:XB0:of it's own::f("of its own", A_ThisHotkey, A_EndChar)
:XB0:ofits::f("of its", A_ThisHotkey, A_EndChar)
:XB0:oft he::f("of the", A_ThisHotkey, A_EndChar) ; Could be legitimate in poetry, but usually a typo.
:XB0:oftenly::f("often", A_ThisHotkey, A_EndChar)
:XB0:oging::f("going", A_ThisHotkey, A_EndChar)
:XB0:oil barron::f("oil baron", A_ThisHotkey, A_EndChar)
:XB0:ole::f("olÃ©", A_ThisHotkey, A_EndChar)
:XB0:omited::f("omitted", A_ThisHotkey, A_EndChar)
:XB0:omiting::f("omitting", A_ThisHotkey, A_EndChar)
:XB0:omlette::f("omelette", A_ThisHotkey, A_EndChar)
:XB0:ommited::f("omitted", A_ThisHotkey, A_EndChar)
:XB0:ommiting::f("omitting", A_ThisHotkey, A_EndChar)
:XB0:ommitted::f("omitted", A_ThisHotkey, A_EndChar)
:XB0:ommitting::f("omitting", A_ThisHotkey, A_EndChar)
:XB0:on accident::f("by accident", A_ThisHotkey, A_EndChar)
:XB0:on going::f("ongoing", A_ThisHotkey, A_EndChar)
:XB0:on it's own::f("on its own", A_ThisHotkey, A_EndChar)
:XB0:on-going::f("ongoing", A_ThisHotkey, A_EndChar)
:XB0:one criteria::f("one criterion", A_ThisHotkey, A_EndChar)
:XB0:one phenomena::f("one phenomenon", A_ThisHotkey, A_EndChar)
:XB0:oneof::f("one of", A_ThisHotkey, A_EndChar)
:XB0:onepoint::f("one point", A_ThisHotkey, A_EndChar)
:XB0:ongoing bases::f("ongoing basis", A_ThisHotkey, A_EndChar)
:XB0:onnair::f("onnaire", A_ThisHotkey, A_EndChar)
:XB0:onomatopeia::f("onomatopoeia", A_ThisHotkey, A_EndChar)
:XB0:ont he::f("on the", A_ThisHotkey, A_EndChar)
:XB0:onyl::f("only", A_ThisHotkey, A_EndChar)
:XB0:openess::f("openness", A_ThisHotkey, A_EndChar)
:XB0:opposit::f("opposite", A_ThisHotkey, A_EndChar)
:XB0:orded::f("ordered", A_ThisHotkey, A_EndChar)
:XB0:other then::f("other than", A_ThisHotkey, A_EndChar)
:XB0:our of::f("out of", A_ThisHotkey, A_EndChar)
:XB0:our resent::f("our recent", A_ThisHotkey, A_EndChar)
:XB0:out grow::f("outgrow", A_ThisHotkey, A_EndChar)
:XB0:out of sink::f("out of sync", A_ThisHotkey, A_EndChar)
:XB0:out of state::f("out-of-state", A_ThisHotkey, A_EndChar)
:XB0:out side::f("outside", A_ThisHotkey, A_EndChar)
:XB0:outof::f("out of", A_ThisHotkey, A_EndChar)
:XB0:over hear::f("overhear", A_ThisHotkey, A_EndChar)
:XB0:over heard::f("overheard", A_ThisHotkey, A_EndChar)
:XB0:over look::f("overlook", A_ThisHotkey, A_EndChar)
:XB0:over looked::f("overlooked", A_ThisHotkey, A_EndChar)
:XB0:over looking::f("overlooking", A_ThisHotkey, A_EndChar)
:XB0:over rated::f("overrated", A_ThisHotkey, A_EndChar)
:XB0:over saw::f("oversaw", A_ThisHotkey, A_EndChar)
:XB0:over see::f("oversee", A_ThisHotkey, A_EndChar)
:XB0:overthere::f("over there", A_ThisHotkey, A_EndChar)
:XB0:paleolitic::f("paleolithic", A_ThisHotkey, A_EndChar)
:XB0:paraphenalia::f("paraphernalia", A_ThisHotkey, A_EndChar)
:XB0:particulary::f("particularly", A_ThisHotkey, A_EndChar)
:XB0:partof::f("part of", A_ThisHotkey, A_EndChar)
:XB0:pasengers::f("passengers", A_ThisHotkey, A_EndChar)
:XB0:passerbys::f("passersby", A_ThisHotkey, A_EndChar)
:XB0:past away::f("passed away", A_ThisHotkey, A_EndChar)
:XB0:past down::f("passed down", A_ThisHotkey, A_EndChar)
:XB0:pasttime::f("pastime", A_ThisHotkey, A_EndChar)
:XB0:pavillion::f("pavilion", A_ThisHotkey, A_EndChar)
:XB0:payed::f("paid", A_ThisHotkey, A_EndChar)
:XB0:peacefuland::f("peaceful and", A_ThisHotkey, A_EndChar)
:XB0:peak her interest::f("pique her interest", A_ThisHotkey, A_EndChar)
:XB0:peak his interest::f("pique his interest", A_ThisHotkey, A_EndChar)
:XB0:peaked my interest::f("piqued my interest", A_ThisHotkey, A_EndChar)
:XB0:penatly::f("penalty", A_ThisHotkey, A_EndChar)
:XB0:peotry::f("poetry", A_ThisHotkey, A_EndChar)
:XB0:per say::f("per se", A_ThisHotkey, A_EndChar)
:XB0:percentof::f("percent of", A_ThisHotkey, A_EndChar)
:XB0:percentto::f("percent to", A_ThisHotkey, A_EndChar)
:XB0:perhasp::f("perhaps", A_ThisHotkey, A_EndChar)
:XB0:perheaps::f("perhaps", A_ThisHotkey, A_EndChar)
:XB0:perhpas::f("perhaps", A_ThisHotkey, A_EndChar)
:XB0:perogative::f("prerogative", A_ThisHotkey, A_EndChar)
:XB0:perphas::f("perhaps", A_ThisHotkey, A_EndChar)
:XB0:personel::f("personnel", A_ThisHotkey, A_EndChar)
:XB0:personell::f("personnel", A_ThisHotkey, A_EndChar)
:XB0:personnell::f("personnel", A_ThisHotkey, A_EndChar)
:XB0:pharoah::f("Pharaoh", A_ThisHotkey, A_EndChar)
:XB0:phenomenonly::f("phenomenally", A_ThisHotkey, A_EndChar)
:XB0:pheonix::f("phoenix", A_ThisHotkey, A_EndChar) ; Not forcing caps, as it could be the bird
:XB0:pinapple::f("pineapple", A_ThisHotkey, A_EndChar)
:XB0:pinnaple::f("pineapple", A_ThisHotkey, A_EndChar)
:XB0:planation::f("plantation", A_ThisHotkey, A_EndChar)
:XB0:plantiff::f("plaintiff", A_ThisHotkey, A_EndChar)
:XB0:poety::f("poetry", A_ThisHotkey, A_EndChar)
:XB0:poisin::f("poison", A_ThisHotkey, A_EndChar)
:XB0:pomegranite::f("pomegranate", A_ThisHotkey, A_EndChar)
:XB0:portayed::f("portrayed", A_ThisHotkey, A_EndChar)
:XB0:portugese::f("Portuguese", A_ThisHotkey, A_EndChar)
:XB0:portuguease::f("portuguese", A_ThisHotkey, A_EndChar)
:XB0:portugues::f("Portuguese", A_ThisHotkey, A_EndChar)
:XB0:potatoe::f("potato", A_ThisHotkey, A_EndChar)
:XB0:potatos::f("potatoes", A_ThisHotkey, A_EndChar)
:XB0:powerfull::f("powerful", A_ThisHotkey, A_EndChar)
:XB0:pre-Colombian::f("pre-Columbian", A_ThisHotkey, A_EndChar)
:XB0:precedessor::f("predecessor", A_ThisHotkey, A_EndChar)
:XB0:precentage::f("percentage", A_ThisHotkey, A_EndChar)
:XB0:prepat::f("preparat", A_ThisHotkey, A_EndChar)
:XB0:primarly::f("primarily", A_ThisHotkey, A_EndChar)
:XB0:principaly::f("principality", A_ThisHotkey, A_EndChar)
:XB0:principlaity::f("principality", A_ThisHotkey, A_EndChar)
:XB0:principle advantage::f("principal advantage", A_ThisHotkey, A_EndChar)
:XB0:principle cause::f("principal cause", A_ThisHotkey, A_EndChar)
:XB0:principle character::f("principal character", A_ThisHotkey, A_EndChar)
:XB0:principle component::f("principal component", A_ThisHotkey, A_EndChar)
:XB0:principle goal::f("principal goal", A_ThisHotkey, A_EndChar)
:XB0:principle group::f("principal group", A_ThisHotkey, A_EndChar)
:XB0:principle method::f("principal method", A_ThisHotkey, A_EndChar)
:XB0:principle owner::f("principal owner", A_ThisHotkey, A_EndChar)
:XB0:principle source::f("principal source", A_ThisHotkey, A_EndChar)
:XB0:principle student::f("principal student", A_ThisHotkey, A_EndChar)
:XB0:principly::f("principally", A_ThisHotkey, A_EndChar)
:XB0:probelms::f("problems", A_ThisHotkey, A_EndChar)
:XB0:procedger::f("procedure", A_ThisHotkey, A_EndChar)
:XB0:prologomena::f("prolegomena", A_ThisHotkey, A_EndChar)
:XB0:prophacy::f("prophecy", A_ThisHotkey, A_EndChar)
:XB0:protem::f("pro tem", A_ThisHotkey, A_EndChar)
:XB0:protocal::f("protocol", A_ThisHotkey, A_EndChar)
:XB0:proximty::f("proximity", A_ThisHotkey, A_EndChar)
:XB0:publically::f("publicly", A_ThisHotkey, A_EndChar)
:XB0:publicaly::f("publicly", A_ThisHotkey, A_EndChar)
:XB0:purposedly::f("purposely", A_ThisHotkey, A_EndChar)
:XB0:puting::f("putting", A_ThisHotkey, A_EndChar)
:XB0:quitted::f("quit", A_ThisHotkey, A_EndChar)
:XB0:rather then::f("rather than", A_ThisHotkey, A_EndChar)
:XB0:rebounce::f("rebound", A_ThisHotkey, A_EndChar)
:XB0:recal::f("recall", A_ThisHotkey, A_EndChar)
:XB0:receivedfrom::f("received from", A_ThisHotkey, A_EndChar)
:XB0:reek havoc::f("wreak havoc", A_ThisHotkey, A_EndChar)
:XB0:refering::f("referring", A_ThisHotkey, A_EndChar)
:XB0:regular bases::f("regular basis", A_ThisHotkey, A_EndChar)
:XB0:reign in::f("rein in", A_ThisHotkey, A_EndChar)
:XB0:reigns of power::f("reins of power", A_ThisHotkey, A_EndChar)
:XB0:rela::f("real", A_ThisHotkey, A_EndChar)
:XB0:relected::f("reelected", A_ThisHotkey, A_EndChar)
:XB0:remaing::f("remaining", A_ThisHotkey, A_EndChar)
:XB0:rememberable::f("memorable", A_ThisHotkey, A_EndChar)
:XB0:republi::f("republic", A_ThisHotkey, A_EndChar)
:XB0:resently::f("recently", A_ThisHotkey, A_EndChar) 
:XB0:retun::f("return", A_ThisHotkey, A_EndChar)
:XB0:revaluated::f("reevaluated", A_ThisHotkey, A_EndChar)
:XB0:rised::f("rose", A_ThisHotkey, A_EndChar)
:XB0:runner up::f("runner-up", A_ThisHotkey, A_EndChar)
:XB0:saddle up to::f("sidle up to", A_ThisHotkey, A_EndChar)
:XB0:saidhe::f("said he", A_ThisHotkey, A_EndChar)
:XB0:saidt he::f("said the", A_ThisHotkey, A_EndChar)
:XB0:sandess::f("sadness", A_ThisHotkey, A_EndChar)
:XB0:scientis::f("scientist", A_ThisHotkey, A_EndChar)
:XB0:seceed::f("secede", A_ThisHotkey, A_EndChar)
:XB0:seceeded::f("seceded", A_ThisHotkey, A_EndChar)
:XB0:severley::f("severely", A_ThisHotkey, A_EndChar)
:XB0:severly::f("severely", A_ThisHotkey, A_EndChar)
:XB0:she begun::f("she began", A_ThisHotkey, A_EndChar)
:XB0:she let's::f("she lets", A_ThisHotkey, A_EndChar)
:XB0:she seen::f("she saw", A_ThisHotkey, A_EndChar)
:XB0:sherif::f("sheriff", A_ThisHotkey, A_EndChar)
:XB0:shiped::f("shipped", A_ThisHotkey, A_EndChar)
:XB0:shorter then::f("shorter than", A_ThisHotkey, A_EndChar)
:XB0:shortly there after::f("shortly thereafter", A_ThisHotkey, A_EndChar)
:XB0:shortwhile::f("short while", A_ThisHotkey, A_EndChar) 
:XB0:should backup::f("should back up", A_ThisHotkey, A_EndChar)
:XB0:should not of::f("should not have", A_ThisHotkey, A_EndChar)
:XB0:should of::f("should have", A_ThisHotkey, A_EndChar) 
:XB0:should've went::f("should have gone", A_ThisHotkey, A_EndChar)
:XB0:show resent::f("show recent", A_ThisHotkey, A_EndChar) 
:XB0:shrinked::f("shrunk", A_ThisHotkey, A_EndChar) 
:XB0:silicone chip::f("silicon chip", A_ThisHotkey, A_EndChar) 
:XB0:simplier::f("simpler", A_ThisHotkey, A_EndChar)
:XB0:single handily::f("single-handedly", A_ThisHotkey, A_EndChar)
:XB0:singsog::f("singsong", A_ThisHotkey, A_EndChar) 
:XB0:slight of hand::f("sleight of hand", A_ThisHotkey, A_EndChar)
:XB0:slue of::f("slew of", A_ThisHotkey, A_EndChar)
:XB0:smaller then::f("smaller than", A_ThisHotkey, A_EndChar)
:XB0:smarter then::f("smarter than", A_ThisHotkey, A_EndChar)
:XB0:sneak peak::f("sneak peek", A_ThisHotkey, A_EndChar)
:XB0:soley::f("solely", A_ThisHotkey, A_EndChar)
:XB0:some how::f("somehow", A_ThisHotkey, A_EndChar)
:XB0:some one::f("someone", A_ThisHotkey, A_EndChar)
:XB0:some what::f("somewhat", A_ThisHotkey, A_EndChar)
:XB0:some where::f("somewhere", A_ThisHotkey, A_EndChar)
:XB0:somene::f("someone", A_ThisHotkey, A_EndChar) 
:XB0:someting::f("something", A_ThisHotkey, A_EndChar) 
:XB0:somthing::f("something", A_ThisHotkey, A_EndChar) 
:XB0:somwhere::f("somewhere", A_ThisHotkey, A_EndChar) 
:XB0:soon there after::f("soon thereafter", A_ThisHotkey, A_EndChar)
:XB0:sooner then::f("sooner than", A_ThisHotkey, A_EndChar)
:XB0:sot hat::f("so that", A_ThisHotkey, A_EndChar) 
:XB0:sotyr::f("story", A_ThisHotkey, A_EndChar)
:XB0:spainish::f("Spanish", A_ThisHotkey, A_EndChar)
:XB0:speach::f("speech", A_ThisHotkey, A_EndChar)
:XB0:spects::f("aspects", A_ThisHotkey, A_EndChar) 
:XB0:spilt among::f("split among", A_ThisHotkey, A_EndChar)
:XB0:spilt between::f("split between", A_ThisHotkey, A_EndChar)
:XB0:spilt into::f("split into", A_ThisHotkey, A_EndChar)
:XB0:spilt up::f("split up", A_ThisHotkey, A_EndChar)
:XB0:spinal chord::f("spinal cord", A_ThisHotkey, A_EndChar)
:XB0:split in to::f("split into", A_ThisHotkey, A_EndChar)
:XB0:spreaded::f("spread", A_ThisHotkey, A_EndChar)
:XB0:sprech::f("speech", A_ThisHotkey, A_EndChar)
:XB0:sq ft::f("ft²", A_ThisHotkey, A_EndChar)
:XB0:sq in::f("in²", A_ThisHotkey, A_EndChar)
:XB0:sq km::f("km²", A_ThisHotkey, A_EndChar)
:XB0:sq mi::f("mi²", A_ThisHotkey, A_EndChar)
:XB0:squared feet::f("square feet", A_ThisHotkey, A_EndChar)
:XB0:standars::f("standards", A_ThisHotkey, A_EndChar)
:XB0:stay a while::f("stay awhile", A_ThisHotkey, A_EndChar)
:XB0:stomache::f("stomach", A_ThisHotkey, A_EndChar)
:XB0:storise::f("stories", A_ThisHotkey, A_EndChar)
:XB0:stornegst::f("strongest", A_ThisHotkey, A_EndChar)
:XB0:strictist::f("strictest", A_ThisHotkey, A_EndChar)
:XB0:strikely::f("strikingly", A_ThisHotkey, A_EndChar)
:XB0:stronger then::f("stronger than", A_ThisHotkey, A_EndChar)
:XB0:stubborness::f("stubbornness", A_ThisHotkey, A_EndChar)
:XB0:student's that::f("students that", A_ThisHotkey, A_EndChar)
:XB0:subpecies::f("subspecies", A_ThisHotkey, A_EndChar)
:XB0:succeds::f("succeeds", A_ThisHotkey, A_EndChar)
:XB0:suppose to::f("supposed to", A_ThisHotkey, A_EndChar)
:XB0:supposingly::f("supposedly", A_ThisHotkey, A_EndChar) 
:XB0:surrended::f("surrendered", A_ThisHotkey, A_EndChar)
:XB0:surviver::f("survivor", A_ThisHotkey, A_EndChar)
:XB0:survivied::f("survived", A_ThisHotkey, A_EndChar)
:XB0:t he::f("the", A_ThisHotkey, A_EndChar)
:XB0:take affect::f("take effect", A_ThisHotkey, A_EndChar)
:XB0:take over the reigns::f("take over the reins", A_ThisHotkey, A_EndChar)
:XB0:take the reigns::f("take the reins", A_ThisHotkey, A_EndChar)
:XB0:taken the reigns::f("taken the reins", A_ThisHotkey, A_EndChar)
:XB0:taking the reigns::f("taking the reins", A_ThisHotkey, A_EndChar)
:XB0:tast::f("taste", A_ThisHotkey, A_EndChar)
:XB0:tath::f("that", A_ThisHotkey, A_EndChar)
:XB0:teached::f("taught", A_ThisHotkey, A_EndChar) 
:XB0:tellt he::f("tell the", A_ThisHotkey, A_EndChar) 
:XB0:thanks@!::f("thanks!", A_ThisHotkey, A_EndChar)
:XB0:thanks@::f("thanks!", A_ThisHotkey, A_EndChar)
:XB0:thast::f("that's", A_ThisHotkey, A_EndChar) 
:XB0:that him and::f("that he and", A_ThisHotkey, A_EndChar)
:XB0:thats::f("that's", A_ThisHotkey, A_EndChar) 
:XB0:thatt he::f("that the", A_ThisHotkey, A_EndChar) 
:XB0:the absent of::f("the absence of", A_ThisHotkey, A_EndChar)
:XB0:the advise of::f("the advice of", A_ThisHotkey, A_EndChar)
:XB0:the affect of::f("the effect of", A_ThisHotkey, A_EndChar)
:XB0:the affect on::f("the effect on", A_ThisHotkey, A_EndChar)
:XB0:the affects of::f("the effects of", A_ThisHotkey, A_EndChar)
:XB0:the both the::f("both the", A_ThisHotkey, A_EndChar)
:XB0:the break down::f("the breakdown", A_ThisHotkey, A_EndChar)
:XB0:the break up::f("the breakup", A_ThisHotkey, A_EndChar)
:XB0:the build up::f("the buildup", A_ThisHotkey, A_EndChar)
:XB0:the clamp down::f("the clampdown", A_ThisHotkey, A_EndChar)
:XB0:the crack down::f("the crackdown", A_ThisHotkey, A_EndChar)
:XB0:the dominate::f("the dominant", A_ThisHotkey, A_EndChar)
:XB0:the extend of::f("the extent of", A_ThisHotkey, A_EndChar)
:XB0:the follow up::f("the follow-up", A_ThisHotkey, A_EndChar)
:XB0:the injures::f("the injuries", A_ThisHotkey, A_EndChar)
:XB0:the lead up::f("the lead-up", A_ThisHotkey, A_EndChar)
:XB0:the phenomena is::f("the phenomenon is", A_ThisHotkey, A_EndChar)
:XB0:the rational behind::f("the rationale behind", A_ThisHotkey, A_EndChar)
:XB0:the rational for::f("the rationale for", A_ThisHotkey, A_EndChar)
:XB0:the resent::f("the recent", A_ThisHotkey, A_EndChar)
:XB0:the set up::f("the setup", A_ThisHotkey, A_EndChar)
:XB0:thecompany::f("the company", A_ThisHotkey, A_EndChar) 
:XB0:thefirst::f("the first", A_ThisHotkey, A_EndChar) 
:XB0:theif::f("thief", A_ThisHotkey, A_EndChar)
:XB0:their are::f("there are", A_ThisHotkey, A_EndChar) 
:XB0:their had::f("there had", A_ThisHotkey, A_EndChar)
:XB0:their has::f("there has", A_ThisHotkey, A_EndChar)
:XB0:their have::f("there have", A_ThisHotkey, A_EndChar)
:XB0:their is::f("there is", A_ThisHotkey, A_EndChar) 
:XB0:their may be::f("there may be", A_ThisHotkey, A_EndChar)
:XB0:their was::f("there was", A_ThisHotkey, A_EndChar)
:XB0:their were::f("there were", A_ThisHotkey, A_EndChar)
:XB0:their would::f("there would", A_ThisHotkey, A_EndChar)
:XB0:theives::f("thieves", A_ThisHotkey, A_EndChar) 
:XB0:them selves::f("themselves", A_ThisHotkey, A_EndChar)
:XB0:themselfs::f("themselves", A_ThisHotkey, A_EndChar) 
:XB0:themslves::f("themselves", A_ThisHotkey, A_EndChar) 
:XB0:thenew::f("the new", A_ThisHotkey, A_EndChar) 
:XB0:ther::f("there", A_ThisHotkey, A_EndChar)
:XB0:therafter::f("thereafter", A_ThisHotkey, A_EndChar) 
:XB0:therby::f("thereby", A_ThisHotkey, A_EndChar) 
:XB0:there after::f("thereafter", A_ThisHotkey, A_EndChar)
:XB0:there best::f("their best", A_ThisHotkey, A_EndChar)
:XB0:there by::f("thereby", A_ThisHotkey, A_EndChar)
:XB0:there first::f("their first", A_ThisHotkey, A_EndChar)
:XB0:there last::f("their last", A_ThisHotkey, A_EndChar)
:XB0:there new::f("their new", A_ThisHotkey, A_EndChar)
:XB0:there next::f("their next", A_ThisHotkey, A_EndChar)
:XB0:there of::f("thereof", A_ThisHotkey, A_EndChar)
:XB0:there own::f("their own", A_ThisHotkey, A_EndChar)
:XB0:there where::f("there were", A_ThisHotkey, A_EndChar)
:XB0:there's is::f("theirs is", A_ThisHotkey, A_EndChar) 
:XB0:there's three::f("there are three", A_ThisHotkey, A_EndChar)
:XB0:there's two::f("there are two", A_ThisHotkey, A_EndChar)
:XB0:theri::f("their", A_ThisHotkey, A_EndChar) 
:XB0:thesame::f("the same", A_ThisHotkey, A_EndChar) 
:XB0:these includes::f("these include", A_ThisHotkey, A_EndChar)
:XB0:these type of::f("these types of", A_ThisHotkey, A_EndChar)
:XB0:these where::f("these were", A_ThisHotkey, A_EndChar)
:XB0:thetwo::f("the two", A_ThisHotkey, A_EndChar) 
:XB0:they begun::f("they began", A_ThisHotkey, A_EndChar)
:XB0:they maybe::f("they may be", A_ThisHotkey, A_EndChar)
:XB0:they we're::f("they were", A_ThisHotkey, A_EndChar)
:XB0:they weight::f("they weigh", A_ThisHotkey, A_EndChar)
:XB0:they where::f("they were", A_ThisHotkey, A_EndChar)
:XB0:they're are::f("there are", A_ThisHotkey, A_EndChar) 
:XB0:they're is::f("there is", A_ThisHotkey, A_EndChar) 
:XB0:they;l::f("they'll", A_ThisHotkey, A_EndChar) 
:XB0:they;r::f("they're", A_ThisHotkey, A_EndChar) 
:XB0:they;v::f("they've", A_ThisHotkey, A_EndChar) 
:XB0:theyll::f("they'll", A_ThisHotkey, A_EndChar) 
:XB0:theyre::f("they're", A_ThisHotkey, A_EndChar) 
:XB0:theyve::f("they've", A_ThisHotkey, A_EndChar) 
:XB0:this data::f("these data", A_ThisHotkey, A_EndChar)
:XB0:this gut::f("this guy", A_ThisHotkey, A_EndChar) 
:XB0:this lead to::f("this led to", A_ThisHotkey, A_EndChar)
:XB0:this maybe::f("this may be", A_ThisHotkey, A_EndChar)
:XB0:this resent::f("this recent", A_ThisHotkey, A_EndChar)
:XB0:thn::f("then", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0:those includes::f("those include", A_ThisHotkey, A_EndChar)
:XB0:those maybe::f("those may be", A_ThisHotkey, A_EndChar)
:XB0:thoughout::f("throughout", A_ThisHotkey, A_EndChar) 
:XB0:threatend::f("threatened", A_ThisHotkey, A_EndChar)
:XB0:through it's::f("through its", A_ThisHotkey, A_EndChar)
:XB0:through the ringer::f("through the wringer", A_ThisHotkey, A_EndChar)
:XB0:throughly::f("thoroughly", A_ThisHotkey, A_EndChar)
:XB0:throughout it's::f("throughout its", A_ThisHotkey, A_EndChar)
:XB0:througout::f("throughout", A_ThisHotkey, A_EndChar)
:XB0:throws of passion::f("throes of passion", A_ThisHotkey, A_EndChar)
:XB0:thru::f("through", A_ThisHotkey, A_EndChar)
:XB0:to back fire::f("to backfire", A_ThisHotkey, A_EndChar)
:XB0:to back-off::f("to back off", A_ThisHotkey, A_EndChar)
:XB0:to back-out::f("to back out", A_ThisHotkey, A_EndChar)
:XB0:to back-up::f("to back up", A_ThisHotkey, A_EndChar)
:XB0:to backoff::f("to back off", A_ThisHotkey, A_EndChar)
:XB0:to backout::f("to back out", A_ThisHotkey, A_EndChar)
:XB0:to backup::f("to back up", A_ThisHotkey, A_EndChar)
:XB0:to bailout::f("to bail out", A_ThisHotkey, A_EndChar)
:XB0:to bath::f("to bathe", A_ThisHotkey, A_EndChar)
:XB0:to be build::f("to be built", A_ThisHotkey, A_EndChar)
:XB0:to be setup::f("to be set up", A_ThisHotkey, A_EndChar)
:XB0:to blackout::f("to black out", A_ThisHotkey, A_EndChar)
:XB0:to blastoff::f("to blast off", A_ThisHotkey, A_EndChar)
:XB0:to blowout::f("to blow out", A_ThisHotkey, A_EndChar)
:XB0:to blowup::f("to blow up", A_ThisHotkey, A_EndChar)
:XB0:to breakdown::f("to break down", A_ThisHotkey, A_EndChar)
:XB0:to breath::f("to breathe", A_ThisHotkey, A_EndChar)
:XB0:to buildup::f("to build up", A_ThisHotkey, A_EndChar)
:XB0:to built::f("to build", A_ThisHotkey, A_EndChar)
:XB0:to buyout::f("to buy out", A_ThisHotkey, A_EndChar)
:XB0:to chose::f("to choose", A_ThisHotkey, A_EndChar)
:XB0:to comeback::f("to come back", A_ThisHotkey, A_EndChar)
:XB0:to crackdown on::f("to crack down on", A_ThisHotkey, A_EndChar)
:XB0:to cut of::f("to cut off", A_ThisHotkey, A_EndChar)
:XB0:to cutback::f("to cut back", A_ThisHotkey, A_EndChar)
:XB0:to cutoff::f("to cut off", A_ThisHotkey, A_EndChar)
:XB0:to dropout::f("to drop out", A_ThisHotkey, A_EndChar)
:XB0:to emphasis the::f("to emphasise the", A_ThisHotkey, A_EndChar)
:XB0:to fill-in::f("to fill in", A_ThisHotkey, A_EndChar)
:XB0:to forego::f("to forgo", A_ThisHotkey, A_EndChar)
:XB0:to happened::f("to happen", A_ThisHotkey, A_EndChar)
:XB0:to have lead to::f("to have led to", A_ThisHotkey, A_EndChar)
:XB0:to he and::f("to him and", A_ThisHotkey, A_EndChar)
:XB0:to holdout::f("to hold out", A_ThisHotkey, A_EndChar)
:XB0:to kickoff::f("to kick off", A_ThisHotkey, A_EndChar)
:XB0:to loath::f("to loathe", A_ThisHotkey, A_EndChar)
:XB0:to lockout::f("to lock out", A_ThisHotkey, A_EndChar)
:XB0:to lockup::f("to lock up", A_ThisHotkey, A_EndChar)
:XB0:to login::f("to log in", A_ThisHotkey, A_EndChar)
:XB0:to logout::f("to log out", A_ThisHotkey, A_EndChar)
:XB0:to lookup::f("to look up", A_ThisHotkey, A_EndChar)
:XB0:to markup::f("to mark up", A_ThisHotkey, A_EndChar)
:XB0:to opt-in::f("to opt in", A_ThisHotkey, A_EndChar)
:XB0:to opt-out::f("to opt out", A_ThisHotkey, A_EndChar)
:XB0:to phaseout::f("to phase out", A_ThisHotkey, A_EndChar)
:XB0:to pickup::f("to pick up", A_ThisHotkey, A_EndChar)
:XB0:to playback::f("to play back", A_ThisHotkey, A_EndChar)
:XB0:to rebuilt::f("to be rebuilt", A_ThisHotkey, A_EndChar)
:XB0:to rollback::f("to roll back", A_ThisHotkey, A_EndChar)
:XB0:to runaway::f("to run away", A_ThisHotkey, A_EndChar)
:XB0:to seen::f("to be seen", A_ThisHotkey, A_EndChar)
:XB0:to sent::f("to send", A_ThisHotkey, A_EndChar)
:XB0:to setup::f("to set up", A_ThisHotkey, A_EndChar)
:XB0:to shut-down::f("to shut down", A_ThisHotkey, A_EndChar)
:XB0:to shutdown::f("to shut down", A_ThisHotkey, A_EndChar)
:XB0:to some extend::f("to some extent", A_ThisHotkey, A_EndChar)
:XB0:to spent::f("to spend", A_ThisHotkey, A_EndChar)
:XB0:to spin-off::f("to spin off", A_ThisHotkey, A_EndChar)
:XB0:to spinoff::f("to spin off", A_ThisHotkey, A_EndChar)
:XB0:to takeover::f("to take over", A_ThisHotkey, A_EndChar)
:XB0:to that affect::f("to that effect", A_ThisHotkey, A_EndChar)
:XB0:to they're::f("to their", A_ThisHotkey, A_EndChar)
:XB0:to touchdown::f("to touch down", A_ThisHotkey, A_EndChar)
:XB0:to try and::f("to try to", A_ThisHotkey, A_EndChar)
:XB0:to try-out::f("to try out", A_ThisHotkey, A_EndChar)
:XB0:to tryout::f("to try out", A_ThisHotkey, A_EndChar)
:XB0:to turn-off::f("to turn off", A_ThisHotkey, A_EndChar)
:XB0:to turnaround::f("to turn around", A_ThisHotkey, A_EndChar)
:XB0:to turnoff::f("to turn off", A_ThisHotkey, A_EndChar)
:XB0:to turnout::f("to turn out", A_ThisHotkey, A_EndChar)
:XB0:to turnover::f("to turn over", A_ThisHotkey, A_EndChar)
:XB0:to wakeup::f("to wake up", A_ThisHotkey, A_EndChar)
:XB0:to walkout::f("to walk out", A_ThisHotkey, A_EndChar)
:XB0:to wipeout::f("to wipe out", A_ThisHotkey, A_EndChar)
:XB0:to withdrew::f("to withdraw", A_ThisHotkey, A_EndChar)
:XB0:to workaround::f("to work around", A_ThisHotkey, A_EndChar)
:XB0:to workout::f("to work out", A_ThisHotkey, A_EndChar)
:XB0:today of::f("today or", A_ThisHotkey, A_EndChar)
:XB0:todays::f("today's", A_ThisHotkey, A_EndChar) 
:XB0:toldt he::f("told the", A_ThisHotkey, A_EndChar) 
:XB0:tomatos::f("tomatoes", A_ThisHotkey, A_EndChar)
:XB0:too also::f("also", A_ThisHotkey, A_EndChar)
:XB0:too be::f("to be", A_ThisHotkey, A_EndChar)
:XB0:took affect::f("took effect", A_ThisHotkey, A_EndChar)
:XB0:took and interest::f("took an interest", A_ThisHotkey, A_EndChar)
:XB0:took awhile::f("took a while", A_ThisHotkey, A_EndChar)
:XB0:took over the reigns::f("took over the reins", A_ThisHotkey, A_EndChar)
:XB0:took the reigns::f("took the reins", A_ThisHotkey, A_EndChar)
:XB0:toolket::f("toolkit", A_ThisHotkey, A_EndChar)
:XB0:tornadoe::f("tornado", A_ThisHotkey, A_EndChar)
:XB0:torpeados::f("torpedoes", A_ThisHotkey, A_EndChar)
:XB0:torpedos::f("torpedoes", A_ThisHotkey, A_EndChar) 
:XB0:tot he::f("to the", A_ThisHotkey, A_EndChar) 
:XB0:tothe::f("to the", A_ThisHotkey, A_EndChar) 
:XB0:trafficing::f("trafficking", A_ThisHotkey, A_EndChar)
:XB0:transcripting::f("transcribing", A_ThisHotkey, A_EndChar)
:XB0:transfered::f("transferred", A_ThisHotkey, A_EndChar)
:XB0:tried to used::f("tried to use", A_ThisHotkey, A_EndChar)
:XB0:troup::f("troupe", A_ThisHotkey, A_EndChar)
:XB0:try and::f("try to", A_ThisHotkey, A_EndChar)
:XB0:turn for the worst::f("turn for the worse", A_ThisHotkey, A_EndChar)
:XB0:tuscon::f("Tucson", A_ThisHotkey, A_EndChar) 
:XB0:twelve month's::f("twelve months", A_ThisHotkey, A_EndChar)
:XB0:twice as much than::f("twice as much as", A_ThisHotkey, A_EndChar)
:XB0:two in a half::f("two and a half", A_ThisHotkey, A_EndChar)
:XB0:tyhe::f("they", A_ThisHotkey, A_EndChar)
:XB0:tyrany::f("tyranny", A_ThisHotkey, A_EndChar)
:XB0:tyrrany::f("tyranny", A_ThisHotkey, A_EndChar)
:XB0:uber::f("über", A_ThisHotkey, A_EndChar)
:XB0:unbeknowst::f("unbeknownst", A_ThisHotkey, A_EndChar)
:XB0:unconfortability::f("discomfort", A_ThisHotkey, A_EndChar) 
:XB0:under it's::f("under its", A_ThisHotkey, A_EndChar)
:XB0:under wear::f("underwear", A_ThisHotkey, A_EndChar)
:XB0:under went::f("underwent", A_ThisHotkey, A_EndChar)
:XB0:undert he::f("under the", A_ThisHotkey, A_EndChar) 
:XB0:undoubtely::f("undoubtedly", A_ThisHotkey, A_EndChar)
:XB0:unitedstates::f("United States", A_ThisHotkey, A_EndChar) 
:XB0:unitesstates::f("United States", A_ThisHotkey, A_EndChar) 
:XB0:unoperational::f("nonoperational", A_ThisHotkey, A_EndChar)
:XB0:unsed::f("unused", A_ThisHotkey, A_EndChar)
:XB0:untill::f("until", A_ThisHotkey, A_EndChar)
:XB0:up field::f("upfield", A_ThisHotkey, A_EndChar)
:XB0:up it's::f("up its", A_ThisHotkey, A_EndChar)
:XB0:up side::f("upside", A_ThisHotkey, A_EndChar)
:XB0:upon it's::f("upon its", A_ThisHotkey, A_EndChar)
:XB0:upto::f("up to", A_ThisHotkey, A_EndChar) 
:XB0:usally::f("usually", A_ThisHotkey, A_EndChar)
:XB0:use to be::f("used to be", A_ThisHotkey, A_EndChar)
:XB0:use to have::f("used to have", A_ThisHotkey, A_EndChar)
:XB0:use to::f("used to", A_ThisHotkey, A_EndChar)
:XB0:via it's::f("via its", A_ThisHotkey, A_EndChar)
:XB0:viathe::f("via the", A_ThisHotkey, A_EndChar)
:XB0:vise versa::f("vice versa", A_ThisHotkey, A_EndChar)
:XB0:volkswagon::f("Volkswagen", A_ThisHotkey, A_EndChar) 
:XB0:vreity::f("variety", A_ThisHotkey, A_EndChar)
:XB0:wa snot::f("was not", A_ThisHotkey, A_EndChar) 
:XB0:waived off::f("waved off", A_ThisHotkey, A_EndChar)
:XB0:wan tit::f("want it", A_ThisHotkey, A_EndChar) 
:XB0:wanna::f("want to", A_ThisHotkey, A_EndChar) 
:XB0:warantee::f("warranty", A_ThisHotkey, A_EndChar) 
:XB0:warn away::f("worn away", A_ThisHotkey, A_EndChar)
:XB0:warn down::f("worn down", A_ThisHotkey, A_EndChar)
:XB0:warn out::f("worn out", A_ThisHotkey, A_EndChar)
:XB0:was apart of::f("was a part of", A_ThisHotkey, A_EndChar)
:XB0:was began::f("began", A_ThisHotkey, A_EndChar)
:XB0:was build::f("was built", A_ThisHotkey, A_EndChar)
:XB0:was cable of::f("was capable of", A_ThisHotkey, A_EndChar)
:XB0:was cutoff::f("was cut off", A_ThisHotkey, A_EndChar)
:XB0:was do to::f("was due to", A_ThisHotkey, A_EndChar)
:XB0:was drank::f("was drunk", A_ThisHotkey, A_EndChar)
:XB0:was establish::f("was established", A_ThisHotkey, A_EndChar)
:XB0:was extend::f("was extended", A_ThisHotkey, A_EndChar)
:XB0:was it's::f("was its", A_ThisHotkey, A_EndChar)
:XB0:was knew::f("was known", A_ThisHotkey, A_EndChar)
:XB0:was know::f("was known", A_ThisHotkey, A_EndChar)
:XB0:was lain::f("was laid", A_ThisHotkey, A_EndChar)
:XB0:was laying on::f("was lying on", A_ThisHotkey, A_EndChar)
:XB0:was lead by::f("was led by", A_ThisHotkey, A_EndChar)
:XB0:was lead to::f("was led to", A_ThisHotkey, A_EndChar)
:XB0:was leaded by::f("was led by", A_ThisHotkey, A_EndChar)
:XB0:was loathe to::f("was loath to", A_ThisHotkey, A_EndChar)
:XB0:was loathed to::f("was loath to", A_ThisHotkey, A_EndChar)
:XB0:was meet by::f("was met by", A_ThisHotkey, A_EndChar)
:XB0:was meet with::f("was met with", A_ThisHotkey, A_EndChar)
:XB0:was mislead::f("was misled", A_ThisHotkey, A_EndChar)
:XB0:was ran::f("was run", A_ThisHotkey, A_EndChar)
:XB0:was rebuild::f("was rebuilt", A_ThisHotkey, A_EndChar)
:XB0:was release by::f("was released by", A_ThisHotkey, A_EndChar)
:XB0:was release on::f("was released on", A_ThisHotkey, A_EndChar)
:XB0:was reran::f("was rerun", A_ThisHotkey, A_EndChar)
:XB0:was rode::f("was ridden", A_ThisHotkey, A_EndChar)
:XB0:was sang::f("was sung", A_ThisHotkey, A_EndChar)
:XB0:was schedule to::f("was scheduled to", A_ThisHotkey, A_EndChar)
:XB0:was send::f("was sent", A_ThisHotkey, A_EndChar)
:XB0:was sentence to::f("was sentenced to", A_ThisHotkey, A_EndChar)
:XB0:was set-up::f("was set up", A_ThisHotkey, A_EndChar)
:XB0:was setup::f("was set up", A_ThisHotkey, A_EndChar)
:XB0:was shook::f("was shaken", A_ThisHotkey, A_EndChar)
:XB0:was shoot::f("was shot", A_ThisHotkey, A_EndChar)
:XB0:was show by::f("was shown by", A_ThisHotkey, A_EndChar)
:XB0:was show on::f("was shown on", A_ThisHotkey, A_EndChar)
:XB0:was showed::f("was shown", A_ThisHotkey, A_EndChar)
:XB0:was shut-off::f("was shut off", A_ThisHotkey, A_EndChar)
:XB0:was shutdown::f("was shut down", A_ThisHotkey, A_EndChar)
:XB0:was shutoff::f("was shut off", A_ThisHotkey, A_EndChar)
:XB0:was shutout::f("was shut out", A_ThisHotkey, A_EndChar)
:XB0:was sold-out::f("was sold out", A_ThisHotkey, A_EndChar)
:XB0:was spend::f("was spent", A_ThisHotkey, A_EndChar)
:XB0:was succeed by::f("was succeeded by", A_ThisHotkey, A_EndChar)
:XB0:was suppose to::f("was supposed to", A_ThisHotkey, A_EndChar)
:XB0:was the dominate::f("was the dominant", A_ThisHotkey, A_EndChar)
:XB0:was though that::f("was thought that", A_ThisHotkey, A_EndChar)
:XB0:was tore::f("was torn", A_ThisHotkey, A_EndChar)
:XB0:was use to::f("was used to", A_ThisHotkey, A_EndChar)
:XB0:was wrote::f("was written", A_ThisHotkey, A_EndChar)
:XB0:wasnt::f("wasn't", A_ThisHotkey, A_EndChar) 
:XB0:wat::f("way", A_ThisHotkey, A_EndChar)
:XB0:way side::f("wayside", A_ThisHotkey, A_EndChar)
:XB0:wayword::f("wayward", A_ThisHotkey, A_EndChar) 
:XB0:we;d::f("we'd", A_ThisHotkey, A_EndChar) 
:XB0:weaponary::f("weaponry", A_ThisHotkey, A_EndChar) 
:XB0:weather or not::f("whether or not", A_ThisHotkey, A_EndChar)
:XB0:well know::f("well known", A_ThisHotkey, A_EndChar)
:XB0:wendsay::f("Wednesday", A_ThisHotkey, A_EndChar) 
:XB0:wensday::f("Wednesday", A_ThisHotkey, A_EndChar) 
:XB0:went rouge::f("went rogue", A_ThisHotkey, A_EndChar)
:XB0:went threw::f("went through", A_ThisHotkey, A_EndChar)
:XB0:were apart of::f("were a part of", A_ThisHotkey, A_EndChar)
:XB0:were began::f("were begun", A_ThisHotkey, A_EndChar)
:XB0:were build::f("were built", A_ThisHotkey, A_EndChar)
:XB0:were cutoff::f("were cut off", A_ThisHotkey, A_EndChar)
:XB0:were drew::f("were drawn", A_ThisHotkey, A_EndChar)
:XB0:were he was::f("where he was", A_ThisHotkey, A_EndChar)
:XB0:were it was::f("where it was", A_ThisHotkey, A_EndChar)
:XB0:were it's::f("were its", A_ThisHotkey, A_EndChar)
:XB0:were knew::f("were known", A_ThisHotkey, A_EndChar)
:XB0:were know::f("were known", A_ThisHotkey, A_EndChar)
:XB0:were lain::f("were laid", A_ThisHotkey, A_EndChar)
:XB0:were lead by::f("were led by", A_ThisHotkey, A_EndChar)
:XB0:were loathe to::f("were loath to", A_ThisHotkey, A_EndChar)
:XB0:were meet by::f("were met by", A_ThisHotkey, A_EndChar)
:XB0:were meet with::f("were met with", A_ThisHotkey, A_EndChar)
:XB0:were overran::f("were overrun", A_ThisHotkey, A_EndChar)
:XB0:were ran::f("were run", A_ThisHotkey, A_EndChar)
:XB0:were rebuild::f("were rebuilt", A_ThisHotkey, A_EndChar)
:XB0:were reran::f("were rerun", A_ThisHotkey, A_EndChar)
:XB0:were rode::f("were ridden", A_ThisHotkey, A_EndChar)
:XB0:were sang::f("were sung", A_ThisHotkey, A_EndChar)
:XB0:were set-up::f("were set up", A_ThisHotkey, A_EndChar)
:XB0:were setup::f("were set up", A_ThisHotkey, A_EndChar)
:XB0:were she was::f("where she was", A_ThisHotkey, A_EndChar)
:XB0:were showed::f("were shown", A_ThisHotkey, A_EndChar)
:XB0:were shut-out::f("were shut out", A_ThisHotkey, A_EndChar)
:XB0:were shutdown::f("were shut down", A_ThisHotkey, A_EndChar)
:XB0:were shutoff::f("were shut off", A_ThisHotkey, A_EndChar)
:XB0:were shutout::f("were shut out", A_ThisHotkey, A_EndChar)
:XB0:were spend::f("were spent", A_ThisHotkey, A_EndChar)
:XB0:were suppose to::f("were supposed to", A_ThisHotkey, A_EndChar)
:XB0:were the dominate::f("were the dominant", A_ThisHotkey, A_EndChar)
:XB0:were took::f("were taken", A_ThisHotkey, A_EndChar)
:XB0:were tore::f("were torn", A_ThisHotkey, A_EndChar)
:XB0:were use to::f("were used to", A_ThisHotkey, A_EndChar)
:XB0:were wrote::f("were written", A_ThisHotkey, A_EndChar)
:XB0:wereabouts::f("whereabouts", A_ThisHotkey, A_EndChar) 
:XB0:wern't::f("weren't", A_ThisHotkey, A_EndChar) 
:XB0:wet your::f("whet your", A_ThisHotkey, A_EndChar)
:XB0:wether or not::f("whether or not", A_ThisHotkey, A_EndChar)
:XB0:what lead to::f("what led to", A_ThisHotkey, A_EndChar)
:XB0:what lied::f("what lay", A_ThisHotkey, A_EndChar)
:XB0:when ever::f("whenever", A_ThisHotkey, A_EndChar)
:XB0:whent he::f("when the", A_ThisHotkey, A_EndChar) 
:XB0:wheras::f("whereas", A_ThisHotkey, A_EndChar) 
:XB0:where abouts::f("whereabouts", A_ThisHotkey, A_EndChar)
:XB0:where as::f("whereas", A_ThisHotkey, A_EndChar)
:XB0:where being::f("were being", A_ThisHotkey, A_EndChar)
:XB0:where by::f("whereby", A_ThisHotkey, A_EndChar)
:XB0:where him::f("where he", A_ThisHotkey, A_EndChar)
:XB0:where made::f("were made", A_ThisHotkey, A_EndChar)
:XB0:where taken::f("were taken", A_ThisHotkey, A_EndChar)
:XB0:where upon::f("whereupon", A_ThisHotkey, A_EndChar)
:XB0:where won::f("were won", A_ThisHotkey, A_EndChar)
:XB0:whereas as::f("whereas", A_ThisHotkey, A_EndChar)
:XB0:wherease::f("whereas", A_ThisHotkey, A_EndChar) 
:XB0:whereever::f("wherever", A_ThisHotkey, A_EndChar)
:XB0:whic::f("which", A_ThisHotkey, A_EndChar)
:XB0:which had lead::f("which had led", A_ThisHotkey, A_EndChar)
:XB0:which has lead::f("which has led", A_ThisHotkey, A_EndChar)
:XB0:which have lead::f("which have led", A_ThisHotkey, A_EndChar)
:XB0:which where::f("which were", A_ThisHotkey, A_EndChar)
:XB0:whicht he::f("which the", A_ThisHotkey, A_EndChar) 
:XB0:while him::f("while he", A_ThisHotkey, A_EndChar)
:XB0:who had lead::f("who had led", A_ThisHotkey, A_EndChar)
:XB0:who has lead::f("who has led", A_ThisHotkey, A_EndChar)
:XB0:who have lead::f("who have led", A_ThisHotkey, A_EndChar)
:XB0:who setup::f("who set up", A_ThisHotkey, A_EndChar)
:XB0:who use to::f("who used to", A_ThisHotkey, A_EndChar)
:XB0:who where::f("who were", A_ThisHotkey, A_EndChar)
:XB0:who's actual::f("whose actual", A_ThisHotkey, A_EndChar)
:XB0:who's brother::f("whose brother", A_ThisHotkey, A_EndChar)
:XB0:who's father::f("whose father", A_ThisHotkey, A_EndChar)
:XB0:who's mother::f("whose mother", A_ThisHotkey, A_EndChar)
:XB0:who's name::f("whose name", A_ThisHotkey, A_EndChar)
:XB0:who's opinion::f("whose opinion", A_ThisHotkey, A_EndChar)
:XB0:who's own::f("whose own", A_ThisHotkey, A_EndChar)
:XB0:who's parents::f("whose parents", A_ThisHotkey, A_EndChar)
:XB0:who's previous::f("whose previous", A_ThisHotkey, A_EndChar)
:XB0:who's team::f("whose team", A_ThisHotkey, A_EndChar)
:XB0:wholey::f("wholly", A_ThisHotkey, A_EndChar)
:XB0:wholy::f("wholly", A_ThisHotkey, A_EndChar)
:XB0:whther::f("whether", A_ThisHotkey, A_EndChar)
:XB0:will backup::f("will back up", A_ThisHotkey, A_EndChar)
:XB0:will buyout::f("will buy out", A_ThisHotkey, A_EndChar)
:XB0:will of::f("will have", A_ThisHotkey, A_EndChar) 
:XB0:will shutdown::f("will shut down", A_ThisHotkey, A_EndChar)
:XB0:will shutoff::f("will shut off", A_ThisHotkey, A_EndChar)
:XB0:willbe::f("will be", A_ThisHotkey, A_EndChar) 
:XB0:with be::f("will be", A_ThisHotkey, A_EndChar)
:XB0:with in::f("within", A_ThisHotkey, A_EndChar)
:XB0:with it's::f("with its", A_ThisHotkey, A_EndChar)
:XB0:with on of::f("with one of", A_ThisHotkey, A_EndChar)
:XB0:with out::f("without", A_ThisHotkey, A_EndChar)
:XB0:with regards to::f("with regard to", A_ThisHotkey, A_EndChar)
:XB0:with who::f("with whom", A_ThisHotkey, A_EndChar)
:XB0:witha::f("with a", A_ThisHotkey, A_EndChar) 
:XB0:witheld::f("withheld", A_ThisHotkey, A_EndChar)
:XB0:withi t::f("with it", A_ThisHotkey, A_EndChar)
:XB0:within it's::f("within its", A_ThisHotkey, A_EndChar)
:XB0:within site of::f("within sight of", A_ThisHotkey, A_EndChar)
:XB0:withing::f("within", A_ThisHotkey, A_EndChar) 
:XB0:witht he::f("with the", A_ThisHotkey, A_EndChar) 
:XB0:wo'nt::f("won't", A_ThisHotkey, A_EndChar) 
:XB0:won it's::f("won its", A_ThisHotkey, A_EndChar)
:XB0:wonderfull::f("wonderful", A_ThisHotkey, A_EndChar)
:XB0:wordlwide::f("worldwide", A_ThisHotkey, A_EndChar) 
:XB0:working progress::f("work in progress", A_ThisHotkey, A_EndChar)
:XB0:world wide::f("worldwide", A_ThisHotkey, A_EndChar)
:XB0:worse comes to worse::f("worse comes to worst", A_ThisHotkey, A_EndChar)
:XB0:worse then::f("worse than", A_ThisHotkey, A_EndChar)
:XB0:worse-case scenario::f("worst-case scenario", A_ThisHotkey, A_EndChar)
:XB0:worst comes to worst::f("worse comes to worst", A_ThisHotkey, A_EndChar)
:XB0:worst than::f("worse than", A_ThisHotkey, A_EndChar)
:XB0:worth it's::f("worth its", A_ThisHotkey, A_EndChar)
:XB0:worth while::f("worthwhile", A_ThisHotkey, A_EndChar)
:XB0:would backup::f("would back up", A_ThisHotkey, A_EndChar)
:XB0:would comeback::f("would come back", A_ThisHotkey, A_EndChar)
:XB0:would fair::f("would fare", A_ThisHotkey, A_EndChar)
:XB0:would forego::f("would forgo", A_ThisHotkey, A_EndChar)
:XB0:would of::f("would have", A_ThisHotkey, A_EndChar) 
:XB0:would setup::f("would set up", A_ThisHotkey, A_EndChar)
:XB0:wouldbe::f("would be", A_ThisHotkey, A_EndChar) 
:XB0:wouldnt::f("wouldn't", A_ThisHotkey, A_EndChar) 
:XB0:wreck havoc::f("wreak havoc", A_ThisHotkey, A_EndChar)
:XB0:writers block::f("writer's block", A_ThisHotkey, A_EndChar)
:XB0:you're own::f("your own", A_ThisHotkey, A_EndChar) 
:XB0:you;d::f("you'd", A_ThisHotkey, A_EndChar) 
:XB0:youare::f("you are", A_ThisHotkey, A_EndChar) 
:XB0:younger then::f("younger than", A_ThisHotkey, A_EndChar)
:XB0:your a::f("you're a", A_ThisHotkey, A_EndChar) 
:XB0:your an::f("you're an", A_ThisHotkey, A_EndChar) 
:XB0:your her::f("you're her", A_ThisHotkey, A_EndChar) 
:XB0:your here::f("you're here", A_ThisHotkey, A_EndChar) 
:XB0:your his::f("you're his", A_ThisHotkey, A_EndChar) 
:XB0:your my::f("you're my", A_ThisHotkey, A_EndChar) 
:XB0:your the::f("you're the", A_ThisHotkey, A_EndChar) 
:XB0:your their::f("you're their", A_ThisHotkey, A_EndChar) 
:XB0:your your::f("you're your", A_ThisHotkey, A_EndChar) 
:XB0:youseff::f("yousef", A_ThisHotkey, A_EndChar) 
:XB0:youself::f("yourself", A_ThisHotkey, A_EndChar) 
:XB0:youve::f("you've", A_ThisHotkey, A_EndChar) 
:XB0:youv’e::f("you've", A_ThisHotkey, A_EndChar) 
:XB0?*:0n0::f("-n-", A_ThisHotkey, A_EndChar) ; For this-n-that
:XB0?*:abaptiv::f("adaptiv", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:abberr::f("aberr", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:abbout::f("about", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:abck::f("back", A_ThisHotkey, A_EndChar) ; Fixes 410 words
:XB0?*:abilt::f("abilit", A_ThisHotkey, A_EndChar) ; Fixes 1110 words
:XB0?*:ablit::f("abilit", A_ThisHotkey, A_EndChar) ; Fixes 1110 words
:XB0?*:abotu::f("about", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:abrit::f("arbit", A_ThisHotkey, A_EndChar) ; Fixes 53 words
:XB0?*:abuda::f("abunda", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:acadm::f("academ", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:accadem::f("academ", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:acccus::f("accus", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:acceller::f("acceler", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:accensi::f("ascensi", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:acceptib::f("acceptab", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:accessab::f("accessib", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:accomadat::f("accommodat", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:accomo::f("accommo", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:accoring::f("according", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:accous::f("acous", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:accqu::f("acqu", A_ThisHotkey, A_EndChar) ; Fixes 89 words
:XB0?*:accro::f("acro", A_ThisHotkey, A_EndChar) ; Fixes 145 words, but misspells accroides (An alcohol-soluble resin from Australian trees; used in varnishes and in manufacturing paper) 
:XB0?*:accuss::f("accus", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:acede::f("acade", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:acheiv::f("achiev", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:achievment::f("achievement", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:acocu::f("accou", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:acom::f("accom", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:acquaintence::f("acquaintance", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:acquiantence::f("acquaintance", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:actial::f("actical", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:acurac::f("accurac", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:acustom::f("accustom", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:acys::f("acies", A_ThisHotkey, A_EndChar) ; Fixes 101 words
:XB0?*:adantag::f("advantag", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:adaption::f("adaptation", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:adavan::f("advan", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:addion::f("addition", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:additon::f("addition", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:addm::f("adm", A_ThisHotkey, A_EndChar) ; Fixes 144 words
:XB0?*:addop::f("adop", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:addow::f("adow", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:adequite::f("adequate", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:adif::f("atif", A_ThisHotkey, A_EndChar) ; Fixes 50 words, but misspells Gadiformes (Cods, haddocks, grenadiers; in some classifications considered equivalent to the order Anacanthini)
:XB0?*:adiquate::f("adequate", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:admend::f("amend", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:admissab::f("admissib", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:admited::f("admitted", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:admition::f("admission", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:adquate::f("adequate", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:adquir::f("acquir", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:advanag::f("advantag", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:adventr::f("adventur", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:advertant::f("advertent", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:adviced::f("advised", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:aelog::f("aeolog", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:aeriel::f("aerial", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:affilat::f("affiliat", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:affilliat::f("affiliat", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:affort::f("afford", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:affraid::f("afraid", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:aggree::f("agree", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:agrava::f("aggrava", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:agreemnt::f("agreement", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:agreg::f("aggreg", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:agress::f("aggress", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:ahev::f("have", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?*:ahpp::f("happ", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:ahve::f("have", A_ThisHotkey, A_EndChar) ; Fixes 47 words, but misspells Ahvenanmaa, Jahvey, Wahvey, Yahve, Yahveh (All are different Hebrew names for God.) 
:XB0?*:aible::f("able", A_ThisHotkey, A_EndChar) ; Fixes 2387 words
:XB0?*:aicraft::f("aircraft", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:ailabe::f("ailable", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:ailiab::f("ailab", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:ailib::f("ailab", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:aisian::f("Asian", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:aiton::f("ation", A_ThisHotkey, A_EndChar) ; Fixes 5205 words
:XB0?*:alchohol::f("alcohol", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:alchol::f("alcohol", A_ThisHotkey, A_EndChar) ;fixes 28 words
:XB0?*:alcohal::f("alcohol", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:aliab::f("ailab", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:alibit::f("abilit", A_ThisHotkey, A_EndChar) ; Fixes 1110 words
:XB0?*:alitv::f("lativ", A_ThisHotkey, A_EndChar) ; Fixes 97 words
:XB0?*:allign::f("align", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:allth::f("alth", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:allto::f("alto", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:alochol::f("alcohol", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:alott::f("allott", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:alowe::f("allowe", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:altion::f("lation", A_ThisHotkey, A_EndChar) ; Fixes 448 words
:XB0?*:ameria::f("America", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:amerli::f("ameli", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:ametal::f("amental", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:amke::f("make", A_ThisHotkey, A_EndChar) ; Fixes 122 words
:XB0?*:amking::f("making", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:ammou::f("amou", A_ThisHotkey, A_EndChar) ; Fixes 99 words
:XB0?*:amny::f("many", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:analitic::f("analytic", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:anbd::f("and", A_ThisHotkey, A_EndChar) ; Fixes 2083 words
:XB0?*:angabl::f("angeabl", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:angeing::f("anging", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:anmd::f("and", A_ThisHotkey, A_EndChar) ; Fixes 2083 words
:XB0?*:annn::f("ann", A_ThisHotkey, A_EndChar) ; Fixes 650 words
:XB0?*:annoi::f("anoi", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:annuled::f("annulled", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:anomo::f("anoma", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:anounc::f("announc", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:antaine::f("antine", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:anwser::f("answer", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:aost::f("oast", A_ThisHotkey, A_EndChar) ; Fixes 75 words
:XB0?*:aparen::f("apparen", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:apear::f("appear", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:aplic::f("applic", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:aplie::f("applie", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:apoint::f("appoint", A_ThisHotkey, A_EndChar) ; Fixes 30 words ; Misspells username Datapoint.
:XB0?*:apparan::f("apparen", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:appart::f("apart", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:appeares::f("appears", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:apperance::f("appearance", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:appol::f("apol", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?*:apprearance::f("appearance", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:apreh::f("appreh", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:apropri::f("appropri", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:aprov::f("approv", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:aptue::f("apture", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:aquain::f("acquain", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:aquiant::f("acquaint", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:aquisi::f("acquisi", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:arange::f("arrange", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:arbitar::f("arbitrar", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:archaelog::f("archaeolog", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:archao::f("archeo", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:archetect::f("architect", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:architectual::f("architectural", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:areat::f("arat", A_ThisHotkey, A_EndChar) ; Fixes 136 words
:XB0?*:arguement::f("argument", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:arhip::f("arship", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:ariage::f("arriage", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:arign::f("aring", A_ThisHotkey, A_EndChar) ; Fixes 140 words
:XB0?*:ariman::f("airman", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:arogen::f("arrogan", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:arrri::f("arri", A_ThisHotkey, A_EndChar) ; Fixes 159 words
:XB0?*:artdridge::f("artridge", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:articel::f("article", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:artrige::f("artridge", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:asdver::f("adver", A_ThisHotkey, A_EndChar) ; Fixes 67 words
:XB0?*:asign::f("assign", A_ThisHotkey, A_EndChar) ; Fixes 27
:XB0?*:asnd::f("and", A_ThisHotkey, A_EndChar) ; Fixes 2083 words
:XB0?*:asociat::f("associat", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:asorb::f("absorb", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:asr::f("ase", A_ThisHotkey, A_EndChar) ; Fixes 698 words, but misspells Basra (An oil city in Iraq) 
:XB0?*:assempl::f("assembl", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:assertation::f("assertion", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:assoca::f("associa", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:assoicat::f("associat", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:asss::f("as", A_ThisHotkey, A_EndChar) ; Fixes 9311 words
:XB0?*:assym::f("asym", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:asthet::f("aesthet", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:asuing::f("ausing", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:atain::f("attain", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:ateing::f("ating", A_ThisHotkey, A_EndChar) ; Fixes 1117 words
:XB0?*:atempt::f("attempt", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:atention::f("attention", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:athori::f("authori", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:aticula::f("articula", A_ThisHotkey, A_EndChar) ; Fixes 69 words
:XB0?*:atoin::f("ation", A_ThisHotkey, A_EndChar) ; Fixes 5229 words
:XB0?*:atribut::f("attribut", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:attemt::f("attempt", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:attenden::f("attendan", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:attensi::f("attenti", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:attentioin::f("attention", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:auclar::f("acular", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:audiance::f("audience", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:auther::f("author", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:authobiograph::f("autobiograph", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:authror::f("author", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:automonom::f("autonom", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:avaialb::f("availab", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:availb::f("availab", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:availib::f("availab", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:avalab::f("availab", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:avalib::f("availab", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:aveing::f("aving", A_ThisHotkey, A_EndChar) ; Fixes 60 words
:XB0?*:avila::f("availa", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:awess::f("awless", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:awya::f("away", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:babilat::f("babilit", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:bakc::f("back", A_ThisHotkey, A_EndChar) ; Fixes 410 words
:XB0?*:ballan::f("balan", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:baout::f("about", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:bateabl::f("batabl", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:bcak::f("back", A_ThisHotkey, A_EndChar) ; Fixes 410 words
:XB0?*:beahv::f("behav", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:beatiful::f("beautiful", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:beaurocra::f("bureaucra", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:becoe::f("become", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:becomm::f("becom", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:bedore::f("before", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:beei::f("bei", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:behaio::f("behavio", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:belan::f("blan", A_ThisHotkey, A_EndChar) ; Fixes 60 words
:XB0?*:belei::f("belie", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:belligeran::f("belligeren", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:benif::f("benef", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:bilsh::f("blish", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:biul::f("buil", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:blence::f("blance", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:bliah::f("blish", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:blich::f("blish", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:blihs::f("blish", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:blisg::f("blish", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:bllish::f("blish", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:boaut::f("about", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:bombardement::f("bombardment", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:bombarment::f("bombardment", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:bondary::f("boundary", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:borrom::f("bottom", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:boundr::f("boundar", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:boxs::f("boxes", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:bradcast::f("broadcast", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:breif::f("brief", A_ThisHotkey, A_EndChar) ; Fixes 22 words.
:XB0?*:brenc::f("branc", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?*:broadacast::f("broadcast", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:brod::f("broad", A_ThisHotkey, A_EndChar) ; Fixes 55 words. Misspells brodiaea (a type of plant)
:XB0?*:buisn::f("busin", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:buring::f("burying", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:burrie::f("burie", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:busness::f("business", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:bussiness::f("business", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:caculater::f("calculator", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:caffin::f("caffein", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:caharcter::f("character", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:cahrac::f("charac", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:calculater::f("calculator", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:calculla::f("calcula", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:calculs::f("calculus", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:caluclat::f("calculat", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:caluculat::f("calculat", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:calulat::f("calculat", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:camae::f("came", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0?*:campagin::f("campaign", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:campain::f("campaign", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:candad::f("candid", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:candiat::f("candidat", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:candidta::f("candidat", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:cannonic::f("canonic", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:caperbi::f("capabi", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:capibl::f("capabl", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:captia::f("capita", A_ThisHotkey, A_EndChar) ; Fixes 69 words
:XB0?*:caracht::f("charact", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:caract::f("charact", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:carcirat::f("carcerat", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:carism::f("charism", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:cartileg::f("cartilag", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:cartilidg::f("cartilag", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:casette::f("cassette", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:casue::f("cause", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:catagor::f("categor", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:catergor::f("categor", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:cathlic::f("catholic", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:catholoc::f("catholic", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:catre::f("cater", A_ThisHotkey, A_EndChar) ; Fixes 23 words.  Misspells fornicatress
:XB0?*:ccce::f("cce", A_ThisHotkey, A_EndChar) ; Fixes 175 words
:XB0?*:ccesi::f("ccessi", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:ceiev::f("ceiv", A_ThisHotkey, A_EndChar) ; Fixes 82 words
:XB0?*:ceing::f("cing", A_ThisHotkey, A_EndChar) ; Fixes 275 words
:XB0?*:cencu::f("censu", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:centente::f("centen", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:cerimo::f("ceremo", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:ceromo::f("ceremo", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:certian::f("certain", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:cesion::f("cession", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:cesor::f("cessor", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:cesser::f("cessor", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:cev::f("ceiv", A_ThisHotkey, A_EndChar) ; Fixes 82 words, but misspells ceviche (South American seafood dish)
:XB0?*:chagne::f("change", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:chaleng::f("challeng", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:challang::f("challeng", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:challengabl::f("challengeabl", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:changab::f("changeab", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:charasma::f("charisma", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:charater::f("character", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:charecter::f("character", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:charector::f("character", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:chargab::f("chargeab", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:chartiab::f("charitab", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:cheif::f("chief", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:chemcial::f("chemical", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:chemestr::f("chemistr", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:chict::f("chit", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:childen::f("children", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:chracter::f("character", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:chter::f("cter", A_ThisHotkey, A_EndChar) ; Fixes 221 words
:XB0?*:cidan::f("ciden", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:ciencio::f("cientio", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:ciepen::f("cipien", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:ciev::f("ceiv", A_ThisHotkey, A_EndChar) ; Fixes 82 words
:XB0?*:cigic::f("cific", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:cilation::f("ciliation", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:cilliar::f("cillar", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:circut::f("circuit", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:ciricu::f("circu", A_ThisHotkey, A_EndChar) ; Fixes 168 words
:XB0?*:cirp::f("crip", A_ThisHotkey, A_EndChar) ; Fixes 126 words, but misspells Scirpus (Rhizomatous perennial grasslike herbs)
:XB0?*:cison::f("cision", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:citment::f("citement", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:civilli::f("civili", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:clae::f("clea", A_ThisHotkey, A_EndChar) ; Fixes 151 words
:XB0?*:clasic::f("classic", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:clincial::f("clinical", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:clomation::f("clamation", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:cmo::f("com", A_ThisHotkey, A_EndChar) ; Fixes 1749 words
:XB0?*:cna::f("can", A_ThisHotkey, A_EndChar) ; Fixes 1019 words.  Misspells Pycnanthemum (mint), and Tridacna (giant clam).+
:XB0?*:coform::f("conform", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:cogis::f("cognis", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:cogiz::f("cogniz", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:cogntivie::f("cognitive", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:colaborat::f("collaborat", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:colecti::f("collecti", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:colelct::f("collect", A_ThisHotkey, A_EndChar) ; Fixes 69 words
:XB0?*:collon::f("colon", A_ThisHotkey, A_EndChar) ; Fixes 89 words
:XB0?*:comanie::f("companie", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:comany::f("company", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:comapan::f("compan", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:comapn::f("compan", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:comban::f("combin", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:combatent::f("combatant", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:combinatin::f("combination", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:combusi::f("combusti", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:comemmorat::f("commemorat", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:comemorat::f("commemorat", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:comision::f("commission", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:comiss::f("commiss", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:comitt::f("committ", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:commed::f("comed", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:commerical::f("commercial", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:commericial::f("commercial", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:commini::f("communi", A_ThisHotkey, A_EndChar) ; Fixes 117 words
:XB0?*:commision::f("commission", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:commite::f("committe", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:commongly::f("commonly", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:commuica::f("communica", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:commuinica::f("communica", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:communcia::f("communica", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:communia::f("communica", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:comnt::f("cont", A_ThisHotkey, A_EndChar) ; Fixes 587 words
:XB0?*:comon::f("common", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:compatab::f("compatib", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:compatiab::f("compatib", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:compeit::f("competit", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:compenc::f("compens", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:competan::f("competen", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:competati::f("competiti", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:competens::f("competenc", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:competive::f("competitive", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:comphr::f("compr", A_ThisHotkey, A_EndChar) ; Fixes 106 words
:XB0?*:compleate::f("complete", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:compleatness::f("completeness", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:comprab::f("comparab", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:comprimis::f("compromis", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:comun::f("commun", A_ThisHotkey, A_EndChar) ; Fixes 140 words
:XB0?*:concider::f("consider", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:concieve::f("conceive", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:concious::f("conscious", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:condidt::f("condit", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:conect::f("connect", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:conferanc::f("conferenc", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:configurea::f("configura", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:confort::f("comfort", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:conqur::f("conquer", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:conscen::f("consen", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:consdider::f("consider", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:consectu::f("consecu", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:consentr::f("concentr", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:consept::f("concept", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:consern::f("concern", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:conservit::f("conservat", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:consici::f("consci", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:consico::f("conscio", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:considerd::f("considered", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:considerit::f("considerat", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:consio::f("conscio", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:consitu::f("constitu", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:consoloda::f("consolida", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:consonent::f("consonant", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:constain::f("constrain", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:constin::f("contin", A_ThisHotkey, A_EndChar) ; Fixes 86 words
:XB0?*:consumate::f("consummate", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:consumbe::f("consume", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:contian::f("contain", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:contien::f("conscien", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:contigen::f("contingen", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:contined::f("continued", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:continential::f("continental", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:continetal::f("continental", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:contino::f("continuo", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:contitut::f("constitut", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:contravers::f("controvers", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:contributer::f("contributor", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:controle::f("controlle", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:controling::f("controlling", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:controveri::f("controversi", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:controversal::f("controversial", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:controvertial::f("controversial", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:contru::f("constru", A_ThisHotkey, A_EndChar) ; Fixes 73 words
:XB0?*:convenant::f("covenant", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:convential::f("conventional", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:convice::f("convince", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:coopor::f("cooper", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:coorper::f("cooper", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:copm::f("comp", A_ThisHotkey, A_EndChar) ; Fixes 729 words
:XB0?*:copty::f("copy", A_ThisHotkey, A_EndChar) ; Fixes 78 words
:XB0?*:coput::f("comput", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:copywrite::f("copyright", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:coropor::f("corpor", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?*:corpar::f("corpor", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?*:corpera::f("corpora", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0?*:corporta::f("corporat", A_ThisHotkey, A_EndChar) ; Fixes 53 words
:XB0?*:corprat::f("corporat", A_ThisHotkey, A_EndChar) ; Fixes 53 words
:XB0?*:corpro::f("corpor", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?*:corrispond::f("correspond", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:corruptab::f("corruptib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:costit::f("constit", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:cotten::f("cotton", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:countain::f("contain", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:couraing::f("couraging", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:couro::f("coro", A_ThisHotkey, A_EndChar) ; Fixes 53 words
:XB0?*:courur::f("cour", A_ThisHotkey, A_EndChar) ; Fixes 144 words
:XB0?*:cpom::f("com", A_ThisHotkey, A_EndChar) ; Fixes 1749 words
:XB0?*:cpoy::f("copy", A_ThisHotkey, A_EndChar) ; Fixes 78 words
:XB0?*:creaet::f("creat", A_ThisHotkey, A_EndChar) ; Fixes 75 words
:XB0?*:credia::f("credita", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:credida::f("credita", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:criib::f("crib", A_ThisHotkey, A_EndChar) ; Fixes 119 words
:XB0?*:crti::f("criti", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0?*:crticis::f("criticis", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:crusie::f("cruise", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:crutia::f("crucia", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:crystalisa::f("crystallisa", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:ctaegor::f("categor", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:ctail::f("cktail", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:ctent::f("ctant", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:cticious::f("ctitious", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:ctinos::f("ctions", A_ThisHotkey, A_EndChar) ; Fixes 214 words
:XB0?*:ctoin::f("ction", A_ThisHotkey, A_EndChar) ; Fixes 717 words
:XB0?*:cualr::f("cular", A_ThisHotkey, A_EndChar) ; Fixes 256 words
:XB0?*:cuas::f("caus", A_ThisHotkey, A_EndChar) ; Fixes 55 words
:XB0?*:cultral::f("cultural", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:cultue::f("culture", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:culure::f("culture", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:curcuit::f("circuit", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:cusotm::f("custom", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:cutsom::f("custom", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:cuture::f("culture", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:cxan::f("can", A_ThisHotkey, A_EndChar) ; Fixes 1015 words
:XB0?*:damenor::f("demeanor", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:damenour::f("demeanour", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:dammag::f("damag", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:damy::f("demy", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:daugher::f("daughter", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:dcument::f("document", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:ddti::f("dditi", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:deatil::f("detail", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:decend::f("descend", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:decideab::f("decidab", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:decrib::f("describ", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:dectect::f("detect", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:defendent::f("defendant", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:deffens::f("defens", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:deffin::f("defin", A_ThisHotkey, A_EndChar) ; Fixes 54 words
:XB0?*:definat::f("definit", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:defintion::f("definition", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:degrat::f("degrad", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:degred::f("degrad", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:deinc::f("dienc", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:delag::f("deleg", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:delevop::f("develop", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:demeno::f("demeano", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:demorcr::f("democr", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:denegrat::f("denigrat", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:denpen::f("depen", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:dentational::f("dental", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:deparment::f("department", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:depedant::f("dependent", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:depeden::f("dependen", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:dependan::f("dependen", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:deptart::f("depart", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:deram::f("dream", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:deriviate::f("derive", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:derivit::f("derivat", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:descib::f("describ", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:descision::f("decision", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:descus::f("discus", A_ThisHotkey, A_EndChar) ; Fixes 14 words.
:XB0?*:desided::f("decided", A_ThisHotkey, A_EndChar) ; Fixes 7 words.
:XB0?*:desinat::f("destinat", A_ThisHotkey, A_EndChar) ; Fixes 11 words.
:XB0?*:desireab::f("desirab", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:desision::f("decision", A_ThisHotkey, A_EndChar) ; Fixes 5 words.
:XB0?*:desitn::f("destin", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:despatch::f("dispatch", A_ThisHotkey, A_EndChar) ; Fixes 7 words.
:XB0?*:despensib::f("dispensab", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:despict::f("depict", A_ThisHotkey, A_EndChar) ; Fixes 10 words.
:XB0?*:despira::f("despera", A_ThisHotkey, A_EndChar) ; Fixes 9 words.
:XB0?*:dessign::f("design", A_ThisHotkey, A_EndChar) ; Fixes 51 words.
:XB0?*:destory::f("destroy", A_ThisHotkey, A_EndChar) ; Fixes 8 words.
:XB0?*:detecab::f("detectab", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:develeopr::f("developer", A_ThisHotkey, A_EndChar) ; Fixes 6 words.
:XB0?*:devellop::f("develop", A_ThisHotkey, A_EndChar) ; Fixes 44 words.
:XB0?*:developor::f("developer", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:developpe::f("develope", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:develp::f("develop", A_ThisHotkey, A_EndChar) ; Fixes 44 words.
:XB0?*:devid::f("divid", A_ThisHotkey, A_EndChar) ; Fixes 61 words.
:XB0?*:devolop::f("develop", A_ThisHotkey, A_EndChar) ; Fixes 44 words.
:XB0?*:dgeing::f("dging", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:dgement::f("dgment", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:diapl::f("displ", A_ThisHotkey, A_EndChar) ; Fixes 33 words.
:XB0?*:diarhe::f("diarrhoe", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:dicatb::f("dictab", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:diciplin::f("disciplin", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:dicover::f("discover", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:dicus::f("discus", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:difef::f("diffe", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:diferre::f("differe", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:differan::f("differen", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:diffren::f("differen", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:dimenion::f("dimension", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:dimention::f("dimension", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:dimesnion::f("dimension", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:diosese::f("diocese", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:dipend::f("depend", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:diriv::f("deriv", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:discrib::f("describ", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:disign::f("design", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:disipl::f("discipl", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:disolved::f("dissolved", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:dispaly::f("display", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:dispenc::f("dispens", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:dispensib::f("dispensab", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:disputib::f("disputab", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:disrict::f("district", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:distruct::f("destruct", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:ditonal::f("ditional", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:ditribut::f("distribut", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:divice::f("device", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:divsi::f("divisi", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:dmant::f("dment", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:dminst::f("dminist", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:doccu::f("docu", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:doctin::f("doctrin", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:docuement::f("document", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:docuemnt::f("document", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:documetn::f("document", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:documnet::f("document", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:doind::f("doing", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:dolan::f("dolen", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:doller::f("dollar", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:dominent::f("dominant", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:dowloads::f("download", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:dpend::f("depend", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:dramtic::f("dramatic", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:driect::f("direct", A_ThisHotkey, A_EndChar) ; Fixes 71 words
:XB0?*:driveing::f("driving", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:drnik::f("drink", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:dulgue::f("dulge", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:dupicat::f("duplicat", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:durig::f("during", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:durring::f("during", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:duting::f("during", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:eacll::f("ecall", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:eanr::f("earn", A_ThisHotkey, A_EndChar) ; Fixes 60 words
:XB0?*:eaolog::f("eolog", A_ThisHotkey, A_EndChar) ; Fixes 134 words
:XB0?*:eareance::f("earance", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:earence::f("earance", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:easen::f("easan", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:easr::f("ears", A_ThisHotkey, A_EndChar) ; Fixes 102 words
:XB0?*:ecco::f("eco", A_ThisHotkey, A_EndChar) ; Fixes 994 words, but misspells Prosecco (Italian wine) and recco (abbrev. for Reconnaissance)
:XB0?*:eccu::f("ecu", A_ThisHotkey, A_EndChar) ; Fixes 353 words
:XB0?*:eceed::f("ecede", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:eceonom::f("econom", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:ecepi::f("ecipi", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:ecomon::f("econom", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:ecuat::f("equat", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:ecyl::f("ecycl", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:edabl::f("edibl", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:eearl::f("earl", A_ThisHotkey, A_EndChar) ; Fixes 66 words
:XB0?*:eeen::f("een", A_ThisHotkey, A_EndChar) ; Fixes 452 words
:XB0?*:eeep::f("eep", A_ThisHotkey, A_EndChar) ; Fixes 316 words
:XB0?*:eferan::f("eferen", A_ThisHotkey, A_EndChar) ; Fixes 35 words 
:XB0?*:efered::f("eferred", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:efering::f("eferring", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:efern::f("eferen", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:effecien::f("efficien", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:efficen::f("efficien", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:egth::f("ength", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:ehter::f("ether", A_ThisHotkey, A_EndChar) ; Fixes 84 words
:XB0?*:eild::f("ield", A_ThisHotkey, A_EndChar) ; Fixes 147 words
:XB0?*:elavan::f("elevan", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:elction::f("election", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:electic::f("electric", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:electrial::f("electrical", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:elemin::f("elimin", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:eletric::f("electric", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:elien::f("elian", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:eligab::f("eligib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:eligo::f("eligio", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:eliment::f("element", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:ellected::f("elected", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:elyhood::f("elihood", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:embarass::f("embarrass", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:emce::f("ence", A_ThisHotkey, A_EndChar) ; Fixes 775 words, but misspells emcee (host at formal occasion)
:XB0?*:emiting::f("emitting", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:emmediate::f("immediate", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:emmigr::f("emigr", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:emmin::f("emin", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:emmis::f("emis", A_ThisHotkey, A_EndChar) ; Fixes 214 words
:XB0?*:emmit::f("emitt", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:emostr::f("emonstr", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:empahs::f("emphas", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:emperic::f("empiric", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:emphais::f("emphasis", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:emphsis::f("emphasis", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:emprison::f("imprison", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:enchang::f("enchant", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:encial::f("ential", A_ThisHotkey, A_EndChar) ; Fixes 244 words
:XB0?*:endand::f("endant", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:endig::f("ending", A_ThisHotkey, A_EndChar) ; Fixes 109 words
:XB0?*:enduc::f("induc", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:enece::f("ence", A_ThisHotkey, A_EndChar) ; Fixes 775 words
:XB0?*:enence::f("enance", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:enflam::f("inflam", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:engagment::f("engagement", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:engeneer::f("engineer", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:engieneer::f("engineer", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:engten::f("engthen", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:entagl::f("entangl", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:entaly::f("entally", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:entatr::f("entar", A_ThisHotkey, A_EndChar) ; Fixes 81 words
:XB0?*:entce::f("ence", A_ThisHotkey, A_EndChar) ; Fixes 775 words
:XB0?*:entgh::f("ength", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:enthusiatic::f("enthusiastic", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:entiatiation::f("entiation", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:entily::f("ently", A_ThisHotkey, A_EndChar) ; Fixes 261 wordsuently
:XB0?*:envolu::f("evolu", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:enxt::f("next", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:eperat::f("eparat", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:equalibr::f("equilibr", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:equelibr::f("equilibr", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:equialent::f("equivalent", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:equilibium::f("equilibrium", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:equilibrum::f("equilibrium", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:equivelant::f("equivalent", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:equivilant::f("equivalent", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:equivilent::f("equivalent", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:erchen::f("erchan", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:ereance::f("earance", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:eremt::f("erent", A_ThisHotkey, A_EndChar) ; Fixes 96 words
:XB0?*:ernece::f("erence", A_ThisHotkey, A_EndChar) ; Fixes 54 words
:XB0?*:ernt::f("erent", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:erruped::f("errupted", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:esab::f("essab", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:esential::f("essential", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:esisten::f("esistan", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:esitmat::f("estimat", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:esnt::f("esent", A_ThisHotkey, A_EndChar) ; Fixes 103 words
:XB0?*:esorce::f("esource", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:essense::f("essence", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:essentail::f("essential", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:essentual::f("essential", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:essesital::f("essential", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:estabish::f("establish", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:estoin::f("estion", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:esxual::f("sexual", A_ThisHotkey, A_EndChar) ; Fixes 91 words
:XB0?*:etanc::f("etenc", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:etead::f("eated", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:eveyr::f("every", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:exagerat::f("exaggerat", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:exagerrat::f("exaggerat", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:exampt::f("exempt", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:exapan::f("expan", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:excact::f("exact", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:excang::f("exchang", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:excecut::f("execut", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:excedd::f("exceed", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:excercis::f("exercis", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:exchanch::f("exchang", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:excist::f("exist", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:execis::f("exercis", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:exeed::f("exceed", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:exept::f("except", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:exersize::f("exercise", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:exict::f("excit", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:exinct::f("extinct", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:exisit::f("exist", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:existan::f("existen", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:exlile::f("exile", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:exmapl::f("exampl", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:expalin::f("explain", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:expeced::f("expected", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:expecial::f("especial", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:experianc::f("experienc", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:expidi::f("expedi", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:expierenc::f("experienc", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:expirien::f("experien", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:explict::f("explicit", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:exploitit::f("exploitat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:explotat::f("exploitat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:exprienc::f("experienc", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:exressed::f("expressed", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:exsis::f("exis", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:extention::f("extension", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:extint::f("extinct", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:facist::f("fascist", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:fagia::f("phagia", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:falab::f("fallib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:fallab::f("fallib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:familar::f("familiar", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:familli::f("famili", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:fammi::f("fami", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0?*:fascit::f("facet", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:fasia::f("phasia", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:fatc::f("fact", A_ThisHotkey, A_EndChar) ; Fixes 200 words
:XB0?*:fature::f("facture", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:faught::f("fought", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:feasable::f("feasible", A_ThisHotkey, A_EndChar) ; Fixes 11 words, but misspells unfeasable (archaic, no longer used)
:XB0?*:fedre::f("feder", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:femmi::f("femi", A_ThisHotkey, A_EndChar) ; Fixes 53 words
:XB0?*:fencive::f("fensive", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:ferec::f("ferenc", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:fereing::f("fering", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:feriang::f("ferring", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:ferren::f("feren", A_ThisHotkey, A_EndChar) ; Fixes 113 words
:XB0?*:fertily::f("fertility", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:fesion::f("fession", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:fesser::f("fessor", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:festion::f("festation", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:ffese::f("fesse", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:ffesion::f("fession", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:fficen::f("fficien", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:fianit::f("finit", A_ThisHotkey, A_EndChar) ; Fixes 79 words
:XB0?*:fictious::f("fictitious", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:fidn::f("find", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:fiet::f("feit", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:filiament::f("filament", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:filitrat::f("filtrat", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:fimil::f("famil", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:finac::f("financ", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:finat::f("finit", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:finet::f("finit", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:finining::f("fining", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:firc::f("furc", A_ThisHotkey, A_EndChar) ; Fixes 33 words, Case-sensitive to not misspell FIRCA (sustainable funding mechanism for agricultural development)
:XB0?*:firend::f("friend", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:firmm::f("firm", A_ThisHotkey, A_EndChar) ; Fixes 85 words
:XB0?*:fisi::f("fissi", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:flama::f("flamma", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:flourid::f("fluorid", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:flourin::f("fluorin", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:fluan::f("fluen", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:fluorish::f("flourish", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:focuss::f("focus", A_ThisHotkey, A_EndChar) ; Fixes 6 words 
:XB0?*:foer::f("fore", A_ThisHotkey, A_EndChar) ; Fixes 340 words
:XB0?*:follwo::f("follow", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:folow::f("follow", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:fomat::f("format", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:fomed::f("formed", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:fomr::f("form", A_ThisHotkey, A_EndChar) ; Fixes 1269 words
:XB0?*:foneti::f("phoneti", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:fontrier::f("frontier", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:fooot::f("foot", A_ThisHotkey, A_EndChar) ; Fixes 176 words
:XB0?*:forbiden::f("forbidden", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:foretun::f("fortun", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:forgetab::f("forgettab", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:forgiveabl::f("forgivabl", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:formidible::f("formidable", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:formost::f("foremost", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:forsee::f("foresee", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:forwrd::f("forward", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:foucs::f("focus", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:foudn::f("found", A_ThisHotkey, A_EndChar) ; Fixes 62 words
:XB0?*:fourti::f("forti", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:fourtun::f("fortun", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:foward::f("forward", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:freind::f("friend", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:frence::f("ference", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:fromed::f("formed", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:fromi::f("formi", A_ThisHotkey, A_EndChar) ; Fixes 84 words
:XB0?*:fucnt::f("funct", A_ThisHotkey, A_EndChar) ; Fixes 60 words
:XB0?*:fufill::f("fulfill", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:fulen::f("fluen", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?*:fullfill::f("fulfill", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:furut::f("furt", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:gallax::f("galax", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:galvin::f("galvan", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:ganaly::f("ginally", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:ganera::f("genera", A_ThisHotkey, A_EndChar) ; Fixes 124 words
:XB0?*:garant::f("guarant", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:garav::f("grav", A_ThisHotkey, A_EndChar) ; Fixes 128 words
:XB0?*:garnison::f("garrison", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:gaurant::f("guarant", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:gaurd::f("guard", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0?*:gemer::f("gener", A_ThisHotkey, A_EndChar) ; Fixes 151 words
:XB0?*:generatt::f("generat", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:gestab::f("gestib", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:giid::f("good", A_ThisHotkey, A_EndChar) ; Fixes 31 words, but misspells Phalangiidae (typoe of Huntsman spider)
:XB0?*:giveing::f("giving", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:glight::f("flight", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:glph::f("glyph", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:glua::f("gula", A_ThisHotkey, A_EndChar) ; Fixes 174 words
:XB0?*:gnficia::f("gnifica", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:gnizen::f("gnizan", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:godess::f("goddess", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:gorund::f("ground", A_ThisHotkey, A_EndChar) ; Fixes 80 words
:XB0?*:gourp::f("group", A_ThisHotkey, A_EndChar) ; Fixes 28 words 
:XB0?*:govement::f("government", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:govenment::f("government", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:govenrment::f("government", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:govera::f("governa", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:goverment::f("government", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:govor::f("govern", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:gradded::f("graded", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:graffitti::f("graffiti", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:grama::f("gramma", A_ThisHotkey, A_EndChar) ; Fixes 72 words, but misspells grama (Pasture grass of plains of South America and western North America)
:XB0?*:grammma::f("gramma", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:greatful::f("grateful", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:greee::f("gree", A_ThisHotkey, A_EndChar) ; Fixes 185 words
:XB0?*:gresion::f("gression", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:gropu::f("group", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:gruop::f("group", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:grwo::f("grow", A_ThisHotkey, A_EndChar) ; Fixes 67 words
:XB0?*:gsit::f("gist", A_ThisHotkey, A_EndChar) ; Fixes 585 words
:XB0?*:gubl::f("guabl", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:guement::f("gument", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:guidence::f("guidance", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:gurantee::f("guarantee", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:habitans::f("habitants", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:habition::f("hibition", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:haneg::f("hange", A_ThisHotkey, A_EndChar) ; Fixes 69 words
:XB0?*:harased::f("harassed", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:havour::f("havior", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:hcange::f("change", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:hcih::f("hich", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:heirarch::f("hierarch", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:heiroglyph::f("hieroglyph", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:heiv::f("hiev", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:herant::f("herent", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:heridit::f("heredit", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:hertia::f("herita", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:hertzs::f("hertz", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:hicial::f("hical", A_ThisHotkey, A_EndChar) ; Fixes 170 words
:XB0?*:hierach::f("hierarch", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:hierarcic::f("hierarchic", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:higway::f("highway", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:hnag::f("hang", A_ThisHotkey, A_EndChar) ; Fixes 150 words
:XB0?*:holf::f("hold", A_ThisHotkey, A_EndChar) ; Fixes 120 words
:XB0?*:hospiti::f("hospita", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:houno::f("hono", A_ThisHotkey, A_EndChar) ; Fixes 99 words
:XB0?*:hstor::f("histor", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:humerous::f("humorous", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:humur::f("humour", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:hvae::f("have", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?*:hvai::f("havi", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:hvea::f("have", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?*:hwere::f("where", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:hwihc::f("which", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:hydog::f("hydrog", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:hymm::f("hym", A_ThisHotkey, A_EndChar) ; Fixes 125 words
:XB0?*:ibile::f("ible", A_ThisHotkey, A_EndChar) ; Fixes 367 words
:XB0?*:ibilt::f("ibilit", A_ThisHotkey, A_EndChar) ; Fixes 281 words
:XB0?*:iblit::f("ibilit", A_ThisHotkey, A_EndChar) ; Fixes 281 words
:XB0?*:icibl::f("iceabl", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:iciton::f("iction", A_ThisHotkey, A_EndChar) ; Fixes 89 words
:XB0?*:ictoin::f("iction", A_ThisHotkey, A_EndChar) ; Fixes 89 words
:XB0?*:idenital::f("idential", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:iegh::f("eigh", A_ThisHotkey, A_EndChar) ; Fixes 186 words
:XB0?*:iegn::f("eign", A_ThisHotkey, A_EndChar) ; Fixes 83 words
:XB0?*:ievn::f("iven", A_ThisHotkey, A_EndChar) ; Fixes 440 words
:XB0?*:igeou::f("igiou", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:igini::f("igni", A_ThisHotkey, A_EndChar) ; Fixes 127 words
:XB0?*:ignf::f("ignif", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:igous::f("igious", A_ThisHotkey, A_EndChar) ; Fixes 23 words, but misspells pemphigous (a skin disease)
:XB0?*:igth::f("ight", A_ThisHotkey, A_EndChar) ; Jack's fixes 315 words
:XB0?*:ihs::f("his", A_ThisHotkey, A_EndChar) ; Fixes 618 words
:XB0?*:iht::f("ith", A_ThisHotkey, A_EndChar) ; Fixes 560 words
:XB0?*:ijng::f("ing", A_ThisHotkey, A_EndChar) ; Fixes 15158 words
:XB0?*:ilair::f("iliar", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:illution::f("illusion", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:imagen::f("imagin", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:immita::f("imita", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:impliment::f("implement", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:imploy::f("employ", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:importen::f("importan", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:imprion::f("imprison", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:incede::f("incide", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:incidential::f("incidental", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:incra::f("incre", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:inctro::f("intro", A_ThisHotkey, A_EndChar) ; Fixes 68 words
:XB0?*:indeca::f("indica", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:indite::f("indict", A_ThisHotkey, A_EndChar) ; Fixes 22 words, but misspells indite (Produce a literaryÂ work)
:XB0?*:indutr::f("industr", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0?*:indvidua::f("individua", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:inece::f("ience", A_ThisHotkey, A_EndChar) ; Fixes 101 words
:XB0?*:ineing::f("ining", A_ThisHotkey, A_EndChar) ; Fixes 193 words
:XB0?*:inential::f("inental", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:infectuo::f("infectio", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:infrant::f("infant", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:infrige::f("infringe", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:ingenius::f("ingenious", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:inheritage::f("inheritance", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:inheritence::f("inheritance", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:inially::f("inally", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:ininis::f("inis", A_ThisHotkey, A_EndChar) ; Fixes 388 words
:XB0?*:inital::f("initial", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:inng::f("ing", A_ThisHotkey, A_EndChar) ; Fixes 15158 words
:XB0?*:innocula::f("inocula", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:inpeach::f("impeach", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:inpolit::f("impolit", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:inprison::f("imprison", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:inprov::f("improv", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:insitut::f("institut", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:institue::f("institute", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:instu::f("instru", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:intelect::f("intellect", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:intelig::f("intellig", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:intenational::f("international", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:intented::f("intended", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:intepret::f("interpret", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:interational::f("international", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:interferance::f("interference", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:intergrat::f("integrat", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:interpet::f("interpret", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:interupt::f("interrupt", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:inteven::f("interven", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:intrduc::f("introduc", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:intrest::f("interest", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:intruduc::f("introduc", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:intut::f("intuit", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:inudstr::f("industr", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0?*:investingat::f("investigat", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:iopn::f("ion", A_ThisHotkey, A_EndChar) ; Fixes 8515 words
:XB0?*:iouness::f("iousness", A_ThisHotkey, A_EndChar) ; Fixes 220 words
:XB0?*:iousit::f("iosit", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:irts::f("irst", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:isherr::f("isher", A_ThisHotkey, A_EndChar) ; Fixes 71 words
:XB0?*:ishor::f("isher", A_ThisHotkey, A_EndChar) ; Fixes 71 words
:XB0?*:ishre::f("isher", A_ThisHotkey, A_EndChar) ; Fixes 71 words
:XB0?*:isile::f("issile", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:issence::f("issance", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:iticing::f("iticising", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:itina::f("itiona", A_ThisHotkey, A_EndChar) ; Fixes 79 words, misspells Mephitinae (skunk), neritina (snail)
:XB0?*:ititia::f("initia", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:itition::f("ition", A_ThisHotkey, A_EndChar) ; Fixes 389 words
:XB0?*:itnere::f("intere", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:itnroduc::f("introduc", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:itoin::f("ition", A_ThisHotkey, A_EndChar) ; Fixes 389 words
:XB0?*:itttle::f("ittle", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:iveing::f("iving", A_ThisHotkey, A_EndChar) ; Fixes 75 words
:XB0?*:iverous::f("ivorous", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:ivle::f("ivel", A_ThisHotkey, A_EndChar) ; Fixes 589 words, but misspells braaivleis (Type of S. Affrican BBQ)
:XB0?*:iwll::f("will", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?*:iwth::f("with", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:jecutr::f("jectur", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:jist::f("gist", A_ThisHotkey, A_EndChar) ; Fixes 587 words
:XB0?*:jstu::f("just", A_ThisHotkey, A_EndChar) ; Fixes 83 words
:XB0?*:jsut::f("just", A_ThisHotkey, A_EndChar) ; Fixes 83 words
:XB0?*:juct::f("junct", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:judgment::f("judgement", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:judical::f("judicial", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:judisua::f("judicia", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:juduci::f("judici", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:jugment::f("judgment", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:juristiction::f("jurisdiction", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:kindergarden::f("kindergarten", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:knowldeg::f("knowledg", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:knowldg::f("knowledg", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:knowleg::f("knowledg", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:knwo::f("know", A_ThisHotkey, A_EndChar) ; Fixes 66 words
:XB0?*:konw::f("know", A_ThisHotkey, A_EndChar) ; Fixes 66 words
:XB0?*:kwno::f("know", A_ThisHotkey, A_EndChar) ; Fixes 66 words
:XB0?*:labat::f("laborat", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:laeg::f("leag", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:laguage::f("language", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:laimation::f("lamation", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:laion::f("lation", A_ThisHotkey, A_EndChar) ; Fixes 448 words
:XB0?*:lalbe::f("lable", A_ThisHotkey, A_EndChar) ; Fixes 122 words
:XB0?*:laraty::f("larity", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:lastes::f("lates", A_ThisHotkey, A_EndChar) ; Fixes 212 words
:XB0?*:lateab::f("latab", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:latrea::f("latera", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?*:lattitude::f("latitude", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:launhe::f("launche", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:lcud::f("clud", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:leagur::f("leaguer", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:leathal::f("lethal", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:lece::f("lesce", A_ThisHotkey, A_EndChar) ; Fixes 52 words, but misspells Illecebrum (contains the single species Illecebrum verticillatum, which is a trailing annual plant native to Europe)
:XB0?*:lecton::f("lection", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:legitamat::f("legitimat", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:legitm::f("legitim", A_ThisHotkey, A_EndChar) ; Fixes 67 words
:XB0?*:legue::f("league", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:leiv::f("liev", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:libgui::f("lingui", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:liek::f("like", A_ThisHotkey, A_EndChar) ; Fixes 405 words
:XB0?*:liement::f("lement", A_ThisHotkey, A_EndChar) ; Fixes 128 words
:XB0?*:lieuenan::f("lieutenan", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:lieutenen::f("lieutenan", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:likl::f("likel", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:liscen::f("licen", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:lisehr::f("lisher", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:lisen::f("licen", A_ThisHotkey, A_EndChar) ; Fixes 34 words, but misspells lisente (100 lisente equal 1 loti in Lesotho, S. Afterica)
:XB0?*:lisheed::f("lished", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:lishh::f("lish", A_ThisHotkey, A_EndChar) ; Fixes 211 words
:XB0?*:lissh::f("lish", A_ThisHotkey, A_EndChar) ; Fixes 211 words
:XB0?*:listn::f("listen", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:litav::f("lativ", A_ThisHotkey, A_EndChar) ; Fixes 97 words
:XB0?*:litert::f("literat", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:littel::f("little", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:litteral::f("literal", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:littoe::f("little", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:liuke::f("like", A_ThisHotkey, A_EndChar) ; Fixes 405 words
:XB0?*:llarious::f("larious", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:llegen::f("llegian", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:llegien::f("llegian", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:lmits::f("limits", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:loev::f("love", A_ThisHotkey, A_EndChar) ; Fixes 111 words
:XB0?*:lonle::f("lonel", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:lpp::f("lp", A_ThisHotkey, A_EndChar) ; Fixes 509 words
:XB0?*:lsih::f("lish", A_ThisHotkey, A_EndChar) ; Fixes 211 words
:XB0?*:lsot::f("lso", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:lutly::f("lutely", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:lyed::f("lied", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?*:machne::f("machine", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:maintina::f("maintain", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:maintion::f("mention", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:majorot::f("majorit", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:makeing::f("making", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:making it's::f("making its", A_ThisHotkey, A_EndChar)
:XB0?*:makse::f("makes", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:mallise::f("malize", A_ThisHotkey, A_EndChar) ; Fixes 17 words ; Ambiguous
:XB0?*:mallize::f("malize", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:mamal::f("mammal", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:mamant::f("mament", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:managab::f("manageab", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:managment::f("management", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:maneouv::f("manoeuv", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:manoeuver::f("maneuver", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:manouver::f("maneuver", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:mantain::f("maintain", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:manuever::f("maneuver", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:manuver::f("maneuver", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:marjorit::f("majorit", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:markes::f("marks", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:markett::f("market", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:marrage::f("marriage", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:mathamati::f("mathemati", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:mathmati::f("mathemati", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:mberan::f("mbran", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:mbintat::f("mbinat", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:mchan::f("mechan", A_ThisHotkey, A_EndChar) ; Fixes 54 words
:XB0?*:meber::f("member", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:medac::f("medic", A_ThisHotkey, A_EndChar) ; Fixes 76 words
:XB0?*:medeival::f("medieval", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:medevial::f("medieval", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:meent::f("ment", A_ThisHotkey, A_EndChar) ; Fixes 1763 words
:XB0?*:meing::f("ming", A_ThisHotkey, A_EndChar) ; Fixes 410 words
:XB0?*:melad::f("malad", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:memeber::f("member", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:memmor::f("memor", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?*:memt::f("ment", A_ThisHotkey, A_EndChar) ; Fixes 1763 words
:XB0?*:menatr::f("mentar", A_ThisHotkey, A_EndChar) ; Fixes 71 words
:XB0?*:metalic::f("metallic", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:mialr::f("milar", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:mibil::f("mobil", A_ThisHotkey, A_EndChar) ; Fixes 78 words
:XB0?*:mileau::f("milieu", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:milen::f("millen", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:mileu::f("milieu", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:milirat::f("militar", A_ThisHotkey, A_EndChar) ; Fixes 54 words
:XB0?*:millit::f("milit", A_ThisHotkey, A_EndChar) ; Fixes 85 words
:XB0?*:millon::f("million", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:milta::f("milita", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?*:minatur::f("miniatur", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:minining::f("mining", A_ThisHotkey, A_EndChar) ; Fixes 15 words.
:XB0?*:miscelane::f("miscellane", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:mision::f("mission", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0?*:missabi::f("missibi", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:misson::f("mission", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0?*:mition::f("mission", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0?*:mittm::f("mitm", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:mitty::f("mittee", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:mkae::f("make", A_ThisHotkey, A_EndChar) ; Fixes 122 words
:XB0?*:mkaing::f("making", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:mkea::f("make", A_ThisHotkey, A_EndChar) ; Fixes 122 words
:XB0?*:mmorow::f("morrow", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:mnet::f("ment", A_ThisHotkey, A_EndChar) ; Fixes 1763 words
:XB0?*:modle::f("model", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:moent::f("moment", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:moleclue::f("molecule", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:morgag::f("mortgag", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:mornal::f("normal", A_ThisHotkey, A_EndChar) ; Fixes 66 words 
:XB0?*:morot::f("motor", A_ThisHotkey, A_EndChar) ; Fixes 72 words  
:XB0?*:morow::f("morrow", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:mortag::f("mortgag", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:mostur::f("moistur", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:moung::f("mong", A_ThisHotkey, A_EndChar) ; Fixes 89 words
:XB0?*:mounth::f("month", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:mpossa::f("mpossi", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:mrak::f("mark", A_ThisHotkey, A_EndChar) ; Fixes 175 words
:XB0?*:mroe::f("more", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:msot::f("most", A_ThisHotkey, A_EndChar) ; Fixes 73 words
:XB0?*:mtion::f("mation", A_ThisHotkey, A_EndChar) ; Fixes 119 words
:XB0?*:mucuous::f("mucous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:muder::f("murder", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:mulatat::f("mulat", A_ThisHotkey, A_EndChar) ; Fixes 110 words
:XB0?*:munber::f("number", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:munites::f("munities", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:muscel::f("muscle", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:muscial::f("musical", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:mutiliat::f("mutilat", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:naisance::f("naissance", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:naton::f("nation", A_ThisHotkey, A_EndChar) ; Fixes 451 words but misspells Akhenaton (Early ruler of Egypt who regected old gods and replaced with sun worship, died 1358 BC).
:XB0?*:naturely::f("naturally", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:naturual::f("natural", A_ThisHotkey, A_EndChar) ; Fixes 54 words
:XB0?*:nclr::f("ncr", A_ThisHotkey, A_EndChar) ; Fixes 193 words
:XB0?*:ndunt::f("ndant", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:necass::f("necess", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:neccesar::f("necessar", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:neccessar::f("necessar", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:necesar::f("necessar", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:necesser::f("necessar", A_ThisHotkey, A_EndChar) ; Fixes 9 words 
:XB0?*:nefica::f("neficia", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:negociat::f("negotiat", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:negota::f("negotia", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:neice::f("niece", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:neigbor::f("neighbor", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:neigbour::f("neighbor", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:neize::f("nize", A_ThisHotkey, A_EndChar) ; Fixes 475 words
:XB0?*:neolitic::f("neolithic", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:nerial::f("neral", A_ThisHotkey, A_EndChar) ; Fixes 103 words
:XB0?*:neribl::f("nerabl", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:nessasar::f("necessar", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:nessec::f("necess", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:nght::f("ngth", A_ThisHotkey, A_EndChar) ; Jack's fixes 33 words
:XB0?*:ngiht::f("night", A_ThisHotkey, A_EndChar) ; Fixes 103 words
:XB0?*:ngng::f("nging", A_ThisHotkey, A_EndChar) ; Fixes 126 words
:XB0?*:nht::f("nth", A_ThisHotkey, A_EndChar) ; Jack's fixes 769 words
:XB0?*:niant::f("nant", A_ThisHotkey, A_EndChar) ; Fixes 147 words
:XB0?*:niare::f("naire", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:nickle::f("nickel", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:nifiga::f("nifica", A_ThisHotkey, A_EndChar) ; Fixes 55 words
:XB0?*:nihgt::f("night", A_ThisHotkey, A_EndChar) ; Fixes 103 words
:XB0?*:nilog::f("nolog", A_ThisHotkey, A_EndChar) ; Fixes 223 words
:XB0?*:nisator::f("niser", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:nisb::f("nsib", A_ThisHotkey, A_EndChar) ; Fixes 88 words
:XB0?*:nistion::f("nisation", A_ThisHotkey, A_EndChar) ; Fixes 140 words
:XB0?*:nitian::f("nician", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:niton::f("nition", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:nizator::f("nizer", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:niztion::f("nization", A_ThisHotkey, A_EndChar) ; Fixes 154 words
:XB0?*:nkow::f("know", A_ThisHotkey, A_EndChar) ; Fixes 66 words, but misspells Minkowski (German mathematician)
:XB0?*:nlcu::f("nclu", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:nlees::f("nless", A_ThisHotkey, A_EndChar) ; Fixes 89 words
:XB0?*:nmae::f("name", A_ThisHotkey, A_EndChar) ; Fixes 100 words
:XB0?*:nnst::f("nst", A_ThisHotkey, A_EndChar) ; Fixes 729 words, misspells Dennstaedtia (fern), Hoffmannsthal, (poet)
:XB0?*:nnung::f("nning", A_ThisHotkey, A_EndChar) ; Fixes 107 words
:XB0?*:nonom::f("nonym", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:nouce::f("nounce", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?*:nounch::f("nounc", A_ThisHotkey, A_EndChar) ; Fixes 54 words
:XB0?*:nouncia::f("nuncia", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?*:nsistan::f("nsisten", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:nsitu::f("nstitu", A_ThisHotkey, A_EndChar) ; Fixes 87 words
:XB0?*:nstade::f("nstead", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:nstatan::f("nstan", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:nsted::f("nstead", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:nstiv::f("nsitiv", A_ThisHotkey, A_EndChar) ; Fixes 62 words
:XB0?*:ntaines::f("ntains", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:ntamp::f("ntemp", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:ntfic::f("ntific", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:ntifc::f("ntific", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:ntrui::f("nturi", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:nucular::f("nuclear", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:nuculear::f("nuclear", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:nuei::f("nui", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:nuptual::f("nuptial", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:nvien::f("nven", A_ThisHotkey, A_EndChar) ; Fixes 101 words
:XB0?*:obedian::f("obedien", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:obelm::f("oblem", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:occassi::f("occasi", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:occasti::f("occasi", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:occour::f("occur", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:occuran::f("occurren", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:occurran::f("occurren", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:ocup::f("occup", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:ocurran::f("occurren", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:odouriferous::f("odoriferous", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:odourous::f("odorous", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:oducab::f("oducib", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:oeny::f("oney", A_ThisHotkey, A_EndChar) ; Fixes 83 words
:XB0?*:oeopl::f("eopl", A_ThisHotkey, A_EndChar) ; Fixes 53 words
:XB0?*:oeprat::f("operat", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:offereing::f("offering", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:offesi::f("ofessi", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:offical::f("official", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:offred::f("offered", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:ogeous::f("ogous", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:ogess::f("ogress", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:ohter::f("other", A_ThisHotkey, A_EndChar) ; Fixes 229 words
:XB0?*:ointiment::f("ointment", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:olece::f("olesce", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:olgist::f("ologist", A_ThisHotkey, A_EndChar) ; Fixes 445 words
:XB0?*:olision::f("olition", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:ollum::f("olum", A_ThisHotkey, A_EndChar) ; Fixes 69 words
:XB0?*:olpe::f("ople", A_ThisHotkey, A_EndChar) ; Fixes 62 words
:XB0?*:olther::f("other", A_ThisHotkey, A_EndChar) ; Fixes 229 words
:XB0?*:omenom::f("omenon", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:ommision::f("omission", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:ommm::f("omm", A_ThisHotkey, A_EndChar) ; Fixes 606 words
:XB0?*:omnio::f("omino", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:omptabl::f("ompatibl", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:omre::f("more", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:omse::f("onse", A_ThisHotkey, A_EndChar) ; Fixes 159 words
:XB0?*:ongraph::f("onograph", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:onnal::f("onal", A_ThisHotkey, A_EndChar) ; Fixes 1038 words
:XB0?*:onnsibilt::f("onsibilit", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:ononent::f("onent", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:ononym::f("onym", A_ThisHotkey, A_EndChar) ; Fixes 137 words
:XB0?*:onsenc::f("onsens", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:onsern::f("concern", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:ontruc::f("onstruc", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0?*:ontstr::f("onstr", A_ThisHotkey, A_EndChar) ; Fixes 165 words
:XB0?*:onyic::f("onic", A_ThisHotkey, A_EndChar) ; Fixes 353 words
:XB0?*:onymn::f("onym", A_ThisHotkey, A_EndChar) ; Fixes 137 words
:XB0?*:oook::f("ook", A_ThisHotkey, A_EndChar) ; Fixes 427 words
:XB0?*:oparate::f("operate", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:oportun::f("opportun", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:opperat::f("operat", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:oppertun::f("opportun", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:oppini::f("opini", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:opprotun::f("opportun", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:opth::f("ophth", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?*:ordianti::f("ordinati", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:orginis::f("organiz", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:orginiz::f("organiz", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:orht::f("orth", A_ThisHotkey, A_EndChar) ; Fixes 275 words
:XB0?*:oridal::f("ordial", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:oridina::f("ordina", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0?*:origion::f("origin", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:orign::f("origin", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:ormenc::f("ormanc", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:osible::f("osable", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:oteab::f("otab", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:otehr::f("other", A_ThisHotkey, A_EndChar) ; Fixes 229 words
:XB0?*:ouevre::f("oeuvre", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:ouhg::f("ough", A_ThisHotkey, A_EndChar) ; Fixes 230 words
:XB0?*:oulb::f("oubl", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0?*:ountian::f("ountain", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:ourious::f("orious", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:owinf::f("owing", A_ThisHotkey, A_EndChar) ; Fixes 133 words
:XB0?*:owrk::f("work", A_ThisHotkey, A_EndChar) ; Fixes 338 words
:XB0?*:oxident::f("oxidant", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:oxigen::f("oxygen", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:paiti::f("pati", A_ThisHotkey, A_EndChar) ; Fixes 157 words
:XB0?*:palce::f("place", A_ThisHotkey, A_EndChar) ; Fixes 94 words
:XB0?*:paliament::f("parliament", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:papaer::f("paper", A_ThisHotkey, A_EndChar) ; Fixes 69 words
:XB0?*:paralel::f("parallel", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:parellel::f("parallel", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:parision::f("parison", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:parisit::f("parasit", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0?*:paritucla::f("particula", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:parliment::f("parliament", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:parment::f("partment", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:parralel::f("parallel", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:parrall::f("parall", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:parren::f("paren", A_ThisHotkey, A_EndChar) ; Fixes 65 words
:XB0?*:pased::f("passed", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:patab::f("patib", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:pattent::f("patent", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:pbli::f("publi", A_ThisHotkey, A_EndChar) ; Fixes 67 words
:XB0?*:pbuli::f("publi", A_ThisHotkey, A_EndChar) ; Fixes 67 words
:XB0?*:pcial::f("pical", A_ThisHotkey, A_EndChar) ; Fixes 102 words
:XB0?*:pcitur::f("pictur", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:peall::f("peal", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:peapl::f("peopl", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:pefor::f("perfor", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:peice::f("piece", A_ThisHotkey, A_EndChar) ; Fixes 60 words
:XB0?*:peiti::f("petiti", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:pendece::f("pendence", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:pendendet::f("pendent", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:penerat::f("penetrat", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:penisula::f("peninsula", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:penninsula::f("peninsula", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:pennisula::f("peninsula", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:pensanti::f("pensati", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:pensinula::f("peninsula", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:penten::f("pentan", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:pention::f("pension", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:peopel::f("people", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:percepted::f("perceived", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:perfom::f("perform", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:performes::f("performs", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:permenan::f("permanen", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:perminen::f("permanen", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:permissab::f("permissib", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:peronal::f("personal", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:perosn::f("person", A_ThisHotkey, A_EndChar) ; Fixes 130 words
:XB0?*:persistan::f("persisten", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:persud::f("persuad", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:pertrat::f("petrat", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:pertuba::f("perturba", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:peteti::f("petiti", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:petion::f("petition", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:petive::f("petitive", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:phenomenonal::f("phenomenal", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:phenomon::f("phenomen", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:phenonmen::f("phenomen", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:philisoph::f("philosoph", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:phillipi::f("Philippi", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:phillo::f("philo", A_ThisHotkey, A_EndChar) ; Fixes 61 words
:XB0?*:philosph::f("philosoph", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:phoricial::f("phorical", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:phyllis::f("philis", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:phylosoph::f("philosoph", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:piant::f("pient", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:piblish::f("publish", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:pinon::f("pion", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:piten::f("peten", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:plament::f("plement", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:plausab::f("plausib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:pld::f("ple", A_ThisHotkey, A_EndChar) ; Fixes 843 words
:XB0?*:pleasent::f("pleasant", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:plesan::f("pleasan", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:pletetion::f("pletion", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:pmant::f("pment", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:poenis::f("penis", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:poepl::f("peopl", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:poleg::f("polog", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0?*:polina::f("pollina", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:politican::f("politician", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:polti::f("politi", A_ThisHotkey, A_EndChar) ; Fixes 61 words
:XB0?*:polut::f("pollut", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:pomd::f("pond", A_ThisHotkey, A_EndChar) ; Fixes 109 words
:XB0?*:ponan::f("ponen", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:ponsab::f("ponsib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:poportion::f("proportion", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:popoul::f("popul", A_ThisHotkey, A_EndChar) ; Fixes 71 words
:XB0?*:porblem::f("problem", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:portad::f("ported", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:porv::f("prov", A_ThisHotkey, A_EndChar) ; Fixes 213 words
:XB0?*:posat::f("posit", A_ThisHotkey, A_EndChar) ; Fixes 215 words
:XB0?*:posess::f("possess", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:posion::f("poison", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:possab::f("possib", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:postion::f("position", A_ThisHotkey, A_EndChar) ; Fixes 103 words
:XB0?*:postit::f("posit", A_ThisHotkey, A_EndChar) ; Fixes 215 words
:XB0?*:postiv::f("positiv", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:potunit::f("portunit", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:poulat::f("populat", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:poverful::f("powerful", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:poweful::f("powerful", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:ppment::f("pment", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:pposs::f("ppos", A_ThisHotkey, A_EndChar) ; Fixes 90 words
:XB0?*:ppub::f("pub", A_ThisHotkey, A_EndChar) ; Fixes 96 words
:XB0?*:practial::f("practical", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:prait::f("priat", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:pratic::f("practic", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:precendent::f("precedent", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:precic::f("precis", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:precid::f("preced", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:prega::f("pregna", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:pregne::f("pregna", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:preiod::f("period", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:prelifer::f("prolifer", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:prepair::f("prepare", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:prerio::f("perio", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:presan::f("presen", A_ThisHotkey, A_EndChar) ; Fixes 90 words
:XB0?*:presp::f("persp", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:pretect::f("protect", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:pricip::f("princip", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:priestood::f("priesthood", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:prisonn::f("prison", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:privale::f("privile", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:privele::f("privile", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:privelig::f("privileg", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:privelle::f("privile", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:privilag::f("privileg", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:priviledg::f("privileg", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:privledg::f("privileg", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:probabli::f("probabili", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:probal::f("probabl", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:procce::f("proce", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?*:proclame::f("proclaime", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:proffession::f("profession", A_ThisHotkey, A_EndChar) ; Fixes 33 words
:XB0?*:progrom::f("program", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:prohabit::f("prohibit", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:prominan::f("prominen", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:prominate::f("prominent", A_ThisHotkey, A_EndChar) ; Fixes 4 words::prominately::prominently
:XB0?*:proov::f("prov", A_ThisHotkey, A_EndChar) ; Fixes 213 words
:XB0?*:propiat::f("priat", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:propiet::f("propriet", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:propmt::f("prompt", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:propotion::f("proportion", A_ThisHotkey, A_EndChar) ; Fixes 25 words::propotions::proportions
:XB0?*:propper::f("proper", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:propro::f("pro", A_ThisHotkey, A_EndChar) ; Fixes 2311 words
:XB0?*:prorp::f("propr", A_ThisHotkey, A_EndChar) ; Fixes 68 words
:XB0?*:protie::f("protei", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:protray::f("portray", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:prounc::f("pronounc", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:provd::f("provid", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:provicial::f("provincial", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:provinicial::f("provincial", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:provison::f("provision", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:proxia::f("proxima", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:psect::f("spect", A_ThisHotkey, A_EndChar) ; Fixes 177 words
:XB0?*:psoiti::f("positi", A_ThisHotkey, A_EndChar) ; Fixes 155 words
:XB0?*:psuedo::f("pseudo", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?*:psyco::f("psycho", A_ThisHotkey, A_EndChar) ; Fixes 161 words
:XB0?*:psyh::f("psych", A_ThisHotkey, A_EndChar) ; Fixes 192 words, but misspells gypsyhood.
:XB0?*:ptenc::f("ptanc", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:ptete::f("pete", A_ThisHotkey, A_EndChar) ; Fixes 61 words
:XB0?*:ptition::f("petition", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:ptogress::f("progress", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:ptoin::f("ption", A_ThisHotkey, A_EndChar) ; Fixes 183 words
:XB0?*:pturd::f("ptured", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:pubish::f("publish", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:publian::f("publican", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:publise::f("publishe", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:publush::f("publish", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:pulare::f("pular", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:puler::f("pular", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:pulishe::f("publishe", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:puplish::f("publish", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:pursuad::f("persuad", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:purtun::f("portun", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:pususad::f("persuad", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:putar::f("puter", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:putib::f("putab", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:pwoer::f("power", A_ThisHotkey, A_EndChar) ; Fixes 67 words
:XB0?*:pysch::f("psych", A_ThisHotkey, A_EndChar) ; Fixes 192 words
:XB0?*:qtuie::f("quite", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:quesece::f("quence", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:quesion::f("question", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:questiom::f("question", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:queston::f("question", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:quetion::f("question", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:quirment::f("quirement", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:qush::f("quish", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:quti::f("quit", A_ThisHotkey, A_EndChar) ; Fixes 86 words
:XB0?*:rabinn::f("rabbin", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:radiactiv::f("radioactiv", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:raell::f("reall", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:rafic::f("rific", A_ThisHotkey, A_EndChar) ; Fixes 85 words
:XB0?*:ranie::f("rannie", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:ratly::f("rately", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:raverci::f("roversi", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:rcaft::f("rcraft", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:reaccurr::f("recurr", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:reaci::f("reachi", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:rebll::f("rebell", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:recide::f("reside", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:recqu::f("requ", A_ThisHotkey, A_EndChar) ; Fixes 96 words
:XB0?*:recration::f("recreation", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:recrod::f("record", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:recter::f("rector", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:recuring::f("recurring", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:reedem::f("redeem", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:reenfo::f("reinfo", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:referal::f("referral", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:reffer::f("refer", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:refrer::f("refer", A_ThisHotkey, A_EndChar) ; Fixes 58 words
:XB0?*:reigin::f("reign", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:reing::f("ring", A_ThisHotkey, A_EndChar) ; Fixes 1481 words
:XB0?*:reiv::f("riev", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:relese::f("release", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:releven::f("relevan", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:renial::f("rennial", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:renno::f("reno", A_ThisHotkey, A_EndChar) ; Fixes 85 words
:XB0?*:rentee::f("rantee", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:rentor::f("renter", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:reomm::f("recomm", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:repatiti::f("repetiti", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:repb::f("repub", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:repentent::f("repentant", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:repetant::f("repentant", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:repetent::f("repentant", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:replacab::f("replaceab", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:reposd::f("respond", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:resense::f("resence", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:residental::f("residential", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:resistab::f("resistib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:resiv::f("ressiv", A_ThisHotkey, A_EndChar) ; Fixes 80 words
:XB0?*:responc::f("respons", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:respondan::f("responden", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:restict::f("restrict", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:revelan::f("relevan", A_ThisHotkey, A_EndChar) ; Fixes 12 words 
:XB0?*:reversab::f("reversib", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:rhitm::f("rithm", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:rhythem::f("rhythm", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:rhytm::f("rhythm", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:ributred::f("ributed", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:ridgid::f("rigid", A_ThisHotkey, A_EndChar) ; Fixes 25 words 
:XB0?*:rieciat::f("reciat", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:rifing::f("rifying", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:rigeur::f("rigor", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:rigourous::f("rigorous", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:rilia::f("rillia", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:rimetal::f("rimental", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:rininging::f("ringing", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:riodal::f("roidal", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:ritent::f("rient", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?*:ritm::f("rithm", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:rixon::f("rison", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:rmaly::f("rmally", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:rmaton::f("rmation", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?*:rnign::f("rning", A_ThisHotkey, A_EndChar) ; Fixes 77 words
:XB0?*:rocord::f("record", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:ropiat::f("ropriat", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:rowm::f("rown", A_ThisHotkey, A_EndChar) ; Fixes 85 words
:XB0?*:roximite::f("roximate", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:rraige::f("rriage", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:rshan::f("rtion", A_ThisHotkey, A_EndChar) ; Fixes 84 words, but misspells darshan (Hinduism)
:XB0?*:rshon::f("rtion", A_ThisHotkey, A_EndChar) ; Fixes 84 words
:XB0?*:rshun::f("rtion", A_ThisHotkey, A_EndChar) ; Fixes 84 words
:XB0?*:rtaure::f("rature", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:rtnat::f("rtant", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:ruming::f("rumming", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:ruptab::f("ruptib", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:rwit::f("writ", A_ThisHotkey, A_EndChar) ; Fixes 88 words
:XB0?*:ryed::f("ried", A_ThisHotkey, A_EndChar) ; Fixes 98 words
:XB0?*:rythim::f("rhythm", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:rythym::f("rhythm", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:saccari::f("sacchari", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:safte::f("safet", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:saidit::f("said it", A_ThisHotkey, A_EndChar) ; Fixes 0 words
:XB0?*:saidthat::f("said that", A_ThisHotkey, A_EndChar) ; Fixes 0 words
:XB0?*:sampel::f("sample", A_ThisHotkey, A_EndChar) ; Fixes 20 words 
:XB0?*:santion::f("sanction", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:sassan::f("sassin", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:satelite::f("satellite", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:satric::f("satiric", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:sattelite::f("satellite", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:saveing::f("saving", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:scaleable::f("scalable", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:scedul::f("schedul", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:schedual::f("schedule", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:scholarstic::f("scholastic", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:scince::f("science", A_ThisHotkey, A_EndChar) ; Fixes 25 words, but misspells Scincella (A reptile genus of Scincidae)
:XB0?*:scipt::f("script", A_ThisHotkey, A_EndChar) ; Fixes 113 words
:XB0?*:scripton::f("scription", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:sctruct::f("struct", A_ThisHotkey, A_EndChar) ; Fixes 171 words
:XB0?*:sdide::f("side", A_ThisHotkey, A_EndChar) ; Fixes 317 words
:XB0?*:sdier::f("sider", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?*:seach::f("search", A_ThisHotkey, A_EndChar) ; Fixes 25 words, but misspells Taoiseach (The prime minister of the Irish Republic)
:XB0?*:secretery::f("secretary", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:sedere::f("sidere", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:seeked::f("sought", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:segement::f("segment", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:seige::f("siege", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:seing::f("seeing", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:senqu::f("sequ", A_ThisHotkey, A_EndChar) ; Fixes 91 words
:XB0?*:sensativ::f("sensitiv", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:sensur::f("censur", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:sentive::f("sentative", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:seper::f("separ", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:sepulchure::f("sepulcher", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:sepulcre::f("sepulcher", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:sequentually::f("sequently", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:serach::f("search", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:sercu::f("circu", A_ThisHotkey, A_EndChar) ; Fixes 168 words
:XB0?*:sesi::f("sessi", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?*:sevic::f("servic", A_ThisHotkey, A_EndChar) ; Fixes 25 words, but misspells seviche (South American dish of raw fish)
:XB0?*:sgin::f("sign", A_ThisHotkey, A_EndChar) ; Fixes 243 words.
:XB0?*:shaddow::f("shadow", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:shco::f("scho", A_ThisHotkey, A_EndChar) ; Fixes 117 words
:XB0?*:sheild::f("shield", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:siad::f("said", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:sibile::f("sible", A_ThisHotkey, A_EndChar) ; Fixes 137 words
:XB0?*:siblit::f("sibilit", A_ThisHotkey, A_EndChar) ; Fixes 110 words
:XB0?*:sicion::f("cision", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:sicne::f("since", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:sidenta::f("sidentia", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:signifa::f("significa", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:significe::f("significa", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:signit::f("signat", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:simala::f("simila", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:similia::f("simila", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:simmi::f("simi", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?*:simpt::f("sympt", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:sincerley::f("sincerely", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:sincerly::f("sincerely", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:sinse::f("since", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:sistend::f("sistent", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:sistion::f("sition", A_ThisHotkey, A_EndChar) ; Fixes 135 words
:XB0?*:sitll::f("still", A_ThisHotkey, A_EndChar) ; Fixes 62 words
:XB0?*:siton::f("sition", A_ThisHotkey, A_EndChar) ; Fixes 135 words
:XB0?*:skelaton::f("skeleton", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:slowy::f("slowly", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:smae::f("same", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:smealt::f("smelt", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:smoe::f("some", A_ThisHotkey, A_EndChar) ; Fixes 260 words
:XB0?*:snese::f("sense", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:socal::f("social", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?*:socre::f("score", A_ThisHotkey, A_EndChar) ; Fixes 34 words 
:XB0?*:soem::f("some", A_ThisHotkey, A_EndChar) ; Fixes 260 words
:XB0?*:sohw::f("show", A_ThisHotkey, A_EndChar) ; Fixes 79 words
:XB0?*:soica::f("socia", A_ThisHotkey, A_EndChar) ; Fixes 115 words
:XB0?*:sollut::f("solut", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:soluab::f("solub", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:sonent::f("sonant", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:sophicat::f("sophisticat", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:sorbsi::f("sorpti", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:sorbti::f("sorpti", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:sosica::f("socia", A_ThisHotkey, A_EndChar) ; Fixes 115 words
:XB0?*:sotry::f("story", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:soudn::f("sound", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:soverign::f("sovereign", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:specal::f("special", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:specfic::f("specific", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:specialliz::f("specializ", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:specifiy::f("specify", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:spectaular::f("spectacular", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:spectum::f("spectrum", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:speices::f("species", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:speling::f("spelling", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:spesial::f("special", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:spiria::f("spira", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?*:spoac::f("spac", A_ThisHotkey, A_EndChar) ; Fixes 83 words
:XB0?*:sponib::f("sponsib", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:sponser::f("sponsor", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:spred::f("spread", A_ThisHotkey, A_EndChar) ; Fixes 37 words
:XB0?*:spririt::f("spirit", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?*:spritual::f("spiritual", A_ThisHotkey, A_EndChar) ; Fixes 31 words, but misspells spritual (A light spar that crosses a fore-and-aft sail diagonally) 
:XB0?*:spyc::f("psyc", A_ThisHotkey, A_EndChar) ; Fixes 192 words, but misspells spycatcher (secret spy stuff) 
:XB0?*:sqaur::f("squar", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:ssanger::f("ssenger", A_ThisHotkey, A_EndChar)  ; Fixes 6 words
:XB0?*:ssese::f("ssesse", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:ssition::f("sition", A_ThisHotkey, A_EndChar) ; Fixes 135 words
:XB0?*:sssurect::f("surrect", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:ssurect::f("surrect", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:stablise::f("stabilise", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:staleld::f("stalled", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:stancial::f("stantial", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:stange::f("strange", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:starna::f("sterna", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:starteg::f("strateg", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:stateman::f("statesman", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:statment::f("statement", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:steriod::f("steroid", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:sterotype::f("stereotype", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:stingent::f("stringent", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:stiring::f("stirring", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:stirrs::f("stirs", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?*:stituan::f("stituen", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:stnad::f("stand", A_ThisHotkey, A_EndChar) ; Fixes 119 words
:XB0?*:stoin::f("stion", A_ThisHotkey, A_EndChar) ; Fixes 53 words, but misspells histoincompatibility.
:XB0?*:stong::f("strong", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:stradeg::f("strateg", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:stratagic::f("strategic", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:streem::f("stream", A_ThisHotkey, A_EndChar) ; Fixes 45 words
:XB0?*:strengh::f("strength", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:structual::f("structural", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:sttr::f("str", A_ThisHotkey, A_EndChar) ; Fixes 2295 words
:XB0?*:stuct::f("struct", A_ThisHotkey, A_EndChar) ; Fixes 171 words
:XB0?*:studdy::f("study", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:studing::f("studying", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:sturctur::f("structur", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:stutionaliz::f("stitutionaliz", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:substancia::f("substantia", A_ThisHotkey, A_EndChar) ; Fixes 55 words
:XB0?*:succesful::f("successful", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:succsess::f("success", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:sueing::f("suing", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:suffc::f("suffic", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:sufferr::f("suffer", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:suffician::f("sufficien", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:superintendan::f("superintenden", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:suph::f("soph", A_ThisHotkey, A_EndChar) ; Fixes 153 words
:XB0?*:supos::f("suppos", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:suppoed::f("supposed", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:supposs::f("suppos", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?*:suppy::f("supply", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:suprass::f("surpass", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:supress::f("suppress", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:supris::f("surpris", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:supriz::f("surpris", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:surect::f("surrect", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:surence::f("surance", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:surfce::f("surface", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:surle::f("surel", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:suro::f("surro", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:surpress::f("suppress", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:surpriz::f("surpris", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:susept::f("suscept", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:svae::f("save", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:swepth::f("swept", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:symetr::f("symmetr", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:symettr::f("symmetr", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:symmetral::f("symmetric", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:syncro::f("synchro", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:sypmtom::f("symptom", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:sysmatic::f("systematic", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:sytem::f("system", A_ThisHotkey, A_EndChar) ; Fixes 62 words
:XB0?*:sytl::f("styl", A_ThisHotkey, A_EndChar) ; Fixes 100 words
:XB0?*:tagan::f("tagon", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?*:tahn::f("than", A_ThisHotkey, A_EndChar) ; Fixes 135 words
:XB0?*:taht::f("that", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:tailled::f("tailed", A_ThisHotkey, A_EndChar) ; Fixes 16 words.
:XB0?*:taimina::f("tamina", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:tainence::f("tenance", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:taion::f("tation", A_ThisHotkey, A_EndChar) ; Fixes 490 words
:XB0?*:tait::f("trait", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?*:tamt::f("tant", A_ThisHotkey, A_EndChar) ; Fixes 330 words
:XB0?*:tanous::f("taneous", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?*:taral::f("tural", A_ThisHotkey, A_EndChar) ; Fixes 140 words
:XB0?*:tarey::f("tary", A_ThisHotkey, A_EndChar) ; Fixes 86 words
:XB0?*:tatch::f("tach", A_ThisHotkey, A_EndChar) ; Fixes 105 words
:XB0?*:tatn::f("tant", A_ThisHotkey, A_EndChar) ; Fixes 530 words
:XB0?*:taxan::f("taxon", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:techic::f("technic", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?*:techini::f("techni", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?*:techt::f("tect", A_ThisHotkey, A_EndChar) ; Fixes 102 words
:XB0?*:tecn::f("techn", A_ThisHotkey, A_EndChar) ; Fixes 87 words
:XB0?*:telpho::f("telepho", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:tempalt::f("templat", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:tempara::f("tempera", A_ThisHotkey, A_EndChar) ; Fixes 22 words
:XB0?*:temperar::f("temporar", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:tempoa::f("tempora", A_ThisHotkey, A_EndChar) ; Fixes 35 words
:XB0?*:temporaneus::f("temporaneous", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:tendac::f("tendenc", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:tendor::f("tender", A_ThisHotkey, A_EndChar) ; Fixes 54 words
:XB0?*:tepmor::f("tempor", A_ThisHotkey, A_EndChar) ; Fixes 73 words
:XB0?*:teriod::f("teroid", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:terranian::f("terranean", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:terrestial::f("terrestrial", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:terrior::f("territor", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:territorist::f("terrorist", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:terroist::f("terrorist", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:tghe::f("the", A_ThisHotkey, A_EndChar) ; Fixes 2176 words
:XB0?*:tghi::f("thi", A_ThisHotkey, A_EndChar) ; Fixes 827 words
:XB0?*:thakn::f("thank", A_ThisHotkey, A_EndChar) ; Fixes 19 words 
:XB0?*:thaph::f("taph", A_ThisHotkey, A_EndChar) ; Fixes 60 words
:XB0?*:theather::f("theater", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:theese::f("these", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:thgat::f("that", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:thiun::f("thin", A_ThisHotkey, A_EndChar) ; Fixes 212 words
:XB0?*:thnig::f("thing", A_ThisHotkey, A_EndChar) ; Fixes 103 words
:XB0?*:threatn::f("threaten", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:thsoe::f("those", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:thyat::f("that", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:tiait::f("tiat", A_ThisHotkey, A_EndChar) ; Fixes 139 words
:XB0?*:tiblit::f("tibilit", A_ThisHotkey, A_EndChar) ; Fixes 75 words
:XB0?*:tibut::f("tribut", A_ThisHotkey, A_EndChar) ; Fixes 92 words
:XB0?*:ticeing::f("ticing", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:ticial::f("tical", A_ThisHotkey, A_EndChar) ; Fixes 863 words
:XB0?*:ticio::f("titio", A_ThisHotkey, A_EndChar) ; Fixes 68 words
:XB0?*:ticlular::f("ticular", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?*:tiction::f("tinction", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:tiget::f("tiger", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:tihkn::f("think", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?*:tihs::f("this", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0?*:tiion::f("tion", A_ThisHotkey, A_EndChar) ; Fixes 7052 words
:XB0?*:tingish::f("tinguish", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:tioge::f("toge", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?*:tionnab::f("tionab", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:tionnal::f("tional", A_ThisHotkey, A_EndChar) ; Fixes 713 words
:XB0?*:tionne::f("tione", A_ThisHotkey, A_EndChar) ; Fixes 108 words
:XB0?*:tionni::f("tioni", A_ThisHotkey, A_EndChar) ; Fixes 265 words
:XB0?*:tiosn::f("tion", A_ThisHotkey, A_EndChar) ; Fixes 7055 words
:XB0?*:tisment::f("tisement", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:titid::f("titud", A_ThisHotkey, A_EndChar) ; Fixes 88 words
:XB0?*:titity::f("tity", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?*:titui::f("tituti", A_ThisHotkey, A_EndChar) ; Fixes 83 words
:XB0?*:tiviat::f("tivat", A_ThisHotkey, A_EndChar) ; Fixes 100 words
:XB0?*:tje::f("the", A_ThisHotkey, A_EndChar) ; Fixes 2176 words, but misspells Ondaatje (Canadian writer (born in Sri Lanka in 1943)) 
:XB0?*:tjhe::f("the", A_ThisHotkey, A_EndChar) ; Fixes 2176 words
:XB0?*:tkae::f("take", A_ThisHotkey, A_EndChar) ; Fixes 83 words
:XB0?*:tkaing::f("taking", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:tlak::f("talk", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?*:tlied::f("tled", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:tlme::f("tleme", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:tlye::f("tyle", A_ThisHotkey, A_EndChar) ; Fixes 81 words
:XB0?*:tned::f("nted", A_ThisHotkey, A_EndChar) ; Fixes 288 words
:XB0?*:tofy::f("tify", A_ThisHotkey, A_EndChar) ; Fixes 73 words
:XB0?*:togani::f("tagoni", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:toghether::f("together", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:toleren::f("toleran", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?*:tority::f("torily", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:touble::f("trouble", A_ThisHotkey, A_EndChar) ; Fixes 25 words
:XB0?*:tounge::f("tongue", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:tourch::f("torch", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:toword::f("toward", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:towrad::f("toward", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:tradion::f("tradition", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:tradtion::f("tradition", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:tranf::f("transf", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?*:transmissab::f("transmissib", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:tribusion::f("tribution", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:triger::f("trigger", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?*:tritian::f("trician", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:tritut::f("tribut", A_ThisHotkey, A_EndChar) ; Fixes 92 words
:XB0?*:troling::f("trolling", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?*:troverci::f("troversi", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:trubution::f("tribution", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:tstion::f("tation", A_ThisHotkey, A_EndChar) ; Fixes 490 words
:XB0?*:ttele::f("ttle", A_ThisHotkey, A_EndChar) ; Fixes 237 words
:XB0?*:tuara::f("taura", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:tudonal::f("tudinal", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:tuer::f("teur", A_ThisHotkey, A_EndChar) ; Fixes 53 words
:XB0?*:twpo::f("two", A_ThisHotkey, A_EndChar) ; Fixes 92 words
:XB0?*:tyfull::f("tiful", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:tyha::f("tha", A_ThisHotkey, A_EndChar) ; Fixes 512 words
:XB0?*:udner::f("under", A_ThisHotkey, A_EndChar) ; Fixes 803 words
:XB0?*:udnet::f("udent", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?*:ugth::f("ught", A_ThisHotkey, A_EndChar) ; Jack's fixes 146 words
:XB0?*:uitious::f("uitous", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:ulaton::f("ulation", A_ThisHotkey, A_EndChar) ; Fixes 192 words
:XB0?*:umetal::f("umental", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:understoon::f("understood", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:untion::f("unction", A_ThisHotkey, A_EndChar) ; Fixes 79 words
:XB0?*:unviers::f("univers", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:uoul::f("oul", A_ThisHotkey, A_EndChar) ; Fixes 207 words
:XB0?*:uraunt::f("urant", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:uredd::f("ured", A_ThisHotkey, A_EndChar) ; Fixes 196 words
:XB0?*:urgan::f("urgen", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?*:urveyer::f("urveyor", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?*:useage::f("usage", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:useing::f("using", A_ThisHotkey, A_EndChar) ; Fixes 78 words
:XB0?*:usuab::f("usab", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:ususal::f("usual", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:utrab::f("urab", A_ThisHotkey, A_EndChar) ; Fixes 138 words
:XB0?*:vacative::f("vocative", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?*:valant::f("valent", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:valubl::f("valuabl", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:valueabl::f("valuabl", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?*:varation::f("variation", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:varien::f("varian", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?*:varing::f("varying", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:varous::f("various", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:vegat::f("veget", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:vegit::f("veget", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:vegt::f("veget", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:veinen::f("venien", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?*:veiw::f("view", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:velant::f("valent", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:velent::f("valent", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:venem::f("venom", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:vereal::f("veral", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:verison::f("version", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:vertibrat::f("vertebrat", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:vertion::f("version", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:vetat::f("vitat", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:veyr::f("very", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:vigeur::f("vigor", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:vigilen::f("vigilan", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:visiosn::f("vision", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:vison::f("vision", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:visting::f("visiting", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?*:vivous::f("vious", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:vlalent::f("valent", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:vment::f("vement", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:voiu::f("viou", A_ThisHotkey, A_EndChar) ; Fixes 45 words 
:XB0?*:volont::f("volunt", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:volount::f("volunt", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?*:volumn::f("volum", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?*:volvment::f("volvement", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:vrey::f("very", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:vyer::f("very", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:vyre::f("very", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?*:waer::f("wear", A_ThisHotkey, A_EndChar) ; Fixes 99 words
:XB0?*:waht::f("what", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:warrent::f("warrant", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:wehn::f("when", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?*:weildl::f("wield", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:werre::f("were", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:whant::f("want", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:wherre::f("where", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?*:whta::f("what", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?*:wief::f("wife", A_ThisHotkey, A_EndChar) ; Fixes 28 words
:XB0?*:wieldl::f("wield", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?*:wierd::f("weird", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?*:wiew::f("view", A_ThisHotkey, A_EndChar) ; Fixes 52 words
:XB0?*:willk::f("will", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?*:windoes::f("windows", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?*:wirt::f("writ", A_ThisHotkey, A_EndChar) ; Fixes 88 words
:XB0?*:witten::f("written", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:wiull::f("will", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?*:wnat::f("want", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?*:woh::f("who", A_ThisHotkey, A_EndChar) ; Fixes 92 words
:XB0?*:wokr::f("work", A_ThisHotkey, A_EndChar) ; Fixes 338 words
:XB0?*:worls::f("world", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:wriet::f("write", A_ThisHotkey, A_EndChar) ; Fixes 48 words
:XB0?*:wrighter::f("writer", A_ThisHotkey, A_EndChar) ; Fixes 31 words
:XB0?*:writen::f("written", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?*:writting::f("writing", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?*:wrod::f("word", A_ThisHotkey, A_EndChar) ; Fixes 92 words
:XB0?*:wrok::f("work", A_ThisHotkey, A_EndChar) ; Fixes 338 words
:XB0?*:wtih::f("with", A_ThisHotkey, A_EndChar) ; Fixes 56 words
:XB0?*:wupp::f("supp", A_ThisHotkey, A_EndChar) ; Fixes 168 words
:XB0?*:yaer::f("year", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:yearm::f("year", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?*:yoiu::f("you", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:ythim::f("ythm", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?*:ytou::f("you", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:yuo::f("you", A_ThisHotkey, A_EndChar) ; Fixes 51 words
:XB0?*:zyne::f("zine", A_ThisHotkey, A_EndChar) ; Fixes 89 words
:XB0?*C:Amercia::f("America", A_ThisHotkey, A_EndChar) ; Fixes 28 words, Case sensitive to not misspell amerciable (Of a crime or misdemeanor) 
:XB0?*C:bouy::f("buoy", A_ThisHotkey, A_EndChar) ; Fixes 13 words.  Case-sensitive to not misspell Bouyie (a branch of Tai language).
:XB0?*C:comt::f("cont", A_ThisHotkey, A_EndChar) ; Fixes 587 words.  Misspells vicomte (French nobleman), Case sensitive so not misspell Comte (founder of Positivism and type of cheese)
:XB0?*C:doimg::f("doing", A_ThisHotkey, A_EndChar) ; Fixes 21 words but might be a variable name(??)
:XB0?*C:elicid::f("elicit", A_ThisHotkey, A_EndChar) ; Fixes 26 words, :C: so not to misspell Lelicidae (snail).
:XB0?*C:elpa::f("epla", A_ThisHotkey, A_EndChar) ; Fixes 92 words.  Case sensitive to not misspell CELPA.
:XB0?*C:manan::f("manen", A_ThisHotkey, A_EndChar) ; Fixes 27 words.  Case sensitive, so not to misspell Manannan (Celtic god of the sea; son of Ler)
:XB0?*C:mnt::f("ment", A_ThisHotkey, A_EndChar) ; Fixes 1763 words.  Case-sensitive, to not misspell TMNT (Teenage Mutant Ninja Turtles)
:XB0?*C:moust::f("mous", A_ThisHotkey, A_EndChar) ; Fixes 445 words, Case-sensitive to not Mousterian (archaeological culture, Neanderthal, before 70,000â€“32,000 BC)
:XB0?*C:oppen::f("open", A_ThisHotkey, A_EndChar) ; Fixes 91 words.  Case-sensitive so not to misspell "Oppenheimer."
:XB0?*C:origen::f("origin", A_ThisHotkey, A_EndChar) ; Fixes 37 words, Case sensitive to not misspell Origen (Greek philosopher and theologian).
:XB0?*C:pulic::f("public", A_ThisHotkey, A_EndChar) ; Fixes 50 words, Case-sensitive to not misspell Pulicaria (Genus of temperate Old World herbs: fleabane)
:XB0?*C:sigin::f("sign", A_ThisHotkey, A_EndChar) ; Fixes 243 words. Case-sensitive to not misspell SIGINT "Info from electronics telemetry intel."
:XB0?*C:tehr::f("ther", A_ThisHotkey, A_EndChar) ; Fixes 921 words. Case sesnsitive to not misspell Tehran (capital and largest city of Iran).
:XB0?*C:tempra::f("tempora", A_ThisHotkey, A_EndChar) ; Fixes 35 words. Case sensitive to not misspell Tempra (type of medicine).
:XB0?:'nt::f("n't", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?:, btu::f(", but", A_ThisHotkey, A_EndChar) ; Not just replacing "btu", as that is a unit of heat.
:XB0?:; btu::f("; but", A_ThisHotkey, A_EndChar)
:XB0?:;ll::f("'ll", A_ThisHotkey, A_EndChar)
:XB0?:;re::f("'re", A_ThisHotkey, A_EndChar)
:XB0?:;s::f("'s", A_ThisHotkey, A_EndChar)
:XB0?:;ve::f("'ve", A_ThisHotkey, A_EndChar)
:XB0?:Spet::f("Sept", A_ThisHotkey, A_EndChar) ; Fixes 2 words 
:XB0?:abely::f("ably", A_ThisHotkey, A_EndChar) ; Fixes 568 words
:XB0?:abley::f("ably", A_ThisHotkey, A_EndChar) ; Fixes 568 words
:XB0?:acn::f("can", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?:addres::f("address", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:adresing::f("addressing", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:aelly::f("eally", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?:aindre::f("ained", A_ThisHotkey, A_EndChar) ; Fixes 81 words
:XB0?:ainity::f("ainty", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:alekd::f("alked", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?:alowing::f("allowing", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:alyl::f("ally", A_ThisHotkey, A_EndChar) ; Fixes 2436 words
:XB0?:amde::f("made", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:ancestory::f("ancestry", A_ThisHotkey, A_EndChar)
:XB0?:ancles::f("acles", A_ThisHotkey, A_EndChar) ; Fixes 21 words
:XB0?:andd::f("and", A_ThisHotkey, A_EndChar) ; Fixes 251 words
:XB0?:anim::f("anism", A_ThisHotkey, A_EndChar) ; Fixes 123 words, but misspells minyanim (The quorum required by Jewish law to be present for public worship)
:XB0?:aotrs::f("ators", A_ThisHotkey, A_EndChar) ; Fixes 414 words
:XB0?:appearred::f("appeared", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:artice::f("article", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:aticly::f("atically", A_ThisHotkey, A_EndChar) ; Fixes 113 words
:XB0?:ativs::f("atives", A_ThisHotkey, A_EndChar) ; Fixes 63 words
:XB0?:atley::f("ately", A_ThisHotkey, A_EndChar) ; Fixes 162 words, but misspells Wheatley (a fictional artificial intelligence from the Portal franchise)
:XB0?:atn::f("ant", A_ThisHotkey, A_EndChar) ; Fixes 506 words
:XB0?:atnt::f("ant", A_ThisHotkey, A_EndChar) ; Fixes 506 words
:XB0?:attemp::f("attempt", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:aunchs::f("aunches", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?:autor::f("author", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:ayd::f("ady", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?:aywa::f("away", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?:bilites::f("bilities", A_ThisHotkey, A_EndChar) ; Fixes 487 words
:XB0?:bilties::f("bilities", A_ThisHotkey, A_EndChar) ; Fixes 487 words
:XB0?:bilty::f("bility", A_ThisHotkey, A_EndChar) ; Fixes 915 words
:XB0?:blility::f("bility", A_ThisHotkey, A_EndChar) ; Fixes 915 words
:XB0?:blities::f("bilities", A_ThisHotkey, A_EndChar) ; Fixes 487 words
:XB0?:blity::f("bility", A_ThisHotkey, A_EndChar) ; Fixes 915 words
:XB0?:blly::f("bly", A_ThisHotkey, A_EndChar) ; Fixes 735 words
:XB0?:boared::f("board", A_ThisHotkey, A_EndChar)
:XB0?:borke::f("broke", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:bthe::f("b the", A_ThisHotkey, A_EndChar)
:XB0?:busines::f("business", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:busineses::f("businesses", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:bve::f("be", A_ThisHotkey, A_EndChar) ; Fixes 127 words
:XB0?:caht::f("chat", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:certainity::f("certainty", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:certaintly::f("certainly", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:cialy::f("cially", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?:cisly::f("cisely", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:claimes::f("claims", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?:claming::f("claiming", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?:clas::f("class", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:clud::f("clude", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:comit::f("commit", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:comming::f("coming", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?:commiting::f("committing", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:committe::f("committee", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:compability::f("compatibility", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:competely::f("completely", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:controll::f("control", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:controlls::f("controls", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:criticists::f("critics", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:cthe::f("c the", A_ThisHotkey, A_EndChar)
:XB0?:cticly::f("ctically", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?:ctino::f("ction", A_ThisHotkey, A_EndChar) ; Fixes 226 words
:XB0?:ctoty::f("ctory", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?:cually::f("cularly", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?:cuarly::f("cularly", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?:cularily::f("cularly", A_ThisHotkey, A_EndChar) ; Fixes 38 words
:XB0?:culem::f("culum", A_ThisHotkey, A_EndChar) ; Fixes 19 words
:XB0?:currenly::f("currently", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:decidely::f("decidedly", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:develope::f("develop", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:developes::f("develops", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:dfull::f("dful", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?:difere::f("differe", A_ThisHotkey, A_EndChar) ; Fixes 41 words
:XB0?:disctinct::f("distinct", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?:dng::f("ding", A_ThisHotkey, A_EndChar) ; Fixes 618 words
:XB0?:doens::f("does", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?:doese::f("does", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?:dreasm::f("dreams", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:dtae::f("date", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0?:dthe::f("d the", A_ThisHotkey, A_EndChar)
:XB0?:eamil::f("email", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:eath::f("each", A_ThisHotkey, A_EndChar) 
:XB0?:ecclectic::f("eclectic", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:eclisp::f("eclips", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:edely::f("edly", A_ThisHotkey, A_EndChar) ; Fixes 674 words
:XB0?:efel::f("feel", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:efort::f("effort", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:efull::f("eful", A_ThisHotkey, A_EndChar) ; Fixes 74 words
:XB0?:efulls::f("efuls", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?:ehre::f("here", A_ThisHotkey, A_EndChar) ; Fixes 49 words
:XB0?:elyl::f("ely", A_ThisHotkey, A_EndChar) ; Fixes 1076 words
:XB0?:encs::f("ences", A_ThisHotkey, A_EndChar) ; Fixes 301 words
:XB0?:equiped::f("equipped", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:eraly::f("erally", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?:essess::f("esses", A_ThisHotkey, A_EndChar) ; Fixes 200 words
:XB0?:establising::f("establishing", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:examinated::f("examined", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:ferrs::f("fers", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?:ficaly::f("fically", A_ThisHotkey, A_EndChar) ; Fixes 20 words
:XB0?:fiel::f("file", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?:finit::f("finite", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:finitly::f("finitely", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:forceing::f("forcing", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:frmo::f("from", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:froms::f("forms", A_ThisHotkey, A_EndChar) ; Fixes 29 words
:XB0?:frp,::f("from", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:fthe::f("f the", A_ThisHotkey, A_EndChar)
:XB0?:fuly::f("fully", A_ThisHotkey, A_EndChar) ; Fixes 191 words
:XB0?:gardes::f("gards", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:getted::f("geted", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:gettin::f("getting", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:gfulls::f("gfuls", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:ginaly::f("ginally", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:giory::f("gory", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:glases::f("glasses", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?:gracefull::f("graceful", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:gratefull::f("grateful", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:gred::f("greed", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:gthe::f("g the", A_ThisHotkey, A_EndChar)
:XB0?:hace::f("hare", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?:herad::f("heard", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:herefor::f("herefore", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:hfull::f("hful", A_ThisHotkey, A_EndChar) ; Fixes 30 words
:XB0?:hge::f("he", A_ThisHotkey, A_EndChar) ; Fixes 147 words
:XB0?:higns::f("hings", A_ThisHotkey, A_EndChar) ; Fixes 79 words
:XB0?:higsn::f("hings", A_ThisHotkey, A_EndChar) ; Fixes 79 words
:XB0?:hsa::f("has", A_ThisHotkey, A_EndChar) ; Fixes 62 words
:XB0?:hsi::f("his", A_ThisHotkey, A_EndChar) ; Fixes 59 words
:XB0?:hte::f("the", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:hthe::f("h the", A_ThisHotkey, A_EndChar)
:XB0?:iaing::f("iating", A_ThisHotkey, A_EndChar) ; Fixes 84 words
:XB0?:ialy::f("ially", A_ThisHotkey, A_EndChar) ; Fixes 244 words, but misspells bialy (Flat crusty-bottomed onion roll) 
:XB0?:iatly::f("iately", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?:iblilty::f("ibility", A_ThisHotkey, A_EndChar) ; Fixes 168 words
:XB0?:icaly::f("ically", A_ThisHotkey, A_EndChar) ; Fixes 1432 words
:XB0?:icm::f("ism", A_ThisHotkey, A_EndChar) ; Fixes 1075 words
:XB0?:icms::f("isms", A_ThisHotkey, A_EndChar) ; Fixes 717 words
:XB0?:idty::f("dity", A_ThisHotkey, A_EndChar) ; Fixes 67 words
:XB0?:ienty::f("iently", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?:ign::f("ing", A_ThisHotkey, A_EndChar) ; Fixes 11384 words, but misspells a bunch (which are nullified above)
:XB0?:ikn::f("ink", A_ThisHotkey, A_EndChar) ; Fixes 66 words
:XB0?:ilarily::f("ilarly", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:ilny::f("inly", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?:inm::f("in", A_ThisHotkey, A_EndChar) 
:XB0?:iosn::f("ions", A_ThisHotkey, A_EndChar) ; Fixes 3055 words
:XB0?:isio::f("ision", A_ThisHotkey, A_EndChar) ; Fixes 27 words
:XB0?:itino::f("ition", A_ThisHotkey, A_EndChar) ; Fixes 113 words
:XB0?:itiy::f("ity", A_ThisHotkey, A_EndChar) ; Fixes 1890 words
:XB0?:itoy::f("itory", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?:itr::f("it", A_ThisHotkey, A_EndChar) ; Fixes 366 words, but misspells Savitr (Important Hindu god) 
:XB0?:ityes::f("ities", A_ThisHotkey, A_EndChar) ; Fixes 1347 words
:XB0?:ivites::f("ivities", A_ThisHotkey, A_EndChar) ; Fixes 73 words
:XB0?:kc::f("ck", A_ThisHotkey, A_EndChar) ; Fixes 610 words.  Misspells kc (thousand per second).
:XB0?:kfulls::f("kfuls", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:kn::f("nk", A_ThisHotkey, A_EndChar) ; Fixes 168 words
:XB0?:kthe::f("k the", A_ThisHotkey, A_EndChar)
:XB0?:l;y::f("ly", A_ThisHotkey, A_EndChar) ; Fixes 10464 words
:XB0?:laly::f("ally", A_ThisHotkey, A_EndChar) ; Fixes 2436 words
:XB0?:letness::f("leteness", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:lfull::f("lful", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:lieing::f("lying", A_ThisHotkey, A_EndChar) ; Fixes 46 words
:XB0?:lighly::f("lightly", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:ligy::f("lify", A_ThisHotkey, A_EndChar) ; ixes 15 words
:XB0?:likey::f("likely", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:lility::f("ility", A_ThisHotkey, A_EndChar) ; Fixes 956 words
:XB0?:llete::f("lette", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?:lsit::f("list", A_ThisHotkey, A_EndChar) ; Fixes 244 words
:XB0?:lthe::f("l the", A_ThisHotkey, A_EndChar)
:XB0?:lwats::f("lways", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:lyu::f("ly", A_ThisHotkey, A_EndChar) ; Fixes 9123 words
:XB0?:maked::f("marked", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?:maticas::f("matics", A_ThisHotkey, A_EndChar) ; Fixes 26 words
:XB0?:metn::f("ment", A_ThisHotkey, A_EndChar) ; Fixes 587 words
:XB0?:metns::f("ments", A_ThisHotkey, A_EndChar) ; Fixes 577 words
:XB0?:miantly::f("minately", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:mibly::f("mably", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?:miliary::f("military", A_ThisHotkey, A_EndChar) ; Fixes 4 words, but misspells miliary ()
:XB0?:morphysis::f("morphosis", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:motted::f("moted", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:mpley::f("mply", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:mpyl::f("mply", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:mthe::f("m the", A_ThisHotkey, A_EndChar)
:XB0?:n;t::f("n't", A_ThisHotkey, A_EndChar)
:XB0?:narys::f("naries", A_ThisHotkey, A_EndChar) ; Fixes 47 words
:XB0?:natley::f("nately", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?:natly::f("nately", A_ThisHotkey, A_EndChar) ; Fixes 42 words
:XB0?:ndacies::f("ndances", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:nfull::f("nful", A_ThisHotkey, A_EndChar) ; Fixes 36 words
:XB0?:nfulls::f("nfuls", A_ThisHotkey, A_EndChar) ; Fixes 17 words
:XB0?:ngment::f("ngement", A_ThisHotkey, A_EndChar) ; Fixes 18 words
:XB0?:nicly::f("nically", A_ThisHotkey, A_EndChar) ; Fixes 136 words
:XB0?:nig::f("ing", A_ThisHotkey, A_EndChar) ; Fixes 11414 words.  Misspells pfennig (100 pfennigs formerly equaled 1 DeutscheÂ Mark in Germany).
:XB0?:nision::f("nisation", A_ThisHotkey, A_EndChar) ; Fixes 93 words
:XB0?:nnally::f("nally", A_ThisHotkey, A_EndChar) ; Fixes 249 words
:XB0?:nnology::f("nology", A_ThisHotkey, A_EndChar) ; Fixes 43 words
:XB0?:ns't::f("sn't", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:nsly::f("nsely", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:nsof::f("ns of", A_ThisHotkey, A_EndChar)
:XB0?:nsur::f("nsure", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?:ntay::f("ntary", A_ThisHotkey, A_EndChar) ; Fixes 34 words
:XB0?:nyed::f("nied", A_ThisHotkey, A_EndChar) ; Fixes 15 words
:XB0?:oachs::f("oaches", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:occured::f("occurred", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:occurr::f("occur", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:olgy::f("ology", A_ThisHotkey, A_EndChar) ; Fixes 316 words
:XB0?:omst::f("most", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?:onaly::f("onally", A_ThisHotkey, A_EndChar) ; Fixes 174 words
:XB0?:onw::f("one", A_ThisHotkey, A_EndChar) ; Fixes 341 words
:XB0?:otaly::f("otally", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:otherw::f("others", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?:otino::f("otion", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?:otu::f("out", A_ThisHotkey, A_EndChar) ; Fixes 97 words
:XB0?:ougly::f("oughly", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:ouldent::f("ouldn't", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:ouldnt::f("ouldn't", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:ourary::f("orary", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:paide::f("paid", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:pich::f("pitch", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:pleatly::f("pletely", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:pletly::f("pletely", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:polical::f("political", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:proces::f("process", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:proprietory::f("proprietary", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:pthe::f("p the", A_ThisHotkey, A_EndChar)
:XB0?:publis::f("publics", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:puertorrican::f("Puerto Rican", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:quater::f("quarter", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:quaters::f("quarters", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:querd::f("quered", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:raly::f("rally", A_ThisHotkey, A_EndChar) ; Fixes 120 words
:XB0?:rarry::f("rary", A_ThisHotkey, A_EndChar) ; Fixes 23 words
:XB0?:realy::f("really", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?:receeded::f("receded", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:reched::f("reached", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?:reciding::f("residing", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:reday::f("ready", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:resed::f("ressed", A_ThisHotkey, A_EndChar) ; Fixes 50 words
:XB0?:resing::f("ressing", A_ThisHotkey, A_EndChar) ; Fixes 40 words
:XB0?:returnd::f("returned", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:riey::f("riety", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:rithy::f("rity", A_ThisHotkey, A_EndChar) ; Fixes 120 words
:XB0?:ritiers::f("rities", A_ThisHotkey, A_EndChar) ; Fixes 105 words
:XB0?:rthe::f("r the", A_ThisHotkey, A_EndChar)
:XB0?:ruley::f("ruly", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:ryied::f("ried", A_ThisHotkey, A_EndChar) ; Fixes 70 words
:XB0?:saccharid::f("saccharide", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:safty::f("safety", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:sasy::f("says", A_ThisHotkey, A_EndChar) ; Fixes 12 words
:XB0?:saught::f("sought", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:schol::f("school", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:scoll::f("scroll", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:seses::f("sesses", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:sfull::f("sful", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:sfuly::f("sfully", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:sfulyl::f("sfully", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:shiping::f("shipping", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:shorly::f("shortly", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:siary::f("sary", A_ThisHotkey, A_EndChar) ; Fixes 16 words
:XB0?:sicaly::f("sically", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?:sice::f("sive", A_ThisHotkey, A_EndChar) ; Fixes 166 words, but misspells sice (The number six at dice)
:XB0?:sicly::f("sically", A_ThisHotkey, A_EndChar) ; Fixes 24 words
:XB0?:smoothe::f("smooth", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:sorce::f("source", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:specif::f("specify", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:ssfull::f("ssful", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:ssully::f("ssfully", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:stanly::f("stantly", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:sthe::f("s the", A_ThisHotkey, A_EndChar)
:XB0?:stino::f("stion", A_ThisHotkey, A_EndChar) ; Fixes 14 words
:XB0?:storicians::f("storians", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:stpo::f("stop", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:strat::f("start", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0?:struced::f("structed", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?:stuls::f("sults", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:sucesfuly::f("successfully", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:syas::f("says", A_ThisHotkey, A_EndChar) ; Fixes 12 words, but misspells Vaisyas (A member of the mercantile and professional Hindu caste.) 
:XB0?:t eh::f("the", A_ThisHotkey, A_EndChar) ; Fixes 44 words ; Made case sensitive for 'at EH.'
:XB0?:targetting::f("targeting", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:teh::f("the", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:tempory::f("temporary", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:teraly::f("terally", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:tfull::f("tful", A_ThisHotkey, A_EndChar) ; Fixes 64 words
:XB0?:theh::f("the", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:thge::f("the", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:thh::f("th", A_ThisHotkey, A_EndChar) ; Fixes 408 words
:XB0?:thn::f("then", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?:thne::f("then", A_ThisHotkey, A_EndChar) ; Fixes 11 words
:XB0?:throught::f("through", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:tht::f("th", A_ThisHotkey, A_EndChar) ; Fixes 408 words
:XB0?:thw::f("the", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:thyness::f("thiness", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?:tialy::f("tially", A_ThisHotkey, A_EndChar) ; Fixes 57 words
:XB0?:tiem::f("time", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:timne::f("time", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:tionar::f("tionary", A_ThisHotkey, A_EndChar) ; Fixes 68 words
:XB0?:tooes::f("toos", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:topry::f("tory", A_ThisHotkey, A_EndChar) ; Fixes 317 words
:XB0?:toreis::f("tories", A_ThisHotkey, A_EndChar) ; Fixes 62 words
:XB0?:toyr::f("tory", A_ThisHotkey, A_EndChar) ; Fixes 317 words
:XB0?:traing::f("traying", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:tricly::f("trically", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?:tricty::f("tricity", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:truely::f("truly", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:tust::f("trust", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:twon::f("town", A_ThisHotkey, A_EndChar) ; Fixes 32 words
:XB0?:tyo::f("to", A_ThisHotkey, A_EndChar) ; Fixes 185 words
:XB0?:typicaly::f("typically", A_ThisHotkey, A_EndChar) ; Fixes 9 words
:XB0?:ualy::f("ually", A_ThisHotkey, A_EndChar) ; Fixes 72 words
:XB0?:uarly::f("ularly", A_ThisHotkey, A_EndChar) ; Fixes 66 words
:XB0?:ularily::f("ularly", A_ThisHotkey, A_EndChar) ; Fixes 66 words
:XB0?:ultimely::f("ultimately", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:uraly::f("urally", A_ThisHotkey, A_EndChar) ; Fixes 44 words
:XB0?:urchs::f("urches", A_ThisHotkey, A_EndChar) ; Fixes 4 words
:XB0?:urnk::f("runk", A_ThisHotkey, A_EndChar) ; Fixes 8 words
:XB0?:usefull::f("useful", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:utino::f("ution", A_ThisHotkey, A_EndChar) ; Fixes 55 words
:XB0?:veill::f("veil", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:verd::f("vered", A_ThisHotkey, A_EndChar) ; Fixes 39 words
:XB0?:videntally::f("vidently", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:vly::f("vely", A_ThisHotkey, A_EndChar) ; Fixes 547 words
:XB0?:wass::f("was", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:wasy::f("ways", A_ThisHotkey, A_EndChar) ; Fixes 106 words
:XB0?:weas::f("was", A_ThisHotkey, A_EndChar) ; Fixes 13 words
:XB0?:weath::f("wealth", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:wifes::f("wives", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:wille::f("will", A_ThisHotkey, A_EndChar) ; Fixes 10 words
:XB0?:willingless::f("willingness", A_ThisHotkey, A_EndChar) ; Fixes 2 words
:XB0?:wordly::f("worldly", A_ThisHotkey, A_EndChar) ; Fixes 3 words
:XB0?:wroet::f("wrote", A_ThisHotkey, A_EndChar) ; Fixes 7 words
:XB0?:wthe::f("w the", A_ThisHotkey, A_EndChar)
:XB0?:wya::f("way", A_ThisHotkey, A_EndChar) ; Fixes 113 words
:XB0?:wyas::f("ways", A_ThisHotkey, A_EndChar) ; Fixes 106 words
:XB0?:xthe::f("x the", A_ThisHotkey, A_EndChar)
:XB0?:yng::f("ying", A_ThisHotkey, A_EndChar) ; Fixes 514 words
:XB0?:ywat::f("yway", A_ThisHotkey, A_EndChar) ; Fixes 6 words
:XB0?C:hc::f("ch", A_ThisHotkey, A_EndChar) ; Fixes 446 words ; :C: so not to break THC or LHC
:XB0?C:itn::f("ith", A_ThisHotkey, A_EndChar) ; Fixes 70 words, Case sensitive, to not misspell ITN (Independent Television News) 
:XB0C:ASS::f("ADD", A_ThisHotkey, A_EndChar) ; Case-sensitive to fix acronym, but not word.
:XB0C:may of::f("may have", A_ThisHotkey, A_EndChar)

;------------------------------------------------------------------------------
; Accented English words, from, amongst others,
; http://en.wikipedia.org/wiki/List_of_English_words_with_diacritics
; Most of the definitions are from https://www.easydefine.com/ or from the WordWeb application.
;------------------------------------------------------------------------------
::aesop::Æsop ; noun Greek author of fables (circa 620-560 BC)
::a bas::à bas ; French: Down with -- To the bottom.  A type of clothing.
::a la::à la ; In the manner of...
::ancien regime::Ancien Régime ; noun a political and social system that no longer governs (especially the system that existed in France before the French Revolution)
:*:angstrom::Ångström ; noun a metric unit of length equal to one ten billionth of a meter (or 0.0001 micron); used to specify wavelengths of electromagnetic radiation
:*:anime::animé ; noun any of various resins or oleoresins; a hard copal derived from an African tree
::ao dai::ào dái  ; noun the traditional dress of Vietnamese women consisting of a tunic with long sleeves and panels front and back; the tunic is worn over trousers
:*:apertif::apértif ; noun an alcoholic drink that is taken as an appetizer before a meal
:*:applique::appliqué ; noun a decorative design made of one material sewn over another; verb sew on as a decoration
::apres::après ; French:  Too late.  After the event.
::arete::arête ; noun a sharp narrow ridge found in rugged mountains
::attache::attaché ; noun a specialist assigned to the staff of a diplomatic mission; a shallow and rectangular briefcase
::auto-da-fe::auto-da-fé ; noun the burning to death of heretics (as during the Spanish Inquisition)
::belle epoque::belle époque ; French: Fine period.   noun the period of settled and comfortable life preceding World War I
::bete noire::bête noire ; noun a detested person
::betise::bêtise ; noun a stupid mistake
::Bjorn::Bjørn ; An old norse name.  Means "Bear."
::blase::blasé ; adj. nonchalantly unconcerned; uninterested because of frequent exposure or indulgence; very sophisticated especially because of surfeit; versed in the ways of the world
:*:boite::boîte ; French: "Box."  a small restaurant or nightclub.
::boutonniere::boutonnière ; noun a flower that is worn in a buttonhole.
:*:canape::canapé  ; noun an appetizer consisting usually of a thin slice of bread or toast spread with caviar or cheese or other savory food
:*:celebre::célèbre ; Cause célèbre An incident that attracts great public attention.
:*:chaine::chaîné ; / (ballet) noun A series of small fast turns, often with the arms extended, used to cross a floor or stage.
:*:cinema verite::cinéma vérité ; noun a movie that shows ordinary people in actual activities without being controlled by a director
::cinemas verite::cinémas vérit ; noun a movie that shows ordinary people in actual activities without being controlled by a directoré
::champs-elysees::Champs-Élysées ; noun a major avenue in Paris famous for elegant shops and cafes
::charge d'affaires::chargé d'affaires ; noun the official temporarily in charge of a diplomatic mission in the absence of the ambassador
:*:chateau::château ; noun an impressive country house (or castle) in France
:*:cliche::cliché ; noun a trite or obvious remark; clichéd adj. repeated regularly without thought or originality
::cloisonne::cloisonné ; adj. (for metals) having areas separated by metal and filled with colored enamel and fired; noun enamelware in which colored areas are separated by thin metal strips
:*:consomme::consommé ; noun clear soup usually of beef or veal or chicken
:*:communique::communiqué ; noun an official report (usually sent in haste)
:*:confrere::confrère ; noun a person who is member of your class or profession
:*:cortege::cortège ; noun the group following and attending to some important person; a funeral procession
:*:coup d'etat::coup d'état ; noun a sudden and decisive change of government illegally or by force
:*:coup de tat::coup d'état ; noun a sudden and decisive change of government illegally or by force
:*:coup de grace::coup de grâce ; noun the blow that kills (usually mercifully)
:*:creche::crèche ; noun a hospital where foundlings (infant children of unknown parents) are taken in and cared for; a representation of Christ's nativity in the stable at Bethlehem
:*:coulee::coulée ; A stream of lava.  A deep gulch or ravine, frequently dry in summer.
::creme brulee::crème brûlée ; noun custard sprinkled with sugar and broiled
:*:crepe::crêpe ; noun a soft thin light fabric with a crinkled surface; paper with a crinkled texture; usually colored and used for decorations; small very thin pancake; verb cover or drape with crape
:*:creme caramel::crème caramel ; noun baked custard topped with caramel
::creme de cacao::crème de cacao ; noun sweet liqueur flavored with vanilla and cacao beans
::creme de menthe::crème de menthe ; noun sweet green or white mint-flavored liqueur
:*:crouton::croûton ; noun a small piece of toasted or fried bread; served in soup or salads
::creusa::Creüsa ; In Greek mythology, Creusa was the daughter of Priam and Hecuba.
::crudites::crudités ; noun raw vegetables cut into bite-sized strips and served with a dip
::curacao::curaçao ; noun flavored with sour orange peel; a popular island resort in the Netherlands Antilles
:*:dais::daïs ; noun a platform raised above the surrounding level to give prominence to the person on it
:*:debacle::débâcle ; noun a sudden and violent collapse; flooding caused by a tumultuous breakup of ice in a river during the spring or summer; a sound defeat
:*:debutante::débutant ; noun a sudden and violent collapse; flooding caused by a tumultuous breakup of ice in a river during the spring or summer; a sound defeat
::declasse::déclassé ; Fallen or lowered in class, rank, or social position; lacking high station or birth; of inferior status
::decolletage::décolletage ; noun a low-cut neckline on a woman's dress
::decollete::décolleté ; adj. (of a garment) having a low-cut neckline
:*:decor::décor ; noun decoration consisting of the layout and furnishings of a livable interior
::decoupage::découpage ; noun the art of decorating a surface with shapes or pictures and then coating it with vanish or lacquer; art produced by decorating a surface with cutouts and then coating it with several layers of varnish or lacquer
::degage::dégagé ; adj. showing lack of emotional involvement; free and relaxed in manner
::deja vu::déjà vu ; noun the experience of thinking that a new situation had occurred before
::demode::démodé ; adj. out of fashion
::denoument::dénoument ; Narrative structure.  (Not in most dictionaries)
::derailleur::dérailleur ; (cycling) the mechanism on a bicycle used to move the chain from one sprocket (gear) to another
:*:derriere::derrière ; noun the fleshy part of the human body that you sit on
::deshabille::déshabillé ; noun the state of being carelessly or partially dressed
::detente::détente ; noun the easing of tensions or strained relations (especially between nations)
::diamante::diamanté ; noun adornment consisting of a small piece of shiny material used to decorate clothing
:*:discotheque::discothèque ; noun a public dance hall for dancing to recorded popular music
:*:divorcee::divorcée ; noun a divorced woman or a woman who is separated from her husband
:*:doppelganger::doppelgänger ; noun a ghostly double of a living person that haunts its living counterpart
:*:eclair::éclair ; noun oblong cream puff
::eclat::éclat ; noun brilliant or conspicuous success or effect; ceremonial elegance and splendor; enthusiastic approval
::el nino::El Niño ; noun the Christ child; (oceanography) a warm ocean current that flows along the equator from the date line and south off the coast of Ecuador at Christmas time
::elan::élan ; noun enthusiastic and assured vigor and liveliness; distinctive and stylish elegance; a feeling of strong eagerness (usually in favor of a person or cause)
:*:emigre::émigré ; noun someone who leaves one country to settle in another
:*:entree::entrée ; noun the act of entering; the right to enter; the principal dish of a meal; something that provides access (to get in or get out)
::entrepot::entrepôt ; noun a port where merchandise can be imported and then exported without paying import duties; a depository for goods
::entrecote::entrecôte ; Cut of meat taken from between the ribs
:*:epee::épée ; noun a fencing sword similar to a foil but with a heavier blade
::etouffee::étouffée ; A Cajun shellfish dish.
:*:facade::façade ; noun the face or front of a building; a showy misrepresentation intended to conceal something unpleasant
:*:fete::fête ; noun an elaborate party (often outdoors); an organized series of acts and performances (usually in one place); verb have a celebration
::faience::faïence ; noun an elaborate party (often outdoors); an organized series of acts and performances (usually in one place); verb have a celebration
:*:fiance::fiancé ; noun a man who is engaged to be married. fiancee ; noun a woman who is engaged to be married
::filmjolk::filmjölk ; Nordic milk product.
::fin de siecle::fin de siècle ; adj. relating to or characteristic of the end of a century (especially the end of the 19th century)
:*:flambe::flambé ; verb pour liquor over and ignite (a dish)
::fleche::flèche ; a type of church spire; a team cycling competition; an aggressive offensive fencing technique; a defensive fortification; ships of the Royal Navy
::Fohn wind::Föhn wind ; A type of dry, relatively warm, downslope wind that occurs in the lee (downwind side) of a mountain range.
::folie a deux::folie à deux ; noun the simultaneous occurrence of symptoms of a mental disorder (as delusions) in two persons who are closely related (as siblings or man and wife)
::folies a deux::folies à deux
::fouette::fouetté ; From Ballet: The working leg is extended and whipped around
:*:frappe::frappé ; noun thick milkshake containing ice cream; liqueur poured over shaved ice; a frozen dessert with fruit flavoring (especially one containing no milk)
:*:fraulein::fräulein ; noun a German courtesy title or form of address for an unmarried woman
:*:garcon::garçon ; A waiter, esp. at a French restaurant
::gardai::gardaí ; Policeman or policewoman
:*:gateau::gâteau ; noun any of various rich and elaborate cakes
::gemutlichkeit::gemütlichkeit ; Friendliness.
::glace::glacé ; adj. (used especially of fruits) preserved by coating with or allowing to absorb sugar
::glogg::glögg ; noun Scandinavian punch made of claret and aquavit with spices and raisins and orange peel and sugar
::gewurztraminer::Gewürztraminer ; An aromatic white wine grape variety that grows best in cooler climates
::gotterdammerung::Götterdämmerung ; noun myth about the ultimate destruction of the gods in a battle with evil
::grafenberg spot::Gräfenberg spot ;  An erogenous area of the vagina.
:*:habitue::habitué ; noun a regular patron
::ingenue::ingénue ; noun an actress who specializes in playing the role of an artless innocent young girl
::jager::jäger ; A German or Austrian hunter, rifleman, or sharpshooter
:*:jalapeno::jalapeño ; noun hot green or red pepper of southwestern United States and Mexico; plant bearing very hot and finely tapering long peppers; usually red
::jardiniere::jardinière ; A preparation of mixed vegetables stewed in a sauce.  An arrangement of flowers.
::krouzek::kroužek ; A ring-shaped diacritical mark (°), whose use is largely restricted to Å, å and U, u.
::kummel::kümmel ; noun liqueur flavored with caraway seed or cumin
::kaldolmar::kåldolmar ; Swedish cabbage rolls filled with rice and minced meat.
::landler::ländler ; noun a moderately slow Austrian country dance in triple time; involves spinning and clapping; music in triple time for dancing the landler
::langue d'oil::langue d'oïl ; noun medieval provincial dialects of French spoken in central and northern France
::la nina::La Niña ; Spanish:'The Girl' is an oceanic and atmospheric phenomenon that is the colder counterpart of El Niño.
::litterateur::littérateur ; noun a writer of literary works
::lycee::lycée ; noun a school for students intermediate between elementary school and college; usually grades 9 to 12
::macedoine::macédoine ; noun mixed diced fruits or vegetables; hot or cold
::macrame::macramé ; noun a coarse lace; made by weaving and knotting cords; verb make knotted patterns
::maitre d'hotel::maître d'hôtel ; noun a dining-room attendant who is in charge of the waiters and the seating of customers
::malaguena::malagueña ; A Spanish dance or folk tune resembling the fandango.
::manana::mañana ; Spanish: Tomorrow.
::manege::manège ; The art of horsemanship or of training horses.
::manque::manqué ; adj. unfulfilled or frustrated in realizing an ambition
::materiel::matériel ; noun equipment and supplies of a military force
:*:matinee::matinée ; noun a theatrical performance held during the daytime (especially in the afternoon)
::melange::mélange ; noun a motley assortment of things
:*:melee::mêlée ; noun a noisy riotous fight
::menage a trois::ménage à trois ; noun household for three; an arrangement where a married couple and a lover of one of them live together while sharing sexual relations
::menages a trois::ménages à trois
::mesalliance::mésalliance ; noun a marriage with a person of inferior social status
::metier::métier ; noun an occupation for which you are especially well suited; an asset of special worth or utility
::minaudiere::minaudière ; A small, decorative handbag without handles or a strap.
::mobius::Möbius ; noun a continuous closed surface with only one side; formed from a rectangular strip by rotating one end 180 degrees and joining it with the other end
::moire::moiré ; adj. (of silk fabric) having a wavelike pattern; noun silk fabric with a wavy surface pattern
:*:moireing::moiré ; A textile technique that creates a wavy or "watered" effect in fabric.
::motley crue::Mötley Crüe ; American heavy metal band formed in Hollywood, California in 1981.
::motorhead::Motörhead ; English rock band formed in London in 1975.
:*:naif::naïf ; adj. marked by or showing unaffected simplicity and lack of guile or worldly experience; noun a naive or inexperienced person
::naive::naïve ; adj. inexperienced; marked by or showing unaffected simplicity and lack of guile or worldly experience
::naiver::naïver ; See above.
::naives::naïves ; See above.
::naivete::naïveté ; See above.
::nee::née ; adj. (meaning literally `born') used to indicate the maiden or family name of a married woman
:*:negligee::negligée ; noun a loose dressing gown for women
::neufchatel::Neufchâtel ; a cheese
::nez perce::Nez Percé ; noun the Shahaptian language spoken by the Nez Perce; a member of a tribe of the Shahaptian people living on the pacific coast
:*:noel::Noël ; French:  Christmas.
::número uno::número uno ; Number one
::objet trouve::objet trouvé ; An object found or picked up at random and considered aesthetically pleasing.
::objets trouve::objets trouvé ; See above.
:*:ombre::ombré ;  (literally "shaded" in French) is the blending of one color hue to another.  A card game.
::omerta::omertà ; noun a code of silence practiced by the Mafia; a refusal to give evidence to the police about criminal activities
::opera bouffe::opéra bouffe ; noun opera with a happy ending and in which some of the text is spoken
::operas bouffe::opéras bouffe ; see above.
::opera comique::opéra comique ; noun opera with a happy ending and in which some of the text is spoken
::operas comique::opéras comique ; See above.
::outre::outré ; adj. conspicuously or grossly unconventional or unusual
::papier-mache::papier-mâché ; noun a substance made from paper pulp that can be molded when wet and painted when dry
::passe::passé ; adj. out of fashion
::piece de resistance::pièce de résistance ; noun the most important dish of a meal; the outstanding item (the prize piece or main exhibit) in a collection
::pied-a-terre::pied-à-terre ; noun lodging for occasional or secondary use
::plisse::plissé ; (Of a fabric) chemically treated to produce a shirred or puckered effect.
:*:pina colada::Piña Colada ; noun a mixed drink made of pineapple juice and coconut cream and rum
:*:pinata::piñata ; noun plaything consisting of a container filled with toys and candy; suspended from a height for blindfolded children to break with sticks
:*:pinon::piñon ; noun any of several low-growing pines of western North America
::pirana::piraña ; noun small voraciously carnivorous freshwater fishes of South America that attack and destroy living animals
::pique::piqué ; noun tightly woven fabric with raised cords; a sudden outburst of anger; verb cause to feel resentment or indignation
::piqued::piquéd ;noun Animosity or ill-feeling, Offence taken. transitive verb To wound the pride of To arouse, stir, provoke.
::più::più ; Move.
::plie::plié ; A movement in ballet, in which the knees are bent while the body remains upright
::precis::précis ; noun a sketchy summary of the main points of an argument or theory; verb make a summary (of)
:*:protege::protégé ; noun a person who receives support and protection from an influential patron who furthers the protege's career.  protegee ; noun a woman protege
:*:puree::purée ; noun food prepared by cooking and straining or processed in a blender; verb rub through a strainer or process in an electric blender
::polsa::pölsa ; A traditional northern Swedish dish which has been compared to hash
::pret-a-porter::prêt-à-porter ; Ready-to-wear / Off-the-rack.
::Quebecois::Québécois ; adj. of or relating to Quebec
::raison d'etre::raison d'être ; noun the purpose that justifies a thing's existence; reason for being
::recherche::recherché ; adj. lavishly elegant and refined
::retrousse::retroussé ; adjective (of a person's nose) turned up at the tip in an attractive way.
::risque::risqué ; adjective slightly indecent and liable to shock, especially by being sexually suggestive.
::riviere::rivière ; noun a necklace of gems that increase in size toward a large central stone, typically consisting of more than one string.
::roman a clef::roman à clef ; noun a novel in which actual persons and events are disguised as fictional characters
::roue::roué ; noun a dissolute man in fashionable society
:*:saute::sauté ; adj. fried quickly in a little fat; noun a dish of sauteed food; verb fry briefly over high heat
:*:seance::séance ; noun a meeting of spiritualists
:*:senor::señor ; noun a Spanish title or form of address for a man; similar to the English `Mr' or `sir'. senora/señorita ; noun a Spanish title or form of address for a married woman; similar to the English `Mrs' or `madam'
:*:smorgasbord::smörgåsbord ; noun served as a buffet meal; a collection containing a variety of sorts of things
:*:soiree::soirée ; noun a party of people assembled in the evening (usually at a private house)
:*:souffle::soufflé ; noun light fluffy dish of egg yolks and stiffly beaten egg whites mixed with e.g. cheese or fish or fruit
::sinn fein::Sinn Féin ; noun an Irish republican political movement founded in 1905 to promote independence from England
::smorgastarta::smörgåstårta ; "sandwich-cake" or "sandwich-torte" is a dish of Swedish origin
::soigne::soigné ; adj. polished and well-groomed; showing sophisticated elegance
::sprachgefühl::sprachgefuhl ; The essential character of a language.
:*:soupcon::soupçon ; noun a slight but appreciable addition
::surstromming::surströmming ; Lightly salted fermented Baltic Sea herring.
:*:tete-a-tete::tête-à-tête ; adj. involving two persons; intimately private; noun a private conversation between two people; small sofa that seats two people
::touche::touché ; Acknowledgement of a hit in fencing or a point made at one's expense.
::tourtiere::tourtière ; A meat pie that is usually eaten at Christmas in Québec
:*:ubermensch::Übermensch ; noun a person with great powers and abilities
::ventre a terre::ventre à terre ; (French) At high speed (literally, belly to the ground.)
::vicuna::vicuña ; noun small wild cud-chewing Andean animal similar to the guanaco but smaller; valued for its fleecy undercoat; a soft wool fabric made from the fleece of the vicuna; the wool of the vicuna
::vin rose::vin rosé ; White wine.
::vins rose::vins rosé ; See above
::vis a vis::vis à vis ; adv. face-to-face
::vis-a-vis::vis-à-vis ; See above
::voila::voilà ; Behold.  There you are.

;-------------------------------------------------------------------------------
;  Capitalize dates
;-------------------------------------------------------------------------------
:XB0C:monday::f("Monday", A_ThisHotkey, A_EndChar) 
:XB0C:tuesday::f("Tuesday", A_ThisHotkey, A_EndChar) 
:XB0C:wednesday::f("Wednesday", A_ThisHotkey, A_EndChar) 
:XB0C:thursday::f("Thursday", A_ThisHotkey, A_EndChar) 
:XB0C:friday::f("Friday", A_ThisHotkey, A_EndChar) 
:XB0C:saturday::f("Saturday", A_ThisHotkey, A_EndChar) 
:XB0C:sunday::f("Sunday", A_ThisHotkey, A_EndChar) 

:XB0C:january::f("January", A_ThisHotkey, A_EndChar) 
:XB0C:february::f("February", A_ThisHotkey, A_EndChar) 
:XB0C:april::f("April", A_ThisHotkey, A_EndChar) 
:XB0C:june::f("June", A_ThisHotkey, A_EndChar) 
:XB0C:july::f("July", A_ThisHotkey, A_EndChar) 
:XB0C:august::f("August", A_ThisHotkey, A_EndChar) 
:XB0C:september::f("September", A_ThisHotkey, A_EndChar) 
:XB0C:october::f("October", A_ThisHotkey, A_EndChar) 
:XB0C:november::f("November", A_ThisHotkey, A_EndChar) 
:XB0C:december::f("December", A_ThisHotkey, A_EndChar) 

;-------------------------------------------------------------------------------
; Anything below this point was added to the script by the user via the Win+H hotkey.
;-------------------------------------------------------------------------------



::thousend::thousand
:XB0:sampTrig::f("sampRepl", A_ThisHotkey, A_EndChar) ; just a comment


