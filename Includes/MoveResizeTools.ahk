#SingleInstance
#Requires AutoHotkey v2+

; MOVE TOOL and RESIZE TOOL
; Author: Kunkel321
; Version: 11-25-2025
; Gets #Included with AutoCorrect2.ahk

;##################### WINDOW MOVER ##########################
; Moves active window via dragging from anywhere (not just titlebar)
^!Lbutton:: ; Ctrl+Alt+Left Mouse Click to drag a window
{
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
    WinGetPos(&BwX, &BwY, &BwW, &BwH, "A") ; Begin window X, Y, Width, Height
    WinRestore("A") ; Unmaximize window if it's maximized
    MouseGetPos(&BmX, &BmY) ; Begin mouse X, Y coordinates
    
    while GetKeyState("Rbutton", "P") ; While right mouse button is held down...
    {
        MouseGetPos(&CmX, &CmY) ; Current mouse X, Y
        NewWidth := BwW + (CmX - BmX)
        NewHeight := BwH + (CmY - BmY)
        
        ; Ensure minimum window size.  Adjust as desired.
        if (NewWidth < 400)
            NewWidth := 400
        if (NewHeight < 200)
            NewHeight := 200
            
        WinMove(BwX, BwY, NewWidth, NewHeight, "A")
    }
    
    SetWinDelay 100
    CoordMode("Mouse", "Window") ; Reset to default
    Return
}
