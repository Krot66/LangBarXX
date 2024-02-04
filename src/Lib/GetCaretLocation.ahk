GetCaretLocation(ByRef x, ByRef y) {    
    CoordMode Caret
    id:=WinExist("A")
    If (x:=A_CaretX) && (y:=A_CaretY)
        Return 1
    If !(x:=A_CaretX) || !(y:=A_CaretY) {
        Acc_Caret := Acc_ObjectFromWindow(id, OBJID_CARET:=0xFFFFFFF8)
        Caret_Location := Acc_Location(Acc_Caret)
        If (x:=Caret_Location.x) && (y:=Caret_Location.y)
            Return 2
    }
    try {
        ; UIA caret. From plankoe https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/
        static IUIA := ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
        ; GetFocusedElement
        DllCall(NumGet(NumGet(IUIA+0)+8*A_PtrSize), "ptr", IUIA, "ptr*", FocusedEl:=0)
        ; GetCurrentPattern. TextPatternElement2 = 10024
        DllCall(NumGet(NumGet(FocusedEl+0)+16*A_PtrSize), "ptr", FocusedEl, "int", 10024, "ptr*", patternObject:=0), ObjRelease(FocusedEl)
        if patternObject {
            ; GetCaretRange
            DllCall(NumGet(NumGet(patternObject+0)+10*A_PtrSize), "ptr", patternObject, "int*", IsActive:=1, "ptr*", caretRange:=0), ObjRelease(patternObject)
            ; GetBoundingRectangles
            DllCall(NumGet(NumGet(caretRange+0)+10*A_PtrSize), "ptr", caretRange, "ptr*", boundingRects:=0), ObjRelease(caretRange)
            ; VT_ARRAY = 0x20000 | VT_R8 = 5 (64-bit floating-point number)
            Rect := ComObject(0x2005, boundingRects)
            if (Rect.MaxIndex() = 3)
            {
                X:=Round(Rect[0]), Y:=Round(Rect[1]), W:=Round(Rect[2]), H:=Round(Rect[3])
                Return 3
            }
        }
    }
}

