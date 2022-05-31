InputLayout(window="A") {
	If !(hWnd := WinExist(window))
		return
	WinGetClass, Class
	If (Class=="ConsoleWindowClass") {
		WinGet, consolePID, PID
		DllCall("AttachConsole", Ptr, consolePID)
		VarSetCapacity(langID, 16)
		DllCall("GetConsoleKeyboardLayoutName", Str, langID),
		DllCall("FreeConsole")
	}
	Else {
		SetFormat Integer, H
		ThreadID:=DllCall("GetWindowThreadProcessId", UInt, hWnd, UInt, 0)
		langID:=DllCall("GetKeyboardLayout", UInt, ThreadID, UInt)
		SetFormat Integer, D
	}
	Return "0x" SubStr(langID, -3)
}
