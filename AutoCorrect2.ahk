#SingleInstance
SetWorkingDir(A_ScriptDir)
SetTitleMatchMode("RegEx")
#Requires AutoHotkey v2+
#Include "DateTool.ahk"
#Include "PrinterTool.ahk"
#Include "HotstringLib.ahk"

;===============================================================================
; Update date: 5-22-2024
; AutoCorrect for v2 thread on AutoHotkey forums:
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=120220
; Project location on GitHub (new versions will be on GitHub)
; https://github.com/kunkel321/AutoCorrect2
;===============================================================================

;The below color assingments should not be commented out.  
;==Change=color=of=Hotstring=Helper=and=other=forms=as=desired================
GuiColor := "F5F5DC" ; "F0F8FF" is light blue. Tip: Use "Default" for Windows default.
FontColor := "003366" ; "003366" is dark blue. Tip: Use "Default" for Windows default.

;===============================================================================
NameOfThisFile := "AutoCorrect2.ahk" ; This variable is used in the below #HotIf command for Ctrl+s: Save and Reload.
HotstringLibrary := "HotstringLib.ahk" ; Your actual library of hotstrings are added here.  
; To change library name, needs to be changed (1) here, and (2) the #Include at the top.
MyAhkEditorPath := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"  ; <--- Only valid when VSCode is installed
; MyAhkEditorPath := "C:\Program Files\AutoHotkey\SciTE\SciTE.exe" : <--- Optionally paste another path and uncomment. 
If not FileExist(MyAhkEditorPath) { ; Make sure AHK editor is assigned.  Use Notepad otherwise.
	MsgBox("This error means that the variable 'MyAhkEditorPath' has"
	"`nnot been assigned a valid path for an editor."
	"`nTherefore Notepad will be used as a substite.")
	MyAhkEditorPath := "Notepad.exe"
}

;===============================================================================
;            			Hotstring Helper 2
;                Hotkey: Win + H | By: Kunkel321
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=114688
; A version of Hotstring Helper that will support block multi-line replacements and 
; allow user to examine hotstring for multi-word matches. The "Examine/Analyze" 
; pop-down part of the form is based on the WAG tool here
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=120377
; Customization options are below, near top of code.
; Please get a copy of AutoHotkey.exe (v2) and rename it to match the name of this
; script file, so that the .exe and the .ahk have the same name, in the same folder.
; DO NOT COMPILE, or the Append command won't work. The Gui stays in RAM, but gets
; repopulated upon hotkey press. HotStrings will be appended (added) by the
; script at the bottom. Shift+Append saves to clipboard instead of appending. 
; This tool is intended to be embedded in your AutoCorrect list.
;===============================================================================

; ===Change=Settings=for=Big=Validity=Dialog=Message=Box========================
myGreen := 'c1D7C08' ; light green 'cB5FFA4' (for use with dark backgrounds.)
myRed := 'cB90012' ; light red 'cFFB2AD'
myBigFont := 's13'
AutoLookupFromValidityCheck := 0 ; Sets default for auto-lookup of selected text on 
; mouse-up, when using the big message box. 
; WARNING:  findInScript() function uses VSCode shortcut keys ^f and ^g. 

;==Miscelanceous=User=Options===================================================
hh_Hotkey := "#h" ; The activation hotkey-combo (not string) for HotString Helper, is Win+h. 


;==Change=title=of=Hotstring=Helper=form=as=desired=============================
hhFormName := "HotString Helper 2" ; The name at the top of the form. Change here, if desired.

; ======Change=size=of=GUI=when="Make Bigger"=is=invoked========================
HeightSizeIncrease := 300 ; Numbers, not 'strings,' so no quotation marks. 
WidthSizeIncrease := 400

;====Assign=symbols=for="Show Symb"=button======================================
myPilcrow := "¶"    ; Okay to change symbols if desired.
myDot := "• "       ; adding a space (optional) allows more natural wrapping.
myTab := "⟹ "      ; adding a space (optional) allows more natural wrapping.

