#Requires AutoHotkey v2.0
#SingleInstance Force

; #Include custom message box -- Required.
#Include "..\Includes\AcMsgBox.ahk"
; INI merging (shared with SettingsDefaultsMaker) -- Required.
#Include "..\Includes\IniMerge.ahk"
; Three-way hotstring library merge (shared with LibraryMerge) -- Required.
#Include "..\Includes\LibMerge.ahk"

/*
AutoCorrect2 Updater Tool
Author: kunkel321
Tool Used: Claude
Version: 11-24-2026 g  (also set UpdaterVersion below)
Intended to use with AutoCorrect2 repo.

HOW IT WORKS
- Asks GitHub for the latest commit and compares it with Data\LastUpdateCheck.ini.  If nothing
  is new (and nothing was left unticked last time), it stops there without downloading.
- Asks GitHub which files changed since your last update, and shows the commit messages for
  those changes in a "What's new" list.  (Double-click a commit to open it on GitHub.)
- Downloads the zip, then compares file CONTENTS (not dates) with your copies.  Text files that
  differ only in line endings count as the same.
- Only files that changed on GitHub since your last update are ticked.  Files that differ from
  GitHub but did not change there are probably your own edits; they are listed last, unticked.
- Files removed from (or renamed in) the repository are offered for removal.  "Removed" means
  moved into the backup folder, so it can be undone.

YOUR FILES ARE NEVER OVERWRITTEN
- ProtectedFiles (below) are only copied if you don't have them yet: your settings, your
  Personal (boilerplate) library, color theme, API key, window positions and so on.
- IgnoredFiles are never copied at all: logs, Debug\, Backup\, LastUpdateCheck.ini, etc.
- AutoCorrectHotstrings.ahk is MERGED by default (see Includes\LibMerge.ahk): the user's added,
  edited and deleted rules are kept, GitHub's new, changed, removed and moved rules are applied,
  and rules changed on both sides are shown for the user to choose.  Nothing is written until the
  user clicks Merge in the review window.  The merge needs the library as the user last got it:
  that is saved as Data\AutoCorrectHotstrings.base.txt after each merge or replace.  The first
  time, the Updater looks through recent GitHub versions for the one closest to the user's file.
- The other choices: save GitHub's library under the "NewTemporaryHotstrLib" name (for the Unique
  String Extractor or Tools\LibraryMerge.ahk), or replace the user's library (shown in red).

SETTINGS ARE MERGED, NOT REPLACED
- acSettings.ini is never copied over.  Instead, settings that are new in the repository's
  Data\acSettings.default.ini are added to the user's acSettings.ini (with their comments), and
  existing values are left exactly as they are.  Renamed keys carry the user's value over (see
  [UpdaterRenames] in the defaults file).  Double-click the settings row to see what will change.
- A user with no acSettings.ini gets a copy of acSettings.default.ini.
- Steve: build acSettings.default.ini with Tools\SettingsDefaultsMaker.ahk before pushing.

BACKUP AND UNDO
- Before any file is replaced or removed, the old copy is saved to Backup\<date_time>\, along
  with UpdateManifest.ini, a record of what the update did.
- "Undo a previous update" (or running Updater with /undo) puts those files back, moves out the
  files the update added, and resets LastUpdateCheck.ini so the update is offered again.

PENDING FILES
- Files you leave unticked are remembered (if the box is ticked) and offered again next time,
  UNTICKED, so a deliberate "no" stays a "no" unless you change it.
*/

; --- CONFIG ---------------------------------------------------------------
RepoOwner := "kunkel321"
RepoName  := "AutoCorrect2"
Branch    := "main"
ApiBase   := "https://api.github.com/repos/" RepoOwner "/" RepoName
LatestZipUrl := "https://github.com/" RepoOwner "/" RepoName "/archive/refs/heads/" Branch ".zip"
ZipRootFolderName := RepoName "-" Branch   ; Name of root folder inside the zip

EnableDebugLog := 1          ; Log to Debug\Updater_debug.txt
CommitListLength := 15       ; How many recent commits to show when "new since last update" is unknown
ShowLocallyDifferentFiles := true  ; List files that differ from GitHub but didn't change there (unticked)

