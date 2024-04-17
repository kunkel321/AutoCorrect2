#SingleInstance
#Requires AutoHotkey v2+
; A script to find duplicate hotstrings that are in one file but not another. 
; Intended for updating AutoHotkey scripts.  kunkel321 2-28-2024.
; Please ensure that is it pointing to two valid files. 
; The "mainFile" is the file that you plan to use--it is your new AutoCorrect file.
; The "extraFile" is a different version of your file, that might have new custom hotstrings
; added, that are not in the new mainFile. 

mainFile := "D:\AutoHotkey\MasterScript\MasterScript.ahk"  ; <--- Your AutoCorrect.ahk file path here.
extraFile := "D:\AutoHotkey\MasterScript\MasterScriptPartialTemp.ahk" 

^Esc::ExitApp ; <----- Emergency kill switch is Ctrl+Esc. 

Try fullList := Fileread(mainFile) ; Make sure file exists and save contents for variable. 
Catch {
	MsgBox '====ERROR====`n`nThe file (' mainFile ')`nwas not found.`n`nRemember to set the three variables`nat the top of the script. Now exiting.'
	ExitApp
}

Try extraList := Fileread(extraFile) ; Make sure file exists and save contents for variable. 
Catch {
	MsgBox '====ERROR====`n`nThe file (' extraFile ')`nwas not found.`n`nRemember to set the three variables`nat the top of the script. Now exiting.'
	ExitApp
}

StartTime := A_TickCount 
Opts:= "", Trig := ""
DupReport := "", Count := 0

TotalLines := StrSplit(fullList, "`n").Length ; Determines number of lines for Prog Bar range.
rep := Gui()
rep.Opt("-MinimizeBox +alwaysOnTop +Owner")
MyProgress := rep.Add("Progress", "w400 h30 cGreen Range0-" . TotalLines, "0")
rep.Title := MyProgress.Value
rep.Title := "Lines of file remaining: "
rep.Show()

; Loop through Main File contents, then remove any matching lines from the Extra File contents. 
loop parse fullList, "`n" { 
	MyProgress.Value += 1
	rep.Title := "Lines of file remaining: " (TotalLines - MyProgress.Value) "... Press Ctrl+Esc to Cancel" ; For progress bar.
	extraList := strReplace(extraList, A_LoopField, "`nxxxxxx",,,1) ; Remove the item because it exists in both files. 
}

; Loop through the Extra Files, and extract anything that wasn't replaced with "xxxxxx."
loop parse extraList, "`n" {
	If  (SubStr(trim(A_LoopField, " `t"), 1,1) = ":") ; Only include lines starting with ":"
	{	DupReport .= A_LoopField "`n"
		Count++
	}
}

ElapsedTime := (A_TickCount - StartTime) / 1000 ; Calculate and format time taken. 
ElapsedTime := "Found " Count " unique items in " Round(ElapsedTime / 60) "-min " Round(mod(ElapsedTime, 60)) "-sec."

rep.Destroy() ; Remove progress bar.

FullReport := DupReport
If FullReport = ""
	FullReport := "No unique hotstrings found in " extraFile "."
FullReport := ElapsedTime "`n=================================`n" FullReport
Location := A_ScriptDir "\Uniques_Report" FormatTime(A_Now, "_MMM_dd_hh_mm") ".txt"
FileAppend FullReport, Location ; Save to text file, then open the file. 
sleep 250
Run Location

SoundBeep 1800, 700
SoundBeep 1200, 200
ExitApp