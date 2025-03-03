/*
=====================================================
            AUTO CORRECTION LOG ANALYZER
                Updated:  3-3-2025
Determines frequency of items in AutoCorrects Log file, then sorts by freq (or weight).  Date not factored in sort. There's no hotkey, just run the script.  It reports the top X hotstrings that were immediately followed by 'Backspace' (<<), and how many times they were used without backspacing (--)).  Sort one or the other, or sort by "weight."  Intended for use with kunkel321's 'AutoCorrect for v2.' Items are reported in Gui, as radio buttons.  User is given option to 'Go to' item in HotStringLibrary, open it in HotStringHelper2, and/or Cull from embedded log at the bottom.  Items culled from ACLog file will get added to the RemovedHotStrings file.  This helps us avoid inadvertently "re-adding" them later.  Fully functional script was written by current human (kunkel321), then totally refactored (with lots of debugging) using ClaudeAI. Then... More human parts were added.  Hellbent helped me workout how to "weigh" the analyzed items. It is important to note that this log analyzer reads/analyzes the autocorrection log that is created by the AutoCorrect2.ahk script.  Without ac2 logging your autocorrections, there will be nothing to analyze.  More recently (11-28-2024), the "ErrContextLog" functionality was added to hh2.  This AcLogAnalyzer script uses that log too.  So please use a version of AutoCorrect2.ahk that is no older than 11-28-2024. Tip: Quick access to context items: Click to select a radio button item, then right-click to see any context loggings.  You'll know which have context because the number of items is in brackets, for example: "Found 10 [5] << and 4-- for :*:whn::when" has 5 associated context items. 
===================================================
*/
#SingleInstance Force
#Requires AutoHotkey v2+
^Esc::ExitApp ; Emergency kill switch: Ctrl+Esc

; ======= Settings =======================
ShowX := 24             ; Show this many top results in report.
SortByBS := 1           ; Sort by "Backspaced" items or "Kept" items? (1=BS, 0=Kept)
WeighItems := 1         ; Attempt to weigh items based on how problematic they are. (1=yes) Only applies if SortByBS is '1'.
freqImportance := 20    ; Is it important for an item to be "high-frequency" when applying weight? (0 to ~50, where 0=not important)
IgnoreFewerThan := 2    ; Only used when Weighing.  If few '<<' items, skip line.
AddFulltoClipBrd := 1   ; Send full report clipboard as well?
myAutoCorrectScript := "AutoCorrect2.ahk" ; Used for sending HS to hotstring helper.
HotstringLibrary := "HotstringLib.ahk" ; Used for 'Go To Hotstring' button.
ACLog := "AutoCorrectsLog.txt" ; The main log that gets analyzed.
errLog := "ErrContextLog.txt" ; Holds the additional context info for BS items.
startLine := 7          ; Don't scan log until getting the this linemumber.
RemovedHsFile := "RemovedHotstrings.txt" ; File containing hotstrings removed (culled) from log. 
CullDateFormat := "MM-dd-yyyy" ; Used in RemovedHsFile.
MyAhkEditorPath := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe" ; Put path to your editor.
TraySetIcon(A_ScriptDir "\icons\AcAnalysis.ico") ; The icon for the guis and System Tray Icon. 
;========================================

; other global variables
ReportArray := []
workingItem := " (No lookup history)"

InitializeSettings()
Main()

