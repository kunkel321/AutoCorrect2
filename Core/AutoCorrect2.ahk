#SingleInstance Force
#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)

; ========================================
; This is AutoCorrect2, with HotstringHelper2
; A comprehensive tool for creating, managing, and analyzing hotstrings
; Version: 12-13-2025
; Author: kunkel321
; Thread on AutoHotkey forums:
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=120220
; Project location on GitHub (new versions will be on GitHub)
; https://github.com/kunkel321/AutoCorrect2
; ========================================

; ============== OPTIONAL INCLUDES ==============
; These files need to be in the same directory or properly referenced
; The "*i" prevents an error if the file doesn't exist.
#Include "*i ..\Includes\DateTool.ahk"              ;  Calendar tool with holidays -- Optional
#Include "*i ..\Includes\PrinterTool.ahk"           ;  Shows list of installed printers -- Optional 
#Include "*i ..\Includes\HotstringQuickLookup.ahk"  ;  Get usage stats for selected hotstring --Optional
#Include "*i ..\Includes\ChatGptWordLookup.ahk"     ;  ChatGPT-based word definitions -- Optional

#HotIf Config.EnableDragTools ;  So users can permanently disable DragTools via acSettings.ini
    #Include "*i ..\Includes\DragTools.ahk"      ;  Mouse right-click/drags trigger things   -- Optional 
#HotIf Config.EnableMoveResizeTools 
    #Include "*i ..\Includes\MoveResizeTools.ahk"      ;  Alt+Ctrl left/right mouse drag on Window   -- Optional 
#HotIf 
; There are required includes defined below the class Config code.

;=============== PERSONAL ITEMS =================
; If user has custom hotstrings, they can optionally keep them in a "PersonalHotstrings.ahk" file.
#Include "*i ..\Includes\PersonalHotstrings.ahk" ;  -- Optional


; =============== CONFIGURATION ===============
; The configuration is now centralized in acSettings.ini
; This class handles loading, validating, and providing defaults for all settings
class Config {
    ; ===== File Paths (Constants) =====
    static SettingsFile := "..\Data\acSettings.ini"
    
    ; ===== Constants =====
    static ScriptName := "AutoCorrect2.ahk"
    static HHWindowTitle := A_UserName "'s Hotstring Helper"
    static ValidOkMessage := "-no problems found" 
    static PilcrowSymbol := "¶" ; Keep symbols defined here because the 
    static DotSymbol := "• " ; Unicode characters don't get saved by
    static TabSymbol := "⟹ " ; the ini file correctly.
    
    ; ===== Settings Properties (Loaded from INI) =====
    ; NOTE: AHK v2 requires static properties to have an initial value.
    ; These defaults are used if the INI file doesn't exist or is incomplete.
    ; During normal operation, LoadSettings() overwrites these with INI values.
    ; This serves as both a language requirement AND a fallback safety mechanism.
    
    ; General Configuration
    static HotstringLibrary := "HotstringLib.ahk"
    static NewTemporaryHotstrLib := "HotstringLib (1).ahk"
    static RemovedHsFile := "..\Data\RemovedHotstrings.txt"
    static AutoCorrectsLogFile := "..\Data\AutoCorrectsLog.txt"
    static ACLogContinuousFile := "..\Data\ACLogContinuous.txt"
    static ErrContextLog := "..\Data\ErrContextLog.txt"
    static ACLogAnalyzer := "..\Tools\ACLogAnalyzer.exe"
    static SettingsManager := "..\Tools\SettingsManager.exe"
    static CODE_ERROR_LOG := 0
    static CODE_DEBUG_LOG := 0
    
    ; Hotkeys
    static HotstringHelperActivationHotkey := "#h"
    static AutoCorrect2EditThisScriptHk := "^+e"
    static SystemUpTimeHk := "!+u"
    static MCLoggerRunAnalysisHotkey := "#^+q"
    static MCLoggerSneakPeekHotkey := "#+q"
    static ACLogAnalyzerHk := "!^+q"

    ; Includes
    static EnableDragTools := 1
    static EnableMoveResizeTools := 1
    
    ; UI Settings
    static DefaultFontSize := "11"
    static LargeFontSize := "15"
    static DefaultWidth := 366
    static HeightSizeIncrease := 300
    static WidthSizeIncrease := 400
    static InitialFocusTarget := "auto"

    ; BoilerPlate Options
    static DefaultBoilerPlateOpts := ""
    static BoilerplatePrefix := ";"
    static BoilerplateSuffix := ""
    static FirstLettersToInclude := 5
    static MinWordLength := 2
    
    ; AutoCorrect Options
    static DefaultAutoCorrectOpts := "B0X"
    static MakeFuncByDefault := 1
    static AutoCommentWithFreqAndStats := 1
    static AutoEnterNewEntry := 1
    
    ; Word Lists
    static WordListFile := "..\Data\GitHubComboList249k.txt"
    static FrequencyListFile := "..\Data\unigram_freq_list_filtered_88k.csv"
    
    ; Editor
    static DefaultEditor := "Notepad.exe"
    static EditorPath := ""
    
    ; Appearance (Colors)
    static FormColor := "0xE5E4E2" ; Overwritten if ColorThemeSettings.ini is present.
    static FontColor := "c0x1F1F1F" ; Overwritten if ColorThemeSettings.ini is present.
    static ListColor := "0xFFFFFF" ; Overwritten if ColorThemeSettings.ini is present.
    static Brightness := 128
    static LightGreen := "b8f3ab"
    static DarkGreen := "0d3803"
    static LightRed := "fd7c73"
    static DarkRed := "B90012"
    static ValidityDialogGreen := ""
    static ValidityDialogRed := ""
    
    ; AutoCorrect System Settings
    static EnableLogging := 1
    static BeepOnAutoCorrection := 1
    static CapFixTwoLetterWords := 1
    static PrecedingWordCount := 6
    static FollowingWordCount := 4
    static FollowingWordTimeout := 8
    static AppSkiplist := []
    static WinSkiplist := []
    static AutoCorrectionsEnabled := true
    static BeepOnContextLog := 1
    static BeepOnCapFix := 1


    ; ============================================================
    ; ===== INITIALIZATION =====
    ; ============================================================
    
    static Init() {
        ; Ensure settings file exists, creating defaults if needed
        this.EnsureSettingsFileExists()
        
        ; Load all settings from ini file
        this.LoadSettings()
        
        ; Load color theme settings (kept separate for UI isolation)
        this.LoadThemeColors()
        
        ; Perform any necessary calculations and validations
        this.CalculateBrightness()
        this.ValidityDialogGreen := this.Brightness < 128 ? "c" Config.LightGreen : "c" Config.DarkGreen 
        this.ValidityDialogRed := this.Brightness < 128 ? "c" Config.LightRed  : "c" Config.DarkRed
        
        ; ; Extract just the filename from the path  ; <----- no longer used? 
        ; SplitPath this.WordListFile, &WordListName
        ; this.WordListName := WordListName
        
        ; Try to find VSCode if available
        this.EditorPath := "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
        if !FileExist(this.EditorPath)
            this.EditorPath := this.DefaultEditor
    }

    ; ============================================================
    ; ===== SETTINGS FILE MANAGEMENT =====
    ; ============================================================
    
    static EnsureSettingsFileExists() {
        if !FileExist(this.SettingsFile) {
            this.CreateDefaultSettingsFile()
        }
    }
    
    static CreateDefaultSettingsFile() {
        template := this.GetDefaultTemplate()
        
        ; Create directory if it doesn't exist
        settingsDir := "..\Data"
        if !FileExist(settingsDir)
            DirCreate(settingsDir)
        
        FileAppend(template, this.SettingsFile)
        
        ; Notify user that settings file was created
        acMsgBox.show("A new settings file has been created at:`n"
            . this.SettingsFile 
            . "`n`nYou can edit this file to customize AutoCorrect2's behavior."
            . "`n`nPress Ctrl+E to edit AutoCorrect2.ahk and check the documentation."
            ,, 4160)
    }
    
    static GetDefaultTemplate() {
        defaultIni := "
        (
; ============================================================
; AutoCorrect2 Suite 'asSettings.ini' File
; ini File template version date:  11-25-2025
; ============================================================
; Edit the values below to customize behavior and appearance of
; AutoCorrect2.ahk and related tools.  Keys can be edited directory,
; or by using the SettingsManager tool.  After editing, reload/restart
; the affected script for changes to take effect.
; ============================================================

[Files]
; File names only.  Relative paths are in the code of the various scripts.
; Many of these are accessed by multiple tools.
; HotstringLibrary is your personal library.
HotstringLibrary=HotstringLib.ahk
; NewTemporaryHotStrLib is the new version from GitHub. Rename to fit your workflow.
NewTemporaryHotstrLib=HotstringLib (1).ahk
RemovedHsFile=RemovedHotstrings.txt
AutoCorrectsLogFile=AutoCorrectsLog.txt
ACLogContinuousFile=ACLogContinuous.txt
ErrContextLog=ErrContextLog.txt
ACLogAnalyzer=ACLogAnalyzer.exe
WordListFile=GitHubComboList249k.txt
FrequencyListFile=unigram_freq_list_filtered_88k.csv
MCLoggerPath=MCLogger.exe
MCLogFile=ManualCorrectionsLog.txt
AutoCorrect2Script=AutoCorrect2.ahk
SettingsManager=SettingsManager.exe

[Hotkeys]
HotstringHelperActivationHotkey=#h
AutoCorrect2EditThisScriptHk=^+e
SystemUpTimeHk=!+u
MCLoggerRunAnalysisHotkey=#^+q
MCLoggerSneakPeekHotkey=#+q
ACLogAnalyzerHk=!^+q

[Shared]
; Default editor for opening scripts (usually VSCode or Notepad).
DefaultEditor=Notepad.exe
; Define light/dark red/green.  (no 'c') 
LightGreen=b8f3ab
DarkGreen=0d3803
LightRed=fd7c73
DarkRed=B90012

[HotstringHelper]
; Enable/disable debug (very verbose) and error logging (1=yes, 0=no).
CODE_DEBUG_LOG=0
CODE_ERROR_LOG=0
; Optional Include
EnableDragTools=1
EnableMoveResizeTools=1
; Large font size for emphasis of trigger and replacement boxes (no 's').
DefaultFontSize=11
LargeFontSize=15
; Default width of main window (recommend: 366).
DefaultWidth=366
; Height/Width increase for larger boilerplate texts when 'Make Bigger' button is pressed.
HeightSizeIncrease=300
WidthSizeIncrease=400
; Default focus to options|trigger|replacement|comment|auto 
InitialFocusTarget=auto
; Default hotstring options for boilerplate/template triggers.
; Prefix/Suffix for boilerplate triggers (leave blank for none)
; When creating an anagram for the boilerplate text...
DefaultBoilerPlateOpts=
BoilerplatePrefix=;
BoilerplateSuffix=
FirstLettersToInclude=5
MinWordLength=2
; Do you use the f(), or prefer vanilla ahk hotstrings? Check 'Make Function' box by default? (1=yes, 0=no)
; Default options for autocorrect entries -- B0X for f() use.  That's B zero X.  Don't use if MakeFuncByDefault=0
MakeFuncByDefault=1
DefaultAutoCorrectOpts=B0X
; Add frequency/stats comments to new entries? This is used by the Ctrl-F3 Stats dialog. (1=yes, 0=no)
AutoCommentWithFreqAndStats=1
; Try to auto-type replacement for new AutoCorrect item, into active field. (1=yes, 0=no)
AutoEnterNewEntry=1

[ACSystem]
; Master switch to enable/disable all logging (1=yes, 0=no).
EnableLogging=1
; Beep when an autocorrection is made (1=yes, 0=no).
; Beep when a backspaced autocorrection's context is logged (1=yes, 0=no).
BeepOnCorrection=1
BeepOnContextLog=1
; Number of words to cache before, and additional words to wait for, after an autocorrection (for context logging).
; Also amount of time to wait for those following words.
PrecedingWordCount=8
FollowingWordCount=6
FollowingWordTimeout=12
; "SkipList" Apps where AutoCorrect should NOT trigger. Separate multiple apps with commas (no spaces).
AppSkiplist=PipeWalker.exe,Roblox.exe,RimWorldWin64.exe
WinSkiplist=Hotstring Quick Lookup
; Items for the AUto-COrrect TWo COnsecutive CApitals code
BeepOnCapFix=1
CapFixTwoLetterWords=1

[MCLogger]
; Show tooltip/Beep every time a hotstring pattern is captured (1=yes, 0=no).
ShowEachHotString=1
BeepEachHotString=1
; Collect log items in RAM, then save to disk this often (in minutes).
; Stop collecting if no new pattern matches for this many intervals (intervals will auto-restart on next manual correction).
SaveIntervalMinutes=10
IntervalsBeforeStopping=2
; Export directly to HotString Helper2 GUI (1=yes, 0=append to AutoCorrect script)
SendToHH=1
; Also save full report to Windows Clipboard (1=yes, 0=no). Warning: does not restore previous clipboard contents.
SaveFullToClipboard=1
; When removing old single-occurrence items, only remove strings older than this many days.
AgeOfOldSingles=90
; When clicking 'Cull and Append', close the list each time (0) or keep it open (1).
KeepReportOpen=1

[ACLogAnalyzer]
; Importance weight for high-frequency items in weight calculation (0-50, 0=not important).
FreqImportance=50
; Minimum threshold for consideration when weighing items. Zero means consider them all.
IgnoreFewerThan=0
; Copy hotstring to clipboard when item is selected--Facilitates sending to HH (1=yes, 0=no).
CopyHotstringOnSelect=1
; Keep window pinned to top by default (1=yes, 0=no).
PinToTop=1
; Enable error logging to file.  Not AutoCorrection errors, but ACLogAnalyzer app runtime errors (1=yes, 0=no).
EnableErrorLogging=1
; Skip lines before this line number when reading log file.
StartLine=7
; Date format for culled items (MM-dd-yyyy, etc.).
CullDateFormat=MM-dd-yyyy

[Defunctionizer]
; if you purge the comments, then AutoCorrect2's ; Ctrl+F3 "Potential Fixes Report" will stop working correctly.
keepComments=0
        )"
        return defaultIni
    }


    ; ============================================================
    ; ===== SETTINGS LOADING =====
    ; ============================================================
    
    static LoadSettings() {
        if !FileExist(this.SettingsFile)
            return
        
        ; [Files] Section
        this.HotstringLibrary           := this.ReadIni("Files", "HotstringLibrary", "HotstringLib.ahk")
        this.NewTemporaryHotstrLib      := this.ReadIni("Files", "NewTemporaryHotstrLib", "HotstringLib (1).ahk")
        this.RemovedHsFile              := "..\Data\" this.ReadIni("Files", "RemovedHsFile", "..\Data\RemovedHotstrings.txt")
        this.AutoCorrectsLogFile        := "..\Data\" this.ReadIni("Files", "AutoCorrectsLogFile", "..\Data\AutoCorrectsLog.txt")
        this.ACLogContinuousFile        := "..\Data\" this.ReadIni("Files", "ACLogContinuousFile", "..\Data\ACLogContinuous.txt")
        this.ErrContextLog              := "..\Data\" this.ReadIni("Files", "ErrContextLog", "..\Data\ErrContextLog.txt")
        this.WordListFile               := "..\Data\" this.ReadIni("Files", "WordListFile", "GitHubComboList249k.txt")
        this.FrequencyListFile          := "..\Data\" this.ReadIni("Files", "FrequencyListFile", "unigram_freq_list_filtered_88k.csv")
        this.ACLogAnalyzer              := "..\Tools\" this.ReadIni("Files", "ACLogAnalyzer", "ACLogAnalyzer.exe")
        this.SettingsManager            := "..\Tools\" this.ReadIni("Files", "SettingsManager", "SettingsManager.exe")

        ; [Shared] Section
        ; Editor
        this.DefaultEditor              := this.ReadIni("Shared", "DefaultEditor", "Notepad.exe")
        ; Green and Red
        this.LightGreen                 := this.ReadIni("Shared", "LightGreen", "b8f3ab")
        this.DarkGreen                  := this.ReadIni("Shared", "DarkGreen", "0d3803")
        this.LightRed                   := this.ReadIni("Shared", "LightRed", "fd7c73")
        this.DarkRed                    := this.ReadIni("Shared", "DarkRed", "B90012")

        ; [Hotkeys] Section
        this.HotstringHelperActivationHotkey := this.ReadIni("Hotkeys", "HotstringHelperActivationHotkey", "#h")
        this.AutoCorrect2EditThisScriptHk := this.ReadIni("Hotkeys", "AutoCorrect2EditThisScriptHk", "^+e")
        this.SystemUpTimeHk := this.ReadIni("Hotkeys", "SystemUpTimeHk", "!+u")
        this.MCLoggerRunAnalysisHotkey := this.ReadIni("Hotkeys", "MCLoggerRunAnalysisHotkey", "#^+q")
        this.MCLoggerSneakPeekHotkey := this.ReadIni("Hotkeys", "MCLoggerSneakPeekHotkey", "#+q")
        this.ACLogAnalyzerHk := this.ReadIni("Hotkeys", "ACLogAnalyzerHk", "#+q")
        
        ; [HotstringHelper] Section   
        ; General
        this.CODE_DEBUG_LOG             := this.ReadIni("HotstringHelper", "CODE_DEBUG_LOG", 0)
        this.CODE_ERROR_LOG             := this.ReadIni("HotstringHelper", "CODE_ERROR_LOG", 0)
        ; UI
        this.DefaultFontSize            := "s" this.ReadIni("HotstringHelper", "DefaultFontSize", "11")
        this.LargeFontSize              := "s" this.ReadIni("HotstringHelper", "LargeFontSize", "15")
        this.DefaultWidth               := this.ReadIni("HotstringHelper", "DefaultWidth", 366)
        this.HeightSizeIncrease         := this.ReadIni("HotstringHelper", "HeightSizeIncrease", 300)
        this.WidthSizeIncrease          := this.ReadIni("HotstringHelper", "WidthSizeIncrease", 400)
        this.InitialFocusTarget         := this.ReadIni("HotstringHelper", "InitialFocusTarget", "auto")
        ; BoilerPlate
        this.DefaultBoilerPlateOpts     := this.ReadIni("HotstringHelper", "DefaultBoilerPlateOpts", "")
        this.BoilerplatePrefix          := this.ReadIni("HotstringHelper", "BoilerplatePrefix", ";")
        this.BoilerplateSuffix          := this.ReadIni("HotstringHelper", "BoilerplateSuffix", "")
        this.FirstLettersToInclude      := this.ReadIni("HotstringHelper", "FirstLettersToInclude", 5)
        this.MinWordLength              := this.ReadIni("HotstringHelper", "MinWordLength", 2)
        ; AutoCorrect
        this.DefaultAutoCorrectOpts     := this.ReadIni("HotstringHelper", "DefaultAutoCorrectOpts", "B0X")
        this.MakeFuncByDefault          := this.ReadIni("HotstringHelper", "MakeFuncByDefault", 1)
        this.AutoCommentWithFreqAndStats := this.ReadIni("HotstringHelper", "AutoCommentWithFreqAndStats", 1)
        this.AutoEnterNewEntry          := this.ReadIni("HotstringHelper", "AutoEnterNewEntry", 1)

        ; [ACSystem] Section
        ; AutoCorrectSystem
        this.EnableLogging              := this.ReadIni("ACSystem", "EnableLogging", 1)
        this.BeepOnAutoCorrection           := this.ReadIni("ACSystem", "BeepOnAutoCorrection", 1)
        this.BeepOnContextLog           := this.ReadIni("ACSystem", "BeepOnContextLog", 1)
        this.PrecedingWordCount         := this.ReadIni("ACSystem", "PrecedingWordCount", 6)
        this.FollowingWordCount         := this.ReadIni("ACSystem", "FollowingWordCount", 4)
        this.FollowingWordTimeout       := this.ReadIni("ACSystem", "FollowingWordTimeout", 8)
        ; Skiplist (Apps and Windows)
        SkiplistString                  := this.ReadIni("ACSystem", "AppSkiplist", "")
        this.AppSkiplist                := StrSplit(SkiplistString, ",")
        WinSkiplistString               := this.ReadIni("ACSystem", "WinSkiplist", "")
        this.WinSkiplist                := StrSplit(WinSkiplistString, ",")
        this.BeepOnCapFix               := this.ReadIni("ACSystem", "BeepOnCapFix", 1)
        this.CapFixTwoLetterWords       := this.ReadIni("ACSystem", "CapFixTwoLetterWords", 1)
    }

