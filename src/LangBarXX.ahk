#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 99999999
#MaxThreadsPerHotkey 1
SetWinDelay -1
SetBatchLines -1
CoordMode Caret
CoordMode Tooltip
CoordMode Mouse
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
SetTitleMatchMode Slow    
Process Priority,, A

version:="1.1.0"

/* 
Использованы:
Начальный код отображения флажка Irbis http://forum.script-coding.com/viewtopic.php?id=10392&p=3
Gdip library by Tic
Acc Standard Library by Sean
*/

PID:=DllCall("GetCurrentProcessId")
Process Exist, LangBarXX.exe
lb:=ErrorLevel
Process Exist, LangBarXX64.exe
lb64:=ErrorLevel
If (lb && lb!=PID) || (lb64 && lb64!=PID) {
    MsgBox, 16, , Запущена другая копия программы!, 1.5
    ExitApp
}

EnvSet __COMPAT_LAYER, RUNASINVOKER

SetFormat, float, 0.2
XS:=8, YS:=-12 ; смещения по умолчанию
width:=20
; Умолчания
Defaul_values:
DX:=XS, DY:=YS, transp:=255, flag:=1, capslock:=1, numlock_on:=0, numlock_icon:=1, scrolllock:=1, scrolllock_icon:=1, icon_shift:=1, aspect:=1, symbsel:=startonly:=enter_on:=tab_on:=0, wordint:=750, wait:=250, symbint:=280, digit_keys:=f_keys:=0

If reset
    Return
FileCreateDir flags
FileCreateDir masks
Loop Parse, % "flags\en-Us.png,flags\ru-RU.png,flags\1.png,masks\NumLock.png,masks\ScrollLock.png,masks\NumScroll.png", CSV
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
    IniRead flag, % cfg, Main, Flag, % " "
    IniRead DX, % cfg, Main, DX, % " "
    IniRead DY, % cfg, Main, DY, % " "
    IniRead width, % cfg, Main, Width, % " "
    IniRead transp, % cfg, Main, Transp, % " "     
    IniRead icon_shift, % cfg, Main, Icon_Shift, % " "
    IniRead aspect, % cfg, Main, Aspect, % " "    
    IniRead capslock, % cfg, Main, CapsLock, % " "
    IniRead numlock_on, % cfg, Main, NumLock_On, % " "
    IniRead numlock_icon, % cfg, Main, NumLock_Icon, % " "
    IniRead scrolllock, % cfg, Main, ScrollLock, % " "
    IniRead scrolllock_icon, % cfg, Main, ScrollLock_Icon, % " "
    IniRead symbsel, % cfg, Main, SymbSel, 0
    IniRead startonly, % cfg, Main, StartOnly, 0

    IniRead enter_on, % cfg, Main, Enter_On, 0
    IniRead tab_on, % cfg, Main, Tab_On, 0

    IniRead wait, % cfg, Main, Wait, % " "
    IniRead symbint, % cfg, Main, SymbInt, % " "
    IniRead wordint, % cfg, Main, WordInt, % " "    
    IniRead pause, % cfg, Main, Pause, 1
    IniRead shift_bs, % cfg, Main, Shift_BS, 1
    IniRead digit_keys, % cfg, Main, Digit_Keys, 0
    IniRead f_keys, % cfg, Main, F_Keys, 0
}
SetTimer Settings, 10000
If numlock_on 
    SetNumLockState On

Menu Tray, NoStandard
Menu Tray, Tip, LangBar++
Menu Tray, Add, Смена раскладки, LangBar 
Menu Tray, Default, 1&
Menu Tray, Add, Флажок (Shift+Shift), Flag
Menu Tray, Add, Раскладки и флажки, LayoutsAndFlags
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
Menu Select, Add, Обработка переносов, EnterOn
Menu Select, Add, Обработка табуляций, TabOn
Menu Select, Add,
Menu Select, Add, Задержки выделения, GUI
Menu Tray, Add, Выделение, :Select

Menu Autorun, Add, Включить, Autorun
Menu Tray, Add, Автозапуск, :Autorun

Menu Help, Add, Справка, Help
Menu Help, Add, Что нового?, Changelog
Menu Help, Add, 
Menu Help, Add, О программе, About
Menu Tray, Add, Помощь, :Help
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