; Folders whose updated files appear unticked by default
RarelyUpdatedFolders := ["Data\"]

; Never copied, even if missing.  Paths are relative to the AutoCorrect2 folder; * and ? are wildcards.
IgnoredFiles := [
    "Debug\*",
    "Backup\*",
    ".git*",
    "Data\LastUpdateCheck.ini",
    "Data\*Log*.txt",            ; AutoCorrectsLog, ManualCorrectionsLog, ErrContextLog, ACLog/MCLogContinuous
    "Data\RemovedHotstrings.txt",
    "Data\*.base.txt"           ; saved originals for the library merge
]

; Copied only if the user doesn't have the file yet; never replaced or removed.
; (The Personal library and NewTemporaryHotstrLib names from acSettings.ini are added below.)
ProtectedFiles := [
    "Data\acSettings.ini",
    "Data\colorThemeSettings.ini",
    "Data\PersonalApiKey.ini",
    "Data\hhWindowPos.ini",
    "Data\HotkeyHub_usage.ini",
    "Data\PersonalHolidays.txt"
]

; INI files that are merged instead of copied (see "SETTINGS ARE MERGED" above).
MergedIniFiles := [
    {defaults: "Data\acSettings.default.ini", target: "Data\acSettings.ini"}
]

; Files the Updater itself needs.  When they change they are always updated (they can't be unticked).
UpdaterDependencies := ["Includes\AcMsgBox.ahk", "Includes\IniMerge.ahk", "Includes\LibMerge.ahk"]

; The library as the user last got it from GitHub (the "original" for the three-way merge)
BaselineRel := "Data\AutoCorrectHotstrings.base.txt"

; File types compared as text (line-ending differences ignored)
TextExtensions := ["ahk", "txt", "ini", "json", "md", "csv", "tsv"]
; --------------------------------------------------------------------------

UpdaterVersion := "11-24-2026 g"    ; Shown in title bars and the debug log
AppTitle := "AutoCorrect2 Updater (" UpdaterVersion ")"
SplitPath(A_ScriptDir, , &InstallDir)
DebugDir   := InstallDir "\Debug"
DebugFile  := DebugDir "\Updater_debug.txt"
CheckFile  := InstallDir "\Data\LastUpdateCheck.ini"
SettingsFile := InstallDir "\Data\acSettings.ini"
BackupDir  := InstallDir "\Backup"
UpstreamLibRel := "Core\AutoCorrectHotstrings.ahk"

Cfg := LoadSettings()
ProtectedFiles.Push("Core\" Cfg.PersonalLibName, "Core\" Cfg.CopyLibName)
IgnoredRx   := GlobsToRegex(IgnoredFiles)
ProtectedRx := GlobsToRegex(ProtectedFiles)
MergeTargets := NewMap()
for pair in MergedIniFiles
    MergeTargets[pair.target] := pair.defaults
DependencySet := NewMap()
for dep in UpdaterDependencies
    DependencySet[dep] := true
TextExts := NewMap()
for ext in TextExtensions
    TextExts[ext] := true
Prog := ""
DeferredCopies := []
OnExit(RunDeferredCopies)

try {
    Main()
} catch as e {
    LogDebug("ERROR: " e.Message " (line " e.Line ")")
    CloseProgress()
    errorMsg := e.Message
    if InStr(e.Message, "internet connection") or InStr(e.Message, "Failed to download")
        errorMsg := "Unable to connect to GitHub. Please check your internet connection and try again."
    else if InStr(e.Message, "not found in extracted zip")
        errorMsg := "The downloaded file appears to be corrupted or incomplete. Please try again."
    AcMsgBox.Show(errorMsg, AppTitle)
    ExitApp
}

; ==========================================================================
; MAIN FLOW
; ==========================================================================
Main() {
    global Prog
    LogDebug("=== Updater " UpdaterVersion " started (" A_ScriptDir ") ===")

    if A_Args.Length && (A_Args[1] = "/undo" || A_Args[1] = "-undo") {
        ShowUndoGui()
        return
    }

    Prog := MakeProgressGui()
    SetProgress("Checking GitHub for updates...", 10)

    recent := GetRecentCommits()
    if Type(recent) = "String" {
        CloseProgress()
        LogDebug("GitHub check failed: " recent)
        AcMsgBox.Show("Unable to check GitHub for updates:`n" recent "`n`nPlease check your internet connection and try again.", AppTitle)
        ExitApp
    }
    latest := recent[1]
    last := ReadLastCheck()
    LogDebug("Latest: " latest.sha " | Last: " last.sha " | Pending: " last.pending.Length)

    if (last.sha != "" && last.sha = latest.sha && last.pending.Length = 0) {
        CloseProgress()
        NoUpdatesMessage("No updates available. You have the latest version!")
        return
    }

    ctx := {haveCompare: false, changed: NewMap(), removedUp: [], pending: NewMap()
        , commits: [], header: "", last: last, latest: latest}
    for p in last.pending
        ctx.pending[p] := true

    if last.sha = "" {
        ctx.commits := recent
        ctx.header := "Recent changes on GitHub:"
    } else if last.sha = latest.sha {
        ctx.haveCompare := true
        ctx.header := "No new changes on GitHub since your last update."
    } else {
        SetProgress("Reading what changed since your last update...", 20)
        cmp := GetCompare(last.sha, latest.sha)
        if Type(cmp) = "String" {
            LogDebug("Compare failed: " cmp)
            ctx.commits := recent
            ctx.header := "Recent changes on GitHub (couldn't tell which ones are new to you):"
        } else {
            ctx.commits := cmp.commits
            ctx.changed := cmp.changed
            ctx.removedUp := cmp.removed
            ctx.haveCompare := !cmp.truncated
            n := cmp.commits.Length
            ctx.header := n " change" (n = 1 ? "" : "s") " since your last update"
                . (cmp.total > n ? " (showing " n " of " cmp.total ")" : "") ":"
            LogDebug("Compare: " n " commits, " cmp.changed.Count " changed, " cmp.removed.Length " removed, truncated=" cmp.truncated)
        }
    }

    SetProgress("Downloading from GitHub...", 40)
    srcRoot := DownloadAndExtract()

    SetProgress("Comparing files...", 90)
    scan := ScanForUpdates(srcRoot, ctx)
    CloseProgress()
    LogDebug("Scan: " scan.items.Length " item(s), library: " (IsObject(scan.lib) ? "yes" : "no"))

    if scan.items.Length = 0 && !IsObject(scan.lib) {
        StoreLastCheck(latest.sha, latest.date, [])
        NoUpdatesMessage("No files need updating. You have the latest version!")
        return
    }
    ShowUpdateGui(scan, ctx)
}

NoUpdatesMessage(msg) {
    ; Offers Undo when there is an update that can still be undone.
    if IsObject(LatestUndoableSession()) {
        if AcMsgBox.Show(msg, AppTitle, ["OK", "Undo last update"]) = "Undo last update" {
            ShowUndoGui()
            return
        }
    } else {
        AcMsgBox.Show(msg, AppTitle)
    }
    ExitApp
}

; ==========================================================================
; GITHUB
; ==========================================================================
HttpGet(url) {
    try {
        http := ComObject("MSXML2.XMLHTTP")
        http.Open("GET", url, false)
        http.SetRequestHeader("User-Agent", "AutoCorrect2-Updater")
        http.SetRequestHeader("Accept", "application/vnd.github+json")
        http.SetRequestHeader("Cache-Control", "no-cache")
        http.Send()
        return {status: http.Status, text: http.ResponseText}
    } catch as e {
        return {status: 0, text: e.Message}
    }
}

HttpErrorText(r) {
    if r.status = 0
        return "Could not connect to GitHub (" Trim(r.text) ")"
    if (r.status = 403 || r.status = 429) && InStr(r.text, "rate limit")
        return "GitHub's hourly limit for update checks was reached. Please try again in an hour."
    return "GitHub returned status " r.status
}

GetRecentCommits() {
    ; Returns an Array of commits (newest first), or an error string.
    r := HttpGet(ApiBase "/commits?sha=" Branch "&per_page=" CommitListLength)
    if r.status != 200
        return HttpErrorText(r)
    body := r.text
    try data := JsonParse(&body)
    catch as e
        return "Could not read GitHub's reply (" e.Message ")"
    if !(data is Array) || data.Length = 0
        return "GitHub returned no commits"
    out := []
    for c in data
        out.Push(CommitFromJson(c))
    if out[1].sha = ""
        return "Could not read GitHub's reply"
    return out
}

GetCompare(baseSha, headSha) {
    ; Returns {commits (newest first), changed (Map relPath -> status), removed (Array), total, truncated}
    ; or an error string.  One call gives both the commit messages and the list of changed files.
    r := HttpGet(ApiBase "/compare/" baseSha "..." headSha)
    if r.status != 200
        return HttpErrorText(r)
    body := r.text
    try data := JsonParse(&body)
    catch as e
        return "Could not read GitHub's reply (" e.Message ")"
    commitsJ := JGet(data, "commits")
    filesJ := JGet(data, "files")
    if !(commitsJ is Array)
        return "Unexpected reply from GitHub"

    commits := []
    i := commitsJ.Length
    while i >= 1 {
        commits.Push(CommitFromJson(commitsJ[i]))
        i--
    }

    status := JGet(data, "status")      ; ahead, behind, diverged or identical
    changed := NewMap(), removed := []
    files := (filesJ is Array) ? filesJ : []
    for f in files {
        name := StrReplace(JGet(f, "filename"), "/", "\")
        if JGet(f, "status") = "removed"
            removed.Push(name)
        else
            changed[name] := JGet(f, "status")
        prev := JGet(f, "previous_filename")
        if prev != ""
            removed.Push(StrReplace(prev, "/", "\"))
    }
    ; History was rewritten (e.g. force-push): the file list can't be trusted for removals.
    if status != "ahead" && status != "identical"
        removed := []
    total := JGet(data, "total_commits")
    return {commits: commits, changed: changed, removed: removed
        , total: (total = "" ? commits.Length : total)
        , truncated: (status != "ahead" && status != "identical") || !(filesJ is Array) || files.Length >= 300}
}

CommitFromJson(c) {
    date := JGet(c, "commit", "author", "date")
    if date = ""
        date := JGet(c, "commit", "committer", "date")
    return {sha: JGet(c, "sha"), date: date
        , msg: Trim(StrReplace(JGet(c, "commit", "message"), "`r", ""), "`n ")
        , url: JGet(c, "html_url")}
}

DownloadAndExtract() {
    tempDir    := A_Temp "\AutoCorrect2_Update"
    zipFile    := tempDir "\AutoCorrect2_latest.zip"
    extractDir := tempDir "\extracted"

    if DirExist(tempDir)
        DirDelete(tempDir, 1)
    DirCreate(extractDir)

    LogDebug("Downloading from: " LatestZipUrl)
    try Download(LatestZipUrl, zipFile)
    catch as e
        throw Error("Failed to download from GitHub. Please check your internet connection.`n`nError: " e.Message)

    SetProgress("Extracting files from zip...", 70)
    sh  := ComObject("Shell.Application")
    zip := sh.NameSpace(zipFile)
    if !zip
        throw Error("Failed to open downloaded zip file.")
    dest := sh.NameSpace(extractDir)
    if !dest
        throw Error("Failed to open extraction folder.")
    dest.CopyHere(zip.Items, 0x10|0x4)

    srcRoot := extractDir "\" ZipRootFolderName
    if !DirExist(srcRoot)
        throw Error("Expected root folder '" ZipRootFolderName "' not found in extracted zip.")
    LogDebug("Zip extracted to " srcRoot)
    return srcRoot
}

; ==========================================================================
; SCAN
; ==========================================================================
ScanForUpdates(srcRoot, ctx) {
    updated := [], added := [], removedItems := [], differs := []
    lib := ""

    loop Files, srcRoot "\*", "FR" {
        src := A_LoopFileFullPath
        rel := SubStr(src, StrLen(srcRoot) + 2)
        if MatchesAny(rel, IgnoredRx) || MergeTargets.Has(rel)
            continue
        if (rel = UpstreamLibRel) {
            lib := CheckLibrary(src, ctx, added)
            continue
        }

        dest := InstallDir "\" rel
        isPending := ctx.pending.Has(rel)
        changedUpstream := !ctx.haveCompare || ctx.changed.Has(rel) || isPending

        if !FileExist(dest) {
            if MatchesAny(rel, ProtectedRx)
                added.Push(MakeItem(rel, src, rel, "copy", "New - you don't have this file", true))
            else if changedUpstream
                added.Push(MakeItem(rel, src, rel, "copy", isPending ? "New - skipped last time" : "New", !isPending))
            ; else: it didn't change on GitHub, so you removed it yourself - leave it gone
            continue
        }
        if MatchesAny(rel, ProtectedRx)
            continue
        if SameContent(src, dest)
            continue

        if !changedUpstream {
            if ShowLocallyDifferentFiles
                differs.Push(MakeItem(rel, src, rel, "copy", "Differs from GitHub - your own edit?", false))
            continue
        }

        status := "Updated", check := true
        if isPending
            status := "Updated - skipped last time", check := false
        else if IsRarelyUpdated(rel)
            status := "Updated - rarely needed", check := false
        deferred := false
        if (dest = A_AhkPath) {
            ; This is the .exe running the Updater right now: it's copied a moment after the Updater closes.
            status := (isPending ? "Skipped last time" : "Updated") " - replaced on close", deferred := true
        } else if IsLocked(dest) {
            status .= " - in use, close it first"
        }
        item := MakeItem(rel, src, rel, "copy", status, check)
        item.deferred := deferred
        updated.Push(item)
        LogDebug("Offer: " rel " [" status "]")
    }

    ; Settings files: merge new keys in, never replace
    for pair in MergedIniFiles {
        defSrc := srcRoot "\" pair.defaults
        if !FileExist(defSrc)
            continue
        target := InstallDir "\" pair.target
        token := "merge:" pair.target
        wasPending := ctx.pending.Has(token)
        if !FileExist(target) {
            added.Push(MakeItem(token, defSrc, pair.target, "copy", "New - default settings", true))
            continue
        }
        try {
            plan := IniMerge_Plan(defSrc, target)
        } catch as e {
            LogDebug("Settings check failed for " pair.target ": " e.Message)
            continue
        }
        if !plan.changed
            continue
        n := plan.added.Length + plan.renamed.Length
        item := MakeItem(token, defSrc, pair.target, "mergeini"
            , (wasPending ? "Skipped last time - " : "") n " new setting" (n = 1 ? "" : "s") " to add (yours kept)", !wasPending)
        item.plan := plan
        updated.InsertAt(1, item)
        LogDebug("Settings merge offered: " pair.target " (" n " keys)")
    }

    ; Files removed or renamed on GitHub (plus removals skipped last time)
    removeList := ctx.removedUp.Clone()
    for token in ctx.pending
        if SubStr(token, 1, 1) = "-"
            removeList.Push(SubStr(token, 2))
    seen := NewMap()
    for rel in removeList {
        if seen.Has(rel)
            continue
        seen[rel] := true
        if MatchesAny(rel, IgnoredRx) || MatchesAny(rel, ProtectedRx) || rel = UpstreamLibRel
            continue
        dest := InstallDir "\" rel
        attr := FileExist(dest)
        if attr = "" || InStr(attr, "D") || FileExist(srcRoot "\" rel)
            continue
        wasPending := ctx.pending.Has("-" rel)
        removedItems.Push(MakeItem(rel, "", rel, "remove"
            , wasPending ? "Removed from GitHub - skipped last time" : "Removed from GitHub", !wasPending))
        LogDebug("Offer removal: " rel)
    }

    items := []
    for group in [updated, added, removedItems, differs]
        for it in group
            items.Push(it)
    ; The Updater's own includes are always updated when they change.
    for it in items {
        if it.action = "copy" && DependencySet.Has(it.destRel) {
            it.required := true
            it.checked := true
            it.status := (InStr(it.status, "New") = 1 ? "New" : "Updated") " - needed by the Updater"
        }
    }
    return {items: items, lib: lib}
}

CheckLibrary(src, ctx, added) {
    ; Returns a library-update object for the GUI, or "" when there's nothing to offer.
    mainDest := InstallDir "\Core\" Cfg.MainLibName
    copyDest := InstallDir "\Core\" Cfg.CopyLibName

    if !FileExist(mainDest) {
        added.Push(MakeItem(UpstreamLibRel, src, "Core\" Cfg.MainLibName, "copy", "New - AutoCorrect library", true))
        return ""
    }
    if SameContent(src, mainDest) {
        ; Same as GitHub's: a good moment to record the original for future merges.
        if !FileExist(InstallDir "\" BaselineRel)
            try FileCopy(src, InstallDir "\" BaselineRel)
        return ""
    }
    if FileExist(copyDest) && SameContent(src, copyDest) {
        LogDebug("Library: GitHub version already saved as " Cfg.CopyLibName)
        return ""
    }
    isPending := ctx.pending.Has(UpstreamLibRel)
    if ctx.haveCompare && !ctx.changed.Has(UpstreamLibRel) && !isPending {
        LogDebug("Library: unchanged on GitHub since last update (differences are your own)")
        return ""
    }
    LogDebug("Library: update available")
    return {src: src, checked: !isPending, pending: isPending}
}

MakeItem(rel, src, destRel, action, status, checked) {
    return {rel: rel, src: src, destRel: destRel, action: action, status: status, checked: checked
        , token: (action = "remove" ? "-" rel : rel), deferred: false, required: false, plan: ""}
}

; ==========================================================================
; UPDATE GUI
; ==========================================================================
ShowUpdateGui(scan, ctx) {
    ; Layout: commit list (top left) and its message (top right); files across the full width below;
    ; options and buttons along the bottom.
    ; Controls are created roughly here and positioned by UpdateGuiSize, so the window can be resized.
    g := Gui("+AlwaysOnTop +Resize +MinSize1000x560", "AutoCorrect2 - Select Updates (" UpdaterVersion ")")
    g.BackColor := Cfg.FormColor
    g.SetFont("s" Cfg.FontSize " " Cfg.FontColor)
    g.OnEvent("Close", (*) => ExitApp())
    g.OnEvent("Escape", (*) => ExitApp())
    st := {scan: scan, ctx: ctx, g: g, lvF: "", lvC: "", edMsg: "", hint: ""
        , cbLib: "", radCopy: "", radReplace: "", bottom: [], buttons: []}

    ; --- Files (left) ---
    n := scan.items.Length
    hasMerge := false
    for it in scan.items
        if it.action = "mergeini"
            hasMerge := true
    st.fHead := g.Add("Text", "x10 y10 w400 cBlue", !n ? "No other files need updating."
        : "Files (" n "). Ticked files will be updated" (hasMerge ? " (double-click the settings row to see what's new)" : "") ":")
    st.fHead.GetPos(, , , &th)
    st.textH := th
    if n {
        st.lvF := g.Add("ListView", "w400 r5 Checked -Multi NoSort NoSortHdr +Background" Cfg.ListColor, ["File", "Status", "Folder"])
        for it in scan.items {
            SplitPath(it.destRel, &fname, &fdir)
            st.lvF.Add(it.checked ? "Check" : "", fname, it.status, fdir = "" ? "(main folder)" : fdir)
        }
        lvF := st.lvF
        lvF.OnEvent("ItemCheck", FileRowChecked.Bind(scan.items))
        lvF.OnEvent("DoubleClick", FileRowDoubleClick.Bind(scan.items))
        st.btnTick := g.Add("Button", "w100", "Tick all")
        st.btnTick.OnEvent("Click", (*) => lvF.Modify(0, "+Check"))
        st.btnUntick := g.Add("Button", "w100", "Untick all")
        st.btnUntick.OnEvent("Click", (*) => UntickAll(scan.items, lvF))
    }

    ; --- What's new (right) ---
    headText := ctx.header
    if ctx.commits.Length
        headText := RTrim(headText, ":") " (double-click one to open it on GitHub):"
    st.cHead := g.Add("Text", "w400 cBlue", headText)
    if ctx.commits.Length {
        st.lvC := g.Add("ListView", "w400 r5 -Multi NoSort NoSortHdr +Background" Cfg.ListColor, ["Date", "Change"])
        for c in ctx.commits
            st.lvC.Add(, SubStr(c.date, 1, 10), StrSplit(c.msg, "`n")[1])
        st.lvC.ModifyCol(1, 100)
        st.edMsg := g.Add("Edit", "w400 r3 ReadOnly +Background" Cfg.ListColor, StrReplace(ctx.commits[1].msg, "`n", "`r`n"))
        st.lvC.Modify(1, "Select Focus")
        st.lvC.OnEvent("ItemSelect", CommitSelected.Bind(ctx.commits, st.edMsg))
        st.lvC.OnEvent("DoubleClick", CommitDoubleClick.Bind(ctx.commits))
        st.hint := g.Add("Text", "w400", "Full message of the selected change:")
    }

    ; --- Bottom: library, options, buttons ---
    if IsObject(scan.lib) {
        AddBottom(st, g.Add("Text", "w400 cBlue", "AutoCorrect library" (scan.lib.pending ? " (skipped last time)" : "") ":"), 0)
        st.cbLib := AddBottom(st, g.Add("Checkbox", "w400" (scan.lib.checked ? " Checked" : ""), "Get the new AutoCorrectHotstrings.ahk from GitHub"), 0)
        st.radMerge := AddBottom(st, g.Add("Radio", "w400 r1 Checked", "Merge GitHub's changes into your " Cfg.MainLibName " (recommended: your own changes are kept, and you review it first)"), 20)
        st.radCopy := AddBottom(st, g.Add("Radio", "w400 r1", "Save it as Core\" Cfg.CopyLibName ", to compare or merge later (your library is not changed)"), 20)
        st.radReplace := AddBottom(st, g.Add("Radio", "w400 r1", "WARNING: Replace your " Cfg.MainLibName " (rules you added, fixed or removed are lost; the old file is backed up)"), 20)
        st.radMerge.OnEvent("Click", LibModeChanged.Bind(st))
        st.radCopy.OnEvent("Click", LibModeChanged.Bind(st))
        st.radReplace.OnEvent("Click", LibModeChanged.Bind(st))
        st.cbLib.OnEvent("Click", LibModeChanged.Bind(st))
        LibModeChanged(st)
    }
    st.cbRemember := AddBottom(st, g.Add("Checkbox", "w400 Checked", "Remind me next time about files I leave unticked"), 0)
    AddBottom(st, g.Add("Text", "w400", "Old copies are saved in the Backup folder first, so the update can be undone."), 0)

    btn := g.Add("Button", "w100 Default", "Update")
    btn.OnEvent("Click", PerformUpdate.Bind(st))
    st.buttons.Push(btn)
    if IsObject(LatestUndoableSession()) {
        btn := g.Add("Button", "w220", "Undo a previous update...")
        btn.OnEvent("Click", (*) => (g.Destroy(), ShowUndoGui()))
        st.buttons.Push(btn)
    }
    btn := g.Add("Button", "w100", "Cancel")
    btn.OnEvent("Click", (*) => ExitApp())
    st.buttons.Push(btn)
    st.buttons[1].GetPos(, , , &bh)
    st.btnH := bh

    ; --- Size to fit the screen ---
    g.OnEvent("Size", UpdateGuiSize.Bind(st))
    MonitorGetWorkArea(MonitorGetPrimary(), &wl, &wt, &wr, &wb)
    scale := A_ScreenDPI / 96          ; Show() sizes are scaled by DPI; the work area is in pixels
    w := Min(1200, Round((wr - wl) / scale) - 40)
    h := Min(860, Round((wb - wt) / scale) - 60)
    g.Show("w" w " h" h)
}

AddBottom(st, ctrl, indent) {
    ctrl.GetPos(, , , &ch)
    st.bottom.Push({ctrl: ctrl, h: ch, indent: indent})
    return ctrl
}

UpdateGuiSize(st, g, minMax, w, h) {
    if minMax = -1
        return
    static WM_SETREDRAW := 0x000B
    DllCall("user32\SendMessageW", "Ptr", g.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)

    m := 10, gap := 16, th := st.textH, bh := st.btnH

    ; Buttons along the very bottom, then the bottom block stacked upward.
    y := h - m - bh
    x := m
    for b in st.buttons {
        b.GetPos(, , &bw)
        b.Move(x, y)
        x += bw + 10
    }
    y -= 6
    i := st.bottom.Length
    while i >= 1 {
        b := st.bottom[i]
        i--
        y -= b.h + 2
        b.ctrl.Move(m + b.indent, y, w - 2 * m - b.indent)
    }
    areaBottom := y - 10
    fullW := w - 2 * m
    top := m

    ; Top: commit list (left) and the selected commit's message (right)
    if IsObject(st.lvC) {
        leftW := Round((fullW - gap) * 0.45)
        rx := m + leftW + gap
        rw := w - m - rx
        topH := Max(140, Round((areaBottom - m) * 0.40))
        st.cHead.Move(m, top, leftW)
        st.hint.Move(rx, top, rw)
        st.lvC.Move(m, top + th + 4, leftW, topH - th - 4)
        st.lvC.ModifyCol(2, leftW - 100 - 30)
        st.edMsg.Move(rx, top + th + 4, rw, topH - th - 4)
        top += topH + 12
    } else {
        st.cHead.Move(m, top, fullW)
        top += th + 8
    }

    ; Below, full width: files
    st.fHead.Move(m, top, fullW)
    if IsObject(st.lvF) {
        lvTop := top + th + 4
        tickY := areaBottom - bh
        st.lvF.Move(m, lvTop, fullW, tickY - 6 - lvTop)
        st.btnTick.Move(m, tickY)
        st.btnTick.GetPos(, , &tw)
        st.btnUntick.Move(m + tw + 6, tickY)
        cw := fullW - 30                ; room for the scrollbar
        c1 := Round(cw * 0.32), c2 := Round(cw * 0.43)
        st.lvF.ModifyCol(1, c1)
        st.lvF.ModifyCol(2, c2)
        st.lvF.ModifyCol(3, cw - c1 - c2)
    }

    DllCall("user32\SendMessageW", "Ptr", g.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
    DllCall("RedrawWindow", "Ptr", g.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0004 | 0x0080)
}

FileRowChecked(items, lv, row, checked, *) {
    ; The Updater's own includes can't be unticked.
    if !checked && row && items[row].required
        lv.Modify(row, "+Check")
}

UntickAll(items, lv) {
    lv.Modify(0, "-Check")
    for i, it in items
        if it.required
            lv.Modify(i, "+Check")
}

FileRowDoubleClick(items, lv, row, *) {
    if !row
        return
    it := items[row]
    if it.action = "mergeini"
        AcMsgBox.Show(IniMerge_Describe(it.plan), "Settings changes - " it.destRel)
    else if it.required
        AcMsgBox.Show(it.destRel " is used by the Updater itself, so it is always updated when it changes.", AppTitle)
}

CommitSelected(commits, edMsg, lv, row, selected, *) {
    if selected && row
        edMsg.Value := StrReplace(commits[row].msg, "`n", "`r`n")
}

CommitDoubleClick(commits, lv, row, *) {
    if row && commits[row].url != ""
        Run(commits[row].url)
}

LibModeChanged(st, *) {
    enabled := st.cbLib.Value
    st.radMerge.Enabled := enabled
    st.radCopy.Enabled := enabled
    st.radReplace.Enabled := enabled
    st.radReplace.SetFont((enabled && st.radReplace.Value) ? "cRed" : Cfg.FontColor)
}

PerformUpdate(st, *) {
    scan := st.scan, ctx := st.ctx
    checked := st.lvF ? CheckedRows(st.lvF) : Map()
    remember := st.cbRemember.Value
    st.g.Hide()

    stamp := FormatTime(A_Now, "yyyy-MM-dd_HHmmss")
    sessionDir := BackupDir "\" stamp
    manifest := [], failed := [], pending := [], notes := ""
    counts := Map("replaced", 0, "added", 0, "removed", 0)

    for i, it in scan.items {
        if !checked.Has(i) && !it.required {
            if remember
                pending.Push(it.token)
            continue
        }
        r := it.deferred ? DeferItem(it.src, it.destRel, sessionDir) : ApplyItem(it.action, it.src, it.destRel, sessionDir)
        if r.ok {
            manifest.Push(r.kind "|" it.destRel)
            counts[r.kind] += 1
            if r.HasOwnProp("note")
                notes .= r.note "`n`n"
        } else {
            failed.Push(it.destRel)
            pending.Push(it.token)
        }
    }

    libNote := ""
    if IsObject(scan.lib) {
        if st.cbLib.Value && st.radMerge.Value {
            r := MergeLibrary(scan.lib.src, sessionDir, stamp)
            if r.ok {
                for e in r.entries
                    manifest.Push(e)
                counts["replaced"] += 1
                libNote := r.note "`n`n"
            } else {
                pending.Push(UpstreamLibRel)
                if r.cancelled
                    libNote := "The library merge was cancelled, so your library was not changed. It will be offered again next time.`n`n"
                else
                    failed.Push("Core\" Cfg.MainLibName " (merge: " r.error ")")
            }
        } else if st.cbLib.Value {
            replaceMode := st.radReplace.Value
            destRel := "Core\" (replaceMode ? Cfg.MainLibName : Cfg.CopyLibName)
            r := ApplyItem("copy", scan.lib.src, destRel, sessionDir)
            if r.ok {
                manifest.Push(r.kind "|" destRel)
                counts[r.kind] += 1
                if replaceMode {
                    ; The replaced library is now the original for the next merge.
                    rb := ApplyItem("copy", scan.lib.src, BaselineRel, sessionDir)
                    if rb.ok
                        manifest.Push(rb.kind "|" BaselineRel)
                } else {
                    libNote := "The new library was saved as Core\" Cfg.CopyLibName ". You can merge it later with Tools\LibraryMerge.`n`n"
                }
            } else {
                failed.Push(destRel)
                pending.Push(UpstreamLibRel)
            }
        } else if remember {
            pending.Push(UpstreamLibRel)
        }
    }

    if manifest.Length
        WriteManifest(sessionDir, manifest, ctx)
    StoreLastCheck(ctx.latest.sha, ctx.latest.date, pending)
    LogDebug("Update done: " counts["replaced"] " replaced, " counts["added"] " added, " counts["removed"] " removed, "
        . failed.Length " failed, " pending.Length " pending")

    ; --- Summary ---
    if manifest.Length = 0 && failed.Length = 0 {
        AcMsgBox.Show("Nothing was changed."
            . (pending.Length ? "`n`nThe " pending.Length " unticked item(s) will be offered again next time." : ""), AppTitle)
        ExitApp
    }
    msg := "AutoCorrect2 has been updated: " counts["replaced"] " replaced, " counts["added"] " added, " counts["removed"] " removed.`n`n"
    msg .= notes libNote
    if failed.Length {
        msg .= "These could not be updated (probably in use). Close AutoCorrect2 and its tools, then run the Updater again:`n"
        for f in failed
            msg .= "  - " f "`n"
        msg .= "`n"
    }
    if pending.Length > failed.Length
        msg .= "Unticked items will be offered again next time.`n`n"
    if manifest.Length
        msg .= "Previous versions were saved in Backup\" stamp ". You can undo this update from the Updater.`n`n"
    msg .= "Restart AutoCorrect2 so the changes take effect."
    if manifest.Length {
        if AcMsgBox.Show(msg, AppTitle, ["OK", "Open backup folder"]) = "Open backup folder"
            Run(sessionDir)
    } else {
        AcMsgBox.Show(msg, AppTitle)
    }
    ExitApp
}

; ==========================================================================
; LIBRARY MERGE
; ==========================================================================
MergeLibrary(src, sessionDir, stamp) {
    ; Three-way merge of GitHub's library into the user's.  Returns {ok, cancelled, error, entries, note}.
    mainRel  := "Core\" Cfg.MainLibName
    mainPath := InstallDir "\" mainRel
    try {
        mineText := FileRead(mainPath, "UTF-8")
        theirsText := FileRead(src, "UTF-8")
        base := GetLibraryBase(mineText)
        res := LibMerge_Run(base.text, mineText, theirsText, LibMerge_ReadRemoved(Cfg.RemovedFile))
        LogDebug("Library merge planned. " StrReplace(LibMerge_Summary(res, base.note), "`n", " | "))
    } catch as e {
        LogDebug("Library merge failed: " e.Message)
        return {ok: false, cancelled: false, error: e.Message}
    }

    style := {formColor: Cfg.FormColor, fontColor: Cfg.FontColor, listColor: Cfg.ListColor, fontSize: Cfg.FontSize}
    if !LibMerge_Review(res, base.note, style, "Merge AutoCorrect Library (" UpdaterVersion ")") {
        LogDebug("Library merge cancelled by user")
        return {ok: false, cancelled: true, error: ""}
    }

    try {
        merged := LibMerge_Build(res)
        enc := IniDoc_DetectEncoding(FileRead(mainPath, "RAW"))
        bak := sessionDir "\" mainRel
        EnsureParent(bak)
        FileCopy(mainPath, bak, 1)
        IniDoc_Write(mainPath, merged, enc)
    } catch as e {
        LogDebug("Library merge could not be written: " e.Message)
        return {ok: false, cancelled: false, error: e.Message}
    }
    entries := ["replaced|" mainRel]
    rb := ApplyItem("copy", src, BaselineRel, sessionDir)     ; GitHub's library is the next original
    if rb.ok
        entries.Push(rb.kind "|" BaselineRel)
    report := DebugDir "\LibraryMerge_" stamp ".txt"
    LibMerge_WriteReport(res, report, base.note)
    L := res.lists
    LogDebug("Library merged into " mainRel "; report: " report)
    return {ok: true, entries: entries
        , note: "Library merged: " L["added"].Length " new and " L["tookTheirs"].Length " updated rules from GitHub, "
            . L["deleted"].Length " removed, and all " (L["yoursOnly"].Length + L["keptYours"].Length + L["stayDeleted"].Length)
            . " of your own changes kept. Details: Debug\LibraryMerge_" stamp ".txt. It's a good idea to run the Conflicting String Locator now."}
}

GetLibraryBase(mineText) {
    ; The original to compare against: the saved copy, else the closest recent GitHub version.
    path := InstallDir "\" BaselineRel
    if FileExist(path)
        return {text: FileRead(path, "UTF-8"), note: "your saved copy of GitHub's library from your last library update"}
    found := FindLibraryBaseOnGitHub(mineText)
    if IsObject(found)
        return found
    return {text: "", note: "none could be found, so every rule that differs is treated as a conflict"
        . " (rules listed in RemovedHotstrings.txt are not added back)"}
}

FindLibraryBaseOnGitHub(mineText) {
    ; Downloads recent versions of the library and picks the one most like the user's file.
    global Prog
    r := HttpGet(ApiBase "/commits?sha=" Branch "&path=Core/AutoCorrectHotstrings.ahk&per_page=10")
    if r.status != 200 {
        LogDebug("Base search: " HttpErrorText(r))
        return ""
    }
    body := r.text
    try list := JsonParse(&body)
    catch
        return ""
    if !(list is Array) || list.Length = 0
        return ""

    M := LibMerge_Parse(mineText)
    mine := Map()
    for k, rule in M.rules
        mine[rule.val] := true
    best := "", bestScore := -1
    Prog := MakeProgressGui()
    for n, c in list {
        cm := CommitFromJson(c)
        SetProgress("Finding the original of your library (" n " of " list.Length ")...", Round(n * 100 / list.Length))
        tmp := A_Temp "\AC2_libbase_" SubStr(cm.sha, 1, 10) ".ahk"
        try {
            Download("https://raw.githubusercontent.com/" RepoOwner "/" RepoName "/" cm.sha "/Core/AutoCorrectHotstrings.ahk", tmp)
            text := FileRead(tmp, "UTF-8")
            FileDelete(tmp)
        } catch {
            continue
        }
        P := LibMerge_Parse(text)
        common := 0
        for k, rule in P.rules
            if mine.Has(rule.val)
                common++
        score := common / Max(1, P.order.Length + M.order.Length - common)
        LogDebug("Base candidate " SubStr(cm.sha, 1, 7) " (" SubStr(cm.date, 1, 10) "): " Round(score * 100, 1) "% match")
        if score > bestScore {
            bestScore := score
            best := {text: text, note: "GitHub's library from " SubStr(cm.date, 1, 10) " (the closest match to yours, " Round(score * 100) "%)"}
        }
        if score >= 0.999
            break
    }
    CloseProgress()
    return best
}

DeferItem(src, destRel, sessionDir) {
    ; For the running Updater.exe: back it up now, copy the new one after this script exits (see RunDeferredCopies).
    dest := InstallDir "\" destRel
    bak  := sessionDir "\" destRel
    try {
        EnsureParent(bak)
        FileCopy(dest, bak, 1)          ; reading a running .exe is allowed; only writing is blocked
        DeferredCopies.Push({src: src, dest: dest})
        LogDebug("Queued for after exit: " destRel)
        return {ok: true, kind: "replaced"}
    } catch as e {
        LogDebug("FAILED to queue " destRel ": " e.Message)
        return {ok: false, kind: ""}
    }
}

RunDeferredCopies(*) {
    if DeferredCopies.Length = 0
        return
    cmd := "ping -n 3 127.0.0.1 >nul"    ; ~2 second pause so this process has closed
    for c in DeferredCopies
        cmd .= ' & copy /y "' c.src '" "' c.dest '" >nul'
    try Run(A_ComSpec ' /c "' cmd '"', , "Hide")
}

ApplyItem(action, src, destRel, sessionDir) {
    ; Backs up, then copies or removes one file.  Returns {ok, kind} where kind is replaced/added/removed.
    dest := InstallDir "\" destRel
    bak  := sessionDir "\" destRel
    try {
        if action = "mergeini" {
            ; Re-plan now, in case the file changed since the window opened.
            plan := IniMerge_Plan(src, dest)
            EnsureParent(bak)
            FileCopy(dest, bak, 1)
            if plan.changed
                IniMerge_Apply(plan)
            n := plan.added.Length + plan.renamed.Length
            LogDebug("Merged settings into " destRel ": " plan.added.Length " added, " plan.renamed.Length " renamed")
            return {ok: true, kind: "replaced"
                , note: "Settings: " n " new setting" (n = 1 ? " was" : "s were") " added to " destRel ". Your existing values were not changed."}
        }
        if action = "remove" {
            EnsureParent(bak)
            FileMove(dest, bak, 1)
            TryRemoveEmptyDirs(dest)
            LogDebug("Removed (moved to backup): " destRel)
            return {ok: true, kind: "removed"}
        }
        existed := FileExist(dest) != ""
        if existed {
            EnsureParent(bak)
            FileCopy(dest, bak, 1)
        }
        EnsureParent(dest)
        FileCopy(src, dest, 1)
        LogDebug((existed ? "Replaced: " : "Added: ") destRel)
        return {ok: true, kind: existed ? "replaced" : "added"}
    } catch as e {
        LogDebug("FAILED " action " " destRel ": " e.Message)
        return {ok: false, kind: ""}
    }
}

; ==========================================================================
; BACKUP SESSIONS AND UNDO
; ==========================================================================
WriteManifest(sessionDir, entries, ctx) {
    f := sessionDir "\UpdateManifest.ini"
    try {
        DirCreate(sessionDir)
        IniWrite(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), f, "Update", "Date")
        IniWrite(ctx.last.sha, f, "Update", "FromSha")
        IniWrite(ctx.last.date, f, "Update", "FromDate")
        IniWrite(ctx.last.pendingRaw, f, "Update", "FromPending")
        IniWrite(ctx.latest.sha, f, "Update", "ToSha")
        IniWrite(0, f, "Update", "Undone")
        IniWrite(entries.Length, f, "Files", "Count")
        for i, e in entries
            IniWrite(e, f, "Files", i)
    } catch as e {
        LogDebug("Could not write manifest: " e.Message)
    }
}

ListBackupSessions() {
    ; Returns sessions newest first: {dir, name, date, count, undone, undoneAt}
    out := []
    names := ""
    if DirExist(BackupDir)
        loop Files, BackupDir "\*", "D"
            if FileExist(A_LoopFileFullPath "\UpdateManifest.ini")
                names .= A_LoopFileName "`n"
    names := RTrim(names, "`n")
    if names = ""
        return out
    for name in StrSplit(Sort(names, "R"), "`n") {
        dir := BackupDir "\" name
        f := dir "\UpdateManifest.ini"
        out.Push({dir: dir, name: name
            , date: IniRead(f, "Update", "Date", name)
            , count: IniRead(f, "Files", "Count", 0)
            , undone: IniRead(f, "Update", "Undone", 0) = "1"
            , undoneAt: IniRead(f, "Update", "UndoneAt", "")
            , kind: IniRead(f, "Update", "Kind", "Update")})
    }
    return out
}

LatestUndoableSession() {
    for s in ListBackupSessions()
        if !s.undone
            return s
    return ""
}

ShowUndoGui() {
    sessions := ListBackupSessions()
    if sessions.Length = 0 {
        AcMsgBox.Show("There are no saved updates to undo.", AppTitle)
        ExitApp
    }
    ug := Gui("+AlwaysOnTop", "AutoCorrect2 Updater - Undo an Update (" UpdaterVersion ")")
    ug.BackColor := Cfg.FormColor
    ug.SetFont("s" Cfg.FontSize " " Cfg.FontColor)
    ug.OnEvent("Close", (*) => ExitApp())
    ug.OnEvent("Escape", (*) => ExitApp())

    ug.Add("Text", "w640", "Pick an update to undo. Files it replaced or removed are put back, and files it added are moved out. Your current copies are saved first, inside that update's backup folder.")
    lv := ug.Add("ListView", "w640 r8 -Multi NoSort NoSortHdr +Background" Cfg.ListColor, ["Updated on", "Files", "Status"])
    for s in sessions
        lv.Add(, s.date, s.count, (s.kind = "LibraryMerge" ? "Library Merge tool. " : "") (s.undone ? "Undone " s.undoneAt : ""))
    lv.ModifyCol(1, 200)
    lv.ModifyCol(2, 70)
    lv.ModifyCol(3, 340)
    lv.Modify(1, "Select Focus")

    ug.Add("Button", "w180 Default", "Undo selected update").OnEvent("Click", UndoClicked.Bind(sessions, lv, ug))
    ug.Add("Button", "x+10 w180", "Open backup folder").OnEvent("Click", OpenSessionFolder.Bind(sessions, lv))
    ug.Add("Button", "x+10 w100", "Close").OnEvent("Click", (*) => ExitApp())
    ug.Show()
}

OpenSessionFolder(sessions, lv, *) {
    row := lv.GetNext(0)
    Run(row ? sessions[row].dir : BackupDir)
}

UndoClicked(sessions, lv, ug, *) {
    row := lv.GetNext(0)
    if !row
        return
    s := sessions[row]
    if s.undone {
        AcMsgBox.Show("That update has already been undone.", AppTitle)
        return
    }
    newerPending := false
    loop row - 1
        if !sessions[A_Index].undone
            newerPending := true

    msg := "Undo the update from " s.date "?`n`n" s.count " file(s) will be put back the way they were before it."
    if newerPending
        msg .= "`n`nNote: a newer update has not been undone. For a clean result, undo the newer one first."
    if AcMsgBox.Show(msg, AppTitle, "48 YesNo") != "Yes"
        return
    ug.Hide()

    f := s.dir "\UpdateManifest.ini"
    keepDir := s.dir "\_before_undo_" FormatTime(A_Now, "yyyy-MM-dd_HHmmss")
    n := Integer(IniRead(f, "Files", "Count", 0))
    failed := [], done := 0
    i := n
    while i >= 1 {                  ; reverse order
        entry := IniRead(f, "Files", i, "")
        i--
        parts := StrSplit(entry, "|", , 2)
        if parts.Length < 2
            continue
        kind := parts[1], rel := parts[2]
        cur  := InstallDir "\" rel
        bak  := s.dir "\" rel
        keep := keepDir "\" rel
        try {
            if (kind = "replaced" || kind = "removed") {
                if !FileExist(bak)
                    throw Error("backup copy is missing")
                if FileExist(cur) {
                    EnsureParent(keep)
                    FileCopy(cur, keep, 1)
                }
                EnsureParent(cur)
                FileCopy(bak, cur, 1)
                done++
            } else if (kind = "added") {
                ; Don't pull out a protected file (e.g. settings) the user may have edited since.
                if !MatchesAny(rel, ProtectedRx) && FileExist(cur) {
                    EnsureParent(keep)
                    FileMove(cur, keep, 1)
                    TryRemoveEmptyDirs(cur)
                    done++
                }
            }
        } catch as e {
            failed.Push(rel " (" e.Message ")")
            LogDebug("Undo failed for " rel ": " e.Message)
        }
    }

    if failed.Length = 0 {
        IniWrite(1, f, "Update", "Undone")
        IniWrite(FormatTime(A_Now, "yyyy-MM-dd HH:mm"), f, "Update", "UndoneAt")
        ; Reset the update check so this update is offered again (not for a Library Merge tool session).
        if IniRead(f, "Update", "Kind", "") != "LibraryMerge"
            StoreLastCheckRaw(IniRead(f, "Update", "FromSha", ""), IniRead(f, "Update", "FromDate", "")
            , IniRead(f, "Update", "FromPending", ""))
        LogDebug("Undo complete: " s.name " (" done " files)")
        AcMsgBox.Show("Undo complete: " done " file(s) put back.`n`nYour copies from just before the undo are in:`n"
            . "Backup\" s.name "\" SubStr(keepDir, StrLen(s.dir) + 2) "`n`nRestart AutoCorrect2 so the changes take effect.", AppTitle)
    } else {
        list := ""
        for x in failed
            list .= "  - " x "`n"
        AcMsgBox.Show("The undo was only partly done (" done " file(s) put back). These could not be restored, probably because they are in use:`n`n"
            . list "`nClose AutoCorrect2 and its tools, then try the undo again.", AppTitle)
    }
    ExitApp
}

; ==========================================================================
; LAST UPDATE CHECK
; ==========================================================================
ReadLastCheck() {
    sha := "", date := "", raw := ""
    if FileExist(CheckFile) {
        sha  := IniRead(CheckFile, "UpdateCheck", "LastCommitHash", "")
        date := IniRead(CheckFile, "UpdateCheck", "LastCommitDate", "")
        raw  := IniRead(CheckFile, "UpdateCheck", "PendingFiles", "")
    }
    pending := []
    for item in StrSplit(raw, "|")
        if Trim(item) != ""
            pending.Push(Trim(item))
    return {sha: sha, date: date, pendingRaw: raw, pending: pending}
}

StoreLastCheck(sha, date, pendingFiles) {
    raw := ""
    for item in pendingFiles
        raw .= (raw = "" ? "" : "|") item
    StoreLastCheckRaw(sha, date, raw)
}

StoreLastCheckRaw(sha, date, pendingRaw) {
    try {
        EnsureParent(CheckFile)
        IniWrite(sha, CheckFile, "UpdateCheck", "LastCommitHash")
        IniWrite(date, CheckFile, "UpdateCheck", "LastCommitDate")
        IniWrite(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), CheckFile, "UpdateCheck", "LastCheckTime")
        IniWrite(pendingRaw, CheckFile, "UpdateCheck", "PendingFiles")
        LogDebug("Stored check: " sha " | pending: " pendingRaw)
    } catch as e {
        LogDebug("Error writing LastUpdateCheck.ini: " e.Message)
    }
}

; ==========================================================================
; SETTINGS, PROGRESS, LOGGING
; ==========================================================================
LoadSettings() {
    f := SettingsFile
    s := {}
    s.FontSize        := IniRead(f, "HotstringHelper", "DefaultFontSize", "11")
    s.MainLibName     := IniRead(f, "Files", "HotstringLibrary", "AutoCorrectHotstrings.ahk")
    s.CopyLibName     := IniRead(f, "Files", "NewTemporaryHotstrLib", "AutoCorrectHotstrings (1).ahk")
    s.PersonalLibName := IniRead(f, "Files", "BoilerplateHotstringLibrary", "PersonalHotstrings.ahk")
    s.RemovedFile     := InstallDir "\Data\" IniRead(f, "Files", "RemovedHsFile", "RemovedHotstrings.txt")
    s.FormColor := "0xE5E4E2"
    s.FontColor := "c0x1F1F1F"
    s.ListColor := "0xFFFFFF"
    ct := InstallDir "\Data\colorThemeSettings.ini"
    if FileExist(ct) {
        s.FormColor := IniRead(ct, "ColorSettings", "formColor", s.FormColor)
        s.FontColor := "c" IniRead(ct, "ColorSettings", "fontColor", "0x1F1F1F")
        s.ListColor := IniRead(ct, "ColorSettings", "listColor", s.ListColor)
    }
    return s
}

MakeProgressGui() {
    pg := Gui("+AlwaysOnTop", AppTitle)
    pg.BackColor := Cfg.FormColor
    pg.SetFont("s" Cfg.FontSize " " Cfg.FontColor)
    pg.txt := pg.Add("Text", "w400 h30", "Checking for updates...")
    pg.bar := pg.Add("Progress", "w400 h20 Range0-100", 0)
    pg.Show("w420 h100")
    return pg
}

SetProgress(text, pct) {
    if IsObject(Prog) {
        Prog.Title := "AutoCorrect2 Updater - " text " (" UpdaterVersion ")"
        Prog.txt.Value := text
        Prog.bar.Value := pct
    }
}

CloseProgress() {
    global Prog
    if IsObject(Prog)
        try Prog.Destroy()
    Prog := ""
}

LogDebug(msg) {
    if !EnableDebugLog
        return
    try {
        if !DirExist(DebugDir)
            DirCreate(DebugDir)
        FileAppend("[" FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "] " msg "`n", DebugFile)
    }
}

; ==========================================================================
; FILE HELPERS
; ==========================================================================
SameContent(a, b) {
    ; True if the files are byte-identical, or (for text files) identical apart from line endings / BOM.
    try {
        sa := FileGetSize(a), sb := FileGetSize(b)
        if sa = sb {
            if sa = 0
                return true
            ba := FileRead(a, "RAW"), bb := FileRead(b, "RAW")
            if DllCall("msvcrt\memcmp", "Ptr", ba, "Ptr", bb, "UPtr", sa, "Cdecl Int") = 0
                return true
        }
        SplitPath(a, , , &ext)
        if !TextExts.Has(ext)
            return false
        ta := StrReplace(FileRead(a, "UTF-8"), "`r`n", "`n")
        tb := StrReplace(FileRead(b, "UTF-8"), "`r`n", "`n")
        return ta == tb
    } catch {
        return false
    }
}

IsLocked(path) {
    ; True if the file can't be opened for writing (a running .exe, for example).
    try {
        f := FileOpen(path, "a")
        f.Close()
        return false
    } catch {
        return true
    }
}

EnsureParent(path) {
    SplitPath(path, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
}

TryRemoveEmptyDirs(path) {
    ; Removes now-empty parent folders, stopping at the install folder.
    SplitPath(path, , &dir)
    while StrLen(dir) > StrLen(InstallDir) {
        try DirDelete(dir, false)
        catch
            break
        SplitPath(dir, , &dir)
    }
}

CheckedRows(lv) {
    rows := Map()
    row := 0
    while (row := lv.GetNext(row, "C"))
        rows[row] := true
    return rows
}

IsRarelyUpdated(relPath) {
    if RegExMatch(relPath, "i)\.default\.ini$")     ; defaults files stay current
        return false
    for folder in RarelyUpdatedFolders
        if SubStr(relPath, 1, StrLen(folder)) = folder
            return true
    return false
}

GlobsToRegex(globs) {
    out := []
    for p in globs {
        r := ""
        loop Parse p {
            c := A_LoopField
            if c = "*"
                r .= ".*"
            else if c = "?"
                r .= "."
            else if InStr("\.^$|()[]{}+", c)
                r .= "\" c
            else
                r .= c
        }
        out.Push("i)^" r "$")
    }
    return out
}

MatchesAny(relPath, regexList) {
    for rx in regexList
        if RegExMatch(relPath, rx)
            return true
    return false
}

NewMap() {
    m := Map()
    m.CaseSense := false
    return m
}

; ==========================================================================
; MINIMAL JSON READER (objects -> Map, arrays -> Array, null -> "")
; Strings are passed ByRef so large replies aren't copied on every call.
; ==========================================================================
JsonParse(&text) {
    pos := 1
    return _JsonValue(&text, &pos)
}

JGet(obj, keys*) {
    ; Safe nested lookup: JGet(c, "commit", "author", "date") returns "" if any level is missing.
    for k in keys {
        if (obj is Map && obj.Has(k))
            obj := obj[k]
        else if (obj is Array && IsInteger(k) && k >= 1 && k <= obj.Length)
            obj := obj[k]
        else
            return ""
    }
    return obj
}

_JsonSkipWs(&text, &pos) {
    if RegExMatch(text, "\G[ \t\r\n]+", &m, pos)
        pos += m.Len
}

_JsonValue(&text, &pos) {
    _JsonSkipWs(&text, &pos)
    ch := SubStr(text, pos, 1)
    if ch = "{" {
        obj := Map(), pos++
        _JsonSkipWs(&text, &pos)
        if SubStr(text, pos, 1) = "}" {
            pos++
            return obj
        }
        loop {
            _JsonSkipWs(&text, &pos)
            if SubStr(text, pos, 1) != '"'
                throw Error("JSON: expected a key at " pos)
            key := _JsonString(&text, &pos)
            _JsonSkipWs(&text, &pos)
            if SubStr(text, pos, 1) != ":"
                throw Error("JSON: expected ':' at " pos)
            pos++
            obj[key] := _JsonValue(&text, &pos)
            _JsonSkipWs(&text, &pos)
            ch := SubStr(text, pos, 1), pos++
            if ch = "}"
                return obj
            if ch != ","
                throw Error("JSON: expected ',' or '}' at " (pos - 1))
        }
    }
    if ch = "[" {
        arr := [], pos++
        _JsonSkipWs(&text, &pos)
        if SubStr(text, pos, 1) = "]" {
            pos++
            return arr
        }
        loop {
            arr.Push(_JsonValue(&text, &pos))
            _JsonSkipWs(&text, &pos)
            ch := SubStr(text, pos, 1), pos++
            if ch = "]"
                return arr
            if ch != ","
                throw Error("JSON: expected ',' or ']' at " (pos - 1))
        }
    }
    if ch = '"'
        return _JsonString(&text, &pos)
    if RegExMatch(text, "\G-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?", &m, pos) {
        pos += m.Len
        return Number(m[0])
    }
    if SubStr(text, pos, 4) == "true" {
        pos += 4
        return true
    }
    if SubStr(text, pos, 5) == "false" {
        pos += 5
        return false
    }
    if SubStr(text, pos, 4) == "null" {
        pos += 4
        return ""
    }
    throw Error("JSON: unexpected character at " pos)
}

_JsonString(&text, &pos) {
    ; pos is on the opening quote.  Finds the closing quote (one not preceded by an odd number of backslashes).
    start := pos + 1, i := start
    loop {
        q := InStr(text, '"', true, i)
        if !q
            throw Error("JSON: unterminated string at " pos)
        bs := 0, k := q - 1
        while (k >= start && SubStr(text, k, 1) = "\")
            bs++, k--
        if Mod(bs, 2) = 0
            break
        i := q + 1
    }
    raw := SubStr(text, start, q - start)
    pos := q + 1
    return _JsonUnescape(raw)
}

_JsonUnescape(s) {
    if !InStr(s, "\")
        return s
    s := StrReplace(s, "\\", Chr(1), true)
    s := StrReplace(s, '\"', '"', true)
    s := StrReplace(s, "\/", "/", true)
    s := StrReplace(s, "\n", "`n", true)
    s := StrReplace(s, "\r", "`r", true)
    s := StrReplace(s, "\t", "`t", true)
    s := StrReplace(s, "\b", Chr(8), true)
    s := StrReplace(s, "\f", Chr(12), true)
    while RegExMatch(s, "\\u([0-9A-Fa-f]{4})", &m)
        s := StrReplace(s, m[0], Chr(Integer("0x" m[1])), true)
    return StrReplace(s, Chr(1), "\", true)
}
