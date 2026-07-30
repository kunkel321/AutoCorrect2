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

; Set when THIS script consumes an RButton-down, cleared as soon as the matching
; up is handled. The up hotkey is gated on it (see its #HotIf below) so the pair
; can never split across scripts. See the ownership note above that hotkey.
DTOwnsButton := false

; ── Yield the right button to ScreenSnip's snips ──────────────────────────────
; ScreenSnip is not part of the AutoCorrect2 Suite of tools.  It is here
; Github https://github.com/kunkel321/ScreenSnip if you want to try it.
; ScreenSnip.ahk pans a snip's captured region with right-click-and-drag, using a
; CONSUMING RButton hotkey scoped to the cursor being over one of its floating
; windows. The two hotkeys below are also consuming, but unscoped — so whichever
; script's low-level mouse hook Windows calls FIRST wins the button outright.
;
; A hook goes to the FRONT of that chain each time it's installed, so simply
; reloading AutoCorrect2 put DragTools ahead of ScreenSnip and silently killed
; the pan gesture until ScreenSnip was itself restarted. (The symptom was
; confusing: right-CLICK on a snip still opened its menu, because the "not a
; recognised drag" branch below replays the click with Send "{RButton}", and that
; replayed click reaches the snip window as a normal WM_CONTEXTMENU.)
;
; Testing the cursor position here settles the arbitration deterministically, so
; load order stops mattering and neither script has to fight for the front of the
; hook chain.
;
; NOTE: this criterion is restated because a #HotIf inside an include REPLACES
; the one wrapping the #Include in AutoCorrect2.ahk rather than combining with
; it — so Config.EnableDragTools has to be repeated to keep the acSettings.ini
; kill switch working. If that config key is ever renamed, change it in both
; places. The bare #HotIf at the bottom of this file restores the default.
#HotIf Config.EnableDragTools && !MouseOverSnipWindow()

; True when the mouse is over a ScreenSnip snip. Cursor-based rather than
; WinActive-based on purpose: a freshly captured snip is not the active window
; yet, and nudging the capture region right after grabbing it is the single most
; common moment to want the pan. Every ScreenSnip snip is created as
; Gui('-Caption +AlwaysOnTop ...', 'SnipperWindow'), so title+class identify one
; exactly. Guarded because the window can vanish between the two queries, and
; because a cursor over bare desktop yields hwnd 0, which makes both throw.
; Returning false on any failure is the safe direction — DragTools simply keeps
; the button, which is the pre-existing behaviour.
MouseOverSnipWindow() {
    MouseGetPos(, , &w)
    try {
        return WinGetClass('ahk_id ' w) = 'AutoHotkeyGUI'
            && WinGetTitle('ahk_id ' w) = 'SnipperWindow'
    } catch {
        return false
    }
}

IgnoreDuration := 100  ; Ignore if right mouse button down shorter than this many milliseconds.
IgnoreLength := 100  ; Ignore drags less than this many pixels long.

RButton::  ; hide
{   ;soundbeep 1200, 200
    Global VarXb, VarYb, VarTb, DTOwnsButton

    ; Claim ownership BEFORE any early return. This hotkey has already consumed
    ; the physical button-down by the time the body runs, so we are on the hook
    ; for consuming the matching up as well.
    DTOwnsButton := true

    ; Skip if Ctrl+Alt is pressed (for window resize functionality)
    if (GetKeyState("Ctrl", "P") && GetKeyState("Alt", "P")) {
        VarTb := 0                  ; MoveResizeTools' gesture, not one of ours
        return
    }

    MouseGetPos(&VarXb, &VarYb)
    VarTb := A_TickCount            ; when the button went down -- see Up handler
}

; True only while a button-down consumed by THIS script is still open.
; Guarded with IsSet in case a press somehow beats the auto-execute assignment
; above -- an error thrown inside a #HotIf expression is an ugly way to find out.
DragToolsHasButton() {
    Global DTOwnsButton
    return IsSet(DTOwnsButton) && DTOwnsButton
}

; ── Why the up hotkey is gated on ownership, not on cursor position ───────────
; The down criterion tests where the cursor IS; a drag can start on a snip and
; end off it (or the reverse), which would split the pair across two scripts.
; That direction matters most: if the press went to ScreenSnip but we ate the
; release, ScreenSnip's hook would never see the button come up, and its pan
; loop -- a plain `while GetKeyState('RButton','P')` -- would spin forever. Its
; right-drag would then be dead until IT was restarted: the exact mirror of the
; bug the guard above was added to fix. Pairing the up to the down we actually
; consumed makes the two scripts hand the button back and forth cleanly.
#HotIf Config.EnableDragTools && DragToolsHasButton()

$RButton Up:: ; hide
{
    Global VarXb, VarYb, VarXe, VarYe, VarTb, DTOwnsButton

    DTOwnsButton := false           ; the pair is closed, whatever happens below

    ; Skip if Ctrl+Alt is pressed
    if (GetKeyState("Ctrl", "P") && GetKeyState("Alt", "P"))
        return

    ; How long was the button held? Measured straight from the down handler's
    ; timestamp rather than with A_TimeSincePriorHotkey, which reports the gap
    ; since whatever hotkey ran LAST -- not necessarily our own RButton-down --
    ; and is BLANK when no hotkey preceded this one at all. Comparing that blank
    ; against a number is what threw "Expected a Number but got an empty string".
    ; Any hotstring or hotkey firing mid-gesture used to corrupt the reading too.
    if (!IsSet(VarTb) || VarTb = 0) {
        Send "{RButton}"            ; nothing of ours to measure -- plain r-click
        return
    }
    heldMs := A_TickCount - VarTb
    VarTb  := 0                     ; consume it; a stray later Up can't reuse it

    if (heldMs <= IgnoreDuration) {
        Send "{RButton}"            ; too brief to be a drag -- plain r-click
        return
    }

    if !(IsSet(VarXb) && IsSet(VarYb)) {
        Send "{RButton}"            ; no start point recorded
        return
    }

    MouseGetPos(&VarXe, &VarYe)
    DoMath()
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
    ; Which app is about to receive the Send? The ACTIVE window, since that's
    ; where the keystrokes land. Both queries are wrapped because between the
    ; drag ending and this running the active window can legitimately be gone,
    ; or belong to a process this script can't query — WinGetProcessName and
    ; WinGetTitle throw a TargetError in that case rather than returning "".
    ;
    ; Test the PROCESS first. The old title-only check was unreliable because
    ; PDF-XChange's caption is the document name plus a suffix the user can turn
    ; off in its own settings, so "PDF-XChange" isn't guaranteed to appear at
    ; all. The executable name is stable. Title match kept as a fallback for
    ; other builds; verify the exe names with Window Spy if a build differs.
    exe := "", activeWindow := ""
    try exe          := WinGetProcessName("A")
    try activeWindow := WinGetTitle("A")

    isPDFXChange := (exe = "PDFXEdit.exe")            ; PDF-XChange Editor
                 || (exe = "PDFXCview.exe")           ; PDF-XChange Viewer
                 || InStr(activeWindow, "PDF-XChange")

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

; Restore the default hotkey context. Everything above this line is scoped by the
; #HotIf near the top of the file; without this, that criterion would leak into
; whatever AutoCorrect2.ahk includes next.
#HotIf
