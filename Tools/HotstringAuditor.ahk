; ============================================================
; Hotstring Auditor -- whole-library conflict auditor for AutoCorrect2
; Part of the AutoCorrect2 Suite.  No dependencies beyond AutoHotkey v2.
; AHK port of AuditHotstringLib.py (VitaKaninen, 2026-09).
; ============================================================
; Version Date: 11-20-2026
;
; Simulates AutoHotkey's hotstring firing order across every correctly-spelled
; word in the word list and reports what actually breaks.  Reads the libraries
; in the order AutoCorrect2.ahk #Includes them, which is what decides ties:
; PersonalHotstrings.ahk, then AutoCorrectHotstrings.ahk, then (optionally)
; Includes\DiacriticHotstrings.ahk.
;
; Firing model (this is the part that matters -- everything else is bookkeeping):
;   For a typed word W, each rule's trigger T can fire at a keystroke position.
;     :*?:  fires at the end of the LEFTMOST occurrence of T anywhere in W
;     :*:   fires at len(T), and only if W starts with T
;     :?:   fires on the END CHAR, and only if W ends with T
;     (none) fires on the END CHAR, and only if W == T
;   Earliest fire position wins; ties break by earliest line (include order).
;   A rule with an empty replacement is a NULLIFIER -- if it wins, the word is
;   protected.  Multi-word triggers can't fire on a single word and are skipped.
;   Known limit: a trigger that contains an end char (e.g. the ' in "hadn'") is
;   simulated as plain text, so such rules can be misjudged.
;
; Report sections (pick them in the startup window):
;   1a real word -> non-word (definite defects)     1b real word -> other real word
;   1c worst offending rules                        2  duplicate trigger+options
;   3  no-op rules                                  4  unreachable (shadowed) rules
;   5  dead nullifiers                              6  broken replacements
;
; Locations print as BP-123 (PersonalHotstrings.ahk = boilerplates), AC-123
; (AutoCorrectHotstrings.ahk) and DI-123 (DiacriticHotstrings.ahk).
;
; Output: ..\Debug\HotstringAudit_Mon_DD_HH_MM.txt (opened when done).  ~20-40 s for 249k words.
; Window choices are remembered in acSettings.ini, section [HotstringAuditor].
; Command line: "all" pre-sets Rows per section to 0 (show everything).
;
; 11-20-2026 changes:
;   - Startup window: choose sections, rows per section, line cutting, and
;     whether to hide problems the rule's own comment already mentions.
;     Window stays open, so you can edit the libraries and run it again.
;   - Short locations (AC-993), so more of each rule's comment fits on a line.
;     Lines are cut as a whole (optional) instead of cutting each field.
;   - Case fix: rules without C now match any case.  Before, sections 4 and 5
;     missed them when the probe word had capitals (e.g. Ganesh).
;   - Options are read properly: C0/C1 are not case-sensitive, and *0/?0 turn
;     those options off.  Duplicates match options given in any order (*? = ?*).
;   - Hotstrings inside /* ... */ block comments are ignored.
;   - An empty-bodied hotstring followed by a { } block, a ( ) continuation
;     section, or a code line is an action, not a nullifier.  Same for an X
;     rule that calls something other than f("...").  Action results can't be
;     simulated, so they're left out of the corruption lists.
;   - Section 4 checks nullifiers too (a shadowed nullifier protects nothing)
;     and probes only inputs that the rule's own options can match, so
;     "shadowed by" names the rule that really blocks it.
;   - Frequencies under 1M print as K or plain counts instead of 0.00M.
;   - "Also hide derivatives": a problem word is also hidden when it is typed
;     the same as a word the comment names, up to the keystroke where the rule
;     fires.  E.g. :*?:beng::being noting "benga" also hides bengal, benghazi.
;   - Library tags BP / AC / DI, each with a checkbox at the top of the window.
; ============================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)

settings := "..\Data\acSettings.ini"
libAC   := "..\Core\" IniRead(settings, "Files", "HotstringLibrary", "AutoCorrectHotstrings.ahk")
libBP   := "..\Core\" IniRead(settings, "Files", "BoilerplateHotstringLibrary", "PersonalHotstrings.ahk")
wlFile  := "..\Data\" IniRead(settings, "Files", "WordListFile", "ExamPaneWordList253k.txt")
fqFile  := "..\Data\" IniRead(settings, "Files", "FrequencyListFile", "unigram_freq_list_filtered_102k.csv")
outDir  := "..\Debug"
outFile := ""          ; set per run: HotstringAudit_Mon_DD_HH_MM.txt

