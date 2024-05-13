This is a version of the AutoHotkey script, AutoCorrect.ahk.  It is written in AHK v2 code, and so is "AutoCorrect2.ahk."  Please note that the file, "AutoCorrect2.exe" is not a compiled version of the .ahk file.  Rather, it is a copy of AutoHotKey.exe that I got from the AutoHotkey site, and renamed, to match the .ahk file.  Keeping the two in the same folder allows a person to run the code "portably," right from the folder.  The Manual Correction Logger (MCLogger) ahk and exe files work similarly.  Neither the AutoCorrect.ahk, nor the MCLogger.ahk files, should ever be compiled, otherwise, they won't be ale to append new autocorrect hotstrings to themselves. 

Later update:  The log of manual corrections now gets saved to a text file (MCLog.txt), which is separate from the MCLogger.ahk script, so I guess you could compile MCLogger.ahk if you wanted to.  The library of autocorrect hotstrings has also been separated from the main "AutoCorrect2.ahk" code, and put in HotstringLib.ahk.  HotstringLib.ahk is #Included in AutoCorrect.ahk, so it doesn't need to be run as a separate process.  

Steve Kunkel
(kunkel321)

