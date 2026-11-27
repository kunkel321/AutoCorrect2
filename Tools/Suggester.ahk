/*
=====================================================
            HOTSTRING SUGGESTER TOOL
                Updated:  11-27-2026
=====================================================
Analyzes hotstrings and suggests lengthened/modified alternatives
that might be better matches. This standalone tool can be called
from ACLogAnalyzer or HotStringHelper2.

The tool takes a hotstring as input (either from command line or GUI),
analyzes the trigger and replacement against a word list, and suggests
alternative versions of the hotstring that might be more effective.

For example, analyzing a word-middle item like ":*?:cna::can" will find
strings that precede or follow "can" in real words, and suggest
hotstrings like ":*?:ecna::ecan" or ":*?:cnat::cant".

Tip: If UpdateClipboard = 1, the 'Send to HH' button is never needed.
Simply select an item, then activate HotStringHelper via hotkey #h.

Results window (11-19-2026):
  - Beg / End columns show the letter added to the trigger and replacement.
  - Check rows, then "Copy Checked" (clipboard) or "Append to Library"
    (asks first; skips triggers already in the library).  Both check the
    checked items against the library with ConflictingStringLocator's rules:
    Copy groups conflicting items at the bottom with "; CONFLICT" comments;
    Append lists them and lets you add all or only the clean ones.
    Conflicts with the original hotstring are expected, so they get one
    reminder to remove the original instead of a flag on every item.
  - Conf column: filled in when a row is checked (count of library
    conflicts, or "dup").  Right-click the cell for the details.  "f() format"
    makes :B0X...:trig::f("repl") items with a Web Freq / Fixes comment;
    unchecked makes plain :opts:trig::repl items.
  - Right-click a Fixes or MisSp cell to see the matching words
    (most frequent first).

Speed notes (11-18-2026):
The word list is held as ONE lowercase string ("`nword1`nword2`n...`n"),
and every lookup is a native InStr() for a pattern:
  whole word  -> "`nword`n"
  beginning   -> "`nword"
  ending      -> "word`n"
  middle      -> "word"
Unlike BulkFunctionizer (which processes hundreds of lines per run and so
can afford to build Map indexes up front), this tool is a fresh process for
each hotstring, so load time matters more than per-lookup time.
The frequency CSV is normalized with a few whole-file StrReplace calls, then
parsed in one light Loop Parse.
Web Freq = sum of the CSV frequencies of the word-list words the
replacement fixes -- the same way HotstringHelper and BulkFunctionizer do it.
Total time is shown in the results window title.
*/

#SingleInstance Force
#Requires AutoHotkey v2+
#Include "..\Includes\DpiKeepSize.ahk"   ; keeps its windows their size across monitors with different scales
SetWorkingDir(A_ScriptDir)

TraySetIcon("..\Resources\Icons\lightbulb-Blue.ico") ; icon for 'add new column'

; The big strings are GLOBALS on purpose.  Reading a string out of a class
; property can copy it, and a multi-MB copy per InStr() call is very slow.
global SG_Lower := ""   ; "`nword1`nword2`n...`n", lowercased
global SG_Orig  := ""   ; same text, original case (identical offsets)

; ======= Configuration =======
class Config {
    ; File paths
    static ScriptFiles := {
        ACScript: "..\Core\AutoCorrect2.ahk",
        HSLibrary: "..\Core\AutoCorrectHotstrings.ahk",
        WordListFile: "..\Data\ExamPaneWordList253k.txt",
        FreqDataFile: "..\Data\unigram_freq_list_filtered_102k.csv"
    }

    ; Behavior options
    static AutoCloseForm := 0       ; 0 = Keep form open after sending to HH, 1 = Auto-close
    static MaxSuggestions := 26     ; Maximum number of suggestions per type (beginning/ending)
    static UpdateClipboard := 1     ; When selecting list item, send it to clipboard
    static DefaultFuncFormat := 1   ; 1 = "f() format" box starts checked (:B0X...:trig::f("repl"))
    static TipMaxWords := 150       ; Right-click word lists: max words shown in the tooltip
    static EnableLogError := 0
    static EnableDebug := 0


    ; Visual properties (will be set during initialization)
    static FontColor := "Default"
    static ListColor := "Default"
    static FormColor := "Default"
    static RadioColor := "Blue"
    static ProgressColor := "c1b7706"

    ; Initialize settings and properties
    static Init() {
        this.LoadThemeSettings()

        ; Extract just the filename from the path
        SplitPath this.ScriptFiles.WordListFile, &WordListName
        this.WordListName := WordListName
    }

    ; Load visual theme settings
    static LoadThemeSettings() {
        try {
            if FileExist("..\Data\colorThemeSettings.ini") {
                settingsFile := "..\Data\colorThemeSettings.ini"
                ; Only overwrite the defaults when the INI actually has a value
                v := IniRead(settingsFile, "ColorSettings", "fontColor", "")
                if (v != "")
                    this.FontColor := v
                v := IniRead(settingsFile, "ColorSettings", "listColor", "")
                if (v != "")
                    this.ListColor := v
                v := IniRead(settingsFile, "ColorSettings", "formColor", "")
                if (v != "")
                    this.FormColor := v

                ; Calculate contrasting colors based on background brightness
                formColor := "0x" SubStr(this.FormColor, -6)
                r := (formColor >> 16) & 0xFF
                g := (formColor >> 8) & 0xFF
                b := formColor & 0xFF
                brightness := (r * 299 + g * 587 + b * 114) / 1000
                this.RadioColor := brightness > 128 ? "Blue" : "0x00FFFF"
                this.ProgressColor := brightness > 128 ? "c248d0c" : "c60fc3d"
            }
        } catch Error as err {
            LogError("Error loading theme settings: " err.Message)
            ; Default colors will be used
        }
    }
}

; ======= Main Class Definition =======
class HotstringSuggester {
    static SuggestGui := ""
    static ProgressGui := ""
    static LV := ""                 ; results ListView
    static FuncFormatCheck := ""    ; "f() format" checkbox
    static SuggestionByHs := Map()  ; ListView column-1 text -> suggestion object (survives sorting)
    static OriginalTrigger := ""    ; trigger of the hotstring being analyzed
    static Lib := 0                 ; cached parsed library {entries, origEntry}
    static WordListLoaded := false
    static StartTick := 0
    static ElapsedText := ""
    static CurrentHotstring := ""
    static Suggestions := []
    static WordListFile := ""
    static FreqDataFile := ""
    static WordFreqMap := Map()
    static CommonLetters := "etaoinsrhdlucmfywgpbvkjxqz" ; Most common letters in English
    static Config := {}
    static FreqDataLoaded := false

    ; Initialize the suggester with necessary settings
    static Init() {
        ; Set up configuration
        this.Config := Config

        ; Set word list path and frequency file path
        this.WordListFile := Config.ScriptFiles.WordListFile
        this.FreqDataFile := Config.ScriptFiles.FreqDataFile

        ; Step 1: try to obtain a hotstring from the command line.
        ; Only the *reading* of the hotstring is wrapped in try/catch. The analysis
        ; itself runs outside any try, so real errors surface instead of being
        ; swallowed and followed by an unexpected input form.
        hotstring := ""
        if A_Args.Length > 0 {
            Debug("Command line arguments received: " A_Args.Length)

            ; File-based parameter method
            if A_Args.Length >= 2 && A_Args[1] = "/fromfile" {
                Debug("Using file-based parameter method")
                tempFile := A_Args[2]
                if FileExist(tempFile) {
                    try {
                        hotstring := FileRead(tempFile)
                        Debug("Hotstring read from file: " hotstring)
                        try {
                            FileDelete(tempFile)
                            Debug("Temporary file deleted")
                        } catch {
                            Debug("Failed to delete temporary file")
                        }
                    } catch Error as err {
                        Debug("Error reading from temp file: " err.Message)
                        hotstring := ""
                    }
                } else {
                    Debug("Temp file not found: " tempFile)
                }
            }
            ; Standard parameter passing
            else if A_Args[1] != "" && A_Args[1] != "/fromfile" {
                hotstring := A_Args[1]
                Debug("Direct command line parameter: " hotstring)
            }
        }

        ; Step 2: analyze if we have a hotstring, otherwise ask for one.
        hotstring := Trim(hotstring, " `t`r`n")
        if (hotstring != "")
            this.AnalyzeHotstring(hotstring)
        else
            this.ShowInputForm()
    }

