; ================================================================================================================================
; LV_MoveRow
; Moves a complete row within an own ListView control.
;     HLV            -  the handle to the ListView
;     RowNumber      -  the number of the row to be moved
;     InsertBefore   -  the number of the row to insert the moved row before
;     MaxTextLength  -  maximum length of item/subitem text being retrieved
; Returns the new row number of the moved row on success, otherwise zero (False).
; ================================================================================================================================
LV_MoveRow(HLV, RowNumber, InsertBefore, MaxTextLength := 257) {
   Static LVM_GETITEM := A_IsUnicode ? 0x104B : 0x1005
   Static LVM_INSERTITEM := A_IsUnicode ? 0x104D : 0x1007
   Static LVM_SETITEM := A_IsUnicode ? 0x104C : 0x1006
   Static OffMask := 0
        , OffItem := OffMask + 4
        , OffSubItem := OffItem + 4
        , OffState := OffSubItem + 4
        , OffStateMask := OffState + 4
        , OffText := OffStateMask + A_PtrSize
        , OffTextLen := OffText + A_PtrSize
   ; Some checks -----------------------------------------------------------------------------------------------------------------
   If (RowNumber = InsertBefore)
      Return True
   Rows := DllCall("SendMessage", "Ptr", HLV, "UInt", 0x1004, "Ptr", 0, "Ptr", 0, "Int") ; LVM_GETITEMCOUNT
   If (RowNumber < 1) || (InsertBefore < 1) || (RowNumber > Rows)
      Return False
   ; Move it, if possible --------------------------------------------------------------------------------------------------------
   GuiControl, -Redraw, %HLV%
   HHD := DllCall("SendMessage", "Ptr", HLV, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr") ; LVM_GETHEADER
   Columns := DllCall("SendMessage", "Ptr", HHD, "UInt", 0x1200, "Ptr", 0, "Ptr", 0, "Int") ; HDM_GETITEMCOUNT
   Item := RowNumber - 1
   StructSize := 88 + (MaxTextLength << !!A_IsUnicode)
   VarSetCapacity(LVITEM, StructSize, 0)
   NumPut(0x01031F, LVITEM, OffMask, "UInt") ; might need to be adjusted for Win XP/Vista
   NumPut(Item, LVITEM, OffItem, "Int")
   NumPut(-1, LVITEM, OffStateMask, "UInt")
   NumPut(&LVITEM + 88, LVITEM, OffText, "Ptr")
   NumPut(MaxTextLength, LVITEM, OffTextLen, "Int")
   If !DllCall("SendMessage", "Ptr", HLV, "UInt", LVM_GETITEM, "Ptr", 0, "Ptr", &LVITEM, "Int")
      Return False
   NumPut(InsertBefore - 1, LVITEM, OffItem, "Int")
   NewItem := DllCall("SendMessage", "Ptr", HLV, "UInt", LVM_INSERTITEM, "Ptr", 0, "Ptr", &LVITEM, "Int")
   If (NewItem = -1)
      Return False
   DllCall("SendMessage", "Ptr", HLV, "UInt", 0x102B, "Ptr", NewItem, "Ptr", &LVITEM) ; LVM_SETITEMSTATE
   If (InsertBefore <= RowNumber)
      Item++
   VarSetCapacity(LVITEM, StructSize, 0) ; reinitialize
   Loop, %Columns% {
      NumPut(0x03, LVITEM, OffMask, "UInt")
      NumPut(Item, LVITEM, OffItem, "Int")
      NumPut(A_Index, LVITEM, OffSubItem, "Int")
      NumPut(&LVITEM + 88, LVITEM, OffText, "Ptr")
      NumPut(MaxTextLength, LVITEM, OffTextLen, "Int")
      If !DllCall("SendMessage", "Ptr", HLV, "UInt", LVM_GETITEM, "Ptr", 0, "Ptr", &LVITEM, "Int")
         Return False
      NumPut(NewItem, LVITEM, OffItem, "Int")
      DllCall("SendMessage", "Ptr", HLV, "UInt", LVM_SETITEM, "Ptr", 0, "Ptr", &LVITEM, "Int")
   }
   Result := DllCall("SendMessage", "Ptr", HLV, "UInt", 0x1008, "Ptr", Item, "Ptr", 0) ; LVM_DELETEITEM
   GuiControl, +Redraw, %HLV%
   Return (Result ? (NewItem + 1) : 0)
}