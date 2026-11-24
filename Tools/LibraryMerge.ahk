#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Includes\AcMsgBox.ahk"
#Include "..\Includes\IniMerge.ahk"
#Include "..\Includes\LibMerge.ahk"

/*
Library Merge
Author: kunkel321
Tool Used: Claude
Version: 11-24-2026

Merges a newer AutoCorrectHotstrings.ahk (for example the "(1)" copy the Updater saved) into your
own library, without losing your changes.  It's the same merge the Updater does; see
Includes\LibMerge.ahk for how each rule is decided.

Three files are needed:
  ORIGINAL  the library as you last got it from GitHub.  The Updater keeps this as
            Data\AutoCorrectHotstrings.base.txt.  If you don't have one, leave it blank: every
            rule that differs is then shown as a conflict for you to decide.
  YOURS     your library (Core\AutoCorrectHotstrings.ahk), which gets updated.
  NEWER     the newer library from GitHub (by default Core\AutoCorrectHotstrings (1).ahk).

Your library is backed up to Backup\<date_time>\ first, and the merge can be undone from the
Updater ("Undo a previous update").  A report is saved in the Debug folder.
*/

AppTitle := "Library Merge"
SplitPath(A_ScriptDir, , &InstallDir)
SettingsFile := InstallDir "\Data\acSettings.ini"
BaselineRel := "Data\AutoCorrectHotstrings.base.txt"

MainLibName := IniRead(SettingsFile, "Files", "HotstringLibrary", "AutoCorrectHotstrings.ahk")
CopyLibName := IniRead(SettingsFile, "Files", "NewTemporaryHotstrLib", "AutoCorrectHotstrings (1).ahk")
RemovedFile := InstallDir "\Data\" IniRead(SettingsFile, "Files", "RemovedHsFile", "RemovedHotstrings.txt")
FontSize := IniRead(SettingsFile, "HotstringHelper", "DefaultFontSize", "11")
FormColor := "0xE5E4E2", FontColor := "c0x1F1F1F", ListColor := "0xFFFFFF"
ctFile := InstallDir "\Data\colorThemeSettings.ini"
if FileExist(ctFile) {
    FormColor := IniRead(ctFile, "ColorSettings", "formColor", FormColor)
    FontColor := "c" IniRead(ctFile, "ColorSettings", "fontColor", "0x1F1F1F")
    ListColor := IniRead(ctFile, "ColorSettings", "listColor", ListColor)
}

g := Gui("+AlwaysOnTop", AppTitle)
g.BackColor := FormColor
g.SetFont("s" FontSize " " FontColor)
g.OnEvent("Close", (*) => ExitApp())
g.OnEvent("Escape", (*) => ExitApp())
g.Add("Text", "x10 y10 w760", "Merge a newer AutoCorrect library into yours, keeping your own additions, edits and deletions.")