    ; Show the input form when no arguments are provided
    static ShowInputForm() {
        inputGui := Gui("", "Hotstring Suggester - Input")
        DpiKeepSize.Watch(inputGui)   ; keep its size across monitors with different scales
        inputGui.BackColor := this.Config.FormColor
        inputGui.SetFont("s12 " (this.Config.FontColor != "" ? "c" this.Config.FontColor : ""))

        inputGui.AddText("w400", "Enter a hotstring to analyze:")
        inputEdit := inputGui.AddEdit("w400 " (this.Config.ListColor != "" ? "Background" this.Config.ListColor : ""), "")
        inputEdit.Focus()

        analyzeBtn := inputGui.AddButton("w200", "Analyze")
        analyzeBtn.OnEvent("Click", (*) => (this.AnalyzeHotstring(inputEdit.Value), inputGui.Destroy()))

        cancelBtn := inputGui.AddButton("x+10 w190", "Cancel")
        cancelBtn.OnEvent("Click", (*) => ExitApp())

        inputGui.OnEvent("Escape", (*) => ExitApp())
        inputGui.OnEvent("Close", (*) => ExitApp())

        inputGui.Show("AutoSize")
    }

    ; Main method to analyze a hotstring and generate suggestions
    static AnalyzeHotstring(hotstring) {
        Debug("Analyzing hotstring: " hotstring)
        this.StartTick := A_TickCount

        ; Create a progress indicator - start at 0%
        progress := this._ShowSimpleProgress("Analyzing hotstring...",
            "Generating suggestions for " hotstring "`nThis may take a moment...")

        this.CurrentHotstring := hotstring
        this.Suggestions := []

        ; Update to 10% - Starting analysis
        progress.bar.Value := 10
        progress.gui.Title := "Loading word list..."

        if (!this.WordListLoaded) {
            t := A_TickCount
            this._LoadWordList()
            Debug("Word list load: " (A_TickCount - t) " ms")
        }

        ; Update to 20% - Loading frequency data
        progress.bar.Value := 20
        progress.gui.Title := "Loading frequency data..."

        if (!this.FreqDataLoaded) {
            t := A_TickCount
            this._LoadWordFrequencies(this.FreqDataFile)
            Debug("Freq data load: " (A_TickCount - t) " ms")
        }

        ; Update to 30% - Parsing hotstring
        progress.bar.Value := 30
        progress.gui.Title := "Parsing hotstring..."

        ; Parse the hotstring to extract components
        hsInfo := this._ParseHotstring(hotstring)

        ; Generate suggestions based on the hotstring type
        if (hsInfo) {
            ; Update to 60% - Generating suggestions
            progress.bar.Value := 60
            progress.gui.Title := "Analyzing letter patterns..."

            t := A_TickCount
            this._GenerateSuggestions(hsInfo, progress)
            Debug("Suggestions + metrics: " (A_TickCount - t) " ms")
            this.ElapsedText := Format("{:.1f}", (A_TickCount - this.StartTick) / 1000) " s"

            ; Update to 90% - Preparing dashboard
            progress.bar.Value := 90
            progress.gui.Title := "Preparing results..."

            ; Close progress window
            if progress && IsObject(progress.gui)
                progress.gui.Destroy()

            this._ShowSuggestionDashboard(hsInfo)
        } else {
            MsgBox("Could not parse the hotstring: " hotstring)
            if progress && IsObject(progress.gui)
                progress.gui.Destroy()
        }
    }

    ; Load word frequencies from CSV file (word,freq[,...]) — tolerant of headers/BOM/tabs/quotes.
    ; All normalizing (CR, tabs, quotes, case) is done once on the whole text with
    ; native calls, so the per-line loop does as little as possible.
    static _LoadWordFrequencies(filePath) {
        this.WordFreqMap := Map()
        this.FreqDataLoaded := false

        if !FileExist(filePath) {
            Debug("Frequency data file not found: " filePath)
            return false
        }

        wordCount := 0, duplicateCount := 0, skippedLines := 0
        try {
            txt := FileRead(filePath, "UTF-8")          ; a UTF-8 BOM is skipped automatically
            txt := StrReplace(txt, "`r")
            txt := StrReplace(txt, "`t", ",")           ; tab-delimited -> comma-delimited
            txt := StrReplace(txt, '"')                 ; drop CSV quoting
            txt := StrLower(txt)

            fm := this.WordFreqMap
            fm.Capacity := 120000                       ; avoid repeated re-growing
            Loop Parse, txt, "`n" {
                p := InStr(A_LoopField, ",")
                if !p {
                    if (A_LoopField != "")
                        skippedLines++
                    continue
                }
                word := Trim(SubStr(A_LoopField, 1, p - 1))
                freqStr := SubStr(A_LoopField, p + 1)
                if (q := InStr(freqStr, ","))           ; ignore any extra columns
                    freqStr := SubStr(freqStr, 1, q - 1)
                freqStr := Trim(freqStr)

                ; IsNumber() never throws — header rows / junk just get skipped
                if (word = "" || !IsNumber(freqStr)) {
                    skippedLines++
                    continue
                }

                if fm.Has(word) {
                    fm[word] += Number(freqStr)
                    duplicateCount++
                } else {
                    fm[word] := Number(freqStr)
                    wordCount++
                }
            }
        } catch Error as err {
            Debug("Error loading frequency data: " err.Message " (line " A_LineNumber ")")
            return false
        }

        Debug("Freq data loaded - Words: " wordCount ", Dups: " duplicateCount ", Skipped: " skippedLines)

        ; Don't claim success if nothing usable was read
        if (wordCount = 0) {
            LogError("Frequency file parsed but contained 0 usable rows: " filePath)
            return false
        }
        this.FreqDataLoaded := true
        return true
    }

    ; Parse the hotstring to extract options, trigger, and replacement
    static _ParseHotstring(hotstring) {
        ; Extract components using regex (handles both regular and function-based hotstrings)
        hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<fCom>\h*;\h*(?:\bFIXES\h*\d+\h*WORDS?\b)?(?:\h;)?\h*(?<mCom>.*))?$"

