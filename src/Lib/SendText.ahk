SendText(txt, hook:="") {
    Global
    If !txt
        Return
    hkl:=InputLayout(), send_text:=1
    If hook
        rh:=InputHook("V"), rh.Start() 
    If IsObject(txt) {
        SetStoreCapsLockMode Off
        Loop % txt.Length() {
            SetCapsLockState % ((txt[A_Index, 3]) ? "On" : "Off")
            vk:=Format("vk{:x}", DllCall("MapVirtualKeyEx", "UINT", txt[A_Index, 1], "UINT", 3, "PTR", hkl))
            If (txt[A_Index, 2]="^!")
                SendInput % "{Ctrl down}{Alt down}{" vk "}{Alt up}{Ctrl up}"
            Else
                SendInput % txt[A_Index, 2] "{" vk "}"
            Sleep 5
        }
        SetStoreCapsLockMode On
    }
    Else
        SendInput % "{Text}" txt
    OutputDebug % hkey "/" hkl " : " (IsObject(txt) ? 1 : 0) " " rh.Input
    Sleep 5
    rb:=rh.Input, rh.Stop(), send_text:=""
    Return StrLen(rb)
}