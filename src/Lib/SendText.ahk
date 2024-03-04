SendText(txt) {
    If !txt
        Return
    If IsObject(txt) {
        hkl:=InputLayout()
        SetStoreCapsLockMode Off
        Loop % txt.Length() {
            SetCapsLockState % ((txt[A_Index, 3]) ? "On" : "Off")
            vk:=Format("vk{:x}", DllCall("MapVirtualKeyEx", "UINT", txt[A_Index, 1], "UINT", 3, "PTR", hkl))
            If (txt[A_Index, 2]="^!") {
                SendInput {Ctrl down}{Alt down}
                SendInput % "{" vk "}"
                SendInput {Alt up}{Ctrl up}
            }
            Else
                SendInput % txt[A_Index, 2] "{" vk "}"
            Sleep 3
        }
        SetStoreCapsLockMode On
        Return
    }
    SendInput % "{Text}" txt
    Return
}