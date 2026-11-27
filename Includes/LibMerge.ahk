#Include "%A_LineFile%\..\DpiKeepSize.ahk"   ; keeps its windows their size across monitors with different scales
#Requires AutoHotkey v2.0
/*
LibMerge.ahk -- three-way merge for the AutoCorrect hotstring library.
Shared by Tools\Updater.ahk and Tools\LibraryMerge.ahk.
Author: kunkel321
Tool Used: Claude
Version: 11-27-2026

THE IDEA
Two files can't tell who changed what.  Three can: the ORIGINAL (the library as the user last got it
from GitHub), YOURS (the user's library now) and GITHUB'S (the new one).  For each rule:
    in original, gone from yours ............ you deleted it: it stays deleted
    in original, different in yours ......... you edited it: yours is kept
    in yours only ........................... you added it: kept
    in original, gone from GitHub's ......... removed upstream: removed (unless you edited it)
    different in GitHub's only .............. updated upstream: GitHub's version is used
    in GitHub's only ........................ new upstream: added (unless RemovedHotstrings.txt
                                              says you removed it before)
    changed differently on both sides ....... a conflict: the user picks, seeing all three versions

HOW RULES ARE MATCHED
- A rule is identified by its trigger plus its options, ignoring B0 and X and the order of the
  options.  The trigger is case-sensitive only with the C option.
- Only the replacement is compared.  The comment (Web Freq, Fixes...) is ignored, so refreshed
  statistics don't count as changes.  If the user didn't touch a rule, GitHub's line (with its new
  comment) is used.
- f("abc") and a plain ::abc replacement count as the same replacement.

WHERE THINGS GO
- The result is built from the user's file, so their order, comments and sections are kept.
- New rules go right after the rule they follow in GitHub's file, so they land in the same section.
- A rule that GitHub's file moved to another section (between "; MARK:" lines -- for example into
  the No Sort section, where order matters) is moved in the user's file too, unless the user moved it.
*/

; ---------------------------------------------------------------------------
; Parsing
; ---------------------------------------------------------------------------
LibMerge_RuleRx() => '^\s*:([^:\s]*):((?:[^``]|``.)+?)::(.*)$'

LibMerge_Parse(text) {
    ; Returns {lines, rules: Map key -> rule, at: Map lineIndex -> key, order: [keys in file order]}
    ; rule: {sec, i, val, sem, raw, show, opts, trig}
    lines := StrSplit(StrReplace(text, "`r`n", "`n"), "`n")
    rules := Map(), at := Map(), order := [], seen := Map()
    sec := "top"
    rx := LibMerge_RuleRx()
    for i, line in lines {
        if SubStr(line, 1, 7) = "; MARK:"
            sec := Trim(SubStr(line, 8))
        if !RegExMatch(line, rx, &m)
            continue
        opts := m[1], trig := m[2]
        norm := LibMerge_NormOpts(opts)
        base := norm "|" (LibMerge_IsCaseSensitive(norm) ? trig : StrLower(trig))
        n := seen.Get(base, 0)
        seen[base] := n + 1
        key := base "|" n
        code := LibMerge_Code(m[3])
        rules[key] := {sec: sec, i: i, val: opts "|" trig "|" code, sem: LibMerge_Sem(code), raw: line
            , show: ":" opts ":" trig "::" code, opts: opts, trig: trig}
        at[i] := key
        order.Push(key)
    }
    return {lines: lines, rules: rules, at: at, order: order}
}

LibMerge_NormOpts(opts) {
    ; Options without B0 and X, in a fixed order, so :B0X*?: and :?*: match.
    o := StrReplace(StrReplace(StrUpper(opts), "B0"), "X")
    toks := ""
    pos := 1
    while RegExMatch(o, "C1|C0|C|\*0|\*|\?0|\?|O0|O|R0|R|T0|T|Z0|Z|K-?\d+|P\d+|SI|SP|SE|B", &m, pos) {
        toks .= m[0] "`n"
        pos := m.Pos + m.Len
    }
    return StrReplace(Sort(RTrim(toks, "`n")), "`n", "")
}

LibMerge_IsCaseSensitive(norm) {
    ; True when the options include C itself (not C0 or C1).
    return RegExMatch(norm, "C(?![01])") > 0
}

