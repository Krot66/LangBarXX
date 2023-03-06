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

version:="1.2.0"

/* 
Использованы:
Начальный код отображения флажка Irbis http://forum.script-coding.com/viewtopic.php?id=10392&p=3
Gdip library by Tic
Acc Standard Library by Sean
*/

pict:="src\Drag.ico" ; Подгружаемые изображения
cur:="Drag.cur"
FileInstall Drag.cur, masks\Drag.cur, 1

PID:=DllCall("GetCurrentProcessId")
Process Exist, LangBarXX.exe
lb:=ErrorLevel
Process Exist, LangBarXX64.exe
lb64:=ErrorLevel
If (lb && lb!=PID) || (lb64 && lb64!=PID) {
    MsgBox, 16, , Запущена другая копия программы!, 1.5
    ExitApp
}
SysGet MW, MonitorWorkArea
EnvSet __COMPAT_LAYER, RUNASINVOKER

SetFormat, float, 0.2

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

cfg:="LangBarXX.ini"

If !FileExist("portable.dat") {
    FileCreateDir % A_AppData "\LangBarXX"
    cfg:=A_AppData "\LangBarXX\" cfg
}
cfg_exist:=FileExist(cfg) ? 1 : 0
IniDelete % cfg, Main

IniRead aspect, % cfg, Tray, Aspect, 1 
IniRead icon_shift, % cfg, Tray, Icon_Shift, 1
IniRead numlock_icon, % cfg, Tray, NumLock_Icon, 1
IniRead scrolllock_icon, % cfg, Tray, ScrollLock_Icon, 1
IniRead set_lang, % cfg, Tray, Set_Lang, 0 

IniRead capslock, % cfg, Keys, CapsLock, 1
IniRead scrolllock, % cfg, Keys, ScrollLock, 1
IniRead numlock_on, % cfg, Keys, NumLock_On, 0

IniRead flag, % cfg, Flag, Flag, 1
IniRead dx, % cfg, Flag, DX, 16
IniRead dy, % cfg, Flag, DY, -12
IniRead width, % cfg, Flag, Width, 22
IniRead transp, % cfg, Flag, Transp, 90

IniRead indicator, % cfg, Indicator, Indicator, 0
IniRead dx_in, % cfg, Indicator, DX_In, 50
IniRead dy_in, % cfg, Indicator, DY_In, 50
IniRead width_in, % cfg, Indicator, Width_In, 3
IniRead transp_in, % cfg, Indicator, Transp_in, 90
IniRead numlock_icon_in, % cfg, Indicator, NumLock_Icon_In, 1
IniRead scrolllock_icon_in, % cfg, Indicator, ScrollLock_Icon_In, 1
   
IniRead pause, % cfg, Layouts, Pause, % "0x0409|0x0419"
IniRead shift_bs, % cfg, Layouts, Shift_BS, % "0x0409|0x0419"
IniRead pause_shift_bs, % cfg, Layouts, Pause_Shift_BS, 0
;IniRead ctrl_p, % cfg, Layouts, Ctrl_P, 0
IniRead digit_keys, % cfg, Layouts, Digit_Keys, 0
IniRead f_keys, % cfg, Layouts, F_Keys, 0

IniRead wordint, % cfg, Select, WordInt, 750
IniRead wait, % cfg, Select, Wait, 250
IniRead symbint, % cfg, Select, SymbInt, 280
IniRead symbsel, % cfg, Select, SymbSel, 0
IniRead startonly, % cfg, Select, StartOnly, 0    
IniRead enter_on, % cfg, Select, Enter_On, 0
IniRead tab_on, % cfg, Select, Tab_On, 0

apps:=[]
If cfg_exist {
    Loop {
        IniRead a, % cfg, Apps, app%A_Index%, % " "
        If !a
            Break        
        apps.Push(StrSplit(a, ","))
    }
}
Else {
    apps.Push([1,1,"WindowsTerminal.exe","CASCADIA_HOSTING_WINDOW_CLASS","Windows Terminal"])
    apps.Push([1,0,"wmplayer.exe","WMPlayerApp","Windows Media Player"])
    apps.Push([1,0,"PotPlayer*.exe","PotPlayer","PotPlayer"])
    apps.Push([1,0,"mpc-be*.exe","MPC-BE","MPC-BE"])
    apps.Push([1,0,"mpc-hc*.exe","MediaPlayerClassicW","MPC-HC"])
    apps.Push([1,0,"1by1.exe","1by1WndClass","1by1 Directory Player"])
    Loop % apps.Length(){
        n:=A_Index, app:=""
        Loop 5
            app.=apps[n,A_Index] ","
        IniWrite % RegExReplace(app, ",$") , % cfg, Apps, app%n%
    }
}

SetTimer Settings, 10000
If numlock_on 
    SetNumLockState On

Menu Tray, NoStandard
Menu Tray, Tip, LangBar++
Menu Tray, Add, Смена раскладки, LangBar 
Menu Tray, Default, 1&
Menu Tray, Add, Флажок (Shift+Shift), FlagToggle
Menu Tray, Add, Раскладки и флажки, LayoutsAndFlags
Menu Tray, Add, Настройка флажка, FlagSettings
Menu Indicator, Add, Включен (Ctrl+Shift+Shift), IndicatorToggle
Menu Indicator, Add
Menu Indicator, Add, Настройки положения, IndicatorSettings
Menu Indicator, Add, Правила приложений, Rules
Menu Tray, Add, Индикатор раскладки, :Indicator
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
Menu NumLock, Add, Отображать на иконке, NumLock_Icon
Menu NumLock, Add, Отображать на индикаторе, NumLock_Icon
Menu Tray, Add, NumLock, :NumLock

