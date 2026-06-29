
/*
Color Theme Integrator
Kunkel321: 6-22-2026
https://github.com/kunkel321/ColorThemeIntegrator
https://www.autohotkey.com/boards/viewtopic.php?f=83&t=132310

WhiteColorBlackGradient function is based on ColorGradient() by Lateralus138 and Teadrinker. 
Calling the Windows color picker is also based on Teadrinker code.  
I Used Claude.ai for debugging several parts and doing the "split complemplementary" math. 
Some aspects are also from https://colordesigner.io/color-wheel

It is a Color Theme "Integrator" because is writes the colors to an ini file, which several of my other AHK gui-based tools read from.  

The colorArray has 120 elements, equidistantly circling the color wheel.  I've attempted to create two color wheel options:
* RGB uses "additive/light-based" color gradients.
* CYM is uses "subtractive/pigment-based" color gradients.
Both arrays start at red, then loop around, back to red.

Using terminology from the above colordesigner site...

Given a reference color, its "Complementary" color will be directly across from it, on the opposite side of the color wheel.  If, instead of choosing the Complementary color, you choose the two colors that are on equal-and-opposite sides of the Complementary color, then the three points will comprise a "Split Complementary" color set.  The below tool uses the color selected in the combobox as the reference color and determines which color in the colorArray is its Complementary color.  The first up/down box in the gui (“Split Size”) defines the number of steps from the Complementary position, that the other two colors should be.  

The three theme color variables are used:
* "fontColor" is the color of the text on the gui and in applicable controls.  I.e myGui.SetFont("c" fontColor)
* "listColor" is the background color of the listView, and other applicable controls.  I.e. "BackgroundColor" as appears in the gui control options. 
* "formColor" is the GUI background color.  I.e. myGui.BackColor := formColor
The fourth color is "outside of" the theme:
* "warnColor" is the color used in place of the formColor, when the gui/app is in an alternate state. 

The colors are assigned by default as:  
* fontColor = The reference color that appears in the comboBox.
* formColor = The color that appears in the posing Counter-Clockwise from the Complementary position. 
* listColor = The color that appears in the posing Clockwise from the Complementary position. 
This means that the color which is chosen in the top comboBox corresponds to the font color of the form.  The gui element (font/list/form) which is used for the reference color (and which corresponds to the top comboBox) can be changed with the second comboBox "... Is Reference."   
The four color, warnColor, is not part of this color pattern scheme and is only changed via double-clicking the warnColor item on the bottom of the ListBox.  However, when changing the light/darkness of the formColor, the warnColor's level of light/darkness will change with it.  If you don't have any projects with guis that use alternate Gui Backcolors, then you can ignore the warnColor. 

So… If the Split Size is 10 or 15 or so, then the pattern will be “Split Complementary.”  If the Split Size is set to 0, then the listColor and the fontColor will be at the same position and will be "Complementary" to the formColor.   If the Split Size is the max of 60, then all three colors will be at the same location and the theme will be "Monochromatic."  If the Split Size value is around 45 to 50, then the pattern will be “Analogous” (again, see colordesigner site).  And if the Split Size is 20, then the pattern will be a “Triad.”   As indicated above, the primary color is set in the top comboBox, and the other two are the split colors.  The split colors can swapped by setting a negative number as the Split Size.

With a gui, the font needs to “stand out” from the background color of the gui and the controls, so the  colors chosen will often need to be adjusted in terms of lightness/darkness.  Typically the font will be on one end of the light/dark continuum, and the background colors will be at the other end.  The Light/Dark radios swap this.  The bottom three up/down boxes are for fine-tuning the light/darkness. Please note that the Light/Dark radios do not affect the warnColor.  It must be manually changed. 

Similar to changing the shading, users may wish to "tone-down" one or more of the colors by reducing the saturation.  This is simulated by fading the color to gray.  The saturation up/down controls are next to the shading ones. Double-clicking the "ReSaturate" text label will reset the saturation levels to max.  And double-clicking the "UnShade" text label will set the shade spinners to the middle number (neither light, nor dark.)

Under the shading and saturation spinners is the 4-row ListBox.  This shows the hexadecimal color values that will get exported.   The ListBox is also an "override."  If you can't get a color you like with the Hue, Shade, and Saturation controls, double-click the row in the list to pick a totally different color.  This will call a Windows color picker (based strongly on Teadrinker code) and disregard the above gui controls.  Holding the Ctrl Key while double-clicking will allow you to "eyedropper-pick" a color from the screen.  Note that if you then change a Hue, Shade, or Saturation controls, those controls will, again, take presidence and determine the colors used for the first three items (font, list, form). 

The current four colors, as well as the values of all the controls, can be saved to a configuration (.ini) file as the main [ColorSettings] section, which is read by other apps.  The tool will attempt to read from the file at start.  If the ini file is not found when the script starts, default values will be applied.  Near the top of the code is the "restartTheseScripts" list.  The tool will look for a list or scripts to restart (so that their gui colors will be updated.)  When the save button is pressed, the user will be given the option to also restart these scripts.  Uncheck the checkbox to bypass restarting the other scripts. 

Added 11-29-2024, at the bottom is are the controls for saving favorive themes.  Each theme is saved as its own [Section] in the ini file. 

The script looks for command line arguments when it starts.  If there are command line arguments, the gui is shown at statup, and Esc or closing the form exits the app.  this was added so that the tool could be launched from the HotString Helper2 tool.
*/

#SingleInstance
#Requires AutoHotkey v2+

^Esc::ExitApp                       ; Ctrl+Esc Terminates entire script.
guiTitle := "Color Theme Integrator" ; OK to change title (here only).

global isPickingColor := 0          ; True while eyedropper (GetColorAtCursor) is running.
global pendingAction := ""          ; Deferred action (a Func) to run once the eyedropper notices
                                     ; it's been interrupted (Cancel/Escape/X while picking) and
                                     ; cleans itself up. See GetColorAtCursor()'s loop.
OnExit(RestoreCursorOnExit)         ; Safety net: always restore system cursor, no matter how the app exits.
RestoreCursorOnExit(*) {
    try SystemCursor("Show")
}

pinToTop            := 1            ; 1=Stay on top of other windows.
shadingSteps        := 30           ; Change number of steps, if desired.
saturationSteps     := 30           ; Change number of steps, if desired.

; *******************************************************
; *** REPLACE BELOW SCRIPT NAMES/PATHS WITH YOUR OWN ***
; Each of the below scripts should have code to read from the colorThemeSettings.ini file. 
; Recommended code to use in the other scripts:
/*
if FileExist("AutoCorrect2\Data\colorThemeSettings.ini") {
   settingsFile := "AutoCorrect2\Data\colorThemeSettings.ini"
   ; --- Get current colors from ini file. 
   fontColor := IniRead(settingsFile, "ColorSettings", "fontColor")
   listColor := IniRead(settingsFile, "ColorSettings", "listColor")
   formColor := IniRead(settingsFile, "ColorSettings", "formColor")
}
else { ; Ini file not there, so use these color instead. 
   fontColor := "0x1F1F1F", listColor := "0xFFFFFF", formColor := "0xE5E4E2"
}
*/
restartTheseScripts := " ; Path not needed if they are in same folder as this script.
(           
..\Core\AutoCorrect2.exe
..\..\HotKeyTool\HotKeyTool.exe
..\Core\MCLogger.exe
..\..\WayText\WayText.exe
..\..\Stickies\Sticky Notes.exe
..\..\TextToolbox\TextToolbox.exe
)"
; *******************************************************

TraySetIcon("shell32.dll",131)      ; Change tray icon, if desired. 

settingsFile := "..\Data\colorThemeSettings.ini" ; Assumes that file is in same location as this script.

