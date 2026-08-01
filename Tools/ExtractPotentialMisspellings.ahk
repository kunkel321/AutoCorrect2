#SingleInstance
#Requires AutoHotkey v2+
#Include "..\Includes\AcMsgBox.ahk" ; <--- Required.
/*
File: ExtractPotentialMisspellings.ahk
Made by kunkel321 using Claude AI. 
Version 3-19-2026 

For use with the AutoCorrect2 library of hotstrings.
AHK v2 Script to extract words that are potentially misspelled by certain AutoCorrect hotstrings.  It doesn't remove them from the HotstringsLib file, it just generates a separate list of them.

If the user recognizes any word as being relevant to them, then they may wish to remove the entry so as not to inadvertently misspell the word during typing. 

Note: The misspell warning must include "but misspells" for this tool do detect it. Example:
:B0X*?C:brod::f("broad") ; Web Freq 138.67 | Fixes 67 words, but misspells brodiaea (a type of plant)
HotstringHelper2 formats potential misspellings this way by default. 
*/


settingsFile := "..\Data\acSettings.ini"
; Verify settings file exists
if !FileExist(settingsFile) {
	acMsgBox.show(settingsFile " was not found. Please run AutoCorrect2 first to create the file.")
	ExitApp
}
filePath := "..\Core\" IniRead(settingsFile, "Files", "HotstringLibrary", "AutoCorrectHotstrings.ahk")
; Check if the file exists
if !FileExist(filePath) {
    acMsgBox.show("File not found: " filePath)
    ExitApp
}

; User Options
IncludeLineNumbers  := 0 ; Set to 1 to include line number of item in library.
IncludeDefinition   := 1 ; Set to 1 to include definitions, 0 for words only (moot if FullLine = 1).
IncludeFullLine     := 1 ; Set to 1 to include the entire hotstring line, including the associated AutoCorrect entry.

; Shift at startup toggles between condensed and expanded modes.
; If full-line mode is active, Shift switches to condensed (words-only).
; If words-only mode is active, Shift switches to expanded (full-line).
ShiftCondensed := false
ShiftExpanded  := false
if (IncludeDefinition && IncludeFullLine && GetKeyState("Shift", "P")) {
    IncludeDefinition := 0
    IncludeFullLine   := 0
    ShiftCondensed    := true
} else if (!IncludeDefinition && !IncludeFullLine && GetKeyState("Shift", "P")) {
    IncludeDefinition := 1
    IncludeFullLine   := 1
    ShiftExpanded     := true
}

; Editor Configuration
DefaultEditor := "Notepad.exe" ; Backup editor if VSCode is not found
EditorPath := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
if !FileExist(EditorPath)
    EditorPath := DefaultEditor

; Function to extract misspelled words from the file
ExtractMisspelledWords(filePath, includeDefinition, includeFullLine) {
    ; Try to read the file
    try {
        fileContent := FileRead(filePath)
    } catch Error as e {
        acMsgBox.show("Error reading file: " e.Message)
        return {text: "", totalItems: 0, flaggedItems: 0}
    }
    
    ; Initialize empty array to store results
    misspelledItems := []
    totalItems := 0
    If (IncludeLineNumbers)
        ThisLine := 0
    ; Split content into lines
    lines := StrSplit(fileContent, "`n", "`r")
    
    ; Process each line
    for line in lines {
        ; Count lines that start with ":" as hotstring entries
        if SubStr(Trim(line, " `t"), 1, 1) = ":"
            totalItems++

        If (IncludeLineNumbers) {
            ThisLine := A_Index
        }

        ; Look for lines that contain "but misspells"
        if InStr(line, "but misspells") {
            
            if (includeFullLine) {
                ; Include the entire line
                fullLine := line (IncludeLineNumbers ? " - Line: " ThisLine : "")
                misspelledItems.Push(fullLine)
            }
            else if (includeDefinition) {
                ; Extract everything after "but misspells "
                startPos := InStr(line, "but misspells ") + 13 ; Length of "but misspells "
                if (startPos > 0) {
                    fullText := SubStr(line, startPos) (IncludeLineNumbers ? " - Line: " ThisLine : "")
                    ; Add the full text to our results
                    misspelledItems.Push(fullText)
                }
            } else {
                ; Extract just the word between "but misspells " and " ("
                startPos := InStr(line, "but misspells ") + 13 ; Length of "but misspells "
                endPos := InStr(line, " (", , startPos)
                
                if (startPos > 0 && endPos > startPos) {
                    word := SubStr(line, startPos, endPos - startPos) (IncludeLineNumbers ? " - Line: " ThisLine : "")
                    ; Add the word to our results
                    misspelledItems.Push(word)
                }
            }
        }
    }
    
    ; Format the results - always use line breaks when including full lines
    if (includeFullLine || includeDefinition) {
        ; Put each item on its own line
        resultString := ""
        for item in misspelledItems {
            resultString .= item "`n"
        }
    } else {
        ; Join the words with commas
        resultString := ""
        for i, word in misspelledItems {
            resultString .= word
            if (i < misspelledItems.Length) {
                resultString .= ", "
            }
        }
    }
    
    return {text: resultString, totalItems: totalItems, flaggedItems: misspelledItems.Length}
}

