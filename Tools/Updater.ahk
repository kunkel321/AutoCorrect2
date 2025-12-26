#Requires AutoHotkey v2.0
#SingleInstance Force

; #Include custom message box -- Required.
#Include "..\Includes\AcMsgBox.ahk"

/*
AutoCorrect2 Updater Tool
Author: kunkel321
Tool Used: Claude
Version: 12-13-2025 
Intended to use with AutoCorrect2 repo. Run the script, and it will download a temporary copy of the repository, then look for files that have been updated.  The script makes this faster by saving a 'LastUpdateCheck.ini' file in the Core\ folder.  Then it checks the github commits page, and compares to the ini date.  If a newer version is found, only then is the zip downloaded and opened.  The script will then offer to replace the old files with the newer versions.  The files listed below as "RarelyUpdated" will be unchecked by default.  The user must check them to update them.  Any new files will be listed in a separate dialog.  

HotstringLib.ahk is a special case and never gets over-written by default. Instead, a copy called  "HotstringLib (1).ahk" is saved to the Core\ folder.  The user must then use the UniueStringExtracter to compare that file with their own.  If the user NEVER customizes their HotstringLib.ahk file, and only wants to adopt the newer version, they can select the radio button to *Overwrite* their existing lib file.  The font is made red to ensure that the user sees what they are doing. 
*/

; --- CONFIG ---------------------------------------------------------------
; GitHub API endpoint for checking latest commit
GitHubApiUrl  := "https://api.github.com/repos/kunkel321/AutoCorrect2/commits?per_page=1"

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
debugDir := parentDir "\Debug"
debugFile := debugDir "\Updater_debug.txt"

LogDebug(msg) {
    if EnableDebugLog {
        ; Ensure Debug folder exists before attempting to write
        if !DirExist(debugDir) {
            try {
                DirCreate(debugDir)
            } catch Error as e {
                ; Silently fail if we can't create debug folder
                return
            }
        }
        
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        try {
            FileAppend("[" timestamp "] " msg "`n", debugFile)
        } catch Error as e {
            ; Silently fail if we can't write debug log
        }
    }
}

CheckGitHubForUpdates() {
    ; Checks GitHub API for the latest commit info.
    ; Returns an object with {sha, date} on success, or error string on failure
    try {
        LogDebug("Checking GitHub API for latest commit...")
        
        ; Create HTTP request
        http := ComObject("MSXML2.XMLHTTP")
        http.Open("GET", GitHubApiUrl, false)
        http.SetRequestHeader("User-Agent", "AutoCorrect2-Updater")
        http.Send()
        
        if http.Status != 200 {
            return "GitHub API returned status " http.Status
        }
        
        ; Parse JSON response
        responseText := http.ResponseText
        LogDebug("GitHub API response received, parsing JSON...")
        LogDebug("Response length: " StrLen(responseText))
        LogDebug("First 500 chars: " SubStr(responseText, 1, 500))
        
        ; Extract sha and date using simple string parsing
        ; GitHub API format: "sha": "abcd1234...", "author": {"date": "2025-01-15T12:34:56Z"}
        sha := ""
        date := ""
        
        ; Extract SHA (commit hash)
        shaPos := InStr(responseText, '"sha"')
        LogDebug("shaPos: " shaPos)
        if shaPos > 0 {
            quotePos := InStr(responseText, '"',, shaPos + 5)
            LogDebug("First quote after sha: " quotePos)
            if quotePos > 0 {
                startPos := quotePos + 1
                endQuotePos := InStr(responseText, '"',, startPos)
                LogDebug("End quote: " endQuotePos)
                if endQuotePos > 0 {
                    sha := SubStr(responseText, startPos, endQuotePos - startPos)
                }
            }
        }
        
        ; Extract commit date
        ; JSON format: "date":"2025-11-17T..."
        datePos := InStr(responseText, '"date"')
        LogDebug("datePos: " datePos)
        if datePos > 0 {
            ; Find the colon after "date"
            colonPos := InStr(responseText, ":",, datePos)
            LogDebug("colonPos: " colonPos)
            ; Find the quote after the colon
            if colonPos > 0 {
                quotePos := InStr(responseText, '"',, colonPos)
                LogDebug("Quote after colon: " quotePos)
                if quotePos > 0 {
                    startPos := quotePos + 1
                    endQuotePos := InStr(responseText, '"',, startPos)
                    LogDebug("End quote: " endQuotePos)
                    if endQuotePos > 0 {
                        date := SubStr(responseText, startPos, endQuotePos - startPos)
                    }
                }
            }
        }
        
        LogDebug("Extracted SHA: " sha)
        LogDebug("Extracted date: " date)
        
        if sha = "" or date = "" {
            return "Could not parse GitHub API response"
        }
        
        LogDebug("Latest commit: SHA=" sha ", Date=" date)
        result := Map()
        result["sha"] := sha
        result["date"] := date
        return result
        
    } catch Error as e {
        return e.Message
    }
}

