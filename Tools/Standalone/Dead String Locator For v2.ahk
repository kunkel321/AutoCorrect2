#SingleInstance
#Requires AutoHotkey v2+

;===============================================================================
; By kunkel321.  Updated: 9-28-2025
; A script to find duplicate and conflicting beg/mid/end hotstring triggers. 
; It should work with hotstrings that are formatted with f(), _HS(), or plain AHK hotstrings. 
; Note: When correcting/culling your autocorrect library, remember that sometimes conflicting
; autocorrect items can peacefully coexist... Read more in manual, attached here
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=120220&p=559727#p559328
; Warning: Sloooww script....  Takes about 6 minutes for 5k lines of autocorrect items. 
;===============================================================================

ACitemsEndAt := 99999 ; <--- Optional:  Stop comparing after this line number. In case
; the user wants to skip the non-English accented words at the end. 
; ACitemsEndAt := 6593
targetFile := "..\..\Core\HotstringLib.ahk"  ; <--- Your Hotstring Library file path here.
^Esc::ExitApp ; <----- Emergency kill switch is Ctrl+Esc.  ; hide
;===============================================================================

Try fullList := Fileread(targetFile)
Catch {
	MsgBox '====ERROR====`n`nThe file (' targetFile ')`nwas not found.`n`nRemember to set the variable`nat the top of the script. Now exiting.'
	ExitApp
}

; Pre-scan to find beginning of items to scan. 
; lines at top of code.  Recommend not scanning 'nullifier' items, 'don't sort' items, 
; nor '#HotIf' items.  (Hopefully those are all at the top, above your main list.) 
ACitemsStartAt := 0
For line in StrSplit(fullList, "`n")
	If InStr(line, "ACitemsStartAt := A_LineNumber + 3")
		ACitemsStartAt := A_Index + 3 ; <--- "AutoCorrect Items Start At this line number."  Skip this many 

StartTime := A_TickCount 
Opts:= "", Trig := ""
DupReport := "", BegReport := "", MidReport := "", EndReport := "", Count := 0
Separator := "`n---------------------------------------`n"
hsRegex := "i):(?P<Opts>[^:]+)*:(?P<Trig>[^:]+)" ; part of andymbody's regex

TotalLines := StrSplit(fullList, "`n").Length ; Determines number of lines for Prog Bar range.
rep := Gui()
rep.Opt("-MinimizeBox +alwaysOnTop +Owner")
MyProgress := rep.Add("Progress", "w400 h30 cGreen Range0-" . TotalLines, "0")
rep.Title := MyProgress.Value
rep.Title := "Lines of file remaining: "
rep.Show()