libDI   := "..\Includes\DiacriticHotstrings.ahk"

; Include order matters: earlier files win ties.
LIBDEFS := [{tag: "BP", path: libBP}, {tag: "AC", path: libAC}, {tag: "DI", path: libDI}]

LibsFor(opt) {
    global LIBDEFS
    libs := []
    for lib in LIBDEFS
        if InStr("," opt.libs ",", "," lib.tag ",")
            libs.Push(lib)
    return libs
}

SECTIONS := [
    {id: "1a", text: "Real word -> non-word (definite defects)"},
    {id: "1b", text: "Real word -> other real word (review)"},
    {id: "1c", text: "Worst offending rules (built from 1a)"},
    {id: "2",  text: "Duplicate trigger + options"},
    {id: "3",  text: "No-op rules (trigger == replacement)"},
    {id: "4",  text: "Unreachable rules (shadowed by an earlier rule)"},
    {id: "5",  text: "Dead nullifiers (nothing would break the word)"},
    {id: "6",  text: "Broken replacements (can't make a real word)"}
]

cfg := LoadCfg()
if (A_Args.Length && A_Args[1] = "all")
    cfg.rows := 0

; ================================================================ startup GUI
g := Gui(, "Hotstring Auditor")
g.SetFont("s10")
g.MarginX := 12, g.MarginY := 10
g.OnEvent("Close", OnClose)
g.OnEvent("Escape", OnClose)

gb0 := g.AddGroupBox("xm ym w470 h" (30 + LIBDEFS.Length * 25), "Libraries to audit (in include order)")
cbLibs := Map()
for k, lib in LIBDEFS {
    SplitPath(lib.path, &libName)
    found := FileExist(lib.path)
    cbLibs[lib.tag] := g.AddCheckbox((k = 1 ? "xm+14 ym+24" : "xm+14 y+5") " w440"
        . (found && InStr("," cfg.libs ",", "," lib.tag ",") ? " Checked" : "")
        . (found ? "" : " Disabled"), lib.tag "    " libName (found ? "" : "   (not found)"))
}
gb0.GetPos(, &gy, , &gh)

gb1 := g.AddGroupBox("xm y" (gy + gh + 10) " w470 h" (30 + SECTIONS.Length * 25), "Report sections")
gb1.GetPos(, &gy)
cbs := Map()
for k, s in SECTIONS
    cbs[s.id] := g.AddCheckbox((k = 1 ? "xm+14 y" (gy + 24) : "xm+14 y+5") " w440"
        . (Wants(cfg, s.id) ? " Checked" : ""), s.id "    " s.text)
gb1.GetPos(, &gy, , &gh)
g.AddButton("xm y" (gy + gh + 6) " w70", "All").OnEvent("Click", (*) => SetAllSections(1))
g.AddButton("x+6 w70", "None").OnEvent("Click", (*) => SetAllSections(0))

gb2 := g.AddGroupBox("xm y+10 w470 h156", "Output")
gb2.GetPos(, &gy)
g.AddText("xm+14 y" (gy + 28), "Rows per section:")
edRows := g.AddEdit("x+6 yp-3 w70 Number", cfg.rows)
g.AddUpDown("Range0-999999", cfg.rows)
g.AddText("x+8 yp+3", "(0 = show all)")
cbTrunc := g.AddCheckbox("xm+14 y" (gy + 62) (cfg.trunc ? " Checked" : ""), "Cut lines longer than")
edWidth := g.AddEdit("x+6 yp-3 w60 Number", cfg.width)
txtWidth := g.AddText("x+8 yp+3", "characters (no wrapping)")
cbNoted := g.AddCheckbox("xm+14 y" (gy + 96) " w440" (cfg.hideNoted ? " Checked" : ""),
    "Hide problems the hotstring's own comment already mentions")
cbDerived := g.AddCheckbox("xm+34 y" (gy + 124) " w420" (cfg.hideDerived ? " Checked" : ""),
    "Also hide derivatives (e.g. noted benga also covers bengal)")
cbTrunc.OnEvent("Click", (*) => (edWidth.Enabled := cbTrunc.Value, txtWidth.Enabled := cbTrunc.Value))
cbNoted.OnEvent("Click", (*) => cbDerived.Enabled := cbNoted.Value)
edWidth.Enabled := txtWidth.Enabled := cfg.trunc
cbDerived.Enabled := cfg.hideNoted

