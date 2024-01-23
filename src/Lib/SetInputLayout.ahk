SetInputLayout(key_switch, target="") {
    Global lang_array
    If !target {
        Loop % lang_array.Length() 
            If (InputLayout()=lang_array[A_Index, 1]) {
                target:=(A_Index<lang_array.Length()) ? lang_array[A_Index+1, 1] : lang_array[1, 1]                
                Break               
            }
    }
    start:=InputLayout(), ks_start:=A_TickCount
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
        st:=A_TickCount, del:=A_KeyDelay, dur:=A_KeyDuration
        SetKeyDelay 20, 10
        Critical On
        Loop {
            old:=InputLayout(), lcount:=0
            Send % keys
            While (InputLayout()=old) && (lcount<20) {
                lcount++
                Sleep 10
            }          
            If (InputLayout()=target) || (A_Index>lang_array.Length())
                Break
        }
        Loop Parse, % "LCtrl,LShift,LAlt", CSV
            If GetKeyState(A_LoopField)
                Send {%A_LoopField% up}
        SetKeyDelay % del, % dur
        Critical Off
    }
    Else {
        WinExist("A")
        ControlGetFocus Focused
        ControlGet CtrlID, Hwnd,, % Focused
        PostMessage 0x50,, % target,, ahk_id %CtrlID%
        If ErrorLevel || (InputLayout()!=target)
            PostMessage, 0x50,, % target,, A
    }
    Sleep 5
    OutputDebug % A_TickCount-ks_start "!!" key_switch " " target " " ((target!=InputLayout()) ? "error" : "")
    Return
}