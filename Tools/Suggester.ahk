/*
=====================================================
            HOTSTRING SUGGESTER TOOL
                Updated:  11-15-2025 
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
*/

#SingleInstance Force
#Requires AutoHotkey v2+
SetWorkingDir(A_ScriptDir) 

TraySetIcon("..\Resources\Icons\lightbulb-Blue.ico") ; icon for 'add new column'

; ======= Configuration =======
class Config {
    ; File paths
    static ScriptFiles := {
        ACScript: "..\Core\AutoCorrect2.ahk",
        HSLibrary: "..\Core\HotstringLib.ahk",
        WordListFile: "..\Data\GitHubComboList249k.txt",
        FreqDataFile: "..\Data\unigram_freq_list_filtered_88k.csv" 
    }
    
    ; Behavior options
    static AutoCloseForm := 0       ; 0 = Keep form open after sending to HH, 1 = Auto-close
    static MaxSuggestions := 26     ; Maximum number of suggestions per type (beginning/ending)
    static UpdateClipboard := 1     ; When selecting list item, send it to clipboard
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
                this.FontColor := IniRead(settingsFile, "ColorSettings", "fontColor")
                this.ListColor := IniRead(settingsFile, "ColorSettings", "listColor")
                this.FormColor := IniRead(settingsFile, "ColorSettings", "formColor")

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
    static LoadedWordList := []
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