        if (RegExMatch(hotstring, hsRegex, &match)) {
            result := {
                options: StrReplace(match.Opts, 'B0X', ''),
                trigger: match.Trig,
                replacement: StrReplace(match.Repl, '"', ''),
                comment: match.mCom
            }

            ; Determine the type of hotstring based on options
            result.isBeginning := InStr(result.options, "*") && !InStr(result.options, "?")
            result.isEnding := !InStr(result.options, "*") && InStr(result.options, "?")
            result.isMiddle := InStr(result.options, "*") && InStr(result.options, "?")

            return result
        }
        return false
    }

    ; Load the word list as one big lowercase string (done once; very fast)
    static _LoadWordList() {
        global SG_Lower, SG_Orig
        if (!FileExist(this.WordListFile)) {
            MsgBox("Word list file not found: " this.WordListFile)
            return false
        }
        try {
            txt := StrReplace(FileRead(this.WordListFile, "UTF-8"), "`r")
            SG_Orig := "`n" Trim(txt, "`n") "`n"
            SG_Lower := StrLower(SG_Orig)
            this.WordListLoaded := true
            return true
        } catch Error as err {
            Debug("Error loading word list: " err.Message)
            return false
        }
    }

    ; Same radio logic HH uses: *? = middle, * = beginning, ? = ending, else whole word
    static _ModeFor(opts) {
        star := InStr(opts, "*")
        q := InStr(opts, "?")
        return (star && q) ? "mid" : star ? "begin" : q ? "end" : "whole"
    }

    ; Returns an Array of the word-list lines that match (case-insensitive).
    ; mode: whole|begin|end|mid
    ; Case-sensitive InStr on lowercased text = case-insensitive match, but faster.
    static _Matches(needle, mode) {
        global SG_Lower, SG_Orig
        out := []
        if (needle = "" || InStr(needle, "`n") || SG_Lower = "")
            return out
        nl := StrLower(needle)
        if (mode = "whole")
            pat := "`n" nl "`n"
        else if (mode = "begin")
            pat := "`n" nl
        else if (mode = "end")
            pat := nl "`n"
        else
            pat := nl
        lead := (mode = "whole" || mode = "begin")   ; pattern starts at the line's leading `n
        len := StrLen(SG_Lower)
        start := 1
        while (pos := InStr(SG_Lower, pat, true, start)) {
            if lead
                ls := pos + 1
            else {
                ; search right-to-left from pos-1 for the newline that starts this line
                nlPos := InStr(SG_Lower, "`n", true, pos - len - 2)
                ls := nlPos + 1
            }
            le := InStr(SG_Lower, "`n", true, ls)
            out.Push(SubStr(SG_Orig, ls, le - ls))
            start := le   ; next match must be on a later line
        }
        return out
    }

    ; Sum of the CSV frequencies for a list of words
    static _FreqSum(words) {
        total := 0
        for w in words {
            key := StrLower(w)
            if this.WordFreqMap.Has(key)
                total += this.WordFreqMap[key]
        }
        return total
    }

    ; Generate suggestions based on analysis
    static _GenerateSuggestions(hsInfo, progress := 0) {
        ; Check if this is a regular hotstring with no wildcards
        if (!hsInfo.isMiddle && !hsInfo.isBeginning && !hsInfo.isEnding) {
            MsgBox("This is a regular exact-match hotstring without wildcards. Suggestions aren't relevant in this case as the hotstring only matches one specific word.", "No Suggestions Available", 64)
            return
        }

        ; Update progress to 65% - Finding matches
        if (progress && IsObject(progress.bar))
            progress.bar.Value := 65, progress.gui.Title := "Finding words containing the replacement..."

        ; First, find actual words containing the replacement
        matchInfo := this._AnalyzeMatchingWords(hsInfo)

        ; Update progress to 75% - Generating suggestions
        if (progress && IsObject(progress.bar))
            progress.bar.Value := 75, progress.gui.Title := "Creating suggestions..."

        ; Create suggestions based on the match analysis
        this._CreateSuggestionsFromAnalysis(hsInfo, matchInfo)

        ; Add the original as reference
        this._AddOriginalAsSuggestion(hsInfo)

        ; Update progress to 85% - Calculating metrics
        if (progress && IsObject(progress.bar))
            progress.bar.Value := 85, progress.gui.Title := "Calculating fixes, web frequencies, misspellings..."

        ; Fixes, Web Freq and MisSp for every suggestion, in one indexed pass
        this._CalculateMetricsForSuggestions()
    }

    ; Find the words that contain the replacement and tally the letters around it
    static _AnalyzeMatchingWords(hsInfo) {
        matchInfo := {
            words: [],             ; Words containing the replacement
            preceding: Map(),      ; Letter -> how many matches it precedes the replacement in
            following: Map()       ; Letter -> how many matches it follows the replacement in
        }

        lcRepl := StrLower(hsInfo.replacement)
        rLen := StrLen(lcRepl)
        mode := this._ModeFor(hsInfo.options)
        Debug("Analyzing matching words for replacement: " lcRepl " (mode: " mode ")")

        matchInfo.words := this._Matches(lcRepl, mode)

        for word in matchInfo.words {
            lcWord := StrLower(word)
            if (mode = "mid") {
                ; Every occurrence can be extended on either side
                pos := 1
                while (pos := InStr(lcWord, lcRepl, true, pos)) {
                    this._TallyLetter(matchInfo.preceding, lcWord, pos - 1)
                    this._TallyLetter(matchInfo.following, lcWord, pos + rLen)
                    pos += rLen
                }
            }
            else if (mode = "end")
                ; Only the occurrence at the end of the word counts
                this._TallyLetter(matchInfo.preceding, lcWord, StrLen(lcWord) - rLen)
            else if (mode = "begin")
                ; Only the occurrence at the start of the word counts
                this._TallyLetter(matchInfo.following, lcWord, rLen + 1)
        }

        Debug("Total matching words found: " matchInfo.words.Length)
        Debug("Preceding letters: " this._MapToString(matchInfo.preceding))
        Debug("Following letters: " this._MapToString(matchInfo.following))

        return matchInfo
    }

    ; Count the letter at position pos of lcWord (ignores out-of-range and non-letters)
    static _TallyLetter(tally, lcWord, pos) {
        if (pos < 1 || pos > StrLen(lcWord))
            return
        ch := SubStr(lcWord, pos, 1)
        if (ch ~= "^[a-z]$")
            tally[ch] := tally.Has(ch) ? tally[ch] + 1 : 1
    }

    ; Create suggestions based on analysis
    static _CreateSuggestionsFromAnalysis(hsInfo, matchInfo) {
        ; Create suggestions from preceding letters (for middle/ending hotstrings)
        if (hsInfo.isMiddle || hsInfo.isEnding)
            this._CreateLetterSuggestions(hsInfo, matchInfo.preceding, true)

        ; Create suggestions from following letters (for middle/beginning hotstrings)
        if (hsInfo.isMiddle || hsInfo.isBeginning)
            this._CreateLetterSuggestions(hsInfo, matchInfo.following, false)
    }

    ; Create suggestions by adding a letter to the beginning (atStart) or end
    static _CreateLetterSuggestions(hsInfo, letters, atStart) {
        count := 0
        for letter, frequency in letters {
            if (frequency < 1)
                continue
            newTrigger := atStart ? letter . hsInfo.trigger : hsInfo.trigger . letter
            newReplacement := atStart ? letter . hsInfo.replacement : hsInfo.replacement . letter

            this.Suggestions.Push({
                options: hsInfo.options,
                trigger: newTrigger,
                replacement: newReplacement,
                begLetter: atStart ? letter : "",
                endLetter: atStart ? "" : letter,
                fixCount: frequency,   ; Replaced by the real word count later
                hotstring: ":" hsInfo.options ":" newTrigger "::" newReplacement,
                webFrequency: 0,       ; Will be calculated later
                misCount: 0            ; Will be calculated later
            })

            count++
            if (count >= this.Config.MaxSuggestions)
                break
        }
    }

    ; Add the original hotstring as a reference suggestion
    static _AddOriginalAsSuggestion(hsInfo) {
        this.OriginalTrigger := hsInfo.trigger
        this.Suggestions.Push({
            options: hsInfo.options,
            trigger: hsInfo.trigger,
            replacement: hsInfo.replacement,
            begLetter: "",
            endLetter: "",
            fixCount: 0,      ; Will be calculated later
            hotstring: ":" hsInfo.options ":" hsInfo.trigger "::" hsInfo.replacement,
            webFrequency: 0,  ; Will be calculated later
            misCount: 0       ; Will be calculated later
        })
    }

    ; Fixes, Web Freq and MisSp for every suggestion.
    ;   Fixes    = word-list words the replacement matches (HH's "Fixes n words")
    ;   Web Freq = summed CSV frequency of those same words (HH's "Web Freq")
    ;   MisSp    = word-list words the trigger matches (real words it would break)
    static _CalculateMetricsForSuggestions() {
        if (!this.FreqDataLoaded)
            Debug("Frequency data not loaded, Web Freq will be 0")
        for suggestion in this.Suggestions {
            mode := this._ModeFor(suggestion.options)
            fixes := this._Matches(suggestion.replacement, mode)
            suggestion.fixCount := fixes.Length
            suggestion.webFrequency := this.FreqDataLoaded ? this._FreqSum(fixes) : 0
            suggestion.misCount := this._Matches(suggestion.trigger, mode).Length
        }
    }

    ; Helper method to convert a Map to a string for debugging
    static _MapToString(map) {
        result := ""
        for key, value in map
            result .= key . ":" . value . ", "
        return RTrim(result, ", ")
    }

    ; Find matches for a word pattern based on options (indexed lookup)
    static _FindMatches(word, options) {
        return this._Matches(word, this._ModeFor(options))
    }

    ; Format web frequency for display
    static _FormatWebFrequency(freq) {
        ; Return 0 if frequency is 0
        if (freq = 0)
            return "0"

        ; Format in millions with 2 decimal places
        return Format("{:.2f}m", freq / 1000000)
    }

    ; Show a simple progress dialog
    static _ShowSimpleProgress(title, message := "Processing...") {
        ; Create a simple progress GUI
        progressGui := Gui("+AlwaysOnTop -MinimizeBox -SysMenu")

        ; Use theme colors
        progressGui.BackColor := this.Config.FormColor
        progressGui.SetFont("s12 " (this.Config.FontColor != "" ? "c" this.Config.FontColor : ""))
        progressGui.Title := title

        progressGui.Add("Text", "w300 Center", message)

        ; Use theme color for progress bar
        progressBar := progressGui.Add("Progress", "w300 h20 c" this.Config.ProgressColor " Background" this.Config.FormColor " Range0-100", 0)

        progressGui.Show("AutoSize")

        return {gui: progressGui, bar: progressBar}
    }

    ; Show the suggestion dashboard with results
    static _ShowSuggestionDashboard(hsInfo) {
        ; Create new suggestion window
        this.SuggestGui := Gui("+AlwaysOnTop", "Hotstring Suggester - Results"
            . (this.ElapsedText != "" ? "   (" this.ElapsedText ")" : ""))
        DpiKeepSize.Watch(this.SuggestGui)   ; keep its size across monitors with different scales
        this.SuggestGui.SetFont("s12 " (this.Config.FontColor != "" ? "c" this.Config.FontColor : ""))
        this.SuggestGui.BackColor := this.Config.FormColor

        ; Add "Keep window on top" checkbox at the top
        keepOnTopCheck := this.SuggestGui.Add("Checkbox", "xm y10 Checked", "Keep window on top")
        keepOnTopCheck.OnEvent("Click", (*) => this._ToggleAlwaysOnTop(keepOnTopCheck))

        totalWidth := 720

        ; Title and original hotstring info - adjusted width to match ListView
        this.SuggestGui.Add("Text", "y+10 w" totalWidth, "Original hotstring: [ " . this.CurrentHotstring
                                            " ]    Type: " . (hsInfo.isMiddle ? "Word-Middle" :
                                            hsInfo.isBeginning ? "Word-Beginning" :
                                            hsInfo.isEnding ? "Word-Ending" : "Regular"))

        ; Checkboxes appear at the left of column 1.  Right-click a Fixes or MisSp
        ; cell to see the matching words.
        columnHeaders := ["Suggestion", "Beg", "End", "Fixes", "Web Freq", "MisSp", "Conf"]
        listViewOpts := "w" totalWidth " r20 Grid Checked"
        if (this.Config.ListColor != "")
            listViewOpts .= " Background" this.Config.ListColor

        listView := this.SuggestGui.Add("ListView", listViewOpts, columnHeaders)
        this.LV := listView

        ; Set column widths
        listView.ModifyCol(1, 225)          ; Suggestion (incl. checkbox)
        listView.ModifyCol(2, "55 Center")  ; Beg
        listView.ModifyCol(3, "55 Center")  ; End
        listView.ModifyCol(4, 85)           ; Fixes
        listView.ModifyCol(5, 115)          ; Web Frequency
        listView.ModifyCol(6, 80)           ; Misspellings (MisSp)
        listView.ModifyCol(7, 75)           ; Conflicts -- filled in when a row is checked

        ; Populate the ListView
        this.SuggestionByHs := Map()
        for idx, suggestion in this.Suggestions {
            this.SuggestionByHs[suggestion.hotstring] := suggestion
            listView.Add(,
                suggestion.hotstring,
                suggestion.begLetter,
                suggestion.endLetter,
                suggestion.fixCount,
                this._FormatWebFrequency(suggestion.webFrequency),
                suggestion.misCount
            )
        }

        ; Set numeric sort for columns
        listView.ModifyCol(4, "Integer")  ; Fixes
        listView.ModifyCol(5, "Float")    ; Web Freq
        listView.ModifyCol(6, "Integer")  ; MisSp
        listView.ModifyCol(7, "Integer")  ; Conf ("dup" sorts as 0)

        ; Selected suggestion
        this.SuggestGui.Add("Text", "xm y+10 w85", "Selected:")
        editOpts := "x+10 ReadOnly w625"
        if (this.Config.ListColor != "")
            editOpts .= " Background" this.Config.ListColor
        selectedHs := this.SuggestGui.Add("Edit", editOpts, "")

        ; Bulk actions for checked rows
        this.FuncFormatCheck := this.SuggestGui.Add("Checkbox", "xm y+14 " (this.Config.DefaultFuncFormat ? "Checked" : ""), 'f() format')
        copyBtn := this.SuggestGui.Add("Button", "x+18 yp-5 w165", "&Copy Checked")
        copyBtn.OnEvent("Click", (*) => this._CopyChecked())
        appendBtn := this.SuggestGui.Add("Button", "x+10 w185", "&Append to Library")
        appendBtn.OnEvent("Click", (*) => this._AppendChecked())
        closeButton := this.SuggestGui.Add("Button", "x+10 w100", "Close")
        closeButton.OnEvent("Click", this._CloseGuiHandler.Bind(this))

        ; Update selected hotstring when item is selected
        listView.OnEvent("ItemSelect", this._ItemSelectHandler.Bind(this, listView, selectedHs))

        ; Double-click behavior - just select the item
        listView.OnEvent("DoubleClick", this._DoubleClickHandler.Bind(this, listView))

        ; Right-click a Fixes / MisSp cell -> tooltip with the matching words
        listView.OnEvent("ContextMenu", (ctrl, *) => this._ContextMenuHandler(ctrl))

        ; Checking a row fills in its Conf cell (library parsed once, on the first check)
        listView.OnEvent("ItemCheck", (ctrl, item, checked) => this._ItemCheckHandler(ctrl, item, checked))
        this.Lib := 0

        ; Left click anywhere on the window closes the word-list tooltip
        OnMessage(0x0201, ObjBindMethod(this, "_OnLeftClick"))   ; WM_LBUTTONDOWN
        OnMessage(0x00A1, ObjBindMethod(this, "_OnLeftClick"))   ; WM_NCLBUTTONDOWN (title bar)

        ; Show the GUI
        this.SuggestGui.Show("AutoSize")

        ; Select the first item by default
        if (this.Suggestions.Length > 0) {
            listView.Modify(1, "Select Focus")
            selectedHs.Value := this.Suggestions[1].hotstring
        }
    }

    ; ---------- Bulk actions ----------

    ; Suggestion objects for all checked rows, in their current (sorted) order
    static _GetCheckedSuggestions() {
        out := []
        row := 0
        while (row := this.LV.GetNext(row, "Checked")) {
            hs := this.LV.GetText(row, 1)
            if this.SuggestionByHs.Has(hs)
                out.Push(this.SuggestionByHs[hs])
        }
        return out
    }

    ; Build the hotstring text for one suggestion in the chosen format
    ;   plain: :C*?:trig::repl
    ;   f():   :B0XC*?:trig::f("repl") ; Web Freq 12.34 | Fixes 56 words
    static _BuildHotstring(s, funcFormat) {
        if !funcFormat
            return ":" s.options ":" s.trigger "::" s.replacement
        opts := "B0X" StrReplace(StrReplace(s.options, "B0", ""), "X", "")
        repl := StrReplace(s.replacement, '"', '``"')
        freqF := Format("{:.2f}", s.webFrequency / 1000000)
        comment := (freqF != "0.00" ? "Web Freq " freqF " | " : "")
            . "Fixes " s.fixCount (s.fixCount = 1 ? " word" : " words")
        return ":" opts ":" s.trigger '::f("' repl '")' " `; " comment
    }

    static _CopyChecked() {
        items := this._GetCheckedSuggestions()
        if !items.Length {
            this._Tip("No rows are checked.")
            return
        }
        r := this._CheckForConflicts(items)
        if !IsObject(r)
            return
        fmt := this.FuncFormatCheck.Value
        lines := []

        if (r.origEntry && (r.clean.Length || r.conflicted.Length))
            lines.Push(this._OriginalNote(r.origEntry))
        for s in r.clean
            lines.Push(this._BuildHotstring(s, fmt))
        if r.conflicted.Length {
            lines.Push("")
            lines.Push("; ===== CONFLICTS (" r.conflicted.Length ") -- check before using =====")
            for c in r.conflicted {
                for i, k in c.conflicts {
                    if (i > 3) {
                        lines.Push("; ...and " (c.conflicts.Length - 3) " more conflicts")
                        break
                    }
                    lines.Push("; CONFLICT (" k.kind ") with " this._DescribeEntry(k.e))
                }
                lines.Push(this._BuildHotstring(c.s, fmt))
            }
        }
        if r.dupes.Length {
            lines.Push("")
            lines.Push("; Skipped (trigger already in library): " this._Join(r.dupes, ", "))
        }

        txt := ""
        for line in lines
            txt .= line "`r`n"
        A_Clipboard := RTrim(txt, "`r`n")
        n := r.clean.Length + r.conflicted.Length
        this._Tip("Copied " n " hotstring" (n = 1 ? "" : "s") " to clipboard"
            . (r.conflicted.Length ? " (" r.conflicted.Length " with conflicts, grouped at bottom)" : "") ".")
    }

    static _AppendChecked() {
        items := this._GetCheckedSuggestions()
        if !items.Length {
            this._Tip("No rows are checked.")
            return
        }
        r := this._CheckForConflicts(items)
        if !IsObject(r)
            return
        libFile := this.Config.ScriptFiles.HSLibrary
        owner := " Owner" this.SuggestGui.Hwnd
        fmt := this.FuncFormatCheck.Value
        nClean := r.clean.Length, nConf := r.conflicted.Length

        dupNote := r.dupes.Length ? "Skipped (trigger already in library): " this._Join(r.dupes, ", ") : ""
        if (nClean + nConf = 0) {
            MsgBox(dupNote, "Hotstring Suggester", "Icon!" owner)
            return
        }

        msg := ""
        if nClean {
            msg .= "No conflicts (" nClean "):`n"
            for i, s in r.clean {
                if (i > 15) {
                    msg .= "   ... and " (nClean - 15) " more`n"
                    break
                }
                msg .= "   " this._BuildHotstring(s, 0) "`n"
            }
            msg .= "`n"
        }
        if nConf {
            msg .= "CONFLICTS (" nConf "):`n"
            for i, c in r.conflicted {
                if (i > 15) {
                    msg .= "   ... and " (nConf - 15) " more`n"
                    break
                }
                k := c.conflicts[1]
                msg .= "   " this._BuildHotstring(c.s, 0) "   -- " k.kind " with " this._DescribeEntry(k.e)
                    . (c.conflicts.Length > 1 ? "  (+" (c.conflicts.Length - 1) " more)" : "") "`n"
            }
            msg .= "`n"
        }
        if (dupNote != "")
            msg .= dupNote "`n`n"
        if r.origEntry
            msg .= "REMINDER: The original is still in the library (line " r.origEntry.line "):`n   "
                . SubStr(r.origEntry.text, 1, 90) "`nRemove or comment it out, or the new items won't fire.`n`n"

        if nConf {
            msg .= "Yes = append all " (nClean + nConf) "`n"
                . "No = append only the " nClean " without conflicts`n"
                . "Cancel = append nothing"
            ans := MsgBox(msg, "Hotstring Suggester - Append to Library", "YesNoCancel Icon!" owner)
            if (ans = "Cancel" || (ans = "No" && !nClean))
                return
            toAdd := r.clean.Clone()
            if (ans = "Yes")
                for c in r.conflicted
                    toAdd.Push(c.s)
        } else {
            msg .= "Append " nClean " hotstring" (nClean = 1 ? "" : "s") " to " libFile "?"
            if (MsgBox(msg, "Hotstring Suggester - Append to Library", "YesNo Icon?" owner) != "Yes")
                return
            toAdd := r.clean
        }

        ; Only the hotstring lines go into the library -- flags would turn into
        ; stale clutter once the conflicts are dealt with.
        txt := ""
        for s in toAdd
            txt .= "`n" this._BuildHotstring(s, fmt)
        try {
            FileAppend(txt, libFile, "UTF-8")
            this.Lib := 0                       ; library changed -- re-parse on next use
            for s in toAdd
                this._SetConfCell(s, "added")
            this._Tip("Appended " toAdd.Length " hotstring" (toAdd.Length = 1 ? "" : "s")
                . ".  Reload AutoCorrect2 to activate.")
        } catch Error as err {
            MsgBox("Couldn't append to the library:`n" err.Message, "Hotstring Suggester", "Iconx" owner)
        }
    }

    ; ---------- Conflict checking (same rules as ConflictingStringLocator) ----------

    ; Sorts checked suggestions into:
    ;   dupes      -- triggers already in the library (never exported)
    ;   conflicted -- [{s, conflicts: [{kind, e}]}] vs. the library and the other checked items
    ;   clean      -- everything else
    ;   origEntry  -- the library line holding the original hotstring, or 0.
    ;                 Every suggestion is built from the original, so conflicts with it
    ;                 are expected: they're left out of the per-item lists and covered by
    ;                 one reminder instead.
    ; Returns 0 if the library can't be read.
    static _CheckForConflicts(items) {
        lib := this._GetLibrary(true)          ; fresh read at export time
        if !IsObject(lib)
            return 0
        origT := StrLower(this.OriginalTrigger)

        ; Checked items also count as "existing" for each other
        newEntries := []
        for s in items
            newEntries.Push({opts: s.options, trig: s.trigger, line: 0, text: this._BuildHotstring(s, 0), s: s})

        r := {clean: [], conflicted: [], dupes: [], origEntry: lib.origEntry}
        for s in items {
            res := this._LibraryConflicts(s, lib)
            this._StoreConf(s, res)            ; keep the Conf column in step
            if res.dup {
                r.dupes.Push(s.trigger)
                continue
            }
            conflicts := res.conflicts.Clone()
            sT := StrLower(s.trigger)
            for e in newEntries {
                if (e.s = s)
                    continue
                ; the original vs. its own derivatives is the expected case -- never flag it
                if (sT = origT || StrLower(e.trig) = origT)
                    continue
                if (kind := this._ConflictKind(s.options, s.trigger, e.opts, e.trig)) != ""
                    conflicts.Push({kind: kind, e: e})
            }
            if conflicts.Length
                r.conflicted.Push({s: s, conflicts: conflicts})
            else
                r.clean.Push(s)
        }
        return r
    }

    ; Parsed library, cached: {entries, origEntry}.  fresh = re-read the file.
    ; Returns 0 (after a message) if the library can't be found.
    static _GetLibrary(fresh := false) {
        if (!fresh && IsObject(this.Lib))
            return this.Lib
        libFile := this.Config.ScriptFiles.HSLibrary
        if !FileExist(libFile) {
            MsgBox("Hotstring library not found:`n" libFile, "Hotstring Suggester", "Icon! Owner" this.SuggestGui.Hwnd)
            return 0
        }
        entries := this._LoadLibraryEntries(libFile)
        origT := StrLower(this.OriginalTrigger)
        origEntry := 0
        for e in entries
            if (StrLower(e.trig) = origT) {
                origEntry := e
                break
            }
        this.Lib := {entries: entries, origEntry: origEntry}
        return this.Lib
    }

    ; One suggestion vs. the library: {dup, conflicts: [{kind, e}]}.
    ; Conflicts with the original's own library line are expected and left out.
    static _LibraryConflicts(s, lib) {
        sT := StrLower(s.trigger)
        origT := StrLower(this.OriginalTrigger)
        conflicts := []
        for e in lib.entries {
            eT := StrLower(e.trig)
            if (eT = sT)
                return {dup: true, conflicts: []}
            if (lib.origEntry && eT = origT)
                continue
            if (kind := this._ConflictKind(s.options, s.trigger, e.opts, e.trig)) != ""
                conflicts.Push({kind: kind, e: e})
        }
        return {dup: false, conflicts: conflicts}
    }

    ; ---------- Conf column ----------

    ; Critical: clicks queue up and run one at a time, so rows never interleave.
    static _ItemCheckHandler(lv, item, checked) {
        Critical
        if !checked || item < 1
            return
        hs := lv.GetText(item, 1)
        if !this.SuggestionByHs.Has(hs)
            return
        s := this.SuggestionByHs[hs]
        if s.HasOwnProp("conf")
            return                              ; already calculated
        lib := this._GetLibrary()
        if IsObject(lib)
            this._StoreConf(s, this._LibraryConflicts(s, lib), item)
    }

    ; Remember a result on the suggestion and show it in its Conf cell
    static _StoreConf(s, res, row := 0) {
        s.conf := res
        this._SetConfCell(s, res.dup ? "dup" : res.conflicts.Length, row)
    }

    ; Write a Conf cell, finding the row by its hotstring text if not given
    static _SetConfCell(s, value, row := 0) {
        if !row {
            Loop this.LV.GetCount()
                if (this.LV.GetText(A_Index, 1) == s.hotstring) {
                    row := A_Index
                    break
                }
        }
        if row
            this.LV.Modify(row, "Col7", value)
    }

    static _ShowConflictTip(s) {
        if !s.HasOwnProp("conf") {
            lib := this._GetLibrary()
            if !IsObject(lib)
                return
            this._StoreConf(s, this._LibraryConflicts(s, lib))
        }
        res := s.conf
        txt := "Conflicts for " s.hotstring "`n`n"
        if res.dup
            txt .= "Trigger '" s.trigger "' is already in the library -- it will be skipped."
        else if !res.conflicts.Length
            txt .= "No conflicts with the library."
        else {
            for i, k in res.conflicts {
                if (i > 25) {
                    txt .= "... and " (res.conflicts.Length - 25) " more`n"
                    break
                }
                txt .= k.kind " -- " this._DescribeEntry(k.e) "`n"
            }
        }
        if (this.Lib && this.Lib.origEntry && !res.dup)
            txt .= "`n(Not counted: the original, library line " this.Lib.origEntry.line ")"
        this._Tip(RTrim(txt, "`n"), 0)
    }

    ; Conflict type between a new item (nOpts/nTrig) and an existing one, or "".
    ; Mirrors ConflictingStringLocator's checks 2-5 (exact trigger matches are
    ; handled as duplicates before this is called).
    static _ConflictKind(nOpts, nTrig, eOpts, eTrig) {
        nT := StrLower(nTrig), eT := StrLower(eTrig)
        if (nT = eT) {
            ; Same trigger: a beginning and an ending item can coexist
            if (InStr(nOpts, "*") && InStr(eOpts, "?") && !InStr(nOpts, "?") && !InStr(eOpts, "*"))
            || (InStr(nOpts, "?") && InStr(eOpts, "*") && !InStr(nOpts, "*") && !InStr(eOpts, "?"))
                return ""
            return "same trigger"
        }
        nMid := InStr(nOpts, "*") && InStr(nOpts, "?")
        eMid := InStr(eOpts, "*") && InStr(eOpts, "?")
        if (eMid && InStr(nT, eT)) || (nMid && InStr(eT, nT))
            return "word-middle"
        if (InStr(eOpts, "*") && SubStr(nT, 1, StrLen(eT)) = eT)
        || (InStr(nOpts, "*") && SubStr(eT, 1, StrLen(nT)) = nT)
            return "word-beginning"
        if (InStr(eOpts, "?") && SubStr(nT, -StrLen(eT)) = eT)
        || (InStr(nOpts, "?") && SubStr(eT, -StrLen(nT)) = nT)
            return "word-ending"
        return ""
    }

    ; Every hotstring line in the library: [{opts, trig, line, text}].
    ; Skips /* ... */ block comments.
    static _LoadLibraryEntries(libFile) {
        entries := []
        inBlock := false
        Loop Parse, FileRead(libFile, "UTF-8"), "`n", "`r" {
            t := LTrim(A_LoopField, " `t")
            if inBlock {
                if InStr(t, "*/")
                    inBlock := false
                continue
            }
            if (SubStr(t, 1, 2) = "/*") {
                inBlock := !InStr(t, "*/")
                continue
            }
            if (SubStr(t, 1, 1) != ":")
                continue
            if RegExMatch(t, "^:(?<Opts>[^:\v]*):(?<Trig>[^:\v]+)::", &m)
                entries.Push({opts: m.Opts, trig: m.Trig, line: A_Index, text: RTrim(t, " `t")})
        }
        return entries
    }

    static _DescribeEntry(e) {
        txt := SubStr(e.text, 1, 90) (StrLen(e.text) > 90 ? "..." : "")
        return e.line ? "line " e.line ": " txt : "checked item " txt
    }

    static _OriginalNote(e) {
        return "; NOTE: These replace the original (library line " e.line "): " SubStr(e.text, 1, 90)
            . "  -- remove or comment it out, or these won't fire."
    }

    ; ---------- Right-click word lists ----------

    static _ContextMenuHandler(lv) {
        col := this._HitTestSubItem(lv, &row)
        if (row < 1 || (col != 4 && col != 6 && col != 7))   ; 4 = Fixes, 6 = MisSp, 7 = Conf
            return
        hs := lv.GetText(row, 1)
        if !this.SuggestionByHs.Has(hs)
            return
        s := this.SuggestionByHs[hs]
        mode := this._ModeFor(s.options)
        if (col = 7) {
            this._ShowConflictTip(s)
            return
        }
        if (col = 4)
            this._ShowWordListTip("Fixes for '" s.replacement "'", this._Matches(s.replacement, mode))
        else
            this._ShowWordListTip("Real words matching trigger '" s.trigger "'", this._Matches(s.trigger, mode))
    }

    ; Row and column (both 1-based) under the mouse in a ListView
    static _HitTestSubItem(lv, &row) {
        pt := Buffer(8, 0)
        DllCall("GetCursorPos", "Ptr", pt)
        DllCall("ScreenToClient", "Ptr", lv.Hwnd, "Ptr", pt)
        hti := Buffer(24, 0)   ; LVHITTESTINFO: pt, flags, iItem, iSubItem, iGroup
        NumPut("Int", NumGet(pt, 0, "Int"), "Int", NumGet(pt, 4, "Int"), hti, 0)
        SendMessage(0x1039, 0, hti.Ptr, lv)   ; LVM_SUBITEMHITTEST
        row := NumGet(hti, 12, "Int") + 1
        return NumGet(hti, 16, "Int") + 1
    }

    ; Words sorted most-frequent first, shown several per line, capped at TipMaxWords
    static _ShowWordListTip(title, words) {
        words := this._SortByFreq(words)
        maxShow := this.Config.TipMaxWords
        perLine := 6
        txt := title " -- " words.Length " word" (words.Length = 1 ? "" : "s")
            . (words.Length > 1 ? ", most frequent first" : "") "`n`n"
        if !words.Length
            txt .= "(none)"
        Loop Min(words.Length, maxShow)
            txt .= words[A_Index] (Mod(A_Index, perLine) ? ",  " : "`n")
        txt := RTrim(txt, ", `n")
        if (words.Length > maxShow)
            txt .= "`n... and " (words.Length - maxShow) " more"
        this._Tip(txt, 0)   ; no timeout -- a left click on the form closes it
    }

    static _SortByFreq(words) {
        if (words.Length < 2)
            return words
        s := ""
        for w in words
            s .= this.WordFreqMap.Get(StrLower(w), 0) "`t" w "`n"
        s := Sort(RTrim(s, "`n"), "N R")
        out := []
        Loop Parse, s, "`n"
            out.Push(SubStr(A_LoopField, InStr(A_LoopField, "`t") + 1))
        return out
    }

    ; Show a tooltip.  ms > 0: clears itself after ms.  ms = 0: stays until a
    ; left click on the results window (or the next tooltip) closes it.
    ; Either way, a new tip cancels any pending timer from an older one.
    static _Tip(text, ms := 3000) {
        static tipOff := ToolTip.Bind()
        SetTimer(tipOff, 0)
        ToolTip(text)
        if (ms > 0)
            SetTimer(tipOff, -ms)
    }

    ; WM_LBUTTONDOWN / WM_NCLBUTTONDOWN: any left click on the results window
    ; (client area, any control, or title bar) closes the current tooltip.
    ; Returns nothing, so the click is still handled normally.
    static _OnLeftClick(wParam, lParam, msg, hwnd) {
        if !this.SuggestGui
            return
        g := this.SuggestGui.Hwnd
        if (hwnd = g || DllCall("IsChild", "Ptr", g, "Ptr", hwnd))
            ToolTip()
    }

    static _Join(arr, sep) {
        out := ""
        for i, v in arr
            out .= (i > 1 ? sep : "") v
        return out
    }

    ; Toggle the always on top status of the window
    static _ToggleAlwaysOnTop(checkControl) {
        if checkControl.Value = 1
            WinSetAlwaysOnTop(1, this.SuggestGui)
        else
            WinSetAlwaysOnTop(0, this.SuggestGui)
    }

    static _CloseGuiHandler(*) {
        this.SuggestGui.Hide()  ; Hide instead of destroy
        ExitApp()
    }

    static _ItemSelectHandler(listView, selectedHs, ctrl, *) {
        rowNum := ctrl.GetNext()
        if (rowNum > 0) {
            ; Get the hotstring value directly from the ListView row
            selectedHs.Value := listView.GetText(rowNum, 1)  ; Column 1 contains the hotstring
            If (Config.UpdateClipboard = 1)
                A_Clipboard := selectedHs.Value
        }
    }

    static _DoubleClickHandler(listView, ctrl, *) {
        rowNum := ctrl.GetNext()
        if (rowNum > 0) {
            ; Get the hotstring value directly from the ListView row
            hotstring := listView.GetText(rowNum, 1)  ; Column 1 contains the hotstring

            ; Just make sure it's selected and in the clipboard
            listView.Modify(rowNum, "Select Focus")
            If (Config.UpdateClipboard = 1)
                A_Clipboard := hotstring
        }
    }

    static _SendToHotStringHelper(hotstring) {
        if (!hotstring)
            return

        ; Try different approaches to get the script name
        myACFileBaseName := ""
        try {
            ; Default to "AutoCorrect2" which is the standard name
            myACFileBaseName := "AutoCorrect2"

            ; Check if the file exists
            if (!FileExist(myACFileBaseName . ".exe")) {
                MsgBox("Error: " myACFileBaseName ".exe not found in the current directory.")
                return
            }

            Run(myACFileBaseName ".exe /script " this.Config.ScriptFiles.ACScript " " hotstring)

            ; Only exit if AutoCloseForm is enabled
            if (this.Config.AutoCloseForm)
                ExitApp()
        } catch Error as err {
            Debug("Error sending to HotString Helper: " err.Message)
            MsgBox("Error sending to HotString Helper: " err.Message)
        }
    }

    ; Handler for max suggestions dropdown
    static _MaxSuggestionsHandler(ctrl, *) {
        value := ctrl.Text

        ; If "All" is selected, set to a large number (99) to effectively show all
        if (value = "All")
            this.Config.MaxSuggestions := 99
        else
            this.Config.MaxSuggestions := Integer(value)

        ; Reanalyze the current hotstring with the new setting
        if (this.CurrentHotstring != "") {
            ; Close the current GUI
            this.SuggestGui.Hide()

            ; Reanalyze with new setting
            this.AnalyzeHotstring(this.CurrentHotstring)
        }
    }

    ; Copy the selected suggestion to clipboard
    static _CopyToClipboard(hotstring) {
        if (!hotstring)
            return

        A_Clipboard := hotstring
        ToolTip("Copied to clipboard!")

        ; Use anonymous function for timer
        SetTimer(() => ToolTip(), -2000)
    }
}