gb2.GetPos(, &gy, , &gh)
txtStatus := g.AddText("xm y" (gy + gh + 10) " w470", "Ready.")
bar := g.AddProgress("xm y+4 w470 h16 Range0-100", 0)
btnRun := g.AddButton("xm y+12 w130 Default", "&Run Audit")
btnRun.OnEvent("Click", OnRun)
btnOpen := g.AddButton("x+8 w150", "&Open Last Report")
btnOpen.OnEvent("Click", OnOpenLast)
g.AddButton("x+8 w100", "Close").OnEvent("Click", OnClose)
g.Show()
; (no "return" here: everything below is function/class definitions, and the
;  open window keeps the script running)

; ================================================================ GUI handlers
SetAllSections(v) {
    global cbs
    for id, cb in cbs
        cb.Value := v
}

ReadGui() {
    global cbs, cbLibs, edRows, cbTrunc, edWidth, cbNoted, cbDerived, SECTIONS, LIBDEFS
    ids := "", libs := ""
    for s in SECTIONS
        if cbs[s.id].Value
            ids .= (ids = "" ? "" : ",") s.id
    for lib in LIBDEFS
        if cbLibs[lib.tag].Value
            libs .= (libs = "" ? "" : ",") lib.tag
    rows := IsInteger(edRows.Value) ? Integer(edRows.Value) : 8
    width := IsInteger(edWidth.Value) ? Max(60, Integer(edWidth.Value)) : 150
    return {libs: libs, sections: ids, rows: rows, trunc: cbTrunc.Value, width: width,
        hideNoted: cbNoted.Value, hideDerived: cbDerived.Value}
}

LoadCfg() {
    global settings
    return {
        libs: IniRead(settings, "HotstringAuditor", "Libraries", "BP,AC,DI"),
        sections: IniRead(settings, "HotstringAuditor", "Sections", "1a,1b,1c,2,3,4,5,6"),
        rows: IniInt("RowsPerSection", 8),
        trunc: IniInt("CutLongLines", 1),
        width: IniInt("LineWidth", 150),
        hideNoted: IniInt("HideNoted", 1),
        hideDerived: IniInt("HideDerivatives", 1)
    }
}

IniInt(key, def) {
    global settings
    v := IniRead(settings, "HotstringAuditor", key, def)
    return IsInteger(v) ? Integer(v) : def
}

SaveCfg(c) {
    global settings
    sec := "HotstringAuditor"
    try {
        IniWrite(c.sections, settings, sec, "Sections")
        IniWrite(c.rows, settings, sec, "RowsPerSection")
        IniWrite(c.trunc ? 1 : 0, settings, sec, "CutLongLines")
        IniWrite(c.width, settings, sec, "LineWidth")
        IniWrite(c.hideNoted ? 1 : 0, settings, sec, "HideNoted")
        IniWrite(c.hideDerived ? 1 : 0, settings, sec, "HideDerivatives")
        IniWrite(c.libs, settings, sec, "Libraries")
    }
}

; Open this session's report, or else the newest HotstringAudit_*.txt in Debug.
OnOpenLast(*) {
    global outFile, outDir
    f := outFile, newest := ""
    if (f = "" || !FileExist(f)) {
        f := ""
        Loop Files outDir "\HotstringAudit*.txt"
            if (A_LoopFileTimeModified > newest)
                newest := A_LoopFileTimeModified, f := A_LoopFileFullPath
    }
    if (f != "")
        Run(f)
    else
        MsgBox("No report yet.", "Hotstring Auditor", 64)
}

OnClose(*) {
    try SaveCfg(ReadGui())
    ExitApp
}

OnRun(*) {
    global cfg, outFile, outDir, btnRun, btnOpen
    cfg := ReadGui()
    if (cfg.libs = "" || cfg.sections = "") {
        MsgBox("Tick at least one library and one report section.", "Hotstring Auditor", 48)
        return
    }
    SaveCfg(cfg)
    btnRun.Enabled := btnOpen.Enabled := false
    try {
        res := RunAudit(cfg)
        if !DirExist(outDir)
            DirCreate(outDir)
        ; e.g. HotstringAudit_Nov_20_10_41.txt (24-hour clock)
        outFile := outDir "\HotstringAudit_" FormatTime(, "MMM_dd_HH_mm") ".txt"
        try FileDelete(outFile)                ; same-minute rerun overwrites
        FileAppend(res.text, outFile, "UTF-8")
        Progress("Done in " res.secs " s.  Report: " outFile, 100)
        Run(outFile)
    } catch as err {
        Progress("Error: " err.Message, 0)
        MsgBox("The audit stopped with an error:`n`n" err.Message
            . (err.Extra != "" ? "`n" err.Extra : ""), "Hotstring Auditor", 16)
    } finally {
        btnRun.Enabled := btnOpen.Enabled := true
    }
}

