SetInputLayout(key_switch, target="") {
    ; Не использовать Critical!
    Global lang_array
    Global kl_change
    target0:=target, start:=InputLayout(), st:=A_TickCount
    If (target=start)
        Return
    If !target {
        Loop % lang_array.Length() 
            If (InputLayout()=lang_array[A_Index, 1]) {
                target:=(A_Index<lang_array.Length()) ? lang_array[A_Index+1, 1] : lang_array[1, 1]                
                Break               
            }
    }    
    StringCaseSense Off
    If key_switch { 
        RegRead lang_key, HKEY_CURRENT_USER\Keyboard Layout\Toggle, Hotkey        If !lang_key || (lang_key=1)
            keys:="{LAlt down}{LShift},{LAlt up}"
        If (lang_key=2)
            keys:="{LCtrl down}{LShift},{LCtrl up}"
        If (lang_key=4)
            keys:="{vkC0 down},{vkC0 up}"
        If (lang_key=3) {
            MsgBox, 16, , У вас выключено переключение раскладки с помощью`nклавиатуры - включите его в панели управления!, 5
            Return
        }
        RegRead, uac, HKEY_LOCAL_MACHINE, Software\Microsoft\Windows\CurrentVersion\Policies\System, EnableLUA
        SendMode % !uac ? "Play" : "Input"
        del:=A_KeyDelay, dur:=A_KeyDuration
        SetKeyDelay -1, -1
        Loop {
            old:=InputLayout(), lcount:=0
            Loop Parse, keys, `,
            {
                Send % A_LoopField
                If (A_Index=1) && InStr(keys, ",")
                    Sleep % uac ? 5 : 20
            }
            While (InputLayout()=old) && (lcount<20) {
                lcount++
                Sleep 10
            }          
            If (InputLayout()=target) || (A_Index>lang_array.Length())
                Break
        }
        SetKeyDelay % del, % dur
    }
    Else {
        WinExist("A")
        ControlGetFocus Focused
        ControlGet CtrlID, Hwnd,, % Focused
        PostMessage 0x50,, % target,, ahk_id %CtrlID%
        If ErrorLevel || (InputLayout()!=target)
            PostMessage, 0x50,, % target,, A
    }
    ;Sleep 5
    ;OutputDebug % A_TickCount-st " " key_switch " " target " " ((target!=InputLayout()) ? "error" : "")
    Return
}