Menu ScrollLock, Add, Выключен, ScrollLock
Menu ScrollLock, Add
Menu ScrollLock, Add, Отображать на иконке, ScrollLock_Icon
Menu ScrollLock, Add, Отображать на индикаторе, ScrollLock_Icon
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
    Menu, Tray, Icon, 7&, % A_ScriptFullPath, 3
    Menu, Tray, Icon, 8&, % A_ScriptFullPath, 3
    Menu, Tray, Icon, 9&, % A_ScriptFullPath, 3    
    Menu, Tray, Icon, 14&, % A_ScriptFullPath, 4
    Menu, Tray, Icon, 18&, % A_ScriptFullPath, 5
    Menu, Tray, Icon, 19&, % A_ScriptFullPath, 6
}

Start:
Menu Tray, % flag ? "Check" : "Uncheck", 2&
Menu Indicator, % indicator ? "Check" : "Uncheck", 1&

Menu CapsLock, % capslock=1 ? "Check" : "Uncheck", 1&
Menu CapsLock, % capslock=4 ? "Check" : "Uncheck", 2&
Menu CapsLock, % capslock=5 ? "Check" : "Uncheck", 3&
Menu CapsLock, % capslock=0 ? "Check" : "Uncheck", 5&
Menu CapsLock, % capslock=-1 ? "Check" : "Uncheck", 6&
Menu CapsLock, % capslock=2 ? "Check" : "Uncheck", 7&
Menu CapsLock, % capslock=3 ? "Check" : "Uncheck", 8&

Menu NumLock, % numlock_on ? "Check" : "Uncheck", 1&
Menu NumLock, % numlock_icon ? "Check" : "Uncheck", 3&
Menu NumLock, % numlock_icon_in ? "Check" : "Uncheck", 4&

Menu ScrollLock, % !scrolllock ? "Check" : "Uncheck", 1&
Menu ScrollLock, % scrolllock_icon ? "Check" : "Uncheck", 3&
Menu ScrollLock, % scrolllock_icon_in ? "Check" : "Uncheck", 4&

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

If not capslock in 1,4
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
Gosub FlagGui
Gosub IndicatorGui
Gosub CapsLockFlag
lang_old:=lang_array[1,1]
SetTimer TrayIcon, 250
If (A_TickCount<150000) {
    While (c<10)
        Sleep 100
}
Else
    Sleep 275
