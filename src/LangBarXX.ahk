#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 1000
CoordMode Caret
CoordMode Tooltip
CoordMode Mouse
SetWinDelay -1
SetBatchLines -1
SetWorkingDir %A_ScriptDir%

/*
Начальный код отображения флажка Irbis http://forum.script-coding.com/viewtopic.php?id=10392&p=3
Использована Acc Standard Library by Sean
*/

SetFormat, float, 0.2
XS:=20, YS:=-4 ; начальные смещения
w0s:=16, h0s:=12
w1s:=21, h1s:=17
DX := XS, DY := YS, zoom:=1, transp:=255, flag:=1, capslock:=1, numlock:=0
Color:={"English":"0x0C0BC0", "Russian":"0xC00C0B"}
cfg:=RegExReplace(A_ScriptName,"\.\w{3}$",".ini")
If FileExist(cfg)
{
   IniRead flag, % cfg, Main, Flag
   IniRead DX, % cfg, Main, DX
   IniRead DY, % cfg, Main, DY
   IniRead zoom, % cfg, Main, Zoom
   IniRead transp, % cfg, Main, Transp
   IniRead capslock, % cfg, Main, CapsLock
   IniRead numlock, % cfg, Main, NumLock
}
else
   SetTimer Settings, -3000

SetNumLockState % numlock ? "On" : "Off"

Menu Tray, NoStandard
Menu Tray, Tip, LangBar++
Menu Tray, Add, Раскладка En ⇔ Ru, LangBar
Menu Tray, Add
Menu Transp, Add, Увеличить, !WheelUp
Menu Transp, Add, Уменьшить, !WheelDown
Menu Transp, Add
Menu Transp, Add, Сбросить, !MButton
Menu Tray, Add, % "Прозрачность (" 100-Round(transp/2.55) "%)", :Transp
Menu Zoom, Add, Увеличить, +WheelUp
Menu Zoom, Add, Уменьшить, +WheelDown
Menu Zoom, Add
Menu Zoom, Add, Сбросить, Zoom
Menu Tray, Add, % "Масштаб (" Round(zoom*100) "%)" , :Zoom
Menu XYPos, Add, Вверх, MoveUp
Menu XYPos, Add, Вниз, MoveDown
Menu XYPos, Add, Вправо, MoveRight
Menu XYPos, Add, Влево, MoveLeft
Menu XYPos, Add
Menu XYPos, Add, Сбросить, PosReset
Menu Tray, Add, % "Положение (x=" DX ", y=" DY ")", :XYPos
Menu Tray, Add
Menu Settings, Add, Флажок раскладки включен, Flag
Menu Settings, Add, Выключение CapsLock, CapsLock
Menu Settings, Add, NumLock включен при запуске , NumLock
Menu Settings, Add
Menu Settings, Add, Сброс всех настроек, Reset
Menu Tray, Add, Настройки, :Settings
Menu Tray, Add, Помощь, Help
Menu Tray, Add
Menu Tray, Add, Выход, Exit
Menu Tray, Click, 1
Menu Tray, Default, 1&

Start:
w0:=w0s*zoom, h0:=h0s*zoom, w1:=w1s*zoom, h1:=h1s*zoom, sx:=4*zoom, sy:=4*zoom
Gui Cancel
Gui -DPIScale
Gui +AlwaysOnTop -Caption +ToolWindow +LastFound +HwndGuiHwnd
Gui Add, Picture,x%sx% y%sy% w%w1% h%h1%, Data\Shadow.png
Gui Add, Picture,x0 y0 w%w0% h%h0% +HwndIconEn, Data\En.png
Gui Add, Picture,x0 y0 w%w0% h%h0% +HwndIconRu, Data\Ru.png
Gui Color, 3F3F3F
WinSet, TransColor, 3F3F3F %transp%

Menu Settings, % flag ? "Check" : "Uncheck", Флажок раскладки включен
Menu Settings, % capslock ? "Uncheck" : "Check", Выключение CapsLock
Menu Settings, % numlock ? "Check" : "Uncheck", NumLock включен при запуске

Menu Tray, Rename, 3&, % "Прозрачность (" 100-Round(transp/2.55) "%)"
Menu Tray, Rename, 4&, % "Масштаб (" Round(zoom*100) "%)"
Menu Tray, Rename, 5&, % "Положение (x=" DX ", y=" DY ")"

SetTimer, WatchCaret, 50

