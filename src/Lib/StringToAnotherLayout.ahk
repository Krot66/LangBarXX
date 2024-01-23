StringToAnotherLayout(string, hkl_in, hkl_out) {
    Loop Parse, string
    {
        val:=DllCall("VkKeyScanEx", "Char", Asc(A_LoopField), "UInt", hkl_in)
        If (val=-1) {
            val:=DllCall("VkKeyScanEx", "Char", Asc(DelAccent(A_LoopField)), "UInt", hkl_in)
            If (val=-1)
                Continue
        }
        vk:=SubStr(Format("{:x}", val), -2), prx:=""
        If (vk~="20d$") ; удаление двойных переносов
            Continue
        shift:=(vk~="1\w\w$") ? 1 : 0, ctrl:=alt:=(vk~="6\w\w$") ? 1 : 0,
        vk:="0x" SubStr(vk, -1),        
        sc:=Format("{:#x}", DllCall("MapVirtualKeyEx", "UINT", vk, "UINT", 0, "PTR", hkl_in))
        vk:=Format("{:#x}", DllCall("MapVirtualKeyEx", "UINT", sc, "UINT", 3, "PTR", hkl_out)),
        VarSetCapacity(lpKeyState, 256, 0)
        VarSetCapacity(pwszBuff, cchBuff:=3,0)
        VarSetCapacity(pwszBuff, 4, 0)
        for modifier, vk1 in {Shift:0x10, Control:0x11, Alt:0x12}
            NumPut(128*%modifier%, lpKeyState, vk1, "Uchar")
        n:=DllCall("ToUnicodeEx"
            , "Uint", vk
            , "Uint", sc
            , "UPtr", &lpKeyState
            , "ptr", &pwszBuff
            , "Int", cchBuff
            , "Uint", 0
            , "ptr", hkl_out),
        out.=StrGet(&pwszBuff, n, "utf-16")
    }
    Return out
}
        
        