    ; ============================================================
    ; ===== THEME COLORS (kept separate from app settings) =====
    ; ============================================================
    
    static LoadThemeColors() {
        if FileExist("..\Data\colorThemeSettings.ini") {
            ctSettingsFile := "..\Data\colorThemeSettings.ini"
            ; --- Get current colors from ini file. 
            this.FontColor := "c" IniRead(ctSettingsFile, "ColorSettings", "fontColor")
            this.ListColor := IniRead(ctSettingsFile, "ColorSettings", "listColor")
            this.FormColor := IniRead(ctSettingsFile, "ColorSettings", "formColor")
        }
        ; If theme file doesn't exist, defaults are already set in static declarations
    }


    ; ============================================================
    ; ===== HELPER METHODS =====
    ; ============================================================
    
    ; Generic ini reader with fallback defaults and type conversion
    static ReadIni(section, key, default := "") {
        if !FileExist(this.SettingsFile)
            return default
        
        ; Use a unique sentinel value to distinguish between "key not found" and "key is empty"
        ; This allows optional hotkeys to be saved as blank values
        sentinel := "<<<KEY_NOT_FOUND>>>"
        value := IniRead(this.SettingsFile, section, key, sentinel)
        
        ; Only return default if key was not found in INI file
        if (value = sentinel)
            return default
        
        ; If default is numeric (Integer or Float), convert the read value to integer
        if (Type(default) = "Integer" or Type(default) = "Float") {
            return Integer(value)
        }
        
        ; Return the actual value (even if it's empty string, which allows optional hotkeys)
        return value
    }
    
    ; Calculate brightness from form color
    static CalculateBrightness() {
        formColor := this.FormColor
        
        ; Convert hex string to number if needed
        if Type(formColor) = "String" && InStr(formColor, "0x") {
            formColor := Integer("0x" SubStr(formColor, 3))
        }
        
        if formColor is Number {
            r := (formColor >> 16) & 0xFF
            g := (formColor >> 8) & 0xFF
            b := formColor & 0xFF
            this.Brightness := (r * 299 + g * 587 + b * 114) / 1000
        }
        
        return this.Brightness
    }
}

; Check if a Skiplisted app is currently the active (focused) window
AutoCorrectionsActivelyRunning() {
    ; Check if skiplisted app is focused
    if IsSkiplistedFocused()
        return false
    ; Check if user has manually disabled autocorrections
    if !Config.AutoCorrectionsEnabled
        return false
    ; Autocorrections are active
    return true
}

IsSkiplistedFocused() {
    ; Check app skiplist (by process name)
    activeProcessName := WinGetProcessName("A")
    for processName in Config.AppSkiplist {
        if (activeProcessName = processName)
            return true
    }
    
    ; Check window skiplist (by window title, partial match)
    for windowTitle in Config.WinSkiplist {
        if WinActive(windowTitle)
            return true
    }
    
    return false
}

; ============== REQUIRED INCLUDES ==============
; These files need to be in the same directory or properly referenced
#Include "..\Includes\AutoCorrectSystem.ahk"  ;  Autocorrection module -- REQUIRED

#HotIf AutoCorrectionsActivelyRunning() ; Only if no Skiplisted apps are active and autocorrections are enabled.
    #Include "HotstringLib.ahk"       ;  Library of hotstrings -- REQUIRED
#HotIf

#Include "..\Includes\AcMsgBox.ahk" ; For custom msgbox system.

; Initialize configuration
Config.Init()
Debug("======[SCRIPT START]======")

; =============== TRAY MENU SETUP ===============
SetupTrayMenu() {
    acMenu := A_TrayMenu
    acMenu.Delete
    acMenu.SetColor("Silver")
    
    acMenu.Add(Config.ScriptName, (*) => Utils.CheckClipboard()) ; Opens hh2 gui.
    acMenu.SetIcon(Config.ScriptName, "..\Resources\Icons\AhkBluePsicon.ico")
    acMenu.Default := Config.ScriptName
    
    acMenu.Add("Edit This Script", (*) => EditThisScript())
    acMenu.SetIcon("Edit This Script", "..\Resources\Icons\edit-Blue.ico")
    
    acMenu.Add("Hotstring Library", (*) => OpenHotstringLibrary())
    acMenu.SetIcon("Hotstring Library", "..\Resources\Icons\library-Blue.ico")
   
    acMenu.Add("Run Printer Tool", (*) => RunPrinterTool())
    acMenu.SetIcon("Run Printer Tool", "..\Resources\Icons\printer-Blue.ico")

    acMenu.Add("Show Calendar", (*) => RunDateTool())
    acMenu.SetIcon("Show Calendar", "..\Resources\Icons\calendar-Blue.ico")
    
    acMenu.Add("System Up Time", (*) => UpTime())
    acMenu.SetIcon("System Up Time", "..\Resources\Icons\clock-Blue.ico")
    
    acMenu.Add("Reload Script", (*) => Reload())
    acMenu.SetIcon("Reload Script", "..\Resources\Icons\repeat-Blue.ico")
    
    acMenu.Add("List Lines Debug", (*) => ListLines())
    acMenu.SetIcon("List Lines Debug", "..\Resources\Icons\ListLines-Blue.ico")
    
    acMenu.Add("Enable AutoCorrections", (*) => ToggleAutoCorrections())
    if Config.AutoCorrectionsEnabled
        acMenu.Check("Enable AutoCorrections")
    
    acMenu.Add("Exit Script", (*) => ExitApp())
    acMenu.SetIcon("Exit Script", "..\Resources\Icons\exit-Blue.ico")

    acMenu.Add("Start with Windows", (*) => StartUpAC()) ; Add menu item at the bottom.
    if FileExist(A_Startup "\" Config.ScriptName ".lnk")
        acMenu.Check("Start with Windows")
    ; This function is only accessed via the systray menu item.  It toggles adding/removing
    ; link to this script in Windows Start up folder.  Applies custom icon too.
    StartUpAC(*) {	
        if FileExist(A_Startup "\" Config.ScriptName ".lnk") {
            FileDelete(A_Startup "\" Config.ScriptName ".lnk")
            acMsgBox.show("" Config.ScriptName " will NO LONGER auto`nstart with Windows.",, "icon!")
        } Else {
            FileCreateShortcut(A_WorkingDir "\" StrReplace(Config.ScriptName, ".ahk") ".exe", A_Startup "\" Config.ScriptName ".lnk"
            , A_WorkingDir, "", "", A_ScriptDir "\..\Resources\Icons\AhkBluePsicon.ico")
            acMsgBox.show(Config.ScriptName " will now auto`nstart with Windows.",, "icon!")
        }
        Reload()
    }

    ; This function toggles AutoCorrections on/off via systray menu
    ToggleAutoCorrections(*) {
        Config.AutoCorrectionsEnabled := !Config.AutoCorrectionsEnabled
        acMenu := A_TrayMenu
        if Config.AutoCorrectionsEnabled {
            acMenu.Check("Enable AutoCorrections")
            acMsgBox.show("AutoCorrections are now ENABLED", , "icon!")
        } else {
            acMenu.Uncheck("Enable AutoCorrections")
            acMsgBox.show("AutoCorrections are now DISABLED", , "icon!")
        }
    }
}

If (Config.AutoCorrect2EditThisScriptHk != "") {
    Hotkey(Config.AutoCorrect2EditThisScriptHk,EditThisScript)
}
EditThisScript(*) {	; Open AutoCorrect2 script in VSCode
	Try
		Run Config.EditorPath " "  Config.ScriptName
	Catch
		acMsgBox.show 'cannot run ' Config.ScriptName
}

OpenHotstringLibrary(*) {
    Try
        Run Config.EditorPath " "  Config.HotstringLibrary
    Catch
        acMsgBox.show 'cannot run ' Config.EditorPath ' or cannot run ' Config.HotstringLibrary
}

; PrinterTool and DateTool are #Included, so we could call the functions directly, but we would 
; get an error if the script ever wasn't included.  Sending the hotkey prevents this.
RunPrinterTool(*) {
    Send "!+p"
}
RunDateTool(*) {
    Send "!+d"
}

If (Config.SystemUpTimeHk != "")
    Hotkey(Config.SystemUpTimeHk, UpTime)
UpTime(*) { ; Uptime -- time since Windows restart
	; Get uptime using math
	ms := A_TickCount // 1000  ; Convert to seconds
	d := ms // 86400
	h := Mod(ms // 3600, 24)
	m := Mod(ms // 60, 60)
	s := Mod(ms, 60)
	
	uptime := RTrim((d ? d . " day" . (d = 1 ? "" : "s") . ", " : "")
	                . (h ? h . " hour" . (h = 1 ? "" : "s") . ", " : "")
	                . (m ? m . " minute" . (m = 1 ? "" : "s") . ", " : "")
	                . (s ? s . " second" . (s = 1 ? "" : "s") : ""), ", ")
	
	; Check for pending updates
	hasPendingUpdates := false
	try {
		RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "RebootRequired")
		hasPendingUpdates := true
	} catch {
	}
	
	; Build message
	messageText := "Uptime:`n" . uptime
	if (hasPendingUpdates) {
		messageText .= "`n`n⚠ Windows updates are pending"
	}
	
	buttons := ["OK", "Restart"]
	
	; Show dialog
	result := acMsgBox.Show(messageText, "System Uptime", {icon: "iconi", buttons: buttons})
	
	if (result == "Restart") {
        result := acMsgBox.Show("Really Restart Computer?", "Confirmation", {icon: "icon!", buttons: ["Confirm", "Cancel"]})
		if (result == "Confirm") 
            Shutdown(2)
	}
}

; Initialize tray menu
SetupTrayMenu()

; Startup announcement
SoundBeep(900, 200)
SoundBeep(1100, 150)

; Initialize BackspaceContextLogger after startup is complete
SetTimer(() => BackspaceContextLogger.Start(), 1000)  ; Start after 1 second delay


; Main application loop
; The script continues running, processing hotstrings and handling events

; Note: Your hotstrings are defined in HotstringLib.ahk and call the f() function
; from AutoCorrectSystem.ahk when triggered.
; Example hotstring:
; :B0X:teh::f("the") 

; =============== GLOBAL VARIABLES ===============
; These variables track state throughout the application

class State {
    ; UI State
    static ExamPaneOpen := 0
    static ControlPaneOpen := 0
    static FormBig := 0
    static SymbolsVisible := 0
    static CurrentEdit := 0
    
    ; History for undo
    static TriggerHistory := []
    static ReplacementHistory := []
    
    ; Original values for restoration
    static OrigTrigger := ""
    static OrigReplacement := ""
    static TrigNeedle_Orig := ""
    
    ; Statistics
    static TriggerMatches := 0
    static ReplacementMatches := 0
    
    ; Clipboard state
    static ClipboardOld := ""
    
    ; Target window for auto-entry
    static TargetWindow := 0
    static OrigTriggerTypo := ""
    
    ; Type of content detected
    static IsBoilerplate := 0
    
    ; Dictionary initialized state
    static DictInitialized := 0
    
    ; Reset state to defaults
    static Reset() {
        this.ExamPaneOpen := 0
        this.ControlPaneOpen := 0
        this.FormBig := 0
        this.SymbolsVisible := 0
        
        this.TriggerHistory := []
        this.ReplacementHistory := []
        
        this.OrigTrigger := ""
        this.OrigReplacement := ""
        this.TrigNeedle_Orig := ""
        
        this.TriggerMatches := 0
        this.ReplacementMatches := 0
        
        this.IsBoilerplate := 0
    }
}

; =============== UI COMPONENT CREATION ===============

class UI {
    static MainForm := 0
    static Controls := Map()
    static ListBackground := ""
    static DeltaColor := ""
    static CommentColor := ""
    
    ; Initialize and build the main UI
    static Init() {
        ; Create main GUI
        this.MainForm := Gui("", Config.HHWindowTitle)
        this.MainForm.Opt("-MinimizeBox +AlwaysOnTop")
        
        try this.MainForm.BackColor := Config.FormColor
        
        ; Set font settings
        fontColor := Config.FontColor != "" ? "c" SubStr(Config.FontColor, -6) : ""
        this.MainForm.SetFont(Config.DefaultFontSize " " fontColor)
        
        ; Set background color for edit controls - defined once for the whole class
        this.ListBackground := Config.ListColor != "" ? "Background" Config.ListColor : ""
        
        ; Build UI sections
        this._CreateTriggerSection()
        this._CreateReplacementSection()
        this._CreateCommentSection()
        this._CreateButtonSection()
        this._CreateExamPane()
        this._CreateControlPane()
        
        ; Set up event handlers
        this._SetupEventHandlers()
        
        ; Hide panes by default
        UIActions.ShowHideExamPane(false)
        UIActions.ShowHideControlPane(false)
    }

    ; Create the trigger string section
    static _CreateTriggerSection() {
        this.MainForm.AddText("y4 w30", "Options")
        this.Controls["TriggerLabel"] := this.MainForm.AddText("x+40 w250", "Trigger String")
        
        ; Set background color for edit controls
        this.ListBackground := Config.ListColor != "" ? "Background" Config.ListColor : ""
        
        ; Add the option and trigger input fields
        this.Controls["OptionsEdit"] := this.MainForm.AddEdit(this.ListBackground " yp+20 xm+2 w70 h24")
        this.Controls["TriggerEdit"] := this.MainForm.AddEdit(this.ListBackground " x+18 w" Config.DefaultWidth - 91)

        ; Add the help button
        this.Controls["HelpButton"] := this.MainForm.AddButton("x" (Config.DefaultWidth - 10) " y2 w25 h20", "?")
        this.Controls["HelpButton"].OnEvent("Click", (*) => HelpSystem.ShowHelp(true))
    }
    
	; Create the replacement string section
	static _CreateReplacementSection() {
		this.MainForm.AddText("xm", "Replacement")
		
		; Set smaller font for the toggle buttons
		this.MainForm.SetFont("s9")
		
		; Add size toggle and symbols toggle buttons
		this.Controls["SizeToggle"] := this.MainForm.AddButton("x+75 yp-5 h8", "Make Bigger")
		this.Controls["SymbolToggle"] := this.MainForm.AddButton("x+5 h8", "Show Symbols")
		
		; Reset font size
		this.MainForm.SetFont(Config.DefaultFontSize)
		
		; Set background color for edit controls (copied from _CreateTriggerSection)
		this.ListBackground := Config.ListColor != "" ? "Background" Config.ListColor : ""
		
		; Add the replacement edit control
		this.Controls["ReplacementEdit"] := this.MainForm.AddEdit(this.ListBackground " +Wrap y+1 xs h100 w" Config.DefaultWidth)
	}
		
	; Create the comment section
	static _CreateCommentSection() {
		this.Controls["CommentLabel"] := this.MainForm.AddText("xm y182", "Comment")
		this.Controls["FunctionCheck"] := this.MainForm.AddCheckbox("x+70 y182", "Make as f() Function")
		
		; Set background color for edit controls (same as in other sections)
		this.ListBackground := Config.ListColor != "" ? "Background" Config.ListColor : ""
		
        CommentColor := Config.Brightness < 128 ? "00ff22" : "005a17" 
		this.Controls["CommentEdit"] := this.MainForm.AddEdit(this.ListBackground " c" CommentColor " xs y200 w" Config.DefaultWidth)
	}
    
    ; Create the action buttons
    static _CreateButtonSection() {
        buttonWidth := (Config.DefaultWidth / 6) - 4
        
        this.Controls["AppendButton"] := this.MainForm.AddButton("xm y234 w" buttonWidth, "Append")
        this.Controls["CheckButton"] := this.MainForm.AddButton("x+5 y234 w" buttonWidth, "Check")
        this.Controls["ExamButton"] := this.MainForm.AddButton("x+5 y234 w" buttonWidth, "Exam")
        this.Controls["SpellButton"] := this.MainForm.AddButton("x+5 y234 w" buttonWidth, "Spell")
        this.Controls["LookButton"] := this.MainForm.AddButton("x+5 y234 w" buttonWidth, "Look")
        this.Controls["CancelButton"] := this.MainForm.AddButton("x+5 y234 w" buttonWidth, "Cancel")
    }
    
    ; Create the examination pane (initially hidden)
    static _CreateExamPane() {
        Debug("In UI class, at top of _CreateExamPane()")
        ; Set font for delta string display
        this.MainForm.SetFont("s10")
        
        ; Add left/right trim buttons and delta string
        this.Controls["LeftTrimButton"] := this.MainForm.AddButton("xm h50 w" (Config.DefaultWidth / 8), ">>")
        
        this.MainForm.SetFont("s14")
        deltaColor := Config.brightness < 128 ? "00FFFF" : "191970" 
        this.Controls["DeltaString"] := this.MainForm.AddText("center c" deltaColor " x+1 w" (Config.DefaultWidth * 3 / 4), "")
        
        this.MainForm.SetFont("s10")
        this.Controls["RightTrimButton"] := this.MainForm.AddButton("x+1 h50 w" (Config.DefaultWidth / 8), "<<")
        
        ; Add radio buttons for match type
        this.MainForm.SetFont(Config.DefaultFontSize)
        this.Controls["BeginningRadio"] := this.MainForm.AddRadio("y+-18 x" (Config.DefaultWidth / 6) + 7, "&Beginnings")
        this.Controls["MiddleRadio"] := this.MainForm.AddRadio("x+5", "&Middles")
        this.Controls["EndingRadio"] := this.MainForm.AddRadio("x+5", "&Endings")
        
        ; Add undo button
        this.Controls["UndoButton"] := this.MainForm.AddButton("xm y+3 h26 w" Config.DefaultWidth, "Undo (+Reset)")
        this.Controls["UndoButton"].Enabled := false
        
        ; Add match list labels and edit boxes
        this.Controls["TriggerFreqLabel"] := this.MainForm.AddText("center y+4 h25 xm w" Config.DefaultWidth / 2, "Web Freq [0]")
        this.Controls["ReplacementFreqLabel"] := this.MainForm.AddText("center h25 x+5 w" Config.DefaultWidth / 2, "Web Freq [0]")
        this.Controls["TriggerMatchLabel"] := this.MainForm.AddText("center y+-2 h25 xm w" Config.DefaultWidth / 2, "Misspells [0]")
        this.Controls["ReplacementMatchLabel"] := this.MainForm.AddText("center h25 x+5 w" Config.DefaultWidth / 2, "Fixes [0]")
        
        this.Controls["TriggerMatchesEdit"] := this.MainForm.AddEdit(this.listBackground " y+0 xm h" Config.HeightSizeIncrease " w" Config.DefaultWidth / 2)
        this.Controls["ReplacementMatchesEdit"] := this.MainForm.AddEdit(this.listBackground " x+5 h" Config.HeightSizeIncrease " w" Config.DefaultWidth / 2)
    }
        
    ; Create the control pane (initially hidden)
    static _CreateControlPane() {
        Debug("In UI class, at top of _CreateControlPane()")
        ; Configuration for control panel buttons
        this.Controls["ControlPanelLabel"] := this.MainForm.AddText("center c" this.DeltaColor " ym+270 h25 xm w" Config.DefaultWidth, "Secret Control Panel!")
        
        this.MainForm.SetFont("s10")
        
        ; Initialize the buttons array
        this.controlButtons := []
        
        ; Add always-present buttons first
        this.controlButtons.Push({
            text: " Open HotString Library", 
            action: (*) => UIActions.OpenHotstringLibrary(),
            icon: A_ScriptDir "\..\Resources\Icons\library-Blue.ico"
        })
        
        if (Config.EnableLogging = 1) {
            this.controlButtons.Push({
                text: " Open AutoCorrection Log", 
                action: (*) => Run(Config.AutoCorrectsLogFile),
                icon: A_ScriptDir "\..\Resources\Icons\log-Blue.ico"
            })
            
            this.controlButtons.Push({
                text: " Analyze AutoCorrection Log !^+Q", 
                action: (*) => Run(Config.AcLogAnalyzer),
                icon: A_ScriptDir "\..\Resources\Icons\AcAnalysis.ico"
            })
            
            ; this.controlButtons.Push({
            ;     text: " Open AutoCorrection Continuous Log", 
            ;     action: (*) => Run(Config.ACLogContinuousFile),
            ;     icon: A_ScriptDir "\..\Resources\Icons\log-Blue.ico"
            ; })
            
            this.controlButtons.Push({
                text: " Open Backspace Context Log", 
                action: (*) => Run(Config.ErrContextLog),
                icon: A_ScriptDir "\..\Resources\Icons\log-Blue.ico"
            })
            
            this.controlButtons.Push({
                text: " Open Removed HotStrings List", 
                action: (*) => Run(Config.RemovedHsFile),
                icon: A_ScriptDir "\..\Resources\Icons\missing-Blue.ico"
            })
        }
        
        ; Add remaining buttons regardless of logging status
        this.controlButtons.Push({
            text: " Open Manual Correction Log", 
            action: (*) => Run("..\Data\ManualCorrectionsLog.txt"),
            icon: A_ScriptDir "\..\Resources\Icons\log-Blue.ico"
        })
        
        this.controlButtons.Push({
            text: " Analyze Manual Correction Log #^+Q", 
            action: (*) => Run("MCLogger.exe /script MCLogger.ahk analyze"),
            icon: A_ScriptDir "\..\Resources\Icons\JustLog.ico"
        })
        
        this.controlButtons.Push({
            text:  "Report HotStrings and Potential Fixes", 
            action: (*) => StringAndFixReport(),
            icon: A_ScriptDir "\..\Resources\Icons\report-Blue.ico"
        })
        
        this.controlButtons.Push({
            text: " Configuration Settings Manager", 
            action: (*) => Run(Config.SettingsManager),
            icon: A_ScriptDir "\..\Resources\Icons\settings-Blue.ico"
        })
        
        ; Check if Suggester tool is present, add button.
        if FileExist("..\Tools\Suggester.exe") {
            this.controlButtons.Push({
                text: " Hotstring Suggester Tool", 
                action: (*) => Run("..\Tools\Suggester.exe"),
                icon: A_ScriptDir "\..\Resources\Icons\lightbulb-Blue.ico"
            })
        }
        
        ; Check if tool is present, add button.
        if FileExist("..\Tools\ExtractPotentialMisspellings.exe") {
            this.controlButtons.Push({
                text: " Extract Potential Misspellings", 
                action: (*) => Run("..\Tools\ExtractPotentialMisspellings.exe"),
                icon: A_ScriptDir "\..\Resources\Icons\tweezers-Blue.ico"
            })
        }
        
        ; Check if tool is present, add button.
        if FileExist("..\Tools\ConflictingStringLocator.exe") {
            this.controlButtons.Push({
                text: " Conflicting String Locator Tool", 
                action: (*) => Run("..\Tools\ConflictingStringLocator.exe"),
                icon: A_ScriptDir "\..\Resources\Icons\conflict-Blue.ico"
            })
        }
        
        ; Check if tool is present, add button.
        if FileExist("..\Tools\Updater.exe") {
            this.controlButtons.Push({
                text: " Check GitHub for Updates", 
                action: (*) => Run("..\Tools\Updater.exe"),
                icon: A_ScriptDir "\..\Resources\Icons\update-Blue.ico"
            })
        }
        
        ; Check if tool is present, add button.
        if FileExist("..\Tools\UniqueStringExtractor.exe") {
            this.controlButtons.Push({
                text: " Compare Two Versions of HotstringLib", 
                action: (*) => Run("..\Tools\UniqueStringExtractor.exe"),
                icon: A_ScriptDir "\..\Resources\Icons\diff-files-Blue.ico"
            })
        }
        
        ; Check if tool is present, add button.
        if FileExist("..\Tools\Defunctionizer.exe") {
            this.controlButtons.Push({
                text: " Defunctionize Hotstrings", 
                action: (*) => Run("..\Tools\Defunctionizer.exe"),
                icon: A_ScriptDir "\..\Resources\Icons\function-Blue.ico"
            })
        }

        ; Open github in web browser
        this.controlButtons.Push({
            text: " Go to GitHub Repository", 
            action: (*) => Run("https://github.com/kunkel321/AutoCorrect2"),
            icon: A_ScriptDir "\..\Resources\Icons\github-Blue.ico"
        })

        ; Check if color theme settings exist, add theme button if they do
        if FileExist("..\Data\colorThemeSettings.ini") {
            this.controlButtons.Push({
                text: " Change Color Theme", 
                action: (*) => Run("..\Tools\ColorThemeInt.exe /script ..\Tools\ColorThemeInt.ahk analyz"),
                icon: A_ScriptDir "\..\Resources\Icons\color-Blue.ico"
            })
        }
        
        ; Create all buttons based on configuration
        this.Controls["ControlButtons"] := []
        
        for buttonConfig in this.controlButtons {
            button := this.MainForm.AddButton("y+2 h25 xm w" Config.DefaultWidth, buttonConfig.text)
            button.OnEvent("click", buttonConfig.action)
            
            if buttonConfig.icon
                try this._SetButtonIcon(button, buttonConfig.icon)
                
            this.Controls["ControlButtons"].Push(button)
        }
    }
    ; Set icon for a button
    static _SetButtonIcon(ButtonCtrl, IconFile) {
        hIcon := DllCall("LoadImage", "Ptr", 0, "Str", IconFile, "UInt", 1, "Int", 24, "Int", 24, "UInt", 0x10) 
        SendMessage(0xF7, 1, hIcon, ButtonCtrl.Hwnd)
    }
    
    ; Set up event handlers for all controls
    static _SetupEventHandlers() {
        ; Trigger section events
        this.Controls["TriggerEdit"].OnEvent("Change", (*) => UIActions.OnTriggerChanged())
        
        ; Replacement section events
        this.Controls["SizeToggle"].OnEvent("Click", (*) => UIActions.ToggleSize())
        this.Controls["SymbolToggle"].OnEvent("Click", (*) => UIActions.ToggleSymbols())
        this.Controls["ReplacementEdit"].OnEvent("Change", (*) => UIActions.FilterWordLists())
        this.Controls["ReplacementEdit"].OnEvent("Focus", (ctrl, *) => State.CurrentEdit := ctrl)
        
        ; Comment section events
        this.Controls["FunctionCheck"].OnEvent("Click", (*) => UIActions.FormAsFunction())
        
        ; Button section events
        this.Controls["AppendButton"].OnEvent("Click", (*) => UIActions.OnAppendButtonClick())
        this.Controls["CheckButton"].OnEvent("Click", (*) => UIActions.OnCheckButtonClick())
        this.Controls["ExamButton"].OnEvent("Click", (*) => UIActions.OnExamButtonClick())
        this.Controls["ExamButton"].OnEvent("ContextMenu", (*) => UIActions.OnExamButtonRightClick())
        this.Controls["SpellButton"].OnEvent("Click", (*) => UIActions.OnSpellButtonClick())
        this.Controls["LookButton"].OnEvent("Click", (*) => UIActions.OnLookButtonClick())
        this.Controls["LookButton"].OnEvent("ContextMenu", (*) => UIActions.OnLookButtonRightClick())
        this.Controls["CancelButton"].OnEvent("Click", (*) => UIActions.OnCancelButtonClick())
        
        ; Exam pane events
        this.Controls["LeftTrimButton"].OnEvent("Click", (*) => UIActions.TrimLeft())
        this.Controls["RightTrimButton"].OnEvent("Click", (*) => UIActions.TrimRight())
        this.Controls["DeltaString"].OnEvent("Click", (*) => UIActions.UpdateDeltaString())
        
        this.Controls["BeginningRadio"].OnEvent("Click", (*) => UIActions.FilterWordLists())
        this.Controls["BeginningRadio"].OnEvent("ContextMenu", (*) => UIActions.ClearRadioButtons())
        this.Controls["MiddleRadio"].OnEvent("Click", (*) => UIActions.FilterWordLists())
        this.Controls["MiddleRadio"].OnEvent("ContextMenu", (*) => UIActions.ClearRadioButtons())
        this.Controls["EndingRadio"].OnEvent("Click", (*) => UIActions.FilterWordLists())
        this.Controls["EndingRadio"].OnEvent("ContextMenu", (*) => UIActions.ClearRadioButtons())
        
        this.Controls["UndoButton"].OnEvent("Click", (*) => UIActions.Undo())
        
        this.Controls["TriggerMatchesEdit"].OnEvent("Focus", (ctrl, *) => State.CurrentEdit := ctrl)
        this.Controls["ReplacementMatchesEdit"].OnEvent("Focus", (ctrl, *) => State.CurrentEdit := ctrl)
        
        ; Main form events
        this.MainForm.OnEvent("Close", (*) => UIActions.OnCancelButtonClick())
    }
    
	; Set up hotkeys specific to the HotString Helper form
	static SetupFormHotkeys() {
		; These hotkeys only apply when the form is active
        HotIfWinActive "ahk_id " this.MainForm.Hwnd
		
		; Enter key behavior
		Hotkey "$Enter", (*) => this.EnterKeyHandler()
		
		; Shift+Left - Go to start of trigger
		Hotkey "+Left", (*) => this.ShiftLeftHandler()

		; Shift+Right - Go to end of replacement
		Hotkey "+Right", (*) => this.ShiftRightHandler()
		
		; Escape - Hide form
		Hotkey "Esc", (*) => UIActions.OnCancelButtonClick()
		
		; Undo operations
		Hotkey "^z", (*) => UIActions.Undo()
		Hotkey "^+z", (*) => UIActions.RestartFromOriginal()
		
		; Font size adjustment
		Hotkey "^Up", (*) => UIActions.SetLargeFont()
		Hotkey "^WheelUp", (*) => UIActions.SetLargeFont()
		Hotkey "^Down", (*) => UIActions.SetNormalFont()
		Hotkey "^WheelDown", (*) => UIActions.SetNormalFont()
		
		; Turn off window-specific behavior when done
		HotIfWinActive ""
	}

	; Handler for Enter key
	static EnterKeyHandler() {
		if this.Controls["SymbolToggle"].Text = "Hide Symbols"
			return
		else if this.Controls["ReplacementEdit"].Focused
			Send("{Enter}")
		else
			UIActions.OnAppendButtonClick()
	}

	; Handler for Shift+Left combo
	static ShiftLeftHandler() {
		this.Controls["TriggerEdit"].Focus()
		Send "{Home}"
	}
    
	; Handler for Shift+Right combo
	static ShiftRightHandler() {
		this.Controls["ReplacementEdit"].Focus()
		Send "{End}"
	}
    
    ; Get all controls in the exam pane for showing/hiding
    static GetExamPaneControls() {
        return [
            this.Controls["LeftTrimButton"],
            this.Controls["DeltaString"],
            this.Controls["RightTrimButton"],
            this.Controls["BeginningRadio"],
            this.Controls["MiddleRadio"],
            this.Controls["EndingRadio"],
            this.Controls["UndoButton"],
            this.Controls["TriggerFreqLabel"],
            this.Controls["ReplacementFreqLabel"],
            this.Controls["TriggerMatchLabel"],
            this.Controls["ReplacementMatchLabel"],
            this.Controls["TriggerMatchesEdit"],
            this.Controls["ReplacementMatchesEdit"]
        ]
    }
    
    ; Get all controls in the control pane for showing/hiding
    static GetControlPaneControls() {
        controls := [this.Controls["ControlPanelLabel"]]
        
        for button in this.Controls["ControlButtons"]
            controls.Push(button)
            
        return controls
    }

    ; Resize the form based on current size state
    static Resize(isLarge) {
        hFactor := isLarge ? Config.HeightSizeIncrease : 0
        wFactor := isLarge ? Config.DefaultWidth + Config.WidthSizeIncrease : Config.DefaultWidth
        
        ; Resize and reposition controls
        this.Controls["TriggerEdit"].Move(, , wFactor - 86)
        this.Controls["ReplacementEdit"].Move(, , wFactor, hFactor + 100)
        this.Controls["CommentLabel"].Move(, hFactor + 182)
        this.Controls["CommentEdit"].Move(, hFactor + 200, wFactor)
        this.Controls["FunctionCheck"].Move(, hFactor + 182)
        
        ; Move buttons
        this.Controls["AppendButton"].Move(, hFactor + 234)
        this.Controls["CheckButton"].Move(, hFactor + 234)
        this.Controls["ExamButton"].Move(, hFactor + 234)
        this.Controls["SpellButton"].Move(, hFactor + 234)
        this.Controls["LookButton"].Move(, hFactor + 234)
        this.Controls["CancelButton"].Move(, hFactor + 234)
        
        ; Update form
        this.MainForm.Show("AutoSize yCenter")
    }

    ; Set initial focus based on configuration
    static SetInitialFocus() {
        focusTarget := Config.InitialFocusTarget
        
        ; Validate the focus target - if invalid or empty, default to "auto"
        if (focusTarget = "" || !InStr("options|trigger|replacement|comment|auto", focusTarget)) {
            focusTarget := "auto"
        }
        
        ; Determine which control to focus
        switch focusTarget {
            case "options":
                this.Controls["OptionsEdit"].Focus()
            case "trigger":
                this.Controls["TriggerEdit"].Focus()
            case "replacement":
                this.Controls["ReplacementEdit"].Focus()
            case "comment":
                this.Controls["CommentEdit"].Focus()
            case "auto":
                ; Auto mode: choose based on entry type
                if State.IsBoilerplate {
                    ; Boilerplate entry - focus replacement
                    this.Controls["TriggerEdit"].Focus()
                }
                else {
                    ; AutoCorrect entry or undetermined - focus trigger
                    this.Controls["ReplacementEdit"].Focus()
                }
        }
    }
}

; =============== UI ACTIONS ===============

class UIActions {
	static ValidityDialog := 0 
    ; Shows or hides the examination pane controls
    static ShowHideExamPane(visible := false) {
        for ctrl in UI.GetExamPaneControls()
            ctrl.Visible := visible
        
        ; Load dictionary in a TRUE background thread instead of blocking the message loop
        if visible {
            ; Don't load dictionary on first show - load it much later, after UI is responsive
            SetTimer(() => Dictionary.StartBackgroundLoad(), -3000)  ; Load after 3 seconds, not immediately
        }
        
        State.ExamPaneOpen := visible
    }

    static UpdateDeltaString() {
        ; Get current trigger and replacement values
        triggerText := UI.Controls["TriggerEdit"].Text
        replacementText := UI.Controls["ReplacementEdit"].Text
        
        ; Recalculate and update the delta string
        this.ExamineWords(triggerText, replacementText)
    }
    
    ; Shows or hides the control pane controls
    static ShowHideControlPane(visible := false) {
        for ctrl in UI.GetControlPaneControls()
            ctrl.Visible := visible
            
        State.ControlPaneOpen := visible
    }
    
    ; Toggle form size between normal and large
    static ToggleSize() {
        if UI.Controls["SizeToggle"].Text = "Make Bigger" {
            UI.Controls["SizeToggle"].Text := "Make Smaller"
            
            ; If exam pane is open, close it first
            if UI.Controls["ExamButton"].Text = "Done" {
                this.ShowHideExamPane(false)
                this.ShowHideControlPane(false)
                State.ExamPaneOpen := 0
                State.ControlPaneOpen := 0
                UI.Controls["ExamButton"].Text := "Exam"
            }
            
            State.FormBig := 1
            UI.Resize(true)
        }
        else if UI.Controls["SizeToggle"].Text = "Make Smaller" {
            UI.Controls["SizeToggle"].Text := "Make Bigger"
            State.FormBig := 0
            UI.Resize(false)
        }
        
        UI.MainForm.Show("AutoSize yCenter")
    }
    
    ; Toggle symbol display in replacement text
    static ToggleSymbols() {
        if UI.Controls["SymbolToggle"].Text = "Show Symbols" {
            UI.Controls["SymbolToggle"].Text := "Hide Symbols"
            
            replaceText := UI.Controls["ReplacementEdit"].Text
            
            ; Replace newlines, spaces, and tabs with symbols
            replaceText := StrReplace(StrReplace(replaceText, "`r`n", "`n"), "`n", Config.PilcrowSymbol . "`n")
            replaceText := StrReplace(replaceText, A_Space, Config.DotSymbol)
            replaceText := StrReplace(replaceText, A_Tab, Config.TabSymbol)
            
            UI.Controls["ReplacementEdit"].Value := replaceText
            UI.Controls["ReplacementEdit"].Opt("+Readonly")
            UI.Controls["AppendButton"].Enabled := false
            
            State.SymbolsVisible := 1
        }
        else if UI.Controls["SymbolToggle"].Text = "Hide Symbols" {
            UI.Controls["SymbolToggle"].Text := "Show Symbols"
            
            replaceText := UI.Controls["ReplacementEdit"].Text
            
            ; Replace symbols with actual characters
            replaceText := StrReplace(replaceText, Config.PilcrowSymbol . "`r", "`r")
            replaceText := StrReplace(replaceText, Config.DotSymbol, A_Space)
            replaceText := StrReplace(replaceText, Config.TabSymbol, A_Tab)
            
            UI.Controls["ReplacementEdit"].Value := replaceText
            UI.Controls["ReplacementEdit"].Opt("-Readonly")
            UI.Controls["AppendButton"].Enabled := true
            
            State.SymbolsVisible := 0
        }
    }
    
    ; Handle changes to the trigger text
    static OnTriggerChanged() {
        newTrigger := UI.Controls["TriggerEdit"].Text
        
        ; Only process add-a-letter functionality if Exam pane is open
        if (State.ExamPaneOpen && State.TrigNeedle_Orig != "" && newTrigger != "") {
            ; Check if exactly one letter was added (length increased by exactly 1)
            if (StrLen(newTrigger) == StrLen(State.TrigNeedle_Orig) + 1) {
                ; Check if letter was added on the left
                if (State.TrigNeedle_Orig == SubStr(newTrigger, 2)) {
                    State.TriggerHistory.Push(UI.Controls["TriggerEdit"].Text)
                    State.ReplacementHistory.Push(UI.Controls["ReplacementEdit"].Text)
                    
                    ; Add same character to left of replacement
                    UI.Controls["ReplacementEdit"].Value := SubStr(newTrigger, 1, 1) UI.Controls["ReplacementEdit"].Text
                    UI.Controls["UndoButton"].Enabled := true
                    Debug("Letter added to left: " SubStr(newTrigger, 1, 1))
                }
                ; Check if letter was added on the right
                else if (State.TrigNeedle_Orig == SubStr(newTrigger, 1, StrLen(newTrigger) - 1)) {
                    State.TriggerHistory.Push(UI.Controls["TriggerEdit"].Text)
                    State.ReplacementHistory.Push(UI.Controls["ReplacementEdit"].Text)
                    
                    ; Add same character to right of replacement
                    UI.Controls["ReplacementEdit"].Text := UI.Controls["ReplacementEdit"].Text SubStr(newTrigger, -1)
                    UI.Controls["UndoButton"].Enabled := true
                    Debug("Letter added to right: " SubStr(newTrigger, -1))
                }
            }
            
            ; Update original value to keep in sync
            State.TrigNeedle_Orig := newTrigger
        } else if (State.ExamPaneOpen) {
            ; If the Exam pane is open but conditions aren't right for add-a-letter,
            ; just update the original value
            State.TrigNeedle_Orig := newTrigger
        }
        
        ; Always filter word lists when trigger changes
        this.FilterWordLists()
    }
            
    ; Update the function checkbox status based on options
    static FormAsFunction() {
        if UI.Controls["FunctionCheck"].Value = 1 {
            options := UI.Controls["OptionsEdit"].Text
            UI.Controls["OptionsEdit"].Text := "B0X" StrReplace(StrReplace(options, "B0", ""), "X", "")
            SoundBeep(700, 200)
        }
        else {
            options := UI.Controls["OptionsEdit"].Text
            UI.Controls["OptionsEdit"].Text := StrReplace(StrReplace(options, "B0", ""), "X", "")
            SoundBeep(900, 200)
        }
    }
    
    ; Set form font size to large
    static SetLargeFont() {
        UI.Controls["OptionsEdit"].SetFont(Config.LargeFontSize)
        UI.Controls["TriggerEdit"].SetFont(Config.LargeFontSize)
        UI.Controls["ReplacementEdit"].SetFont(Config.LargeFontSize)
    }
    
    ; Set form font size to normal
    static SetNormalFont() {
        UI.Controls["OptionsEdit"].SetFont(Config.DefaultFontSize)
        UI.Controls["TriggerEdit"].SetFont(Config.DefaultFontSize)
        UI.Controls["ReplacementEdit"].SetFont(Config.DefaultFontSize)
    }
    
    ; Trim one character from the left of trigger and replacement
    static TrimLeft() {
        ; Save current state for undo
        State.TriggerHistory.Push(UI.Controls["TriggerEdit"].Value)
        State.ReplacementHistory.Push(UI.Controls["ReplacementEdit"].Value)
        
        ; Remove first character from trigger and replacement
        UI.Controls["TriggerEdit"].Value := SubStr(UI.Controls["TriggerEdit"].Value, 2)
        UI.Controls["ReplacementEdit"].Value := SubStr(UI.Controls["ReplacementEdit"].Value, 2)
        
        ; Update original trigger value to prevent add-a-letter from triggering
        State.TrigNeedle_Orig := UI.Controls["TriggerEdit"].Value
        
        UI.Controls["UndoButton"].Enabled := true
        this.FilterWordLists()
    }

    ; Trim one character from the right of trigger and replacement
    static TrimRight() {
        ; Save current state for undo
        State.TriggerHistory.Push(UI.Controls["TriggerEdit"].Value)
        State.ReplacementHistory.Push(UI.Controls["ReplacementEdit"].Value)
        
        ; Remove last character from trigger and replacement
        triggerText := UI.Controls["TriggerEdit"].Value
        replacementText := UI.Controls["ReplacementEdit"].Value
        
        UI.Controls["TriggerEdit"].Value := SubStr(triggerText, 1, StrLen(triggerText) - 1)
        UI.Controls["ReplacementEdit"].Value := SubStr(replacementText, 1, StrLen(replacementText) - 1)
        
        ; Update original trigger value to prevent add-a-letter from triggering
        State.TrigNeedle_Orig := UI.Controls["TriggerEdit"].Value
        
        UI.Controls["UndoButton"].Enabled := true
        this.FilterWordLists()
    }
    
    ; Undo the last edit operation
    static Undo() {
        if GetKeyState("Shift") {
            this.RestartFromOriginal()
        }
        else if State.TriggerHistory.Length > 0 && State.ReplacementHistory.Length > 0 {
            UI.Controls["TriggerEdit"].Value := State.TriggerHistory.Pop()
            UI.Controls["ReplacementEdit"].Value := State.ReplacementHistory.Pop()
            this.FilterWordLists()
        }
        else {
            UI.Controls["UndoButton"].Enabled := false
        }
    }
    
    ; Reset to the original trigger and replacement
    static RestartFromOriginal() {
        if !State.OrigTrigger && !State.OrigReplacement {
            ToolTip("Can't restart. Nothing in memory.")
            SetTimer () => ToolTip(), -2000
        }
        else {
            UI.Controls["TriggerEdit"].Value := State.OrigTrigger
            UI.Controls["ReplacementEdit"].Value := State.OrigReplacement
            
            UI.Controls["UndoButton"].Enabled := false
            State.TriggerHistory := []
            State.ReplacementHistory := []
            
            this.FilterWordLists()
        }
    }
    
    ; Clear all radio buttons and update options accordingly
    static ClearRadioButtons() {
        UI.Controls["BeginningRadio"].Value := 0
        UI.Controls["MiddleRadio"].Value := 0
        UI.Controls["EndingRadio"].Value := 0
        
        options := UI.Controls["OptionsEdit"].Text
        UI.Controls["OptionsEdit"].Text := StrReplace(StrReplace(options, "?", ""), "*", "")
        
        this.FilterWordLists()
    }
    
    ; Filter word lists based on current trigger/replacement and options
    static FilterWordLists(viaExamButton := false) {
        Debug("FilterWordLists called, isLoaded=" WordFrequency.isLoaded ", isLoading=" WordFrequency.isLoading)
        ; Get trigger and replacement text
        triggerText := Trim(UI.Controls["TriggerEdit"].Value)
        if triggerText = ""
            triggerText := " " ; Prevent error if empty
            
        replacementText := Trim(UI.Controls["ReplacementEdit"].Value, "`n`t ")
        if replacementText = ""
            replacementText := " " ; Prevent error if empty
            
        options := UI.Controls["OptionsEdit"].Text
        
        ; If called via Exam button, update radio buttons based on options
        if viaExamButton {
            if InStr(options, "*") && InStr(options, "?")
                UI.Controls["MiddleRadio"].Value := 1
            else if InStr(options, "*")
                UI.Controls["BeginningRadio"].Value := 1
            else if InStr(options, "?")
                UI.Controls["EndingRadio"].Value := 1
            else {
                UI.Controls["MiddleRadio"].Value := 0
                UI.Controls["BeginningRadio"].Value := 0
                UI.Controls["EndingRadio"].Value := 0
            }
        }
        
        ; Process trigger matches
        triggerMatches := 0
        triggerFilteredList := ""
        
        if FileExist(Config.WordListFile) {
            Loop Read, Config.WordListFile {
                if InStr(A_LoopReadLine, triggerText) {
                    if UI.Controls["MiddleRadio"].Value = 1 {
                        triggerFilteredList .= A_LoopReadLine '`n'
                        triggerMatches++
                    }
                    else if UI.Controls["EndingRadio"].Value = 1 {
                        if InStr(SubStr(A_LoopReadLine, -StrLen(triggerText)), triggerText) {
                            triggerFilteredList .= A_LoopReadLine '`n'
                            triggerMatches++
                        }
                    }
                    else if UI.Controls["BeginningRadio"].Value = 1 {
                        if InStr(SubStr(A_LoopReadLine, 1, StrLen(triggerText)), triggerText) {
                            triggerFilteredList .= A_LoopReadLine '`n'
                            triggerMatches++
                        }
                    }
                    else {
                        if A_LoopReadLine = triggerText {
                            triggerFilteredList := triggerText
                            triggerMatches++
                        }
                    }
                }
            }
        }
        else {
            triggerFilteredList := "Comparison`nword list`nnot found"
        }
        
        ; Update options based on radio selection
        if UI.Controls["MiddleRadio"].Value = 1 {
            if !InStr(options, "*")
                options := options "*"
            if !InStr(options, "?")
                options := options "?"
        }
        else if UI.Controls["EndingRadio"].Value = 1 {
            if !InStr(options, "?")
                options := options "?"
            options := StrReplace(options, "*")
        }
        else if UI.Controls["BeginningRadio"].Value = 1 {
            if !InStr(options, "*")
                options := options "*"
            options := StrReplace(options, "?")
        }
        
        UI.Controls["OptionsEdit"].Text := options
        
        ; Update trigger matches display
        UI.Controls["TriggerMatchesEdit"].Value := triggerFilteredList
        UI.Controls["TriggerMatchLabel"].Text := "Misspells [" triggerMatches "]"

        ; Update trigger label based on matches
        if State.IsBoilerplate {
            ; For boilerplate text, always show "Trigger String"
            UI.Controls["TriggerLabel"].Text := "Trigger String"
            UI.Controls["TriggerLabel"].SetFont(Config.FontColor)
        } else if triggerText = " " || triggerText = "" {
            ; For empty trigger, show "Trigger String" 
            UI.Controls["TriggerLabel"].Text := "Trigger String"
            UI.Controls["TriggerLabel"].SetFont(Config.FontColor)
        } else if triggerMatches > 0 {
            UI.Controls["TriggerLabel"].Text := "Misspells [" triggerMatches "] words"
            UI.Controls["TriggerLabel"].SetFont("c" Config.ValidityDialogRed)
        } else if triggerMatches = 0 {
            UI.Controls["TriggerLabel"].Text := "No Misspellings found."
            UI.Controls["TriggerLabel"].SetFont(Config.FontColor)
        }
        
        ; Process replacement matches
        replacementMatches := 0
        replacementFilteredList := ""
        
        if FileExist(Config.WordListFile) {
            Loop Read, Config.WordListFile {
                if InStr(A_LoopReadLine, replacementText) {
                    if UI.Controls["MiddleRadio"].Value = 1 {
                        replacementFilteredList .= A_LoopReadLine '`n'
                        replacementMatches++
                    }
                    else if UI.Controls["EndingRadio"].Value = 1 {
                        if InStr(SubStr(A_LoopReadLine, -StrLen(replacementText)), replacementText) {
                            replacementFilteredList .= A_LoopReadLine '`n'
                            replacementMatches++
                        }
                    }
                    else if UI.Controls["BeginningRadio"].Value = 1 {
                        if InStr(SubStr(A_LoopReadLine, 1, StrLen(replacementText)), replacementText) {
                            replacementFilteredList .= A_LoopReadLine '`n'
                            replacementMatches++
                        }
                    }
                    else {
                        if A_LoopReadLine = replacementText {
                            replacementFilteredList := replacementText
                            replacementMatches++
                        }
                    }
                }
            }
        }
        else {
            replacementFilteredList := "Comparison`nword list`nnot found"
        }
        
        UI.Controls["ReplacementMatchesEdit"].Value := replacementFilteredList
        UI.Controls["ReplacementMatchLabel"].Text := "Fixes [" replacementMatches "]"
        
        ; Save match counts to state
        State.TriggerMatches := triggerMatches
        State.ReplacementMatches := replacementMatches

        ; Calculate and display word frequencies
        if (triggerFilteredList != "" && triggerFilteredList != "Comparison`nword list`nnot found") {
            ; Ensure data is loaded
            if (!WordFrequency.isLoaded) {
                WordFrequency.LoadSync()
            }
            
            triggerFreq := WordFrequency.CalculateFrequency(triggerFilteredList)
            UI.Controls["TriggerFreqLabel"].Text := "Web Freq [" WordFrequency.FormatFrequency(triggerFreq) "]"
        } else {
            UI.Controls["TriggerFreqLabel"].Text := "Web Freq [0]"
        }

        if (replacementFilteredList != "" && replacementFilteredList != "Comparison`nword list`nnot found") {
            ; Ensure data is loaded
            if (!WordFrequency.isLoaded) {
                WordFrequency.LoadSync()
            }
            
            replacementFreq := WordFrequency.CalculateFrequency(replacementFilteredList)
            UI.Controls["ReplacementFreqLabel"].Text := "Web Freq [" WordFrequency.FormatFrequency(replacementFreq) "]"
        } else {
            UI.Controls["ReplacementFreqLabel"].Text := "Web Freq [0]"
        }
    }
    
    ; Examine the words - analyze the differences between trigger and replacement
    static ExamineWords(triggerText, replacementText) {
        Debug("At top of ExamineWords() method")
        if State.FormBig {
            UI.Controls["SizeToggle"].Text := "Make Bigger"
            SoundBeep(200, 100)
            this.ToggleSize()
        }
        UI.MainForm.Show("AutoSize yCenter")
        
        ; Analyze the delta between trigger and replacement
        beginning := ""
        typo := ""
        fix := ""
        ending := ""
        
        ; Store originals
        oTrigger := triggerText
        oReplacement := replacementText
        
        triggerLength := StrLen(triggerText)
        replacementLength := StrLen(replacementText)
        
        ; If trigger and replacement are identical
        if oTrigger = oReplacement {
            deltaString := "[ " oTrigger " ]"
        }
        else {
            ; Find matching prefix
            i := 1
            while i <= triggerLength && i <= replacementLength 
                  && SubStr(triggerText, i, 1) = SubStr(replacementText, i, 1) {
                beginning .= SubStr(triggerText, i, 1)
                i++
            }
            
            ; Find matching suffix (working backwards)
            j := 0
            while j < triggerLength - i + 1 && j < replacementLength - i + 1 
                  && SubStr(triggerText, triggerLength - j, 1) = SubStr(replacementText, replacementLength - j, 1) {
                ending := SubStr(triggerText, triggerLength - j, 1) . ending
                j++
            }
            
            ; Extract the differing middle parts
            typo := SubStr(triggerText, i, triggerLength - i - j + 1)
            fix := SubStr(replacementText, i, replacementLength - i - j + 1)
            
            deltaString := beginning " [ " typo " | " fix " ] " ending
        }
        
        UI.Controls["DeltaString"].Text := deltaString
        
        ; Filter word lists
        this.FilterWordLists(true)
        
        ; Update button status and show exam pane
        if UI.Controls["ExamButton"].Text = "Exam" {
            UI.Controls["ExamButton"].Text := "Done"
            
            if State.FormBig {
                UI.Controls["SizeToggle"].Text := "Make Bigger"
                SoundBeep(200, 100)
                this.ToggleSize()
            }
            
            this.ShowHideExamPane(true)
        }
        Debug("In ExamineWords() method, before second mainForm.show")
        ; Commenting-out the next line does not prevent the form from reappearing.
        UI.MainForm.Show("AutoSize yCenter")
        Debug("At bottom of ExamineWords() method")
    }
    
    ; Handler for the Exam button
    static OnExamButtonClick() {
        ; Handle different exam pane states
        if State.ExamPaneOpen = 0 && State.ControlPaneOpen = 0 && GetKeyState("Shift") {
            ; Shift+Click when both panes closed: open control pane
            this.OnExamButtonRightClick()
        }
        else if State.ExamPaneOpen = 1 && State.ControlPaneOpen = 0 && GetKeyState("Shift") {
            ; Shift+Click when exam pane open: switch to control pane
            this.OnExamButtonRightClick()
        }
        else if State.ExamPaneOpen = 0 && State.ControlPaneOpen = 0 {
            ; Both panes closed: open exam pane
            UI.Controls["ExamButton"].Text := "Done"
            
            if State.FormBig {
                this.ToggleSize()
                UI.Controls["SizeToggle"].Text := "Make Bigger"
            }
            
            State.OrigTrigger := UI.Controls["TriggerEdit"].Text
            State.OrigReplacement := UI.Controls["ReplacementEdit"].Text
            State.TrigNeedle_Orig := UI.Controls["TriggerEdit"].Text  ; Make sure this line is present
            
            this.ExamineWords(State.OrigTrigger, State.OrigReplacement)
            this.FilterWordLists()
            
            this.ShowHideControlPane(false)
            this.ShowHideExamPane(true)
            
            State.ExamPaneOpen := 1
        }
        else {
            ; Close whatever pane is open
            UI.Controls["ExamButton"].Text := "Exam"
            this.ShowHideControlPane(false)
            this.ShowHideExamPane(false)
            
            State.ExamPaneOpen := 0
            State.ControlPaneOpen := 0
        }
        
        UI.MainForm.Show("AutoSize yCenter")
    }
    
    ; Handler for right-clicking the Exam button (shows control pane)
    static OnExamButtonRightClick() {
        if State.ControlPaneOpen = 1 {
            UI.Controls["ExamButton"].Text := "Exam"
            this.ShowHideControlPane(false)
            this.ShowHideExamPane(false)
            
            State.ControlPaneOpen := 0
            State.ExamPaneOpen := 0
        }
        else {
            UI.Controls["ExamButton"].Text := "Done"
            
            if State.FormBig {
                this.ToggleSize()
                UI.Controls["SizeToggle"].Text := "Make Bigger"
            }
            
            this.ShowHideControlPane(true)
            this.ShowHideExamPane(false)
            
            State.ControlPaneOpen := 1
            State.ExamPaneOpen := 0
        }
        
        UI.MainForm.Show("AutoSize yCenter")
    }
    
    ; Handler for the Append button
    static OnAppendButtonClick() {
        options := UI.Controls["OptionsEdit"].Text
        triggerText := UI.Controls["TriggerEdit"].Text
        replacementText := UI.Controls["ReplacementEdit"].Text
        
        ; If Alt is pressed, send to Suggester tool
        if GetKeyState("Alt") {
            this.SendToSuggester(options, triggerText, replacementText)
            return
        }
        
        ; Existing code for Append functionality
        result := Validation.ValidateHotstring(options, triggerText, replacementText)
        
        if !InStr(result.combinedMsg, Config.ValidOkMessage, , , 3) {
            ; Validation issues found, show message
            this.ShowValidityDialog(result.combinedMsg, true)
        }
        else {
            ; No validation issues, append the hotstring
            this.AppendHotstring(options, triggerText, replacementText)
        }
    }
    
	; Handler for the Check button
	static OnCheckButtonClick() {
		static validityDialog := 0  
		
		if WinExist("Validity Report") {
			; If dialog is already open, close it
			if IsObject(validityDialog)
				this.validityDialog.Destroy()
		}
		else {
			; Validate the hotstring and show results
			options := UI.Controls["OptionsEdit"].Text
			triggerText := UI.Controls["TriggerEdit"].Text
			replacementText := UI.Controls["ReplacementEdit"].Text
			
			result := Validation.ValidateHotstring(options, triggerText, replacementText)
			this.ShowValidityDialog(result.combinedMsg, false)
		}
	}
    

    ; Handler for the Spell button
    static OnSpellButtonClick() {
        replacementText := UI.Controls["ReplacementEdit"].Text
        
        if replacementText = "" {
            acMsgBox.show("Replacement Text not found.", , "4096 icon!")
        }
        else {
            suggestion := Utils.SpellingGrammarSuggestion(replacementText)
            
            if suggestion = "" || suggestion = replacementText {
                acMsgBox.show("No suggestions found.", , "4096 iconi")
            }
            else {
                ; Show suggestion in a custom GUI instead of MsgBox
                Utils.ShowSpellingSuggestionGui(replacementText, suggestion)
            }
        }
    }

    ; Handler for the Look button (dictionary lookup)
    static OnLookButtonClick() {
        if !Utils.ProcessSelectedText((word) => Dictionary.ShowDefinitionGui(word)) {
            AcMsgBox.Show("Please select a word from one of the lists or text boxes:`n`n• Replacement box`n• Misspells list`n• Fixes list`n`nThen click Look again.", "No Selection", 64)
        }
    }
    
    ; Handler for right-clicking the Look button (online dictionary)
    static OnLookButtonRightClick() {
        if !Utils.ProcessSelectedText((word) => Run("https://gcide.gnu.org.ua/?q=" word "&define=Define&strategy=.")) {
            AcMsgBox.Show("Please select a word from one of the lists or text boxes:`n`n• Replacement box`n• Misspells list`n• Fixes list`n`nThen click Look again.", "No Selection", 64)
        }
    }
    
    ; Handler for the Cancel button
    static OnCancelButtonClick() {
        UI.MainForm.Hide()
        
        ; Clear form values
        UI.Controls["OptionsEdit"].Value := ""
        UI.Controls["TriggerEdit"].Value := ""
        UI.Controls["ReplacementEdit"].Value := ""
        UI.Controls["CommentEdit"].Value := ""
        
        ; Reset undo history
        State.TriggerHistory := []
        State.ReplacementHistory := []
        
        ; Restore clipboard
        A_Clipboard := State.ClipboardOld
    }
    
    ; Send current hotstring to Suggester tool
    static SendToSuggester(options, triggerText, replacementText) {
        hotstringFull := ":" options ":" triggerText "::" replacementText
        
        Debug("Sending from HH2 to Suggester: " hotstringFull)
        
        try {
            rootDir := A_ScriptDir "\.."
            suggesterExe := rootDir "\Tools\Suggester.exe"
            suggesterAhk := rootDir "\Tools\Suggester.ahk"
            
            Debug("Looking for Suggester at: " suggesterAhk)
            
            if (!FileExist(suggesterExe) || !FileExist(suggesterAhk)) {
                acMsgBox.show("Error: Suggester tool not found.`n`nNeeds both:`n" suggesterExe "`n" suggesterAhk)
                return
            }
            
            ; Create a temporary file with the hotstring
            tempFile := A_Temp "\ac2_suggester_temp.txt"
            try FileDelete(tempFile)
            FileAppend(hotstringFull, tempFile)
            
            Debug("Created temp file: " tempFile)
            
            ; Run: Suggester.exe "Suggester.ahk" /fromfile "tempfile.txt"
            ; The renamed AutoHotkey.exe needs the script file as first parameter
            cmdLine := '"' suggesterExe '" "' suggesterAhk '" /fromfile "' tempFile '"'
            Debug("Running command: " cmdLine)
            Run(cmdLine)
            
            UI.MainForm.Show()
            
        } catch Error as err {
            LogError("Error launching Suggester tool: " err.Message)
            acMsgBox.show("Error launching Suggester tool: (" err.Number ") " err.Message "`n`nDebug info written to log.")
        }
    }

    ; Open the hotstring library in the editor
    static OpenHotstringLibrary() {
        if WinActive(Config.HHWindowTitle) {
            UI.MainForm.Hide()
            A_Clipboard := State.ClipboardOld
        }
        
        try {
            Run(Config.EditorPath " " Config.HotstringLibrary)
        }
        catch {
            acMsgBox.show("Cannot run " Config.HotstringLibrary)
            return
        }
        
        counter := 0
        while !WinActive(Config.HotstringLibrary) {
            Sleep(100)
            counter++
            
            if counter > 80 {
                acMsgBox.show("Cannot seem to open Library.`nMaybe an 'admin rights' issue?")
                return
            }
        }
        
        Send("{Ctrl Down}{End}{Ctrl Up}{Home}")  ; Navigate to the bottom
    }
    
	; Create and show validity dialog
	static ShowValidityDialog(message, appendOption) {
		if IsObject(this.ValidityDialog)
			this.ValidityDialog.Destroy()
			
		this.ValidityDialog := Gui(, "Validity Report")
		this.ValidityDialog.BackColor := Config.FormColor
		
		; Set font
		this.ValidityDialog.SetFont("s11 " Config.FontColor)
		titleText := this.ValidityDialog.Add("Text", "", "For proposed new item:")
		titleText.Focus()
		
		; Display the proposed hotstring
		this.ValidityDialog.SetFont(Config.LargeFontSize)
		proposedHS := ":" UI.Controls["OptionsEdit"].Text ":" UI.Controls["TriggerEdit"].Text "::" UI.Controls["ReplacementEdit"].Text
		this.ValidityDialog.Add("Text", (StrLen(proposedHS) > 90 ? "w600 " : "") "xs yp+22", proposedHS)
		
		; If not append option, add section header
		this.ValidityDialog.SetFont("s11")
		if !appendOption
			this.ValidityDialog.Add("Text", "", "===Validation Check Results===")
			
		; Split message into sections
		this.ValidityDialog.SetFont(Config.LargeFontSize)
		messageItems := StrSplit(message, "*|*")
		
		; Limit long messages
		if InStr(messageItems[2], "`n", , , 10)
			messageItems[2] := SubStr(messageItems[2], 1, InStr(messageItems[2], "`n", , , 10)) "`n## Too many conflicts to show in form ##"
			
		; Add message sections
		editSharedSettings := " -VScroll ReadOnly -E0x200 Background" Config.FormColor
		this.ValidityDialog.Add("Edit", (InStr(messageItems[1], Config.ValidOkMessage) ? Config.ValidityDialogGreen : Config.ValidityDialogRed) editSharedSettings, messageItems[1])
		triggerEditBox := this.ValidityDialog.Add("Edit", (StrLen(messageItems[2]) > 104 ? " w600 " : " ") (InStr(messageItems[2], Config.ValidOkMessage) ? Config.ValidityDialogGreen : Config.ValidityDialogRed) editSharedSettings, messageItems[2])
		this.ValidityDialog.Add("Edit", (StrLen(messageItems[3]) > 104 ? " w600 " : " ") (InStr(messageItems[3], Config.ValidOkMessage) ? Config.ValidityDialogGreen : Config.ValidityDialogRed) editSharedSettings, messageItems[3])
		
		; Add buttons
		this.ValidityDialog.SetFont("s11 " Config.FontColor)
		
		if appendOption
			this.ValidityDialog.Add("Text", "", "==============================`nAppend HotString Anyway?")
			
		appendButton := this.ValidityDialog.Add("Button",, "Append Anyway")
		appendButton.OnEvent("Click", (*) => (this.AppendHotstring(UI.Controls["OptionsEdit"].Text, UI.Controls["TriggerEdit"].Text, UI.Controls["ReplacementEdit"].Text), this.ValidityDialog.Destroy()))
		
		if !appendOption
			appendButton.Visible := false
			
		closeButton := this.ValidityDialog.Add("Button", "x+5 Default", "Close")
		closeButton.OnEvent("Click", (*) => this.ValidityDialog.Destroy())
		
		; Add lookup button if needed
		if messageItems[4] = 1 {
			lookupButton := this.ValidityDialog.Add("Button", "x+12", "Look Up")
			lookupButton.OnEvent("Click", (*) => Utils.ProcessSelectedText((text) => Utils.LookupSelectedText(text, triggerEditBox)))
			triggerEditBox.OnEvent("Focus", (*) => State.CurrentEdit := triggerEditBox)
		}
		
		; Show dialog centered
		this.ValidityDialog.Show("yCenter x" (A_ScreenWidth / 2))
		WinSetAlwaysontop(1, "A")
		this.ValidityDialog.OnEvent("Escape", (*) => this.ValidityDialog.Destroy())
	}
		
    ; Construct and append hotstring to library
    static AppendHotstring(options, triggerText, replacementText) {
        wholeString := ""
        commentText := ""
        autoComment := ""
        
        ; Get comment text from form
        commentInput := UI.Controls["CommentEdit"].Text

        ; Generate auto-comment about fixes and misspellings if enabled
        if Config.AutoCommentWithFreqAndStats = 1 {
            ; Ensure word frequency data is loaded
            if !WordFrequency.isLoaded {
                WordFrequency.Initialize()
            }
            ; Calculate web frequency for replacement matches
            replacementFreq := 0
            if UI.Controls["ReplacementMatchesEdit"].Value != "" {
                replacementFreq := WordFrequency.CalculateFrequency(UI.Controls["ReplacementMatchesEdit"].Value)
            }
            
            ; Format frequency in millions with 2 decimal places
            formattedFreq := WordFrequency.FormatFrequency(replacementFreq)
            
            ; Get content from the TriggerMatchesEdit box and properly trim whitespace
            triggerMatchesContent := Trim(UI.Controls["TriggerMatchesEdit"].Value, " `t`n`r")
            
            ; Count the number of words in the edit box
            wordCount := 0
            if (triggerMatchesContent != "") {
                ; Split by newlines and count non-empty lines
                Loop Parse, triggerMatchesContent, "`n", "`r" {
                    trimmedLine := Trim(A_LoopField, " `t")
                    if (trimmedLine != "")
                        wordCount++
                }
            }
            
            ; Build misspellsText based on TriggerMatchesEdit content
            if wordCount > 3 {
                misspellsText := ", but misspells " wordCount " words !!! "
            }
            else if wordCount > 0 {
                ; For 3 or fewer words, collect and format them explicitly
                wordList := ""
                Loop Parse, triggerMatchesContent, "`n", "`r" {
                    trimmedLine := Trim(A_LoopField, " `t")
                    if (trimmedLine != "")
                        wordList .= trimmedLine " (), "
                }
                ; Remove trailing ", " and add period
                misspellsText := SubStr(wordList, 1, -2) ". "
                misspellsText := ", but misspells " misspellsText
            }
            else {
                misspellsText := ""
            }
            
            ; Create the complete auto-comment with web frequency
            If (formattedFreq != 0.00)
                autoComment := "Web Freq " formattedFreq " | Fixes " State.ReplacementMatches " words " misspellsText
            else
                autoComment := "Fixes " State.ReplacementMatches " words " misspellsText

            autoComment := StrReplace(autoComment, "Fixes 1 words ", "Fixes 1 word ")
            autoComment := StrReplace(autoComment, "Fixes 0 words ", "Fixes 1 word ") ; <--- catches grammar items
        }
        
        ; Add function part if needed. Combine the parts into a single- or multi-line hotstring.
        if UI.Controls["FunctionCheck"].Value = 1 && State.IsBoilerplate = 0 && !InStr(replacementText, "`n") {
            ; Function format
            options := "B0X" StrReplace(StrReplace(options, "B0", ""), "X", "")
            
            if commentInput != "" || autoComment != "" {
                commentText := " `; " autoComment commentInput
                commentText := StrReplace(commentText, "words ,", "words,") ; <--- removes erroneous space
                commentText := StrReplace(commentText, "word ,", "word,") ; <--- removes erroneous space
                commentText := StrReplace(commentText, "word .", "word.") ; <--- removes erroneous space
                commentText := StrReplace(commentText, "words .", "words.") ; <--- removes erroneous space
                commentText := StrReplace(commentText, "(). (", "(") ; <--- removes erroneous parenths
            }
                
            wholeString := ":" options ":" triggerText "::f(`"" replacementText "`")" commentText
        }
        else if InStr(replacementText, "`n") {
            ; Multi-line format
            options := StrReplace(StrReplace(options, "B0", ""), "X", "")
            ; If last char of replacement text is tab or space, include 'RTrim0'.
            openParenth := SubStr(replacementText, -1) = "`t" || SubStr(replacementText, -1) = " " ? "(RTrim0`n" : "(`n"
            
            wholeString := ":" options ":" triggerText "::" commentText "`n" openParenth replacementText "`n)"
        }
        else {
            ; Plain vanilla, single-line, no function
            options := StrReplace(options, "X", "")
            
            if commentInput != ""
                commentText := " `; " commentInput
                
            wholeString := ":" options ":" triggerText "::" replacementText commentText
        }
        
        ; Handle different append modes
        if GetKeyState("Shift") {
            ; Shift held - copy to clipboard
            A_Clipboard := wholeString
            ToolTip("Copied to clipboard.")
            SetTimer () => ToolTip(), -2000
        }
        else {
            ; Normal append - add to library file
            FileAppend("`n" wholeString, Config.HotstringLibrary)
            
            ; Auto-enter replacement if enabled
            if Config.AutoEnterNewEntry = 1
                this.AutoEnterNewReplacement()
                
            ; Reload script unless Ctrl is held
            if !GetKeyState("Ctrl")
                Reload()
        }
    }
    
    ; Auto-enter the replacement in the active document
    static AutoEnterNewReplacement() {
        ; Save current clipboard
        oldClipboard := ClipboardAll()
        
        try {
            ; Close any validity dialogs that might still be open
            if IsObject(UIActions.ValidityDialog) {
                try {
                    UIActions.ValidityDialog.Destroy()
                    Sleep(50)
                } catch {
                    ; Dialog already closed, ignore
                }
            }
            
            ; Hide main form
            UI.MainForm.Hide()
            
            ; Wait a bit longer for any dialogs to close
            Sleep(100)
            
            ; Try to activate target window
            try {
                WinActivate(State.TargetWindow)
            } catch Error as err {
                Debug("AutoEnterNewReplacement: Could not activate target window: " err.Message)
            }
            
            ; Wait for target window to be active, with longer timeout
            if !WinWaitActive(State.TargetWindow, , 5) {  ; Increased to 5 seconds
                Debug("AutoEnterNewReplacement: Target window failed to become active within timeout")
                A_Clipboard := oldClipboard
                return
            }
            
            ; Additional delay to ensure window is fully active and ready
            Sleep(150)
            
            ; NOW copy the current selection
            A_Clipboard := ""
            Send("^c")
            
            if !ClipWait(1.0) {
                Debug("AutoEnterNewReplacement: ClipWait timeout - no text copied")
                A_Clipboard := oldClipboard
                return
            }
            
            ; Remove whitespace for comparison
            State.OrigTriggerTypo := Trim(State.OrigTriggerTypo)
            currentSelection := Trim(A_Clipboard)
            
            Debug("AutoEnterNewReplacement: Comparing - orig: '" State.OrigTriggerTypo "' current: '" currentSelection "'")
            
            ; Check if the original text is still selected and unchanged
            if (State.OrigTriggerTypo = currentSelection && 
                State.OrigTriggerTypo = UI.Controls["TriggerEdit"].Text) {
                
                ; Determine if we need to preserve trailing space
                hasSpace := (A_Clipboard != "" && SubStr(A_Clipboard, -1) = " ") ? " " : ""
                
                ; Send the replacement text
                replacementText := UI.Controls["ReplacementEdit"].Text hasSpace
                Send(replacementText)
                
                Debug("AutoEnterNewReplacement: Successfully entered replacement: " replacementText)
            } else {
                Debug("AutoEnterNewReplacement: Selection mismatch - orig: '" State.OrigTriggerTypo "' current: '" currentSelection "'")
            }
            
        } catch Error as err {
            LogError("AutoEnterNewReplacement: Error - " err.Message)
        } finally {
            ; Always restore clipboard
            A_Clipboard := oldClipboard
        }
    }
}

; =============== HOTSTRING VALIDATION ===============

class Validation {
    ; Validate a hotstring for potential issues
    static ValidateHotstring(options, triggerText, replacementText) {
        result := {
            validOpts: "",
            validHot: "",
            validRep: "",
            showLookupBox: 0,
            combinedMsg: ""
        }
        
        ; Validate options
        if options = "" {
            result.validOpts := Config.ValidOkMessage
        }
        else {
            validOptionRegex := "(\*|B0|\?|SI|C|K[0-9]{1,3}|SE|X|SP|O|R|T)"
            remainingOptions := RegExReplace(options, validOptionRegex, "")
            
            if remainingOptions = "" {
                result.validOpts := Config.ValidOkMessage
            }
            else {
                optionTips := InStr(remainingOptions, ":") ? "Don't include the colons.`n" : ""
                optionTips .= " ;  a block text assignment to var
                (
                Common options. From AHK docs
                * - ending char not needed
                ? - trigger inside other words
                C - case-sensitive
                --don't use below with f function--
                B0 - no backspacing (leave trigger)
                SI - send input mode
                SE - send event mode
                Kn - set key delay (n is a digit)
                O - omit end char
                R - raw dog it
                )"
                
                result.validOpts := "Invalid Hotstring Options found.`n---> " remainingOptions "`n" optionTips
            }
        }
        
        ; Validate trigger string
        this._ValidateTriggerString(triggerText, options, result)
        
        ; Validate replacement string
        if replacementText = "" {
            result.validRep := "Replacement string box should not be empty."
        }
        else if SubStr(replacementText, 1, 1) = ":" {
            result.validRep := "Don't include the colons."
        }
        else if replacementText = triggerText {
            result.validRep := "Replacement string SAME AS Trigger string."
        }
        else {
            result.validRep := Config.ValidOkMessage
        }
        
        ; Combine all validation messages
        result.combinedMsg := "OPTIONS BOX `n" result.validOpts "*|*HOTSTRING BOX `n" result.validHot "*|*REPLACEMENT BOX `n" result.validRep "*|*" result.showLookupBox
        
        return result
    }
    
    ; Validate trigger string against existing hotstrings
    static _ValidateTriggerString(triggerText, options, result) {
        validHotDupes := ""
        validHotMisspells := ""
        
        if triggerText = "" || triggerText = Config.BoilerplatePrefix || triggerText = Config.BoilerplateSuffix {
            result.validHot := "HotString box should not be empty."
            return
        }
        
        if InStr(triggerText, ":") {
            result.validHot := "Don't include colons."
            return
        }
        
        ; Check for duplicates and conflicts in the hotstring library
        try {
            fileContent := FileRead(Config.HotstringLibrary)
            
            ; Determine where autocorrect items start
            ACitemsStartAt := 1  ; This should be set based on your file structure
            
            ; Check line by line for conflicts
            loop parse, fileContent, "`n", "`r" {
                ; Skip non-hotstring lines
                if A_Index < ACitemsStartAt || SubStr(Trim(A_LoopField, " `t"), 1, 1) != ":" {
                    continue
                }
                
                ; Look for hotstring definition
                if RegExMatch(A_LoopField, "i):(?P<Opts>[^:]+)*:(?P<Trig>[^:]+)", &match) {
                    currentOpts := match.Opts
                    currentTrig := match.Trig
                    
                    ; Check for exact duplicate
                    if triggerText = currentTrig && options = currentOpts {
                        validHotDupes := "`nDuplicate trigger string found at line " A_Index ".`n---> " A_LoopField
                        result.showLookupBox := 1
                        continue
                    }
                    
                    ; Check for word-middle conflicts
                    if (InStr(currentTrig, triggerText) && InStr(options, "*") && InStr(options, "?")) ||
                       (InStr(triggerText, currentTrig) && InStr(currentOpts, "*") && InStr(currentOpts, "?")) {
                        validHotDupes .= "`nWord-Middle conflict found at line " A_Index ", where one of the strings will be nullified by the other.`n---> " A_LoopField
                        result.showLookupBox := 1
                        continue
                    }
                    
					; Check for same word with different match types
					if currentTrig = triggerText {
						; Check if one is word-beginning and other is word-ending
						if (InStr(currentOpts, "*") && !InStr(currentOpts, "?") && 
							InStr(options, "?") && !InStr(options, "*")) ||
						(InStr(currentOpts, "?") && !InStr(currentOpts, "*") && 
							InStr(options, "*") && !InStr(options, "?")) {
							validHotDupes .= "`nDuplicate trigger found at line " A_Index ", but maybe okay, because one is word-beginning and other is word-ending.`n---> " A_LoopField
							result.showLookupBox := 1
							continue
						}
					}
                    
                    ; Check for word-beginning conflicts
                    if (InStr(currentOpts, "*") && currentTrig = SubStr(triggerText, 1, StrLen(currentTrig))) ||
                       (InStr(options, "*") && triggerText = SubStr(currentTrig, 1, StrLen(triggerText))) {
                        validHotDupes .= "`nWord Beginning conflict found at line " A_Index ", where one of the strings is a subcomponent of the other. Whichever appears last will never be expanded.`n---> " A_LoopField
                        result.showLookupBox := 1
                        continue
                    }
                    
                    ; Check for word-ending conflicts
                    if (InStr(currentOpts, "?") && currentTrig = SubStr(triggerText, -StrLen(currentTrig))) ||
                       (InStr(options, "?") && triggerText = SubStr(currentTrig, -StrLen(triggerText))) {
                        validHotDupes .= "`nWord Ending conflict found at line " A_Index ", where one of the strings is a supercomponent of the other. The longer of the strings should appear before the other, in your code.`n---> " A_LoopField
                        result.showLookupBox := 1
                        continue
                    }
                }
            }
            
            ; Check for previously removed hotstrings
            if FileExist(Config.RemovedHsFile) {
                removedContent := FileRead(Config.RemovedHsFile)
                
                loop parse, removedContent, "`n", "`r" {
                    if RegExMatch(A_LoopField, "i):(?P<Opts>[^:]+)*:(?P<Trig>[^:]+)", &match) {
                        if triggerText = match.Trig && options = match.Opts {
                            validHotDupes .= "`nWarning: A duplicate trigger string was previously removed.`n----> " A_LoopField
                            continue
                        }
                    }
                }
            }
        }
        catch {
            validHotDupes := "`nError reading hotstring library. Please check file."
        }
        
        ; Format the duplicate messages
        if validHotDupes != ""
            validHotDupes := SubStr(validHotDupes, 2)  ; Trim leading newline
            
        ; Check for potential misspellings
        if State.TriggerMatches > 0 {
            validHotMisspells := "This trigger string will misspell [" State.TriggerMatches "] words."
        }
        
        ; Combine results
        if validHotDupes && validHotMisspells
            result.validHot := validHotDupes "`n-" validHotMisspells
        else if !validHotDupes && !validHotMisspells
            result.validHot := Config.ValidOkMessage
        else
            result.validHot := validHotDupes validHotMisspells
    }
}

; =============== DICTIONARY FUNCTIONALITY ===============
; ===== Left-Clicking the "Look" Button Uses WordNet =====
; George A. Miller (1995). WordNet: A Lexical Database for English.
; Communications of the ACM Vol. 38, No. 11: 39-41.
; Christiane Fellbaum (1998, ed.) WordNet: An Electronic Lexical Database. Cambridge, MA: MIT Press.
; Princeton University "About WordNet." WordNet. Princeton University. 2010. 
; https://wordnet.princeton.edu/

; ======== Right-Clicking the Button uses GCIDE =========
; GNU Collaborative International Dictionary of English
; https://gcide.gnu.org.ua/
; =======================================================
class Dictionary {
    static instance := ""
    static definitions := Map()
    static isLoaded := false
    static isLoading := false
    static loadingStatus := ""
    static WORDNET_PATH := "..\Resources\Dictionary\WordNet-3.0\dict\"
    
    ; Temporary references for optional ChatGPT module
    static _DefinitionGui := ""
    static _DefinitionWord := ""
    static _DefinitionEdit := ""
    
    ; Optional callback after Dictionary GUI is created
    static _PostShowCallback := ""
    
    ; Start loading dictionary in background
    static StartBackgroundLoad() {
        if !this.isLoaded && !this.isLoading {
            this.isLoading := true
            this.loadingStatus := "Initializing..."
            SetTimer(() => this.LoadDictionary(), -100)
        }
    }
    
    ; Load dictionary data
    static LoadDictionary() {
        posMap := Map(
            "noun", "Loading nouns...",
            "verb", "Loading verbs...",
            "adj", "Loading adjectives...",
            "adv", "Loading adverbs..."
        )
        
        for dfile, statusMsg in posMap {
            this.loadingStatus := statusMsg
            
            indexFile := this.WORDNET_PATH "index." dfile
            dataFile := this.WORDNET_PATH "data." dfile
            
            if FileExist(indexFile) && FileExist(dataFile) {
                entries := this._ReadIndexFile(indexFile, dataFile)
                
                for word, def in entries {
                    if this.definitions.Has(word)
                        this.definitions[word] .= "`n[" dfile "]" def
                    else
                        this.definitions[word] := "[" dfile "]" def
                }
            }
        }
        
        this.isLoaded := true
        this.isLoading := false
        this.loadingStatus := "Ready"
    }
    
    ; Read data file for dictionary
    static _ReadDataFile(filePath) {
        if !FileExist(filePath)
            return Map()
            
        dataMap := Map()
        try {
            fileContent := FileRead(filePath, "UTF-8")
            isHeader := true
            
            for line in StrSplit(fileContent, "`n", "`r") {
                if line = ""
                    continue
                    
                if isHeader && RegExMatch(line, "^\d")
                    isHeader := false
                    
                if isHeader
                    continue
                    
                if InStr(line, "|") {
                    synsetOffset := SubStr(line, 1, 8)
                    if RegExMatch(line, "\|(.*)", &match) {
                        defText := Trim(match[1])
                        if defText != ""
                            dataMap[synsetOffset] := defText
                    }
                }
            }
        }
        return dataMap
    }

    ; Read index file for dictionary
    static _ReadIndexFile(filePath, dataFilePath) {
        if !FileExist(filePath)
            return Map()
            
        entries := Map()
        dataContent := this._ReadDataFile(dataFilePath)
        
        try {
            fileContent := FileRead(filePath, "UTF-8")
            isHeader := true
            
            for line in StrSplit(fileContent, "`n", "`r") {
                if line = ""
                    continue
                    
                if isHeader && SubStr(line, 1, 1) != " "
                    isHeader := false
                    
                if isHeader
                    continue
                    
                fields := StrSplit(RegExReplace(line, "\s+", " "), " ")
                if fields.Length < 4
                    continue
                    
                word := fields[1]
                offsets := []
                
                for field in fields {
                    if RegExMatch(field, "^\d{8}$") {
                        offsets.Push(field)
                        if offsets.Length >= 3
                            break
                    }
                }
                
                definitions := ""
                for offset in offsets {
                    if dataContent.Has(offset)
                        definitions .= "`n  • " dataContent[offset]
                }
                
                if definitions != ""
                    entries[word] := definitions
            }
        }
        return entries
    }
    
    ; Look up a word in the dictionary
    static LookupWord(word) {
        if !this.isLoaded {
            if !this.isLoading
                this.StartBackgroundLoad()
            return "Dictionary is still loading. Current status: " this.loadingStatus
        }
        
        ; Clean and prepare the search word
        word := StrLower(Trim(word))
        
        ; Try exact match first
        if this.definitions.Has(word)
            return this.definitions[word]
        
        ; Try with underscores instead of spaces
        wordWithUnderscores := StrReplace(word, A_Space, "_")
        if this.definitions.Has(wordWithUnderscores)
            return this.definitions[wordWithUnderscores]
        
        ; Try with spaces instead of underscores
        wordWithSpaces := StrReplace(word, "_", A_Space)
        if this.definitions.Has(wordWithSpaces)
            return this.definitions[wordWithSpaces]
        
        return "Word not found."
    }
    
    ; Find similar words for suggestions
    static FindSimilarWords(partial, limit := 5) {
        if !this.isLoaded {
            if !this.isLoading
                this.StartBackgroundLoad()
            return []
        }
        
        similar := []
        count := 0
        
        for word in this.definitions {
            if InStr(word, partial) = 1 && count < limit {
                similar.Push(word)
                count++
            }
        }
        
        return similar
    }
    
    ; Show dictionary definition in a GUI
    static ShowDefinitionGui(word) {
        ; Get the definition - use loading message if dictionary isn't ready yet
        if !this.isLoaded {
            if !this.isLoading {
                this.StartBackgroundLoad()
            }
            definition := "Dictionary is still loading...`n`nCurrent status: " this.loadingStatus "`n`nYou can still use 'Try GCIDE' or 'Try ChatGPT' while waiting, or close this window and try again in a moment."
        } else {
            definition := this.LookupWord(word)
        }
    
        dictGui := Gui()
        dictGui.SetFont(Config.LargeFontSize, "Segoe UI")
        dictGui.SetFont(Config.FontColor)
        dictGui.BackColor := Config.FormColor
        
        dictGui.Add("Text", "y10", "Definition for: " word)
        
        ; Use Edit control styled as text for the definition
        defEdit := dictGui.Add("Edit", "xm y+10 w500 r10 ReadOnly -E0x200 -WantReturn -TabStop", definition)
        defEdit.Opt("Background" Config.FormColor)
        
        ; Add buttons
        closeBtn := dictGui.AddButton("x10 y+10", "Close")
        dictGui.AddButton("x+8", "Copy Text").OnEvent("Click", (*) => A_Clipboard := definition)
        dictGui.AddButton("x+8", "Try GCIDE").OnEvent("Click", (*) => Run("https://gcide.gnu.org.ua/?q=" word "&define=Define&strategy=."))
        
        ; Store references for optional ChatGPT module to add its button post-hoc
        this._DefinitionGui := dictGui
        this._DefinitionWord := word
        this._DefinitionEdit := defEdit
        
        ; Setup events
        closeBtn.OnEvent("Click", (*) => dictGui.Destroy())
        dictGui.OnEvent("Escape", (*) => dictGui.Destroy())
        
        ; Call optional post-show callback (for ChatGPT module, etc.)
        callback := this._PostShowCallback
        if (callback != "") {
            callback(dictGui, word, defEdit)
        }
        
        dictGui.Show("AutoSize")
        closeBtn.Focus()
    }
}

; =============== UTILITY FUNCTIONS ===============

class Utils {
    ; Process selected text from an edit control
    static ProcessSelectedText(callback) {
        if !IsObject(State.CurrentEdit) {
            return false
        }
        
        EM_GETSEL := 0xB0
        start := 0
        end := 0
        DllCall("SendMessage", "Ptr", State.CurrentEdit.hwnd, "Uint", EM_GETSEL, "Ptr*", &start, "Ptr*", &end)
        
        if start != end {
            text := StrReplace(State.CurrentEdit.Value, "`n", "`r`n")
            selected := SubStr(text, start + 1, end - start)
            A_Clipboard := selected
            word := Trim(A_Clipboard)
            
            if word != "" {
                callback(word)
                return true
            }
        }
        return false
    }
    
    /*
    ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=139205
    ; Get spelling/grammar suggestions from LanguageTool API
    ; USAGE: 
    ; Get full corrected sentence (default)
    msgbox SpellingGrammarSuggestion("I are going now.")  ; Returns: "I am going now."
    ; Get just the replacement word
    msgbox SpellingGrammarSuggestion("I are going now.", false)  ; Returns: "am"
    ; Works with single words too
    msgbox SpellingGrammarSuggestion("wisard")  ; Returns: "wizard"
    */

    ;====The=Function================================
    Static SpellingGrammarSuggestion(text, returnFullText := true) {
        objReq := ComObject('WinHttp.WinHttpRequest.5.1')
        url := 'https://api.languagetool.org/v2/check'
        postData := 'text=' text '&language=en-US'
        
        objReq.Open('POST', url)
        objReq.SetRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        objReq.Send(postData)
        
        response := objReq.ResponseText
        
        ; Find all corrections - replacements comes BEFORE offset/length in JSON
        corrections := []
        pos := 1
        
        while (pos := RegExMatch(response, '"replacements":\[\{"value":"([^"]+)"[^\]]*\],"offset":(\d+),"length":(\d+)', &match, pos)) {
            corrections.Push({
                offset: Integer(match[2]),
                length: Integer(match[3]),
                replacement: match[1]
            })
            pos += match.Len
        }
        
        if corrections.Length == 0
            return text
        
        if returnFullText {
            ; Apply corrections in reverse order (so offsets stay valid)
            correctedText := text
            
            ; Sort by offset descending
            Loop corrections.Length - 1 {
                i := corrections.Length - A_Index
                Loop i {
                    if corrections[A_Index].offset < corrections[A_Index + 1].offset {
                        temp := corrections[A_Index]
                        corrections[A_Index] := corrections[A_Index + 1]
                        corrections[A_Index + 1] := temp
                    }
                }
            }
            
            for corr in corrections {
                correctedText := SubStr(correctedText, 1, corr.offset) . corr.replacement . SubStr(correctedText, corr.offset + corr.length + 1)
            }
            
            return correctedText
        }
        else {
            return corrections[1].replacement
        }
    }

    ; Show spelling suggestion in a GUI
    static ShowSpellingSuggestionGui(originalText, suggestion) {
        suggestionGui := Gui("+AlwaysOnTop")
        suggestionGui.SetFont(Config.LargeFontSize)
        suggestionGui.SetFont(Config.FontColor)
        suggestionGui.BackColor := Config.FormColor
        
        ; Determine width based on text length
        longerText := StrLen(originalText) > StrLen(suggestion) ? originalText : suggestion
        isLongText := StrLen(longerText) > 90
        guiWidth := isLongText ? "w600 " : ""
        
        ; Only show original text for shorter strings
        if !isLongText {
            suggestionGui.Add("Text", "y10", "Original text:")
            suggestionGui.Add("Text", guiWidth "xm y+0", originalText)
            suggestionGui.Add("Text", "xm y+15", "Suggested correction:")
        } else {
            suggestionGui.Add("Text", "y10", "Suggested correction:")
        }
        
        suggestionGui.Add("Text", guiWidth "xm y+0", suggestion)
        
        ; Add buttons
        useSuggestionBtn := suggestionGui.AddButton(" y+20", "Use Suggestion")
        cancelBtn := suggestionGui.AddButton("x+8", "Cancel")
        
        ; Setup events
        useSuggestionBtn.OnEvent("Click", (*) => (
            UI.Controls["ReplacementEdit"].Value := suggestion,
            UIActions.FilterWordLists(),
            suggestionGui.Destroy()
        ))
        
        cancelBtn.OnEvent("Click", (*) => suggestionGui.Destroy())
        suggestionGui.OnEvent("Escape", (*) => suggestionGui.Destroy())
        
        suggestionGui.Show("AutoSize")
        useSuggestionBtn.Focus()
    }

    ; Look up selected text in editor
    static LookupSelectedText(text, editControl) {
        if !WinExist(Config.HotstringLibrary) {
            Run(Config.EditorPath " " Config.HotstringLibrary)
            while !WinExist(Config.HotstringLibrary)
                Sleep(50)
        }
        
        WinActivate(Config.HotstringLibrary)
        Sleep(300)
        
        if RegExMatch(text, "^\d{2,}")
            SendInput("^g" text)
        else {
            SendInput("^f^v")
        }
        
        ; Return focus to edit control
        if IsObject(editControl)
            editControl.Focus()
    }
    
    ; Initialize the application by checking clipboard content
    static CheckClipboard() {
        ; Save old clipboard content
        State.ClipboardOld := ClipboardAll()
        
        ; Reset state
        State.Reset()
        
        ; Check if the call comes from command line
        global A_Args
        if A_Args.Length > 0 {
            ; Ensure frequency data is loaded synchronously before processing the argument
            WordFrequency.LoadSync()
            
            A_Clipboard := A_Args[1]
            A_Args := []  ; Clear arguments after use
        }
        else {
            ; Check if Suggester Tool or MCLogger are active and clipboard contains a hotstring
            hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<Comm>\h+;.+)?$"
            clipContent := Trim(A_Clipboard, " `t`n`r")

            ; Check if systray is currently active
            currentClass := ""  ; Initialize as empty
            try currentClass := WinGetClass("A")
            If (currentClass = "Shell_TrayWnd")||(currentClass = "NotifyIconOverflowWindow") {
                ; If systray active, put saved clipboard content back.
                A_Clipboard := State.ClipboardOld
            }
            else if !((WinActive("Hotstring Suggester - Results")||WinActive("MCLogger.ahk")||WinActive("AC Analysis Report")) && clipContent != "" && RegExMatch(clipContent, hsRegex)) {
                ; If Suggester/MCL not active or clipboard doesn't contain a hotstring, 
                ; clear clipboard and copy selected text

                A_Clipboard := ""
                Send("^c")
                ClipWait(0.3)
            }
        }

        ; Check for hotstring pattern in clipboard
        clipContent := Trim(A_Clipboard, " `t`n`r")
        ; Regexes based on those from AndyNBody.
        hsRegex := "(?Jim)^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::(?:f\((?<Repl>[^,)]*)[^)]*\)|(?<Repl>[^;\v]+))?(?<Comm>\h+;.+)?$"
        comRegEx := "i);\h*(?<Freq>WEB\h+FREQ\h+\d+\.\d+)?[\h,|]*(?<Fix>\bFIXES\h*\d+\h*WORDS?\b)?[\h,|]*(?<mCom>.*)$"
        
        ; If clipboard contains a hotstring, parse it
        if RegExMatch(clipContent, hsRegex, &hotstr) {
            UI.Controls["TriggerEdit"].Text := hotstr.Trig
            UI.Controls["OptionsEdit"].Value := hotstr.Opts
            UI.Controls["FunctionCheck"].Value := Config.MakeFuncByDefault
            
            Sleep(200)  ; prevents intermittent error
            
            State.OrigTrigger := hotstr.Trig
            State.TrigNeedle_Orig := hotstr.Trig
            
            hotstr.Repl := Trim(hotstr.Repl, '"')
            UI.Controls["ReplacementEdit"].Text := hotstr.Repl
            
            ; Process the comment to extract only the manual part
            if (hotstr.Comm) {
                ; Use the new regex to parse the comment portion
                if RegExMatch(hotstr.Comm, comRegEx, &comment) {
                    ; Extract the manual part of the comment
                    manualComment := comment.mCom
                    if (manualComment && Trim(manualComment) != "") {
                        UI.Controls["CommentEdit"].Text := Trim(manualComment)
                    } else {
                        UI.Controls["CommentEdit"].Text := ""
                    }
                } else {
                    ; If comment regex doesn't match, use the whole comment (legacy support)
                    UI.Controls["CommentEdit"].Text := Trim(StrReplace(hotstr.Comm, ";", ""))
                }
            } else {
                UI.Controls["CommentEdit"].Text := ""
            }
            
            State.OrigReplacement := hotstr.Repl
            
            ; Set radio buttons based on options
            if InStr(hotstr.Opts, "*") && InStr(hotstr.Opts, "?")
                UI.Controls["MiddleRadio"].Value := 1
            else if InStr(hotstr.Opts, "*")
                UI.Controls["BeginningRadio"].Value := 1
            else if InStr(hotstr.Opts, "?")
                UI.Controls["EndingRadio"].Value := 1
            else
                UI.Controls["MiddleRadio"].Value := 1
            
            Debug("About to call ExamineWords")
            Debug("WordFrequency state before ExamineWords: isLoaded=" WordFrequency.isLoaded)

            ; Always close Control Pane and open Exam Pane
            ; This ensures proper state management
            UIActions.ShowHideControlPane(false)
            State.ControlPaneOpen := 0
            
            UI.Controls["ExamButton"].Text := "Done"
            UIActions.ShowHideExamPane(true)

            Debug("just before UIActions.ExamineWords()")
            UIActions.ExamineWords(hotstr.Trig, hotstr.Repl)
            Debug("just after UIActions.ExamineWords()")

            State.ExamPaneOpen := 1
            
            ; Reset history for add-a-letter feature
            State.TriggerHistory := []
            State.ReplacementHistory := []
            UI.Controls["UndoButton"].Enabled := false
            
            ; Force synchronization for add-a-letter functionality
            UIActions.OnTriggerChanged()
        } else {
            ; Handle normal startup when clipboard doesn't contain a hotstring
            Utils.HandleNormalStartup(A_Clipboard)
        }
        
        ; Reset trigger matches for validation
        State.TriggerMatches := 0
        
        ; Reset undo history
        UI.Controls["UndoButton"].Enabled := false
        State.TriggerHistory := []
        State.ReplacementHistory := []
        
        ; Show UI
        UI.MainForm.Show("AutoSize yCenter")
        UI.SetInitialFocus()  ; Set focus based on config
    }
        
    ; Handle normal startup when clipboard doesn't contain a hotstring
    static HandleNormalStartup(content) {
        ; Reset IsBoilerplate flag
        State.IsBoilerplate := 0

        ; Determine if this is boilerplate text or a typo
        if (StrLen(content) - StrLen(StrReplace(content, " ")) > 2) || InStr(content, "`n") {
            ; Likely boilerplate text
            UI.Controls["OptionsEdit"].Text := Config.DefaultBoilerPlateOpts
            UI.Controls["ReplacementEdit"].Value := content
            
            State.IsBoilerplate := 1
            UI.Controls["FunctionCheck"].Value := 0  ; Don't make multi-line items into functions
            
            ; Also add this line to set the label correctly
            UI.Controls["TriggerLabel"].Text := "Trigger String"
            UI.Controls["TriggerLabel"].SetFont(Config.FontColor)
            
            ; Generate acronym from first letters if configured
            if Config.FirstLettersToInclude > 0 {
                initials := ""
                textForAcronym := StrReplace(content, "`n", " ")
                
                Loop Parse, textForAcronym, A_Space, A_Tab {
                    if StrLen(A_LoopField) > Config.MinWordLength {
                        initials .= SubStr(A_LoopField, 1, 1)
                    }
                    
                    if StrLen(initials) = Config.FirstLettersToInclude {
                        break
                    }
                }
                
                initials := StrLower(initials)
                UI.Controls["TriggerEdit"].Value := Config.BoilerplatePrefix initials Config.BoilerplateSuffix
            }
            else {
                UI.Controls["TriggerEdit"].Value := Config.BoilerplatePrefix Config.BoilerplateSuffix
            }
        }
        else if content = "" {
            ; Empty clipboard, clear form
            UI.Controls["OptionsEdit"].Text := ""
            UI.Controls["TriggerEdit"].Text := ""
            UI.Controls["ReplacementEdit"].Text := ""
            UI.Controls["CommentEdit"].Text := ""
            
            UI.Controls["BeginningRadio"].Value := 0
            UI.Controls["MiddleRadio"].Value := 0
            UI.Controls["EndingRadio"].Value := 0
        }
        else {
            ; Likely a typo/autocorrect entry
            if Config.AutoEnterNewEntry = 1 {
                State.TargetWindow := WinActive("A")
                State.OrigTriggerTypo := content
            }
            
            UI.Controls["TriggerEdit"].Value := Trim(StrLower(content))
            UI.Controls["ReplacementEdit"].Value := Trim(StrLower(content))
            UI.Controls["OptionsEdit"].Text := Config.DefaultAutoCorrectOpts
            UI.Controls["FunctionCheck"].Value := Config.MakeFuncByDefault
        }
        
        ; Ensure replacement field is editable
        UI.Controls["ReplacementEdit"].Opt("-Readonly")
        UI.Controls["AppendButton"].Enabled := true
        
        ; Filter word lists
        UIActions.FilterWordLists()
    }
}

; =============== WORD FREQUENCY FUNCTIONALITY ===============

class WordFrequency {
    static wordFreqMap := Map()
    static isLoaded := false
    static isLoading := false
    static EXPECTED_WORD_COUNT := 88916
    static DATA_FILE := Config.FrequencyListFile
    
    ; Initialize word frequency data
    static Initialize() {
        if (!this.isLoaded && !this.isLoading) {
            this.isLoading := true
            Debug("Starting to load word frequency data")
            return this.LoadWordFrequencies()
        }
        return this.isLoaded
    }
    
    ; Load word frequencies from CSV file
    static LoadWordFrequencies() {
        try {
            ; Clear existing data
            this.wordFreqMap.Clear()
            
            filePath := this.DATA_FILE
            Debug("Reading word frequency CSV file: " filePath)
            
            ; Process the file directly from disk, one line at a time
            wordCount := 0
            duplicateCount := 0
            skippedLines := 0
            
            ; Check if file exists
            if (!FileExist(filePath)) {
                LogError("Word frequency file not found: " filePath)
                this.isLoading := false
                return false
            }
            
            ; Open the file for reading
            file := FileOpen(filePath, "r")
            if (!file) {
                LogError("Could not open word frequency file: " filePath)
                this.isLoading := false
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
                    if (this.wordFreqMap.Has(word)) {
                        duplicateCount++
                        ; For duplicates, add the frequencies together
                        this.wordFreqMap[word] += freq
                    } else {
                        ; Add new word
                        this.wordFreqMap[word] := freq
                        wordCount++
                    }
                }
            }
            
            ; Close the file
            file.Close()
            
            Debug("Word frequency data loaded - Unique words: " wordCount)
            Debug("Duplicate entries found: " duplicateCount)
            Debug("Skipped lines: " skippedLines)
            
            this.isLoaded := true
            this.isLoading := false
            return true
        }
        catch Error as err {
            LogError("Error loading word frequency file: " err.Message)
            this.isLoading := false
            return false
        }
    }

    ; Add a synchronous loading method to the WordFrequency class
    static LoadSync() {
        Debug("LoadSync called - isLoaded=" this.isLoaded ", isLoading=" this.isLoading)
        if (!this.isLoaded) {
            this.isLoading := true
            result := this.LoadWordFrequencies()
            this.isLoading := false
            this.isLoaded := result
            return result
        }
        return true
    }
    
    ; Calculate total frequency for a list of words
    static CalculateFrequency(wordList) {
        ; Ensure data is loaded
        if (!this.isLoaded) {
            Debug("WordFrequency: Data not loaded when CalculateFrequency was called")
            if (!this.LoadSync()) {
                LogError("Failed to initialize frequency data for calculation")
                return 0
            }
        }
        
        ; Handle empty input
        if (wordList = "") {
            Debug("WordFrequency: Empty word list provided to CalculateFrequency")
            return 0
        }
        
        ; Process word list
        totalFreq := 0
        wordList := Trim(wordList)
        
        ; Count words for debugging
        wordCount := 0
        foundCount := 0
        
        ; Split by newlines
        words := StrSplit(wordList, "`n")
        
        ; Process each word
        for word in words {
            ; Clean the word (remove whitespace)
            cleanWord := Trim(word)
            
            ; Skip empty words
            if (cleanWord = "")
                continue
                
            wordCount++
            
            ; Convert to lowercase for case-insensitive comparison
            cleanWord := StrLower(cleanWord)
            
            ; Look up the word in the frequency map
            if (this.wordFreqMap.Has(cleanWord)) {
                freq := this.wordFreqMap[cleanWord]
                totalFreq += freq
                foundCount++
            }
        }
        
        Debug("WordFrequency: Processed " wordCount " words, found " foundCount " in frequency database")
        Debug("WordFrequency: Total frequency calculated: " totalFreq)
        
        return totalFreq
    }
        
    ; Format frequency in millions with 2 decimal places
    static FormatFrequency(freq) {
        return Format("{:.2f}", freq / 1000000)
    }
}

; =============== MAIN PROGRAM ===============

TraySetIcon(A_ScriptDir "\..\Resources\Icons\AhkBluePsicon.ico")
;TrayTip("HotString Helper 2", "Running - Press " Config.HotstringHelperActivationHotkey " to activate", 10)

; Initialize UI components
UI.Init()

; Initialize word frequency data in the background
SetTimer(() => WordFrequency.Initialize(), -500)  ; Start loading x seconds after script startup

; Set up form-specific hotkeys
UI.SetupFormHotkeys()

; Register activation hotkey with a delay
SetTimer(RegisterHotkeyDelayed, -250)  ; x-second delay

; Add this function somewhere appropriate, perhaps near your other helper functions
RegisterHotkeyDelayed() {
    try {
        Hotkey(Config.HotstringHelperActivationHotkey, (*) => Utils.CheckClipboard())
        Debug("Successfully registered activation hotkey after delay: " Config.HotstringHelperActivationHotkey)
    } catch Error as err {
        LogError("Failed to register delayed activation hotkey: " err.Message)
    }
}

; Check command line arguments
if A_Args.Length > 0
    Utils.CheckClipboard()


; Helper functions for conditional error/debug logging.  
; This is not for "End user" purposes, it is for mainstaining the code. 
LogError(message) {
    if (Config.CODE_ERROR_LOG) {
        FileAppend("ErrLog: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Debug\ac2_error_debug_log.txt")
    }
}
Debug(message) {
    if (Config.CODE_DEBUG_LOG) {
        FileAppend("Debug: " formatTime(A_Now, "MMM-dd hh:mm:ss") ": " message "`n", "..\Debug\ac2_error_debug_log.txt")
    }
}

If (Config.ACLogAnalyzerHk != "")
    Hotkey(Config.ACLogAnalyzerHk, RunACLogAnalyzer)
RunACLogAnalyzer(*) {
    Run(Config.AcLogAnalyzer) ; Run AutoCorrection Log Analyzer tool.
}

;===============================================================================
#HotIf WinActive(Config.ScriptName) || WinActive(Config.HotstringLibrary) || WinActive("AutoCorrectSystem.ahk" ) ; If this file is open and active.
^s:: ; When you press Ctrl+s, this scriptlet will save the file, then reload it to RAM.  ; hide
{
	Send("^s") ; Save me.
	MsgBox("Reloading...", "", "T0.3")
	Sleep(500)
	Reload() ; Reload me too.
	MsgBox("I'm reloaded.") ; Pops up then disappears super-quickly because of the reload.
}

#HotIf WinActive(Config.HHWindowTitle) ; Only if hh2 window is active.
F1::HelpSystem.ShowHelp() ; Show help for whatever window control is focused. ; hide

#HotIf

class HelpSystem {
    static helpTexts := Map()
    static helpGui := 0
    
    ; Initialize help texts for all controls
    static Init() {
        ; Main edit controls
        this.helpTexts["OptionsEdit"] := "This is the Options edit box.`nOptions control how the hotstring behaves.`n`nCommon options:`n--------------------------`n* = no end character needed`n? = trigger inside other words`nC = case sensitive`nB0 = don't backspace the trigger`nX = Execute code instead of typing.`n`nDon't use below with f() function:`n--------------------------`nSI = send input mode`nSE = send event mode`nKn = set key delay (n is a digit)`nO = omit end char`nR = send as raw"
        
        this.helpTexts["TriggerEdit"] := "This is the Trigger string edit box.`n`nThe text entered here is what will be watched-for and will trigger the hotstring replacement.`n`nFor AutoCorrect entries, this will usually be a misspelled word or word-part.  Or it might be a short phrase with a grammar error.`n`nFor boilerplate template entries, this will be an easy to remember acronym or short string. When multiple lines of text, or more than three words, are selected, and the hotkey is pressed, an acronym is auto-generated from the first letter of the first words. Try it with this paragraph :) Optionally assign a default prefix character in the variables near the top of the code.`n`nWhen making single-word AutoCorrect entries, the number of potential misspellings will be shown in red above the editbox.`n`nPressing Shift+Left jumps to trigger box and moves cursor to home position."
        
        this.helpTexts["ReplacementEdit"] := "This is the Replacement edit box.`n`nThe text entered here will replace the trigger text when the hotstring is activated.`n`nFor AutoCorrect items, this will be a corrected spelling or perhaps a short phrase with corrected grammar, but for boilerplate template items, this will be the actual boilerplate text.`n`nNote: When pressing the 'Spell' button, the string in the Replacement box gets looked-up.   It does not have to be selected first.  The 'Look' button expects to find selected text though."
        
        this.helpTexts["CommentEdit"] := "This is the Comment edit box.`n`nComments are added to the hotstring as in-line AHK comments. They are useful for documenting what the hotstring does.`n`nFor AutoCorrect items: Web-Frequency totals and Potential Fixes are (optionally) automatically added to the comments.`n`nAuto comments also include a flag for potential misspellings.  If there are fewer than four words, the words are listed.  If more, the number of words is given. Tip: To prevent this flag from being added, delete any words from the Misspells box just before appending."
        
        ; Buttons and checkboxes
        this.helpTexts["SizeToggle"] := "This is the toggle button to make the replacement text area larger or smaller.`n`nThis mostly applies to large boilerplate texts, not autocorrects.`n`nThe amount of width/height increase can be customized in the Settings Manager.`n`nIf the Exam Pane or Control Pane is open, this will close it."
        
        this.helpTexts["SymbolToggle"] := "Toggle button to show special characters: spaces, tabs, and line breaks as visible symbols.`n`nThe symbols used can be customized in the code.  (They can't be in the INI file because they are unicode chars.)`n`nTip: Including a space with the Pilcrow or Dot allows more natural text-wrapping in the Replacement box.`n`nThis mostly applies to large boilerplate texts, not autocorrects."
        
        this.helpTexts["FunctionCheck"] := "When checked, your hotstring will be created using the f() function that enables logging, backspace (error-correction) detection, automatic rarefication, and Descolada InputBuffering.`n`nMulti-line `"Coninuation section`" style hotstrings are never wrapped in function calls.`n`nTip: If you never want the function calls, search for 'MakeFuncByDefault := 1' in the 'HotstringHelper' section of the Setting Manager, and set it to `"Vanilla.`"  Also checkout the Defunctionizer script in the Control Pane."
        
        this.helpTexts["AppendButton"] := "Adds the current hotstring to your library file and reloads the script.`n`nNote that a validation is also done when clicking Append, though the Validation Report is only shown if there is a problem. If there is a problem, the user is given the option to append anyway.`n`nShift+Click:`nCopies to clipboard instead.`n`nCtrl+Click:`nAppends without closing or reloading--useful for multiple simultaneous entries.`n`nAlt+Click:`nSends hotstring to Suggester Tool.`n`nPressing Enter will also append the new hotstring and restart the script, but not when the replacement box is focused.  In that case, pressing Enter just types a new line."
        
        this.helpTexts["CheckButton"] := "Validates the hotstring without adding it to your library.`n`nThere is a `'Look up`' button in the Validation report.  Select the hotstring from the report and click button to go to string in library in default editor using Ctrl+F.  If line number is selected, Ctrl+G will be used to goto line number.`n`nDuring validation, several things are checked for, but mostly the trigger is compared to existing library items, checking for conflicts.  Please see User Manual for further discussion.`n`nNote that a validation is also done when clicking Append, though the Validation Report is only shown if there is a problem."
        
        this.helpTexts["ExamButton"] := "Opens the Exam Pane to analyze the trigger and replacement which is useful for creating multi-match autocorrect entries.`n`nRight-click to access the Secret Control Panel.`n`nIf pane is open, button text will change to `"Done`"."
        
        this.helpTexts["SpellButton"] := "Uses LanguageTool.org's AI to check spelling of the replacement text.  If a suggested correction is found, it will offer to fix the word in the replacement text box.  It will check sentences for grammar mistakes as well.  It works well, but is not perfect.`n`nTip:  If it doesn't correct the grammar of a short phrase, try making the phrase into a complete sentence, and try again. "
        
        this.helpTexts["LookButton"] := "Looks up selected text in the onboard WordNet dictionary (https://wordnet.princeton.edu/).`n`nRight-click to search the GNU Collaborative International Dictionary of English (GCIDE; https://gcide.gnu.org.ua/) online.`n`n`n`nThe Spell button checks only the text in the replacement edit box, but definitions can be looked up for words in the replacement box or in the Misspells or Fixes Exam Pane lists.  HOWEVER the words must be selected with your mouse first.`n`nNote: It takes several seconds for WordNet to load in the background of AutoCorrect2, which happens automatically each time the script is restarted."
        
        this.helpTexts["CancelButton"] := "Closes the form without saving changes.`n`nThis will also replace the previous clipboard content.`n`nPressing the Esc key will have the same effect."
        
        ; Exam pane controls
        this.helpTexts["LeftTrimButton"] := "Removes one character from the beginning of both trigger and replacement.`n`nGood for use with word-end or word-middle AutoCorrect items. More trimming means it will match (fix) more words, but it also increases the risk of confounding misspellings (discussed in User Manual)."
        
        this.helpTexts["RightTrimButton"] := "Removes one character from the end of both trigger and replacement.`n`nGood for use with word-beginning or word-middle AutoCorrect items. More trimming means it will match (fix) more words, but it also increases the risk of confounding misspellings (discussed in User Manual)."
        
        this.helpTexts["BeginningRadio"] := "Sets the AutoCorrect hotstring to match word beginnings (adds * option).`n`nFor example `"app`" matches:`n-app`n-apple`n-application`n`nBut does not match:`n-zapp`n-snapple`n`nRight-clicking any of the three radio buttons sets them all to unchecked."
        
        this.helpTexts["MiddleRadio"] := "Sets the AutoCorrect hotstring to match anywhere in words (adds *? options).`n`nFor example `"app`" matches:`n-app`n-apple`n-application`n-zapp`n-snapple`n`nRight-clicking any of the three radio buttons sets them all to unchecked."
        
        this.helpTexts["EndingRadio"] := "Sets the AutoCorrect hotstring to match word endings (adds ? option).`n`nFor example `"ap`" matches:`n-zap`n-backstrap`n-ASAP`n`nBut does not match:`n-apple`n-sappling`n`nRight-clicking any of the three radio buttons sets them all to unchecked."
        
        this.helpTexts["UndoButton"] := "Undoes the last trim operation.`n`nShift+Click to reset to original words.`n`nCtrl+Z or Shift+Ctrl+Z also works.`n`nChanges to the radio buttons are not `"remembered`" for undoing--only trims are. "
        
        this.helpTexts["TriggerMatchesEdit"] := "Shows words that contain the trigger string based on selected match type.`n`nThese are words that would be erroneously `"mis-corrected`" by this hotstring.  I.e., if you typed the word correctly, the correct spelling would get changed.`n`nThe Web-Frequency total is based on the Kaggle.com list of `'The 1/3 Million Most Frequent English Words on the Web.`' The data is apparently derived from the Google Web Trillion Word Corpus. This offers a metric to whether the to-be-mis-corrected words are high-frequency words.`n`nThe Misspels number is simply the number of words in the list."
        
        this.helpTexts["ReplacementMatchesEdit"] := "Shows words that contain the replacement string, based on selected match type.`n`nThese are words that could potentialy be fixed by this AutoCorrect hotstring.`n`nThe Web-Frequency total is based on the Kaggle.com list of `'The 1/3 Million Most Frequent English Words on the Web.`' The data is apparently derived from the Google Web Trillion Word Corpus. This offers a metric to whether the to-be-fixed words are high-frequency words.`n`nThe Fixes number is simply the number of words in the list.`n`nThe idea is to trim the word and adjust the radio buttons such that the maximum number of words appear in this box, while none appear in the Misspells box.`n`nTip: If a word gets over-trimmed you can check for the best letters to put back by using the Suggester Tool (Alt-Click Append Button).  You'll know if you've trimmed an item too much because it will appear as a frequently-backspaced item on your AutoCorrectionLog analysis report."
        ; Control Panel buttons
        for index, buttonConfig in UI.controlButtons {
            switch buttonConfig.text {
                case " Open HotString Library":
                    this.helpTexts["ControlButton_OpenLibrary"] := "Opens your hotstring library file in your configured editor.`n`nThis allows you to directly view and edit all your hotstrings.`n`nScript will attempt to jump to the bottom of the file, where any new hotstrings are likely to be located.`n`nTip:  When adopting a newer version of the HotstringLib.ahk file from https://github.com/kunkel321/AutoCorrect2 it is recommended to use the UniqueStringExtracter tool.  This will allow you to not lose any custom hotstrings that you have, yourself, added.  Also, you'll see any hotstrings that you've manually removed from my working library."
                    
                case " Open AutoCorrection Log":
                    this.helpTexts["ControlButton_ACLog"] := "Opens the " config.AutoCorrectsLogFile " file.`n`nThis log contains a record of all autocorrections made using the f`(`) function, including whether a correction was backspaced, thus indicating a likely mis-application of the item.`n`nThe date of each logged item is present and separated from the item with a hyphen.`n`n<< = Backspace was pressed within one second.`n-- = Backspace not pressed within one second.`n`nNote: The script can't detect exactly WHAT you backspaced, only that the BS was pressed within one second.  There is, however, a Backspace Context Log that tries to help with this.`n`nThe AC Log file is analyzed by ACLogAnalyer.  Manually handling the log file is usually not needed.  The reading and writing from it is all automated. `n`nWhen adopting updated releases of the AutoCorrect2 suite, users should keep their own AutoCorrectsLog.txt and MannualCorrectionsLog.txt files.  The purpose of these is to log and analyze your own typing experiences.`n`nTip: If you don't care to ever use the logging features, go to the AutoCorrectSystem.ahk file, and change Global EnableLogging := 1 to 0."
                    
                case " Analyze AutoCorrection Log !^+Q":
                    this.helpTexts["ControlButton_ACAnalyze"] := "Runs the AutoCorrection Log Analyzer tool.`n`nThis tool analyzes your autocorrection log to identify problematic autocorrect items that you frequently backspace after triggering.`n`nThe hotkey Alt+Ctrl+Shift+Q can also be used to launch this tool.`n`nThe most-frequent errant hotstrings are returned as radio buttons in a report.`n`nSeveral actions can be taken on an item."
                    
                case " Open Backspace Context Log":
                    this.helpTexts["ControlButton_BSLog"] := "Opens the Error Context Log file.`n`nThis log contains detailed context information around autocorrection errors, showing what was typed before and after a problematic correction.`n`nThe context log items are accessed via the ACLogAnaylzer report, to help the user figure out why a particular AutoCorrect entry is problematic.`n`nIt is usually not necessary to access the log directly."
                    
                case " Open Removed HotStrings List":
                    this.helpTexts["ControlButton_RemovedHS"] := "Opens the RemovedHotstrings.txt file.`n`nThis file keeps track of hotstrings that have been removed in the past.`n`nThis helps prevent the user from inadvertently reintrocuding a hotstring that was found to be problematic in the past.`n`nThe HotstringHelper Validaton mechanism warns the user before appending a previously-removed string to the library.`n`nThe MCLogger will try not to log manual corrections that correspond to a hotstring that has been prevoiusly removed from the library."
                    
                case " Open Manual Correction Log":
                    this.helpTexts["ControlButton_MCLog"] := "Opens the Manual Correction Log file.`n`nThis log contains records of corrections you've made manually, which might be candidates for new autocorrect entries.`n`nThe log is accessed by the Manual Correction Log Anayzer.`n`nIt is usually not necessary to access the log directly.`n`nWhen adopting updated releases of the AutoCorrect2 suite, users should keep their own AutoCorrectsLog.txt and MannualCorrectionsLog.txt files.  The purpose of these is to log and analyze your own typing experiences."
                    
                case " Analyze Manual Correction Log #^+Q":
                    this.helpTexts["ControlButton_MCAnalyze"] := "Runs the Manual Correction Log Analyzer tool.`n`nThis tool helps identify patterns in your manual corrections that might be good candidates for new autocorrect entries.`n`nThe hotkey Win+Ctrl+Shift+Q can also be used to start the analysis process.`n`nIt is recommended to have the logger run in the background, to `"catch`" your manual corrections.`n`nA sophisticated series of events is used for this.  Please see the AutoCorrect2 User Manual."
                    
                case " Report HotStrings and Potential Fixes":
                    this.helpTexts["ControlButton_Report"] := "Generates a report showing statistics about your hotstring library.`n`nThis includes counts of different types of autocorrect entries and the total number of potential word fixes.`n`nThe total `"Web Frequency`" total is given, though anaylyzing this total number is less imporant that anaylyzing the WF of particular individual hotstrings."

                case " Configuration Settings Manager":
                    this.helpTexts["ControlButton_SettingsMan"] := "Runs the AutoCorrect2 Settings Manager Tool, which is a GUI-based tool for edting the user config initialization file, `"acSettings.ini`"."
                    
                case " Hotstring Suggester Tool":
                    this.helpTexts["ControlButton_Suggester"] := "Launches the Hotstring Suggester tool.`n`nThis tool helps generate related hotstrings based on an existing entry.  It is useful for creating variations of a hotstring.  When creating a mult-match word middle AutoCorrect item via trimming the ends, it is possible to over-trim.  The Suggester tool helps you choose which letter to put back--that's why it was made.`n`nThe Suggester tool is usually accessed via Alt+Clicking the Append button, or via the ACLogAnalyer report, though you can run it directly, and type/paste in a hotstring."
                    
                case " Extract Potential Misspellings":
                    this.helpTexts["ControlButton_ExtractMisspellings"] := "Launches the Extract Potential Misspellings tool.`n`nThis tool scans your HotstringLib.ahk file and generates a list of words that may be inadvertently misspelled by your autocorrect entries.`n`nThe tool looks for comments containing 'but misspells' and extracts those flagged words.`n`nYou can configure whether to include definitions and line numbers, making it easy to review and decide if any autocorrect entries should be removed to avoid misspelling words relevant to your work. The config options are in the .ahk file."

                case " Conflicting String Locator Tool":
                    this.helpTexts["ControlButton_ConflictingStringLocator"] := "This runs an INTRA-script scan, checking for hotstrings in the main part of your " Config.HotstringLibrary " file that might conflict with each other. A report document is created in the \Data\ folder and the report is opened upon completion of the scan.  It uses the same algorithms as the validiy tool.  It is thorough and is slow.  Please see AutoCorrect2 User Manual for more information."

                case " Compare Two Versions of HotstringLib":
                    this.helpTexts["ControlButton_UniqueStringExtractor"] := "This runs an INTER-script scan to compare two versions of the hotstring library:`n`n" Config.HotstringLibrary "`n" Config.NewTemporaryHotstrLib "`n`nIt will alert the user of hotstrings that are unique to each version.  This is meant to facilitate merging two versions of the library. It is recommended to choose a convenient temporary name for one the new version, such as `"HotstringLib (1).ahk`" then program that into the acSettings.ini file (current name is shown above) and use the same temporary name each time.  The tool will default to those paths.  If either is not found, a file chooser dialog will appear. A report document is created in the \Data\ folder and the report is opened upon completion of the scan."

                case " Defunctionize Hotstrings":
                    this.helpTexts["ControlButton_Defunctionizer"] := "This is for users who do not want their AutoCorrect items embedded in the f() function calls. The `"Defunctionizer`" tool removes them."

                case " Go to GitHub Repository":
                    this.helpTexts["ControlButton_GitHub"] := "Opens the GitHub repository for this tool, in your default web browswer."
                    
                case " Change Color Theme":
                    this.helpTexts["ControlButton_Theme"] := "Opens the Color Theme Integrator customization tool.`n`nThis allows you to change the colors of the HotstringHelper interface (as well as other apps) to match your preferences.  See the ColorThemeInt.ahk code to customize which apps (other than these in the AutoCorrect2 repository) should get colorized."
            }
        }
    }
    
    static ShowHelp(showGeneral := false) {
        ; Destroy existing help window if open
        if IsObject(this.helpGui)
            this.helpGui.Destroy()
            
        ; Get the currently focused control
        focusedControl := showGeneral ? "" : this.GetFocusedControl()
        
        ; Determine if panes are visible by checking if controls are visible
        examPaneVisible := UI.Controls["DeltaString"].Visible
        controlPaneVisible := UI.Controls["ControlPanelLabel"].Visible
        
        ; Determine help text based on focused control
        if focusedControl && this.helpTexts.Has(focusedControl) {
            ; Format the title based on the control type
            if InStr(focusedControl, "ControlButton_") {
                ; For control panel buttons, extract a clean title
                buttonType := StrReplace(focusedControl, "ControlButton_", "")
                
                ; Make title more user-friendly
                switch buttonType {
                    case "OpenLibrary":
                        helpTitle := "Help for 'Open HotString Library' button"
                    case "ACLog":
                        helpTitle := "Help for 'AutoCorrection Log' button"
                    case "ACAnalyze":
                        helpTitle := "Help for 'Analyze AutoCorrection Log' button"
                    case "BSLog":
                        helpTitle := "Help for 'Backspace Context Log' button"
                    case "RemovedHS":
                        helpTitle := "Help for 'Removed HotStrings List' button"
                    case "MCLog":
                        helpTitle := "Help for 'Manual Correction Log' button"
                    case "MCAnalyze":
                        helpTitle := "Help for 'Analyze Manual Correction Log' button"
                    case "Report":
                        helpTitle := "Help for 'Report HotStrings' button"
                    case "SettingsMan":
                        helpTitle := "Help for 'Settings Manager' button"
                    case "Suggester":
                        helpTitle := "Help for 'Hotstring Suggester Tool' button"
                    case "ExtractMisspellings":
                        helpTitle := "Help for 'Potential Misspellings Tool' button"
                    case "ConflictingStringLocator":
                        helpTitle := "Help for 'Conflicting String Locator Tool' button"
                    case "UniqueStringExtractor":
                        helpTitle := "Help for 'Unique String Extractor Tool' button"
                    case "Defunctionizer":
                        helpTitle := "Help for 'Defunctionizer Tool' button"
                    case "Theme":
                        helpTitle := "Help for 'Change Color Theme' button"
                    case "GitHub":
                        helpTitle := "Help for 'Go to GitHub Repository' button"
                    default:
                        helpTitle := "Help for Control Panel Button"
                }
            } else {
                helpTitle := "Help for " focusedControl
            }
            
            helpText := this.helpTexts[focusedControl]
        } else {
            helpTitle := "HotString Helper Help"
            helpText := "This is the Hotstring Helper 2.0 main window.`n`nUse this tool to create and analyze hotstrings for AutoCorrect2. Some of the functionality is for making AutoCorrect items, and some is for making boilerplate template items.`n`nPress F1 while focusing on a specific control (button, box, etc.) for more help and tips.  Press Tab to move between controls or Shift+Tab to move backwards.  This allows you to highlight buttons without actually pressing them.`n`nGet the latest AutoCorrect2 suite from https://github.com/kunkel321/AutoCorrect2`n`nMost of the user configurarion settings are in the Core\acSettings.ini file."
            
            If (examPaneVisible)
                helpText .= "`n`n------------------`nAt the bottom is the `"Exam Pane.`"`n`nThe Blue text is the Delta String and shows which parts of the trigger /replacement are unique vs. which parts are shared.`n`nFor example:`ncrea[s|t]ion shows:`tcreasion ---> creation.`nt[eh|he] shows:`t`tteh ---> the.`n[sp|ps]ych shows:`tspych ---> psych.`n`n`"Misspells`" shows the number of matches for the trigger string.  These are the words that will get erroneously mis-corrrected.  `"Fixes`" shows the number for the replacement, which is the list of words that will be corrected by the given hotstring.  Our goal, is to have many matches and no misspells.`n`nThe `"Web Frequency`" is expressed in millions, and is the number of total matches on the internet, for the list of words.  The frequency data is derived from the Google Web Trillion Word Corpus (Credit: Racheal Tatman, Kaggle.com).  The word list and CSV file are in the Resources\WordListsForHH\ folder. "
                
            If (controlPaneVisible)
                helpText .= "`n`n------------------`nAt the bottom is the `"Control Panel.`"`n`nIt contains buttons to launch several script-related tools and other things.  Some items are only shown conditionally.  The bottom `'Suggester`' and `'Color Theme`' buttons are only displayed if the corresponding apps are present in the AutoCorrect2 folder.  The log-related buttons are only displayed if logging is enabled in the Core\acSettings.ini file.`n`nThe icons are not compiled.  They are in the Resources\Icons\ folder. Most are from icons8.com"
        }
        
        ; Create help GUI
        this.helpGui := Gui("AlwaysOnTop", helpTitle)
        this.helpGui.SetFont("s10", "Courier New")
        fontColor := Config.FontColor != "" ? "c" SubStr(Config.FontColor, -6) : ""
        this.helpGui.SetFont(fontColor)
        this.helpGui.BackColor := Config.FormColor
        
        ; Use an Edit control for selectable text, styled as a label
        this.helpGui.Add("Edit", "w500 -VScroll ReadOnly -E0x200 -WantReturn -TabStop Background" Config.FormColor, helpText)
        
        ; Add close button
        closeBtn := this.helpGui.AddButton("Default", "Close")
        closeBtn.OnEvent("Click", (*) => this.helpGui.Destroy())
        
        ; Show the help window
        this.helpGui.Show()
        
        ; Set up event handlers
        this.helpGui.OnEvent("Escape", (*) => this.helpGui.Destroy())
    }
            
    ; Get the name of the currently focused control
    static GetFocusedControl() {
        ; First check main controls
        for ctrlName, ctrl in UI.Controls {
            try {
                if ctrl.Focused {
                    return ctrlName
                }
            } catch {
                ; Skip controls that don't support Focused property
                continue
            }
        }
        
        ; Then check Control Panel buttons
        if UI.Controls.Has("ControlButtons") && IsObject(UI.Controls["ControlButtons"]) {
            for index, button in UI.Controls["ControlButtons"] {
                try {
                    if button.Focused {
                        ; Map the button to its help text key based on text content
                        buttonText := button.Text
                        
                        ; This switch would be cleaner with a map, but we'll use if/else for clarity
                        if InStr(buttonText, "Open HotString Library")
                            return "ControlButton_OpenLibrary"
                        else if InStr(buttonText, "Open AutoCorrection Log")
                            return "ControlButton_ACLog"
                        else if InStr(buttonText, "Analyze AutoCorrection Log")
                            return "ControlButton_ACAnalyze"
                        else if InStr(buttonText, "Open Backspace Context Log")
                            return "ControlButton_BSLog"
                        else if InStr(buttonText, "Open Removed HotStrings List")
                            return "ControlButton_RemovedHS"
                        else if InStr(buttonText, "Open Manual Correction Log")
                            return "ControlButton_MCLog"
                        else if InStr(buttonText, "Analyze Manual Correction Log")
                            return "ControlButton_MCAnalyze"
                        else if InStr(buttonText, "Report HotStrings")
                            return "ControlButton_Report"
                        else if InStr(buttonText, "Configuration Settings Manager")
                            return "ControlButton_SettingsMan"
                        else if InStr(buttonText, "Extract Potential Misspellings")
                            return "ControlButton_ExtractMisspellings"
                        else if InStr(buttonText, "Hotstring Suggester Tool")
                            return "ControlButton_Suggester"
                        else if InStr(buttonText, "Conflicting String Locator Tool")
                            return "ControlButton_ConflictingStringLocator"
                        else if InStr(buttonText, "Compare Two Versions of HotstringLib")
                            return "ControlButton_UniqueStringExtractor"
                        else if InStr(buttonText, "Defunctionize Hotstrings")
                            return "ControlButton_Defunctionizer"
                        else if InStr(buttonText, "Go to GitHub Repository")
                            return "ControlButton_GitHub"
                        else if InStr(buttonText, "Change Color Theme")
                            return "ControlButton_Theme"
                    }
                } catch {
                    continue
                }
            }
        }
        return ""
    }
}

; In UI.Init() function, add after UI._SetupEventHandlers():
HelpSystem.Init()
