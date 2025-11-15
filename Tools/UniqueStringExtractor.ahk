#SingleInstance
#Requires AutoHotkey v2+

; Intended for updating AutoHotkey scripts.  kunkel321 11-15-2025
; A script to find unique hotstrings that are in one file but not another. 
; Default files to scan can be entered.  If they are not found, a file-picker will appear.
; The "mainFile" is the file that you plan to use--it is your new AutoCorrect file.
; The "extraFile" is a different version of your file, that might have new custom hotstrings
; added, that are not in the new mainFile.

^Esc::ExitApp ; <----- Emergency kill switch is Ctrl+Esc. 

settingsFile := "..\Data\acSettings.ini"
; Verify settings file exists
if !FileExist(settingsFile) {
	MsgBox(settingsFile " was not found. Please run AutoCorrect2 first to create the file.")
	ExitApp
}
mainFile := "..\Core\" IniRead(settingsFile, "Files", "HotstringLibrary", "HotstringLib.ahk")
extraFile := "..\Core\" IniRead(settingsFile, "Files", "NewTemporaryHotstrLib", "HotstringLib (1).ahk")

; Function to get file path with dialog fallback
GetFilePath(defaultPath, fileType) {
	if (FileExist(defaultPath)) {
		return defaultPath
	}
	
	; File not found, open dialog. Default to AutoCorrect2\ directory (2 levels up from script location)
	startDir := A_ScriptDir "\..\.."
	selectedFile := FileSelect(1, startDir, "Please select the " fileType " file (*.ahk):", "AutoHotkey Scripts (*.ahk)")
	if (selectedFile = "") {
		MsgBox "No file selected. Exiting."
		ExitApp
	}
	return selectedFile
}

mainFile := GetFilePath(mainFile, "main")
extraFile := GetFilePath(extraFile, "extra")

Try mainContent := Fileread(mainFile)
Catch {
	MsgBox '====ERROR====`n`nCould not read the file: ' mainFile '`n`nNow exiting.'
	ExitApp
}
Try extraContent := Fileread(extraFile)
Catch {
	MsgBox '====ERROR====`n`nCould not read the file: ' extraFile '`n`nNow exiting.'
	ExitApp
}

; Normalize line endings and split into arrays, trimming each line
mainLines := StrSplit(StrReplace(mainContent, "`r`n", "`n"), "`n")
extraLines := StrSplit(StrReplace(extraContent, "`r`n", "`n"), "`n")

; Trim all lines
loop mainLines.Length
	mainLines[A_Index] := trim(mainLines[A_Index])
loop extraLines.Length
	extraLines[A_Index] := trim(extraLines[A_Index])

TotalLinesM := mainLines.Length
TotalLinesE := extraLines.Length

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
MyProgressE := rep.Add("Progress", "w400 h30 cGreen Range0-" . TotalLinesE, "0")

rep.Show()

; Create a map of extra file lines for fast lookup
extraMap := Map()
for line in extraLines {
	if (line != "")
		extraMap[line] := true
}

; Find items in extra file that are NOT in main file
for line in extraLines {
	MyProgressM.Value += 1
	if (SubStr(trim(line, " `t"), 1, 1) = ":" && !extraMap.Has(line)) {
		; This line was removed from the map, so it's unique to extra file
	}
}

; Create a map of main file lines for fast lookup
mainMap := Map()
for line in mainLines {
	if (line != "")
		mainMap[line] := true
}

; Loop through extra lines and find those NOT in main
for line in extraLines {
	if (line = "")
		continue
	if (SubStr(trim(line, " `t"), 1, 1) = ":") {
		if (!mainMap.Has(line)) {
			DupeReportM .= line "`n"
			CountM++
		}
	}
}

; Loop through main lines and find those NOT in extra
for line in mainLines {
	MyProgressE.Value += 1
	if (line = "")
		continue
	if (SubStr(trim(line, " `t"), 1, 1) = ":") {
		if (!extraMap.Has(line)) {
			DupeReportE .= line "`n"
			CountE++
		}
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

Location := "..\Debug\Uniques_Report" FormatTime(A_Now, "_MMM_dd_hh_mm") ".txt"
FileAppend finalReport, Location ; Save to text file, then open the file. 
sleep 250
Run Location

SoundBeep 1800, 700
SoundBeep 1200, 200
ExitApp