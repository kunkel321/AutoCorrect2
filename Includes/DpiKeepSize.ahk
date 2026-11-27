#Requires AutoHotkey v2.0
; ============================================================
; DpiKeepSize - keeps a Gui its own size when it is dragged to a
; monitor with a different scale.
; Intended for use with AutoCorrect2 apps.
; Version 11-27-2026
; ============================================================
; THE PROBLEM
;   Dragged from, say, a 125% monitor to a 100% one, a Gui's FRAME was
;   shrunk to the new scale while the controls inside kept their size,
;   so the right and bottom edges were cut off.  Blocking WM_DPICHANGED
;   (handling 0x02E0 with "return 0") did NOT stop it on AHK 2.0.30, so
;   this puts the size back afterwards instead.
;
; HOW
;   When a drag starts (WM_ENTERSIZEMOVE) the window's outer size and its
;   monitor's DPI are noted.  When the drag ends (WM_EXITSIZEMOVE), if the
;   size changed, it is put back with SetWindowPos -- but only if the window
;   ended up on a monitor with a different DPI, or has no resize border.  So
;   resizing a +Resize window by its border is never undone.  The window just
;   looks a little bigger on the lower-scaled monitor (and smaller on a
;   higher-scaled one), but complete.
;
;   Measuring is done with the thread in per-monitor mode: a timer that runs
;   during or right after a drag can be system-aware, where GetWindowRect
;   gives scaled rather than physical pixels.
;
;   The message handlers only observe: they return nothing, so no message is
;   marked handled, for watched windows or any other (see the ahk-v2-tips
;   skill, "OnMessage: the return value...").
;
; USAGE
;   #Include "..\Includes\DpiKeepSize.ahk"            ; from Core\ or Tools\
;   #Include "%A_LineFile%\..\DpiKeepSize.ahk"        ; from another file in Includes\
;   myGui.Show()
;   DpiKeepSize.Watch(myGui)       ; a Gui object or an hwnd; once per window
;
;   A destroyed window is forgotten automatically (WM_DESTROY).  Not needed
;   for MsgBox()/InputBox() (Windows' own dialogs), nor for +Parent child Guis
;   (watch the top-level window they sit in).
; ============================================================

class DpiKeepSize {
    static wins := Map()        ; hwnd -> {w, h, dpi} noted when a drag starts
    static hooked := false

    static Watch(guiOrHwnd) {
        hwnd := IsObject(guiOrHwnd) ? guiOrHwnd.Hwnd : guiOrHwnd
        if !hwnd
            return
        this.wins[hwnd] := {w: 0, h: 0, dpi: 0}
        if !this.hooked {
            this.hooked := true
            OnMessage(0x0231, this._Start.Bind(this))     ; WM_ENTERSIZEMOVE
            OnMessage(0x0232, this._Stop.Bind(this))      ; WM_EXITSIZEMOVE
            OnMessage(0x0002, this._Gone.Bind(this))      ; WM_DESTROY
        }
    }

    static Unwatch(guiOrHwnd) {
        hwnd := IsObject(guiOrHwnd) ? guiOrHwnd.Hwnd : guiOrHwnd
        if this.wins.Has(hwnd)
            this.wins.Delete(hwnd)
    }

    ; ----- message handlers: observe only, never return a value -----
    static _Start(wParam, lParam, msg, hwnd) {
        if !this.wins.Has(hwnd)
            return
        prev := this._DpiEnter()
        this._Size(hwnd, &w, &h)
        e := this.wins[hwnd]
        e.w := w, e.h := h, e.dpi := this._MonitorDpi(hwnd)
        this._DpiLeave(prev)
    }

    static _Stop(wParam, lParam, msg, hwnd) {
        if this.wins.Has(hwnd) && this.wins[hwnd].w
            SetTimer(this._Restore.Bind(this, hwnd), -50)  ; after Windows has finished with the window
    }

    static _Gone(wParam, lParam, msg, hwnd) {
        if this.wins.Has(hwnd)
            this.wins.Delete(hwnd)
    }

    ; ----- the fix -----
    static _Restore(hwnd) {
        if !this.wins.Has(hwnd) || !DllCall("IsWindow", "Ptr", hwnd)
            return
        e := this.wins[hwnd]
        prev := this._DpiEnter()
        this._Size(hwnd, &w, &h)
        if w != e.w || h != e.h {
            dpi := this._MonitorDpi(hwnd)
            resizable := false
            try resizable := WinGetStyle(hwnd) & 0x40000          ; WS_THICKFRAME
            if (dpi && e.dpi && dpi != e.dpi) || !resizable
                DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", e.w, "Int", e.h
                    , "UInt", 0x16)                                ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
        }
        this._DpiLeave(prev)
    }

    static _Size(hwnd, &w, &h) {
        rc := Buffer(16, 0)
        DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rc)
        w := NumGet(rc, 8, "Int") - NumGet(rc, 0, "Int")
        h := NumGet(rc, 12, "Int") - NumGet(rc, 4, "Int")
    }

    ; The DPI of the monitor the window is (mostly) on; 0 if it can't be read.
    static _MonitorDpi(hwnd) {
        try {
            hMon := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")    ; MONITOR_DEFAULTTONEAREST
            if DllCall("shcore\GetDpiForMonitor", "Ptr", hMon, "Int", 0, "UInt*", &dx := 0, "UInt*", &dy := 0) = 0
                return dx
        }
        return 0
    }

    static _DpiEnter() {
        prev := 0
        try prev := DllCall("SetThreadDpiAwarenessContext", "Ptr", -3, "Ptr")    ; PER_MONITOR_AWARE
        return prev
    }

    static _DpiLeave(prev) {
        if prev
            try DllCall("SetThreadDpiAwarenessContext", "Ptr", prev, "Ptr")
    }
}
