;===============================================================================
; CONFLICTING STRING LOCATOR 
;                    a.k.a. DEAD STRING FINDER
; Author: kunkel321 
; Tool used: Claude AI
; Updated: 11-15-2025
;===============================================================================
; Part of the AutoCorrect2 Suite of Tools.  Get new versions from 
; github.com/kunkel321/autocorrect2
; The Dead String Finder expects to find acSettings.ini, but your hotstrings don't
; have to be wrapped in f() functions. 
;===============================================================================

#SingleInstance
#Requires AutoHotkey v2+

^Esc::ExitApp ; Emergency kill switch

settingsFile := "..\Data\acSettings.ini"
if !FileExist(settingsFile) {
	MsgBox(settingsFile " was not found. Please run AutoCorrect2 first.")
	ExitApp
}

targetFile := "..\Core\" IniRead(settingsFile, "Files", "HotstringLibrary", "..\Core\HotstringLib.ahk")
fullList := FileRead(targetFile)

; Find line range to scan
ACitemsStartAt := 0
ACitemsEndAt := 0
allLines := StrSplit(fullList, "`n")
loop allLines.Length {
	line := allLines[A_Index]
	If InStr(line, "ACitemsStartAt := A_LineNumber + 3")
		ACitemsStartAt := A_Index + 3
	If InStr(line, "ACitemsEndAt := A_LineNumber - 3")
		ACitemsEndAt := A_Index - 3
}

StartTime := A_TickCount
DupReport := "", BegReport := "", MidReport := "", EndReport := "", Count := 0
Separator := "`n---------------------------------------`n"
hsRegex := "i):(?P<Opts>[^:]+)*:(?P<Trig>[^:]+)"

; ===== PHASE 1: SINGLE-PASS EXTRACTION =====
; Parse ALL lines once, extract and cache hotstring parts from regex matches
TotalLines := allLines.Length
hotstringData := []  ; Array to store: {opts, trig, line, index}

rep := Gui()
rep.Opt("-MinimizeBox +alwaysOnTop +Owner")
MyProgress := rep.Add("Progress", "w400 h30 cGreen Range0-" TotalLines, "0")
rep.Title := "Extracting hotstring data..."
rep.Show()

loop TotalLines {
	If GetKeyState("Esc") {
		rep.Destroy()
		ExitApp
	}
	
	MyProgress.Value := A_Index
	rep.Title := "Extracting: " A_Index "/" TotalLines
	
	lineNum := A_Index
	line := allLines[lineNum]
	
	; Skip if outside range or doesn't start with ":"
	if (lineNum < ACitemsStartAt) || (lineNum > ACitemsEndAt) || (SubStr(Trim(line, " `t"), 1, 1) != ":")
		Continue
	
	; Parse regex once per line
	if RegexMatch(line, hsRegex, &match) {
		hotstringData.Push({
			opts: match.Opts,
			trig: match.Trig,
			line: line,
			index: lineNum
		})
	}
}

; ===== PHASE 2: COMPARISON =====
; Only compare each pair once using upper-triangle approach
rep.Title := "Comparing hotstrings..."
itemCount := hotstringData.Length
totalExpectedComparisons := itemCount * (itemCount - 1) / 2  ; Total pairs to compare
MyProgress.Opt("Range0-100") 