;===Change=options=for=MULTI=word=entry=options=and=trigger=strings=as=desired==
; These are the defaults for "acronym" based boiler plate template trigger strings. 
DefaultBoilerPlateOpts := ""  ; PreEnter these multi-word hotstring options; "*" = end char not needed, etc.
myPrefix := ";"        ; Optional character that you want suggested at the beginning of each hotstring.
addFirstLetters := 5   ; Add first letter of this many words. (5 recommended; 0 = don't use feature.)
tooSmallLen := 2       ; Only first letters from words longer than this. (Moot if addFirstLetters = 0)
mySuffix := ""         ; An empty string "" means don't use feature.

;===============Change=options=AUTOCORRECT=words=as=desired=====================
; PreEnter these (single-word) autocorrect options; "T" = raw text mode, etc.
DefaultAutoCorrectOpts := "*" ; An empty string "" means don't use feature.

;=====List=of=words=use=for=examination=lookup==================================
WordListFile := 'GitHubComboList249k.txt' ; Mostly from github: Copyright (c) 2020 Wordnik
; WordListFile := 'wlist_match6.txt' ; From https://www.keithv.com/software/wlist/
; Make sure word list is there. Change name of word list subfolder, if desired. 
WordListPath := A_ScriptDir '\WordListsForHH\' WordListFile
If not FileExist(WordListPath)
	MsgBox("This error means that the big list of comparison words at:`n" . WordListPath . 
	"`nwas not found.`n`nTherefore the 'Exam' button of the Hotstring Helper tool won't work.")
SplitPath WordListPath, &WordListName ; Extract just the name of the file.

;=====Other=Settings============================================================
; Add "Fixes X words, but misspells Y" to the end of autocorrect items. 
; 1 = Yes, 0 = No. Multi-line Continuation Section items are never auto-commented.
AutoCommentFixesAndMisspells := 1
; Automatically enter the new replacement of a 'whole-word' autocorrect entry into the active edit field?
AutoEnterNewEntry := 1 ; 1 = yes, add. 0 = no, I'll manually type it. 

;====Window=specific=hotkeys====================================================
; These can be edited... Cautiously. 
#HotIf WinActive(hhFormName) ; Allows window-specific hotkeys.
$Enter:: ; When Enter is pressed, but only in this GUI. "$" prevents accidental Enter key loop.
{ 	If (hh['SymTog'].text = "Hide Symb")
		return ; If 'Show symbols' is active, do nothing.
	Else if ReplaceString.Focused {
		Send("{Enter}") ; Just normal typing; Enter yields Enter key press.
		Return
	}
	Else hhButtonAppend() ; Replacement box not focused, so press Append button.
}
+Left:: ; Shift+Left: Got to trigger, move cursor far left.
{	TriggerString.Focus()
		Send "{Home}"
}
Esc::
{ 	hh.Hide()
	A_Clipboard := ClipboardOld
}
^z:: GoUndo() ; Undo last 'word exam' trims, one at a time.
^+z:: GoReStart() ; Put the whole trigger and replacement back (restart).
^Up:: 		; Ctrl+Up Arrow, or 
^WheelUp::	; Ctrl+Mouse Wheel Up to increase font size (toggle, not zoom.)
{	MyDefaultOpts.SetFont('s15')  ; sets at 15
	TriggerString.SetFont('s15')
	ReplaceString.SetFont('s15')
}
^Down:: 		; Ctrl+Down Arrow, or 
^WheelDown:: 	; Ctrl+Mouse Wheel Down to put font size back.
{	MyDefaultOpts.SetFont('s11')  ; sets back at 11
	TriggerString.SetFont('s11')
	ReplaceString.SetFont('s11')
}
#HotIf ; Turn off window-specific behavior.

;===== Main Graphical User Interface (GUI) is built here =======================
hh := Gui('', hhFormName)
hh.Opt("-MinimizeBox +alwaysOnTop")
try hh.BackColor := GuiColor ; This variable gets set at the top of the HotString Helper section. 
FontColor := FontColor != "" ? "c" . FontColor : ""
hh.SetFont("s11 " . FontColor)  ; This variable gets set at the top of the HotString Helper section. 
hFactor := 0, wFactor := 0 ; Don't change size here. 
; -----  Trigger string parts ----
hh.AddText('y4 w30', 'Options')
(TrigLbl := hh.AddText('x+40 w250', 'Trigger String'))
(MyDefaultOpts := hh.AddEdit('cDefault yp+20 xm+2 w70 h24'))
(TriggerString := hh.AddEdit('cDefault x+18 w' . wFactor + 280, '')).OnEvent('Change', TriggerChanged)
; ----- Replacement string parts ----
hh.AddText('xm', 'Replacement')
hh.SetFont('s9')
hh.AddButton('vSizeTog x+75 yp-5 h8 +notab', 'Make Bigger').OnEvent("Click", TogSize)
hh.AddButton('vSymTog x+5 h8 +notab', '+ Symbols').OnEvent("Click", TogSym)
hh.SetFont('s11')
(ReplaceString := hh.AddEdit('cDefault vReplaceString +Wrap y+1 xs h' . hFactor + 100 . ' w' . wFactor + 370, '')).OnEvent('Change', GoFilter)
; ---- Below Replacement ----
ComLbl := hh.AddText('xm y' . hFactor + 182, 'Comment')
(ChkFunc := hh.AddCheckbox('vFunc, x+70 y' . hFactor + 182, 'Make Function')).onEvent('click', FormAsFunc)
ChkFunc.Value := 1 ; 'Make Function' box checked by default?  1 = checked.  NOTE: If HH detects a multiline item, this gets unchecked. 
;hh.SetFont("s11 cGreen")
ComStr := hh.AddEdit('cGreen vComStr xs y' . hFactor + 200 . ' w' . wFactor + 370)
;hh.SetFont("s11 " . FontColor)
; ---- Buttons ----
(ButApp := hh.AddButton('xm y' . hFactor + 234, 'Append')).OnEvent("Click", hhButtonAppend)
(ButCheck := hh.AddButton('+notab x+5 y' . hFactor + 234, 'Check')).OnEvent("Click", hhButtonCheck)
(ButExam := hh.AddButton('+notab x+5 y' . hFactor + 234, 'Exam'))
ButExam.OnEvent("Click", hhButtonExam)
ButExam.OnEvent("ContextMenu", subFuncExamControl)
(ButSpell := hh.AddButton('+notab x+5 y' . hFactor + 234, 'Spell')).OnEvent("Click", hhButtonSpell)
(ButOpen := hh.AddButton('+notab x+5 y' . hFactor + 234, 'Open')).OnEvent("Click", hhButtonOpen)
(ButCancel := hh.AddButton('+notab x+5 y' . hFactor + 234, 'Cancel')).OnEvent("Click", hhButtonCancel)
hh.OnEvent("Close", hhButtonCancel)
; ============== Bottom (toggling) "Exam Pane" part of GUI =====================
; ---- delta string ----
hh.SetFont('s10')
(ButLTrim := hh.AddButton('vbutLtrim xm h50  w' . (wFactor+182/6), '>>')).onEvent('click', GoLTrim)
hh.SetFont('s14')
(TxtTypo := hh.AddText('vTypoLabel -wrap +center cBlue x+1 w' . (wFactor+182*5/3), hhFormName))
hh.SetFont('s10')
(ButRTrim := hh.AddButton('vbutRtrim x+1 h50 w' . (wFactor+182/6), '<<')).onEvent('click', GoRTrim)
; ---- radio buttons -----
hh.SetFont('s11')
RadBeg := hh.AddRadio('vBegRadio y+-18 x' . (wFactor+182/3), '&Beginnings')
	RadBeg.onEvent('click', GoFilter)
	RadBeg.onEvent('contextmenu', GoRadioClick)
RadMid := hh.AddRadio('vMidRadio x+5', '&Middles')
	RadMid.onEvent('click', GoFilter)
	RadMid.onEvent('contextmenu', GoRadioClick)
RadEnd := hh.AddRadio('vEndRadio x+5', '&Endings')
	RadEnd.onEvent('click', GoFilter)
	RadEnd.onEvent('contextmenu', GoRadioClick)
; ---- bottom buttons -----
(ButUndo := hh.AddButton('xm y+3 h26 w' . (wFactor+182*2), "Undo (+Reset)")).OnEvent('Click', GoUndo)
ButUndo.Enabled := false
; ---- results lists -----
hh.SetFont('s12')
(TxtTLable := hh.AddText('vTrigLabel center y+4 h25 xm w' . wFactor+182, 'Misspells'))
(TxtRLable := hh.AddText('vReplLabel center h25 x+5 w' . wFactor+182, 'Fixes'))
(EdtTMatches := hh.AddEdit('cDefault vTrigMatches y+1 xm h' . hFactor+300 . ' w' . wFactor+182,))
(EdtRMatches := hh.AddEdit('cDefault vReplMatches x+5 h' . hFactor+300 . ' w' . wFactor+182,))
; ---- word list file ----
hh.SetFont('bold s8')
(TxtWordList := hh.AddText('vWordList center xm y+1 h14 w' . wFactor*2+364 , "Assigned word list: " WordListName))
hh.SetFont('bold s10')
ShowHideButtonExam(Visibility := False) ; Hides bottom part of GUI as default. 
; ============== Bottom (toggling) "Control Pane" part of GUI =====================
(TxtCtrlLbl1 := hh.AddText(' center cBlue ym+270 h25 xm w' . wFactor+370, 'Secret Control Panel!'))
hh.SetFont('s10')
(butRunHSlib := hh.AddButton('  y+5 h25 xm w' . wFactor+370, 'Open HotString Library'))
butRunHSlib.OnEvent("click", (*) => ControlPaneRuns("butRunHSlib"))
(butRunAcLog := hh.AddButton('  y+5 h25 xm w' . wFactor+370, 'Open AutoCorrection Log'))
butRunAcLog.OnEvent("click", (*) => ControlPaneRuns("butRunAcLog"))
(butRunMcLog := hh.AddButton('  y+5 h25 xm w' . wFactor+370, 'Open Manual Correction Log'))
butRunMcLog.OnEvent("click", (*) => ControlPaneRuns("butRunMcLog"))
(butFixRep := hh.AddButton('y+5 h25 xm w' . wFactor+370,'Count HotStrings and Potential Fixes'))
butFixRep.OnEvent('Click', StringAndFixReport)

ShowHideButtonsControl(Visibility := False) ; Hides bottom part of GUI as default. 

ControlPaneRuns(buttonIdentifier)
{
	if (buttonIdentifier = "butRunHSlib")
		hhButtonOpen()
	if (buttonIdentifier = "butRunAcLog")
		Run MyAhkEditorPath " AutoCorrectsLog.ahk" ; Note space before file name.
	else if (buttonIdentifier = "butRunMcLog")
		Run MyAhkEditorPath " MCLog.txt" ; Note space before file name.
}

ShowHideButtonsControl(Visibility := False) ; Shows/Hides bottom, Exam Pane, part of GUI.
{	ControlCmds := [TxtCtrlLbl1,butRunHSlib,butRunAcLog,butRunMcLog,butFixRep]
	for ctrl in ControlCmds {
		ctrl.Visible := Visibility
	}
}

ShowHideButtonExam(Visibility := False) ; Shows/Hides bottom, Exam Pane, part of GUI.
{	examCmds := [ButLTrim, TxtTypo, ButRTrim, RadBeg, RadMid, RadEnd, ButUndo, TxtTLable, TxtRLable, EdtTMatches, EdtRMatches, TxtWordList]
	for ctrl in examCmds {
		ctrl.Visible := Visibility
	}
}

ExamPaneOpen := 0
ControlPaneOpen := 0

OrigTrigger := "" ; Used to restore original content.
OrigReplacment := ""
tArrStep := [] ; array for trigger undos
rArrStep := [] ; array for replacement undos

origTriggerTypo := "" ; Used to determine is trigger has been changed, to potentially type new replacement at runtime.

if (A_Args.Length > 0) ; Check if a command line argument is present.
	CheckClipboard()  ; If present, open hh2 directly. 

;===The=main=function=for=showing=the=Hotstring=Helper=Tool=====================
; This code block copies the selected text, then determines if a hotstring is present.
; If present, hotstring is parsed and HH form is populated and ExamineWords() called. 
; If not, NormalStartup() function is called.
Hotkey hh_Hotkey, CheckClipboard ; Change hotkey above, if desired. 
CheckClipboard(*)
{ 	DefaultHotStr := "" ; Clear each time. 
	TrigLbl.SetFont(FontColor) ; Reset color of Label, in case it's red. 
	EdtRMatches.CurrMatches := "" ; reset custom property
	Global ClipboardOld := ClipboardAll() ; Save and put back later.
	A_Clipboard := ""  ; Must start off blank for detection to work.
	global A_Args
	if (A_Args.Length > 0) ; Check if a command line argument is present.
	{	A_Clipboard := A_Args[1] ; Sent via command line, from MCLogger.
		A_Args := [] ; Clear, the array after each use. 
	}	
	else ; No cmd line, so just simulaate copy like normal. 
	{	Send("^c") ; Copy selected text.
		Errorlevel := !ClipWait(0.3) ; Wait for clipboard to contain text.
	}
	Global Opts:= "", Trig := "", Repl := "", Opts := ""
	hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<fCom>\h*;\h*(?:\bFIXES\h*\d+\h*WORDS?\b)?(?:\h;)?\h*(?<mCom>.*))?$" ; Jim 156
	; Awesome regex by andymbody: https://www.autohotkey.com/boards/viewtopic.php?f=82&t=125100
	; The regex will detect, and parse, a hotstring, whether normal, or embedded in an f() function. 
	thisHotStr := Trim(A_Clipboard," `t`n`r")
	If RegExMatch(thisHotStr, hsRegex, &hotstr) {
		thisHotStr := "" ; Reset to blank each use.
		TriggerString.text := hotstr.Trig  ; Send to top of GUI. 
		MyDefaultOpts.Value := hotstr.Opts
		sleep(200) ; prevents intermitent error on next line.
		Global OrigTrigger := hotstr.Trig
		hotstr.Repl := Trim(hotstr.Repl, '"')
		ReplaceString.text := hotstr.Repl
		ComStr.text := hotstr.mCom ; Removes automated part of comment, leaves manual part. 
		Global OrigReplacement := hotstr.Repl
		; ---- For parse text label ----
		Global strT := hotstr.Trig
		Global TrigNeedle_Orig := hotstr.Trig  ; used for TriggerChnged function below.
		Global strR := hotstr.Repl
		;hh.origHotStr := hotstr.Repl ; Used if Rarify checkbox undone. 
		; set radio buttons, based on options of copied hotstring... 
		If InStr(hotstr.Opts, "*") && InStr(hotstr.Opts, "?")
			RadMid.Value := 1 ; Set Radio to "middle"
		Else If InStr(hotstr.Opts, "*") 
			RadBeg.Value := 1 ; Set Radio to "beginning"
		Else If InStr(hotstr.Opts, "?")
			RadEnd.Value := 1 ; Set Radio to "end"
		Else
			RadMid.Value := 1 ; Also set Radio to "middle"
		ExamineWords(strT, strR)
	}
	Else {
		Global strT := A_Clipboard
		Global TrigNeedle_Orig := strT ; used for TriggerChnged function below.
		Global strR := A_Clipboard	
		;hh.origHotStr := A_Clipboard ; Used if Rarify checkbox undone. 
		NormalStartup(strT, strR)
	}

	Global tMatches := 0 ; <--- Need this or can't run validiy check w/o first filtering. 
	; ---- clear/reset undo history --- 
	ButUndo.Enabled := false
	Loop tArrStep.Length
		tArrStep.pop
	Loop rArrStep.Length
		rArrStep.pop
	; ---------------------------
}