If FileExist(settingsFile) {
    fontColor                := IniRead(settingsFile, "ColorSettings", "fontColor")
    listColor                := IniRead(settingsFile, "ColorSettings", "listColor")
    formColor                := IniRead(settingsFile, "ColorSettings", "formColor")
    warnColor                := IniRead(settingsFile, "ColorSettings", "warnColor") 
    myRadRGBVal              := IniRead(settingsFile, "ColorSettings", "myRadRGB")
    myRadCYMVal              := IniRead(settingsFile, "ColorSettings", "myRadCYM")
    setColorArrays() ; The arrays are large, so I put them at the bottom.  
    colorArray := (myRadRGBVal = 1)? additiveRGB : subtractiveCMY
    color1Val                := IniRead(settingsFile, "ColorSettings", "color1")
    myReferenceVal           := IniRead(settingsFile, "ColorSettings", "myReference")
    sStepsVal                := IniRead(settingsFile, "ColorSettings", "sSteps")
    myRadLightVal            := IniRead(settingsFile, "ColorSettings", "myRadLight")
    myRadDarkVal             := IniRead(settingsFile, "ColorSettings", "myRadDark")
    FontShadeStepsVal        := IniRead(settingsFile, "ColorSettings", "FontShadeSteps")
    FontSaturationStepsVal   := IniRead(settingsFile, "ColorSettings", "FontSaturationSteps")
    ListShadeStepsVal        := IniRead(settingsFile, "ColorSettings", "ListShadeSteps")
    ListSaturationStepsVal   := IniRead(settingsFile, "ColorSettings", "ListSaturationSteps")
    FormShadeStepsVal        := IniRead(settingsFile, "ColorSettings", "FormShadeSteps")
    FormSaturationStepsVal   := IniRead(settingsFile, "ColorSettings", "FormSaturationSteps")	
}
Else {  ; If ini file doesn't exist, just use these default values. 
    formColor := "0x550000", listColor := "0xC4E1A4", fontColor := "0x92B0C3"
    , warnColor := "0xFF8080", myRadRGBVal := "0", myRadCYMVal := "1", color1Val := "1"
    , myReferenceVal := "1", sStepsVal := "10", myRadLightVal := "1", myRadDarkVal := "0"
    , FontShadeStepsVal := "25", FontSaturationStepsVal := "30", ListShadeStepsVal := "6"
    , ListSaturationStepsVal := "30", FormShadeStepsVal := "5", FormSaturationStepsVal := "30", customList := ""
        setColorArrays() ; The arrays are large, so I put them at the bottom.  
        colorArray := additiveRGB
}

; --- Build gui ---
global myGui := Gui(pinToTop? "+AlwaysOnTop" : "", guiTitle)
;myGui.SetFont("s12 " fontColor? " c" fontColor : "")
myGui.SetFont("s12")
myGui.BackColor := formColor
pattern := myGui.Add("Text", "x14 W215 Center","`n" guiTitle)
pattern.SetFont("bold")

myRadRGB := myGui.Add("Radio", "x50 c" fontColor " Checked" myRadRGBVal, "RGB")
myRadRGB.OnEvent("Click", wheelChanged)
myRadCYM := myGui.Add("Radio", "x+30 c" fontColor " Checked" myRadCYMVal, "CYM")
myRadCYM.OnEvent("Click", wheelChanged)

myGui.Add("Text","x14 ","Reference:")
global color1 := myGui.Add("ComboBox", "x+5 w110 Background" listColor " Choose" Color1Val, colorArray) 
color1.OnEvent("Change", colorChanged)

global myReference := myGui.Add("ComboBox", "x14 w90 choose" myReferenceVal " Background" listColor, ['fontColor','listColor','formColor'])
myReference.OnEvent("Change", colorChanged)
myGui.Add("Text","x+5 ","uses reference")

myGui.Add("Text", "x14", "Split steps for other 2: ")
sEdit := myGui.Add("Edit", "w50 x+5 Background" listColor)
sSteps := myGui.Add("UpDown", " Range-60-60", sStepsVal) 
sSteps.OnEvent("change", colorChanged)

myRadLight := myGui.Add("Radio", "x50 c" fontColor " Checked" myRadLightVal, "Light")
myRadLight.OnEvent("Click", shadeChanged)
myRadDark := myGui.Add("Radio", "x+30 c" fontColor "  Checked" myRadDarkVal, "Dark")
myRadDark.OnEvent("Click", shadeChanged)

myGui.SetFont("s10")
myGui.Add("Text","x12","UnShade").OnEvent("DoubleClick", unshade)
myGui.Add("Text","x+3","ReSaturate").OnEvent("DoubleClick", resaturate)
myGui.SetFont("s12")

FontShadeEdit := myGui.Add("Edit", "y+5 w50 x14 Background" listColor) ; FontColor Shading.
FontShadeSteps := myGui.Add("UpDown", "Range1-" shadingSteps, FontShadeStepsVal) ; last parameter is the default setting. Change as desired.
FontShadeSteps.OnEvent("change", colorChanged)

FontSaturationEdit := myGui.Add("Edit", "w50 x+5 Background" listColor) ; FontColor Saturation.
FontSaturationSteps := myGui.Add("UpDown", "Range1-" saturationSteps, FontSaturationStepsVal) ; last parameter is the default setting. Change as desired.
myGui.Add("Text", "x+5", "Font")
FontSaturationSteps.OnEvent("change", colorChanged)
;-----------------------

ListShadeEdit := myGui.Add("Edit", "w50 x14 Background" listColor) ; ListColor (Ctrl Background) Shading.
ListShadeSteps := myGui.Add("UpDown", "Range1-" shadingSteps, ListShadeStepsVal) 
ListShadeSteps.OnEvent("change", colorChanged)

ListSaturationEdit := myGui.Add("Edit", "w50 x+5 Background" listColor) ; ListColor (Ctrl Background) Saturation.
ListSaturationSteps := myGui.Add("UpDown", "Range1-" saturationSteps, ListSaturationStepsVal) 
myGui.Add("Text", "x+5", "List (Ctrl Bkg)")
ListSaturationSteps.OnEvent("change", colorChanged)
;-----------------------

FormShadeEdit := myGui.Add("Edit", " w50 x14 Background" listColor) ; Form (Gui BackColor) Shading. 
FormShadeSteps := myGui.Add("UpDown", "Range1-" shadingSteps, FormShadeStepsVal)
FormShadeSteps.OnEvent("change", colorChanged)

FormShadeEdit.OnEvent("Focus", colorChanged)

FormSaturationEdit := myGui.Add("Edit", " w50 x+5 Background" listColor) ; Form (Gui BackColor) Saturation. 
FormSaturationSteps := myGui.Add("UpDown", "Range1-" saturationSteps, FormSaturationStepsVal)
myGui.Add("Text", "x+5", "Form (Gui Bck)")
FormSaturationSteps.OnEvent("change", colorChanged)
;-----------------------

myGui.SetFont("s9")
myGui.Add("Text","x14 w215 Center","Double-Click list item to change`ndirectly...With Ctrl for eyedropper.").SetFont("bold")
myGui.SetFont("s12")

myListArr := ["fontColor:`t" fontColor, "listColor:`t" listColor
			, "formColor:`t" formColor, "warnColor:" warnColor,]
myList := myGui.Add("ListBox", "y+4 x14 w215 r4 Background" listColor, myListArr)
myList.OnEvent("DoubleClick", listClick)

warnProg := myGui.Add("Progress", "x14 w215 h30 c" . warnColor, "100")
myGui.Add("text", "xp+14 yp+4  +BackgroundTrans", "Form warning state" )

; -- Saved Favorite Themes dropdown moved above the button group, so picking a
; theme previews it immediately (via the Change event below), and the buttons
; underneath act on whatever is currently shown -- no more switching between
; two separate button rows to load then apply a theme. --
myGui.SetFont("s9")
myGui.Add("Text","x14 w215 Center","Saved Favorite Themes").SetFont("bold")
myGui.SetFont("s11")

; read ini file and put section names into array for combo box.
myFavesArr := []

favesDropList := myGui.Add("DropDownList", "y+4 w215", myFavesArr)
favesDropList.OnEvent("Change", loadFave) ; Auto-preview the theme as soon as it's selected.

