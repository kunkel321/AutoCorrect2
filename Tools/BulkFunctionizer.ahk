#SingleInstance Force
#Requires AutoHotkey v2.0
#Include "..\Includes\DpiKeepSize.ahk"   ; keeps its windows their size across monitors with different scales
SetWorkingDir(A_ScriptDir)

; ========================================
; BulkFunctionizer -- part of the AutoCorrect2 suite (lives in Tools\)
; Version: 11-27-2026
; Author: kunkel321
; AI Used: Claude
;
; Paste hotstrings into the big box, pick a mode, click Process.  The result
; replaces the box contents, ready to copy out.  Click Undo to get the input back.
;
; Modes
;   Functionize
;       ::Bjorn::Bjørn ; comment     ->   :B0X:Bjorn::f("Bjørn") ; comment
;       Lines already wrapped in f() are left as they are.
;   Rebuild metrics
;       Same wrapping, plus every AutoCorrect f() item gets fresh
;       "Web Freq n | Fixes n words" text, computed exactly the way
;       HotstringHelper does it, from the CURRENT word list and frequency CSV.
;       Boilerplate items (f(..., 0) or 3+ words) get no metrics, same as in HH.
;       Options:
;         Rebuild 'but misspells'  -- off: ONLY Web Freq / Fixes are replaced and
;                                     the rest of the comment is left exactly as is
;         Group word variations    -- benga, bengaline, bengalines: only the root
;                                     (benga) is listed and flagged
;         Honor :C: option         -- for case-sensitive (C) items, words that only
;                                     match in another case (beng vs Bengal) aren't
;                                     counted as misspelled
;         Flag Fixes changes >= n% -- flag items whose Fixes count changed a lot
;   Defunctionize  (replaces the old Defunctionizer.ahk)
;       :B0X*?:useing::f("using") ; Web Freq ...   ->   :*?:useing::using
;       Multi-line continuation-section f() items are converted too.
;       "Keep comments" off drops comments, except "but misspells" ones.
;
; Anything the tool doesn't recognize (blank lines, comments, code, X-option
; hotstrings, non-f() continuation sections) passes through untouched.
;
; Items that need a human look get a "; [REVIEW] ..." comment line above them.
; With "Group flagged items at bottom" checked, they are moved to two sections
; at the end: misspell problems first, then other changes.
;
; Press F1 on any control for help with it, or click [?] for general help.
;
; Settings in ..\Data\acSettings.ini (everything in the GUI is remembered there)
;   [Files]            WordListFile, FrequencyListFile   (same keys as AC2)
;   [BulkFunctionizer] Mode, GroupFlagged, RebuildMisspells, GroupVariations,
;                      HonorCaseOption, FlagBigChanges, BigChangePercent=20,
;                      DefuncKeepComments
;   (DefuncKeepComments replaces the old [Defunctionizer] keepComments key; the old
;    key is read once if the new one is missing, then removed.)
; ========================================

BFConfig.Load()
App.Build()

; =============== CONFIGURATION ===============
class BFConfig {
    static SettingsFile := "..\Data\acSettings.ini"
    static ThemeFile := "..\Data\colorThemeSettings.ini"
    static WordListFile := "..\Data\ExamPaneWordList253k.txt"
    static FrequencyListFile := "..\Data\unigram_freq_list_filtered_102k.csv"
    static BigChangePercent := 20
    static FontColor := "c000000"
    static ListColor := "FFFFFF"
    static FormColor := "F0F0F0"
    ; Remembered UI state
    static Mode := 1                ; 1 functionize, 2 rebuild, 3 defunctionize
    static GroupFlagged := 1
    static RebuildMisspells := 1
    static GroupVariations := 1
    static HonorCaseOption := 1
    static FlagBigChanges := 0
    static KeepComments := 0

    static Load() {
        f := this.SettingsFile
        if FileExist(f) {
            this.WordListFile      := "..\Data\" IniRead(f, "Files", "WordListFile", "ExamPaneWordList253k.txt")
            this.FrequencyListFile := "..\Data\" IniRead(f, "Files", "FrequencyListFile", "unigram_freq_list_filtered_102k.csv")
            this.BigChangePercent  := this.Num(IniRead(f, "BulkFunctionizer", "BigChangePercent", "20"), 20)
            this.Mode              := this.Num(IniRead(f, "BulkFunctionizer", "Mode", "1"), 1)
            this.GroupFlagged      := this.Num(IniRead(f, "BulkFunctionizer", "GroupFlagged", "1"), 1)
            this.RebuildMisspells  := this.Num(IniRead(f, "BulkFunctionizer", "RebuildMisspells", "1"), 1)
            this.GroupVariations   := this.Num(IniRead(f, "BulkFunctionizer", "GroupVariations", "1"), 1)
            this.HonorCaseOption   := this.Num(IniRead(f, "BulkFunctionizer", "HonorCaseOption", "1"), 1)
            this.FlagBigChanges    := this.Num(IniRead(f, "BulkFunctionizer", "FlagBigChanges", "0"), 0)
            ; New key, falling back to the old Defunctionizer.ahk key the first time
            old := IniRead(f, "Defunctionizer", "keepComments", "0")
            this.KeepComments      := this.Num(IniRead(f, "BulkFunctionizer", "DefuncKeepComments", old), 0)
        }
        if (this.Mode < 1 || this.Mode > 3)
            this.Mode := 1
        if FileExist(this.ThemeFile) {
            try this.FontColor := "c" IniRead(this.ThemeFile, "ColorSettings", "fontColor")
            try this.ListColor := IniRead(this.ThemeFile, "ColorSettings", "listColor")
            try this.FormColor := IniRead(this.ThemeFile, "ColorSettings", "formColor")
        }
    }

    static Save() {
        f := this.SettingsFile
        if !FileExist(f)
            return
        try {
            IniWrite(this.Mode,             f, "BulkFunctionizer", "Mode")
            IniWrite(this.GroupFlagged,     f, "BulkFunctionizer", "GroupFlagged")
            IniWrite(this.RebuildMisspells, f, "BulkFunctionizer", "RebuildMisspells")
            IniWrite(this.GroupVariations,  f, "BulkFunctionizer", "GroupVariations")
            IniWrite(this.HonorCaseOption,  f, "BulkFunctionizer", "HonorCaseOption")
            IniWrite(this.FlagBigChanges,   f, "BulkFunctionizer", "FlagBigChanges")
            IniWrite(this.BigChangePercent, f, "BulkFunctionizer", "BigChangePercent")
            IniWrite(this.KeepComments,     f, "BulkFunctionizer", "DefuncKeepComments")
        }
        ; Retire the old [Defunctionizer] keepComments key (and the section, if empty)
        try {
            IniDelete(f, "Defunctionizer", "keepComments")
            if (Trim(IniRead(f, "Defunctionizer"), " `t`r`n") = "")
                IniDelete(f, "Defunctionizer")
        }
    }

    static Num(v, dflt) => IsNumber(v) ? Number(v) : dflt
}