GetLastUpdateCheckInfo() {
    ; Reads the stored update check info from Data\LastUpdateCheck.ini
    ; Returns a Map with {sha, date} or empty Map if file doesn't exist
    checkFile := A_ScriptDir "\..\Data\LastUpdateCheck.ini"
    
    if !FileExist(checkFile) {
        LogDebug("LastUpdateCheck.ini not found - first run or data file missing")
        return Map()
    }
    
    try {
        lastSha := IniRead(checkFile, "UpdateCheck", "LastCommitHash", "")
        lastDate := IniRead(checkFile, "UpdateCheck", "LastCommitDate", "")
        
        if lastSha = "" or lastDate = "" {
            LogDebug("LastUpdateCheck.ini exists but is empty")
            return Map()
        }
        
        LogDebug("Last update check: SHA=" lastSha ", Date=" lastDate)
        result := Map()
        result["sha"] := lastSha
        result["date"] := lastDate
        return result
        
    } catch Error as e {
        LogDebug("Error reading LastUpdateCheck.ini: " e.Message)
        return Map()
    }
}

StoreUpdateCheckInfo(sha, date) {
    ; Stores the latest commit info to Data\LastUpdateCheck.ini
    checkFile := A_ScriptDir "\..\Data\LastUpdateCheck.ini"
    checkDir := A_ScriptDir "\..\Data"
    
    try {
        if !DirExist(checkDir) {
            DirCreate(checkDir)
            LogDebug("Created Data directory")
        }
        
        IniWrite(sha, checkFile, "UpdateCheck", "LastCommitHash")
        IniWrite(date, checkFile, "UpdateCheck", "LastCommitDate")
        IniWrite(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), checkFile, "UpdateCheck", "LastCheckTime")
        LogDebug("Stored update check info: SHA=" sha ", Date=" date)
        
    } catch Error as e {
        LogDebug("Error writing LastUpdateCheck.ini: " e.Message)
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
    
    ; --- Read configuration from settings file ---
    settingsFile := A_ScriptDir "\..\Data\acSettings.ini"
    fontSize := IniRead(settingsFile, "HotstringHelper", "DefaultFontSize", "11")
    largeFontSize := IniRead(settingsFile, "HotstringHelper", "LargeFontSize", "13")
    hotstringLibName := IniRead(settingsFile, "Files", "NewTemporaryHotstrLib", "HotstringLib (1).ahk")
    
    ; Read colors from color theme settings (with defaults)
    formColor := "0xE5E4E2"
    fontColor := "c0x1F1F1F"
    listColor := "0xFFFFFF"
    
    if FileExist(A_ScriptDir "\..\Data\colorThemeSettings.ini") {
        ctSettingsFile := A_ScriptDir "\..\Data\colorThemeSettings.ini"
        formColor := IniRead(ctSettingsFile, "ColorSettings", "formColor", formColor)
        fontColor := "c" IniRead(ctSettingsFile, "ColorSettings", "fontColor", "0x1F1F1F")
        listColor := IniRead(ctSettingsFile, "ColorSettings", "listColor", listColor)
    }
    
    ; Create Config class for AcMsgBox
    class Config {
        static FormColor := formColor
        static FontColor := fontColor
        static LargeFontSize := "s" . largeFontSize
    }
    
    LogDebug("HotstringLib name: " hotstringLibName)
    
    ; --- Create progress GUI ---
    progressGui := Gui()
    progressGui.Title := "AutoCorrect2 Updater"
    progressGui.Opt("+AlwaysOnTop")
    progressGui.BackColor := formColor
    progressGui.SetFont("s" fontSize " " fontColor)
    
    statusTextCtrl := progressGui.Add("Text", "w400 h30 cBlue", "Checking for updates...")
    progressBarCtrl := progressGui.Add("Progress", "w400 h20 vMyProgress Range0-100", 0)
    progressGui.Show("w420 h100")
    
    UpdateProgress(progressGui, statusTextCtrl, progressBarCtrl, "Checking GitHub for updates...", 10)
    
    ; --- Check GitHub API for latest commit ---
    latestInfo := CheckGitHubForUpdates()
    
    if Type(latestInfo) = "String" {
        progressGui.Destroy()
        AcMsgBox.Show("Unable to check GitHub for updates:`n" latestInfo "`n`nPlease check your internet connection and try again.", "AutoCorrect2 Updater")
        LogDebug("GitHub API check failed: " latestInfo)
        ExitApp
    }
    
    ; --- Compare with stored update check info ---
    lastCheckInfo := GetLastUpdateCheckInfo()
    lastSha := ""
    try {
        lastSha := lastCheckInfo["sha"]
    }
    
    if lastSha != "" and lastSha = latestInfo["sha"] {
        LogDebug("No updates available - commit hash matches")
        progressGui.Destroy()
        AcMsgBox.Show("No updates available. You have the latest version!", "AutoCorrect2 Updater")
        ExitApp
    }
    
    LogDebug("Update available! Proceeding with file comparison...")
    
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
        AcMsgBox.Show("No updates available.", "AutoCorrect2 Updater")
        ExitApp
    }

    ; Close progress GUI and show update selection GUI
    progressGui.Destroy()
    ; Show GUI with checkboxes
    ShowUpdateGui(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, hotstringLibName, installDir, latestInfo, fontSize, formColor, fontColor, listColor)

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
    
    AcMsgBox.Show(errorMsg, "AutoCorrect2 Updater")
    ExitApp
}

