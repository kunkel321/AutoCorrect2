# AutoCorrect for v2 Package.
This started as a version of the 2007 AutoHotkey script, AutoCorrect.ahk, though it has evolved into a package of several interrelated scripts.  It is written in AHK v2 code, and so is called "AutoCorrect2."  Please note that the .exe files are not compiled versions of the same-named .ahk files.  Rather, they are a copies of AutoHotKey.exe that were downloaded from the AutoHotkey site, and renamed, to match the .ahk file.  Keeping the two in the same folder allows the user to run the code "portably," right from the folder.   

_Stephen Kunkel (kunkel321)_

# Start Here.
- Run: AutoCorrect2\Core\AutoCorrect2.exe
- Then press _Win+H_

# Updating to October 1st version.  
- You can use your existing HotstringLib.ahk file and log files.  Just be sure to put the log files in the AutoCorrect\Data\ folder and the HotstringLib.ahk file in AutoCorrect2\Core\.
- Important: Please note that MCLog.txt has been renamed to ManualCorrectionLog.txt.

# Contributors.
It's worth noting that only one other person -- Robert -- has contributed code _via the GitHub push mechanism_, but many others have made **significant** contributions by other means (usually the AutoHotkey forums).  I'll list them here eventually, but they can also be found in the code comments of the various ahk files in the repository. 

# March 6, 2025 Major Update...
- The AutoCorrect2 code (which is mostly for HotstringHelper2) was very messy and "Frankensteinish" from evolving over the years.  I used Claude AI to totally refactor it, implementing best practice for code organization, naming conventions, etc.  The last parts of the script (loggers and inputBuffer class) are now a separate file that gets #Included.  So, _AutoCorrect2.ahk, AutoCorrectSystem.ahk, and HotstringLib.ahk_ must all be present for it to work. 
# October 1, 2025 Update to Folder Structure...
- The main folder was cluttered with tons of files, so I used Claude again to suggest the most sensible way to use subfolders.  The downside is that many of the tools call each other.  All those bits of code were easier when everything was in the same folder.  They now have to point to different locations.  I think I got it all working though.  I do think it is better organized like this.  None of the functionality of the tools was changed, though many folder paths in the code had to be updated.  

# Hotstring Helper 2 – Quick Sheet
![Screenshot of hotstringhelper main gui](https://github.com/kunkel321/AutoCorrect2/blob/main/Resources/Images/GUI%20quicksheet.jpg))
1.	The Options Box.  Hotstring options go here.
2.	The Hotstring (Trigger string) Box.  Upon pressing the hotkey, this box gets populated with the word on the clipboard.  If many words are on the clipboard, an acronym is generated.  If the Exam Pane is open, adding a letter to the beginning or end of the trigger will cause the same letter to be automatically added to the replacement text.  Shift+Left focuses the Trigger Box.  Ctrl-Up/Down or Ctrl-Mouse Wheel toggles font size.
3.	If the string in the Trigger Box corresponds to any English words, it will turn red and warn you.  
4.	On-board help system.  Also press F1 while any form element is selected.
5.	The Make Bigger toggle button makes the Replacement Box much larger.
6.	The Show Symbols toggle button makes the Replacement Box read only and shows characters for new  lines, tabs, and spaces.
7.	The Replacement Box.  For autocorrects, this will likely be a single word.   For boilerplate templates, it might be a whole paragraph. 
8.	The Make Function checkbox instructs hh2 to create the autocorrect item with the auto-logging function syntax, such as :B0X*:automasion::f("automation") 
- Note that boilerplate items are never created with function calls. 
9.	The Comments Box.  Text entered here is added to the new hotstring as an inline comment. 
10.	The Append Button combines the content of the boxes into a hotstring and (after doing a validity check) appends it to the Hotstring Library, then restarts the AutoCorrect script.  Pressing Enter does this too, but only if the replacement box is not active.  The Append Button has no effect when in Show Symbols mode.  
- Shift-Click sends the hotstring to the clipboard, rather than appending it.  
- Ctrl-Click appends the hotstring, but does not restart the script.  
- Alt-Click sends the hotstring to the Suggester Tool for analysis.
11.	The Check Button does a validity check but does not append the item.  Mostly this consists of ensuring that the new hotstring doesn’t conflict with any existing ones. 
12.	The Exam Button opens the Exam Pane (as seen in the image).  When the Pane is open, the button shows “Done.”   Right-Click, or Shift-Click will open a Control Panel, which has several links to other tools. 
13.	The Spell Button sends the content of the Replacement Box to LanguageTool.org’s API and returns spelling and/or grammar suggestions.  
14.	If a word from the Replacement, Misspells, or Fixes box is selected, the Look Button will search the on-board WordNet dictionary for a definition.  Right-click uses the online GCIDE dictionary.
15.	Cancel hides the hh2 form and puts the previous content of the clipboard back.  Esc does the same thing. 
(Note that the following items are part of the Exam Pane and are only for refining autocorrect entries.  They are not useful for boilerplate template hotstrings.)
16.	The tall Left-Trim Button simultaneously trims a single letter from the  beginning of the trigger string and the replacement string.
17.	The tall Right-Trim Button trims a letter from the ends.
18.	The wide Undo button will undo the trims.  Ctrl-z also does.  Shift-Click or Shift-Ctrl-z will undo all trims, resetting the originally-captured trigger and replacement.  
19.	The Delta String shows which parts of the autocorrect entry get changed, and which parts can safely be trimmed.
20.	The Radio Buttons set the hotstring as a word-beginning, word-ending, or word-middle item.  The Options Box is automatically updated to match.  Right-Click any item to unselect all of them.
21.	Web Frequencies are the sum of the number of times the words in the Misspells or Fixes lists occur on the internet.  This helps to see if the words are common English words or if they are obscure.  The Fixes [] and Misspells [] just shows the number of items in each list.
22.	The Misspells Box lists all of the English words that correspond to the text string in the Trigger Box and hence would be misspelled from the use of the autocorrection item as it is.  
23.	The Fixes Box is a list of the words that can potentially be fixed by the current autocorrect item.   Trimming, or changing the radios, will change the number of Misspells and Fixes.  

Please see the User Manual for more information.   https://github.com/kunkel321/AutoCorrect2

# Icon on main AutoCorrect2 parent folder:
- The files in the sub folders all use relative folder paths, so you should be able to unzip the AutoCorrect2.zip and put the folder anywhere.  Note however, that the desktop.ini that Windows uses for the custom icon location has to be an absolute path.  Mine is "C:\Users\steve\OneDrive\Documents\GitHub\AutoCorrect2\Resources\Icons\AhkBluePsicon.ico".  You should change that to the path on your own computer. 