loop itemCount {
	If GetKeyState("Esc") {
		rep.Destroy()
		ExitApp
	}
	
	oIdx := A_Index
	oData := hotstringData[oIdx]
	
	; Update progress based on outer loop iteration
	; Progress = how many comparisons done / total comparisons
	; After oIdx iterations: sum from i=0 to oIdx-1 of (itemCount - i) comparisons
	comparisonsDone := oIdx * itemCount - (oIdx * (oIdx - 1)) / 2
	progressPercent := Round((comparisonsDone / totalExpectedComparisons) * 100)
	
	MyProgress.Value := progressPercent
	rep.Title := "Comparing: " progressPercent "% [Esc to stop]"
	
	; Inner loop starts at oIdx+1 to avoid duplicate comparisons
	loop itemCount - oIdx {
		iIdx := oIdx + A_Index
		iData := hotstringData[iIdx]
		
		; ===== CONFLICT DETECTION LOGIC =====
		
		; Check 1: Exact duplicates
		if (oData.trig = iData.trig) && (oData.opts = iData.opts) {
			DupReport .= Separator
			DupReport .= "Line: " oData.index "`t`t" oData.trig (StrLen(oData.trig)<8?"`t`t":"`t") oData.line "`n"
			DupReport .= "-and: " iData.index "`t`t" iData.trig (StrLen(iData.trig)<8?"`t`t":"`t") iData.line "`n"
			Count++
		}
		; Check 2: Word-Middle conflicts
		Else If (InStr(iData.trig, oData.trig) && InStr(oData.opts, "*") && InStr(oData.opts, "?"))
		|| (InStr(oData.trig, iData.trig) && InStr(iData.opts, "*") && InStr(iData.opts, "?")) {
			MidReport .= Separator
			MidReport .= "Line: " oData.index "`t" StrReplace(StrReplace(oData.opts, "B0", ""),"X", "") "`t" oData.trig (StrLen(oData.trig)<8?"`t`t":"`t") oData.line "`n"
			MidReport .= "-and: " iData.index "`t" StrReplace(StrReplace(iData.opts, "B0", ""),"X", "") "`t" iData.trig (StrLen(iData.trig)<8?"`t`t":"`t") iData.line "`n"
			Count++
		}
		; Check 3: Skip if same trigger with beginning+ending (these can coexist)
		Else If ((iData.trig = oData.trig) && InStr(iData.opts, "*") && InStr(oData.opts, "?"))
		|| ((oData.trig = iData.trig) && InStr(iData.opts, "?") && InStr(oData.opts, "*")) {
			Continue
		}
		; Check 4: Word-Beginning conflicts
		Else If (InStr(iData.opts, "*") && iData.trig = SubStr(oData.trig, 1, StrLen(iData.trig)))
		|| (InStr(oData.opts, "*") && oData.trig = SubStr(iData.trig, 1, StrLen(oData.trig))) {
			BegReport .= Separator
			BegReport .= "Line: " oData.index "`t" StrReplace(StrReplace(oData.opts, "B0", ""),"X", "") "`t" oData.trig (StrLen(oData.trig)<8?"`t`t":"`t") oData.line "`n"
			BegReport .= "-and: " iData.index "`t" StrReplace(StrReplace(iData.opts, "B0", ""),"X", "") "`t" iData.trig (StrLen(iData.trig)<8?"`t`t":"`t") iData.line "`n"
			Count++
		}
		; Check 5: Word-Ending conflicts
		Else If (InStr(iData.opts, "?") && iData.trig = SubStr(oData.trig, -StrLen(iData.trig)))
		|| (InStr(oData.opts, "?") && oData.trig = SubStr(iData.trig, -StrLen(oData.trig))) {
			EndReport .= Separator
			EndReport .= "Line: " oData.index "`t" StrReplace(StrReplace(oData.opts, "B0", ""),"X", "") "`t" oData.trig (StrLen(oData.trig)<8?"`t`t":"`t") oData.line "`n"
			EndReport .= "-and: " iData.index "`t" StrReplace(StrReplace(iData.opts, "B0", ""),"X", "") "`t" iData.trig (StrLen(iData.trig)<8?"`t`t":"`t") iData.line "`n"
			Count++
		}
	}
}

; Build final report
If (DupReport != "")
	DupReport := "Duplicates:" DupReport "`n"
If (BegReport != "")
	BegReport := "Beginnings:" BegReport "`n"
If (MidReport != "")
	MidReport := "Middles:" MidReport "`n"
If (EndReport != "")
	EndReport := "Endings:" EndReport "`n"

ElapsedTime := (A_TickCount - StartTime) / 1000
ElapsedTime := "Found " Count " item pairs in " Round(ElapsedTime / 60) "-min " Round(Mod(ElapsedTime, 60)) "-sec."

rep.Destroy()

FullReport := DupReport BegReport MidReport EndReport
If FullReport = ""
	FullReport := "No duplicate or conflicting hotstring pairs located."
FullReport := ElapsedTime "`nLine`t`tOpt`tTrigger`t`tFull item`n=================================`n" FullReport

Location := "..\Debug\Conflict_Report" FormatTime(A_Now, "_MMM_dd_hh_mm") ".txt"
FileAppend FullReport, Location
Sleep 1000
Run Location

SoundBeep 1800, 700
SoundBeep 1200, 200
ExitApp