Menu Select, % symbsel ? "Check" : "Uncheck", 1&
Menu Select, % startonly ? "Check" : "Uncheck", 2&
Menu Select, % enter_on ? "Check" : "Uncheck", 4&
Menu Select, % tab_on ? "Check" : "Uncheck", 5&

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

If A_IsCompiled && FileExist("LB_WatchDog.exe") {
    Gosub LB_WatchDog
    SetTimer LB_WatchDog, 60000
}
Gosub LayoutsAndFlags
Gosub CapsLockFlag
While !(InputLayout())
    Sleep 100
lang_old:=lang_array[1,1]
SetTimer TrayIcon, 250
Sleep 325
SetTimer WatchCaret, 50

;==================================================
endkeys:="{Esc}{AppsKey}{LCtrl}{LAlt}{RAlt}{LWin}{RWin}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}"

If !tab_on
    endkeys.="{Tab}"
If !enter_on
    endkeys.="{Enter}{NumpadEnter}"
    
If digit_keys {
    Loop % lang_count {
        Hotkey % ">!" A_Index, SetInputLang
        Hotkey % "<^>!" A_Index, SetInputLang
        Hotkey % ">^" A_Index, Translate
        Hotkey % ">+" A_Index, Translate
    }
}
If f_keys {
    Loop % lang_count {
        Hotkey % ">!F" A_Index, SetInputLang
        Hotkey % "<^>!F" A_Index, SetInputLang
        Hotkey % ">^F" A_Index, Translate
        Hotkey % ">+F" A_Index, Translate
        endkeys:=RegExReplace(endkeys, "\{F" A_Index "}")
    }
}

Loop {
    ks:=[]
    ih:=InputHook("I V", endkeys)
    ih.KeyOpt("{All}", "V N")
    ih.KeyOpt("{CapsLock}{NumLock}{LShift}{RShift}{RCtrl}", "-N")
    ih.OnKeyDown:=Func("KeyArray")
    ih.Start()
    ih.Wait()
}

KeyArray(hook, vk) {
    Global ks
    If (GetKeyName(vk_code:=Format("vk{:x}", vk))~="Backspace") || (GetKeyState("LControl", "P")) || (GetKeyState("LAlt", "P")) || (GetKeyState("RAlt", "P")) || (GetKeyState("AltGr", "P")) || (GetKeyState("LWin", "P")) || (GetKeyState("RWin", "P"))
        ks.Pop() 
    Else
        ks.Push([(GetKeyState("Shift", "P") ? "+" : "") "{" vk_code "}", GetKeyState("CapsLock", "T")])
    ;Tooltip % ks.Length(),0 ,0, 7
}