        ; Check for command line arguments
        if A_Args.Length > 0 {
            Debug("Command line arguments received: " A_Args.Length)
            
            ; Check if using the file-based parameter method
            if A_Args.Length >= 2 && A_Args[1] = "/fromfile" {
                Debug("Using file-based parameter method")
                
                ; Read the hotstring from the temporary file
                tempFile := A_Args[2]
                if FileExist(tempFile) {
                    try {
                        hotstring := FileRead(tempFile)
                        Debug("Hotstring read from file: " hotstring)
                        
                        ; Clean up the temporary file
                        try {
                            FileDelete(tempFile)
                            Debug("Temporary file deleted")
                        } catch {
                            Debug("Failed to delete temporary file")
                        }
                        
                        ; Process the hotstring
                        this.AnalyzeHotstring(hotstring)
                        return
                    } catch Error as err {
                        Debug("Error reading from temp file: " err.Message)
                        ; Fall back to input form if file reading fails
                    }
                } else {
                    Debug("Temp file not found: " tempFile)
                }
            } 
            ; Standard parameter passing
            else if A_Args[1] {
                hotstring := A_Args[1]
                Debug("Direct command line parameter: " hotstring)
                
                ; Process the hotstring
                this.AnalyzeHotstring(hotstring)
                return
            }
            
            ; Fall back to input form if no valid parameter found
            this.ShowInputForm()
        }
        else {
            this.ShowInputForm()
        }
    }
    
    ; Show the input form when no arguments are provided
    static ShowInputForm() {
        inputGui := Gui("", "Hotstring Suggester - Input")
        inputGui.BackColor := this.Config.FormColor
        inputGui.SetFont("s12 " (this.Config.FontColor ? "c" this.Config.FontColor : ""))
        
        inputGui.AddText("w400", "Enter a hotstring to analyze:")
        inputEdit := inputGui.AddEdit("w400 " (this.Config.ListColor ? "Background" this.Config.ListColor : ""), "")
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
        
        ; Create a progress indicator - start at 0%
        progress := this._ShowSimpleProgress("Analyzing hotstring...", 
            "Generating suggestions for " hotstring "`nThis may take a moment...")
        
        this.CurrentHotstring := hotstring
        this.Suggestions := []
        
        ; Update to 10% - Starting analysis
        progress.bar.Value := 10
        progress.gui.Title := "Loading word list..."
        
        if (this.LoadedWordList.Length = 0) {
            this._LoadWordList()
        }
        
        ; Update to 20% - Loading frequency data
        progress.bar.Value := 20
        progress.gui.Title := "Loading frequency data..."
        
        if (!this.FreqDataLoaded) {
            this._LoadWordFrequencies(this.FreqDataFile)
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
            
            this._GenerateSuggestions(hsInfo, progress)
            
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
    
    ; Load word frequencies from CSV file
    static _LoadWordFrequencies(filePath) {
        try {
            ; Clear existing data
            this.WordFreqMap.Clear()
            
            ; Check if file exists
            if (!FileExist(filePath)) {
                Debug("Frequency data file not found: " filePath)
                return false
            }
            
            ; Process the file directly from disk, one line at a time
            wordCount := 0
            duplicateCount := 0
            skippedLines := 0
            
            ; Open the file for reading
            file := FileOpen(filePath, "r")
            if (!file) {
                Debug("Could not open frequency data file: " filePath)
                return false
            }
            
            ; Read line by line
            while !file.AtEOF {
                line := file.ReadLine()
                
                ; Skip empty lines
                if (line = "" || line = "`r")
                    continue
                
                ; Split the line into word and frequency
                commaPos := InStr(line, ",")
                if (commaPos) {
                    word := Trim(SubStr(line, 1, commaPos - 1))
                    freqStr := Trim(SubStr(line, commaPos + 1))
                    
                    ; Skip lines with empty frequencies
                    if (word = "" || freqStr = "") {
                        skippedLines++
                        continue
                    }
                    
                    ; Convert frequency to number
                    freq := Number(freqStr)
                    if (freq = 0 && freqStr != "0") {
                        skippedLines++
                        continue
                    }
                    
                    ; Convert word to lowercase for consistency
                    word := StrLower(word)
                    
                    ; Check for duplicates
                    if (this.WordFreqMap.Has(word)) {
                        duplicateCount++
                        ; For duplicates, add the frequencies together
                        this.WordFreqMap[word] += freq
                    } else {
                        ; Add new word
                        this.WordFreqMap[word] := freq
                        wordCount++
                    }
                }
            }
            
            ; Close the file
            file.Close()
            
            Debug("Word frequency data loaded - Words: " wordCount)
            
            this.FreqDataLoaded := true
            return true
        }
        catch Error as err {
            Debug("Error loading frequency data: " err.Message)
            return false
        }
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
    
    ; Load the word list for analysis
    static _LoadWordList() {
        if (!FileExist(this.WordListFile)) {
            MsgBox("Word list file not found: " this.WordListFile)
            return
        }
        
        try {
            this.LoadedWordList := []
            Loop Read, this.WordListFile {
                this.LoadedWordList.Push(A_LoopReadLine)
            }
        } catch Error as err {
            Debug("Error loading word list: " err.Message)
        }
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
        
        ; Update progress to 85% - Calculating frequencies
        if (progress && IsObject(progress.bar))
            progress.bar.Value := 85, progress.gui.Title := "Calculating web frequencies..."
            
        ; Calculate web frequencies for all suggestions
        this._CalculateFrequenciesForSuggestions()
        
        ; Calculate potential misspellings for all suggestions
        this._CalculateMisspellingsForSuggestions()
    }

    ; Analyze words to find patterns and letter frequencies
    static _AnalyzeMatchingWords(hsInfo) {
        ; Structure to collect analysis data
        matchInfo := {
            words: [],             ; Words containing the replacement
            preceding: Map(),      ; Letters preceding the replacement
            following: Map(),      ; Letters following the replacement
            variations: Map()      ; Fixes count for each variation
        }
        
        lcReplacement := StrLower(hsInfo.replacement)
        
        ; Determine the type of hotstring based on options
        isBeginning := hsInfo.isBeginning
        isEnding := hsInfo.isEnding
        isMiddle := hsInfo.isMiddle
        
        Debug("Analyzing matching words for replacement: " lcReplacement)
        Debug("Hotstring type - Beginning: " isBeginning ", Middle: " isMiddle ", Ending: " isEnding)
        
        ; Scan the word list to find matching words and collect letter frequencies
        for idx, word in this.LoadedWordList {
            word := Trim(word)
            if word = ""
                continue
                
            ; Convert to lowercase for case-insensitive matching
            lcWord := StrLower(word)
            matchFound := false
            
            ; Apply correct matching based on hotstring type
            if (isMiddle) {
                ; For word-middle, check if the word contains the replacement
                matchFound := InStr(lcWord, lcReplacement) > 0
            } 
            else if (isBeginning) {
                ; For word-beginning, check if the word starts with the replacement
                matchFound := SubStr(lcWord, 1, StrLen(lcReplacement)) = lcReplacement
            } 
            else if (isEnding) {
                ; For word-ending, check if the word ends with the replacement
                matchFound := SubStr(lcWord, 1 + StrLen(lcWord) - StrLen(lcReplacement)) = lcReplacement
            }
            else {
                ; For exact match
                matchFound := lcWord = lcReplacement
            }
            
            ; Skip if no match found
            if (!matchFound)
                continue
                
            ; Add to matching words list
            matchInfo.words.Push(word)
            
            ; Log some matching words for debugging
            if (matchInfo.words.Length <= 5) {
                Debug("Match found: " word)
            }
            
            ; For word-middle and word-beginning, analyze letters that could precede the replacement
            if (isMiddle || isEnding) {
                ; Find all occurrences and analyze preceding letters
                pos := 1
                while (pos := InStr(lcWord, lcReplacement, , pos)) {
                    ; Check letter before replacement
                    if (pos > 1) {
                        beforeLetter := SubStr(lcWord, pos-1, 1)
                        if (beforeLetter ~= "[a-z]") {
                            ; Increment frequency count
                            matchInfo.preceding[beforeLetter] := matchInfo.preceding.Has(beforeLetter) ? 
                                                            matchInfo.preceding[beforeLetter] + 1 : 1
                                                            
                            ; Create a key for this variation (preceding letter + replacement)
                            variationKey := beforeLetter . lcReplacement
                            matchInfo.variations[variationKey] := matchInfo.variations.Has(variationKey) ?
                                                                matchInfo.variations[variationKey] + 1 : 1
                        }
                    }
                    
                    pos += StrLen(lcReplacement)
                }
            }
            
            ; For word-middle and word-ending, analyze letters that could follow the replacement
            if (isMiddle || isBeginning) {
                ; Find all occurrences and analyze following letters
                pos := 1
                while (pos := InStr(lcWord, lcReplacement, , pos)) {
                    ; Check letter after replacement
                    afterPos := pos + StrLen(lcReplacement)
                    if (afterPos <= StrLen(lcWord)) {
                        afterLetter := SubStr(lcWord, afterPos, 1)
                        if (afterLetter ~= "[a-z]") {
                            ; Increment frequency count
                            matchInfo.following[afterLetter] := matchInfo.following.Has(afterLetter) ? 
                                                        matchInfo.following[afterLetter] + 1 : 1
                                                        
                            ; Create a key for this variation (replacement + following letter)
                            variationKey := lcReplacement . afterLetter
                            matchInfo.variations[variationKey] := matchInfo.variations.Has(variationKey) ?
                                                            matchInfo.variations[variationKey] + 1 : 1
                        }
                    }
                    
                    pos += StrLen(lcReplacement)
                }
            }
        }
        
        Debug("Total matching words found: " matchInfo.words.Length)
        Debug("Preceding letters: " this._MapToString(matchInfo.preceding))
        Debug("Following letters: " this._MapToString(matchInfo.following))
        
        return matchInfo
    }
    
    ; Create suggestions based on analysis
    static _CreateSuggestionsFromAnalysis(hsInfo, matchInfo) {
        ; Create suggestions from preceding letters (for middle/ending hotstrings)
        if (hsInfo.isMiddle || hsInfo.isEnding) {
            this._CreatePrecedingLetterSuggestions(hsInfo, matchInfo)
        }
        
        ; Create suggestions from following letters (for middle/beginning hotstrings)
        if (hsInfo.isMiddle || hsInfo.isBeginning) {
            this._CreateFollowingLetterSuggestions(hsInfo, matchInfo)
        }
    }
    
    ; Create suggestions by adding letters to the beginning
    static _CreatePrecedingLetterSuggestions(hsInfo, matchInfo) {
        ; Get preceding letters
        precedingLetters := matchInfo.preceding
        
        ; Take up to Config.MaxSuggestions most common letters
        count := 0
        for beforeLetter, frequency in precedingLetters {
            ; Create new trigger and replacement
            newTrigger := beforeLetter . hsInfo.trigger
            newReplacement := beforeLetter . hsInfo.replacement
            
            ; Get fix count for this variation
            variationKey := beforeLetter . StrLower(hsInfo.replacement)
            fixCount := matchInfo.variations.Has(variationKey) ? matchInfo.variations[variationKey] : 0
            
            ; Only add if it fixes at least one word
            if (fixCount > 0) {
                description := "Add '" beforeLetter "' to beginning"
                if (frequency > 3)
                    description .= "   >>>---->"
                    
                this.Suggestions.Push({
                    options: hsInfo.options,
                    trigger: newTrigger,
                    replacement: newReplacement,
                    description: description,
                    fixCount: fixCount,
                    hotstring: ":" hsInfo.options ":" newTrigger "::" newReplacement,
                    webFrequency: 0,  ; Will be calculated later
                    misCount: 0       ; Will be calculated later
                })
                
                count++
                ; Use configurable limit
                if (count >= this.Config.MaxSuggestions)
                    break
            }
        }
    }
    
    ; Create suggestions by adding letters to the end
    static _CreateFollowingLetterSuggestions(hsInfo, matchInfo) {
        ; Get following letters
        followingLetters := matchInfo.following
        
        ; Take up to Config.MaxSuggestions most common letters
        count := 0
        for afterLetter, frequency in followingLetters {
            ; Create new trigger and replacement
            newTrigger := hsInfo.trigger . afterLetter
            newReplacement := hsInfo.replacement . afterLetter
            
            ; Get fix count for this variation
            variationKey := StrLower(hsInfo.replacement) . afterLetter
            fixCount := matchInfo.variations.Has(variationKey) ? matchInfo.variations[variationKey] : 0
            
            ; Only add if it fixes at least one word
            if (fixCount > 0) {
                description := "Add '" afterLetter "' to end"
                if (frequency > 3)
                    description .= "   >>>---->"
                    
                this.Suggestions.Push({
                    options: hsInfo.options,
                    trigger: newTrigger,
                    replacement: newReplacement,
                    description: description,
                    fixCount: fixCount,
                    hotstring: ":" hsInfo.options ":" newTrigger "::" newReplacement,
                    webFrequency: 0,  ; Will be calculated later
                    misCount: 0       ; Will be calculated later
                })
                
                count++
                ; Use configurable limit
                if (count >= this.Config.MaxSuggestions)
                    break
            }
        }
    }
    
    ; Add the original hotstring as a reference suggestion
    static _AddOriginalAsSuggestion(hsInfo) {
        ; Count original fixes
        fixCount := this._CountFixesForSuggestion(hsInfo.options, hsInfo.trigger, hsInfo.replacement)
        
        ; Add to suggestions list
        this.Suggestions.Push({
            options: hsInfo.options,
            trigger: hsInfo.trigger,
            replacement: hsInfo.replacement,
            description: "Original",
            fixCount: fixCount,
            hotstring: ":" hsInfo.options ":" hsInfo.trigger "::" hsInfo.replacement,
            webFrequency: 0,  ; Will be calculated later
            misCount: 0       ; Will be calculated later
        })
    }
    
    ; Calculate potential misspellings for all suggestions
    static _CalculateMisspellingsForSuggestions() {
        ; Process each suggestion
        for idx, suggestion in this.Suggestions {
            ; Call the misspellings calculation function for the trigger
            misCount := this._CountPotentialMisspellings(suggestion.options, suggestion.trigger)
            
            ; Update the suggestion object with the misspellings count
            suggestion.misCount := misCount
        }
    }
    
    ; Count potential misspellings for a trigger string
    static _CountPotentialMisspellings(options, trigger) {
        ; Determine the type of hotstring based on options
        isBeginning := InStr(options, "*") && !InStr(options, "?")
        isEnding := !InStr(options, "*") && InStr(options, "?")
        isMiddle := InStr(options, "*") && InStr(options, "?")
        
        ; Log to help debug
        Debug("Counting misspellings for trigger: " trigger)
        Debug("Options: " options)
        Debug("isBeginning: " isBeginning)
        Debug("isEnding: " isEnding)
        Debug("isMiddle: " isMiddle)
        
        ; Count matching words that would be misspelled
        matches := []
        
        for dictWord in this.LoadedWordList {
            dictWord := Trim(dictWord)
            
            ; Skip empty words
            if (dictWord = "")
                continue
                
            matchFound := false
            
            if (isMiddle) {
                matchFound := InStr(dictWord, trigger) > 0
            } 
            else if (isBeginning) {
                ; For word-beginning, check if the word starts with the trigger
                matchFound := SubStr(dictWord, 1, StrLen(trigger)) = trigger
            } 
            else if (isEnding) {
                ; For word-ending, check if the word ends with the trigger
                matchFound := SubStr(dictWord, 1 + StrLen(dictWord) - StrLen(trigger)) = trigger
            }
            else {
                ; For exact match
                matchFound := dictWord = trigger
            }
            
            if (matchFound) {
                matches.Push(dictWord)
                
                ; Log a few sample matches for debugging
                if (matches.Length <= 5) {
                    Debug("Misspelling match found: " dictWord)
                }
            }
        }
        
        Debug("Total misspellings found: " matches.Length)
        return matches.Length
    }

    ; Helper method to check if a suggestion would fix at least one word
    static _CountFixesForSuggestion(options, trigger, replacement) {
        ; Determine the type of hotstring based on options
        isBeginning := InStr(options, "*") && !InStr(options, "?")
        isEnding := !InStr(options, "*") && InStr(options, "?")
        isMiddle := InStr(options, "*") && InStr(options, "?")
        
        ; Find matches based on the hotstring type
        matches := []
        
        for dictWord in this.LoadedWordList {
            if (isMiddle && InStr(dictWord, replacement)) {
                matches.Push(dictWord)
            } else if (isBeginning) {
                ; For word-beginning, check if the word starts with the replacement
                if (SubStr(dictWord, 1, StrLen(replacement)) = replacement) {
                    matches.Push(dictWord)
                }
            } else if (isEnding) {
                ; For word-ending, check if the word ends with the replacement
                if (StrLen(dictWord) >= StrLen(replacement)) {
                    if (SubStr(dictWord, -(StrLen(replacement) - 1)) = replacement) {
                        matches.Push(dictWord)
                    }
                }
            } else if (!isBeginning && !isEnding && !isMiddle && dictWord = replacement) {
                matches.Push(dictWord)
            }
        }
        
        return matches.Length
    }
    
    ; Calculate web frequencies for all suggestions
    static _CalculateFrequenciesForSuggestions() {
        ; Skip if frequency data not loaded
        if (!this.FreqDataLoaded) {
            Debug("Frequency data not loaded, skipping frequency calculations")
            return
        }
        
        ; Process each suggestion
        for idx, suggestion in this.Suggestions {
            ; Call the frequency calculation function for the replacement
            webFreq := this._CalculateHotstringFrequency(suggestion)
            
            ; Update the suggestion object with the frequency
            suggestion.webFrequency := webFreq
        }
    }
    
    ; Calculate frequency for a single hotstring suggestion
    static _CalculateHotstringFrequency(suggestion) {
        ; Parse the replacement to determine hotstring type
        hsInfo := {
            replacement: suggestion.replacement,
            isBeginning: InStr(suggestion.options, "*") && !InStr(suggestion.options, "?"),
            isEnding: !InStr(suggestion.options, "*") && InStr(suggestion.options, "?"),
            isMiddle: InStr(suggestion.options, "*") && InStr(suggestion.options, "?")
        }
        
        ; Find matching words based on the hotstring type
        matchingWords := this._FindMatchesForFrequency(hsInfo)
        
        ; Calculate total frequency
        totalFreq := 0
        
        for idx, word in matchingWords {
            if (this.WordFreqMap.Has(word))
                totalFreq += this.WordFreqMap[word]
        }
        
        return totalFreq
    }
    
    ; Find matches for frequency calculation
    static _FindMatchesForFrequency(hsInfo) {
        matches := []
        lcReplacement := StrLower(hsInfo.replacement)
        
        if (!lcReplacement || !this.WordFreqMap.Count)
            return matches
        
        ; Iterate through the word frequency map to find matches
        for word, freq in this.WordFreqMap {
            ; Skip processing if word is empty
            if (word = "")
                continue
                
            if (hsInfo.isMiddle && InStr(word, lcReplacement)) {
                matches.Push(word)
            } else if (hsInfo.isBeginning && SubStr(word, 1, StrLen(lcReplacement)) = lcReplacement) {
                matches.Push(word)
            } else if (hsInfo.isEnding) {
                ; Check if the word ends with the replacement
                wordLength := StrLen(word)
                replLength := StrLen(lcReplacement)
                
                if (wordLength >= replLength) {
                    endPortion := SubStr(word, wordLength - replLength + 1)
                    if (endPortion = lcReplacement) {
                        matches.Push(word)
                    }
                }
            } else if (!hsInfo.isBeginning && !hsInfo.isEnding && !hsInfo.isMiddle && word = lcReplacement) {
                matches.Push(word)
            }
        }
        
        return matches
    }
    
    ; Helper method to convert a Map to a string for debugging
    static _MapToString(map) {
        result := ""
        for key, value in map
            result .= key . ":" . value . ", "
        return RTrim(result, ", ")
    }
    
    ; Find matches for a word pattern based on options
    static _FindMatches(word, options) {
        ; Determine the type of hotstring based on options
        isBeginning := InStr(options, "*") && !InStr(options, "?")
        isEnding := !InStr(options, "*") && InStr(options, "?")
        isMiddle := InStr(options, "*") && InStr(options, "?")
        
        ; Debug the pattern matching settings
        Debug("Finding matches for word: " word)
        Debug("Using options: " options)
        Debug("isBeginning: " isBeginning)
        Debug("isEnding: " isEnding)
        Debug("isMiddle: " isMiddle)
        
        matches := []
        
        for dictWord in this.LoadedWordList {
            dictWord := Trim(dictWord)
            
            ; Skip empty words
            if (dictWord = "")
                continue
                
            matchFound := false
            
            if (isMiddle) {
                matchFound := InStr(dictWord, word) > 0
            } 
            else if (isBeginning) {
                ; For word-beginning, check if the word starts with the pattern
                matchFound := SubStr(dictWord, 1, StrLen(word)) = word
            } 
            else if (isEnding) {
                ; For word-ending, check if the word ends with the pattern
                matchFound := SubStr(dictWord, 1 + StrLen(dictWord) - StrLen(word)) = word
            }
            else {
                ; For exact match
                matchFound := dictWord = word
            }
            
            if (matchFound) {
                matches.Push(dictWord)
                
                ; Log a few sample matches for debugging
                if (matches.Length <= 5) {
                    Debug("Match found in _FindMatches: " dictWord)
                }
            }
        }
        
        Debug("Total matches in _FindMatches: " matches.Length)
        return matches
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
        progressGui.SetFont("s12 c" (this.Config.FontColor ? this.Config.FontColor : ""))
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
        this.SuggestGui := Gui("+AlwaysOnTop", "Hotstring Suggester - Results")
        this.SuggestGui.SetFont("s12 c" (this.Config.FontColor ? this.Config.FontColor : ""))
        this.SuggestGui.BackColor := this.Config.FormColor
        
        ; Add "Keep window on top" checkbox at the top
        keepOnTopCheck := this.SuggestGui.Add("Checkbox", "xm y10 Checked", "Keep window on top")
        keepOnTopCheck.OnEvent("Click", (*) => this._ToggleAlwaysOnTop(keepOnTopCheck))
        
        ; Calculate total width based on column widths
        totalWidth := 660 ; Increased to add space for misspellings column
        
        ; Title and original hotstring info - adjusted width to match ListView
        this.SuggestGui.Add("Text", "y+10 w" totalWidth, "Original hotstring: [ " . this.CurrentHotstring
                                            " ]    Type: " . (hsInfo.isMiddle ? "Word-Middle" : 
                                            hsInfo.isBeginning ? "Word-Beginning" : 
                                            hsInfo.isEnding ? "Word-Ending" : "Regular"))
        
        ; Create a ListView with five columns (moved MisSp to last column)
        columnHeaders := ["Suggestion", "Description", "Fixes", "Web Freq", "MisSp"]
        
        ; Use list color for ListView background
        listViewOpts := "w" totalWidth " r20 Grid"  ; Increased rows from 15 to 20
        if (this.Config.ListColor)
            listViewOpts .= " Background" this.Config.ListColor
            
        listView := this.SuggestGui.Add("ListView", listViewOpts, columnHeaders)
        
        ; Set column widths
        listView.ModifyCol(1, 165)  ; Suggestion
        listView.ModifyCol(2, 240)  ; Description
        listView.ModifyCol(3, 70)   ; Fixes
        listView.ModifyCol(4, 90)   ; Web Frequency
        listView.ModifyCol(5, 70)   ; Misspellings (MisSp)
        
        ; Populate the ListView with frequency data
        for idx, suggestion in this.Suggestions {
            ; Format the web frequency
            formattedFreq := this._FormatWebFrequency(suggestion.webFrequency)
            
            ; Add suggestion to the ListView
            listView.Add(, 
                suggestion.hotstring,
                suggestion.description,
                suggestion.fixCount,
                formattedFreq,
                suggestion.misCount
            )
        }
        
        ; Set numeric sort for columns
        listView.ModifyCol(3, "Integer")  ; Sort Fixes column as numbers
        listView.ModifyCol(4, "Float")    ; Sort Web Freq column as numbers
        listView.ModifyCol(5, "Integer")  ; Sort MisSp column as numbers
        
        ; Add text and selected suggestion edit box with theme colors
        this.SuggestGui.Add("Text", "y+10 w85", "Selected:")
        
        ; Use theme color for edit control background - same width as ListView
        editOpts := "x+10 ReadOnly w500"
        if (this.Config.ListColor)
            editOpts .= " Background" this.Config.ListColor
            
        selectedHs := this.SuggestGui.Add("Edit", editOpts, "")
        
        ; Add a single close button centered
        buttonY := "y+8"
        closeButton := this.SuggestGui.Add("Button", buttonY " x" (totalWidth/2 - 90) " w180", "Close")
        closeButton.OnEvent("Click", this._CloseGuiHandler.Bind(this))
        
        ; Update selected hotstring when item is selected
        listView.OnEvent("ItemSelect", this._ItemSelectHandler.Bind(this, listView, selectedHs))
        
        ; Double-click behavior - just select the item
        listView.OnEvent("DoubleClick", this._DoubleClickHandler.Bind(this, listView))
        
        ; Show the GUI
        this.SuggestGui.Show("AutoSize")
        
        ; Select the first item by default
        if (this.Suggestions.Length > 0) {
            listView.Modify(1, "Select Focus")
            selectedHs.Value := this.Suggestions[1].hotstring
        }
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

; Run the Suggester
HotstringSuggester.Init()