; =============== WORD DATA ===============
; Everything is indexed once at load, so no lookup ever walks the whole list:
;   whole word  -> WholeMap: lowercase word -> its spellings
;   beginning   -> Begin3:   first 3 letters -> word indices, then a prefix check
;   ending      -> End3:     last 3 letters  -> word indices, then a suffix check
;   middle      -> InStr over one lowercase string of the whole list
; Needles shorter than 3 letters fall back to the string search.
; Matching is case-insensitive, same as HH's InStr / = comparisons.
;
; The big strings are GLOBALS on purpose.  Reading a string out of a class
; property can copy it, and a 5 MB copy per InStr() call is what made v1 of
; this tool crawl (about 1 s per hotstring).
global WD_Lower := ""   ; "`nword1`nword2`n...`n", lowercased
global WD_Orig  := ""   ; same text, original case (identical offsets)

class WordData {
    static Lower := []      ; index -> lowercase word
    static Orig := []       ; index -> word as written in the list
    static WholeMap := Map()
    static Begin3 := Map()
    static End3 := Map()
    static Freq := Map()
    static Loaded := false

    static Load() {
        global WD_Lower, WD_Orig
        if this.Loaded
            return true
        if !FileExist(BFConfig.WordListFile) {
            MsgBox("Word list not found:`n" BFConfig.WordListFile, "Bulk Functionizer", 16)
            return false
        }
        txt := StrReplace(FileRead(BFConfig.WordListFile), "`r")
        WD_Orig := "`n" Trim(txt, "`n") "`n"
        WD_Lower := StrLower(WD_Orig)

        this.Lower := [], this.Orig := []
        this.WholeMap := Map(), this.Begin3 := Map(), this.End3 := Map()
        Loop Parse, txt, "`n" {
            if (A_LoopField = "")
                continue
            w := A_LoopField
            lw := StrLower(w)
            this.Orig.Push(w)
            this.Lower.Push(lw)
            idx := this.Orig.Length
            if !this.WholeMap.Has(lw)
                this.WholeMap[lw] := []
            this.WholeMap[lw].Push(w)
            if (StrLen(lw) >= 3) {
                k := SubStr(lw, 1, 3)
                if !this.Begin3.Has(k)
                    this.Begin3[k] := []
                this.Begin3[k].Push(idx)
                k := SubStr(lw, -3)
                if !this.End3.Has(k)
                    this.End3[k] := []
                this.End3[k].Push(idx)
            }
        }

        ; Frequency CSV: word,count -- lowercased keys, duplicates summed (same as HH)
        this.Freq := Map()
        if FileExist(BFConfig.FrequencyListFile) {
            Loop Parse, FileRead(BFConfig.FrequencyListFile), "`n", "`r" {
                p := InStr(A_LoopField, ",")
                if !p
                    continue
                w := StrLower(Trim(SubStr(A_LoopField, 1, p - 1)))
                f := Trim(SubStr(A_LoopField, p + 1))
                if (w = "" || !IsNumber(f))
                    continue
                this.Freq[w] := (this.Freq.Has(w) ? this.Freq[w] : 0) + Number(f)
            }
        }
        else
            MsgBox("Frequency file not found:`n" BFConfig.FrequencyListFile "`n`nWeb Freq will be 0 for everything.", "Bulk Functionizer", 48)

        this.Loaded := true
        return true
    }

    ; Returns an Array of the word-list lines that match.  mode: whole|begin|end|mid
    static Matches(needle, mode) {
        out := []
        if (needle = "" || InStr(needle, "`n"))
            return out
        nl := StrLower(needle)
        L := StrLen(nl)
        if (mode = "whole")
            return this.WholeMap.Has(nl) ? this.WholeMap[nl].Clone() : out

        ; Bucket lookups for beginning / ending
        if (L >= 3 && (mode = "begin" || mode = "end")) {
            if (mode = "begin") {
                k := SubStr(nl, 1, 3)
                if this.Begin3.Has(k)
                    for idx in this.Begin3[k]
                        if (SubStr(this.Lower[idx], 1, L) == nl)
                            out.Push(this.Orig[idx])
            } else {
                k := SubStr(nl, -3)
                if this.End3.Has(k)
                    for idx in this.End3[k]
                        if (SubStr(this.Lower[idx], -L) == nl)
                            out.Push(this.Orig[idx])
            }
            return out
        }
        return this.ScanBlob(nl, mode)
    }

    ; String search over the lowercase list (middle matches, short needles).
    ; Case-sensitive InStr on lowercased text = case-insensitive match, but faster.
    static ScanBlob(nl, mode) {
        global WD_Lower, WD_Orig
        out := []
        pat := (mode = "begin") ? "`n" nl : (mode = "end") ? nl "`n" : nl
        lead := (mode = "begin")
        len := StrLen(WD_Lower)
        start := 1
        while (pos := InStr(WD_Lower, pat, true, start)) {
            if lead
                ls := pos + 1
            else {
                ; search right-to-left from pos-1 for the newline that starts this line
                nlPos := InStr(WD_Lower, "`n", true, pos - len - 2)
                ls := nlPos + 1
            }
            le := InStr(WD_Lower, "`n", true, ls)
            out.Push(SubStr(WD_Orig, ls, le - ls))
            start := le   ; next match must be on a later line
        }
        return out
    }

    static FreqSum(words) {
        total := 0
        for w in words {
            key := StrLower(w)
            if this.Freq.Has(key)
                total += this.Freq[key]
        }
        return total
    }
}

; =============== COMMENT PARSER ===============
; Splits an existing inline comment into:
;   oldFixes  -- the old "Fixes n" number (or "" if none)
;   defs      -- Map of lowercase word -> {w, d} from "but misspells w (d), w2 (d2)"
;   order     -- the defs keys in their original order
;   rawClause -- set if a "but misspells" clause was found but couldn't be parsed;
;                it is then kept word-for-word and the item gets flagged
;   manual    -- every other bit of comment text
;   sep       -- the punctuation (, or .) that separated the misspells list from
;                the manual text, so a rebuild doesn't change it
; Repeated "but misspells" clauses (left behind when HH re-saves an item that
; already had one) are merged; a filled-in definition wins over an empty "()".
class CommentParser {
    ; The auto-written metrics at the front of a comment
    static ReMetrics := 'i)^\h*(?<F>Web\h+Freq\h+[\d.]+)?[\h,|]*(?:Fixes\h*(?<N>\d+)\h*words?\b(?:\h*!!!\h*CHECK REPLACEMENT - it matches no real word)?)?[\h,|]*'