Select:
    If WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || ((A_PriorHotkey=A_ThisHotkey) && (A_TimeSincePriorHotkey<50))
        Return 
    hkey:=A_ThisHotkey, button:=RegExReplace(hkey,"^[\^\$\+>]+")
    Hotkey % "*" button, Return, On
    lang_sel:=InputLayout()
    text:=rem:=ih.Input, sel:=hand_sel:=send_bs:=per_symbol_select:=""
    ih.Stop()
    If StrLen(text) {
        If (button~="(RButton|MButton)")
            SetTimer WatchCaret, Off
        If (WinActive("ahk_class ConsoleWindowClass") || WinActive("ahk_class VirtualConsoleClass") || WinActive("ahk_exe WindowsTerminal.exe") || (A_ThisHotkey~="BS$")) || (A_ThisHotkey~="^>\+F?[1-8]$")
            send_bs:=1
        Else
            Send {Shift down}
        If symbsel {
            KeyWait % button, T%wait_button%
            If !Errorlevel {
                KeyWait % button, D T0.3
                If ErrorLevel
                    Exit
                per_symbol_select:=1
            }
        }
        Sleep 50
        While GetKeyState(button,"P") && !(rem~="^\s*$"){
            rem_old:=rem, rem:=per_symbol_select ? RegExReplace(rem_old,".$") : RegExReplace(rem_old,"\S+\s{0,3}$")
            If send_bs {
                Loop % (StrLen(rem_old)-StrLen(rem)) {
                    Send {BS}
                    Sleep 20
                }
            }
            Else 
                Send % "{Left " StrLen(rem_old)-StrLen(rem) "}"
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
        If !send_bs
            Send {Shift up}
        sel:=SubStr(text, StrLen(rem)+1)
        ks.RemoveAt(1, StrLen(rem)), out:=ks.Clone()
        KeyWait % button, T1
        If (button~="(RButton|MButton)")
            SetTimer WatchCaret, On
        Sleep 100
    }
    Else {
        KeyWait % button, T1
        KeyWait RCtrl, T1
        KeyWait RShift, T1
        tmp:=Clipboard, Clipboard:=""
        Send ^{vk43}
        ClipWait 0.3
        sel:=hand_sel:=Clipboard, Clipboard:=tmp
    }
    Hotkey % "*" button, Return, Off
    Hotkey *BS, Return, Off
    If !sel && (capslock!=7) { ;;;;;;;;;
        Tooltip % "Буфер пуст -`nвыделите текст!", % x-40, % y-50
        SetTimer ToolTip, -1500
        Exit
    }
    Sleep 100
    Return

Convert:
ReConvert:
    Sleep 100
    out:=[], convert:=""
    HKL:=DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", InputLayout()), "UInt", 0)
    Loop Parse, sel
    {
        val:=DllCall("VkKeyScanEx", "Char", Asc(A_LoopField), "UInt", HKL)
        vk:="vk" SubStr(Format("{:x}", val), -2)
        If (vk="vk20d") ; удаление двойных переносов
            continue
        If (vk~="vkfff") {
            If (A_ThisLabel="Convert") && (button~="(Pause|BS|RButton|CapsLock)") {
                Gosub SetInputLang
                Goto Reconvert
            }
            ToolTip Неверная`nраскладка!,  % x-40, % y-50
            SetTimer ToolTip, -2000
            target:=lang_sel
            Gosub ResetLang
            Exit
        }
        convert.="{" vk "}"
        out.Push([((vk~="^vk1\w\w$") ? "+" : "") "{" RegExReplace(vk,"vk\K\d(?=\w\w)") "}", 0])       
    }
    Return

SendText(txt) {
    global vk_string ;;;;
    If !txt
        Return
    If IsObject(txt) {
        vk_string:="" ;;;;;;
        SetStoreCapsLockMode Off
        Loop % txt.Length() {
            SetCapsLockState % ((txt[A_Index, 2]) ? "On" : "Off")
            SendInput % txt[A_Index, 1]
            vk_string.=txt[A_Index, 1] ;;;;;;
        }
        SetStoreCapsLockMode On
    }
    Else
        Send % "{Text}" txt
    Return
}

>^=::
    Hotkey *Bs, Return, On
    Gosub Select
    SendText(InvertCase(sel))
    Return

InvertCase(t) {
    StringCaseSense Locale
    Loop % StrLen(t) {
        r:=SubStr(t,A_Index,1)
        If r is upper
            StringLower o, r
        Else
            StringUpper o, r
        out.=o
    }
    Return out
}

>^-::
    Gosub Select
    SendText(Format("{:L}",sel))
    Return

>^0::
    Gosub Select
    SendText(Format("{:U}",sel))
    Return

>^9::
    Gosub Select
    SendText(Format("{:T}",sel))
    Return

>^vkDD::
    Gosub Select
    target:=0x0409
    Gosub SetInputLang
    SendText(Translit(sel))
    Return

#If (InputLayout()~="(" lang_list[pause, 1] "|" lang_list[pause, 2] ")") && (pause!=1)
Pause::Goto Translate

#If (id=FlagHwnd) 
RButton::
If (InputLayout()~="(" lang_list[pause, 1] "|" lang_list[pause, 2] ")") && (pause!=1)
    Goto Translate
Return

MButton::
    Gosub Select
    SendText(InvertCase(sel))
    Return

#If (capslock=3) && (InputLayout()~="(" lang_list[pause, 1] "|" lang_list[pause, 2] ")") && (pause!=1)
CapsLock::
SetCapsLockState AlwaysOff
Goto Translate
Return

#If (capslock=3)
CapsLock::SetCapsLockState AlwaysOff

#If (InputLayout()~="(" lang_list[shift_bs, 1] "|" lang_list[shift_bs, 2] ")") && (shift_bs!=1)
+BS::Goto Translate
#If

Translate:
    Gosub Select
    If hand_sel
        Gosub Convert
    Send {Del}
    Gosub SetInputLang
    Sleep 50
    SendText(out)
    If (A_ThisHotkey="CapsLock")
        SetCapsLockState Off
    ;FileAppend % A_Now " " hkey " " button " " InputLayout() "`r`ntext: " text "`r`nsel: " sel "`r`nconvert: " convert "`r`nvk_string: " vk_string " (" txt.Length() ")`r`n`r`n", Log.txt, UTF-8 ; логирование введенного и обработанного текста
    Return

;=======================================
SetInputLang:
    If WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe")
        Return
    lang_start:=InputLayout()
    If (A_ThisHotkey~="!F?\d$") 
        target:=lang_array[SubStr(A_ThisHotkey, 0),1]
    Else If (hkey~="F?\d$")
        target:=lang_array[SubStr(hkey, 0),1]   
    Else If hkey in RButton,Pause,CapsLock
        target:=(lang_start=lang_list[pause, 1]) ? lang_list[pause, 2] : lang_list[pause, 1]
    Else If (hkey="+BS")
        target:=(lang_start=lang_list[shift_bs, 1]) ? lang_list[shift_bs, 2] : lang_list[shift_bs, 1]
ResetLang:
    WinExist("A")
    ControlGetFocus, CtrlInFocus
    PostMessage, 0x50, 0, % target, % CtrlInFocus, A
    target:=""
    Return

#If (capslock=-1)
CapsLock::
    SetCapsLockState AlwaysOff
    Send {Shift down}
    KeyWait CapsLock
    Send {Shift up}
    Return

#If !capslock
CapsLock::SetCapsLockState AlwaysOff

#If (capslock=2)
CapsLock::
    SetCapsLockState AlwaysOff
    Gosub Langbar
    Return

#If (capslock=4)
~CapsLock::
    KeyWait CapsLock, T0.25
    If !ErrorLevel
        Return
    Gosub Select
    SetCapsLockState Off
    SendText(InvertCase(sel))   
    Return

#If (capslock=5)
CapsLock:: 
    Gosub Select
    SetCapsLockState Off
    SendText(InvertCase(sel))
    Return
#If

#If !OnTaskBar() && !(id=FlagHwnd)   
~*LButton::
    ih.Stop()
    Sleep 100
    wheel:=0
    Return

~*MButton::
    ih.Stop()
    Return
#If

~*WheelUp::
~*WheelDown::
~*WheelRight::
~*WheelLeft::
    ih.Stop()
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

EnterOn:
    enter_on:=enter_on ? 0 : 1
    Goto Start

TabOn:
    tab_on:=tab_on ? 0 : 1
    Goto Start

Reset:
    CheckText := "*Сохранить копию текущих"
    msg:="Все настройки к значениям по умолчанию?`nКнопка 'Бэкап' сохраняет копию без сброса"
    Result := MsgBoxEx(msg, "Сброс настроек", "OK|Бэкап|Cancel*", 5, CheckText, "AlwaysOnTop", 0, 0, "s10 c0x000000", "Sego UI", "0x8CB9D7")
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
    
Changelog:
    Run Changelog.txt
    Return

About:
    Gui 4:Destroy
    Gui 3:Margin, 30, 20
    Gui 4:Font, s9
    Gui 4:Color, 8CB9D7
    Gui 4:-DPIScale +AlwaysOnTop +ToolWindow +HwndGui4
    Gui 4:Add, Link, section, <a href="https://github.com/Krot66/LangBarXX">GitHub</a>
    Gui 4:Add, Link, ys, <a href="http://forum.ru-board.com/topic.cgi?forum=5&topic=50256#1">Форум Ru.Board</a>
    Gui 4:Font, s11
    Gui 4:Add, Text, x30 y+30, % "LangBar++ v." version
    Gui 4:Font, s10
    Gui 4:Add, Button, x60 y+30 w100 h28 g4GuiClose, OK
    Gui 4:Show,, О программе
    Return
    
4GuiClose:
    Gui 4:Destroy
    Return

#If WinActive("ahk_id" Gui4 )
Esc::Goto 4GuiClose
#If    
    
Reload:
    Reload    Return

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
    If !ErrorLevel
        Run % "LB_WatchDog.exe " A_ScriptName, % A_ScriptDir            
    Return

Settings:
    IniWrite % flag, % cfg, Main, Flag
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

    IniWrite % wordint, % cfg, Main, WordInt
    IniWrite % wait, % cfg, Main, Wait
    IniWrite % symbint, % cfg, Main, SymbInt

    IniWrite % symbsel, % cfg, Main, SymbSel
    IniWrite % startonly, % cfg, Main, StartOnly

    IniWrite % enter_on, % cfg, Main, Enter_On
    IniWrite % tab_on, % cfg, Main, Tab_On

    IniWrite % pause, % cfg, Main, Pause
    IniWrite % shift_bs, % cfg, Main, Shift_BS
    IniWrite % digit_keys, % cfg, Main, Digit_Keys
    IniWrite % f_keys, % cfg, Main, F_Keys
    Return

ToolTip:
    ToolTip
    ToolTip,,,, 2
    Return

LangBar:
    SetTimer TrayIcon, Off
    SetTimer WatchCaret, Off
    KeyWait LButton, T1
    Sleep 50
    If lastwin && WinExist("ahk_id" lastwin) {
    WinGet st, MinMax, ahk_id %lastwin%
        If (st!=-1) {
            WinActivate ahk_id %lastwin%
            WinWaitActive ahk_id %lastwin%,, 1
        }
	}
    Sleep 50
    Loop lang_count
        If (lang=lang_array[A_Index, 1])
            curr_lang:=A_Index
    target:=lang_array[(curr_lang=lang_count) ? 1 : curr_lang+1, 1]
    GoSub ResetLang
    SetTimer TrayIcon, On
    Sleep 25
    SetTimer WatchCaret, On
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
    SetTimer TrayIcon, Off
    SetTimer WatchCaret, Off
    lang_old:=caps_old:=""
    Gosub CapsLockFlag
    SetTimer TrayIcon, On
    Sleep 25
    SetTimer WatchCaret, On
    Return

#If (id=FlagHwnd)
LButton::
    SetTimer WatchCaret, Off
    ControlGetFocus, CtrlInFocus, A
    PostMessage, 0x50, 2,, %CtrlInFocus%, A
    ;Critical Off
    SetTimer WatchCaret, On
    Return

+WheelUp::
    If (width<64)
        width+=2, mess:="Размер`n" width "x" width*3//4 " px"    
Pos:
    If WinActive("ahk_id" Gui2) {
        GuiControl Focus, Edit1
        Sleep 100
    }
    ToolTip % mess, % x+width+15,% y-20, 2
    SetTimer ToolTip, -1500
    WinSet, TransColor, 3F3F3F %transp%, ahk_id %FlagHwnd%
    If !WinActive("ahk_id" Gui2 )
        MouseMove % x+width//2, % y+width*3//8
    Return

+WheelDown::
    If (width>16)
        width-=2, mess:="Размер`n" width "x" width*3//4 " px"    
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
    MouseGetPos, x0, y0
    WinGetPos xc, yc,,, ahk_id %FlagHwnd%
    xc-=x0, yc-=y0
    While GetKeyState("Lbutton", "P") {
        sleep 10
        MouseGetPos, xn, yn
        WinMove, ahk_id %FlagHwnd%,, xc+xn, yc+yn
    }
    DX+=xn-x0, DY+=yn-y0, mess:="Положение`nx=" DX ", y=" DY
    Goto Pos
#If

FlagGui:
    Gui Destroy
    Gui -DPIScale
    Gui +AlwaysOnTop -Caption +ToolWindow +LastFound +HwndFlagHwnd
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
    If !(lang:=InputLayout())
        lang:=lang_old    
    Loop % lang_array.Length()
        If (lang=lang_array[A_Index, 1])
            flag_png:=lang_array[A_Index, 3]
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
        ih.Stop() 
        Gui Hide,
        SetTimer WatchCaret, Off
        SetTimer TrayIcon, Off
        Sleep 300
        SetTimer TrayIcon, On
        Sleep 50
        SetTimer WatchCaret, On
    }
    If !InputLayout() {
        Gui Hide
        Return
    }
    MouseGetPos,,, id
    DetectHiddenWindows On
    If !WinExist("ahk_id" FlagHwnd)
        Gosub FlagGui
    DetectHiddenWindows Off
    caret:=GetCaretLocation(), _x:=caret[1], _y:=caret[2], x:=_x+DX, y:=_y+DY
    If wheel && (_x=x_wheel) && (_y=y_wheel)    
        Return
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
        If _x && _y && (FlagHwnd!=WinExist("A")){
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
            WinRestore ahk_id %FlagHwnd%
            WinSet Top,, ahk_id %FlagHwnd%
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

LayoutsAndFlags:
    Gui 3:Destroy
    Gui 3:+LastFound -DPIScale +hWndGui3
    Gui 3:Default
    Gui 3:Margin, 16, 12
    Gui 3:Color, 6DA0B8
    Gui 3:Font, Sego UI s10
    Gui 3:Add, ListView, w676 -Multi Grid R5 -LV0x10 HwndHLV NoSort ReadOnly, N|Раскладка|Код (реестр)|Файл флажка
    ImageListID := IL_Create(10)
    LV_SetImageList(ImageListID)
    Gdip_Startup()   
    row:=0, lang_array:=[], uflag:=0
    RegRead lang_sort, HKEY_CURRENT_USER\Software\Microsoft\CTF\SortOrder\Language, 00000000
    Loop {
        If !lang_sort {
            RegRead kl, HKEY_CURRENT_USER\Keyboard Layout\Preload, % A_Index
            If kl && !(kl~="^0")
                continue
        }
        Else
            RegRead kl, HKEY_CURRENT_USER\Software\Microsoft\CTF\SortOrder\Language, % Format("{:08}", A_Index-1)            
        If !kl
            break
        RegRead lang_name, HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Keyboard Layouts\%kl%, Layout Text
        lang_name:=lang_name ? lang_name : "???"
        lcode:=LangCode("0x" SubStr(kl, -3))
        lcode:=lcode ? lcode : SubStr(kl, -3), 
        If !FileExist(kl_flag:="flags\" lcode ".png") {
            uflag++
            If FileExist("flags\" uflag ".png")
                kl_flag:="flags\" uflag ".png"
            Else
                kl_flag:="flags\1.png", uflag:=0
        }
        lang_array.Push(["0x" SubStr(kl, -3), lang_name, kl_flag]) ;;;;;;;;;;;
        row++        
        pFlag := Gdip_CreateBitmapFromFile(FileExist(kl_flag) ? kl_flag : "") 
        Gdip_GetImageDimensions(pFlag, wf, hf)
        pMem := Gdip_CreateBitmap(32, 32)
        G := Gdip_GraphicsFromImage(pMem)
        Gdip_GraphicsClear(G, 0x00000000)
        Gdip_DrawImage(G, pFlag, 0, 2, 32, 26, 0, 0, wf, hf)
        Handle:=Gdip_CreateHICONFromBitmap(pMem)
        IL_Add(ImageListID, "HICON:*" Handle)        
        LV_Add("Icon" A_Index, " " row, lang_name, kl, "flags\" lcode ".png")
        DllCall("DestroyIcon", "ptr", Handle)
    }
    lang_count:=row, lang_set:="Выкл.|", lc_count:=0, def_lang:=1, lang_list:=[0]
    Loop % lang_count-1
    {
        lc:=A_Index
        Loop % (lang_count-lc) {
            lang_set.=lc "/" lc+A_Index " (" SubStr(lang_array[lc,2], 1, 20) "/" SubStr(lang_array[lc+A_Index,2], 1, 12)  ")|"
            lang_list.Push([lang_array[lc,1], lang_array[lc+A_Index,1]])
            lc_count++
            If (lang_array[lc,1]~="(0x0409|0x0419)") && (lang_array[lc+A_Index,1]~="(0x0409|0x0419)$")
                def_lang:=lc_count+1
        }
    }    
    pause:=(!pause || (pause>lang_count)) ? def_lang : pause
    shift_bs:=(!shift_bs || (shift_bs>lang_count)) ? def_lang : shift_bs      
    If !(A_ThisMenuItem="Раскладки и флажки")
        Return
    LV_ModifyCol(1, "AutoHdr Center")
    LV_ModifyCol(2, "220")
    LV_ModifyCol(3, "180 Center")
    LV_ModifyCol(4, "AutoHdr Center")
    Gui 3:Add, GroupBox, w676 h112, Исправление раскладки
    Gui 3:Add, Text, x32 yp+32, Pause, CapsLock и флажок:
    Gui 3:Add, DropDownList, vpause Choose%pause% AltSubmit x360 yp-4 w320, % lang_set
    Gui 3:Add, Text, x32 yp+42, Сочетание Shift + BS:
    Gui 3:Add, DropDownList, vshift_bs Choose%shift_bs% AltSubmit x360 yp-4 w320, % lang_set
    Gui 3:Add, GroupBox, x16 yp+56 w676 h72, Работа с множественными раскладками (плюс правые Ctrl, Shift и Alt)
    Gui 3:Add, Checkbox, x64 yp+32 vdigit_keys, % "Цифровые клавиши"
    Gui 3:Add, Checkbox, x360 yp0 vf_keys, % "Функциональные клавиши (F*)"
    Gui 3:Font, s9.5
    Gui 3:Add, Button, x40 y+32 w120 h32 gFlagsFolder, Флажки
    Gui 3:Add, Button, x+6 yp wp hp gControlPanel, Языки (ПУ)
    Gui 3:Add, Button, x+6 yp wp hp gLayoutsAndFlags, Обновить
    Gui 3:Add, Button, x+6 yp wp hp g3Save, OK
    Gui 3:Add, Button, x+6 yp wp hp g3GuiClose, Cancel
    GuiControl,, digit_keys, % digit_keys
    GuiControl,, f_keys, % f_keys
    Gui 3:Show,, Раскладки и флажки    
    Return

3Save:
    Gui 3:Submit
    Gosub Settings
    Reload

3GuiClose:
    Gui 3:Destroy
    Return

#If WinActive("ahk_id" Gui3)
Esc::Goto 3GuiClose
#If

FlagsFolder:
    Run % "explorer.exe " A_ScriptDir "\flags"
    Return

ControlPanel:
    SetTimer ToolTip, -3000
    If (A_OSVersion="WIN_XP") {
        Run intl.cpl
        If ErrorLevel
            Run %A_WinDir%\system32\control.exe
    }
    Else
        Run %A_WinDir%\system32\control.exe /name Microsoft.RegionalAndLanguageOptions /page /p:"keyboard"
    Return

FlagSettings:    
    Gui 2:Destroy
    Gui 2:-DPIScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui2
    Gui 2:Font, s13 
    Gui 2:Color, 6DA0B8
    ;7BA8C6
    Gui 2:Add, Edit, w382 r3, % comment
    Gui 2:Font, s10 
    Gui 2:Add, Button, w122 h36 section g+WheelDown, Размер -
    Gui 2:Add, Button, wp hp x+8 yp gUp, Вверх
    Gui 2:Add, Button, wp hp x+8 yp g+WheelUp, Размер +

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
    Gui 9:Font, Sego UI s10
    Gui 9:Color, 6DA0B8
    Gui 9:Add, GroupBox, x16 w480 h90, Интервал выделения "по словам"
    Gui 9:Add, Slider, xp10 yp+40 section w370 v_wordint gWordint Range300-1000 ToolTip, % _wordint
    Gui 9:Add, Text, ys, %_wordint% мс
    Gui 9:Add, GroupBox, x16 w480 h90, Ожидание отпускания клавиши
    Gui 9:Add, Slider,xp10 yp+40 section w370 v_wait gWait Range160-320 ToolTip2, % _wait
    Gui 9:Add, Text, ys, %_wait% мс
    Gui 9:Add, GroupBox, x16 w480 h90, Интервал посимвольного выделения
    Gui 9:Add, Slider, xp10 yp+40 section w370 v_symbint gSymbint Range120-360 ToolTip3, % _symbint 
    Gui 9:Add, Text, ys, %_symbint% мс
    Gui 9:Add, Button, x50 yp+66 w100 h32 section g9GuiClose, Cancel
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
    _wordint:=750, _wait:=250, _symbint:=280
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
