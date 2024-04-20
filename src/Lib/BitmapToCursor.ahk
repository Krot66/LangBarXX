; from iseahound ImagePut https://github.com/iseahound/ImagePut

BitmapToCursor(pBitmap, width:=0, height:=0, xHotspot := "", yHotspot := "", ctype:="") {
    If !ctype
        ctype:="32512,32513,32514,32515,32516,32631,32642,32643,32644,32645,32646,32648,32649,32650,32651,32671,32672"
    DllCall("gdiplus\GdipCreateHICONFromBitmap", "ptr", pBitmap, "ptr*", hIcon:=0)
    if (xHotspot ~= "^\d+$" || yHotspot ~= "^\d+$") {
        VarSetCapacity(ii, 8+3*A_PtrSize)
        DllCall("GetIconInfo", "ptr", hIcon, "ptr", &ii)
        NumPut(False, ii, 0, "uint")
        (xHotspot ~= "^\d+$") && NumPut(xHotspot, ii, 4, "uint")
        (yHotspot ~= "^\d+$") && NumPut(yHotspot, ii, 8, "uint")
        DllCall("DestroyIcon", "ptr", hIcon)
        hIcon := DllCall("CreateIconIndirect", "ptr", &ii, "ptr")
        DllCall("DeleteObject", "ptr", NumGet(ii, 8+A_PtrSize, "ptr"))
        DllCall("DeleteObject", "ptr", NumGet(ii, 8+2*A_PtrSize, "ptr"))
    }
    Loop Parse, % ctype, % ","
        if hCursor := DllCall("CopyImage", "ptr", hIcon, "uint", 2, "int", width, "int", height, "uint", 0)
            DllCall("SetSystemCursor", "uint", hCursor, "int", A_LoopField)
    DllCall("DestroyCursor", "ptr", hCursor)
    DllCall("DestroyIcon", "ptr", hIcon)
    return "A_Cursor"
}

