hse:="QwertY"
hse2:="ЙцукеН"
MsgBox % StringToAnotherLayout(hse, 0x0409, 0x0419) "`n" StringToAnotherLayout(hse2, 0x0419, 0x0409)

StringToAnotherLayout(string, hkl_in, hkl_out) {
    id:=WinExist("A")
    Loop Parse, string
    {
        vk:=DllCall("VkKeyScanEx", "Char", Asc(A_LoopField), "UInt", hkl_in)
        If (vk=-1)
            Return
        vk_hex:=Format("vk{:x}", SubStr(vk, -2)) ;, sc:=GetKeySC("vk" RegExReplace(vk_hex,"\d(?=\w\w)"))  
        Shift:=(vk_hex~="1\w\w") ? 1 : 0, Control:=Alt:=(vk_hex~="6\w\w") ? 1 : 0        
        VarSetCapacity(lpKeyState, 256, 0)
        VarSetCapacity(pwszBuff, cchBuff:=3,0)
        VarSetCapacity(pwszBuff, 4, 0)

        for modifier, vk1 in {Shift:0x10, Control:0x11, Alt:0x12}
            NumPut(128*%modifier%, lpKeyState, vk1, "Uchar")
        n := DllCall("ToUnicodeEx", "Uint", vk, "Uint", sc, "UPtr", &lpKeyState, "ptr", &pwszBuff, "Int", cchBuff, "Uint", 0, "ptr", hkl_out),
        out.=StrGet(&pwszBuff, n, "utf-16")
    }
    Return out
}
