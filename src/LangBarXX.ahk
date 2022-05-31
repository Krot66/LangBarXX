#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 99999999
SetWinDelay -1
SetBatchLines -1
CoordMode Caret
CoordMode Tooltip
CoordMode Mouse
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
SetTitleMatchMode Slow	
Process Priority,, A 

/* 
Использованы:
Начальный код отображения флажка Irbis http://forum.script-coding.com/viewtopic.php?id=10392&p=3
Gdip library by Tic
Acc Standard Library by Sean
*/


SetFormat, float, 0.2
XS:=8, YS:=-12 ; смещения по умолчанию
width:=20
; Умолчания
Defaul_values:
DX:=XS, DY:=YS, transp:=255, flag:=1, capslock:=1, numlock_on:=0, numlock_icon:=1, scrolllock:=1, scrolllock_icon:=1, icon_shift:=1, aspect:=1, symbsel:=0 , wait:=250, symbint:=280, wordint:=750, startonly:=0, pause:=1, max_send:=60
If reset
	Return
FileCreateDir flags
FileCreateDir masks
Loop Parse, % "flags\en-Us.png,flags\ru-RU.png,flags\00.png,masks\NumLock.png,masks\ScrollLock.png,masks\NumScroll.png", CSV
{
	If !FileExist(A_LoopField)
		no_files.=A_LoopField ", "
}
If no_files {
	MsgBox, 16, , % "Отсутствуют файлы: " no_files, 3
	ExitApp
}

cfg:=RegExReplace(A_ScriptName,"(64)?\.\w{3}$",".ini")
If !FileExist("portable.dat") {
	FileCreateDir % A_AppData "\LangBarXX"
	cfg:=A_AppData "\LangBarXX\" cfg
}
If FileExist(cfg) {
	IniRead flag, % cfg, Main, Flag
	IniRead pause, % cfg, Main, Pause
	IniRead DX, % cfg, Main, DX
	IniRead DY, % cfg, Main, DY
	IniRead width, % cfg, Main, Width
	IniRead transp, % cfg, Main, Transp 	
	IniRead icon_shift, % cfg, Main, Icon_Shift
	IniRead aspect, % cfg, Main, Aspect	
	IniRead capslock, % cfg, Main, CapsLock
	IniRead numlock_on, % cfg, Main, NumLock_On
	IniRead numlock_icon, % cfg, Main, NumLock_Icon
	IniRead scrolllock, % cfg, Main, ScrollLock
	IniRead scrolllock_icon, % cfg, Main, ScrollLock_Icon
	IniRead symbsel, % cfg, Main, SymbSel
	IniRead startonly, % cfg, Main, StartOnly
	IniRead wait, % cfg, Main, Wait
	IniRead symbint, % cfg, Main, SymbInt
	IniRead wordint, % cfg, Main, WordInt
	IniRead max_send, % cfg, Main, Max_send
}
SetTimer Settings, 10000
If numlock_on 
	SetNumLockState On

Menu Tray, NoStandard
Menu Tray, Tip, LangBar++
Menu Tray, Add, Смена раскладки, LangBar 
Menu Tray, Default, 1&
Menu Tray, Add, Флажок (Shift+Shift), Flag
Menu Tray, Add, Файл флажка, FlagFile
Menu Tray, Add, Настройка флажка, FlagSettings
Menu Tray, Add

Menu CapsLock, Add, Без изменений, CapsLockState
Menu CapsLock, Add, То же и инверсия регистра, CapsLockState
Menu CapsLock, Add, Только инверсия регистра, CapsLockState
Menu CapsLock, Add
Menu CapsLock, Add, Выключен, CapsLockState
Menu CapsLock, Add, Как Shift, CapsLockState
Menu CapsLock, Add, Переключение раскладки, CapsLockState
Menu CapsLock, Add, Исправление раскладки, CapsLockState
Menu Tray, Add, CapsLock, :CapsLock

Menu NumLock, Add, Включен по умолчанию, NumLock
Menu NumLock, Add
Menu NumLock, Add, Отображать на иконке, NumLock_Icon
Menu Tray, Add, NumLock, :NumLock

Menu ScrollLock, Add, Выключен, ScrollLock
Menu ScrollLock, Add
Menu ScrollLock, Add, Отображать на иконке, ScrollLock_Icon
Menu Tray, Add, ScrollLock, :ScrollLock
Menu Tray, Add

Menu Tray, Add, ScrollLock, :ScrollLock
Menu Icon, Add, Пропорция 5:4, Aspect
Menu Icon, Add, Пропорция 4:3, Aspect
Menu Icon, Add, Пропорция 3:2, Aspect
Menu Tray, Add, Иконка в трее, :Icon