ShowUpdateGui(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, hotstringLibName, installDir, latestInfo, fontSize, formColor, fontColor, listColor) {
    updateGui := Gui()
    updateGui.Title := "AutoCorrect2 - Select Updates"
    updateGui.Opt("+AlwaysOnTop")
    updateGui.BackColor := formColor
    
    ; Apply font size from settings
    updateGui.SetFont("s" fontSize " " fontColor)

    lvUpdated := ""
    lvNew := ""
    lvHotstringLib := ""
    
    ; Track HotstringLib state (true = append (1), false = replace)
    hotstringLibMode := Map()  ; Will store which radio is selected
    
    ; Build a combined list of all updated files with checked state info
    allUpdatedFiles := []
    rarelyUpdatedMap := Map()
    
    ; Add regularly updated files (will be checked)
    for item in updatedFiles {
        allUpdatedFiles.Push({data: item, shouldCheck: true})
    }
    
    ; Add rarely updated files (will be unchecked) and track them
    for item in rarelyUpdatedFiles {
        allUpdatedFiles.Push({data: item, shouldCheck: false})
        rarelyUpdatedMap[item.path] := true
    }

    ; Show all updated files in one ListView
    if allUpdatedFiles.Length > 0 {
        updateGui.Add("Text", "w700 cBlue", "Updated files (" allUpdatedFiles.Length "):")
        lvUpdated := updateGui.Add("ListView", "w700 r8 Checked -Multi +Background" listColor, ["Filename", "Path"])
        
        for item in allUpdatedFiles {
            if item.shouldCheck {
                lvUpdated.Add("Check", SubStr(item.data.relPath, InStr(item.data.relPath, "\") + 1), item.data.relPath)
            } else {
                lvUpdated.Add("", SubStr(item.data.relPath, InStr(item.data.relPath, "\") + 1), item.data.relPath)
            }
        }
        
        lvUpdated.ModifyCol(1, 200)
        lvUpdated.ModifyCol(2, 500)
        
        ; Pre-check only the regularly updated items
        rowNum := 0
        loop {
            rowNum := lvUpdated.GetNext(rowNum)
            if rowNum = 0
                break
            
            if rowNum <= updatedFiles.Length {
                lvUpdated.Modify(rowNum, "+Check")
            }
        }
    }

    ; Show new files with checkboxes (checked by default)
    if newFiles.Length > 0 {
        updateGui.Add("Text", "w700 cGreen y+8", "New files (" newFiles.Length "):")
        lvNew := updateGui.Add("ListView", "w700 r8 Checked -Multi +Background" listColor, ["Filename", "Path"])
        
        for item in newFiles {
            lvNew.Add("Check", SubStr(item.relPath, InStr(item.relPath, "\") + 1), item.relPath)
        }
        
        lvNew.ModifyCol(1, 200)
        lvNew.ModifyCol(2, 500)
        
        ; Pre-check all new items
        loop lvNew.GetCount()
            lvNew.Modify(A_Index, "+Check")
    }

    ; Show HotstringLib update with radio button options
    if hotstringLibUpdate != "" {
        updateGui.Add("Text", "w700 cBlack y+8", "HotstringLib Update Available")
        
        ; Radio button option 1: Keep as (1), safe for customizers
        radAppend := updateGui.Add("Radio", "w700 h38 Checked vHotstringLibMode", "Save new library as: Core\HotstringLib (1).ahk. Your current HotstringLib.ahk will not be modified. Use UniqueStringExtractor tool to compare and merge.")
        
        ; Radio button option 2: Replace existing, no merge needed
        radReplace := updateGui.Add("Radio", "w700 h38", "WARNING: Replaces your existing HotstringLib.ahk file. Any customizations you've made will be lost, but you won't have to bother merging the old and new versions.")
        
        ; ListView for HotstringLib - initially shows merge mode
        lvHotstringLib := updateGui.Add("ListView", "w700 r2 Checked -Multi +Background" listColor " y+5", ["Filename", "Path"])
        lvHotstringLib.Add("", "HotstringLib (1).ahk", "Core\HotstringLib (1).ahk")
        lvHotstringLib.ModifyCol(1, 200)
        lvHotstringLib.ModifyCol(2, 500)
        
        ; Store the ListView reference in the GUI object for access in event handlers
        updateGui.lvHotstringLib := lvHotstringLib
        updateGui.radReplace := radReplace
        updateGui.fontColor := fontColor
        
        ; Add event handlers to update the ListView filename and color when radio button changes
        radAppend.OnEvent("Click", HotstringLibModeChanged.Bind(updateGui, 1))
        radReplace.OnEvent("Click", HotstringLibModeChanged.Bind(updateGui, 0))
    }

    ; Buttons
    updateGui.Add("Button", "w100 y+8", "Update").OnEvent("Click", (*) => PerformUpdate(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, installDir, updateGui, lvUpdated, lvNew, lvHotstringLib, latestInfo))
    updateGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (*) => ExitApp())

    updateGui.Show()
}

; Event handler for HotstringLib radio button changes
HotstringLibModeChanged(updateGui, mode, GuiCtrlObj, Info) {
    ; Update ListView
    if updateGui.lvHotstringLib != "" {
        updateGui.lvHotstringLib.Delete(1)  ; Delete the existing row
        if mode = 1 {
            ; Mode 1: Append as (1) - merge mode
            updateGui.lvHotstringLib.Add("", "HotstringLib (1).ahk", "Core\HotstringLib (1).ahk")
            LogDebug("Radio mode changed to: MERGE (1)")
        } else {
            ; Mode 2: Replace existing - simple mode
            updateGui.lvHotstringLib.Add("", "HotstringLib.ahk", "Core\HotstringLib.ahk")
            LogDebug("Radio mode changed to: REPLACE")
        }
    }
    
    ; Update radio button font colors for visual warning
    if updateGui.radReplace != "" {
        if mode = 0 {
            ; Replace mode selected - turn text RED as a warning
            updateGui.radReplace.Opt("+cFF0000")
            LogDebug("Replace mode selected - radio button text is RED")
        } else {
            ; Merge mode selected - return to normal font color
            updateGui.radReplace.Opt("+" updateGui.fontColor)
            LogDebug("Merge mode selected - radio button text is normal color")
        }
    }
}

PerformUpdate(updatedFiles, rarelyUpdatedFiles, newFiles, hotstringLibUpdate, installDir, updateGui, lvUpdated, lvNew, lvHotstringLib, latestInfo) {
    LogDebug("Starting file copy...")
    LogDebug("lvUpdated: " (lvUpdated != "" ? "exists" : "null"))
    LogDebug("lvNew: " (lvNew != "" ? "exists" : "null"))
    LogDebug("lvHotstringLib: " (lvHotstringLib != "" ? "exists" : "null"))
    
    ; Get the form values to check which HotstringLib mode was selected
    formValues := updateGui.Submit(0)  ; Submit without destroying the GUI
    
    ; Copy checked files from combined updated files list
    if lvUpdated != "" {
        LogDebug("Processing updated files...")
        rowNum := 0
        rowIndex := 0
        loop {
            rowNum := lvUpdated.GetNext(rowNum, "C")  ; "C" for checked rows
            if rowNum = 0
                break
            
            rowIndex++
            LogDebug("Found checked row: " rowNum)
            
            ; Determine if this row is from updatedFiles or rarelyUpdatedFiles
            if rowNum <= updatedFiles.Length {
                file := updatedFiles[rowNum]
                LogDebug("Copying (updated): " file.relPath)
                CopyFileWithDirCreation(file.srcPath, file.path)
                LogDebug("Updated: " file.relPath)
            } else {
                rarelyIndex := rowNum - updatedFiles.Length
                if rarelyIndex <= rarelyUpdatedFiles.Length {
                    file := rarelyUpdatedFiles[rarelyIndex]
                    LogDebug("Copying (rarely updated): " file.relPath)
                    CopyFileWithDirCreation(file.srcPath, file.path)
                    LogDebug("Updated: " file.relPath)
                }
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

    ; Handle HotstringLib update with mode selection
    if lvHotstringLib != "" {
        LogDebug("Processing HotstringLib...")
        rowNum := lvHotstringLib.GetNext(0, "C")  ; Check first (and only) row
        if rowNum = 1 {
            ; Determine which mode was selected based on radio button value
            ; formValues.HotstringLibMode = 1 means first radio (append as (1), merge mode)
            ; formValues.HotstringLibMode = 0 means second radio (replace existing)
            
            if formValues.HotstringLibMode = 1 {
                ; Mode 1: Keep as HotstringLib (1).ahk - MERGE MODE
                LogDebug("HotstringLib mode: MERGE (append as (1))")
                
                ; Source file from GitHub
                srcFile := hotstringLibUpdate.srcPath
                
                ; Destination: Core\HotstringLib (1).ahk
                destFile := A_ScriptDir "\..\Core\HotstringLib (1).ahk"
                
                LogDebug("Copying (merge mode): " srcFile " -> " destFile)
                CopyFileWithDirCreation(srcFile, destFile)
                LogDebug("Created: HotstringLib (1).ahk (existing HotstringLib.ahk untouched)")
                
            } else {
                ; Mode 2: Replace existing HotstringLib.ahk - REPLACE MODE
                LogDebug("HotstringLib mode: REPLACE (direct replacement)")
                
                ; Source file from GitHub
                srcFile := hotstringLibUpdate.srcPath
                
                ; Destination: Core\HotstringLib.ahk (replacing existing)
                destFile := A_ScriptDir "\..\Core\HotstringLib.ahk"
                
                LogDebug("Copying (replace mode): " srcFile " -> " destFile)
                CopyFileWithDirCreation(srcFile, destFile)
                LogDebug("Replaced: HotstringLib.ahk")
            }
        } else {
            LogDebug("HotstringLib update skipped by user")
        }
    }

    ; Store the latest update check info
    if Type(latestInfo) = "Map" {
        StoreUpdateCheckInfo(latestInfo["sha"], latestInfo["date"])
    }

    LogDebug("=== Update Completed Successfully ===")
    updateGui.Hide()
    AcMsgBox.Show("AutoCorrect2 has been updated successfully!", "AutoCorrect2 Updater")
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