; Extract the misspelled words
result := ExtractMisspelledWords(filePath, IncludeDefinition, IncludeFullLine)
misspelledWords := result.text
totalItems := result.totalItems
flaggedItems := result.flaggedItems

; Calculate percentage
percentage := totalItems > 0 ? Round((flaggedItems / totalItems) * 100, 3) : 0

; Display the result
if (misspelledWords != "") {
    ; Create a simple GUI to show the results
    titleText := ShiftCondensed ? "Misspelled Words (Condensed)"
        : ShiftExpanded ? "Hotstrings with Potential Misspellings (Expanded)"
        : (IncludeFullLine ? "Hotstrings with Potential Misspellings" : (IncludeDefinition ? "Misspelled Words with Definitions" : "Misspelled Words"))
    headerText := ShiftCondensed ? "Condensed word list — comma-separated (Shift was held at startup)."
        : ShiftExpanded ? "Expanded view — full hotstring lines (Shift was held at startup)."
        : (IncludeFullLine ? "The following hotstring lines may cause misspellings:"
        : (IncludeDefinition ? "The following words with definitions may be misspelled by the hotstrings:"
        : "The following words may be misspelled by the hotstrings:"))
    headerText .= IncludeLineNumbers ? " (Includes line numbers.)" : ""
    ; Show the appropriate Shift hint based on the baseline configuration.
    if (!ShiftCondensed && !ShiftExpanded) {
        if (IncludeFullLine && IncludeDefinition)
            headerText .= "   (Rescan while holding Shift for a condensed list.)"
        else if (!IncludeFullLine && !IncludeDefinition)
            headerText .= "   (Rescan while holding Shift for a detailed list.)"
    }
    
    myGui := Gui("", titleText)
    myGui.SetFont("s10", "Segoe UI")
    myGui.Add("Text", "w900", headerText)
    resultsEdit := myGui.Add("Edit", "r15 w900 ReadOnly", misspelledWords)
    myGui.Add("Button", "Default w100", "Copy").OnEvent("Click", (*) => (A_Clipboard := misspelledWords, ToolTip("Copied to clipboard!"), SetTimer(() => ToolTip(), -2000)))
    myGui.Add("Button", "w100 x+10", "Look Up").OnEvent("Click", (*) => LookupSelected(resultsEdit))
    myGui.Add("Button", "w100 x+10", "Close").OnEvent("Click", (*) => myGui.Destroy())
    
    ; Add statistics text
    statsText := "Of " totalItems " items scanned, " flaggedItems " have 'but misspells' flags (" percentage "%)"
    myGui.Add("Text", "x+20 yp+5", statsText)
    
    myGui.OnEvent("Close", (*) => myGui.Destroy())
    myGui.Show()
} else {
    acMsgBox.show("No misspelled words found.")
}

; Function to look up selected text in the AutoCorrectHotstrings.ahk file
LookupSelected(editControl) {
    ; Get selected text
    EM_GETSEL := 0xB0
    start := 0
    end := 0
    DllCall("SendMessage", "Ptr", editControl.hwnd, "Uint", EM_GETSEL, "Ptr*", &start, "Ptr*", &end)
    
    if start = end {
        ToolTip("Please select text first")
        SetTimer(() => ToolTip(), -2000)
        return
    }
    
    ; Get the selected text
    text := StrReplace(editControl.Value, "`n", "`r`n")
    selected := Trim(SubStr(text, start + 1, end - start))
    
    if selected = "" {
        ToolTip("No text selected")
        SetTimer(() => ToolTip(), -2000)
        return
    }
    
    ; Open the library file if not already open
    if !WinExist("AutoCorrectHotstrings.ahk") {
        try {
            Run(EditorPath " " filePath)
        } catch {
            acMsgBox.show("Cannot run " filePath)
            return
        }
        
        ; Wait for the file to open
        counter := 0
        while !WinExist("AutoCorrectHotstrings.ahk") {
            Sleep(50)
            counter++
            if counter > 80 {
                acMsgBox.show("Cannot seem to open Library.`nMaybe an 'admin rights' issue?")
                return
            }
        }
    }
    
    ; Activate the window and search
    try {
        WinActivate("AutoCorrectHotstrings.ahk")
        Sleep(300)
        
        ; Use Ctrl+F to search for the selected text
        SendInput("^f" selected)
    } catch Error as err {
        acMsgBox.show("Error activating editor: " err.Message)
    }
}