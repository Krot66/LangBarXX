GetCaretLocation(ByRef x, ByRef y) {    
    CoordMode Caret
    id:=WinExist("A")
    If !(x:=A_CaretX) || !(y:=A_CaretY) {
        Acc_Caret := Acc_ObjectFromWindow(id, OBJID_CARET:=0xFFFFFFF8)
        Caret_Location := Acc_Location(Acc_Caret)
        x:=Caret_Location.x, y:=Caret_Location.y
    }
    Return (x && y) ? ((Acc_State(Acc_Caret)="normal") ? 1 : 0) : ""
}

