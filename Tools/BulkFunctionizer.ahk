#SingleInstance Force
#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)

; ========================================
; BulkFunctionizer -- part of the AutoCorrect2 suite (lives in Tools\)
; Version: 11-14-2026
; Author: kunkel321
; AI Used: Claude
;
; Paste hotstrings into the big box, pick a mode, click Process.  The result
; replaces the box contents, ready to copy out.  Click Undo to get the input back.
;
; Modes
;   Functionize only
;       ::Bjorn::Bjørn ; comment     ->   :B0X:Bjorn::f("Bjørn") ; comment
;       Lines already wrapped in f() are left as they are.
;   Functionize + rebuild metrics
;       Same wrapping, plus every AutoCorrect f() item gets fresh
;       "Web Freq n | Fixes n words" text, computed exactly the way
;       HotstringHelper does it, from the CURRENT word list and frequency CSV.
;       Existing "but misspells word (definition)" text and any other manual
;       comment text are kept.  Boilerplate items (f(..., 0) or 3+ words) get
;       no metrics, same as in HH.
;
; Anything the tool doesn't recognize (blank lines, comments, code,
; continuation sections, X-option hotstrings) passes through untouched.
;
; Items that need a human look get a "; [REVIEW] ..." comment line above them.
; With "Group flagged items at bottom" checked, they are moved to two sections
; at the end: misspell problems first, then other changes.
;
; Settings read from ..\Data\acSettings.ini
;   [Files]            WordListFile, FrequencyListFile   (same keys as AC2)
;   [BulkFunctionizer] BigChangePercent=20   ; flag when "Fixes" changes by >= this %
;
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

    static Load() {
        if FileExist(this.SettingsFile) {
            this.WordListFile      := "..\Data\" IniRead(this.SettingsFile, "Files", "WordListFile", "ExamPaneWordList253k.txt")
            this.FrequencyListFile := "..\Data\" IniRead(this.SettingsFile, "Files", "FrequencyListFile", "unigram_freq_list_filtered_102k.csv")
            v := IniRead(this.SettingsFile, "BulkFunctionizer", "BigChangePercent", "20")
            this.BigChangePercent := IsNumber(v) ? Number(v) : 20
        }
        if FileExist(this.ThemeFile) {
            try this.FontColor := "c" IniRead(this.ThemeFile, "ColorSettings", "fontColor")
            try this.ListColor := IniRead(this.ThemeFile, "ColorSettings", "listColor")
            try this.FormColor := IniRead(this.ThemeFile, "ColorSettings", "formColor")
        }
    }
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
; Repeated "but misspells" clauses (left behind when HH re-saves an item that
; already had one) are merged; a filled-in definition wins over an empty "()".
class CommentParser {
    static Parse(body) {
        r := {oldFixes: "", defs: Map(), order: [], rawClause: "", manual: ""}
        pat := 'i)^\h*(?<F>Web\h+Freq\h+[\d.]+)?[\h,|]*(?:Fixes\h*(?<N>\d+)\h*words?\b(?:\h*!!!\h*CHECK REPLACEMENT[^,.;]*)?)?[\h,|]*'
        RegExMatch(body, pat, &m)
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
        if ok
            suffix := RTrim(LTrim(SubStr(rest, pos), " `t,.;"), " `t")
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
}

; =============== PROCESSOR ===============
class Processor {
    ; :opts:trig::f("repl", 0, 1) ; comment
    static ReFunc := '^(?<Ind>\h*):(?<Opts>[^:]*):(?<Trig>[^:]+)::f\("(?<Repl>(?:[^"``]|``.)*)"(?<Params>(?:\h*,\h*[01]){0,2})\h*\)(?<Comm>\h+;.*)?$'
    ; :opts:trig::repl ; comment      (first whitespace+; starts the comment, as in AHK)
    static RePlain := '^(?<Ind>\h*):(?<Opts>[^:]*):(?<Trig>[^:]+)::(?<Repl>.*?\S)(?<Comm>\h+;.*)?$'
    ; first line of a continuation section:  :opts:trig::  or  :opts:trig::f("
    static ReOpener := '^\h*:[^:]*:[^:]+::(?:f\(")?(?:\h+;.*)?$'

    static Run(txt, metrics, group, progress) {
        t0 := A_TickCount
        txt := StrReplace(StrReplace(txt, "`r`n", "`n"), "`r", "`n")
        lines := StrSplit(txt, "`n")
        st := {hs: 0, wrapped: 0, rebuilt: 0, same: 0, skipped: 0, misFlag: 0, otherFlag: 0}
        main := [], misGrp := [], othGrp := []
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

            ; Continuation section -> copy verbatim through the closing ) line
            if (i < n && RegExMatch(line, this.ReOpener) && RegExMatch(lines[i + 1], '^\h*\(')) {
                main.Push(line)
                while (i < n) {
                    i++
                    main.Push(lines[i])
                    if RegExMatch(lines[i], '^\h*\)')
                        break
                }
                continue
            }

            res := this.ProcessLine(line, metrics)
            if (res.kind = "raw") {
                main.Push(line)
                continue
            }
            st.hs++
            st.%res.action%++
            if res.flags.Length {
                target := !group ? main : (res.misFlag ? misGrp : othGrp)
                target.Push("; [REVIEW] " this.Join(res.flags, " | "))
                target.Push(res.text)
                if res.misFlag
                    st.misFlag++
                else
                    st.otherFlag++
            }
            else
                main.Push(res.text)
        }

