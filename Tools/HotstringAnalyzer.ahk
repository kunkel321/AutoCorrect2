#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; Hotstring / Manual Correction Analyzer
; Made for use with the AutoCorrect2 Suite of applications
; By: kunkel321 using ChatGPT and Claude.
; Version Date: 6-29-2026
; ============================================================
;
; On startup a file-selection GUI appears offering:
;   1. HotstringLib.ahk   (auto-detected via acSettings.ini)
;   2. ManualCorrectionsLog.txt  (default log path)
;   3. Browse for another file...
;
; When an .ahk hotstring library is selected the defunctionizer
; logic strips f() wrapper calls first, so the analyzer sees
; plain ::trigger::replacement lines.
;
; This script can analyze either:
;   1. ManualCorrection log lines--     2025-01-29 -- ::functionaliyy::functionality
;   2. Plain AutoHotkey hotstrings--    ::functionaliyy::functionality
;   3. Word-middle hotstrings--         :*?:trig::replacement
;   4. Word-beginning hotstrings--      :*:trig::replacement
;   5. Word-ending hotstrings--         :?:trig::replacement
;
; Inline comments are stripped only when the semicolon is
; preceded by whitespace, so literal semicolons inside text
; are less likely to be damaged.
;
;   Note: When analyzing a full ManualCorrectionsLog file, the trigger
;   is usually a full mistyped word.
;
;   When analyzing an AutoCorrect library, the trigger may be
;   only part of a word. Results are best understood as
;   trigger/replacement pattern analysis, not full-word typo
;   analysis.
;
; ============================================================

; ============================================================
; PATHS
; ============================================================

settingsFile    := A_ScriptDir "\..\Data\acSettings.ini"
defaultLogPath  := A_ScriptDir "\..\Data\ManualCorrectionsLog.txt"
debugDir        := A_ScriptDir "\..\Debug\"
maxExamples     := 24          ; Max example items shown per category in the report

; Resolve HotstringLib path via acSettings.ini if available.
if FileExist(settingsFile)
    hsLibPath := A_ScriptDir "\..\Core\" IniRead(settingsFile, "Paths", "HotstringLibrary", "HotstringLib.ahk")
else
    hsLibPath := A_ScriptDir "\..\Core\HotstringLib.ahk"

; Resolve AutoCorrectsLog path via acSettings.ini if available.
if FileExist(settingsFile)
    acLogPath := A_ScriptDir "\..\Data\" IniRead(settingsFile, "Files", "AutoCorrectsLogFile", "AutoCorrectsLog.txt")
else
    acLogPath := A_ScriptDir "\..\Data\AutoCorrectsLog.txt"

; ============================================================
; FILE-SELECTION GUI
; ============================================================

selGui := Gui("+AlwaysOnTop", "Hotstring Analyzer — Select Input File")
selGui.SetFont("s11")
selGui.Add("Text",, "Select a file to analyze:")
selGui.Add("Text",, "")   ; spacer

; ManualCorrectionsLog button
logLabel := FileExist(defaultLogPath)
    ? "ManualCorrectionsLog.txt"
    : "ManualCorrectionsLog.txt  (not found)"
btnLog := selGui.Add("Button", "w380 h35", logLabel)
btnLog.OnEvent("Click", ChooseLog)

; HotstringLib button
libLabel := FileExist(hsLibPath)
    ? "HotstringLib.ahk  (defunctionize then analyze)"
    : "HotstringLib.ahk  (not found)"
btnLib := selGui.Add("Button", "w380 h35", libLabel)
btnLib.OnEvent("Click", ChooseLib)

; Browse button
selGui.Add("Button", "w380 h35", "Browse for another file...").OnEvent("Click", BrowseFile)

selGui.Add("Text",, "")   ; spacer
chkDump := selGui.Add("Checkbox",, "Also create Complex/Unknown dump file")
chkLog  := selGui.Add("Checkbox", "Checked", "Include ACLog usage stats in summary  (HotstringLib only)")

selGui.Show("AutoSize")

; ----------------------------------------------------------------
; Button handlers
; ----------------------------------------------------------------

ChooseLog(GuiCtrlObj, *) {
    global defaultLogPath, selGui, chkDump, chkLog
    doDump := chkDump.Value
    doLog  := chkLog.Value
    selGui.Destroy()
    if !FileExist(defaultLogPath) {
        MsgBox "ManualCorrectionsLog.txt was not found:`n" defaultLogPath
        ExitApp
    }
    RunAnalysis(defaultLogPath, false, doDump, doLog)
}

ChooseLib(GuiCtrlObj, *) {
    global hsLibPath, selGui, chkDump, chkLog
    doDump := chkDump.Value
    doLog  := chkLog.Value
    selGui.Destroy()
    if !FileExist(hsLibPath) {
        MsgBox "HotstringLib.ahk was not found:`n" hsLibPath
        ExitApp
    }
    RunAnalysis(hsLibPath, true, doDump, doLog)
}

BrowseFile(GuiCtrlObj, *) {
    global selGui, hsLibPath, chkDump, chkLog
    doDump := chkDump.Value
    doLog  := chkLog.Value
    SplitPath(hsLibPath,, &startDir)
    chosen := FileSelect(1, startDir, "Select file to analyze",
        "AHK or text files (*.ahk; *.txt)")
    if (chosen = "")
        return
    selGui.Destroy()
    ; Treat .ahk files as hotstring libraries needing defunctionizing.
    needsDefunc := (SubStr(chosen, -3) = ".ahk")
    RunAnalysis(chosen, needsDefunc, doDump, doLog)
}

