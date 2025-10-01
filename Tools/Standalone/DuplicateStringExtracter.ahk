#SingleInstance
#Requires AutoHotkey v2+

; Intended for updating AutoHotkey scripts.  kunkel321 9-28-2025 
; A script to find duplicate hotstrings that are in one file but not another. 
; Please ensure that is it pointing to two valid files. 
; The "mainFile" is the file that you plan to use--it is your new AutoCorrect file.
; The "extraFile" is a different version of your file, that might have new custom hotstrings
; added, that are not in the new mainFile. 

mainFile := "..\..\Core\HotstringLib.ahk"  ; <--- Your hotstring file path here.
extraFile := "..\..\Core\HotstringLib_OLD.ahk" 

^Esc::ExitApp ; <----- Emergency kill switch is Ctrl+Esc. 

Try mainList := Fileread(mainFile) ; Make sure file exists and save contents for variable. 
Catch {
	MsgBox '====ERROR====`n`nThe file (' mainFile ')`nwas not found.`n`nRemember to set the two variables`nat the top of the script. Now exiting.'
	ExitApp
}
Try extraList := Fileread(extraFile) ; Make sure file exists and save contents for variable. 
Catch {
	MsgBox '====ERROR====`n`nThe file (' extraFile ')`nwas not found.`n`nRemember to set the two variables`nat the top of the script. Now exiting.'
	ExitApp
}

extraListOrig := extraList
TotalLinesM := StrSplit(mainList, "`n").Length ; Determines number of lines for Prog Bar range.
TotalLinesE := StrSplit(extraList, "`n").Length ; Determines number of lines for Prog Bar range.

StartTime := A_TickCount
DupeReportM := "", CountM := 0, DupeReportE := "", CountE := 0
SplitPath(extraFile, &extraFileName) ; get file name.
SplitPath(mainFile, &mainFileName) ; get file name.

rep := Gui()
rep.Opt("-MinimizeBox +alwaysOnTop +Owner")
rep.SetFont("s13")
progLabelM := rep.Add("Text",, "Items Unique to: " extraFileName)
MyProgressM := rep.Add("Progress", "w400 h30 cGreen Range0-" . TotalLinesM, "0")
progLabelE := rep.Add("Text",, "Items Unique to: " mainFileName)
MyProgressE := rep.Add("Progress", "w400 h30 cGreen Range0-" . TotalLinesM, "0")

rep.Show()

; Loop through Main File contents, then remove any matching lines from the Extra File contents. 
loop parse mainList, "`n" { 
	MyProgressM.Value += 1
	extraList := strReplace(extraList, A_LoopField, "`nxxxxxx",,,1) ; Remove the item because it exists in both files. 
}
; Loop through the Extra Files, and extract anything that wasn't replaced with "xxxxxx."
loop parse extraList, "`n" {
	If  (SubStr(trim(A_LoopField, " `t"), 1,1) = ":") ; Only include lines starting with ":"
	{	DupeReportM .= A_LoopField "`n"
		CountM++
	}
}

; Then Loop through Etra File contents, then remove any matching lines from the Main File contents. 
loop parse extraListOrig, "`n" { 
	MyProgressE.Value += 1
	mainList := strReplace(mainList, A_LoopField, "`nxxxxxx",,,1) ; Remove the item because it exists in both files. 
}
; Loop through the Extra Files, and extract anything that wasn't replaced with "xxxxxx."
loop parse mainList, "`n" {
	If  (SubStr(trim(A_LoopField, " `t"), 1,1) = ":") ; Only include lines starting with ":"
	{	DupeReportE .= A_LoopField "`n"
		CountE++
	}
}

ElapsedTime := (A_TickCount - StartTime) / 1000 ; Calculate and format time taken. 
MessageHeader := 
(
	"Search took " Round(ElapsedTime / 60) " minutes and " Round(mod(ElapsedTime, 60)) " seconds.`n`n"
	"We Found " CountM " items unique to " extraFileName ".  These might be custom items that you added via HotString Helper.  Please copy and keep any, from the first list, below, that you want to save.  Then you can optionally delete " extraFileName 
	".`n`nWe also found " CountE " items unique to " mainFileName ".  These are either newly added ones, or ones that you manually removed from your own version of ac2.  Search for and remove any unwanted items from " mainFileName ". Those are listed at the bottom, below."
)

rep.Destroy() ; Remove progress bar.

mainReport := DupeReportM
If mainReport = ""
	mainReport := "No unique hotstrings found in " extraFile "."
extraReport := DupeReportE
If extraReport = ""
	extraReport := "No unique hotstrings found in " mainFile "."

finalReport := 
(
	MessageHeader 
	"`n=================================`n" 
	extraFileName " items you may wish to keep:`n" 
	mainReport
	"`n`n=================================`n" 
	mainFileName " items that you may have removed from your new working file, or items that were recently added:`n" 
	extraReport
)

Location := "..\..\Data\Uniques_Report" FormatTime(A_Now, "_MMM_dd_hh_mm") ".txt"
FileAppend finalReport, Location ; Save to text file, then open the file. 
sleep 250
Run Location

SoundBeep 1800, 700
SoundBeep 1200, 200
ExitApp
