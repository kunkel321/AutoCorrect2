/*
================================================================
ChatGPT Word Lookup Module to be #Include'd in AutoCorrect2.ahk
			github.com/kunkel321/autocorrect2 
================================================================

Optional include file for ChatGPT-based word definitions.
Reads API key from ..\Data\PersonalApiKey.ini
Creates ini file if not already present.
When included, this module hooks into Dictionary.ShowDefinitionGui() to add 
a "Try ChatGPT" button post-hoc to the Dictionary GUI.

Requires an OpenAI account and prepaid API tokens. See 'SetupMessage' below.

			By: Kunkel321
			Date: 8-9-2026  
			Tool Used: Claude
Credit:  This is based on the app 'ChatGPT-AutoHotkey-Utility' by kdalanon. 
https://github.com/kdalanon/ChatGPT-AutoHotkey-Utility
*/

; ===== Module Constants =====
; The INI path was previously written out twice, in two different functions.
; One place to change it, so the two can never drift apart.
; NOTE: this is relative to A_WorkingDir, NOT to this script.  If AC2 is ever
; launched with a different working directory (Task Scheduler is the classic
; offender), both the read and the create will silently target the wrong
; folder.  A_ScriptDir "\..\Data\PersonalApiKey.ini" would harden it -- left
; as-is here so this file changes nothing you did not ask it to.
global ChatGptWordLookup_IniPath := "..\Data\PersonalApiKey.ini"

; Used when the INI has no Model= key, which is every INI created before this
; setting existed -- so old installs keep working with no migration step.
global ChatGptWordLookup_DefaultModel := "gpt-4o-mini"

; ===== Setup Message =====
global ChatGptWordLookup_SetupMessage := "
(
PersonalApiKey.ini has been created in the Data folder.
To use ChatGPT word lookup:
1. Set up an account and get an API key from: https://platform.openai.com/account/api-keys
2. Open the AutoCorrect2\Data\PersonalApiKey.ini file.
3. Paste your API key as the ApiKey value (no quotation marks).
4. Save the INI file, then restart AutoCorrect2
The same INI file has a Model= key, which sets which OpenAI model gets asked.  The default is a small, inexpensive one.  Current model names are listed at https://platform.openai.com/docs/models -- if you enter one that does not exist, the lookup will tell you so in plain language rather than just failing.
Please note that the OpenAI service is not free.  Also note, kunkel321 (the author of AutoCorrect2.ahk) does not receive any compensation or benefit from your transactions with OpenAI.  Upon testing, word lookups cost a small fraction of a cent each on the default model.  Important:  Your pre-paid tokens expire after one year! (Boooo!) As such, I don't recommend "loading up" your account with tokens.  Just purchase one or two dollars worth every six months, and add a "Budget alert" for when you are about to run out.  
)"
; See down below for wording of prompt.

; ===== Register Callback for Dictionary GUI Creation =====
; Register this module's callback to add the ChatGPT button when Dictionary GUI is created
Dictionary._PostShowCallback := ChatGptWordLookup_OnDefinitionGuiCreated

ChatGptWordLookup_OnDefinitionGuiCreated(dictGui, word, defEdit) {
	; Add the ChatGPT button with proper spacing
	dictGui.AddButton("x+8", "Try ChatGPT").OnEvent("Click", (*) => ChatGptWordLookup_LookupWord(word, defEdit))
}

; ===== Initialization & INI Management =====
ChatGptWordLookup_EnsureIniFile() {
	; Create directory if it doesn't exist
	dataDir := "..\Data"
	if !DirExist(dataDir) {
		try {
			DirCreate(dataDir)
		} catch Error as err {
			return false
		}
	}
	
	; Create INI file if it doesn't exist
	if !FileExist(ChatGptWordLookup_IniPath) {
		template := "[OpenAI]`nApiKey=`nModel=" ChatGptWordLookup_DefaultModel "`n"
		try {
			FileAppend(template, ChatGptWordLookup_IniPath)
			; Return false - the caller shows the setup instructions.
			return false
		} catch Error as err {
			return false
		}
	}
	
	return true
}

ChatGptWordLookup_GetApiKey() {
	try {
		apiKey := IniRead(ChatGptWordLookup_IniPath, "OpenAI", "ApiKey", "")
		return (apiKey = "") ? "" : apiKey
	} catch Error as err {
		return ""
	}
}

