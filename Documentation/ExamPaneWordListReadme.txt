ExamPaneWordList README
Updating new combo list. 
First user VitaKaninen, with Claude AI, processed original GitHubComboList249k.txt list (Thanks Andrew!) See AHK forum discussion, about page 14. 
AI Notes: 
1. Dictionary pass (a script, no AI). A word was confirmed real if any of these had it: Hunspell en_US / en_GB / en_CA / en_AU (the spell-check
dictionaries used by LibreOffice and Firefox, with every suffix expanded), ENABLE (a public-domain Scrabble list), or WordNet. For
capitalized words only Hunspell counts, because the others are lowercase-only. The 89k frequency list was NOT used, as you asked. Result: 205,307 of 249,745 words confirmed and left alone.

2. AI pass over the 44,438 words that no dictionary confirmed (34,598 lowercase, 9,840 capitalized), in 9 batches of ~5,000. Instructions: keep Scrabble, archaic, dialect, technical and foreign words; flag only what isn't a real word; "when in doubt, keep". Lowercase words were only listed if flagged. Every capitalized word got a category.

Kunkel321 then started with GitHubComboList-A-conservative.txt, defined by Claude as:
GitHubComboList-A-conservative.txt   317 words removed
      -Lowercase: MISSPELLING, GARBAGE, RUNON
      -Capitalized: MISSPELLING, GARBAGE

Then kunkel321 did manual edits: 
-Removed 92 words from 1-flagged-lowercase.txt, that were UNSURE.
-Added all of 4-missing-recommended file (414)
-Added from 7-missing-gb-ca-au.tsv:
--NAME-COMMON (2708)
--COMMON (1034)
--BRAND common (208)
--ACRONYM common (130)
End Result: As of Nov-10-2026: 253,700 words, 2.67 MB

Old
Data\GitHubComboList249k.txt
new
Data\ExamPaneWordList253k.txt

Files affected:
-AutoCorret2.ahk
-MCLogger.ahk
-Suggester.ahk
-HotstringAuditor.ahk
-acSettings.ini 
