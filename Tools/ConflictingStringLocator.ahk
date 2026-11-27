;===============================================================================
; CONFLICTING STRING LOCATOR
;                    a.k.a. DEAD STRING FINDER
; Author: kunkel321
; Tool used: Claude AI
; Updated: 11-27-2026
;===============================================================================
; Part of the AutoCorrect2 Suite of Tools.  Get new versions from
; github.com/kunkel321/autocorrect2
; The Dead String Finder expects to find acSettings.ini, but your hotstrings don't
; have to be wrapped in f() functions.
;
; Workflow:  Options window -> Run Scan -> Review window.  In the Review window,
; look over each finding, set its action (Delete / Move to no-sort / No action),
; tick the rows you approve, then press "Apply checked".  Each changed library is
; backed up to ..\Debug\Backups before it is rewritten.
;===============================================================================

#SingleInstance
#Requires AutoHotkey v2+
#Include "..\Includes\DpiKeepSize.ahk"   ; keeps its windows their size across monitors with different scales

^Esc::ExitApp ; Emergency kill switch

settingsFile := "..\Data\acSettings.ini"
if !FileExist(settingsFile) {
	MsgBox(settingsFile " was not found. Please run AutoCorrect2 first.")
	ExitApp
}

Title := "Conflicting String Locator"
IniSec := "ConflictingStringLocator"
; Command for opening a library at a line.  {file} and {line} get filled in.
EditorCmd := IniRead(settingsFile, IniSec, "EditorCmd", 'code -g "{file}:{line}"')
SystemFile := "..\Core\AutoCorrectSystem.ahk"   ; read only to learn the #Hotstring Z state before the libraries
BackupDir := "..\Debug\Backups"

; Libraries in the order AutoCorrect2 #Includes them
Libraries := [
	{tag: "BP", name: "PersonalHotstrings.ahk", path: "..\Core\PersonalHotstrings.ahk"},
	{tag: "AC", name: "", path: "..\Core\" IniRead(settingsFile, "Files", "HotstringLibrary", "..\Core\AutoCorrectHotstrings.ahk")},
	{tag: "DI", name: "DiacriticHotstrings.ahk", path: "..\Includes\DiacriticHotstrings.ahk"}
]
SplitPath(Libraries[2].path, &acFileName)
Libraries[2].name := acFileName

Items := [], Findings := [], LibInfo := Map()
NeedRescan := false, RevGui := 0, ScanSummary := "", Populating := false
Separator := "`n---------------------------------------`n"
hsRegex := "i):(?P<Opts>[^:]+)*:(?P<Trig>[^:]+)"
EndChars := "-()[]{}':;`"/\,.?!`n`s`t"   ; AHK's default hotstring end characters

KindName := Map("Dup", "Duplicate", "Order", "Wrong order", "Dead", "Never fires", "Redundant", "Redundant")
ActionName := Map("Delete", "Delete", "Move", "Move to no-sort", "None", "-")
FilterNames := ["All", "Duplicates", "Wrong order", "Never fire", "Redundant", "Checked rows"]
FilterKinds := Map("All", "", "Duplicates", "Dup", "Wrong order", "Order", "Never fire", "Dead", "Redundant", "Redundant", "Checked rows", "*checked")

BuildOptionsGui()
OptGui.Show()
return

;===============================================================================
; SMALL HELPERS
;===============================================================================

; A hotstring is case-sensitive if its options contain "C" (but not "C0" or "C1",
; which are both case-INsensitive).  A pair is only compared case-sensitively when
; BOTH items have C.  If only one has C, the non-C item still matches every casing,
; so the pair remains a genuine conflict and is compared case-insensitively.
IsCaseSensitive(opts) => RegExMatch(opts, "i)C(?![01])") ? true : false
TrigEq(a, b, cs) => cs ? (a == b) : (a = b)
IsEndChar(ch) => (ch != "") && InStr(EndChars, ch, true)
Loc(item) => item.lib " " item.index
Dpi(n) => Round(n * A_ScreenDPI / 96)

; One report line for an item
FormatItem(prefix, d) => prefix Loc(d) "`t" StrReplace(StrReplace(d.opts, "B0", ""), "X", "") "`t" d.trig (StrLen(d.trig) < 8 ? "`t`t" : "`t") d.line "`n"

; A hotstring line with nothing after "::" (a stacked or blocker line)
IsEmptyActionHotstring(raw) => RegExMatch(Trim(raw, " `t`r"), "^:[^:]*:[^:]+::(\s+;.*)?$") ? true : false

GetFullPath(p) {
	loop files p
		return A_LoopFileFullPath
	return p
}

FileHasBom(path) {
	buf := FileRead(path, "RAW m3")
	return (buf.Size >= 3) && (NumGet(buf, 0, "UChar") = 0xEF) && (NumGet(buf, 1, "UChar") = 0xBB) && (NumGet(buf, 2, "UChar") = 0xBF)
}

JoinLines(arr) {
	out := ""
	for i, raw in arr
		out .= (i > 1 ? "`n" : "") raw
	return out
}