InitializeSettings() {
    ; colorThemeSettings.ini is a component of the ColorThemeIntegrator Tool.
    ; https://github.com/kunkel321/ColorThemeIntegrator
    if FileExist("colorThemeSettings.ini") {
        settingsFile := "colorThemeSettings.ini"
        global fontColor := IniRead(settingsFile, "ColorSettings", "fontColor")
        global listColor := IniRead(settingsFile, "ColorSettings", "listColor")
        global formColor := IniRead(settingsFile, "ColorSettings", "formColor")

        ; Calculate contrasting text color for better readability of radio buttons and progress bar.
        formColor := "0x" subStr(formColor, -6) ; Make sure the hex value appears as a number, rather than a string. 
        r := (formColor >> 16) & 0xFF, g := (formColor >> 8) & 0xFF, b := formColor & 0xFF
        brightness := (r * 299 + g * 587 + b * 114) / 1000
        global radioColor := brightness > 128 ? "Blue" : "0x00FFFF"   ; Color for radio button text.
        global progressColor := brightness > 128 ? 'c248d0c' : 'c60fc3d'   ; Color for progress bar.
    }
    Else { ; If user doesn't have ColorThemeIntegrator, just use these.
        global fontColor := "Default" ; <--- Change as desired. This is the color of the words.
        global listColor := "Default" ; <--- Change as desired. This is the color of the cull notes editbox.
        global formColor := "Default" ; <--- Change as desired. Color or GUI forms.
        global radioColor := "Blue"
        Global progressColor := 'c1b7706'
    }    
}

; If the RemovedHotstrings file doesn't exist, silently create it. 
If !FileExist(RemovedHsFile) {
    remFileHeader := "
    (
    This is a list of AutoCorrect hotstrings that were manually removed from the HotstringLib.ahk.  They were removed because an analysis report from the AutoCorrectsLog file indicated that the autocorrection was 'Backspaced' more than it was kept.   The MCLogger tool, and the HotString Helper tool each will check this list to avoid re-adding them to your HotstringLib.ahk list. 
    =======================================
    )"
    FileAppend(remFileHeader,RemovedHsFile)
}

Main() {
    If FileExist(ACLog)
        AllStrs := FileRead(ACLog)
    else {
        MsgBox "File '" ACLog "' not found...  There must be a log file to analyze.  Now exiting."
        ExitApp()
    }

    TotalLines := StrSplit(AllStrs, "`n").Length
    
    pgObj := CreateProgressGui(TotalLines)
    Report := ProcessLines(AllStrs, TotalLines, pgObj)
    pgObj.gui.Destroy()
    
    global ReportArray := PrepareReport(Report)
    AnalysisResults()
}

CreateProgressGui(TotalLines) {
    pg := Gui()
    pg.Opt("-MinimizeBox +alwaysOnTop +Owner")
    pg.BackColor := formColor
    MyProgress := pg.Add("Progress", "w400 h30 c" progressColor " Background" formColor " Range0-" . TotalLines, "0")

    If (WeighItems = 1) and (SortByBS = 1)
        reportType := "weighted"
    Else If (SortByBS = 1)
        reportType := "backspaced"
    else
        reportType := "kept"

    reportType := "Top " ShowX " " reportType " autocorrects."
    pg.Title := reportType "  Percent complete: 0 %."
    pg.Show()
    return {gui: pg, progress: MyProgress, reportType: reportType}
}

ProcessLines(AllStrs, TotalLines, pgObj) {
    Report := ""
    Loop parse AllStrs, "`n`r" {
        pgObj.progress.Value += 1
        pgObj.gui.Title := pgObj.reportType "  Percent complete: " Round((pgObj.progress.Value/TotalLines)*100) "%."
        
        oStr := SubStr(A_LoopField, 15)
        ; okTally := 0, bsTally := 0
        okTally := 1, bsTally := 1
        
        Loop parse AllStrs, "`n`r" {
            iStr := SubStr(A_LoopField, 15)
            If iStr = oStr {
                If SubStr(A_LoopField, 12, 2) = "--"
                    okTally++
                If SubStr(A_LoopField, 12, 2) = "<<"
                    bsTally++
            }
        }
        
        Report .= FormatReportLine(bsTally, okTally, oStr)
        AllStrs := StrReplace(AllStrs, oStr, "Cap fix")
    }
    return Report
}

