#Requires AutoHotkey v2.0
#SingleInstance Force

; -----------------------------------------------------------------------
; AutoCorrect2 Updater Tool
; Author: kunkel321
; Tool Used: Claude
; Version: 11-15-2025 
; Intended to use with AutoCorrect2 repo. Run the script, and it will download a 
; temporary copy of the repository, then look for files that have been updated.
; The script will then offer to replace the old files with the newer versions. 
; -----------------------------------------------------------------------

; --- CONFIG ---------------------------------------------------------------
; URL of zip containing the latest version of your repo
LatestZipUrl  := "https://github.com/kunkel321/AutoCorrect2/archive/refs/heads/main.zip"

; Name of root folder inside the zip
ZipRootFolderName := "AutoCorrect2-main"

; Optional: Enable debug logging to file
EnableDebugLog := false

; Files/folders that will NEVER be overwritten
PreserveList := [
    "Core\HotstringLib.ahk",
    "Data\acSettings.ini",
    "Data\AutoCorrectsLog.txt",
    "Data\ManualCorrectionsLog.txt",
    "Data\ErrContextLog.txt"
]
; -----------------------------------------------------------------------

; Setup debug logging
SplitPath(A_ScriptDir, , &parentDir)
debugFile := parentDir "\Debug\Updater_debug.txt"

LogDebug(msg) {
    if EnableDebugLog {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        FileAppend("[" timestamp "] " msg "`n", debugFile)
    }
}