If sub {
   WinGet st, MinMax, ahk_id %lastwin%
   If st!=-1
      WinActivate ahk_id %lastwin%
Sleep 100
If mess {	
   ToolTip % mess, % x+w+15,% y-20, 2
   SetTimer ToolTip, -1000
   mess:=""
}
SetTimer Settings, -3000
return
}
else

sub:=1
endkeys:="{Enter}{NumpadEnter}{Tab}{Esc}{LControl}{RControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}"
Loop
{
   Input text, I V, % endkeys
   If (ErrorLevel="NewInput") && ((A_ThisHotkey~="(Pause|BS)") || rkey) 
   {
      button:=RegExReplace(A_ThisHotkey,".+\+")
      tmp:=Clipboard, rkey:=0, rem:=text 
      SetTimer, WatchCaret, Off
      If StrLen(text)
      {
         While GetKeyState(button,"P") && !(rem~="^\s*$")
         {
            rem_old:=rem, rem:=RegExReplace(rem_old,"\S+\s{0,3}$")
            If (WinActive("ahk_class ConsoleWindowClass")||WinActive("ahk_class VirtualConsoleClass")||(A_ThisHotkey~="BS"))
               Send % "{BS " StrLen(rem_old)-StrLen(rem) "}"
            else
               Send % "{Shift down}{Left " StrLen(rem_old)-StrLen(rem) "}{Shift up}"
            If !(rem~="^\s*$") 
               Sleep 700
         }
         sel:=SubStr(text, StrLen(rem)+1)
         If !(WinActive("ahk_class ConsoleWindowClass")||WinActive("ahk_class VirtualConsoleClass")||(A_ThisHotkey~="BS"))
            Send {Del}            
      }
      else
      {
         tmp:=Clipboard, Clipboard:=""
         Send ^{vk43}
         ClipWait 0.3
         If !Errorlevel
         {
            Send {Del}
            sel:=Clipboard, Clipboard:=tmp
         }
         else 
         {
            Tooltip % "Выделите текст!", % x-80,% y-30
            Clipboard:=tmp
            goto End
         }
      }
      Send % "{Raw}" Translate(sel)
      End:
      Sleep 500
      ToolTip
      SetTimer, WatchCaret, On
   }
}

Pause::
$>+BS::
$<+BS::
~LButton::
~RButton::
~MButton::
~WheelUp::
~WheelDown::
Input
return

CapsLock:
   capslock:=Abs(capslock-1)
   goto Start
   
NumLock:
   numlock:=Abs(numlock-1)
   gosub Settings
   Reload

Flag:
   flag:=Abs(flag-1)
   goto Start

Help:
   Run Help.html
   return

LangBar:
   KeyWait LButton, T1
   Send !{Esc}
   Sleep 100
   ControlGetFocus, CtrlInFocus
   PostMessage, 0x50, 2,, %CtrlInFocus%, A  
   return
   
Return:
   return
   
MoveUp:
   DY-=4
   goto Start
   
MoveDown:
   DY+=4
   goto Start
   
MoveRight:
   DX+=4
   goto Start
   
MoveLeft:
   DX-=4
   goto Start
   
PosReset:
   DX := XS, DY := YS 
   goto Start

Reset:
   MsgBox, 33, LangBar++, Все настройки программы и`nотображение флажка по умолчанию?
   IfMsgBox OK 
   {
      FileDelete LangBarXX.ini
      Reload
   }      
   return
      
Exit:
   gosub Settings
   ExitApp
      
Settings:
   IniWrite % flag, % cfg, Main, Flag
   IniWrite % DX, % cfg, Main, DX
   IniWrite % DY, % cfg, Main, DY
   IniWrite % zoom, % cfg, Main, Zoom
   IniWrite % transp, % cfg, Main, Transp
   IniWrite % capslock, % cfg, Main, CapsLock
   IniWrite % numlock, % cfg, Main, NumLock
   return
   
ToolTip:
   ToolTip,,,, 2
   return

#If (id=GuiHwnd)
LButton::PostMessage, 0x50, 2,,, A

RButton::
   rkey:=1
   Input
   return
   
+WheelUp::
   If zoom<2.5
      zoom+=0.1
   mess:="Масштаб`n  " Round(zoom*100) " %"
   goto Start

+WheelDown::
   If zoom>1
      zoom-=0.1
   mess:="Масштаб`n  " Round(zoom*100) " %"
   goto Start
   
Zoom:
   zoom:=1
   goto Start

!WheelUp::
   If transp>120
      transp-=25.5
   mess:="Прозрачность`n       " 100-Round(transp/2.55) " %"
   goto Start
   
