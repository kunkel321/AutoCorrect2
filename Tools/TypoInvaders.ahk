#Requires AutoHotkey v2.0
#SingleInstance Force

/*
===============================================================================
  Typo Invaders  --  v1.0
  A typing-shooter for the AutoCorrect2 suite.

  By: Kunkel321 with ClaudeAI
  Version date: 8-21-2026 

  Misspellings descend from the top of the screen.  You destroy one by typing
  the CORRECT spelling.  There is no aiming and no fire button -- the keyboard
  is the weapon.  The instant your typed buffer matches an invader's correct
  word, that invader is vaporized.

  WORD SOURCE
    Cfg.Source selects where the invaders come from:
      "mclog"  ManualCorrectionsLog.txt -- the typos you actually made and
               fixed by hand.  Lines look like:
                   2026-04-28 -- ::tesking::testing
               Personal, current, all whole-word.  This is the default.
      "lib"    the hotstring library (Cfg.LibFile).  Big and general; entries
               whose options contain * or ? are skipped, since those are
               word-part triggers and make nonsense invaders.
      "both"   merge the two.
    Files are located by searching Cfg.SearchPaths, or give an absolute path.
    A typo logged repeatedly becomes a more frequent invader (Cfg.MaxWeight),
    so the game drills your real weak spots.  If nothing usable is found it
    falls back to a built-in list of ~100 classic misspellings.

  UNREADABLE TYPOS
    Real hotstring triggers are tuned for catching mistakes, not for being
    solvable puzzles -- some are mangled past recognition.  Four layers deal
    with that, cheapest first:
      1. Each pair is scored on how close the typo is to its answer.  Hopeless
         ones are dropped at load (Cfg.MinSimilarity).
      2. Merely-hard ones always wear a skeleton hint under the box, showing
         the first letter and the length ("q.......").
      3. An invader nearly at the ground reveals its answer for free, so you
         can never be stumped to death.
      4. Hold the hint key to reveal every answer on screen, at a running
         score cost.

  CONTROLS
    letters      type the correct spelling of any invader on screen
    Backspace    delete last character
    Space        clear the typed buffer
    Up / Down    adjust fall speed  (see Cfg.InvertSpeedKeys)
    Tab (hold)   reveal all answers  (Cfg.HintKey / Cfg.HintMod)
    Esc          pause / resume  (Q while paused = quit)
    Enter        start game / restart after game over

  The window is resizable -- drag it taller for more reaction time.  Layout
  reflows automatically and the back buffer is rebuilt to match.

  RENDERING
    Pure GDI double-buffering via DllCall -- no Gdip_All.ahk needed.  Every
    frame is composed in an off-screen memory DC and BitBlt'd to the window in
    one shot, so there is zero flicker.

  NOTE ON KEY SUPPRESSION
    The InputHook swallows text keys while the game window is active.  That is
    deliberate: without it, typing "teh" would fire your real AutoCorrect2
    hotstrings in the background.  The hook stops the moment the window loses
    focus (WM_ACTIVATE), so it can never strand your keyboard.

  steve / kunkel321 -- built with Claude
===============================================================================
*/

TI.Start()

; =============================================================================
;  CONFIG  --  tweak freely
; =============================================================================
class Cfg {
    ; --- word source -------------------------------------------------------
    ; Which of your AutoCorrect2 files supplies the invaders:
    ;   "mclog"  ManualCorrectionsLog.txt -- typos you actually made and fixed
    ;            by hand. Personal, current, and every entry is whole-word.
    ;   "lib"    the hotstring library -- big, general, needs option filtering.
    ;   "both"   merge them, mclog first (its duplicates win).
    static Source := "both"

    static MCLogFile := "ManualCorrectionsLog.txt"
    static LibFile   := "AutoCorrectHotstrings.ahk"

    ; Folders searched, in order, for whichever file(s) are in play.  Put an
    ; absolute path in MCLogFile/LibFile to skip the search entirely.
    ; Default assumes the game lives in Tools\ alongside Core\ and Data\.
    static SearchPaths := [A_ScriptDir "\..\Core"
                         , A_ScriptDir "\..\Data"
                         , A_ScriptDir]

    ; Only consider mclog entries from the last N days. 0 = the whole log.
    static MCLogDays := 0

    ; A typo you make repeatedly shows up as an invader more often, so the
    ; game drills your real weak spots. 1 disables the weighting.
    static MaxWeight := 3

    ; Whole-word entries only.  AC2 word-part triggers carry * or ? in their
    ; options (":*:ationna::ationally") and produce unplayable fragments.
    ; (Only applies to the library -- mclog entries are all whole-word.)
    static WholeWordOnly := true

    ; --- window ------------------------------------------------------------
    ; WinW/WinH/GroundY/LeakY are live values -- Relayout() rewrites them on
    ; every resize.  The numbers here are just the starting size.
    static WinW    := 900
    static WinH    := 660
    static MinW    := 780            ; enforced via WM_GETMINMAXINFO
    static MinH    := 520
    static HudH    := 140            ; fixed-height band below the ground line
    static GroundY := 520
    static LeakY   := 498

    ; --- legibility --------------------------------------------------------
    ; Some real-world triggers are mangled past recognition ("titity").  Each
    ; pair is scored 0..1 on how close the typo is to the correct word:
    ;   below MinSimilarity   -> dropped at load, never appears
    ;   below HardSimilarity  -> appears, but always wears a skeleton hint
    ;   above                 -> plain, solve it yourself
    static MinSimilarity  := 0.85
    static HardSimilarity := 0.95

    ; Very short pairs fail the opposite way: "ork" -> "ord" scores as highly
    ; similar, but a single swap in a 3-letter word gives you nothing to
    ; reason from. Anything this short always gets the skeleton hint.
    static ShortIsHard := 4
    static MinWordLen  := 3           ; raise to 4-5 to drop tiny words entirely

    ; An invader that gets this far down its descent reveals its answer for
    ; free -- you still have to type it, but you can't be stumped to death.
    static PanicReveal := true
    static PanicAt     := 0.80        ; fraction of the way to the ground

    ; --- hint key ----------------------------------------------------------
    ; Hold to reveal every answer on screen. Costs score while held.
    ; HintKey takes any AHK key name ("Tab", "F1", "h", "CapsLock"...).
    ; Set HintMod to "Ctrl"/"Shift"/"Alt" to require a modifier, or "" for none.
    static HintKey   := "Tab"
    static HintMod   := ""
    static HintDrain := 25            ; score points per second while held


    ; --- invader sprites ---------------------------------------------------
    ; The word box is the creature's body; head, shoulders, legs and feet are
    ; built from blocks this many pixels square.
    static PixelSize  := 5
    static AnimFrames := 20           ; frames per animation flip (lower = frantic)
    static MarchStep  := 3            ; px the whole fleet side-steps each flip
    static LockAnimx2 := true         ; targeted invaders animate twice as fast

