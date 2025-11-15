#SingleInstance
#Requires AutoHotkey v2+
; ==============================================================================
; DEFUNCTIONIZER
; ==============================================================================
; Author: kunkel321
; Tool Used: Claude AI
; Version: 11-15-2025 
; It removes the function call from AutoCorrect2 hotstrings.  
; For example 		:B0X*?:useing::f("using") ; Web Freq 369.49 | Fixes 115 words 
; is converted to: 	:*?:useing::using
; ==============================================================================

; QUESTION:  Why remove the function calls?
; ANSWER:  Because you don't use any of the functionality.  
; The f() function does three things:
; (1) Rarify/Optimize hotstring execution by only backspacing the minimun number 
; of characters. But... Newer versions of AHK v2 do this anyway...  
; (2) Utilizes Descolada's InputBuffer class.  This alone, is a good reason to 
; keep using the f() functions! 
; (3) Logging autocorrections for later analysis.  This is the original reason 
; for even creating the f() function.  Not everyone wants to log/analyze though.
; If you don't care about any of these functionalities, there is no point using
; the function calls, so defunctionize the autocorrect items and use AHK's built-in
; auto-replace hotstring functionality. 

; ==============================================================================
; KNOWN ISSUE: It won't convert :B0X?:http:\\::f("http://")  Sorry !!!
; If you have any autocorrects with colons, you'll need to fix them manually.

; ==============================================================================

settingsFile := "..\Data\acSettings.ini"
; Verify settings file exists
if !FileExist(settingsFile) {
    MsgBox(settingsFile " was not found. Please run AutoCorrect2 first to create the file.")
    ExitApp
}

KeepComments := IniRead(settingsFile, "Defunctionizer", "keepComments", 0)
; Set preference in acSettings.ini.  1=keep, 0=discard.  Please note that "misspell warnings" such as
; :*:itr::it ; Fixes 101 words, but misspells itraconazole (Antifungal drug). 
; will be kept either way. Note also, if you purge the comments, then AutoCorrect2's
; Ctrl+F3 "Potential Fixes Report" will stop working correctly. 

defaultHSLibrary := "..\Core\" IniRead(settingsFile, "Paths", "HotstringLibrary", "..\Core\HotstringLib.ahk")
alternateHSLibrary := "..\Core\" IniRead(settingsFile, "Files", "NewTemporaryHotstrLib", "HotstringLib (1).ahk")

; ==============================================================================
; LOAD COLORS AND THEME
; ==============================================================================

; Load green colors from acSettings.ini
LightGreen := IniRead(settingsFile, "Shared", "LightGreen", "b8f3ab")
DarkGreen := IniRead(settingsFile, "Shared", "DarkGreen", "0d3803")
LargeFontSize := "s" IniRead(settingsFile, "HotstringHelper", "LargeFontSize", "15")

; Load theme colors (FormColor, FontColor, ListColor)
; First check if colorThemeSettings.ini exists
colorThemeFile := "..\Data\colorThemeSettings.ini"
if FileExist(colorThemeFile) {
    FormColor := IniRead(colorThemeFile, "ColorSettings", "formColor", "E5E4E2")
    FontColor := "c" IniRead(colorThemeFile, "ColorSettings", "fontColor", "0x1F1F1F")
    ListColor := IniRead(colorThemeFile, "ColorSettings", "listColor", "FFFFFF")
} else {
    ; Use defaults if theme file doesn't exist
    FormColor := "E5E4E2"
    FontColor := "c0x1F1F1F"
    ListColor := "FFFFFF"
}

; Helper function to calculate brightness of a color (0-255 scale)
CalculateBrightness(colorHex) {
    ; Convert hex string to number
    if InStr(colorHex, "0x") {
        colorNum := Integer("0x" SubStr(colorHex, 3))
    } else {
        colorNum := Integer("0x" colorHex)
    }
    
    if colorNum is Number {
        r := (colorNum >> 16) & 0xFF
        g := (colorNum >> 8) & 0xFF
        b := colorNum & 0xFF
        brightness := (r * 299 + g * 587 + b * 114) / 1000
        return brightness
    }
    return 128 ; Default if calculation fails
}

; Determine which green to use based on form brightness
formBrightness := CalculateBrightness(FormColor)
ProgressBarColor := (formBrightness > 128) ? DarkGreen : LightGreen

; If this Defunctionizer is in the same folder, you can just put the name of the
; library, as I have done here.  Otherwise, put whole path. 
; Your original library file won't get changed.  A copy, "LibDefunc-..." will be made.

; ==============================================================================
; FILE SELECTION DIALOG
; ==============================================================================

; Get the filename for display purposes
SplitPath(defaultHSLibrary, &defaultFileName)
SplitPath(alternateHSLibrary, &alternateFileName)

; Check if alternate file exists
alternateFileExists := FileExist(alternateHSLibrary)

; Create selection dialog
selectionGUI := Gui("+AlwaysOnTop +Owner")
selectionGUI.BackColor := FormColor
selectionGUI.SetFont(FontColor " " LargeFontSize)