FormatReportLine(bsTally, okTally, oStr) {
    if (SortByBS = 1)
        If (WeighItems = 1) {
            try { ; Handles div/0 errors. Setting IgnoreFewerThan should also prevent the error.
                If not bsTally <= IgnoreFewerThan { ; Only use high-frequency items.
                    ; Special thanks to Hellbent for helping me try different weighing algorithms.
                    Weight := Round((bsTally / (bsTally + okTally) * 100) + bsTally * (freqImportance * 0.1), 1)  
                    return Weight " is weight for ->`t" Format("{1}<< and {2}-- `tfor {3}`n", bsTally, okTally, oStr)
                }
            }
        }
        Else
            return Format("{1}<< and {2}-- `tfor {3}`n", bsTally, okTally, oStr)
    else
        return Format("{1}-- and {2}<< `tfor {3}`n", okTally, bsTally, oStr)
}

PrepareReport(Report) {
    global contextLogContent := FileRead(errLog)

    Report := Sort(Sort(Report, "/U"), "NR")
    If (AddFulltoClipBrd =1)
        A_Clipboard := Report
    trunkReport := ""
    Loop Parse, Report, "`n" {
        if (A_Index <= ShowX && A_LoopField != "") {

            contextCount := " [" IfHasContext(A_LoopField) "] "
            contextCount := StrReplace(contextCount, "[0]", "[_]")
            loopFldArr := StrSplit(A_LoopField, "<<")
            thisLoopFld := loopFldArr[1] contextCount "<<" loopFldArr[2]
            trunkReport .=  thisLoopFld "`n"


        }
        else if (A_Index > ShowX)
            break
    }
    return StrSplit(RTrim(trunkReport, "`n"), "`n")
}

IfHasContext(workingItem) {
    ContextItemCount := 0
    selItemArr := StrSplit(workingItem, ":")
    selItemTrigger := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]
    global contextLogContent
    loop parse contextLogContent, "`n" {
        If InStr(A_LoopField, selItemTrigger) {
            ContextItemCount++
        }
    }
    Return ContextItemCount
}

AnalysisResults() {
    global workingItem := " (No lookup history)"
    Global SortByBS
    global aca := Gui(, 'AC Analysis Report')
    aca.SetFont('s12 ' (FontColor ? "c" FontColor : ""))
    aca.BackColor := formColor
    If (WeighItems = 1) and (SortByBS = 1)
        aca.AddText(,'The ' ShowX ' highest weighted problem items are below.`nAnalyze in HH and Cull separately.  Culling adds`nitem to ' RemovedHsFile ' file.')
    Else If (SortByBS = 1)
        aca.AddText(,'The ' ShowX ' most frequntly Backspaced items are below.`nAnalyze in HH and Cull separately.  Culling adds`nitem to ' RemovedHsFile ' file.')
    else
        aca.AddText(,"The " ShowX " most frequntly KEPT items are below.`nYOU PROBABLY DON'T WANT TO CHANGE THESE!")
        aca.AddText("y+2","(Select an item and right-click for context.)")
    global radioColor
    aca.SetFont('c' radioColor)
    CreateRadioButtons()
    CreateActionButtons()
    
    aca.Show('yCenter x' (A_ScreenWidth/2) " autosize")
    WinSetAlwaysOnTop(1, "A")
    aca.OnEvent('Escape', (*) => ExitApp())
}

CreateRadioButtons() {
    global radioColor
    if (ReportArray.Length = 0) {
        aca.Add("Text", "w300", "No items to display.")
        return
    }
    For idx, citem in ReportArray {
        If (WeighItems = 1) and (SortByBS = 1)
            citem := StrSplit(citem, " is weight for ->`t")[2] ; Don't display weight score.
        options := (idx = 1) ? 'vRadioGrp' : 'xs y+5'
        aca.Add('Radio', options, "Found " citem).OnEvent("ContextMenu", seeContext)

    }
}

