; ============================================================
; AcMsgBox - Custom Message Box with GUI Styling
; Intended for use with AutoCorrect2 apps.
; Version 11-20-2025 
; ============================================================
; Replacement for standard MsgBox() with custom GUI styling
; 
; DEPENDENCIES (automatic - reads from INI files):
;   - ..\Data\ColorThemeSettings.ini (FormColor, FontColor, WarnColor)
;   - ..\Data\acSettings.ini (LargeFontSize)
;   - ..\Resources\Images\ (icon-16.png, icon-32.png, icon-48.png, icon-64.png)
;
; NOTE: Configure paths and default values in the CONFIGURATION section
;       at the top of the AcMsgBox class if your folder structure differs.
;
; If INI files or keys aren't found, uses hardcoded defaults.
;
; Simply #Include this file - it handles configuration automatically!
; 
; SUPPORTED OPTIONS:
;   - Button types: 0-6, OkCancel, YesNo, YesNoCancel, AbortRetryIgnore, RetryCancel, CancelTryAgainContinue
;   - Icons: 16 (Error/IconX - uses WarnColor background), 32 (Question/Icon?), 48 (Exclamation/Icon!), 64 (Info/IconI)
;   - NOTE: Dialogs are always displayed as "Always On Top"
; 
; USAGE (same as AHK v2 MsgBox, plus custom button support):
;   AcMsgBox.Show(Text)
;   AcMsgBox.Show(Text, Title)
;   AcMsgBox.Show(Text, Title, Options)
;   AcMsgBox.Show(Text, Title, Options, TimeoutSeconds)
;   AcMsgBox.Show(Text, Title, ["CustomButton1", "CustomButton2"])
;   AcMsgBox.Show(Text, Title, {icon: 16, buttons: ["CustomButton1", "CustomButton2"]})
;
; BUTTON OPTIONS (standard):
;   0 = OK
;   1 = OK / Cancel
;   2 = Abort / Retry / Ignore
;   3 = Yes / No / Cancel
;   4 = Yes / No
;   5 = Retry / Cancel
;   6 = Cancel / Try Again / Continue
;
; CUSTOM BUTTONS:
;   Pass an array as the third parameter for custom button text (no icon):
;   Result := AcMsgBox.Show("Choose action",, ["Restart", "Exit", "Cancel"])
;
;   Pass an object with buttons and icon for custom buttons with icon:
;   Result := AcMsgBox.Show("Choose action",, {icon: 16, buttons: ["Restart", "Exit", "Cancel"]})
;   Result := AcMsgBox.Show("Choose action",, {icon: "iconx", buttons: ["Restart", "Exit", "Cancel"]})
;
;   Per-dialog styling (optional properties to override INI/defaults):
;   Note: largeFontSize only affects the message text, not button text.
;   Button font size always comes from the INI or default configuration.
;   Result := AcMsgBox.Show("Action", "Title", {
;       icon: 16,
;       buttons: ["Yes", "No"],
;       formColor: 0xE5E4E2,
;       fontColor: "c0x1F1F1F",
;       warnColor: 0xEE9393,
;       largeFontSize: 15,
;       fontName: "Calibri"
;   })
;
; RETURNS:
;   - "OK", "Cancel", "Yes", "No", "Retry", "Abort", "Ignore", "Try Again", "Continue"
;   - "" (empty string) if timeout occurs
; ============================================================
; EXAMPLES:
; ============================================================

; choice := AcMsgBox.Show("Hello " A_UserName "!`n`nThis is line number " A_LineNumber, "Test", 4)
; AcMsgBox.show("User chose " choice)

; AcMsgBox.Show("Something went wrong!", "Error", 16)

; result := AcMsgBox.Show("Do you want to continue?", "Question", 6)
; AcMsgBox.show("You chose " result)

; myVar := AcMsgBox.Show("This action cannot be undone", "Warning", "48 YesNo")
; AcMsgBox.show("You chose " myVar)

; AcMsgBox.Show("Operation completed successfully!", "Info", 64)

; AcMsgBox.Show("An example of really long text`n`nThe form gets bigger to accommodate the larger text.`n`nThe five boxing wizards jump quickly and the quick brown fox jumps over the lazy dog, so pack my box with five dozen liquor jugs. The five boxing wizards jump quickly and the quick brown fox jumps over the lazy dog, so pack my box with five dozen liquor jugs.  The five boxing wizards jump quickly and the quick brown fox jumps over the lazy dog, so pack my box with five dozen liquor jugs.")

