/*
================================================================
Non-Word List Module to be #Include'd in AutoCorrect2.ahk
            github.com/kunkel321/autocorrect2
================================================================

For cleaning the Exam Pane word list (Config.WordListFile, normally
Data\ExamPaneWordList253k.txt) of entries that are not real words, e.g.
"afficionado", which is a misspelling of "aficionado".

Words are FLAGGED first and REMOVED later, in one batch:
  1. Flag   -- they go into Debug\NonWords.txt (the word list is untouched).
  2. Review -- the Non-Word List window (Control Panel button) shows them;
               double-click one to look it up, or remove it from the list.
  3. Apply  -- the "Apply to Word List" button takes them all out of the word
               list (a dated backup goes to Debug\ first), reloads the Exam
               Pane's copy in memory, and moves the entries to
               Debug\NonWords_Applied.txt as a record.

Three ways to flag:
  * Hotkey: NonWordFlagHk in [Hotkeys] of acSettings.ini (e.g. !+n for Alt+Shift+N).
    Blank or missing = no hotkey, since most users never need this tool.
    Select text and press it.  Understands the bulk tool's lines:
        ; [REVIEW] needs definition: afficionado, afficionados
        :B0X*:afficionad::f("aficionad") ; ... but misspells afficionado (), afficionados ()
    In VS Code, Ctrl+C with nothing selected copies the whole line, so just put
    the cursor on either line and press the hotkey.  Only words that are actually
    in the word list get flagged; anything else is reported and skipped.
  * [Non-word] button in the Look/Definition window (next to Try ChatGPT).  If
    ChatGPT said "MISSPELLING: x -> y", the note records "misspelling of y".
    When the list also has forms like word+s, a small checklist lets you pick.
  * Typing into Debug\NonWords.txt by hand (one word per line).

Optional second hotkey to open the review window: NonWordManagerHk in [Hotkeys] (blank = none).

            By: Kunkel321
            Date: 11-15-2026
            Tool Used: Claude
*/

NonWords.Register()

class NonWords {
    ; Paths are relative to Core\ (AC2 does SetWorkingDir(A_ScriptDir)).
    static File        := "..\Debug\NonWords.txt"
    static AppliedFile := "..\Debug\NonWords_Applied.txt"
    static BackupDir   := "..\Debug"

    ; Safety net for the hotkey: ask before flagging a word this common on the web
    ; (raw count from the frequency CSV; 2,000,000 shows as "Web Freq 2.00").
    static HighFreqWarn := 2000000
    ; ...and before flagging more than this many words at once.
    static ConfirmOver := 6

    static Header := "
    (
; Words flagged as NON-WORDS, waiting to be removed from the Exam Pane word list.
; Format: word<Tab>note<Tab>date flagged.  Only the word is required.
; Lines starting with a semicolon are ignored.  Edit freely.
; Removal happens only when you click 'Apply to Word List' in the Non-Word List window.

    )"

    static Mgr := 0, MgrLV := 0, MgrStatus := 0

    ; Runs at #Include time -- BEFORE Config.Init() and UI.Init().  Config.ReadIni()
    ; reads the ini directly, so it already works here.
    static Register() {
        Dictionary._PostShowCallbacks.Push(ObjBindMethod(this, "AddDictButton"))

        UI.ExtraControlButtons.Push({
            name: "NonWords",
            text: " Non-Word List (flagged for removal)",
            action: (*) => NonWords.ShowManager(),
            icon: A_ScriptDir "\..\Resources\Icons\missing-Blue.ico",
            help: "Opens the Non-Word List: words flagged for removal from the Exam Pane word list (Data\ExamPaneWordList253k.txt by default).`n`n"
                . "Flag words by selecting them and pressing the Non-Word hotkey (NonWordFlagHk in acSettings.ini; there is none until you set one), or with the [Non-word] button in the Look window.  "
                . "The hotkey understands the bulk tool's '[REVIEW] needs definition:' lines and the 'but misspells x (), y ()' hotstring comments, so in VS Code you can just put the cursor on such a line and press it.`n`n"
                . "Nothing is removed until you click 'Apply to Word List'.  A dated backup of the word list goes to the Debug folder first, and applied entries are logged in Debug\NonWords_Applied.txt.`n`n"
                . "Double-click a word in the list to look it up."
        })

        hk := Config.ReadIni("Hotkeys", "NonWordFlagHk", "")       ; blank or missing = no hotkey
        if (hk != "") {
            try Hotkey(hk, (*) => NonWords.FlagSelection())
            catch as err
                LogError("NonWords: could not register hotkey '" hk "': " err.Message)
        }
        hk := Config.ReadIni("Hotkeys", "NonWordManagerHk", "")
        if (hk != "") {
            try Hotkey(hk, (*) => NonWords.ShowManager())
            catch as err
                LogError("NonWords: could not register hotkey '" hk "': " err.Message)
        }
    }