CreateActionButtons() {
    buttons := [
        {label: 'Send to HH', callback: SendToHH},
        {label: 'Cull From Log', callback: cullFromLog},
        {label: 'Edit Scpt', callback: (*) => Run(MyAhkEditorPath " " A_ScriptName)},
        {label: 'See in Lib', callback: goToHS},
        {label: 'See Context', callback: seeContext},
        {label: 'Close Tool', callback: (*) => ExitApp()}
    ]
    
    For idx, btn in buttons {
        buttonOpts := (idx > 1 ? 'x+5 ' : '') (idx = 4? ' xm y+5 ' : '')
        newBtn := aca.Add('Button', buttonOpts, btn.label)
        newBtn.OnEvent('Click', btn.callback)
    }
}

SendToHH(*) {
    result := ProcessSelectedItem()
    if (result) {
        global workingItem := result.workingItem
        selItemArr := StrSplit(workingItem, ":")
        workingItem := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]

        myACFileBaseName := StrSplit(myAutoCorrectScript, ".")[1]
        if (!FileExist(myACFileBaseName . ".exe")) { ; Check if the file exists
            MsgBox("Error: " myACFileBaseName ".exe not found in the current directory.")
            return
        }
        
        Run myACFileBaseName ".exe /script " myAutoCorrectScript " " workingItem
        aca.Show()
    }
}

goToHS(*) {
    result := ProcessSelectedItem()
    if (result) {
        global workingItem := result.workingItem
        selItemArr := StrSplit(workingItem, ":")
        selItemTrigger := selItemArr[2] ":" selItemArr[3] "::"
        
        if !WinExist(HotstringLibrary)
            Run MyAhkEditorPath " " HotstringLibrary
        WinWait(HotstringLibrary)
        WinActivate
        SendInput "^f"
        Sleep 200
        SendInput selItemTrigger
        aca.Show()
    }
}

seeContext(*) {
    result := ProcessSelectedItem()
    if (result) {
        global workingItem := result.workingItem
        selItemArr := StrSplit(workingItem, ":")
        selItemTrigger := ":" selItemArr[2] ":" selItemArr[3] "::" selItemArr[5]
        contextLogContent := FileRead(errLog)

        If !InStr(contextLogContent, selItemTrigger)
            contextItems := "No context found for this item."
        Else {
            loop parse contextLogContent, "`n" {
                If InStr(A_LoopField, selItemTrigger) {
                    thisItem := StrSplit(A_LoopField, "`t---> ")[2]
                    contextItems .= thisItem "`n"
                }
            }
        }

        ctxGui := Gui()
        ctxGUI.SetFont('s15 ' (FontColor ? "c" FontColor : ""))
        ctxGUI.BackColor := formColor
        ; Use an Edit control, so text in selectable.  Make it look like text though.
        ctxGui.Add('Edit', '-VScroll ReadOnly -E0x200 -WantReturn -TabStop Background' formColor
        , "Context of item -- " selItemTrigger "`n======================`n" contextItems)
        ctxGui.AddButton(,"Open Log").OnEvent("click", ctxOpenLog)
        closeBtn := ctxGui.AddButton(" x+4","Close This")
        closeBtn.OnEvent("click", ctxClose)
        ctxGui.Show()
        closeBtn.Focus() ; Move focus to the close button

        ctxOpenLog(*) {
            ctxGui.Destroy()
            Run(errLog)
            aca.Show()
        }
        ctxClose(*) {
            ctxGui.Destroy()
            aca.Show()
        }
    } 
}