; ============================================================
; DEFUNCTIONIZER HELPER
; ============================================================

; Returns the text of an AHK hotstring library with all f()
; wrapper calls stripped, producing plain ::trig::replacement lines.
; Non-hotstring lines (comments, #Requires, blank lines, etc.)
; are passed through unchanged.
DefunctionizeText(rawText) {
    ; Regex credit: based on work by Andymbody.
    hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<Comment>\h*;.*)?$"

    out := ""
    Loop Parse, rawText, "`n", "`r" {
        line := A_LoopField
        if RegExMatch(line, hsRegex, &m) {
            opts    := StrReplace(StrReplace(m.Opts, "X", ""), "B0", "")
            trig    := m.Trig
            repl    := Trim(m.Repl, '"')
            ; Keep "misspells" warnings; drop other comments.
            comment := (m.Comment && InStr(m.Comment, "misspells")) ? m.Comment : ""
            out .= ":" opts ":" trig "::" repl comment "`n"
        } else {
            out .= line "`n"
        }
    }
    return out
}

; ============================================================
; MAIN ANALYSIS ROUTINE
; ============================================================

RunAnalysis(filePath, isAhkLib, createDump := true, includeLog := true) {
    global debugDir, acLogPath

    ; Ensure Debug output folder exists.
    if !DirExist(debugDir)
        DirCreate(debugDir)

    ; -------------------------------
    ; Read file
    ; -------------------------------
    txt := FileRead(filePath, "UTF-8")

    ; If this is an AHK library, strip f() calls first.
    if isAhkLib
        txt := DefunctionizeText(txt)

    ; -------------------------------
    ; Load ACLog usage stats (optional)
    ; -------------------------------
    ; logStats Map: key = "trigger::replacement"  value = {bs, ok}
    logStats := Map()
    if includeLog
        logStats := LoadACLogStats(acLogPath)

    ; -------------------------------
    ; Statistics
    ; -------------------------------
    stats := Map()
    stats["Total parsed"]                      := 0
    stats["Skipped lines"]                     := 0
    stats["Adjacent transposition"]            := 0
    stats["Dropped letter + neighbor doubled"] := 0
    stats["Extra letter"]                      := 0
    stats["Missing letter"]                    := 0
    stats["Suffix/chunk intrusion"]            := 0
    stats["Homophone / wrong word"]            := 0
    stats["Wrong verb form"]                   := 0
    stats["Modal 'of' -> 'have'"]              := 0
    stats["Hyphenation fix"]                   := 0
    stats["Wrong apostrophe char"]             := 0
    stats["Latin plural/singular"]             := 0
    stats["Wrong function word"]               := 0
    stats["Keyboard adjacent substitution"]     := 0
    stats["Vowel confusion"]                    := 0
    stats["Phonetic substitution"]              := 0
    stats["Accented character fix"]             := 0
    stats["Complex/unknown"]                   := 0

    examples    := Map()
    logBS       := Map()   ; backspace count per category from ACLog
    logOK       := Map()   ; kept count per category from ACLog
    complexDump := []      ; full list of Complex/unknown pairs for separate dump file
    for category in stats {
        if (category != "Total parsed" && category != "Skipped lines") {
            examples[category] := []
            logBS[category]    := 0
            logOK[category]    := 0
        }
    }

    ; -------------------------------
    ; Parse and classify
    ; -------------------------------
    Loop Parse, txt, "`n", "`r" {
        rawLine := A_LoopField
        line := StripInlineComment(Trim(rawLine))

        if (line = "")
            continue
        if InStr(line, "Manual Correction Logger")
            continue
        if InStr(line, "Capture Date")
            continue
        if RegExMatch(line, "^=+$")
            continue
        if RegExMatch(line, "^-+$")
            continue

        if !TryParseHotstringLine(line, &trigger, &replacement) {
            stats["Skipped lines"] += 1
            continue
        }

        trigger     := Trim(trigger)
        replacement := Trim(replacement)

        if (trigger = "" || replacement = "") {
            stats["Skipped lines"] += 1
            continue
        }

        category := AnalyzePair(trigger, replacement)
        stats["Total parsed"] += 1

        if stats.Has(category)
            stats[category] += 1
        else
            stats["Complex/unknown"] += 1

        if examples.Has(category) && examples[category].Length < maxExamples
            examples[category].Push(trigger " → " replacement)

        if (category = "Complex/unknown")
            complexDump.Push(trigger " → " replacement)

        ; Accumulate ACLog BS/OK for this category.
        if includeLog && logStats.Count > 0 {
            key := trigger "::" replacement
            if logStats.Has(key) {
                logBS[category] += logStats[key].bs
                logOK[category] += logStats[key].ok
            }
        }
    }

    ; -------------------------------
    ; Build report
    ; -------------------------------
    SplitPath(filePath, &dispName)

    report := "Hotstring / Manual Correction Analysis`n"
    report .= "======================================`n`n"
    report .= "Input file:`n" filePath "`n"
    if isAhkLib
        report .= "(AHK library — f() calls were stripped before analysis)`n"
    report .= "`n"

    total := stats["Total parsed"]

    report .= "Total parsed:  " total "`n"
    report .= "Skipped lines: " stats["Skipped lines"] "`n`n"

    report .= "Pattern summary`n"
    report .= "---------------`n"

    orderedCategories := [
        "Dropped letter + neighbor doubled",
        "Adjacent transposition",
        "Extra letter",
        "Missing letter",
        "Suffix/chunk intrusion",
        "Homophone / wrong word",
        "Wrong verb form",
        "Modal 'of' -> 'have'",
        "Hyphenation fix",
        "Wrong apostrophe char",
        "Latin plural/singular",
        "Wrong function word",
        "Keyboard adjacent substitution",
        "Vowel confusion",
        "Phonetic substitution",
        "Accented character fix",
        "Complex/unknown"
    ]

    ; Totals for ACLog columns.
    totalBS := 0
    totalOK := 0
    if includeLog && logStats.Count > 0 {
        for cat in orderedCategories {
            totalBS += logBS[cat]
            totalOK += logOK[cat]
        }
    }
    totalLog := totalBS + totalOK

    ; Column headers — plain strings (AHK Format does not support {:>N} right-align).
    if includeLog && logStats.Count > 0 {
        report .= "Pattern                                Count  (  %)       BSed  (  %)      Kept  (  %)`n"
        report .= "======================================================================================`n"
        report .= "  Count(%): share of all scanned items belonging to this pattern type`n"
        report .= "  BSed (%): rejection rate for this category  — BS / (BS+Kept)`n"
        report .= "  Kept (%): acceptance rate for this category — Kept / (BS+Kept)`n"
        report .= "  BSed% + Kept% = 100% for any category that has ACLog entries.`n"
        report .= "  A category showing 0 BS and 0 Kept has no matching ACLog entries.`n"
        report .= "======================================================================================`n"
    } else {
        report .= "Pattern                                Count  (  %)`n"
        report .= "====================================================`n"
        report .= "  Count(%): share of all scanned items belonging to this pattern type`n"
        report .= "====================================================`n"
    }

    for category in orderedCategories {
        count := stats[category]
        pct   := total ? Round((count / total) * 100, 1) : 0
        if includeLog && logStats.Count > 0 {
            bs      := logBS[category]
            ok      := logOK[category]
            ; Both % are per-category rates: BS/(BS+OK) and OK/(BS+OK).
            ; They are directly comparable and sum to 100% when entries exist.
            bsPct   := (bs + ok) ? Round((bs / (bs + ok)) * 100, 1) : 0
            keptPct := (bs + ok) ? Round((ok / (bs + ok)) * 100, 1) : 0
            report .= Format("{:-36}  {:6} ({:4.1f}%)   {:6} ({:4.1f}%)   {:6} ({:4.1f}%)`n",
                category ":", count, pct, bs, bsPct, ok, keptPct)
        } else {
            report .= Format("{:-36}  {:6} ({:4.1f}%)`n", category ":", count, pct)
        }
    }

    ; Log summary footer.
    if includeLog && logStats.Count > 0 {
        report .= "`n"
        report .= Format("ACLog totals:  {} BSed  +  {} Kept  =  {} entries`n", totalBS, totalOK, totalLog)
        if totalLog
            report .= Format("Overall acceptance rate: {:.1f}% kept,  {:.1f}% backspaced`n",
                (totalOK / totalLog) * 100, (totalBS / totalLog) * 100)
    } else if includeLog && logStats.Count = 0 {
        report .= "(ACLog not found or empty — usage columns omitted)`n"
    }

    report .= "`nExamples  (up to " maxExamples " real scanned items per category)`n"
    report .= "--------`n"

    ; One-line description shown under each category heading.
    descriptions := Map(
        "Dropped letter + neighbor doubled",
            "A letter was omitted and the following letter was typed twice instead.  (functionaliyy -> functionality)",
        "Adjacent transposition",
            "Two adjacent letters were swapped.  (teh -> the,  clcik -> click)",
        "Extra letter",
            "One extra letter was inserted.  (goood -> good)",
        "Missing letter",
            "One letter was omitted.  (defnitely -> definitely)",
        "Suffix/chunk intrusion",
            "A common suffix or chunk appears in the trigger but not the replacement.  (Karent -> Karen)",
        "Homophone / wrong word",
            "A real word was used that sounds like, or is commonly confused with, the intended word.  (bare the brunt -> bear the brunt)",
        "Wrong verb form",
            "An incorrect irregular verb form follows an auxiliary verb.  (had went -> had gone,  was sang -> was sung)",
        "Modal 'of' -> 'have'",
            "A modal verb was followed by 'of' instead of 'have'.  (should of -> should have)",
        "Hyphenation fix",
            "The pair differs only in the presence or absence of a hyphen; the non-hyphen text is otherwise identical.  (a falling out -> a falling-out)",
        "Wrong apostrophe char",
            "A semicolon or backtick was typed instead of an apostrophe in a contraction.  (can``nt -> can't,  i;d -> I'd)",
        "Latin plural/singular",
            "A Latin-origin plural was used where the singular was needed, or vice versa.  (a criteria -> a criterion)",
        "Wrong function word",
            "Only one small function word (preposition, article, conjunction) differs.  (on accident -> by accident)",
        "Keyboard adjacent substitution",
            "One letter was replaced by a QWERTY keyboard neighbor.  (vuew -> view,  contect -> context)",
        "Vowel confusion",
            "One vowel was substituted for another vowel, typically in an unstressed syllable.  (solotion -> solution,  wrip -> wrap)",
        "Phonetic substitution",
            "A phonetically equivalent letter or digraph was used instead of the correct spelling.  (cometimes -> sometimes,  sould -> could)",
        "Accented character fix",
            "The replacement is the same word but with accented characters.  (decollete -> decollete,  cafe -> cafe)",
        "Complex/unknown",
            "Did not match any of the above patterns."
    )

    for category in orderedCategories {
        count := stats[category]
        pct   := total ? Round((count / total) * 100, 1) : 0
        if includeLog && logStats.Count > 0 {
            bs      := logBS[category]
            ok      := logOK[category]
            bsPct   := (bs + ok) ? Round((bs / (bs + ok)) * 100, 1) : 0
            keptPct := (bs + ok) ? Round((ok / (bs + ok)) * 100, 1) : 0
            statsLine := Format("Count {} ({:4.1f}%) BSed {} ({:4.1f}%)  Kept {} ({:4.1f}%)",
                count, pct, bs, bsPct, ok, keptPct)
        } else {
            statsLine := Format("Count {} ({:4.1f}%)", count, pct)
        }
        report .= "`n" category ":  " statsLine "`n"
        if descriptions.Has(category)
            report .= "  (" descriptions[category] ")`n"
        if !examples.Has(category) || examples[category].Length = 0 {
            report .= "  (none)`n"
            continue
        }
        for item in examples[category]
            report .= "  " item "`n"
    }

    ; -------------------------------
    ; Save and open report
    ; -------------------------------
    reportPath := debugDir "HotstringAnalysisReport" A_Now ".txt"

    FileAppend report, reportPath, "UTF-8"
    Run reportPath

    ; -------------------------------
    ; Dump Complex/unknown pairs (optional)
    ; -------------------------------
    if createDump {
        dumpPath := debugDir "ComplexUnknown_Dump.txt"
        if FileExist(dumpPath)
            FileDelete dumpPath

        dumpText := "Complex/Unknown pairs — " complexDump.Length " items`n"
        dumpText .= "Source: " filePath "`n"
        dumpText .= FormatTime(A_Now, "yyyy-MM-dd  HH:mm") "`n"
        dumpText .= "======================================`n`n"
        for pair in complexDump
            dumpText .= pair "`n"

        FileAppend dumpText, dumpPath, "UTF-8"
        Run dumpPath
    }

    ExitApp
}


