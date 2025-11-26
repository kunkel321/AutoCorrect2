#SingleInstance
#Requires AutoHotkey v2+

; DRAG TOOLS
; Author: Kunkel321
; Version: 11-25-2025
; Gets #Included with AutoCorrect2.ahk

;###############################################################
; Up Down Left Right RightClick-and-Drag Actions Tool
; Inspired by the excellent MouseGesureL.ahk
; https://hp.vector.co.jp/authors/VA018351/en/mglahk.html

IgnoreDuration := 100  ; Ignore if right mouse button down shorter than this many milliseconds.
IgnoreLength := 100  ; Ignore drags less than this many pixels long.

RButton::  ; hide
{   ;soundbeep 1200, 200
    ; Skip if Ctrl+Alt is pressed (for window resize functionality)
    if (GetKeyState("Ctrl", "P") && GetKeyState("Alt", "P"))
        return
        
    Global VarXb, VarYb ; i.e. variable Xpos, Ypos "beginning"
    MouseGetPos &VarXb, &VarYb
}

$RButton Up:: ; hide
{
    ; Skip if Ctrl+Alt is pressed
    if (GetKeyState("Ctrl", "P") && GetKeyState("Alt", "P"))
        return
        
    IF (A_TimeSincePriorHotkey > IgnoreDuration) {
        Global VarXe, VarYe ; i.e. variable Xpos, Ypos "ending"
        MouseGetPos &VarXe, &VarYe
        
        ; Check if variables are initialized to prevent errors
        if (IsSet(VarXb) && IsSet(VarYb) && IsSet(VarXe) && IsSet(VarYe))
            DoMath()
        else
            Send "{RButton}" ; Just do default mouse r-click if variables aren't set
    }
    else
        Send "{RButton}" ; just do default mouse r-click.
}

DoMath()
{ 	
	abX := Abs(VarXb - VarXe) ; get begin-end differences
	abY := Abs(VarYb - VarYe)
	If abX > (abY * 3) and (abX > IgnoreLength) { ; is horizontal -and- drag was long enough?
		If VarXb > VarXe
			DragDirection("Left")
		Else
			DragDirection("Right")
	}
	Else If abY > (abX * 3) and (abY > IgnoreLength) {  ; is vertical -and- drag was long enough?
		If VarYb > VarYe
			DragDirection("Up")
		Else
			DragDirection("Down")
	}
	Else
		Send "{RButton}" ; just do default mouse r-click.
}

DragDirection(dragWay)
{	
	isPDFXChange := 0 ; Set default to prevent crash when we can't get active window ??
    activeWindow := "" ; Initialize variable so next line doesn't have problems.
	try activeWindow := WinGetTitle("A")
    isPDFXChange := InStr(activeWindow, "PDF-XChange") > 0 ; This part is buggy.
	;MsgBox("Active Window: " . activeWindow . "`nIs PDF-XChange: " . isPDFXChange)
    if (isPDFXChange) {	
		switch dragWay
        {	case "Left"		: Send "{Home}"  ; Back
            case "Right"	: Send "{End}"   ; Forward
            case "Up"		: Send "{PgUp}"  ; Top
            case "Down"		: Send "{PgDn}"  ; Bottom
        }
    }
    else {	
		switch dragWay
        {	case "Left"		: Send "!{Left}"  ; Back
            case "Right"	: Send "!{Right}" ; Forward
            case "Up"		: Send "^{Home}"  ; Top
            case "Down"		: Send "^{End}"   ; Bottom
        }
    }
}