!WheelDown::
   If transp<250
      transp+=25.5
   mess:="Прозрачность`n      " 100-Round(transp/2.55) " %"
   goto Start
   
!MButton::
   transp:=255
   mess:="Прозрачность`n      " 100-Round(transp/2.55) " %"
   goto Start
      
+MButton::
   DX := XS, DY := YS, zoom:=1, transp:=255
   mess:="Флажок`nпо умолчанию!"
   goto Start

+LButton::
   SetTimer, WatchCaret, Off
   MouseGetPos, x0, y0
   WinGetPos xc, yc,,, ahk_id %GuiHwnd%
   xc-=x0, yc-=y0
   While GetKeyState("Lbutton", "P")
   {
      sleep 10
      MouseGetPos, xn, yn
      WinMove, ahk_id %GuiHwnd%,, xc+xn, yc+yn
   }
   DX+=xn-x0, DY+=yn-y0
   mess:="Положение`nx=" DX " y=" DY
   goto Start
#If
 
WatchCaret:
   MouseGetPos,,,id
   WinGetClass cl, A
   If cl not in Shell_TrayWnd,#32768
      lastwin:=WinExist("A")
   Control, % (InputLayout()="English") ? "Hide" : "Show",,,ahk_id %IconRu%
   w := GetKeyState("CapsLock", "T") ? w1 : w0
   h := GetKeyState("CapsLock", "T") ? h1 : h0  
   (A_CaretX = "" && Acc_ObjectFromPoint())
   _x:=A_CaretX, _y:=A_CaretY   
   If !_x {
      Acc_Caret := Acc_ObjectFromWindow(WinExist("A"), OBJID_CARET := 0xFFFFFFF8)
      Caret_Location := Acc_Location(Acc_Caret)
      _x:=Caret_Location.x, _y:=Caret_Location.y
   }      
   If flag && _x && _y
         Gui, % (x:=_x+DX)&&(y:=_y+DY)&&(GuiHwnd!=WinExist("A")) ? "Show" : "Hide", x%x% y%y% w%w% h%h% NA
   else
      Gui Cancel
   If !capslock     
      SetCapsLockState Off
   
   numstate:=numlock ? !GetKeyState("NumLock","T") : GetKeyState("NumLock","T")
   nl:=numstate ? "_" : ""

   Menu Tray, Icon, % (InputLayout()="English") ? "Data\" nl "EN.ico" : "Data\" nl "RU.ico"
   return

;----------------------------------------

InputLayout(window := "A") {
   If !(hWnd := WinExist(window))
      return
   WinGetClass, Class
   if (Class == "ConsoleWindowClass"){
       WinGet, consolePID, PID
       DllCall("AttachConsole", Ptr, consolePID)
       VarSetCapacity(buff, 16)
       DllCall("GetConsoleKeyboardLayoutName", Str, buff),
       DllCall("FreeConsole")
       langID := "0x" . SubStr(buff, -3)
   }
   Else langID := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr), Ptr) & 0xFFFF
   Size := (DllCall("GetLocaleInfo", UInt, langID, UInt, 0x1001, UInt, 0, UInt, 0) * 2)   ; LOCALE_SENGLANGUAGE := 0x1001
   VarSetCapacity(localeSig, Size, 0)
   DllCall("GetLocaleInfo", UInt, langID, UInt, 0x1001, Str, localeSig, UInt, Size)
   return localeSig
}

Translate(text)
{
	Eng:="~QWERTYUIOP{}ASDFGHJKL:""ZXCVBNM<>?|``qwertyuiop[]asdfghjkl;'zxcvbnm,./@#$^&"
	Rus:="ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,/ёйцукенгшщзхъфывапролджэячсмитьбю.""№;:?"
	Loop, parse, text, ,`r
	{ 		
		If p:=InStr(InputLayout()="English" ? Eng : Rus, A_LoopField, true) 
			r:=r . SubStr(InputLayout()="English" ? Rus : Eng, p, 1)
		else
			r.=A_LoopField 
	}
	ControlGetFocus CtrlFocus, A
	SendMessage, 0x50,, % InputLayout()="English" ? 0x4190419 : 0x4090409, % CtrlFocus, A
	return r
}

; ----------- Acc Standard Library by Sean --------------

Acc_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}

Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "")
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
	Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject = -4)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return	ComObjEnwrap(9,pacc,1)
}

Acc_Location(Acc, ChildId=0, byref Position="") { ; adapted from Sean's code
	try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
	catch
		return
	Position := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
	return	{x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")}
}

