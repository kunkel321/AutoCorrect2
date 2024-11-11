## The AutoCorrect for v2 Package.
This started as a version of the 2007 AutoHotkey script, AutoCorrect.ahk, though it has evolved into a package of several interrelated scripts.  It is written in AHK v2 code, and so is "AutoCorrect2."  Please note that the .exe files are not compiled versions of the same-named .ahk files.  Rather, they are a copies of AutoHotKey.exe that were downloaded from the AutoHotkey site, and renamed, to match the .ahk file.  Keeping the two in the same folder allows the user to run the code "portably," right from the folder.   It would probably be okay for a user to compile the ahk files into exe files, but the txt files must stay as read/writable separate files. 

Steve Kunkel
(kunkel321)

![Screenshot of hotstringhelper main gui](https://github.com/kunkel321/AutoCorrect2/blob/main/WordListsForHH/GUI%20quicksheet.png))
## Hotstring Helper 2 – Quick Sheet
1.	The Options Box.  Hotstring options go here.
2.	The Hotstring (Trigger string) Box.  Gets populated with word on clipboard.  If many words are on clipboard, an acronym is generated.  If the Exam Pane is open, adding a letter to the beginning or end of the trigger will cause the same letter to be automatically added to the replacement text.  Shift+Left focuses the Trigger Box.  Ctrl+Up/Down or Ctrl+Mouse Wheel toggles font size.
3.	If the string in the Trigger Box corresponds to any English words, if will turn red and warn you.  
4.	The Make Bigger toggle button.  Makes the Replacement Box much larger.
5.	The Show Symbols toggle button.  Make Replacement Box read only and shows characters for new lines, tabs, and spaces.
6.	The Replacement Box.  For autocorrects, this will likely be a single word.   For boilerplate templates, it might be a whole paragraph. 
7.	Make Function checkbox.  Instructs hh2 to create the autocorrect item with auto-logging syntax, such as 
:B0X*:automasion::f("automation") ; Fixes 2 words
Note that boilerplate items are never created with function calls. 
8.	The Comments Box.  Text entered here is added to the new hotstring as an inline comment. 
9.	The Append Button combines the content of the boxes into a hotstring and (after doing a validity check) appends it to the Hotstring Library, then restarts the AutoCorrect script.  Pressing Enter has the effect too, but only if the replacement box is not active.  The Append Button has no effect when in Show Symbols mode.  Shift+Click sends the hotstring to the clipboard, rather than appending it.  Ctrl+Click appends the hotstring, but does not restart the script.  
10.	he Check Button does a validity check.  Mostly this consists of ensuring that the new hotstring doesn’t conflict with any existing ones. 
11.	The Exam Button opens the Exam Pane (as seen in img).  When the Pane is open, the button shows “Done.”   Right-Click, or Shift+Click will open a Control Panel that has several links to other tools. 
12.	The Spell Button sends the content of the Replacement Box to Google.com and returns the “Did you mean...” response.  
13.	The Open Button opens the HotstringsLib.ahk file and navigates to the bottom of the file.
14.	Cancel hides the hh2 form and puts the previous content of the clipboard back.  Esc does the same thing. 
(Note that the following items are part of the Exam Pane, and are only for refining autocorrect entries.  They are not useful for boilerplate template hotstrings.)
15.	The tall Left-Trim Button simultaneously trims a single letter from the  beginning of the trigger string and the replacement string.
16.	The tall Right-Trim Button trims a letter from the ends.
17.	The wide Undo button will undo the trims.  Ctrl+z also does.  Shift+Click or Shift+Ctrl+z will undo all trims, resetting the originally-captured trigger and replacement.  
18.	The Delta String shows which parts of the autocorrect entry get changed, and which parts can safely be trimmed.
19.	The Radio Buttons set the hotstring as a word-beginning, word-ending, or word-middle item.  The Options Box is automatically updated to match.  Right-Click any item to unselect all of them.
20.	The Misspells Box lists all of the English words that correspond to the text string in the Trigger Box, and hence would be misspelled, from the application of the autocorrection item as it is.  
21.	The Fixes Box is a list of the words that can potentially be fixed by the current autocorrect item.   Trimming, or changing the radios, will change the number Misspells and Fixes.  
22.	The Word List Label simply shows what the currently-set comparison word list is.  (This is the list from which the Misspells and Fixes lists are derived.)

Please see the User Manual for more information. 