    static Parse(body) {
        r := {oldFixes: "", defs: Map(), order: [], rawClause: "", manual: "", sep: ""}
        RegExMatch(body, this.ReMetrics, &m)
        if (m.N != "")
            r.oldFixes := Integer(m.N)
        rest := SubStr(body, m.Len + 1)

        if !RegExMatch(rest, "i)\bbut\h+misspells\h+", &mm) {
            r.manual := Trim(rest)
            return r
        }
        prefix := Trim(SubStr(rest, 1, mm.Pos - 1), " `t,.;|")
        clauseStart := mm.Pos
        pos := mm.Pos + mm.Len
        ok := true
        loop {
            if RegExMatch(rest, "i)\G(\d+)\h+words?\h*(?:!!!)?", &cm, pos)
                pos := cm.Pos + cm.Len               ; "but misspells 12 words !!!" form
            else if !this.ParseDefList(rest, &pos, r) {
                ok := false
                break
            }
            if RegExMatch(rest, "i)\G[\h.,;]*but\h+misspells\h+", &dm, pos)
                pos := dm.Pos + dm.Len               ; duplicate clause -- merge it
            else
                break
        }
        if ok {
            tail := SubStr(rest, pos)
            if RegExMatch(tail, "^\h*([,.;])", &sm)
                r.sep := sm[1]
            suffix := RTrim(LTrim(tail, " `t,.;"), " `t")
        }
        else {
            r.rawClause := Trim(SubStr(rest, clauseStart), " `t")
            r.defs := Map()
            r.order := []
            suffix := ""
        }
        r.manual := Trim(prefix ((prefix != "" && suffix != "") ? " " : "") suffix)
        return r
    }

    ; Parses  word (def), word2 (def2) and word3 (def3)  starting at pos.
    ; Definitions may contain nested parentheses and commas.
    static ParseDefList(s, &pos, r) {
        count := 0
        n := StrLen(s)
        loop {
            if !RegExMatch(s, "\G\h*([^\s(),]+)\h*\(", &wm, pos)
                return count > 0
            word := wm[1]
            p := wm.Pos + wm.Len
            depth := 1
            i := p
            while (i <= n) {
                ch := SubStr(s, i, 1)
                if (ch = "(")
                    depth++
                else if (ch = ")") {
                    depth--
                    if (depth = 0)
                        break
                }
                i++
            }
            if (depth != 0)
                return false
            def := Trim(SubStr(s, p, i - p))
            key := StrLower(word)
            if !r.defs.Has(key) {
                r.defs[key] := {w: word, d: def}
                r.order.Push(key)
            }
            else if (r.defs[key].d = "" && def != "")
                r.defs[key].d := def
            pos := i + 1
            count++
            if !RegExMatch(s, "i)\G\h*(?:,|\band\b)\h*(?=[^\s(),]+\h*\()", &sm, pos)
                return true
            pos := sm.Pos + sm.Len
        }
    }

    ; "Rebuild 'but misspells'" off: swap ONLY the Web Freq / Fixes text and keep
    ; every other character of the comment as it was.
    static ReplaceMetrics(body, auto) {
        if RegExMatch(body, 'i)^\h*(?:Web\h+Freq\h+[\d.]+\h*\|?\h*)?Fixes\h*\d+\h*words?\b(?:\h*!!!\h*CHECK REPLACEMENT - it matches no real word)?', &m)
            return auto SubStr(body, m.Len + 1)
        if RegExMatch(body, 'i)^\h*Web\h+Freq\h+[\d.]+', &m)
            return auto SubStr(body, m.Len + 1)
        b := Trim(body)
        if (b = "")
            return auto
        return auto (RegExMatch(b, "i)^but\h+misspells") ? ", " : " ") b
    }
}