; Works out what an item leaves on screen when it fires.
; Returns false if that can't be told (for example, an X item that calls something other than f()).
GetReplacement(opts, trig, rest, &repl) {
	repl := ""
	if InStr(opts, "X") {
		if RegExMatch(rest, '^\s*f\("((?:[^"``]|``.)*)"\)', &m) {
			repl := m[1]
			return true
		}
		return false
	}
	r := Trim(RegExReplace(rest, "\s+;.*$"), " `t")
	if (r != "") {
		repl := r
		return true
	}
	if RegExMatch(opts, "i)B0") {   ; protective "blocker" item: leaves the typed word as it is
		repl := trig
		return true
	}
	return false
}

;===============================================================================
; READING THE LIBRARIES
;===============================================================================

; Tracks "#Hotstring Z" / "#Hotstring Z0".  With Z on, the recognizer is reset after
; a hotstring fires, so a longer trigger that was being typed can't complete.
ApplyHotstringDirective(t, zOn) {
	if !RegExMatch(t, "i)^#Hotstring\s+(.*)$", &m)
		return zOn
	opts := Trim(RegExReplace(m[1], "\s+;.*$"))
	if RegExMatch(opts, "i)^(EndChars|NoMouse)")
		return zOn
	if RegExMatch(opts, "i)Z(0?)", &zm)
		return (zm[1] != "0")
	return zOn
}

; The Z state in effect before the first library is included
InitialZState() {
	z := false   ; AHK's default: no reset after a hotstring fires
	if !FileExist(SystemFile)
		return z
	for raw in StrSplit(FileRead(SystemFile, "UTF-8"), "`n") {
		t := Trim(raw, " `t`r")
		if RegExMatch(t, "i)^#Include\b") {
			for lib in Libraries {
				if InStr(t, lib.name)
					return z
			}
			continue
		}
		z := ApplyHotstringDirective(t, z)
	}
	return z
}

; Finds the ACitemsStartAt / ACitemsEndAt / NoSortItemsEndAt marker lines.
; insertAt is where moved items go: just below the last code line above the NoSortItemsEndAt marker.
FindMarkers(lines) {
	mk := {startAt: 1, endAt: lines.Length, noSortEnd: 0, insertAt: 0}
	for n, raw in lines {
		if !RegExMatch(raw, "i)^\s*(ACitemsStartAt|ACitemsEndAt|NoSortItemsEndAt)\s*:=\s*A_LineNumber\s*(?:([+-])\s*(\d+))?", &mm)
			continue
		off := (mm[2] = "") ? 0 : ((mm[2] = "-") ? -Integer(mm[3]) : Integer(mm[3]))
		switch mm[1], false {
			case "ACitemsStartAt":
				mk.startAt := n + off
			case "ACitemsEndAt":
				mk.endAt := n + off
			case "NoSortItemsEndAt":
				mk.noSortEnd := n + off
				k := n - 1
				while (k > 0) && RegExMatch(lines[k], "^\s*(;.*)?\r?$")
					k--
				mk.insertAt := k + 1
		}
	}
	return mk
}

ParseItem(line, n, tag, libOrder, zOn, marks) {
	if !RegExMatch(line, hsRegex, &match)
		return 0
	opts := match.Opts, trig := match.Trig
	afterTrig := match.Pos("Trig") + match.Len("Trig")
	if (SubStr(line, afterTrig, 2) != "::")
		return 0
	rest := SubStr(line, afterTrig + 2)
	hasRepl := GetReplacement(opts, trig, rest, &repl)
	emptyAction := (Trim(RegExReplace(rest, "\s+;.*$"), " `t") = "")
	reset := RegExMatch(opts, "i)Z(0?)", &zm) ? (zm[1] != "0") : zOn
	item := {
		opts: opts,
		trig: trig,
		cs: IsCaseSensitive(opts),
		star: InStr(opts, "*") ? true : false,
		q: InStr(opts, "?") ? true : false,
		repl: repl,
		hasRepl: hasRepl,
		blocker: (!InStr(opts, "X") && RegExMatch(opts, "i)B0") && emptyAction) ? true : false,
		reset: reset ? true : false,
		line: line,
		index: n,
		lib: tag,
		ord: libOrder * 1000000 + n,
		inNoSort: (marks.noSortEnd && (n < marks.noSortEnd)) ? true : false
	}
	return item
}

