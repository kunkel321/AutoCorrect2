#SingleInstance
#Requires AutoHotkey v2+
; ==============================================================================
; DEFUNCTIONIZER
; ==============================================================================
; Author: kunkel321
; Tool Used: Claude AI
; Version: 6-29-2026 
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
; June 2026 update:  It now supports multi-line continuation style f() calls.
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
    ; Repl is now quote-delimited (rather than comma-delimited) so f() calls with the
    ; optional Log/Paste boolean params (e.g. f("text, with comma", 1, 0)) parse correctly
    ; even when the replacement text itself contains a comma. Log/Paste are captured but
    ; intentionally discarded below since Defunctionizer strips the function call entirely.
    hsRegex := '(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\("(?<Repl>[^"]*)"(?:\h*,\h*(?<Log>[01]))?(?:\h*,\h*(?<Paste>[01]))?\)|(?<Repl>[^;\v]+))?(?<Comment>\h*;.*)?$'

    ; Detects a multiline continuation-section hotstring (with or without an f() wrapper)
    ; starting at 1-based index i in lineArr. Mirrors the logic AutoCorrect2 already uses in
    ; Utils.NormalizeFCallText, adapted to scan the file's line array (rather than a single
    ; clipboard string) and to report how many lines were consumed.
    ;
    ;   Non-f() :   :opts:trig::          (line 1 ends with ::, optional comment)
    ;               (                     (line 2 is opener, optional modifiers)
    ;               content lines
    ;               )                     (closer: first line whose first non-space char is ))
    ;
    ;   f() wrap:   :opts:trig::f("       (line 1 ends with f(", optional comment)
    ;               (                     (line 2 is opener, optional modifiers)
    ;               content lines
    ;               )",params)            (closer: first line whose first non-space char is ))
    ;
    ; Returns a Map with "Matched". If matched, also includes Opts/Trig/Comment/InnerLines/
    ; OpenerLine/NextIndex (1-based index of the line just after the consumed block).
    DetectMultilineBlock(lineArr, i) {
        result := Map("Matched", false)

        ; Need at least a header line, an opener line, and one more line to even attempt this.
        if (i + 2 > lineArr.Length)
            return result

        firstLine := Trim(lineArr[i], " `t`r")

        isFCall := RegExMatch(firstLine, '^:(?<Opts>[^:]*):(?<Trig>[^:]+)::f\("(\h*;.*)?$', &fm)
        isPlain := !isFCall && RegExMatch(firstLine, '^:(?<Opts>[^:]*):(?<Trig>[^:]+)::(\h*;.*)?$', &fm)

        if (!isFCall && !isPlain)
            return result   ; Not a recognizable multiline opener.

        ; Line 2 must be the continuation-section opener ( with optional modifiers.
        openerLine := Trim(lineArr[i + 1], " `t`r")
        if !RegExMatch(openerLine, '^\((?:RTrim0?|LTrim0?|Join\S*|C|P\d+|\s)*\s*$')
            return result

        ; Collect content lines until the closer (first line whose first non-space char is )).
        innerLines  := []
        foundCloser := false
        j := i + 2
        Loop {
            if (j > lineArr.Length)
                break
            rawLine := RTrim(lineArr[j], "`r")   ; strip CR; preserve inner whitespace
            if RegExMatch(rawLine, '^\s*\)') {
                foundCloser := true
                break
            }
            innerLines.Push(rawLine)
            j += 1
        }

        if !foundCloser
            return result   ; Malformed — bail out safely; caller falls back to single-line logic.

        ; Extract any trailing comment from line 1 (after the final ::), same approach as
        ; Utils.NormalizeFCallText: find the last :: then look for required whitespace + ;
        lastDColonPos := 0
        p := 1
        while RegExMatch(firstLine, '::', &dm, p) {
            lastDColonPos := dm.Pos
            p := dm.Pos + 2
        }
        afterDColon := SubStr(firstLine, lastDColonPos + 2)
        comm := RegExMatch(afterDColon, '\h+(;.*)$', &mc) ? mc[1] : ""

        result["Matched"]    := true
        result["Opts"]       := fm.Opts
        result["Trig"]       := fm.Trig
        result["Comment"]    := comm
        result["InnerLines"] := innerLines
        result["OpenerLine"] := lineArr[i + 1]
        result["NextIndex"]  := j + 1
        return result
    }

    i := 1
    while (i <= myListArr.Length) {
        MyProgress.Value := i

        blk := DetectMultilineBlock(myListArr, i)
        if blk["Matched"] {
            Debug("Multiline block matched for trigger: " blk["Trig"])

            OptsStr := StrReplace(StrReplace(blk["Opts"], "X", ""), "B0", "")
            TrigStr := blk["Trig"]
            commentText := blk["Comment"]

            ; Handle comment retention logic (same rule as the single-line branch below)
            IF KeepComments || (commentText && InStr(commentText, "misspells")) {
                FullComment := commentText ? " " commentText : ""
            } else {
                FullComment := ""
            }

            ; Rebuild as a vanilla continuation-section hotstring with no f() wrapper.
            ; The text has real line breaks, so it must stay a continuation section —
            ; only the f("...",Log,Paste) wrapper is stripped away. Plain (non-f()) blocks
            ; pass through unchanged content-wise, just with Opts cleaned the same way.
            innerText := ""
            for idx, ln in blk["InnerLines"]
                innerText .= (idx > 1 ? "`n" : "") . ln

            itemDefun := ":" OptsStr ":" TrigStr "::" FullComment "`n" blk["OpenerLine"] "`n" innerText "`n)"

            Debug("Converted multiline block to: " itemDefun)
            NewLib .= itemDefun "`n"

            i := blk["NextIndex"]
            continue
        }

        item := myListArr[i]
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

        i += 1
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