; ======= Utility Functions =======

; Helper functions for conditional logging
LogError(message) {
    If Config.EnableLogError
        FileAppend("ErrLog: " FormatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Debug\suggester_error_log.txt")
}

Debug(message) {
    If Config.EnableDebug
        FileAppend("Debug: " FormatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Debug\suggester_debug_log.txt")
}

; ======= Main Execution =======
; Initialize configuration
Config.Init()

; Tooltip styling (font, margins, theme colors) -- class is at the bottom of this file
ToolTipOptions.Init()
ToolTipOptions.SetFont("s14", "Calibri")
ToolTipOptions.SetMargins(5, 5, 5, 5) ; Left, Top, Right, Bottom
if (Config.ListColor != "Default" && Config.ListColor != "" && Config.FontColor != "Default" && Config.FontColor != "")
    ToolTipOptions.SetColors("0x" SubStr(Config.ListColor, -6), "0x" SubStr(Config.FontColor, -6))

; Run the Suggester
HotstringSuggester.Init()

; ======= ToolTipOptions class (by just me) =======
; .QQQQQQQQQQQQQQQQ...QQQQQQQQQQQQQQQQ..............QQQQQQQ...
; QQQQQQQQQQQQQQQQQ..QQQQQQQQQQQQQQQQQ...........QQQQQQQQQQ...
; QQQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ.........QQQQQQQQQQQ....
; QQQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ........QQQQQQQQQ..QQQQQ
; QQQQQQQQQQQQQQQQ.QQQQQQQQQQQQQQQQQQ........QQQQQQQQ...QQQQQQQ
; QQQQQQQQQQQQQ.....QQQQQQQQQQQQQQ..........QQQQQQQ...QQQQQQQQQ
; .....QQQQQQQQ...........QQQQQQQQ.........QQQQQQQ....QQQQQQQQQQ
; .....QQQQQQQQ...........QQQQQQQQ........QQQQQQQQ....QQQQQQQQQQ
; ....QQQQQQQQQ..........QQQQQQQQQ........QQQQQQQ.....QQQQQQQQQQQ
; ....QQQQQQQQ...........QQQQQQQQ........QQQQQQQQ......QQQQQQQQQQ
; ....QQQQQQQQ...........QQQQQQQQ.......QQQQQQQQ.......QQQQQQQQQQ
; ...QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQ........QQQQQQQQ
; ...QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ........QQQQQQQQ
; ...QQQQQQQQ...........QQQQQQQQ.......QQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ.........QQQQQQQ
; ..QQQQQQQQQ..........QQQQQQQQQ......QQQQQQQQQ.........QQQQQQ
; .QQQQQQQQQQ.........QQQQQQQQQQ......QQQQQQQQQ.........QQQQQQ
; .QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQQ........QQQQQQ.
; .QQQQQQQQQ..........QQQQQQQQQ.......QQQQQQQQQQ.......QQQQQQ.
; QQQQQQQQQQ.........QQQQQQQQQQ.......QQQQQQQQQQ......QQQQQQ..
; QQQQQQQQQ..........QQQQQQQQQ.........QQQQQQQQQ......QQQQQQ..
; QQQQQQQQQ..........QQQQQQQQQ.........QQQQQQQQQQ....QQQQQQ...
; QQQQQQQQQ..........QQQQQQQQQ..........QQQQQQQQQQ.QQQQQQQ....
; QQQQQQQQ...........QQQQQQQQ............QQQQQQQQQQQQQQQQ.....
; QQQQQQQ............QQQQQQQ..............QQQQQQQQQQQQQ.......
; .QQQQQ..............QQQQQ.................QQQQQQQQQ.........
;                       Class ToolTipOptions - 2023-09-10 
;                                      Just Me
;           https://www.autohotkey.com/boards/viewtopic.php?f=83&t=113308
; ==============================================================================
; ==============================================================================
; ==============================================================================
; ----------------------------------------------------------------------------------------------------------------------


; ----------------------------------------------------------------------------------------------------------------------

; ======================================================================================================================
; ToolTipOptions        -  additional options for ToolTips
;
; Tooltip control       -> https://learn.microsoft.com/en-us/windows/win32/controls/tooltip-control-reference
; TTM_SETMARGIN         = 1050
; TTM_SETTIPBKCOLOR     = 1043
; TTM_SETTIPTEXTCOLOR   = 1044
; TTM_SETTITLEW         = 1057
; WM_SETFONT            = 0x30
; SetClassLong()        -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclasslongw
; ======================================================================================================================
Class ToolTipOptions {
   ; -------------------------------------------------------------------------------------------------------------------
   Static HTT := DllCall("User32.dll\CreateWindowEx", "UInt", 8, "Str", "tooltips_class32", "Ptr", 0, "UInt", 3
                       , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0)
   Static SWP := CallbackCreate(ObjBindMethod(ToolTipOptions, "_WNDPROC_"), , 4) ; subclass window proc
   Static OWP := 0                                                               ; original window proc
   Static ToolTips := Map()
   ; -------------------------------------------------------------------------------------------------------------------
   Static BkgColor := ""
   Static TktColor := ""
   Static Icon := ""
   Static Title := ""
   Static HFONT := 0
   Static Margins := ""
   ; -------------------------------------------------------------------------------------------------------------------
   Static Call(*) => False ; do not create instances
   ; -------------------------------------------------------------------------------------------------------------------
   ; Init()          -  Initialize some class variables and subclass the tooltip control.
   ; -------------------------------------------------------------------------------------------------------------------
   Static Init() {
      If (This.OWP = 0) {
         This.BkgColor := ""
         This.TktColor := ""
         This.Icon := ""
         This.Title := ""
         This.Margins := ""
         If (A_PtrSize = 8)
            This.OWP := DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.SWP, "UPtr")
         Else
            This.OWP := DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.SWP, "UInt")
         OnExit(ToolTipOptions._EXIT_, -1)
         Return This.OWP
      }
      Else
         Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ;  Reset()        -  Close all existing tooltips, delete the font object, and remove the tooltip's subclass.
   ; -------------------------------------------------------------------------------------------------------------------
   Static Reset() {
      If (This.OWP != 0) {
         For HWND In This.ToolTips.Clone()
            DllCall("DestroyWindow", "Ptr", HWND)
        This.ToolTips.Clear()
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := 0
         If (A_PtrSize = 8)
            DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.OWP, "UPtr")
         Else
            DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.OWP, "UInt")
         This.OWP := 0
         Return True
      }
      Else
         Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetColors()     -  Set or remove the text and/or the background color for the tooltip.
   ; Parameters:
   ;     BkgColor    -  color value like used in Gui, Color, ...
   ;     TxtColor    -  see above.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetColors(BkgColor := "", TxtColor := "") {
      This.BkgColor := BkgColor = "" ? "" : BGR(BkgColor)
      This.TxtColor := TxtColor = "" ? "" : BGR(TxtColor)
      BGR(Color, Default := "") { ; converts colors to BGR
         ; HTML Colors (BGR)
         Static HTML := {AQUA:   0x00FFFF, BLACK: 0x000000, BLUE:   0x0000FF, FUCHSIA: 0xFF00FF, GRAY:  0x808080,
                         GREEN:  0x008000, LIME:  0x00FF00, MAROON: 0x800000, NAVY:    0x000080, OLIVE: 0x808000,
                         PURPLE: 0x800080, RED:   0xFF0000, SILVER: 0xC0C0C0, TEAL:    0x008080, WHITE: 0xFFFFFF,
                         YELLOW: 0xFFFF00 }
         If IsInteger(Color)
            Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
         Return HTML.HasProp(Color) ? HTML.%Color% : Default
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetFont()       -  Set or remove the font used by the tooltip.
   ; Parameters:
   ;     FntOpts     -  font options like Gui.SetFont(Options, ...)
   ;     FntName     -  font name like Gui.SetFont(..., Name)
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetFont(FntOpts := "", FntName := "") {
      Static HDEF := DllCall("GetStockObject", "Int", 17, "UPtr") ; DEFAULT_GUI_FONT
      Static LOGFONTW := 0
      If (FntOpts = "") && (FntName = "") {
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := 0
         LOGFONTW := 0
      }
      Else {
         If (LOGFONTW = 0) {
            LOGFONTW := Buffer(92, 0)
            DllCall("GetObject", "Ptr", HDEF, "Int", 92, "Ptr", LOGFONTW)
         }
         HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
         LOGPIXELSY := DllCall("GetDeviceCaps", "Ptr", HDC, "Int", 90, "Int")
         DllCall("ReleaseDC", "Ptr", HDC, "Ptr", 0)
         If (FntOpts != "") {
            For Opt In StrSplit(RegExReplace(Trim(FntOpts), "\s+", " "), " ") {
               Switch StrUpper(Opt) {
                  Case "BOLD":      NumPut("Int", 700, LOGFONTW, 16)
                  Case "ITALIC":    NumPut("Char",  1, LOGFONTW, 20)
                  Case "UNDERLINE": NumPut("Char",  1, LOGFONTW, 21)
                  Case "STRIKE":    NumPut("Char",  1, LOGFONTW, 22)
                  Case "NORM":      NumPut("Int", 400, "Char", 0, "Char", 0, "Char", 0, LOGFONTW, 16)
                  Default:
                     O := StrUpper(SubStr(Opt, 1, 1))
                     V := SubStr(Opt, 2)
                     Switch O {
                        Case "C":
                           Continue ; ignore the color option
                        Case "Q":
                           If !IsInteger(V) || (Integer(V) < 0) || (Integer(V) > 5)
                              Throw ValueError("Option Q must be an integer between 0 and 5!", -1, V)
                           NumPut("Char", Integer(V), LOGFONTW, 26)
                        Case "S":
                           If !IsNumber(V) || (Number(V) < 1) || (Integer(V) > 255)
                              Throw ValueError("Option S must be a number between 1 and 255!", -1, V)
                           NumPut("Int", -Round(Integer(V + 0.5) * LOGPIXELSY / 72), LOGFONTW)
                        Case "W":
                           If !IsInteger(V) || (Integer(V) < 1) || (Integer(V) > 1000)
                              Throw ValueError("Option W must be an integer between 1 and 1000!", -1, V)
                           NumPut("Int", Integer(V), LOGFONTW, 16)
                        Default:
                           Throw ValueError("Invalid font option!", -1, Opt)
                     }
                  }
               }
            }
         NumPut("Char", 1, "Char", 4, "Char", 0, LOGFONTW, 23) ; DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS
         NumPut("Char", 0, LOGFONTW, 27) ; FF_DONTCARE
         If (FntName != "")
            StrPut(FntName, LOGFONTW.Ptr + 28, 32)
         If !(HFONT := DllCall("CreateFontIndirectW", "Ptr", LOGFONTW, "UPtr"))
            Throw OSError()
         If This.HFONT
            DllCall("DeleteObject", "Ptr", This.HFONT)
         This.HFONT := HFONT
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetMargins()    -  Set or remove the margins used by the tooltip
   ; Parameters:
   ;     L, T, R, B  -  left, top, right, and bottom margin in pixels.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetMargins(L := 0, T := 0, R := 0, B := 0) {
      If ((L + T + R + B) = 0)
         This.Margins := 0
      Else {
         This.Margins := Buffer(16, 0)
         NumPut("Int", L, "Int", T, "Int", R, "Int", B, This.Margins)
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; SetTitle()      -  Set or remove the title and/or the icon displayed on the tooltip.
   ; Parameters:
   ;     Title       -  string to be used as title.
   ;     Icon        -  icon to be shown in the ToolTip.
   ;                    This can be the number of a predefined icon (1 = info, 2 = warning, 3 = error
   ;                    (add 3 to display large icons on Vista+) or a HICON handle.
   ; -------------------------------------------------------------------------------------------------------------------
   Static SetTitle(Title := "", Icon := "") {
      Switch {
         Case (Title = "") && (Icon != ""):
            This.Icon := Icon
            This.Title := " "
         Case (Title != "") && (Icon = ""):
            This.Icon := 0
            This.Title := Title
         Default:
            This.Icon := Icon
            This.Title := Title
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; For internal use only!
   ; -------------------------------------------------------------------------------------------------------------------
   Static _WNDPROC_(hWnd, uMsg, wParam, lParam) {
      ; WNDPROC -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
      Switch uMsg {
         Case 0x0411: ; TTM_TRACKACTIVATE - just handle the first message after the control has been created
            If This.ToolTips.Has(hWnd) && (This.ToolTips[hWnd] = 0) {
               If (This.BkgColor != "")
                  SendMessage(1043, This.BkgColor, 0, hWnd)                ; TTM_SETTIPBKCOLOR
               If (This.TxtColor != "")
                  SendMessage(1044, This.TxtColor, 0, hWnd)                ; TTM_SETTIPTEXTCOLOR
               If This.HFONT
                  SendMessage(0x30, This.HFONT, 0, hWnd)                   ; WM_SETFONT
               If (Type(This.Margins) = "Buffer")
                  SendMessage(1050, 0, This.Margins.Ptr, hWnd)             ; TTM_SETMARGIN
               If (This.Icon != "") || (This.Title != "")
                  SendMessage(1057, This.Icon, StrPtr(This.Title), hWnd)   ; TTM_SETTITLE
               This.ToolTips[hWnd] := 1
            }
         Case 0x0001: ; WM_CREATE
            DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "Ptr", 0, "Ptr", StrPtr(""))
            This.ToolTips[hWnd] := 0
         Case 0x0002: ; WM_DESTROY
            This.ToolTips.Delete(hWnd)
      }
      Return DllCall(This.OWP, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "UInt")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Static _EXIT_(*) {
      If (ToolTipOptions.OWP != 0)
         ToolTipOptions.Reset()
   }
}
; ============= Bottom of TOOLTIP OPTIONS CLASS ===============
