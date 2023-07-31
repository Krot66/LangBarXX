SendText(txt) {
    global sc_string ; Для слежения и записи лога
    Global hand_sel
    If !txt
        Return
    If hand_sel
        Send {Del}
    If IsObject(txt) {
        sc_string:=""
        SetStoreCapsLockMode Off
        Loop % txt.Length() {
            SetCapsLockState % ((txt[A_Index, 2]) ? "On" : "Off")
            If (txt[A_Index, 1]~="^>!") {
                SendInput {RAlt Down}
                SendInput % RegExReplace(txt[A_Index, 1], "^>!")
                SendInput {RAlt Up}
            }
            Else If (txt[A_Index, 1]~="^<\^>!") {
                SendInput {AltGr Down}
                SendInput % RegExReplace(txt[A_Index, 1], "^<\^>!")
                SendInput {AltGr Up}
            }
            Else
                SendInput % txt[A_Index, 1]
            sc_string.=txt[A_Index, 1]
            Sleep 5
        }
        SetStoreCapsLockMode On
        Return
    }
    Send % "{Text}" txt
    Return
}