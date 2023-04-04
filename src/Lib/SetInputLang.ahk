SetInputLang(method, target="") {
    If (target=(start:=InputLayout()))
        Return
    If !method {
        WinExist("A")
        ControlGetFocus, CtrlInFocus
        PostMessage, 0x50, 0, % target, % CtrlInFocus, A            
    }        
    Else {
        keys:="{LWin down}{Space}{LWin up}"
        If A_OSVersion in WIN_XP,WIN_VISTA,WIN_7
        {
            RegRead lang_key, HKEY_CURRENT_USER\Keyboard Layout\Toggle, Hotkey            If !lang_key || (lang_key=1)
                keys:="{Alt down}{LShift down}{LShift up}{Alt up}"
            If (lang_key=2)
                keys:="{Ctrl down}{LShift down}{LShift up}{Ctrl up}"
            If (lang_key=4)
                keys:="{" vkC0 " down}{" vkC0 " up}"
            If (lang_key=3) {
                MsgBox, 16, , У вас выключено переключение раскладки с помощью клавиатуры - включите его в панели управления!, 2
                Return
            }
        }
        If !target
            Send % keys
        Else {
            Critical On
            Loop {
                Send % keys
                Sleep 50
                If (InputLayout()=target) || (InputLayout()=start)
                    Break
            } 
            Critical Off
        }
    }
}