SetInputLang(key_switch, target="") {
    If key_switch && target
        Critical
    target:=Format("{:#.4x}", target), st:=A_TickCount , start:=InputLayout()
    StringCaseSense Off
    If (target=start)
        Return
    If key_switch {
        RegRead lang_key, HKEY_CURRENT_USER\Keyboard Layout\Toggle, Hotkey        If !lang_key || (lang_key=1)
            keys:="{LAlt down}{LShift down}{LShift up}{LAlt up}"
        If (lang_key=2)
            keys:="{LCtrl down}{LShift down}{LShift up}{LCtrl up}"        
        If (lang_key=4)
            keys:="{" vkC0 " down}{" vkC0 " up}"
        If (lang_key=3) {
            MsgBox, 16, , У вас выключено переключение раскладки с помощью`nклавиатуры - включите его в панели управления!, 5
            Return
        }
        del:=A_KeyDelay, dur:=A_KeyDuration, st:=A_TickCount
        SetKeyDelay 20, 10        
        Loop {
            SendEvent % keys
            Sleep 5
            new:=InputLayout()
            If !target || (new=target) || (new=start) || (A_TickCount-st>1000)
                Break            
        }
        SetKeyDelay % del, % dur        
    }
    Else {
        WinExist("A")
        ControlGetFocus, CtrlInFocus
        PostMessage, 0x50, % (target ? 0 : 2), % target, % CtrlInFocus        
    }
    ;ToolTip % A_ThisHotkey " " key_switch "`n" target " " A_TickCount-st, 0, 0
    Critical Off
    Return
}