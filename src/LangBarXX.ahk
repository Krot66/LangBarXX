#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 99999999
#MaxThreadsPerHotkey 1
#InstallKeybdHook
#KeyHistory % A_IsCompiled ? 0 : 40
If A_IsCompiled
    ListLines Off
SetWinDelay -1
SetBatchLines -1
CoordMode Caret
CoordMode Tooltip
CoordMode Mouse
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
SetTitleMatchMode Slow
Process Priority,, A
FileEncoding UTF-8

version:="1.4.4.2"

/*
Использованы:
Начальный код отображения флажка Irbis http://forum.script-coding.com/viewtopic.php?id=10392&p=3
Gdip library by Tic    
Acc Standard Library by Sean
FileGetInfo and StrUnmark by Lexicos
ChooseColor - iPhilip 
*/

start:=A_TickCount
pict:="Drag.ico" ; Подгружаемые изображения при нескомпилированном файле
cur:="Drag.cur"
FileInstall Drag.cur, masks\Drag.cur, 1

PID:=DllCall("GetCurrentProcessId")
Process Exist, LangBarXX.exe
lb:=ErrorLevel
Process Exist, LangBarXX64.exe
lb64:=ErrorLevel
If ((lb && lb!=PID) || (lb64 && lb64!=PID)) && FileExist("portable.dat") {
    MsgBox, 16, , Запущена другая копия программы!, 1.5
    ExitApp
}
EnvSet __COMPAT_LAYER, RUNASINVOKER HighDpiAware
SetFormat, float, 0.2

If reset
    Return

FileCreateDir backup
FileCreateDir dict
FileCreateDir editor
FileCreateDir logs

If FileExist("editor")
    Loop Files, editor\*.*
        If (A_LoopFilePath~="\.(exe|lnk)$")
            editor:=A_LoopFilePath
If !editor
    editor:="notepad.exe"

If FileExist("config") ; конфигурация портативная или установленная
    cfg_folder:=A_ScriptDir "\config", cfg:="config\langbarxx.ini" 
Else {
    cfg_folder:=A_AppData "\LangBarXX", cfg:=cfg_folder "\langbarxx.ini"
    FileCreateDir % cfg_folder
    If FileExist(cfg_folder "\temp.txt")
        Gosub USB-Version
}
If !FileExist(cfg_folder "\user_dict.dic")
    FileAppend,, % cfg_folder "\user_dict.dic",UTF-8

SetTimer UpdateUserDict, 10000

; ====== Обработка старых версий ======
If FileExist("langbarxx.ini") && FileExist("config") && !FileExist("config\langbarxx.ini")
    FileMove langbarxx.ini, config
    
FileDelete LB_WatchDog.exe
FileDelete langbarxx.ini
FileDelete ReadMe.html
FileDelete ReadMe.md
FileRemoveDir ReadMe.assets, 1
FileDelete Changelog.txt
FileDelete portable.dat
If FileExist(cfg) {
    IniDelete % cfg, Tray, key_switch
    IniDelete % cfg, Indicator, DX_In
    IniDelete % cfg, Indicator, DY_In
    IniDelete % cfg, Layouts, pause
    IniDelete % cfg, Layouts, shift_bs
    IniRead old_version, % cfg, Main, Version, 0
    If (old_version!=version)
        IniWrite 0, % cfg, Layouts, Key_Switch
}

;================================
IniRead aspect, % cfg, Tray, Aspect, 1
IniRead icon_shift, % cfg, Tray, Icon_Shift, 1
IniRead numlock_icon, % cfg, Tray, NumLock_Icon, 1
IniRead scrolllock_icon, % cfg, Tray, ScrollLock_Icon, 1
IniRead flag_sett, % cfg, Tray, Flag_Sett, 0

IniRead capslock, % cfg, Keys, CapsLock, 1
IniRead scrolllock, % cfg, Keys, ScrollLock, 1
IniRead numlock_on, % cfg, Keys, NumLock_On, 0

IniRead flag, % cfg, Flag, Flag, 1
IniRead dx, % cfg, Flag, DX, 16
IniRead dy, % cfg, Flag, DY, -12
IniRead width, % cfg, Flag, Width, 22
IniRead transp, % cfg, Flag, Transp, 100
IniRead scaling, % cfg, Flag, Scaling, 5
IniRead smoothing, % cfg, Flag, Smoothing, 3
IniRead no_border, % cfg, Flag, No_Border, 0
IniRead file_aspect, % cfg, Flag, File_Aspect, 0

IniRead indicator, % cfg, Indicator, Indicator, 0
IniRead lang_switcher, % cfg, Indicator, Lang_Switcher, 0
IniRead on_full_screen, % cfg, Indicator, On_Full_Screen, 0
IniRead dx_in_1, % cfg, Indicator, DX_In_1, 50
IniRead dy_in_1, % cfg, Indicator, DY_In_1, 50
IniRead dx_in_2, % cfg, Indicator, DX_In_2, 50
IniRead dy_in_2, % cfg, Indicator, DY_In_2, 50
IniRead width_in, % cfg, Indicator, Width_In, 2
IniRead transp_in, % cfg, Indicator, Transp_in, 90
IniRead numlock_icon_in, % cfg, Indicator, NumLock_Icon_In, 1
IniRead scrolllock_icon_in, % cfg, Indicator, ScrollLock_Icon_In, 1

IniRead pause_langs, % cfg, Layouts, Pause_Langs, % "(0x0409|0x0419)"
IniRead shift_bs_langs, % cfg, Layouts, Shift_BS_Langs, % "(0x0409|0x0419)"
IniRead pause_shift_bs, % cfg, Layouts, Pause_Shift_BS, 0
IniRead key_switch, % cfg, Layouts, Key_Switch, 0
IniRead lang_select, % cfg, Layouts, Lang_Select, 3
IniRead lctrl, % cfg, Layouts, LCtrl, 0
IniRead rctrl, % cfg, Layouts, RCtrl, 0
IniRead lshift, % cfg, Layouts, LShift, 0
IniRead rshift, % cfg, Layouts, RShift, 0
IniRead double_click, % cfg, Layouts, Double_Click, 0
IniRead digit_keys, % cfg, Layouts, Digit_Keys, 0
IniRead f_keys, % cfg, Layouts, F_Keys, 0

IniRead wordint, % cfg, Select, WordInt, 750
IniRead wait, % cfg, Select, Wait, 250
IniRead symbint, % cfg, Select, SymbInt, 280
IniRead symbsel, % cfg, Select, SymbSel, 0
IniRead startonly, % cfg, Select, StartOnly, 0
IniRead enter_on, % cfg, Select, Enter_On, 0
IniRead tab_on, % cfg, Select, Tab_On, 0

IniRead autocorrect, % cfg, Autocorrect, Autocorrect, 0
IniRead single_lang, % cfg, Autocorrect, Single_Lang, 0
IniRead lang_auto, % cfg, Autocorrect, Lang_Auto, % "(0x0409|0x0419)"
IniRead only_main_dict, % cfg, Autocorrect, only_main_dict, 0
IniRead lang_auto_single, % cfg, Autocorrect, Lang_Auto_Single, % "0x0409"
IniRead lang_auto_others, % cfg, Autocorrect, Lang_Auto_Others, % " "
IniRead min_length, % cfg, Autocorrect, Min_Length, 1
IniRead sound, % cfg, Autocorrect, Sound, 1
IniRead tray_tip, % cfg, Autocorrect, Tray_Tip, 0
IniRead accent_ignore, % cfg, Autocorrect, Accent_Ignore, 1
IniRead ctrlz_undo, % cfg, Autocorrect, CtrlZ_Undo, 1
IniRead no_indicate, % cfg, Autocorrect, No_Indicate, 0
IniRead abbr_ignore, % cfg, Autocorrect, Abbr_Ignore, 1
IniRead short_abbr_ignore, % cfg, Autocorrect, Short_Abbr_Ignore, 1
IniRead word_margins_enabled, % cfg, Autocorrect, Word_Margins_Enabled, 0
IniRead word_margins, % cfg, Autocorrect, Word_Margins, % "(,|,\,/,_,=,+"
IniRead digit_borders, % cfg, Autocorrect, Digit_Borders, 0
IniRead new_lang_ignore, % cfg, Autocorrect, New_Lang_Ignore, 0
IniRead mouse_click_ignore, % cfg, Autocorrect, Mouse_Click_Ignore, 0

IniRead regexp_list, % cfg, Converter, Regexp_List, % " "

IniRead font_size, % cfg, TextFlags, Font_Size, 36
IniRead bold, % cfg, TextFlags, Bold, 1
IniRead font_size, % cfg, TextFlags, Font_Size, 38
IniRead font_color, % cfg, TextFlags, Font_Color, EEEEEE
IniRead radius, % cfg, TextFlags, Radius, 10
IniRead gradient, % cfg, TextFlags, Gradient, 16

_radius:=64*radius//100, _bold:=bold ? "Bold" : ""
default_colors:=[0x003FA5, 0xBF0000, 0x406300, 0x994A03, 0xC632A1, 0x1B7785, 0x444444, 0x8201D8, 0x003FA5, 0xBF0000, 0x406300, 0x994A03, 0xC632A1, 0x1B7785, 0x444444, 0x8201D8]

apps:=[]
If FileExist(cfg) {
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
    FileEncoding UTF-16
    Loop % apps.Length() {
        n:=A_Index, app:=""
        Loop 5
            app.=apps[n,A_Index] ","
        IniWrite % RegExReplace(app, ",$") , % cfg, Apps, app%n%
    }
    FileEncoding UTF-8
}
    
SysGet MW, MonitorWorkArea
SysGet monitors, MonitorCount
dx_in:=(monitors>1) ? dx_in_2 : dx_in_1, dy_in:=(monitors>1) ? dy_in_2 : dy_in_1

SetTimer Settings, 10000
If numlock_on
    SetNumLockState On

Menu Tray, NoStandard
Menu Tray, Tip, LangBar++
Menu Tray, Add, Смена раскладки, LangBar
Menu Tray, Default, 1&
Menu Tray, Add, Раскладки и флажки, LayoutsAndFlags

Menu Flag, Add, Включен (Shift+Shift), FlagToggle
Menu Flag, Add
Menu Scaling, Add, Default, Scaling
Menu Scaling, Add, NearestNeighbor, Scaling
Menu Scaling, Add, Bilinear, Scaling
Menu Scaling, Add, Bicubic, Scaling
Menu Scaling, Add, Bicubic HQ, Scaling
Menu Flag, Add, Масштабирование, :Scaling
Menu Flag, Add, Сглаживание, Smoothing
Menu Flag, Add, Без обводки, NoBorder
Menu Flag, Add, Пропорции файла, FlagAspect
Menu Flag, Add, Настройка флажка, FlagSettings
Menu Tray, Add, Флажок курсора, :Flag

Menu Indicator, Add, Включен (Ctrl+Shift+Shift), IndicatorToggle
Menu Indicator, Add
Menu Indicator, Add, Переключатель раскладки, Lang_Switcher
Menu Indicator, Add, На полном экране, OnFullScreen
Menu Indicator, Add, Настройки индикатора, IndicatorSettings
Menu Indicator, Add, Правила приложений, Rules
Menu Tray, Add, Индикатор раскладки, :Indicator

Menu Icon, Add, Настройки флажка, As_Flag
Menu Icon, Add,
Menu Icon, Add, Пропорция 5:4, Aspect
Menu Icon, Add, Пропорция 4:3, Aspect
Menu Icon, Add, Пропорция 3:2, Aspect
Menu Tray, Add, Иконка в трее, :Icon
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

Menu Autocorrect, Add, Включено (Ctrl+Ctrl), AutocorrectToggle
Menu Autocorrect, Add, Режим одного языка, SingleLangToggle
Menu Autocorrect, Add
Menu Autocorrect, Add, Настройки, Autocorrect
Menu Autocorrect, Add
Menu Autocorrect, Add, Конвертер словарей, DictConverter
Menu Autocorrect, Add, Папка словарей, DictFolder
Menu Autocorrect, Add, Рабочие словари, OpenDict
Menu Autocorrect, Add
Menu Autocorrect, Add, Пользовательский словарь, UserDict
Menu Autocorrect, Add, История отмен, UndoLog
Menu Autocorrect, Add, Статистика, Statistics
Menu Tray, Add, Автопереключение, :Autocorrect

Menu Select, Add, Посимвольное выделение, SymbSel
Menu Select, Add, Только с начала, StartOnly
Menu Select, Add,
Menu Select, Add, Обработка переносов, EnterOn
Menu Select, Add, Обработка табуляций, TabOn
Menu Select, Add,
Menu Select, Add, Задержки выделения, GUI
Menu Tray, Add, Выделение, :Select
Menu Tray, Add

Menu Autorun, Add, Включить, Autorun
Menu Tray, Add, Автозапуск, :Autorun

Menu Help, Add, Справка, Help
Menu Help, Add, Что нового?, Changelog
If !FileExist("config") {
    Menu Help, Add,
    Menu Help, Add, USB-версия, USB-Version
}
Menu Help, Add,
Menu Help, Add, О программе, About
Menu Tray, Add, Помощь, :Help
Menu Tray, Add
Menu Tray, Add, Сброс и бэкап настроек, Reset
Menu Tray, Add
Menu Tray, Add, Перезапуск, Apply
Menu Tray, Add, Выход, Exit
Menu Tray, Click, 1