cullFromLog(*) {
    result := ProcessSelectedItem()
    if (result) {
        selectedItem := result.workingItem
        fullItemName := result.fullItemName
        
        if (workingItem != selectedItem && workingItem != " (No lookup history)") {
            if (MsgBox("Warning: Different items detected`nYou were working on: " workingItem "`nBut you're culling: " selectedItem "`n`nDo you want to continue?", "Item Mismatch", 4) != "Yes") {
                aca.Show()
                return
            }
        }
        global fontColor, listColor, formColor, SortByBS
        confGUI := Gui() ; Create a cull-confirmation dialog. 
        confGUI.SetFont('s12 ' (FontColor ? "c" FontColor : ""))
        confGUI.BackColor := formColor
        global remCheck
        If (SortByBS = 1) { 
            selectedItem := StrSplit(selectedItem, "is weight for ->	")[2]
            confGUI.AddText(,"Confirm culling item...`n" selectedItem "`n")
            remCheck := confGUI.AddCheckbox("checked1","Add to Removed Strings list.")
            txtAddNotes := confGUI.AddText(, "Add optional notes to culled item.")
            txtAddNotes.Visible := True
            edtBoxOpts := " -ReadOnly Background" listColor 
        }
        Else {
            confGUI.AddText(,"THESE ARE SORTED BY *KEPT*`nSo you probably don't want to`nchange the HotStr Lib item.")
            remCheck := confGUI.AddCheckbox("checked0","Add to Removed Strings list.")
            txtAddNotes := confGUI.AddText(, "Add optional notes to culled item.")
            txtAddNotes.Visible := False
            edtBoxOpts := " +ReadOnly Background" formColor 
        }
        
        confirmNotes := confGUI.AddEdit("w305 " edtBoxOpts, "")
        confGUI.AddButton("w150", "Cull Item").OnEvent("Click", DoCullItem)
        confGUI.AddButton("w150 x+5", "Cancel").OnEvent("Click", cancelCull)
        confGUI.Show()

        remCheck.OnEvent("Click", addToRemoved)
        addToRemoved(*) { ; If "add to removed items list" checkbox is changed, update these properties. 
            If remCheck.Value = 0 {
                confirmNotes.Opt(" +ReadOnly Background" formColor)
                confirmNotes.Text := ""
                txtAddNotes.Visible := False
            }
            else {
                confirmNotes.Opt(" -ReadOnly  Background" listColor)
                txtAddNotes.Visible := True
            }
        }

        cancelCull(*) {
            confGUI.Destroy()
            aca.Show()
            return
        }
        DoCullItem(*) {
            If (confirmNotes.Value != "") 
                selectedItem .= " (" confirmNotes.Value ")"
            CullItemFromLog(selectedItem)
            confGUI.Destroy()
        }
        global workingItem := " (No lookup history)"  ; Reset after culling
    }
}

ProcessSelectedItem() {
    global selectedItem := aca.Submit()
    if (selectedItem.RadioGrp = 0) {
        MsgBox 'Nothing selected.'
        aca.Show()
        return false
    }
    
    fullItemName := ReportArray[selectedItem.RadioGrp]
    workingItem := ExtractItemName(fullItemName)
    return {workingItem: workingItem, fullItemName: fullItemName}
}

ExtractItemName(selItemName) {
    splitStr := SortByBS ? "-- for" : "<< for"
    parts := StrSplit(selItemName, splitStr)
    return Trim(parts[parts.Length], " `n`r")  ; Always take the last part
}

CullItemFromLog(itemToCull) {
    Global ACLog
    thisFileContents := FileRead(ACLog)
    newFileContents := ""

    Global remCheck
    If remCheck.Value = 1 {
        CullItemAndDate := "Removed " FormatTime(A_Now, CullDateFormat) " -> " itemToCull "`n"
        FileAppend(CullItemAndDate, RemovedHsFile)
    }

    for scriptLine in StrSplit(thisFileContents, "`n")
        If scriptLine != ""
            if !InStr(itemToCull, SubStr(scriptLine, 15))
                newFileContents .= scriptLine "`n"
    
    FileDelete(ACLog)
    while FileExist(ACLog) 
        sleep 10
    FileAppend(newFileContents, ACLog)
    SoundBeep
    ExitApp()
    ;MsgBox("Item culled and added`nto 'Removed' list:`n`n" itemToCull)
}