    ; --- difficulty --------------------------------------------------------
    static BaseSpeed  := 0.45        ; px per frame at wave 1
    static SpeedPerWave := 0.07
    static WaveSize   := 6           ; invaders in wave 1
    static WaveGrowth := 2           ; extra invaders per wave
    static MaxOnScreen := 6          ; concurrent cap at wave 1 (grows slowly)
    static SpawnGap   := 105         ; frames between spawns at wave 1
    static Lives      := 3
    static FrameMs    := 16          ; ~60 fps

    ; --- live speed trim (Up/Down arrows) ----------------------------------
    ; false: Up = slower, Down = faster (arrow points the way they fall)
    ; true : Up = faster, Down = slower
    static InvertSpeedKeys := false
    static SpeedStep := 0.1
    static SpeedMin  := 0.3
    static SpeedMax  := 2.5
}

; -----------------------------------------------------------------------------
;  Palette (0xRRGGBB -- converted to GDI BGR internally)
; -----------------------------------------------------------------------------
class Pal {
    static Bg        := 0x0B0E17
    static Panel     := 0x111726
    static StarDim   := 0x1E2740
    static StarLit   := 0x46567F
    static Ground    := 0x2F5D8A
    static GroundLit := 0x63C2FF

    static ShipBody  := 0x63C2FF
    static ShipCore  := 0xE8F6FF

    static EnemyFill := 0x14203A
    static EnemyEdge := 0x2F5D8A
    static EnemyText := 0x7FD4FF

    static LockFill  := 0x3A2A12
    static LockEdge  := 0xFFA630
    static LockText  := 0xFFD166

    static Danger    := 0xFF5A5A
    static Laser     := 0x9BF0FF
    static Spark     := 0xFFD166
    static Spark2    := 0xFF8A4C

    static HudDim    := 0x6E80A8
    static HudLit    := 0xC9D9F5
    static Score     := 0xFFD166
    static Buffer    := 0xE8F1FF
    static Life      := 0xFF6B8A

    ; blend two RGB colors, t = 0..1
    static Mix(c1, c2, t) {
        t := t < 0 ? 0 : (t > 1 ? 1 : t)
        r := ((c1 >> 16 & 0xFF) * (1 - t)) + ((c2 >> 16 & 0xFF) * t)
        g := ((c1 >>  8 & 0xFF) * (1 - t)) + ((c2 >>  8 & 0xFF) * t)
        b := ((c1       & 0xFF) * (1 - t)) + ((c2       & 0xFF) * t)
        return (Integer(r) << 16) | (Integer(g) << 8) | Integer(b)
    }
}

; =============================================================================
;  Canvas -- GDI double-buffered drawing surface
; =============================================================================
class Canvas {
    __New(hwnd, w, h) {
        this.hwnd := hwnd, this.w := w, this.h := h
        this.brushes := Map(), this.pens := Map(), this.fonts := Map()

        dc := DllCall("GetDC", "Ptr", hwnd, "Ptr")
        this.mdc := DllCall("CreateCompatibleDC", "Ptr", dc, "Ptr")
        this.bmp := DllCall("CreateCompatibleBitmap", "Ptr", dc, "Int", w, "Int", h, "Ptr")
        this.obmp := DllCall("SelectObject", "Ptr", this.mdc, "Ptr", this.bmp, "Ptr")
        DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", dc)

        DllCall("SetBkMode", "Ptr", this.mdc, "Int", 1)          ; TRANSPARENT
        this.curFont := 0
    }

    ; --- RGB (0xRRGGBB) to GDI COLORREF (0x00BBGGRR) ---
    static BGR(c) => ((c & 0xFF) << 16) | (c & 0xFF00) | ((c >> 16) & 0xFF)

    Brush(color) {
        if !this.brushes.Has(color)
            this.brushes[color] := DllCall("CreateSolidBrush", "UInt", Canvas.BGR(color), "Ptr")
        return this.brushes[color]
    }

    Pen(color, width := 1) {
        key := color "|" width
        if !this.pens.Has(key)
            this.pens[key] := DllCall("CreatePen", "Int", 0, "Int", width, "UInt", Canvas.BGR(color), "Ptr")
        return this.pens[key]
    }

    Font(name, size, bold := false, italic := false) {
        key := name "|" size "|" (bold ? 1 : 0) "|" (italic ? 1 : 0)
        if !this.fonts.Has(key) {
            this.fonts[key] := DllCall("CreateFontW"
                , "Int", -size, "Int", 0, "Int", 0, "Int", 0
                , "Int", bold ? 700 : 400
                , "UInt", italic ? 1 : 0, "UInt", 0, "UInt", 0
                , "UInt", 1          ; DEFAULT_CHARSET
                , "UInt", 0, "UInt", 0
                , "UInt", 5          ; CLEARTYPE_QUALITY
                , "UInt", 0, "Str", name, "Ptr")
        }
        return this.fonts[key]
    }

    UseFont(hFont) {
        if (this.curFont != hFont) {
            DllCall("SelectObject", "Ptr", this.mdc, "Ptr", hFont)
            this.curFont := hFont
        }
    }

    Clear(color) => this.Rect(0, 0, this.w, this.h, color)

    Rect(x, y, w, h, color) {
        r := Buffer(16)
        NumPut("Int", Integer(x), "Int", Integer(y), "Int", Integer(x + w), "Int", Integer(y + h), r)
        DllCall("FillRect", "Ptr", this.mdc, "Ptr", r, "Ptr", this.Brush(color))
    }

    Frame(x, y, w, h, color, t := 1) {
        this.Rect(x, y, w, t, color)
        this.Rect(x, y + h - t, w, t, color)
        this.Rect(x, y, t, h, color)
        this.Rect(x + w - t, y, t, h, color)
    }

    Line(x1, y1, x2, y2, color, width := 1) {
        old := DllCall("SelectObject", "Ptr", this.mdc, "Ptr", this.Pen(color, width), "Ptr")
        DllCall("MoveToEx", "Ptr", this.mdc, "Int", Integer(x1), "Int", Integer(y1), "Ptr", 0)
        DllCall("LineTo",   "Ptr", this.mdc, "Int", Integer(x2), "Int", Integer(y2))
        DllCall("SelectObject", "Ptr", this.mdc, "Ptr", old)
    }

    Measure(text, hFont) {
        text := String(text)                 ; DllCall "Str" will not accept a raw number
        this.UseFont(hFont)
        sz := Buffer(8, 0)
        DllCall("GetTextExtentPoint32W", "Ptr", this.mdc, "Str", text, "Int", StrLen(text), "Ptr", sz)
        return {w: NumGet(sz, 0, "Int"), h: NumGet(sz, 4, "Int")}
    }

    Text(x, y, text, color, hFont) {
        text := String(text)
        this.UseFont(hFont)
        DllCall("SetTextColor", "Ptr", this.mdc, "UInt", Canvas.BGR(color))
        DllCall("TextOutW", "Ptr", this.mdc, "Int", Integer(x), "Int", Integer(y)
              , "Str", text, "Int", StrLen(text))
    }

    ; horizontally centered on cx
    TextC(cx, y, text, color, hFont) {
        m := this.Measure(text, hFont)
        this.Text(cx - m.w / 2, y, text, color, hFont)
    }

