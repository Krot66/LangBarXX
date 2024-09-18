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
    Else If (Class~="(ApplicationFrameWindow|DocEditorsWindowClass)") || (WinActive("ahk_exe notepad.exe") && (A_OSVersion~="10\.0\.2")) {
        SetFormat Integer, H
        ControlGetFocus Focused, A
        ControlGet CtrlID, Hwnd,, % Focused, A
        ThreadID := DllCall("GetWindowThreadProcessId", "Ptr", CtrlID, "Ptr", 0)
        LangID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "Ptr")
        SetFormat Integer, D
    }
	Else {
		SetFormat Integer, H
		ThreadID:=DllCall("GetWindowThreadProcessId", UInt, hWnd, UInt, 0)
		langID:=DllCall("GetKeyboardLayout", UInt, ThreadID, UInt)
		SetFormat Integer, D
	}
    Return langID ? "0x" Format("{:L}", SubStr(langID, -3)) : ""
}