        if group {
            if misGrp.Length {
                main.Push("")
                main.Push("; ===== FLAGGED: MISSPELLS / NEEDS DEFINITION (" st.misFlag ") =====")
                for l in misGrp
                    main.Push(l)
            }
            if othGrp.Length {
                main.Push("")
                main.Push("; ===== FLAGGED: OTHER CHANGES (" st.otherFlag ") =====")
                for l in othGrp
                    main.Push(l)
            }
        }

        secs := Format("{:.1f}", (A_TickCount - t0) / 1000)
        summary := "Done in " secs " s.  " st.hs " hotstrings: " st.wrapped " wrapped, "
            . (metrics ? st.rebuilt " metrics changed, " : "")
            . st.same " unchanged, " st.skipped " skipped.  Flagged: "
            . st.misFlag " misspell, " st.otherFlag " other."
        return {canceled: false, text: this.Join(main, "`r`n"), summary: summary}
    }

    static ProcessLine(line, metrics) {
        if RegExMatch(line, this.ReFunc, &m) {
            item := {ind: m.Ind, opts: m.Opts, trig: m.Trig, repl: m.Repl, params: m.Params, comm: m.Comm}
            if !metrics
                return {kind: "hs", action: "same", text: line, flags: [], misFlag: false}
            return this.Rebuild(item, line, false)
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
            if (metrics && !flags.Length)
                return this.Rebuild(item, line, true)
            return {kind: "hs", action: "wrapped", text: this.Assemble(item, item.comm), flags: flags, misFlag: false}
        }
        return {kind: "raw"}
    }