Menu Select, Add, Посимвольное выделение, SymbSel
Menu Select, Add, Только с начала, StartOnly
Menu Select, Add,
Menu Select, Add, Задержки выделения, GUI
Menu Tray, Add, Выделение, :Select

Menu Autorun, Add, Включить, Autorun
Menu Tray, Add, Автозапуск, :Autorun

Menu Tray, Add, Помощь, Help
Menu Tray, Add
Menu Tray, Add, Сброс настроек, Reset
Menu Tray, Add
Menu Tray, Add, Перезапуск, Reload
Menu Tray, Add, Выход, Exit
Menu Tray, Click, 1

If A_IsCompiled {
	Menu, Tray, Icon, 3&, % A_ScriptFullPath, 2
	Menu, Tray, Icon, 6&, % A_ScriptFullPath, 3
	Menu, Tray, Icon, 7&, % A_ScriptFullPath, 3
	Menu, Tray, Icon, 8&, % A_ScriptFullPath, 3	
	Menu, Tray, Icon, 13&, % A_ScriptFullPath, 4
	Menu, Tray, Icon, 17&, % A_ScriptFullPath, 5
	Menu, Tray, Icon, 18&, % A_ScriptFullPath, 6
}

Start:
Menu Tray, % flag ? "Check" : "Uncheck", 2&

Menu CapsLock, % capslock=1 ? "Check" : "Uncheck", 1&
Menu CapsLock, % capslock=4 ? "Check" : "Uncheck", 2&
Menu CapsLock, % capslock=5 ? "Check" : "Uncheck", 3&
Menu CapsLock, % capslock=0 ? "Check" : "Uncheck", 5&
Menu CapsLock, % capslock=-1 ? "Check" : "Uncheck", 6&
Menu CapsLock, % capslock=2 ? "Check" : "Uncheck", 7&
Menu CapsLock, % capslock=3 ? "Check" : "Uncheck", 8&

Menu NumLock, % numlock_on ? "Check" : "Uncheck", 1&
Menu NumLock, % numlock_icon ? "Check" : "Uncheck", 3&

Menu ScrollLock, % !scrolllock ? "Check" : "Uncheck", 1&
Menu ScrollLock, % scrolllock_icon ? "Check" : "Uncheck", 3&

Menu Icon, % (aspect=2) ? "Check" : "Uncheck", 1&
Menu Icon, % (aspect=1) ? "Check" : "Uncheck", 2&
Menu Icon, % !aspect ? "Check" : "Uncheck", 3&

Menu Select, % symbsel ? "Check" : "Uncheck", Посимвольное выделение
Menu Select, % startonly ? "Check" : "Uncheck", Только с начала