; ; Custom button example - pass array as third parameter
; customResult := AcMsgBox.Show("What would you like to do?", "Custom Actions", ["Restart", "Exit", "Cancel"])
; AcMsgBox.show("You chose " customResult)

; Custom buttons with icon - pass object with icon and buttons
; customWithIcon := AcMsgBox.Show("What would you like to do?", "Custom Actions", {icon: "icon?", buttons: ["Restart", "Exit", "Cancel"]})
; AcMsgBox.show("You chose " customWithIcon)

; ; Custom buttons with per-dialog styling overrides
; ; Note: largeFontSize only affects the message text, not the button text
; styledResult := AcMsgBox.Show("Important choice", "Override Styles", {
;     icon: 48,
;     buttons: ["Accept", "Decline"],
;     largeFontSize: 28,
;     fontColor: "c0xFF0000"
; })
; AcMsgBox.show("You chose " styledResult)

; ============================================================

class AcMsgBox {
    ; ===== CONFIGURATION - Customize these paths for your setup =====
    ; Update these paths if your folder structure is different
    static ColorThemeIniPath := A_ScriptDir . "\..\Data\ColorThemeSettings.ini"
    static SettingsIniPath := A_ScriptDir . "\..\Data\acSettings.ini"
    static IconImageFolder := A_ScriptDir . "\..\Resources\Images\"
    
    ; Default values if INI files or keys are not found
    static DefaultFormColor := "0xE5E4E2"
    static DefaultFontColor := "c0x1F1F1F"
    static DefaultWarnColor := "0xEE9393"
    static DefaultLargeFontSize := "13"
    
    ; ===== END CONFIGURATION =====
    