selectionGUI.Add("Text",, "Select HotString Library to Defunctionize:")

; Default file button
selectionGUI.Add("Button", "w400 h35", defaultFileName).OnEvent("Click", SelectDefault)

; Alternate file button (only if it exists)
if (alternateFileExists) {
    selectionGUI.Add("Button", "w400 h35", alternateFileName).OnEvent("Click", SelectAlternate)
}

; Browse button
selectionGUI.Add("Button", "w400 h35", "Browse for another file...").OnEvent("Click", BrowseFile)

selectedFile := ""

SelectDefault(GuiCtrlObj, GuiEvent) {
    global selectedFile, defaultHSLibrary, selectionGUI
    selectedFile := defaultHSLibrary
    selectionGUI.Destroy()
    ProcessFile(selectedFile)
}

SelectAlternate(GuiCtrlObj, GuiEvent) {
    global selectedFile, alternateHSLibrary, selectionGUI
    selectedFile := alternateHSLibrary
    selectionGUI.Destroy()
    ProcessFile(selectedFile)
}

BrowseFile(GuiCtrlObj, GuiEvent) {
    global selectedFile, selectionGUI, defaultHSLibrary
    
    ; Get the directory of the default file for starting point
    SplitPath(defaultHSLibrary, , &defaultDir)
    
    browsedFile := FileSelect(1, defaultDir, "Select the HotString Library file to defunctionize:", "AutoHotkey Scripts (*.ahk)")
    
    if (browsedFile != "") {
        selectedFile := browsedFile
        selectionGUI.Destroy()
        ProcessFile(selectedFile)
    }
}

selectionGUI.Show()

; ==============================================================================
; PROCESSING FUNCTION
; ==============================================================================

ProcessFile(HSLibrary) {
    ; Helper functions for conditional logging
    LogError(message) {
        ; Uncomment if you need error logging
        ; FileAppend("ErrLog: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Debug\Df_error_debug_log.txt")
        Return
    }
    
    Debug(message) {
        ; Uncomment if you need debug logging  
        ; FileAppend("Debug: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Debug\Df_error_debug_log.txt")
        Return
    }
    
    Try {
        myList := Fileread(HSLibrary) ; Make sure file exists and save contents for variable. 
    } Catch Error as err {
        MsgBox('====ERROR====`n`nThe file (' HSLibrary ')`nwas not found.`n`nNow exiting.`nError: ' err.Message)
        ExitApp
    }
    
    myListArr := StrSplit(myList, "`n")
    TotalLines := myListArr.Length ; Determines number of lines for Prog Bar range.
    NewLib := ""
    
    SplitPath(HSLibrary, , , , &myFileName) ; get file name without extension.
    
    rep := Gui()
    rep.Opt("-MinimizeBox +alwaysOnTop +Owner")
    rep.BackColor := FormColor
    rep.SetFont(FontColor " " LargeFontSize)
    progLabel := rep.Add("Text",, "Defunctionizing " myFileName ".ahk" )
    MyProgress := rep.Add("Progress", "w400 h30 c" ProgressBarColor " Range0-" . TotalLines " Background" listColor, "0")
    
    ; Apply ListColor as the progress bar background
    MyProgress.BackColor := "0x" ListColor
    
    rep.Show()
    
    ; Updated regex to handle the new comment format with Web Freq and pipe separators
    ; Based on regex work by Andymbody.
    hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<Comment>\h*;.*)?$"
    
    For item in myListArr {
        MyProgress.Value += 1
        Debug("Processing line: " item)
        
        If RegExMatch(item, hsRegex, &hotstr) {
            Debug("Regex matched for: " hotstr.Trig)
            
            thisHotStr := "" ; Reset to blank each use.
            OptsStr := hotstr.Opts
            TrigStr := hotstr.Trig
            ReplStr := hotstr.Repl
            CommentStr := hotstr.Comment
    
            ; Handle comment retention logic
            IF KeepComments || (CommentStr && inStr(CommentStr, "misspells")) { 
                FullComment := CommentStr
            } else {
                FullComment := ""
            }
    
            ; Clean up options string - remove X and B0
            OptsStr := StrReplace(StrReplace(OptsStr, "X", ""), "B0", "")
            
            ; Remove quotation marks from replacement string
            ReplStr := Trim(ReplStr, '"')
            
            ; Build the defunctionized hotstring
            itemDefun := ":" OptsStr ":" TrigStr "::" ReplStr FullComment
    
            Debug("Converted to: " itemDefun)
            NewLib .= itemDefun "`n"
        } else {
            Debug("No regex match for: " item)
            NewLib .= item "`n"
        }
    }
    
    rep.Destroy()
    Location := "..\Core\" myFileName "-Defunc-" FormatTime(A_Now, "MMM-dd-hh-mm") ".ahk"
    
    Try {
        FileAppend(NewLib, Location, "UTF-8") ; Save to text file, then open the file. 
        sleep 250
        Run Location
    } Catch Error as err {
        LogError("Failed to save or open file: " err.Message)
        MsgBox("Error saving file: " err.Message)
    }
}
