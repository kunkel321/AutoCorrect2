#SingleInstance
#Requires AutoHotkey v2+

; ==============================================================================
; DEFUNCTIONIZER
; kunkel321
; version 6-5-2025 
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
; KNOWN ISSUE: If won't convert :B0X?:http:\\::f("http://")  Sorry !!!
; If you have any autocorrects with colons, you'll need to fix them manually.

; ==============================================================================
KeepComments := 0 ; 1=keep, 0=discard.  Please note that "misspell warnings" such as
; :*:itr::it ; Fixes 101 words, but misspells itraconazole (Antifungal drug). 
; will be kept either way. Note also, if you purge the comments, then AutoCorrect2's
; Ctrl+F3 "Potential Fixes Report" will stop working correctly. 

myFile := "HotstringLib.ahk" ; Path to your autocorrect hotstring library.  
; If this Defunctionizer is in the same folder, you can just put the name of the
; library, as I have done here.  Otherwise, put whole path. 
; Your original library file won't get changed.  A copy, "LibDefunc-..." will be made.

; ==============================================================================

; Helper functions for conditional logging
LogError(message) {
    ; Uncomment if you need error logging
    ; FileAppend("ErrLog: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "error_debug_log.txt")
}

Debug(message) {
    ; Uncomment if you need debug logging  
    ; FileAppend("Debug: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "error_debug_log.txt")
}

Try {
    myList := Fileread(myFile) ; Make sure file exists and save contents for variable. 
} Catch Error as err {
    MsgBox('====ERROR====`n`nThe file (' myFile ')`nwas not found.`n`nRemember to set the myFile variable`nat the top of the script. Now exiting.`nError: ' err.Message)
    ExitApp
}

myListArr := StrSplit(myList, "`n")
TotalLines := myListArr.Length ; Determines number of lines for Prog Bar range.
NewLib := ""

SplitPath(myFile, &myFileName) ; get file name.

rep := Gui()
rep.Opt("-MinimizeBox +alwaysOnTop +Owner")
rep.SetFont("s13")
progLabel := rep.Add("Text",, "Defunctionaizing " myFileName "." )
MyProgress := rep.Add("Progress", "w400 h30 cGreen Range0-" . TotalLines, "0")

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
Location := A_ScriptDir "\LibDefunc--" FormatTime(A_Now, "MMM-dd-hh-mm") ".ahk"

Try {
    FileAppend(NewLib, Location, "UTF-8") ; Save to text file, then open the file. 
    sleep 250
    Run Location
} Catch Error as err {
    LogError("Failed to save or open file: " err.Message)
    MsgBox("Error saving file: " err.Message)
}