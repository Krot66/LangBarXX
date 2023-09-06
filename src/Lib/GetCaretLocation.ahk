GetCaretLocation(ByRef x, ByRef y) {    
    CoordMode Caret
    If !(x:=A_CaretX) || !(y:=A_CaretY) {
        Acc_Caret := Acc_ObjectFromWindow(WinExist("A"), OBJID_CARET:=0xFFFFFFF8)
        Caret_Location := Acc_Location(Acc_Caret)
        x:=Caret_Location.x, y:=Caret_Location.y
    }
    Return (x && y) ? ((Acc_State(Acc_Caret)="normal") ? 2 : 1) : 0
}
