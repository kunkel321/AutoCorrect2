; ============================================================
; Hotstring Auditor -- whole-library conflict auditor for AutoCorrect2
; Part of the AutoCorrect2 Suite.  No dependencies beyond AutoHotkey v2.
; AHK port of AuditHotstringLib.py (VitaKaninen, 2026-09).
; ============================================================
; Version Date: 11-10-2026 
;
; Simulates AutoHotkey's hotstring firing order across every correctly-spelled
; word in the word list and reports what actually breaks.  Reads BOTH libraries
; (PersonalHotstrings.ahk first, then AutoCorrectHotstrings.ahk -- the order
; AutoCorrect2.ahk #Includes them, which is what decides ties).
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
;
; Report sections:
;   1a real word -> non-word (definite defects)     1b real word -> other real word
;   1c worst offending rules                        2  duplicate trigger+options
;   3  no-op rules                                  4  unreachable (shadowed) rules
;   5  dead nullifiers                              6  broken replacements
;
; Output: ..\Debug\HotstringAudit.txt (opened when done).  ~20-40 s for 249k words.
; ============================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)

TOP := 40   ; rows per section; pass "all" on the command line for everything
if (A_Args.Length && A_Args[1] = "all")
    TOP := 0

settings := "..\Data\acSettings.ini"
libAC  := "..\Core\" IniRead(settings, "Files", "HotstringLibrary", "AutoCorrectHotstrings.ahk")
libBP  := "..\Core\" IniRead(settings, "Files", "BoilerplateHotstringLibrary", "PersonalHotstrings.ahk")
wlFile := "..\Data\" IniRead(settings, "Files", "WordListFile", "ExamPaneWordList253k.txt")
fqFile := "..\Data\" IniRead(settings, "Files", "FrequencyListFile", "unigram_freq_list_filtered_89k.csv")
outFile := "..\Debug\HotstringAudit.txt"

; ---------------------------------------------------------------- progress GUI
prog := Gui("+AlwaysOnTop -MinimizeBox", "Hotstring Auditor")
prog.SetFont("s10")
progText := prog.AddText("w420", "Loading libraries...")
progBar  := prog.AddProgress("w420 h18 Range0-100", 0)
prog.Show()
Progress(text, pct := "") {
    global progText, progBar
    progText.Text := text
    if (pct != "")
        progBar.Value := pct
}

