; ============================================================
; AcMsgBox - Custom Message Box with GUI Styling
; ============================================================
; Replacement for standard MsgBox() with custom GUI styling
; 
; DEPENDENCIES:
;   - Config.FormColor (background color)
;   - Config.FontColor (text color)
;   - Config.LargeFontSize (font size)
; 
; All three Config properties should be set before calling acMsgBox.
; Since your tools already have Config setup for colors and fonts,
; just #Include this file and you're ready to go!
; 
; USAGE (same as AHK v2 MsgBox):
;   AcMsgBox.Show(Text)
;   AcMsgBox.Show(Text, Title)
;   AcMsgBox.Show(Text, Title, Options)
;   AcMsgBox.Show(Text, Title, Options, TimeoutSeconds)
;
; BUTTON OPTIONS:
;   0 = OK
;   1 = OK / Cancel
;   2 = Abort / Retry / Ignore
;   3 = Yes / No / Cancel
;   4 = Yes / No
;   5 = Retry / Cancel
;   6 = Cancel / Try Again / Continue
;
; RETURNS:
;   - "OK", "Cancel", "Yes", "No", "Retry", "Abort", "Ignore", "Try Again", "Continue"
;   - "" (empty string) if timeout occurs
; ============================================================

class AcMsgBox {
    static Show(Text := "", Title := "", Options := "", TimeoutSeconds := 0) {
        ; ===== Determine Button Type =====
        ; Convert Options to button array
        buttons := AcMsgBox.GetButtons(Options)
        
        ; ===== Create Custom GUI =====
        msgGui := Gui(, Title)
        msgGui.Opt("+AlwaysOnTop")
        msgGui.BackColor := Config.FormColor
        
        fontColor := Config.FontColor != "" ? "c" SubStr(Config.FontColor, -6) : ""
        msgGui.SetFont(Config.LargeFontSize, "Segoe UI")
        msgGui.SetFont(fontColor)
        
        ; ===== Add Text Message =====
        msgGui.Add("Text",, Text)
        
        ; ===== Add Buttons =====
        buttonCount := buttons.Length
        buttonWidth := 80
        totalButtonWidth := (buttonCount * buttonWidth) + ((buttonCount - 1) * 10)
        startX := (600 - totalButtonWidth) / 2
        
        buttonResult := ""
        
        for index, btnText in buttons {
            xPos := startX + ((index - 1) * (buttonWidth + 10))
            btn := msgGui.Add("Button", "x" xPos " y80 w" buttonWidth, btnText)
            btn.OnEvent("Click", (GuiCtrlObj, Info) => (
                buttonResult := GuiCtrlObj.Value,
                msgGui.Destroy()
            ))
        }
        
        ; Handle Escape key (closes dialog)
        msgGui.OnEvent("Close", (GuiCtrlObj) => (
            buttonResult := buttons[buttons.Length],
            msgGui.Destroy()
        ))
        
        ; ===== Show GUI and Wait =====
        msgGui.Show()
        
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
}

/*
; Use minimal config classes as needed

; Read colors directly
formColor := ""
fontColor := ""
largeFontSize := 11

IniRead(formColor, "..\Data\acSettings.ini", "Appearance", "FormColor", "0xE5E4E2")
IniRead(fontColor, "..\Data\acSettings.ini", "Appearance", "FontColor", "c0x1F1F1F")
IniRead(largeFontSize, "..\Data\acSettings.ini", "UI", "LargeFontSize", 11)

; Create a Config class wrapper for AcMsgBox
class Config {
    static FormColor := formColor
    static FontColor := fontColor
    static LargeFontSize := largeFontSize
}

#Include "..\Resources\Includes\AcMsgBox.ahk"

*/