try {
    LogDebug("=== Update Started ===")
    LogDebug("Script Directory: " A_ScriptDir)
    
    MsgBox "Updating AutoCorrect2..." . "`n`nThis may take a moment.", "AutoCorrect2 Updater"

    installDir   := parentDir
    tempDir      := A_Temp "\AutoCorrect2_Update"
    zipFile      := tempDir "\AutoCorrect2_latest.zip"
    extractDir   := tempDir "\extracted"

    LogDebug("Install Dir: " installDir)
    LogDebug("Temp Dir: " tempDir)

    ; Clean temp directory
    LogDebug("Cleaning temp directory...")
    if DirExist(tempDir)
        DirDelete tempDir, 1
    DirCreate tempDir
    DirCreate extractDir
    LogDebug("Temp directory created.")

    ; --- Download latest zip ---
    LogDebug("Downloading from: " LatestZipUrl)
    Download(LatestZipUrl, zipFile)
    LogDebug("Download completed.")

    ; --- Extract zip using Shell.Application COM ---
    LogDebug("Starting zip extraction...")
    sh  := ComObject("Shell.Application")
    zip := sh.NameSpace(zipFile)
    if !zip
        throw Error("Failed to open downloaded zip file.")
    
    dest := sh.NameSpace(extractDir)
    if !dest
        throw Error("Failed to open extraction folder.")
    
    dest.CopyHere(zip.Items, 0x10|0x4)
    LogDebug("Zip extraction completed.")

    ; Verify source root exists
    srcRoot := extractDir "\" ZipRootFolderName
    if !DirExist(srcRoot)
        throw Error("Expected root folder '" ZipRootFolderName "' not found in extracted zip.")
    LogDebug("Source root directory found.")

    ; --- Build preserve map ---
    LogDebug("Building preserve map...")
    preserveMap := Map()
    for rel in PreserveList {
        full := NormalizePath(installDir "\" rel)
        preserveMap[full] := true
        LogDebug("Preserving: " full)
    }

    ; --- Scan for updated and new files ---
    LogDebug("Scanning for updated and new files...")
    updatedFiles := []
    newFiles := []
    
    loop Files, srcRoot "\*", "FR"
    {
        srcFile := A_LoopFileFullPath

        ; Skip directories
        if InStr(A_LoopFileAttrib, "D")
            continue

        ; Compute relative path from srcRoot
        relPath := SubStr(srcFile, StrLen(srcRoot) + 2)
        destPath := installDir "\" relPath

        ; Skip if in PreserveList
        if preserveMap.Has(NormalizePath(destPath)) {
            LogDebug("Skipping (preserved): " relPath)
            continue
        }

        ; Check if file is new or updated
        if !FileExist(destPath) {
            ; New file
            newFiles.Push({path: destPath, relPath: relPath, srcPath: srcFile})
            LogDebug("New file found: " relPath)
        } else {
            ; File exists - compare size and modification time
            srcSize := FileGetSize(srcFile)
            destSize := FileGetSize(destPath)
            srcTime := FileGetTime(srcFile)
            destTime := FileGetTime(destPath)
            
            ; Only consider updated if BOTH timestamp is newer AND file size changed
            if (srcTime > destTime) and (srcSize != destSize) {
                ; Source is newer with different size
                updatedFiles.Push({path: destPath, relPath: relPath, srcPath: srcFile})
                LogDebug("Updated file found: " relPath " (size: " destSize " → " srcSize ")")
            }
        }
    }

    LogDebug("Found " updatedFiles.Length " updated files and " newFiles.Length " new files.")

    ; Check if there are any updates
    if updatedFiles.Length = 0 and newFiles.Length = 0 {
        LogDebug("No updates available.")
        MsgBox "No updates available.", "AutoCorrect2 Updater"
        ExitApp
    }

    ; Show GUI with checkboxes
    ShowUpdateGui(updatedFiles, newFiles, installDir)

} catch Error as e {
    LogDebug("ERROR: " e.Message)
    MsgBox "Update failed:`n" e.Message, "AutoCorrect2 Updater", "Iconx"
    ExitApp
}

ShowUpdateGui(updatedFiles, newFiles, installDir) {
    myGui := Gui()
    myGui.Title := "AutoCorrect2 - Select Updates"
    myGui.Opt("+AlwaysOnTop")

    myGui.Add("Text", "w700", "Review and select files to update:")
    myGui.Add("Text", "w700 h2")  ; Separator

    lvUpdated := ""
    lvNew := ""

    ; Show updated files with checkboxes (pre-checked)
    if updatedFiles.Length > 0 {
        myGui.Add("Text", "w700 cBlue", "Updated files (" updatedFiles.Length "):")
        lvUpdated := myGui.Add("ListView", "w700 r8 Checked -Multi", ["Filename", "Path"])
        
        for item in updatedFiles {
            lvUpdated.Add("Check", SubStr(item.relPath, InStr(item.relPath, "\") + 1), item.relPath)
        }
        
        lvUpdated.ModifyCol(1, 200)
        lvUpdated.ModifyCol(2, 500)
        
        ; Pre-check all updated items
        loop lvUpdated.GetCount()
            lvUpdated.Modify(A_Index, "+Check")
    }

    ; Show new files with checkboxes (unchecked by default)
    if newFiles.Length > 0 {
        myGui.Add("Text", "w700 cGreen y+10", "New files (" newFiles.Length ") - optional:")
        lvNew := myGui.Add("ListView", "w700 r8 Checked -Multi", ["Filename", "Path"])
        
        for item in newFiles {
            lvNew.Add("", SubStr(item.relPath, InStr(item.relPath, "\") + 1), item.relPath)
        }
        
        lvNew.ModifyCol(1, 200)
        lvNew.ModifyCol(2, 500)
    }

    ; Buttons
    myGui.Add("Button", "w100 y+10", "Update").OnEvent("Click", (*) => PerformUpdate(updatedFiles, newFiles, installDir, myGui, lvUpdated, lvNew))
    myGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (*) => ExitApp())

    myGui.Show()
}

PerformUpdate(updatedFiles, newFiles, installDir, myGui, lvUpdated, lvNew) {
    LogDebug("Starting file copy...")
    LogDebug("lvUpdated: " (lvUpdated != "" ? "exists" : "null"))
    LogDebug("lvNew: " (lvNew != "" ? "exists" : "null"))
    
    ; Copy checked updated files
    if lvUpdated != "" {
        LogDebug("Processing updated files...")
        rowNum := 0
        loop {
            rowNum := lvUpdated.GetNext(rowNum, "C")  ; "C" for checked rows
            if rowNum = 0
                break
            
            LogDebug("Found checked row: " rowNum)
            if rowNum <= updatedFiles.Length {
                file := updatedFiles[rowNum]
                LogDebug("Copying: " file.relPath)
                CopyFileWithDirCreation(file.srcPath, file.path)
                LogDebug("Updated: " file.relPath)
            }
        }
    }

    ; Copy checked new files
    if lvNew != "" {
        LogDebug("Processing new files...")
        rowNum := 0
        loop {
            rowNum := lvNew.GetNext(rowNum, "C")  ; "C" for checked rows
            if rowNum = 0
                break
            
            LogDebug("Found checked row: " rowNum)
            if rowNum <= newFiles.Length {
                file := newFiles[rowNum]
                LogDebug("Copying: " file.relPath)
                CopyFileWithDirCreation(file.srcPath, file.path)
                LogDebug("Added: " file.relPath)
            }
        }
    }

    LogDebug("=== Update Completed Successfully ===")
    myGui.Hide()
    MsgBox "AutoCorrect2 has been updated successfully!"
    ExitApp
}

CopyFileWithDirCreation(srcFile, destPath) {
    SplitPath(destPath, , &outDir)
    if !DirExist(outDir)
        DirCreate(outDir)
    FileCopy(srcFile, destPath, 1)
}

NormalizePath(path) {
    path := StrReplace(path, "/", "\")
    while SubStr(path, -0) = "\"
        path := SubStr(path, 1, -1)
    return StrLower(path)
}