; ============================================================
; PARSING FUNCTIONS
; ============================================================

TryParseHotstringLine(line, &trigger, &replacement) {
    ; Supports:
    ;   2025-01-29 -- ::functionaliyy::functionality
    ;   ::functionaliyy::functionality
    ;   :*?:trig::replacement
    ;   :*:trig::replacement
    ;   :?:trig::replacement

    ; Drop optional date prefix used by ManualCorrectionsLog.
    line := RegExReplace(line, "^\s*\d{4}-\d{2}-\d{2}\s+--\s+", "")

    if !RegExMatch(line, "^:([^:]*):(.*?)::(.*)$", &m)
        return false

    trigger     := m[2]
    replacement := m[3]
    return true
}

StripInlineComment(line) {
    ; Removes inline comments when the semicolon is preceded by whitespace.
    ; Does NOT remove:  ::semi::;
    return RegExReplace(line, "\s+;.*$", "")
}


; ============================================================
; ANALYSIS FUNCTIONS
; ============================================================

AnalyzePair(trigger, replacement) {
    ; Order matters.  Semantic/grammatical checks run FIRST so that
    ; multi-word homophone pairs (e.g. "managerial reign -> rein",
    ; "all tolled -> all told") are not swallowed by the broader
    ; char-level matchers (ExtraChar, MissingChar, SuffixIntrusion).
    ;
    ; Defunctionizer artifact guard: skip pairs whose replacement
    ; still contains f(" — the line was not fully parsed.
    if InStr(replacement, "f(" Chr(34))
        return "Complex/unknown"

    if IsWrongApostropheChar(trigger, replacement)
        return "Wrong apostrophe char"
    if IsModalOf(trigger, replacement)
        return "Modal 'of' -> 'have'"
    if IsHyphenationFix(trigger, replacement)
        return "Hyphenation fix"
    if IsLatinPluralFix(trigger, replacement)
        return "Latin plural/singular"
    if IsHomophoneSwap(trigger, replacement)
        return "Homophone / wrong word"
    if IsWrongVerbForm(trigger, replacement)
        return "Wrong verb form"
    if IsWrongFunctionWord(trigger, replacement)
        return "Wrong function word"
    if IsAdjacentTranspose(trigger, replacement)
        return "Adjacent transposition"
    if IsNeighborDoubledAfterOmission(trigger, replacement)
        return "Dropped letter + neighbor doubled"
    if IsOneExtraChar(trigger, replacement)
        return "Extra letter"
    if IsOneMissingChar(trigger, replacement)
        return "Missing letter"
    if IsSuffixIntrusion(trigger, replacement)
        return "Suffix/chunk intrusion"
    if IsKeyboardAdjacentSub(trigger, replacement)
        return "Keyboard adjacent substitution"
    if IsVowelConfusion(trigger, replacement)
        return "Vowel confusion"
    if IsPhoneticSub(trigger, replacement)
        return "Phonetic substitution"
    if IsAccentFix(trigger, replacement)
        return "Accented character fix"
    return "Complex/unknown"
}

; ----------------------------------------------------------------
; Original detectors
; ----------------------------------------------------------------

IsAdjacentTranspose(a, b) {
    ; Example: teh → the, clcik → click
    ; Same length, exactly two adjacent positions differ, and they are swapped.
    if StrLen(a) != StrLen(b)
        return false
    diffs := []
    Loop StrLen(a) {
        i := A_Index
        if SubStr(a, i, 1) != SubStr(b, i, 1)
            diffs.Push(i)
    }
    return (
        diffs.Length = 2
        && diffs[2] = diffs[1] + 1
        && SubStr(a, diffs[1], 1) = SubStr(b, diffs[2], 1)
        && SubStr(a, diffs[2], 1) = SubStr(b, diffs[1], 1)
    )
}

IsOneExtraChar(trigger, replacement) {
    ; Example: goood → good
    return (
        StrLen(trigger) = StrLen(replacement) + 1
        && CanMatchBySkippingOne(trigger, replacement)
    )
}

IsOneMissingChar(trigger, replacement) {
    ; Example: defnitely → definitely
    return (
        StrLen(trigger) + 1 = StrLen(replacement)
        && CanMatchBySkippingOne(replacement, trigger)
    )
}

CanMatchBySkippingOne(longer, shorter) {
    ; Returns true if "longer" becomes "shorter" by deleting exactly one character.
    i       := 1
    j       := 1
    skipped := false
    while i <= StrLen(longer) {
        if (j <= StrLen(shorter) && SubStr(longer, i, 1) = SubStr(shorter, j, 1)) {
            i++
            j++
        } else {
            if skipped
                return false
            skipped := true
            i++
        }
    }
    return true
}

IsNeighborDoubledAfterOmission(trigger, replacement) {
    ; Example: functionaliyy -> functionality
    ; Same length; one intended letter was omitted and the next letter was doubled.
    ; Guard: only applies to single-word pairs — multi-word pairs with the same
    ; total length could generate spurious matches (e.g. "allot of" -> "a lot of").
    if InStr(trigger, " ") || InStr(replacement, " ")
        return false
    if StrLen(trigger) != StrLen(replacement)
        return false
    Loop StrLen(replacement) - 1 {
        i  := A_Index
        c2 := SubStr(replacement, i + 1, 1)
        test := SubStr(replacement, 1, i - 1) . c2 . c2 . SubStr(replacement, i + 2)
        if (test = trigger)
            return true
    }
    return false
}

IsSuffixIntrusion(trigger, replacement) {
    ; Example: Karent → Karen
    ; A common typed chunk appears in the trigger but not the replacement.
    commonChunks := [
        "ent", "ing", "tion", "sion", "ment",
        "ally", "ed", "er", "ly", "able", "ible"
    ]
    for chunk in commonChunks {
        if (InStr(trigger, chunk) && !InStr(replacement, chunk))
            return true
    }
    return false
}

; ----------------------------------------------------------------
; New detectors
; ----------------------------------------------------------------

IsWrongApostropheChar(trigger, replacement) {
    ; Detects contractions where the user typed ; or ` instead of '
    ; Examples:  i;d → I'd    can`nt → can't    they;re → they're
    return (
        RegExMatch(trigger, "[;`]")
        && InStr(replacement, "'")
    )
}

IsModalOf(trigger, replacement) {
    ; Detects "would/should/could/might/must/may of" written instead of "have".
    ; Examples:  would of → would have    must of been → must have been
    return (
        RegExMatch(trigger, "i)\b(would|should|could|might|must|may|can)\s+of\b")
        && RegExMatch(replacement, "i)\bhave\b")
    )
}

IsHyphenationFix(trigger, replacement) {
    ; Detects pairs that differ only in the presence or absence of a hyphen.
    ; Examples:  a falling out → a falling-out    are set-up → are set up
    ; The non-hyphen text must be identical once hyphens and spaces are removed.
    if (!!InStr(trigger, "-")) = (!!InStr(replacement, "-"))
        return false
    tStripped := StrReplace(StrReplace(trigger,     "-", ""), " ", "")
    rStripped := StrReplace(StrReplace(replacement, "-", ""), " ", "")
    return (tStripped = rStripped)
}

IsLatinPluralFix(trigger, replacement) {
    ; Detects misuse of Latin-origin plural/singular forms.
    ; Examples:  a criteria → a criterion    in parenthesis → in parentheses
    latinPairs := [
        ["criteria",     "criterion"],
        ["phenomena",    "phenomenon"],
        ["nuclei",       "nucleus"],
        ["fungi",        "fungus"],
        ["radii",        "radius"],
        ["strata",       "stratum"],
        ["taxa",         "taxon"],
        ["protozoa",     "protozoon"],
        ["spermatozoa",  "spermatozoon"],
        ["flagella",     "flagellum"],
        ["consortia",    "consortium"],
        ["parentheses",  "parenthesis"],
        ["data",         "datum"],
        ["bacteriae",    "bacteria"],
        ["alumni",       "alumnus"],
        ["syllabi",      "syllabus"],
        ["stimuli",      "stimulus"],
        ["foci",         "focus"],
        ["cacti",        "cactus"],
        ["formulae",     "formula"],
    ]
    tLow := StrLower(trigger)
    rLow := StrLower(replacement)
    for pair in latinPairs {
        pl := pair[1], sg := pair[2]
        if (InStr(tLow, pl) && InStr(rLow, sg))
            return true
        if (InStr(tLow, sg) && InStr(rLow, pl))
            return true
    }
    return false
}

IsHomophoneSwap(trigger, replacement) {
    ; Detects pairs where a real English word in the trigger is replaced by its
    ; homophone or commonly confused near-homophone in the replacement.
    ; Examples:  bare the brunt → bear the brunt    better then → better than
    ;            maid a mistake → made a mistake     pore over → pour over

    ; Map: wrong word → correct word(s)  (lower-case, no punctuation)
    homophones := Map(
        "affect",    "effect",
        "effect",    "affect",
        "then",      "than",
        "bare",      "bear",
        "brake",     "break",
        "maid",      "made",
        "warn",      "worn",
        "pore",      "poor",
        "pour",      "poor",
        "soar",      "sore",
        "rain",      "reign",
        "rein",      "rain",
        "weight",    "wait",
        "weather",   "whether",
        "loan",      "lone",
        "principal", "principle",
        "principle", "principal",
        "cite",      "site",
        "sight",     "site",
        "soul",      "sole",
        "threw",     "through",
        "role",      "roll",
        "roll",      "role",
        "peak",      "pique",
        "peek",      "peak",
        "passed",    "past",
        "waist",     "waste",
        "waste",     "waist",
        "seam",      "seem",
        "steel",     "steal",
        "plain",     "plane",
        "plane",     "plain",
        "aloud",     "allowed",
        "vane",      "vain",
        "knead",     "need",
        "colonel",   "kernel",
        "kernel",    "colonel",
        "rite",      "right",
        "write",     "right",
        "reign",     "rain",
        "lessen",    "lesson",
        "whose",     "whos",
        "your",      "youre",
        "their",     "there",
        "there",     "their",
        "theyre",    "there",
        "whos",      "whose"
    )

    ; Tokenize: lower-case letters/digits/apostrophes only.
    tWords := StrSplit(RegExReplace(StrLower(trigger),     "[^a-z0-9']+", " "), " ")
    rWords := Map()
    for w in StrSplit(RegExReplace(StrLower(replacement), "[^a-z0-9']+", " "), " ")
        rWords[w] := 1

    for tw in tWords {
        if !homophones.Has(tw)
            continue
        correct := homophones[tw]
        if rWords.Has(correct)
            return true
    }
    return false
}

IsWrongVerbForm(trigger, replacement) {
    ; Detects incorrect irregular verb forms following an auxiliary.
    ; Examples:  had went → had gone    has came → has come    was sang → was sung
    ;
    ; Strategy: both strings must be multi-word, same word count, share the same
    ; auxiliary, and differ in exactly one word (the verb form).

    tWords := StrSplit(StrLower(Trim(trigger)),     " ")
    rWords := StrSplit(StrLower(Trim(replacement)), " ")

    if (tWords.Length < 2 || tWords.Length != rWords.Length)
        return false

    auxiliaries := Map(
        "had",1, "have",1, "has",1, "having",1,
        "was",1, "were",1, "been",1, "be",1,
        "is",1,  "are",1,
        "will",1, "would",1, "should",1, "could",1,
        "must",1, "may",1, "might",1, "can",1
    )

    ; Check that at least one auxiliary is present and shared.
    tHasAux := false
    for w in tWords
        if auxiliaries.Has(w)
            tHasAux := true
    if !tHasAux
        return false

    ; Count differing positions.
    diffCount := 0
    Loop tWords.Length {
        if (tWords[A_Index] != rWords[A_Index])
            diffCount++
    }

    ; Exactly one word differs (the verb form), and neither differing word is an
    ; auxiliary itself (that would be a function-word swap, not a verb form).
    if (diffCount < 1 || diffCount > 2)
        return false

    for i, tw in tWords {
        if (tw != rWords[i]) {
            if auxiliaries.Has(tw) || auxiliaries.Has(rWords[i])
                return false
        }
    }
    return true
}

IsWrongFunctionWord(trigger, replacement) {
    ; Detects pairs where only one small function word differs.
    ; Examples:  on accident → by accident    try and → try to    in masse → en masse
    ;            copy or report → copy of report

    functionWords := Map(
        "of",1, "to",1, "on",1, "from",1, "with",1, "by",1, "at",1,
        "for",1, "as",1, "into",1, "in",1, "up",1, "off",1, "out",1,
        "or",1, "and",1, "a",1, "an",1, "en",1, "the",1, "per",1
    )

    tWords := StrSplit(StrLower(Trim(trigger)),     " ")
    rWords := StrSplit(StrLower(Trim(replacement)), " ")

    if (tWords.Length != rWords.Length || tWords.Length < 2)
        return false

    diffs := []
    Loop tWords.Length {
        if (tWords[A_Index] != rWords[A_Index])
            diffs.Push(A_Index)
    }

    if (diffs.Length != 1)
        return false

    d := diffs[1]
    return (functionWords.Has(tWords[d]) || functionWords.Has(rWords[d]))
}

IsAccentFix(trigger, replacement) {
    ; Detects pairs where the replacement is the same word(s) as the trigger
    ; but with one or more ASCII letters replaced by their accented equivalents.
    ; Examples:  decollete -> decollete  cafe -> cafe  manana -> manana
    ;            resume -> resume  naive -> naive  fiancee -> fiancee
    ;
    ; Strategy: build a plain-ASCII version of the replacement by mapping each
    ; accented character back to its base letter, then compare case-insensitively
    ; with the trigger.  If they match (and the replacement actually contains at
    ; least one non-ASCII character) it is an accent fix.

    ; Quick bail-outs.
    if (StrLen(trigger) != StrLen(replacement))
        return false

    ; Check whether the replacement contains any non-ASCII byte.
    hasAccent := false
    Loop StrLen(replacement) {
        if (Ord(SubStr(replacement, A_Index, 1)) > 127) {
            hasAccent := true
            break
        }
    }
    if !hasAccent
        return false

    ; Map accented characters to their ASCII base letters.
    accentMap := Map(
        Chr(0xC0),"a", Chr(0xC1),"a", Chr(0xC2),"a", Chr(0xC3),"a",
        Chr(0xC4),"a", Chr(0xC5),"a", Chr(0xC6),"ae",
        Chr(0xC7),"c",
        Chr(0xC8),"e", Chr(0xC9),"e", Chr(0xCA),"e", Chr(0xCB),"e",
        Chr(0xCC),"i", Chr(0xCD),"i", Chr(0xCE),"i", Chr(0xCF),"i",
        Chr(0xD0),"d", Chr(0xD1),"n",
        Chr(0xD2),"o", Chr(0xD3),"o", Chr(0xD4),"o", Chr(0xD5),"o",
        Chr(0xD6),"o", Chr(0xD8),"o",
        Chr(0xD9),"u", Chr(0xDA),"u", Chr(0xDB),"u", Chr(0xDC),"u",
        Chr(0xDD),"y", Chr(0xDE),"th",
        Chr(0xDF),"ss",
        Chr(0xE0),"a", Chr(0xE1),"a", Chr(0xE2),"a", Chr(0xE3),"a",
        Chr(0xE4),"a", Chr(0xE5),"a", Chr(0xE6),"ae",
        Chr(0xE7),"c",
        Chr(0xE8),"e", Chr(0xE9),"e", Chr(0xEA),"e", Chr(0xEB),"e",
        Chr(0xEC),"i", Chr(0xED),"i", Chr(0xEE),"i", Chr(0xEF),"i",
        Chr(0xF0),"d", Chr(0xF1),"n",
        Chr(0xF2),"o", Chr(0xF3),"o", Chr(0xF4),"o", Chr(0xF5),"o",
        Chr(0xF6),"o", Chr(0xF8),"o",
        Chr(0xF9),"u", Chr(0xFA),"u", Chr(0xFB),"u", Chr(0xFC),"u",
        Chr(0xFD),"y", Chr(0xFE),"th", Chr(0xFF),"y",
        Chr(0x0102),"a", Chr(0x0103),"a",
        Chr(0x011E),"g", Chr(0x011F),"g",
        Chr(0x0130),"i", Chr(0x0131),"i",
        Chr(0x015E),"s", Chr(0x015F),"s",
        Chr(0x0160),"s", Chr(0x0161),"s",
        Chr(0x017D),"z", Chr(0x017E),"z"
    )

    ; Build ASCII version of replacement.
    stripped := ""
    Loop StrLen(replacement) {
        ch := SubStr(replacement, A_Index, 1)
        stripped .= accentMap.Has(ch) ? accentMap[ch] : ch
    }

    return (StrLower(stripped) = StrLower(trigger))
}

; ----------------------------------------------------------------
; Keyboard / phonetic single-character substitution detectors
; ----------------------------------------------------------------

IsKeyboardAdjacentSub(trigger, replacement) {
    ; Detects pairs where exactly one character was typed as a QWERTY
    ; keyboard neighbor of the intended character.
    ; Examples:  vuew -> view (r->e)   degault -> default (e->f... wait, d->e)
    ;            contect -> context (e->x)   evaluatioj -> evaluation (j->n)
    ;
    ; Only applies to single-word pairs and requires the two strings to be
    ; the same length with exactly one differing position.

    if InStr(trigger, " ") || InStr(replacement, " ")
        return false
    if StrLen(trigger) != StrLen(replacement)
        return false

    ; QWERTY adjacency — each key lists its horizontal/diagonal neighbors.
    adjacent := Map(
        "q","wa",   "w","qase",  "e","wsdr",  "r","edft",
        "t","rfgy", "y","tghu",  "u","yhji",  "i","ujko",
        "o","iklp", "p","ol",
        "a","qwsz", "s","awedxz","d","serfcx","f","drtgvc",
        "g","ftyhbv","h","gyujnb","j","huikmn","k","jiolm",
        "l","kop",
        "z","asx",  "x","zsdc",  "c","xdfv",  "v","cfgb",
        "b","vghn", "n","bhjm",  "m","njk"
    )

    diffCount := 0
    diffTc    := ""
    diffRc    := ""
    Loop StrLen(trigger) {
        tc := StrLower(SubStr(trigger,     A_Index, 1))
        rc := StrLower(SubStr(replacement, A_Index, 1))
        if (tc != rc) {
            diffCount++
            if (diffCount > 1)
                return false
            diffTc := tc
            diffRc := rc
        }
    }
    if (diffCount != 1)
        return false

    ; Check adjacency in both directions.
    return (adjacent.Has(diffTc) && InStr(adjacent[diffTc], diffRc))
        || (adjacent.Has(diffRc) && InStr(adjacent[diffRc], diffTc))
}

IsVowelConfusion(trigger, replacement) {
    ; Detects pairs where exactly one vowel was substituted for another vowel.
    ; This covers the very common "unstressed vowel" (schwa) errors where the
    ; correct vowel is phonetically ambiguous.
    ; Examples:  wrip -> wrap (i->a)   solotion -> solution (o->u)
    ;            condected -> conducted (e->u)   protty -> pretty (o->e)
    ;
    ; Requires single-word, same-length, exactly one differing position,
    ; and both the typed and correct characters must be vowels.

    if InStr(trigger, " ") || InStr(replacement, " ")
        return false
    if StrLen(trigger) != StrLen(replacement)
        return false

    vowels    := "aeiou"
    diffCount := 0
    Loop StrLen(trigger) {
        tc := StrLower(SubStr(trigger,     A_Index, 1))
        rc := StrLower(SubStr(replacement, A_Index, 1))
        if (tc != rc) {
            diffCount++
            if (diffCount > 1)
                return false
            if (!InStr(vowels, tc) || !InStr(vowels, rc))
                return false
        }
    }
    return (diffCount = 1)
}

IsPhoneticSub(trigger, replacement) {
    ; Detects pairs where a phonetically equivalent letter or digraph was
    ; substituted for the correct spelling.
    ; Examples:  cometimes -> sometimes (c->s at start)
    ;            chackbox -> checkbox (a->e vowel... wait that's vowel)
    ;            charaster -> character (s->c)   sould -> could (s->c)
    ;
    ; Checks a table of common phonetic equivalences by trying each
    ; substitution on the trigger and seeing if it produces the replacement.
    ; Requires single-word pairs only.

    if InStr(trigger, " ") || InStr(replacement, " ")
        return false

    ; Each pair is [typed_fragment, correct_fragment].
    ; Length-preserving subs come first (most reliable); length-changing
    ; subs (ck<->k, ll<->l, ph<->f, etc.) are checked after.
    phoneticPairs := [
        ; Consonant voicing confusion (typed->correct and correct->typed)
        ["p","b"],  ["b","p"],
        ["t","d"],  ["d","t"],
        ["k","g"],  ["g","k"],
        ["s","z"],  ["z","s"],
        ["f","v"],  ["v","f"],
        ["c","g"],  ["g","c"],
        ["c","s"],  ["s","c"],
        ["c","b"],  ["b","c"],
        ["d","g"],  ["g","d"],
        ; Digraph <-> single
        ["ph","f"], ["f","ph"],
        ["ck","k"], ["k","ck"],
        ["ss","s"], ["s","ss"],
        ["ll","l"], ["l","ll"],
        ["tt","t"], ["t","tt"],
        ["nn","n"], ["n","nn"],
        ; Vowel digraph alternates
        ["ee","ea"],["ea","ee"],
        ["ai","ay"],["ay","ai"],
        ["ei","ie"],["ie","ei"],
        ["ou","ow"],["ow","ou"],
        ; Vowel+r variations
        ["er","ur"],["ur","er"],
        ["er","or"],["or","er"],
        ; Miscellaneous
        ["i","y"],  ["y","i"],
        ["j","g"],  ["g","j"],
        ["an","en"],["en","an"],
        ["w","wh"], ["wh","w"]
    ]

    tLow := StrLower(trigger)
    rLow := StrLower(replacement)

    for pair in phoneticPairs {
        tf := pair[1], rf := pair[2]
        if InStr(tLow, tf) {
            candidate := StrReplace(tLow, tf, rf, , , 1)   ; replace first occurrence only
            if (candidate = rLow)
                return true
        }
    }
    return false
}

; ============================================================
; ACLog STATISTICS LOADER
; ============================================================

; Reads AutoCorrectsLog.txt and returns a Map of
; "trigger::replacement" -> {bs, ok} usage counts.
; Log line format (from HotstringLibStats):
;   positions 1-10  date/time
;   positions 12-13 action  (-- = kept,  << = backspaced)
;   position  15+   hotstring  (:opts:trigger::replacement)
LoadACLogStats(logPath) {
    result := Map()

    if !FileExist(logPath)
        return result

    ; Reuse the same hotstring regex as DefunctionizeText.
    hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<Comment>\h*;.*)?$"

    Loop Parse, FileRead(logPath, "UTF-8"), "`n", "`r" {
        line := A_LoopField
        if StrLen(line) < 15
            continue

        action     := SubStr(line, 12, 2)   ; "--" or "<<"
        hsFragment := SubStr(line, 15)

        if !RegExMatch(hsFragment, hsRegex, &m)
            continue

        trig := Trim(m.Trig)
        repl := Trim(Trim(m.Repl, '"'))
        if (trig = "" || repl = "")
            continue

        key := trig "::" repl
        if !result.Has(key)
            result[key] := {bs: 0, ok: 0}

        if (action = "--")
            result[key].ok++
        else if (action = "<<")
            result[key].bs++
    }
    return result
}