; Two small status indicators side by side, tracking two different things:
; LEFT  ("In Use"/blank)            -- does the live preview match what's actually
;                                       active in [ColorSettings] right now?
; RIGHT ("Unsaved changes"/blank)   -- does the live preview match the favorite
;                                       currently selected in the dropdown? (Falls
;                                       back to the same [ColorSettings] comparison
;                                       as the left side when nothing's selected.)
myGui.SetFont("s9")
leftStatusText := myGui.Add("Text", "x14 w100 Center y+2", "")
rightStatusText := myGui.Add("Text", "x+15 w100 Center", "")
myGui.SetFont("s11")

; the buttons (single consolidated group)
myGui.SetFont("s11")

expButton := myGui.Add("Button" , "w100 x14 y+8", "To ClipBrd")
expButton.OnEvent("Click", exportClip)

saveFaveButton := myGui.Add("Button" , "w100 x+15", "Save Fave")
saveFaveButton.OnEvent("Click", saveFave)

; "Apply Colors" (was "Save Colors") -- name change to avoid confusion with "Save
; Fave" above: this commits the live preview to the active [ColorSettings]
; section and offers to restart the other tools, it doesn't save a named theme.
savButton := myGui.Add("Button" , "w100 x14", "Apply Colors")
savButton.OnEvent("Click", SaveColors)

renameFaveButton := myGui.Add("Button" , "w100 x+15", "Rename Fave")
renameFaveButton.OnEvent("Click", renameFave)

; "Reset Colors" sits directly under "Apply Colors" -- reverts the live
; preview/controls back to whatever's in [ColorSettings], without closing the gui.
resColorsButton := myGui.Add("Button" , "w100 x14", "Reset Colors")
resColorsButton.OnEvent("Click", resetColors)

deleteFaveButton := myGui.Add("Button" , "w100 x+15", "Delete Fave")
deleteFaveButton.OnEvent("Click", deleteFave)

relButton := myGui.Add("Button" , "w100 x14", "Reload Script")
relButton.OnEvent("Click", buttRestart)

canButton := myGui.Add("Button" , "w100 x+15", "Exit")
canButton.OnEvent("Click", ExitTool)

myGui.OnEvent("Close", ExitTool) ; If user closes via red 'x'.


saveFave(*) {
    global myGui, listColor, fontColor, formColor, favesDropList
    ; Create input box for theme name
    inputGui := Gui()
    inputGui.BackColor := formColor
    inputGui.SetFont("s12 c" fontColor)
    inputGui.Add("Text",, "Enter theme name:")
    ; Pre-fill with whatever's currently selected/previewed, so editing an existing
    ; fave's colors and re-saving doesn't require retyping its name from scratch.
    themeName := inputGui.Add("Edit", "w200 Background" listColor, favesDropList.Text)
    inputGui.Add("Button", "Default w80", "OK").OnEvent("Click", (*) => inputGui.Submit())
    inputGui.Add("Button", "w80 x+10", "Cancel").OnEvent("Click", (*) => inputGui.Hide())
    inputGui.Show()
    
    WinWaitClose(inputGui)
    if !themeName.Value  ; User cancelled or entered empty name
        return

    if (themeName.Value = "ColorSettings") {
        MsgBox("`"ColorSettings`" is a reserved name (it's the main active-colors section). Please choose a different name.", "Reserved Name", "Icon!")
        return
    }

    ; Warn before silently clobbering an existing favorite of the same name.
    existingSections := StrSplit(IniRead(settingsFile), "`n")
    for section in existingSections {
        if (section = themeName.Value) {
            result := MsgBox("A favorite named '" themeName.Value "' already exists.`n`nOverwrite it?", "Confirm Overwrite", "0x34") ; Yes/No + Warning icon
            if (result != "Yes")
                return
            break
        }
    }

    ; Save all current settings under new section
    IniWrite(fontColor, settingsFile, themeName.Value, "fontColor")
    IniWrite(listColor, settingsFile, themeName.Value, "listColor")
    IniWrite(formColor, settingsFile, themeName.Value, "formColor")
    IniWrite(warnColor, settingsFile, themeName.Value, "warnColor")
    IniWrite(myRadRGB.Value, settingsFile, themeName.Value, "myRadRGB")
    IniWrite(myRadCYM.Value, settingsFile, themeName.Value, "myRadCYM")
    IniWrite(color1.Value, settingsFile, themeName.Value, "color1")
    IniWrite(myReference.Value, settingsFile, themeName.Value, "myReference")
    IniWrite(sSteps.Value, settingsFile, themeName.Value, "sSteps")
    IniWrite(myRadLight.Value, settingsFile, themeName.Value, "myRadLight")
    IniWrite(myRadDark.Value, settingsFile, themeName.Value, "myRadDark")
    IniWrite(FontShadeSteps.Value, settingsFile, themeName.Value, "FontShadeSteps")
    IniWrite(FontSaturationSteps.Value, settingsFile, themeName.Value, "FontSaturationSteps")
    IniWrite(ListShadeSteps.Value, settingsFile, themeName.Value, "ListShadeSteps")
    IniWrite(ListSaturationSteps.Value, settingsFile, themeName.Value, "ListSaturationSteps")
    IniWrite(FormShadeSteps.Value, settingsFile, themeName.Value, "FormShadeSteps")
    IniWrite(FormSaturationSteps.Value, settingsFile, themeName.Value, "FormSaturationSteps")
    
    ; Update combobox with new theme
    refreshThemesList()
    favesDropList.Choose(themeName.Value) ; Select the (possibly new) entry.
    UpdateModifiedStatus() ; The fave's saved values now match what's live -- refresh both indicators.
}

loadFave(*) {
    global myGui, favesDropList, fontColor, listColor, formColor, warnColor, colorsManuallyset
    if !favesDropList.Text  ; No theme selected
        return
        
    themeName := favesDropList.Text
    
    ; Loading a fave deliberately replaces every color/control wholesale -- it's
    ; not an incremental tweak, so any prior manual color override shouldn't be
    ; preserved or even prompt about it here. (Previously this flag was only
    ; cleared/checked inside colorChanged(), called at the very end of this
    ; function -- AFTER all the controls below were already switched to the new
    ; theme. That meant the warning dialog, if it fired, was too late to mean
    ; anything: clicking Cancel just aborted the color *recompute*, leaving the
    ; new theme's controls paired with the old, manually-tainted colors.)
    colorsManuallyset := 0
    
    ; Load all settings from selected theme section
    fontColor := IniRead(settingsFile, themeName, "fontColor")
    listColor := IniRead(settingsFile, themeName, "listColor")
    formColor := IniRead(settingsFile, themeName, "formColor")
    warnColor := IniRead(settingsFile, themeName, "warnColor")
    myRadRGB.Value := IniRead(settingsFile, themeName, "myRadRGB")
    myRadCYM.Value := IniRead(settingsFile, themeName, "myRadCYM")
    color1.Value := IniRead(settingsFile, themeName, "color1")
    myReference.Value := IniRead(settingsFile, themeName, "myReference")
    sSteps.Value := IniRead(settingsFile, themeName, "sSteps")
    myRadLight.Value := IniRead(settingsFile, themeName, "myRadLight")
    myRadDark.Value := IniRead(settingsFile, themeName, "myRadDark")
    FontShadeSteps.Value := IniRead(settingsFile, themeName, "FontShadeSteps")
    FontSaturationSteps.Value := IniRead(settingsFile, themeName, "FontSaturationSteps")
    ListShadeSteps.Value := IniRead(settingsFile, themeName, "ListShadeSteps")
    ListSaturationSteps.Value := IniRead(settingsFile, themeName, "ListSaturationSteps")
    FormShadeSteps.Value := IniRead(settingsFile, themeName, "FormShadeSteps")
    FormSaturationSteps.Value := IniRead(settingsFile, themeName, "FormSaturationSteps")
    
    ; Update GUI with new colors
    colorChanged()
}

deleteFave(*) {
    global favesDropList
    if !favesDropList.Text  ; No theme selected
        return
        
    themeName := favesDropList.Text
    Result := MsgBox("Are you sure you want to delete the theme '" themeName "'?", 
                    "Confirm Delete", "0x34")  ; Yes/No + Warning icon
    if Result != "Yes"
        return
        
    ; Delete the section from ini file
    IniDelete(settingsFile, themeName)
    
    ; Update combobox
    refreshThemesList()
}

; Renames the currently-selected favorite without losing it (previously the only
; way to "rename" was delete + re-save under a new name, which loses the old one
; on any typo).
renameFave(*) {
    global myGui, listColor, fontColor, formColor, favesDropList
    oldName := favesDropList.Text
    if !oldName  ; No theme selected
        return

    ; Create input box for the new name, pre-filled with the old one.
    inputGui := Gui()
    inputGui.BackColor := formColor
    inputGui.SetFont("s12 c" fontColor)
    inputGui.Add("Text",, "Rename '" oldName "' to:")
    newNameEdit := inputGui.Add("Edit", "w200 Background" listColor, oldName)
    inputGui.Add("Button", "Default w80", "OK").OnEvent("Click", (*) => inputGui.Submit())
    inputGui.Add("Button", "w80 x+10", "Cancel").OnEvent("Click", (*) => inputGui.Hide())
    inputGui.Show()

    WinWaitClose(inputGui)
    newName := newNameEdit.Value
    if (!newName || newName = oldName)  ; Cancelled, empty, or unchanged
        return

    if (newName = "ColorSettings") {
        MsgBox("`"ColorSettings`" is a reserved name (it's the main active-colors section). Please choose a different name.", "Reserved Name", "Icon!")
        return
    }

    ; Warn before clobbering an existing favorite with the new name.
    existingSections := StrSplit(IniRead(settingsFile), "`n")
    for section in existingSections {
        if (section = newName) {
            result := MsgBox("A favorite named '" newName "' already exists.`n`nOverwrite it?", "Confirm Overwrite", "0x34")
            if (result != "Yes")
                return
            break
        }
    }

    ; Copy every key from the old section to the new one, then delete the old section.
    ; NOTE: IniRead(file, section) with no Key param returns lines formatted as
    ; "Key=Value" -- not bare key names -- so each line must be split on "=".
    lines := StrSplit(IniRead(settingsFile, oldName), "`n")
    for line in lines {
        if (line = "")
            continue
        eqPos := InStr(line, "=")
        if (!eqPos)
            continue
        key := SubStr(line, 1, eqPos - 1)
        value := SubStr(line, eqPos + 1)
        IniWrite(value, settingsFile, newName, key)
    }
    IniDelete(settingsFile, oldName)

    refreshThemesList()
    favesDropList.Choose(newName) ; Keep the renamed entry selected.
    UpdateModifiedStatus()
}

refreshThemesList() {
    global favesDropList, settingsFile
    
    ; Get all section names as newline-delimited string
    sections := StrSplit(IniRead(settingsFile), "`n")
    themeNames := []
    for section in sections {
        if (section != "ColorSettings")
            themeNames.Push(section)
    }
    
    ; Update combobox
    favesDropList.Delete()
    favesDropList.Add(themeNames)
}
; Call this when GUI is created to populate initial themes list
refreshThemesList()

; Baseline snapshot of what's actually saved in [ColorSettings]. Used to detect
; unsaved changes (leftStatusText/rightStatusText) and to revert the preview via Reset Colors.
;
; IMPORTANT: colorChanged() *recomputes* font/list/form colors from the sliders
; and reference combo rather than just reading back the raw saved values -- and
; that recompute runs once at startup, right here. If we
; snapshotted the raw as-loaded-from-ini colors here, any tiny difference
; between "what's literally in the ini" and "what the algorithm reproduces from
; the same control settings" would falsely show as unsaved changes forever, even
; with zero user interaction. So: run colorChanged() once now (a placeholder
; baseline avoids an uninitialized-variable error inside it), THEN capture the
; real baseline from its output -- that's what will always be redisplayed as
; long as nothing changes, so the comparison stays honest.
global lastSavedState := CaptureCurrentConfig() ; placeholder, just to avoid an error inside colorChanged()
global colorsManuallyset := 0 ; Must be initialized before colorChanged() runs -- its own initializer further down in the file hasn't executed yet at this point.
colorChanged()
global lastSavedState := CaptureCurrentConfig() ; the real baseline, taken after the recompute settles
UpdateModifiedStatus()

; Captures every control value + the 4 live colors into a plain Map, so the
; current state can be compared against / restored later.
CaptureCurrentConfig() {
    global fontColor, listColor, formColor, warnColor
    global myRadRGB, myRadCYM, color1, myReference, sSteps, myRadLight, myRadDark
    global FontShadeSteps, FontSaturationSteps, ListShadeSteps, ListSaturationSteps, FormShadeSteps, FormSaturationSteps
    cfg := Map()
    cfg["fontColor"] := fontColor
    cfg["listColor"] := listColor
    cfg["formColor"] := formColor
    cfg["warnColor"] := warnColor
    cfg["myRadRGB"] := myRadRGB.Value
    cfg["myRadCYM"] := myRadCYM.Value
    cfg["color1"] := color1.Value
    cfg["myReference"] := myReference.Value
    cfg["sSteps"] := sSteps.Value
    cfg["myRadLight"] := myRadLight.Value
    cfg["myRadDark"] := myRadDark.Value
    cfg["FontShadeSteps"] := FontShadeSteps.Value
    cfg["FontSaturationSteps"] := FontSaturationSteps.Value
    cfg["ListShadeSteps"] := ListShadeSteps.Value
    cfg["ListSaturationSteps"] := ListSaturationSteps.Value
    cfg["FormShadeSteps"] := FormShadeSteps.Value
    cfg["FormSaturationSteps"] := FormSaturationSteps.Value
    return cfg
}

; Re-applies a config Map captured by CaptureCurrentConfig() -- sets every control
; back, then recomputes colors via colorChanged() so everything stays consistent.
ApplyConfig(cfg) {
    global warnColor, colorArray, additiveRGB, subtractiveCMY
    global myRadRGB, myRadCYM, color1, myReference, sSteps, myRadLight, myRadDark
    global FontShadeSteps, FontSaturationSteps, ListShadeSteps, ListSaturationSteps, FormShadeSteps, FormSaturationSteps
    global colorsManuallyset := 0 ; This is a programmatic revert, not a manual change -- skip the overwrite-warning prompt.

    myRadRGB.Value := cfg["myRadRGB"]
    myRadCYM.Value := cfg["myRadCYM"]
    colorArray := (cfg["myRadRGB"] = 1) ? additiveRGB : subtractiveCMY
    color1.Delete()
    color1.Add(colorArray)
    color1.Value := cfg["color1"]
    myReference.Value := cfg["myReference"]
    sSteps.Value := cfg["sSteps"]
    myRadLight.Value := cfg["myRadLight"]
    myRadDark.Value := cfg["myRadDark"]
    FontShadeSteps.Value := cfg["FontShadeSteps"]
    FontSaturationSteps.Value := cfg["FontSaturationSteps"]
    ListShadeSteps.Value := cfg["ListShadeSteps"]
    ListSaturationSteps.Value := cfg["ListSaturationSteps"]
    FormShadeSteps.Value := cfg["FormShadeSteps"]
    FormSaturationSteps.Value := cfg["FormSaturationSteps"]
    warnColor := cfg["warnColor"] ; colorChanged() never reassigns warnColor itself, so set it directly.
    colorChanged()
}

; True if the live colors/controls differ from what's actually saved in [ColorSettings].
IsModified() {
    global lastSavedState
    return !ConfigsMatch(CaptureCurrentConfig(), lastSavedState)
}

; Reads a favorite's saved values from the ini into the same Map shape that
; CaptureCurrentConfig() produces, so the two can be compared directly.
; Missing keys/sections read back as "" (e.g. a fave deleted out from under the
; dropdown), which simply won't match the live config -- safe failure mode.
CaptureFaveConfig(themeName) {
    static keyList := ["fontColor","listColor","formColor","warnColor"
        ,"myRadRGB","myRadCYM","color1","myReference","sSteps","myRadLight","myRadDark"
        ,"FontShadeSteps","FontSaturationSteps","ListShadeSteps","ListSaturationSteps"
        ,"FormShadeSteps","FormSaturationSteps"]
    cfg := Map()
    for k in keyList
        cfg[k] := IniRead(settingsFile, themeName, k, "")
    return cfg
}

; True if every key in cfgA matches cfgB (cfgB may have extra/missing keys; only
; cfgA's keys are checked, which is fine since both Capture* functions emit the
; same key set). skipKeys, if given, is a Map of key names to ignore.
ConfigsMatch(cfgA, cfgB, skipKeys?) {
    for k, v in cfgA {
        if (IsSet(skipKeys) && skipKeys.Has(k))
            continue
        if (!cfgB.Has(k) || cfgB[k] != v)
            return false
    }
    return true
}

; True if the live colors/controls differ from the favorite currently selected in
; the dropdown. With nothing selected, falls back to comparing against
; [ColorSettings] instead (same baseline as IsModified()), so the two status
; labels behave as plain opposites of each other until a favorite is involved.
IsModifiedFromSelectedFave() {
    global favesDropList, lastSavedState
    current := CaptureCurrentConfig()
    if (favesDropList.Text) {
        ; Comparing against a saved FAVE specifically: skip fontColor/listColor/
        ; formColor. Those three are *recomputed* by colorChanged() from the
        ; slider/combo values every time it runs (which loadFave() always
        ; triggers) rather than being copied back verbatim -- so comparing the
        ; raw stored hex against the freshly-recomputed hex would falsely show
        ; "modified" immediately after loading a fave, with zero user
        ; interaction. The underlying slider/combo values (which ARE copied
        ; verbatim) plus warnColor (never touched by colorChanged()) are the
        ; reliable signal for "does this match the fave".
        static derivedColorKeys := Map("fontColor",1,"listColor",1,"formColor",1)
        refCfg := CaptureFaveConfig(favesDropList.Text)
        return !ConfigsMatch(current, refCfg, derivedColorKeys)
    }
    ; Nothing selected -- fall back to the same strict comparison IsModified() uses.
    return !ConfigsMatch(current, lastSavedState)
}

; Updates the two status indicators flanking the favorites dropdown.
UpdateModifiedStatus(*) {
    global leftStatusText, rightStatusText, fontColor

    ; Left: matches what's actually active in [ColorSettings]?
    leftStatusText.Value := IsModified() ? "" : "In Use"
    try leftStatusText.SetFont("c" fontColor)

    ; Right: matches the favorite currently selected in the dropdown?
    if (IsModifiedFromSelectedFave()) {
        rightStatusText.Value := "Unsaved changes"
        try rightStatusText.SetFont("cRed")
    } else {
        rightStatusText.Value := ""
        try rightStatusText.SetFont("c" fontColor)
    }
}

; Closes the tool. Always a full exit now -- there's no more "keep running in the
; background, toggle visible via hotkey" mode, so closing always means closing.
ExitTool(*) {
    global isPickingColor, pendingAction
    ; The eyedropper (GetColorAtCursor) handles its own Escape key via polling, and
    ; restores the cursor itself when it's done. If we let THIS handler also act on
    ; the X button while the eyedropper's mid-pick, we could call ExitApp() before
    ; the eyedropper's own cursor-restore code ever runs -- leaving the crosshair
    ; cursor stuck system-wide. So instead of racing it, defer: stash this same
    ; call for the eyedropper's loop to pick up, clean itself up, and then run it
    ; for us once it's actually safe to.
    if (isPickingColor) {
        pendingAction := ExitTool
        return
    }
    try SystemCursor("Show") ; Belt-and-suspenders: make sure cursor is normal before exiting.
    ExitApp()
}

; Show a warning if colors were manually set, then the user tries for programmatically change them. 
global colorsManuallyset := 0
manualChangeWarning(*) {
    Result := ""
    If (colorsManuallyset = 1)
        Result := msgbox("One of more colors were manually changed, this will overwrite the change.`n`nContinue?"
        , "Confirm Change", "4096 OKCancel Icon!") 
        If Result = "Cancel"
            return "Cancel update"
        else    
            global colorsManuallyset := 0
}

; If user changes light/dark radio, set 3 shade spinners.
shadeChanged(*) { 
    If manualChangeWarning() = "Cancel update"
        return

    If (myRadLight.Value = 1) {
        FormShadeSteps.Value := (ShadingSteps * 1/5)+1
        ListShadeSteps.Value := ShadingSteps * 1/5
        FontShadeSteps.Value := ShadingSteps * 5/6
        colorChanged()
    }
    Else {
        FormShadeSteps.Value := (ShadingSteps * 4/5)+1
        ListShadeSteps.Value := ShadingSteps * 4/5
        FontShadeSteps.Value := ShadingSteps * 1/6
        colorChanged()
    }
}

; Sets the three saturation spin boxes to max. 
resaturate(*) {
    If manualChangeWarning() = "Cancel update"
        return

    FormSaturationSteps.Value := saturationSteps
    ListSaturationSteps.Value := saturationSteps
    FontSaturationSteps.Value := saturationSteps
    colorChanged()
}

; Set three shade boxes to mid point (neither white, not black.)
unshade(*){
    If manualChangeWarning() = "Cancel update"
        return

    FormShadeSteps.Value := ShadingSteps //2 
    ListShadeSteps.Value := ShadingSteps //2
    FontShadeSteps.Value := ShadingSteps //2
    colorChanged()
}

; This function is called when the user double-clicks the ListBox.
; (Or if they Ctrl+Double-click.)
listClick(*) {
    global fontColor, listColor, formColor, warnColor
    static customColors := [] ; Holds the "Custom Colors" added to the Windows color picker.
    If customColors.Length = 0 ; Only parse-up array if it hasn't been done yet. 
        customColors := StrSplit(IniRead(settingsFile, "ColorSettings", "customList"), ",")

    currentColor := SubStr(myList.text, -8) ; Use only hex code at right of list item. 

    If (GetKeyState("Ctrl", "P"))  ; Ctrl held down during Double-click?
        newcolor := GetColorAtCursor() ; Calls the below function.
    else
        newColor := ChooseColor(currentColor,, customColors) ; Calls the other below function.

    If (newColor = "") ; If user presses cancel, a blank str is returned, so use previous color.
        newColor := currentColor

    If SubStr(myList.Text, 1, 4) = "font"  ; Read left 4 letters of list choice. 
        fontColor := newColor
    Else If SubStr(myList.Text, 1, 4) = "list"
        listColor := newColor
    Else If SubStr(myList.Text, 1, 4) = "form"
        formColor := newColor
    Else 							; = "warn"
        warnColor := newColor

    myGui.BackColor := formColor   ; Reset all the colors of the gui parts.

    For Ctrl in myGui {
        If (Ctrl.Type = "Edit") or (Ctrl.Type = "ListBox") or (Ctrl.Type = "ComboBox")
            Ctrl.Opt("Background" listColor)
        If (Ctrl.Type = "Text") or (Ctrl.Type = "Edit") or (Ctrl.Type = "ListBox") or (Ctrl.Type = "ComboBox")
            Ctrl.Opt("c" fontColor) ; doesn't work for radios :- (
    }
    
    ; Update progress bar color
    warnProg.Opt("c" SubStr(warnColor, 3))  ; Remove "0x" prefix
    warnProg.Redraw()  ; Force redraw of the progress bar

    ; Update color values displayed in ListBox. 
    myListArr := ["fontColor:`t" fontColor, "listColor:`t" listColor, "formColor:`t" formColor, "warnColor:" warnColor]
    myList.Delete() ; Clear all existing items
    myList.Add(myListArr) ; Add new items

    for color in customColors
        Global customList .= color ","

    global colorsManuallyset := 1 ; Set flag. 
    UpdateModifiedStatus()
}

; This function is called if the RGB/CYM radios are clicked. 
wheelChanged(*) {
    If manualChangeWarning() = "Cancel update"
        return

    If myRadRGB.Value = 1 {
        colorArray := additiveRGB   
        refIndex := color1.Value
        color1.Delete() ; Clear all existing items
        color1.Add(colorArray) ; Add new items
        color1.Value := refIndex
    }
    else {
        colorArray := subtractiveCMY
        refIndex := color1.Value
        color1.Delete() ; Clear all existing items
        color1.Add(colorArray) ; Add new items
        color1.Value := refIndex
    }
    colorChanged()
}

; This is the main function that updates the colors in the gui and does several calculations. 
colorChanged(*) { 
    If manualChangeWarning() = "Cancel update"
        return
           
    splitSteps := sSteps.Value

    refIndex := color1.Value

    refIndex := color1.Value
    reference := color1.Text

    complementaryIndex := Mod(refIndex + 59, 120) + 1 ; These three lines written by Claude.ai.
    splitCompCounterClockwiseIdx := Mod(complementaryIndex + 120 - splitSteps - 1, 120) + 1
    splitCompClockwiseIdx := Mod(complementaryIndex + splitSteps - 1, 120) + 1
    
    CounterClock := colorArray[splitCompCounterClockwiseIdx]
    ClockWise := colorArray[splitCompClockwiseIdx]

    Switch splitSteps { ; Update Title.
        Case 0:pattern.text := "Complementary`n" guiTitle
        Case 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15:
            pattern.text := "Split Complementary`n" guiTitle
        Case -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15:
            pattern.text := "Split Complementary`n" guiTitle
        Case 20, -20: pattern.text := "Triad`n" guiTitle
        Case 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59: 
            pattern.text := "Analogous`n" guiTitle
        Case -45, -46, -47, -48, -49, -50, -51, -52, -53, -54, -55, -56, -57, -58, -59: 
            pattern.text := "Analogous`n" guiTitle
        Case 60, -60: pattern.text := "Monochromatic`n" guiTitle
        Default: pattern.text := guiTitle
    }
    
    ; This part is for the "font/from/list Is Reference" color part.
    global fontColor, listColor, formColor, warnColor


    If (myReference.text = "fontColor") {
        fontColor := reference
        listColor := CounterClock
        formColor := ClockWise
    }
    Else if  (myReference.text = "formColor") {
        formColor := reference
        fontColor := CounterClock
        listColor := ClockWise
    }
    Else { ; myRef is listColor
        listColor := reference
        formColor := CounterClock
        fontColor := ClockWise
    }

    ; Apply shading, then saturation to formColor as needed. 
    formArr := WhiteColorBlackGradient(formColor, shadingSteps)
    formColor := formArr[FormShadeSteps.Value]
    formArr := ColorToGrayGradient(formColor, saturationSteps)
    formColor := formArr[-FormSaturationSteps.Value]
    myGui.BackColor := formColor

    ; Apply shading, saturation to listColor and fontColor, as needed.
    listArr := WhiteColorBlackGradient(listColor, shadingSteps)
    listColor := listArr[ListShadeSteps.Value]
    listArr := ColorToGrayGradient(listColor, saturationSteps)
    listColor := listArr[-ListSaturationSteps.Value]
    
    fontArr := WhiteColorBlackGradient(fontColor, shadingSteps)
    fontColor := fontArr[FontShadeSteps.Value]
    fontArr := ColorToGrayGradient(fontColor, saturationSteps)
    fontColor := fontArr[-FontSaturationSteps.Value]
   
    warnArr := WhiteColorBlackGradient(warnColor, shadingSteps)
    newWarnColor := warnArr[FormShadeSteps.Value]

	warnProg.Opt("c" newWarnColor)
    ;warnProg.Opt("c" SubStr(warnColor, 3))  ; Remove "0x" prefix

    For Ctrl in myGui {
        If (Ctrl.Type = "Edit") or (Ctrl.Type = "ListBox") or (Ctrl.Type = "ComboBox")
            Ctrl.Opt("Background" listColor)

        If (Ctrl.Type = "Text") or (Ctrl.Type = "Edit") or (Ctrl.Type = "ListBox") or (Ctrl.Type = "ComboBox")
            Ctrl.Opt("c" fontColor) ; doesn't work for radios :- (
    }

    ; Update color values displayed in ListBox. 
    myListArr := ["fontColor:`t" fontColor, "listColor:`t" listColor, "formColor:`t" formColor, "warnColor:" warnColor]
    myList.Delete() ; Clear all existing items
    myList.Add(myListArr) ; Add new items

    UpdateModifiedStatus()
}

; This is the function that is based closely on ColorGradient() by Lateralus138 and Teadrinker.
WhiteColorBlackGradient(color, steps) {
    static red   := color => color >> 16
         , green := color => (color >> 8) & 0xFF
         , blue  := color => color & 0xFF
         , fmt := Format.Bind('0x{:06X}')

    colorArr := []
    redArr := [], greenArr := [], blueArr := []

    ; Calculate steps for white to color and color to black
    stepsToColor := Floor((steps - 1) / 2)
    stepsToBlack := steps - stepsToColor - 1

    ; White to color
    for item in ['red', 'green', 'blue'] {
        step := (255 - %item%(color)) / stepsToColor
        value := 255
        Loop stepsToColor {
            %item%Arr.Push(Round(value))
            value -= step
        }
    }

    ; Add the specified color
    redArr.Push(red(color))
    greenArr.Push(green(color))
    blueArr.Push(blue(color))

    ; Color to black
    for item in ['red', 'green', 'blue'] {
        step := %item%(color) / stepsToBlack
        value := %item%(color)
        Loop stepsToBlack {
            value -= step
            %item%Arr.Push(Round(value))
        }
    }

    ; Construct the color array
    Loop steps {
        colorArr.Push(fmt(redArr[A_Index] << 16 | greenArr[A_Index] << 8 | blueArr[A_Index]))
    }

    return colorArr
}

ColorToGrayGradient(color, steps) {
    static red   := color => color >> 16
         , green := color => (color >> 8) & 0xFF
         , blue  := color => color & 0xFF
         , fmt := Format.Bind('0x{:06X}')

    colorArr := []
    redArr := [], greenArr := [], blueArr := []

    ; Calculate the gray value (average of R, G, B)
    grayValue := (red(color) + green(color) + blue(color)) / 3

    ; Calculate steps from color to gray
    for item in ['red', 'green', 'blue'] {
        startValue := %item%(color)
        step := (startValue - grayValue) / (steps - 1)
        value := startValue
        Loop steps {
            %item%Arr.Push(Round(value))
            value -= step
        }
    }

    ; Construct the color array
    Loop steps {
        colorArr.Push(fmt(redArr[A_Index] << 16 | greenArr[A_Index] << 8 | blueArr[A_Index]))
    }

    return colorArr
}

; CooseColor is based on Teadrinker code here: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=131364#p578641
; Used Claude.ai to update it for returning the value as an 8-char 0x****** value. 
ChooseColor(initColor := 0, hWnd := 0, customColorsArr := '', flags := 3) { ; flags: CC_RGBINIT = 1, CC_FULLOPEN = 2, CC_PREVENTFULLOPEN = 4
    static init := false, customColors := '', CHOOSECOLOR := ''
         , RGB_BGR := color => (color & 0xFF) << 16 | color & 0xFF00 | color >> 16
    if !init {
        init := true
        if !IsObject(customColorsArr) {
            customColorsArr := []
        }
        customColorsArr.Length := 16
        customColors := Buffer(64)
        Loop 16 {
            clr := customColorsArr.Has(A_Index) && IsInteger(customColorsArr[A_Index])
                ? RGB_BGR(customColorsArr[A_Index] & 0xFFFFFF) : 0xFFFFFF
            NumPut('UInt', clr, customColors, (A_Index - 1) * 4)
        }
        CHOOSECOLOR := Buffer(A_PtrSize * 9)
        NumPut('Ptr', customColors.ptr, NumPut('Ptr', CHOOSECOLOR.size, CHOOSECOLOR) + A_PtrSize * 3)
    }
    NumPut('Ptr', hWnd, CHOOSECOLOR, A_PtrSize)
    NumPut('UInt', RGB_BGR(initColor), CHOOSECOLOR, A_PtrSize * 3)
    NumPut('UInt', flags, CHOOSECOLOR, A_PtrSize * 5)
    res := DllCall('Comdlg32\ChooseColor', 'Ptr', CHOOSECOLOR)
    Loop 16 {
        customColorsArr[A_Index] := RGB_BGR(NumGet(customColors, (A_Index - 1) * 4, 'UInt'))
    }
    if (res) {
        color := NumGet(CHOOSECOLOR, A_PtrSize * 3, 'UInt')
        return Format("0x{:06X}", RGB_BGR(color))  ; Convert BGR to RGB
    } else {
        return ""
    }
}

; This function was written almost entirely with Claude AI. 
GetColorAtCursor() {
    ; Store the original state
    originalCursor := true
    global fontColor, listColor, formColor, warnColor, isPickingColor, pendingAction
    isPickingColor := 1
    ; Set up error handling to ensure cursor is restored
    try {
        ; Change cursor to crosshair
        SystemCursor("Hide")
        
        ; Create a GUI for our custom tooltip
        colorTip := Gui()
        colorTip.Opt("+AlwaysOnTop -Caption +ToolWindow")
        colorTip.SetFont("s11", "Arial")
        colorTipTxt := colorTip.Add("Text", "center w120 h54", "color `n'Shift' to capture`n'Esc' to cancel`n")
        colorTip.Show("Hide")
        colorTip.GetPos(,, &tipW, &tipH) ; Real size, used below to keep it on-screen.
        
        ; Wait for either Shift or Escape key
        loop {
            ; If the gui was closed/canceled out from under us (Cancel, Escape on the
            ; main gui, or the title-bar X), stop here instead of letting the eyedropper
            ; just keep running in the background. Clean up exactly like the Escape
            ; path below, then run whatever the interrupting action wanted to do --
            ; deferred via SetTimer so it fires only after this call (and listClick(),
            ; its caller) has fully returned. Running it inline here would risk the
            ; same kind of race we fixed earlier: e.g. ExitTool() calling ExitApp()
            ; before this cleanup has actually finished.
            if (pendingAction) {
                colorTip.Destroy()
                SystemCursor("Show")
                isPickingColor := 0
                deferred := pendingAction
                pendingAction := ""
                SetTimer(deferred, -1)
                return ""
            }

            ; Get current mouse position and color for preview
            CoordMode("Mouse","Screen")
            CoordMode("Pixel","Screen")
            MouseGetPos(&mouseX, &mouseY)
            currentColor := PixelGetColor(mouseX, mouseY)
            hexColor := Format("{:06X}", currentColor & 0xFFFFFF)
            
            ; Calculate contrasting text color for better readability
            r := (currentColor >> 16) & 0xFF, g := (currentColor >> 8) & 0xFF, b := currentColor & 0xFF
            brightness := (r * 299 + g * 587 + b * 114) / 1000
            textColor := brightness > 128 ? "000000" : "FFFFFF"
            
            ; Update GUI position and colors
            colorTip.BackColor := hexColor
            colorTipTxt.SetFont("c" . textColor)
            colorTipTxt.Value := hexColor "`n'Shift' to capture`n'Esc' to cancel`n"

            ; Keep the tooltip on-screen: flip to the opposite side of the cursor
            ; whenever the default offset would run it off the right or bottom edge,
            ; then clamp as a last resort (e.g. near a corner where even the flipped
            ; position would still overflow).
            tipX := (mouseX + 20 + tipW > A_ScreenWidth) ? (mouseX - tipW - 10) : (mouseX + 20)
            tipY := (mouseY + 20 + tipH > A_ScreenHeight) ? (mouseY - tipH - 10) : (mouseY + 20)
            tipX := Max(0, Min(tipX, A_ScreenWidth - tipW))
            tipY := Max(0, Min(tipY, A_ScreenHeight - tipH))
            colorTip.Show("x" . tipX . " y" . tipY . " NoActivate")

            if GetKeyState("Shift", "P") { ; Remove GUI
                colorTip.Destroy()
                SystemCursor("Show") ; Change cursor back
                isPickingColor := 0
                return "0x" hexColor ; NOTE: every other color value in this script is "0x"-prefixed
                                     ; (ChooseColor()'s return, ini storage, the gradient math, etc.)
                                     ; -- hexColor itself is bare for the tooltip's own display, but the
                                     ; value handed back to the caller must match that convention or
                                     ; downstream bitwise math (and the next color-picker call) breaks.
            }
            else if GetKeyState("Escape", "P") { ; Remove GUI
                colorTip.Destroy()
                SystemCursor("Show") ; Change cursor back
                isPickingColor := 0
                return ""  ; Return empty string on escape
            }
            
            Sleep(10)  ; Small sleep to prevent high CPU usage
        }
    }
    catch Error as e { ; Ensure cursor is restored on error
        SystemCursor("Show") ; Clean up GUI if it exists
        try colorTip.Destroy()
        isPickingColor := 0
        throw e  ; Re-throw the error
    }
    finally { ; Additional safety measure to ensure cursor is always restored
        SystemCursor("Show")
        try colorTip.Destroy()
        isPickingColor := 0
    }
}

; SystemCursor function is used by above GetColorAtCursor function.
; Rewritten per TeaDrinker's CursorOverride pattern: "Show" no longer copies a cached
; LoadCursor(0,id) handle back (that's just the generic stock cursor baked into
; user32.dll, NOT your actual configured cursor scheme/size/theme -- which is why
; the restored cursor always looked pixelated no matter what CopyImage flags were used).
; Instead, "Show" asks Windows to reload your real cursor scheme from the registry via
; SystemParametersInfo(SPI_SETCURSORS). This also eliminates the earlier stale-cache
; problem, since nothing is cached anymore -- each Hide/Show call is self-contained.
SystemCursor(cmd) {  ; cmd = "Show|Hide"
    static sys_cursors := [32512, 32513, 32514, 32515, 32516, 32642
                         , 32643, 32644, 32645, 32646, 32648, 32649, 32650]
    static SPI_SETCURSORS := 0x57

    try {
        if (cmd = "Hide") {
            h_cross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515)  ; IDC_CROSS
            for id in sys_cursors {
                ; Each id needs its own copy -- SetSystemCursor takes ownership of the handle it's given.
                h_custom := DllCall("CopyImage", "Ptr", h_cross, "UInt", 2
                    , "Int", 0, "Int", 0, "UInt", 0x4000) ; LR_COPYFROMRESOURCE
                DllCall("SetSystemCursor", "Ptr", h_custom, "UInt", id)
            }
        }
        else { ; "Show" -- reload the user's real cursor scheme instead of copying a stock handle back.
            DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "Ptr", 0, "UInt", 0)
        }
    }
    catch Error as e {
        ; If we fail while trying to hide the cursor, make sure we attempt to show it
        if (cmd = "Hide")
            SystemCursor("Show")
        throw e
    }
}

; Send simple list of vars to Windows Clipboard. 
exportClip(*)
{   Global fontColor, listColor, formColor
    myExp := 
    (
    "fontColor := `"" fontColor "`""
    "`nlistColor := `"" listColor "`""
    "`nformColor := `"" formColor "`""
    "`nwarnColor := `"" warnColor "`""
    )
    A_Clipboard := myExp
    SoundBeep
}

; Called via save button.  Saves colors to ini file. 
SaveColors(*) {
    Global sav := Gui()
    sav.BackColor := formColor
    sav.SetFont("s12 c" fontColor)
    Global savCkBx := sav.Add("Checkbox", "Checked1", "Attempt to restart the following scripts.")
    sav.Add("Edit", "BackGround" listColor, restartTheseScripts)
    sav.SetFont("s11 c" fontColor)
    sav.Add("Button", "x14 w100", "OK").OnEvent("Click", doSave)
    sav.Add("Button", "w100 x+15", "Cancel").OnEvent("Click", (*) => sav.Hide())
    sav.Show()
}

doSave(*) {
	IniWrite(formColor, settingsFile, "ColorSettings", "formColor")
	IniWrite(listColor, settingsFile, "ColorSettings", "listColor")
	IniWrite(fontColor, settingsFile, "ColorSettings", "fontColor")
	IniWrite(warnColor, settingsFile, "ColorSettings", "warnColor")

    IniWrite(myRadRGB.Value, settingsFile, "ColorSettings", "myRadRGB")
    IniWrite(myRadCYM.Value, settingsFile, "ColorSettings", "myRadCYM")
    IniWrite(color1.Value, settingsFile, "ColorSettings", "color1")
    IniWrite(myReference.Value, settingsFile, "ColorSettings", "myReference")
    IniWrite(sSteps.Value, settingsFile, "ColorSettings", "sSteps")
    IniWrite(myRadLight.Value, settingsFile, "ColorSettings", "myRadLight")
    IniWrite(myRadDark.Value, settingsFile, "ColorSettings", "myRadDark")
    IniWrite(FontShadeSteps.Value, settingsFile, "ColorSettings", "FontShadeSteps")
    IniWrite(FontSaturationSteps.Value, settingsFile, "ColorSettings", "FontSaturationSteps")
    IniWrite(ListShadeSteps.Value, settingsFile, "ColorSettings", "ListShadeSteps")
    IniWrite(ListSaturationSteps.Value, settingsFile, "ColorSettings", "ListSaturationSteps")
    IniWrite(FormShadeSteps.Value, settingsFile, "ColorSettings", "FormShadeSteps")
    IniWrite(FormSaturationSteps.Value, settingsFile, "ColorSettings", "FormSaturationSteps")
    Try IniWrite(customList, settingsFile, "ColorSettings", "customList")
    
    If (savCkBx.Value = 1) { ; If checkbox is true, try to run the scripts. 
        loop parse restartTheseScripts, "`n" {
            If FileExist(A_LoopField) { ; Only try to run scripts that exist. 
                Run(A_LoopField)
                Sleep 100
            }
            else
                msgbox "`"" A_LoopField "`" doesn't appear to exist.  Skipping that one.`n`nYou may wish to remove it from the 'restartTheseScripts' variable near the top of the code."
        }
    }
    global lastSavedState := CaptureCurrentConfig() ; What's on disk now matches what's live -- reset the baseline.
    UpdateModifiedStatus()
    sav.Hide()
}

; 'Reload Script' button pressed
buttRestart(*) {
        Reload()
}

; 'Reset Colors' button pressed. Same revert as Cancel, but leaves the gui open
; so you can keep working -- useful after previewing a fave or tweaking sliders
; and deciding you want to start back over from the active [ColorSettings].
resetColors(*) {
    global lastSavedState, favesDropList
    ApplyConfig(lastSavedState)
    favesDropList.Value := 0 ; Clear the selection -- the dropdown shouldn't keep showing
                              ; a fave that's no longer what's actually being previewed.
    UpdateModifiedStatus()
}

myGui.Show("x" A_ScreenWidth /5*3) ; Always show on run now -- show off center.

; The color arrays for the main reference color. 
setColorArrays() {
    global additiveRGB := [ ; 120 elements, going around the colorwheel. 
        '0xff4538', '0xff4f38', '0xff5938', '0xff6338', '0xff6d38', '0xff7738', '0xff8138', '0xff8b38', '0xff9538', '0xff9f38',
        '0xffa938', '0xffb338', '0xffbc38', '0xffc638', '0xffd038', '0xffda38', '0xffe438', '0xffee38', '0xfff838', '0xfbff38',
        '0xf1ff38', '0xe7ff38', '0xeaff38', '0xe0ff38', '0xd6ff38', '0xccff38', '0xc2ff38', '0xb8ff38', '0xadff38', '0xa3ff38',
        '0x99ff38', '0x8fff38', '0x85ff38', '0x7bff38', '0x71ff38', '0x67ff38', '0x5dff38', '0x53ff38', '0x49ff38', '0x3eff38',
        '0x38ff3b', '0x38ff45', '0x38ff4f', '0x38ff59', '0x38ff63', '0x38ff6d', '0x38ff77', '0x38ff81', '0x38ff8b', '0x38ff95',
        '0x38ff9f', '0x38ffa9', '0x38ffb2', '0x38ffbc', '0x38ffc6', '0x38ffd0', '0x38ffda', '0x38ffe3', '0x38ffec', '0x38f2ff',
        '0x38e8ff', '0x38deff', '0x38d2ff', '0x38c8ff', '0x38beff', '0x38b4ff', '0x38aaff', '0x38a0ff', '0x3896ff', '0x388cff',
        '0x3882ff', '0x3878ff', '0x386eff', '0x3864ff', '0x385bff', '0x3851ff', '0x3847ff', '0x383dff', '0x3e38ff', '0x4838ff',
        '0x4d38ff', '0x5738ff', '0x6238ff', '0x6c38ff', '0x7638ff', '0x8038ff', '0x8a38ff', '0x9438ff', '0x9e38ff', '0xa838ff',
        '0xb238ff', '0xbc38ff', '0xc638ff', '0xd038ff', '0xda38ff', '0xe438ff', '0xee38ff', '0xf838ff', '0xff38f7', '0xff38ed',
        '0xff38e3', '0xff38d9', '0xff38cf', '0xff38c5', '0xff38bb', '0xff38b1', '0xff38a7', '0xff389d', '0xff3893', '0xff3889',
        '0xff387f', '0xff3875', '0xff386b', '0xff3861', '0xff3857', '0xff384d', '0xff3843', '0xff3839', '0xff3c39', '0xff4139',
    ]
    global subtractiveCMY := [
        "0xFF0000", "0xFF0700", "0xFF0D00", "0xFF1400", "0xFF1A00", "0xFF2100", "0xFF2700", "0xFF2E00", "0xFF3400", "0xFF3B00", 
        "0xFF4100", "0xFF4800", "0xFF4E00", "0xFF5500", "0xFF5C00", "0xFF6200", "0xFF6900", "0xFF6F00", "0xFF7600", "0xFF7C00", 
        "0xFF8300", "0xFF8900", "0xFF9000", "0xFF9600", "0xFF9D00", "0xFFA300", "0xFFAA00", "0xFFB100", "0xFFB700", "0xFFBE00", 
        "0xFFC400", "0xFFCB00", "0xFFD100", "0xFFD800", "0xFFDE00", "0xFFE500", "0xFFEB00", "0xFFF200", "0xFFF800", "0xFFFF00", 
        "0xF2F900", "0xE6F200", "0xD9EC00", "0xCCE600", "0xBFDF00", "0xB3D900", "0xA6D300", "0x99CC00", "0x8CC600", "0x80C000", 
        "0x73B900", "0x66B300", "0x59AC00", "0x4DA600", "0x40A000", "0x339900", "0x269300", "0x1A8D00", "0x0D8600", "0x008000", 
        "0x007A0D", "0x00731A", "0x006D26", "0x006633", "0x006040", "0x005A4D", "0x005359", "0x004D66", "0x004673", "0x004080", 
        "0x003A8C", "0x003399", "0x002DA6", "0x0026B3", "0x0020BF", "0x001ACC", "0x0013D9", "0x000DE6", "0x0006F2", "0x0000FF", 
        "0x0600F9", "0x0D00F2", "0x1300EC", "0x1A00E6", "0x2000DF", "0x2600D9", "0x2D00D2", "0x3300CC", "0x3900C6", "0x4000BF", 
        "0x4600B9", "0x4D00B3", "0x5300AC", "0x5900A6", "0x60009F", "0x660099", "0x6C0093", "0x73008C", "0x790086", "0x800080", 
        "0x860079", "0x8C0073", "0x93006C", "0x990066", "0x9F0060", "0xA60059", "0xAC0053", "0xB3004D", "0xB90046", "0xBF0040", 
        "0xC60039", "0xCC0033", "0xD2002D", "0xD90026", "0xDF0020", "0xE6001A", "0xEC0013", "0xF2000D", "0xF90006", "0xFF0000"
    ]
}