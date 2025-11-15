#Requires AutoHotkey v2.0
#SingleInstance Force

/*
AutoCorrect2 Updater Tool
Author: kunkel321
Tool Used: Claude
Version: 11-15-2025 
Intended to use with AutoCorrect2 repo. Run the script, and it will download a 
temporary copy of the repository, then look for files that have been updated.
The script will then offer to replace the old files with the newer versions.
The files listed below as "RarelyUpdated" will be unchecked by default.  The user
must check them to update them.  Any new files will be listed in the dialog 
separately. HotstringLib.ahk is a special case and never gets over-written.  
Instead, the user should keep a copy of "HotstringLib_DoNotRemove.ahk" in the
Core\ folder.  The Updater script will compare against that file and update it 
if a newer version is on GitHub.  The user must then use the UniueStringExtracter
to compare that file with their own.  
*/

; --- CONFIG ---------------------------------------------------------------
; URL of zip containing the latest version of your repo
LatestZipUrl  := "https://github.com/kunkel321/AutoCorrect2/archive/refs/heads/main.zip"

; Name of root folder inside the zip
ZipRootFolderName := "AutoCorrect2-main"

; Optional: Enable debug logging to file
EnableDebugLog := 0

; Files that will appear in update dialog but unchecked by default
RarelyUpdated := [
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

UpdateProgress(gui, textCtrl, progressBar, statusText, progressValue := 0) {
    gui.Title := "AutoCorrect2 Updater - " statusText
    textCtrl.Value := statusText
    progressBar.Value := progressValue
}

try {
    LogDebug("=== Update Started ===")
    LogDebug("Script Directory: " A_ScriptDir)
    
    ; --- Read configuration file for HotstringLib filename ---
    settingsFile := A_ScriptDir "\..\Data\acSettings.ini"
    hotstringLibName := IniRead(settingsFile, "Files", "NewTemporaryHotstrLib", "HotstringLib (1).ahk")
    LogDebug("HotstringLib name: " hotstringLibName)
    
    ; --- Create progress GUI ---
    progressGui := Gui()
    progressGui.Title := "AutoCorrect2 Updater"
    progressGui.Opt("+AlwaysOnTop")
    statusTextCtrl := progressGui.Add("Text", "w400 h30 cBlue", "Initializing...")
    progressBarCtrl := progressGui.Add("Progress", "w400 h20 vMyProgress Range0-100", 0)
    progressGui.Show("w420 h100")
    
    UpdateProgress(progressGui, statusTextCtrl, progressBarCtrl, "Connecting to GitHub...", 20)

    installDir   := parentDir
    tempDir      := A_Temp "\AutoCorrect2_Update"
    zipFile      := tempDir "\AutoCorrect2_latest.zip"
    extractDir   := tempDir "\extracted"

    LogDebug("Install Dir: " installDir)
    LogDebug("Temp Dir: " tempDir)

    ; Clean temp directory
    LogDebug("Cleaning temp directory...")
    UpdateProgress(progressGui, statusTextCtrl, progressBarCtrl, "Cleaning temporary files...", 40)
    if DirExist(tempDir)
        DirDelete tempDir, 1
    DirCreate tempDir
    DirCreate extractDir
    LogDebug("Temp directory created.")

    ; --- Download latest zip ---
    LogDebug("Downloading from: " LatestZipUrl)
    UpdateProgress(progressGui, statusTextCtrl, progressBarCtrl, "Downloading from GitHub...", 60)
    
    try {
        Download(LatestZipUrl, zipFile)
    } catch Error as e {
        progressGui.Destroy()
        throw Error("Failed to download from GitHub. Please check your internet connection.`n`nError: " e.Message)
    }
    LogDebug("Download completed.")

    ; --- Extract zip using Shell.Application COM ---
    LogDebug("Starting zip extraction...")
    UpdateProgress(progressGui, statusTextCtrl, progressBarCtrl, "Extracting files from zip...", 80)
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

    ; --- Build rarely-updated map for categorizing file changes ---
    UpdateProgress(progressGui, statusTextCtrl, progressBarCtrl, "Analyzing changes...", 100)
    LogDebug("Building rarely-updated map...")
    rarelyUpdatedMap := Map()
    
    for rel in RarelyUpdated {
        full := NormalizePath(installDir "\" rel)
        rarelyUpdatedMap[full] := true
        LogDebug("Rarely updated (offer unchecked): " full)
    }

    ; --- Scan for updated and new files ---
    LogDebug("Scanning for updated and new files...")
    updatedFiles := []
    rarelyUpdatedFiles := []
    newFiles := []
    hotstringLibUpdate := ""  ; Special handling for HotstringLib.ahk
    
    loop Files, srcRoot "\*", "FR"
    {
        srcFile := A_LoopFileFullPath

        ; Skip directories
        if InStr(A_LoopFileAttrib, "D")
            continue

        ; Compute relative path from srcRoot
        relPath := SubStr(srcFile, StrLen(srcRoot) + 2)
        destPath := installDir "\" relPath
        normalizedDest := NormalizePath(destPath)

        ; Special handling for HotstringLib.ahk
        if (relPath = "Core\HotstringLib.ahk") {
            LogDebug("Found HotstringLib.ahk in GitHub")
            ; Always save with the configured name, never replace user's original
            destPath := installDir "\Core\" hotstringLibName
            
            ; Check if it differs from existing version
            if FileExist(destPath) {
                srcSize := FileGetSize(srcFile)
                destSize := FileGetSize(destPath)
                srcTime := FileGetTime(srcFile)
                destTime := FileGetTime(destPath)
                
                if (srcTime > destTime) and (srcSize != destSize) {
                    hotstringLibUpdate := {path: destPath, relPath: "Core\" hotstringLibName, srcPath: srcFile}
                    LogDebug("HotstringLib.ahk update available - will save as: " hotstringLibName)
                }
            } else {
                hotstringLibUpdate := {path: destPath, relPath: "Core\" hotstringLibName, srcPath: srcFile}
                LogDebug("HotstringLib.ahk (" hotstringLibName ") is new/missing")
            }
            continue
        }

        ; Check if file is new or updated
        if !FileExist(destPath) {
            ; Skip HotstringLib.ahk - it's handled specially above
            if (relPath = "Core\HotstringLib.ahk") {
                LogDebug("Skipping HotstringLib.ahk from new files (handled specially)")
                continue
            }
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
                ; Check if this is a rarely-updated file
                if rarelyUpdatedMap.Has(normalizedDest) {
                    rarelyUpdatedFiles.Push({path: destPath, relPath: relPath, srcPath: srcFile})
                    LogDebug("Rarely-updated file found (unchecked by default): " relPath)
                } else {
                    updatedFiles.Push({path: destPath, relPath: relPath, srcPath: srcFile})
                    LogDebug("Updated file found: " relPath " (size: " destSize " → " srcSize ")")
                }
            }
        }
    }

    LogDebug("Found " updatedFiles.Length " updated files, " rarelyUpdatedFiles.Length " rarely-updated files, " newFiles.Length " new files, and HotstringLib update: " (hotstringLibUpdate != "" ? "yes" : "no"))

    ; Check if there are any updates
    if updatedFiles.Length = 0 and rarelyUpdatedFiles.Length = 0 and newFiles.Length = 0 and hotstringLibUpdate = "" {
        LogDebug("No updates available.")
        progressGui.Destroy()
        MsgBox "No updates available.", "AutoCorrect2 Updater"
        ExitApp
    }

    ; Close progress GUI and show update selection GUI
    progressGui.Destroy()
    ; Show GUI with checkboxes
    ShowUpdateGui(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, hotstringLibName, installDir)

} catch Error as e {
    LogDebug("ERROR: " e.Message)
    try progressGui.Destroy()  ; Try to close if it exists
    
    ; Provide user-friendly error messages
    errorMsg := "Update failed"
    if InStr(e.Message, "internet connection") or InStr(e.Message, "Failed to download") {
        errorMsg := "Unable to connect to GitHub. Please check your internet connection and try again."
    } else if InStr(e.Message, "not found in extracted zip") {
        errorMsg := "The downloaded file appears to be corrupted or incomplete. Please try again."
    } else {
        errorMsg := e.Message
    }
    
    MsgBox errorMsg, "AutoCorrect2 Updater", "Iconx"
    ExitApp
}

ShowUpdateGui(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, hotstringLibName, installDir) {
    myGui := Gui()
    myGui.Title := "AutoCorrect2 - Select Updates"
    myGui.Opt("+AlwaysOnTop")

    myGui.Add("Text", "w700", "Review and select files to update:")
    myGui.Add("Text", "w700 h2")  ; Separator

    lvUpdated := ""
    lvRarelyUpdated := ""
    lvNew := ""
    lvHotstringLib := ""

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

    ; Show rarely-updated files with checkboxes (unchecked by default)
    if rarelyUpdatedFiles.Length > 0 {
        myGui.Add("Text", "w700 cBlack y+10", "Configuration files (" rarelyUpdatedFiles.Length ") - optional:")
        lvRarelyUpdated := myGui.Add("ListView", "w700 r4 Checked -Multi", ["Filename", "Path"])
        
        for item in rarelyUpdatedFiles {
            lvRarelyUpdated.Add("", SubStr(item.relPath, InStr(item.relPath, "\") + 1), item.relPath)
        }
        
        lvRarelyUpdated.ModifyCol(1, 200)
        lvRarelyUpdated.ModifyCol(2, 500)
    }

    ; Show new files with checkboxes (checked by default)
    if newFiles.Length > 0 {
        myGui.Add("Text", "w700 cGreen y+10", "New files (" newFiles.Length "):")
        lvNew := myGui.Add("ListView", "w700 r8 Checked -Multi", ["Filename", "Path"])
        
        for item in newFiles {
            lvNew.Add("Check", SubStr(item.relPath, InStr(item.relPath, "\") + 1), item.relPath)
        }
        
        lvNew.ModifyCol(1, 200)
        lvNew.ModifyCol(2, 500)
        
        ; Pre-check all new items
        loop lvNew.GetCount()
            lvNew.Modify(A_Index, "+Check")
    }

    ; Show HotstringLib update (special handling)
    if hotstringLibUpdate != "" {
        myGui.Add("Text", "w700 cBlack y+10", "Hotstring Library Update:")
        myGui.Add("Text", "w700", "A new version of HotstringLib.ahk is available. It will be saved as:`nCore\" hotstringLibName "`n`nYour current HotstringLib.ahk will not be modified. Use UniqueStringExtractor.ahk to compare and merge custom hotstrings.", )
        lvHotstringLib := myGui.Add("ListView", "w700 r2 Checked -Multi", ["Filename", "Path"])
        lvHotstringLib.Add("", hotstringLibName, "Core\" hotstringLibName)
        lvHotstringLib.ModifyCol(1, 200)
        lvHotstringLib.ModifyCol(2, 500)
    }

    ; Buttons
    myGui.Add("Button", "w100 y+10", "Update").OnEvent("Click", (*) => PerformUpdate(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, installDir, myGui, lvUpdated, lvRarelyUpdated, lvNew, lvHotstringLib))
    myGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (*) => ExitApp())

    myGui.Show()
}

PerformUpdate(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, installDir, myGui, lvUpdated, lvRarelyUpdated, lvNew, lvHotstringLib) {
    LogDebug("Starting file copy...")
    LogDebug("lvUpdated: " (lvUpdated != "" ? "exists" : "null"))
    LogDebug("lvRarelyUpdated: " (lvRarelyUpdated != "" ? "exists" : "null"))
    LogDebug("lvNew: " (lvNew != "" ? "exists" : "null"))
    LogDebug("lvHotstringLib: " (lvHotstringLib != "" ? "exists" : "null"))
    
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

    ; Copy checked rarely-updated files
    if lvRarelyUpdated != "" {
        LogDebug("Processing rarely-updated files...")
        rowNum := 0
        loop {
            rowNum := lvRarelyUpdated.GetNext(rowNum, "C")  ; "C" for checked rows
            if rowNum = 0
                break
            
            LogDebug("Found checked row: " rowNum)
            if rowNum <= rarelyUpdatedFiles.Length {
                file := rarelyUpdatedFiles[rowNum]
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

    ; Handle HotstringLib update (checked = copy, unchecked = skip)
    if lvHotstringLib != "" {
        LogDebug("Processing HotstringLib...")
        rowNum := lvHotstringLib.GetNext(0, "C")  ; Check first (and only) row
        if rowNum = 1 {
            LogDebug("Copying: " hotstringLibUpdate.relPath)
            CopyFileWithDirCreation(hotstringLibUpdate.srcPath, hotstringLibUpdate.path)
            LogDebug("Added: " hotstringLibUpdate.relPath)
        } else {
            LogDebug("HotstringLib update skipped by user")
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