Progress(text, pct := "") {
    global txtStatus, bar
    txtStatus.Text := text
    if (pct != "")
        bar.Value := pct
}

Wants(c, id) => InStr("," c.sections ",", "," id ",")

; ================================================================ rules
class Rule {
    ; order = position across both files in include order (decides ties);
    ; line = the line in its own file; loc = "AC-993" (what the report prints).
    __New(order, line, tag, opts, trig, replRaw, raw) {
        this.order := order, this.line := line, this.tag := tag, this.opts := opts, this.raw := raw
        this.loc := tag "-" line
        ; C = case-sensitive (C0 and C1 are not).  The word list is lowercase, so a
        ; C rule whose trigger has uppercase can never match it -- that's correct.
        this.cs   := RegExMatch(opts, "i)C(?![01])") ? 1 : 0
        this.star := RegExMatch(opts, "\*(?!0)") ? 1 : 0
        this.q    := RegExMatch(opts, "\?(?!0)") ? 1 : 0
        isX       := RegExMatch(opts, "i)X") ? 1 : 0
        body := Trim(replRaw), comment := ""
        if (SubStr(body, 1, 1) = ";")
            comment := SubStr(body, 2), body := ""
        else if (p := RegExMatch(body, "\s;"))
            comment := SubStr(body, p + 2), body := Trim(SubStr(body, 1, p - 1))
        this.comment := Trim(comment)
        this.null := (body = "")
        this.action := 0                  ; fires, but its result can't be simulated
        rp := body
        if RegExMatch(body, "^f\(\s*([`"'])(.*?)\1", &m)
            rp := m[2]
        else if (isX && body != "")
            this.action := 1              ; X rule calling something other than f("...")
        this.otrig := trig, this.orepl := rp
        this.trig := this.cs ? trig : StrLower(trig)
        this.repl := this.cs ? rp : StrLower(rp)
        this.multi := InStr(trig, " ") ? 1 : 0
    }
}

LoadRules(libs) {
    rules := []
    n := 0
    for lib in libs {
        if !FileExist(lib.path)
            continue
        inBlock := false, pending := []
        Loop Parse FileRead(lib.path, "UTF-8"), "`n", "`r" {
            n++
            s := Trim(A_LoopField)
            ; skip /* ... */ block comments
            if inBlock {
                if (SubStr(s, 1, 2) = "*/" || SubStr(s, -2) = "*/")
                    inBlock := false
                continue
            }
            if (SubStr(s, 1, 2) = "/*") {
                inBlock := !(StrLen(s) > 2 && SubStr(s, -2) = "*/")
                continue
            }
            if (s = "" || SubStr(s, 1, 1) = ";")
                continue
            if RegExMatch(s, "^:([^:]*):((?:[^:]|:(?!:))+)::(.*)$", &m) {
                r := Rule(n, A_Index, lib.tag, m[1], m[2], m[3], s)
                rules.Push(r)
                if r.null
                    pending.Push(r)       ; empty body: nullifier, or stacked onto what follows
                else
                    pending := []
                continue
            }
            ; A non-hotstring line right after empty-bodied hotstrings is their body
            ; ({ } block, ( ) continuation, or a one-line action) -- so they are
            ; actions, not nullifiers.  "return" and #directives don't count.
            if (pending.Length && SubStr(s, 1, 1) != "#" && !RegExMatch(s, "i)^return\b")) {
                for p in pending
                    p.null := false, p.action := 1
            }
            pending := []
        }
    }
    return rules
}

GetWords() {
    static cache := "", stamp := ""
    global wlFile, fqFile
    if !FileExist(wlFile)
        throw Error("Word list not found: " wlFile)
    now := FileGetTime(wlFile) "|" (FileExist(fqFile) ? FileGetTime(fqFile) : "")
    if (IsObject(cache) && now = stamp)
        return cache
    words := [], seen := Map(), fq := Map()
    Loop Parse FileRead(wlFile, "CP1252"), "`n", "`r" {
        w := StrLower(Trim(A_LoopField))
        if (w != "" && !seen.Has(w))
            seen[w] := 1, words.Push(w)
    }
    if FileExist(fqFile) {
        Loop Parse FileRead(fqFile, "CP1252"), "`n", "`r" {
            p := InStr(A_LoopField, ",")
            if (p && IsInteger(v := Trim(SubStr(A_LoopField, p + 1))))
                fq[StrLower(Trim(SubStr(A_LoopField, 1, p - 1)))] := Integer(v)
        }
    }
    cache := {words: words, set: seen, freq: fq}, stamp := now
    return cache
}

; Keyed by the LOWERCASED trigger so one lookup finds both kinds; case-sensitive
; rules are then checked against the exact text in WinnerFor.
BuildIndex(rules) {
    idx := Map(), maxlen := 1
    for r in rules {
        if r.multi
            continue
        key := StrLower(r.trig)
        if !idx.Has(key)
            idx[key] := []
        idx[key].Push(r)
        maxlen := Max(maxlen, StrLen(r.trig))
    }
    return {idx: idx, maxlen: maxlen}
}

; The rule that actually fires when `word` is typed, or "" if none.
WinnerFor(word, ix) {
    best := "", bestFire := 0, bestOrder := 0
    lw := StrLower(word), L := StrLen(word), idx := ix.idx, maxlen := ix.maxlen
    Loop L {
        i := A_Index                          ; 1-based start
        Loop Min(L - i + 1, maxlen) {
            n := A_Index, j := i + n - 1      ; j = 1-based end (inclusive)
            sub := SubStr(lw, i, n)
            if !idx.Has(sub)
                continue
            for r in idx[sub] {
                if (r.star && r.q)
                    fires := j
                else if r.star
                    fires := (i = 1) ? j : 0
                else if r.q
                    fires := (j = L) ? L + 1 : 0
                else
                    fires := (i = 1 && j = L) ? L + 1 : 0
                if !fires
                    continue
                if (IsObject(best) && (fires > bestFire || (fires = bestFire && r.order > bestOrder)))
                    continue
                if (r.cs && !(SubStr(word, i, n) == r.trig))
                    continue                  ; case-sensitive rule, case doesn't match
                best := r, bestFire := fires, bestOrder := r.order
            }
        }
    }
    return best
}

; What the word becomes after rule r fires.
ResultOf(word, r) {
    t := r.trig
    if (r.star && r.q)
        i := InStr(r.cs ? word : StrLower(word), t, true)
    else if r.star
        i := 1
    else
        i := StrLen(word) - StrLen(t) + 1
    return SubStr(word, 1, i - 1) r.repl SubStr(word, i + StrLen(t))
}

; Inputs the rule's own options can match: bare trigger, plus "x"+T for ?,
; T+"x" for *, and both for *?.
ProbesFor(r) {
    t := r.trig, p := [t]
    if r.q
        p.Push("q" t)
    if r.star
        p.Push(t "q")
    if (r.star && r.q)
        p.Push("q" t "q")
    return p
}

; True if the rule's comment already names this word (whole word, any case),
; e.g. "... but misspells bibtex (a computer/tech term)".
NotedWord(r, w) {
    if (r.comment = "")
        return false
    return RegExMatch(r.comment, "i)(?<![a-z])\Q" StrReplace(w, "\E", "\E\\E\Q") "\E(?![a-z])") ? true : false
}

; Text of w up to and including the keystroke where rule r fires on it
; ("" if r's trigger doesn't match w the way its options require).
FirePrefix(w, r) {
    lw := StrLower(w), t := StrLower(r.trig)
    if (r.star && r.q)
        return (p := InStr(lw, t, true)) ? SubStr(lw, 1, p + StrLen(t) - 1) : ""
    if r.star
        return (SubStr(lw, 1, StrLen(t)) == t) ? t : ""
    if r.q
        return (StrLen(lw) >= StrLen(t) && SubStr(lw, -StrLen(t)) == t) ? lw : ""
    return (lw == t) ? lw : ""
}

; Fire prefixes of the words a rule's comment names (cached on the rule).
; Uses the text after "misspell" when present, ignoring (parenthetical notes).
NotedPrefixes(r) {
    if r.HasOwnProp("notedPfx")
        return r.notedPfx
    pfx := Map(), txt := r.comment
    if (p := InStr(txt, "misspell"))
        txt := SubStr(txt, p)
    txt := RegExReplace(txt, "\([^)]*\)")
    pos := 1
    while (pos := RegExMatch(txt, "[A-Za-z][A-Za-z'-]*", &mm, pos)) {
        if (StrLen(mm[0]) > 1 && (fp := FirePrefix(mm[0], r)) != "")
            pfx[fp] := 1
        pos += mm.Len
    }
    r.notedPfx := pfx
    return pfx
}

; Is the problem of rule r breaking word w already flagged in r's comment?
; derive: also count words typed identically to a named word up to the firing
; keystroke (benga -> bengal, bengals, benghazi for :*?:beng).
Covered(r, w, derive) {
    if NotedWord(r, w)
        return true
    if (!derive || r.comment = "")
        return false
    fp := FirePrefix(w, r)
    return (fp != "" && NotedPrefixes(r).Has(fp))
}

NormOpts(opts) {
    s := "", pos := 1
    while (pos := RegExMatch(opts, "i)S[IPE]|[A-Z]\d*|[*?]\d*", &m, pos))
        s .= StrUpper(m[0]) "`n", pos += m.Len
    return StrReplace(Sort(RTrim(s, "`n"), "U"), "`n", "")
}

; Sort an array of objects by a numeric key, descending (stable).
SortRows(arr, keyFn) {
    if !arr.Length
        return []
    s := ""
    for i, e in arr
        s .= Format("{:015d}|{:07d}", 999999999999999 - keyFn(e), i) "`n"
    res := []
    Loop Parse Sort(RTrim(s, "`n")), "`n"
        res.Push(arr[Integer(SubStr(A_LoopField, InStr(A_LoopField, "|") + 1))])
    return res
}

FmtFreq(n) => n >= 1000000 ? Format("{:.2f}M", n / 1000000) : n >= 1000 ? Format("{:.1f}K", n / 1000) : String(n)

Join(arr, sep) {
    s := ""
    for x in arr
        s .= (s = "" ? "" : sep) x
    return s
}

SumF(rows) {
    t := 0
    for e in rows
        t += e.f
    return t
}

; ---------------------------------------------------------------- row formats
CorruptRow(e) => Format("  {:8}  {:-20} -> {:-20} {:-9}{}", FmtFreq(e.f), e.w, e.out, e.r.loc ":", e.r.raw)
WorstRow(e)   => Format("  {:8}  {:4} words  {:-9}{}", FmtFreq(e.f), e.cnt, e.r.loc ":", e.r.raw)
              . "`n              e.g. " Join(e.ex, ", ")
DupRow(e) {
    locs := ""
    for r in e.v
        locs .= (locs = "" ? "" : ", ") r.loc
    return "  " locs ": " e.v[1].raw
}
ShadowRow(e)  => "  " e.r.loc ": " e.r.raw "`n      shadowed by " e.w.loc ": " e.w.raw
RuleRow(r)    => "  " r.loc ": " r.raw

; ---------------------------------------------------------------- report text
class Report {
    __New(opt) {
        this.opt := opt, this.out := ""
    }
    Fit(s) => (this.opt.trunc && StrLen(s) > this.opt.width) ? SubStr(s, 1, this.opt.width - 1) Chr(0x2026) : s
    Add(s) {
        for ln in StrSplit(s, "`n")
            this.out .= this.Fit(ln) "`n"
    }
    Section(title, rows, fmt, hidden := 0) {
        this.out .= "=== " title ": " rows.Length
            . (hidden ? "  (+" hidden " hidden: already noted in the rule's comment)" : "") " ===`n"
        top := this.opt.rows
        for k, e in rows {
            if (top && k > top) {
                this.out .= "  ... " (rows.Length - top) " more (set Rows per section to 0 to see all)`n"
                break
            }
            this.Add(fmt(e))
        }
        this.out .= "`n"
    }
}

; ================================================================ the audit
RunAudit(opt) {
    t0 := A_TickCount
    Progress("Loading libraries...", 1)
    libs := LibsFor(opt)
    rules := LoadRules(libs)
    if !rules.Length
        throw Error("No hotstrings found.  Check the library paths in acSettings.ini [Files].")
    Progress("Loading word list...", 3)
    wl := GetWords()
    words := wl.words, wset := wl.set, freq := wl.freq, total := words.Length
    ix := BuildIndex(rules)
    nulls := 0, actions := 0
    for r in rules
        nulls += r.null, actions += r.action

    rep := Report(opt)
    legend := ""
    for lib in libs
        if FileExist(lib.path) {
            SplitPath(lib.path, &nm)
            legend .= (legend = "" ? "" : "   ") lib.tag " = " nm
        }
    rep.out := "Hotstring Auditor  " FormatTime(, "yyyy-MM-dd HH:mm") "`n"
        . "Libraries (include order): " legend "`n"
        . "  " rules.Length " hotstrings (" nulls " nullifiers, " actions " actions), longest trigger " ix.maxlen "`n"
        . "  " total " reference words`n"
        . "Options: sections " opt.sections "; rows per section " (opt.rows ? opt.rows : "all")
        . (opt.trunc ? "; lines cut at " opt.width " chars" : "")
        . (opt.hideNoted ? "; problems noted in comments hidden" (opt.hideDerived ? " (with derivatives)" : "") : "") "`n`n"

    ; ---- 1. CORRUPTIONS: a real word gets silently changed ------------------
    if (Wants(opt, "1a") || Wants(opt, "1b") || Wants(opt, "1c")) {
        Progress("1. Simulating every word...", 5)
        corrupt := []
        for k, w in words {
            if (Mod(k, 5000) = 0)
                Progress("1. Simulating every word... " k " / " total, 5 + 55 * k / total)
            r := WinnerFor(w, ix)
            if (!IsObject(r) || r.null || r.action)
                continue
            res := ResultOf(w, r)
            if (res == w || StrLower(res) = w)
                continue                      ; capitalisation rules are intentional
            corrupt.Push({f: freq.Has(w) ? freq[w] : 0, w: w, out: res, r: r})
        }
        corrupt := SortRows(corrupt, e => e.f)
        hard := [], soft := [], hidHard := 0, hidSoft := 0
        for c in corrupt {
            isSoft := wset.Has(StrLower(c.out))
            if (opt.hideNoted && Covered(c.r, c.w, opt.hideDerived)) {
                isSoft ? hidSoft++ : hidHard++
                continue
            }
            (isSoft ? soft : hard).Push(c)
        }
        if Wants(opt, "1a")
            rep.Section("1a. REAL WORD -> NON-WORD (definite defects), combined web freq " FmtFreq(SumF(hard)), hard, CorruptRow, hidHard)
        if Wants(opt, "1b")
            rep.Section("1b. REAL WORD -> OTHER REAL WORD (review; many are intentional), combined web freq " FmtFreq(SumF(soft)), soft, CorruptRow, hidSoft)

        ; ---- 1c. worst OFFENDING RULES (the actionable view) ----------------
        if Wants(opt, "1c") {
            Progress("1c. Ranking rules...", 62)
            byRule := Map()
            for c in hard {
                key := c.r.loc
                if !byRule.Has(key)
                    byRule[key] := {r: c.r, cnt: 0, f: 0, ex: []}
                e := byRule[key], e.cnt += 1, e.f += c.f
                if (e.ex.Length < 4)
                    e.ex.Push(c.w "->" c.out)
            }
            worst := []
            for k, e in byRule
                worst.Push(e)
            rep.Section("1c. WORST OFFENDING RULES (from 1a)", SortRows(worst, e => e.f), WorstRow)
        }
    }

    ; ---- 2. DUPLICATE triggers ---------------------------------------------
    if Wants(opt, "2") {
        Progress("2. Duplicates...", 65)
        byTrig := Map(), dups := []
        for r in rules {
            key := r.trig "|" NormOpts(r.opts)
            if !byTrig.Has(key)
                byTrig[key] := []
            byTrig[key].Push(r)
        }
        for key, v in byTrig
            if (v.Length > 1)
                dups.Push({key: key, v: v})
        rep.Section("2. DUPLICATE trigger+options", dups, DupRow)
    }

    ; ---- 3. NO-OP rules -----------------------------------------------------
    if Wants(opt, "3") {
        noop := []
        for r in rules
            if (!r.null && !r.action && r.orepl == r.otrig)
                noop.Push(r)
        rep.Section("3. NO-OP rules (trigger == replacement)", noop, RuleRow)
    }

    ; ---- 4. UNREACHABLE rules (shadowed by an earlier rule) ----------------
    if Wants(opt, "4") {
        Progress("4. Unreachable rules...", 70)
        dead := []
        for r in rules {
            if r.multi
                continue
            shadow := "", reached := false
            ; A ? rule loses to a same-trigger * rule only when the word STARTS with
            ; the trigger -- it still wins on "xxx"+trigger.  Probe every context the
            ; options permit; only call it dead if nothing reaches it.
            for p in ProbesFor(r) {
                w := WinnerFor(p, ix)
                if (IsObject(w) && w.order = r.order) {
                    reached := true
                    break
                }
                if (IsObject(w) && !IsObject(shadow))
                    shadow := w
            }
            if (!reached && IsObject(shadow))
                dead.Push({r: r, w: shadow})
        }
        rep.Section("4. UNREACHABLE rules (no input reaches them)", dead, ShadowRow)
    }

    ; ---- 5. DEAD NULLIFIERS ------------------------------------------------
    if Wants(opt, "5") {
        Progress("5. Dead nullifiers...", 75)
        nonNull := []
        for r in rules
            if !r.null
                nonNull.Push(r)
        ixNN := BuildIndex(nonNull)
        deadNull := []
        for r in rules {
            if (!r.null || r.multi)
                continue
            breaks := false
            for p in ProbesFor(r) {
                w := WinnerFor(p, ixNN)
                if (IsObject(w) && !w.action && !(ResultOf(p, w) == p)) {
                    breaks := true
                    break
                }
            }
            if !breaks
                deadNull.Push(r)
        }
        rep.Section("5. DEAD NULLIFIERS (nothing would have broken this word)", deadNull, RuleRow)
    }

    ; ---- 6. BROKEN REPLACEMENTS --------------------------------------------
    ; A replacement is usually a fragment ("ings"), so "not a word" is not a defect.
    ; The defect is a fragment that can never land in a real word AT THE POSITION the
    ; rule's own options put it: :*: replaces a word's start, :?: its end, :*?:
    ; anywhere, plain replaces the whole word.
    if Wants(opt, "6") {
        Progress("6. Broken replacements (scanning fragments)...", 80)
        prefixes := Map(), suffixes := Map(), subsCand := Map(), subsSeen := Map(), cmax := 1, pmax := 1, smax := 1
        for r in rules {
            rp := StrLower(r.repl)
            if (r.null || r.action || rp = "" || !RegExMatch(rp, "^[a-z]+$"))
                continue
            if (r.star && r.q)
                subsCand[rp] := 1, cmax := Max(cmax, StrLen(rp))
            else if r.star
                prefixes[rp] := 0, pmax := Max(pmax, StrLen(rp))
            else if r.q
                suffixes[rp] := 0, smax := Max(smax, StrLen(rp))
        }
        for k, w in words {
            if (Mod(k, 10000) = 0)
                Progress("6. Broken replacements (scanning fragments)... " k " / " total, 80 + 18 * k / total)
            L := StrLen(w)
            Loop L {
                i := A_Index
                Loop Min(L - i + 1, cmax) {
                    s := SubStr(w, i, A_Index)
                    if subsCand.Has(s)
                        subsSeen[s] := 1
                }
            }
            ; prefixes / suffixes: look up every prefix / suffix of this word (cheap),
            ; rather than testing every candidate against every word.
            Loop Min(L, pmax) {
                pre := SubStr(w, 1, A_Index)
                if prefixes.Has(pre)
                    prefixes[pre] := 1
            }
            Loop Min(L, smax) {
                sfx := SubStr(w, -A_Index)
                if suffixes.Has(sfx)
                    suffixes[sfx] := 1
            }
        }
        broken := [], hidBroken := 0
        for r in rules {
            rp := StrLower(r.repl)
            if (r.null || r.action || rp = "" || !RegExMatch(rp, "^[a-z]+$") || RegExMatch(r.orepl, "^[A-Z]"))
                continue                      ; proper nouns / phrases are intentional
            if (r.star && r.q)
                ok := subsSeen.Has(rp)
            else if r.star
                ok := prefixes[rp]
            else if r.q
                ok := suffixes[rp]
            else
                ok := wset.Has(rp)
            if ok
                continue
            if (opt.hideNoted && RegExMatch(r.comment, "i)check replacement")) {
                hidBroken++
                continue
            }
            broken.Push(r)
        }
        rep.Section("6. BROKEN REPLACEMENTS (cannot produce a real word at this position)", broken, RuleRow, hidBroken)
    }

    secs := Round((A_TickCount - t0) / 1000, 1)
    rep.out .= "Done in " secs " s`n"
    return {text: rep.out, secs: secs}
}