; =============== PROCESSOR ===============
class Processor {
    ; :opts:trig::f("repl", 0, 1) ; comment
    ; Trig is lazy up to the first "::", so triggers containing a colon
    ; (:B0X?:http:\\::f("http://")) parse too.
    static ReFunc := '^(?<Ind>\h*):(?<Opts>[^:]*):(?<Trig>.+?)::f\("(?<Repl>(?:[^"``]|``.)*)"(?<Params>(?:\h*,\h*[01]){0,2})\h*\)(?<Comm>\h+;.*)?$'
    ; :opts:trig::repl ; comment      (first whitespace+; starts the comment, as in AHK)
    static RePlain := '^(?<Ind>\h*):(?<Opts>[^:]*):(?<Trig>.+?)::(?<Repl>.*?\S)(?<Comm>\h+;.*)?$'
    ; first line of a continuation section:  :opts:trig::  or  :opts:trig::f("
    static ReOpener := '^\h*:[^:]*:.+?::(?:f\(")?(?:\h+;.*)?$'
    ; f() continuation header, for Defunctionize
    static ReFuncOpener := '^(?<Ind>\h*):(?<Opts>[^:]*):(?<Trig>.+?)::f\("(?<Comm>\h+;.*)?$'
    ; the ( line of a continuation section, with its optional modifiers
    static ReContOpen := '^\h*\((?:RTrim0?|LTrim0?|Join\S*|C|P\d+|\s)*\s*$'

    ; opt: {mode: "func"|"rebuild"|"defunc", group, misspells, variations, honorCase,
    ;       flagBig, keepComments}
    static Run(txt, opt, progress) {
        t0 := A_TickCount
        txt := StrReplace(StrReplace(txt, "`r`n", "`n"), "`r", "`n")
        lines := StrSplit(txt, "`n")
        st := {hs: 0, wrapped: 0, rebuilt: 0, same: 0, skipped: 0, defunc: 0, misFlag: 0, otherFlag: 0}
        out := {main: [], mis: [], oth: []}
        n := lines.Length
        i := 0
        lastTick := 0
        while (i < n) {
            i++
            line := lines[i]
            ; Update the status (and let Stop clicks through) about 3x a second
            if (A_TickCount - lastTick > 300) {
                lastTick := A_TickCount
                if progress(i, n, A_TickCount - t0)
                    return {canceled: true}
            }

            ; Continuation section: converted in Defunctionize mode, otherwise
            ; copied verbatim through the closing ) line
            if (i < n && RegExMatch(line, this.ReOpener) && RegExMatch(lines[i + 1], '^\h*\(')) {
                block := [line]
                j := i
                closed := false
                while (j < n) {
                    j++
                    block.Push(lines[j])
                    if RegExMatch(lines[j], '^\h*\)') {
                        closed := true
                        break
                    }
                }
                res := (opt.mode = "defunc" && closed) ? this.DefuncBlock(block, opt) : {kind: "raw"}
                if (res.kind = "hs")
                    this.Emit(res, out, st, opt)
                else
                    for l in block
                        out.main.Push(l)
                i := j
                continue
            }

            res := this.ProcessLine(line, opt)
            if (res.kind = "raw")
                out.main.Push(line)
            else
                this.Emit(res, out, st, opt)
        }

        main := out.main
        if opt.group {
            if out.mis.Length {
                main.Push("")
                main.Push("; ===== FLAGGED: MISSPELLS / NEEDS DEFINITION (" st.misFlag ") =====")
                for l in out.mis
                    main.Push(l)
            }
            if out.oth.Length {
                main.Push("")
                main.Push("; ===== FLAGGED: OTHER CHANGES (" st.otherFlag ") =====")
                for l in out.oth
                    main.Push(l)
            }
        }

        secs := Format("{:.1f}", (A_TickCount - t0) / 1000)
        summary := "Done in " secs " s.  " st.hs " hotstrings: "
        if (opt.mode = "defunc")
            summary .= st.defunc " defunctionized, "
        else
            summary .= st.wrapped " wrapped, " (opt.mode = "rebuild" ? st.rebuilt " metrics changed, " : "")
        summary .= st.same " unchanged, " st.skipped " skipped.  Flagged: "
            . st.misFlag " misspell, " st.otherFlag " other."
        return {canceled: false, text: this.Join(main, "`r`n"), summary: summary}
    }

    ; Send one processed item to the output, with its [REVIEW] line if flagged.
    static Emit(res, out, st, opt) {
        st.hs++
        st.%res.action%++
        if !res.flags.Length {
            out.main.Push(res.text)
            return
        }
        target := !opt.group ? out.main : (res.misFlag ? out.mis : out.oth)
        target.Push("; [REVIEW] " this.Join(res.flags, " | "))
        target.Push(res.text)
        if res.misFlag
            st.misFlag++
        else
            st.otherFlag++
    }

    static ProcessLine(line, opt) {
        if (opt.mode = "defunc")
            return this.DefuncLine(line, opt)
        if RegExMatch(line, this.ReFunc, &m) {
            item := {ind: m.Ind, opts: m.Opts, trig: m.Trig, repl: m.Repl, params: m.Params, comm: m.Comm}
            if (opt.mode != "rebuild")
                return {kind: "hs", action: "same", text: line, flags: [], misFlag: false}
            return this.Rebuild(item, line, false, opt)
        }
        if RegExMatch(line, this.RePlain, &m) {
            opts := m.Opts
            repl := Trim(m.Repl)
            if (InStr(opts, "X") || SubStr(repl, 1, 2) = "f(")
                return {kind: "raw"}               ; code hotstring / odd f( form -- leave alone
            if (InStr(repl, "{") || InStr(repl, "}"))
                return {kind: "hs", action: "skipped", text: line, misFlag: false
                    , flags: ["not wrapped: contains {} send syntax -- convert by hand"]}
            newOpts := "B0X" StrReplace(StrReplace(opts, "B0", ""), "X", "")
            q := RegExReplace(repl, '(?<!``)"', '``"')     ; escape bare double quotes
            item := {ind: m.Ind, opts: newOpts, trig: m.Trig, repl: q, params: "", comm: m.Comm}
            flags := []
            if (StrLen(repl) - StrLen(StrReplace(repl, " ")) > 2)
                flags.Push('wrapped, but looks like boilerplate -- HH would make it f("...", 0)')
            if (opt.mode = "rebuild" && !flags.Length)
                return this.Rebuild(item, line, true, opt)
            return {kind: "hs", action: "wrapped", text: this.Assemble(item, item.comm), flags: flags, misFlag: false}
        }
        return {kind: "raw"}
    }

    ; Recalculate metrics for one f() item.  wasWrapped = it started as a bare hotstring.
    static Rebuild(item, origLine, wasWrapped, opt) {
        replM := Trim(this.Unescape(item.repl))
        trigM := Trim(item.trig)

        ; Boilerplate gets no metrics -- same rule as HH (log=0 param, newline, or 3+ words)
        if (RegExMatch(item.params, '^\h*,\h*0') || InStr(replM, "`n")
            || StrLen(replM) - StrLen(StrReplace(replM, " ")) > 2)
            return {kind: "hs", action: wasWrapped ? "wrapped" : "skipped"
                , text: wasWrapped ? this.Assemble(item, item.comm) : origLine, flags: [], misFlag: false}

        mode := this.ModeFor(item.opts)
        fixes := WordData.Matches(replM, mode)

        body := RegExMatch(item.comm, '^\h+;\h?(.*)$', &cmm) ? cmm[1] : ""
        c := CommentParser.Parse(body)
        flags := []
        misFlag := false

        ; ---- Fixes / Web Freq (HH rules, including the 0-match cases) ----
        nFix := fixes.Length
        shownN := nFix
        freqF := Format("{:.2f}", WordData.FreqSum(fixes) / 1000000)
        fixTxt := "Fixes " nFix (nFix = 1 ? " word" : " words")
        if (nFix = 0) {
            if RegExMatch(replM, "^[A-Za-z]+$") {
                fixTxt := "Fixes 0 words !!! CHECK REPLACEMENT - it matches no real word"
                flags.Push("replacement matches no word in the list")
            }
            else {
                fixTxt := "Fixes 1 word"     ; phrase / grammar item
                shownN := 1
            }
        }
        auto := (freqF != "0.00" ? "Web Freq " freqF " | " : "") fixTxt

        if (opt.flagBig && c.oldFixes != "" && c.oldFixes != shownN) {
            if (c.oldFixes = 0)
                flags.Push("Fixes 0 -> " shownN)
            else {
                pct := (shownN - c.oldFixes) / c.oldFixes * 100
                if (Abs(pct) >= BFConfig.BigChangePercent)
                    flags.Push("Fixes " c.oldFixes " -> " shownN " (" (pct > 0 ? "+" : "") Round(pct) "%)")
            }
        }

        ; ---- Metrics only: leave the rest of the comment exactly as it was ----
        if !opt.misspells {
            full := CommentParser.ReplaceMetrics(body, auto)
            return this.Finish(item, full, origLine, wasWrapped, flags, false)
        }

        ; ---- "but misspells" ----
        mis := WordData.Matches(trigM, mode)
        ; C option: a case-sensitive trigger only fires on its exact case, so
        ; "beng" can't misspell Bengal.
        if (opt.honorCase && this.IsCaseSensitive(item.opts))
            mis := this.CaseFilter(mis, trigM, mode)

        consider := Map()           ; lowercase -> true, for the stale check
        for w in mis
            consider[StrLower(w)] := true
        stale := []
        for key in c.order
            if !consider.Has(key)
                stale.Push(c.defs[key])

        ; Which words get listed: every word, or (Group word variations) only the
        ; root of each family -- plus any variation that already has a definition.
        listed := []                ; {w, vars}
        if (opt.variations && mis.Length <= 300) {
            rootOf := this.GroupRoots(mis, mode)
            varCount := Map()
            for i, w in mis
                if (rootOf[i] != i)
                    varCount[rootOf[i]] := varCount.Get(rootOf[i], 0) + 1
            for i, w in mis {
                key := StrLower(w)
                hasDef := c.defs.Has(key) && c.defs[key].d != ""
                if (rootOf[i] = i || hasDef)
                    listed.Push({w: w, vars: varCount.Get(i, 0)})
            }
        }
        else
            for w in mis
                listed.Push({w: w, vars: 0})

        misTxt := ""
        if (c.rawClause != "") {
            misTxt := ", " c.rawClause
            flags.Push("couldn't parse the existing 'but misspells' text -- check by hand")
            misFlag := true
        }
        else if (listed.Length > 3 && c.defs.Count = 0) {
            misTxt := ", but misspells " mis.Length " words !!!"
            rootW := []
            for e in listed
                rootW.Push(e.w)
            flags.Push("misspells " mis.Length " words: " this.Join(rootW, ", ", 15))
            misFlag := true
        }
        else if (listed.Length || stale.Length) {
            parts := [], needDef := [], staleW := []
            for e in listed {
                key := StrLower(e.w)
                has := c.defs.Has(key)
                def := has ? c.defs[key].d : ""
                parts.Push((has ? c.defs[key].w : e.w) " (" def ")")
                if (def = "")
                    needDef.Push(e.w (e.vars ? " (+" e.vars " variation" (e.vars = 1 ? "" : "s") ")" : ""))
            }
            for s in stale {
                parts.Push(s.w " (" s.d ")")
                staleW.Push(s.w)
            }
            misTxt := ", but misspells " this.Join(parts, ", ")
            if needDef.Length {
                flags.Push("needs definition: " this.Join(needDef, ", "))
                misFlag := true
            }
            if staleW.Length {
                flags.Push("no longer misspelled (remove?): " this.Join(staleW, ", "))
                misFlag := true
            }
        }

        full := auto misTxt
        if (c.manual != "") {
            if (misTxt = "" || SubStr(misTxt, -3) = "!!!")
                full .= " " c.manual
            else
                full .= (c.sep != "" ? c.sep " " : ". ") c.manual
        }
        return this.Finish(item, full, origLine, wasWrapped, flags, misFlag)
    }

    static Finish(item, full, origLine, wasWrapped, flags, misFlag) {
        newLine := this.Assemble(item, " `; " full)
        action := wasWrapped ? "wrapped" : (RTrim(newLine) == RTrim(origLine) ? "same" : "rebuilt")
        return {kind: "hs", action: action, text: newLine, flags: flags, misFlag: misFlag}
    }

    ; For each word, the index of its root in the same array (its own index if it
    ; IS a root).  A word's root is the shortest other word in the list that it
    ; starts with -- or, for ending (?) items, also ends with:
    ;   benga <- bengaline, bengalines      Bengal <- Bengali, Bengalis, Bengals
    ; Same word in a different case counts as a variation of the first one.
    static GroupRoots(words, mode) {
        n := words.Length
        lw := []
        for w in words
            lw.Push(StrLower(w))
        parent := []
        Loop n {
            i := A_Index
            b := lw[i]
            lb := StrLen(b)
            best := 0
            Loop n {
                j := A_Index
                if (j = i)
                    continue
                a := lw[j]
                la := StrLen(a)
                if (la > lb)
                    continue
                if (la = lb && (a != b || j > i))   ; same length: only an earlier duplicate
                    continue
                if (SubStr(b, 1, la) == a || (mode = "end" && SubStr(b, -la) == a))
                    if (!best || la < StrLen(lw[best]))
                        best := j
            }
            parent.Push(best)
        }
        rootOf := []
        Loop n {
            r := A_Index
            guard := 0
            while (parent[r] && guard++ < n)
                r := parent[r]
            rootOf.Push(r)
        }
        return rootOf
    }

    ; C (case-sensitive) without 0/1 after it.  C0 = off, C1 = "don't conform case".
    static IsCaseSensitive(opts) => RegExMatch(opts, "i)C(?![01])") > 0

    ; Keep only the words the trigger matches in its exact case.
    static CaseFilter(words, trig, mode) {
        out := []
        L := StrLen(trig)
        for w in words {
            switch mode {
                case "whole": ok := (w == trig)
                case "begin": ok := (SubStr(w, 1, L) == trig)
                case "end":   ok := (SubStr(w, -L) == trig)
                default:      ok := (InStr(w, trig, true) > 0)
            }
            if ok
                out.Push(w)
        }
        return out
    }

    ; ---- Defunctionize ----
    static DefuncOpts(opts) => StrReplace(StrReplace(opts, "X", ""), "B0", "")

    static DefuncLine(line, opt) {
        if !RegExMatch(line, this.ReFunc, &m)
            return {kind: "raw"}
        repl := m.Repl
        flags := []
        if RegExMatch(m.Params, '^\h*,\h*[01]\h*,\h*1')
            flags.Push("f() paste option dropped")
        if RegExMatch(repl, '[{}^!+#]')
            flags.Push("contains {}^!+# -- a plain hotstring sends these as keys; add the T option?")
        repl := RegExReplace(repl, '(\h);', '$1``;')   ; a space then ; would start a comment
        keep := opt.keepComments || InStr(m.Comm, "misspells")
        text := m.Ind ":" this.DefuncOpts(m.Opts) ":" m.Trig "::" repl (keep ? m.Comm : "")
        return {kind: "hs", action: "defunc", text: text, flags: flags, misFlag: false}
    }

    ; block = header, ( line, content lines..., ) line.  Only f() blocks change.
    static DefuncBlock(block, opt) {
        if !RegExMatch(block[1], this.ReFuncOpener, &m)
            return {kind: "raw"}
        if !RegExMatch(block[2], this.ReContOpen)
            return {kind: "raw"}
        closer := block[block.Length]
        flags := []
        if RegExMatch(closer, '^\h*\)"\h*,\h*[01]\h*,\h*1')
            flags.Push("f() paste option dropped")
        keep := opt.keepComments || InStr(m.Comm, "misspells")
        outLines := [m.Ind ":" this.DefuncOpts(m.Opts) ":" m.Trig "::" (keep ? m.Comm : ""), block[2]]
        special := false
        Loop block.Length - 3 {
            l := block[A_Index + 2]
            outLines.Push(l)
            if RegExMatch(l, '[{}^!+#]')
                special := true
        }
        outLines.Push(RegExReplace(closer, '^(\h*)\).*$', '$1)'))
        if special
            flags.Push("contains {}^!+# -- a plain hotstring sends these as keys; add the T option?")
        return {kind: "hs", action: "defunc", text: this.Join(outLines, "`r`n"), flags: flags, misFlag: false}
    }

    static Assemble(item, commentPart) {
        return item.ind ":" item.opts ":" item.trig '::f("' item.repl '"' item.params ")" commentPart
    }

    ; Same radio logic HH uses: *? = middle, * = beginning, ? = ending, else whole word
    static ModeFor(opts) {
        star := InStr(opts, "*")
        q := InStr(opts, "?")
        return (star && q) ? "mid" : star ? "begin" : q ? "end" : "whole"
    }

    static Unescape(s) {
        s := StrReplace(s, "````", "``")
        return StrReplace(s, '``"', '"')
    }

    static Join(arr, sep, maxItems := 0) {
        out := ""
        for i, v in arr {
            if (maxItems && i > maxItems) {
                out .= sep "..."
                break
            }
            out .= (i > 1 ? sep : "") v
        }
        return out
    }
}

; =============== GUI ===============
class App {
    static G := ""
    static Ed := ""
    static RbFunc := ""
    static RbMetric := ""
    static RbDefunc := ""
    static CbGroup := ""
    static CbMis := ""
    static CbVar := ""
    static CbCase := ""
    static CbBig := ""
    static CbKeep := ""
    static PctEdit := ""
    static PctUpDown := ""
    static PctLabel := ""
    static HelpBtn := ""
    static Named := Map()     ; help-system name -> control
    static Status := ""
    static Btns := []
    static StopBtn := ""
    static StopRequested := false
    static LastInput := ""

    static Build() {
        c := BFConfig
        g := Gui("+Resize +MinSize900x440", "AC2 Bulk Functionizer")
        DpiKeepSize.Watch(g)   ; keep its size across monitors with different scales
        g.BackColor := c.FormColor
        g.SetFont("s10 " c.FontColor, "Segoe UI")

        ; Row 1: mode
        g.AddText("xm y14", "Mode:")
        this.RbFunc   := g.AddRadio("x+10 y12", "&Functionize")
        this.RbMetric := g.AddRadio("x+15", "&Rebuild metrics")
        this.RbDefunc := g.AddRadio("x+15", "&Defunctionize")
        this.CbGroup  := g.AddCheckbox("x+40", "Group flagged items at bottom")
        this.HelpBtn  := g.AddButton("x+20 y8 w28 h26", "?")     ; moved to top-right in OnSize
        this.HelpBtn.OnEvent("Click", (*) => BFHelp.Show(true))
        radios := [this.RbFunc, this.RbMetric, this.RbDefunc]
        radios[c.Mode].Value := 1
        this.CbGroup.Value := c.GroupFlagged

        ; Row 2: options for the current mode (the others are greyed out)
        this.CbMis  := g.AddCheckbox("xm y42", "Rebuild 'but misspells'")
        this.CbVar  := g.AddCheckbox("x+15", "Group word variations")
        this.CbCase := g.AddCheckbox("x+15", "Honor :C: option")
        this.CbBig  := g.AddCheckbox("x+15", "Flag Fixes changes >=")
        this.PctEdit   := g.AddEdit("x+4 yp-3 w48 Number Background" c.ListColor, c.BigChangePercent)
        this.PctUpDown := g.AddUpDown("Range1-1000", c.BigChangePercent)
        this.PctLabel  := g.AddText("x+3 yp+3", "%")
        this.CbKeep := g.AddCheckbox("x+25 y42", "Keep comments")
        this.CbMis.Value  := c.RebuildMisspells
        this.CbVar.Value  := c.GroupVariations
        this.CbCase.Value := c.HonorCaseOption
        this.CbBig.Value  := c.FlagBigChanges
        this.CbKeep.Value := c.KeepComments
        for ctl in [this.RbFunc, this.RbMetric, this.RbDefunc, this.CbMis, this.CbBig]
            ctl.OnEvent("Click", (*) => App.UpdateStates())

        g.SetFont("s10 " c.FontColor, "Consolas")
        this.Ed := g.AddEdit("xm y70 w880 h480 Multi WantTab HScroll -Wrap Background" c.ListColor)
        ; EM_LIMITTEXT 0 = maximum, so pasting a whole library isn't cut off
        DllCall("user32\SendMessageW", "Ptr", this.Ed.Hwnd, "UInt", 0xC5, "Ptr", 0, "Ptr", 0)

        g.SetFont("s10 " c.FontColor, "Segoe UI")
        defs := [["&Process", (*) => App.OnProcess()]
               , ["Paste &In", (*) => App.OnPasteIn()]
               , ["&Copy All", (*) => App.OnCopy()]
               , ["&Undo", (*) => App.OnUndo()]
               , ["C&lear", (*) => App.OnClear()]]
        for d in defs {
            b := g.AddButton((A_Index = 1 ? "xm" : "x+8") " w110 h30", d[1])
            b.OnEvent("Click", d[2])
            this.Btns.Push(b)
        }
        this.StopBtn := g.AddButton("x+24 w110 h30 Disabled", "&Stop")
        this.StopBtn.OnEvent("Click", (*) => App.StopRequested := true)
        this.Status := g.AddText("xm w880 h22", "Paste hotstrings above, choose a mode, then click Process.  F1 = help.")

        ; Names the help system uses for each control (F1 shows the focused one's help)
        for name, ctl in Map("ModeFunc", this.RbFunc, "ModeRebuild", this.RbMetric
                , "ModeDefunc", this.RbDefunc, "GroupFlagged", this.CbGroup
                , "RebuildMisspells", this.CbMis, "GroupVariations", this.CbVar
                , "HonorCase", this.CbCase, "FlagBig", this.CbBig, "BigPercent", this.PctEdit
                , "KeepComments", this.CbKeep, "EditBox", this.Ed, "HelpBtn", this.HelpBtn
                , "Process", this.Btns[1], "PasteIn", this.Btns[2], "CopyAll", this.Btns[3]
                , "Undo", this.Btns[4], "Clear", this.Btns[5], "Stop", this.StopBtn)
            this.Named[name] := ctl

        this.UpdateStates()
        g.OnEvent("Size", (gObj, mm, w, h) => App.OnSize(mm, w, h))
        g.OnEvent("Close", (*) => ExitApp())
        this.G := g
        g.Show("w960 h660")
    }

    ; Grey out the options that don't apply to the selected mode.
    static UpdateStates() {
        rebuild := this.RbMetric.Value = 1
        this.CbMis.Enabled  := rebuild
        this.CbVar.Enabled  := rebuild && this.CbMis.Value
        this.CbCase.Enabled := rebuild && this.CbMis.Value
        this.CbBig.Enabled  := rebuild
        pct := rebuild && this.CbBig.Value
        this.PctEdit.Enabled   := pct
        this.PctUpDown.Enabled := pct
        this.PctLabel.Enabled  := pct
        this.CbKeep.Enabled := this.RbDefunc.Value = 1
    }

    ; Layout pass is bracketed with WM_SETREDRAW and finished with one clean
    ; repaint; otherwise the first Size event (inside Show) leaves "ghost"
    ; buttons painted at their creation position.
    static OnSize(minMax, w, h) {
        if (minMax = -1)
            return
        static WM_SETREDRAW := 0x000B
        static RDW_FLAGS := 0x0001 | 0x0004 | 0x0080   ; INVALIDATE | ERASE | ALLCHILDREN
        hwnd := this.G ? this.G.Hwnd : this.Ed.Gui.Hwnd
        DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)

        this.Ed.Move(10, 70, w - 20, h - 150)
        x := 10
        for b in this.Btns {
            b.Move(x, h - 72)
            x += 118
        }
        this.StopBtn.Move(x + 16, h - 72)
        this.HelpBtn.Move(w - 38, 8)
        this.Status.Move(10, h - 32, w - 20)

        DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
        DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
    }

    ; Read the UI into an options object and remember it in the ini.
    static GetOptions() {
        c := BFConfig
        c.Mode := this.RbMetric.Value ? 2 : this.RbDefunc.Value ? 3 : 1
        c.GroupFlagged     := this.CbGroup.Value
        c.RebuildMisspells := this.CbMis.Value
        c.GroupVariations  := this.CbVar.Value
        c.HonorCaseOption  := this.CbCase.Value
        c.FlagBigChanges   := this.CbBig.Value
        v := this.PctEdit.Value
        c.BigChangePercent := (IsNumber(v) && v > 0) ? Number(v) : 20
        c.KeepComments     := this.CbKeep.Value
        c.Save()
        return {mode: (["func", "rebuild", "defunc"])[c.Mode]
            , group: c.GroupFlagged = 1
            , misspells: c.RebuildMisspells = 1
            , variations: c.GroupVariations = 1
            , honorCase: c.HonorCaseOption = 1
            , flagBig: c.FlagBigChanges = 1
            , keepComments: c.KeepComments = 1}
    }

    static OnProcess() {
        txt := this.Ed.Value
        if (Trim(txt, " `t`r`n") = "") {
            MsgBox("Paste some hotstrings into the box first.", "Bulk Functionizer", 48)
            return
        }
        opt := this.GetOptions()
        this.SetBusy(true)
        try {
            if (opt.mode = "rebuild" && !WordData.Loaded) {
                this.Status.Text := "Loading and indexing word list and frequency data..."
                Sleep(-1)
                t := A_TickCount
                if !WordData.Load() {
                    this.Status.Text := "Couldn't load the word list."
                    return
                }
                this.Status.Text := "Word data loaded in " Format("{:.1f}", (A_TickCount - t) / 1000) " s."
                Sleep(-1)
            }
            this.StopRequested := false
            res := Processor.Run(txt, opt, ObjBindMethod(this, "Progress"))
            if res.canceled {
                this.Status.Text := "Stopped -- input left unchanged."
                return
            }
            this.LastInput := txt
            this.Ed.Value := res.text
            this.Status.Text := res.summary
        }
        catch as err {
            MsgBox("Processing failed:`n" err.Message "`n(line " err.Line ")", "Bulk Functionizer", 16)
            this.Status.Text := "Error -- input left unchanged."
        }
        finally {
            this.SetBusy(false)
        }
    }

    ; Returns true when the user has clicked Stop.
    static Progress(i, n, elapsedMs) {
        eta := (i > 1) ? Round(elapsedMs / (i - 1) * (n - i + 1) / 1000) : 0
        this.Status.Text := "Processing line " i " of " n "...   "
            . Round(elapsedMs / 1000) " s elapsed, about " eta " s left"
        Sleep(-1)   ; pump messages so the status repaints and Stop can be clicked
        return this.StopRequested
    }

    static SetBusy(busy) {
        for b in this.Btns
            b.Enabled := !busy
        this.Ed.Enabled := !busy
        this.StopBtn.Enabled := busy
    }

    static OnPasteIn() {
        this.Ed.Value := A_Clipboard
        this.Status.Text := "Pasted from clipboard."
    }

    static OnCopy() {
        A_Clipboard := this.Ed.Value
        this.Status.Text := "Copied to clipboard."
    }

    static OnUndo() {
        if (this.LastInput = "") {
            this.Status.Text := "Nothing to undo."
            return
        }
        this.Ed.Value := this.LastInput
        this.Status.Text := "Restored the last input."
    }

    static OnClear() {
        this.Ed.Value := ""
        this.Status.Text := "Cleared."
    }
}

; =============== HELP ===============
; Modeled on HotstringHelper's HelpSystem.  [?] shows the general help; F1 shows
; the help for the focused control.  The help window stays open and follows
; keyboard focus: Tab (or click) to another control and its help replaces the text.
class BFHelp {
    static Texts := Map()
    static HelpGui := 0
    static HelpEdit := 0
    static pollFn := ""
    static lastPolled := ""

    static Init() {
        if this.Texts.Count
            return
        t := this.Texts
        t["ModeFunc"] := "Functionize mode.`n`nWraps bare hotstrings in the f() function:`n`n"
            . "    ::Bjorn::Bjørn`n    becomes`n    :B0X:Bjorn::f(`"Bjørn`")`n`n"
            . "B0 and X are added to the options, double quotes in the replacement are escaped, and comments are kept as they are.`n`n"
            . "Lines already wrapped in f() are left alone.  Hotstrings whose replacement contains {} send syntax are not wrapped (they're flagged instead), and items with 3+ words are wrapped but flagged, since HotstringHelper would make them f(`"...`", 0) boilerplate items."
        t["ModeRebuild"] := "Rebuild metrics mode.`n`nDoes everything Functionize does, then recalculates the auto-comment of every AutoCorrect f() item from the CURRENT word list and frequency CSV, exactly the way HotstringHelper calculates them:`n`n"
            . "    Web Freq 157.47 | Fixes 169 words, but misspells ...`n`n"
            . "Boilerplate items (f(..., 0), multi-line, or 3+ words) get no metrics, same as in HotstringHelper.`n`n"
            . "The checkboxes on the second row control how much of the comment is rebuilt and what gets flagged for review.`n`n"
            . "The word list is loaded and indexed the first time you run this mode (a few seconds); after that it stays in memory."
        t["ModeDefunc"] := "Defunctionize mode.`n`nThe reverse of Functionize: removes the f() wrapper (and the B0 and X options) for people who don't use f()'s logging and InputBuffer features:`n`n"
            . "    :B0X*?:useing::f(`"using`") `; Web Freq ...`n    becomes`n    :*?:useing::using`n`n"
            . "Multi-line continuation-section f() items are converted too.  This replaces the old Defunctionizer.ahk tool.`n`n"
            . "Flagged for review:`n- replacements containing {}^!+#, because a plain hotstring sends those as keys (add the T option if they should be typed literally)`n- items whose f() paste option was turned on, since a plain hotstring can't paste"
        t["GroupFlagged"] := "Group flagged items at bottom.`n`nItems that need your attention get a `"`; [REVIEW] ...`" comment line above them saying why.`n`n"
            . "Checked: flagged items are moved out of their place and collected in two sections at the end of the output -- misspell problems first, then other changes -- so you can work through them in one spot.`n`n"
            . "Unchecked: flagged items stay where they were, with their [REVIEW] line above them."
        t["RebuildMisspells"] := "Rebuild 'but misspells'  (Rebuild metrics mode).`n`n"
            . "Checked: the whole auto-comment is rebuilt.  The trigger is checked against the word list, newly misspelled words are added as `"word ()`" for you to define, and words that are no longer misspelled are flagged.  Definitions you already wrote are always kept, and so is the rest of your comment text.`n`n"
            . "Unchecked: ONLY the `"Web Freq n | Fixes n words`" part is replaced.  Every other character of the comment is left exactly as it was, and no misspell flags are raised."
        t["GroupVariations"] := "Group word variations  (Rebuild metrics mode, with 'but misspells' on).`n`n"
            . "Many misspelled words are just forms of one word.  For example, a hotstring that misspells benga also misspells bengaline and bengalines.  With this checked, only the root word (benga) is listed and flagged, and the flag notes how many variations it covers.`n`n"
            . "A variation is a longer misspelled word that starts with a shorter misspelled word (or, for word-ending ? items, ends with it).  A variation that already has a definition is always kept.`n`n"
            . "Note: 'starts with' can group unrelated words too, so give the list a glance.  Lists over 300 words aren't grouped."
        t["HonorCase"] := "Honor :C: option  (Rebuild metrics mode, with 'but misspells' on).`n`n"
            . "A hotstring with the C option is case-sensitive: it only fires when the trigger is typed in exactly that case.  So :B0X*?C:beng:: can never change Bengal, Bengali or Benghazi.`n`n"
            . "Checked: for C items, a word only counts as misspelled if the trigger matches it in its exact case.`n`n"
            . "Unchecked: words are matched case-insensitively, the same way HotstringHelper's Exam pane does it.`n`n"
            . "C0 (off) and C1 (don't conform case) are not treated as case-sensitive."
        t["FlagBig"] := "Flag Fixes changes >= n%  (Rebuild metrics mode).`n`n"
            . "Checked: an item gets flagged when its new Fixes count differs from the old one in its comment by at least this percentage (and when it goes up from 0).  Useful after a big change to the word list.`n`n"
            . "Unchecked: Fixes changes are applied quietly.`n`n"
            . "The percentage is saved as BigChangePercent in acSettings.ini."
        t["BigPercent"] := "The percentage for 'Flag Fixes changes'.`n`nAn item is flagged when its Fixes count changes by at least this much.  For example, with 20, an item going from 100 to 79 or to 121 fixes is flagged, but 100 to 85 is not.`n`n"
            . "Saved as BigChangePercent in acSettings.ini."
        t["KeepComments"] := "Keep comments  (Defunctionize mode).`n`n"
            . "Checked: each hotstring keeps its inline comment.`n`n"
            . "Unchecked: comments are dropped -- except comments containing 'but misspells', which are always kept so the warning isn't lost.`n`n"
            . "Note: without the Web Freq / Fixes comments, AutoCorrect2's 'Potential Fixes Report' can't count your fixes.`n`n"
            . "Saved as DefuncKeepComments in the [BulkFunctionizer] section of acSettings.ini."
        t["EditBox"] := "The hotstring box.`n`nPaste the hotstrings to process here -- a few lines, or your whole library.  Click Process and the result replaces the box contents, ready to copy out.`n`n"
            . "Anything the tool doesn't recognize (blank lines, comments, code, section headers) passes through unchanged, so a whole library can go through in one pass."
        t["Process"] := "Process.`n`nRuns the selected mode on everything in the box and replaces the box contents with the result.  The status bar then shows a summary: how many items were wrapped, changed, skipped and flagged.`n`n"
            . "Click Undo to get your input back."
        t["PasteIn"] := "Paste In.`n`nReplaces the box contents with whatever is on the clipboard."
        t["CopyAll"] := "Copy All.`n`nCopies the whole box to the clipboard, so you can paste the result into your library."
        t["Undo"] := "Undo.`n`nPuts back the text that was in the box before the last Process."
        t["Clear"] := "Clear.`n`nEmpties the box."
        t["Stop"] := "Stop.`n`nAvailable while a run is in progress.  Cancels it and leaves the box exactly as it was."
        t["HelpBtn"] := "Help.`n`nClick [?] for general help.  Press F1 on any control for help with that control.  The help window follows keyboard focus while it's open, so you can Tab through the controls to read about each one."
    }

    static GeneralText() {
        return "AC2 Bulk Functionizer`n`n"
            . "Processes many hotstrings at once.  Paste them into the box, choose a mode, and click Process.  The result replaces the box contents, ready to copy back into your library (Undo restores the input).`n`n"
            . "Modes:`n- Functionize: wraps bare hotstrings in f().`n- Rebuild metrics: also recalculates Web Freq, Fixes and 'but misspells' from the current word list and frequency CSV.`n- Defunctionize: removes f() wrappers.`n`n"
            . "Items that need a look get a `"`; [REVIEW] ...`" line above them explaining why.`n`n"
            . "Press F1 on any control for help with it.  Press Tab to move between controls -- this window follows along.`n`n"
            . "Settings are remembered in Data\acSettings.ini, in the [BulkFunctionizer] section."
    }

    static Show(general := false) {
        this.Init()
        focused := this.Focused()
        if !IsObject(this.HelpGui)
            this.Build()
        this.SetContent(general ? "" : focused)
        this.HelpGui.Show("NoActivate")   ; keep focus on the main window, so Tab still works
        ; Remember where focus is, so the poll doesn't immediately swap the general
        ; text for the [?] button's own help.
        this.lastPolled := focused
        if (this.pollFn = "")
            this.pollFn := ObjBindMethod(this, "Poll")
        SetTimer(this.pollFn, 150)
    }

    static Poll() {
        if !IsObject(this.HelpGui) {
            SetTimer(this.pollFn, 0)
            return
        }
        ; "" while focus is in the help window itself, so the text stays put
        ; while the user reads or scrolls it.
        name := this.Focused()
        if (name = "" || name = this.lastPolled)
            return
        this.lastPolled := name
        this.SetContent(name)
    }

    static Close() {
        if IsObject(this.HelpGui) {
            this.HelpGui.Destroy()
            this.HelpGui := 0
        }
        if (this.pollFn != "")
            SetTimer(this.pollFn, 0)
    }

    static Build() {
        c := BFConfig
        h := Gui("+AlwaysOnTop +Owner" App.G.Hwnd, "Bulk Functionizer Help")
        h.BackColor := c.FormColor
        h.SetFont("s10 " c.FontColor, "Segoe UI")
        this.HelpEdit := h.AddEdit("w520 r18 +VScroll ReadOnly -E0x200 -WantReturn -TabStop Background" c.FormColor)
        closeBtn := h.AddButton("Default w80", "Close")
        closeBtn.OnEvent("Click", (*) => BFHelp.Close())
        h.OnEvent("Escape", (*) => BFHelp.Close())
        h.OnEvent("Close", (*) => BFHelp.Close())
        this.HelpGui := h

        ; First position: just right of the main window, so neither covers the other.
        h.Show("Hide")
        h.GetPos(, , &hw, &hh)
        WinGetPos(&mx, &my, &mw, &mh, App.G.Hwnd)
        hx := mx + mw + 8
        if (hx + hw > A_ScreenWidth)      ; no room on the right: try the left
            hx := mx - hw - 8
        if (hx < 0)                       ; no room anywhere: overlap a little
            hx := mx + 40
        h.Move(hx, my)
    }

    static SetContent(name) {
        if (name != "" && this.Texts.Has(name)) {
            text := this.Texts[name]
            this.HelpGui.Title := "Help: " SubStr(text, 1, InStr(text, "`n") - 1)
        } else {
            text := this.GeneralText()
            this.HelpGui.Title := "Bulk Functionizer Help"
        }
        this.HelpEdit.Value := text
    }

    ; Help-system name of the focused control in the main window ("" if none).
    static Focused() {
        for name, ctl in App.Named {
            try {
                if ctl.Focused
                    return name
            }
        }
        return ""
    }
}

#HotIf App.G && WinActive("ahk_id " App.G.Hwnd)
F1::BFHelp.Show()   ; help for the focused control
#HotIf