edBase := AddFileRow("Original (as you last got it from GitHub; may be blank):", FileExist(InstallDir "\" BaselineRel) ? InstallDir "\" BaselineRel : "")
edMine := AddFileRow("Yours (this file is updated):", InstallDir "\Core\" MainLibName)
edNew  := AddFileRow("Newer library from GitHub:", FileExist(InstallDir "\Core\" CopyLibName) ? InstallDir "\Core\" CopyLibName : "")

g.Add("Button", "x10 y+16 w140 Default", "Merge...").OnEvent("Click", (*) => DoMerge())
g.Add("Button", "x+10 w100", "Close").OnEvent("Click", (*) => ExitApp())
g.Show()
return

AddFileRow(label, value) {
    g.Add("Text", "x10 y+12 w760", label)
    ed := g.Add("Edit", "x10 y+2 w650 r1", value)
    g.Add("Button", "x+6 w100", "Browse...").OnEvent("Click", (*) => BrowseInto(ed))
    return ed
}

BrowseInto(ed) {
    SplitPath(ed.Value, , &dir)
    f := FileSelect(1, dir != "" ? dir : InstallDir "\Core", "Choose a library file", "AutoHotkey or text (*.ahk; *.txt)")
    if f != ""
        ed.Value := f
}

DoMerge() {
    basePath := Trim(edBase.Value), minePath := Trim(edMine.Value), newPath := Trim(edNew.Value)
    if !FileExist(minePath) || !FileExist(newPath) {
        AcMsgBox.Show("Please choose both your library and the newer library.", AppTitle, 48)
        return
    }
    if basePath != "" && !FileExist(basePath) {
        AcMsgBox.Show("The original file wasn't found:`n" basePath, AppTitle, 48)
        return
    }
    try {
        baseText := basePath = "" ? "" : FileRead(basePath, "UTF-8")
        mineText := FileRead(minePath, "UTF-8")
        newText := FileRead(newPath, "UTF-8")
        res := LibMerge_Run(baseText, mineText, newText, LibMerge_ReadRemoved(RemovedFile))
    } catch as e {
        AcMsgBox.Show("Could not read the libraries:`n" e.Message, AppTitle, 16)
        return
    }
    baseNote := basePath = "" ? "none (every rule that differs is treated as a conflict)" : basePath
    g.Hide()
    style := {formColor: FormColor, fontColor: FontColor, listColor: ListColor, fontSize: FontSize}
    if !LibMerge_Review(res, baseNote, style, AppTitle) {
        g.Show()
        return
    }

    stamp := FormatTime(A_Now, "yyyy-MM-dd_HHmmss")
    sessionDir := InstallDir "\Backup\" stamp
    mineRel := RelOrName(minePath)
    entries := []
    try {
        merged := LibMerge_Build(res)
        enc := IniDoc_DetectEncoding(FileRead(minePath, "RAW"))
        CopyWithDirs(minePath, sessionDir "\" mineRel)
        IniDoc_Write(minePath, merged, enc)
        entries.Push("replaced|" mineRel)
        ; The newer library becomes the original for the next merge.
        basePathNew := InstallDir "\" BaselineRel
        if FileExist(basePathNew) {
            CopyWithDirs(basePathNew, sessionDir "\" BaselineRel)
            entries.Push("replaced|" BaselineRel)
        } else {
            entries.Push("added|" BaselineRel)
        }
        CopyWithDirs(newPath, basePathNew)
    } catch as e {
        AcMsgBox.Show("The merge could not be written:`n" e.Message "`n`nYour library backup is in Backup\" stamp ".", AppTitle, 16)
        ExitApp
    }

    ; A manifest in the Updater's format, so "Undo a previous update" can undo this merge too.
    mf := sessionDir "\UpdateManifest.ini"
    IniWrite(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), mf, "Update", "Date")
    IniWrite("LibraryMerge", mf, "Update", "Kind")
    IniWrite(0, mf, "Update", "Undone")
    IniWrite(entries.Length, mf, "Files", "Count")
    for i, e in entries
        IniWrite(e, mf, "Files", i)

    report := InstallDir "\Debug\LibraryMerge_" stamp ".txt"
    LibMerge_WriteReport(res, report, baseNote)
    AcMsgBox.Show("Done.`n`n" LibMerge_Summary(res) "`n`nYour old library is in Backup\" stamp
        . ", and the merge can be undone from the Updater.`nReport: Debug\LibraryMerge_" stamp ".txt"
        . "`n`nRestart AutoCorrect2 to use the merged library.  Running the Conflicting String Locator now is a good idea.", AppTitle, 64)
    ExitApp
}

RelOrName(path) {
    ; Path relative to the AutoCorrect2 folder (for the backup and the manifest).
    if SubStr(path, 1, StrLen(InstallDir) + 1) = InstallDir "\"
        return SubStr(path, StrLen(InstallDir) + 2)
    SplitPath(path, &name)
    return "Core\" name
}

CopyWithDirs(src, dest) {
    SplitPath(dest, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
    FileCopy(src, dest, 1)
}