LibMerge_Code(rest) {
    ; The replacement part of a rule, without its trailing comment.
    if RegExMatch(rest, '^(f\("(?:[^"``]|``.)*"(?:\s*,[^)]*)?\))', &m)
        return m[1]
    p := InStr(rest, " " Chr(59))      ; " ;" starts the comment
    return RTrim(p ? SubStr(rest, 1, p - 1) : rest)
}

LibMerge_Sem(code) {
    ; What the rule types: f("abc") and a plain abc replacement are the same.
    if RegExMatch(code, '^f\("((?:[^"``]|``.)*)"(.*)\)$', &m)
        return m[1] "|" RegExReplace(m[2], "\s")
    return code "|"
}

LibMerge_BaseKey(key) => RegExReplace(key, "\|\d+$")

LibMerge_ReadRemoved(path) {
    ; Rules listed in RemovedHotstrings.txt, as base keys.
    keys := Map()
    if !FileExist(path)
        return keys
    try text := FileRead(path)
    catch
        return keys
    loop Parse, text, "`n", "`r" {
        if RegExMatch(A_LoopField, ':([^:\s]*):((?:[^``\s]|``.)+?)::', &m) {
            norm := LibMerge_NormOpts(m[1])
            keys[norm "|" (LibMerge_IsCaseSensitive(norm) ? m[2] : StrLower(m[2]))] := true
        }
    }
    return keys
}

