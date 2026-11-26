/*
================================================================
AI Word Lookup Module to be #Include'd in AutoCorrect2.ahk
			github.com/kunkel321/autocorrect2
================================================================

Optional include file for AI (OpenAI) word lookups.
When included, this module hooks into Dictionary.ShowDefinitionGui() and adds
an [Ask AI] button to the WordNet Dictionary dialog.  Delete this file (or
comment out its #Include) and the button simply does not appear.

[Ask AI] opens its own window (the WordNet dialog is left alone):

	Word:     pre-filled with the word from the Dictionary dialog; editable.
	Word 2:   optional, starts empty.  For prompts that compare two words.
	Presets / recent prompts:  a drop-down.  Picking one copies it into the
	          Prompt box, where it can be tweaked before sending.
	Prompt:   free-form.  At send time the token  [word]  is replaced with the
	          Word box and  [word2]  with the Word 2 box, so a saved prompt
	          works for any word(s).  A prompt with neither token is sent
	          exactly as typed.
	Answer:   read-only, below.  The window stays open, so you can change the
	          word or the prompt and ask again.

	Enter in the Word box, or Ctrl+Enter anywhere, sends.  In the Prompt box
	plain Enter adds a line break.

Files (all in ..\Data\):
	PersonalApiKey.ini      [OpenAI] ApiKey= and Model=.  Created if missing.
	WordLookupPrompts.ini   [Saved] presets and [Recent] prompts.  Created on
	                        first use, seeded with a few starter presets.
	                        Recent prompts are stored as TEMPLATES (with the
	                        [word] token), not with the word filled in.

Requires an OpenAI account and prepaid API tokens. See SetupMessage below.

			By: Kunkel321
			Date: 11-17-2026
			Tool Used: Claude
Credit:  Originally based on the app 'ChatGPT-AutoHotkey-Utility' by kdalanon.
https://github.com/kdalanon/ChatGPT-AutoHotkey-Utility
The prompt-library dialog follows SnipAI.ahk from ScreenSnip.
*/

; ══════════════════════════════════════════════════════════════════════════════
; SETTINGS
; ══════════════════════════════════════════════════════════════════════════════

class AiWordCfg {
	; Paths are relative to A_WorkingDir, matching the rest of AC2 (WindowPos
	; etc.).  If AC2 is ever launched with a different working directory (Task
	; Scheduler is the classic offender) these will point at the wrong folder.
	static DataDir     := "..\Data"
	static KeyIni      := "..\Data\PersonalApiKey.ini"
	static PromptsFile := "..\Data\WordLookupPrompts.ini"

	; Used when the INI has no Model= key, which is every INI created before
	; that setting existed -- so old installs keep working with no migration.
	static DefaultModel := "gpt-4o-mini"

	; The placeholders replaced by the Word and Word 2 boxes.  Matched
	; case-insensitively.  Neither is a substring of the other ("[word]" needs
	; its "]" right after "word"), so the two never interfere.
	static Token  := "[word]"
	static Token2 := "[word2]"

	; How many recent prompts to keep.  0 = do not record any.
	static HistoryMax := 15

	; Give up on a request after this many seconds.
	static TimeoutSecs := 60

	static FontSize := "s11"

	; Seeded into [Saved] the first time WordLookupPrompts.ini is created.  The
	; first one is the full prompt the old [Try ChatGPT] button always sent.
	; After that the INI is the authority -- edit presets there or in the dialog.
	; A getter (=>), not a stored value: static initializers run top to bottom,
	; and EvaluatePrompt is declared below this line.
	static StarterPresets => [
		AiWordCfg.EvaluatePrompt,
		'Give a short, plain-English definition of "[word]", with its part of speech.',
		'Is "[word]" a correctly spelled English word?  If not, what word was most likely intended?  Answer in one or two sentences.',
		'Compare "[word]" and "[word2]".  Are both legitimate English words?  Briefly define each, and explain how they differ in meaning and usage.'
	]

