#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "..\Includes\AcMsgBox.ahk"
#Include "..\Includes\DpiKeepSize.ahk"   ; keeps its windows their size across monitors with different scales
#Include "..\Includes\IniMerge.ahk"

/*
Settings Defaults Maker
Author: kunkel321
Tool Used: Claude
Version: 11-27-2026

For the AutoCorrect2 author (or anyone maintaining a fork), not for end users.

Builds Data\acSettings.default.ini -- the neutral settings file that ships in the repository.
The Updater uses it to ADD new settings to each user's acSettings.ini without touching their values,
and a user with no acSettings.ini gets a copy of it.

HOW IT WORKS
- Layout, comments and key order come from YOUR Data\acSettings.ini, so the defaults file always
  matches the current settings file.
- The VALUE for each key comes from the existing acSettings.default.ini, so neutral values you set
  once stay set.  Keys that aren't in the defaults file yet take your value (or a suggested neutral
  value from the list below), and are marked NEW so you can check them.
- Double-click a row (or press Edit) to change the default value.  "Use my value" copies yours.
- The [UpdaterRenames] section of the existing defaults file is kept.  Add a line there when you
  rename a key, so users keep their value:
      OldSection.OldKey=NewSection.NewKey
- The "template version date" line in the header is set to today's date when you save.

Run it before copying acSettings.default.ini to the GitHub folder.
*/

; --- CONFIG ---------------------------------------------------------------
; Neutral values suggested for keys that are new to the defaults file (Section|Key -> value).
; Personal paths and lists shouldn't ship to other users.
SuggestedNeutral := Map(
    "Files|FileManagerPath", "",
    "Shared|EditorCmd", "",
    "ACSystem|AppSkiplist", ""
)
; --------------------------------------------------------------------------

AppTitle := "Settings Defaults Maker"
SplitPath(A_ScriptDir, , &InstallDir)
UserIni     := InstallDir "\Data\acSettings.ini"
DefaultsIni := InstallDir "\Data\acSettings.default.ini"

if !FileExist(UserIni) {
    AcMsgBox.Show("Can't find your settings file:`n" UserIni, AppTitle, 16)
    ExitApp
}

; --- Colors and font, as in the other AC2 tools ---
FontSize := IniRead(UserIni, "HotstringHelper", "DefaultFontSize", "11")
FormColor := "0xE5E4E2", FontColor := "c0x1F1F1F", ListColor := "0xFFFFFF"
ctFile := InstallDir "\Data\colorThemeSettings.ini"
if FileExist(ctFile) {
    FormColor := IniRead(ctFile, "ColorSettings", "formColor", FormColor)
    FontColor := "c" IniRead(ctFile, "ColorSettings", "fontColor", "0x1F1F1F")
    ListColor := IniRead(ctFile, "ColorSettings", "listColor", ListColor)
}

