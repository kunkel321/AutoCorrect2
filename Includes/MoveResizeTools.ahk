#SingleInstance
#Requires AutoHotkey v2+

; MOVE TOOL and RESIZE TOOL
; Author: Kunkel321
; Version: 8-30-2026
; Gets #Included with AutoCorrect2.ahk

;##################### WINDOW MOVER ##########################
; Moves active window via dragging from anywhere (not just titlebar)
^!Lbutton:: ; Ctrl+Alt+Left Mouse Click to drag a window
{
	if IsSnipWindow("A") ; ScreenSnip snips already drag from anywhere - nothing to add.
		Return
	SetWinDelay(-1) ; Sets time between moves. -1 = no time
	CoordMode("Mouse", "Screen")
	WinGetPos(&BwX, &BwY, , , "A") ; Begin window X Y coord.
	WinRestore("A") ; Unmaximizes window.
	MouseGetPos(&BmX, &BmY) ; Begin mouse X Y coord
	while GetKeyState("Lbutton", "P") ; While left mouse button is held down.
	{	MouseGetPos(&CmX, &CmY) ; Keep getting current mouse X Y
		WinMove((BwX+CmX-BmX), (BwY+CmY-BmY), , , "A")
	} 
	SetWinDelay 100
	CoordMode("Mouse", "Window") ; Put back, because window is mostly the default.
Return
}

;##################### WINDOW RESIZER ########################
^!Rbutton:: ; Ctrl+Alt+Right Mouse Click to resize (via drag) a window
{
    SetWinDelay(-1) ; Sets time between moves. -1 = no time
    CoordMode("Mouse", "Screen")
    ; A snip is a picture in a frame, not an ordinary window: dragging its edge
    ; re-crops the frozen master rather than stretching anything, and ScreenSnip
    ; itself repairs the window/image/border relationship as we drag.  All this
    ; hotkey has to do is not fight it - hence no min-size clamp, and no
    ; WinRestore on a window that was never maximised.
    isSnip := IsSnipWindow("A")
    WinGetPos(&BwX, &BwY, &BwW, &BwH, "A") ; Begin window X, Y, Width, Height
    if !isSnip
        WinRestore("A") ; Unmaximize window if it's maximized
    MouseGetPos(&BmX, &BmY) ; Begin mouse X, Y coordinates
    
    while GetKeyState("Rbutton", "P") ; While right mouse button is held down...
    {
        MouseGetPos(&CmX, &CmY) ; Current mouse X, Y
        NewWidth := BwW + (CmX - BmX)
        NewHeight := BwH + (CmY - BmY)
        
        ; Ensure minimum window size.  Adjust as desired.
        ; Snips are exempt: they are often far smaller than this, and clamping
        ; would BLOW UP a small snip to 400x200 the instant you grabbed it.
        ; ScreenSnip enforces its own floor when it re-crops (see below).
        if !isSnip
        {
            if (NewWidth < 400)
                NewWidth := 400
            if (NewHeight < 200)
                NewHeight := 200
        }
        
        WinMove(BwX, BwY, NewWidth, NewHeight, "A")
    }
    
    SetWinDelay 100
    CoordMode("Mouse", "Window") ; Reset to default
    Return
}

;##################### SNIP DETECTION ########################
; ScreenSnip.ahk names every snip window "SnipperWindow"; the class check keeps
; the title from matching some unrelated app's window.
IsSnipWindow(win)
{
	try
		return WinGetTitle(win) = "SnipperWindow" && WinGetClass(win) = "AutoHotkeyGUI"
	catch
		return false
}
