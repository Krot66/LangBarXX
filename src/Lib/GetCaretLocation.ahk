GetCaretLocation() {
        CoordMode Caret
        id:=WinExist("A"), x:=A_CaretX, y:=A_CaretY, m:=0  
        If (!x || !y) {
            Acc_Caret := Acc_ObjectFromWindow(id, OBJID_CARET := 0xFFFFFFF8)
            Caret_Location := Acc_Location(Acc_Caret)
            x:=Caret_Location.x, y:=Caret_Location.y, m:=1
        }
	Return [x,y,m]
}