    ; right edge of the text sits on rx
    TextR(rx, y, text, color, hFont) {
        m := this.Measure(text, hFont)
        this.Text(rx - m.w, y, text, color, hFont)
    }

    ; draw a compiled sprite frame at (px, py), scaled up
    Sprite(px, py, runs, scale, color) {
        for r in runs
            this.Rect(px + r.x * scale, py + r.y * scale, r.w * scale, scale, color)
    }

    ; swap in a bigger/smaller back buffer, keeping the same memory DC
    Resize(w, h) {
        if (w = this.w && h = this.h) || (w < 1 || h < 1)
            return
        this.w := w, this.h := h
        dc := DllCall("GetDC", "Ptr", this.hwnd, "Ptr")
        nb := DllCall("CreateCompatibleBitmap", "Ptr", dc, "Int", w, "Int", h, "Ptr")
        DllCall("ReleaseDC", "Ptr", this.hwnd, "Ptr", dc)
        old := DllCall("SelectObject", "Ptr", this.mdc, "Ptr", nb, "Ptr")
        DllCall("DeleteObject", "Ptr", old)      ; the previous back buffer
        this.bmp := nb
        DllCall("SetBkMode", "Ptr", this.mdc, "Int", 1)
    }

    Flip() {
        dc := DllCall("GetDC", "Ptr", this.hwnd, "Ptr")
        DllCall("BitBlt", "Ptr", dc, "Int", 0, "Int", 0, "Int", this.w, "Int", this.h
              , "Ptr", this.mdc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)   ; SRCCOPY
        DllCall("ReleaseDC", "Ptr", this.hwnd, "Ptr", dc)
    }

    Free() {
        ; a selected font cannot be deleted -- swap in a stock font first
        DllCall("SelectObject", "Ptr", this.mdc, "Ptr", DllCall("GetStockObject", "Int", 17, "Ptr"))
        for k, v in this.brushes
            DllCall("DeleteObject", "Ptr", v)
        for k, v in this.pens
            DllCall("DeleteObject", "Ptr", v)
        for k, v in this.fonts
            DllCall("DeleteObject", "Ptr", v)
        DllCall("SelectObject", "Ptr", this.mdc, "Ptr", this.obmp)
        DllCall("DeleteObject", "Ptr", this.bmp)
        DllCall("DeleteDC", "Ptr", this.mdc)
    }
}

; =============================================================================
;  Sprite -- the invader chassis
; =============================================================================
; The word box IS the creature's body.  Only the head is fixed pixel art (an
; 11x5 grid, two frames); shoulders, arms and feet are drawn parametrically off
; the box rect, so a long word makes a wide invader rather than a small alien
; towing a big label.  All measurements are in cells of Cfg.PixelSize.
class Sprite {
    static Heads := [], built := false
    static HeadW := 11, HeadH := 5

    static Build() {
        if this.built
            return
        defs := [
            ; --- feelers: antennae sweep down, wide-set eyes ---
            [ ["..X.....X.."
             , "...X...X..."
             , ".XXXXXXXXX."
             , "XX.XXXXX.XX"
             , "XXXXXXXXXXX"]
            , [".X.......X."
             , "..X.....X.."
             , ".XXXXXXXXX."
             , "XX.XXXXX.XX"
             , "XXXXXXXXXXX"] ]
            ; --- dome: blinks on the off-beat ---
          , [ ["...XXXXX..."
             , "..XXXXXXX.."
             , ".XX.XXX.XX."
             , "XXXXXXXXXXX"
             , "X.XXXXXXX.X"]
            , ["...XXXXX..."
             , "..XXXXXXX.."
             , ".XXXXXXXXX."
             , "XXXXXXXXXXX"
             , "X.XXXXXXX.X"] ]
            ; --- horned: brow flares ---
          , [ ["X.........X"
             , "XX.......XX"
             , ".XXXXXXXXX."
             , ".X.XXXXX.X."
             , "XXXXXXXXXXX"]
            , [".X.......X."
             , "XXX.....XXX"
             , ".XXXXXXXXX."
             , ".X.XXXXX.X."
             , "XXXXXXXXXXX"] ]
        ]
        for d in defs
            this.Heads.Push({a: this.Runs(d[1]), b: this.Runs(d[2])})
        this.built := true
    }

    ; row strings -> [{x, y, w}] horizontal runs, in sprite-pixel units
    static Runs(rows) {
        out := []
        for ri, row in rows {
            x := 0, run := 0
            Loop StrLen(row) {
                if (SubStr(row, A_Index, 1) = "X") {
                    if (run = 0)
                        x := A_Index - 1
                    run++
                } else if (run) {
                    out.Push({x: x, y: ri - 1, w: run}), run := 0
                }
            }
            if (run)
                out.Push({x: x, y: ri - 1, w: run})
        }
        return out
    }

    ; --- how far the chassis reaches past the word box, in px ---
    static PadT() => Sprite.HeadH * Cfg.PixelSize
    static PadX() => 3 * Cfg.PixelSize
    static PadB() => 3 * Cfg.PixelSize

    ; Draws everything except the box and the text: head above, shoulder yoke
    ; across the top, legs down both flanks, feet underneath.  af is the
    ; animation beat (0/1) -- limbs extend on one and tuck on the other.
    static Draw(cv, x, y, bw, bh, type, af, body, head) {
        p := Cfg.PixelSize
        hd := Sprite.Heads[type]

        ; head, centered above the box
        cv.Sprite(x + (bw - Sprite.HeadW * p) / 2, y - Sprite.HeadH * p
                , af ? hd.b : hd.a, p, head)

        ; shoulder yoke -- ties the head to the body and squares off the flanks
        cv.Rect(x - 2 * p, y, bw + 4 * p, p, body)

        ; legs: long and planted on the beat, short and splayed on the off-beat
        legY := y + p
        legH := bh + (af ? 2 * p : 0)
        cv.Rect(x - 2 * p, legY, 2 * p, legH, body)
        cv.Rect(x + bw,    legY, 2 * p, legH, body)

        ; knees / claws kick outward at whichever end the leg is anchored
        ky := af ? legY + legH - p : legY
        cv.Rect(x - 3 * p, ky, p, p, body)
        cv.Rect(x + bw + 2 * p, ky, p, p, body)

        ; feet under the belly
        Loop 3 {
            fx := x + bw * A_Index / 4 - p / 2
            if af
                cv.Rect(fx, y + bh, p, 2 * p, body)
            else
                cv.Rect(fx + (A_Index = 2 ? 0 : (A_Index = 1 ? -p : p)), y + bh + p, p, p, body)
        }
    }
}

; =============================================================================
;  TI -- the game
; =============================================================================
class TI {
    static gui := 0, cv := 0, ih := 0, hooked := false
    static state := "menu"            ; menu | play | pause | over
    static enemies := [], parts := [], lasers := [], stars := []
    static words := [], pool := [], source := ""
    static buffer := "", frame := 0
    static score := 0, best := 0, wave := 0, lives := 0
    static combo := 0, bestCombo := 0
    static typed := 0, hits := 0
    static queue := [], spawnT := 0, banner := "", bannerT := 0
    static shake := 0, flashT := 0
    static speedMul := 1.0, speedT := 0
    static hintOn := false, hintFrames := 0, hintDebt := 0.0, hintSpent := 0
    static dropped := 0
    static F := 0                      ; font handles, filled in Start()

