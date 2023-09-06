SetInputLang(key_switch, target="") {
    Critical
    id:=WinExist("A"), target:=Format("{:#.4x}", target), start:=InputLayout(), ks_start:=A_TickCount
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
        bs:="LCtrl,LShift,LAlt"
    }
        st:=A_TickCount, RegExMatch(keys, "\{\K\S+(?=\s+up}$)", last_key)
        del:=A_KeyDelay, dur:=A_KeyDuration, st:=A_TickCount
        SetKeyDelay 20, 10   
        Loop {
            WinActivate ahk_id %id%
            old:=InputLayout(), lcount:=0
            Send % keys
            While (InputLayout()=old) && (lcount<20) {
                lcount++
                Sleep 10
            }
            new:=InputLayout()
            If !target || (new=target)  || (new=start)
                Break
            Loop Parse, bs, CSV
                If GetKeyState(A_LoopField)
                    Send {%A_LoopField% up}
        }
        SetKeyDelay % del, % dur
    }
    Else {
        ControlGetFocus, CtrlInFocus
        PostMessage, 0x50, % (target ? 0 : 2), % target, % CtrlInFocus, ahk_id %id%
        Sleep 10
    }
    Critical Off
    mess:=(target && (target!=InputLayout())) ? " error" : ""
    OutputDebug % A_TickCount-ks_start " " key_switch " " mess
    If !A_IsCompiled
        FileAppend % "`r`n" A_TickCount-ks_start " " key_switch . mess, logs\key_switch.log
    Return
}