; The model is a setting rather than a hardcoded string because OpenAI reshuffles
; its lineup faster than this script gets edited.  When a name is retired, the
; fix becomes a one-line INI change instead of a code change.
ChatGptWordLookup_GetModel() {
	try {
		modelName := Trim(IniRead(ChatGptWordLookup_IniPath, "OpenAI", "Model", ""))
		return (modelName = "") ? ChatGptWordLookup_DefaultModel : modelName
	} catch Error as err {
		return ChatGptWordLookup_DefaultModel
	}
}

ChatGptWordLookup_LookupWord(word, defEdit) {
	; EnsureIniFile returns false in TWO different situations: a real failure,
	; and the perfectly normal case where it just created a fresh INI.  The old
	; code returned silently on false, so the very first click on the button did
	; nothing at all -- no message, no error, nothing.  The setup text was only
	; reachable on the SECOND click, once the (empty) INI already existed.  Show
	; it either way; it is the right message in both cases.
	if !ChatGptWordLookup_EnsureIniFile() {
		defEdit.Value := ChatGptWordLookup_SetupMessage
		return
	}
	
	; Trim() because a key pasted from a browser very often carries a trailing
	; space, and a trailing space in an Authorization header produces a 401 that
	; looks exactly like a wrong key.
	apiKey := Trim(ChatGptWordLookup_GetApiKey())
	if (apiKey = "") {
		defEdit.Value := ChatGptWordLookup_SetupMessage
		return
	}
	
	; Show loading message and clear any "Word not found" message
	defEdit.Value := "Asking ChatGPT... (This may take a moment)`n`n"
		. "(This uses your OpenAI API credits)"
	
	; Make the API request
	errMsg := ""
	definition := ChatGptWordLookup_GetDefinition(word, apiKey, &errMsg)
	
	; Display result
	if (definition = "") {
		defEdit.Value := "ChatGPT Lookup Failed`n`n"
			. (errMsg != "" ? errMsg "`n`n" : "")
			. "Possible reasons:`n"
			. "• Network error`n"
			. "• Invalid API key`n"
			. "• Model name not recognized (check Model= in PersonalApiKey.ini)`n"
			. "• API rate limit exceeded"
	} else {
		defEdit.Value := definition
	}
}