    ; Recalculate metrics for one f() item.  wasWrapped = it started as a bare hotstring.
    static Rebuild(item, origLine, wasWrapped) {
        replM := Trim(this.Unescape(item.repl))
        trigM := Trim(item.trig)

        ; Boilerplate gets no metrics -- same rule as HH (log=0 param, newline, or 3+ words)
        if (RegExMatch(item.params, '^\h*,\h*0') || InStr(replM, "`n")
            || StrLen(replM) - StrLen(StrReplace(replM, " ")) > 2)
            return {kind: "hs", action: wasWrapped ? "wrapped" : "skipped"
                , text: wasWrapped ? this.Assemble(item, item.comm) : origLine, flags: [], misFlag: false}

        mode := this.ModeFor(item.opts)
        fixes := WordData.Matches(replM, mode)
        mis := WordData.Matches(trigM, mode)

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

        if (c.oldFixes != "" && c.oldFixes != shownN) {
            if (c.oldFixes = 0)
                flags.Push("Fixes 0 -> " shownN)
            else {
                pct := (shownN - c.oldFixes) / c.oldFixes * 100
                if (Abs(pct) >= BFConfig.BigChangePercent)
                    flags.Push("Fixes " c.oldFixes " -> " shownN " (" (pct > 0 ? "+" : "") Round(pct) "%)")
            }
        }

        ; ---- "but misspells" ----
        misKeys := Map()
        for w in mis
            misKeys[StrLower(w)] := w
        stale := []
        for key in c.order
            if !misKeys.Has(key)
                stale.Push(c.defs[key])

        misTxt := ""
        if (c.rawClause != "") {
            misTxt := ", " c.rawClause
            flags.Push("couldn't parse the existing 'but misspells' text -- check by hand")
            misFlag := true
        }
        else if (mis.Length > 3 && c.defs.Count = 0) {
            misTxt := ", but misspells " mis.Length " words !!!"
            flags.Push("misspells " mis.Length " words: " this.Join(mis, ", ", 15))
            misFlag := true
        }
        else if (mis.Length || stale.Length) {
            parts := [], needDef := [], staleW := []
            for w in mis {
                key := StrLower(w)
                has := c.defs.Has(key)
                def := has ? c.defs[key].d : ""
                parts.Push((has ? c.defs[key].w : w) " (" def ")")
                if (def = "")
                    needDef.Push(w)
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
                flags.Push("no longer in word list (remove?): " this.Join(staleW, ", "))
                misFlag := true
            }
        }

        full := auto misTxt
        if (c.manual != "")
            full .= ((misTxt = "" || SubStr(misTxt, -3) = "!!!") ? " " : ". ") c.manual

        newLine := this.Assemble(item, " `; " full)
        action := wasWrapped ? "wrapped" : (RTrim(newLine) == RTrim(origLine) ? "same" : "rebuilt")
        return {kind: "hs", action: action, text: newLine, flags: flags, misFlag: misFlag}
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
    static RbMetric := ""
    static CbGroup := ""
    static Status := ""
    static Btns := []
    static StopBtn := ""
    static StopRequested := false
    static LastInput := ""

    static Build() {
        c := BFConfig
        g := Gui("+Resize +MinSize700x420", "AC2 Bulk Functionizer")
        g.BackColor := c.FormColor
        g.SetFont("s10 " c.FontColor, "Segoe UI")

        g.AddRadio("xm y12 Checked", "Functionize only")
        this.RbMetric := g.AddRadio("x+15", "Functionize + rebuild metrics")
        this.CbGroup := g.AddCheckbox("x+30 Checked", "Group flagged items at bottom")

        g.SetFont("s10 " c.FontColor, "Consolas")
        this.Ed := g.AddEdit("xm y42 w880 h500 Multi WantTab HScroll -Wrap Background" c.ListColor)
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
        this.Status := g.AddText("xm w880 h22", "Paste hotstrings above, choose a mode, then click Process.")

        g.OnEvent("Size", (gObj, mm, w, h) => App.OnSize(mm, w, h))
        g.OnEvent("Close", (*) => ExitApp())
        this.G := g
        g.Show("w900 h640")
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

        this.Ed.Move(10, 42, w - 20, h - 122)
        x := 10
        for b in this.Btns {
            b.Move(x, h - 72)
            x += 118
        }
        this.StopBtn.Move(x + 16, h - 72)
        this.Status.Move(10, h - 32, w - 20)

        DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
        DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
    }

    static OnProcess() {
        txt := this.Ed.Value
        if (Trim(txt, " `t`r`n") = "") {
            MsgBox("Paste some hotstrings into the box first.", "Bulk Functionizer", 48)
            return
        }
        metrics := (this.RbMetric.Value = 1)
        this.SetBusy(true)
        try {
            if (metrics && !WordData.Loaded) {
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
            res := Processor.Run(txt, metrics, this.CbGroup.Value = 1, ObjBindMethod(this, "Progress"))
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