    static Show(Text := "", Title := "", Options := "", TimeoutSeconds := 0) {
        ; ===== Check if Options is a custom buttons object or array =====
        if (Type(Options) == "Object") {
            ; Object format: {icon: "iconx", buttons: ["Button1", "Button2"]}
            ; or with optional styling: {icon: 16, buttons: [...], largeFontSize: 15, formColor: 0xE5E4E2, ...}
            buttons := Options.HasOwnProp("buttons") ? Options.buttons : ["OK"]
            
            if (Options.HasOwnProp("icon")) {
                iconValue := Options.icon
                ; If icon is a string, parse it; if numeric, use directly
                if (Type(iconValue) == "String") {
                    icon := AcMsgBox.GetIconFromOptions(iconValue)
                } else {
                    icon := iconValue
                }
            } else {
                icon := 0
            }
            
            ; Get styling values - allow override from options object
            FormColor := Options.HasOwnProp("formColor") ? Options.formColor : AcMsgBox.GetFormColor()
            FontColor := Options.HasOwnProp("fontColor") ? Options.fontColor : AcMsgBox.GetFontColor()
            WarnColor := Options.HasOwnProp("warnColor") ? Options.warnColor : AcMsgBox.GetWarnColor()
            LargeFontSize := Options.HasOwnProp("largeFontSize") ? Options.largeFontSize : AcMsgBox.GetLargeFontSize()
            FontName := Options.HasOwnProp("fontName") ? Options.fontName : "Segoe UI"
            ; Buttons always use default font size from INI/config, never overridden
            ButtonFontSize := AcMsgBox.GetLargeFontSize()
        } else if (Type(Options) == "Array") {
            ; Array format: ["Button1", "Button2"] for custom buttons
            buttons := Options
            icon := 0
            
            ; Get styling values from INI/defaults
            FormColor := AcMsgBox.GetFormColor()
            FontColor := AcMsgBox.GetFontColor()
            WarnColor := AcMsgBox.GetWarnColor()
            LargeFontSize := AcMsgBox.GetLargeFontSize()
            FontName := "Segoe UI"
            ; Buttons always use default font size
            ButtonFontSize := AcMsgBox.GetLargeFontSize()
        } else {
            ; String format: traditional MsgBox options
            icon := AcMsgBox.GetIconFromOptions(Options)
            buttons := AcMsgBox.GetButtons(Options)
            
            ; Get styling values from INI/defaults
            FormColor := AcMsgBox.GetFormColor()
            FontColor := AcMsgBox.GetFontColor()
            WarnColor := AcMsgBox.GetWarnColor()
            LargeFontSize := AcMsgBox.GetLargeFontSize()
            FontName := "Segoe UI"
            ; Buttons always use default font size
            ButtonFontSize := AcMsgBox.GetLargeFontSize()
        }
        
        ; Use warnColor as background if this is an error icon
        BackgroundColor := (icon == 16) ? WarnColor : FormColor
        
        ; ===== Create Custom GUI =====
        msgGui := Gui(, Title)
        msgGui.Opt("+AlwaysOnTop")
        msgGui.BackColor := BackgroundColor
        
        fontColorOption := FontColor != "" ? "c" SubStr(FontColor, -6) : ""
        msgGui.SetFont("s" . Integer(LargeFontSize), FontName)
        msgGui.SetFont(fontColorOption)
        
        ; ===== Add Icon Image and Text Message =====
        ; Determine if text is long enough to warrant width constraint
        textLength := StrLen(Text)
        constrainWidth := textLength > 80  ; Roughly "Oh my gosh. Oh my gosh. Oh my gosh. Something failed!"
        
        textCtrl := ""
        ; Check if icon file actually exists before trying to add it
        iconExists := false
        if (icon != 0) {
            iconPath := AcMsgBox.GetIconPath(icon)
            if (FileExist(iconPath)) {
                msgGui.Add("Picture", "x10 y10 w48 h48", iconPath)
                iconExists := true
            }
        }
        
        if (iconExists) {
            if (constrainWidth)
                textCtrl := msgGui.Add("Text", "x70 y10 w520", Text)
            else
                textCtrl := msgGui.Add("Text", "x70 y10", Text)
        } else {
            if (constrainWidth)
                textCtrl := msgGui.Add("Text", "x18 y10 w562", Text)
            else
                textCtrl := msgGui.Add("Text", "x18 y10", Text)
        }
        
        ; Add buttons with placeholder Y position (will be repositioned after show)
        buttonCount := buttons.Length
        buttonWidth := AcMsgBox.CalculateButtonWidth(buttons)
        totalButtonWidth := (buttonCount * buttonWidth) + ((buttonCount - 1) * 10)
        
        ; Reset font size to default for buttons (don't use custom LargeFontSize)
        msgGui.SetFont("s" . Integer(ButtonFontSize))
        
        buttonResult := ""
        buttonControls := []
        
        ; Add buttons with placeholder position (will be repositioned after show)
        for index, btnText in buttons {
            btn := msgGui.Add("Button", "x10 y300 w" buttonWidth, btnText)  ; x10, y300 are placeholders
            btn.OnEvent("Click", (GuiCtrlObj, Info) => (
                buttonResult := GuiCtrlObj.Text,
                msgGui.Destroy()
            ))
            buttonControls.Push(btn)
        }
        
        ; ===== Show GUI to allow auto-sizing of text control =====
        msgGui.Show()
        
        ; Set focus to first button so user can press Enter
        if (buttonControls.Length > 0)
            buttonControls[1].Focus()
        
        ; ===== Measure text control and reposition buttons =====
        textCtrl.GetPos(&x, &y, &w, &h)
        buttonY := y + h + 15  ; 15px padding below text
        
        ; Ensure buttons don't overlap icon (icon is at y10, height 48, so minimum Y is 68)
        if (iconExists && buttonY < 68)
            buttonY := 68
        
        ; Get the actual window width and center buttons
        msgGui.GetPos(,,&guiWidth,)
        
        ; Calculate minimum width to fit 3 buttons with gaps and padding
        minWidth := (3 * buttonWidth) + (2 * 10) + 40
        if (guiWidth < minWidth) {
            guiWidth := minWidth
            msgGui.Show("w" minWidth)
        }
        
        centerX := (guiWidth - totalButtonWidth) / 2
        
        for index, btn in buttonControls {
            xPos := centerX + ((index - 1) * (buttonWidth + 10))
            btn.Move(xPos, buttonY)
        }
        
        ; Adjust window size to fit repositioned buttons
        msgGui.Show("h" . (buttonY + 60))  ; 60px for button height + padding
        
        ; Handle Escape key (closes dialog)
        msgGui.OnEvent("Close", (GuiCtrlObj) => (
            buttonResult := buttons[buttons.Length],
            msgGui.Destroy()
        ))
        
        ; Wait for button click or timeout
        startTime := A_TickCount
        while (true) {
            try {
                if (!msgGui.Hwnd) {
                    break
                }
            } catch {
                break
            }
            
            if (TimeoutSeconds && (A_TickCount - startTime) >= (TimeoutSeconds * 1000)) {
                break
            }
            
            Sleep(100)
        }
        
        ; Destroy GUI if still open (timeout)
        try {
            msgGui.Destroy()
        } catch {
            ; Already destroyed
        }
        
        return buttonResult
    }
    
    static GetFormColor() {
        ; Try INI file, fall back to hardcoded default
        FormColor := IniRead(AcMsgBox.ColorThemeIniPath, "ColorSettings", "FormColor", AcMsgBox.DefaultFormColor)
        return FormColor
    }
    
    static GetFontColor() {
        ; Try INI file, fall back to hardcoded default
        FontColor := IniRead(AcMsgBox.ColorThemeIniPath, "ColorSettings", "FontColor", AcMsgBox.DefaultFontColor)
        return FontColor
    }
    
    static GetWarnColor() {
        ; Try INI file, fall back to hardcoded default
        WarnColor := IniRead(AcMsgBox.ColorThemeIniPath, "ColorSettings", "WarnColor", AcMsgBox.DefaultWarnColor)
        return WarnColor
    }
    
    static GetLargeFontSize() {
        ; Try INI file, fall back to hardcoded default
        LargeFontSize := IniRead(AcMsgBox.SettingsIniPath, "HotStringHelper", "LargeFontSize", AcMsgBox.DefaultLargeFontSize)
        return LargeFontSize
    }
    
    static GetIconFromOptions(Options) {
        if (Options == "")
            return 0
        
        optionsLower := StrLower(Options)
        
        ; Check string-based icon options
        if (InStr(optionsLower, "iconx") || InStr(optionsLower, "icon hand"))
            return 16
        if (InStr(optionsLower, "icon?") || InStr(optionsLower, "icon question"))
            return 32
        if (InStr(optionsLower, "icon!") || InStr(optionsLower, "icon exclamation"))
            return 48
        if (InStr(optionsLower, "iconi") || InStr(optionsLower, "icon asterisk"))
            return 64
        
        ; Check numeric icon codes (16, 32, 48, 64)
        if (RegExMatch(Options, "\b(16|32|48|64)\b", &match)) {
            iconVal := Integer(match[1])
            if (iconVal == 16 || iconVal == 32 || iconVal == 48 || iconVal == 64)
                return iconVal
        }
        
        return 0
    }
    
    static GetIconPath(icon) {
        switch icon {
            case 16: return AcMsgBox.IconImageFolder . "icon-16.png"
            case 32: return AcMsgBox.IconImageFolder . "icon-32.png"
            case 48: return AcMsgBox.IconImageFolder . "icon-48.png"
            case 64: return AcMsgBox.IconImageFolder . "icon-64.png"
            default: return ""
        }
    }
    
    static GetButtons(Options) {
        ; Convert MsgBox options to button array
        ; Handle both numeric and string option formats
        
        ; Default to OK
        if (Options == "" || Options == 0 || Options == "0")
            return ["OK"]
        
        ; Check for various button configurations
        if (Options == 1 || InStr(Options, "OkCancel"))
            return ["OK", "Cancel"]
        else if (Options == 2 || InStr(Options, "AbortRetryIgnore"))
            return ["Abort", "Retry", "Ignore"]
        else if (Options == 3 || InStr(Options, "YesNoCancel"))
            return ["Yes", "No", "Cancel"]
        else if (Options == 4 || InStr(Options, "YesNo"))
            return ["Yes", "No"]
        else if (Options == 5 || InStr(Options, "RetryCancel"))
            return ["Retry", "Cancel"]
        else if (Options == 6 || InStr(Options, "CancelTryAgainContinue"))
            return ["Cancel", "Try Again", "Continue"]
        
        return ["OK"]
    }
    
    static CalculateButtonWidth(buttons) {
        ; Find the longest button text
        maxLength := 0
        for index, btnText in buttons {
            len := StrLen(btnText)
            if (len > maxLength)
                maxLength := len
        }
        
        ; Calculate width: roughly 8px per character + 20px padding
        ; This gives comfortable spacing for all button lengths
        calculatedWidth := (maxLength * 8) + 20
        
        ; Clamp between reasonable bounds to maintain proportional appearance
        minWidth := 70
        maxWidth := 120
        
        if (calculatedWidth < minWidth)
            return minWidth
        if (calculatedWidth > maxWidth)
            return maxWidth
        
        return calculatedWidth
    }
}