If A_IsCompiled {
    Menu, Tray, Icon, 2&, % A_ScriptFullPath, 2
    Menu, Tray, Icon, 7&, % A_ScriptFullPath, 3
    Menu, Tray, Icon, 8&, % A_ScriptFullPath, 3
    Menu, Tray, Icon, 9&, % A_ScriptFullPath, 3
    Menu, Tray, Icon, 15&, % A_ScriptFullPath, 4
    Menu, Tray, Icon, 19&, % A_ScriptFullPath, 5
    Menu, Tray, Icon, 20&, % A_ScriptFullPath, 6
}

Menu Flag, % flag ? "Check" : "Uncheck", 1&
Menu Indicator, % indicator ? "Check" : "Uncheck", 1&
Menu Indicator, % lang_switcher ? "Check" : "Uncheck", 3&
Menu Indicator, % on_full_screen ? "Check" : "Uncheck", 4&
Menu Autocorrect, % autocorrect ? "Check" : "Uncheck", 1&

Menu Scaling, % scaling=0 ? "Check" : "Uncheck", 1&
Menu Scaling, % scaling=5 ? "Check" : "Uncheck", 2&
Menu Scaling, % scaling=3 ? "Check" : "Uncheck", 3&
Menu Scaling, % scaling=4 ? "Check" : "Uncheck", 4&
Menu Scaling, % scaling=7 ? "Check" : "Uncheck", 5&

Menu Flag, % smoothing!=3 ? "Check" : "Uncheck", 4&
Menu Flag, % no_border ? "Check" : "Uncheck", 5&
Menu Flag, % file_aspect ? "Check" : "Uncheck", 6&

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

Menu Icon, % flag_sett ? "Check" : "Uncheck", 1&

Menu Icon, % aspect=2 ? "Check" : "Uncheck", 3&
Menu Icon, % aspect=1 ? "Check" : "Uncheck", 4&
Menu Icon, % !aspect ? "Check" : "Uncheck", 5&

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

If A_IsCompiled && FileExist("bin\LB_WatchDog.exe") {
    Gosub LB_WatchDog
    SetTimer LB_WatchDog, 60000
}

pToken:=Gdip_Startup()

Gosub LayoutsAndFlags
Gosub FlagGui
Gosub IndicatorGui
Gosub Masks


lang_old:=lang_array[1,1]
SetTimer TrayIcon, 100
Sleep 500
SetTimer Flag, 33
Gosub LoadDict

;==================================================
endkeys:="{Esc}{AppsKey}{LWin}{RWin}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{NumpadDel}{Ins}{NumpadIns}"

If !tab_on
    endkeys.="{Tab}"
If !enter_on
    endkeys.="{Enter}{NumpadEnter}"

If (lang_select=1)
    Loop  % lang_count
        Hotkey % "<^sc" A_Index+1, SetInputLang

If (lang_select=2)
    Loop  % lang_count
        Hotkey % "<!sc" A_Index+1, SetInputLang

If digit_keys {
    Loop % lang_count {
        Hotkey % ">^>+sc" A_Index+1, SetInputLang
        Hotkey % ">^sc" A_Index+1, Translate
        Hotkey % ">+sc" A_Index+1, Translate
    }
}
If f_keys {
    Loop % lang_count {
        Hotkey % ">^>+F" A_Index, SetInputLang
        Hotkey % ">^F" A_Index, Translate
        Hotkey % ">+F" A_Index, Translate
        endkeys:=RegExReplace(endkeys, "\{F" A_Index "}")
    }
}

Loop {
    ks:=[], ks_string:=text:=text_alt:=text_old:=""
    ih:=InputHook("I V", endkeys)
    ih.KeyOpt("{All}", "V N")
    ih.KeyOpt("{CapsLock}{NumLock}{LShift}{RShift}{LCtrl}{RCtrl}{LAlt}{RAlt}{AltGr}{BS}{Pause}", "-N")
    ih.OnKeyDown:=Func("KeyArray")
    ih.Start()
    ih.Wait()
}

KeyArray(hook, vk, sc) {
    Global
    StringCaseSense Off
    tstart:=A_TickCount, vk0:=vk, sc0:=sc
    
    If (GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P")) && !(GetKeyState("RAlt", "P") || GetKeyState("AltGr", "P")) {
        ih.Stop(), stop:="Ctrl"
        Return
    }
    prefix:=(GetKeyState("LShift", "P") || GetKeyState("RShift", "P")) ? "+" : "",
    prefix:=GetKeyState("RAlt", "P") ? ">!" : prefix,
    prefix:=GetKeyState("AltGr", "P") ? "<^>!" : prefix,
    vk:=Format("vk{:x}", vk), sc:=Format("sc{:x}", sc),
    ks.Push([prefix "{" sc "}", GetKeyState("CapsLock", "T")])

    If ((print_win:=WinExist("A"))!=print_win_old) 
        mouse_click:=new_lang:=text_convert:=key_name:=""    
    If ((il:=InputLayout())!=il_old) && (print_win=print_win_old) && print_win_old && il_old && new_lang_ignore
        new_lang:=1
    il_old:=il, print_win_old:=print_win, wheel:=0
    
    If !autocorrect || (!single_lang && !(il~=lang_auto)) || (single_lang && !(il~=lang_auto_others) && lang_auto_others) || (single_lang && (il=lang_auto_single))
        Return
    If single_lang
        alt_lang:=lang_auto_single
    Else
        RegExMatch(lang_auto, "\(\K.+(?=\|)", auto1), RegExMatch(lang_auto, "\|\K.+(?=\))", auto2), alt_lang:=(il=auto1) ? auto2 : auto1
    dic_curr:=dic_%il%, dic_alt:=dic_%alt_lang%

    If (key_name~="^(Space|Tab|Enter|NumpadEnter)$")
        text_convert:=new_lang:=mouse_click:=text:=text_alt:=""

    key_name:=GetKeyName(sc), ih_old:=ih.Input, last_symb:=SubStr(ih_old, 0), last_space:=(key_name~="^(Space|Tab|Enter|NumpadEnter)$") ? 1 : 0
    
    If last_space && str_length
        Goto End
    Else If (digit_borders && (sc~="^(sc[2-9a-dA-D])$")) {
        ih.Stop()
        Return
    }
    Else If last_symb in % word_margins
    {
        If last_symb && word_margins_enabled {
            ih.Stop()
            Return        
        }
        Else
            text_alt.=last_symb            
    }
    Else {
        VarSetCapacity(state, 256, 0), VarSetCapacity(char, 4, 0)
        n:=DllCall("ToUnicodeEx", "uint", vk0, "uint", sc0, "ptr", &state, "ptr", &char, "int", 2, "uint", 0, "ptr", alt_lang), symb:=StrGet(&char, n, "utf-16"), 
        
        If (GetKeyState("CapsLock", "T") && !GetKeyState("Shift", "P")) || (!GetKeyState("CapsLock", "T") && GetKeyState("Shift", "P"))
            StringUpper symb, symb
        text_alt.=symb 
    }
    End:
    RegExMatch(ih_old, "\S+(?=\s?$)", text), RegExMatch(text_alt, "\S+(?=\s?$)", t_alt), RegExMatch(ih_old, "\S+\s*$", ct), str_length:=StrLen(ct)  
    If text_convert || (new_lang && new_lang_ignore)  || (mouse_click && mouse_click_ignore)
        Return
    t0:=Backslash(text), t0_alt:=Backslash(t_alt)
    If accent_ignore
        t0:=DelAccent(t0), t0_alt:=DelAccent(t0_alt)
    rs:="mi)^"
    If ((t0==Format("{:U}", t0)) || (t0_alt==Format("{:U}", t0_alt)) && (StrLen(t0)>1)) {
        If (abbr_ignore=1)
            rs:="m)^"
        If (abbr_ignore=2)
            rs:="mi)^"
        If (abbr_ignore=3)
            Return
    }
    Else
        t0:=Format("{:L}", t0), t0_alt:=Format("{:L}", t0_alt), rs:=(abbr_ignore=2) ? "mi)^" : "m)^"
    If RegExMatch(user_dic, rs . t0) {
        text_convert:=1
        Return
    }
    
    RegExMatch(dic_curr, rs . t0 (last_space ? "$" : ""), t1),
    RegExMatch(dic_alt, rs . t0_alt (last_space ? "$" : ""), t2)
    
    OutputDebug % t0 "/" t0_alt "<kn: " key_name " t1: " t1 "t2: " t2 " len: " str_length
    
    If ttip {           
        Tooltip % LangCode(il) "   " t0 "   " t1 "`n" LangCode(alt_lang) "   " t0_alt "   " t2, % A_ScreenWidth//2-200, 0, 10
        Return
    }

    If ((last_space && str_length) || (str_length>(min_length ? 2 : 1))) && t2 && !t1 {
        Critical On
        ih.VisibleText:=False
        lconvert:=single_lang ? lang_auto_single : ((il=auto1) ? auto2 : auto1)
        If sound
            SoundPlay *64
        If tray_tip {
            TrayTip,, % "Преобразование`n" LangCode(il) " / " LangCode(lconvert),, 17
            SetTimer TrayTip, -2000
        }
        If str_length && ((ks.Length()-str_length)>0)
            ks.RemoveAt(1, ks.Length()-str_length) 
        il_convert:=il, ts:=A_TickCount, keys:=ts-tstart
        Loop % str_length
            SendInput % "{BS down}{BS up}"
        SetInputLang(key_switch, lconvert)
        Sleep 50
        out_orig:=ks.Clone(), ks:=[]
        SendText(out_orig)
        SendText(ks)
        out_orig.Push(ks*)
        ih.VisibleText:=True
        Critical Off
        il_old:=InputLayout(), ih.Stop(), text_convert:=1
        FileAppend % "`r`n" t0 "/" t0_alt " - "  keys "/" A_TickCount-ts, logs\transform.log
    }       
}

TrayTip:
    TrayTip
    If (A_OSVersion~="^10") {
        Menu Tray, NoIcon
        Sleep 200
        Menu Tray, Icon
    }

    Return