; --- Build the rows ---
UserDoc := IniDoc_Load(UserIni)
DefDoc := FileExist(DefaultsIni) ? IniDoc_Load(DefaultsIni) : ""
Rows := []          ; {section, key, mine, def, note}
for sec in UserDoc.sectionOrder {
    if sec.name = IniMerge_RenamesSection()
        continue
    for key in sec.order {
        mine := sec.keys[key].value
        inDefaults := IsObject(DefDoc) && DefDoc.sections.Has(sec.name) && DefDoc.sections[sec.name].keys.Has(key)
        if inDefaults {
            def := DefDoc.sections[sec.name].keys[key].value
            note := ""
        } else {
            id := sec.name "|" key
            def := SuggestedNeutral.Has(id) ? SuggestedNeutral[id] : mine
            note := "NEW" (SuggestedNeutral.Has(id) ? " (neutral value suggested)" : "")
        }
        Rows.Push({section: sec.name, key: key, mine: mine, def: def, note: note})
    }
}
; Keys in the old defaults file that are gone from your ini (they'll be dropped)
Dropped := []
if IsObject(DefDoc) {
    for dsec in DefDoc.sectionOrder {
        if dsec.name = IniMerge_RenamesSection()
            continue
        for key in dsec.order
            if !(UserDoc.sections.Has(dsec.name) && UserDoc.sections[dsec.name].keys.Has(key))
                Dropped.Push(dsec.name ": " key)
    }
}

; --- GUI ---
g := Gui("+Resize +MinSize700x400", AppTitle)
DpiKeepSize.Watch(g)   ; keep its size across monitors with different scales
g.BackColor := FormColor
g.SetFont("s" FontSize " " FontColor)
g.OnEvent("Close", (*) => ExitApp())
g.OnEvent("Escape", (*) => ExitApp())
g.OnEvent("Size", GuiSize)

intro := IsObject(DefDoc)
    ? "Default values from acSettings.default.ini.  NEW = not in the defaults file yet; check these."
    : "No acSettings.default.ini yet: every value starts as yours.  Change the personal ones before saving."
txtIntro := g.Add("Text", "x10 y10 w900", intro)
cbOnly := g.Add("Checkbox", "x10 y+6", "Show only NEW keys and keys where the default differs from yours")
cbOnly.OnEvent("Click", (*) => FillList())
lv := g.Add("ListView", "x10 y+6 w900 h420 -Multi +Background" ListColor, ["Section", "Key", "Default (shipped)", "Your value", "Note"])
lv.OnEvent("DoubleClick", (*) => EditSelected())
btnEdit := g.Add("Button", "x10 w140", "Edit default...")
btnEdit.OnEvent("Click", (*) => EditSelected())
btnMine := g.Add("Button", "x+8 w140", "Use my value")
btnMine.OnEvent("Click", (*) => UseMine())
btnBlank := g.Add("Button", "x+8 w140", "Make blank")
btnBlank.OnEvent("Click", (*) => SetSelected(""))
btnSave := g.Add("Button", "x+30 w220 Default", "Save acSettings.default.ini")
btnSave.OnEvent("Click", (*) => SaveDefaults())
btnClose := g.Add("Button", "x+8 w100", "Close")
btnClose.OnEvent("Click", (*) => ExitApp())
txtStatus := g.Add("Text", "x10 w900", "")

FillList()
UpdateStatus()
g.Show("w1000 h640")
return

; ==========================================================================
FillList() {
    lv.Opt("-Redraw")
    lv.Delete()
    for i, r in Rows {
        if cbOnly.Value && r.note = "" && r.def == r.mine
            continue
        lv.Add(, r.section, r.key, r.def, r.mine, NoteFor(r))
    }
    lv.ModifyCol(1, 130), lv.ModifyCol(2, 220), lv.ModifyCol(3, 250), lv.ModifyCol(4, 250), lv.ModifyCol(5, 200)
    lv.Opt("+Redraw")
}

NoteFor(r) {
    if r.note != ""
        return r.note
    return (r.def == r.mine) ? "" : "differs from yours"
}

SelectedIndex() {
    row := lv.GetNext(0)
    if !row
        return 0
    ; Find the Rows entry by section + key (the list may be filtered)
    sec := lv.GetText(row, 1), key := lv.GetText(row, 2)
    for i, r in Rows
        if r.section = sec && r.key = key
            return i
    return 0
}

SetSelected(value) {
    i := SelectedIndex()
    if !i
        return
    Rows[i].def := value
    row := lv.GetNext(0)
    lv.Modify(row, , Rows[i].section, Rows[i].key, value, Rows[i].mine, NoteFor(Rows[i]))
    UpdateStatus()
}

EditSelected() {
    i := SelectedIndex()
    if !i
        return
    r := Rows[i]
    ib := InputBox("Default value for [" r.section "] " r.key ":`n`n(Your value: " r.mine ")", AppTitle, "w600 h170", r.def)
    if ib.Result = "OK"
        SetSelected(ib.Value)
}

UseMine() {
    i := SelectedIndex()
    if i
        SetSelected(Rows[i].mine)
}

UpdateStatus() {
    newCount := 0, diffCount := 0
    for r in Rows {
        if r.note != ""
            newCount++
        else if !(r.def == r.mine)
            diffCount++
    }
    txtStatus.Value := Rows.Length " keys.  " newCount " new.  " diffCount " where the default differs from your value."
        . (Dropped.Length ? "  " Dropped.Length " key(s) in the old defaults file are no longer in your ini and will be dropped." : "")
}

SaveDefaults() {
    ; Values by "Section|Key"
    vals := Map()
    vals.CaseSense := false
    for r in Rows
        vals[r.section "|" r.key] := r.def

    out := ""
    cur := ""
    today := FormatTime(A_Now, "M-d-yyyy")
    for i, line in UserDoc.lines {
        t := Trim(line)
        if RegExMatch(t, "^\[([^\]]+)\]", &m) {
            cur := Trim(m[1])
            if cur = IniMerge_RenamesSection()      ; never take a renames section from the user's ini
                cur := "__skip__"
        }
        if cur = "__skip__"
            continue
        if RegExMatch(line, "i)^(\s*;.*template version date:\s*)", &m)
            line := m[1] today
        else if cur != "" && !(SubStr(t, 1, 1) = ";" || SubStr(t, 1, 1) = "#") && (p := InStr(line, "=")) {
            key := Trim(SubStr(line, 1, p - 1))
            if vals.Has(cur "|" key)
                line := SubStr(line, 1, p) vals[cur "|" key]
        }
        out .= line "`r`n"
    }

    ; Keep (or start) the renames section
    out := RTrim(out, "`r`n") "`r`n`r`n"
    if IsObject(DefDoc) && DefDoc.sections.Has(IniMerge_RenamesSection()) {
        sec := DefDoc.sections[IniMerge_RenamesSection()]
        start := sec.header
        ; copy the comment block just above the header, the header, and everything after it up to the next section
        for c in IniDoc_CommentsAbove(DefDoc, start)
            out .= c "`r`n"
        i := start
        while i <= DefDoc.lines.Length {
            if i > start && RegExMatch(Trim(DefDoc.lines[i]), "^\[")
                break
            out .= DefDoc.lines[i] "`r`n"
            i++
        }
    } else {
        out .= "; Renamed settings, for the Updater.  When a key is renamed, add a line here so users keep`r`n"
            . "; their value:  OldSection.OldKey=NewSection.NewKey`r`n"
            . "; This section is never copied into acSettings.ini.`r`n"
            . "[" IniMerge_RenamesSection() "]`r`n"
            . "Hotkeys.AC2HotkeyRefHotkey=Hotkeys.HotkeyHubHotkey`r`n"
            . "ControlButtons.HotkeyRef=ControlButtons.HotkeyHub`r`n"
    }

    try {
        IniDoc_Write(DefaultsIni, out, UserDoc.enc)
    } catch as e {
        AcMsgBox.Show("Could not save:`n" e.Message, AppTitle, 16)
        return
    }
    AcMsgBox.Show("Saved:`n" DefaultsIni "`n`nCopy it to your GitHub folder along with any changed tools.", AppTitle, 64)
}

GuiSize(gObj, minMax, w, h) {
    if minMax = -1
        return
    txtIntro.Move(, , w - 20)
    cbOnly.Move(, , w - 20)
    btnEdit.GetPos(, , , &bh)
    txtStatus.GetPos(, , , &sh)
    lv.GetPos(, &ly)
    statusY := h - 10 - sh
    btnY := statusY - 8 - bh
    lv.Move(, , w - 20, btnY - 8 - ly)
    for b in [btnEdit, btnMine, btnBlank, btnSave, btnClose] {
        b.GetPos(&bx)
        b.Move(bx, btnY)
    }
    txtStatus.Move(10, statusY, w - 20)
}
