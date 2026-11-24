#Requires AutoHotkey v2.0
/*
IniMerge.ahk -- shared by Tools\Updater.ahk and Tools\SettingsDefaultsMaker.ahk
Author: kunkel321
Tool Used: Claude
Version: 11-23-2026

Reads INI files as text, so comments, blank lines, key order and the file's encoding are kept.
(IniRead/IniWrite can't do that: IniWrite puts a new key at the end of its section with no comment.)

IniMerge_Plan(defaultsPath, userPath) works out what a user's ini is missing compared with a
defaults file:
  - Keys the user doesn't have are inserted in the defaults file's order, right after the key
    they follow there, together with the comment lines directly above them.
  - Sections the user doesn't have are added at the end.
  - Keys the user already has are NEVER changed.
  - Keys the user has that the defaults file doesn't are left alone and reported as "unused".
  - An [UpdaterRenames] section in the defaults file moves a value to a renamed key:
        Hotkeys.AC2HotkeyRefHotkey=Hotkeys.HotkeyHubHotkey
    (OldSection.OldKey=NewSection.NewKey).  That section is never copied into the user's ini.
IniMerge_Apply(plan) then writes the merged text back in the file's own encoding.
*/

IniMerge_RenamesSection() => "UpdaterRenames"

; ---------------------------------------------------------------------------
; Loading and indexing
; ---------------------------------------------------------------------------
IniDoc_Load(path) {
    buf := FileRead(path, "RAW")
    enc := IniDoc_DetectEncoding(buf)
    text := FileRead(path, enc = "UTF-8-RAW" ? "UTF-8" : enc)
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    lines := StrSplit(text, "`n")
    trailingNewline := false
    if lines.Length > 1 && lines[lines.Length] = "" {
        lines.Pop()
        trailingNewline := true
    }
    doc := {path: path, enc: enc, lines: lines, trailingNewline: trailingNewline}
    IniDoc_Index(doc)
    return doc
}

IniDoc_DetectEncoding(buf) {
    ; Returns an encoding name usable with FileRead/FileOpen that reproduces the file as it was.
    if buf.Size >= 3 && NumGet(buf, 0, "UChar") = 0xEF && NumGet(buf, 1, "UChar") = 0xBB && NumGet(buf, 2, "UChar") = 0xBF
        return "UTF-8"          ; UTF-8 with BOM (FileOpen "w" writes the BOM back)
    if buf.Size >= 2 && NumGet(buf, 0, "UChar") = 0xFF && NumGet(buf, 1, "UChar") = 0xFE
        return "UTF-16"         ; what IniWrite creates
    if buf.Size = 0
        return "UTF-8-RAW"
    ; No BOM: plain ASCII/UTF-8 if it decodes cleanly as UTF-8, otherwise the ANSI code page.
    ok := DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 0x8, "Ptr", buf, "Int", buf.Size, "Ptr", 0, "Int", 0)
    return ok ? "UTF-8-RAW" : "CP0"
}

IniDoc_Index(doc) {
    ; doc.sections: Map name -> {name, header, keys: Map key -> {idx, value}, order: [keys]}
    sections := Map()
    sections.CaseSense := false
    order := []
    cur := ""
    for i, line in doc.lines {
        t := Trim(line)
        if RegExMatch(t, "^\[([^\]]+)\]", &m) {
            name := Trim(m[1])
            if !sections.Has(name) {
                keys := Map()
                keys.CaseSense := false
                sections[name] := {name: name, header: i, keys: keys, order: []}
                order.Push(sections[name])
            }
            cur := sections[name]
            continue
        }
        if !IsObject(cur) || t = "" || SubStr(t, 1, 1) = ";" || SubStr(t, 1, 1) = "#"
            continue
        p := InStr(line, "=")
        if !p
            continue
        key := Trim(SubStr(line, 1, p - 1))
        if key != "" && !cur.keys.Has(key) {
            cur.keys[key] := {idx: i, value: SubStr(line, p + 1)}
            cur.order.Push(key)
        }
    }
    doc.sections := sections
    doc.sectionOrder := order
}

IniDoc_CommentsAbove(doc, idx) {
    ; The comment lines directly above line idx (stops at a blank line, a key or a section header).
    out := []
    i := idx - 1
    while i >= 1 {
        t := Trim(doc.lines[i])
        if !(SubStr(t, 1, 1) = ";" || SubStr(t, 1, 1) = "#")
            break
        out.InsertAt(1, doc.lines[i])
        i--
    }
    return out
}

IniDoc_Get(doc, section, key, default := "") {
    if doc.sections.Has(section) && doc.sections[section].keys.Has(key)
        return doc.sections[section].keys[key].value
    return default
}

IniDoc_Write(path, text, enc) {
    ; Writes to a temporary file first, then replaces the target.
    tmp := path ".tmp"
    f := FileOpen(tmp, "w", enc)
    f.Write(text)
    f.Close()
    FileMove(tmp, path, 1)
}