Backslash(t) {
    Loop Parse, t
        If A_LoopField in  \,.,*,?,+,[,{,|,(,),^,$
            out.="\" A_LoopField
        Else
            out.=A_LoopField
    Return out
}

DelAccent(txt) {
    If (A_OSVersion="Win_XP") 
        Return RemoveLetterAccents(txt)
    Else
        Return StrUnmark(txt)
}

#If (InputLayout()~=pause_langs) && pause_langs && !(autocorrect && text_convert)
Pause::Goto Translate

#If (InputLayout()~=shift_bs_langs) && shift_bs_langs && !(autocorrect && text_convert)
+BS::Goto Translate

#If autocorrect && text_convert && ctrlz_undo
^vk5A up::
    KeyWait Ctrl, T1
        Goto Rollback
    Return

#If !(WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || WinActive("ahk_exe VirtualBoxVM.exe"))
Pause::
+BS::
    If autocorrect && text_convert {
        KeyWait BS
        KeyWait Pause
        Goto Rollback
    }
    Return
#If

Rollback:
    If sound
        SoundPlay *16
    If tray_tip {
        TrayTip
        If (A_OSVersion~="^10\.") {
            Menu Tray, NoIcon
            Sleep 200
            Menu Tray, Icon
        }
    }
    out_orig.Push(ks*)
    Loop % out_orig.Length()
        SendInput % "{BS down}{BS up}"
    SetInputLang(key_switch, il_convert)
    Sleep 5
    SendText(out_orig)
    If (A_ThisHotkey~="\+")
        Send {Shift up}
    FileAppend % "`r`n" t0 "/" t0_alt, logs\undo.log        
    FileAppend % " <==", logs\transform.log
    text_convert:="", ih.Stop(), out_orig:=[]
    Return

Select:
    If WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || WinActive("ahk_exe VirtualBoxVM.exe") || ((A_ThisHotkey=A_PriorHotkey) && (A_TimeSincePriorHotkey<50))
        Return
    hkey:=A_ThisHotkey, button:=RegExReplace(hkey,"^[\^\$\+>]+"), lang_start:=InputLayout()
    Hotkey % "*" button, Return, On
    Hotkey *BS, Return, On
    SetTimer ResetButtons, -10000
    sel:=hand_sel:=send_bs:=per_symbol_select:="", key_block:=flag_block:=1, text:=rem:=ih.Input, out:=ks.Clone(), ih.Stop(), stop:="Select"
    RegRead lang_key, HKEY_CURRENT_USER\Keyboard Layout\Toggle, Hotkey
    If StrLen(text) {
        If (button~="(RButton|MButton)")
            SetTimer Flag, Off
        If WinActive("ahk_class ConsoleWindowClass") || WinActive("ahk_class VirtualConsoleClass") || WinActive("ahk_exe WindowsTerminal.exe") || ((A_ThisHotkey~="BS$") && !pause_shift_bs) || ((A_ThisHotkey~="Pause") && pause_shift_bs) || (A_ThisHotkey~=">\+(F|sc)\d")
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
        While GetKeyState(button,"P") && !(rem~="^\s*$") {
            rem_old:=rem, rem:=per_symbol_select ? RegExReplace(rem_old,".$") : RegExReplace(rem_old,"\S+\s{0,3}$")
            Loop % (StrLen(rem_old)-StrLen(rem)) {
                SendInput % send_bs ? "{RShift up}{BS down}{BS up}" : "{RCtrl up}+{Left}"
                Sleep % send_bs ? 20 : 10
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
        sel:=SubStr(text, StrLen(rem)+1), out.RemoveAt(1, StrLen(rem)), flag_block:=""
        KeyWait % button, T1
        KeyWait RShift, T1
        KeyWait RCtrl, T1
        Sleep 50
        If (button~="(RButton|MButton)")
            SetTimer Flag, On
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
    If !sel && (capslock!=7) {
        Tooltip % "Буфер пуст -`nвыделите текст!", % x-40, % y-50
        SetTimer ToolTip, -1500
        Gosub ResetButtons
        Exit
    }
    flag_block:=0
    SetTimer ResetButtons, -1000
    Sleep 100
    out_orig:=out.Clone(), il_convert:=InputLayout(), text_convert:=1
    Return

ResetButtons:
    key_block:=flag_block:=0
    Hotkey % "*" button, Return, Off
    Hotkey *BS, Return, Off
    SetTimer Flag, On
    Return

Convert:
ReConvert:
    Sleep 100
    out:=[], convert:=""
    HKL:=DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", InputLayout()), "UInt", 0)
    Loop Parse, sel
    {
        val:=DllCall("VkKeyScanEx", "Char", Asc(A_LoopField), "UInt", HKL)
        vk:=vk_start:="vk" SubStr(Format("{:x}", val), -2)
        If (vk="vk20d") ; удаление двойных переносов
            continue
        If (vk~="vkfff") {
            If (lang_count=2) && (A_ThisLabel="Convert") && (button~="(Pause|BS|RButton|CapsLock)") {
                SetInputLang(key_switch)
                Goto Reconvert
            }
            ToolTip Неверная`nраскладка!,  % x-40, % y-50
            SetTimer ToolTip, -2000
            SetInputLang(key_switch, lang_start)
            Exit
        }
        sh:=(vk~="vk1\w\w") ? 1 : 0, sc:=Format("sc{:x}", GetKeySC(RegExReplace(vk,"vk\K\d(?=\w\w)")))
        out.Push([(sh ? "+" : "") "{" sc "}", 0]), convert.=(sh ? "+" : "") "{" sc "}"
    }
    Return

>^scD::
    Gosub Select
    SendText(InvertCase(sel))
    SetInputLang(key_switch, lang_start)
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

>^scC::
    Gosub Select
    SendText(Format("{:L}",sel))
    SetInputLang(key_switch, lang_start)
    Return

>^scB::
    Gosub Select
    SendText(Format("{:U}",sel))
    SetInputLang(key_switch, lang_start)
    Return

>^scA::
    Gosub Select
    SendText(Format("{:T}",sel))
    SetInputLang(key_switch, lang_start)
    Return

>^sc1B::
    Gosub Select
    SendText(Translit(sel))
    SetInputLang(key_switch, 0x0409)
    Return

OnFlag(hwnd) {
    MouseGetPos,,, win, ctrl
    Return (win && (win=hwnd) && (ctrl~="Static")) ? 1 : 0
}

#If OnFlag(FlagHwnd)
RButton::
    If (InputLayout()~=pause_langs) && pause_langs
        Goto Translate
    Return

MButton::
    Gosub Select
    SendText(InvertCase(sel))
    Return

#If (capslock=3) && (InputLayout()~=pause_langs) && pause_langs
CapsLock::
    If autocorrect && text_convert {
        KeyWait CapsLock
        Gosub RollBack
    }
    Else
        Gosub Translate
    SetCapsLockState AlwaysOff
    Return 
    
#If

Translate:
    Gosub Select
    If hand_sel
        Gosub Convert
    Gosub SetInputLang
    Sleep 50
    SendText(out)
    ih.Stop()
    ;FileAppend % A_Now " " hkey " " A_ThisHotkey " " InputLayout() "`r`ntext: " text " (" text.Length() ")`r`nsel: " sel "`r`nconvert: " convert "`r`nsc_string: " sc_string "`r`n`r`n", Log.txt, UTF-8 ; логирование введенного и обработанного текста
    Return

;=======================================
SetInputLang:
    ;If WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || WinActive("ahk_exe VirtualBoxVM.exe")
        ;Return
    _pause_langs:=StrSplit(SubStr(pause_langs, 2, -1), "|"), _shift_bs_langs:=StrSplit(SubStr(shift_bs_langs, 2, -1), "|")
    StringCaseSense Off
    If (A_ThisHotkey~="^(LShift|RShift|LCtrl|RCtrl)"){
        hk:=RegExReplace(A_ThisHotkey, " up$"), target=%hk%
        If (target=1)
            target:=0
        If (target=2) {
            curr_lang:=InputLayout()
            Loop % lang_count
                If (curr_lang=lang_array[A_Index, 1])
                    ln:=A_Index
            target:=(ln>1) ? lang_array[ln-1, 1] : lang_array[lang_count, 1]
        }
        SetInputLang(key_switch, target)
        Return
    }
    If (A_ThisHotkey~="^<\^sc\d+$") || (A_ThisHotkey~="^<!sc\d+$") { ; LCtr+#, LAlt+#
        target:=lang_array[SubStr(A_ThisHotkey, 0)-1, 1]
        KeyWait % RegExReplace(A_ThisHotkey, ".+(?=sc)"), T1
        KeyWait LCtrl, T1
        KeyWait LAlt, T1
        Sleep 100
        SetInputLang(key_switch, target)
        Return
    }
    If (hkey~="^>\^F\d+$") || (hkey~="^>\+F\d+$")
        target:=lang_array[SubStr(hkey, 0),1]
    If (hkey~="^>\^sc\d+$") || (hkey~="^>\+sc\d+$")
        target:=lang_array[SubStr(hkey, 0)-1,1]
    If (A_ThisHotkey~="^>\^>\+F\d+$") {
        target:=lang_array[SubStr(A_ThisHotkey, 0),1]
        KeyWait RCtrl, T1
        KeyWait RShift, T1
    }
    If (A_ThisHotkey~="^>\^>\+sc\d+$") {
        target:=lang_array[SubStr(A_ThisHotkey, 0)-1,1]
        KeyWait RCtrl, T1
        KeyWait RShift, T1
    }
    If (hkey~="^(RButton|Pause)$") || ((hkey="Capslock") && (capslock=3))
        target:=(lang_start=_pause_langs[1]) ? _pause_langs[2] : _pause_langs[1]
    If (hkey="+BS")
        target:=(lang_start=_shift_bs_langs[1]) ? _shift_bs_langs[2] : _shift_bs_langs[1]
    SetInputLang(key_switch, Format("{:#.4x}", target))
    Sleep 200
    Return

#If lshift && !key_block && !GetKeyState("LCtrl", "P")    
LShift up::
    Sleep 10
    Send {LShift up}
    If double_click && !((A_ThisHotkey=A_PriorHotkey) && (A_TimeSincePriorHotkey<400))
        Return
    If (A_TickCount-lang_change_time<1000)
        Return    
    Gosub SetInputLang
    ih.Stop(), new_lang:=1, key_name:=text_convert:=""
    Return


#If rshift && !key_block && !GetKeyState("RCtrl", "P")
RShift up::
    Sleep 10
    Send {RShift up}
    If double_click && !((A_ThisHotkey=A_PriorHotkey) && (A_TimeSincePriorHotkey<400))
        Return
    If (A_TickCount-lang_change_time<1000)
        Return    
    Gosub SetInputLang
    ih.Stop(), new_lang:=1, key_name:=text_convert:=""
    Return

#If lctrl && !key_block && !GetKeyState("LShift", "P")
LCtrl up::
    Sleep 10
    Send {LCtrl up}
    If double_click && !((A_ThisHotkey=A_PriorHotkey) && (A_TimeSincePriorHotkey<400))
        Return
    If (A_TickCount-lang_change_time<1000)
        Return    
    Gosub SetInputLang
    ih.Stop(), new_lang:=1, key_name:=text_convert:=""
    Return

#If rctrl && !key_block && !GetKeyState("RShift", "P")
RCtrl up::
    Sleep 10
    Send {RCtrl up}
    If double_click && !((A_ThisHotkey=A_PriorHotkey) && (A_TimeSincePriorHotkey<400))
        Return
    If (A_TickCount-lang_change_time<1000)
        Return    
    Gosub SetInputLang
    Sleep 200
    ih.Stop(), new_lang:=1, key_name:=text_convert:=""
    Return

#If (capslock=-1)
CapsLock::Shift

#If !capslock
CapsLock::Return

#If (capslock=2)
CapsLock::
    SetInputLang(key_switch)
    KeyWait CapsLock, T1
    SetCapsLockState AlwaysOff
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
    SendText(InvertCase(sel))
    SetCapsLockState AlwaysOff
    Return

#If !OnFlag(FlagHwnd)
~*LButton::
~*MButton::
    ih.Stop(), stop:="Mouse"
    If GetCaretLocation(_x, _y)
        wheel:=x_wheel:=y_wheel:=0
    MouseGetPos,,, new_win
    WinExist("ahk_id" new_win)
    If (new_win=print_win)
        mouse_click:=1
    Else
        new_lang:=""
    print_win:=new_win, text_convert:=key_name:=""
    Return

~*WheelUp::
~*WheelDown::
~*WheelRight::
~*WheelLeft::
    ih.Stop(), stop:="Mouse"
    If (cl~="^(ApplicationFrameWindow|Chrome_WidgetWin_\d|MozillaWindowClass|Slimjet_WidgetWin_1)") {
        wheel:=1, x_wheel:=_x, y_wheel:=_y
        Gui Hide
    }
    Return

#If

OnTaskBar() {
    MouseGetPos,,, win_id
    WinGetClass class, ahk_id %win_id%
    Return (class="Shell_TrayWnd") ? 1 : 0
}

Return:
    Return

Scaling:
    If (A_ThisMenuItemPos=1)
        scaling=0
    If (A_ThisMenuItemPos=2)
        scaling=5
    If (A_ThisMenuItemPos=3)
        scaling=3
    If (A_ThisMenuItemPos=4)
        scaling=4
    If (A_ThisMenuItemPos=5)
        scaling=7
Apply:
    Gosub Settings
    Sleep 200
    Reload
    Return

Smoothing:
    If (A_ThisMenuItemPos=4)
        smoothing:=(smoothing=2) ? 3 : 2
    Goto Apply

NoBorder:
    If (A_ThisMenuItemPos=5)
        no_border:=!no_border
    Goto Apply

FlagAspect:
    If (A_ThisMenuItemPos=6)
        file_aspect:=!file_aspect
    Goto Apply

Lang_Switcher:
    lang_switcher:=!lang_switcher
    Goto Apply
    
OnFullScreen:
    on_full_screen:=!on_full_screen
    Goto Apply

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
    Goto Apply

NumLock:
    numlock_on:=!numlock_on
    Goto Apply

NumLock_Icon:
    If (A_ThisMenuItemPos=3)
        numlock_icon:=!numlock_icon
    Else
        numlock_icon_in:=!numlock_icon_in
    Goto Apply

ScrollLock:
    scrolllock:=!scrolllock
    Goto Apply

ScrollLock_Icon:
    If (A_ThisMenuItemPos=3)
        scrolllock_icon:=!scrolllock_icon
    Else
        scrolllock_icon_in:=!scrolllock_icon_in
    Goto Apply

As_Flag:
    flag_sett:=!flag_sett
    Goto Apply


Aspect:
    aspect:=1
    If (A_ThisMenuItem~="5")
        aspect:=2
    If (A_ThisMenuItem~="2")
        aspect:=0
    Goto Apply

SymbSel:
    symbsel:=symbsel ? 0 : 1
    Goto Apply

StartOnly:
    startonly:=startonly ? 0 : 1
    Goto Apply

EnterOn:
    enter_on:=enter_on ? 0 : 1
    Goto Apply

TabOn:
    tab_on:=tab_on ? 0 : 1
    Goto Apply
    
Reset:
    CheckText := "*Сохранить копию текущих"
    msg:="Все настройки к значениям по умолчанию?`nКнопка 'Бэкап' сохраняет копию без сброса"
    Result := MsgBoxEx(msg, "Сброс настроек", "OK|Бэкап|Cancel*", 5, CheckText, "AlwaysOnTop", 0, 0, "s10 c0x000000", "Sego UI", "0x8CB9D7")
    If (Result =="Cancel")
        Return
    If (Result == "OK") {
        If CheckText
            Run % "bin\7zr.exe a backup\backup_" A_YYYY "." A_MM "." A_DD "_" A_Hour "." A_Min "." A_Sec ".zip " cfg_folder "\*"  
        FileDelete % cfg
        Sleep 200
        Reload
    }
    If (Result == "Бэкап")
        Run % "bin\7zr.exe a backup\backup_" A_YYYY "." A_MM "." A_DD "_" A_Hour "." A_Min "." A_Sec ".zip " cfg_folder "\*"   
        If !ErrorLevel {
            MsgBox, 64, , Бэкап сохранен в подпапке backup программы!, 2
            SetTimer ToolTip, -2000
        }
    Return

#If WinActive("LangBar++ ahk_class AutoHotkeyGUI")
Esc::WinClose LangBar++ ahk_class AutoHotkeyGUI
#If

Help:
    Run doc\ReadMe.html
    If ErrorLevel
        Run % A_WinDir "\System32\OpenWith.exe " """" A_ScriptDir "doc\ReadMe.html"""
    Return

Changelog:
    Run % """" editor """ doc\Changelog.txt"
    Return

About:
    Gui 4:Destroy
    Gui 4:Margin, 24, 12
    Gui 4:Font, s9
    Gui 4:Color, 8CB9D7
    Gui 4:-DPIScale +AlwaysOnTop +ToolWindow +HwndGui4
    Gui 4:Add, Link, x110, <a href="https://github.com/Krot66/LangBarXX">GitHub</a>
    Gui 4:Add, Link, x70 yp+24 , <a href="http://forum.ru-board.com/topic.cgi?forum=5&topic=50256#1">Форум Ru.Board</a>
    If A_IsCompiled
        Gui 4:Add, Picture, x60 y+16 w160 h-1 Icon1, % A_ScriptName
    Else
        Gui 4:Add, Picture, x60 y+16 w160 h-1, src\LB.ico
    Gui 4:Font, s10
    Gui 4:Add, Text, x40 y+10, % "LangBar++ v. " version " " (A_PtrSize=8 ? "x64" : "x32") . (FileExist("config") ? "`n             portable" : "")
    Gui 4:Font, s9
    Gui 4:Add, Button, x80 y+16 w120 h32 g4GuiClose, OK
    Gui 4:Show, w270, О программе
    Return

4GuiClose:
    Gui 4:Destroy
    Return

#If WinActive("ahk_id" Gui4 )
Esc::Goto 4GuiClose
#If

Exit:
    Loop % lang_count
        Gdip_DisposeImage(lang_array[A_Index, 4])
    Gdip_DisposeImage(pCaps)
    Gdip_DisposeImage(pNumLock)
    Gdip_DisposeImage(pScrollLock)
    Gdip_DisposeImage(pNumScroll)
    Gdip_DeleteBrush(Brush)
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
    Goto Apply

LB_WatchDog:
    Process Exist, LB_WatchDog.exe
    If !ErrorLevel
        Run % "bin\LB_WatchDog.exe " A_ScriptName
    Return

Settings:
    FileEncoding UTF-16
    IniWrite % version, % cfg, Main, Version

    IniWrite % pause_langs, % cfg, Layouts, Pause_Langs
    IniWrite % shift_bs_langs, % cfg, Layouts, Shift_BS_Langs
    IniWrite % pause_shift_bs, % cfg, Layouts, Pause_Shift_BS
    IniWrite % key_switch, % cfg, Layouts, Key_Switch
    IniWrite % lang_select, % cfg, Layouts, Lang_Select
    IniWrite % lctrl, % cfg, Layouts, LCtrl
    IniWrite % rctrl, % cfg, Layouts, RCtrl
    IniWrite % lshift, % cfg, Layouts, LShift
    IniWrite % rshift, % cfg, Layouts, RShift
    IniWrite % double_click, % cfg, Layouts, Double_Click
    IniWrite % digit_keys, % cfg, Layouts, Digit_Keys
    IniWrite % f_keys, % cfg, Layouts, F_Keys
    
    IniWrite % font_size, % cfg, TextFlags, Font_Size
    IniWrite % bold, % cfg, TextFlags, Bold
    IniWrite % font_color, % cfg, TextFlags, Font_Color
    IniWrite % radius, % cfg, TextFlags, Radius
    IniWrite % gradient, % cfg, TextFlags, Gradient
    
    IniWrite % flag, % cfg, Flag, Flag
    IniWrite % dx, % cfg, Flag, DX
    IniWrite % dy, % cfg, Flag, DY
    IniWrite % width, % cfg, Flag, Width
    IniWrite % transp, % cfg, Flag, Transp
    IniWrite % scaling, % cfg, Flag, Scaling
    IniWrite % smoothing, % cfg, Flag, Smoothing
    IniWrite % no_border, % cfg, Flag, No_Border
    IniWrite % file_aspect, % cfg, Flag, File_Aspect
    
    Loop % lang_array.Length() {
        IniWrite % lang_array[A_Index, 6], % cfg, Colors, % "C_" lang_array[A_Index, 1] 
        IniWrite % (lang_array[A_Index, 7]) ? 1 : 0, % cfg, Colors, % "T_" lang_array[A_Index, 1]
    }

    IniWrite % indicator, % cfg, Indicator, Indicator
    IniWrite % lang_switcher, % cfg, Indicator, Lang_Switcher
    IniWrite % on_full_screen, % cfg, Indicator, On_Full_Screen
    IniWrite % dx_in_1, % cfg, Indicator, DX_In_1
    IniWrite % dy_in_1, % cfg, Indicator, DY_In_1
    IniWrite % dx_in_2, % cfg, Indicator, DX_In_2
    IniWrite % dy_in_2, % cfg, Indicator, DY_In_2
    IniWrite % width_in, % cfg, Indicator, Width_In
    IniWrite % transp_in, % cfg, Indicator, Transp_In
    IniWrite % numlock_icon_in, % cfg, Indicator, NumLock_Icon_In
    IniWrite % scrolllock_icon_in, % cfg, Indicator, ScrollLock_Icon_In
    
    IniWrite % aspect, % cfg, Tray, Aspect
    IniWrite % icon_shift, % cfg, Tray, Icon_Shift
    IniWrite % numlock_icon, % cfg, Tray, NumLock_Icon
    IniWrite % scrolllock_icon, % cfg, Tray, ScrollLock_Icon
    IniWrite % flag_sett, % cfg, Tray, Flag_Sett

    IniWrite % capslock, % cfg, Keys, CapsLock
    IniWrite % scrolllock, % cfg, Keys, ScrollLock
    IniWrite % numlock_on, % cfg, Keys, NumLock_On

    IniWrite % wordint, % cfg, Select, WordInt
    IniWrite % wait, % cfg, Select, Wait
    IniWrite % symbint, % cfg, Select, SymbInt
    IniWrite % symbsel, % cfg, Select, SymbSel
    IniWrite % startonly, % cfg, Select, StartOnly
    IniWrite % enter_on, % cfg, Select, Enter_On
    IniWrite % tab_on, % cfg, Select, Tab_On
    
    IniWrite % autocorrect, % cfg, Autocorrect, Autocorrect
    IniWrite % single_lang, % cfg, Autocorrect, Single_Lang
    IniWrite % lang_auto, % cfg, Autocorrect, Lang_Auto   
    IniWrite % only_main_dict, % cfg, Autocorrect, Only_Main_Dict
    IniWrite % lang_auto_single, % cfg, Autocorrect, Lang_Auto_Single
    IniWrite % lang_auto_others, % cfg, Autocorrect, Lang_Auto_Others
    IniWrite % min_length, % cfg, Autocorrect, Min_Length
    IniWrite % sound, % cfg, Autocorrect, Sound
    IniWrite % tray_tip, % cfg, Autocorrect, Tray_Tip
    IniWrite % accent_ignore, % cfg, Autocorrect, Accent_Ignore
    IniWrite % ctrlz_undo, % cfg, Autocorrect, CtrlZ_Undo
    IniWrite % no_indicate, % cfg, Autocorrect, No_Indicate
    IniWrite % abbr_ignore, % cfg, Autocorrect, Abbr_Ignore
    IniWrite % short_abbr_ignore, % cfg, Autocorrect, Short_Abbr_Ignore
    IniWrite % word_margins_enabled, % cfg, Autocorrect, Word_Margins_Enabled
    IniWrite % word_margins, % cfg, Autocorrect, Word_Margins
    IniWrite % digit_borders, % cfg, Autocorrect, Digit_Borders
    IniWrite % new_lang_ignore, % cfg, Autocorrect, New_Lang_Ignore
    IniWrite % mouse_click_ignore, % cfg, Autocorrect, Mouse_Click_Ignore
    FileEncoding UTF-8
    Return

ToolTip:
    ToolTip
    ToolTip,,,, 2
    Return

LangBar:
    SetTimer TrayIcon, Off
    SetTimer Flag, Off
    Gui Destroy
    KeyWait LButton, T1
    Sleep 50
    Send !{Esc}
    Sleep 150
    SetInputLang(key_switch)
    ih.Stop()
    SetTimer TrayIcon, On
    Sleep 100 ; !!!!!!
    SetTimer Flag, On
    Return

<+RShift::
>+LShift::
FlagToggle:
    flag:=!flag
    Menu Flag, % flag ? "Check" : "Uncheck", 1&
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
~!Shift up::
    SetTimer TrayIcon, Off
    SetTimer Flag, Off
    ih.Stop(), lang_old:=lang_in_old:=lang_fl_old:=caps_old:=caps_in_old:=""
    Sleep 150
    Gosub Masks
    SetTimer TrayIcon, On
    Sleep 30
    SetTimer Flag, On
    Return
    
^+!vkBE::
    ttip1:=!ttip1
    If !ttip1 {
        ToolTip,,,, 12
        ToolTip,,,, 13
    }        
    Return

#If OnFlag(IndHwnd) && lang_switcher
LButton::
    SetInputLang(key_switch)
    ih.Stop()
    Return
#If

^+!vk54::
#If OnFlag(FlagHwnd)
^LButton::
    ttip:=!ttip
    If !ttip
        ToolTip,,,, 10
    Else
        autocorrect:=1
    Return
    
LButton::
    SetInputLang(key_switch)
    ih.Stop()
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
    DX:=16, DY:=-12, width:=22, transp:=100, mess:="Флажок по`nумолчанию!"
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
    Gui Add, Picture, x0 y0 w96 h128 +HwndCapsID
    Gui Add, Picture, x0 y0 w96 h128 +HwndFlagID
    Gui Add, Picture, x0 y0 w96 h128 +HwndAutocorrectID AltSubmit BackGroundTrans
    Gui Color, 3F3F3F
    WinSet, TransColor, % "3F3F3F " transp*255//100
    Return

IndicatorGui:
    Gui 11:Destroy
    Gui 11:-DPIScale
    click_transparent:=lang_switcher ? "" : "+E0x20"
    Gui 11:+AlwaysOnTop -Caption +ToolWindow +LastFound +HwndIndHwnd %click_transparent%
    Gui 11:Add, Picture, x0 y0 w256 h256 +HwndIndCapsID
    Gui 11:Add, Picture, x0 y0 w256 h256 +HwndIndID
    Gui 11:Add, Picture, x0 y0 w256 h256 +HwndIndAutocorrectID AltSubmit BackGroundTrans
    Gui 11:Color, 3F3F3F
    WinSet, TransColor, % "3F3F3F " transp_in*255//100
    Return

Masks:
    Gdip_DisposeImage(pAutocorrect)
    pAutocorrect:=Gdip_CreateBitmapFromFile("masks\Autocorrect.png")
    AutocorrectHandle:=Gdip_CreateHBITMAPFromBitmap(pAutocorrect)       
    Gdip_DisposeImage(pSingleLang)
    pSingleLang:=Gdip_CreateBitmapFromFile("masks\SingleLang.png")
    SingleLangHandle:=Gdip_CreateHBITMAPFromBitmap(pSingleLang)       
    Gdip_DisposeImage(pCaps)
    pCaps:=Gdip_CreateBitmapFromFile("masks\CapsLock.png")
    CapsHandle:=Gdip_CreateHBITMAPFromBitmap(pCaps)
    Gdip_DisposeImage(pNumLock)
    pNumLock:=Gdip_CreateBitmapFromFile("masks\NumLock.png")
    Gdip_DisposeImage(pScrollLock)
    pScrollLock:=Gdip_CreateBitmapFromFile("masks\ScrollLock.png")
    Gdip_DisposeImage(pNumScroll)
    pNumScroll:=Gdip_CreateBitmapFromFile("masks\NumScroll.png")
    Gdip_DeleteBrush(Brush)
    Brush:=Gdip_BrushCreateSolid(0x33000000)
    Return

TrayIcon:
    If ttip1 {
        ToolTip % "sl/ks: " str_length "/" ks.Length() " rs: " rs " tc/nl/mc: " text_convert "/" new_lang "/" mouse_click " ls: " last_space, 250, 0, 12
        Tooltip % ">" t0 "<>" t1 "<ls: " last_space " kn: " key_name "`n>" t0_alt "<>" t2 "<", 550, 0, 13
        ;ToolTip % ih.EndReason " " ih.EndKey " " ((ih.EndReason="Stopped") ? stop : ""), 700, 0, 14
    }
    lang:=InputLayout(), lang:=lang ? lang : lang_old
    If (lang!=lang_old)
        lang_change_time:=A_TickCount
    WinGetClass cl, A
    If (cl="#32768")
        Return
    If upd
        Goto Indicator
    Loop % lang_array.Length()
        If (lang=lang_array[A_Index, 1])
            pFlag:=lang_array[A_Index, 4], text_flag:=lang_array[A_Index, 7]
    num:=GetKeyState("NumLock","T"), scr:=GetKeyState("ScrollLock","T"), caps:=GetKeyState("CapsLock","T")
    If (lang && (lang!=lang_old))||(num!=num_old)||(scr!=scr_old) || (autocorrect!=autocorrect_old) || (single_lang!=single_lang_old) {
        Gdip_GetImageDimensions(pFlag, wf, hf)
        size:=24
        If A_OSVersion in WIN_XP,WIN_VISTA,WIN_7
            size:=16
        pMem:=Gdip_CreateBitmap(size, size)
        T:=Gdip_GraphicsFromImage(pMem)
        Gdip_SetSmoothingMode(T, flag_sett ? smoothing : 2)
        Gdip_SetInterpolationMode(T, flag_sett ? scaling : 7)
        hf2:=!aspect ? size*2//3 : ((aspect=1) ? size*3//4 : size*4//5)
        shift:=(size-hf2)//2
        If (num && numlock_icon) || (scr && scrolllock_icon)
            shift:=(icon_shift=0) ? (size-hf2)//2 : ((icon_shift=1) ? size-hf2 : 0)
        Gdip_DrawImage(T, pFlag, 0, shift, size, hf2, 0, 0,wf, hf)
        If (num && numlock_icon) {
            pNumLock_tray:=(scrolllock_icon && scrolllock) ? pNumLock : pNumScroll
            Gdip_DrawImage(T, pNumLock_tray, 0, 0, size, size)
        }
        If (scr && scrolllock_icon && scrolllock) {
            pScrollLock_tray:=numlock_icon ? pScrollLock : pNumScroll
            Gdip_DrawImage(T, pScrollLock_tray, 0, 0, size, size)
        }
        If autocorrect && !no_indicate       
            Gdip_DrawImage(T, single_lang ? pSingleLang : pAutocorrect, Round(size*.28), size*.6, Round(size*.44), Round(size*.44))
        DeleteObject(IconHandle)
        IconHandle:=Gdip_CreateHICONFromBitmap(pMem)
        If !IconHandle {
            FileAppend error, logs\tray_icon.log
            Return
        }
        Sleep 5
        Menu Tray, Icon, hicon:%IconHandle%,, 1
        Gdip_DisposeImage(pMem)
        Gdip_DeleteGraphics(T)
        lang_old:=lang, num_old:=num, scr_old:=scr, autocorrect_old:=autocorrect, single_lang_old:=single_lang
    }

Indicator:
    WinGet pn, ProcessName, A
    WinGetClass cl, A
    If (cl~="(Shell_TrayWnd|WorkerW|Progman)") || (IsFullScreen() && !on_full_screen){
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
    If (app_state>0) || (indicator && !(app_state=0)) || WinExist("ahk_id" Gui5) {
        If upd || !WinExist("ahk_id" IndHwnd) || (lang && (lang!=lang_in_old)) || (num!=num_in_old) || (scr!=scr_in_old) || (caps!=caps_in_old) || (autocorrect!=autocorrect_in_old) || (single_lang!=single_lang_in_old) {
            w_in:=width_in*MWRight//100, h_in:=(file_aspect && !text_flag) ? w_in*hf//wf : w_in*3//4
            x_in:=dx_in*MWRight//100-w_in//2, y_in:=dy_in*MWBottom//100-h_in//2
            
            mn:=(!no_border && !text_flag) ? ((w_in>60) ? 2 : 1) : 0 ; Величина полей
            pBitmap:=Gdip_CreateBitmap(w_in, w_in)
            I:=Gdip_GraphicsFromImage(pBitmap)
            Gdip_SetSmoothingMode(I, 4)
            Gdip_SetInterpolationMode(I, 7)
            If mn
                Gdip_FillRectangle(I ,Brush, -1, w_in-h_in-1, w_in+1, h_in+1)
            Gdip_DrawImage(I, pFlag, mn, w_in-h_in+mn, w_in-mn*2, h_in-mn*2, 0, 0, wf, hf)
            If (num && numlock_icon_in) {
                pNumLock_in:=(scrolllock_icon_in && scrolllock) ? pNumLock : pNumScroll
                Gdip_DrawImage(I, pNumLock_in, 0, 0, w_in, w_in)
            }
            If (scr && scrolllock_icon_in && scrolllock) {
                pScrollLock_in:=numlock_icon_in ? pScrollLock : pNumScroll
                Gdip_DrawImage(I, pScrollLock_in, 0, 0, w_in, w_in)
            }
            WinSet, TransColor, % "3F3F3F " transp_in*255//100, ahk_id %IndHwnd%
            DeleteObject(IndicatorHandle)
            IndicatorHandle:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
            Gdip_DisposeImage(pBitmap)
            Gdip_DeleteGraphics(I)
            Gui IndHwnd:Default
            GuiControl,, %IndID%, *w%w_in% *h-1 hbitmap:*%IndicatorHandle%
            Gui 11:Show, x%x_in% y%y_in% NA
            WinSet Top,, ahk_id %IndHwnd%            
            If caps {
                GuiControl,, %IndCapsID%, *w%w_in% *h%h_in% hbitmap:*%CapsHandle%
                GuiControl Move, % IndCapsID, % "x" w_in//5 "y" w_in-h_in+w_in//6
                GuiControl Show, % IndCapsID
            }
            Else
                GuiControl Hide, % IndCapsID
            Gui IndHwnd:Default
            If autocorrect && !no_indicate {
                au_h1:=w_in*.4, AinHandle:=single_lang ? SingleLangHandle : AutocorrectHandle
                GuiControl,, % IndAutocorrectID, *w%au_h1% *h%au_h1% hbitmap:*%AinHandle%
                GuiControl MoveDraw, % IndAutocorrectID, % "x" w_in*.34 "y" w_in*.8
                GuiControl Show, % IndAutocorrectID
            }
            Else
                GuiControl Hide, % IndAutocorrectID
            If indicator && !WinExist("ahk_id" IndHwnd)
                Gosub IndicatorGui
            lang_in_old:=lang, width_in_old:=width_in, caps_in_old:=caps, num_in_old:=num, scr_in_old:=scr, upd:=0, autocorrect_in_old:=autocorrect, single_lang_in_old:=single_lang
        }
    }
    Else
        Gui 11:Hide
    Return
    
IsFullScreen(win="A") {
	SysGet, M, Monitor
	WinGetPos, , , w, h, % win
	MouseGetPos, , , , ctrl
	f:=0
	If (w>=MRight && h>=MBottom && ctrl!="PowerProChildToolbar1")
		f:=1
	return f
}

Flag:
    ;ToolTip % A_ThisHotkey " " A_PriorHotkey " " ih.Input " " ks.Length() " " out.Length(), 0, 0, 8
    WinGetClass cl, A
    If cl not in Shell_TrayWnd,#32768
        lastwin:=WinExist("A")
    If lastwin && (lastwin!=lastwin_old) {
        Gui Hide
        SetTimer Flag, Off
        SetTimer TrayIcon, Off
        lang_old:=lang_in_old:=lang_fl_old:=""
        Sleep 200
        SetTimer TrayIcon, On
        Sleep 50
        SetTimer Flag, On
        ih.Stop(), stop:="NewWindow"
    }
    If !InputLayout() {
        Gui Hide
        Return        
    }
    GetCaretLocation(_x, _y), x:=_x+DX, y:=_y+DY
    If wheel && ((_x!=x_wheel) || (_y!=y_wheel))
        wheel:=0
    If flag && _x && _y && (FlagHwnd!=WinExist("A")) && !wheel {
        If ((pFlag_old!=pFlag) && !flag_block) || (width!=width_old) || !WinExist("ahk_id" FlagHwnd) {
            fl_h:=(file_aspect && !text_flag) ? width*hf//wf : width*3//4,
            mn:=(!no_border && !text_flag) ? 1 : 0
            pBanner:=Gdip_CreateBitmap(width+mn*2, fl_h+mn*2)
            F:=Gdip_GraphicsFromImage(pBanner)
            Gdip_SetSmoothingMode(F, smoothing)
            Gdip_SetInterpolationMode(F, scaling)
            If mn
                Gdip_FillRectangle(F ,Brush, -1, -1, width+mn*2+2, fl_h+mn*2+2)
            Gdip_DrawImage(F, pFlag, mn, mn, width, fl_h, 0, 0, wf, hf)
            DeleteObject(FlagHandle)
            FlagHandle:=Gdip_CreateHBITMAPFromBitmap(pBanner)
            Gdip_DisposeImage(pBanner)
            Gdip_DeleteGraphics(F)
            Sleep 5
            Gui Default
            GuiControl,, %FlagID%, *w%width% *h%fl_h% hbitmap:*%FlagHandle%
            pFlag_old:=pFlag
        }
        WinSet, TransColor, % "3F3F3F " transp*255//100, ahk_id %FlagHwnd%
        Gui FlagHwnd:Default
        GuiControlGet caps_vis, Visible, % CapsID
        GuiControlGet au_vis, Visible, % AutocorrectID
        If (autocorrect && !au_vis && !no_indicate) || (single_lang_fl_old!=single_lang) || (width!=width_old) {
            au_h:=width*.4, Afl:=single_lang ? SingleLangHandle : AutocorrectHandle
            GuiControl,, % AutocorrectID, *w%au_h% *h%au_h% hbitmap:*%Afl%
            GuiControl Move, % AutocorrectID, % "x" width*.4 "y" fl_h*.8
            GuiControl Show, % AutocorrectID
        }
        If !autocorrect || no_indicate
            GuiControl Hide, % AutocorrectID
            
        If (caps && !caps_vis) || (width!=width_old) {
            GuiControl,, % CapsID, *w%width% *h%fl_h% hbitmap:*%CapsHandle%
            GuiControl Move, % CapsID, % "x" width//5 "y" width//6
            GuiControl Show, % CapsID
        }
        If !caps
            GuiControl Hide, % CapsID
        Gui Show, x%x% y%y% NA
        WinSet Top,, ahk_id %FlagHwnd%
        If !WinExist("ahk_id" FlagHwnd)
            Gosub FlagGui
        width_old:=width, fl_h_old:=fl_h, caps_old:=caps, autocorrect_fl_old:=autocorrect, single_lang_fl_old:=single_lang
    }
    Else
        Gui FlagHwnd:Hide
    lastwin_old:=lastwin 
    Return

LayoutsAndFlags:
    SetTimer TrayIcon, Off
    SetTimer Flag, Off
    Sleep 200
    Gui 3:Destroy
    Gui 3:+LastFound -DPIScale -MinimizeBox +hWndGui3
    Gui 3:Default
    Gui 3:Color, 6DA0B8
    Gui 3:Margin, 16, 12
    Gui 3:Font, s9
    Gui 3:Add, ListView, x14 w620 -Multi Grid R4 -LV0x10 HwndHLV gSetColor Checked NoSort ReadOnly, N|Раскладка|Hex|Флажок|Есть?|Словарь
    ImageListID:=IL_Create(10)
    LV_SetImageList(ImageListID)
    row:=0, lang_array:=[], uflag:=0, lang_index:="0,1,2"
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
        lang_name:=lang_name ? lang_name : "???", lhex:="0x" SubStr(kl, -3)
        lcode:=LangCode(lhex), kl_flag:="flags\" lcode ".png", 
        lt:=lcode ? Format("{:U}", SubStr(lcode, -1)) : "??",
        lcode:=lcode ? lcode : lhex
        IniRead t_%lhex%, % cfg, Colors, T_%lhex%, % " "
        IniRead c_%lhex%, % cfg, Colors, C_%lhex%, % " "
        If !c_%lhex%
            c_%lhex%:=Format("{:.6X}", default_colors[A_Index])
        If !FileExist(kl_flag)
            t_%lhex%:=1
        If t_%lhex% {
            pFlag:=Gdip_CreateBitmap(64, 48)
            T:=Gdip_GraphicsFromImage(pFlag)
            Gdip_SetSmoothingMode(I, 4)
            Gdip_SetInterpolationMode(I, 2)
            Brush:=Gdip_CreateLineBrushFromRect(0, 0, 12, 48, "0xff" Brightness(c_%lhex%, gradient), "0xff" c_%lhex%)
            Gdip_FillRoundedRectangle(T, Brush, 0, 0, 64, 48, _radius)
            Gdip_DeleteBrush(Brush)
            Options=x-4 y4 Center vCenter %_bold% cff%font_color% r4 s%font_size%
            Gdip_TextToGraphics(T, lt, Options, "Arial", 72, 48)
            Handle:=Gdip_CreateHICONFromBitmap(pFlag)           
            Gdip_DeleteGraphics(T)          
        }
        Else
            pFlag:=Gdip_CreateBitmapFromFile(kl_flag)
     
        lang_array.Push([lhex, lang_name, kl_flag, pFlag, lcode, c_%lhex%, t_%lhex%])
        lang_index.="," lhex
        row++

        Gdip_GetImageDimensions(pFlag, wf, hf)
        pMem:=Gdip_CreateBitmap(32, 32)
        G:=Gdip_GraphicsFromImage(pMem)
        Gdip_DrawImage(G, pFlag, 0, 4, 32, 24)
        DeleteObject(Handle)
        Handle:=Gdip_CreateHICONFromBitmap(pMem)
        Gdip_DisposeImage(pMem)
        Gdip_DeleteGraphics(G)
        IL_Add(ImageListID, "HICON:*" Handle)
        LV_Add("Icon" A_Index " " (t_%lhex% ? "Check" : ""), " " row, lang_name, lhex, lcode ".png", FileExist("flags\" lcode ".png") ? "Да" : "Нет")
    }
    If lshift not in % lang_index
        lshift:=0
    If rshift not in % lang_index
        rshift:=0
    If lctrl not in % lang_index
        lctrl:=0
    If rctrl not in % lang_index
        rctrl:=0
    lang_menu:="Выкл.|Перекл. +|Перекл. -", lshift_ind:=rshift_ind:=lctrl_ind:=rctrl_ind:="", lang_menu_single:="", lang_menu_s:=[]
    Loop % lang_array.Length() {
        lang_menu.="|" lang_array[A_Index, 2],
        fsize:=Format("{:0.2f}", FolderSize("dict\" lang_array[A_Index, 5])/1000000)
        If FileExist("dict\" lang_array[A_Index, 5]) && fsize {             
            LV_Modify(A_Index,,,,,,, fsize " MB")
            lang_menu_single.=A_Index ". " lang_array[A_Index, 2] "|", lang_menu_s.Push(lang_array[A_Index, 1]) 
        }
        Else
            LV_Modify(A_Index,,,,,,, "-")
        If (lshift=lang_array[A_Index, 1])
            lshift_ind:=A_Index+3
        If (rshift=lang_array[A_Index, 1])
            rshift_ind:=A_Index+3
        If (lctrl=lang_array[A_Index, 1])
            lctrl_ind:=A_Index+3
        If (rctrl=lang_array[A_Index, 1])
            rctrl_ind:=A_Index+3
    }
    lshift_ind:=lshift_ind ? lshift_ind : lshift+1,
    rshift_ind:=rshift_ind ? rshift_ind : rshift+1,
    lctrl_ind:=lctrl_ind ? lctrl_ind : lctrl+1,
    rctrl_ind:=rctrl_ind ? rctrl_ind : rctrl+1,
    lang_count:=row, lang_set:="Выкл.|", lc_count:=0, pause_kl:=1, shift_bs_kl:=1, lang_list:=[0], lang_menu_single:=RegExReplace(lang_menu_single, "\|$"), lang_set_auto:="", lang_list_auto:=[]
    Loop % lang_count-1
    {
        lc:=A_Index
        Loop % (lang_count-lc) {
            lang_set.=lc "/" lc+A_Index " (" SubStr(lang_array[lc,2], 1, 20) "/" SubStr(lang_array[lc+A_Index,2], 1, 12)  ")|"            
            lang_list.Push([lang_array[lc,1], lang_array[lc+A_Index,1]])
            lc_count++
            
            If FileExist("dict\" lang_array[lc, 5]) && FileExist("dict\" lang_array[lc+A_Index, 5]) && FolderSize("dict\" lang_array[lc, 5]) && FolderSize("dict\" lang_array[lc+A_Index, 5]){                
                lang_set_auto.=lc "/" lc+A_Index " (" SubStr(lang_array[lc,2], 1, 20) "/"lang_array[lc+A_Index,2]  ")|"
                lang_list_auto.Push([lang_array[lc,1], lang_array[lc+A_Index,1]])
            }
                        
            If pause_kl && (lang_array[lc,1]~=pause_langs) && (lang_array[lc+A_Index,1]~=pause_langs)
                pause_kl:=lc_count+1
            If shift_bs_kl && (lang_array[lc,1]~=shift_bs_langs) && (lang_array[lc+A_Index,1]~=shift_bs_langs)
                shift_bs_kl:=lc_count+1            
        }
    }
    lang_set_auto:=RegExReplace(lang_set_auto, "\|$")
    Loop % lang_list_auto.Length()
        If (lang_list_auto[A_Index,1]~=lang_auto) && (lang_list_auto[A_Index,2]~=lang_auto)
            lang_auto_sel:=A_Index
    Loop % lang_menu_s.Length()
        If (lang_menu_s[A_Index]=lang_auto_single)
            lang_auto_single_sel:=A_Index
    If (A_TickCount<120000) && (A_OSVersion~="^10")
        SetInputLang(key_switch, lang_array[1, 1])
    If !(A_ThisMenuItem="Раскладки и флажки")
        Return
    LV_ModifyCol(1, "AutoHdr Center")
    LV_ModifyCol(2, "160")
    LV_ModifyCol(3, "80 Center")
    LV_ModifyCol(4, "120 Center")
    LV_ModifyCol(5, "60 Center")
    LV_ModifyCol(6, "AutoHdr Center")
    Gui 3:Add, GroupBox, x16 w616 h208, Переключение раскладки

    Gui 3:Add, Radio, x60 yp+26 vrb1, Левый Ctrl+N
    Gui 3:Add, Radio, x260 yp vrb2, Левый Alt+N
    Gui 3:Add, Radio, x440 yp vrb3, Выключено

    Gui 3:Add, Text, x40 yp+36, Левый Shift:
    Gui 3:Add, DropDownList, vlshift_ind  x160 yp-4 w150 Choose%lshift_ind% AltSubmit, % lang_menu
    Gui 3:Add, Text, x340 yp+4, Правый Shift:
    Gui 3:Add, DropDownList, vrshift_ind  x460 yp-4 w150 Choose%rshift_ind% AltSubmit, % lang_menu

    Gui 3:Add, Text, x40 yp+42, Левый Ctrl:
    Gui 3:Add, DropDownList, vlctrl_ind  x160 yp-4 w150 Choose%lctrl_ind% AltSubmit, % lang_menu
    Gui 3:Add, Text, x340 yp+4, Правый Ctrl:
    Gui 3:Add, DropDownList, vrctrl_ind  x460 yp-4 w150 Choose%rctrl_ind% AltSubmit, % lang_menu
    Gui 3:Add, CheckBox, x40 yp+40 vdouble_click, Двойное нажатие клавиш для перключения раскладки
    Gui 3:Add, CheckBox, x40 yp+36 vkey_switch, Использовать имитацию клавишного переключения раскладки

    Gui 3:Add, GroupBox, x16 w616 h142, Исправление раскладки
    Gui 3:Add, Text, x40 yp+32, Pause, CapsLock и флажок:
    Gui 3:Add, DropDownList, vpause_kl Choose%pause_kl% AltSubmit x300 yp-4 w310, % lang_set
    Gui 3:Add, Text, x40 yp+42, Сочетание Shift+Backspace:
    Gui 3:Add, DropDownList, vshift_bs_kl Choose%shift_bs_kl% AltSubmit x300 yp-4 w310, % lang_set
    Gui 3:Add, CheckBox, x40 yp+40 vpause_shift_bs, Обменять назначение кнопок Pause и Shift+Backspace

    Gui 3:Add, GroupBox, x16 w616 h72, Работа с множеством раскладок (+ правые Ctrl и Shift)
    Gui 3:Add, Checkbox, x52 yp+34 vdigit_keys, Цифровые клавиши
    Gui 3:Add, Checkbox, x300 yp0 vf_keys, % "Функциональные клавиши (F*)"
    Gui 3:Font, s9, Arial
    Gui 3:Add, Button, x40 y+28 w120 h32 gFlagsFolder, Флажки
    Gui 3:Add, Button, x+6 yp wp hp gControlPanel, Языки (ПУ)
    Gui 3:Add, Button, x+6 yp wp hp gLayoutsAndFlags, Обновить
    Gui 3:Add, Button, x+6 yp w90 hp g3GuiClose, Cancel
    Gui 3:Add, Button, x+6 yp wp hp g3Save, OK
    GuiControl,, rb%lang_select%, 1
    GuiControl,, double_click, % double_click
    GuiControl,, pause_shift_bs, % pause_shift_bs
    GuiControl,, key_switch, % key_switch
    GuiControl,, digit_keys, % digit_keys
    GuiControl,, f_keys, % f_keys
    Gui 3:Show,, Раскладки и флажки
    SetTimer TrayIcon, On
    SetTimer Flag, On
    Return
    
Brightness(color, amt) {
    RegExMatch(color, "^#?(\w\w)(\w\w)(\w\w)$", c)    
    Loop 3 {
        o%A_Index%:=Round(Format("{:d}", "0x" c%A_Index%)+amt*256/100)
        o%A_Index%:=Format("{:.2X}", (o%A_Index% > 255) ? 255 : o%A_Index%)        
    }
    Return o1 . o2 . o3
}
    
FolderSize(folder) {
    SetBatchLines, -1
    fs:=0
    Loop, Files, %folder%\*.*, R
        fs+=A_LoopFileSize
    Return fs
}

3Save:
    Gui 3:Submit, Nohide
    Loop % LV_GetCount()
        lang_array[A_Index, 7]:=(LV_GetNext(A_Index-1, "C")=A_Index) ? 1 : 0
    Gui 3:Destroy
    Loop 4
        If rb%A_Index%
            lang_select:=A_Index

    lshift:=(lshift_ind>3) ? lang_array[lshift_ind-3, 1] : lshift_ind-1
    rshift:=(rshift_ind>3) ? lang_array[rshift_ind-3, 1] : rshift_ind-1
    lctrl:=(lctrl_ind>3) ? lang_array[lctrl_ind-3, 1] : lctrl_ind-1
    rctrl:=(rctrl_ind>3) ? lang_array[rctrl_ind-3, 1] : rctrl_ind-1

    pause_langs:=(pause_kl>1) ? "(" lang_list[pause_kl,1] "|" lang_list[pause_kl, 2] ")" : ""
    shift_bs_langs:=(shift_bs_kl>1) ? "(" lang_list[shift_bs_kl,1] "|" lang_list[shift_bs_kl, 2] ")" : ""
    Goto Apply

3GuiClose:
    Gui 3:Destroy
    Return

#If WinActive("ahk_id" Gui3)
Enter::
NumpadEnter::
    Gui 3:Default
    ControlGetFocus cfocus
    If (cfocus="SysListView321") {
        fr:=LV_GetNext(, "F")
        lang_array[fr, 6]:=ChooseColor("0x" lang_array[fr, 6], default_colors, Gui3)     
        Gosub Settings
    }
    Return

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
    
SetColor:
    If (A_GuiEvent="DoubleClick") && A_EventInfo && (A_EventInfo=LV_GetNext(A_EventInfo-1)) {
        lang_array[A_EventInfo, 6]:=ChooseColor("0x" lang_array[A_EventInfo, 6], default_colors, Gui3)
        Gosub Settings        
    }
    Return

FlagSettings:
    Gui 2:Destroy
    Gui 2:-DPIScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui2
    Gui 2:Font, s12, Arial
    Gui 2:Color, 6DA0B8
    Gui 2:Add, Edit, w372 r3 -VScroll, % comment
    Gui 2:Font, s9
    Gui 2:Add, Button,y+6 w120 h32 section g+WheelDown, Размер -
    Gui 2:Add, Button, wp hp x+6 yp g_Up, Вверх
    Gui 2:Add, Button, wp hp x+6 yp g+WheelUp, Размер +

    Gui 2:Add, Button, wp hp xs y+6 g_Left, Влево
    Gui 2:Add, Button, wp hp x+6 yp g+Mbutton, Сброс
    Gui 2:Add, Button, wp hp x+6 yp g_Right, Вправо

    Gui 2:Add, Button, wp hp xs y+6 g!WheelDown, Прозр-ть -
    Gui 2:Add, Button, wp hp x+6 yp g_Down, Вниз
    Gui 2:Add, Button, wp hp x+6 yp g!WheelUp, Прозр-ть +

    Gui 2:Show,, Настройка флажка
    SendInput % "^{Home}{Enter}{Raw}                     Текст"
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
    Gui 5:Font, s9, Arial
    Gui 5:Add, Button, w120 h32 section g^Left, Размер -
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
    SB_SetParts(140, 128)
    SB_SetText("`tX " dx_in "%  Y " dy_in "%`t", 1, 2)
    SB_SetText("`tШирина " width_in "%`t", 2, 2)
    SB_SetText("`tПрозр-ть " 100-transp_in "%`t", 3, 2)
    Return

5GuiClose:
    Gui 5:Destroy
    If (dx_in>0) && (dx_in<A_ScreenWidth) && (dy_in>0) && (dy_in<A_ScreenHeight)
        dx_in_1:=dx_in, dy_in_1:=dy_in
    Else
        dx_in_2:=dx_in, dy_in_2:=dy_in
    Gosub Settings
    Return

#If WinActive("ahk_id" Gui5)
Esc::Goto 5GuiClose

~LButton::
    MouseGetPos,,, win, ctrl
    If (win=Gui5) && (ctrl~="Button") {
        If (ctrl="Button1")
            Goto ^Left
        If (ctrl="Button2")
            Goto Up
        If (ctrl="Button3")
            Goto ^Right
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
        dx_in:=((dx_in<100) || (monitors>1)) ? dx_in+((A_Index>3) ? 0.2 : 0.1) : dx_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 200
    }
Return

Left::
    While GetKeyState("LButton", "P") || GetKeyState("Left", "P") {
        dx_in:=((dx_in>0) || (monitors>1)) ? dx_in-((A_Index>3) ? 0.2 : 0.1): dx_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 200
    }
    Return

Up::
    While GetKeyState("LButton", "P") || GetKeyState("Up", "P") {
        dy_in:=((dy_in>0)  || (monitors>1)) ? dy_in-((A_Index>3) ? 0.2 : 0.1) : dy_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 200
    }
    Return

Down::
    While GetKeyState("LButton", "P") || GetKeyState("Down", "P") {
        dy_in:=((dy_in<100) || (monitors>1)) ? dy_in+((A_Index>3) ? 0.2 : 0.1) : dy_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 200
    }
    Return

^Right::
    While GetKeyState("LButton", "P") || GetKeyState("Right", "P") {
        If (width_in<10)
            width_in+=0.1, upd:=1
        Gosub StatusBar
        Sleep 200
    }
    Return

^Left::
    While GetKeyState("LButton", "P") || GetKeyState("Left", "P") {
        If (width_in>1)
            width_in-=0.1, upd:=1
        Gosub StatusBar
        Sleep 200
    }
    Return

^Up::
    If (transp_in>54)
        transp_in-=5, upd:=1
    Goto StatusBar

^Down::
    If (transp_in<96)
        transp_in+=5, upd:=1
    Goto StatusBar

Space::
    width_in:=2, dx_in:=50, dy_in:=60, transp_in:=85, upd:=1
    Goto StatusBar

; Правила приложений
Rules:
    Gui 6:Destroy
    Gui 6:-DpiScale +AlwaysOnTop +ToolWindow +LastFound +HwndGui6
    Gui 6:Default
    Gui 6:Margin, 8, 6
    Gui 6:Font, s9, Microsoft Sans Serif
    If A_IsCompiled
        Gui 6:Add, Picture, w32 x20 h-1 Icon7 gDetect, LangBarXX.exe
    Else
        Gui 6:Add, Picture, w32 x20 h-1 gDetect, % pict
    Gui 6:Add, Text, x+20 yp+6, Для создания правила перетащите кнопку на окно приложения!
    Gui 6:Add, ListView, x8 w720 r16 -Multi NoSortHdr Checked +Grid -LV0x10  vapp gProperties, % " №|+/-|Имя файла|Класс окна|Описание/комментарий"
    Loop % apps.Length()
        LV_Add(apps[A_Index,1] ? "Check" : "", A_Index, apps[A_Index, 2] ? "+" : "-", apps[A_Index, 3], apps[A_Index, 4], apps[A_Index, 5])
    LV_ModifyCol(1,"60 Center")
    LV_ModifyCol(2,"40 Center")
    LV_ModifyCol(3, "200")
    LV_ModifyCol(4, "190")
    Loop % LV_GetCount()
        LV_Modify(A_Index, "-Select")
    LV_ModifyCol(5, (LV_GetCount()>16) ? 200:220)
    If (A_ThisHotkey~="\+(L|R)Shift$") && last_rule
        LV_Modify(last_rule, "Select Vis Focus")
    ;Gui 6:Font, s9, Arial
    Gui 6:Add, Button, x20 w160 gProperties, Редактировать
    Gui 6:Add, Button, x+6 yp w70 gRuleUp, Вверх
    Gui 6:Add, Button, x+6 yp wp gRuleDown, Вниз
    Gui 6:Add, Button, x+6 yp w100 gRuleDelete, Удалить
    Gui 6:Add, Button, x+110 yp w80 g6GuiClose, Cancel
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
    FileEncoding UTF-16
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
    FileEncoding UTF-8
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
        row:=(A_GuiEvent="DoubleClick") ? A_EventInfo : LV_GetNext(, "F")
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
    Gui 7:+Owner6 +AlwaysOnTop +LastFound +ToolWindow +HwndGui7
    Gui 7:Font, s9, Segoe UI
    Gui 7:Add, Edit, x10 w160 vpr_name, % pr_name
    Gui 7:Add, Text, x+5 yp+2, - имя файла
    Gui 7:Add, Button, x+10 yp-2 w60 gAll, Все!
    Gui 7:Add, Edit, x10 w160 vclass ReadOnly, % class
    Gui 7:Add, Text, x+5 yp+2, - класс окна
    ;Gui 7:Add, Button, x260 yp-2 w60 gClassAll, Все!
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
    If (pr_name=="*.*") && ((class=="*") || !class) {
        MsgBox, 4129, , Недопустимо создание такого универсального правила!, 22
        Return
    }
    Gui 6:Default
    If row
        LV_Modify(row,,, always_on ? "+" : "-", pr_name, class, description)
    Else {
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
    
ClassAll:
    GuiControl,, class, *
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
    Gui 9:Font, s9, Arial
    Gui 9:Add, Button, x50 yp+66 w100 h32 section g9GuiClose, Cancel
    Gui 9:Add, Button, x+6 ys w200 hp gDefaults, По умолчанию
    Gui 9:Add, Button, x+6 ys w100 hp g9OK, OK
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

9OK:
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

USB-Version:
    If !FileExist(cfg_folder "\temp.txt") {
        FileAppend,, % cfg_folder "\temp.txt"
        Sleep 200
        Reload
    }
    Else {
        FileDelete % cfg_folder "\temp.txt"
        FileSelectFolder usb_folder, ::{20d04fe0-3aea-1069-a2d8-08002b30309d},, Выберите папку, в которую будет скопирована USB-версия программы
        If !(usb_folder:=RegExReplace(usb_folder, "\\$"))
            Return
        FileCopyDir % A_ScriptDir, %usb_folder%\LangBarXX, 1
        FileCreateDir %usb_folder%\LangBarXX\config
        FileCopy % A_AppData "\LangBarXX\*.*", %usb_folder%\LangBarXX\config
        FileRemoveDir %usb_folder%\LangBarXX\flags_old, 1
        FileRemoveDir %usb_folder%\LangBarXX\masks_old, 1
        FileDelete %usb_folder%\LangBarXX\unins000.*
        MsgBox, 64, , Портативная версия программы со всеми настройками создана в %usb_folder%\LangBarXX, 2.5
    }
    Return 

;========= Загрузка словарей =========
LoadDict:
    ld_start:=A_TickCount, dict_string:=""
    StringCaseSense Locale
    Loop % lang_count {
        lac:=lang_array[A_Index, 1]
        If !((lac~=lang_auto) || (lac=lang_auto_single) || ((lac~=lang_auto_others) && lang_auto_others))
            Continue
        df:=lang_array[A_Index, 5], dic_out:="" 
        Loop Files, % "dict\" df "\*.dic"
        {
            If only_main_dict && (A_LoopFileName!=df ".dic$")
                Continue
            dict_string.="""" A_ScriptDir "\" A_LoopFilePath ""","
            FileRead dic, % A_LoopFilePath
            words:=StrSplit(dic, "`n", "`r")
            For each, ds in words
            {
                ds:=Trim(RegExReplace(ds, "/.+$"))
                If (ds~="^\d+$") || (ds~="^\s*;")
                    Continue
                If (StrLen(ds)=1) || !(ds==Format("{:U}", ds)) ;;;;;;
                    ds:=Format("{:L}", ds)
                If (StrLen(ds)=2) && (ds==Format("{:U}", ds)) && short_abbr_ignore
                    Continue
                If (abbr_ignore=3) && (ds==Format("{:U}", ds))
                    Continue
                dic_out.=ds ? ds "`r`n" : ""
                n%fn%++
            }
            If accent_ignore
                dic_out:=DelAccent(dic_out)
            Sort dic_out, U
        }
        dv:=lang_array[A_Index, 1], dic_%dv%:=dic_out
        ;FileDelete dict\dic_%dv%
        ;FileAppend % dic_out, dict\dic_%dv%.dic
    }
    FileAppend % "`r`n;" A_TickCount-start "/" A_TickCount-ld_start, logs\transform.log
    start:=ld_start:=0
    Return
    
UpdateUserDict:
    FileGetTime dict_time, % cfg_folder "\user_dict.dic", M
    If (dict_time!=dict_time_old) {
        user_dic:=""
        FileRead udic, % cfg_folder "\user_dict.dic"
        udic:=StrSplit(udic, "`n", "`r")
        For each, us in udic
        {
            If (us~="^\s*$") || (us~="^\s*;")
                Continue
            user_dic.=us "`r`n"
        }        
        dict_time_old:=dict_time
    }
    Return 

;=========== Автопереключение ============
Autocorrect:
    Gui 8:Destroy
    Gui 8:+LastFound +AlwaysOnTop -DPIScale -MinimizeBox +ToolWindow +hWndGui8
    Gui 8:Default
    Gui 8:Color, 6DA0B8
    Gui 8:Margin, 12, 8
    Gui 8:Font, s9
    Gui 8:Add, CheckBox, x28 section vsound, Звук при автопереключении и отмене
    Gui 8:Add, CheckBox, xs vtray_tip, Уведомление при автопереключении
    Gui 8:Add, CheckBox, xs vctrlz_undo, Отмена преобразования по Ctrl+Z
    Gui 8:Add, CheckBox, xs vno_indicate, Выключение индикации на флажке
    Gui 8:Add, GroupBox, x12 w380 h98, Языки автопереключения
    Gui 8:Add, DropDownList, vlang_auto_i x60 yp+28 w288 Choose%lang_auto_sel% AltSubmit, % lang_set_auto
    Gui 8:Add, CheckBox, x28 y+8 section vonly_main_dict, Только основной словарь
    Gui 8:Add, GroupBox, x12 w380 h186, Режим одного языка
    Gui 8:Add, DropDownList, vlang_auto_i2 gAcupdate x60 yp+28 w288 Choose%lang_auto_single_sel% AltSubmit, % lang_menu_single
    Gui 8:Add, Text, xp y+8, Языки автопереключения:
    Gui 8:Add, ListView, -Hdr Grid r3 Checked w288 x60 yp+28, #|Layout
    row_numb:=0
    Loop % lang_array.Length() {
        row_numb++
        If (lang_auto_single=lang_array[A_Index,1])
            Continue
        If FileExist("dict\" lang_array[A_Index, 5]) && FolderSize("dict\" lang_array[A_Index, 5])
            LV_Add(((lang_array[A_Index, 1]~=lang_auto_others) && lang_auto_others) ? "Check" : "", A_Index, lang_array[A_Index, 2])
    }
    LV_ModifyCol(1, "60 AutoHdr Center")
    LV_ModifyCol(2, "208")
    
    Gui 8:Add, CheckBox, x420 y12 section vmin_length, Обработка текста с 3-х символов
    Gui 8:Add, CheckBox, xs vaccent_ignore, Игнорировать акценты (ё=е, á=a и пр.)
    
    Gui 8:Add, GroupBox, xp-16 y+6 w380 h152, Обработка аббревиатур
    Gui 8:Add, Radio, xs yp+28 vabbr_ignore, Сравнение с учетом регистра 
    Gui 8:Add, Radio, xs yp+32 +hwndr2, Сравнение без учета регистра 
    Gui 8:Add, Radio, xs yp+32 +hwndr3, Игнорировать полностью
    Gui 8:Add, CheckBox, xs yp+28 vshort_abbr_ignore, Игнорировать короткие аббревиатуры
    
    Gui 8:Add, GroupBox, xp-16 y+16 w380 h94, Начальные границы слов
    Gui 8:Add, CheckBox, xs yp+28 vword_margins_enabled, Символы:
    w_margins:=""
    Loop Parse, word_margins, CSV
        w_margins.=A_LoopField        
    Gui 8:Add, Edit, x+20 yp-4 w160 h32 vw_margins, % w_margins
    Gui 8:Add, CheckBox, xs yp+36 vdigit_borders, Клавиши цифрового ряда
    Gui 8:Add, GroupBox, xp-16 y+16 w380 h94, Не исправлять раскладку
    Gui 8:Add, CheckBox, xs yp+28 vnew_lang_ignore, После ручного переключения
    Gui 8:Add, CheckBox, xs yp+32 vmouse_click_ignore, После клика мышью (вставка)
    
    Gui 8:Add, Button, x168 w120 h28 section g8GuiClose, Cancel
    Gui 8:Add, Button, x+6 ys w200 hp g8Defaults, По умолчанию
    Gui 8:Add, Button, x+6 ys w120 hp g8OK, OK
    
    GuiControl,, only_main_dict, % only_main_dict
    GuiControl,, single_lang_only, % single_lang_only
    GuiControl,, min_length, % min_length
    GuiControl,, sound, % sound
    GuiControl,, tray_tip, % tray_tip
    GuiControl,, accent_ignore, % accent_ignore
    GuiControl,, ctrlz_undo, % ctrlz_undo
    GuiControl,, no_indicate, % no_indicate
    GuiControl,, abbr_ignore, % (abbr_ignore=1) ? 1 : 0 
    GuiControl,, % r2, % (abbr_ignore=2) ? 1 : 0 
    GuiControl,, % r3, % (abbr_ignore=3) ? 1 : 0
    GuiControl,, short_abbr_ignore, % short_abbr_ignore
    GuiControl,, word_margins_enabled, % word_margins_enabled
    GuiControl,, digit_borders, % digit_borders
    GuiControl,, new_lang_ignore, % new_lang_ignore
    GuiControl,, mouse_click_ignore, % mouse_click_ignore
    Gui 8:Show,, Настройки автопереключения
    Return
    
Acupdate:
    Gui 8:Submit
    Sleep 100
    lang_auto_single:=lang_menu_s[lang_auto_i2], lang_auto_single_sel:=lang_auto_i2
    Goto Autocorrect
       
8Defaults:
    subfolders:=sound:=abbr_ignore:=word_margins_enabled:=digit_borders:=new_lang_ignore:=mouse_click_ignore:=tray_tip:=0, sound:=accent_ignore:=abbr_ignore:=short_abbr_ignore:=1, single_lang:=0x0409, word_margins:="(,|,\,/,_,=,+"    
    Gosub Autocorrect
    Goto Settings
    
8GuiClose:
    Gui 8:Destroy
    Return
       
8OK:
    Gui 8:Submit, NoHide
    Sleep 100
    lang_auto:="(" lang_list_auto[lang_auto_i,1] "|" lang_list_auto[lang_auto_i, 2] ")"
    lang_auto_single:=lang_menu_s[lang_auto_i2]
    lang_auto_o:="", rn:=mouse_click:=""
    
    Loop % row_numb {
        rn:=LV_GetNext(rn, "C")
        If !rn
            Break
        LV_GetText(ch, rn, 1)
        ;If ch
            lang_auto_o.=lang_array[ch,1] "|"
    }
    lang_auto_others:="(" RegExReplace(lang_auto_o, "\|$") ")"
        
    word_margins:=""
    Loop Parse, w_margins
        word_margins.=((A_LoopField=",") ? "`" A_LoopField : A_LoopField) ","    
    Gosub Settings
    Sleep 200
    Reload
    
    
#If WinActive("ahk_id" Gui8 )
Esc::Goto 8GuiClose
#If

<^RCtrl::
>^LCtrl::
AutocorrectToggle:
    autocorrect:=!autocorrect, ih.Stop()
    Menu Autocorrect, % autocorrect ? "Check" : "Uncheck", 1&
    If !autocorrect {
        ttip:=0
        ToolTip,,,, 10    
    }  
    Return
    
<^<!RCtrl::
SingleLangToggle:
    single_lang:=!single_lang, ih.Stop()
    Menu Autocorrect, % single_lang ? "Check" : "Uncheck", 2&
    If !autocorrect && single_lang
        Goto AutocorrectToggle
    Return

DictFolder:
    Run explore dict
    Return
    
OpenDict:
    Loop Parse, dict_string, CSV
    {
        Run % """" editor """ """ A_LoopField """"
        Sleep 200
    }
    Return

UserDict:
    Run % """" editor """ " cfg_folder "\user_dict.dic"
    Return
    
UndoLog:
    Run % """" editor """ logs\undo.log"
    Return    
    
;======== Конвертер словарей =========
DictConverter:
    clip_load:=file_dir:=text:=""
    VarSetCapacity(text, 102400000), VarSetCapacity(dic0, 102400000)
    Gui 10:Destroy
    Gui 10:Default
    Gui 10:+LastFound +AlwaysOnTop +ToolWindow -DPIScale +HwndGui10
    Gui 10:Font, s9, Segoe UI
    Gui 10:Add, CheckBox, vconv_as_text section x24 y8, Открыть как простой текст
    Gui 10:Add, CheckBox, vconv_min x46 +Checked, Выбирать слова длиннее
    Gui 10:Add, DropDownList, vconv_min_size x+0 yp-4 w48, 1|2||3|4|5|6
    Gui 10:Add, Text, x+8 yp+4, знаков
    Gui 10:Add, CheckBox, vconv_merge xs +Checked, Слияние и удаление дубликатов`nслов с учетом регистра
    Gui 10:Add, CheckBox, vconv_sort xs, Сортировка слов с учетом регистра
    
    Gui 10:Add, Radio, vfile_out xs +Checked, Добавить в словарь программы
    Gui 10:Add, Radio,  xs, Сохранить в отдельный dic-файл
    Gui 10:Add, CheckBox, vopen_dict xs +Checked, Открыть в редакторе по завершении

    Gui 10:Add, Button, gOpenClipboard xs w376, Вставить текст из буфера обмена
    Gui 10:Add, Button, gOpenFile vopen_file xs wp h72, Открыть или перетащить на кнопку текстовый файл(ы) в кодировке utf-8
    
    Gui 10:Add, GroupBox, x+20 y8 w420 h382, Опции
    Gui 10:Add, CheckBox, vconv_accent_ignore section xp+12 yp+32, Удалять акценты (ё=е, á=a и т.д.)
    Gui 10:Add, CheckBox, vconv_en xs, Только слова с английскими буквами
    Gui 10:Add, CheckBox, vconv_ru xs, Только слова с русскими буквами
    Gui 10:Add, CheckBox, vconv_regexp xs, Регэксп слов:
    Gui 10:Add, ComboBox, x+4 yp-4 w220 vregexp, % regexp_list
    Gui 10:Add, CheckBox, vconv_abbr xs, Обработка аббревиатур
    Gui 10:Add, Text, xs y+12
    Gui 10:Add, Radio, vconv_abbr_del x+12 yp +Checked, Удалять все
    Gui 10:Add, Radio, x+6, Только аббревиатуры
    Gui 10:Add, CheckBox, vconv_lowercase xs , Все слова в нижний регистр
    Gui 10:Add, CheckBox, vconv_del_digits xs +Checked, Удалять слова с цифрами
    Gui 10:Add, CheckBox, vconv_del_quot xs, Удалять слова с апострофами
    Gui 10:Add, CheckBox, vconv_crop xs +Checked, Обрезать слова до
    Gui 10:Add, DropDownList, vconv_crop_size x+8 yp-4 w48, 3|4|5|6||7|8|9|10|11|12
    Gui 10:Add, Text, x+8 yp+4, знаков
    
    If (A_OSVersion="WIN_XP")
        GuiControl Disable, conv_accent_ignore    
    Gui 10:Show,, Конвертер словарей
    Return
    
#If WinActive("ahk_id" Gui10)
Esc::
#If

10GuiEscape:
10GuiClose:
    Gui 10:Destroy
    Return

OpenClipboard:
    Gui 10:Submit
    text:=Clipboard
    ClipWait 1
    If ErrorLevel {
        MsgBox, 16, , Буфер обмена пуст!, 1.5
        Return
    }
    clip_load:=1
    Sleep 50
    Goto SaveText
    
10GuiDropFiles:
    If !(A_GuiControl="open_file")
        Return
    Gui 10:Submit
    file_path:=A_GuiEvent
    Goto ReadFiles

OpenFile:
    Gui 10:Submit
    Sleep 100
    FileSelectFile file_path, M
    If ErrorLevel
        Return
ReadFiles:
    text:="", f_path:=file_path
    Loop Parse, f_path, `n
    {
        FileRead t_in, % A_LoopField
        text.="`r`n" t_in 
        If (A_Index=1)
            file_path:=A_LoopField
    }
SaveText:
    CoordMode ToolTip
    ToolTip % "`n   Работаем...   `n  ", % A_ScreenWidth//2-50, % A_ScreenHeight//2-25, 11    If conv_regexp && regexp {
        regexp_list:=regexp "|" regexp_list
        IniWrite % regexp_list, % cfg, Converter, Regexp_List    
    }
    Gosub TextConvert
    ToolTip,,,, 11
    If (file_out=2) {
        file_name:=A_YYYY "." A_MM "." A_DD "_" A_Hour "." A_Min "." A_Sec ".dic"
        If !clip_load {
            SplitPath file_path,, file_dir,, f_name
            file_name:=RegExReplace(file_dir, "\\$") "\" f_name "_" file_name
        }
        FileSelectFile save_path, 16, % file_name,, *.dic
        If ErrorLevel
            Return
        save_path:=RegExReplace(save_path, "\.dic$") ".dic"
    } 
    Else {
        FileSelectFolder dict_name, % A_ScriptDir "\dict", 3
        If ErrorLevel
            Return
        Loop {
            SplitPath dict_name,,,, dir_name 
            save_path:=dict_name "\" dir_name ((A_Index>1) ? "_" A_Index-1 : "") ".dic"
            If !FileExist(save_path)
                Break
        }
    }
    SplitPath save_path,, save_dir    
    If FileExist(save_path)
        FileDelete % save_path
    FileAppend % dic0, % save_path
    Sleep 50
    FileGetSize file_size, % save_path, K
    file_size:=(file_size>1000) ? file_size/1000 " KB" : file_size " B"
    MsgBox, 65, , % "Файл: " save_path "`nРазмер: " file_size " KB`nОбщее число слов: " word_count "`nОбработка завершена за " ctime " с", 3
    Sleep 100
    If open_dict
        Run % """" editor """ """ save_path """"  
    Return

TextConvert:
    start:=A_TickCount, dic0:=word_count:=hhk:=""
    StringCaseSense Locale  
    If conv_as_text {
        del:=[A_Tab, A_Space, "``", "!", "?", "@", "#", "№", "$", "%", "^", "&", "*", "(", ")", "[", "]", "{", "}", "+", "=", "_", "\" ,"|" , "/", "<", ">", ".", """", ":", ";", ",", "~", "©", "«", "»", "”", "“", "—", "~"]
        words:=StrSplit(text, del, "'")
    }
    Else
        words:=StrSplit(text, "`n", "`r")
    For each, ds in words
    {
        RegExMatch(ds, "^\s*\K\S+?(?=(/|\s|$))", ds)
        If !(ds:=Trim(ds)) || (ds~="\s*^-+")
            Continue
        If conv_as_text
            RegExMatch(ds, "(^|')\K\S+?(?=(`|$)", ds)
        If conv_del_quot && (ds~="'")
            Continue
        If conv_crop
            ds:=SubStr(ds, 1, conv_crop_size)
        If (StrLen(ds)=1)
            ds:=Format("{:L}", ds)
        If conv_abbr && (conv_abbr_del=1) && (StrLen(ds)>1) && (ds==Format("{:U}", ds))
            Continue     
        If conv_abbr && (conv_abbr_del=2) && (StrLen(ds)>1) && !(ds==Format("{:U}", ds))
            Continue            
        If conv_del_digits && (ds~="\d")
            Continue
        If conv_en && !(ds~="^[a-zA-Z-]+$")
            Continue
        If conv_ru && !(ds~="^[а-яА-ЯёЁ-]+$")
            Continue
        If conv_regexp && !(ds~=regexp)
            Continue
        If conv_as_text && conv_min && !(StrLen(ds)>conv_min_size)
            Continue
        dic0.=ds ? ds "`r`n" : ""
    }
    If conv_accent_ignore
        dic0:=DelAccent(dic0)    
    If conv_lowercase
        dic0:=Format("{:L}", dic0)
    Sort dic0, % conv_merge ? "C U" : "U"
    Sort dic0, % conv_sort ? "C" : "CL"
    StringCaseSense  Off
    Loop Parse, dic0, `n, `r
        word_count++
    ctime:=(A_TickCount-start)/1000, word_count-=1
    Return
    
Statistics:
    res1_all:=res2_all:=res3_all:=res4_all:=max:=0
    If FileExist("logs\transform.log") {
        FileRead transform, logs\transform.log
        trans:=StrSplit(transform, "`n", "`r"), nl:=tr:=lpr:=ldt:=0
        For each, str in trans
        {
            If RegExMatch(str, "^;(\d+)/(\d+)", tl)
                nl+=1, lpr+=Format("{:d}", tl1), ldt+=Format("{:d}", tl2)
            
            If RegExMatch(str, "(?<!;)(\S+)/.+ (\d+)/(\d+)\s*(\S+)?", res)
                tr+=1, rl:=StrLen(res1), res1_all+=rl, max:=Max(rl, max), res2_all+=Format("{:d}", res2), res3_all+=Format("{:d}", res3), res4_all+=(res4 ? 1 : 0)          
            
        }
        MsgBox,, Статистика, % "Среднее время загрузки программы: " lpr/nl " mc`nИз них загрузки словарей: " ldt/nl " mc`n`nСреднее время обработки нажатий клавиш: " res2_all/tr " mc`nСреднее время преобразования текста: " res3_all/tr " mc`n`nСредняя длина преобразованного текста: " Format("{:.3}", res1_all/tr) "`nМаксимальная длина преобразованного текста: " max "`nЧисло преобразований: " tr "`nЧисло отмен преобразований: " res4_all " (" Format("{:.2}", res4_all/tr*100) " %)"
    }
    Return