; ---------------------------------------------------------------- rules
class Rule {
    ; order = position across both files in include order (decides ties);
    ; line = the line in its own file (what the report prints).
    __New(order, line, file, opts, trig, replRaw, raw) {
        this.order := order, this.line := line, this.file := file, this.opts := opts, this.raw := raw
        ; C = case-sensitive.  The word list is lowercase, so a C rule whose trigger
        ; has uppercase can never match it -- keep the case and let the index decide.
        this.cs := InStr(opts, "C") && !InStr(opts, "C1")
        body := Trim(replRaw)
        if (SubStr(body, 1, 1) = ";")
            body := ""
        else if (p := RegExMatch(body, "\s;"))
            body := Trim(SubStr(body, 1, p - 1))
        this.null := (body = "")
        rp := body
        if RegExMatch(body, "^f\(\s*([`"'])(.*?)\1", &m)
            rp := m[2]
        this.otrig := trig, this.orepl := rp
        this.trig := this.cs ? trig : StrLower(trig)
        this.repl := this.cs ? rp : StrLower(rp)
        this.star := InStr(opts, "*") ? 1 : 0
        this.q    := InStr(opts, "?") ? 1 : 0
        this.multi := InStr(trig, " ") ? 1 : 0
    }
}

LoadRules(files) {
    rules := []
    n := 0
    for file in files {
        if !FileExist(file)
            continue
        short := SubStr(file, InStr(file, "\", , -1) + 1)
        Loop Parse FileRead(file, "UTF-8"), "`n", "`r" {
            n++
            s := Trim(A_LoopField)
            if RegExMatch(s, "^:([^:]*):((?:[^:]|:(?!:))+)::(.*)$", &m)
                rules.Push(Rule(n, A_Index, short, m[1], m[2], m[3], s))
        }
    }
    return rules
}

LoadWords(wlFile, fqFile) {
    words := [], seen := Map(), freq := Map()
    Loop Parse FileRead(wlFile, "CP1252"), "`n", "`r" {
        w := StrLower(Trim(A_LoopField))
        if (w != "" && !seen.Has(w))
            seen[w] := 1, words.Push(w)
    }
    if FileExist(fqFile) {
        Loop Parse FileRead(fqFile, "CP1252"), "`n", "`r" {
            p := InStr(A_LoopField, ",")
            if (p && IsInteger(v := Trim(SubStr(A_LoopField, p + 1))))
                freq[StrLower(Trim(SubStr(A_LoopField, 1, p - 1)))] := Integer(v)
        }
    }
    return {words: words, set: seen, freq: freq}
}

BuildIndex(rules) {
    idx := Map(), maxlen := 1
    for r in rules {
        if r.multi
            continue
        if !idx.Has(r.trig)
            idx[r.trig] := []
        idx[r.trig].Push(r)
        maxlen := Max(maxlen, StrLen(r.trig))
    }
    return {idx: idx, maxlen: maxlen}
}

; The rule that actually fires when `word` is typed, or "" if none.
WinnerFor(word, ix) {
    best := "", bestFire := 0, bestOrder := 0
    L := StrLen(word), idx := ix.idx, maxlen := ix.maxlen
    Loop L {
        i := A_Index                          ; 1-based start
        jmax := Min(L, i - 1 + maxlen)
        Loop jmax - i + 1 {
            j := i - 1 + A_Index              ; 1-based end (inclusive)
            sub := SubStr(word, i, j - i + 1)
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
                if (best = "" || fires < bestFire || (fires = bestFire && r.order < bestOrder))
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
        i := InStr(word, t, true)
    else if r.star
        i := 1
    else
        i := StrLen(word) - StrLen(t) + 1
    return SubStr(word, 1, i - 1) r.repl SubStr(word, i + StrLen(t))
}

M(n) => Format("{:.2f}M", n / 1000000)
Cut(s, n) => SubStr(s, 1, n)

; ================================================================ run
t0 := A_TickCount
rules := LoadRules([libBP, libAC])
Progress("Loading word list...", 3)
wl := LoadWords(wlFile, fqFile)
words := wl.words, wset := wl.set, freq := wl.freq
ix := BuildIndex(rules)
nulls := 0
for r in rules
    nulls += r.null
out := "Hotstring Auditor  " FormatTime(, "yyyy-MM-dd HH:mm") "`n"
    . "Libraries : " libBP "  then  " libAC "`n"
    . "  " rules.Length " hotstrings (" nulls " nullifiers), longest trigger " ix.maxlen "`n"
    . "  " words.Length " reference words`n`n"

; ---- 1. CORRUPTIONS: a real word gets silently changed ------------------
Progress("1. Simulating every word...", 5)
corrupt := []
total := words.Length
for k, w in words {
    if (Mod(k, 5000) = 0)
        Progress("1. Simulating every word... " k " / " total, 5 + 55 * k / total)
    r := WinnerFor(w, ix)
    if (r = "" || r.null)
        continue
    res := ResultOf(w, r)
    if (res == w || StrLower(res) = w)
        continue                          ; capitalisation rules are intentional
    corrupt.Push({f: freq.Has(w) ? freq[w] : 0, w: w, out: res, r: r})
}
; sort by frequency, descending
SortRows(arr, keyFn) {
    tmp := []
    for e in arr
        tmp.Push(Format("{:015d}", 999999999999999 - keyFn(e)) "|" A_Index)
    s := ""
    for x in tmp
        s .= x "`n"
    s := Sort(RTrim(s, "`n"))
    res := []
    Loop Parse s, "`n"
        res.Push(arr[Integer(SubStr(A_LoopField, InStr(A_LoopField, "|") + 1))])
    return res
}
corrupt := SortRows(corrupt, e => e.f)
hard := [], soft := []
for c in corrupt
    (wset.Has(StrLower(c.out)) ? soft : hard).Push(c)

Section(title, rows, fmt) {
    global out, TOP
    out .= "=== " title ": " rows.Length " ===`n"
    for k, e in rows {
        if (TOP && k > TOP) {
            out .= "  ... " (rows.Length - TOP) " more (run with 'all')`n"
            break
        }
        out .= fmt(e) "`n"
    }
    out .= "`n"
}
sumF(rows) {
    t := 0
    for e in rows
        t += e.f
    return t
}
Section("1a. REAL WORD -> NON-WORD (definite defects), combined web freq " M(sumF(hard)), hard,
    e => Format("  {:9}  {:-20} -> {:-20} {} line {}: {}", M(e.f), e.w, e.out, e.r.file, e.r.line, Cut(e.r.raw, 58)))
Section("1b. REAL WORD -> OTHER REAL WORD (review; many are intentional), combined web freq " M(sumF(soft)), soft,
    e => Format("  {:9}  {:-20} -> {:-20} {} line {}: {}", M(e.f), e.w, e.out, e.r.file, e.r.line, Cut(e.r.raw, 58)))

; ---- 1c. worst OFFENDING RULES (the actionable view) --------------------
Progress("1c. Ranking rules...", 62)
byRule := Map()
for c in hard {
    key := c.r.file ":" c.r.line
    if !byRule.Has(key)
        byRule[key] := {r: c.r, cnt: 0, f: 0, ex: []}
    e := byRule[key], e.cnt += 1, e.f += c.f
    if (e.ex.Length < 4)
        e.ex.Push(c.w "->" c.out)
}
worst := []
for k, e in byRule
    worst.Push(e)
worst := SortRows(worst, e => e.f)
Section("1c. WORST OFFENDING RULES (from 1a)", worst, (e) => (
    Format("  {:8}  {:4} words  {} line {}: {}", M(e.f), e.cnt, e.r.file, e.r.line, Cut(e.r.raw, 56))
    . "`n              e.g. " Join(e.ex, ", ")))
Join(arr, sep) {
    s := ""
    for x in arr
        s .= (s = "" ? "" : sep) x
    return s
}

; ---- 2. DUPLICATE triggers ---------------------------------------------
Progress("2-3. Duplicates and no-ops...", 65)
byTrig := Map(), dups := []
for r in rules {
    key := r.trig "|" r.opts
    if !byTrig.Has(key)
        byTrig[key] := []
    byTrig[key].Push(r)
}
for key, v in byTrig
    if (v.Length > 1)
        dups.Push({key: key, v: v})
DupLine(e) {
    lines := ""
    for r in e.v
        lines .= (lines = "" ? "" : ", ") r.file ":" r.line
    return "  " e.v[1].raw "   lines " lines
}
Section("2. DUPLICATE trigger+options", dups, DupLine)

; ---- 3. NO-OP rules -----------------------------------------------------
noop := []
for r in rules
    if (!r.null && r.orepl == r.otrig)
        noop.Push(r)
Section("3. NO-OP rules (trigger == replacement)", noop, r => "  " r.file " line " r.line ": " Cut(r.raw, 80))

; ---- 4. UNREACHABLE rules (shadowed by an earlier rule) ----------------
Progress("4. Unreachable rules...", 70)
dead := []
for r in rules {
    if (r.null || r.multi)
        continue
    t := r.trig, shadow := "", reached := false
    ; A ? rule loses to a same-trigger * rule only when the word STARTS with the
    ; trigger -- it still wins on "xxx"+trigger.  Probe every context the options
    ; permit; only call it dead if nothing reaches it.
    for p in [t, "q" t, t "q", "q" t "q"] {
        w := WinnerFor(p, ix)
        if (w != "" && w.line = r.line && w.file = r.file) {
            reached := true
            break
        }
        if (w != "" && shadow = "")
            shadow := w
    }
    if (!reached && shadow != "")
        dead.Push({r: r, w: shadow})
}
Section("4. UNREACHABLE rules (no input reaches them)", dead, e =>
    "  " e.r.file " line " e.r.line ": " Cut(e.r.raw, 52) "`n      shadowed by " e.w.file " line " e.w.line ": " Cut(e.w.raw, 52))

; ---- 5. DEAD NULLIFIERS ------------------------------------------------
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
    w := WinnerFor(r.trig, ixNN)
    if (w = "" || ResultOf(r.trig, w) == r.trig)
        deadNull.Push(r)
}
Section("5. DEAD NULLIFIERS (nothing would have broken this word)", deadNull, r => "  " r.file " line " r.line ": " Cut(r.raw, 80))

; ---- 6. BROKEN REPLACEMENTS --------------------------------------------
; A replacement is usually a fragment ("ings"), so "not a word" is not a defect.
; The defect is a fragment that can never land in a real word AT THE POSITION the
; rule's own options put it: :*: replaces a word's start, :?: its end, :*?:
; anywhere, plain replaces the whole word.
Progress("6. Broken replacements (scanning fragments)...", 80)
prefixes := Map(), suffixes := Map(), subsCand := Map(), subsSeen := Map(), cmax := 1, pmax := 1, smax := 1
for r in rules {
    if (r.null || r.repl = "" || !RegExMatch(r.repl, "^[a-zA-Z]+$"))
        continue
    if (r.star && r.q)
        subsCand[r.repl] := 1, cmax := Max(cmax, StrLen(r.repl))
    else if r.star
        prefixes[r.repl] := 0, pmax := Max(pmax, StrLen(r.repl))
    else if r.q
        suffixes[r.repl] := 0, smax := Max(smax, StrLen(r.repl))
}
for k, w in words {
    if (Mod(k, 10000) = 0)
        Progress("6. Broken replacements (scanning fragments)... " k " / " total, 80 + 18 * k / total)
    L := StrLen(w)
    Loop L {
        i := A_Index
        Loop Min(L, i - 1 + cmax) - i + 1 {
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
broken := []
for r in rules {
    rp := r.repl
    if (r.null || rp = "" || !RegExMatch(rp, "^[a-zA-Z]+$") || RegExMatch(r.orepl, "^[A-Z]"))
        continue                          ; proper nouns / phrases are intentional
    if (r.star && r.q)
        ok := subsSeen.Has(rp)
    else if r.star
        ok := prefixes[rp]
    else if r.q
        ok := suffixes[rp]
    else
        ok := wset.Has(rp)
    if !ok
        broken.Push(r)
}
Section("6. BROKEN REPLACEMENTS (cannot produce a real word at this position)", broken, r => "  " r.file " line " r.line ": " Cut(r.raw, 80))

out .= "Done in " Round((A_TickCount - t0) / 1000, 1) " s`n"
try FileDelete(outFile)
FileAppend(out, outFile, "UTF-8")
Progress("Done.  Report: " outFile, 100)
Run(outFile)
Sleep(1500)
ExitApp