; ===== API Request =====
; errMsg is an OUTPUT parameter.  The old version returned "" for every possible
; failure, so expired credits and a DNS outage produced identical, unhelpful
; text on screen.  Now the reason comes back with it.
ChatGptWordLookup_GetDefinition(word, apiKey, &errMsg) {
	errMsg := ""
	apiUrl := "https://api.openai.com/v1/chat/completions"
	
	; Build the prompt.
	; NOTE: the "(" below does not open inside a quoted string, so this is an
	; EXPRESSION continuation section -- each line is a separate string literal
	; and `word` really is interpolated.  But adjacent string literals join with
	; NOTHING between them, so the line breaks you see here do not survive into
	; the prompt.  Hence the explicit `n escapes; without them GPT receives
	; "...a short sentence.Have the condensed version formatted as:Word (summary
	; definition)Don't present it as..." -- and the one part of the prompt whose
	; entire purpose is line layout arrives with no layout.
	prompt := 
	(
"Return the definition of the word: " word ".  Please provide a normal definition, including the word type (e.g. noun, verb, adjective, adverb). Additionally, at the top, provide a super-condensed summary definition that is just a short sentence.`n`n"
"Have the condensed version formatted as:`n"
"Word (summary definition)`n"
"Don't present it as 'Condensed version: Word (summary definition)', just have the summary on the top row and the extended description below.`n`n"
"If the word is a non-English word, indicate so. Also if the word is archaic, disused, or questionable in any way, indicate that too."
	)
	
	try {
		; Prepare JSON request.  EscapeJson renders every non-ASCII character as
		; \uXXXX, so jsonBody is guaranteed 7-bit clean -- which sidesteps the
		; question of what encoding WinHttpRequest.Send() picks for a string
		; body.  If there are no bytes above 0x7F, it cannot get them wrong.
		messages := '{"role":"user","content":"' ChatGptWordLookup_EscapeJson(prompt) '"}'
		jsonBody := '{"model":"' ChatGptWordLookup_EscapeJson(ChatGptWordLookup_GetModel()) '","messages":[' messages ']}'
		
		httpReq := ComObject("WinHttp.WinHttpRequest.5.1")
		httpReq.Open("POST", apiUrl, true)
		; The charset is declared even though the body is already ASCII-only.
		; It costs nothing and documents the intent for the next reader.
		httpReq.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
		httpReq.SetRequestHeader("Authorization", "Bearer " apiKey)
		httpReq.SetTimeouts(30000, 30000, 30000, 30000)
		httpReq.Send(jsonBody)
		; A bare WaitForResponse() can block indefinitely if the connection is
		; half-open in a way SetTimeouts does not catch.  35s > the 30s above.
		httpReq.WaitForResponse(35)
		
		status := httpReq.Status
		
		; Decode ONCE, up front, so the error path gets clean text too.  A
		; mangled error message is actively misleading -- it sends you chasing
		; an encoding ghost instead of reading "insufficient_quota".
		responseText := ChatGptWordLookup_ResponseUtf8(httpReq)
		
		if (status != 200) {
			errMsg := "HTTP " status
			; OpenAI's error blob says far more than the status code does.  This
			; is also what makes the Model= INI setting safe to experiment with:
			; a retired model name comes back as a readable sentence.
			errData := ChatGptWordLookup_JsonParse(responseText)
			if IsObject(errData) && errData.Has("error") {
				apiErr := errData["error"]
				if IsObject(apiErr) && apiErr.Has("message")
					errMsg .= ": " apiErr["message"]
			}
			return ""
		}
		
		jsonData := ChatGptWordLookup_JsonParse(responseText)
		
		if !IsObject(jsonData) || !jsonData.Has("choices") {
			errMsg := "The response was not in the expected format."
			return ""
		}
		
		choices := jsonData["choices"]
		if (choices.Length = 0) {
			errMsg := "The API returned no choices."
			return ""
		}
		
		message := choices[1]["message"]
		if !message.Has("content") {
			errMsg := "The API returned a choice with no content."
			return ""
		}
		
		return message["content"]
		
	} catch as err {
		errMsg := err.Message
		return ""
	}
}

; ===== HTTP Response Decoding =====
; WinHttpRequest chooses its decoder from the charset= parameter of the
; Content-Type RESPONSE header.  OpenAI sends "application/json" with no charset
; at all, so .ResponseText falls back to Latin-1 and reads the UTF-8 body one
; byte at a time.  "naive" with a diaeresis (C3 AF) comes back as two
; characters; an em dash (E2 80 94) comes back as "a-circumflex" plus U+0080 and
; U+0094 -- and those two are INVISIBLE C1 control characters, so the damage
; does not even look like damage until it lands in the clipboard.
;
; The fix is to bypass the header sniffing entirely: take .ResponseBody, which
; is the raw byte array, and tell StrGet what the encoding actually is.
ChatGptWordLookup_ResponseUtf8(req) {
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
		
		; The byte count is passed explicitly because an HTTP body is not
		; null-terminated -- letting StrGet hunt for a terminator would read
		; past the end of the array.
		str := (len > 0) ? StrGet(pData, len, "UTF-8") : ""
		
		DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", pSA)
		return str
	} catch {
		; If the SAFEARRAY dance fails we are already in trouble; mangled text
		; still beats an empty string for figuring out what went wrong.
		try return req.ResponseText
		return ""
	}
}

; ===== JSON Parsing & Escaping =====

; Every character outside printable ASCII is emitted as \uXXXX.  That makes the
; entire request body 7-bit clean, which is the robust answer to "what encoding
; does WinHttpRequest.Send() use for a string body?" -- it stops mattering.
;
; The old version also missed the other control characters entirely: a raw 0x0C
; in the input would have produced literally invalid JSON, because the spec
; forbids unescaped characters below 0x20 inside a string.
;
; Parameter is named srcText, NOT inStr -- variable names are case-insensitive
; in v2, so a parameter named inStr would shadow the built-in InStr function.
ChatGptWordLookup_EscapeJson(srcText) {
	out := ""
	Loop Parse, srcText {
		ch := A_LoopField
		code := Ord(ch)
		
		if (ch == '"')
			out .= '\"'
		else if (ch == "\")
			out .= "\\"
		else if (code >= 0x20 && code <= 0x7E)
			out .= ch                        ; plain printable ASCII, pass through
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
			; (emoji, rare CJK) has to go out as a surrogate PAIR.  Ord() hands
			; back the combined code point when the loop gives us a whole
			; character, so split it back apart here.
			code -= 0x10000
			out .= Format("\u{:04x}\u{:04x}", 0xD800 + (code >> 10), 0xDC00 + (code & 0x3FF))
		}
		else
			out .= Format("\u{:04x}", code)  ; other controls, and all non-ASCII
	}
	return out
}

