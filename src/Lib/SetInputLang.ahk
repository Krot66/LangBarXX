SetInputLang(key_switch, target="") {
    start:=A_TickCount
    id:=WinExist("A")
    If key_switch && target
        Critical
    target:=Format("{:#.4x}", target), st:=A_TickCount , start:=InputLayout()
    StringCaseSense Off
    If (target=start)
        Return
    If key_switch {
        RegRead lang_key, HKEY_CURRENT_USER\Keyboard Layout\Toggle, Hotkey        If !lang_key || (lang_key=1)
            keys:="{LAlt down}{LShift}{LAlt up}"
        If (lang_key=2)
            keys:="{LCtrl down}{LShift}{LCtrl up}"        
        If (lang_key=4)
            keys:="{" vkC0 " down}{" vkC0 " up}"
        If (lang_key=3) {
            MsgBox, 16, , У вас выключено переключение раскладки с помощью`nклавиатуры - включите его в панели управления!, 5
            Return
        }
        st:=A_TickCount, RegExMatch(keys, "\{\K\S+(?=\s+up}$)", last_key)       
        Loop {
            WinActivate ahk_id %id%
            old:=InputLayout(), lcount:=0
            SendEvent % keys
            While (InputLayout()=old) && (lcount<20) {
                lcount++
                Sleep 10
            }
            new:=InputLayout()
            If !target || (new=target)  || (new=start)
                Break
        }   
    }
    Else {
        ControlGetFocus, CtrlInFocus
        PostMessage, 0x50, % (target ? 0 : 2), % target, % CtrlInFocus, ahk_id %id%
        Sleep 10
    }
    Critical Off
    mess:=(target && (target!=InputLayout())) ? " error" : ""
    OutputDebug % A_TickCount-start " " key_switch " " mess
    Return
}