;===============================================================================
; PAIR ANALYSIS
;===============================================================================

; Checks whether item A (whose trigger is found inside B's trigger) stops item B from working.
; It works out which item fires first while B's trigger is being typed:
;   - An item with * fires on the last letter of its trigger.
;   - An item without * fires on the end character typed after its trigger.
;   - An item without ? only matches at the start of a word (after an end character).
;   - When both fire on the same keystroke, the one loaded first wins.
; If A fires first (or wins the tie), B never fires.  B is also redundant when letting A
; fire gives the same final text:  B's replacement = (B's text before A) A's replacement (B's text after A).
; Returns 0 when the pair is fine, otherwise [kind, message, A, B].
AnalyzePair(A, B, cs) {
	lenA := StrLen(A.trig), lenB := StrLen(B.trig)
	if (lenA > lenB)
		return 0
	sameTrig := (lenA = lenB)
	if sameTrig && A.blocker
		return 0                             ; a blocker for its own word is intentional

	best := 0, bestPos := 0, startAt := 1
	while (pos := InStr(B.trig, A.trig, cs, startAt)) {
		startAt := pos + 1
		if !A.q && (pos > 1) && !IsEndChar(SubStr(B.trig, pos - 1, 1))
			continue                         ; A needs a word start here
		endPos := pos + lenA - 1
		if A.star
			fireAt := endPos
		else if (endPos = lenB)
			fireAt := lenB + 1               ; the end char typed after B's trigger
		else if IsEndChar(SubStr(B.trig, endPos + 1, 1))
			fireAt := endPos + 1
		else
			continue                         ; A would wait for an end char that never comes
		if !best || (fireAt < best)
			best := fireAt, bestPos := pos
	}
	if !best
		return 0
	fireB := B.star ? lenB : lenB + 1
	if (best > fireB)
		return 0                             ; B fires first, so A never gets in its way
	sameKey := (best = fireB)
	if sameKey && sameTrig && (A.ord > B.ord)
		return 0                             ; the reverse comparison reports this pair

	; Partial overlap: B still works in some situations where A doesn't match
	midWord := !A.q && B.q
	caseOnly := A.cs && !B.cs
	partial := midWord || caseOnly
	note := partial ? " (Only partly: " Loc(B) " still works " (midWord ? "in the middle of words" : "for other capitalizations") ".)" : ""

	; Without a Z reset, A firing early doesn't stop B from completing later
	if !sameKey && !A.reset {
		if A.blocker
			return 0                         ; the blocker changed nothing, so B still works
		return ["Dead", Loc(A) " fires partway through " Loc(B) ", and since it has no Z reset, " Loc(B) " then fires on the changed text." note, A, B]
	}

	prefixB := SubStr(B.trig, 1, bestPos - 1)
	suffixB := SubStr(B.trig, bestPos + lenA)
	if !partial && A.hasRepl && B.hasRepl && (B.repl == prefixB A.repl suffixB)
		return ["Redundant", Loc(B) " is redundant. " Loc(A) " already gives the same result, so " Loc(B) " can be deleted.", A, B]
	if sameKey && (A.ord > B.ord)
		return 0                             ; longer item loads first, so both work
	if sameKey && !sameTrig {
		fix := (A.lib != B.lib) ? " (" A.lib " loads before " B.lib ", so this needs a manual fix.)" : " Move " Loc(B) " above it (into the no-sort section)."
		return ["Order", Loc(B) " is blocked because " Loc(A) " is above it." fix note, A, B]
	}
	if sameTrig
		return ["Dead", Loc(B) " can never fire. " Loc(A) " has the same trigger and fires first." note, A, B]
	return ["Dead", Loc(B) " can never fire. " Loc(A) " fires first while it is being typed." note, A, B]
}

CanMove(a, b) => (a.lib = "AC") && (b.lib = "AC") && LibInfo.Has("AC") && LibInfo["AC"].marks.insertAt && !b.blocker

AddFinding(kind, a, b, msg) {
	if !ChkSec[kind].Value
		return
	if (kind = "Dup") || (kind = "Redundant")
		action := "Delete"
	else if (kind = "Order") && CanMove(a, b)
		action := "Move"
	else
		action := "None"
	Findings.Push({kind: kind, a: a, b: b, msg: msg, action: action, checked: false, done: false})
}

;===============================================================================
; THE SCAN
;===============================================================================