; ---------------------------------------------------------------------------
; Merging
; ---------------------------------------------------------------------------
LibMerge_Run(baseText, mineText, theirsText, removed := "") {
    ; Returns {B, M, T, decide: Map key -> action, lists: Map category -> [keys], conflicts: [...]}
    ; Actions: mine, theirs, delete, add, move, skip, conflict
    ; NOTE: AHK names ignore case, so the parsed files are baseDoc/mineDoc/theirsDoc and single rules b/m/t.
    baseDoc := LibMerge_Parse(baseText), mineDoc := LibMerge_Parse(mineText), theirsDoc := LibMerge_Parse(theirsText)
    lists := Map()
    for cat in ["same", "keptYours", "yoursOnly", "stayDeleted", "tookTheirs", "added", "deleted", "moved", "skipRemoved"]
        lists[cat] := []
    keys := Map()
    for src in [baseDoc, mineDoc, theirsDoc]
        for k in src.rules
            keys[k] := true

    decide := Map(), conflicts := []
    for k in keys {
        b := baseDoc.rules.Get(k, ""), m := mineDoc.rules.Get(k, ""), t := theirsDoc.rules.Get(k, "")
        bv := IsObject(b) ? b.val : ""
        mv := IsObject(m) ? m.val : ""
        tv := IsObject(t) ? t.val : ""

        if (mv == tv) {                                     ; both sides agree
            if IsObject(m)
                lists["same"].Push(k)
            ; Untouched by the user: take GitHub's line so refreshed comments come along.
            decide[k] := (IsObject(m) && IsObject(b) && IsObject(t) && m.raw == b.raw && !(t.raw == m.raw)) ? "theirs" : "mine"
            continue
        }
        if (mv == bv) {                                     ; the user didn't change it
            if !IsObject(t) {
                decide[k] := "delete", lists["deleted"].Push(k)
            } else if !IsObject(m) {
                if IsObject(removed) && removed.Has(LibMerge_BaseKey(k))
                    decide[k] := "skip", lists["skipRemoved"].Push(k)
                else
                    decide[k] := "add", lists["added"].Push(k)
            } else {
                decide[k] := "theirs", lists["tookTheirs"].Push(k)
            }
            continue
        }
        if (tv == bv) {                                     ; GitHub didn't change it
            decide[k] := "mine"
            if !IsObject(m)
                lists["stayDeleted"].Push(k)
            else if !IsObject(b)
                lists["yoursOnly"].Push(k)
            else
                lists["keptYours"].Push(k)
            continue
        }
        if IsObject(m) && IsObject(t) && m.sem == t.sem {   ; same replacement, different formatting
            decide[k] := "theirs", lists["tookTheirs"].Push(k)
            continue
        }
        decide[k] := "conflict"
        conflicts.Push({key: k, b: b, m: m, t: t, choice: "mine"})
    }

    ; Rules GitHub moved to another section (the user didn't move them) are moved too.
    moves := []
    for k, d in decide {
        if !(d = "mine" || d = "theirs")
            continue
        b := baseDoc.rules.Get(k, ""), m := mineDoc.rules.Get(k, ""), t := theirsDoc.rules.Get(k, "")
        if IsObject(b) && IsObject(m) && IsObject(t) && b.sec != t.sec && m.sec = b.sec
            moves.Push(k)
    }
    for k in moves {
        decide[k] := "move"
        lists["moved"].Push(k)
    }
    return {B: baseDoc, M: mineDoc, T: theirsDoc, decide: decide, lists: lists, conflicts: conflicts}
}

LibMerge_Build(res) {
    ; Builds the merged library text from the user's file, using the conflict choices.
    M := res.M, T := res.T
    decide := res.decide.Clone()
    for c in res.conflicts {
        if c.choice = "theirs"
            decide[c.key] := !IsObject(c.t) ? "delete" : !IsObject(c.m) ? "add" : "theirs"
        else
            decide[c.key] := "mine"
    }

    outKeys := Map()
    for k in M.order {
        d := decide[k]
        if !(d = "delete" || d = "move")
            outKeys[k] := true
    }
    ; Each new or moved rule goes after the nearest rule before it (in GitHub's file) that is in the result.
    ins := Map()            ; anchor key ("" = before the first rule) -> [keys]
    for n, k in T.order {
        d := decide.Get(k, "")
        if !(d = "add" || d = "move")
            continue
        anchor := ""
        j := n - 1
        while j >= 1 {
            if outKeys.Has(T.order[j]) {
                anchor := T.order[j]
                break
            }
            j--
        }
        if !ins.Has(anchor)
            ins[anchor] := []
        ins[anchor].Push(k)
        outKeys[k] := true
    }

    out := []
    firstRuleSeen := false
    for i, line in M.lines {
        k := M.at.Get(i, "")
        if k = "" {
            out.Push(line)
            continue
        }
        if !firstRuleSeen {
            firstRuleSeen := true
            LibMerge_Emit("", out, ins, T)
        }
        d := decide[k]
        if (d = "delete" || d = "move")
            continue
        out.Push(d = "theirs" ? T.rules[k].raw : line)
        LibMerge_Emit(k, out, ins, T)
    }
    text := ""
    for line in out
        text .= line "`r`n"
    return SubStr(text, 1, -2)      ; the last element of lines is "" when the file ended with a newline
}

LibMerge_Emit(anchor, out, ins, T) {
    if !ins.Has(anchor)
        return
    for k in ins[anchor] {
        out.Push(T.rules[k].raw)
        LibMerge_Emit(k, out, ins, T)
    }
}

; ---------------------------------------------------------------------------
; Reporting
; ---------------------------------------------------------------------------
LibMerge_Summary(res, baseNote := "") {
    L := res.lists
    s := ""
    if baseNote != ""
        s .= "Original used for comparison: " baseNote "`n`n"
    s .= "Your changes kept: " (L["yoursOnly"].Length + L["keptYours"].Length + L["stayDeleted"].Length)
    s .= "  (" L["yoursOnly"].Length " added, " L["keptYours"].Length " edited, " L["stayDeleted"].Length " deleted)`n"
    s .= "From GitHub: " L["added"].Length " new, " L["tookTheirs"].Length " updated, " L["deleted"].Length " removed, " L["moved"].Length " moved`n"
    if L["skipRemoved"].Length
        s .= "Not added because RemovedHotstrings.txt says you removed them before: " L["skipRemoved"].Length "`n"
    s .= "Unchanged: " L["same"].Length "`n"
    s .= "Conflicts (changed on both sides): " res.conflicts.Length
    return s
}

LibMerge_WriteReport(res, path, baseNote := "") {
    rep := "AutoCorrect library merge -- " FormatTime(A_Now, "yyyy-MM-dd HH:mm") "`r`n`r`n"
    rep .= StrReplace(LibMerge_Summary(res, baseNote), "`n", "`r`n") "`r`n"
    if res.conflicts.Length {
        rep .= "`r`n=== Conflicts ===`r`n"
        for c in res.conflicts {
            rep .= "Kept " (c.choice = "theirs" ? "GITHUB'S" : "YOURS") ":`r`n"
            rep .= "   original: " LibMerge_Show(c.b) "`r`n   yours:    " LibMerge_Show(c.m) "`r`n   github:   " LibMerge_Show(c.t) "`r`n"
        }
    }
    sections := [["added", "New from GitHub", "T"], ["tookTheirs", "Updated from GitHub", "T"], ["deleted", "Removed (GitHub removed them)", "B"]
        , ["moved", "Moved to another section (as on GitHub)", "T"], ["keptYours", "Your edits, kept", "M"], ["yoursOnly", "Your additions, kept", "M"]
        , ["stayDeleted", "You deleted these; they stay deleted", "B"], ["skipRemoved", "Skipped (in RemovedHotstrings.txt)", "T"]]
    for s in sections {
        keys := res.lists[s[1]]
        if !keys.Length
            continue
        rep .= "`r`n=== " s[2] " (" keys.Length ") ===`r`n"
        src := res.%s[3]%
        for k in keys
            rep .= "  " LibMerge_Show(src.rules.Get(k, "")) "`r`n"
    }
    try {
        SplitPath(path, , &dir)
        if !DirExist(dir)
            DirCreate(dir)
        f := FileOpen(path, "w", "UTF-8")
        f.Write(rep)
        f.Close()
    }
}

LibMerge_Show(rule) => IsObject(rule) ? rule.show : "(none)"

; ---------------------------------------------------------------------------
; Review window (modal).  Returns true to go ahead, false to cancel.
; style: {formColor, fontColor, listColor, fontSize}
; ---------------------------------------------------------------------------
LibMerge_Review(res, baseNote, style, title := "Merge AutoCorrect Library") {
    g := Gui("+AlwaysOnTop +Resize +MinSize900x420", title)
    DpiKeepSize.Watch(g)   ; keep its size across monitors with different scales
    g.BackColor := style.formColor
    g.SetFont("s" style.fontSize " " style.fontColor)
    state := {ok: false, res: res}

    g.Add("Text", "x10 y10 w1000 cBlue", "Here is what the merge will do.  Nothing has been written yet.")
    sumText := g.Add("Text", "x10 y+6 w1000", LibMerge_Summary(res, baseNote))
    n := res.conflicts.Length
    lv := ""
    if n {
        g.Add("Text", "x10 y+12 w1000 cBlue", "These " n " rule(s) were changed on both sides.  Pick which version to keep (yours is the default):")
        lv := g.Add("ListView", "x10 y+4 w1000 r12 NoSortHdr +Background" style.listColor, ["Keep", "Yours", "GitHub's", "Original"])
        for c in res.conflicts
            lv.Add(, "Yours", LibMerge_Show(c.m), LibMerge_Show(c.t), LibMerge_Show(c.b))
        lv.ModifyCol(1, 80), lv.ModifyCol(2, 300), lv.ModifyCol(3, 300), lv.ModifyCol(4, 300)
        g.Add("Button", "x10 y+6 w170", "Keep yours").OnEvent("Click", (*) => LibMerge_SetChoice(res, lv, "mine", false))
        g.Add("Button", "x+6 w170", "Keep GitHub's").OnEvent("Click", (*) => LibMerge_SetChoice(res, lv, "theirs", false))
        g.Add("Button", "x+20 w170", "All: yours").OnEvent("Click", (*) => LibMerge_SetChoice(res, lv, "mine", true))
        g.Add("Button", "x+6 w170", "All: GitHub's").OnEvent("Click", (*) => LibMerge_SetChoice(res, lv, "theirs", true))
    } else {
        g.Add("Text", "x10 y+12 w1000", "No conflicts: nothing needs a decision.")
    }
    g.Add("Text", "x10 y+12 w1000", "Your current library is backed up before it is changed.  A full report is saved in the Debug folder.")
    g.Add("Button", "x10 y+8 w140 Default", "Merge").OnEvent("Click", (*) => (state.ok := true, g.Destroy()))
    g.Add("Button", "x+10 w140", "Cancel").OnEvent("Click", (*) => g.Destroy())
    g.OnEvent("Close", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())
    g.Show()
    WinWaitClose("ahk_id " g.Hwnd)
    return state.ok
}

LibMerge_SetChoice(res, lv, choice, all) {
    label := choice = "theirs" ? "GitHub's" : "Yours"
    if all {
        for i, c in res.conflicts {
            c.choice := choice
            lv.Modify(i, , label)
        }
        return
    }
    row := 0
    while (row := lv.GetNext(row)) {
        res.conflicts[row].choice := choice
        lv.Modify(row, , label)
    }
}
