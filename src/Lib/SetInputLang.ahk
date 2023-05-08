SetInputLang(key_switch, target="") {
    Global lang_count
    If key_switch && target
        Critical
    target:=Format("{:#.4x}", target) 
    ;ToolTip % A_ThisHotkey " " key_switch " " target, 0, 0
    StringCaseSense Off
    If (target=InputLayout())
        Return
    If key_switch {
        RegRead lang_key, HKEY_CURRENT_USER\Keyboard Layout\Toggle, Hotkey        If !lang_key || (lang_key=1)
            keys:="{LAlt down}{LShift down}{LShift up}{LAlt up}"
        If (lang_key=2)
            keys:="{LCtrl down}{LShift down}{LShift up}{LCtrl up}"        
        If (lang_key=4)
            keys:="{" vkC0 " down}{" vkC0 " up}"
        If (lang_key=3) {
            MsgBox, 16, , У вас выключено переключение раскладки с помощью клавиатуры - включите его в панели управления!, 2
            Return
        }
        del:=A_KeyDelay, dur:=A_KeyDuration
        SetKeyDelay 20, 10        
        Loop {
            SendEvent % keys
            c++
            Sleep 20
            If !target || (InputLayout()=target) || (c=lang_count)
                Break            
        }
        SetKeyDelay % del, % dur        
    }
    Else {
        WinExist("A")
        ControlGetFocus, CtrlInFocus
        PostMessage, 0x50, % (target ? 0 : 2), % target, % CtrlInFocus        
    }
    Critical Off
    Return
}