    ; -------------------------------------------------------------------------
    static Start() {
        Sprite.Build()
        this.words := this.LoadWords()

        TraySetIcon("shell32.dll", 123)          ; down-arrow -- they're descending

        g := Gui("+Resize -DPIScale", "Typo Invaders")
        g.BackColor := Format("{:06X}", Pal.Bg)
        g.OnEvent("Close", (*) => TI.Quit())
        this.gui := g                            ; before Show -- OnMinMax needs it
        OnMessage(0x0024, ObjBindMethod(this, "OnMinMax"))    ; WM_GETMINMAXINFO
        g.Show("w" Cfg.WinW " h" Cfg.WinH)

        this.cv := Canvas(g.Hwnd, Cfg.WinW, Cfg.WinH)
        this.Relayout(Cfg.WinW, Cfg.WinH)
        g.OnEvent("Size", ObjBindMethod(this, "OnSize"))
        this.F := {
            word:   this.cv.Font("Consolas", 21, true)
          , buf:    this.cv.Font("Consolas", 30, true)
          , hud:    this.cv.Font("Segoe UI", 15, true)
          , small:  this.cv.Font("Segoe UI", 13)
          , hint:   this.cv.Font("Consolas", 14)
          , big:    this.cv.Font("Segoe UI", 44, true)
          , mid:    this.cv.Font("Segoe UI", 24, true)
        }

        this.SeedStars()

        OnMessage(0x0014, (*) => 1)                      ; WM_ERASEBKGND -> no erase
        OnMessage(0x0006, ObjBindMethod(this, "OnActivate"))
        OnExit(ObjBindMethod(this, "OnExitApp"))

        this.MakeHook()
        this.StartHook()
        SetTimer(ObjBindMethod(this, "Tick"), Cfg.FrameMs)
    }

    ; -------------------------------------------------------------------------
    ;  Window sizing
    ; -------------------------------------------------------------------------
    static OnSize(guiObj, minMax, w, h) {
        if (minMax = -1 || !this.cv)          ; minimized
            return
        this.cv.Resize(w, h)
        this.Relayout(w, h)
    }

    ; Rewrites the live geometry values. Everything downstream reads Cfg.*,
    ; so this is the only place that needs to know about the layout.
    static Relayout(w, h) {
        Cfg.WinW := w, Cfg.WinH := h
        Cfg.GroundY := h - Cfg.HudH
        Cfg.LeakY   := Cfg.GroundY - 22

        ; keep invaders inside the new width
        for e in this.enemies {
            if (e.x + e.w + e.padX > w - 8)
                e.x := w - e.w - e.padX - 8
            if (e.x < e.padX + 8)
                e.x := e.padX + 8
            if (e.y + e.h + e.padB > Cfg.LeakY)    ; window got shorter under them
                e.y := Cfg.LeakY - e.h - e.padB - 1
        }
        this.SeedStars()
    }

    static SeedStars() {
        want := Integer(Cfg.WinW * Cfg.GroundY / 7200)      ; density, not count
        want := want < 40 ? 40 : (want > 220 ? 220 : want)
        while (this.stars.Length > want)
            this.stars.Pop()
        while (this.stars.Length < want)
            this.stars.Push({x: 0, y: 0, v: 0, s: 1})
        for s in this.stars {
            if (s.v = 0 || s.x > Cfg.WinW || s.y > Cfg.GroundY)
                s.x := Random(0, Cfg.WinW), s.y := Random(0, Cfg.GroundY)
                , s.v := Random(3, 12) / 100, s.s := Random(1, 2)
        }
    }

    static OnMinMax(wParam, lParam, msg, hwnd) {
        if (!this.gui || hwnd != this.gui.Hwnd)
            return
        NumPut("Int", Cfg.MinW, lParam, 24)     ; MINMAXINFO.ptMinTrackSize.x
        NumPut("Int", Cfg.MinH, lParam, 28)     ; MINMAXINFO.ptMinTrackSize.y
        return 0
    }

    ; -------------------------------------------------------------------------
    ;  Input
    ; -------------------------------------------------------------------------
    static MakeHook() {
        ih := InputHook("I1")            ; I1 = ignore keys sent by AHK itself
        ih.VisibleText := false          ; swallow text keys (protects AC2 hotstrings)
        ih.BackspaceIsUndo := false
        ih.KeyOpt("{Backspace}{Escape}{Enter}{Up}{Down}", "NS")   ; Notify + Suppress
        ih.OnChar := ObjBindMethod(this, "OnChar")
        ih.OnKeyDown := ObjBindMethod(this, "OnKeyDown")
        this.ih := ih
    }

    static StartHook() {
        if !this.hooked
            this.ih.Start(), this.hooked := true
    }

    static StopHook() {
        if this.hooked
            this.ih.Stop(), this.hooked := false
    }

    static OnActivate(wParam, lParam, msg, hwnd) {
        if (hwnd != this.gui.Hwnd)
            return
        if (wParam & 0xFFFF) {
            this.StartHook()
        } else {
            this.StopHook()
            if (this.state = "play")
                this.state := "pause"
        }
    }

    static OnChar(ih, char) {
        if (this.state = "pause") {
            if (char = "q" || char = "Q")
                this.Quit()
            return
        }
        if (this.state != "play")
            return
        if (char = " ") {
            this.buffer := ""
            return
        }
        if !RegExMatch(char, "^[A-Za-z'\-]$")
            return

        this.typed++
        test := this.buffer . StrLower(char)

        ; accept the keystroke only if it still prefixes some live invader
        for e in this.enemies {
            if (SubStr(e.word, 1, StrLen(test)) = test) {
                this.buffer := test
                this.hits++
                this.CheckKill()
                return
            }
        }
        this.flashT := 6                 ; rejected -- brief red pulse, no penalty
    }

    static OnKeyDown(ih, vk, sc) {
        if (vk = 8) {                                  ; Backspace
            if (this.state = "play")
                this.buffer := SubStr(this.buffer, 1, -1)
        } else if (vk = 27) {                          ; Escape
            if (this.state = "play")
                this.state := "pause"
            else if (this.state = "pause")
                this.state := "play"
            else if (this.state = "menu")
                this.Quit()
        } else if (vk = 13) {                          ; Enter
            if (this.state = "menu" || this.state = "over")
                this.NewGame()
            else if (this.state = "pause")
                this.state := "play"
        } else if (vk = 38) {                          ; Up
            this.Nudge(Cfg.InvertSpeedKeys ? 1 : -1)
        } else if (vk = 40) {                          ; Down
            this.Nudge(Cfg.InvertSpeedKeys ? -1 : 1)
        }
    }

    static Nudge(dir) {
        v := Round(this.speedMul + dir * Cfg.SpeedStep, 2)
        this.speedMul := v < Cfg.SpeedMin ? Cfg.SpeedMin : (v > Cfg.SpeedMax ? Cfg.SpeedMax : v)
        this.speedT := 45                              ; highlight the HUD readout
    }