; ---------------------------------------------------------------------------
; Merging
; ---------------------------------------------------------------------------
IniMerge_Plan(defaultsPath, userPath) {
    ; Returns {added: ["Section: Key"], renamed: ["Old -> New"], newSections: [], unused: [],
    ;          text, enc, userPath, changed}
    d := IniDoc_Load(defaultsPath)
    u := IniDoc_Load(userPath)
    renames := IniMerge_ReadRenames(d)

    inserts := Map()        ; user line index -> lines to insert after it
    tail := []              ; whole new sections, added at the end
    added := [], renamed := [], newSections := []

    for dsec in d.sectionOrder {
        if dsec.name = IniMerge_RenamesSection()
            continue
        usec := u.sections.Has(dsec.name) ? u.sections[dsec.name] : ""
        if !IsObject(usec) {
            newSections.Push(dsec.name)
            tail.Push("", d.lines[dsec.header])
            for key in dsec.order {
                line := IniMerge_LineFor(d, dsec, key, u, renames, added, renamed)
                tail.Push(IniDoc_CommentsAbove(d, dsec.keys[key].idx)*)
                tail.Push(line)
            }
            continue
        }
        anchor := usec.header
        for key in dsec.order {
            if usec.keys.Has(key) {
                anchor := usec.keys[key].idx
                continue
            }
            line := IniMerge_LineFor(d, dsec, key, u, renames, added, renamed)
            if !inserts.Has(anchor)
                inserts[anchor] := []
            inserts[anchor].Push(IniDoc_CommentsAbove(d, dsec.keys[key].idx)*)
            inserts[anchor].Push(line)
        }
    }

    ; Keys the user has that the defaults file doesn't
    unused := []
    for usec in u.sectionOrder {
        dsec := d.sections.Has(usec.name) ? d.sections[usec.name] : ""
        for key in usec.order
            if !IsObject(dsec) || !dsec.keys.Has(key)
                unused.Push(usec.name ": " key)
    }

    out := []
    for i, line in u.lines {
        out.Push(line)
        if inserts.Has(i)
            out.Push(inserts[i]*)
    }
    out.Push(tail*)
    text := ""
    for line in out
        text .= line "`r`n"
    if !u.trailingNewline
        text := SubStr(text, 1, -2)

    return {added: added, renamed: renamed, newSections: newSections, unused: unused
        , text: text, enc: u.enc, userPath: userPath
        , changed: (added.Length + renamed.Length) > 0}
}

IniMerge_LineFor(d, dsec, key, u, renames, added, renamed) {
    ; The line to insert for a missing key: the defaults line, or the user's value from a renamed key.
    newId := dsec.name "." key
    if renames.Has(newId) {
        old := renames[newId]
        if u.sections.Has(old.section) && u.sections[old.section].keys.Has(old.key) {
            renamed.Push(old.section "." old.key " -> " newId)
            return key "=" u.sections[old.section].keys[old.key].value
        }
    }
    added.Push(dsec.name ": " key)
    return d.lines[dsec.keys[key].idx]
}

IniMerge_ReadRenames(d) {
    ; Map "NewSection.NewKey" -> {section, key} of the old name
    renames := Map()
    renames.CaseSense := false
    if !d.sections.Has(IniMerge_RenamesSection())
        return renames
    sec := d.sections[IniMerge_RenamesSection()]
    for oldId in sec.order {
        newId := Trim(sec.keys[oldId].value)
        p := InStr(oldId, ".")
        if !p || newId = ""
            continue
        renames[newId] := {section: SubStr(oldId, 1, p - 1), key: SubStr(oldId, p + 1)}
    }
    return renames
}

IniMerge_Apply(plan) {
    IniDoc_Write(plan.userPath, plan.text, plan.enc)
}

IniMerge_Describe(plan, maxLines := 40) {
    ; A readable summary of a plan, for message boxes.
    msg := ""
    shown := 0
    if plan.added.Length {
        msg .= "New settings to add (" plan.added.Length "), with their default values:`n"
        for x in plan.added {
            if ++shown > maxLines {
                msg .= "  ...and " (plan.added.Length - maxLines) " more`n"
                break
            }
            msg .= "  + " x "`n"
        }
        msg .= "`n"
    }
    if plan.renamed.Length {
        msg .= "Renamed settings (your value is carried over):`n"
        for x in plan.renamed
            msg .= "  > " x "`n"
        msg .= "`n"
    }
    if plan.unused.Length {
        msg .= "Settings in your file that AutoCorrect2 no longer uses (" plan.unused.Length "). They are left as they are:`n"
        n := 0
        for x in plan.unused {
            if ++n > 15 {
                msg .= "  ...and " (plan.unused.Length - 15) " more`n"
                break
            }
            msg .= "  - " x "`n"
        }
        msg .= "`n"
    }
    return msg "None of your existing values are changed."
}