; This function tries to determine if the content of the clipboard is an AutoCorrect
; item, or a selection of boilerplate text.  If boilerplate text, an acronym is
; generated from the first letters.  (e.g. ::ttyl::talk to you later)
IsMultiLine := 0
NormalStartup(strT, strR)
{	; If multiple spaces or `n present, probably not an Autocorrect entry, so make acronym.
	If ((StrLen(A_Clipboard) - StrLen(StrReplace(A_Clipboard," ")) > 2) || InStr(A_Clipboard, "`n"))
	{	DefaultOpts := DefaultBoilerPlateOpts 
		ReplaceString.value := A_Clipboard
		Global IsMultiLine := 1
		ChkFunc.Value := 0 ; Multi-line item, so don't make into function. 
		If (addFirstLetters > 0)
		{ ;LBLhotstring := "Edit trigger string as needed"
			initials := "" ; Initials will be the first letter of each word as a hotstring suggestion.
			HotStrSug := StrReplace(A_Clipboard, "`n", " ") ; Unwrap, but only for hotstr suggestion.
			Loop Parse, HotStrSug, A_Space, A_Tab
			{ 	If (Strlen(A_LoopField) > tooSmallLen) ; Check length of each word, ignore if N letters.
					initials .= SubStr(A_LoopField, "1", "1") 
				If (StrLen(initials) = addFirstLetters) ; stop looping if hotstring is N chars long.
					break
			}
			initials := StrLower(initials)
			; Append preferred prefix or suffix, as defined above, to initials.
			DefaultHotStr := myPrefix . initials . mySuffix
		}
		else 
		{	;LBLhotstring := "Add a trigger string"
			DefaultHotStr := myPrefix . mySuffix ; Use prefix and/or suffix as needed, but no initials.
		}
	}
	Else If (A_Clipboard = "")
	{	;LBLhotstring := "Add a trigger string"
		MyDefaultOpts.Text := "" ; <-- Is this needed?  Might be redundant by Filter() ? 
		TriggerString.Text := "", ReplaceString.Text := "", ComStr.Text := "" ; Clear boxes. 
		RadBeg.Value := 0, RadMid.Value := 0, RadEnd.Value := 0 
		GoFilter()
		hh.Show('Autosize yCenter') 
		Return
	}
	else
	{ ;LBLhotstring := "Add misspelled word"
		If (AutoEnterNewEntry = 1)
		{	Global targetWindow := WinActive("A")  ; Get the handle of the currently active window
			Global origTriggerTypo  := A_Clipboard ; Used to determine if we can type new replacement into current edit field.
		}
		; NOTE:  Do we want the copied word to be lower-cased and trimmed of white space?  Methinks, yes. 
		DefaultHotStr := Trim(StrLower(A_Clipboard)) ; No `n found so assume it's a mispelling autocorrect entry: no pre/suffix.
		ReplaceString.value := Trim(StrLower(A_Clipboard)) 
		DefaultOpts := DefaultAutoCorrectOpts  
	}
	
	MyDefaultOpts.text := DefaultOpts
	;TrigLbl.value := LBLhotstring
	TriggerString.value := DefaultHotStr
	ReplaceString.Opt("-Readonly")
	ButApp.Enabled := true
	If ExamPaneOpen = 1
		goFilter()
	hh.Show('Autosize yCenter') 
} 

; The "Exam" button triggers this function.  Most of this function is dedicated
; to comparing/parsing the trigger and replacement to populate the blue Delta String
ExamineWords(strT, strR) 
{	SubTogSize(0, 0) ; Incase size is 'Bigger,' make Smaller.
	hh.Show('Autosize yCenter') 

	ostrT := strT ; original value (not an array)
	ostrR := strR
	LenT := strLen(strT)
	LenR := strLen(strR)

	LoopNum := min(LenT, LenR)
	strT := StrSplit(strT)
	strR := StrSplit(strR)
	Global beginning := ""
	Global typo := ""
	Global fix := ""
	Global ending := ""

	If ostrT = ostrR ; trig/replacement the same
	{	deltaString := "[ " ostrT " | " ostrR " ]"
		found := false ; for duplicate item message, below
	}
	else ; trig/replacement not the same, so find the difference
	{	Loop LoopNum
		{ ; find matching left substring.
			bsubT := (strT[A_Index])
			bsubR := (strR[A_Index])
			If (bsubT = bsubR)
				beginning .= bsubT
			else
				break
		}

		Loop LoopNum
		{ ; Reverse Loop, find matching right substring.
			RevIndex := (LenT - A_Index) + 1
			esubT := (strT[RevIndex])
			RevIndex := (LenR - A_Index) + 1
			esubR := (strR[RevIndex])
			If (esubT = esubR)
				ending := esubT . ending
			else
				break
		}

		If (strLen(beginning) + strLen(ending)) > LoopNum { ; Overlap means repeated chars in trig or replacement.
			If (LenT > LenR) { ; Trig is longer, so use T-R for str len.
				delta := subStr(ending, 1, (LenT - LenR)) ; Left part of ending.  Right part of beginning would also work.
				delta := " [ " . delta . " |  ] "
			}
			If (LenR > LenT) { ; Replacement is longer, so use R-T for str len.
				delta := subStr(ending, 1, (LenR - LenT))
				delta := " [  |  " . delta . " ] "
			}
		}
		Else {
			If strLen(beginning) > strLen(ending) { ; replace shorter string last
				typo := StrReplace(ostrT, beginning, "")
				typo := StrReplace(typo, ending, "")
				fix := StrReplace(ostrR, beginning, "")
				fix := StrReplace(fix, ending, "")
			}
			Else {
				typo := StrReplace(ostrT, ending, "")
				typo := StrReplace(typo, beginning, "")
				fix := StrReplace(ostrR, ending, "")
				fix := StrReplace(fix, beginning, "")
			}
			delta := " [ " . typo . " | " . fix . " ] "
		}
		deltaString := beginning . delta . ending

	}		
	; -------------
	TxtTypo.text := deltaString ; set label at top of form.

	ViaExamButt := "Yes"
	GoFilter(ViaExamButt) ; Call filter function then come back here.
	
	If (ButExam.text = "Exam") { 
		ButExam.text := "Done"
		If(hFactor != 0) {
			hh['SizeTog'].text := "Make Bigger"
			SoundBeep
			SubTogSize(0, 0) ; Make replacement edit box small again.
		}
	ShowHideButtonExam(True)	
	}	
	hh.Show('Autosize yCenter') 
}

; This function toggles the size of the HH form, using the above variables.
; HeightSizeIncrease and WidthSizeIncrease determine the size when large.
; The size when small is hardcoded.  Change with caution. 
TogSize(*)
{ 	If (hh['SizeTog'].text = "Make Bigger") { ; Means current state is 'Small'
		hh['SizeTog'].text := "Make Smaller"
		If (ButExam.text = "Done") {
			ShowHideButtonExam(Visibility := False)
			ExamPaneOpen := 0
			ShowHideButtonsControl(Visibility := False)
			ControlPaneOpen := 0
			ButExam.text := "Exam"
		}
		Global hFactor := HeightSizeIncrease
		SubTogSize(hFactor, WidthSizeIncrease)
		;hhButtonExam()
		hh.Show('Autosize yCenter') 
		return
	}
	If (hh['SizeTog'].text = "Make Smaller") { ; Means current state is 'Big'
		hh['SizeTog'].text := "Make Bigger"
		Global hFactor := 0
		SubTogSize(0, 0)
		hh.Show('Autosize yCenter') 
		return
	}
}

; Called by TogSize function. 
SubTogSize(hFactor, wFactor) ; Actually re-draws the form. 
{	;MsgBox("TogSizeFunc`nhFactor is:`n`n" . hFactor)
	TriggerString.Move(, , wFactor + 280,)
	ReplaceString.Move(, , wFactor + 372, hFactor + 100)
	ComLbl.Move(, hFactor + 182, ,)
	ComStr.move(, hFactor + 200, wFactor + 367,)
	ChkFunc.Move(, hFactor + 182, ,)
	ButApp.Move(, hFactor + 234, ,)
	ButCheck.Move(, hFactor + 234, ,)
	ButExam.Move(, hFactor + 234, ,)
	ButSpell.Move(, hFactor + 234, ,)
	ButOpen.Move(, hFactor + 234, ,)
	ButCancel.Move(, hFactor + 234, ,)
}

; This function gets called from hhButtonExam (below) or ButExam's onEvent.
; It shows the Control Pane.
subFuncExamControl(*)
{	Global ControlPaneOpen
	If ControlPaneOpen = 1 {
		ButExam.text := "Exam"
		ShowHideButtonsControl(False)
		ShowHideButtonExam(False)	
		ControlPaneOpen := 0
	}
	Else {
		ButExam.text := "Done"
			;msgbox 'hFactor is ' hFactor 
		If(hFactor = HeightSizeIncrease) { 
			TogSize() ; Make replacement edit box small again.
			hh['SizeTog'].text := "Make Bigger"
		}
		ShowHideButtonsControl(True)
		ShowHideButtonExam(False)	
		ControlPaneOpen := 1
	}
	hh.Show('Autosize yCenter') 
}

hhButtonExam(*) ; Tripple state, but button text is only dual state (exam/done)
{	Global ExamPaneOpen
	Global ControlPaneOpen
	If ((ExamPaneOpen = 0) and (ControlPaneOpen = 0) and GetKeyState("Shift")) 
	|| ((ExamPaneOpen = 1) and (ControlPaneOpen = 0) and GetKeyState("Shift")) { ; Both closed, so open Control Pane.
	subFuncExamControl() ; subFunction shows control pane. 
	}
	Else If (ExamPaneOpen = 0) and (ControlPaneOpen = 0) { ; Both closed, so open Exam Pane.
		ButExam.text := "Done"
		If(hFactor = HeightSizeIncrease) {
			TogSize() ; Make replacement edit box small again.
			hh['SizeTog'].text := "Make Bigger"
		}
		Global OrigTrigger := TriggerString.text
		Global OrigReplacement := ReplaceString.text
		ExamineWords(OrigTrigger, OrigReplacement) ; Call Exam function every time Pane is opened. 
		goFilter()
		ShowHideButtonsControl(False)
		ShowHideButtonExam(True)	
		ExamPaneOpen := 1
	}
	Else { ; Close either whatever pane is open..
		ButExam.text := "Exam"
		ShowHideButtonsControl(False)
		ShowHideButtonExam(False)
		ExamPaneOpen := 0
		ControlPaneOpen := 0	
	}	
	hh.Show('Autosize yCenter') 	
}

; This functions toggles on/off whether the Pilcrow and other symbols are shown.
; When shown, the replacment box is set "read only" and Append is disabled. 
TogSym(*)
{ 	If (hh['SymTog'].text = "+ Symbols") {
		hh['SymTog'].text := "- Symbols"
		togReplaceString := ReplaceString.text
		togReplaceString := StrReplace(StrReplace(togReplaceString, "`r`n", "`n"), "`n", myPilcrow . "`n") ; Pilcrow for Enter
		togReplaceString := StrReplace(togReplaceString, A_Space, myDot) ; middle dot for Space
		togReplaceString := StrReplace(togReplaceString, A_Tab, myTab) ; space arrow space for Tab
		ReplaceString.value := togReplaceString
		ReplaceString.Opt("+Readonly")
		ButApp.Enabled := false
		hh.Show('Autosize yCenter') 
		return
	}
	If (hh['SymTog'].text = "- Symbols") {
		hh['SymTog'].text := "+ Symbols"
		togReplaceString := ReplaceString.text
		togReplaceString := StrReplace(togReplaceString, myPilcrow . "`r", "`r") ; Have to use `r ... weird.
		togReplaceString := StrReplace(togReplaceString, myDot, A_Space)
		togReplaceString := StrReplace(togReplaceString, myTab, A_Tab)
		ReplaceString.value := togReplaceString
		ReplaceString.Opt("-Readonly")
		ButApp.Enabled := true
		hh.Show('Autosize yCenter') 
		return
	}
}

; The function is called whenever the trigger(hotstring) edit box is changed.  
; It assesses whether a letter has beem manually added to the beginning/ending
; of the trigger, and adds the same letter to the replacement edit box.  
; BUGGY...  Doesn't always do anything.  :(
TriggerChanged(*)
{	TrigNeedle_New := TriggerString.text 
	If TrigNeedle_New != TrigNeedle_Orig && ExamPaneOpen = 1 { ; If trigger has changed and pane open.
		If TrigNeedle_Orig = SubStr(TrigNeedle_New, 2, ) { ; one char added on the left left box
			tArrStep.push(TriggerString.text) ; <---- save history for Undo feature
			rArrStep.push(ReplaceString.text) ; <---- save history
			ReplaceString.Value := SubStr(TrigNeedle_New, 1, 1) . ReplaceString.text ; add same char to left of other box
		}
		If TrigNeedle_Orig = SubStr(TrigNeedle_New, 1, StrLen(TrigNeedle_New)-1) { ; one char added on the right or left box
			tArrStep.push(TriggerString.text) ; <---- save history for Undo feature
			rArrStep.push(ReplaceString.text) ; <---- save history
			ReplaceString.text :=  ReplaceString.text . SubStr(TrigNeedle_New, -1, ) ; add same char on other side.
		}
		Global TrigNeedle_Orig := TrigNeedle_New ; Update the "original" string so it can detect the next change.
	}
	ButUndo.Enabled := true
	goFilter()
}

; This function detects that the "[] Make Function" box was ticked. 
; It puts/removes the needed hotstring options, then beeps. 
FormAsFunc(*)
{	If (ChkFunc.Value = 1) {
		MyDefaultOpts.text := "B0X" StrReplace(StrReplace(MyDefaultOpts.text, "B0", ""), "X", "")
		SoundBeep 700, 200
	}
	else {
		MyDefaultOpts.text := StrReplace(StrReplace(MyDefaultOpts.text, "B0", ""), "X", "")
		SoundBeep 900, 200
	}
}

; Runs a validity check.  If validiy problems are found, user is given option to append anyway.  
hhButtonAppend(*)
{ 	Global tMyDefaultOpts := MyDefaultOpts.text
	Global tTriggerString := TriggerString.text
	Global tReplaceString := ReplaceString.text
	ValidationFunction(tMyDefaultOpts, tTriggerString, tReplaceString)
	If Not InStr(CombinedValidMsg, "-Okay.", , , 3) ; Msg doesn't have three occurrences of "-Okay." 
		biggerMsgBox(CombinedValidMsg, 1)
	else { ; no validation problems found
		Appendit(tMyDefaultOpts, tTriggerString, tReplaceString)
		return
	}
}

; Calls the validity check, but doesn't append the hotstring. 
hhButtonCheck(*)
{ 	
	If winExist('Validity Report') ; Toggles showing the big box. 
	{	bb.Destroy()
		Return
	}
	else
	{	Global tMyDefaultOpts := MyDefaultOpts.text
		Global tTriggerString := TriggerString.text
		Global tReplaceString := ReplaceString.text
		ValidationFunction(tMyDefaultOpts, tTriggerString, tReplaceString)
		biggerMsgBox(CombinedValidMsg, 0)
		Return
	}
}

; An easy-to-see large dialog to show Validity report/warning. 
; Selecting text from the trigger report box copies it when releasing the mouse button.
; Selected text is sent to find box in VSCode.  If digits, sent to go-to-line. 
bb := 0
biggerMsgBox(thisMess, secondButt)
{	A_Clipboard := thisMess
	global bb
	if (IsObject(bb)) ; Ensures we don't have multiple instances. 
		bb.Destroy()
	Global bb := Gui(,'Validity Report')
	bb.SetFont('s11 ' FontColor)
	bb.BackColor := GuiColor, GuiColor
	global mbTitle := ""
	(mbTitle := bb.Add('Text',, 'For proposed new item:')).Focus() ; Focusing this prevents the three "edit" boxes from being focussed by default.
	bb.SetFont(myBigFont )
	proposedHS := ':' tMyDefaultOpts ':' tTriggerString '::' tReplaceString
	bb.Add('Text', (strLen(proposedHS)>90? 'w600 ':'') 'xs yp+22', proposedHS)
	bb.SetFont('s11 ')
	secondButt=0? bb.Add('Text', ,"===Validation Check Results==="):''
	bb.SetFont(myBigFont )
	bbItem := StrSplit(thisMess, "*|*") 
	If InStr(bbItem[2],"`n",,,10)  ; 2 lines per conflict, if more than 5 conflicts, truncate, and add message.
		bbItem2 :=  subStr(bbItem[2], 1, inStr(bbItem[2], "`n",,,10)) "`n## Too many conflicts to show in form ##"
	Else  ; There are 10 or fewer conflicts found, so show full substring.
		bbItem2 := bbItem[2]
	; Use "edit" rather than "text" because it allows us to select the text. 
	edtSharedSettings := ' -VScroll ReadOnly -E0x200 Background'
	bb.Add('Edit', (inStr(bbItem[1],'-Okay.')? myGreen : myRed) edtSharedSettings GuiColor, bbItem[1]) 
	trigEdtBox := bb.Add('Edit', (strLen(bbItem2)>104? ' w600 ' : ' ') (inStr(bbItem2,'-Okay.')? myGreen : myRed) edtSharedSettings GuiColor, bbItem2) 
	bb.Add('Edit', (strLen(bbItem[3])>104? ' w600 ' : ' ') (inStr(bbItem[3],'-Okay.')? myGreen : myRed) edtSharedSettings GuiColor, bbItem[3])
	trigEdtBox.OnEvent('Focus', findInScript) 
	bb.SetFont('s11 ' FontColor)
	secondButt=1? bb.Add('Text',,"==============================`nAppend HotString Anyway?"):''
	bbAppend := bb.Add('Button', , 'Append Anyway')
	bbAppend.OnEvent 'Click', (*) => Appendit(tMyDefaultOpts, tTriggerString, tReplaceString)
	bbAppend.OnEvent 'Click', (*) => bb.Destroy()
	if secondButt != 1
		bbAppend.Visible := False
	bbClose := bb.Add('Button', 'x+5 Default', 'Close')
	bbClose.OnEvent 'Click', (*) => bb.Destroy()
	If not inStr(bbItem2,'-Okay.') ; It no trigger concerns, don't need checkbox.
		global bbAuto := bb.Add('Checkbox', 'x+5 Checked' AutoLookupFromValidityCheck, 'Auto Lookup`nin editor')
	bb.Show('yCenter x' (A_ScreenWidth/2))
	WinSetAlwaysontop(1, "A")
	bb.OnEvent 'Escape', (*) => bb.Destroy()
}

; Find the text that is selected in the biggerMsgBox GUI. 
findInScript(*) 
{	If (bbAuto.Value = 0)
		Return ; If auto-lookup on mouse up box not checked, do nothing. 
	SoundBeep ; Otherwise beep, wait for mouse up, etc. 
	if (GetKeyState("LButton", "P"))
		KeyWait "LButton", "U"
	A_Clipboard := ""
	SendInput "^c"
	If !ClipWait( 1, 0)
		Return	
	;msgbox A_Clipboard
	if WinExist(HotstringLibrary)
		WinActivate HotstringLibrary
	else 
	{	Run MyAhkEditorPath " " HotstringLibrary
		While !WinExist(HotstringLibrary)
			Sleep 50
		WinActivate HotstringLibrary
	}
	If RegExMatch(A_Clipboard, "^\d{2,}") ; two or more digits? 
		SendInput "^g" A_Clipboard ; <--- Keyboard shortcut for "Go to line number."
	else 
	{	SendInput "^f" ; <--- Keyboard shortcut for "Find"
		sleep 200
		SendInput "^v" ; Paste in search string (which is text selected in big message box.)
	}
	mbTitle.Focus() ; Focus title again so text doesn't stay selected. 
}

; This function runs several validity checks. 
ValidationFunction(tMyDefaultOpts, tTriggerString, tReplaceString)
{ 	GoFilter() ; This ensures that "rMatches" has been populated. <--- had it commented out for a while, then put back. 
	Global CombinedValidMsg := "", validHotDupes := "", validHotMisspells := "", ACitemsStartAt
	ThisFile := Fileread(HotstringLibrary) ; Save these contents to variable 'ThisFile'.
	If (tMyDefaultOpts = "") ; If options box is empty, skip regxex check.
		validOpts := "Okay."
	else { ;===== Make sure hotstring options are valid ========
		NeedleRegEx := "(\*|B0|\?|SI|C|K[0-9]{1,3}|SE|X|SP|O|R|T)" ; These are in the AHK docs I swear!!!
		WithNeedlesRemoved := RegExReplace(tMyDefaultOpts, NeedleRegEx, "") ; Remove all valid options from var.
		If (WithNeedlesRemoved = "") ; If they were all removed...
			validOpts := "Okay."
		else { ; Some characters from the Options box were not recognized.
			OptTips := inStr(WithNeedlesRemoved, ":")? "Don't include the colons.`n":""
			OptTips .= " ;  a block text assignement to var
			(
			...Tips from AHK v1 docs...
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
			validOpts .= "Invalid Hotsring Options found.`n---> " WithNeedlesRemoved "`n" OptTips
		}
	}
	;==== Make sure hotstring box content is valid ========
	validHot := "" ; Reset to empty each time.
	If (tTriggerString = "") || (tTriggerString = myPrefix) || (tTriggerString = mySuffix) 
		validHot := "HotString box should not be empty."
	Else If InStr(tTriggerString, ":")
		validHot := "Don't include colons."
	else ; No colons, and not empty. Good. Now check for duplicates.
	{	Loop Parse, ThisFile, "`n", "`r" { ; Check line-by-line.
			If (A_Index < ACitemsStartAt) or (SubStr(trim(A_LoopField, " `t"), 1,1) != ":") 
				continue ; Will skip non-hotstring lines, so the regex isn't used as much.
			If RegExMatch(A_LoopField, "i):(?P<Opts>[^:]+)*:(?P<Trig>[^:]+)", &loo) { ; loo is "current loopfield"
				If (tTriggerString = loo.Trig) and (tMyDefaultOpts = loo.Opts) { ; full duplicate triggers
					validHotDupes := "`nDuplicate trigger string found at line " A_Index ".`n---> " A_LoopField
					Continue
				} ; No duplicates.  Look for conflicts... 
				If (InStr(loo.Trig, tTriggerString) and inStr(tMyDefaultOpts, "*") and inStr(tMyDefaultOpts, "?"))
				|| (InStr(tTriggerString, loo.Trig) and inStr(loo.Opts, "*") and  inStr(loo.Opts, "?")) { ; Word-Middle Matches
					validHotDupes .= "`nWord-Middle conflict found at line " A_Index ", where one of the strings will be nullified by the other.`n---> " A_LoopField 
					Continue
				}
				If ((loo.Trig = tTriggerString) and inStr(loo.Opts, "*") and  not inStr(loo.Opts, "?") and inStr(tMyDefaultOpts, "?") and not inStr(tMyDefaultOpts, "*"))
				|| ((loo.Trig = tTriggerString) and inStr(loo.Opts, "?") and  not inStr(loo.Opts, "*") and inStr(tMyDefaultOpts, "*") and not inStr(tMyDefaultOpts, "?")) { ; Rule out: Same word, but beginning and end opts
					validHotDupes .= "`nDuplicate trigger found at line " A_Index ", but maybe okay, because one is word-beginning and other is word-ending.`n---> " A_LoopField 
					Continue
				}
				If (inStr(loo.Opts, "*") and loo.Trig = subStr(tTriggerString, 1, strLen(loo.Trig)))
				|| (inStr(tMyDefaultOpts, "*") and tTriggerString = subStr(loo.Trig, 1, strLen(tTriggerString))) { ; Word-Beginning Matches
					validHotDupes .= "`nWord Beginning conflict found at line " A_Index ", where one of the strings is a subset of the other.  Whichever appears last will never be expanded.`n---> " A_LoopField					
					Continue
				}
				If (inStr(loo.Opts, "?") and loo.Trig = subStr(tTriggerString, -strLen(loo.Trig)))
				|| (inStr(tMyDefaultOpts, "?") and tTriggerString = subStr(loo.Trig, -strLen(tTriggerString))) { ; Word-Ending Matches
					validHotDupes .= "`nWord Ending conflict found at line " A_Index ", where one of the strings is a superset of the other.  The longer of the strings should appear before the other, in your code.`n---> " A_LoopField					
					Continue
				}
			}
			Else ; not a regex match, so go to next loop.
				continue 
		}	
		If validHotDupes != ""
			validHotDupes := SubStr(validHotDupes, 2)
		If (tMatches > 0){ ; This error message is collected separately from the loop, so both can potentially be reported. 
			validHotMisspells := "This trigger string will misspell [" tMatches "] words."
		}
		if validHotDupes and validHotMisspells
			validHot := validHotDupes "`n-" validHotMisspells ; neither is blank, so new line
		else If !validHotDupes  and !validHotMisspells ; both are blank, so no validity concerns. 
			validHot := "Okay."
		else 
		validHot := validHotDupes  validHotMisspells ; one (and only one) is blank so concantinate
	}

	;==== Make sure replacement string box content is valid ===========
	If (tReplaceString = "")
		validRep := "Replacement string box should not be empty."
	else if (SubStr(tReplaceString, 1, 1) == ":") ; If Replacement box empty, or first char is ":"
		validRep := "Don't include the colons."
	else if  (tReplaceString = tTriggerString)
		validRep := "Replacement string SAME AS Trigger string."
	else
		validRep := "Okay."
	; Concatenate the three above validity checks.
	CombinedValidMsg := "OPTIONS BOX `n-" . validOpts . "*|*HOTSTRING BOX `n-" . validHot . "*|*REPLACEMENT BOX `n-" . validRep
	Return CombinedValidMsg ; return result for use is Append or Validation functions.
} ; end of validation func

; The "Append It" function actually combines the hotsring components and 
; appends them to the script, then reloads it. 
Appendit(tMyDefaultOpts, tTriggerString, tReplaceString)
{ 	WholeStr := ""
	tMyDefaultOpts := MyDefaultOpts.text
	tTriggerString := TriggerString.text
	tReplaceString := ReplaceString.text
	; tComStr := hh['ComStr'].text ; tComStr is "text of comment string." <--- not used?
	tComStr := '' ; tComStr is "text of comment string."
	aComStr := '' ; aComStr is "auto comment string." Default to blank each time. 
	
	If (rMatches > 0) and (AutoCommentFixesAndMisspells = 1) ; AutoCom var set near top of code. 
	{ 	Misspells := ""
		Misspells := EdtTMatches.Value
		If (tMatches > 3) ; and (Misspells != "") ; More than 3 misspellings?
			Misspells := ", but misspells " . tMatches . " words !!! "
		Else If (Misspells != "") { ; any misspellings? List them, if <= 3.
		; Misspells := StrReplace(Misspells, "`n", " (), ")
			Misspells := SubStr(StrReplace(Misspells, "`n", " (), "), 1, -2) . ". "
			Misspells := ", but misspells " . Misspells
			;MsgBox("tMatches " . tMatches . "`nMisspells is:`n`n" . Misspells)
		}
		aComStr := "Fixes " . rMatches . " words " . Misspells
		aComStr := StrReplace(aComStr, "Fixes 1 words ", "Fixes 1 word ")
	}

	fopen := '' , fclose := ''
	If (chkFunc.Value = 1) and (IsMultiLine = 0) ; add function part if needed
		{
			tMyDefaultOpts := "B0X" . StrReplace(tMyDefaultOpts, "B0X", "")
			fopen := 'f("'
			fclose := '")'
		}
	
	If (ComStr.text != "") || (aComStr != "")
		tComStr := " `; " . aComStr . ComStr.text

	If InStr(tReplaceString, "`n") { ; Combine the parts into a muli-line hotstring.
		openParenth := subStr(tReplaceString, -1) = "`t"? "(RTrim0`n" : "(`n" ; If last char is Tab, use LTrim0.
		WholeStr := ":" . tMyDefaultOpts . ":" . tTriggerString . "::" . tComStr . "`n" . fopen . openParenth . tReplaceString . "`n)" . fclose
	}
	Else ; Combine the parts into a single-line hotstring.
		WholeStr := ":" . tMyDefaultOpts . ":" . tTriggerString . "::" . fopen . tReplaceString . fclose . tComStr
			
	If GetKeyState("Shift") { ; User held Shift when clicking Append Button. 
		A_Clipboard := WholeStr
		SoundBeep 800, 200
		SoundBeep 700, 300
		; MsgBox "in appendit(), clipbrd is`n" A_Clipboard
	}
	else
	{ 	FileAppend("`n" WholeStr, HotstringLibrary) ; 'n makes sure it goes on a new line.
		If (AutoEnterNewEntry = 1) ; If this user setting (at the top) is set, then call function
			ChangeActiveEditField()
		If not getKeyState("Ctrl")
			Reload() ; relaod the script so the new hotstring will be ready for use; but not if ctrl pressed.
	}
}  ; Newly added hotstrings will be way at the bottom of the ahk file.

; This function only gets called if the new AC item is a single-word fix.
; It assesses whether the text in the target document is still selected, and if trigger is unchanged,
; and if so, corrects the item in the target document. 
ChangeActiveEditField(*)
{	Send("^c") ; Copy selected text.
	Errorlevel := !ClipWait(0.3) ; Wait for clipboard to contain text.
	Global origTriggerTypo := trim(origTriggerTypo) ; Remove any whitespace.
	hasSpace := (subStr(A_Clipboard, -1) = " ")? " " : ""
	A_Clipboard := trim(A_Clipboard) ; Remove any whitespace.
	If (origTriggerTypo = A_Clipboard) and (origTriggerTypo = TriggerString.text) ; Make sure nothing has changed. 
	{	If (bb != 0) ; If the big validity message box is showing.. 
			bb.Hide() ; Hide it.
		hh.Hide() ; hide main HotStrHelper form.
		WinWaitActive(targetWindow)
		Send(ReplaceString.text hasSpace)
	}
}

; Calls the Google "Did you mean..." function below. 
hhButtonSpell(*) ; Called it "Spell" because "Spell Check" is too long.
{ tReplaceString := ReplaceString.text
	If (tReplaceString = "")
		MsgBox("Replacement Text not found.", , 4096)
	else {
		googleSugg := GoogleAutoCorrect(tReplaceString) ; Calls below function
		If (googleSugg = "")
			MsgBox("No suggestions found.", , 4096)
		Else {
			msgResult := MsgBox(googleSugg "`n`n######################`nChange Replacement Text?", "Google Suggestion", "OC 4096")
			if (msgResult = "OK") {
				ReplaceString.value := googleSugg
				goFilter()
			}
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

; Opens this file and go to the bottom so you can see your Hotstrings.
hhButtonOpen(*)
{  	If WinActive(hhFormName) 
	{	hh.Hide()
		A_Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
	}
	Try
		Run MyAhkEditorPath " "  HotstringLibrary
	Catch
		msgbox 'cannot run ' HotstringLibrary
	WinWaitActive(HotstringLibrary) ; Wait for the script to be open in text editor.
	Sleep(1000)
	Send("{Ctrl Down}{End}{Ctrl Up}{Home}") ; Navigate to the bottom.
}

; Close/hide form, clear everything, and restore clipboard contents. 
hhButtonCancel(*)
{ 	hh.Hide()
	MyDefaultOpts.value := ""
	TriggerString.value := ""
	ReplaceString.value := ""
	tArrStep := [] ; array for trigger undos
	rArrStep := [] ; array for replacement undos
	A_Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
}

GoLTrim(*) ; Trim one char from left of trigger and replacement.
{		;---- trig -----
	tText := TriggerString.value
	tArrStep.push(tText) ; <---- save history for Undo feature
	tText := subStr(tText, 2)
	TriggerString.value := tText
		; ----- repl -----
	rText := ReplaceString.value
	rArrStep.push(rText) ; <---- save history
	rText := subStr(rText, 2)
	ReplaceString.value := rText
	; -----------
	ButUndo.Enabled := true
	TriggerChanged() 
}

GoRTrim(*) ; Trim one char from right of trigger and replacement.
{		; ----- trig -----
	tText := TriggerString.value
	tArrStep.push(tText) ; <---- save history
	tText := subStr(tText, 1, strLen(tText) - 1)
	TriggerString.value := tText
		; ----- repl -----
	rText := ReplaceString.value
	rArrStep.push(rText) ; <---- save history
	rText := subStr(rText, 1, strLen(rText) - 1)
	ReplaceString.value := rText
	; -----------
	ButUndo.Enabled := true
	TriggerChanged() 
}

; Left and Right Trims are saved in Arrays.  This function removes the last one. 
GoUndo(*)
{ 	If GetKeyState("Shift") 
		GoReStart() 
	else If (tArrStep.Length > 0) and (rArrStep.Length > 0) {
		TriggerString.value := tArrStep.Pop()
		ReplaceString.value := rArrStep.Pop()
		GoFilter()
	}
	else {
		ButUndo.Enabled := false
	}
}
; ReEnters the trigger and replacement that were gotten from RegEx upon first capture.
; Clears arrays.  Has effect of "undoing" all of the changes. 
GoReStart(*)
{ 	If !OrigTrigger and !OrigReplacment
		MsgBox("Can't restart -- Nothing in memory...")
	Else {
		TriggerString.Value := OrigTrigger ; Restore original values. 
		ReplaceString.Value := OrigReplacement
		ButUndo.Enabled := false
		tArrStep := [] ; Reset arrays to nothing.
		rArrStep := []
		GoFilter()
	}
}

; Single-click of middle radio button just calls GoFilter function but 
; double-click sets button to false.  
GoRadioClick(*)
{	RadBeg.Value := 0 ; Set radios to blank, and removed hotstring options. 
	RadMid.Value := 0
	RadEnd.Value := 0
	MyDefaultOpts.text := strReplace(strReplace(MyDefaultOpts.text, "?", ""), "*", "")
	GoFilter()
}

; Filters the two lists of words at bottom of Exam Pane. 
; Mostly this is called via L/R trims, or by changing radio buttons.  
; If it is called via Exam button, then reads Options box and updates radios.
GoFilter(ViaExamButt := "No", *) ; Filter the big list of words, as needed.
{	; ====== Hotstring/Trigger ===========
	tFind := Trim(TriggerString.Value)
	If !tFind
		tFind := " " ; prevents error if tFind is blank.
	tFilt := ''
	Global tMatches := 0 ; Global so I can read it in the Validation() function.
	MyOpts := MyDefaultOpts.text 

	If (ViaExamButt = "Yes") { ; Read opts box, change radios as needed.
		If  inStr(MyOpts, "*") and  inStr(MyOpts, "?")
			RadMid.value := 1
		Else if  inStr(MyOpts, "*")
			RadBeg.value := 1
		Else if  inStr(MyOpts, "?")
			RadEnd.value := 1
		Else {
			RadMid.value := 0
			RadBeg.value := 0
			RadEnd.value := 0
		}
	}

	Loop Read, WordListPath ; Compare with the big list of words and find matches.
	{
		If InStr(A_LoopReadLine, tFind) {
			IF (RadMid.value = 1) {
				tFilt .= A_LoopReadLine '`n'
				tMatches++
			}
			Else If (RadEnd.value = 1) {
				If InStr(SubStr(A_LoopReadLine, -StrLen(tFind)), tFind) {
					tFilt .= A_LoopReadLine '`n'
					tMatches++
				}
			}
			else If (RadBeg.value = 1) {
				If InStr(SubStr(A_LoopReadLine, 1, StrLen(tFind)), tFind) {
					tFilt .= A_LoopReadLine '`n'
					tMatches++
				}
			}
			Else {
				If (A_LoopReadLine = tFind) {
					tFilt := tFind
					tMatches++
				}
			}
		}
	}

	IF (RadMid.value = 1) {
		If not inStr(MyOpts, "*")
			MyOpts := MyOpts . "*"
		If not inStr(MyOpts, "?")
			MyOpts := MyOpts . "?"
	}
	Else If (RadEnd.value = 1) {
		If not inStr(MyOpts, "?")
			MyOpts := MyOpts . "?"
			MyOpts := StrReplace(MyOpts, "*")
	}
	else If (RadBeg.value = 1) {
		If not inStr(MyOpts, "*")
			MyOpts := MyOpts . "*"
			MyOpts := StrReplace(MyOpts, "?")
	}
	MyDefaultOpts.text := MyOpts

	EdtTMatches.Value := tFilt
	TxtTLable.Text := "Misspells [" . tMatches . "]"
	
	If (tMatches > 0) { 
		TrigLbl.Text := "Misspells [" . tMatches . "] words" ; Change Trig Str Label to show warning. 
		TrigLbl.SetFont("cRed")
	}
	If (tMatches = 0) {
		TrigLbl.Text := "No Misspellings found." ; Change Trig Str Label to NO LONGER show warning. 
		TrigLbl.SetFont(FontColor) ; reset color of Label, incase it's red. 
	}

	; ====== Replacement/Expansion text ==========
	rFind := Trim(ReplaceString.Value, "`n`t ")
		If !rFind
		rFind := " " ; prevents error if rFind is blank.
	rFilt := ''
	Global rMatches := 0
	
	Loop Read WordListPath  ; Compare with the big list of words and find matches.
	{
		If InStr(A_LoopReadLine, rFind) {
			IF (RadMid.value = 1) { 
				rFilt .= A_LoopReadLine '`n'

				rMatches++
			}
			Else If (RadEnd.value = 1) {
				If InStr(SubStr(A_LoopReadLine, -StrLen(rFind)), rFind) {
					rFilt .= A_LoopReadLine '`n'
					rMatches++
				}
			}
			else If (RadBeg.value = 1) { ; 'Beg' radio.
				If InStr(SubStr(A_LoopReadLine, 1, StrLen(rFind)), rFind) {
					rFilt .= A_LoopReadLine '`n'
					rMatches++
				}
			}
			Else {
				If (A_LoopReadLine = rFind) {
					rFilt := rFind
					rMatches++
				}
			}
		}
	}
	EdtRMatches.Value := rFilt
	TxtRLable.Text := "Fixes [" . rMatches . "]"
}


; ################ END of HH2 ###########################################################
; ...............................QQQ.....................QQQQQQ.....QQQ.........QQQ......
; ...............................QQQ.....................QQQQQ......QQQ.........QQQ......
; ...............................QQQ....................QQQQ........QQQ.........QQQ......
; ...............................QQQ....................QQQQ........QQQ.........QQQ......
; ...............................QQQ....................QQQQ........QQQ.........QQQ......
; ..QQQQQQ....QQQQQQQQQ....QQQQQQQQQ..........QQQQQQ..QQQQQQQQ......QQQQQQQQQ...QQQQQQQQQ
; .QQQQQQQQ...QQQQQQQQQQ..QQQQQQQQQQ.........QQQQQQQQ.QQQQQQQQ......QQQQQQQQQQ..QQQQQQQQQ
; QQQQ.QQQQQ..QQQQQ.QQQQ..QQQQ.QQQQQ........QQQQ.QQQQQ..QQQQ........QQQQQ.QQQQ..QQQQQ.QQQ
; QQQ....QQQ..QQQQ...QQQ.QQQQ...QQQQ.......QQQQ....QQQ..QQQQ........QQQQ...QQQ..QQQQ...QQ
; QQQ....QQQ..QQQ....QQQ.QQQQ...QQQQ.......QQQQ....QQQQ.QQQQ........QQQ....QQQ..QQQ....QQ
; QQQ....QQQQ.QQQ....QQQ.QQQ.....QQQ.......QQQ.....QQQQ.QQQQ........QQQ....QQQ..QQQ....QQ
; QQQQQQQQQQQ.QQQ....QQQ.QQQ.....QQQ.......QQQ.....QQQQ.QQQQ........QQQ....QQQ..QQQ....QQ
; QQQQQQQQQQQ.QQQ....QQQ.QQQ.....QQQ.......QQQ.....QQQQ.QQQQ........QQQ....QQQ..QQQ....QQ
; QQ..........QQQ....QQQ.QQQ.....QQQ.......QQQ.....QQQQ.QQQQ........QQQ....QQQ..QQQ....QQ
; QQQ.........QQQ....QQQ.QQQQ...QQQQ.......QQQQ....QQQQ.QQQQ........QQQ....QQQ..QQQ....QQ
; QQQ....QQQ..QQQ....QQQ.QQQQ...QQQQ.......QQQQ....QQQ..QQQQ........QQQ....QQQ..QQQ....QQ
; QQQQ..QQQQ..QQQ....QQQ..QQQQ.QQQQQ........QQQQ.QQQQQ..QQQQ........QQQ....QQQ..QQQ....QQ
; .QQQQQQQQ...QQQ....QQQ...QQQQQQQQQ.........QQQQQQQQ...QQQQ........QQQ....QQQ..QQQ....QQ
; ..QQQQQQ....QQQ....QQQ....QQQQQQQQ..........QQQQQQ....QQQQ........QQQ....QQQ..QQQ....QQ
; #######################################################################################

;====== Change icons here if desired ===========================================
TraySetIcon(A_ScriptDir . "\Icons\AhkBluePsicon.ico")
acMenu := A_TrayMenu ; For convenience.
acMenu.Delete
acMenu.Add("Edit This Script", EditThisScript)
acMenu.SetIcon("Edit This Script", "Icons\edit-Blue.ico")
acMenu.Add("Hotstring Library", hhButtonOpen) ; <--- Calls a function that is in the hh2 code.
acMenu.SetIcon("Hotstring Library", "Icons\library-Blue.ico")

acMenu.Add("Run Printer Tool", PrinterTool)
acMenu.SetIcon("Run Printer Tool", "Icons\printer-Blue.ico")
; acMenu.Add("DateTool - H", MCRemake)
; acMenu.SetIcon("DateTool - H", "Icons\calendar-Blue.ico")
acMenu.Add("System Up Time", UpTime)
acMenu.SetIcon("System Up Time", "Icons\clock-Blue.ico")
acMenu.Add("Reload Script", (*) => Reload())
acMenu.SetIcon("Reload Script", "icons/repeat-Blue.ico")
acMenu.Add("List Lines Debug", (*) => ListLines())
acMenu.SetIcon("List Lines Debug", "icons/ListLines-Blue.ico")
acMenu.Add("Exit Script", (*) => ExitApp())
acMenu.SetIcon("Exit Script", "icons/exit-Blue.ico")
acMenu.SetColor("Silver")

;===============================================================================
; Startup anouncement.  Also beeps whenever HotString Helper appends an item.
SoundBeep(900, 250)
SoundBeep(1100, 200)

;===============================================================================
#HotIf WinActive(NameOfThisFile,) || WinActive(HotstringLibrary) ; Can't use A_Var here.
^s:: ; When you press Ctrl+s, this scriptlet will save the file, then reload it to RAM.
{
	Send("^s") ; Save me.
	MsgBox("Reloading...", "", "T0.3")
	Sleep(250)
	Reload() ; Reload me too.
	MsgBox("I'm reloaded.") ; Pops up then disappears super-quickly because of the reload.
}
#HotIf

;===============================================================================
; Open this script in VSCode.
^+e::
EditThisScript(*)
{	Try
		Run MyAhkEditorPath " "  NameOfThisFile
	Catch
		msgbox 'cannot run ' NameOfThisFile
}


; ==============================================================================
; UPTIME 
!+u::
UpTime(*)
{ MsgBox("UpTime is:`n" . Uptime(A_TickCount))
	Uptime(ms) {
		VarSetStrCapacity(&b, 256) ; V1toV2: if 'b' is NOT a UTF-16 string, use 'b := Buffer(256)'
		;    DllCall("GetDurationFormat","uint",2048,"uint",0,"ptr",0,"int64",ms*10000,"wstr"," d 'days, 'h' hours, 'm' minutes, 's' seconds'", "wstr",b,"int",256)
		DllCall("GetDurationFormat", "uint", 2048, "uint", 0, "ptr", 0, "int64", ms * 10000, "wstr", " d 'days, 'h' hrs, 'm' mins'", "wstr", b, "int", 256)
		b := StrReplace(b, " 0 days,")
		b := StrReplace(b, " 0 hrs,")
		b := StrReplace(b, " 0 mins,")
		b := StrReplace(b, " 1 days,", "1 day,")
		b := StrReplace(b, " 1 hrs,", " 1 hr,")
		b := StrReplace(b, " 1 mins,", " 1 min,")
		; b := StrReplace(b," 1 seconds"," 1 second")
		return b
	}
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
			Hotstring(":*?CXB0Z:" char1 char2, fix.Bind(char1, char2))
		}
	}
	HotIf
	; Third letter is checked using InputHook.
	fix(char1, char2, *) {
		ih := InputHook("V I101 L1 T.3")
		ih.OnEnd := OnEnd
		ih.Start()
		OnEnd(ih) {
			char3 := ih.Input
			if (char3 ~= "[A-Z]")  ; If char is UPPERcase alpha.
				Hotstring "Reset"
			else if (char3 ~= "[a-z]")  ; If char is lowercase alpha.
			|| (char3 = A_Space && char1 char2 ~= "OF|TO|IN|IT|IS|AS|AT|WE|HE|BY|ON|BE|NO") ; <--- Remove this line to prevent correction of those 2-letter words.
			{	SendInput("{BS 2}" StrLower(char2) char3)
				SoundBeep(800, 80) ; Case fix announcent. 
			}
		}
	}
}

;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
;  AUto-COrrect TWo COnsecutive CApitals
;  Table of Contents (this)
;  f() AutoCorrect hotstring function
;  KeepText() cacher function
;  Logger function
;  InputBuffer Class by Descolada
;  Mini report generator function
;  The actual HOTSTRING LIBRARY has been moved to "HotstringLib.ahk" and is #Included above. 
;------------------------------------------------------------------------------
;  Multi-fix items are commented with " ; Fixes N misspellings"
;  Warning: several items break obscure words.  These are commented with "Misspells xxx" with an explanation. 
;  The Replacment nullifiers attempt to nullify the potential misspellings. 
;  As of Feb 2024, ~5k items, >328k potential fixes.  Ctrl+F3 for Fix counter
;  Number of "potential fixes" based on WordWeb app, and varies greatly by word list used. 
;------------------------------------------------------------------------------

;:B0XC:smith::f("Smith") ; Fixes 2 words , but misspells smi. 

;========= AUTOCORRECTION LOGGER OPTIONS ======================================= 
saveIntervalMinutes := 20     ; Collect the log items in RAM, then save to disc this often. 
IntervalsBeforeStopping := 2  ; Stop collecting, if no new pattern matches for this many intervals.
; (Script will automatically restart the log intervals next time there's a match.)

!+F3:: MsgBox(lastTrigger, "Trigger", 0) ; Shift+Alt+F3: Peek at last trigger.
;!+l::Run("AutoCorrectsLog.ahk") ; Shift+Alt+L: View/Run log of all autocorrections. (Disabled hotkey because I never use it.) 

; Mikeyww's idea to use a one-line function call. Cool.
; www.autohotkey.com/boards/viewtopic.php?f=76&t=120745
lastTrigger := "No triggers logged yet." ; in case no autocorrects have been made
f(replace := "") ; All the one-line "f" autocorrects call this f(unction).
{	static HSInputBuffer := InputBuffer()
	HSInputBuffer.Start()
	trigger := A_ThisHotkey, endchar := A_EndChar
	Global lastTrigger := StrReplace(trigger, "B0X", "") "::" replace ; set 'lastTrigger' before removing options and colons.
	trigger := SubStr(trigger, inStr(trigger, ":",,,2)+1) ; use everything to right of 2nd colon. 
	TrigLen := StrLen(trigger) + StrLen(endchar) ; determine number of backspaces needed.
	; Rarify: Only remove and replace rightmost necessary chars.  
	trigL := StrSplit(trigger)
	replL := StrSplit(replace)
	endCh := StrLen(endchar)
	Global ignorLen := 0
	Loop Min(trigL.Length, replL.Length) ; find matching left substring.
	{	If (trigL[A_Index] == replL[A_Index]) ; The double equal (==) makes it case-sensitive. 
			ignorLen++
		else break
	}
	replace := SubStr(replace, (ignorLen+1))
	SendInput("{BS " . (TrigLen - ignorLen) . "}" replace StrReplace(endchar, "!", "{!}")) ; Type replacemement and endchar. 
	replace := "" ; Reset to blank string.
	HSInputBuffer.Stop()
	SoundBeep(900, 60) ; Notification of replacement.
	Global KeepForLog := LastTrigger  
	SetTimer(keepText, -1)
}

logIsRunning := 0, savedUpText := '', intervalCounter := 0 ; Initialize the counter
saveIntervalMinutes := saveIntervalMinutes*60*1000 ; convert to miliseconds.

#MaxThreadsPerHotkey 5 ; Allow up to 5 instances of the function.
; There's no point running the logger if no text has been saved up...  
; So don't run timer when script starts.  Run it when logging starts. 
keepText(*) ; Automatically logs if an autocorrect happens, and if I press Backspace within X seconds. 
{ 	EndKeys := "{Backspace}"
	global lih := InputHook("B V I1 E T1", EndKeys) ; "logger input hook." T is time-out. T1 = 1 second.
	lih.Start(), lih.Wait()
	;msgbox lih.EndKey
	hyphen := (lih.EndKey = "Backspace")?  " << " : " -- "
	global savedUpText .= "`n" A_YYYY "-" A_MM "-" A_DD hyphen KeepForLog
	global intervalCounter := 0  	; Reset the counter since we're adding new text
	If logIsRunning = 0  			; only start the timer it it is not already running.
		setTimer Appender, saveIntervalMinutes  	; call function every X minutes.
}
#MaxThreadsPerHotkey 1

; Gets called by timer, or by onExit.
Appender(*) 
{	FileAppend(savedUpText, "AutoCorrectsLog.ahk")
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

OnExit Appender ; Also append one more time on exit, incase we are in the middle of on interval. 

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

class InputBuffer {
    Buffer := [], SendLevel := A_SendLevel + 2, ActiveCount := 0, IsReleasing := 0
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
        sent := [], this.IsReleasing := 1
		; Theoretically the user can still input keystrokes between ih.Stop() and Send, in which case
        ; they would get interspersed with Send. So try to send all keystrokes, then check if any more 
        ; were added to the buffer and send those as well until the buffer is emptied. 
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
} ; *End of InputBuffer Class

;###############################################
; Number of "potential fixes" based on WordWeb app, and varies greatly by word list used. 
^F3:: ; Ctrl+F3: Report information about the autocorrect items.
StringAndFixReport(*)
{	ThisFile := FileRead(HotstringLibrary)
	thisOptions := '', regulars := 0, begins := 0, middles := 0, ends := 0, fixes := 0, entries := 0
	Loop Parse ThisFile, '`n'
	{	If SubStr(Trim(A_LoopField),1,1) != ':'
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
		If RegExMatch(A_LoopField, 'Fixes\h*\K\d+', &fn) ; Need a regex for this... 
			fixes += fn[]
	}
	MsgBox( '   Totals`n==========================='
	'`n    Regular Autocorrects:`t' numberFormat(regulars)
	'`n    Word Beginnings:`t`t' numberFormat(begins)
	'`n    Word Middles:`t`t' numberFormat(middles)
	'`n    Word Ends:`t`t' numberFormat(ends)
	'`n==========================='
	'`n   Total Entries:`t`t' numberFormat(entries)
	'`n   Potential Fixes:`t`t' numberFormat(fixes) 
	, 'Report for ' HotstringLibrary, 64 + 4096  ; Icon Asterisk (info)	64; System Modal (always on top) 4096
	)
	numberFormat(num) ; Function to format a number with commas (by ChatGPT4)
	{	global
		Loop 
		{	oldnum := num
			num := RegExReplace(num, "(\d)(\d{3}(\,|$))", "$1,$2") ; search for number patterns and insert commas
			if (num == oldnum) ; If the number doesn't change, exit the loop
				break
		}
		return num
	}
}
;###############################################