	static EvaluatePrompt := "
(
You are an English dictionary assistant evaluating individual words for use in an autocorrection dictionary.

WORD TO EVALUATE: "[word]"

Your primary task is to determine whether the EXACT spelling provided has an independently established meaning in English. Include modern, historical, archaic, dialectal, regional, scientific, and technical vocabulary.

IMPORTANT: Do not silently correct the input or substitute a similar-looking word. Equally important, do not assume an unfamiliar spelling is incorrect merely because it resembles a more familiar word. Judge the exact spelling on its own merits.

Follow this decision process:
1. Determine whether the exact spelling is an attested English word with its own meaning. Include obscure and obsolete words.
2. If not a separate dictionary headword, consider whether it is a legitimate grammatical inflection or accepted spelling variant.
IMPORTANT INFLECTION CHECK: If the exact input is not recognized as a standalone dictionary word, examine whether it is a grammatically valid inflection of another word. Try reversing ordinary English plural, possessive, comparative, superlative, and verb endings to identify possible base words. Validate the resulting base word independently, including obscure, archaic, and technical vocabulary. If the base word is legitimate AND the inflection is grammatically appropriate, classify the input as INFLECTION rather than UNKNOWN or MISSPELLING. Do not require the inflected form to have its own dictionary entry. Do not invent a base word merely to justify an unfamiliar spelling.
3. If the exact spelling is legitimate, provide its definition, even if it closely resembles another, more common word.
4. Only if the exact spelling has no identifiable legitimate English usage should you consider whether it is a misspelling of another word.
5. If you cannot confidently establish either validity or a spelling error, report UNKNOWN. Never invent a definition or assert dictionary recognition without sufficient confidence.

FOR LEGITIMATE WORDS:
Begin with the EXACT input spelling followed by a very concise definition in parentheses, formatted as:
word (brief definition)
Do not change the spelling on this line. Keep the definition approximately 3-12 words.

Then provide:
Status: STANDARD, INFLECTION, VARIANT, or RARE
Part of speech: noun, verb, adjective, etc.
Definition: A clear explanation of the word's meaning.
Etymology: Brief information about its origins, when reliably known.
Usage: Mention if archaic, obsolete, dialectal, regional, or specialized. Omit if not applicable.
For inflections, identify the base word. For variants, identify the preferred American English spelling.

FOR MISSPELLINGS:
Do not provide a definition. Begin with:
MISSPELLING: [input] → [correct spelling]
Briefly explain the spelling error. Do not define the corrected word.

FOR NON-ENGLISH OR UNKNOWN WORDS:
Begin with NON-ENGLISH or UNKNOWN, followed by the exact input and a brief explanation. Do not provide a definition line.

FINAL SELF-CHECK:
Ask: Does the definition I am about to provide actually belong to the EXACT input spelling, or have I mentally substituted another word? If substituted, do not provide that definition.
Also ask: Am I rejecting a legitimate obscure word merely because it resembles a familiar word? If so, preserve the obscure word and its actual meaning.
Never manufacture a meaning to justify an unfamiliar spelling.
)"

	static SetupMessage := "
(
No OpenAI API key is configured yet.

PersonalApiKey.ini is in the AutoCorrect2\Data folder.  To use AI word lookup:
1. Set up an account and get an API key from: https://platform.openai.com/account/api-keys
2. Open the AutoCorrect2\Data\PersonalApiKey.ini file.
3. Paste your API key as the ApiKey value (no quotation marks).
4. Save the INI file, then press Ask again.  No restart is needed.

The same INI file has a Model= key, which sets which OpenAI model gets asked.  The default is a small, inexpensive one.  Current model names are listed at https://platform.openai.com/docs/models -- if you enter one that does not exist, the lookup will tell you so in plain language rather than just failing.

Please note that the OpenAI service is not free.  Also note, kunkel321 (the author of AutoCorrect2.ahk) does not receive any compensation or benefit from your transactions with OpenAI.  Upon testing, word lookups cost a small fraction of a cent each on the default model.  Important:  Your pre-paid tokens expire after one year! (Boooo!) As such, I don't recommend "loading up" your account with tokens.  Just purchase one or two dollars worth every six months, and add a "Budget alert" for when you are about to run out.
)"
}

; Runtime state.  The dialog is a singleton.
class AiWordState {
	static Gui := 0
	static Ctl := 0              ; Map of the dialog's controls
	static Refill := 0           ; closure that rebuilds the drop-down
	static Req := 0              ; in-flight WinHttpRequest, or 0
	static StartTick := 0
	static PendingTemplate := ""
	static PendingModel := ""
}


; ══════════════════════════════════════════════════════════════════════════════
; HOOK INTO THE WORDNET DIALOG
; ══════════════════════════════════════════════════════════════════════════════

; Pushed onto a list (not assigned), so other modules' buttons coexist with this.
Dictionary._PostShowCallbacks.Push(AiWord_OnDefinitionGuiCreated)