    ; ============================================================
    ; ===== Pending list file =====
    ; ============================================================

    ; [{word, note, date}] in file order.
    static ReadPending() {
        out := []
        if !FileExist(this.File)
            return out
        try txt := FileRead(this.File, "UTF-8")
        catch
            return out
        Loop Parse, txt, "`n", "`r" {
            line := Trim(A_LoopField, " `t")
            if (line = "" || SubStr(line, 1, 1) = ";")
                continue
            parts := StrSplit(line, "`t")
            w := Trim(parts[1])
            if (w = "")
                continue
            out.Push({word: w
                , note: parts.Length >= 2 ? Trim(parts[2]) : ""
                , date: parts.Length >= 3 ? Trim(parts[3]) : ""})
        }
        return out
    }

    static WritePending(entries) {
        this._EnsureDir()
        txt := this.Header
        for e in entries
            txt .= e.word "`t" e.note "`t" e.date "`n"
        f := FileOpen(this.File, "w", "UTF-8")
        f.Write(txt)
        f.Close()
    }

    ; Adds words not already pending.  Returns {added: [], dupes: []}.
    static Add(words, note := "") {
        res := {added: [], dupes: []}
        have := Map()
        for e in this.ReadPending()
            have[e.word] := 1
        note := Trim(RegExReplace(note, "[`t`r`n]+", " "))
        today := FormatTime(, "yyyy-MM-dd")
        lines := ""
        for w in words {
            if have.Has(w) {
                res.dupes.Push(w)
                continue
            }
            have[w] := 1
            res.added.Push(w)
            lines .= w "`t" note "`t" today "`n"
        }
        if (lines != "") {
            try {
                this._EnsureDir()
                if !FileExist(this.File)
                    FileAppend(this.Header, this.File, "UTF-8")
                FileAppend(lines, this.File, "UTF-8")
            } catch as err {
                acMsgBox.Show("Could not write " this.File "`n`n" err.Message, "Non-Word List", "icon!")
                res.added := []
            }
        }
        if IsObject(this.Mgr)
            this._MgrRefresh()
        return res
    }

    static _EnsureDir() {
        if !DirExist(this.BackupDir)
            DirCreate(this.BackupDir)
    }

