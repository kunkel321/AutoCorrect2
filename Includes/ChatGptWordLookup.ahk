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
			Date: 12-3-2025 
			Tool Used: Claude
Credit:  This is based on the app 'ChatGPT-AutoHotkey-Utility' by kdalanon. 
https://github.com/kdalanon/ChatGPT-AutoHotkey-Utility
*/

; ===== Setup Message =====
global ChatGptWordLookup_SetupMessage := "
(
PersonalApiKey.ini has been created in the Data folder.
To use ChatGPT word lookup:
1. Set up an accound and get an API key from: https://platform.openai.com/account/api-keys
2. Open the AutoCorrect2\Data\PersonalApiKey.ini file.
3. Paste your API key as the ApiKey value (no quotation marks).
4. Save the INI file, then restart AutoCorrect2
Please note that the OpenAI service is not free.  Also note, kunkel321 (the author of AutoCorrect2.ahk) does not receive any compensation or benefit from your transactions with OpenAI.  I've only added this integration because I use it, and I thought others might like to as well.  Upon testing, word lookups seem to cost a little under one cent USD each.  Important:  Your pre-paid tokens expire after one year! (Boooo!) As such, I don't recommend "loading up" your account with tokens.  Just purchase one or two dollars worth every six months, and add a "Budget alert" for when you are about to run out.  
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
	iniPath := "..\Data\PersonalApiKey.ini"
	
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
	if !FileExist(iniPath) {
		template := "[OpenAI]`nApiKey=`n"
		try {
			FileAppend(template, iniPath)
			; Silently return false - user will see setup instructions in the GUI
			return false
		} catch Error as err {
			return false
		}
	}
	
	return true
}

ChatGptWordLookup_GetApiKey() {
	iniPath := "..\Data\PersonalApiKey.ini"
	
	try {
		apiKey := IniRead(iniPath, "OpenAI", "ApiKey", "")
		return (apiKey = "") ? "" : apiKey
	} catch Error as err {
		return ""
	}
}

ChatGptWordLookup_LookupWord(word, defEdit) {
	; Ensure INI file exists
	if !ChatGptWordLookup_EnsureIniFile() {
		return
	}
	
	; Get API key
	apiKey := ChatGptWordLookup_GetApiKey()
	if (apiKey = "") {
		defEdit.Value := ChatGptWordLookup_SetupMessage
		return
	}
	
	; Show loading message and clear any "Word not found" message
	defEdit.Value := "Asking ChatGPT... (This may take a moment)`n`n"
		. "(This uses your OpenAI API credits)"
	
	; Make the API request
	definition := ChatGptWordLookup_GetDefinition(word, apiKey)
	
	; Display result
	if (definition = "") {
		defEdit.Value := "ChatGPT Lookup Failed`n`n"
			. "Possible reasons:`n"
			. "• Network error`n"
			. "• Invalid API key`n"
			. "• API rate limit exceeded"
	} else {
		defEdit.Value := definition
	}
}

; ===== API Request =====
ChatGptWordLookup_GetDefinition(word, apiKey) {
	apiUrl := "https://api.openai.com/v1/chat/completions"
	
	; Build the prompt
	prompt := 
	(
"Return the definition of the word: " word ".  Please provide a normal definition, including the word type (e.g. noun, verb, adjective, adverb). Additionally, at the top, provide a super-condensed summary definition that is just a short sentence.

Have the condensed version formatted as:
Word (summary definition)
Don't present it as 'Condensed version: Word (summary definition)', just have the summary on the top row and the extended description below.

If the word is a non-English word, indicate so. Also if the word is archaic, disused, or questionable in any way, indicate that too."
	)
	
	try {
		; Prepare JSON request
		messages := '{"role":"user","content":"' ChatGptWordLookup_EscapeJson(prompt) '"}'
		jsonBody := '{"model":"gpt-4","messages":[' messages ']}'
		
		; Make HTTP request
		httpReq := ComObject("WinHttp.WinHttpRequest.5.1")
		httpReq.Open("POST", apiUrl, true)
		httpReq.SetRequestHeader("Content-Type", "application/json")
		httpReq.SetRequestHeader("Authorization", "Bearer " apiKey)
		httpReq.SetTimeouts(30000, 30000, 30000, 30000)
		httpReq.Send(jsonBody)
		httpReq.WaitForResponse()
		
		if (httpReq.Status != 200) {
			return ""
		}
		
		; Parse JSON response
		responseText := httpReq.ResponseText
		jsonData := ChatGptWordLookup_JsonParse(responseText)
		
		if !IsObject(jsonData) || !jsonData.Has("choices") {
			return ""
		}
		
		choices := jsonData["choices"]
		if (choices.Length = 0) {
			return ""
		}
		
		message := choices[1]["message"]
		if !message.Has("content") {
			return ""
		}
		
		return message["content"]
		
	} catch Error as err {
		return ""
	}
}

; ===== JSON Parsing & Escaping =====
ChatGptWordLookup_EscapeJson(str) {
	str := StrReplace(str, "\", "\\")
	str := StrReplace(str, '"', '\"')
	str := StrReplace(str, "`n", "\n")
	str := StrReplace(str, "`r", "\r")
	str := StrReplace(str, "`t", "\t")
	return str
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
					if (SubStr(val, -1) != "\")
						break
				}
				if !i
					return ""
				
				pos := i
				val := StrReplace(val, "\\", "\")
				val := StrReplace(val, '\"', '"')
				val := StrReplace(val, "\n", "`n")
				
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