; defEdit (the WordNet dialog's definition box) is no longer written to -- the
; answer has its own window now.  The parameter stays because the hook passes it.
AiWord_OnDefinitionGuiCreated(dictGui, word, defEdit) {
	dictGui.AddButton("x+8", "Ask AI").OnEvent("Click", (*) => AiWord_OpenDialog(word))
}


; ══════════════════════════════════════════════════════════════════════════════
; THE DIALOG
; ══════════════════════════════════════════════════════════════════════════════

AiWord_OpenDialog(word) {
	word := Trim(word, " `t`r`n")

	; Singleton: raise the open one and give it the new word.
	if (AiWordState.Gui && WinExist("ahk_id " AiWordState.Gui.Hwnd)) {
		AiWordState.Ctl["word"].Value := word
		WinActivate("ahk_id " AiWordState.Gui.Hwnd)
		AiWord_SelectAll(AiWordState.Ctl["word"])
		return
	}

	; Ctrl+Enter, registered ONCE with a function criterion.  A per-window
	; HotIfWinActive would add a new hotkey variant every time the dialog opens.
	static hotkeyMade := false
	if !hotkeyMade {
		HotIf(AiWord_IsActive)
		Hotkey("^Enter", (*) => AiWord_Ask())
		HotIf()
		hotkeyMade := true
	}

	AiWord_SeedPromptsFile()

	c := Map()
	ui := { entries: [] }        ; parallel to drop-down items, minus the placeholder
	g := Gui("+Resize +MinSize560x480", "AutoCorrect2 — Ask AI")
	AiWordState.Gui := g, AiWordState.Ctl := c
	g.MarginX := 12, g.MarginY := 10
	g.SetFont(AiWordCfg.FontSize, "Segoe UI")
	; Match the user's AC2 color theme.  Config always exists inside AC2; the
	; try is only so a theme oddity can never stop the dialog from opening.
	boxOpt := ""
	try g.BackColor := Config.FormColor
	try g.SetFont(Config.FontColor)
	try boxOpt := " Background" Config.ListColor

	g.AddText("xm", "Word:")
	c["word"]   := g.AddEdit("x+8 yp-3 w200" boxOpt, word)
	g.AddText("x+20 yp+3", "Word 2:")
	c["word2"]  := g.AddEdit("x+8 yp-3 w200" boxOpt)
	g.AddText("xm y+12", "Presets and recent prompts:")
	c["dd"]     := g.AddDropDownList("xm w620")
	c["lblPrompt"] := g.AddText("xm y+10 w620", "Prompt   ( [word] and [word2] = the boxes above.   Ctrl+Enter to ask )")
	c["prompt"] := g.AddEdit("xm w620 r5 +Multi +WantReturn +VScroll" boxOpt)
	c["ask"]    := g.AddButton("xm w90 Default", "Ask")
	c["save"]   := g.AddButton("x+8 w140", "Save as Preset")
	c["del"]    := g.AddButton("x+8 w140", "Delete Selected")
	c["answer"] := g.AddEdit("xm y+12 w620 r10 +Multi +ReadOnly +VScroll" boxOpt)
	c["copy"]   := g.AddButton("xm w120", "Copy Answer")
	c["close"]  := g.AddButton("x+8 w90", "Close")
	c["status"] := g.AddText("x+14 yp+6 w380 cGray", "")

	; Rebuild the drop-down from the file.  Item 1 is a placeholder so that
	; "nothing chosen" is a real, visible state and Delete knows to stay off.
	Refill() {
		store := AiWord_PromptsRead()
		ui.entries := []
		items := ["—  choose a preset or a recent prompt  —"]
		for t in store["Saved"] {
			ui.entries.Push({ sec: "Saved", text: t })
			items.Push("Preset:  " AiWord_OneLine(t))
		}
		for t in store["Recent"] {
			ui.entries.Push({ sec: "Recent", text: t })
			items.Push("Recent:  " AiWord_OneLine(t))
		}
		c["dd"].Delete()
		c["dd"].Add(items)
		c["dd"].Choose(1)
		c["del"].Enabled := false
	}
	AiWordState.Refill := Refill

	OnPick(*) {
		i := c["dd"].Value
		c["del"].Enabled := (i > 1)
		if (i < 2)
			return
		AiWord_SetPrompt(ui.entries[i - 1].text)
		c["prompt"].Focus()
		len := StrLen(c["prompt"].Value)
		SendMessage(0x00B1, len, len, c["prompt"])     ; EM_SETSEL: caret to the end
	}

	OnSave(*) {
		q := AiWord_PromptText()
		if (q = "") {
			AiWord_ToolTip("Nothing to save", 1200)
			return
		}
		r := AiWord_PromptAdd("Saved", q)
		Refill()
		AiWord_ToolTip(r = "exists" ? "Already a preset" : "Saved as preset", 1200)
	}

	OnDel(*) {
		i := c["dd"].Value
		if (i < 2)
			return
		e := ui.entries[i - 1]
		AiWord_PromptRemove(e.sec, e.text)
		Refill()
	}

	OnCopy(*) {
		if (c["answer"].Value = "")
			return
		A_Clipboard := c["answer"].Value
		AiWord_ToolTip("Copied to clipboard", 1200)
	}

	Refill()
	c["dd"].OnEvent("Change", OnPick)
	c["ask"].OnEvent("Click", (*) => AiWord_Ask())
	c["save"].OnEvent("Click", OnSave)
	c["del"].OnEvent("Click", OnDel)
	c["copy"].OnEvent("Click", OnCopy)
	c["close"].OnEvent("Click", AiWord_CloseDialog)
	g.OnEvent("Close", AiWord_CloseDialog)
	g.OnEvent("Escape", AiWord_CloseDialog)
	g.OnEvent("Size", AiWord_OnSize)

	; Start with the prompt used last, else the first preset -- so opening the
	; dialog and pressing Enter repeats the previous kind of lookup.
	store := AiWord_PromptsRead()
	if store["Recent"].Length
		AiWord_SetPrompt(store["Recent"][1])
	else if store["Saved"].Length
		AiWord_SetPrompt(store["Saved"][1])
	else
		AiWord_SetPrompt(AiWordCfg.EvaluatePrompt)

	; Point out a missing key now, rather than after the first click.
	if !AiWord_EnsureKeyIni() || AiWord_GetApiKey() = ""
		c["answer"].Value := AiWordCfg.SetupMessage
	c["status"].Value := "Model: " AiWord_GetModel()

	g.Show()
	; Focus on the Word box with its text selected: Enter asks right away,
	; typing replaces the word.
	AiWord_SelectAll(c["word"])
}

AiWord_IsActive(*) => AiWordState.Gui && WinActive("ahk_id " AiWordState.Gui.Hwnd)

AiWord_CloseDialog(*) {
	SetTimer(AiWord_Poll, 0)
	if AiWordState.Req {
		try AiWordState.Req.Abort()
		AiWordState.Req := 0
	}
	if (g := AiWordState.Gui) {
		AiWordState.Gui := 0, AiWordState.Ctl := 0, AiWordState.Refill := 0
		g.Destroy()
	}
}

; Prompt Edit <-> template text.  The Edit wants CRLF and hands back CRLF;
; everything stored uses LF.
AiWord_PromptText() => Trim(StrReplace(AiWordState.Ctl["prompt"].Value, "`r`n", "`n"), " `t`r`n")
AiWord_SetPrompt(t) => AiWordState.Ctl["prompt"].Value := StrReplace(StrReplace(t, "`r`n", "`n"), "`n", "`r`n")

AiWord_SelectAll(ctl) {
	ctl.Focus()
	SendMessage(0x00B1, 0, -1, ctl)                     ; EM_SETSEL: everything
}

; The answer box grows with the window; the buttons ride the bottom-left.
; Positions are read back from the controls themselves (GetPos), so this is
; correct at any DPI without having to know how AHK scaled the margins.
AiWord_OnSize(g, MinMax, W, H) {
	if (MinMax = -1)
		return
	c := AiWordState.Ctl
	if !c
		return
	c["dd"].GetPos(&mx)                                 ; left margin, in pixels
	cw := W - 2 * mx
	for name in ["dd", "lblPrompt", "prompt"]
		c[name].Move(, , cw)

	c["answer"].GetPos(, &ay)
	c["copy"].GetPos(, , , &bh)
	ansH := H - ay - bh - 2 * mx
	if (ansH < 60)
		ansH := 60
	c["answer"].Move(, , cw, ansH)

	by := ay + ansH + mx
	c["copy"].Move(, by)
	c["close"].Move(, by)
	c["status"].GetPos(&sx)
	c["status"].Move(, by + 6, (W - sx - mx > 50) ? W - sx - mx : 50)
}


; ══════════════════════════════════════════════════════════════════════════════
; ASKING  (asynchronous, so the window keeps painting while it waits)
; ══════════════════════════════════════════════════════════════════════════════

AiWord_Ask() {
	if !AiWordState.Gui || AiWordState.Req          ; closed, or already waiting
		return
	c := AiWordState.Ctl

	word     := Trim(c["word"].Value, " `t`r`n")
	word2    := Trim(c["word2"].Value, " `t`r`n")
	template := AiWord_PromptText()
	if (template = "") {
		AiWord_ToolTip("Type a prompt first", 1200)
		c["prompt"].Focus()
		return
	}
	; StrReplace and InStr are case-insensitive by default, so [Word] and
	; [WORD] count too.
	if (InStr(template, AiWordCfg.Token) && word = "") {
		AiWord_ToolTip("The prompt uses " AiWordCfg.Token " but the Word box is empty", 2000)
		c["word"].Focus()
		return
	}
	if (InStr(template, AiWordCfg.Token2) && word2 = "") {
		AiWord_ToolTip("The prompt uses " AiWordCfg.Token2 " but the Word 2 box is empty", 2000)
		c["word2"].Focus()
		return
	}

	; Read fresh every time, so a key pasted into the INI works without a restart.
	; Trim() because a key pasted from a browser very often carries a trailing
	; space, and that produces a 401 that looks exactly like a wrong key.
	apiKey := AiWord_EnsureKeyIni() ? Trim(AiWord_GetApiKey()) : ""
	if (apiKey = "") {
		c["answer"].Value := AiWordCfg.SetupMessage
		return
	}

	; Either replacement is a no-op when its token is absent.
	prompt := StrReplace(StrReplace(template, AiWordCfg.Token2, word2), AiWordCfg.Token, word)
	model  := AiWord_GetModel()

	; AiWord_EscapeJson renders every non-ASCII character as \uXXXX, so the
	; body is 7-bit clean and WinHttpRequest's string encoding cannot mangle it.
	body := '{"model":"' AiWord_EscapeJson(model) '","messages":[{"role":"user","content":"'
	      . AiWord_EscapeJson(prompt) '"}]}'

	try {
		req := ComObject("WinHttp.WinHttpRequest.5.1")
		req.Open("POST", "https://api.openai.com/v1/chat/completions", true)   ; true = async
		req.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
		req.SetRequestHeader("Authorization", "Bearer " apiKey)
		; Resolve, connect, send, receive (ms).  The overall limit is enforced
		; by AiWord_Poll; this is the backstop.
		req.SetTimeouts(10000, 10000, 30000, AiWordCfg.TimeoutSecs * 1000)
		req.Send(body)
	} catch as err {
		AiWord_ShowFailure("Could not send the request: " err.Message)
		return
	}

	AiWordState.Req := req
	AiWordState.StartTick := A_TickCount
	AiWordState.PendingTemplate := template
	AiWordState.PendingModel := model
	c["ask"].Enabled := false
	c["answer"].Value := "Asking " model "…   (this uses your OpenAI API credits)"
	c["status"].Value := "Waiting…"
	SetTimer(AiWord_Poll, 150)
}

; Checks the in-flight request without blocking.  WaitForResponse(0) returns
; at once: true when the reply is complete, false while still waiting.
AiWord_Poll() {
	req := AiWordState.Req
	if !req {
		SetTimer(AiWord_Poll, 0)
		return
	}
	secs := (A_TickCount - AiWordState.StartTick) // 1000

	try done := req.WaitForResponse(0)
	catch as err {
		AiWord_Finish("", "Network error: " err.Message)
		return
	}

	if !done {
		if (secs >= AiWordCfg.TimeoutSecs) {
			try req.Abort()
			AiWord_Finish("", "No response after " secs " seconds.")
			return
		}
		try AiWordState.Ctl["status"].Value := "Waiting… " secs "s"
		return
	}

	text := AiWord_ReadResponse(req, &errMsg, &usage)
	AiWord_Finish(text, errMsg, usage)
}

AiWord_Finish(text, errMsg, usage := "") {
	SetTimer(AiWord_Poll, 0)
	AiWordState.Req := 0
	if !AiWordState.Gui                                  ; closed while waiting
		return
	c := AiWordState.Ctl
	c["ask"].Enabled := true
	secs := Round((A_TickCount - AiWordState.StartTick) / 1000, 1)

	if (text = "") {
		AiWord_ShowFailure(errMsg)
		c["status"].Value := "Failed after " secs "s"
		return
	}

	c["answer"].Value := Trim(text, " `t`r`n")
	c["status"].Value := AiWordState.PendingModel "  ·  " secs "s"
	                   . (usage != "" ? "  ·  " usage : "")

	; Recorded only on success, so a failed call never lands in the history.
	if AiWord_RecordRecent(AiWordState.PendingTemplate) && AiWordState.Refill
		AiWordState.Refill.Call()
}

AiWord_ShowFailure(errMsg) {
	if !AiWordState.Gui
		return
	AiWordState.Ctl["answer"].Value := "The lookup failed.`n`n"
		. (errMsg != "" ? errMsg "`n`n" : "")
		. "Possible reasons:`n"
		. "• Network error`n"
		. "• Invalid API key`n"
		. "• Model name not recognized (check Model= in PersonalApiKey.ini)`n"
		. "• Out of prepaid credits, or rate limit exceeded"
}

; Response -> the model's text, or "" with errMsg set.  usage gets a short
; token-count string when the API supplies one.
AiWord_ReadResponse(req, &errMsg, &usage) {
	errMsg := "", usage := ""
	try {
		status := req.Status
		responseText := AiWord_ResponseUtf8(req)
	} catch as err {
		errMsg := "Network error: " err.Message
		return ""
	}

	if (status != 200) {
		errMsg := "HTTP " status
		; OpenAI's error blob says far more than the status code does.  This is
		; also what makes the Model= INI setting safe to experiment with: a
		; retired model name comes back as a readable sentence.
		errData := AiWord_JsonParse(responseText)
		if IsObject(errData) && (errData is Map) && errData.Has("error")
		&& IsObject(apiErr := errData["error"]) && (apiErr is Map) && apiErr.Has("message")
			errMsg .= ": " apiErr["message"]
		else if (responseText != "")
			errMsg .= ": " SubStr(responseText, 1, 400)
		return ""
	}

	jsonData := AiWord_JsonParse(responseText)
	if !IsObject(jsonData) || !(jsonData is Map) || !jsonData.Has("choices") {
		errMsg := "The response was not in the expected format."
		return ""
	}
	if jsonData.Has("usage")
		usage := AiWord_FormatUsage(jsonData["usage"])

	choices := jsonData["choices"]
	if !(choices is Array) || (choices.Length = 0) {
		errMsg := "The API returned no choices."
		return ""
	}
	choice := choices[1]
	if !(choice is Map) || !choice.Has("message") || !(choice["message"] is Map) {
		errMsg := "The API returned a choice with no message."
		return ""
	}
	msg := choice["message"]
	content := msg.Has("content") ? msg["content"] : ""
	if (content = "") {
		; A populated "refusal" is the model declining, which is worth naming
		; rather than reporting as an empty result.
		if msg.Has("refusal") && (msg["refusal"] != "")
			errMsg := "The model declined: " msg["refusal"]
		else
			errMsg := "The API returned a choice with no content."
		return ""
	}
	return content
}

; "in 812 / out 164 tokens" -- reasoning tokens are billed as output but are
; otherwise invisible, so they get named when present.
AiWord_FormatUsage(u) {
	if !IsObject(u) || !(u is Map)
		return ""
	inTok  := u.Has("prompt_tokens")     ? u["prompt_tokens"]     : 0
	outTok := u.Has("completion_tokens") ? u["completion_tokens"] : 0
	out := "in " inTok " / out " outTok " tokens"
	if u.Has("completion_tokens_details") && IsObject(d := u["completion_tokens_details"])
	&& (d is Map) && d.Has("reasoning_tokens") && d["reasoning_tokens"]
		out .= " (" d["reasoning_tokens"] " reasoning)"
	return out
}


; ══════════════════════════════════════════════════════════════════════════════
; API KEY / MODEL  (..\Data\PersonalApiKey.ini)
; ══════════════════════════════════════════════════════════════════════════════

; Returns true if the key INI already existed.  Creates it (and the Data
; folder) when missing, and returns false so the caller shows the setup text.
AiWord_EnsureKeyIni() {
	if FileExist(AiWordCfg.KeyIni)
		return true
	try {
		if !DirExist(AiWordCfg.DataDir)
			DirCreate(AiWordCfg.DataDir)
		FileAppend("[OpenAI]`nApiKey=`nModel=" AiWordCfg.DefaultModel "`n", AiWordCfg.KeyIni)
	}
	return false
}

AiWord_GetApiKey() {
	try return IniRead(AiWordCfg.KeyIni, "OpenAI", "ApiKey", "")
	return ""
}

; The model is a setting rather than hardcoded because OpenAI reshuffles its
; lineup faster than this script gets edited.  Read fresh on every request.
AiWord_GetModel() {
	m := ""
	try m := Trim(IniRead(AiWordCfg.KeyIni, "OpenAI", "Model", ""))
	return (m = "") ? AiWordCfg.DefaultModel : m
}


; ══════════════════════════════════════════════════════════════════════════════
; PROMPT LIBRARY  (..\Data\WordLookupPrompts.ini)
; ══════════════════════════════════════════════════════════════════════════════
; Same format as ScreenSnip's SnipAiPrompts.ini.  Two sections, [Saved] and
; [Recent], each a list of  key=text  lines.  Hand-rolled rather than
; IniRead/IniWrite on purpose: IniRead strips enclosing quotes, and the Win32
; INI API is ANSI unless the file is UTF-16, so prompts with quotes or non-ASCII
; text would not survive.  The file is UTF-8, so Notepad shows it correctly.
; Key names are ignored on read (file order is the order) and renumbered on
; write, so a hand-added  x=Define [word]  under [Saved] just works.
; A line break inside a prompt is stored as \n; backslashes are doubled.

; Creates the file with the starter presets, once.
AiWord_SeedPromptsFile() {
	if FileExist(AiWordCfg.PromptsFile)
		return
	try {
		if !DirExist(AiWordCfg.DataDir)
			DirCreate(AiWordCfg.DataDir)
	}
	store := Map("Saved", [], "Recent", [])
	for t in AiWordCfg.StarterPresets
		store["Saved"].Push(t)
	AiWord_PromptsWrite(store)
}

; Whole file -> Map("Saved" => [text, ...], "Recent" => [text, ...]).  A
; missing or unreadable file is simply an empty library.
AiWord_PromptsRead() {
	store := Map()
	store.CaseSense := false
	store["Saved"] := [], store["Recent"] := []

	path := AiWordCfg.PromptsFile
	if !FileExist(path)
		return store
	try txt := FileRead(path, "UTF-8")
	catch
		return store

	sect := ""
	Loop Parse, txt, "`n", "`r" {
		line := Trim(A_LoopField, " `t")
		if (line = "" || SubStr(line, 1, 1) = ";")
			continue
		if RegExMatch(line, "^\[(.+)\]$", &m) {
			sect := m[1]
			continue
		}
		if !store.Has(sect) || !(p := InStr(line, "="))    ; first "=" only
			continue
		val := AiWord_JsonUnescape(SubStr(line, p + 1))
		if (Trim(val, " `t`r`n") != "")
			store[sect].Push(val)
	}
	return store
}

; Write the whole library back, via a temp file and a move so a crash mid-write
; can't leave a half-written library.  Returns true on success.
AiWord_PromptsWrite(store) {
	path := AiWordCfg.PromptsFile
	out := "; AutoCorrect2 AI word lookup prompt library.`n"
	     . "; [Saved] = your presets.  Add lines by hand if you like: one prompt per line, any key name.`n"
	     . "; [Recent] is managed automatically.  [word] is replaced with the word being looked up.`n"
	     . "; A line break inside a prompt is written as \n.  Comments you add here will be lost on the next save.`n"
	for sect in ["Saved", "Recent"] {
		out .= "`n[" sect "]`n"
		for i, t in store[sect]
			out .= i "=" AiWord_PromptEscape(t) "`n"
	}
	tmp := path ".tmp"
	try {
		f := FileOpen(tmp, "w", "UTF-8")
		f.Write(out)
		f.Close()
		FileMove(tmp, path, true)
		return true
	} catch {
		try FileDelete(tmp)
		return false
	}
}

; Backslash FIRST, or the backslashes added for \n would be doubled again.
AiWord_PromptEscape(s) {
	s := StrReplace(s, "\", "\\")
	s := StrReplace(s, "`r`n", "\n")
	s := StrReplace(s, "`n", "\n")
	s := StrReplace(s, "`r", "\n")
	return StrReplace(s, "`t", "\t")
}

; "Recent" goes to the top, de-duplicated, and trimmed to cap (0 = no limit).
; "Saved" is appended, and left alone if already there.
; Returns "exists" for a duplicate preset, true on success, false otherwise.
AiWord_PromptAdd(section, text, cap := 0) {
	text := Trim(text, " `t`r`n")
	if (text = "")
		return false
	store := AiWord_PromptsRead()
	list := store[section]
	if (section = "Recent") {
		for i, t in list {
			if (t == text) {
				list.RemoveAt(i)
				break
			}
		}
		list.InsertAt(1, text)
		while (cap > 0 && list.Length > cap)
			list.Pop()
	} else {
		for t in list {
			if (t == text)
				return "exists"
		}
		list.Push(text)
	}
	return AiWord_PromptsWrite(store)
}

AiWord_PromptRemove(section, text) {
	store := AiWord_PromptsRead()
	list := store[section]
	for i, t in list {
		if (t == text) {
			list.RemoveAt(i)
			return AiWord_PromptsWrite(store)
		}
	}
	return false
}

; Note a successful prompt (the TEMPLATE, token and all) in [Recent], unless
; history is off or it is already a preset.  Returns true if the file changed.
AiWord_RecordRecent(template) {
	if (AiWordCfg.HistoryMax < 1)
		return false
	q := Trim(template, " `t`r`n")
	for t in AiWord_PromptsRead()["Saved"] {
		if (t == q)
			return false
	}
	return AiWord_PromptAdd("Recent", q, AiWordCfg.HistoryMax)
}

; One line, bounded length, for a drop-down item.
AiWord_OneLine(s, maxLen := 90) {
	s := RegExReplace(s, "\s*[\r\n]+\s*", " | ")
	return (StrLen(s) > maxLen) ? (SubStr(s, 1, maxLen - 1) "…") : s
}


; ══════════════════════════════════════════════════════════════════════════════
; HTTP RESPONSE DECODING
; ══════════════════════════════════════════════════════════════════════════════
; WinHttpRequest chooses its decoder from the charset= parameter of the
; Content-Type RESPONSE header.  OpenAI sends "application/json" with no charset
; at all, so .ResponseText falls back to Latin-1 and reads the UTF-8 body one
; byte at a time.  An em dash (E2 80 94) comes back as "a-circumflex" plus
; U+0080 and U+0094 -- INVISIBLE C1 control characters, so the damage does not
; even look like damage until it lands in the clipboard.
;
; The fix is to bypass the header sniffing: take .ResponseBody, the raw byte
; array, and tell StrGet what the encoding actually is.
AiWord_ResponseUtf8(req) {
	try {
		bodyBytes := req.ResponseBody
		pSA := ComObjValue(bodyBytes)      ; VT_ARRAY variant -> SAFEARRAY pointer
		if !pSA
			return ""
		pData := 0
		; Returns 0 (S_OK) on success, and locks the array until Unaccess.
		if DllCall("oleaut32\SafeArrayAccessData", "Ptr", pSA, "Ptr*", &pData)
			return ""
		lo := 0, hi := 0
		DllCall("oleaut32\SafeArrayGetLBound", "Ptr", pSA, "UInt", 1, "Int*", &lo)
		DllCall("oleaut32\SafeArrayGetUBound", "Ptr", pSA, "UInt", 1, "Int*", &hi)
		len := hi - lo + 1
		; Byte count passed explicitly: an HTTP body is not null-terminated.
		str := (len > 0) ? StrGet(pData, len, "UTF-8") : ""
		DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", pSA)
		return str
	} catch {
		; Mangled text still beats an empty string for figuring out what broke.
		try return req.ResponseText
		return ""
	}
}


; ══════════════════════════════════════════════════════════════════════════════
; JSON ESCAPING & PARSING
; ══════════════════════════════════════════════════════════════════════════════

; Every character outside printable ASCII is emitted as \uXXXX, so the request
; body is 7-bit clean.  Control characters below 0x20 are always escaped, as
; the JSON spec requires.
; Parameter is named srcText, NOT inStr -- variable names are case-insensitive
; in v2, so a parameter named inStr would shadow the built-in InStr function.
AiWord_EscapeJson(srcText) {
	out := ""
	Loop Parse, srcText {
		ch := A_LoopField
		code := Ord(ch)
		if (ch == '"')
			out .= '\"'
		else if (ch == "\")
			out .= "\\"
		else if (code >= 0x20 && code <= 0x7E)
			out .= ch                        ; plain printable ASCII
		else if (code = 0x08)
			out .= "\b"
		else if (code = 0x09)
			out .= "\t"
		else if (code = 0x0A)
			out .= "\n"
		else if (code = 0x0C)
			out .= "\f"
		else if (code = 0x0D)
			out .= "\r"
		else if (code > 0xFFFF) {
			; JSON \u escapes are UTF-16 code units, so an astral character
			; (emoji, rare CJK) has to go out as a surrogate PAIR.
			code -= 0x10000
			out .= Format("\u{:04x}\u{:04x}", 0xD800 + (code >> 10), 0xDC00 + (code & 0x3FF))
		}
		else
			out .= Format("\u{:04x}", code)  ; other controls, and all non-ASCII
	}
	return out
}

; Counts the unbroken run of backslashes at the END of a string.  Used by the
; string scanner in JsonParse to decide whether a closing quote was escaped.
AiWord_TrailingBackslashes(txt) {
	count := 0
	i := StrLen(txt)
	while (i >= 1 && SubStr(txt, i, 1) == "\") {
		count++
		i--
	}
	return count
}

; Single left-to-right pass.  Chained StrReplace calls get this wrong: doing
; \\ -> \ first turns the literal text  \\n  into a real newline.
; Also used to decode prompt lines from WordLookupPrompts.ini.
AiWord_JsonUnescape(txt) {
	if !InStr(txt, "\")
		return txt
	out := ""
	i := 1
	n := StrLen(txt)
	while (i <= n) {
		ch := SubStr(txt, i, 1)
		if (ch != "\") {
			out .= ch
			i++
			continue
		}
		esc := SubStr(txt, i + 1, 1)
		switch esc, true {
			case '"':  out .= '"',     i += 2
			case "\":  out .= "\",     i += 2
			case "/":  out .= "/",     i += 2
			case "b":  out .= Chr(8),  i += 2
			case "f":  out .= Chr(12), i += 2
			case "n":  out .= "`n",    i += 2
			case "r":  out .= "`r",    i += 2
			case "t":  out .= "`t",    i += 2
			case "u":
				hex := SubStr(txt, i + 2, 4)
				if (StrLen(hex) = 4 && RegExMatch(hex, "^[0-9A-Fa-f]{4}$")) {
					code := Integer("0x" hex)
					; Chr(0) would embed a NUL, which truncates the string at
					; every Windows API boundary it later crosses.  Drop it.
					if (code != 0)
						out .= Chr(code)
					i += 6
				}
				else {
					; Malformed \u -- keep the backslash as a literal character.
					out .= ch
					i++
				}
			default:
				; Unknown escape: pass it through rather than corrupt the text.
				out .= ch
				i++
		}
	}
	return out
}

AiWord_JsonParse(jsonStr) {
	key := "", is_key := false
	stack := [tree := []]
	next := '"{[01234567890-tfn'
	pos := 0

	while ((ch := SubStr(jsonStr, ++pos, 1)) != "") {
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true)
			return ""

		obj := stack[1]
		is_array := (obj is Array)

		if i := InStr("{[", ch) {
			val := (i = 1) ? Map() : Array()
			is_array ? obj.Push(val) : obj[key] := val
			stack.InsertAt(1, val)
			next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
		} else if InStr("}]", ch) {
			stack.RemoveAt(1)
			next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
		} else if InStr(",:", ch) {
			is_key := (!is_array && ch == ",")
			next := is_key ? '"' : '"{[0123456789-tfn'
		} else {
			if (ch == '"') {
				i := pos
				while i := InStr(jsonStr, '"',, i+1) {
					val := SubStr(jsonStr, pos+1, i-pos-1)
					; A quote only ends the string if the run of backslashes
					; before it is EVEN (they pair off among themselves).
					if !(AiWord_TrailingBackslashes(val) & 1)
						break
				}
				if !i
					return ""
				pos := i
				val := AiWord_JsonUnescape(val)
				if is_key {
					key := val, next := ":"
					continue
				}
			} else {
				val := SubStr(jsonStr, pos, i := RegExMatch(jsonStr, "[\]\},\s]|$",, pos)-pos)
				if (val = "true")
					val := true
				else if (val = "false")
					val := false
				else if (val = "null")
					val := ""
				else if IsInteger(val) || IsFloat(val)
					val := val + 0
				pos += i-1
			}
			is_array ? obj.Push(val) : obj[key] := val
			next := obj == tree ? "" : is_array ? ",]" : ",}"
		}
	}
	return tree[1]
}


; ══════════════════════════════════════════════════════════════════════════════
; SMALL UTILITIES
; ══════════════════════════════════════════════════════════════════════════════

AiWord_ToolTip(text := "", timeoutMs := 0) {
	static TimerFn := (*) => ToolTip()
	SetTimer(TimerFn, 0)
	if (text = "") {
		ToolTip()
		return
	}
	ToolTip(text)
	if timeoutMs
		SetTimer(TimerFn, -timeoutMs)
}