    static CheckKill() {
        idx := 0, lowest := -1
        for i, e in this.enemies {                     ; kill the most urgent match
            if (e.word = this.buffer && e.y > lowest)
                idx := i, lowest := e.y
        }
        if idx
            this.Kill(idx), this.buffer := ""
    }

    ; -------------------------------------------------------------------------
    ;  Game flow
    ; -------------------------------------------------------------------------
    static NewGame() {
        this.score := 0, this.wave := 0, this.lives := Cfg.Lives
        this.combo := 0, this.bestCombo := 0, this.typed := 0, this.hits := 0
        this.hintFrames := 0, this.hintDebt := 0.0, this.hintSpent := 0
        this.enemies := [], this.parts := [], this.lasers := [], this.queue := []
        this.buffer := "", this.state := "play"
        this.NextWave()
    }

    static NextWave() {
        this.wave++
        n := Cfg.WaveSize + (this.wave - 1) * Cfg.WaveGrowth
        n := n > 26 ? 26 : n

        ; early waves favor short words; the window widens as you go
        maxLen := 5 + Integer(this.wave * 1.4)
        cand := []
        for w in this.words
            if (StrLen(w.correct) <= maxLen)
                Loop w.weight                    ; repeat offenders appear more often
                    cand.Push(w)
        if (cand.Length < 12) {
            cand := []
            for w in this.words
                Loop w.weight
                    cand.Push(w)
        }

        this.queue := []
        Loop n
            this.queue.Push(cand[Random(1, cand.Length)])

        this.spawnT := 40
        this.banner := "WAVE " this.wave
        this.bannerT := 80
    }

    static Spawn() {
        w := this.queue.RemoveAt(1)
        f := this.F.word
        m := this.cv.Measure(w.typo, f)

        ; the box is just the body -- the chassis reaches beyond it
        bw := Max(m.w + 26, (Sprite.HeadW + 2) * Cfg.PixelSize)
        bh := m.h + 12
        ty := (bh - m.h) / 2
        padX := Sprite.PadX(), padT := Sprite.PadT(), padB := Sprite.PadB()

        x := 0
        Loop 12 {                        ; try to find a lane that isn't crowded
            x := Random(padX + 8, Cfg.WinW - bw - padX - 8)
            ok := true
            for e in this.enemies
                if (e.y < 110 && Abs((x + bw / 2) - (e.x + e.w / 2)) < (bw + e.w) / 2 + padX * 2 + 10)
                    ok := false
            if ok
                break
        }

        len := StrLen(w.correct)
        spd := Cfg.BaseSpeed + (this.wave - 1) * Cfg.SpeedPerWave
        spd *= 1 - (len - 4 > 0 ? Min(0.40, (len - 4) * 0.05) : 0)   ; long words fall slower

        this.enemies.Push({word: w.correct, typo: w.typo
                         , skel: w.HasOwnProp("skel") ? w.skel : ""
                         , hard: w.HasOwnProp("hard") ? w.hard : false
                         , sp: Random(1, Sprite.Heads.Length)
                         , ty: ty, padX: padX, padT: padT, padB: padB
                         , x: x, y: -(bh + padT), w: bw, h: bh, v: spd})
    }