RunScan() {
	global Items, Findings, LibInfo, ScanSummary
	Items := [], Findings := [], LibInfo := Map()
	startTime := A_TickCount
	zOn := InitialZState()
	scannedTags := ""

	; ----- Read every library in include order (unchecked ones still count for #Hotstring Z) -----
	libOrder := 0
	for lib in Libraries {
		libOrder++
		if !FileExist(lib.path)
			continue
		lines := StrSplit(FileRead(lib.path, "UTF-8"), "`n")
		marks := (lib.tag = "AC") ? FindMarkers(lines) : {startAt: 1, endAt: lines.Length, noSortEnd: 0, insertAt: 0}
		LibInfo[lib.tag] := {path: lib.path, name: lib.name, marks: marks}
		scanThis := lib.cb.Value
		if scanThis
			scannedTags .= (scannedTags = "" ? "" : ", ") lib.tag
		OptStatus.Value := "Reading " lib.name "..."
		for n, raw in lines {
			line := RTrim(raw, "`r")
			t := LTrim(line, " `t")
			if (SubStr(t, 1, 1) = "#") {
				zOn := ApplyHotstringDirective(t, zOn)
				continue
			}
			if !scanThis || (n < marks.startAt) || (n > marks.endAt) || (SubStr(t, 1, 1) != ":")
				continue
			item := ParseItem(line, n, lib.tag, libOrder, zOn, marks)
			if IsObject(item)
				Items.Push(item)
		}
	}

	; ----- Compare each pair once (upper triangle) -----
	itemCount := Items.Length
	total := itemCount * (itemCount - 1) / 2
	OptStatus.Value := "Comparing " itemCount " hotstrings...  (hold Esc to stop)"
	loop itemCount {
		oIdx := A_Index
		if (Mod(oIdx, 25) = 0) {
			if GetKeyState("Esc", "P")
				return false
			done := oIdx * itemCount - (oIdx * (oIdx + 1)) / 2
			OptProgress.Value := total ? Round(done / total * 100) : 100
			Sleep(-1)
		}
		oData := Items[oIdx]
		loop itemCount - oIdx {
			iData := Items[oIdx + A_Index]

			; Compare case-sensitively only when both hotstrings use the C option
			cs := oData.cs && iData.cs
			sameTrig := TrigEq(oData.trig, iData.trig, cs)

			; Check 1: Exact duplicates
			if sameTrig && (oData.opts = iData.opts) {
				AddFinding("Dup", oData, iData, Loc(iData) " has the same trigger and options as " Loc(oData) ".")
				continue
			}
			; Check 2: Same trigger with word-beginning + word-ending (these can coexist)
			if sameTrig && ((iData.star && oData.q) || (iData.q && oData.star))
				continue

			; Check 3: One trigger inside the other -- which one fires first, and is the longer one needed?
			if (StrLen(oData.trig) <= StrLen(iData.trig)) && InStr(iData.trig, oData.trig, cs)
				r := AnalyzePair(oData, iData, cs)
			else if InStr(oData.trig, iData.trig, cs)
				r := AnalyzePair(iData, oData, cs)
			else
				continue
			if !IsObject(r) && sameTrig
				r := AnalyzePair(iData, oData, cs)
			if IsObject(r)
				AddFinding(r[1], r[3], r[4], r[2])
		}
	}
	OptProgress.Value := 100

	secs := (A_TickCount - startTime) / 1000
	ScanSummary := "Scanned " itemCount " hotstrings (" scannedTags ").  Found " Findings.Length " item pairs in " Floor(secs / 60) "-min " Round(Mod(secs, 60)) "-sec."
	SoundBeep 1800, 300
	return true
}

;===============================================================================
; OPTIONS WINDOW
;===============================================================================

BuildOptionsGui() {
	global OptGui, ChkSec, ChkSaveTxt, OptStatus, OptProgress, BtnRun
	OptGui := Gui("-MinimizeBox", Title)
	DpiKeepSize.Watch(OptGui)   ; keep its size across monitors with different scales
	OptGui.SetFont("s10", "Segoe UI")
	OptGui.OnEvent("Close", (*) => ExitApp())

	y := 8
	OptGui.Add("GroupBox", "x10 y" y " w460 h" (30 + 24 * Libraries.Length), "Libraries to scan (in include order)")
	y += 26
	for lib in Libraries {
		exists := FileExist(lib.path)
		lib.cb := OptGui.Add("CheckBox", "x24 y" y " w436" (exists ? "" : " Disabled"), lib.tag "     " lib.name (exists ? "" : "   (not found)"))
		lib.cb.Value := exists ? Integer(IniRead(settingsFile, IniSec, "Lib" lib.tag, 1)) : 0
		y += 24
	}
	y += 16

	secs := [["Dup", "Duplicates (same trigger and options)"]
		, ["Order", "Wrong order (the longer item must be above the shorter one)"]
		, ["Dead", "Never fire (the shorter item always fires first)"]
		, ["Redundant", "Redundant (the shorter item already gives the same result)"]]
	OptGui.Add("GroupBox", "x10 y" y " w460 h" (30 + 24 * secs.Length), "Report sections")
	y += 26
	ChkSec := Map()
	for s in secs {
		ChkSec[s[1]] := OptGui.Add("CheckBox", "x24 y" y " w436", s[2])
		ChkSec[s[1]].Value := Integer(IniRead(settingsFile, IniSec, "Show" s[1], 1))
		y += 24
	}
	y += 16

	OptGui.Add("GroupBox", "x10 y" y " w460 h56", "Output")
	ChkSaveTxt := OptGui.Add("CheckBox", "x24 y" (y + 26) " w436", "Also save a text report in the Debug folder")
	ChkSaveTxt.Value := Integer(IniRead(settingsFile, IniSec, "SaveTextReport", 0))
	y += 68

	OptStatus := OptGui.Add("Text", "x10 y" y " w460", "Ready.")
	y += 24
	OptProgress := OptGui.Add("Progress", "x10 y" y " w460 h16 Range0-100", 0)
	y += 30
	BtnRun := OptGui.Add("Button", "x10 y" y " w150 h30 Default", "Run Scan")
	BtnRun.OnEvent("Click", OnRunScan)
	OptGui.Add("Button", "x320 y" y " w150 h30", "Close").OnEvent("Click", (*) => ExitApp())
}

SaveOptions() {
	for lib in Libraries {
		if FileExist(lib.path)
			IniWrite(lib.cb.Value, settingsFile, IniSec, "Lib" lib.tag)
	}
	for kind, cb in ChkSec
		IniWrite(cb.Value, settingsFile, IniSec, "Show" kind)
	IniWrite(ChkSaveTxt.Value, settingsFile, IniSec, "SaveTextReport")
}

OnRunScan(*) {
	global NeedRescan
	anyLib := false
	for lib in Libraries
		anyLib := anyLib || lib.cb.Value
	if !anyLib {
		MsgBox("Please pick at least one library.", Title, "Icon!")
		return
	}
	SaveOptions()
	BtnRun.Enabled := false
	ok := RunScan()
	BtnRun.Enabled := true
	if !ok {
		OptStatus.Value := "Scan stopped."
		OptProgress.Value := 0
		return
	}
	OptStatus.Value := "Ready."
	NeedRescan := false
	if ChkSaveTxt.Value
		SaveTextReport(false)
	OptGui.Hide()
	ShowReview()
}

;===============================================================================
; REVIEW WINDOW
;===============================================================================

BuildReviewGui() {
	global RevGui, LV, DdlFilter, EdDetail, RevSummary, RevStatus, RevButtons
	; -DPIScale: every size below is in real pixels, scaled by Dpi(), so resizing math stays consistent
	RevGui := Gui("+Resize -DPIScale +MinSize" Dpi(820) "x" Dpi(440), Title " - Review")
	DpiKeepSize.Watch(RevGui)   ; keep its size across monitors with different scales
	RevGui.SetFont("s10", "Segoe UI")
	RevGui.OnEvent("Close", (*) => ExitApp())
	RevGui.OnEvent("Size", OnRevSize)

	RevGui.Add("Text", "x" Dpi(10) " y" Dpi(12) " w" Dpi(42), "Show:")
	DdlFilter := RevGui.Add("DropDownList", "x" Dpi(54) " y" Dpi(8) " w" Dpi(150) " Choose1", FilterNames)
	DdlFilter.OnEvent("Change", PopulateLV)
	RevSummary := RevGui.Add("Text", "x" Dpi(220) " y" Dpi(12) " w" Dpi(800), "")

	LV := RevGui.Add("ListView", "x" Dpi(10) " y" Dpi(40) " w" Dpi(1000) " h" Dpi(400) " Checked Grid"
		, ["Type", "Action", "Lib", "Line", "Trigger", "Because of", "Its trigger", "Full line", "#"])
	LV.OnEvent("ItemSelect", OnLVSelect)
	LV.OnEvent("ItemCheck", OnLVCheck)
	LV.OnEvent("DoubleClick", (*) => OpenRowItem("b"))
	LV.OnEvent("ContextMenu", OnLVContext)

	EdDetail := RevGui.Add("Edit", "x" Dpi(10) " y" Dpi(450) " w" Dpi(1000) " h" Dpi(96) " ReadOnly -Wrap +HScroll", "")

	btns := [["Open target", (*) => OpenRowItem("b")]
		, ["Open other", (*) => OpenRowItem("a")]
		, ["Delete", SetAct.Bind("Delete")]
		, ["Move to no-sort", SetAct.Bind("Move")]
		, ["No action", SetAct.Bind("None")]
		, ["Apply checked", ApplyChecked]
		, ["Save report", (*) => SaveTextReport(true)]
		, ["Rescan", OnRescan]]
	RevButtons := []
	for b in btns {
		c := RevGui.Add("Button", "x" Dpi(10) " y" Dpi(560) " w" Dpi(110) " h" Dpi(30), b[1])
		c.OnEvent("Click", b[2])
		RevButtons.Push(c)
	}
	RevStatus := RevGui.Add("Text", "x" Dpi(10) " y" Dpi(600) " w" Dpi(1000), "Tick the rows you approve, set their action, then press Apply checked.  Right-click for more.")
}

OnRevSize(g, minMax, W, H) {
	if (minMax = -1)
		return
	static WM_SETREDRAW := 0x000B
	static RDW_INVALIDATE := 0x0001, RDW_ERASE := 0x0004, RDW_ALLCHILDREN := 0x0080
	m := Dpi(10), gap := Dpi(6), btnH := Dpi(30), stH := Dpi(20), detH := Dpi(96), top := Dpi(40)
	statusY := H - m - stH
	btnY := statusY - gap - btnH
	detY := btnY - Dpi(8) - detH
	lvH := detY - Dpi(8) - top

	DllCall("user32\SendMessageW", "Ptr", g.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)
	RevSummary.Move(Dpi(220), Dpi(12), W - Dpi(230), stH)
	LV.Move(m, top, W - 2 * m, lvH)
	EdDetail.Move(m, detY, W - 2 * m, detH)
	bw := Floor((W - 2 * m - gap * (RevButtons.Length - 1)) / RevButtons.Length)
	x := m
	for c in RevButtons {
		c.Move(x, btnY, bw, btnH)
		x += bw + gap
	}
	RevStatus.Move(m, statusY, W - 2 * m, stH)
	DllCall("user32\SendMessageW", "Ptr", g.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
	DllCall("RedrawWindow", "Ptr", g.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN)
}

ShowReview() {
	static shown := false
	if !RevGui
		BuildReviewGui()
	PopulateLV()
	if !shown {
		RevGui.Show("w" Dpi(1150) " h" Dpi(680))
		shown := true
	} else
		RevGui.Show()
}

PopulateLV(*) {
	global Populating
	Populating := true
	want := FilterKinds[DdlFilter.Text]
	LV.Opt("-Redraw")
	LV.Delete()
	for i, f in Findings {
		if (want = "*checked") {
			if !f.checked
				continue
		} else if (want != "") && (f.kind != want)
			continue
		LV.Add(f.checked ? "Check" : "", KindName[f.kind], f.done ? "Done" : ActionName[f.action]
			, f.b.lib, f.b.index, f.b.trig, Loc(f.a), f.a.trig, f.b.line, i)
	}
	LV.ModifyCol(1, Dpi(95))
	LV.ModifyCol(2, Dpi(115))
	LV.ModifyCol(3, Dpi(40))
	LV.ModifyCol(4, Dpi(55) " Integer")
	LV.ModifyCol(5, Dpi(150))
	LV.ModifyCol(6, Dpi(85))
	LV.ModifyCol(7, Dpi(150))
	LV.ModifyCol(8, Dpi(700))
	LV.ModifyCol(9, "0 Integer")
	LV.Opt("+Redraw")
	Populating := false
	EdDetail.Value := ""
	UpdateSummary()
}

UpdateSummary() {
	counts := Map("Dup", 0, "Order", 0, "Dead", 0, "Redundant", 0), nChecked := 0
	for f in Findings {
		counts[f.kind] += 1
		if f.checked && !f.done
			nChecked++
	}
	txt := "Duplicates " counts["Dup"] "   Wrong order " counts["Order"] "   Never fire " counts["Dead"]
		. "   Redundant " counts["Redundant"] "      Checked: " nChecked
	if !(LibInfo.Has("AC") && LibInfo["AC"].marks.insertAt)
		txt .= "      (NoSortItemsEndAt marker not found, so Move is off)"
	RevSummary.Value := txt
}

RowFinding(row) => Findings[Integer(LV.GetText(row, 9))]

OnLVSelect(ctrl, row, selected) {
	if !selected
		return
	f := RowFinding(row)
	EdDetail.Value := "Target   " Loc(f.b) ":   " f.b.line "`nOther    " Loc(f.a) ":   " f.a.line "`n`n" f.msg
}

OnLVCheck(ctrl, row, checked) {
	if Populating || !IsInteger(LV.GetText(row, 9))
		return
	RowFinding(row).checked := checked ? true : false
	UpdateSummary()
}

OnLVContext(ctrl, item, isRightClick, x, y) {
	mn := Menu()
	mn.Add("Open target in editor", (*) => OpenRowItem("b"))
	mn.Add("Open other item in editor", (*) => OpenRowItem("a"))
	mn.Add()
	mn.Add("Action: Delete", SetAct.Bind("Delete"))
	mn.Add("Action: Move to no-sort", SetAct.Bind("Move"))
	mn.Add("Action: No action", SetAct.Bind("None"))
	mn.Add()
	mn.Add("Check selected rows", CheckRows.Bind("sel", 1))
	mn.Add("Uncheck selected rows", CheckRows.Bind("sel", 0))
	mn.Add("Check all shown rows", CheckRows.Bind("all", 1))
	mn.Add("Uncheck all shown rows", CheckRows.Bind("all", 0))
	mn.Show()
}

CheckRows(scope, val, *) {
	if (scope = "all") {
		loop LV.GetCount()
			SetRowCheck(A_Index, val)
	} else {
		row := 0
		while (row := LV.GetNext(row))
			SetRowCheck(row, val)
	}
	UpdateSummary()
}

SetRowCheck(row, val) {
	LV.Modify(row, val ? "Check" : "-Check")
	RowFinding(row).checked := val ? true : false
}

SetAct(action, *) {
	row := 0, skipped := 0
	while (row := LV.GetNext(row)) {
		f := RowFinding(row)
		if f.done
			continue
		if (action = "Move") && !CanMove(f.a, f.b) {
			skipped++
			continue
		}
		f.action := action
		LV.Modify(row, "Col2", ActionName[action])
	}
	RevStatus.Value := skipped ? skipped " row(s) can't be moved automatically. Move only works for an AC item blocked by another AC item (not a blocker line), and needs the NoSortItemsEndAt marker." : ""
}

OpenRowItem(which) {
	row := LV.GetNext(0, "F")
	if !row
		row := LV.GetNext(0)
	if !row
		return
	if NeedRescan {
		RevStatus.Value := "Line numbers changed after Apply.  Rescan first."
		return
	}
	item := RowFinding(row).%which%
	OpenInEditor(LibInfo[item.lib].path, item.index)
}

OpenInEditor(path, line) {
	cmd := StrReplace(StrReplace(EditorCmd, "{file}", GetFullPath(path)), "{line}", line)
	try Run(A_ComSpec ' /c "' cmd '"', , "Hide")
	catch as e
		MsgBox("Couldn't open the editor with:`n" cmd "`n`n" e.Message, Title, "Icon!")
}

OnRescan(*) {
	RevGui.Hide()
	OptGui.Show()
	OnRunScan()
}

;===============================================================================
; APPLYING CHANGES
;===============================================================================

; Finds an item's line in the current file text.  Uses the scanned line number if the
; text still matches, otherwise looks for the exact line elsewhere (only if it's unique).
LocateLine(lines, item) {
	if (item.index <= lines.Length) && (RTrim(lines[item.index], "`r") == item.line)
		return item.index
	found := 0
	for n, raw in lines {
		if (RTrim(raw, "`r") == item.line) {
			if found
				return 0
			found := n
		}
	}
	return found
}

; A line with nothing after "::" shares the { } block below it.  Don't remove the last one.
SafeToRemove(lines, idx) {
	if !IsEmptyActionHotstring(lines[idx])
		return true
	if ((idx > 1) && IsEmptyActionHotstring(lines[idx - 1])) || ((idx < lines.Length) && IsEmptyActionHotstring(lines[idx + 1]))
		return true
	k := idx + 1
	while (k <= lines.Length) && (Trim(lines[k], " `t`r") = "")
		k++
	return !((k <= lines.Length) && (SubStr(Trim(lines[k], " `t`r"), 1, 1) = "{"))
}

ApplyChecked(*) {
	global NeedRescan
	if NeedRescan {
		MsgBox("The libraries changed since the last scan.  Please Rescan first, so the line numbers are current.", Title, "Icon!")
		return
	}

	; One operation per target line (Delete wins if a line was marked both ways)
	ops := Map()
	for f in Findings {
		if !f.checked || f.done || (f.action = "None")
			continue
		key := f.b.lib ":" f.b.index
		if ops.Has(key) {
			if (f.action = "Delete")
				ops[key].action := "Delete"
			continue
		}
		ops[key] := {item: f.b, action: f.action, anchor: f.a}
	}
	if !ops.Count {
		MsgBox("No checked rows have an action.  Tick some rows and set them to Delete or Move first.", Title, "Iconi")
		return
	}
	nDel := 0, nMove := 0
	for key, op in ops {
		if (op.action = "Delete")
			nDel++
		else
			nMove++
	}
	if MsgBox("Delete " nDel " line(s) and move " nMove " line(s) into the no-sort section?`n`nEach changed library is backed up to " BackupDir " first.", Title, "OKCancel Icon?") != "OK"
		return

	byLib := Map()
	for key, op in ops {
		if !byLib.Has(op.item.lib)
			byLib[op.item.lib] := []
		byLib[op.item.lib].Push(op)
	}

	problems := "", changedFiles := 0, handled := Map()
	stamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
	for tag, list in byLib {
		path := LibInfo[tag].path
		try {
			hasBom := FileHasBom(path)
			lines := StrSplit(FileRead(path, "UTF-8"), "`n")
		} catch as e {
			problems .= "`n" tag ": couldn't read the file (" e.Message ")"
			continue
		}
		marks := FindMarkers(lines)   ; fresh marker position
		removeAt := Map(), insertBefore := Map()
		for op in list {
			idx := LocateLine(lines, op.item)
			if !idx {
				problems .= "`n" Loc(op.item) "  " op.item.trig ":  line not found (was the file edited?)"
				continue
			}
			if !SafeToRemove(lines, idx) {
				problems .= "`n" Loc(op.item) "  " op.item.trig ":  skipped, removing it would leave an empty { } block"
				continue
			}
			if (op.action = "Move") {
				anchor := 0
				if op.anchor.inNoSort && (op.anchor.lib = tag)
					anchor := LocateLine(lines, op.anchor)   ; shorter item is itself in no-sort: go just above it
				if !anchor
					anchor := marks.insertAt
				if !anchor || (anchor > idx) {
					problems .= "`n" Loc(op.item) "  " op.item.trig ":  not moved (no place above it to move it to)"
					continue
				}
				if !insertBefore.Has(anchor)
					insertBefore[anchor] := []
				insertBefore[anchor].Push(lines[idx])
			}
			removeAt[idx] := true
			handled[tag ":" op.item.index] := true
		}
		if !removeAt.Count
			continue

		out := []
		for n, raw in lines {
			if insertBefore.Has(n) {
				for moved in insertBefore[n]
					out.Push(moved)
			}
			if !removeAt.Has(n)
				out.Push(raw)
		}
		try {
			DirCreate(BackupDir)
			SplitPath(path, , , , &nameNoExt)
			FileCopy(path, BackupDir "\" nameNoExt "_" stamp ".ahk", true)
			fh := FileOpen(path, "w", hasBom ? "UTF-8" : "UTF-8-RAW")
			fh.Write(JoinLines(out))
			fh.Close()
			changedFiles++
		} catch as e {
			problems .= "`n" tag ": couldn't write the file (" e.Message ").  Nothing was changed in it."
			for n in removeAt
				handled.Delete(tag ":" n)   ; best effort; the rescan will show what's left
		}
	}

	for f in Findings {
		if f.checked && handled.Has(f.b.lib ":" f.b.index)
			f.done := true
	}
	if changedFiles
		NeedRescan := true
	PopulateLV()

	msg := "Changed " changedFiles " file(s).  Backups are in " BackupDir "."
	if (problems != "")
		msg .= "`n`nSkipped:" problems
	if changedFiles
		msg .= "`n`nReload AutoCorrect2 for the changes to take effect.`n`nRescan now?"
	if changedFiles {
		if MsgBox(msg, Title, "YesNo Iconi") = "Yes"
			OnRescan()
	} else
		MsgBox(msg, Title, "Icon!")
}

;===============================================================================
; TEXT REPORT
;===============================================================================

SaveTextReport(openIt := true, *) {
	heads := [["Dup", "Duplicates:"]
		, ["Order", "Wrong order (the longer item must be above the shorter one):"]
		, ["Dead", "Never fire (blocked no matter the order):"]
		, ["Redundant", "Redundant (the shorter item already gives the same result):"]]
	txt := ScanSummary "`nLine`t`tOpt`tTrigger`t`tFull item`n=================================`n"
	body := ""
	for h in heads {
		part := ""
		for f in Findings {
			if (f.kind != h[1])
				continue
			first := (f.a.ord < f.b.ord) ? f.a : f.b
			second := (f.a.ord < f.b.ord) ? f.b : f.a
			part .= Separator FormatItem("Line: ", first) FormatItem("-and: ", second) "   >> " f.msg "`n"
		}
		if (part != "")
			body .= h[2] part "`n"
	}
	if (body = "")
		body := "No duplicate or conflicting hotstring pairs located.`n"
	location := "..\Debug\Conflict_Report" FormatTime(A_Now, "_MMM_dd_hh_mm") ".txt"
	try {
		fh := FileOpen(location, "w", "UTF-8")
		fh.Write(txt body)
		fh.Close()
	} catch as e {
		MsgBox("Couldn't save the report:`n" e.Message, Title, "Icon!")
		return
	}
	if openIt
		Run(location)
}