    ; ============================================================
    ; ===== Word list lookups (the Exam Pane's in-memory copy) =====
    ; ============================================================

    ; The word as spelled in the list ("" if absent).  An exact-case match wins;
    ; otherwise the first case-insensitive one.
    static FindInList(w) {
        global HH_WordsLower, HH_WordsOrig
        if (w = "" || !WordList.Load())
            return ""
        if InStr(HH_WordsOrig, "`n" w "`n", true)
            return w
        p := InStr(HH_WordsLower, "`n" StrLower(w) "`n", true)
        return p ? SubStr(HH_WordsOrig, p + 1, StrLen(w)) : ""
    }

    ; For the Look window: the word itself plus list words that start with it and
    ; are at most 4 letters longer.  Only the word and its s / es / 's forms start
    ; checked -- "teh" would otherwise drag in "tehran".
    static Candidates(word) {
        out := [], seen := Map()
        stem := this.FindInList(word)
        if (stem != "") {
            out.Push({word: stem, checked: true})
            seen[stem] := 1
        }
        n := 0
        for w in StrSplit(Trim(WordList.Filter(word, "begin", &n), "`n"), "`n") {
            if (w = "" || seen.Has(w) || StrLen(w) > StrLen(word) + 4)
                continue
            seen[w] := 1
            rest := SubStr(w, StrLen(word) + 1)
            out.Push({word: w, checked: (stem != "" && (rest == "s" || rest == "es" || rest == "'s"))})
            if (out.Length >= 25)
                break
        }
        return out
    }

    ; ============================================================
    ; ===== Hotkey: flag the selected text =====
    ; ============================================================

    static FlagSelection() {
        saved := ClipboardAll()
        A_Clipboard := ""
        Send("^c")
        text := ClipWait(0.6) ? A_Clipboard : ""
        A_Clipboard := saved
        saved := ""

        if (Trim(text, " `t`r`n") = "") {
            this._Tip("Non-Word List: nothing selected.")
            return
        }
        if !WordList.Load() {
            this._Tip("Non-Word List: word list not found:`n" Config.WordListFile)
            return
        }

        parsed := this.ParseSelection(text)
        found := [], missing := []
        seen := Map(), seen.CaseSense := "Off"
        for t in parsed.words {
            if seen.Has(t)
                continue
            seen[t] := 1
            f := this.FindInList(t)
            if (f != "")
                found.Push(f)
            else
                missing.Push(t)
        }

        if !found.Length {
            this._Tip("Non-Word List: none of the selected words are in the word list."
                . (missing.Length ? "`n(" this._Join(missing, 12) ")" : ""))
            return
        }

        ; Guard against a stray selection flagging real, common words.
        risky := []
        for w in found
            if (WordFrequency.CalculateFrequency(w) >= this.HighFreqWarn)
                risky.Push(w)
        if (risky.Length || found.Length > this.ConfirmOver) {
            msg := "Flag " found.Length " word(s) for removal from the word list?`n`n" this._Join(found, 40)
            if risky.Length
                msg .= "`n`nCAREFUL -- these are common on the web:`n" this._Join(risky, 40)
            if (acMsgBox.Show(msg, "Flag Non-Words", {icon: "icon!", buttons: ["Flag", "Cancel"]}) != "Flag")
                return
        }

        res := this.Add(found, parsed.note)
        res.missing := missing
        if res.added.Length
            SoundBeep(1000, 120)
        this._Tip(this._Summary(res))
    }

    ; Pulls candidate words out of the selection.  Per line:
    ;   "... but misspells a (), b ()"  -> a, b      (the words before each "(")
    ;   "; [REVIEW] needs definition: a, b" -> a, b
    ;   any other comment line or hotstring line -> nothing
    ;   anything else (a plain word or list)  -> every word in it
    ; A hotstring line also supplies the note: "from afficionad -> aficionad".
    static ParseSelection(text) {
        words := [], note := ""
        Loop Parse, text, "`n", "`r" {
            line := A_LoopField
            isHotstring := RegExMatch(line, '^\h*:[^:]*:([^:]+)::(?:f\(")?([^"\h;]*)', &h)
            if (isHotstring && note = "")
                note := "from " h[1] " -> " h[2]
            if RegExMatch(line, "but misspells\h+(.*)$", &m) {          ; case-sensitive on purpose:
                pos := 1                                                ; the "MISSPELLS" banner must not match
                while (pos := RegExMatch(m[1], "([A-Za-z][A-Za-z'\-]*)\h*\(", &w, pos)) {
                    words.Push(w[1])
                    pos += w.Len
                }
            }
            else if RegExMatch(line, "i)needs definition:\h*(.*)$", &m)
                this._Tokens(m[1], words)
            else if (!isHotstring && SubStr(LTrim(line, " `t"), 1, 1) != ";")
                this._Tokens(line, words)
        }
        return {words: words, note: note}
    }

    static _Tokens(s, arr) {
        pos := 1
        while (pos := RegExMatch(s, "[A-Za-z][A-Za-z'\-]*", &m, pos)) {
            arr.Push(RTrim(m[0], "'-"))
            pos += m.Len
        }
    }

    ; ============================================================
    ; ===== [Non-word] button in the Look (Definition) window =====
    ; ============================================================

    ; Called by Dictionary.ShowDefinitionGui() through _PostShowCallbacks.
    static AddDictButton(dictGui, word, defEdit) {
        btn := dictGui.AddButton("x+8", "Non-word")
        btn.OnEvent("Click", (ctrl, *) => NonWords.OnDictButton(ctrl, word, defEdit, dictGui))
    }

    static OnDictButton(btn, word, defEdit, dictGui) {
        if !WordList.Load() {
            this._Tip("Word list not found:`n" Config.WordListFile)
            return
        }
        cands := this.Candidates(word)
        if !cands.Length {
            btn.Text := "Not in list"
            btn.Enabled := false
            return
        }
        note := this.NoteFromDefinition(defEdit.Value)
        if (cands.Length = 1 && cands[1].checked)
            this._DictFlagged(btn, this.Add([cands[1].word], note))
        else
            this.ShowPicker(cands, note, btn, dictGui)
    }

    ; Reads ChatGPT's verdict out of the definition box, if it is there.
    static NoteFromDefinition(txt) {
        if RegExMatch(txt, "MISSPELLING:\h*\S+\h*(?:" Chr(0x2192) "|->)\h*([A-Za-z][A-Za-z'\-]*)", &m)
            return "misspelling of " m[1]
        if RegExMatch(txt, "^\h*(NON-ENGLISH|UNKNOWN)\b", &m)
            return "ChatGPT: " m[1]
        return ""
    }

    static ShowPicker(cands, note, btn, owner) {
        pk := Gui("+Owner" owner.Hwnd " -MinimizeBox", "Flag as Non-Words")
        this._Theme(pk)
        pk.Add("Text", "w340", "Remove which of these from the word list?")
        lv := pk.Add("ListView", "w340 Checked -Hdr r" Max(3, Min(cands.Length, 12)) " " this._Bg(), ["Word"])
        for c in cands
            lv.Add(c.checked ? "Check" : "", c.word)
        lv.ModifyCol(1, 310)
        pk.Add("Text", "w340", "Note (optional):")
        noteEdit := pk.Add("Edit", "w340 " this._Bg(), note)
        okBtn := pk.AddButton("w90 Default", "Flag")
        cancelBtn := pk.AddButton("x+8 w90", "Cancel")
        okBtn.OnEvent("Click", (*) => NonWords._PickerOK(pk, lv, noteEdit, btn))
        cancelBtn.OnEvent("Click", (*) => pk.Destroy())
        pk.OnEvent("Escape", (*) => pk.Destroy())
        pk.Show("AutoSize")
        okBtn.Focus()
    }

    static _PickerOK(pk, lv, noteEdit, btn) {
        words := [], row := 0
        while (row := lv.GetNext(row, "Checked"))
            words.Push(lv.GetText(row))
        note := noteEdit.Value
        pk.Destroy()
        if words.Length
            this._DictFlagged(btn, this.Add(words, note))
    }

    static _DictFlagged(btn, res) {
        try {                          ; the Look window may already be closed
            btn.Text := "Flagged"
            btn.Enabled := false
        }
        this._Tip(this._Summary(res))
    }

    ; ============================================================
    ; ===== Apply: remove pending words from the word list =====
    ; ============================================================

    static Apply(ownerHwnd := 0) {
        entries := this.ReadPending()
        ownerOpt := ownerHwnd ? " Owner" ownerHwnd : ""
        if !entries.Length {
            MsgBox("No words are waiting to be removed.", "Non-Word List", "Iconi" ownerOpt)
            return
        }
        path := Config.WordListFile
        if !FileExist(path) {
            MsgBox("Word list not found:`n" path, "Non-Word List", "Icon!" ownerOpt)
            return
        }
        SplitPath(path, &fileName, , , &nameNoExt)
        if (MsgBox("Remove " entries.Length " word(s) from " fileName "?`n`n"
            . "A backup copy of the current list is saved in the Debug folder first.",
            "Apply Non-Word List", "OKCancel Icon?" ownerOpt) != "OK")
            return

        try {
            enc := this._DetectEncoding(path)
            txt := FileRead(path, enc)
        } catch as err {
            MsgBox("Could not read " path "`n`n" err.Message, "Non-Word List", "Icon!" ownerOpt)
            return
        }

        ; Keep the file's own line endings, encoding and BOM (or lack of one).
        eol := InStr(txt, "`r`n") ? "`r`n" : "`n"
        hadFinalEol := (SubStr(txt, -1) = "`n")
        drop := Map()                  ; case-sensitive: "Polish" and "polish" are different entries
        for e in entries
            drop[e.word] := 0
        out := ""
        Loop Parse, txt, "`n", "`r" {
            w := Trim(A_LoopField, " `t")
            if (w != "" && drop.Has(w)) {
                drop[w] += 1
                continue
            }
            out .= A_LoopField eol
        }
        out := RTrim(out, "`r`n") (hadFinalEol ? eol : "")

        try {
            this._EnsureDir()
            backup := this.BackupDir "\" nameNoExt "_" FormatTime(, "yyyyMMdd_HHmmss") ".bak"
            FileCopy(path, backup, 1)
            tmp := path ".tmp"
            f := FileOpen(tmp, "w", enc)
            f.Write(out)
            f.Close()
            FileMove(tmp, path, 1)
        } catch as err {
            MsgBox("Could not write the word list -- nothing was changed.`n`n" err.Message, "Non-Word List", "Icon!" ownerOpt)
            return
        }

        ; The Exam Pane's in-memory copy is stale now.
        WordList.isLoaded := false
        WordList.Load()

        ; Record what happened, then empty the pending list.
        today := FormatTime(, "yyyy-MM-dd")
        removed := [], notFound := []
        log := ""
        for e in entries {
            if drop[e.word] {
                status := "removed"
                removed.Push(e.word)
            } else {
                status := "not in list"
                notFound.Push(e.word)
            }
            log .= e.word "`t" e.note "`t" e.date "`t" today "`t" status "`n"
        }
        try {
            if !FileExist(this.AppliedFile)
                FileAppend("; Non-words applied to the word list.`n; word<Tab>note<Tab>flagged<Tab>applied<Tab>result`n", this.AppliedFile, "UTF-8")
            FileAppend(log, this.AppliedFile, "UTF-8")
        }
        this.WritePending([])
        if IsObject(this.Mgr)
            this._MgrRefresh()

        msg := "Removed " removed.Length " word(s) from " fileName "."
        if notFound.Length
            msg .= "`n`nNot found in the list (already gone?):`n" this._Join(notFound, 40)
        msg .= "`n`nBackup: " backup "`nLog: " this.AppliedFile
        MsgBox(msg, "Non-Word List", "Iconi" ownerOpt)
    }

    ; "UTF-8" (has a BOM), "UTF-8-RAW" (valid UTF-8, or plain ASCII, with no BOM)
    ; or "CP0" (ANSI).  Writing back with the same name reproduces the same bytes.
    static _DetectEncoding(path) {
        buf := FileRead(path, "RAW")
        if (buf.Size >= 3 && NumGet(buf, 0, "UChar") = 0xEF
            && NumGet(buf, 1, "UChar") = 0xBB && NumGet(buf, 2, "UChar") = 0xBF)
            return "UTF-8"
        ; MB_ERR_INVALID_CHARS (8): returns 0 if the bytes are not valid UTF-8.
        if (buf.Size && DllCall("MultiByteToWideChar", "UInt", 65001, "UInt", 8
            , "Ptr", buf, "Int", buf.Size, "Ptr", 0, "Int", 0, "Int"))
            return "UTF-8-RAW"
        return "CP0"
    }

    ; ============================================================
    ; ===== Review window =====
    ; ============================================================

    static ShowManager(*) {
        if IsObject(this.Mgr) {
            this._MgrRefresh()
            this.Mgr.Show()
            return
        }
        SplitPath(Config.WordListFile, &fileName)
        ; AlwaysOnTop, like HH itself -- otherwise HH covers it when opened from the Control Panel.
        g := Gui("+AlwaysOnTop", "Non-Word List")
        this._Theme(g)
        g.Add("Text", "w600", "Words flagged for removal from " fileName ".  Nothing changes in the word list until you click Apply.")
        lv := g.Add("ListView", "w600 r16 " this._Bg(), ["Word", "Note", "Flagged"])
        st := g.Add("Text", "w600", "")
        applyBtn := g.AddButton("", "Apply to Word List")
        removeBtn := g.AddButton("x+8", "Remove Selected")
        openBtn := g.AddButton("x+8", "Open File")
        closeBtn := g.AddButton("x+8", "Close")

        applyBtn.OnEvent("Click", (*) => NonWords.Apply(g.Hwnd))
        removeBtn.OnEvent("Click", (*) => NonWords._MgrRemoveSelected())
        openBtn.OnEvent("Click", (*) => NonWords._MgrOpenFile())
        closeBtn.OnEvent("Click", (*) => NonWords._MgrClose())
        lv.OnEvent("DoubleClick", (ctrl, row) => NonWords._MgrLookup(ctrl, row))
        g.OnEvent("Escape", (*) => NonWords._MgrClose())
        g.OnEvent("Close", (*) => NonWords._MgrClose())

        this.Mgr := g, this.MgrLV := lv, this.MgrStatus := st
        this._MgrRefresh()
        g.Show("AutoSize")
        closeBtn.Focus()
    }

    static _MgrRefresh() {
        entries := this.ReadPending()
        lv := this.MgrLV
        lv.Opt("-Redraw")
        lv.Delete()
        for e in entries
            lv.Add(, e.word, e.note, e.date)
        lv.ModifyCol(1, "AutoHdr"), lv.ModifyCol(2, "AutoHdr"), lv.ModifyCol(3, "AutoHdr")
        lv.Opt("+Redraw")
        this.MgrStatus.Text := entries.Length " word(s) waiting.  Double-click a word to look it up."
    }

    static _MgrRemoveSelected() {
        sel := Map(), row := 0
        while (row := this.MgrLV.GetNext(row))
            sel[this.MgrLV.GetText(row, 1)] := 1
        if !sel.Count
            return
        keep := []
        for e in this.ReadPending()
            if !sel.Has(e.word)
                keep.Push(e)
        this.WritePending(keep)
        this._MgrRefresh()
    }

    static _MgrOpenFile() {
        if !FileExist(this.File)
            this.WritePending([])
        Utils.OpenFileAtEnd(this.File)
    }

    ; The Look window is not AlwaysOnTop, so lift it above this one.
    static _MgrLookup(lv, row) {
        if !row
            return
        Dictionary.ShowDefinitionGui(lv.GetText(row, 1))
        try WinSetAlwaysOnTop(1, "A")
    }

    static _MgrClose() {
        if IsObject(this.Mgr)
            this.Mgr.Destroy()
        this.Mgr := 0, this.MgrLV := 0, this.MgrStatus := 0
    }

    ; ============================================================
    ; ===== Small helpers =====
    ; ============================================================

    static _Summary(res) {
        s := ""
        if res.added.Length
            s .= "Flagged as non-word: " this._Join(res.added, 15)
        if res.dupes.Length
            s .= (s != "" ? "`n" : "") "Already flagged: " this._Join(res.dupes, 15)
        if (res.HasOwnProp("missing") && res.missing.Length)
            s .= (s != "" ? "`n" : "") "Not in word list (skipped): " this._Join(res.missing, 15)
        return s "`n(" this.ReadPending().Length " waiting in Non-Word List)"
    }

    static _Join(arr, maxItems) {
        s := ""
        for i, v in arr {
            if (i > maxItems)
                return s ", ... (" arr.Length " total)"
            s .= (i > 1 ? ", " : "") v
        }
        return s
    }

    static _Tip(msg) {
        ToolTip(msg)
        SetTimer(() => ToolTip(), -2000)
    }

    static _Theme(g) {
        try g.BackColor := Config.FormColor
        g.SetFont("s11 " Config.FontColor)
    }

    static _Bg() => (Config.ListColor != "" ? "Background" Config.ListColor : "")
}