RegRead lb_autorun, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, LangBarXX
Menu Autorun, Rename, 1&, % (lb_autorun="""" A_ScriptFullPath """") ? "Включен" : "Включить"
Menu Autorun, % (lb_autorun="""" A_ScriptFullPath """") ? "Check" : "Uncheck", 1&

If !capslock
	SetCapsLockState AlwaysOff
If numlock_on 
	SetNumLockState On
If !scrolllock
	SetScrollLockState AlwaysOff

wait_button:=wait/1000, wait_button2:=wordint/2000, wait_button3:=wordint/1000


If A_IsCompiled && (A_IsAdmin || (A_OSVersion="WIN_XP")) && FileExist("LB_WatchDog.exe"){
	Gosub LB_WatchDog
	SetTimer LB_WatchDog, 60000
}

RegRead lcode, HKEY_CURRENT_USER\Keyboard Layout\Preload, 1
lang_old:=LangCode("0x" SubStr(lcode,-3))
Sleep 100
Gosub CapsLockFlag
SetTimer TrayIcon, 250
Sleep 25
SetTimer WatchCaret, 50

endkeys:="{Enter}{NumpadEnter}{Tab}{Esc}{LControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}"
Loop {
	Input text, I V, % endkeys
	If (ErrorLevel="NewInput") && (A_ThisHotkey~="(Pause|BS|CapsLock|=|-|0|9|vkDD|RButton)") {
		If StrLen(text) {
			Hotkey % "*" button, Return, On			
			rem:=text, sending:=0
			If (WinActive("ahk_class ConsoleWindowClass") || WinActive("ahk_class VirtualConsoleClass") || WinActive("ahk_exe WindowsTerminal.exe") || (A_ThisHotkey~="BS"))
			sending:=1
			While GetKeyState(button,"P") && !(rem~="^\s*$") {
				rem_old:=rem, rem:=per_symbol_select ? RegExReplace(rem_old,".$") : RegExReplace(rem_old,"\S+\s{0,3}$")
				If sending
					Send % "{BS " StrLen(rem_old)-StrLen(rem) "}"				
				Else {
					If (A_Index=1)
						Send {Shift down}
					Send % "{Left " StrLen(rem_old)-StrLen(rem) "}"
				}
				If !(rem~="^\s*$") {
					If per_symbol_select
						Sleep % symbint
					Else If (symbsel && !startonly) {
						KeyWait % button, T%wait_button2%
						If !Errorlevel {
							KeyWait % button, D T%wait_button2%
							If ErrorLevel
								break
							per_symbol_select:=1
							Sleep 300
						}
					}
					Else
						Sleep % wordint
				}
			}
			sel:=SubStr(text, StrLen(rem)+1)
			KeyWait % button, T1
		}
		Else {
			sel:=sel ? sel : CopyText()
			If sel && !(sel~="^\w:\\.+")
				Send {Del}
			Else If (capslock!=4) {
				Tooltip % "Выделите текст!", % x-80,% y-30
				SetTimer ToolTip, -700
				Goto End
			}
		}
		Hotkey % "*" button, Return, Off
		Send {Shift up}
		If !sel
			Goto End
		If (A_ThisHotkey~="=") || ((A_ThisHotkey~="CapsLock") && (capslock>3))
			SetText(ChangeCase(sel,3),sending,max_send)
		Else If (A_ThisHotkey~="-")
			SetText(ChangeCase(sel,2),sending,max_send)
		Else If (A_ThisHotkey~="0")
			SetText(ChangeCase(sel,1),sending,max_send)
		Else If (A_ThisHotkey~="9")
			SetText(ChangeCase(sel,0),sending,max_send)
		Else If (A_ThisHotkey~="vkDD") {
			SetText(Translit(sel),sending,max_send)
			Sleep 100
			If (InputLayout()~="0x0419") {
				ControlGetFocus, CtrlInFocus
				PostMessage, 0x50, 2,, %CtrlInFocus%, A
			}
		}
		Else 
		    SetText(Translate(sel),sending,max_send)
		End:
		per_symbol_select:=0, sel:=""
		Hotkey % "*" button, Return, Off
		Hotkey *Bs, Return, Off
		If (A_ThisHotkey~="(=|-|0|9|CapsLock)")
			SetCapsLockState Off 
		}
	Else If (ErrorLevel~="EndKey")	
		wheel:=0
	Sleep 100	
}
Return

#If capslock=-1
CapsLock::Shift

#If !capslock
CapsLock::
	If GetKeyState("CapsLock","T")
		SetCapsLockState AlwaysOff
	Return

#If (capslock=2)
CapsLock::
	KeyWait CapsLock, T1
	ControlGetFocus, CtrlInFocus
	PostMessage, 0x50, 2,, %CtrlInFocus%, A
	SetCapsLockState AlwaysOff
	Return

#If (capslock=3)
CapsLock::
	If !(InputLayout()~="(0x0409|0x0419)")
		Return
	Goto Hotkey
		
#If (capslock=4)
~CapsLock::
	KeyWait CapsLock, T0.2
	If ErrorLevel
		Goto Hotkey
	Return
	
#If (capslock=5)
CapsLock::		
	Goto Hotkey
#If

$>^=::
Hotkey *Bs, Return, On
$>^-::
$>^0::
$>^9::
$>^vkDD::
Goto Hotkey

#If (InputLayout()~="(0x0409|0x0419)") && pause
Pause::Goto Hotkey
#If (InputLayout()~="(0x0409|0x0419)")
$>+BS::
$<+BS::
#If

Hotkey:
	If WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || (A_PriorHotkey=A_ThisHotkey && A_TimeSincePriorHotkey<50)
		Return
	button:=RegExReplace(A_ThisHotkey,"^.*(\^|\+|!)")
	If symbsel {
		KeyWait % button, T%wait_button%
		If !Errorlevel {
			KeyWait % button, D T0.3
			If ErrorLevel
				Return
			per_symbol_select:=1
		}
	}
	Sleep 50
	Input
	Return
	
#If !OnTaskBar() && !(id=GuiHwnd)	
~*LButton::
	Input
	Sleep 100
	wheel:=0
	Return

~*MButton::
	Input
	Return

#If

~*WheelUp::
~*WheelDown::
~*WheelRight::
~*WheelLeft::
	Input
	If !wheel && (A_PriorHotkey~="Wheel") && (A_TimeSincePriorHotkey<2000) && (cl~="^(ApplicationFrameWindow|Chrome_WidgetWin_\d|MozillaWindowClass|Slimjet_WidgetWin_1)") {
		x_wheel:=_x, y_wheel:=_y
		Sleep 100
		Gui Hide
		wheel:=1
	}		
	Return

OnTaskBar() {
	MouseGetPos,,, win_id
	WinGetClass class, ahk_id %win_id%
	Return (class="Shell_TrayWnd") ? 1 : 0
}

Return:
	Return

CapsLockState:
	If (A_ThisMenuItem="Без изменений")
		capslock:=1
	If (A_ThisMenuItem="Выключен")
		capslock:=0
	If (A_ThisMenuItem="Как Shift")
		capslock:=-1
	If (A_ThisMenuItem="Переключение раскладки")
		capslock:=2
	If (A_ThisMenuItem="Исправление раскладки")
		capslock:=3
	If (A_ThisMenuItem="То же и инверсия регистра")
		capslock:=4
	If (A_ThisMenuItem="Только инверсия регистра")
		capslock:=5
	Gosub Settings
	Sleep 100
	Reload
	Return
   
NumLock:
	numlock_on:=!numlock_on
	Gosub Settings
	Reload
	Return
	
NumLock_Icon:
	numlock_icon:=!numlock_icon
	Gosub Settings
	Reload
	Return
	
ScrollLock:
	scrolllock:=!scrolllock
	Gosub Settings
	Reload
	Return
	
ScrollLock_Icon:
	scrolllock_icon:=!scrolllock_icon
	Gosub Settings
	Reload
	Return
	
Aspect:
	aspect:=1
	If (A_ThisMenuItem~="5")
		aspect:=2
	If (A_ThisMenuItem~="2")
		aspect:=0
	Gosub Settings
	Reload
	Return
  
SymbSel:
	symbsel:=symbsel ? 0 : 1
	Goto Start
   
StartOnly:
	startonly:=startonly ? 0 : 1
	Goto Start
	
Reset:
	CheckText := "*Сохранить копию текущих"
	msg:="Все настройки к значениям по умолчанию?`nКнопка 'Бэкап' сохраняет копию без сброса."
	Result := MsgBoxEx(msg, "LangBar++", "OK|Бэкап|Cancel*", 4, CheckText, "AlwaysOnTop", 0, 0, "s11 c0x000000", "Arial", "0xA0CDEB")
	If (Result =="Cancel")
		Return
	If (Result == "OK") {
		If CheckText
			FileCopy % cfg, % "LangBarXX_" A_YYYY "." A_MM "." A_DD "_" A_Hour "." A_Min "." A_Sec ".ini"
		FileDelete % cfg
		Reload
	}
	If (Result == "Бэкап")
		FileCopy % cfg, % "Backup_" A_YYYY "." A_MM "." A_DD "_" A_Hour "." A_Min "." A_Sec ".ini"
		If !ErrorLevel {
			ToolTip Бэкап сохранен`nв папке программы!
			SetTimer ToolTip, -2000
		}
	Return
	
#If WinActive("LangBar++ ahk_class AutoHotkeyGUI")
Esc::WinClose LangBar++ ahk_class AutoHotkeyGUI
#If

Help:
	Run ReadMe.html
	Return
   
Reload:
	Reload	Return
      
Exit:
	Gdip_Shutdown(pToken)
	Process Exist, LB_WatchDog.exe
	If ErrorLevel
		Process Close, LB_WatchDog.exe
	Gosub Settings
	ExitApp
	
Autorun:
	RegRead lb_autorun, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, LangBarXX
	If (lb_autorun!="""" A_ScriptFullPath """")
		RegWrite Reg_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, LangBarXX, % """" A_ScriptFullPath """"
	Else
		RegDelete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, LangBarXX
	Reload
	Return
	
LB_WatchDog:
	Process Exist, LB_WatchDog.exe
	If !ErrorLevel {
		If (A_OSVersion="WIN_XP")
			Run % "LB_WatchDog.exe " A_ScriptName, % A_ScriptDir		
		Else
			Run % "*RunAs LB_WatchDog.exe " A_ScriptName, % A_ScriptDir
	}		
	Return
	
     
Settings:
	IniWrite % flag, % cfg, Main, Flag
	IniWrite % pause, % cfg, Main, Pause
	IniWrite % DX, % cfg, Main, DX
	IniWrite % DY, % cfg, Main, DY
	IniWrite % width, % cfg, Main, Width
	IniWrite % transp, % cfg, Main, Transp
	IniWrite % icon_shift, % cfg, Main, Icon_Shift
	IniWrite % aspect, % cfg, Main, Aspect
	IniWrite % capslock, % cfg, Main, CapsLock
	IniWrite % numlock_on, % cfg, Main, NumLock_On
	IniWrite % numlock_icon, % cfg, Main, NumLock_Icon
	IniWrite % scrolllock, % cfg, Main, ScrollLock
	IniWrite % scrolllock_icon, % cfg, Main, ScrollLock_Icon
	IniWrite % symbsel, % cfg, Main, SymbSel
	IniWrite % startonly, % cfg, Main, StartOnly
	IniWrite % wait, % cfg, Main, Wait
	IniWrite % symbint, % cfg, Main, SymbInt
	IniWrite % wordint, % cfg, Main, WordInt
	IniWrite % max_send, % cfg, Main, Max_send
	Return
   
ToolTip:
	ToolTip
	ToolTip,,,, 2
	Return
   
LangBar:
	SetTimer WatchCaret, Off
	KeyWait LButton, T1
	Sleep 50
	If lastwin && WinExist("ahk_id" lastwin) {
		WinGet st, MinMax, ahk_id %lastwin%
		If (st!=-1) {
			WinActivate ahk_id %lastwin%
			WinWaitActive ahk_id %lastwin%
		}
	}
	Else {
		WinActivate ahk_class Progman
		WinWaitActive ahk_class Progman		
	}
	ControlGetFocus, CtrlInFocus
	PostMessage, 0x50, 2,, %CtrlInFocus%, A
	SetTimer WatchCaret, On
	If (A_ThisLabel="ChangeLanguage")
		WinSet Top,, ahk_id %lastwin%
	Critical Off
	Return

<+RShift::
>+LShift::
Flag:
	flag:=!flag
	Menu Tray, % flag ? "Check" : "Uncheck", 2&
	Return
	
~#Space up::
	KeyWait LWin	
~<^LShift up::
~>^RShift up::
~!Shift up::
	Critical On
	SetTimer TrayIcon, Off
	SetTimer WatchCaret, Off
	lang_old:=caps_old:=""
	Critical Off
	Gosub CapsLockFlag
	SetTimer TrayIcon, 250
	Sleep 25
	SetTimer WatchCaret, 50
	Return
	
#If (id=GuiHwnd)
Lbutton::
	SetTimer WatchCaret, Off
	ControlGetFocus, CtrlInFocus, A
	PostMessage, 0x50, 2,, %CtrlInFocus%, A
	Critical Off
	SetTimer WatchCaret, On
	Return
	
RButton::
	Input
	Return

+WheelUp::
	If (width<64)
		width+=2, mess:="Ширина " width " px"	
Pos:
	If WinActive("ahk_id" Gui2) {
		GuiControl Focus, Edit1
		Sleep 100
	}
	ToolTip % mess, % x+width+15,% y-20, 2
	SetTimer ToolTip, -1500
	WinSet, TransColor, 3F3F3F %transp%, ahk_id %GuiHwnd%
	If !WinActive("ahk_id" Gui2 )
		MouseMove % x+width//2, % y+width*3//8
	Return

+WheelDown::
	If (width>16)
		width-=2, mess:="Ширина " width " px"	
	Goto Pos

!WheelUp::
	If (transp>120)
		transp-=25.5, mess:="Прозрачность`n       " 100-Round(transp/2.55) " %"	
	Goto Pos
   
!WheelDown::
	If (transp<250)
		transp+=25.5, mess:="Прозрачность`n      " 100-Round(transp/2.55) " %"	
	Goto Pos
   
!MButton::
	transp:=255, mess:="Прозрачность`n      " 100-Round(transp/2.55) " %"
	Goto Pos
      
+MButton::
	DX:=XS, DY:=YS, width:=20, transp:=255, mess:="Флажок по`nумолчанию!"
	Goto Pos

+LButton::
	Critical
	MouseGetPos, x0, y0
	WinGetPos xc, yc,,, ahk_id %GuiHwnd%
	xc-=x0, yc-=y0
	While GetKeyState("Lbutton", "P") {
		sleep 10
		MouseGetPos, xn, yn
		WinMove, ahk_id %GuiHwnd%,, xc+xn, yc+yn
	}
	Critical Off
	DX+=xn-x0, DY+=yn-y0, mess:="Положение`nx=" DX ", y=" DY
	Goto Pos
#If
	
FlagGui:
	Gui Destroy
	Gui -DPIScale
	Gui +AlwaysOnTop -Caption +ToolWindow +LastFound +HwndGuiHwnd
	Gui Add, Picture, x0 y0 w96 h64 +HwndCapsID
	Gui Add, Picture, x0 y0 w96 h64 +HwndFlagID
	Gui Color, 3F3F3F
	WinSet, TransColor, 3F3F3F %transp%
	Return
	
CapsLockFlag:
	pToken:=Gdip_Startup()
	pCaps:=Gdip_CreateBitmap(16, 12) 
	G:=Gdip_GraphicsFromImage(pCaps)
	caps_color:="0xAA00E5E5"
	Brush:=Gdip_BrushCreateSolid(caps_color)
	Gdip_FillRectangle(G ,Brush, -1, -1, 18, 14)
	Gdip_DeleteBrush(Brush)       
	Gdip_DrawImage(G, pCaps, 0, 0, 16, 12, 0, 0, 16, 12)	
	CapsHandle:=Gdip_CreateHBITMAPFromBitmap(pCaps)
	Gdip_DeleteGraphics(G)
	Return
	

TrayIcon:
	WinGetClass cl, A
	lang_hex:=InputLayout()
	If !(lang:=LangCode(lang_hex))
		lang:=lang_old
	flag_png:="flags\" lang ".png"
	If !FileExist(flag_png)
		flag_png:="flags\00.png"
	num:=GetKeyState("NumLock","T"), scr:=GetKeyState("ScrollLock","T")
	If lang && ((lang!=lang_icon_old)||(num!=num_old)||(scr!=scr_old)) {
		pFlag:=Gdip_CreateBitmapFromFile(flag_png)
		pNumLock:=(numlock_icon && (scrolllock_icon && scrolllock)) ? Gdip_CreateBitmapFromFile("masks\NumLock.png") : Gdip_CreateBitmapFromFile("masks\NumScroll.png")
		pScrollLock:=(numlock_icon && (scrolllock_icon && scrolllock)) ? Gdip_CreateBitmapFromFile("masks\ScrollLock.png") : Gdip_CreateBitmapFromFile("masks\NumScroll.png")

		Gdip_GetImageDimensions(pFlag, w_flag, h_flag)
		size:=w_flag
		;size:=64
		Gdip_GetImageDimensions(pNumLock, w_numlock, h_numlock)
		Gdip_GetImageDimensions(pScrollLock, w_scrolllock, h_scrolllock)
		pMem:=Gdip_CreateBitmap(size, size)
		G:=Gdip_GraphicsFromImage(pMem)
		Gdip_SetSmoothingMode(G, 2)
		Gdip_SetInterpolationMode(G, 7)

		hf2:=!aspect ? size*2//3 : ((aspect=1) ? size*3//4 : size*4//5)
		shift:=(size-hf2)//2
		If (num && numlock_icon) || (scr && scrolllock_icon)
			shift:=(icon_shift=0) ? (size-hf2)//2 : ((icon_shift=1) ? size-hf2 : 0)			
		Gdip_DrawImage(G, pFlag, 0, shift, size, hf2, 0, 0, w_flag, h_flag)
		If num && numlock_icon
			Gdip_DrawImage(G, pNumLock, 0, 0, size, size, 0, 0, w_numlock, h_numlock)
		If scr && scrolllock_icon
			Gdip_DrawImage(G, pScrollLock, 0, 0, size, size, 0, 0, w_scrolllock, h_scrolllock)
		DllCall("DestroyIcon", "ptr", IconHandle)
		IconHandle:=Gdip_CreateHICONFromBitmap(pMem)
		Gdip_DisposeImage(pFlag)
		Gdip_DisposeImage(pNumLock)
		Gdip_DisposeImage(pScrollLock)
		Gdip_DeleteGraphics(G)
		Menu Tray, Icon, hicon:*%IconHandle%
		lang_icon_old:=lang, num_old:=num, scr_old:=scr
	}	
	Return

WatchCaret:
	WinGetClass cl, A
	If cl not in Shell_TrayWnd,#32768
		lastwin:=WinExist("A")
	If lastwin && (lastwin!=lastwin_old) {	
		Critical On
		Gui Hide
		Sleep 300
		Gosub TrayIcon
		Critical Off
	}
	DetectHiddenWindows On
	If !WinExist("ahk_id" GuiHwnd)
		Gosub FlagGui
	DetectHiddenWindows Off
	caret:=GetCaretLocation(), _x:=caret[1], _y:=caret[2], x:=_x+DX, y:=_y+DY
	If wheel && (_x=x_wheel) && (_y=y_wheel)	
		Return
	Hotkey *Bs, Return, Off
	MouseGetPos,,, id
	caps:=GetKeyState("CapsLock","T")
	
	If flag {
		If (lang!=lang_old) || (width!=width_old) {
			pFlag:=Gdip_CreateBitmapFromFile(flag_png)
			Gdip_GetImageDimensions(pFlag, wf, hf)
			fl_h:=width*3//4, mn=(width>48) ? 2 : 1 ; Величина полей
			pBitmap:=Gdip_CreateBitmap(width+mn*2, fl_h+mn*2)
			G:=Gdip_GraphicsFromImage(pBitmap)
			Gdip_SetSmoothingMode(G, 2)
			Gdip_SetInterpolationMode(G, 7)
			
			Brush:=Gdip_BrushCreateSolid(0x33000000)
			Gdip_FillRectangle(G ,Brush, -1, -1, width+mn*2+2, fl_h+mn*2+2)
			Gdip_DeleteBrush(Brush)       
			Gdip_DrawImage(G, pBitmap, 0, 0, width+mn*2, fl_h+mn*2, 0, 0, width+mn*2, fl_h+mn*2)
			Gdip_DrawImage(G, pFlag, mn, mn, width, fl_h, 0, 0, wf, hf)
			DllCall("DeleteObject", "ptr", FlagHandle)
			FlagHandle:=Gdip_CreateHBITMAPFromBitmap(pBitmap) 
			GuiControl,, %FlagID%, *w%width% *h%fl_h% hbitmap:*%FlagHandle%
			Gdip_DisposeImage(pBitmap)
			Gdip_DisposeImage(pFlag)
			Gdip_DeleteGraphics(G)
			
		}
		If _x && _y && (GuiHwnd!=WinExist("A")){
			If (caps!=caps_old)  || (width!=width_old) {
				If caps {
					GuiControl,, %CapsID%, *w%width% *h-1 hbitmap:*%CapsHandle%
					GuiControl Move, % CapsID, % "x" width//3 "y" width//4
					GuiControl Show, % CapsID
				}				
				Else {
					GuiControl Move, % CapsID, % "x" x "y" y
					GuiControl Hide, % CapsID
				}
				caps_old:=caps
			}
			Gui Show, x%x% y%y% NA, % lang
			WinRestore ahk_id %GuiHwnd%
			WinSet Top,, ahk_id %GuiHwnd%
			lang_old:=lang, width_old:=width
		}			
		Else
			Gui Hide	
		DetectHiddenWindows Off
	}
	If !flag
		Gui Hide	
	x_old:=x, y_old:=y, lastwin_old:=lastwin
	Return
   	
FlagFile:
	KeyWait LButton, T1
	Sleep 200
	If !WinExist("A") {
		Send !{Esc}
		Sleep 300		
	}
	flagfile:=LangCode(InputLayout()) ".png"
	If (flagfile=".png") {
		ToolTip Определение раскладки`nтребует активного окна!
		SetTimer ToolTip, -2000
		Return
	}
	msg:="Для отображения раскладки " . (FileExist("flags\" flagfile) ? "используется" : "необходим") . "`nфайл """ flagfile """ в каталоге flags!"
	CheckText := "*Копировать имя файла"
	
	Result := MsgBoxEx(msg, "LangBar++", "Папка|Cancel*", 5, CheckText, "AlwaysOnTop", 0, 0, "s11 c0x000000", "Arial", "0xA0CDEB")
	If (Result == "Папка") {
		Run % "explorer.exe " A_ScriptDir "\flags"	
	}
	If CheckText{
		Clipboard:=flagfile
		ToolTip Имя файла в буфере!
		SetTimer ToolTip, -1500
	}
	Return

FlagSettings:	
	Gui 2:Destroy
	Gui 2:-DPIScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui2
	Gui 2:Font, s13 Arial 
	Gui 2:Color, 77A4C2
	Gui 2:Add, Edit, w382 r3, % comment
	Gui 2:Font, s10
	Gui 2:Add, Button, w122 h40 section g+WheelDown, Ширина -
	Gui 2:Add, Button, wp hp x+8 yp gUp, Вверх
	Gui 2:Add, Button, wp hp x+8 yp g+WheelUp, Ширина +
	
	Gui 2:Add, Button, wp hp xs y+8 gLeft, Влево
	Gui 2:Add, Button, wp hp x+8 yp g+Mbutton, Сброс
	Gui 2:Add, Button, wp hp x+8 yp gRight, Вправо
	
	Gui 2:Add, Button, wp hp xs y+8 g!WheelDown, Прозр-ть -
	Gui 2:Add, Button, wp hp x+8 yp gDown, Вниз
	Gui 2:Add, Button, wp hp x+8 yp g!WheelUp, Прозр-ть +
	
	Gui 2:Show,, Настройка флажка
	SendInput % "^{Home}{Enter}{Raw}                   Текст"
	Return
	
2GuiClose:
	Gui 2:Destroy
	Gosub Settings
	Return

#If WinActive("ahk_id" Gui2)
Esc::Goto 2GuiClose
#If

Up:
	DY-=2, mess:="Положение`nx=" DX ", y=" DY
	Goto Pos
   
Down:
	DY+=2, mess:="Положение`nx=" DX ", y=" DY
	Goto Pos
   
Right:
	DX+=2, mess:="Положение`nx=" DX ", y=" DY
	Goto Pos
   
Left:
	DX-=2, mess:="Положение`nx=" DX ", y=" DY
	Goto Pos	

#If
	
GUI:
	_wait:=wait, _symbint:=symbint, _wordint:=wordint
Def:
	Gui 9:Destroy
	Gui 9:-DPIScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui9
	Gui 9:Font, s10 Arial 
	Gui 9:Color, 77A4C2
	Gui 9:Add, GroupBox, x16 w480 h90, Интервал выделения "по словам"
	Gui 9:Add, Slider, xp10 yp+40 section w370 v_wordint gWordint Range300-1000 ToolTip, % _wordint
	Gui 9:Add, Text, ys, %_wordint% мс
	Gui 9:Add, GroupBox, x16 w480 h90, Ожидание отпускания клавиши
	Gui 9:Add, Slider,xp10 yp+40 section w370 v_wait gWait Range160-320 ToolTip2, % _wait
	Gui 9:Add, Text, ys, %_wait% мс
	Gui 9:Add, GroupBox, x16 w480 h90, Интервал посимвольного выделения
	Gui 9:Add, Slider, xp10 yp+40 section w370 v_symbint gSymbint Range120-360 ToolTip3, % _symbint 
	Gui 9:Add, Text, ys, %_symbint% мс
	Gui 9:Add, Button, x50 yp+70 w100 h32 section g9GuiClose, Cancel
	Gui 9:Add, Button, x+6 ys w200 hp gDefaults, По умолчанию
	Gui 9:Add, Button, x+6 ys w100 hp gOK, OK
	Gui 9:Show,, Задержки выделения	
	Return

Wordint:
	GuiControl,, Static1, %_wordint% мс
	Return

Wait:
	GuiControl,, Static2, %_wait% мс
	Return
	
Symbint:
	GuiControl,, Static3, %_symbint% мс
	Return
		
Defaults:
	_wait:=220, _symbint:=250, _wordint:=700
	Goto Def
		
OK:
	Gui 9:Submit
	wait:=_wait, symbint:=_symbint, wordint:=_wordint
	Goto Settings

9GuiClose:
	Gui 9:Destroy
	Return

#If WinActive("ahk_id" Gui9 )
Esc::Goto 9GuiClose

WheelUp::
WheelDown::
	Return
#If
;----------------------------------------
CopyText() {
	tmp:=Clipboard, Clipboard:=""
	Send ^{vk43}
	ClipWait 0.1
	cl:=Clipboard, Clipboard:=tmp
	Return cl
}

Is64BitExe(path) {
  DllCall("GetBinaryType", "astr", path, "uint*", type)
  return 6 = type
}

SetText(txt,sending,max_send){	
	If (!sending && (StrLen(txt)>max_send)){
		tmp:=Clipboard, Clipboard:=txt
		Send ^{vk56}
		Clipboard:=tmp
	}
	Else	
		Send % "{Text}" txt
}

Translate(text) {
	Eng:="~QWERTYUIOP{}ASDFGHJKL:""ZXCVBNM<>?|``qwertyuiop[]asdfghjkl;'zxcvbnm,./@#$^&"
	Rus:="ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,/ёйцукенгшщзхъфывапролджэячсмитьбю.""№;:?"
	lcode:=InputLayout()
	Loop Parse, text, ,`r
	{ 		
		If p:=InStr(lcode="0x0409" ? Eng : Rus, A_LoopField, true) 
			r.=SubStr(lcode="0x0409" ? Rus : Eng, p, 1)
		Else
			r.=A_LoopField 
	}
	ControlGetFocus CtrlFocus, A
	SendMessage, 0x50,, % lcode="0x0409" ? 0x4190419 : 0x4090409, % CtrlFocus, A
	Return r
}

InvertLayout(text) {
	Eng:="~QWERTYUIOP{}ASDFGHJKL:""ZXCVBNM<>?|``qwertyuiop[]asdfghjkl;'zxcvbnm,./@#$^&"
	Rus:="ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,/ёйцукенгшщзхъфывапролджэячсмитьбю.""№;:?"
	Loop Parse, text, ,`r
	{ 		
		If p:=InStr(Eng, A_LoopField, true) 
			r.=SubStr(Rus, p, 1), last:="0x4190419"			
		Else If p:=InStr(Rus, A_LoopField, true) 
			r.=SubStr(Eng, p, 1), last:="0x4090409"
		Else
			r.=A_LoopField		
	}	
	ControlGetFocus CtrlFocus, A
	SendMessage, 0x50,, % last, % CtrlFocus, A
	Return r
}

ChangeCase(t,n)
{
	StringCaseSense, Locale
	If !n
		StringUpper t, t, T
	If n=1
		StringUpper t, t
	If n=2
		StringLower t, t
	If n<3
		Return t
	Loop % StrLen(t)
	{
		r:=SubStr(t,A_Index,1)
		If r is upper
			StringLower o, r
		Else
			StringUpper o, r
		out.=o
	}
	Return out
}