; Counts the unbroken run of backslashes at the END of a string.  Used by the
; string scanner in JsonParse to decide whether a closing quote was escaped;
; see the comment at the call site for why parity is the right test.
ChatGptWordLookup_TrailingBackslashes(txt) {
	count := 0
	i := StrLen(txt)
	while (i >= 1 && SubStr(txt, i, 1) == "\") {
		count++
		i--
	}
	return count
}

; The old unescaping was three chained StrReplace calls with \\ -> \ done FIRST.
; That is the classic order-of-operations trap: given the literal four-character
; JSON text  \\n  (an escaped backslash followed by the letter n), pass one
; turns it into  \n , and the later \n -> newline pass then turns that into a
; real newline.  The backslash the API deliberately escaped for us gets eaten
; and a line break appears out of nowhere.
;
; A single left-to-right pass makes that structurally impossible: once we have
; consumed the \\ we are already positioned past the n, so nothing can come back
; around and reinterpret it.
ChatGptWordLookup_JsonUnescape(txt) {
	; Overwhelmingly the common case for a dictionary definition -- skip the
	; whole character loop when there is nothing to unescape.
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
		
		; CaseSense is passed explicitly.  Switch is case-sensitive by default
		; in v2, but the JSON escapes are lowercase-only and a stray \N must
		; stay literal -- worth stating rather than relying on remembering.
		switch esc, true {
			case '"':  out .= '"',     i += 2
			case "\":  out .= "\",     i += 2
			case "/":  out .= "/",     i += 2   ; legal, and OpenAI does emit it
			case "b":  out .= Chr(8),  i += 2
			case "f":  out .= Chr(12), i += 2
			case "n":  out .= "`n",    i += 2
			case "r":  out .= "`r",    i += 2
			case "t":  out .= "`t",    i += 2
			case "u":
				hex := SubStr(txt, i + 2, 4)
				if (StrLen(hex) = 4 && RegExMatch(hex, "^[0-9A-Fa-f]{4}$")) {
					code := Integer("0x" hex)
					; Chr(0) would embed a NUL, and a NUL truncates the string
					; at every Windows API boundary it later crosses.  Drop it.
					if (code != 0)
						out .= Chr(code)
					; Surrogate pairs need no special handling: two consecutive
					; \uD83D \uDE00 escapes append two UTF-16 code units, which
					; IS the correctly-formed character in an AHK string.
					i += 6
				}
				else {
					; Malformed \u -- keep the backslash as a literal character
					; rather than silently swallowing four bytes of real text.
					out .= ch
					i++
				}
			default:
				; Unknown escape.  JSON says this is invalid; being lenient and
				; passing it through is friendlier than corrupting the output.
				out .= ch
				i++
		}
	}
	return out
}

ChatGptWordLookup_JsonParse(jsonStr) {
	key := "", is_key := false
	stack := [tree := []]
	next := '"{[01234567890-tfn'
	pos := 0
	
	while ((ch := SubStr(jsonStr, ++pos, 1)) != "") {
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true) {
			return ""
		}
		
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
					; A quote only terminates the string if it is NOT escaped.
					; The old test was  SubStr(val, -1) != "\"  which is wrong
					; for any string that legitimately ENDS in a backslash
					; (written \\ in JSON) -- it saw the trailing backslash,
					; concluded the quote was escaped, and kept scanning on into
					; the rest of the document.
					;
					; What actually matters is the PARITY of the run of
					; backslashes just before the quote.  Even means they pair
					; off among themselves and the quote is real; odd means the
					; last one is escaping the quote.
					if !(ChatGptWordLookup_TrailingBackslashes(val) & 1)
						break
				}
				if !i
					return ""
				
				pos := i
				val := ChatGptWordLookup_JsonUnescape(val)
				
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