SetTimer Flag, 50

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
    Global wheel
    Global ks
    wheel:=0
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
    lang_sel:=InputLayout(), text:=rem:=ih.Input, sel:=hand_sel:=send_bs:=per_symbol_select:=""
    ih.Stop()
    If StrLen(text) {
        If (button~="(RButton|MButton)")
            SetTimer Flag, Off
        If WinActive("ahk_class ConsoleWindowClass") || WinActive("ahk_class VirtualConsoleClass") || WinActive("ahk_exe WindowsTerminal.exe") || ((A_ThisHotkey~="BS$") && !pause_shift_bs) || ((A_ThisHotkey~="Pause") && pause_shift_bs) || (A_ThisHotkey~="^>\+F?[1-8]$")
            send_bs:=1
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
            Loop % (StrLen(rem_old)-StrLen(rem)) {
                If send_bs
                    SendInput {BS down}{BS up}
                Else
                    SendInput {Shift down}{Left down}{Left up}{Shift up}
                Sleep 20
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
        ks.RemoveAt(1, StrLen(rem)), out:=ks.Clone()
        KeyWait % button, T1
        If (hkey~=">\^") ;;;;;;;;;;;;;
            KeyWait RCtrl, T1
        If (button~="(RButton|MButton)")
            SetTimer Flag, On
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
            If (A_ThisLabel="Convert") && (button~="(Pause|BS|RButton|CapsLock|vk50)") {
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
    

#If (InputLayout()~="(" pause ")") && pause
Pause::Goto Translate

OnFlag(hwnd) {
    DetectHiddenWindows Off
    MouseGetPos,,, win
    Return (win=hwnd) ? 1 : 0
}

#If OnFlag(FlagHwnd) && flag
RButton::
If (InputLayout()~="(" pause ")") && pause
    Goto Translate
Return

MButton::
    Gosub Select
    SendText(InvertCase(sel))
    Return

#If (capslock=3) && (InputLayout()~="(" pause ")") && pause
CapsLock::
Goto Translate
Return

#If (InputLayout()~="(" shift_bs ")") && shift_bs
+BS::Goto Translate
#If

Translate:
    Gosub Select
    If hand_sel
        Gosub Convert
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
    lang_start:=InputLayout(), _pause:=StrSplit(pause, "|"), _shift_bs:=StrSplit(shift_bs, "|")
    If (!set_lang && !target) {
        Loop % lang_count {
            curr_lang:=A_Index
            If (lang_start=lang_array[A_Index,1])
                break    
        }
        target:=(curr_lang<lang_count) ? lang_array[curr_lang+1, 1] : lang_array[1, 1]
        ;ToolTip % lang_start " " curr_lang "`n" target, 1000, 500
        ;SetTimer ToolTip, -2000
    }
    If (A_ThisHotkey~="!F?\d$") 
        target:=lang_array[SubStr(A_ThisHotkey, 0),1]
    Else If (hkey~="F?\d$")
        target:=lang_array[SubStr(hkey, 0),1] 
    Else If hkey in RButton,Pause,CapsLock
        target:=(lang_start=_pause[1]) ? _pause[2] : _pause[1]
    Else If (hkey="+BS")
        target:=(lang_start=_shift_bs[1]) ? _shift_bs[2] : _shift_bs[1]
ResetLang:
    SetInputLang(set_lang, target)
    target:=""
    Return

#If (capslock=-1)
CapsLock::Shift

#If !capslock
CapsLock::Return

#If (capslock=2)
CapsLock::SetInputLang(set_lang)

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
    SendText(InvertCase(sel))
    Return
#If

#If !OnTaskBar() && !OnFlag(FlagHwnd)   
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
    If (A_ThisMenuItemPos=3)
        numlock_icon:=!numlock_icon
    Else
        numlock_icon_in:=!numlock_icon_in
    Gosub Settings
    Reload
    Return

ScrollLock:
    scrolllock:=!scrolllock
    Gosub Settings
    Reload
    Return

ScrollLock_Icon:
    If (A_ThisMenuItemPos=3)
        scrolllock_icon:=!scrolllock_icon
    Else
        scrolllock_icon_in:=!scrolllock_icon_in
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
    If ErrorLevel
        Run % A_WinDir "\System32\OpenWith.exe " """" A_ScriptDir "\ReadMe.html"""
    Return
    
Changelog:
    Run Changelog.txt
    Return

About:
    Gui 4:Destroy
    Gui 4:Margin, 12, 12
    Gui 4:Font, s9
    Gui 4:Color, 8CB9D7
    Gui 4:-DPIScale +AlwaysOnTop +ToolWindow +HwndGui4
    Gui 4:Add, Link, x80, <a href="https://github.com/Krot66/LangBarXX">GitHub</a>
    Gui 4:Add, Link, x40 yp+24 , <a href="http://forum.ru-board.com/topic.cgi?forum=5&topic=50256#1">Форум Ru.Board</a>
    If A_IsCompiled
        Gui 4:Add, Picture, x30 y+16 w160 h-1 Icon1, % A_ScriptName
    Else
        Gui 4:Add, Picture, x30 y+16 w160 h-1, src\LB.ico
    Gui 4:Font, s11
    Gui 4:Add, Text, x20 y+16, % "LangBar++ v." version
    Gui 4:Font, s9
    Gui 4:Add, Button, x60 y+24 w100 h28 g4GuiClose, OK
    Gui 4:Show,, О программе
    Return
    
4GuiClose:
    Gui 4:Destroy
    Return

#If WinActive("ahk_id" Gui4 )
Esc::Goto 4GuiClose
#If    
    
Reload:
    Gosub Settings
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
IniWrite % aspect, % cfg, Tray, Aspect
IniWrite % icon_shift, % cfg, Tray, Icon_Shift
IniWrite % numlock_icon, % cfg, Tray, NumLock_Icon
IniWrite % scrolllock_icon, % cfg, Tray, ScrollLock_Icon
IniWrite % set_lang, % cfg, Tray, Set_Lang
    
IniWrite % capslock, % cfg, Keys, CapsLock
IniWrite % scrolllock, % cfg, Keys, ScrollLock
IniWrite % numlock_on, % cfg, Keys, NumLock_On

IniWrite % flag, % cfg, Flag, Flag
IniWrite % dx, % cfg, Flag, DX
IniWrite % dy, % cfg, Flag, DY
IniWrite % width, % cfg, Flag, Width
IniWrite % transp, % cfg, Flag, Transp

IniWrite % indicator, % cfg, Indicator, Indicator
IniWrite % dx_in, % cfg, Indicator, DX_In
IniWrite % dy_in, % cfg, Indicator, DY_In
IniWrite % width_in, % cfg, Indicator, Width_In
IniWrite % transp_in, % cfg, Indicator, Transp_In
IniWrite % numlock_icon_in, % cfg, Indicator, NumLock_Icon_In
IniWrite % scrolllock_icon_in, % cfg, Indicator, ScrollLock_Icon_In

IniWrite % pause, % cfg, Layouts, Pause
IniWrite % shift_bs, % cfg, Layouts, Shift_BS
IniWrite % pause_shift_bs, % cfg, Layouts, Pause_Shift_BS
;IniWrite % ctrl_p, % cfg, Layouts, Ctrl_P
IniWrite % digit_keys, % cfg, Layouts, Digit_Keys
IniWrite % f_keys, % cfg, Layouts, F_Keys

IniWrite % wordint, % cfg, Select, WordInt
IniWrite % wait, % cfg, Select, Wait
IniWrite % symbint, % cfg, Select, SymbInt
IniWrite % symbsel, % cfg, Select, SymbSel
IniWrite % startonly, % cfg, Select, StartOnly
IniWrite % enter_on, % cfg, Select, Enter_On
IniWrite % tab_on, % cfg, Select, Tab_On    
Return

ToolTip:
    ToolTip
    ToolTip,,,, 2
    Return

LangBar:
    SetTimer TrayIcon, Off
    SetTimer Flag, Off
    KeyWait LButton, T1
    Sleep 50
    Send !{Esc}
    Sleep 50
    Gosub SetInputLang
    SetTimer TrayIcon, On
    Sleep 50
    SetTimer Flag, On
    Return

<+RShift::
>+LShift::
FlagToggle:
    flag:=!flag
    Menu Tray, % flag ? "Check" : "Uncheck", 2&
    Return
       
<^<+RShift::
>^>+LShift::
    KeyWait % RegExReplace(A_ThisHotkey, "^.+\+"), T0.8
    If ErrorLevel {
        lr:=last_rule
        Gosub Rules
        Sleep 2000
        Return
    }
IndicatorToggle:
    indicator:=!indicator
    Menu Indicator, % indicator ? "Check" : "Uncheck", 1&
    If !indicator {
        Gui 11:Hide
        Gui 5:Destroy
    }
    Else
        Goto Indicator
    Return

~#Space up:: ; Space up::   
~<^LShift up::
~>^RShift up::
~!Shift up::
    ih.Stop()
    SetTimer TrayIcon, Off
    SetTimer Flag, Off
    lang_old:=lang_in_old:=lang_fl_old:=caps_old:=caps_in_old:=""
    Gosub CapsLockFlag
    SetTimer TrayIcon, On
    Sleep 25
    SetTimer Flag, On
    Return

#If OnFlag(FlagHwnd) && flag
LButton::
    ih.Stop()
    Goto SetInputLang

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
    WinSet, TransColor, % "3F3F3F " transp*255//100, ahk_id %FlagHwnd%
    If !WinActive("ahk_id" Gui2 )
        MouseMove % x+width//2, % y+width*3//8
    Return

+WheelDown::
    If (width>16)
        width-=2, mess:="Размер`n" width "x" width*3//4 " px"    
    Goto Pos

!WheelUp::
    If (transp>55)
        transp-=10, mess:="Прозрачность " 100-transp " %"    
    Goto Pos

!WheelDown::
    If (transp<95)
        transp+=10, mess:="Прозрачность " 100-transp " %"    
    Goto Pos

!MButton::
    transp:=90, mess:="Прозрачность " 100-transp " %"
    Goto Pos

+MButton::
    DX:=16, DY:=-12, width:=22, transp:=90, mess:="Флажок по`nумолчанию!"
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
    WinSet, TransColor, % "3F3F3F " transp*255//100
    Return
    
IndicatorGui:
    Gui 11:Destroy
    Gui 11:-DPIScale
    Gui 11:+AlwaysOnTop -Caption +ToolWindow +LastFound +HwndIndHwnd +E0x20
    Gui 11:Add, Picture, x0 y0 w512 h512 +HwndIndCapsID
    Gui 11:Add, Picture, x0 y0 w512 h512 +HwndIndID
    Gui 11:Color, 3F3F3F
    WinSet, TransColor, % "3F3F3F " transp_in*255//100
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
    If (cl="#32768")
        Return
    If upd
        Goto Indicator
    If !(lang:=InputLayout())
        lang:=lang_old    
    Loop % lang_array.Length()
        If (lang=lang_array[A_Index, 1])
            flag_png:=lang_array[A_Index, 3]
    num:=GetKeyState("NumLock","T"), scr:=GetKeyState("ScrollLock","T"), caps:=GetKeyState("CapsLock","T")
    If (lang && (lang!=lang_old))||(num!=num_old)||(scr!=scr_old) {
        pFlag:=Gdip_CreateBitmapFromFile(flag_png)
        pNumLock:=(numlock_icon && (scrolllock_icon && scrolllock)) ? Gdip_CreateBitmapFromFile("masks\NumLock.png") : Gdip_CreateBitmapFromFile("masks\NumScroll.png")
        pScrollLock:=(numlock_icon && (scrolllock_icon && scrolllock)) ? Gdip_CreateBitmapFromFile("masks\ScrollLock.png") : Gdip_CreateBitmapFromFile("masks\NumScroll.png")

        Gdip_GetImageDimensions(pFlag, wf, hf)
        size:=64
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
        Gdip_DrawImage(G, pFlag, 0, shift, size, hf2, 0, 0, wf, hf)
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
        lang_old:=lang, num_old:=num, scr_old:=scr
    }
    c++
      
Indicator:
    WinGet pn, ProcessName, A
    WinGetClass cl, A
    If (cl~="(Shell_TrayWnd|WorkerW|Progman)") {
        Gui 11:Hide
        Return
    }        
    app_state:=-1, last_rule:=""
    Loop % apps.Length() {
        If WinExist("ahk_hwnd" Gui6) || !apps[A_Index, 1]
            continue
        an:=(apps[A_Index, 3]="*.*") ? "" : RegExReplace(apps[A_Index, 3], "\*", "[\w -_]*")
        If (an && (pn~="^" an "$") && (apps[A_Index, 4]=cl)) || (!an && cl && (apps[A_Index, 4]=cl)) {
            app_state:=apps[A_Index, 2], last_rule:=A_Index                
            Break
        }
    }
    ;ToolTip % indicator "/" app_state,600,700, 7 ; индикация правил
    If ((app_state>0) || (indicator && !(app_state=0)) || WinExist("ahk_id" Gui5)) {
        If indicator && !WinExist("ahk_id" IndHwnd)
            Gosub IndicatorGui
        If upd || !WinExist("ahk_id" IndHwnd) || (lang && (lang!=lang_in_old)) || (caps!=caps_in_old) || (num!=num_in_old) || (scr!=scr_in_old) {
            w_in:=width_in*MWRight//100, h_in:=w_in*3//4
            x_in:=dx_in*MWRight//100-w_in//2, y_in:=dy_in*MWBottom//100-h_in//2
            mn:=(w_in>60) ? 2 : 1 ; Величина полей
            pFlag:=Gdip_CreateBitmapFromFile(flag_png)
            Gdip_GetImageDimensions(pFlag, wf, hf)
            
            pNumLock:=(numlock_icon_in && (scrolllock_icon_in && scrolllock)) ? Gdip_CreateBitmapFromFile("masks\NumLock.png") : Gdip_CreateBitmapFromFile("masks\NumScroll.png")
            pScrollLock:=(numlock_icon_in && (scrolllock_icon_in && scrolllock)) ? Gdip_CreateBitmapFromFile("masks\ScrollLock.png") : Gdip_CreateBitmapFromFile("masks\NumScroll.png")

            Gdip_GetImageDimensions(pNumLock, w_numlock_in, h_numlock_in)
            Gdip_GetImageDimensions(pScrollLock, w_scrolllock_in, h_scrolllock_in)

            pBitmap:=Gdip_CreateBitmap(w_in, w_in)
            G:=Gdip_GraphicsFromImage(pBitmap)
            Gdip_SetSmoothingMode(G, 2)
            Gdip_SetInterpolationMode(G, 7)

            Brush:=Gdip_BrushCreateSolid(0x33000000)
            Gdip_FillRectangle(G ,Brush, -1, w_in-h_in, w_in+1, h_in+1)
            Gdip_DeleteBrush(Brush)
            Gdip_DrawImage(G, pFlag, mn, w_in-h_in+mn, w_in-mn*2, h_in-mn*2, 0, 0, wf, hf)
            If num && numlock_icon_in
                Gdip_DrawImage(G, pNumLock, 0, 0, w_in, w_in, 0, 0, w_numlock_in, h_numlock_in)
            If scr && scrolllock_icon_in
                Gdip_DrawImage(G, pScrollLock, 0, 0, w_in, w_in, 0, 0, w_scrolllock_in, h_scrolllock_in)
            DllCall("DeleteObject", "ptr", IndicatorHandle)
            IndicatorHandle:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
            Gdip_DisposeImage(pFlag)
            Gdip_DisposeImage(pNumLock)
            Gdip_DisposeImage(pScrollLock)
            Gdip_DeleteGraphics(G)
            Gui 11:Default
            GuiControl,, %IndID%, *w%w_in% *h-1 hbitmap:*%IndicatorHandle%
            Gui 11:Show, x%x_in% y%y_in% NA 
            WinSet, TransColor, % "3F3F3F " transp_in*255//100, ahk_id %IndHwnd%
            WinSet Top,, ahk_id %IndHwnd%
            If caps {            
                GuiControl,, %IndCapsID%, *w%w_in% *h-1 hbitmap:*%CapsHandle%
                GuiControl Move, % IndCapsID, % "x" w_in//6 "y" w_in*2//5
                GuiControl Show, % IndCapsID    
            }
            Else
                GuiControl Hide, % IndCapsID            
        }
    }
    Else
        Gui 11:Hide
    lang_in_old:=lang, width_in_old:=width_in, caps_in_old:=caps, num_in_old:=num, scr_in_old:=scr, upd:=0
    Return

Flag:
    WinGetClass cl, A
    If cl not in Shell_TrayWnd,#32768
        lastwin:=WinExist("A")
    If lastwin && (lastwin!=lastwin_old) {
        ih.Stop() 
        Gui Hide
        SetTimer Flag, Off
        SetTimer TrayIcon, Off
        lang_old:=lang_in_old:=lang_fl_old:=""
        Sleep 300
        SetTimer TrayIcon, On
        Sleep 50
        SetTimer Flag, On
    }
    If !InputLayout() {
        Gui Hide
        Return
    }
    caret:=GetCaretLocation(), _x:=caret[1], _y:=caret[2], x:=_x+DX, y:=_y+DY
    If wheel && (_x=x_wheel) && (_y=y_wheel)    
        Return
    If flag {
        If (lang && (lang!=lang_fl_old)) || (width!=width_old) || !WinExist("ahk_id" FlagHwnd){
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
            Gdip_DrawImage(G, pFlag, mn, mn, width, fl_h, 0, 0, wf, hf)
            DllCall("DeleteObject", "ptr", FlagHandle)
            FlagHandle:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
            Gui Default
            GuiControl,, %FlagID%, *w%width% *h%fl_h% hbitmap:*%FlagHandle%
            Gdip_DisposeImage(pBitmap)
            Gdip_DisposeImage(pFlag)
            Gdip_DeleteGraphics(G)
        }
        If _x && _y && (FlagHwnd!=WinExist("A")){
            If (caps!=caps_old)  || (width!=width_old) {
                Gui Default
                If caps {
                    GuiControl,, %CapsID%, *w%width% *h-1 hbitmap:*%CapsHandle%
                    GuiControl Move, % CapsID, % "x" width//4 "y" width//5
                    GuiControl Show, % CapsID
                    
                }                
                Else {
                    GuiControl Move, % CapsID, % "x" x "y" y
                    GuiControl Hide, % CapsID
                }
                caps_old:=caps
            }
            Gui Show, x%x% y%y% NA
            WinSet Top,, ahk_id %FlagHwnd%
            If !WinExist("ahk_id" FlagHwnd)
                Gosub FlagGui
            width_old:=width, lang_fl_old:=lang
        }                     
        Else
            Gui Hide            
    }
    If !flag
        Gui Hide    
    x_old:=x, y_old:=y, lastwin_old:=lastwin
    Return

LayoutsAndFlags:
    Gui 3:Destroy
    Gui 3:+LastFound -DPIScale -MinimizeBox +hWndGui3
    Gui 3:Default
    Gui 3:Color, 6DA0B8
    Gui 3:Font, s9
    Gui 3:Add, ListView, w616 -Multi Grid R5 -LV0x10 HwndHLV NoSort ReadOnly, №|Раскладка|Код (реестр)|Файл флажка
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
        lang_array.Push(["0x" SubStr(kl, -3), lang_name, kl_flag])
        row++        
        pFlag := Gdip_CreateBitmapFromFile(FileExist(kl_flag) ? kl_flag : "") 
        Gdip_GetImageDimensions(pFlag, wf, hf)
        pMem := Gdip_CreateBitmap(32, 32)
        G := Gdip_GraphicsFromImage(pMem)
        Gdip_GraphicsClear(G, 0x00000000)
        Gdip_DrawImage(G, pFlag, 0, 2, 32, 26, 0, 0, wf, hf)
        Handle:=Gdip_CreateHICONFromBitmap(pMem)
        IL_Add(ImageListID, "HICON:*" Handle)        
        LV_Add("Icon" A_Index, " " row, lang_name, kl, lcode ".png")
        DllCall("DestroyIcon", "ptr", Handle)
    }
    lang_count:=row, lang_set:="Выкл.|", lc_count:=0, pause_lang:=1, shift_bs_lang:=1, lang_list:=[0]
    Loop % lang_count-1
    {
        lc:=A_Index
        Loop % (lang_count-lc) {
            lang_set.=lc "/" lc+A_Index " (" SubStr(lang_array[lc,2], 1, 20) "/" SubStr(lang_array[lc+A_Index,2], 1, 12)  ")|"
            lang_list.Push([lang_array[lc,1], lang_array[lc+A_Index,1]])
            lc_count++
            If pause && (lang_array[lc,1]~="(" pause ")") && (lang_array[lc+A_Index,1]~="(" pause ")$")
                pause_lang:=lc_count+1
            If shift_bs && (lang_array[lc,1]~="(" shift_bs ")") && (lang_array[lc+A_Index,1]~="(" shift_bs ")$")
                shift_bs_lang:=lc_count+1
        }
    }     
    If !(A_ThisMenuItem="Раскладки и флажки")
        Return
    LV_ModifyCol(1, "AutoHdr Center")
    LV_ModifyCol(2, "220")
    LV_ModifyCol(3, "150")
    LV_ModifyCol(4, "AutoHdr")

    Gui 3:Add, GroupBox, w616 h180, Исправление раскладки
    Gui 3:Add, Text, x40 yp+32, Pause, CapsLock и флажок:
    Gui 3:Add, DropDownList, vpause_lang Choose%pause_lang% AltSubmit x300 yp-4 w310, % lang_set
    Gui 3:Add, Text, x40 yp+42, Сочетание Shift+Backspace:
    Gui 3:Add, DropDownList, vshift_bs_lang Choose%shift_bs_lang% AltSubmit x300 yp-4 w310, % lang_set
    Gui 3:Add, CheckBox, x40 yp+44 vpause_shift_bs, Обменять назначение кнопок Pause и Shift+Backspace
    ;Gui 3:Add, CheckBox, x40 yp+36 vctrl_p, Использовать сочетание правый Ctrl+P как Pause
    Gui 3:Add, CheckBox, x40 yp+36 vset_lang, Использовать имитацию клавишного переключения раскладки
    Gui 3:Add, GroupBox, x16 yp+44 w616 h72, Работа с множественными раскладками (+ правые Ctrl, Shift и Alt)
    Gui 3:Add, Checkbox, x52 yp+32 vdigit_keys, % "Цифровые клавиши"
    Gui 3:Add, Checkbox, x300 yp0 vf_keys, % "Функциональные клавиши (F*)"
    Gui 3:Add, Button, x40 y+32 w120 h32 gFlagsFolder, Флажки
    Gui 3:Add, Button, x+6 yp wp hp gControlPanel, Языки (ПУ)
    Gui 3:Add, Button, x+6 yp wp hp gLayoutsAndFlags, Обновить
    Gui 3:Add, Button, x+6 yp w90 hp g3GuiClose, Cancel
    Gui 3:Add, Button, x+6 yp wp hp g3Save, OK
    GuiControl,, pause_shift_bs, % pause_shift_bs
    GuiControl,, set_lang, % set_lang
    ;GuiControl,, ctrl_p, % ctrl_p
    GuiControl,, digit_keys, % digit_keys
    GuiControl,, f_keys, % f_keys
    Gui 3:Show,, Раскладки и флажки    
    Return

3Save:
    Gui 3:Submit
    pause:=(pause_lang>1) ? lang_list[pause_lang,1] "|" lang_list[pause_lang,2] : ""
    shift_bs:=(shift_bs_lang>1) ? lang_list[shift_bs_lang,1] "|" lang_list[shift_bs_lang,2] : ""
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
    Gui 2:Font, s12
    Gui 2:Color, 6DA0B8
    Gui 2:Add, Edit, w348 r3 -VScroll, % comment
    Gui 2:Font, s9
    Gui 2:Add, Button,y+6 w112 h32 section g+WheelDown, Размер -
    Gui 2:Add, Button, wp hp x+6 yp g_Up, Вверх
    Gui 2:Add, Button, wp hp x+6 yp g+WheelUp, Размер +

    Gui 2:Add, Button, wp hp xs y+6 g_Left, Влево
    Gui 2:Add, Button, wp hp x+6 yp g+Mbutton, Сброс
    Gui 2:Add, Button, wp hp x+6 yp g_Right, Вправо

    Gui 2:Add, Button, wp hp xs y+6 g!WheelDown, Прозр-ть -
    Gui 2:Add, Button, wp hp x+6 yp g_Down, Вниз
    Gui 2:Add, Button, wp hp x+6 yp g!WheelUp, Прозр-ть +

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

_Up:
    DY-=2, mess:="Положение`nx=" DX ", y=" DY
    Goto Pos

_Down:
    DY+=2, mess:="Положение`nx=" DX ", y=" DY
    Goto Pos

_Right:
    DX+=2, mess:="Положение`nx=" DX ", y=" DY
    Goto Pos

_Left:
    DX-=2, mess:="Положение`nx=" DX ", y=" DY
    Goto Pos 

; Настройки индикатора
IndicatorSettings:
    Menu Indicator, % indicator ? "Check" : "Uncheck", 1&
    Gui 5:Destroy
    ;Gui 5:Margin, 10, 6
    Gui 5:-DPIScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui5
    Gui 5:Color, 6DA0B8
    Gui 5:Font, s9
    Gui 5:Add, Button, w112 h32 section g^Left, Размер -
    Gui 5:Add, Button, wp hp x+6 yp gUp, Вверх
    Gui 5:Add, Button, wp hp x+6 yp g^Right, Размер +

    Gui 5:Add, Button, wp hp xs y+6 gLeft, Влево
    Gui 5:Add, Button, wp hp x+6 yp gSpace, Сброс
    Gui 5:Add, Button, wp hp x+6 yp gRight, Вправо

    Gui 5:Add, Button, wp hp xs y+6 g^Down, Прозр-ть -
    Gui 5:Add, Button, wp hp x+6 yp gDown, Вниз
    Gui 5:Add, Button, wp hp x+6 yp g^Up, Прозр-ть +
    Gui 5:Font, s7
    Gui 5:Add, StatusBar
    Gui 5:Show, % "x" A_ScreenWidth//2+100 " y" A_ScreenHeight//2-50, Настройка индикатора
    Gosub StatusBar
    Return
    
StatusBar:
    Gui 5:Default 
    SB_SetParts(134, 116)
    SB_SetText("`tX " dx_in "%   Y " dy_in "%`t", 1, 2)
    SB_SetText("`tШирина " width_in "%`t", 2, 2)
    SB_SetText("`tПрозр-ть " 100-transp_in "%`t", 3, 2)
    Return
    
5GuiClose:
    Gui 5:Destroy
    Gosub Settings
    Return

#If WinActive("ahk_id" Gui5)
Esc::Goto 5GuiClose

~LButton::
    MouseGetPos,,, win, ctrl
    If (win=Gui5) && (ctrl~="Button") {
        If (ctrl="Button2")
            Goto Up
        If (ctrl="Button4")
            Goto Left
        If (ctrl="Button6")
            Goto Right
        If (ctrl="Button8")
            Goto Down
        KeyWait LButton
    }
    Return

#If WinExist("ahk_id" Gui5)
Right::
    While GetKeyState("LButton", "P") || GetKeyState("Right", "P") {
        dx_in:=(dx_in+1<100) ? dx_in+1 : dx_in, upd:=1
        Gosub StatusBar
        Sleep 200
    }    
Return    

Left::
    While GetKeyState("LButton", "P") || GetKeyState("Left", "P") {
        dx_in:=(dx_in-1>0) ? dx_in-1 : dx_in, upd:=1
        Gosub StatusBar
        Sleep 200
    }
    Return

Up::
    While GetKeyState("LButton", "P") || GetKeyState("Up", "P") {
        dy_in:=(dy_in-1>0) ? dy_in-1 : dy_in, upd:=1
        Gosub StatusBar
        Sleep 200
    }
    Return

Down::
    While GetKeyState("LButton", "P") || GetKeyState("Down", "P") {
        dy_in:=(dy_in+width_in//2+2<100) ? dy_in+1 : dy_in, upd:=1
        Gosub StatusBar
        Sleep 200
    }
    Return

^Right::
    If (width_in<10)
        width_in+=0.2, upd:=1
    Goto StatusBar

^Left::
    If (width_in>2)
        width_in-=0.2, upd:=1
    Goto StatusBar

^Up::
    If (transp_in>54)
        transp_in-=5, upd:=1
    Goto StatusBar

^Down::
    If (transp_in<96)
        transp_in+=5, upd:=1
    Goto StatusBar

Space::
    width_in:=3, dx_in:=50, dy_in:=60, transp_in:=85, upd:=1
    Goto StatusBar
    
; Правила приложений
Rules:
    Gui 6:Destroy
    Gui 6:-DpiScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui6
    Gui 6:Default
    ;Gui 6:Margin, 8, 6
    Gui 6:Font, s9
    ;Gui 6:Add, Picture, w32 x20 h-1 gDetect, % pict
    If A_IsCompiled
        Gui 6:Add, Picture, w32 x20 h-1 Icon7 gDetect, LangBarXX.exe
    Else
        Gui 6:Add, Picture, w32 x20 h-1 gDetect, % pict
    Gui 6:Add, Text, x+20 yp+6, Для создания правила перетащите кнопку на окно приложения
    Gui 6:Add, ListView, x8 w720 r16 -Multi NoSortHdr Checked +Grid -LV0x10  vapp gProperties, % " №|+/-|Имя файла|Класс окна|Описание/комментарий"
    Loop % apps.Length()
        LV_Add(apps[A_Index,1] ? "Check" : "", A_Index, apps[A_Index, 2] ? "+" : "-", apps[A_Index, 3], apps[A_Index, 4], apps[A_Index, 5])
    LV_ModifyCol(1,"50 Center")
    LV_ModifyCol(2,"40 Center")
    LV_ModifyCol(3, "200")
    LV_ModifyCol(4, "200")
    Loop % LV_GetCount()
        LV_Modify(A_Index, "-Select")    
    LV_ModifyCol(5, (LV_GetCount()>16) ? 200:220)
    If (A_ThisHotkey~="\+(L|R)Shift$") && last_rule
        LV_Modify(last_rule, "Select Vis Focus")
    ;Gui 6:Font, s8
    Gui 6:Add, Button, x20 w140 gProperties, Редактировать
    Gui 6:Add, Button, x+6 yp w70 gRuleUp, Вверх
    Gui 6:Add, Button, x+6 yp wp gRuleDown, Вниз
    Gui 6:Add, Button, x+6 yp w100 gRuleDelete, Удалить
    Gui 6:Add, Button, x+130 yp w80 g6GuiClose, Cancel
    Gui 6:Add, Button, x+6 yp wp gRulesSave, OK
    Gui 6:Show,, Правила приложений
    If (A_ThisHotkey~="\+(L|R)Shift$") && !lr {
        Tooltip Нет включенных правил`nдля данного приложения!, % MWRight//2-100, % MWBottom//2-20
        SetTimer Tooltip, -3000
    }
    lr:=0
    Return
    
RuleUp:
    LVMoveRow()
    Loop % LV_GetCount()
        LV_Modify(A_Index,, A_Index)
    Return
        
RuleDown:
    LVMoveRow(false)
    Loop % LV_GetCount()
        LV_Modify(A_Index,, A_Index)
    Return

RuleDelete:
    row:=LV_GetNext(, "F")
    MsgBox, 4129, , Удалить правило %row%?
    IfMsgBox OK
    {
        LV_Delete(row)
        Loop % LV_GetCount()
            LV_Modify(A_Index,, A_Index)
    }        
    Return
    
RulesSave:
    Gui 6:Submit, Nohide
    apps:=[]
    IniDelete % cfg, Apps
    Loop % LV_GetCount() {
        r1:=(LV_GetNext(A_Index-1, "C")=A_Index) ? 1 : 0
        LV_GetText(r2, A_Index,2)
        r2:=(r2="+") ? 1 : 0
        LV_GetText(r3, A_Index, 3)    
        LV_GetText(r4, A_Index, 4)
        LV_GetText(r5, A_Index, 5)
        r5:=RegExReplace(r5,"(:|;|,)", " "), r5:=RegExReplace(r5, " {2,}", " ")
        app%A_Index%:=r1 "," r2 "," r3 "," r4 "," r5
        IniWrite % app%A_Index%, % cfg, Apps, app%A_Index%
        apps.Push([r1, r2, r3, r4, r5])
    }
6GuiClose:
    Gui 6:Destroy
    Return
   
#If WinActive("ahk_id" Gui6)
Esc::Goto 6GuiClose
#If

Detect:
    If A_IsCompiled
        SetSystemCursor("masks\Drag.cur")
    Else
        SetSystemCursor(cur)
    KeyWait LButton
    RestoreCursors()
    MouseGetPos,,, win
    WinGetClass class, ahk_id %win%
    WinGet pr_name, ProcessName, ahk_id %win%
    WinGet pr_path, ProcessPath, ahk_id %win%
    ch:="+", description:=FileGetInfo(pr_path).FileDescription
    If (win=Gui6) || (class="Shell_TrayWnd") || (class="WorkerW") || (class="Progman")
        Return
Properties:
    row:=0
    If (A_ThisLabel="Properties") {
        row:=(A_GuiEvent = "DoubleClick") ? A_EventInfo : LV_GetNext(, "F")
        If (row=0) || (row>LV_GetCount())
            Return
        LV_GetText(ch, row, 2)
        LV_GetText(pr_name, row, 3)
        If !pr_name
            Return
        LV_GetText(class, row, 4)
        LV_GetText(description, row, 5)
    }
    Gui 7:Destroy
    Gui 7:Margin, 10, 6
    Gui 7:Default
    Gui 7:+Owner6 +AlwaysOnTop +LastFound +HwndGui7
    Gui 7:Add, Edit, x10 w160 vpr_name, % pr_name
    Gui 7:Add, Text, x+5 yp+2, - имя файла
    Gui 7:Add, Button, x+10 yp-2 w60 gAll, Все!
    Gui 7:Add, Edit, x10 w160 ReadOnly vclass, % class
    Gui 7:Add, Text, x+5 yp+2, - класс окна
    Gui 7:Add, Edit, x10 w160 vdescription, % description
    Gui 7:Add, Text, x+5 yp+2, - описание/комментарий
    Gui 7:Add, Radio, x40 valways_on, Всегда включен
    Gui 7:Add, Radio, x+20 yp valways_off, Всегда выключен
    Gui 7:Add, Button, x90 w60 g7GuiCancel, Cancel
    Gui 7:Add, Button, x+20 yp wp g7GuiOK, OK
    GuiControl,, always_on, % (ch="+") ? 1 : 0
    GuiControl,, always_off, % (ch="-") ? 1 : 0
    Gui 7:Show, Center, Свойства окна
    Sleep 50
    Send {End}
    Return
      
7GuiCancel:
7GuiClose:
    Gui 7:Destroy
    Return
    
7GuiOK:
    Gui 7:Submit
    Gui 6:Default
    If row
        LV_Modify(row,,, always_on ? "+" : "-", pr_name, class, description)
    Else {
        If (name="*.*") && !cl {
            MsgBox, 4129, , Недопустимо создание универсального правила с пустым классом окна!, 22
            Return       
        }
        Loop % LV_GetCount() {
            LV_GetText(name, A_Index, 3)
            LV_GetText(cl, A_Index, 4)
            If (name=pr_name) && (cl=class) {
                MsgBox, 4129, , Дубликат правила %A_Index%!, 2
                Return
            }        
        }    
        row:=LV_GetCount()+1
        LV_Add("Check", row, always_on ? "+" : "-", pr_name, class, description)
    }
    Return
    

#If WinActive("ahk_id" Gui7)
Esc::Goto 7GuiCancel
#If

All:
    GuiControl,, pr_name, *.*
    Return
        
    
SetSystemCursor(file) {
    CursorHandle := DllCall("LoadCursorFromFile", Str, file)
    Cursors = 32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651
    Loop, Parse, Cursors, `,
    {
        DllCall( "SetSystemCursor", Uint, CursorHandle, Int, A_Loopfield )
    }
}

RestoreCursors() {
    SPI_SETCURSORS := 0x57
    DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0 )
}
    
FileGetInfo( lptstrFilename) { ; by Lexicos
	List := "Comments InternalName ProductName CompanyName LegalCopyright ProductVersion"
		. " FileDescription LegalTrademarks PrivateBuild FileVersion OriginalFilename SpecialBuild"
	dwLen := DllCall("Version.dll\GetFileVersionInfoSize", "Str", lptstrFilename, "Ptr", 0)
	dwLen := VarSetCapacity( lpData, dwLen + A_PtrSize)
	DllCall("Version.dll\GetFileVersionInfo", "Str", lptstrFilename, "UInt", 0, "UInt", dwLen, "Ptr", &lpData) 
	DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\VarFileInfo\Translation", "PtrP", lplpBuffer, "PtrP", puLen )
	sLangCP := Format("{:04X}{:04X}", NumGet(lplpBuffer+0, "UShort"), NumGet(lplpBuffer+2, "UShort"))
	i := {}
	Loop, Parse, % List, %A_Space%
		DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\StringFileInfo\" sLangCp "\" A_LoopField, "PtrP", lplpBuffer, "PtrP", puLen )
		? i[A_LoopField] := StrGet(lplpBuffer, puLen) : ""
	return i
}

LVMoveRow(Up := True) {
    CO := [], TO := [], F := LV_GetNext("F"), N := F + (Up ? -1 : 1)

    If (!N) || (N > LV_GetCount()) || (!F) {
        return
    }

    Loop, % LV_GetCount("Col") {
        LV_GetText(CT, F, A_Index), LV_GetText(TT, N, A_Index), CO.Push(CT), TO.Push(TT)
    }

    Loop, % CO.MaxIndex() {
        LV_Modify(F, "Col" A_Index, TO[A_Index]), LV_Modify(N, "Col" A_Index, CO[A_Index])
    }

    LV_Modify(F, "-Select"), LV_Modify(N, "Select")
}
    

; Настройки выделения
GUI:
    _wait:=wait, _symbint:=symbint, _wordint:=wordint
Def:
    Gui 9:Destroy
    Gui 9:-DPIScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui9
    Gui 9:Font, s9
    Gui 9:Color, 6DA0B8
    Gui 9:Add, GroupBox, x16 w480 h86, Интервал выделения по словам
    Gui 9:Add, Slider, xp10 yp+36 section w370 v_wordint gWordint Range300-1000 ToolTip NoTicks, % _wordint
    Gui 9:Add, Text, ys, %_wordint% мс
    Gui 9:Add, GroupBox, x16 w480 h86, Ожидание отпускания клавиши
    Gui 9:Add, Slider,xp10 yp+36 section w370 v_wait gWait Range160-320 ToolTip2 NoTicks, % _wait
    Gui 9:Add, Text, ys, %_wait% мс
    Gui 9:Add, GroupBox, x16 w480 h86, Интервал посимвольного выделения
    Gui 9:Add, Slider, xp10 yp+36 section w370 v_symbint gSymbint Range120-360 ToolTip3 NoTicks, % _symbint 
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
