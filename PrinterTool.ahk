#SingleInstance
#Requires AutoHotkey v2+
;===============================================================================
;   Get/Set my default printer.  Updated: 5-14-2024
; A tool to allow user to check and/or change default printer.
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=118596&p=526363#p526363
; By Kunkel321 with help from Garry, Boiler, RussF
;===============================================================================
+!p:: ; Shift+Alt+P
PrinterTool(*)
{	; TraySetIcon("shell32.dll","107") ; Icon of a printer with a green checkmark.
	pfontColor := fontColor

	;guiColor := "F0F8FF" ; "F0F8FF" is light blue
	;pfontColor := "003366" ; "003366" is dark blue
	Global df := ""

	; ===== Get default printer name. ======
	defaultPrinter := RegRead("HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows", "Device")

	; ==== Get list of installed printers ======
	Global printerlist := ""
	Loop Reg, "HKCU\Software\Microsoft\Windows NT\CurrentVersion\devices"
		printerlist := printerlist . "" . A_loopRegName . "`n"
	printerlist := SubStr(printerlist, 1, strlen(printerlist) - 2)

	df := Gui()
	df.Title := "Default Printer Changer"
	df.OnEvent("Close", ButtonCancel)
	df.OnEvent("Escape", ButtonCancel)
	df.BackColor := guiColor
	df.SetFont("s12 bold c" . pFontColor)
	df.Add("Text", , "View or Set A Default Printer ...")
	df.SetFont("s10 bold c" . pFontColor)
	df.Add("Text","y+3" , "Select one and right-click for more options.")
	df.SetFont("s11")
	Loop Parse, printerlist, "`n"
		If InStr(defaultPrinter, A_LoopField)
			df.AddRadio("checked vRadio" . a_index, a_loopfield)
		Else
			df.AddRadio("vRadio" . a_index, a_loopfield)
	df.AddButton("default", "Set Printer").OnEvent("Click", ButtonSet)
	df.AddButton("x+4", "Queue").OnEvent("Click", ButtonQue)
	df.AddButton("x+4", "Ctrl Panel").OnEvent("Click", ButtonCtrlPanel)
	df.AddButton("x+4", "Cancel").OnEvent("Click", ButtonCancel)
	df.Show()
	df.OnEvent("ContextMenu", PrinterToolMenu) ; Detect right-click on form.
}

; Gets called when user right-clicks on maing df form. 
PrinterToolMenu(*)
{	Switches := " ; Find more potential switches at "help this message" menu item. 
	( ; Make sure the switch is on the left, description on the right, space between.
	/e display printing preferences
	/ge enum per machine printer connections
	/k print test page to specified printer
	/o display printer queue view
	/p display printer properties
	/s display server properties
	/y set printer as the default
	/Xg get printer settings
	/? "help this message"
	)"

	dfm := Menu()
	Loop Parse, Switches, "`n"
		dfm.Add(A_Loopfield, chosenSwitch.Bind(A_Loopfield ))
	dfm.Show()
}

chosenSwitch(mySwitch, *)
{	Loop Parse, printerlist, "`n" 
	{	thisRadioVal := df["Radio" . a_index].value
		If thisRadioVal != 0
		newDefault := a_loopfield
	}
	mySwitch := StrSplit(mySwitch, " ")[1]
	RunWait("C:\Windows\System32\RUNDLL32.exe PRINTUI.DLL, PrintUIEntry  " mySwitch "   /n `"" newDefault "`"") 
}

ButtonSet(*)
{ Loop Parse, printerlist, "`n" {
	thisRadioVal := df["Radio" . a_index].value
	If thisRadioVal != 0
		newDefault := a_loopfield
}
; ==== Set new default printer =====
RunWait("C:\Windows\System32\RUNDLL32.exe PRINTUI.DLL, PrintUIEntry /y /n `"" newDefault "`"") ; sets the printer
df.Destroy()
}

ButtonQue(*)
{ viewThis := ""
	Loop Parse, printerlist, "`n" {
		thisRadioVal := df["Radio" . a_index].value
		If thisRadioVal != 0
			viewThis := a_loopfield
	}
	; ==== View print queue for selected =====
	RunWait("rundll32 printui.dll, PrintUIEntry /o /n `"" viewThis "`"")  ;- display printer queue view
	df.Destroy()
}

ButtonCtrlPanel(*)
{ Run("control printers")
	df.Destroy()
	printerlist := ""
}  

ButtonCancel(*)
{ df.Destroy()
	printerlist := ""
}