    static Kill(idx) {
        e := this.enemies[idx]
        cx := e.x + e.w / 2, cy := e.y + e.h / 2

        this.combo++
        if (this.combo > this.bestCombo)
            this.bestCombo := this.combo
        mult := 1 + Min(4, this.combo // 5)
        this.score += 10 * StrLen(e.word) * mult

        this.lasers.Push({x: cx, y: cy, life: 7})
        Loop 18 {
            a := Random(0, 628) / 100, s := Random(80, 420) / 100
            this.parts.Push({x: cx, y: cy
                           , vx: Cos(a) * s, vy: Sin(a) * s - 0.6
                           , life: Random(16, 34)
                           , c: Random(1, 3) = 1 ? 0xFFFFFF : (Random(1, 2) = 1 ? Pal.Spark : Pal.Spark2)})
        }
        this.enemies.RemoveAt(idx)
    }

    static Leak(idx) {
        e := this.enemies[idx]
        this.combo := 0
        this.lives--
        this.flashT := 14
        this.shake := 10
        Loop 26 {
            a := Random(314, 628) / 100, s := Random(60, 380) / 100
            this.parts.Push({x: e.x + e.w / 2, y: Cfg.LeakY - e.padB
                           , vx: Cos(a) * s * 1.6, vy: -Abs(Sin(a) * s)
                           , life: Random(14, 30), c: Pal.Danger})
        }
        this.enemies.RemoveAt(idx)
        if (this.lives <= 0) {
            this.state := "over"
            if (this.score > this.best)
                this.best := this.score
        }
    }

    ; -------------------------------------------------------------------------
    ;  Main loop
    ; -------------------------------------------------------------------------
    static Tick() {
        this.frame++
        if (this.hooked && !WinActive("ahk_id " this.gui.Hwnd))
            this.StopHook()                            ; safety net
        this.Update()
        this.Draw()
    }

    static Update() {
        ; stars drift always
        for s in this.stars {
            s.y += s.v
            if (s.y > Cfg.GroundY)
                s.y := 0, s.x := Random(0, Cfg.WinW)
        }
        if (this.flashT > 0)
            this.flashT--
        if (this.shake > 0)
            this.shake--
        if (this.speedT > 0)
            this.speedT--

        ; particles & lasers decay in every state so explosions finish
        i := this.parts.Length
        while (i >= 1) {
            p := this.parts[i]
            p.x += p.vx, p.y += p.vy, p.vy += 0.055, p.life--
            if (p.life <= 0)
                this.parts.RemoveAt(i)
            i--
        }
        i := this.lasers.Length
        while (i >= 1) {
            if (--this.lasers[i].life <= 0)
                this.lasers.RemoveAt(i)
            i--
        }

        if (this.state != "play")
            return

        ; --- hint key (polled, so it works as a hold rather than a press) ---
        this.hintOn := false
        if (this.hooked
            && GetKeyState(Cfg.HintKey, "P")
            && (Cfg.HintMod = "" || GetKeyState(Cfg.HintMod, "P"))) {
            this.hintOn := true
            this.hintFrames++
            this.hintDebt += Cfg.HintDrain * Cfg.FrameMs / 1000
            while (this.hintDebt >= 1) {
                this.hintDebt -= 1
                if (this.score > 0)
                    this.score--, this.hintSpent++
            }
        }

        if (this.bannerT > 0)
            this.bannerT--

        ; spawning
        if (this.bannerT = 0 && this.queue.Length) {
            cap := Cfg.MaxOnScreen + (this.wave - 1) // 2
            cap := cap > 10 ? 10 : cap
            if (--this.spawnT <= 0 && this.enemies.Length < cap) {
                this.Spawn()
                gap := Cfg.SpawnGap - (this.wave - 1) * 6
                this.spawnT := gap < 34 ? 34 : gap
            }
        }

        ; invaders descend
        i := this.enemies.Length
        while (i >= 1) {
            e := this.enemies[i]
            e.y += e.v * this.speedMul
            if (e.y + e.h + e.padB >= Cfg.LeakY)      ; feet touch down, not the box
                this.Leak(i)
            i--
        }

        ; buffer may have gone stale (its target landed) -- drop invalid chars
        if (this.buffer != "") {
            ok := false
            for e in this.enemies
                if (SubStr(e.word, 1, StrLen(this.buffer)) = this.buffer)
                    ok := true
            if !ok
                this.buffer := ""
        }

        if (!this.queue.Length && !this.enemies.Length && this.state = "play")
            this.NextWave()
    }

    ; -------------------------------------------------------------------------
    ;  Rendering
    ; -------------------------------------------------------------------------
    static Draw() {
        cv := this.cv, F := this.F
        ox := this.shake > 0 ? Random(-3, 3) : 0
        oy := this.shake > 0 ? Random(-2, 2) : 0

        cv.Clear(Pal.Bg)

        ; --- starfield ---
        for s in this.stars
            cv.Rect(s.x, s.y, s.s, s.s, s.s > 1 ? Pal.StarLit : Pal.StarDim)

        ; --- invaders ---
        ; The whole fleet flips animation frames and side-steps together, the
        ; way the original arcade rows did. Unison is what sells it.
        beat := (this.frame // Cfg.AnimFrames) & 1
        fast := (this.frame // Max(1, Cfg.AnimFrames // 2)) & 1
        march := beat ? Cfg.MarchStep : -Cfg.MarchStep

        for e in this.enemies {
            danger := (e.y + e.h + e.padB) / Cfg.LeakY
            locked := (this.buffer != "" && SubStr(e.word, 1, StrLen(this.buffer)) = this.buffer)

            fill := locked ? Pal.LockFill : Pal.EnemyFill
            edge := locked ? Pal.LockEdge : Pal.EnemyEdge
            txt  := locked ? Pal.LockText : Pal.EnemyText
            if (danger > 0.72) {
                t := (danger - 0.72) / 0.28
                edge := Pal.Mix(edge, Pal.Danger, t)
                txt  := Pal.Mix(txt,  Pal.Danger, t)
            }

            af := (locked && Cfg.LockAnimx2) ? fast : beat
            x := e.x + ox + march, y := e.y + oy

            ; chassis first, so the body box sits on top of the shoulder yoke
            Sprite.Draw(cv, x, y, e.w, e.h, e.sp, af, edge, txt)

            cv.Rect(x, y, e.w, e.h, fill)
            cv.Frame(x, y, e.w, e.h, edge, locked ? 2 : 1)

            ; corner brackets -- carapace plating, and a reticle when locked
            bl := 7, bt := 2
            for c in [[x, y, 1, 1], [x + e.w, y, -1, 1]
                    , [x, y + e.h, 1, -1], [x + e.w, y + e.h, -1, -1]] {
                cx0 := c[3] > 0 ? c[1] : c[1] - bl
                cy0 := c[4] > 0 ? c[2] : c[2] - bt
                cv.Rect(cx0, cy0, bl, bt, txt)
                cx0 := c[3] > 0 ? c[1] : c[1] - bt
                cy0 := c[4] > 0 ? c[2] : c[2] - bl
                cv.Rect(cx0, cy0, bt, bl, txt)
            }

            cv.TextC(x + e.w / 2, y + e.ty, e.typo, txt, F.word)

            ; --- answer hinting, cheapest tier that applies ---
            ; hold-hint (paid) > panic reveal (free, nearly landed) > skeleton
            panic := Cfg.PanicReveal && (danger >= Cfg.PanicAt)
            hy := y + e.h + e.padB + 4
            if (this.hintOn)
                cv.TextC(x + e.w / 2, hy, e.word, Pal.LockText, F.hint)
            else if (panic)
                cv.TextC(x + e.w / 2, hy, e.word, Pal.Danger, F.hint)
            else if (e.hard)
                cv.TextC(x + e.w / 2, hy, e.skel, Pal.HudDim, F.hint)
        }

        ; --- lasers ---
        for l in this.lasers {
            a := l.life / 7
            cv.Line(Cfg.WinW / 2, Cfg.GroundY - 18, l.x, l.y, Pal.Mix(Pal.Bg, Pal.Laser, a), 3)
            cv.Line(Cfg.WinW / 2, Cfg.GroundY - 18, l.x, l.y, Pal.Mix(Pal.Bg, 0xFFFFFF, a * 0.9), 1)
        }

        ; --- particles ---
        for p in this.parts {
            sz := p.life > 20 ? 3 : 2
            cv.Rect(p.x, p.y, sz, sz, Pal.Mix(Pal.Bg, p.c, Min(1, p.life / 18)))
        }

        ; --- ground + turret ---
        cv.Rect(0, Cfg.GroundY, Cfg.WinW, 2, Pal.Ground)
        cv.Rect(0, Cfg.GroundY + 2, Cfg.WinW, 1, Pal.Mix(Pal.Bg, Pal.GroundLit, 0.35))
        cx := Cfg.WinW / 2 + ox
        cv.Rect(cx - 26, Cfg.GroundY - 10, 52, 10, Pal.ShipBody)
        cv.Rect(cx - 14, Cfg.GroundY - 17, 28, 8,  Pal.ShipBody)
        cv.Rect(cx - 3,  Cfg.GroundY - 24, 6, 8,   Pal.ShipCore)

        ; --- HUD ---
        this.DrawHud()

        ; --- overlays ---
        if (this.flashT > 0)
            cv.Frame(0, 0, Cfg.WinW, Cfg.GroundY, Pal.Danger, Integer(this.flashT / 2) + 1)

        if (this.bannerT > 0 && this.state = "play")
            cv.TextC(Cfg.WinW / 2, Cfg.GroundY * 0.4, this.banner, Pal.Mix(Pal.Bg, Pal.Score, Min(1, this.bannerT / 30)), F.big)

        switch this.state {
            case "menu":  this.DrawMenu()
            case "pause": this.DrawCenter("PAUSED", "Esc to resume    Q to quit")
            case "over":  this.DrawOver()
        }

        cv.Flip()
    }

    static DrawHud() {
        cv := this.cv, F := this.F, y := Cfg.GroundY + 16

        cv.Text(24, y, "SCORE", Pal.HudDim, F.small)
        cv.Text(24, y + 18, this.score, Pal.Score, F.hud)

        cv.Text(136, y, "WAVE", Pal.HudDim, F.small)
        cv.Text(136, y + 18, this.wave, Pal.HudLit, F.hud)

        cv.Text(218, y, "COMBO", Pal.HudDim, F.small)
        mult := 1 + Min(4, this.combo // 5)
        cv.Text(218, y + 18, this.combo (mult > 1 ? "  x" mult : ""), mult > 1 ? Pal.Score : Pal.HudLit, F.hud)

        acc := this.typed ? Round(this.hits / this.typed * 100) : 100
        cv.Text(348, y, "ACCURACY", Pal.HudDim, F.small)
        cv.Text(348, y + 18, acc "%", Pal.HudLit, F.hud)

        cv.Text(468, y, "SPEED", Pal.HudDim, F.small)
        sc := this.speedT > 0 ? Pal.Score
            : (this.speedMul > 1.001 ? Pal.Danger
            : (this.speedMul < 0.999 ? Pal.EnemyText : Pal.HudLit))
        cv.Text(468, y + 18, Format("{:.1f}x", this.speedMul), sc, F.hud)

        lx := 570
        cv.Text(lx, y, "LIVES", Pal.HudDim, F.small)
        Loop Cfg.Lives
            cv.Rect(lx + (A_Index - 1) * 22, y + 22, 15, 13
                  , A_Index <= this.lives ? Pal.Life : Pal.Panel)

        cv.TextR(Cfg.WinW - 24, y, "BEST", Pal.HudDim, F.small)
        cv.TextR(Cfg.WinW - 24, y + 18, this.best, Pal.HudDim, F.hud)

        ; --- typed buffer box ---
        bx := 24, by := Cfg.GroundY + 68, bw := Cfg.WinW - 48, bh := 50
        cv.Rect(bx, by, bw, bh, Pal.Panel)
        cv.Frame(bx, by, bw, bh, this.flashT > 0 ? Pal.Danger : Pal.EnemyEdge, 1)
        if (this.buffer != "") {
            cv.TextC(Cfg.WinW / 2, by + 8, this.buffer, Pal.Buffer, F.buf)
            m := cv.Measure(this.buffer, F.buf)
            if (Mod(this.frame, 40) < 24)
                cv.Rect(Cfg.WinW / 2 + m.w / 2 + 4, by + 12, 3, 28, Pal.Score)
        } else if (this.state = "play") {
            cv.TextC(Cfg.WinW / 2, by + 15, "type the correct spelling", Pal.HudDim, F.small)
        }
        if (this.hintOn) {
            cv.Text(bx + 12, by + 16, "HINT", Pal.LockText, F.small)
            cv.TextR(bx + bw - 12, by + 16, "-" this.hintSpent, Pal.Danger, F.small)
        }
    }

    static DrawMenu() {
        cv := this.cv, F := this.F, cx := Cfg.WinW / 2, cy := Cfg.GroundY
        cv.TextC(cx, cy * 0.22, "TYPO INVADERS", Pal.Score, F.big)
        cv.TextC(cx, cy * 0.37, "Misspellings are attacking. Type them correctly to destroy them.", Pal.HudLit, F.small)
        cv.TextC(cx, cy * 0.43, "No aiming, no fire button. Your keyboard is the gun.", Pal.HudDim, F.small)
        cv.TextC(cx, cy * 0.56, this.words.Length " misspellings loaded from " this.source
               . (this.dropped ? "   (" this.dropped " too garbled, skipped)" : ""), Pal.EnemyText, F.small)
        cv.TextC(cx, cy * 0.66, "Press ENTER to launch", Pal.Mix(Pal.HudDim, Pal.Buffer, (Sin(this.frame / 12) + 1) / 2), F.mid)
        cv.TextC(cx, cy * 0.78, "Backspace = correct    Space = clear    Up/Down = speed    Esc = pause", Pal.HudDim, F.small)
        cv.TextC(cx, cy * 0.85, "Hold " (Cfg.HintMod ? Cfg.HintMod "+" : "") Cfg.HintKey " to reveal every answer -- it costs score while you hold it", Pal.HudDim, F.small)
    }

    static DrawOver() {
        cv := this.cv, F := this.F, cx := Cfg.WinW / 2, cy := Cfg.GroundY
        cv.TextC(cx, cy * 0.28, "GAME OVER", Pal.Danger, F.big)
        cv.TextC(cx, cy * 0.44, "Score " this.score "   .   Wave " this.wave, Pal.Buffer, F.mid)
        acc := this.typed ? Round(this.hits / this.typed * 100) : 100
        cv.TextC(cx, cy * 0.54, "Best combo " this.bestCombo "   .   Accuracy " acc "%", Pal.HudLit, F.small)
        if (this.hintFrames)
            cv.TextC(cx, cy * 0.60, "Hints held " Round(this.hintFrames * Cfg.FrameMs / 1000, 1) "s   .   cost " this.hintSpent " pts", Pal.HudDim, F.small)
        cv.TextC(cx, cy * 0.72, "ENTER to play again    Esc to quit", Pal.HudDim, F.small)
    }

    static DrawCenter(title, sub) {
        cv := this.cv, F := this.F, cx := Cfg.WinW / 2, cy := Cfg.GroundY
        cv.TextC(cx, cy * 0.36, title, Pal.Buffer, F.big)
        cv.TextC(cx, cy * 0.52, sub, Pal.HudDim, F.small)
    }

    ; -------------------------------------------------------------------------
    ;  Legibility scoring
    ; -------------------------------------------------------------------------
    ; Normalized Levenshtein similarity, 0 (unrecognizable) .. 1 (identical).
    ; A typo you can solve is one that's *close* to its answer; one that shares
    ; almost nothing is a word-part artifact or a wild mistype, and makes an
    ; unfair invader.
    static Sim(a, b) {
        la := StrLen(a), lb := StrLen(b)
        if (la = 0 || lb = 0)
            return 0
        mx := la > lb ? la : lb
        if (Abs(la - lb) / mx > 0.6)                 ; wildly different lengths
            return 0
        ; fast path -- same initial and near-equal length is always legible,
        ; and skips the DP for the large majority of real hotstrings
        if (SubStr(a, 1, 1) = SubStr(b, 1, 1) && Abs(la - lb) <= 2)
            return 0.85

        prev := []
        Loop lb + 1
            prev.Push(A_Index - 1)
        Loop la {
            i := A_Index
            cur := [i]
            Loop lb {
                j := A_Index
                d := prev[j] + ((SubStr(a, i, 1) = SubStr(b, j, 1)) ? 0 : 1)   ; substitute
                if (prev[j + 1] + 1 < d)
                    d := prev[j + 1] + 1                                        ; delete
                if (cur[j] + 1 < d)
                    d := cur[j] + 1                                             ; insert
                cur.Push(d)
            }
            prev := cur
        }
        return 1 - (prev[lb + 1] / mx)
    }

    ; Drops hopeless pairs, flags merely-hard ones, and precomputes the
    ; skeleton hint string ("q·······" for "quantity").
    static Grade(arr) {
        out := [], this.dropped := 0
        for w in arr {
            s := this.Sim(w.typo, w.correct)
            if (s < Cfg.MinSimilarity) {
                this.dropped++
                continue
            }
            w.sim := s
            w.hard := (s < Cfg.HardSimilarity) || (StrLen(w.correct) <= Cfg.ShortIsHard)
            if !w.HasOwnProp("weight")
                w.weight := 1
            sk := SubStr(w.correct, 1, 1)
            Loop StrLen(w.correct) - 1
                sk .= Chr(0x00B7)                    ; middle dot
            w.skel := sk
            out.Push(w)
        }
        return out
    }

    ; -------------------------------------------------------------------------
    ;  Word loading
    ; -------------------------------------------------------------------------
    ; Both parsers feed one collector, so dedup, weighting and normalization
    ; live in exactly one place regardless of which file the pairs came from.
    static LoadWords() {
        bag := Map(), names := []

        order := (Cfg.Source = "both") ? ["mclog", "lib"] : [Cfg.Source]
        for which in order {
            file := (which = "mclog") ? Cfg.MCLogFile : Cfg.LibFile
            path := this.Find(file)
            if (path = "")
                continue
            before := bag.Count
            if (which = "mclog")
                this.ParseMCLog(path, bag)
            else
                this.ParseLib(path, bag)
            if (bag.Count > before) {
                SplitPath(path, &fn)
                names.Push(fn)
            }
        }

        out := []
        for , v in bag
            out.Push(v)
        out := this.Grade(out)

        if (out.Length < 20) {
            this.source := "the built-in list"
            return this.Grade(this.FallbackWords())
        }
        this.source := names.Length ? this.Join(names, " + ") : "?"
        return out
    }

    static Join(arr, sep) {
        s := ""
        for v in arr
            s .= (s = "" ? "" : sep) v
        return s
    }

    ; Resolve a filename against SearchPaths (absolute paths pass straight through)
    static Find(file) {
        if InStr(file, "\") || InStr(file, ":")
            return FileExist(file) ? file : ""
        for dir in Cfg.SearchPaths {
            p := dir "\" file
            if FileExist(p)
                return p
        }
        return ""
    }

    ; Shared gate: normalize, reject unusable pairs, tally repeats.
    static Add(bag, trig, repl) {
        trig := Trim(trig), repl := Trim(repl)
        repl := RegExReplace(repl, "\s+;.*$", "")            ; strip trailing comment
        if RegExMatch(repl, 'f\(\s*"([^"]*)"', &fm)          ; AC2 wrapper: f("the")
            repl := fm[1]
        repl := Trim(repl, ' "')
        trig := Trim(trig, ' "')

        ok := "^[A-Za-z]{" Cfg.MinWordLen ",14}$"
        if !RegExMatch(trig, ok)
            return
        if !RegExMatch(repl, ok)
            return
        if (StrLower(trig) = StrLower(repl))
            return

        key := StrLower(trig)
        if bag.Has(key) {
            ; repeated in the log = you keep making it = show it more often
            if (bag[key].weight < Cfg.MaxWeight)
                bag[key].weight++
            return
        }
        bag[key] := {typo: StrLower(trig), correct: StrLower(repl), weight: 1}
    }

    ; MCLogger format:  2026-04-28 -- ::tesking::testing
    static ParseMCLog(path, bag) {
        try txt := FileRead(path, "UTF-8")
        catch
            return

        cutoff := ""
        if (Cfg.MCLogDays > 0) {
            d := DateAdd(A_Now, -Cfg.MCLogDays, "Days")
            cutoff := FormatTime(d, "yyyy-MM-dd")
        }

        Loop Parse txt, "`n", "`r" {
            line := Trim(A_LoopField)
            if (line = "" || SubStr(line, 1, 1) = ";")
                continue
            if !RegExMatch(line, "^(\d{4}-\d{2}-\d{2}).*?::([^:]+)::(.*)$", &m)
                continue
            if (cutoff != "" && m[1] < cutoff)               ; ISO dates sort as strings
                continue
            this.Add(bag, m[2], m[3])
        }
    }

    ; Hotstring library format:  :B0X:tesking::f("testing")
    static ParseLib(path, bag) {
        try txt := FileRead(path, "UTF-8")
        catch
            return

        Loop Parse txt, "`n", "`r" {
            line := Trim(A_LoopField)
            if (line = "" || SubStr(line, 1, 1) = ";")
                continue
            if !RegExMatch(line, "^:([^:]*):([^:]+)::(.*)$", &m)
                continue

            ; Whole-word entries only.  * (no end char needed) and ? (fires
            ; inside another word) both mark word-part triggers like
            ; ":*:ationna::ationally" -- fragments, not words.
            if (Cfg.WholeWordOnly && (InStr(m[1], "*") || InStr(m[1], "?")))
                continue

            this.Add(bag, m[2], m[3])
        }
    }

    static FallbackWords() {
        list := "
        (
        teh=the, adn=and, taht=that, thier=their, recieve=receive, seperate=separate,
        definately=definitely, occured=occurred, untill=until, becuase=because,
        wich=which, freind=friend, beleive=believe, calender=calendar, cemetary=cemetery,
        comming=coming, commited=committed, concious=conscious, dilemna=dilemma,
        dissapear=disappear, embarass=embarrass, enviroment=environment,
        existance=existence, familar=familiar, finaly=finally, foriegn=foreign,
        goverment=government, grammer=grammar, gaurd=guard, harrass=harass,
        immediatly=immediately, independant=independent, intresting=interesting,
        knowlege=knowledge, liason=liaison, libary=library, millenium=millennium,
        neccessary=necessary, noticable=noticeable, occassion=occasion,
        paralell=parallel, particulary=particularly, personel=personnel,
        possesion=possession, prefered=preferred, priviledge=privilege,
        probaly=probably, publically=publicly, refered=referred, relevent=relevant,
        religous=religious, remeber=remember, rythm=rhythm, sieze=seize,
        similiar=similar, sincerly=sincerely, succesful=successful,
        supercede=supersede, suprise=surprise, tommorow=tomorrow, truely=truly,
        unfortunatly=unfortunately, vaccum=vacuum, wierd=weird, writting=writing,
        acheive=achieve, accross=across, agressive=aggressive, apparant=apparent,
        arguement=argument, athiest=atheist, basicly=basically, begining=beginning,
        bizzare=bizarre, buisness=business, catagory=category, cieling=ceiling,
        completly=completely, decieve=deceive, diffrent=different,
        dissapoint=disappoint, equiptment=equipment, experiance=experience,
        extreamly=extremely, feild=field, fourty=forty, greatful=grateful,
        happend=happened, heigth=height, hierachy=hierarchy, humourous=humorous,
        ignorence=ignorance, occurence=occurrence, pharoah=pharaoh, potatoe=potato,
        recomend=recommend, refering=referring, restaraunt=restaurant,
        rediculous=ridiculous, secratary=secretary, sence=sense, speach=speech,
        strenght=strength, tounge=tongue, twelth=twelfth, wether=whether,
        wonderfull=wonderful, yeild=yield
        )"

        out := []
        flat := StrReplace(StrReplace(list, "`n", " "), "`r", " ")
        Loop Parse flat, ",", " `t" {
            pair := StrSplit(Trim(A_LoopField), "=")
            if (pair.Length = 2 && pair[1] != "" && pair[2] != "")
                out.Push({typo: StrLower(Trim(pair[1])), correct: StrLower(Trim(pair[2]))})
        }
        return out
    }

    ; -------------------------------------------------------------------------
    static OnExitApp(*) {
        this.StopHook()
        try this.cv.Free()
    }

    static Quit() {
        this.StopHook()
        ExitApp()
    }
}