loop parse fullList, "`n" {
	MyProgress.Value += 1
	rep.Title := "Lines of file remaining: " (TotalLines - MyProgress.Value) "... Press Ctrl+Esc to Cancel" ; For progress bar.
	fullList := strReplace(fullList, A_LoopField, "xxxxxx",,,1) ; Redact the oLoop item we just checked, so we don't compare it again in a future inner loop.
	If (A_Index < ACitemsStartAt) or (A_Index > ACitemsEndAt) or (SubStr(trim(A_LoopField, " `t"), 1,1) != ":") 
		Continue ; Skip if line number is too high/low, or line doesn't start with ":".  Ignore leading whitespace. 
	oLoop :=  A_LoopField ; "o" for "outter"
	oIdx := A_Index
	if regexMatch(oLoop, hsRegex, &o) {
		loop parse fullList, "`n" {
			If (A_Index < ACitemsStartAt) or (A_Index > ACitemsEndAt) or (SubStr(trim(A_LoopField, " `t"), 1,1) != ":") 
				Continue ; Skip if line number is too high/low, or line doesn't start with ":".  Ignore leading whitespace. 
			iLoop :=  A_LoopField ; "i" for "inner"
			iIdx := A_Index
			If regexMatch(iLoop, hsRegex, &i) {
			;msgBox o.Opts " " o.Trig "`n---------`n" i.Opts " " i.Trig 
				If (o.Trig = i.Trig) and (o.Opts = i.Opts) { ; Duplicates
					DupReport .= Separator
					DupReport .= "Line: " oIdx "`t`t" o.Trig (strLen(o.Trig)<8?"`t`t":"`t") oLoop "`n"
					DupReport .= "-and: " iIdx "`t`t" i.Trig (strLen(i.Trig)<8?"`t`t":"`t") iLoop "`n"
					Count++
				}
				Else If (InStr(i.Trig, o.Trig) and inStr(o.Opts, "*") and inStr(o.Opts, "?"))
				|| (InStr(o.Trig, i.Trig) and inStr(i.Opts, "*") and inStr(i.Opts, "?")) { ; Word-Middle Matches
					MidReport .= Separator
					MidReport .= "Line: " oIdx "`t" strReplace(strReplace(o.Opts, "B0", ""),"X", "") "`t" o.Trig (strLen(o.Trig)<8?"`t`t":"`t") oLoop "`n"
					MidReport .= "-and: " iIdx "`t" strReplace(strReplace(i.Opts, "B0", ""),"X", "") "`t" i.Trig  (strLen(i.Trig)<8?"`t`t":"`t") iLoop "`n"
					Count++
				}
				Else If ((i.Trig = o.Trig) and inStr(i.Opts, "*") and inStr(o.Opts, "?"))
				|| ((o.Trig = i.Trig) and inStr(i.Opts, "?") and inStr(o.Opts, "*")) ; Rule out: Same word, but beginning and end opts
					Continue
				Else If (inStr(i.Opts, "*") and i.Trig = subStr(o.Trig, 1, strLen(i.Trig)))
				|| (inStr(o.Opts, "*") and o.Trig = subStr(i.Trig, 1, strLen(o.Trig))) { ; Word-Beginning Matches
					BegReport .= Separator
					BegReport .= "Line: " oIdx "`t" strReplace(strReplace(o.Opts, "B0", ""),"X", "") "`t" o.Trig (strLen(o.Trig)<8?"`t`t":"`t") oLoop "`n"
					BegReport .= "-and: " iIdx "`t" strReplace(strReplace(i.Opts, "B0", ""),"X", "") "`t" i.Trig  (strLen(i.Trig)<8?"`t`t":"`t") iLoop "`n"
					Count++
				}
				Else If (inStr(i.Opts, "?") and i.Trig = subStr(o.Trig, -strLen(i.Trig)))
				|| (inStr(o.Opts, "?") and o.Trig = subStr(i.Trig, -strLen(o.Trig))) { ; Word-Ending Matches
					EndReport .= Separator
					EndReport .= "Line: " oIdx "`t" strReplace(strReplace(o.Opts, "B0", ""),"X", "") "`t" o.Trig (strLen(o.Trig)<8?"`t`t":"`t") oLoop "`n"
					EndReport .= "-and: " iIdx "`t" strReplace(strReplace(i.Opts, "B0", ""),"X", "") "`t" i.Trig  (strLen(i.Trig)<8?"`t`t":"`t") iLoop "`n"
					Count++
				}
			}
			Else ; not a regex match, so go to next loop.
				continue 
		}
	} 
	;msgBox fullList
}

If (DupReport != "") ; Create headings only for needed parts. 
	DupReport := "Duplicates:" DupReport "`n"
If (BegReport != "")
	BegReport := "Beginnings:" BegReport "`n"
If (MidReport != "")
	MidReport := "Middles:" MidReport "`n"
If (EndReport != "")
	EndReport := "Endings:" EndReport "`n"

ElapsedTime := (A_TickCount - StartTime) / 1000 ; Calculate and format time taken. 
ElapsedTime := "Found " Count " item pairs in " Round(ElapsedTime / 60) "-min " Round(mod(ElapsedTime, 60)) "-sec."

rep.Destroy() ; Remove progress bar.

FullReport := DupReport BegReport MidReport EndReport 
If FullReport = ""
	FullReport := "No duplicate or conflicting hotstring pairs located."
FullReport := ElapsedTime "`nLine`t`tOpt`tTrigger`t`tFull item`n=================================`n" FullReport
Location := "..\..\Data\Conflict_Report" FormatTime(A_Now, "_MMM_dd_hh_mm") ".txt"
FileAppend FullReport, Location ; Save to text file, then open the file. 
sleep 1000
Run Location
; msgbox FullReport

SoundBeep 1800, 700
SoundBeep 1200, 200
ExitApp