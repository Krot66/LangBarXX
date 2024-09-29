#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 99999999
#MaxMem 150
#InstallMouseHook
#KeyHistory 0
SetBatchLines -1
If A_IsCompiled
    ListLines Off
SetKeyDelay -1, -1
SetWinDelay 20
CoordMode Caret
CoordMode Tooltip
CoordMode Mouse
CoordMode Pixel
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
SetTitleMatchMode Slow
Process Priority,, A
#Include <ZipFile>
#Include <Gdip_All>
#Include %A_ScriptDir%\Lib\_icons.ahk

version:="1.8.2"

/*
Использованы:
Начальный код отображения флажка Irbis http://forum.script-coding.com/viewtopic.php?id=10392&p=3
Gdip library by Tic
Acc Standard Library by Sean
Hunspell Spell library - majkinetor, jballi
FileGetInfo and StrUnmark by Lexicos
ChooseColor - iPhilip
GetCaret - plankoe
*/


;@Ahk2Exe-SetProductName LangBar++
;@Ahk2Exe-SetProductVersion 1.8.2
;@Ahk2Exe-SetFileVersion 1.8.2
;@Ahk2Exe-SetDescription https://github.com/Krot66/LangBarXX

;@Ahk2Exe-SetMainIcon LangBarXX.ico
;@Ahk2Exe-AddResource drag.ico, 160

start:=A_TickCount
OnExit Exit
pid:=DllCall("GetCurrentProcessId")
Process Exist, LangBarXX.exe
lb:=ErrorLevel
Process Exist, LangBarXX64.exe
lb64:=ErrorLevel
If ((lb && lb!=PID) || (lb64 && lb64!=PID)) && FileExist("portable.dat") {
    MsgBox, 16, , Запущена другая копия программы!, 1.5
    ExitApp
}
EnvSet __COMPAT_LAYER, RUNASINVOKER HIGHDPIAWARE
SetFormat, float, 0.2

If reset
    Return

FileCreateDir backup
FileCreateDir dict
If FileExist("hunspell") {
    FileCreateDir editor
    FileCreateDir logs
}
Loop Files, editor\*.*
    If (A_LoopFilePath~="\.(exe|lnk)$")
        editor:=A_LoopFilePath
If !editor
    editor:="notepad.exe"
If !A_IsCompiled
    FileCreateDir config
If FileExist("config") ; конфигурация портативная или установленная
    cfg_folder:=A_ScriptDir "\config"
Else {
    cfg_folder:=A_AppData "\LangBarXX"
    FileCreateDir % cfg_folder
    If FileExist(cfg_folder "\temp.txt")
        Gosub USB-Version
}
cfg:=cfg_folder "\langbarxx.ini",
apps_cfg:=cfg_folder "\apps_rules.ini",
hs_cfg:=cfg_folder "\hotstrings.ini"
If !FileExist(cfg_folder "\user_dict.dic")
    FileAppend,, % cfg_folder "\user_dict.dic", UTF-8

; ====== Обработка старых версий ======
If FileExist("langbarxx.ini") && FileExist("config") && !FileExist("config\langbarxx.ini")
    FileMove langbarxx.ini, config
If FileExist(cfg_folder "\Clips")
    FileMoveDir % cfg_folder "\Clips", Clips
If FileExist("doc\Changelog.txt")
    FileDelete doc\Changelog.txt
FileDelete LB_WatchDog.exe
FileDelete langbarxx.ini
FileDelete ReadMe.html
FileDelete ReadMe.md
FileRemoveDir ReadMe.assets, 1
FileRemoveDir bin, 1
FileDelete Changelog.txt
FileDelete portable.dat
If FileExist(cfg) {
    IniDelete % cfg, Apps
    IniDelete % cfg, Tray, key_switch
    IniDelete % cfg, Indicator, DX_In_1
    IniDelete % cfg, Indicator, DY_In_1
    IniDelete % cfg, Indicator, DX_In_2
    IniDelete % cfg, Indicator, DY_In_2
    IniDelete % cfg, Indicator, DY_In_2
    IniDelete % cfg, Layouts, pause
    IniDelete % cfg, Layouts, shift_bs
    IniDelete % cfg, Layouts, pause_shift_bs
    IniDelete % cfg, Autocorrect, accent_ignore
    IniDelete % cfg, Autocorrect, short_abbr_ignore
    IniDelete % cfg, Autocorrect, word_margins_enabled
    IniDelete % cfg, Autocorrect, word_margins
    IniDelete % cfg, Autocorrect, tray_tip
    IniDelete % cfg, Cursor, text_cursor_size
    IniRead old_version, % cfg, Main, Version, 0
}

;================================
If FileExist("reset") {
    FileDelete reset
    FileDelete % cfg_folder "\*.*"    
}

IniRead aspect, % cfg, Tray, Aspect, 1
IniRead icon_shift, % cfg, Tray, Icon_Shift, 1
IniRead numlock_icon, % cfg, Tray, NumLock_Icon, 1
IniRead scrolllock_icon, % cfg, Tray, ScrollLock_Icon, 1
IniRead flag_sett, % cfg, Tray, Flag_Sett, 0

IniRead capslock, % cfg, Keys, CapsLock, 1
IniRead scrolllock, % cfg, Keys, ScrollLock, 1
IniRead numlock_on, % cfg, Keys, NumLock_On, 0
IniRead shift_capslock, % cfg, Keys, Shift_CapsLock, 0

IniRead flag, % cfg, Flag, Flag, 1
IniRead dx, % cfg, Flag, DX, 16
IniRead dy, % cfg, Flag, DY, -12
IniRead width, % cfg, Flag, Width, 22
IniRead transp, % cfg, Flag, Transp, 100
IniRead scaling, % cfg, Flag, Scaling, 5
IniRead smoothing, % cfg, Flag, Smoothing, 3
IniRead no_border, % cfg, Flag, No_Border, 0
IniRead file_aspect, % cfg, Flag, File_Aspect, 0
IniRead text_flags, % cfg, Flag, Text_Flags, 0

IniRead indicator, % cfg, Indicator, Indicator, 0
IniRead lang_switcher, % cfg, Indicator, Lang_Switcher, 0
IniRead on_full_screen, % cfg, Indicator, On_Full_Screen, 0
IniRead dx_in, % cfg, Indicator, DX_In, 50
IniRead dy_in, % cfg, Indicator, DY_In, 1.0
IniRead window_snap, % cfg, Indicator, Window_Snap, 1
IniRead width_in, % cfg, Indicator, Width_In, 2
IniRead transp_in, % cfg, Indicator, Transp_in, 90
IniRead numlock_icon_in, % cfg, Indicator, NumLock_Icon_In, 1
IniRead scrolllock_icon_in, % cfg, Indicator, ScrollLock_Icon_In, 1

IniRead text_cursor, % cfg, Cursor, Text_Cursor, 1
IniRead arrow_cursor, % cfg, Cursor, Arrow_Cursor, 1
IniRead large_flag, % cfg, Cursor, Large_Flag, 0
IniRead invert_arrow, % cfg, Cursor, Invert_Arrow, 0
IniRead invert_threshold, % cfg, Cursor, Invert_Threshold, 100
IniRead color_arrow, % cfg, Cursor, color_arrow, 0
IniRead arrow_color, % cfg, Cursor, Arrow_Color, % "FF80FF"
IniRead cursor_size, % cfg, Cursor, Cursor_Size, 32
IniRead on_new_window, % cfg, Cursor, On_New_Window, 0
IniRead on_mouse_click, % cfg, Cursor, On_Mouse_Click, 0
IniRead cursor_show, % cfg, Cursor, Cursor_Show, 3
IniRead flag_width, % cfg, Cursor, Flag_Width, 18
IniRead flag_height, % cfg, Cursor, Flag_Height, 12
IniRead flag_x, % cfg, Cursor, Flag_X, 4
IniRead flag_y, % cfg, Cursor, Flag_Y, 22

IniRead cycl_langs, % cfg, Layouts, Cycl_Langs, % " "
IniRead pause_langs, % cfg, Layouts, Pause_Langs, 1
IniRead shift_bs_langs, % cfg, Layouts, Shift_BS_Langs, 1
IniRead ctrl_capslock_langs, % cfg, Layouts, Ctrl_CapsLock_Langs, % " "
IniRead key_switch, % cfg, Layouts, Key_Switch, 0
IniRead lang_select, % cfg, Layouts, Lang_Select, 4
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
IniRead reverseint, % cfg, Select, ReverseInt, 700
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
IniRead sound, % cfg, Autocorrect, Sound, 1
IniRead lang_note, % cfg, Autocorrect, lang_note, 0
IniRead min_length, % cfg, Autocorrect, Min_Length, 1
IniRead no_indicate, % cfg, Autocorrect, No_Indicate, 0
IniRead letter_ignore, % cfg, Autocorrect, Letter_Ignore, 0
IniRead abbr_ignore, % cfg, Autocorrect, Abbr_Ignore, 0
IniRead digit_ignore, % cfg, Autocorrect, Digit_Ignore, 1
IniRead ctrlz_undo, % cfg, Autocorrect, Ctrlz_Undo, 1
IniRead start_symbols_enabled, % cfg, Autocorrect, Start_Symbols_Enabled, 0
IniRead start_symbols, % cfg, Autocorrect, Start_Symbols, % "(_=+"""
IniRead end_symbols_enabled, % cfg, Autocorrect, End_Symbols_Enabled, 0
IniRead end_symbols, % cfg, Autocorrect, End_Symbols, % ").,!?"""
IniRead digit_borders, % cfg, Autocorrect, Digit_Borders, 0
IniRead new_lang_ignore, % cfg, Autocorrect, New_Lang_Ignore, 0
IniRead mouse_click_ignore, % cfg, Autocorrect, Mouse_Click_Ignore, 0
IniRead backspace_ignore, % cfg, Autocorrect, Backspace_Ignore, 0

IniRead regexp_list, % cfg, Converter, Regexp_List, % " "

IniRead bold, % cfg, TextFlags, Bold, 1
IniRead font_size, % cfg, TextFlags, Font_Size, 40
IniRead font_color, % cfg, TextFlags, Font_Color, EEEEEE
IniRead radius, % cfg, TextFlags, Radius, 4
IniRead gradient, % cfg, TextFlags, Gradient, 20

IniRead note, % cfg, LangNote, Note, 1
IniRead note_size, % cfg, LangNote, Note_Size, 8
IniRead note_transp, % cfg, LangNote, Note_Transp, 60
IniRead note_duration, % cfg, LangNote, Note_Duration, 700

IniRead key_press, % cfg, Hotkeys, Key_Press, 1
IniRead short_press, % cfg, Hotkeys, Short_Press, 200
IniRead long_press, % cfg, Hotkeys, Long_Press, 600
IniRead ctrl_ctrl, % cfg, Hotkeys, Ctrl_Ctrl, 1
IniRead shift_shift, % cfg, Hotkeys, Shift_Shift, 1

_radius:=64*radius//100, _bold:=bold ? "Bold" : ""
default_colors:=[0x003FA5, 0xBF003F, 0x406300, 0x994A03, 0xC632A1, 0x1B7785, 0x444444, 0x8201D8]

apps:=[]
If FileExist(apps_cfg) {
    Loop {
        IniRead a, % apps_cfg, Apps, app%A_Index%, % " "
        If !a
            Break
        apps.Push(StrSplit(a, ","))
    }
}

SysGet MW, MonitorWorkArea
RegRead lang_key, HKEY_CURRENT_USER\Keyboard Layout\Toggle, Hotkey

; Меню раскладок
Menu LayoutMenu, Add, Цвет текстового флага, SetColor2
Menu LayoutMenu, Default, 1&
Menu LayoutMenu, Add, Копировать имя файла флага, CopyFlagName
Menu LayoutMenu, Add, Изменить сокращение раскладки, Rename
Menu LayoutMenu, Add, Открыть (создать) папку словаря, OpenDictFolder
Menu LayoutMenu, Add,
Menu LayoutMenu, Add, Отмена, Return

Gosub Settings

If numlock_on
    SetNumLockState On

Menu Tray, NoStandard
Menu Tray, Tip, LangBar++
Menu Tray, Add, Смена раскладки, LangBar
Menu Tray, Default, Смена раскладки
Menu Tray, Add, Раскладки и флажки, LayoutsAndFlags

Menu Flag, Add, Включен (Shift+Shift), FlagToggle
Menu Flag, Add, Настройка флажка, FlagSettings
Menu Scaling, Add, Default, Scaling
Menu Scaling, Add, NearestNeighbor, Scaling
Menu Scaling, Add, Bilinear, Scaling
Menu Scaling, Add, Bicubic, Scaling
Menu Scaling, Add, Bicubic HQ, Scaling
Menu Flag, Add, Масштабирование, :Scaling
Menu Flag, Add, Сглаживание, Smoothing
Menu Flag, Add, Без обводки, NoBorder
Menu Flag, Add, Пропорции файла, FlagAspect
Menu Tray, Add, Флажок каретки, :Flag

Menu Cursor, Add, На текстовом курсоре, TextCursorToggle
Menu Cursor, Add, На указателе мыши, ArrowCursorToggle
Menu Cursor, Add
Menu Cursor, Add, При смене окна, OnNewWindow
Menu Cursor, Add, При клике мышью, OnMouseClick
Menu CursorShow, Add, 2 сек., CursorShow
Menu CursorShow, Add, 3 сек., CursorShow
Menu CursorShow, Add, 5 сек., CursorShow
Menu CursorShow, Add, 10 сек., CursorShow
Menu Cursor, Add, Время показа, :CursorShow
Menu Cursor, Add
Menu Cursor, Add, Увеличенный флаг, LargeFlagToggle
Menu Cursor, Add, Инверсия указателя, InvertArrowToggle
Menu Cursor, Add, Цветной указатель, ArrowColorToggle
Menu Cursor, Add, Цвет указателя, ArrowColor
Menu CursorSize, Add, 24x24 px, CursorSize
Menu CursorSize, Add, 28x28 px, CursorSize
Menu CursorSize, Add, 32x32 px, CursorSize
Menu CursorSize, Add, 36x36 px, CursorSize
Menu CursorSize, Add, 40x40 px, CursorSize
Menu CursorSize, Add, 44x44 px, CursorSize
Menu CursorSize, Add, 48x48 px, CursorSize
Menu Cursor, Add, Размер курсора, :CursorSize
Menu Tray, Add, Флажок курсора, :Cursor


Menu Indicator, Add, Включен (Ctrl+Shift+Shift), IndicatorToggle
Menu Indicator, Add
Menu Indicator, Add, Привязка к активному окну, WindowSnap
Menu Indicator, Add, Переключатель раскладки, LangSwitcher
Menu Indicator, Add, На полном экране, OnFullScreen
Menu Indicator, Add
Menu Indicator, Add, Настройка индикатора, IndicatorSettings
Menu Tray, Add, Индикатор раскладки, :Indicator

Menu Icon, Add, Настройки флажка, As_Flag
Menu Icon, Add, Без смещения вниз, Icon_Shift
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
Menu CapsLock, Add, Shift+CapsLock - инверсия, ShiftCapslock
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
Menu Autocorrect, Add, Словари Hunspell, Hunspell
Menu Autocorrect, Add
Menu Autocorrect, Add, Исключения, UserDict
Menu Autocorrect, Add, История отмен, UndoLog
Menu Autocorrect, Add, Статистика, Statistics
Menu Tray, Add, Автопереключение, :Autocorrect
If !FileExist("hunspell")
    Menu Tray, Disable, Автопереключение
Menu Select, Add, Посимвольное выделение, SymbSel
Menu Select, Add, Только с начала, StartOnly
Menu Select, Add,
Menu Select, Add, Обработка переносов, EnterOn
Menu Select, Add, Обработка табуляций, TabOn
Menu Select, Add,
Menu Select, Add, Настройки клавиатуры, GUI
Menu Tray, Add, Правила приложений, AppRules
Menu Tray, Add, Выделение, :Select
Menu Tray, Add, Автозамена, Autoreplace
Menu Tray, Add

Menu Autorun, Add, Включить, Autorun
Menu Tray, Add, Автозапуск, :Autorun

Menu Help, Add, Справка, Help
Menu Help, Add, Горячие клавиши, Hotkeys
Menu Help, Add, Что нового?, Changelog
Menu Help, Add,
Menu Help, Add, Папка программы, ProgramFolder
Menu Help, Add, Папка настроек, ConfigFolder
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

try {
    Menu, Tray, Icon, 2&, % "HICON:" Base64PNG_to_HICON(icon2)
    Menu, Tray, Icon, 8&, % "HICON:" Base64PNG_to_HICON(icon3)
    Menu, Tray, Icon, 9&, % "HICON:" Base64PNG_to_HICON(icon3)
    Menu, Tray, Icon, 10&, % "HICON:" Base64PNG_to_HICON(icon3)
    Menu, Tray, Icon, 18&, % "HICON:" Base64PNG_to_HICON(icon4)
    Menu, Tray, Icon, 22&, % "HICON:" Base64PNG_to_HICON(icon5)
    Menu, Tray, Icon, 23&, % "HICON:" Base64PNG_to_HICON(icon6)
}

Menu Flag, % flag ? "Check" : "Uncheck", 1&
Menu Flag, % (smoothing!=3) ? "Check" : "Uncheck", 4&
Menu Flag, % no_border ? "Check" : "Uncheck", 5&
Menu Flag, % file_aspect ? "Check" : "Uncheck", 6&

Menu Cursor, % text_cursor ? "Check" : "Uncheck", 1&
Menu Cursor, % arrow_cursor ? "Check" : "Uncheck", 2&
Menu Cursor, % on_new_window ? "Check" : "Uncheck", 4&
Menu Cursor, % on_mouse_click ? "Check" : "Uncheck", 5&
Menu Cursor, % large_flag ? "Check" : "Uncheck", 8&
Menu Cursor, % invert_arrow ? "Check" : "Uncheck", 9&
Menu Cursor, % color_arrow ? "Check" : "Uncheck", 10&

Menu CursorSize, % (cursor_size=24) ? "Check" : "Uncheck", 1&
Menu CursorSize, % (cursor_size=28) ? "Check" : "Uncheck", 2&
Menu CursorSize, % (cursor_size=32) ? "Check" : "Uncheck", 3&
Menu CursorSize, % (cursor_size=36) ? "Check" : "Uncheck", 4&
Menu CursorSize, % (cursor_size=40) ? "Check" : "Uncheck", 5&
Menu CursorSize, % (cursor_size=44) ? "Check" : "Uncheck", 6&
Menu CursorSize, % (cursor_size=48) ? "Check" : "Uncheck", 7&

Menu CursorShow, % (cursor_show=2) ? "Check" : "Uncheck", 1&
Menu CursorShow, % (cursor_show=3) ? "Check" : "Uncheck", 2&
Menu CursorShow, % (cursor_show=5) ? "Check" : "Uncheck", 3&
Menu CursorShow, % (cursor_show=10) ? "Check" : "Uncheck", 4&

Menu Indicator, % indicator ? "Check" : "Uncheck", 1&
Menu Indicator, % window_snap ? "Check" : "Uncheck", 3&
Menu Indicator, % lang_switcher ? "Check" : "Uncheck", 4&
Menu Indicator, % on_full_screen ? "Check" : "Uncheck", 5&

Menu Scaling, % scaling=0 ? "Check" : "Uncheck", 1&
Menu Scaling, % scaling=5 ? "Check" : "Uncheck", 2&
Menu Scaling, % scaling=3 ? "Check" : "Uncheck", 3&
Menu Scaling, % scaling=4 ? "Check" : "Uncheck", 4&
Menu Scaling, % scaling=7 ? "Check" : "Uncheck", 5&


Menu CapsLock, % capslock=1 ? "Check" : "Uncheck", 1&
Menu CapsLock, % capslock=4 ? "Check" : "Uncheck", 2&
Menu CapsLock, % capslock=5 ? "Check" : "Uncheck", 3&
Menu CapsLock, % capslock=0 ? "Check" : "Uncheck", 7&
Menu CapsLock, % capslock=-1 ? "Check" : "Uncheck", 8&
Menu CapsLock, % capslock=2 ? "Check" : "Uncheck", 9&
Menu CapsLock, % capslock=3 ? "Check" : "Uncheck", 10&

Menu CapsLock, % shift_capslock ? "Check" : "Uncheck", 5&

Menu NumLock, % numlock_on ? "Check" : "Uncheck", 1&
Menu NumLock, % numlock_icon ? "Check" : "Uncheck", 3&
Menu NumLock, % numlock_icon_in ? "Check" : "Uncheck", 4&

Menu ScrollLock, % !scrolllock ? "Check" : "Uncheck", 1&
Menu ScrollLock, % scrolllock_icon ? "Check" : "Uncheck", 3&
Menu ScrollLock, % scrolllock_icon_in ? "Check" : "Uncheck", 4&

Menu Icon, % flag_sett ? "Check" : "Uncheck", 1&
Menu Icon, % !icon_shift ? "Check" : "Uncheck", 2&

Menu Icon, % aspect=2 ? "Check" : "Uncheck", 4&
Menu Icon, % aspect=1 ? "Check" : "Uncheck", 5&
Menu Icon, % !aspect ? "Check" : "Uncheck", 6&

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

pToken:=Gdip_Startup()
Gosub LayoutsAndFlags
Gosub Hotstrings

Gosub FlagGui
Gosub IndicatorGui
Gosub Masks
lang_old:=lang_array[1,1]
SetTimer TrayIcon, 100
Sleep 100
SetTimer Flag, 40
If FileExist("hunspell") {
    Gosub LoadDict
    SetTimer UpdateUserDict, 10000
}

Gosub EmptyMem
SetTimer EmptyMem, 60000

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

If (lang_select=3)
    Loop  % lang_count
        Hotkey % "<#sc" A_Index+1, SetInputLang

If digit_keys {
    Loop % lang_count {
        Hotkey % ">^sc" A_Index+1, MultiTranslate
        Hotkey % ">+sc" A_Index+1, MultiTranslate
    }
}
If f_keys {
    Loop % lang_count {
        Hotkey % ">^F" A_Index, MultiTranslate
        Hotkey % ">+F" A_Index, MultiTranslate
        endkeys:=RegExReplace(endkeys, "\{F" A_Index "}")
    }
}
If !FileExist("hunspell")
    Return
hook_opt:="I V"
InputHook:
    ks:=[], ih_alt:=text_alt:=text_old:=key_prev:=bs_ignore:=""
    ih:=InputHook(hook_opt, endkeys)
    If !InStr(hook_opt, "V")
        ih.VisibleNonText:=0
    ih.KeyOpt("{All}", "N")
    ih.KeyOpt("{CapsLock}{NumLock}{LWin}{LShift}{RShift}{LCtrl}{RCtrl}{LAlt}{RAlt}{AltGr}{Pause}", "-N")
    ih.OnKeyDown:=Func("KeyArray")
    ih.Start()
    ih.Wait()
    If (ih.EndKey~="(Tab|Enter)")
        key_name:=ih.EndKey
    If (ih.EndKey~="Enter")
        new_lang:=mouse_click:=""
    Goto InputHook

^#vk4C:: ; Ctrl+Win+L
    ListVars
    Return

KeyArray(hook, vk, sc) {
    Global
    If WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || WinActive("ahk_exe VirtualBoxVM.exe")
        Return
    tstart:=A_TickCount, il:=lang, win_now:=WinExist("A")
    ControlGetFocus ctrl_now
    If (win_now!=win_prior) || (ctrl_now!=ctrl_prior)
        ks:=[], out:=[], key_string:=manual_convert:=text_convert:=text:=text_alt:=bs_ignore:=reverse:="", bs_count:=deadkey_count:=send_length:=0, key_name:="Space"
    win_prior:=win_now, ctrl_prior:=ctrl_now
    StringCaseSense Off
    prefix:=(GetKeyState("LShift", "P") || GetKeyState("RShift", "P")) ? "+" : "",
    prefix:=((GetKeyState("LCtrl", "P") && GetKeyState("LAlt", "P")) || GetKeyState("RAlt", "P") || GetKeyState("AltGr", "P")) ? "^!" : prefix
    If (GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P")) && !GetKeyState("LAlt", "P")
        Return
    If (pefix="+") && GetKeyState("BS", "P")
        Return
    ks.Push([sc, prefix, GetKeyState("CapsLock", "T")]), ksl:=ks.Length()
    If !ih.VisibleText
        Return

    If ((print_win:=WinExist("A"))!=print_win_old)
        mouse_click:=new_lang:=key_name:=""
    If (il!=il_old) && (print_win=print_win_old) && print_win_old && il_old && new_lang_ignore
        new_lang:=1
    il_old:=il, print_win_old:=print_win, wheel:=0, key_prev:=key_name

    If (key_name~="(Space|Tab|Enter)")
        lang_start:=new_lang:=mouse_click:=trans:=text_convert:=manual_convert:=text_alt:=bs_ignore:=reverse:="", bs_count:=deadkey_count:=0, out:=[]
    key_name:=GetKeyName(Format("sc{:x}", sc)), ih_old:=ih.Input, last_symb:=SubStr(ih_old, 0), last_space:=(key_name~="(Space|Tab|Enter)") ? 1 : 0

    If (ih.Input~="^\S$") && (WinActive("ahk_class ConsoleWindowClass") || WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_class VirtualConsoleClass")) ; сброс для консольных программ
        manual_convert:=""
    If last_space
        key_string:=text:=text_alt:=manual_convert:="", key_time:=nkeys:=0
    If (key_name="Backspace") && (prefix!="+") { ; обработка BS
        ih_alt:=SubStr(ih_alt, 1, -1), t0_alt:=SubStr(t0_alt, 1, -1), ks.Pop(), ks.Pop(),
        manual_convert:=text_convert:="", bs_count:=0
        If backspace_ignore
            bs_ignore:=1
        Return ; Необходимо для автопереключения при полном затирании слова!
    }
    If autocorrect && (il~=lang_auto) && (((digit_borders && (Format("sc{:x}", sc)~="^(sc[2-9a-dA-D])$")) || (start_symbols_enabled && InStr(start_symbols, last_symb))) && ((key_prev~="(Space|Tab|Enter)") || !key_prev)) {
        ih.Stop()
        Return
    }

    If !((auto_state=1) || (autocorrect && (auto_state!=2)))
        Return
    If !single_lang && lang_auto {
        If !(il~=lang_auto)
            Return
        RegExMatch(lang_auto, "\(\K(.+)\|(.+)(?=\))", auto), alt_lang:=(il=auto1) ? auto2 : auto1
    }
    Else If lang_auto_others {
        If !(il~=lang_auto_others)
            Return
        alt_lang:=lang_auto_single
    }
    vk:=DllCall("MapVirtualKeyEx", "UINT", sc, "UINT", 3, "PTR", alt_lang)
    deadkey:=(DllCall("MapVirtualKeyEx", "UINT", vk, "UINT", 2, "PTR", alt_lang)<0) ? 1 : 0

    VarSetCapacity(lpKeyState, 256, 0),
    VarSetCapacity(pwszBuff, cchBuff:=3,0),
    VarSetCapacity(pwszBuff, 4, 0)

    for modifier, vk1 in {Shift:0x10, Control:0x11, Alt:0x12}
        NumPut(128*(GetKeyState("L" modifier) || GetKeyState("R" modifier)) , lpKeyState, vk1, "Uchar")
    NumPut(GetKeyState("CapsLock", "T") , &lpKeyState+0, 0x14, "Uchar")
    Loop 2
        nch:=DllCall("ToUnicodeEx"
            , "Uint", vk
            , "Uint", sc
            , "UPtr", &lpKeyState
            , "ptr", &pwszBuff
            , "Int", cchBuff
            , "Uint", 0
            , "ptr", alt_lang)
    ;OutputDebug % vk " " sc " " alt_lang
    symb:=StrGet(&pwszBuff, nch, "utf-16"), text_alt:=ih_alt.=(deadkey || (key_name="Backspace")) ? "" : symb,
    deadkey_count+=deadkey ? 1 : 0
    If deadkey
        Return

    RegExMatch(ih_old, "\S+(?=\s?$)", text), RegExMatch(text_alt, "\S+(?=\s?$)", t_alt),
    RegExMatch(ih_old, "\S+\s?$", tconv), str_length:=StrLen(tconv),
    t0:=RegExReplace(text, "\s$"), t0_alt:=RegExReplace(t_alt, "\s$")

    If (StrLen(text)>2) && (SubStr(text, 1, 1)=SubStr(text, 2, 1)) && (SubStr(text, 1, 1)=SubStr(text, 3, 1)) || (StrLen(text)>10) {
        bs_ignore:=1
        Return
    }

    If text_convert
        || (new_lang && new_lang_ignore)
        || (mouse_click && mouse_click_ignore)
        || (abbr_ignore && (t0_alt==Format("{:U}", t0_alt)) && (str_length>1))
        || (digit_ignore && (t0_alt~="\d"))
        || (letter_ignore && (StrLen(t0)=1))
        Return

    If RegExMatch(user_dic, "mi`n)^" t0) && (StrLen(t0)>2) {
        text_convert:=1
        Return
    }
    end_symb:=""
    If InStr(end_symbols, SubStr(t0_alt, 0)) && end_symbols_enabled
        t0_alt:=SubStr(t0_alt, 1, -1), end_symb:=1

    If (SubStr(t0, 1, 1)=SubStr(t0, 2, 1)) && (SubStr(t0, 1, 1)=SubStr(t0, 3, 1)) ; начальные дубликаты знаков и срабатывание границ слов
        Return

    If (StrLen(t0_alt)<2) && deadkey_count ; Блокировка одиночных букв с диакритикой
        Return

    t1:=t2:=tu:=list_curr:=list_alt:=""
    If (t0==Format("{:L}", t0))
        t0:=Format("{:T}", t0), t0_alt:=Format("{:T}", t0_alt), tu:=1

    If !(t1:=Spell_Spell(d_%il%, t0) ? t0 : "")
        t1:=Spell_Spell(d_%il%, DelAccent(t0)) ? t0 : ""
    If !t1 && !last_space && !(t0~="[.*?+\\[{|()^$]")
        If Spell_Suggest(d_%il%, t0 "*", list_curr)
            If !RegExMatch(list_curr, "m`n)^" t0, t1)
                RegExMatch(DelAccent(list_curr), "m`n)^" DelAccent(t0), t1)

    If !(t2:=Spell_Spell(d_%alt_lang%, t0_alt) ? t0_alt : "")
        t2:=Spell_Spell(d_%alt_lang%, DelAccent(t0_alt)) ? t0_alt : ""
    If !t2 && !last_space && !(t0_alt~="[.*?+\\[{|()^$]")
        If Spell_Suggest(d_%alt_lang%, t0_alt "*", list_alt)
            If !RegExMatch(list_alt, "m`n)^" t0_alt, t2)
                RegExMatch(DelAccent(list_alt), "m`n)^" DelAccent(t0_alt), t2)


    ;OutputDebug % t0 "/" t0_alt "  kn: " key_name " t1: " t1 "t2: " t2 " len: " str_length
    ;OutputDebug % il " " t0 " " list_curr " " t0_alt " " list_alt

    If ttip {
        list1:=list2:=count1:=count2:=""
        If t1 {
            list1:=t1 ", ", count1:=1
            Loop Parse, list_curr, `n
                If (A_LoopField~="^" t0 . (last_space ? "$" : "")) && (A_LoopField!=t1) {
                    count1++
                    If (count1<6)
                        list1.=A_LoopField ", "
                }
            list1:="(" RegExReplace(list1, ", ?$") ")"
        }
        If t2 {
            list2:=t2 ", ", count2:=1
            Loop Parse, list_alt, `n
                If (A_LoopField~="^" t0_alt . (last_space ? "$" : ""))  && (A_LoopField!=t2) {
                    count2++
                    If (count2<6)
                        list2.=A_LoopField ", "
                }
            list2:="(" RegExReplace(list2, ", ?$") ")"
        }
        If tu
            t0:=Format("{:L}", t0), t1:=Format("{:L}", t1), t0_alt:=Format("{:L}", t0_alt), t2:=Format("{:L}", t2), list1:=Format("{:L}", list1), list2:=Format("{:L}", list2)
        Tooltip % LangCode(il) "   " t0 "   " t1 "  " list1 "`n" LangCode(alt_lang) "   " t0_alt "   " t2  "  " list2 , % A_ScreenWidth//2-200, 0, 10
        ttip1:=""
    }
    key_time+=A_TickCount-tstart, nkeys+=1, minl:=Min(StrLen(t0), StrLen(t0_alt))
    If autocorrect && (((last_space || end_symb) && str_length) || (minl>(min_length ? 2 : 1))) && t2 && !t1 && !text_convert && !bs_ignore {
        ;KeyWait % Format("vk{:x}", vk) , T0.5
        text_convert:=1, out:=ks.Clone(), 
        hook_opt:="I", ih.Stop(), ks:=[],
        r1:=tu ? Format("{:L}", t0) : t0, r2:=tu ? Format("{:L}", t2) : t2,
        SetTimer ResetHook, -3000
        SetTimer AutocorrectRun, -3
    }
    Return
}

AutocorrectRun:
    last_space:="", lang_start:=il, ts:=A_TickCount, olds:=tconv
    bs_count:=(str_length>out.Length()) ? out.Length() : str_length,
    out.RemoveAt(1, out.Length()-bs_count)
    If lang_note {
        Gosub LangNote
        SetTimer LangNote, -700
    }
    Loop % bs_count {
        SendInput {BS down}{BS up}
        Sleep 2
    }
    SetInputLayout(key_switch, alt_lang)
    Sleep 2
    SendText(out)
    SendText(ks)
    ;OutputDebug % ih.InProgress " " ih.VisibleText " " ih.VisibleNonText
    Sleep 5
    il_old:=InputLayout(), ih_alt:=text_alt:="",
    bs_count+=ks.Length(), out.Push(ks*), hook_opt:="I V", ih.Stop(), ks:=[], wtime:=key_time//nkeys "/" A_TickCount-ts
    If sound && FileExist("sounds\autocorrect.wav")
        SetTimer AutocorrectSound, -10
    Return

ResetHook:
    If FileExist("logs")
        FileAppend % "`r`n" r1 "/" r2 " - "  wtime " - "  alt_lang, logs\transform.log, UTF-8
    If !(ih.VisibleText && ih.InProgress)
        hook_opt:="I V", ih.Stop()
    SetTimer TrayIcon, On
    SetTimer Flag, On
    Return

AutocorrectSound:
    SoundPlay sounds\autocorrect.wav, 1
    Return

EmptyMem:
    Dllcall("psapi.dll\EmptyWorkingSet", "UInt", -1)
    Return

DelAccent(txt) {
    If A_OSVersion in Win_XP,WIN_2003
        Return RemoveLetterAccents(txt)
    Else
        Return StrUnmark(txt)
}

#If manual_convert
~Left::
~Right::manual_convert:=out:=""
#If

#If pause_langs
Pause::
    If ((text_convert && !last_space) || (manual_convert && (A_ThisHotkey=hkey) && (A_TimeSincePriorHotkey>500))) && out {
        KeyWait Pause, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    If (InputLayout()~="^" pause_langs "$") || ((InputLayout()~="^" cycl_langs "$") && (pause_langs~="^\d$"))
        Goto Translate
    Return

#If shift_bs_langs
<+BS::
>+BS::
    If (text_convert || (manual_convert && (A_ThisHotkey=hkey))) {
        KeyWait BS, T1
        KeyWait LShift, T1
        KeyWait RShift, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    If (InputLayout()~="^" shift_bs_langs "$") || ((InputLayout()~="^" cycl_langs "$") && (shift_bs_langs~="^\d$"))
        Gosub Translate
    Send {LShift up}
    Send {RShift up}
    Return

#If ctrl_capslock_langs
<^CapsLock::
    cls:=cls_old
    SetCapsLockState Off
    If manual_convert && (A_ThisHotkey=hkey) && out {
        KeyWait CapsLock, T1
        KeyWait LCtrl, T1
        Gosub Rollback
        Sleep 50
        SetCapsLockState % cls ? "On" : "Off"
        Return
    }
    Else If !manual_convert && (InputLayout()~="^" ctrl_capslock_langs "$") || ((InputLayout()~="^" cycl_langs "$") && (ctrl_capslock_langs~="^\d$"))
        Gosub Translate
    Sleep 50
    SetCapsLockState % cls ? "On" : "Off"
    Return

#If shift_capslock
<+CapsLock::
    cls:=cls_old
    SetCapsLockState Off
    If manual_convert && (A_ThisHotkey=hkey) && out {
        KeyWait CapsLock, T1
        KeyWait LShift, T1
        Gosub Rollback
        Sleep 50
        SetCapsLockState % cls ? "On" : "Off"
        Return
    }
    Gosub Select
    send_length:=SendText(InvertCase(sel), 1)
    out:=sel, manual_convert:=1
    Sleep 50
    SetCapsLockState % cls ? "On" : "Off"
    Return


#If (text_convert || manual_convert) && !last_space && out && ctrlz_undo
^sc2C up:: ; Ctrl+Z
#If

Rollback:
    Critical
    KeyWait Ctrl, T1
    Sleep 10
    If IsObject(out) {
        If text_convert && !manual_convert
            out.Push(ks*)
        Loop % manual_convert ? send_length : bs_count+StrLen(ih.Input)-deadkey_count {
            SendInput {BS down}{BS up}          
            Sleep 20
        }
        ;Tooltip % bs_count " " ih.Input " " deadkey_count, % A_CaretX, % A_CaretY-20
        ;SetTimer Tooltip, -5000
    }
    Else {
        ; OutputDebug % ">" out "<>" text_alt "<"
        Loop % send_length {
            SendInput {BS down}{BS up}
            Sleep 20
            manual_convert:=0
        }
    }
    If lang_start {
        If (hkey~="^>(\^|\+)(sc|F)\d+$") || ((hkey="CapsLock") && (capslock=4)) || (hkey="<+CapsLock") || (hkey~="^>\^")
            SetInputLayout(key_switch, lang_start)
        Else
            Gosub SetInputLang
        Sleep 10 ; !!!
    }
    send_length:=SendText(out, 1)
    If sound && FileExist("sounds\undo.wav") && text_convert
        SetTimer UndoSound, -50
    If FileExist("logs") && r1 && r2 {
        FileAppend % "`r`n" r2 "/" r1, logs\undo.log, UTF-8
        FileAppend % " <==", logs\transform.log, UTF-8
        If !A_IsCompiled
            FileAppend % " " bs_count "/" ks.Length(), logs\undo.log, UTF-8
    }
    ih.Stop(), bs_count:=deadkey_count:=0
    Return

UndoSound:
    SoundPlay sounds\undo.wav, 1
    Return

KeyString(in) {
    Loop % in.Length()
        out.=in[A_Index, 2] GetKeyName(Format("sc{:x}", in[A_Index, 1]))
    Return out
}

Select:
    If key_block || WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || WinActive("ahk_exe VirtualBoxVM.exe")
        Return
    hkey:=A_ThisHotkey, RegExMatch(hkey, "\w+$", button), key_block:=1, hkey_time:=A_TickCount
    Hotkey % "*" button, Return, On
    Hotkey *BS, Return, On
    text:=rem:=ih.Input, out:=ks.Clone(), bh:=InputHook("I"), bh.Start(),
    sel:=hand_sel:=send_bs:=per_symbol_select:=text_convert:="", bs_count:=0
    SetTimer ResetButtons, -2500, 9
    If StrLen(text) {
        If (button~="(RButton|MButton)")
            SetTimer Flag, Off
        WinGetActiveTitle ttl
        If WinActive("ahk_class ConsoleWindowClass") || WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_class VirtualConsoleClass") || (hkey="<+BS") || (hkey~=">\+(F|sc)\d+")
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
                SendInput % send_bs ? "{BS down}{BS up}" : "+{Left}"
                Sleep 5
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
        sel:=SubStr(text, StrLen(rem)+1), out.RemoveAt(1, StrLen(rem))
        If (hkey~="(Pause|\+BS|\^CapsLock|RButton)") || ((hkey="CapsLock") && (capslock=3)) {
            KeyWait % button, % "T" reverseint/1000
            If (reverse:=ErrorLevel) {
                Gui Hide
                Sleep 20
                Gui Hide
            }
        }
        KeyWait % button, T1.5
        If (hkey~="(RButton|MButton)")
            SetTimer Flag, On
    }
    Else {
        If (hkey~="(Pause|\+BS|\^CapsLock|RButton)") || ((hkey="CapsLock") && (capslock=3)) {
            KeyWait % button, % "T" reverseint/1000
            If (reverse:=ErrorLevel)  {
                Gui Hide
                Sleep 20
                Gui Hide
            }
        }
        KeyWait % button, T1.5
        KeyWait LCtrl, T1
        KeyWait RCtrl, T1
        KeyWait RShift, T1
        tmp:=ClipboardAll, Clipboard:=""
        SendInput ^{vk43}
        ClipWait 1
        If !ErrorLevel
            sel:=hand_sel:=Clipboard
        Sleep 20
        Clipboard:=tmp
    }
    If !sel {
        Tooltip % "Буфер пуст -`nвыделите текст!", % (_x && _y) ? _x+20 : A_ScreenWidth//2-30, % (_x && _y) ? _y+20 : A_ScreenHeight//2-15
        SetTimer ToolTip, -1200
        Sleep 200
        Gosub ResetButtons
        Exit
    }
    SetTimer ResetButtons, -500
    manual_convert:=1, ih.Stop(), lang_start:=InputLayout()
    Sleep 100
    Return

ResetButtons:
    Send {RCtrl up}
    bh.Stop(), key_block:=""
    Hotkey % "*" button, Return, Off
    Hotkey *BS, Return, Off
    SetTimer Flag, On
    Return

Convert:
ReConvert:
    Sleep 100
    out:=[], convert:="", hkl:=InputLayout()
    Loop Parse, sel
    {
        val:=DllCall("VkKeyScanEx", "Char", Asc(A_LoopField), "UInt", hkl)
        If (val=-1) {
            val:=DllCall("VkKeyScanEx", "Char", Asc(DelAccent(A_LoopField)), "UInt", hkl)
            If (val=-1) {
                If (lang_count=2) && (A_ThisLabel="Convert") && (button~="(Pause|BS|RButton|CapsLock)") {
                    SetInputLayout(key_switch)
                    Goto Reconvert
                }
                ToolTip Неверная`nраскладка!,  % (_x && _y) ? _x-50 : A_ScreenWidth/2-100, % (_x && _y) ? _y-40 : A_ScreenHeight/2
                SetTimer ToolTip, -2000
                SetInputLayout(key_switch, lang_start)
                Exit
            }
        }
        vk:="0x" SubStr(Format("{:x}", val), -2), prx:=""
        If (vk~="20d$") ; удаление двойных переносов
            Continue
        If (vk~="1\w\w$")
            prx:="+"
        If (vk~="6\w\w$")
            prx:="^!"
        vk:=RegExReplace(vk, "0x\K\d(?=\w\w$)")
        sc:=Format("{:#x}", DllCall("MapVirtualKeyEx", "UINT", vk, "UINT", 0, "PTR", hkl))
        out.Push([sc, prx, 0]), convert.=prx "{" sc "}"
        OutputDebug % hkl " " KeyString(out)
    }
    Return

#If !text_convert
>^scD::
    If manual_convert && out && (A_ThisHotkey=hkey) {
        KeyWait scD, T1
        KeyWait RCtrl, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    Gosub Select
    send_length:=SendText(InvertCase(sel), 1)
    Sleep 10
    SetInputLayout(key_switch, lang_start)
    SendInput {RCtrl up}
    out:=sel, manual_convert:=1
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
    If manual_convert && out && (A_ThisHotkey=hkey) {
        KeyWait scC, T1
        KeyWait RCtrl, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    Gosub Select
    send_length:=SendText(Format("{:L}", sel), 1)
    Sleep 5
    SetInputLayout(key_switch, lang_start)
    SendInput {RCtrl up}
    out:=sel, manual_convert:=1
    Return

>^scB::
    If manual_convert && out && (A_ThisHotkey=hkey) {
        KeyWait scB, T1
        KeyWait RCtrl, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    Gosub Select
    send_length:=SendText(Format("{:U}", sel), 1)
    Sleep 5
    SetInputLayout(key_switch, lang_start)
    SendInput {RCtrl up}
    out:=sel, manual_convert:=1
    Return

>^scA::
    If manual_convert && out && (A_ThisHotkey=hkey) {
        KeyWait scA, T1
        KeyWait RCtrl, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    Gosub Select
    send_length:=SendText(Format("{:T}", sel), 1)
    Sleep 5
    SetInputLayout(key_switch, lang_start)
    SendInput {RCtrl up}
    out:=sel, manual_convert:=1
    Return

>^sc1B::
    If manual_convert && out && (A_ThisHotkey=hkey) {
        KeyWait sc1B, T1
        KeyWait RCtrl, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    Gosub Select
    send_length:=SendText(Translit(sel), 1)
    Sleep 5
    SetInputLayout(key_switch, 0x0409)
    SendInput {RCtrl up}
    out:=sel, manual_convert:=1
    Return

OnFlag(hwnd) {
    MouseGetPos,,, win, ctrl
    WinGetClass class, ahk_id %win%
    Return ((win=hwnd) && (ctrl~="Static")) && (class="AutoHotkeyGUI") ? 1 : 0
}

#If OnFlag(FlagHwnd)
RButton::
    If ((text_convert && !last_space) || (manual_convert && (A_ThisHotkey=hkey) && (A_TimeSincePriorHotkey>500) )) && out {
        KeyWait RButton, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    If (InputLayout()~="^" pause_langs "$") || ((InputLayout()~="^" cycl_langs "$") && (pause_langs=1))
        Goto Translate
    Return

MButton::
    If manual_convert && out && (A_ThisHotkey=hkey) {
        KeyWait MButton, T1
        Goto Rollback
    }
    If manual_convert && !(A_ThisHotkey=hkey)
        Return
    Gosub Select
    send_length:=SendText(InvertCase(sel), 1)
    out:=sel, manual_convert:=1
    Return

#If (capslock=3) && ((InputLayout()~="^" pause_langs "$") || ((InputLayout()~="^" cycl_langs "$") && (pause_langs=1))) && (A_TimeSincePriorHotkey>700)
CapsLock::
    If ((text_convert && !last_space) || (manual_convert && (A_ThisHotkey=hkey) && (A_TimeSincePriorHotkey>500))) && out {
        KeyWait CapsLock
        Gosub RollBack
    }
    Else
        Gosub Translate
    SetCapsLockState AlwaysOff
    Return
#If

MultiTranslate:
    If (manual_convert && !last_space) && out && (A_ThisHotkey=hkey) {
        KeyWait % button, T1
        KeyWait RCtrl, T1
        KeyWait RShift, T1
        Goto Rollback
    }
Translate:
    Gosub Select
    If hand_sel {
        Gosub Convert
        Send {Del}
    }
    Gosub SetInputLang
    Sleep 10 ; !!!
    ;OutputDebug % lang_start " " target
    send_length:=SendText(out, 1)
    ih.Stop()
    Return

;=======================================
SetInputLang:
    If WinActive("ahk_class VMPlayerFrame") || WinActive("ahk_exe VirtualBox.exe") || WinActive("ahk_exe VirtualBoxVM.exe")
        Return
    curr_lang:=Format("{:#06x}", InputLayout()), show_lang:=0
    _pause_langs:=StrSplit(SubStr(pause_langs, 2, -1), "|"),
    _shift_bs_langs:=StrSplit(SubStr(shift_bs_langs, 2, -1), "|"),
    _ctrl_capslock_langs:=StrSplit(SubStr(ctrl_capslock_langs, 2, -1), "|")
    cycl_array:=[]
    If cycl_langs {
        Loop % lang_array.Length() {
            If (lang_array[A_Index, 1]~="^" cycl_langs "$")
                cycl_array.Push(lang_array[A_Index, 1])
            If (curr_lang=lang_array[A_Index, 1])
                cycl_curr:=A_Index
        }
        cycl_next:=(cycl_array.Length()>cycl_curr) ? cycl_array[cycl_curr+1] : cycl_array[1], 
        cycl_prev:=(cycl_curr>1) ? cycl_array[cycl_curr-1] : cycl_array[cycl_array.Length()]
    }
    StringCaseSense Off
    If (A_ThisHotkey="^sc2C up")
        target:=lang_start
    Else If (A_ThisHotkey~="(LShift|RShift|LCtrl|RCtrl)") {
        RegExMatch(A_ThisHotkey, "\w+$", lkey)
        target:=%lkey%, new_lang:=show_lang:=1
        If !target
            Return
        If (target=1)
            target:=0
        If (target=2) {
            Loop % lang_count
                If (curr_lang=lang_array[A_Index, 1]) {
                    ln:=A_Index
                    Break
                }
            target:=(ln>1) ? lang_array[ln-1, 1] : lang_array[lang_count, 1]
        }
    }
    Else If (A_ThisHotkey~="^<(\^|!|#)sc\d+$") {
        target:=lang_array[SubStr(A_ThisHotkey, 0)-1, 1]
        If key_switch {
            If (lang_select=1)
                KeyWait LCtrl, T1
            If (lang_select=2)
                KeyWait LAlt, T1
            If (lang_select=3)
                KeyWait LWin, T1
        }
        ih.Stop(), new_lang:=1, key_name:=text_convert:=""
    }
    Else If (hkey~="^>(\^|\+)F\d+$")
        target:=lang_array[SubStr(hkey, 0), 1]
    Else If (hkey~="^>(\^|\+)sc\d+$")
        target:=lang_array[SubStr(hkey, 0)-1, 1]
    Else If (hkey~="^(RButton|Pause)$") || ((hkey="Capslock") && (capslock=3)) {
        If (pause_langs=1) && cycl_langs
            target:=!reverse ? cycl_next : cycl_prev
        Else If (pause_langs=2) && cycl_langs
            target:=!reverse ? cycl_prev : cycl_next
        Else
            target:=(curr_lang=_pause_langs[1]) ? _pause_langs[2] : _pause_langs[1]
    }
    Else If (hkey~="\+BS$") {
        If (shift_bs_langs=1) && cycl_langs
            target:=!reverse ? cycl_next : cycl_prev
        Else If (shift_bs_langs=2) && cycl_langs
            target:=!reverse ? cycl_prev : cycl_next
        Else
            target:=(curr_lang=_shift_bs_langs[1]) ? _shift_bs_langs[2] : _shift_bs_langs[1]
    }
    Else If (hkey="<^CapsLock") {
        If (ctrl_capslock_langs=1) && cycl_langs
            target:=!reverse ? cycl_next : cycl_prev
        Else If (ctrl_capslock_langs=2) && cycl_langs
            target:=!reverse ? cycl_prev : cycl_next
        Else
            target:=(curr_lang=_ctrl_capslock_langs[1]) ? _ctrl_capslock_langs[2] : _ctrl_capslock_langs[1]
    }
    ;OutputDebug % hkey " " target
    SetInputLayout(key_switch, Format("{:#06x}", target))
    If (target!=curr_lang)
        SetTimer LangNote, -50
    Return

;================================================
#If lshift
~LShift::
#If rshift
~RShift::
#If lctrl
~LCtrl::
#If rctrl
~RCtrl::
    hkey_prev:=A_ThisHotkey
    KeyWait % SubStr(A_ThisHotkey, 2)
    If (hkey_prev!=A_ThisHotkey)
        Return
    key_time:=A_TimeSinceThisHotkey
    If ((key_press=2) && (key_time>short_press)) || ((key_press=3) && (key_time<long_press)) || ((key_press=4) && !((A_ThisHotkey=A_PriorHotkey) && (A_TimeSincePriorHotkey<400)))
            Return
    Gosub SetInputLang
    ih.Stop(), key_name:=text_convert:=""
    Return

#If (capslock=-1)
CapsLock::Shift

#If !capslock
CapsLock::Return

#If (capslock=2) && (A_TimeSincePriorHotkey>200)
CapsLock::
    SetInputLayout(key_switch)
    KeyWait CapsLock, T1
    SetCapsLockState AlwaysOff
    SetTimer LangNote, -50
    Return

#If (capslock=4)
CapsLock::
    If manual_convert && (A_ThisHotkey=hkey) && out {
        KeyWait CapsLock, T1
        Sleep 10
        SetCapsLockState Off
        Goto Rollback
    }
    KeyWait CapsLock, T0.25
    If !ErrorLevel {
        SetCapsLockState % GetKeyState("CapsLock", "T") ? "Off" : "On"
        Return
    }
    Gosub Select
    send_length:=SendText(InvertCase(sel), 1)
    SetCapsLockState Off
    out:=sel, manual_convert:=1
    Return

#If (capslock=5)
CapsLock::
    If manual_convert && (A_ThisHotkey=hkey) && out {
        KeyWait CapsLock, T1
        Sleep 10
        SetCapsLockState AlwaysOff
        Goto Rollback
    }
    Gosub Select
    send_length:=SendText(InvertCase(sel), 1)
    SetCapsLockState AlwaysOff
    Return

#If !OnFlag(FlagHwnd) && !OnFlag(IndHwnd)
~*LButton::
~*RButton::
~*MButton::
    print_win:=new_win, text_convert:=manual_convert:=out:=key_name:=key_prev:="", ih.Stop(), stop:="Mouse"
    GetCaretLocation(_x, _y)
    If _x && _y
        wheel:=x_wheel:=y_wheel:=0
    MouseGetPos,,, new_win
    If (new_win=print_win)
        mouse_click:=1
    Else
        new_lang:=""
    Sleep 50
    If on_new_window && on_mouse_click {
        cursor_hide:=0
        SetTimer CursorOff, % -1000*cursor_show
    }
    Return

~*WheelUp::
~*WheelDown::
~*WheelRight::
~*WheelLeft::
~*Up::
~*Down::
~*PgUp::
~*PgDn::
    ih.Stop(), stop:="Mouse", wtime:=A_TickCount
    If (cl~="^(ApplicationFrameWindow|Chrome_WidgetWin_\d|MozillaWindowClass|Slimjet_WidgetWin_1)") {
        wheel:=1, x_wheel:=_x, y_wheel:=_y
        Gui Hide
    }
    Return

ToolTip:
    Loop 20
        ToolTip,,,, % A_Index
    Return

#If
~!Tab::
    ih.Stop()
    Return

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
    Sleep 200
    Reload
    Return

Smoothing:
    smoothing:=(smoothing=2) ? 3 : 2
    Goto Apply

NoBorder:
    no_border:=!no_border
    Goto Apply

FlagAspect:
    file_aspect:=!file_aspect
    Goto Apply

WindowSnap:
    window_snap:=!window_snap
    Goto Apply

LangSwitcher:
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
    If (A_ThisMenuItem="Как Shift") {        
        capslock:=-1        If shift_capslock
            MsgBox, 16, , Несовместимо с включенным Shift+CapsLock!, 2
    }
    If (A_ThisMenuItem="Переключение раскладки")
        capslock:=2
    If (A_ThisMenuItem="Исправление раскладки")
        capslock:=3
    If (A_ThisMenuItem="То же и инверсия регистра")
        capslock:=4
    If (A_ThisMenuItem="Только инверсия регистра")
        capslock:=5
    Goto Apply

ShiftCapsLock:
    shift_capslock:=!shift_capslock
    If shift_capslock && (capslock=-1)
        MsgBox, 16, , Несовместимо с использованием CapsLock как Shift!, 2
    goto Apply

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

Icon_Shift:
    icon_shift:=!icon_shift
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
    msg:="'Reset' - настройки к значениям по умолчанию`n'Backup' - сохраняет копию без сброса"
    Result := MsgBoxEx(msg, "Сброс настроек", "Reset|Backup|Cancel*", 5, CheckText, "AlwaysOnTop", 0, 0, "s10 c0x000000", "Sego UI", "0x8CB9D7")
    If (Result=="Cancel")
        Return
    If (Result=="Reset") {
        If CheckText
            Gosub Zip
        FileAppend,, reset
        Sleep 100
        Reload
    }
    If (Result=="Backup") {
        Gosub Zip
        MsgBox, 64, , Бэкап сохранен в подпапке backup программы!, 2
        SetTimer ToolTip, -2000

    }
    Return

Zip:
    SetWorkingDir % cfg_folder
    zip:=new ZipFile(A_ScriptDir "\backup\backup_" A_YYYY "." A_MM "." A_DD "_" A_Hour "." A_Min "." A_Sec ".zip")
    zip.Pack()
    SetWorkingDir % A_ScriptDir
    Return


#If WinActive("LangBar++ ahk_class AutoHotkeyGUI")
Esc::WinClose LangBar++ ahk_class AutoHotkeyGUI
#If

Help:
    Run doc\ReadMe.html
    If ErrorLevel
        Run % A_WinDir "\System32\OpenWith.exe " """" A_ScriptDir "doc\ReadMe.html"""
    Return

Hotkeys:
    If !FileExist(A_ScriptDir "\doc\Hotkeys.html") {
        MsgBox, 16, , Отсутствует файл справки!, 2
        Return
    }
    Gui 16:Destroy
    wh:=A_ScreenWidth*2//3, ht:=A_ScreenHeight*5//6
    Gui 16:-DPIScale +AlwaysOnTop +LastFound +ToolWindow +HwndGui16
    Gui 16:Add, ActiveX, w%wh% h%ht% vWB, Shell.Explorer
    WB.Silent:=True
    WB.Navigate(A_ScriptDir "\doc\Hotkeys.html")
    Gui 16:Show,, Горячие клавиши
    Return

Changelog:
    Run % """" editor """ doc\Changelog.md"
    Return

ProgramFolder:
    Run % "explore """ A_ScriptDir """"
    Return

ConfigFolder:
    Run % "explore """ cfg_folder """"
    Return

About:
    Gui 4:Destroy
    Gui 4:Margin, 24, 12
    Gui 4:Font, s9
    Gui 4:Color, 8CB9D7
    Gui 4:-DPIScale +AlwaysOnTop +ToolWindow +HwndGui4
    Gui 4:Add, Link, x120, <a href="https://github.com/Krot66/LangBarXX">GitHub</a>
    Gui 4:Add, Link, x80 yp+24 , <a href="http://forum.ru-board.com/topic.cgi?forum=5&topic=50256#1">Форум Ru.Board</a>
    Gui 4:Add, Picture, x56 y+16 w160 h-1 Icon1, % "HICON:" Base64PNG_to_HICON(icon1)
    Gui 4:Font, s11
    Gui 4:Add, Text, x60 y+6, % "LangBar++ " version " " (A_PtrSize=8 ? "x64" : "x86")
    If FileExist("config")
        Gui 4:Add, Text, x100 y+4, % A_IsCompiled ? "portable" : "ahk-script"
    Gui 4:Font, s9
    Gui 4:Add, Button, x76 y+16 w120 h32 g4GuiClose, OK
    Gui 4:Show, w270, О программе
    Return

4GuiClose:
    Gui 4:Destroy
    Return

#If WinActive("ahk_id" Gui4 )
Esc::Goto 4GuiClose
#If

Exit:
    Gosub Settings
    RestoreCursors()
    Loop Parse, dname_string, CSV
        Spell_Uninit(A_LoopField)
    Loop % lang_count
        Gdip_DisposeImage(lang_array[A_Index, 4])
    Gdip_DisposeImage(pCaps)
    Gdip_DisposeImage(pNumLock)
    Gdip_DisposeImage(pScrollLock)
    Gdip_DisposeImage(pNumScroll)
    Gdip_DeleteBrush(Brush)
    Gdip_Shutdown(pToken)
    ExitApp

Autorun:
    RegRead lb_autorun, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, LangBarXX
    If (lb_autorun!="""" A_ScriptFullPath """")
        RegWrite Reg_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, LangBarXX, % """" A_ScriptFullPath """"
    Else
        RegDelete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, LangBarXX
    Goto Apply

Settings:
    IniWrite % version, % cfg, Main, Version

    IniWrite % cycl_langs, % cfg, Layouts, Cycl_Langs
    IniWrite % pause_langs, % cfg, Layouts, Pause_Langs
    IniWrite % shift_bs_langs, % cfg, Layouts, Shift_BS_Langs
    IniWrite % ctrl_capslock_langs, % cfg, Layouts, Ctrl_CapsLock_Langs
    IniWrite % key_switch, % cfg, Layouts, Key_Switch
    IniWrite % lang_select, % cfg, Layouts, Lang_Select
    IniWrite % lctrl, % cfg, Layouts, LCtrl
    IniWrite % rctrl, % cfg, Layouts, RCtrl
    IniWrite % lshift, % cfg, Layouts, LShift
    IniWrite % rshift, % cfg, Layouts, RShift
    IniWrite % double_click, % cfg, Layouts, Double_Click
    IniWrite % digit_keys, % cfg, Layouts, Digit_Keys
    IniWrite % f_keys, % cfg, Layouts, F_Keys

    IniWrite % flag, % cfg, Flag, Flag
    IniWrite % dx, % cfg, Flag, DX
    IniWrite % dy, % cfg, Flag, DY
    IniWrite % width, % cfg, Flag, Width
    IniWrite % transp, % cfg, Flag, Transp
    IniWrite % scaling, % cfg, Flag, Scaling
    IniWrite % smoothing, % cfg, Flag, Smoothing
    IniWrite % no_border, % cfg, Flag, No_Border
    IniWrite % file_aspect, % cfg, Flag, File_Aspect
    IniWrite % text_flags, % cfg, Flag, Text_Flags

    IniWrite % font_size, % cfg, TextFlags, Font_Size
    IniWrite % bold, % cfg, TextFlags, Bold
    IniWrite % font_color, % cfg, TextFlags, Font_Color
    IniWrite % radius, % cfg, TextFlags, Radius
    IniWrite % gradient, % cfg, TextFlags, Gradient

    IniWrite % text_cursor, % cfg, Cursor, Text_Cursor
    IniWrite % arrow_cursor, % cfg, Cursor, Arrow_Cursor
    IniWrite % large_flag, % cfg, Cursor, Large_Flag
    IniWrite % invert_arrow, % cfg, Cursor, Invert_Arrow
    IniWrite % invert_threshold , % cfg, Cursor, Invert_Threshold
    IniWrite % color_arrow, % cfg, Cursor, Color_Arrow
    IniWrite % arrow_color, % cfg, Cursor, Arrow_Color
    IniWrite % cursor_size, % cfg, Cursor, Cursor_Size
    IniWrite % on_new_window, % cfg, Cursor, On_New_Window
    IniWrite % on_mouse_click, % cfg, Cursor, On_Mouse_Click
    IniWrite % cursor_show, % cfg, Cursor, Cursor_Show
    IniWrite % flag_width, % cfg, Cursor, Flag_Width
    IniWrite % flag_height, % cfg, Cursor, Flag_Height
    IniWrite % flag_x, % cfg, Cursor, Flag_X
    IniWrite % flag_y, % cfg, Cursor, Flag_Y

    IniWrite % note, % cfg, LangNote, Note
    IniWrite % note_size, % cfg, LangNote, Note_Size
    IniWrite % note_transp, % cfg, LangNote, Note_Transp
    IniWrite % note_duration, % cfg, LangNote, Note_Duration
    Loop % lang_array.Length() {
        IniWrite % lang_array[A_Index, 6], % cfg, Colors, % "C_" lang_array[A_Index, 1]
        IniDelete % cfg, Colors, % "T_" lang_array[A_Index, 1]
    }

    IniWrite % indicator, % cfg, Indicator, Indicator
    IniWrite % lang_switcher, % cfg, Indicator, Lang_Switcher
    IniWrite % on_full_screen, % cfg, Indicator, On_Full_Screen
    IniWrite % dx_in, % cfg, Indicator, DX_In
    IniWrite % dy_in, % cfg, Indicator, DY_In
    IniWrite % window_snap, % cfg, Indicator, Window_Snap
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
    IniWrite % shift_capslock, % cfg, Keys, Shift_CapsLock

    IniWrite % wordint, % cfg, Select, WordInt
    IniWrite % wait, % cfg, Select, Wait
    IniWrite % symbint, % cfg, Select, SymbInt
    IniWrite % reverseint, % cfg, Select, ReverseInt
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
    IniWrite % sound, % cfg, Autocorrect, Sound
    IniWrite % lang_note, % cfg, Autocorrect, lang_note
    IniWrite % ctrlz_undo, % cfg, Autocorrect, CtrlZ_Undo
    IniWrite % no_indicate, % cfg, Autocorrect, No_Indicate
    IniWrite % min_length, % cfg, Autocorrect, Min_Length
    IniWrite % letter_ignore, % cfg, Autocorrect, Letter_Ignore
    IniWrite % abbr_ignore, % cfg, Autocorrect, Abbr_Ignore
    IniWrite % digit_ignore, % cfg, Autocorrect, Digit_Ignore
    IniWrite % start_symbols_enabled, % cfg, Autocorrect, Start_Symbols_Enabled
    IniWrite % start_symbols, % cfg, Autocorrect, Start_Symbols
    IniWrite % end_symbols_enabled, % cfg, Autocorrect, End_Symbols_Enabled
    IniWrite % end_symbols, % cfg, Autocorrect, End_Symbols
    IniWrite % digit_borders, % cfg, Autocorrect, Digit_Borders
    IniWrite % new_lang_ignore, % cfg, Autocorrect, New_Lang_Ignore
    IniWrite % mouse_click_ignore, % cfg, Autocorrect, Mouse_Click_Ignore
    IniWrite % backspace_ignore, % cfg, Autocorrect, Backspace_Ignore

    IniWrite % key_press, % cfg, Hotkeys, Key_Press
    IniWrite % short_press, % cfg, Hotkeys, Short_Press
    IniWrite % long_press, % cfg, Hotkeys, Long_Press
    IniWrite % ctrl_ctrl, % cfg, Hotkeys, Ctrl_Ctrl
    IniWrite % shift_shift, % cfg, Hotkeys, Shift_Shift

    ;IniWrite % tooltip_font, % cfg, ToolTip, ToolTip_Font
    Return

LangBar:
    SetTimer TrayIcon, Off
    SetTimer Flag, Off
    Gui Destroy
    Gui 11:Destroy
    KeyWait LButton, T1
    Sleep 10
    WinActivate ahk_id %last_lang_win%
    Sleep 50
    SetInputLayout(key_switch)
    SetTimer LangNote, -50
    ih.Stop()
    SetTimer TrayIcon, On
    SetTimer Flag, On
    Return

#If shift_shift
<+RShift::
>+LShift::
    RegExMatch(A_ThisHotkey, "\w+$", ckey)
    KeyWait % ckey
    key_time:=A_TimeSinceThisHotkey
    If (key_time>900) {
        lr:=last_rule
        Gosub AppRules
        Sleep 2000
        Return
    }
    If ((key_press=2) && (key_time>short_press)) || ((key_press=3) && (key_time<long_press))
        Return
FlagToggle:
    flag:=!flag
    Menu Flag, % flag ? "Check" : "Uncheck", 1&
    Return
#If

<^<+RShift::
>^>+LShift::
IndicatorToggle:
    KeyWait % RegExReplace(A_ThisHotkey, "^\W+"), T0.8
    If ErrorLevel && (A_ThisHotkey~="Shift") && !WinExist("ahk_id" hwnd5)
        Goto IndicatorSettings
    indicator:=!indicator
    Menu Indicator, % indicator ? "Check" : "Uncheck", 1&
    Return

#If !lang_key || (lang_key=1)
~!Shift::
#If (lang_key=2)
~^Shift::
#If
~#Space::
    lang_before:=InputLayout()
    KeyWait Shift, T1
    KeyWait LWin, T1
    Sleep 50
    If (InputLayout()=lang_before)
        Return
    SetTimer LangNote, -50
    ih.Stop(), lang_old:=lang_in_old:=lang_fl_old:=caps_old:=caps_in_old:=""
    Return

#If OnFlag(FlagHwnd)
^+MButton::
    ttip1:=!ttip1
    If !ttip1
        Goto ToolTip
    Return

#MButton::
    ttip2:=!ttip2
    If !ttip1 {
        ToolTip,,,, 16
    }
    Return

*LButton::
*RButton::
*MButton::Return

#If OnFlag(IndHwnd) && lang_switcher
LButton::
    Send {LButton up}
    SetInputLayout(key_switch)
    SetTimer LangNote, -50
    ih.Stop()
    Return

RButton::
    Send {RButton up}
    curr_lang:=InputLayout()
    Loop % lang_count
        If (curr_lang=lang_array[A_Index, 1]) {
            ln:=A_Index
            Break
        }
    target:=(ln>1) ? lang_array[ln-1, 1] : lang_array[lang_count, 1]
    SetInputLayout(key_switch, target)
    SetTimer LangNote, -50
    ih.Stop()
    Return

*LButton::
*RButton::
*MButton::Return
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
    SetInputLayout(key_switch)
    SetTimer LangNote, -5
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
    WinSet, TransColor, % "3A3B3C " transp*255//100, ahk_id %FlagHwnd%
    If !WinActive("ahk_id" Gui2 )
        MouseMove % x+width//2, % y+width*3//8
    Return

+WheelDown::
    If (width>12)
        width-=2, mess:="Размер`n" width "x" width*3//4 " px"
    Goto Pos

!WheelUp::
    If (transp>25)
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
    SetTimer Flag, Off
    MouseGetPos, x0, y0
    WinGetPos xc, yc,,, ahk_id %FlagHwnd%
    xc-=x0, yc-=y0
    While GetKeyState("Lbutton", "P") {
        sleep 10
        MouseGetPos, xn, yn
        WinMove, ahk_id %FlagHwnd%,, xc+xn, yc+yn
    }
    DX+=xn-x0, DY+=yn-y0, mess:="Положение`nx=" DX ", y=" DY
    SetTimer Flag, On
    Goto Pos
#If

CheckMonitorPos(x, y) {
    SysGet monCount, MonitorCount
    Loop % monCount {
        SysGet wa, Monitor, % A_Index
        If (x>=waLeft) && (x<=waRight) && (y>=waTop) && (y<=waBottom)
            Return % A_Index
    }
}

LangNote:
    If !note || IsFullScreen()
        Return
    SetTimer LangNoteDestroy, % text_convert ? -800 : note_duration
    Loop % lang_array.Length()
    If (InputLayout()=lang_array[A_Index, 1]) {
        pNote:=lang_array[A_Index, 8]
        Break
    }
    nw:=A_ScreenWidth*note_size//100, nh:=nw*3//4
    pLnote:=Gdip_CreateBitmap(nw, nh)
    N:=Gdip_GraphicsFromImage(pLnote)
    Gdip_SetSmoothingMode(N, 4)
    Gdip_SetInterpolationMode(N, 7)
    Gdip_DrawImage(N, pNote, 0, 0, nw, nh)
    NoteHandle:=Gdip_CreateHBITMAPFromBitmap(pLnote)
    If WinExist("ahk_id" Lnote) {
        Gui 20:Default
        GuiControl,, % Lncode, *w%nw% *h%nh% hbitmap:*%NoteHandle%
        Return
    }
    Gui 20:Destroy
    Gui 20:-DPIScale +AlwaysOnTop +ToolWindow -Caption +LastFound +HwndLnote +E0x20
    Gui 20:Add, Picture, x0 y0 w%nw% h%nh% +HwndLncode, hbitmap:*%NoteHandle%
    Gui 20:Color, 2A2B2C
    WinSet TransColor, % "2A2B2C " note_transp*255//100
    WinSet Style, -0xC40000
    Gui 20:Show, NA w%nw% h%nh%
    Gdip_DisposeImage(pLnote)
    Gdip_DeleteGraphics(N)
    Return

LangNoteDestroy:
    Gui 20:Destroy
    Return

FlagGui:
    Gui Destroy
    Gui -DPIScale +AlwaysOnTop +ToolWindow -Caption +LastFound +HwndFlagHwnd
    Gui Add, Picture, x0 y0 w96 h128 +HwndCapsID
    Gui Add, Picture, x0 y0 w96 h128 +HwndFlagID
    Gui Add, Picture, x0 y0 w96 h128 +HwndAutocorrectID AltSubmit BackGroundTrans gReturn
    WinSet Style, -0xC40000
    Gui Color, 3A3B3C
    WinSet TransColor, % "3A3B3C " transp*255//100
    Return

IndicatorGui:
    Gui 11:Destroy
    click_transparent:=lang_switcher ? "" : "+E0x20"
    Gui 11:-DPIScale +AlwaysOnTop +ToolWindow -Caption +LastFound +HwndIndHwnd %click_transparent%
    Gui 11:Add, Picture, x0 y0 w256 h256 +HwndIndCapsID
    Gui 11:Add, Picture, x0 y0 w256 h256 +HwndIndID
    Gui 11:Add, Picture, x0 y0 w256 h256 +HwndIndAutocorrectID AltSubmit BackGroundTrans
    WinSet Style, -0xC40000
    Gui 11:Color, 3D3E3F
    WinSet TransColor, % "3D3E3F " transp_in*255//100
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
    ;ToolTip % OnFlag(FlagHwnd) "/" OnFlag(IndHwnd), 0, 0, 20
    If !pToken
        pToken:=Gdip_Startup()
    If ttip1 {
        ToolTip % hkey "/" button "`n" A_TimeSinceThisHotkey-A_TimeSincePriorHotkey " мс`n" A_ThisHotkey "`n" A_PriorHotkey, 200, 0, 11
        ToolTip % "strl/ksl/dkc: " str_length "/" ks.Length() "/" deadkey_count "`nt_con: " text_convert "  m_con: " manual_convert "`no_orig: " (IsObject(out) ? out.Length() : StrLen(out)) " sl:" send_length "`nsel_length: " sel_length "`nbs_count/ksl: " bs_count "/" ks.Length() "`nnew_lang:" new_lang "`nmouse_click:" mouse_click "`nlast_space: " last_space "`nrev: " reverse, 400, 0, 12
        If !ttip
            Tooltip % il " " t0 "  " t1 " (ls: " last_space " es: " end_symb " kp: " key_prev ")`n" alt_lang " " t0_alt "  " t2, 600, 0, 13
        Else
            ToolTip ,,,,13
        ;ToolTip % ih.EndReason " " ih.EndKey " " ((ih.EndReason="Stopped") ? stop : ""), 900, 0, 14
        ToolTip % ih.InProgress "/" ih.VisibleText "`n" bh.InProgress "/" bh.VisibleText , 1400, 0, 14
        ToolTip % an "`n" cln "`nfl: " flag "/" flag_state "`nind: " indicator "/" ind_state "`nac: " autocorrect "/" auto_state "`nss: " suspend_state, 1000, 0, 15 ; индикация правил
    }
    WinGetClass cl, A
    If (lang:=InputLayout()) && !(cl~="Shell_TrayWnd")
        last_lang_win:=WinExist("A")
    lang:=lang ? lang : lang_old
    If upd
        Goto Indicator
    Loop % lang_array.Length() {
        If (lang=lang_array[A_Index, 1]) {
            pFlag:=lang_array[A_Index, 4], clang:=A_Index
            Break
        }
    }
    num:=GetKeyState("NumLock","T"), scr:=GetKeyState("ScrollLock","T"), caps:=GetKeyState("CapsLock","T")
    If suspend_state
        Menu, Tray, Icon, % "HICON:" Base64PNG_to_HICON(icon1, 24, 24), 1, 1
    Else If (lang && (lang!=lang_old))||(num!=num_old)||(scr!=scr_old) || (autocorrect!=autocorrect_old) || (single_lang!=single_lang_old) {
        Gdip_GetImageDimensions(pFlag, wf, hf)
        icon_size:=24
        If A_OSVersion in WIN_XP,WIN_VISTA,WIN_7
            icon_size:=16
        pMem:=Gdip_CreateBitmap(icon_size, icon_size)
        T:=Gdip_GraphicsFromImage(pMem)
        Gdip_SetSmoothingMode(T, flag_sett ? smoothing : 2)
        Gdip_SetInterpolationMode(T, flag_sett ? scaling : 7)
        hf2:=!aspect ? icon_size*2//3 : ((aspect=1) ? icon_size*3//4 : icon_size*4//5)
        shift2:=(icon_size-hf2)//2
        If (num && numlock_icon && !numlock_on) || (scr && scrolllock_icon)
            shift2:=(icon_shift=0) ? (icon_size-hf2)//2 : ((icon_shift=1) ? icon_size-hf2 : 0)
        Gdip_DrawImage(T, pFlag, 0, shift2, icon_size, hf2, 0, 0,wf, hf)
        If numlock_icon &&((num && !numlock_on) || (!num && numlock_on)) {
            pNumLock_tray:=(scrolllock_icon && scrolllock) ? pNumLock : pNumScroll
            Gdip_DrawImage(T, pNumLock_tray, 0, 0, icon_size, icon_size)
        }
        If (scr && scrolllock_icon && scrolllock) {
            pScrollLock_tray:=numlock_icon ? pScrollLock : pNumScroll
            Gdip_DrawImage(T, pScrollLock_tray, 0, 0, icon_size, icon_size)
        }
        If autocorrect && !no_indicate
            Gdip_DrawImage(T, single_lang ? pSingleLang : pAutocorrect, Round(icon_size*.32), icon_size*.64, Round(icon_size*.36), Round(icon_size*.36))
        DeleteObject(IconHandle)
        IconHandle:=Gdip_CreateHICONFromBitmap(pMem)
        Sleep 5
        Menu Tray, Icon, hicon:%IconHandle%,, 1
        Gdip_DisposeImage(pMem)
        Gdip_DeleteGraphics(T)
        lang_old:=lang, num_old:=num, scr_old:=scr, autocorrect_old:=autocorrect, single_lang_old:=single_lang
    }

Cursors:     
    If cursor_hide || (flag_state=2) || !DllCall("User32\OpenInputDesktop", "int", 0*0, "int", 0*0,"int", 0x0001L*1) || IsFullScreen() {
        If cursor_type
            RestoreCursors()
        cursor_type:=""
        Sleep 10
        Goto CheckRules
    }
    If ((A_TickCount-cursor_time<300) || key_block) && (lang_cur_old=lang) && (A_Cursor=cursor_type)
        Goto CheckRules
    flag_w:=large_flag ? flag_width*1.25 : flag_width, flag_h:=large_flag ? flag_height*1.25 : flag_height, csize:=cursor_size
    If text_cursor && (A_Cursor="IBeam") && FileExist("cursors\cursor.png") {
        try {
            MouseGetPos xcur, ycur
            PixelGetColor bcolor1, xcur, ycur, RGB
            PixelGetColor bcolor2, xcur-10, ycur-10, RGB
            PixelGetColor bcolor3, xcur+10, ycur+10, RGB
            bbr:=((GetBrightness(bcolor1)+GetBrightness(bcolor2)+GetBrightness(bcolor3))/3<invert_threshold) ? 1 : 0
            pCursor:=Gdip_CreateBitmap(csize*3, csize*3)
            C:=Gdip_GraphicsFromImage(pCursor)
            Gdip_SetSmoothingMode(C, 2)
            Gdip_SetInterpolationMode(C, 7)
            If !pCursorDraft
                pCursorDraft:=Gdip_CreateBitmapFromFile("cursors\cursor.png")
            Gdip_DrawImage(C, pCursorDraft, csize, csize, csize, csize,"","","","", bbr ? GenerateColorMatrix(6) : "")
            mn:=(!no_border && !text_cursors) ? 1 : 0
            If mn
                Gdip_FillRectangle(C ,Brush, csize*(1.5+flag_x/32), csize*(1.5+flag_y/32), csize*flag_w/32, csize*flag_h/32)
            Gdip_DrawImage(C, pFlag, csize*(1.5+flag_x/32), csize*(1.5+flag_y/32), csize*flag_w/32, csize*flag_h/32)
            DeleteObject(CursorHandle)
            CursorHandle:=Gdip_CreateHICONFromBitmap(pCursor)
            DllCall("SetSystemCursor", Uint, CursorHandle, Int, 32513)
            Gdip_DisposeImage(pCursor)
            Gdip_DeleteGraphics(С)
            cursor_type:="IBeam", cursor_time:=A_TickCount, lang_cur_old:=lang
        }
    }
    If arrow_cursor && (A_Cursor="Arrow") && !WinActive("ahk_class ConsoleWindowClass") && FileExist("cursors\arrow.png") {
        try {
            pArrow:=Gdip_CreateBitmap(csize*3, csize*3)
            A:=Gdip_GraphicsFromImage(pArrow)
            Gdip_SetSmoothingMode(A, 2)
            Gdip_SetInterpolationMode(A, 7)
            If mn
                Gdip_FillRectangle(A , Brush, csize*(1.5+flag_x/32), csize*(1.5+flag_y/32), csize*flag_w/32, csize*flag_h/32)
            Gdip_DrawImage(A, pFlag, csize*(1.5+flag_x/32), csize*(1.5+flag_y/32), csize*flag_w/32, csize*flag_h/32)
            If !pArrowDraft
                pArrowDraft:=Gdip_CreateBitmapFromFile(color_arrow ? "cursors\color_arrow.png" : "cursors\arrow.png")
            matrix:="", a_color:="0x" arrow_color
            If invert_arrow
                matrix:=GenerateColorMatrix(6)
            If color_arrow && arrow_color
                matrix:=GenerateColorMatrix(1, 1, 0, 1, 1, (a_color >> 16 & 0xFF)/255-1, (a_color >> 8 & 0xFF)/255-1, (a_color & 0xFF)/255-1)
            Gdip_DrawImage(A, pArrowDraft, csize*1.5, csize*1.5, csize, csize,"","","","", matrix)
            DeleteObject(ArrowHandle)
            ArrowHandle:=Gdip_CreateHICONFromBitmap(pArrow)
            DllCall("SetSystemCursor", Uint, ArrowHandle, Int, 32512)
            Gdip_DisposeImage(pArrow)
            Gdip_DeleteGraphics(A)
            cursor_type:="Arrow", cursor_time:=A_TickCount, lang_cur_old:=lang
        }
    }

CheckRules:
    If ((win_curr:=WinExist("A"))!=win_last) {
        WinGet pn, ProcessName, ahk_id %win_curr%
        WinGetClass cl, ahk_id %win_curr%
        flag_state:=ind_state:=auto_state:=0, last_rule:=""
        Loop % apps.Length() {
            If WinExist("ahk_hwnd" Gui6) || !apps[A_Index, 1]
                Continue
            an:=(apps[A_Index, 2]="*.*") ? "" : RegExReplace(apps[A_Index, 2], "\*", "[\w -_]*"), cln:=RegExReplace(apps[A_Index, 3], "\*", "[\w -_]*"), an:=Backslash(an), cln:=Backslash(cln)

            If (an && (pn~="^" an "$") && (cl~="^" cln "$")) || (!an && (cl && (cl~="^" cln "$"))) {
                flag_state:=apps[A_Index, 5], ind_state:=apps[A_Index, 6], auto_state:=apps[A_Index, 7], suspend_state:=apps[A_Index, 8], last_rule:=A_Index
                Break
            }
        }
    }
    Suspend % suspend_state ? "On" : "Off"
    win_last:=win_curr
    If (cl~="(Shell_TrayWnd|WorkerW|Progman)") || (IsFullScreen() && !on_full_screen) || !WinExist("A") {
        Gui 11:Destroy
        Return
    }
    If WinExist("ahk_id" hwnd5)
        ind_state:=1

Indicator:
    If ((ind_state=1) || (indicator && ind_state!=2) || WinExist("ahk_id" hwnd5)) && !WinExist("ahk_class #32768") && !WinActive("ahk_class NotifyIconOverflowWindow") && !WinActive("ahk_class OpenShell.CMenuContainer") {
        SysGet MWM, MonitorWorkArea, % monitor
        SysGet MM, MonitorWorkArea, % monitor
        w_in:=width_in*MWMRight//100, h_in:=(file_aspect && !text_flags) ? w_in*hf//wf : w_in*3//4
        If window_snap && !WinExist("ahk_id" hwnd5) {
            WinGetPos xpos, ypos, wpos, hpos, A
            x_in:=xpos+dx_in*wpos/100-w_in//2-((dx_in>50) ? w_in*.1*MWMRight/wpos : 0),
            y_in:=ypos+dy_in*hpos/100-h_in//2-((dy_in>50) ? h_in*.1*MWMBottom/hpos : 0)
            x_in:=(x_in<xpos) ? xpos : x_in,
            y_in:=(y_in<ypos) ? ypos : y_in
            If (y_in>MWMBottom) && (y_in<MMBottom) {
                Gui 11:Hide
                Return
            }
            If (x_in!=x_in_old) || (y_in!=y_in_old) {
                Gui 11:Hide
                SetTimer IndicatorShow, -200
                ind_hide:=1
            }
            x_in_old:=x_in, y_in_old:=y_in
        }
        Else {
            x_in:=dx_in*MWMRight//100-w_in//2, y_in:=dy_in*MWMBottom//100-h_in//2
            monitor:=CheckMonitorPos(x_in+w_in//2, y_in+h_in//2)
            If !monitor
                dx_in:=50, dy_in:=97      
        }
        If !(x_in && y_in)
            Return
        If !ind_hide && (upd || !WinExist("ahk_id" IndHwnd) || (lang && (lang!=lang_in_old)) || (num!=num_in_old) || (scr!=scr_in_old) || (caps!=caps_in_old) || (autocorrect!=autocorrect_in_old) || (single_lang!=single_lang_in_old)) {
            mn:=(!no_border && !text_flags) ? ((w_in>60) ? 2 : 1) : 0 ; Величина полей
            pBitmap:=Gdip_CreateBitmap(w_in, w_in)
            I:=Gdip_GraphicsFromImage(pBitmap)
            Gdip_SetSmoothingMode(I, 4)
            Gdip_SetInterpolationMode(I, 7)
            If mn && !text_flags && FileExist(lang_array[clang, 3])
                Gdip_FillRectangle(I ,Brush, 0, w_in-h_in, w_in, h_in)
            Gdip_DrawImage(I, pFlag, mn, w_in-h_in+mn, w_in-mn*2, h_in-mn*2, 0, 0, wf, hf)
            If numlock_icon_in &&((num && !numlock_on) || (!num && numlock_on)) {
                pNumLock_in:=(scrolllock_icon_in && scrolllock) ? pNumLock : pNumScroll
                Gdip_DrawImage(I, pNumLock_in, 0, 0, w_in, w_in)
            }
            If (scr && scrolllock_icon_in && scrolllock) {
                pScrollLock_in:=numlock_icon_in ? pScrollLock : pNumScroll
                Gdip_DrawImage(I, pScrollLock_in, 0, 0, w_in, w_in)
            }
            WinSet, TransColor, % "3D3E3F " transp_in*255//100, ahk_id %IndHwnd%
            DeleteObject(IndicatorHandle)
            IndicatorHandle:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
            Gdip_DisposeImage(pBitmap)
            Gdip_DeleteGraphics(I)
            Gui 11:Default
            GuiControl,, %IndID%, *w%w_in% *h-1 hbitmap:*%IndicatorHandle%
            Gui 11:Show, x%x_in% y%y_in% NA
            WinSet Top,, ahk_id %IndHwnd%
            If autocorrect && !no_indicate {
                au_h1:=Round(w_in/3), AinHandle:=single_lang ? SingleLangHandle : AutocorrectHandle
                GuiControl,, % IndAutocorrectID, *w%au_h1% *h%au_h1% hbitmap:*%AinHandle%
                GuiControl Move, % IndAutocorrectID, % "x" Round(w_in/3)+1 "y" Round(w_in*.78)
                GuiControl Show, % IndAutocorrectID
            }
            Else
                GuiControl Hide, % IndAutocorrectID
            If caps {
                GuiControl,, %IndCapsID%, *w%w_in% *h%h_in% hbitmap:*%CapsHandle%
                GuiControl Move, % IndCapsID, % "x" w_in//5 "y" w_in-h_in+w_in//5
                GuiControl Show, % IndCapsID
            }
            Else
                GuiControl Hide, % IndCapsID
            If !WinExist("ahk_id" IndHwnd)
                Gosub IndicatorGui
            lang_in_old:=lang, width_in_old:=width_in, caps_in_old:=caps, num_in_old:=num, scr_in_old:=scr, upd:=0, autocorrect_in_old:=autocorrect, single_lang_in_old:=single_lang
        }
    }
    Else If !WinExist("ahk_id" hwnd5)
        Gui 11:Hide
    Return

Backslash(t) {
    RegExMatch(t, "^(.+)(\.)?(\w+)?$", n)
    Loop Parse, n1
        If A_LoopField in  .,+,(,),$
            out.="\" A_LoopField
        Else
            out.=A_LoopField
    Return out . (n3 ? "." n3 : "")
}

IndicatorShow:
    ind_hide:=0, upd:=1
    Return

IsFullScreen(win="A") {
	SysGet, M, Monitor
	WinGetPos, , , w, h, % win
	return (w>=MRight && h>=MBottom) ? 1 : 0
}

GetBrightness(c) {
	r := (c & 0xFF0000) >> 16
	g := (c & 0x00FF00) >> 8
	b := c & 0x0000FF
	return Sqrt(0.241 * r ** 2 + 0.691 * g ** 2 + 0.068 * b ** 2)
}

CursorOff:
    cursor_hide:=1
    Return

Flag:
    WinGetClass cl, A
    If cl not in Shell_TrayWnd
        lastwin:=WinExist("A")
    If lastwin && (lastwin!=lastwin_old) && !WinActive("ahk_id" Hwnd3) && !WinActive("ahk_id" Hwnd5) {
        ih.Stop(), stop:="NewWindow", RestoreCursors()
        If on_new_window {
            cursor_hide:=0
            SetTimer CursorOff, % -1000*cursor_show
        }
        SetTimer Flag, Off
        SetTimer TrayIcon, Off
        Gui Destroy
        Gui 11:Destroy
        lang_old:=lang_in_old:=lang_fl_old:=text_convert:=manual_convert:="", x_in_old:=y_in_old:=0, upd:=1
        bs_count:=deadkey_count:=0, out:=[]
        Sleep 50
        SetTimer TrayIcon, On
        SetTimer Flag, On
    }
    If !(il_fl:=lang) {
        Gui Hide
        Return
    }
    Loop % lang_array.Length() {
        If (il_fl=lang_array[A_Index, 1]) {
            pFlag2:=lang_array[A_Index, 4]
            Break
        }
    }
    GetCaretLocation(_x, _y), x:=_x+DX, y:=_y+DY
    If wheel && ((_x!=x_wheel) || (_y!=y_wheel))
        wheel:=0
        
    If ((flag_state=1) || (flag && flag_state!=2)) && _x && _y && !wheel && !IsFullScreen() && !WinExist("ahk_class #32768") {
        If ((il_fl_old!=il_fl) || (width!=width_old) || !WinExist("ahk_id" FlagHwnd)) {
            fl_h:=(file_aspect && !text_flags) ? width*hf//wf : width*3//4,
            mn:=(!no_border && !text_flags) ? 1 : 0
            pBanner:=Gdip_CreateBitmap(width, fl_h)
            F:=Gdip_GraphicsFromImage(pBanner)
            Gdip_SetSmoothingMode(F, smoothing)
            Gdip_SetInterpolationMode(F, scaling)
            If mn && FileExist(lang_array[clang, 3])
                Gdip_FillRectangle(F ,Brush, 0, 0, width, fl_h)
            Gdip_DrawImage(F, pFlag2, 0, 0, width, fl_h)
            DeleteObject(FlagHandle)
            FlagHandle:=Gdip_CreateHBITMAPFromBitmap(pBanner)
            Gdip_DisposeImage(pBanner)
            Gdip_DeleteGraphics(F)
            Sleep 5
            Gui Default
            GuiControl,, %FlagID%, *w%width% *h%fl_h% hbitmap:*%FlagHandle%
            il_fl_old:=il_fl
        }
        WinSet, TransColor, % "3A3B3C " transp*255//100, ahk_id %FlagHwnd%
        Gui Default
        GuiControlGet caps_vis, Visible, % CapsID
        GuiControlGet au_vis, Visible, % AutocorrectID
        If (autocorrect && !au_vis && !no_indicate) || (single_lang_fl_old!=single_lang) || (width!=width_old) {
            au_h:=Round(width*.4), Afl:=single_lang ? SingleLangHandle : AutocorrectHandle
            GuiControl,, % AutocorrectID, *w%au_h% *h%au_h% hbitmap:*%Afl%
            GuiControl Move, % AutocorrectID, % "x" Round(width*.3) "y" Round(fl_h*.7)
            GuiControl Show, % AutocorrectID
        }
        If !autocorrect || no_indicate
            GuiControl Hide, % AutocorrectID

        If (caps && !caps_vis) || (width!=width_old) {
            GuiControl,, % CapsID, *w%width% *h%fl_h% hbitmap:*%CapsHandle%
            GuiControl Move, % CapsID, % "x" width//5 "y" width//5
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
        Gui Hide
    lastwin_old:=lastwin, cls_old:=GetKeyState("CapsLock", "P") ? cls_old : GetKeyState("CapsLock", "T")
    Return

LayoutsAndFlags:
    If A_ThisMenuItem || 3apply {
        SetTimer TrayIcon, Off
        SetTimer Flag, Off
        Sleep 200
        RestoreCursors()
    }
    Gui 3:Destroy
    Gui 3:+LastFound -MinimizeBox +hWndHwnd3
    Gui 3:Default
    Gui 3:Margin, 12
    Gui 3:Color, 6DA0B8
    Gui 3:Font, Arial s9
    Gui 3:Add, ListView, w424 -Multi Grid R4 -LV0x10 HwndHLV gSetColor Checked NoSort ReadOnly AltSubmit, N|Раскладка|Имя|Hex|Флажок|Есть?|Словарь
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
        RegRead subst, HKEY_CURRENT_USER\Keyboard Layout\Substitutes, % kl
        reg_name:=subst ? subst : kl
        RegRead lang_name, HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Keyboard Layouts\%reg_name%, Layout Text
        lang_name:=lang_name ? lang_name : "???", lhex:="0x" SubStr(kl, -3)
        lcode:=LangCode(lhex), lt:="?"
        If lcode {
            cfl:=StrSplit(lcode, "-"), lt:=cfl[cfl.Length()],
            If lt in Cyrl,Latn,Arab,tradnl
                lt:=cfl[1]
        }
        lt:=SubStr(lt, 1, 2),
        lcode:=lcode ? lcode : lhex, kl_flag:="flags\" lcode ".png"
        IniRead a_%lhex%, % cfg, Aliases, A_%lhex%, % " "
        lt:=a_%lhex% ? a_%lhex% : lt
        IniRead c_%lhex%, % cfg, Colors, C_%lhex%, % " "
        If !c_%lhex%
            c_%lhex%:=Format("{:.6X}", default_colors[A_Index])
        pFlag:=pNotif:=Gdip_CreateBitmap(68, 50)
        T:=Gdip_GraphicsFromImage(pFlag)
        Gdip_SetSmoothingMode(I, 4)
        Gdip_SetInterpolationMode(I, 2)
        Brush:=Gdip_CreateLineBrushFromRect(0, 0, 12, 50, "0xff" Brightness(c_%lhex%, gradient), "0xff" c_%lhex%)
        Gdip_FillRoundedRectangle(T, Brush, 0, 0, 64, 48, _radius)
        Gdip_DeleteBrush(Brush)
        Options=x-8 y-2 Center vCenter %_bold% cff%font_color% r4 s%font_size%
        Gdip_TextToGraphics(T, lt, Options, "Arial", 80, 60)
        Handle:=Gdip_CreateHICONFromBitmap(pFlag)
        Gdip_DeleteGraphics(T)
        If FileExist(kl_flag) && !text_flags
            pFlag:=Gdip_CreateBitmapFromFile(kl_flag)

        lang_array.Push([lhex, lang_name, kl_flag, pFlag, lcode, c_%lhex%, ((lhex~=cycl_langs) || !cycl_langs) ? 1 : 0, pNotif, lt])
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
        LV_Add("Icon" A_Index " " (((lhex~=cycl_langs) || !cycl_langs) ? "Check" : ""), " " row, lang_name, lt, lhex, lcode ".png", FileExist("flags\" lcode ".png") ? "Да" : "Нет")
    }
    If lshift not in % lang_index
        lshift:=0
    If rshift not in % lang_index
        rshift:=0
    If lctrl not in % lang_index
        lctrl:=0
    If rctrl not in % lang_index
        rctrl:=0
    lang_menu:="Выкл.|Перекл. +|Перекл. -", lshift_ind:=rshift_ind:=lctrl_ind:=rctrl_ind:="", lang_menu_single:="", lang_menu_s:=[], lang_menu_h:=""
    Loop % lang_array.Length() {
        lang_menu.="|" lang_array[A_Index, 2],
        fsize:=Format("{:0.2f}", FolderSize("dict\" lang_array[A_Index, 5])/1000000)
        If FileExist("dict\" lang_array[A_Index, 5]) && fsize {
            LV_Modify(A_Index,,,,,,,, fsize " MB")
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
    lang_count:=row, lang_set:="Выключено|Цикл вперед|Цикл назад|", lc_count:=0,

    pause_kl:=(pause_langs=2) ? 3 : ((pause_langs=1) ? 2 : 1),
    shift_bs_kl:=(shift_bs_langs=2) ? 3 : ((shift_bs_langs=1) ? 2 : 1),
    ctrl_capslock_kl:=(ctrl_capslock_langs=2) ? 3 : ((ctrl_capslock_langs=1) ? 2 : 1),

    lang_list:=[0, 0, 0], lang_menu_single:=RegExReplace(lang_menu_single, "\|$"), lang_set_auto:="", lang_list_auto:=[]
    Loop % lang_count-1
    {
        lc:=A_Index
        Loop % (lang_count-lc) {
            lang_set.=lc "/" lc+A_Index " (" SubStr(lang_array[lc,2], 1, 20) "/" SubStr(lang_array[lc+A_Index,2], 1, 12)  ")|"
            lang_list.Push([lang_array[lc,1], lang_array[lc+A_Index,1]])
            lc_count++

            If FileExist("dict\" lang_array[lc, 5]) && FileExist("dict\" lang_array[lc+A_Index, 5]) && FolderSize("dict\" lang_array[lc, 5]) && FolderSize("dict\" lang_array[lc+A_Index, 5]) {
                lang_set_auto.=lc "/" lc+A_Index " (" SubStr(lang_array[lc,2], 1, 20) "/"lang_array[lc+A_Index,2]  ")|"
                lang_list_auto.Push([lang_array[lc,1], lang_array[lc+A_Index,1]])
            }

            If pause_langs && (lang_array[lc,1]~=pause_langs) && (lang_array[lc+A_Index,1]~=pause_langs)
                pause_kl:=lc_count+3
            If shift_bs_langs && (lang_array[lc,1]~=shift_bs_langs) && (lang_array[lc+A_Index,1]~=shift_bs_langs)
                shift_bs_kl:=lc_count+3
            If ctrl_capslock_langs && (lang_array[lc,1]~=ctrl_capslock_langs) && (lang_array[lc+A_Index,1]~=ctrl_capslock_langs)
                ctrl_capslock_kl:=lc_count+3
        }
    }
    lang_set_auto:=RegExReplace(lang_set_auto, "\|$")

    Loop % lang_list_auto.Length()
        If (lang_list_auto[A_Index,1]~=lang_auto) && (lang_list_auto[A_Index,2]~=lang_auto)
            lang_auto_sel:=A_Index
    Loop % lang_menu_s.Length()
        If (lang_menu_s[A_Index]=lang_auto_single)
            lang_auto_single_sel:=A_Index

    cycl_l:=cycl_langs, cycl_langs:=""
    Loop % lang_array.Length()
        If (lang_array[A_Index, 7] || !cycl_l)
            cycl_langs.=lang_array[A_Index, 1] "|"
    cycl_langs:=RegExReplace(cycl_langs, "\|$")
    If InStr(cycl_langs, "|")
        cycl_langs:="(" cycl_langs ")"

    If !A_ThisMenuItem && !3apply
        Return
    3apply:=0,
    LV_ModifyCol(1, "AutoHdr Center"),
    LV_ModifyCol(2, "96"),
    LV_ModifyCol(3, "34"),
    LV_ModifyCol(4, "50")
    LV_ModifyCol(5, "74"),
    LV_ModifyCol(6, "46"),
    LV_ModifyCol(7, "AutoHdr")
    Gui 3:Add, Checkbox, x32 vtext_flags, Использовать текстовые флажки для индикации раскладки
    Gui 3:Add, GroupBox, x12 w424 h156, Переключение раскладки (N - номер раскладки)

    Gui 3:Add, Radio, x32 yp+20 vrb1, Левый Ctrl+N
    Gui 3:Add, Radio, x+8 yp vrb2, Левый Alt+N
    Gui 3:Add, Radio, x+8 yp vrb3, Левый Win+N
    Gui 3:Add, Radio, x+8 yp vrb4, Выкл.

    Gui 3:Add, Text, x32 yp+24, Левый Shift:
    Gui 3:Add, DropDownList, vlshift_ind  x112 yp-4 w100 Choose%lshift_ind% AltSubmit, % lang_menu
    Gui 3:Add, Text, x240 yp+4, Правый Shift:
    Gui 3:Add, DropDownList, vrshift_ind  x316 yp-4 w100 Choose%rshift_ind% AltSubmit, % lang_menu

    Gui 3:Add, Text, x32 yp+28, Левый Ctrl:
    Gui 3:Add, DropDownList, vlctrl_ind  x112 yp-4 w100 Choose%lctrl_ind% AltSubmit, % lang_menu
    Gui 3:Add, Text, x240 yp+4, Правый Ctrl:
    Gui 3:Add, DropDownList, vrctrl_ind  x316 yp-4 w100 Choose%rctrl_ind% AltSubmit, % lang_menu

    Gui 3:Add, Text, x32 yp+28, Нажатия:
    Gui 3:Add, Radio, x+6 yp vdb1, Простые
    Gui 3:Add, Radio, x+6 yp vdb2, Короткие
    Gui 3:Add, Radio, x+6 yp vdb3, Долгие
    Gui 3:Add, Radio, x+6 yp vdb4, Двойные

    Gui 3:Add, CheckBox, x32 yp+20 vkey_switch, Использовать имитацию клавишного переключения раскладки
    Gui 3:Add, CheckBox, x32 yp+20 vnote, Уведомления
    Gui 3:Add, DropDownList, vnote_size x+4 yp-4 w40 Choose%note_size%, 5|6|7|8|9|10
    Gui 3:Add, Text, x+6 yp+4, Ширина (`%)
    Gui 3:Add, DropDownList, v_note_transp x+12 yp-4 w54 Choose%note_transp%, 0|10|20|30|40|50
    Gui 3:Add, Text, x+6 yp+4, Прозрачность (`%)
    Gui 3:Add, GroupBox, x12 y+16 w424 h92, Ручное исправление раскладки`n (цикл - чекбоксы списка раскладок)
    Gui 3:Add, Text, x36 yp+20, Pause, CapsLock и флажок:
    Gui 3:Add, DropDownList, vpause_kl Choose%pause_kl% AltSubmit x256 yp-4 w160, % lang_set
    Gui 3:Add, Text, x36 yp+28, Сочетание Shift+Backspace:
    Gui 3:Add, DropDownList, vshift_bs_kl Choose%shift_bs_kl% AltSubmit x256 yp-4 w160, % lang_set
    Gui 3:Add, Text, x36 yp+28, Сочетание Ctrl+CapsLock:
    Gui 3:Add, DropDownList, vctrl_capslock_kl Choose%ctrl_capslock_kl% AltSubmit x256 yp-4 w160, % lang_set

    Gui 3:Add, GroupBox, x12 y+16 w424 h44, Работа с множеством раскладок (+ правые Ctrl или Shift)
    Gui 3:Add, Checkbox, x32 yp+20 vdigit_keys, Цифровые клавиши
    Gui 3:Add, Checkbox, x+24 yp0 vf_keys, % "Функциональные клавиши (F*)"
    Gui 3:Font, s9, Arial
    Gui 3:Add, Button, x24 y+16 w76 gFlagsFolder, Флажки
    Gui 3:Add, Button, x+4 yp wp hp gControlPanel, Языки (ПУ)
    Gui 3:Add, Button, x+4 yp wp hp g3Apply, Обновить
    Gui 3:Add, Button, x+4 yp wp hp g3GuiClose, Cancel
    Gui 3:Add, Button, x+4 yp wp hp g3Save, OK
    GuiControl,, text_flags, % text_flags
    GuiControl,, rb%lang_select%, 1
    GuiControl,, db%key_press%, 1
    GuiControl,, double_click, % double_click
    GuiControl,, ctrl_capslock, % ctrl_capslock
    GuiControl,, key_switch, % key_switch
    GuiControl,, note, % note
    GuiControl,, digit_keys, % digit_keys
    GuiControl,, f_keys, % f_keys
    GuiControl, ChooseString, note_size, % note_size ""
    _note_transp:=100-note_transp
    GuiControl, ChooseString, _note_transp, % _note_transp ""
    Gui 3:Show,, Раскладки и флажки
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

3Apply:
    3apply:=1
    Gui 3:Submit
    SetTimer TrayIcon, On
    SetTimer Flag, On
    Goto LayoutsAndFlags

3Save:
    Gui 3:Submit, Nohide
    note_transp:=100-_note_transp
    lcycl:=""
    Loop % LV_GetCount()
        lcycl.=(LV_GetNext(A_Index-1, "C")=A_Index) ? lang_array[A_Index, 1] "|" : ""
    cycl_langs:="(" RegExReplace(lcycl, "\|$") ")"
    Gui 3:Destroy
    Loop 4
        If rb%A_Index%
            lang_select:=A_Index
    Loop 4
        If db%A_Index%
            key_press:=A_Index

    lshift:=(lshift_ind>3) ? lang_array[lshift_ind-3, 1] : lshift_ind-1
    rshift:=(rshift_ind>3) ? lang_array[rshift_ind-3, 1] : rshift_ind-1
    lctrl:=(lctrl_ind>3) ? lang_array[lctrl_ind-3, 1] : lctrl_ind-1
    rctrl:=(rctrl_ind>3) ? lang_array[rctrl_ind-3, 1] : rctrl_ind-1

    If (pause_kl=2)
        pause_langs:=1
    Else If (pause_kl=3)
        pause_langs:=2
    Else
        pause_langs:=(pause_kl>3) ? "(" lang_list[pause_kl,1] "|" lang_list[pause_kl, 2] ")" : ""
    If (shift_bs_kl=2)
        shift_bs_langs:=1
    Else If (shift_bs_kl=3)
        shift_bs_langs:=2
    Else
        shift_bs_langs:=(shift_bs_kl>3) ? "(" lang_list[shift_bs_kl,1] "|" lang_list[shift_bs_kl, 2] ")" : ""

    If (ctrl_capslock_kl=2)
        ctrl_capslock_langs:=1
    Else If (ctrl_capslock_kl=3)
        ctrl_capslock_langs:=2
    Else
        ctrl_capslock_langs:=(ctrl_capslock_kl>3) ? "(" lang_list[ctrl_capslock_kl,1] "|" lang_list[ctrl_capslock_kl, 2] ")" : ""
    Goto Apply

3GuiClose:
    Gui 3:Destroy
    Goto Apply

#If WinActive("ahk_id" Hwnd3)
Enter::
NumpadEnter::
    Gui 3:Default
    ControlGetFocus cfocus
    If (cfocus="SysListView321") {
        fr:=LV_GetNext(, "F")
        lang_array[fr, 6]:=ChooseColor("0x" lang_array[fr, 6], default_colors, Hwnd3)
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
        lang_array[A_EventInfo, 6]:=ChooseColor("0x" lang_array[A_EventInfo, 6], default_colors, Hwnd3)
        Goto Settings
    }
    If (A_GuiEvent="RightClick") && A_EventInfo && (A_EventInfo=LV_GetNext(A_EventInfo-1)) {
        dnf:=A_EventInfo
        Menu LayoutMenu, Show
    }
    Return

SetColor2:
    lang_array[dnf, 6]:=ChooseColor("0x" lang_array[dnf, 6], default_colors, Hwnd3)
    Goto Settings
    Return


OpenDictFolder:
    dfolder:="dict\" lang_array[dnf, 5]
    FileCreateDir % dfolder
    Run explore %dfolder%
    Return

CopyFlagName:
    Clipboard:=lang_array[dnf, 5] ".png"
    ToolTip Скопировано
    SetTimer ToolTip, -1000
    Return

Rename:
    Gui 3:Default
    LV_GetText(ln, dnf, 3)
    InputBox ln, LangBar++, Введите новое сокращение раскладки (учитываются первые два символа`, пустая строка - сброс значений по умолчанию),, 400, 140,,,,, % ln
    If ErrorLevel
        Return
    ln:=SubStr(ln, 1, 2), _hex:=lang_array[dnf, 1]
    LV_Modify(dnf,,,, ln)
    If !ln || (ln~="^\s+$")
        IniDelete % cfg, Aliases, A_%_hex%
    Else
        IniWrite % """" ln """", % cfg, Aliases, A_%_hex%
    Return

FlagSettings:
    Gui 2:Destroy
    Gui 2:+AlwaysOnTop +ToolWindow +LastFound +HwndGui2
    Gui 2:Font, s12
    Gui 2:Color, 6DA0B8
    Gui 2:Add, Edit, w250 r3 -VScroll, % comment
    Gui 2:Font, s9
    Gui 2:Add, Button,y+6 w80 section g+WheelDown, Размер -
    Gui 2:Add, Button, wp hp x+4 yp g_Up, Вверх
    Gui 2:Add, Button, wp hp x+4 yp g+WheelUp, Размер +

    Gui 2:Add, Button, wp hp xs y+4 g_Left, Влево
    Gui 2:Add, Button, wp hp x+4 yp g+Mbutton, Сброс
    Gui 2:Add, Button, wp hp x+4 yp g_Right, Вправо

    Gui 2:Add, Button, wp hp xs y+4 g!WheelDown, Прозр-ть -
    Gui 2:Add, Button, wp hp x+4 yp g_Down, Вниз
    Gui 2:Add, Button, wp hp x+4 yp g!WheelUp, Прозр-ть +

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
    SysGet monitors, MonitorCount
    Menu Indicator, % indicator ? "Check" : "Uncheck", 1&
    Gui 5:Destroy
    Gui 5:+AlwaysOnTop +ToolWindow +LastFound +Hwndhwnd5
    Gui 5:Color, 6DA0B8
    Gui 5:Font, s9
    Gui 5:Add, Button, w80 section g^Left, Размер -
    Gui 5:Add, Button, wp hp x+4 yp gUp, Вверх
    Gui 5:Add, Button, wp hp x+4 yp g^Right, Размер +

    Gui 5:Add, Button, wp hp xs y+4 gLeft, Влево
    Gui 5:Add, Button, wp hp x+4 yp gSpace, Сброс
    Gui 5:Add, Button, wp hp x+4 yp gRight, Вправо

    Gui 5:Add, Button, wp hp xs y+4 g^Down, Прозр-ть -
    Gui 5:Add, Button, wp hp x+4 yp gDown, Вниз
    Gui 5:Add, Button, wp hp x+4 yp g^Up, Прозр-ть +
    Gui 5:Font, s7
    Gui 5:Add, StatusBar
    Gui 5:Show, % "x" A_ScreenWidth//2+50, Настройка индикатора
    Gosub StatusBar
    Return

StatusBar:
    Gui 5:Default
    SB_SetParts(94, 84)
    SB_SetText("`tX " dx_in " %  Y " dy_in " %`t", 1, 2)
    SB_SetText("`tШирина " width_in " %`t", 2, 2)
    SB_SetText("`tПрозр-ть " 100-transp_in " %`t", 3, 2)
    Return

5GuiClose:
    Gui 5:Destroy
    If (dx_in>0) && (dx_in<A_ScreenWidth) && (dy_in>0) && (dy_in<A_ScreenHeight)
        dx_in_1:=dx_in, dy_in_1:=dy_in
    Else
        dx_in_2:=dx_in, dy_in_2:=dy_in
    Gosub Settings
    Return

#If WinActive("ahk_id" hwnd5)
Esc::Goto 5GuiClose

~LButton::
    MouseGetPos,,, win, ctrl
    If (win=hwnd5) && (ctrl~="Button") {
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

#If WinExist("ahk_id" hwnd5)
Right::
    Critical
    SetFormat float, 0.2
    While GetKeyState("LButton", "P") || GetKeyState("Right", "P") {
        dx_in:=((dx_in<99.5) || (monitors>1)) ? dx_in+((A_Index>3) ? 0.3 : 0.1) : dx_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 150
    }
Return

Left::
    Critical
    SetFormat float, 0.2
    While GetKeyState("LButton", "P") || GetKeyState("Left", "P") {
        dx_in:=((dx_in>0.5) || (monitors>1)) ? dx_in-((A_Index>3) ? 0.3 : 0.1) : dx_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 150
    }
    Return

Up::
    Critical
    SetFormat float, 0.2
    While GetKeyState("LButton", "P") || GetKeyState("Up", "P") {
        dy_in:=((dy_in>.5)  || (monitors>1)) ? dy_in-((A_Index>3) ? 0.3 : 0.1) : dy_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 150
    }
    Return

Down::
    Critical
    SetFormat float, 0.2
    While GetKeyState("LButton", "P") || GetKeyState("Down", "P") {
        dy_in:=((dy_in<98.5) || (monitors>1)) ? dy_in+((A_Index>3) ? 0.3 : 0.1) : dy_in, upd:=1
        Gosub Indicator
        Gosub StatusBar
        Sleep % (A_Index>3) ? 20 : 150
    }
    Return

^Right::
    SetFormat float, 0.2
    While GetKeyState("LButton", "P") || GetKeyState("Right", "P") {
        If (width_in<10)
            width_in+=0.1, upd:=1
        Gosub StatusBar
        Sleep 200
    }
    Return

^Left::
    SetFormat float, 0.2
    While GetKeyState("LButton", "P") || GetKeyState("Left", "P") {
        If (width_in>1)
            width_in-=0.1, upd:=1
        Gosub StatusBar
        Sleep 200
    }
    Return

^Up::
    If (transp_in>44)
        transp_in-=5, upd:=1
    Goto StatusBar

^Down::
    If (transp_in<96)
        transp_in+=5, upd:=1
    Goto StatusBar

Space::
    width_in:=2, dx_in:=50, dy_in:=1.0, transp_in:=90, upd:=1
    Goto StatusBar
#If

; Правила приложений
AppRules:
    Gui 6:Destroy
    Gui 6:+AlwaysOnTop +ToolWindow +LastFound +HwndGui6
    Gui 6:Default
    Gui 6:Font, s9
    If Base64PNG_to_HICON(icon7)
        Gui 6:Add, Picture, x20 w24 h-1 gDetect, % "HICON:" Base64PNG_to_HICON(icon7)
    Else
        Gui 6:Add, Picture, x20 w24 h-1 Icon2 gDetect, % A_ScriptFullPath
    Gui 6:Add, Text, x+12 yp+2, Для создания правила перетащите кнопку на окно приложения!
    Gui 6:Add, ListView, x8 w680 r16 -Multi NoSortHdr Checked +Grid -LV0x10  vapp gProperties HwndLV, % " №|Имя файла|Класс окна|Описание|Флажок|Инд-р|Авто|Блок-ка"
    Loop % apps.Length()
        LV_Add(apps[A_Index,1] ? "Check" : "", A_Index, apps[A_Index,2], apps[A_Index,3], apps[A_Index,4]
        , (apps[A_Index, 5]=1) ? "+++" : (apps[A_Index, 5] ? "- - -" : "")
        , (apps[A_Index, 6]=1) ? "+++" : (apps[A_Index, 6] ? "- - -" : "")
        , (apps[A_Index, 7]=1) ? "+++" : (apps[A_Index, 7] ? "- - -" : "")
        , (apps[A_Index, 8]=1) ? "+++" : "")

    LV_ModifyCol(1,"AutoHdr")
    LV_ModifyCol(2,"100")
    LV_ModifyCol(3, "140")
    LV_ModifyCol(4, "150")
    LV_ModifyCol(5,"56 Center")
    LV_ModifyCol(6,"56 Center")
    LV_ModifyCol(7, "56 Center")
    LV_ModifyCol(8, "56 Center")
    Loop % LV_GetCount()
        LV_Modify(A_Index, "-Select")
    If (A_ThisHotkey~="\+(L|R)Shift$") && last_rule
        LV_Modify(last_rule, "Select Vis Focus")
    Gui 6:Add, Button, x40 w120 gProperties, Редактировать
    Gui 6:Add, Button, x+4 yp w70 hp gRuleUp, Вверх
    Gui 6:Add, Button, x+4 yp wp hp gRuleDown, Вниз
    Gui 6:Add, Button, x+4 yp w80 hp gRuleDelete, Удалить
    Gui 6:Add, Button, x+100 yp w80 hp g6GuiClose, Cancel
    Gui 6:Add, Button, x+6 yp wp hp gRulesSave, OK
    Gui 6:Show,, Правила приложений
    If (A_ThisHotkey~="\+(L|R)Shift$") && !lr
        Tooltip Нет включенных правил`nдля данного приложения!, % MWRight//2-100, % MWBottom//2-20
    Else If (A_ThisHotkey~="\+(L|R)Shift$")
        Tooltip Выделено правило для`nтекущего приложения!, % MWRight//2-100, % MWBottom//2-20
    SetTimer Tooltip, -2500
    lr:=0
    Return

RuleUp:
    row:=LV_GetNext(, "F")
    LV_MoveRow(LV, row, row-1)
    Return

RuleDown:
    row:=LV_GetNext(, "F")
    rn:=LV_MoveRow(LV, row, row+2)
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
    IniDelete % apps_cfg, Apps
    Loop % LV_GetCount() {
        r1:=(LV_GetNext(A_Index-1, "C")=A_Index) ? 1 : 0
        LV_GetText(r2, A_Index,2)
        LV_GetText(r3, A_Index, 3)
        LV_GetText(r4, A_Index, 4)
        r4:=RegExReplace(r4,"(:|;|,)", " "), r4:=RegExReplace(r4, " {2,}", " ")
        LV_GetText(r5, A_Index, 5)
        r5:=(r5~="\+") ? 1 : (r5 ? 2 : 0)
        LV_GetText(r6, A_Index, 6)
        r6:=(r6~="\+") ? 1 : (r6 ? 2 : 0)
        LV_GetText(r7, A_Index, 7)
        r7:=(r7~="\+") ? 1 : (r7 ? 2 : 0)
        LV_GetText(r8, A_Index, 8)
        r8:=r8 ? 1 : 0
        app%A_Index%:=r1 "," r2 "," r3 "," r4 "," r5 "," r6 "," r7 "," r8
        IniWrite % app%A_Index%, % apps_cfg, Apps, app%A_Index%
        apps.Push([r1, r2, r3, r4, r5, r6, r7, r8])
    }
6GuiClose:
    Gui 6:Destroy
    Return

#If WinActive("ahk_id" Gui6)
Esc::Goto 6GuiClose
#If

Detect:
    SetTimer TrayIcon, Off
    try {
        CursorHandle:=Base64PNG_to_HICON(icon7, 24*A_ScreenDPI/96, 24*A_ScreenDPI/96)
        Cursors= 32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651
        Loop, Parse, Cursors, `,
            DllCall("SetSystemCursor", Uint, CursorHandle, Int, A_Loopfield)
    }

    SetTimer RestoreCursors, -5000, 9
    KeyWait LButton
    RestoreCursors()
    SetTimer TrayIcon, On
    MouseGetPos,,, win
    WinGetClass class, ahk_id %win%
    WinGet pr_name, ProcessName, ahk_id %win%
    WinGet pr_path, ProcessPath, ahk_id %win%
    ch:="+", description:=FileGetInfo(pr_path).FileDescription
    If (win=Gui6) || (class="Shell_TrayWnd") || (class="WorkerW") || (class="Progman")
        Return
Properties:
    row:=0, flag_on:=ind_on:=auto_on:=0
    If (A_ThisLabel="Properties") {
        row:=(A_GuiEvent="DoubleClick") ? A_EventInfo : LV_GetNext(, "F")
        If (row=0) || (row>LV_GetCount())
            Return
        LV_GetText(pr_name, row, 2)
        If !pr_name
            Return
        LV_GetText(class, row, 3)
        LV_GetText(description, row, 4)
        LV_GetText(flag_on, row, 5)
        LV_GetText(ind_on, row, 6)
        LV_GetText(auto_on, row, 7)
        LV_GetText(sd_on, row, 8)
    }
    Gui 7:Destroy
    Gui 7:Margin, 10, 6
    Gui 7:Default
    Gui 7:+Owner6 -DPIScale +AlwaysOnTop +LastFound +ToolWindow +HwndGui7
    Gui 7:Font, s8, Segoe UI
    Gui 7:Add, Edit, x10 w200 r1 vpr_name, % pr_name
    Gui 7:Add, Text, x+5 yp+2, - имя файла
    Gui 7:Add, Button, x350 yp-2 w60 gAll, Все!
    Gui 7:Add, Edit, x10 w200 r1 vclass ReadOnly, % class
    Gui 7:Add, Text, x+5 yp+2, - класс окна
    Gui 7:Add, Button, x350 yp-2 w60 gEditClass, Edit
    Gui 7:Add, Edit, x10 w200 r1 vdescription, % description
    Gui 7:Add, Text, x+5 yp+2, - описание

    Gui 7:Add, Text, x10 y+24, Флаг:
    Gui 7:Add, DropDownList, x+8 yp-4 w70 vflag_on, |+++|- - -
    Gui 7:Add, Text, x+8 yp+4, Индикатор:
    Gui 7:Add, DropDownList, x+8 yp-4 w70 vind_on, |+++|- - -
    Gui 7:Add, Text, x+8 yp+4, Авто:
    Gui 7:Add, DropDownList, x+8 yp-4 w70 vauto_on, |+++|- - -
    Gui 7:Add, Checkbox, x10 y+8 vsd_on, Блокировка горячих клавиш и автозамен
    Gui 7:Add, Text, x8 w410 h1 0x4
    Gui 7:Font, s9
    Gui 7:Add, Button, x90 w100 g7GuiCancel, Cancel
    Gui 7:Add, Button, x+40 yp wp g7GuiOK, OK
    If (A_ThisLabel="Properties") {
        GuiControl, ChooseString, flag_on, % flag_on
        GuiControl, ChooseString, ind_on, % ind_on
        GuiControl, ChooseString, auto_on, % auto_on
    }
    GuiControl,, sd_on, % sd_on ? 1 : 0
    Gui 7:Show, Center, Свойства окна
    Sleep 50
    Send {End}
    Return

RestoreCursors:
    RestoreCursors()
    Sleep 50
    lang_cursor_old:=""
    Return

EditClass:
    GuiControl -ReadOnly, class
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
        LV_Modify(row,, row, pr_name, class, description, flag_on, ind_on, auto_on, sd_on ? "+++" : "")
    Else {
        Loop % LV_GetCount() {
            LV_GetText(name, A_Index, 2)
            LV_GetText(cl, A_Index, 3)
            If (name=pr_name) && (cl=class) {
                MsgBox, 4129, , Дубликат правила %A_Index%!, 2
                Return
            }
        }
        row:=LV_GetCount()+1
        LV_Add("Check", row, pr_name, class, description, flag_on, ind_on, auto_on,  sd_on ? "+++" : "")
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

RestoreCursors() {
    DllCall("SystemParametersInfo", UInt, 0x57, UInt, 0, UInt, 0, UInt, 0 )
}

FileGetInfo(lptstrFilename) { ; by Lexicos
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


; Настройки выделения
GUI:
    _wait:=wait, _symbint:=symbint, _wordint:=wordint, _reverseint:=reverseint, _short_press:=short_press, _long_press:=long_press
Def:
    Gui 9:Destroy
    Gui 9:+AlwaysOnTop +ToolWindow +LastFound +HwndGui9
    Gui 9:Font, s9
    Gui 9:Margin, 8, 6
    Gui 9:Color, 6DA0B8
    
    Gui 9:Add, GroupBox, x8 w312 h48, Интервал выделения по словам
    Gui 9:Add, Slider, xp10 yp+18 section w240 v_wordint gWordint Range300-1000 ToolTip NoTicks, % _wordint
    Gui 9:Add, Text, w50 ys, %_wordint% мс
    
    Gui 9:Add, GroupBox, x8 w312 h48, Ожидание отпускания клавиши
    Gui 9:Add, Slider,xp10 yp+18 section w240 v_wait gWait Range160-320 ToolTip2 NoTicks, % _wait
    Gui 9:Add, Text, w50 ys, %_wait% мс
    
    Gui 9:Add, GroupBox, x8 w312 h48, Интервал посимвольного выделения
    Gui 9:Add, Slider, xp10 yp+18 section w240 v_symbint gSymbint Range120-360 ToolTip3 NoTicks, % _symbint
    Gui 9:Add, Text, w50 ys, %_symbint% мс
    
    Gui 9:Add, GroupBox, x8 w312 h48, Задержка обращения цикла
    Gui 9:Add, Slider, xp10 yp+18 section w240 v_reverseint gReverseint Range500-1200 ToolTip3 NoTicks, % _reverseint
    Gui 9:Add, Text, w50 ys, %_reverseint% мс
    
    Gui 9:Add, GroupBox, x8 w312 h48, Короткое нажатие клавиш переключения
    Gui 9:Add, Slider, xp10 yp+18 section w240 v_short_press gShortPress Range150-350 ToolTip4 NoTicks, % _short_press
    Gui 9:Add, Text, w50 ys, %_short_press% мс
    
    Gui 9:Add, GroupBox, x8 w312 h48, Долгое нажатие клавиш переключения
    Gui 9:Add, Slider, xp10 yp+18 section w240 v_long_press gLongPress Range450-800 ToolTip5 NoTicks, % _long_press
    Gui 9:Add, Text, w50 ys, %_long_press% мс
    
    Gui 9:Add, GroupBox, x8 w312 h40, Клавиатурные сочетания
    Gui 9:Add, Checkbox, xp20 yp+17 vctrl_ctrl, Сочетание Ctrl+Ctrl
    Gui 9:Add, Checkbox, x+20 yp vshift_shift, Сочетание Shift+Shift
    Gui 9:Default
    GuiControl,, ctrl_ctrl, % ctrl_ctrl
    GuiControl,, shift_shift, % shift_shift
       
    Gui 9:Add, Button, x30 w60 section g9GuiClose, Cancel
    Gui 9:Add, Button, x+4 ys w140 hp gDefaults, По умолчанию
    Gui 9:Add, Button, x+4 ys w60 hp g9OK, OK
    Gui 9:Show,, Настройки клавиатуры
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

Reverseint:
    GuiControl,, Static4, %_reverseint% мс
    Return
    
ShortPress:
    GuiControl,, Static5, %_short_press% мс
    Return
    
LongPress:
    GuiControl,, Static6, %_long_press% мс
    Return

Defaults:
    _wordint:=750, _wait:=250, _symbint:=280, _reverseint:=700, _short_press:=250, _long_press:=600, ctrl_ctrl:=shift_shift:=1
    Goto Def

9OK:
    Gui 9:Submit
    wait:=_wait, symbint:=_symbint, wordint:=_wordint, reverseint:=_reverseint, short_press:=_short_press, long_press:=_long_press
    Goto Settings

9GuiClose:
    Gui 9:Destroy
    Return

#If WinActive("ahk_id" Gui9)
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
    ld_start:=A_TickCount, dict_string:=dname_string:=""
    Loop % lang_count {
        lac:=lang_array[A_Index, 1], ind:=A_Index
        If !((lac~=lang_auto) || (lac=lang_auto_single) || ((lac~=lang_auto_others) && lang_auto_others))
            Continue
        Loop Files, % "dict\" lang_array[A_Index, 5] "\*.aff"
        {
            maff:=A_LoopFilePath, mdic:=RegExReplace(maff, "aff$", "dic")
            If (A_Index=2) {
                MsgBox, 48, , % "Имеются лишние файлы словарей в папке dict\" lang_array[ind, 5] "!", 3
                Break
            }
            If FileExist(mdic) && Spell_Init(d_%lac%, maff, mdic, "hunspell\") {
                dict_string.="""" maff """,""" mdic """,", dname_string.=d_%lac% ","
                Continue
            }
        }
        If !only_main_dict {
            Loop Files, % "dict\" lang_array[A_Index, 5] "\*.dic"
            {
                If (A_LoopFilePath=mdic)
                    Continue
                Spell_InitCustom(d_%lac%, A_LoopFilePath)
                dict_string.="""" A_LoopFilePath ""","
            }
        }
    }
    If FileExist("logs")
        FileAppend % "`r`n;" A_TickCount-start "/" A_TickCount-ld_start, logs\transform.log, UTF-8
    start:=ld_start:=0
    Return

UpdateUserDict:
    FileGetTime dict_time, % cfg_folder "\user_dict.dic", M
    If (dict_time!=dict_time_old) {
        user_dic:=""
        FileRead udic, % "*P65001 " cfg_folder "\user_dict.dic"
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

Hunspell:
    Run https://drive.google.com/drive/folders/1Xe13v0hm3nzipRkTSIcbuAaTZGIYYpP2?usp=drive_link
    If ErrorLevel
        Run % A_WinDir "\System32\OpenWith.exe https://drive.google.com/drive/folders/1Xe13v0hm3nzipRkTSIcbuAaTZGIYYpP2"
    Return

;=========== Автопереключение ============
Autocorrect:
    Gui 8:Destroy
    Gui 8:+LastFound +AlwaysOnTop -MinimizeBox +ToolWindow +hWndGui8
    Gui 8:Default
    Gui 8:Color, 6DA0B8
    Gui 8:Font, s9
    Gui 8:Add, CheckBox, x24 y16 section vsound, Звуки автопереключения и отмены
    Gui 8:Add, CheckBox, xs vlang_note, Уведомление при автопереключении
    Gui 8:Add, CheckBox, xs vctrlz_undo, Отмена преобразования по Ctrl+Z
    Gui 8:Add, CheckBox, xs vno_indicate, Выключение индикации на флажке
    Gui 8:Add, GroupBox, x12 w240 h68, Языки автопереключения
    Gui 8:Add, DropDownList, vlang_auto_i x50 yp+20 w160 Choose%lang_auto_sel% AltSubmit, % lang_set_auto
    Gui 8:Add, CheckBox, x28 y+8 section vonly_main_dict, Только основной словарь
    Gui 8:Add, GroupBox, x12 w240 h134, Режим одного языка
    Gui 8:Add, DropDownList, vlang_auto_i2 gAcupdate x50 yp+20 w160 Choose%lang_auto_single_sel% AltSubmit, % lang_menu_single
    Gui 8:Add, Text, xp y+8, Языки автопереключения:
    Gui 8:Add, ListView, -Hdr Grid r3 Checked w160 x50 yp+20 -LV0x10, #|Layout
    row_numb:=0
    Loop % lang_array.Length() {
        row_numb++
        If (lang_auto_single=lang_array[A_Index,1])
            Continue
        If FileExist("dict\" lang_array[A_Index, 5]) && FolderSize("dict\" lang_array[A_Index, 5])
            LV_Add(((lang_array[A_Index, 1]~=lang_auto_others) && lang_auto_others) ? "Check" : "", A_Index, lang_array[A_Index, 2])
    }
    LV_ModifyCol(1, "30 Center")
    LV_ModifyCol(2, "AutoHdr")

    Gui 8:Add, CheckBox, x280 y16 section vmin_length, Обработка текста с 3-х символов
    Gui 8:Add, CheckBox, xs vletter_ignore, Игнорировать одельные буквы
    Gui 8:Add, CheckBox, xs vabbr_ignore, Игнорировать аббревиатуры
    Gui 8:Add, CheckBox, xs vdigit_ignore, Игнорировать слова с цифрами

    Gui 8:Add, GroupBox, x264 y+6 w240 h66, Начальные границы слов
    Gui 8:Add, CheckBox, xs yp+20 vstart_symbols_enabled, Символы:
    Gui 8:Add, Edit, x+20 yp-4 w100 r1 vstart_symbols, % start_symbols
    Gui 8:Add, CheckBox, xs yp+24 vdigit_borders, Клавиши цифрового ряда

    Gui 8:Add, GroupBox, x264 y+20 w240 h44, Конечные границы слов
    Gui 8:Add, CheckBox, xs yp+20 vend_symbols_enabled, Символы:
    Gui 8:Add, Edit, x+20 yp-4 w100 r1 vend_symbols, % end_symbols

    Gui 8:Add, GroupBox, x264 y+12 w240 h84, Не исправлять раскладку
    Gui 8:Add, CheckBox, xs yp+20 vnew_lang_ignore, После ручного переключения
    Gui 8:Add, CheckBox, xs yp+20 vmouse_click_ignore, После клика мышью (вставка)
    Gui 8:Add, CheckBox, xs yp+20 vbackspace_ignore, После нажатия Backspace

    Gui 8:Add, Button, x108 w80 h20 section g8GuiClose, Cancel
    Gui 8:Add, Button, x+4 ys w132 hp g8Defaults, По умолчанию
    Gui 8:Add, Button, x+4 ys w80 hp g8OK, OK

    GuiControl,, only_main_dict, % only_main_dict
    GuiControl,, single_lang_only, % single_lang_only
    GuiControl,, sound, % sound
    GuiControl,, lang_note, % lang_note
    GuiControl,, ctrlz_undo, % ctrlz_undo
    GuiControl,, no_indicate, % no_indicate
    GuiControl,, letter_ignore, % letter_ignore
    GuiControl,, min_length, % min_length
    GuiControl,, abbr_ignore, % abbr_ignore
    GuiControl,, digit_ignore, % digit_ignore
    GuiControl,, start_symbols_enabled, % start_symbols_enabled
    GuiControl,, digit_borders, % digit_borders
    GuiControl,, end_symbols_enabled, % end_symbols_enabled
    GuiControl,, new_lang_ignore, % new_lang_ignore
    GuiControl,, mouse_click_ignore, % mouse_click_ignore
    GuiControl,, backspace_ignore, % backspace_ignore
    Gui 8:Show,, Настройки автопереключения
    Return

Acupdate:
    Gui 8:Submit
    Sleep 100
    lang_auto_single:=lang_menu_s[lang_auto_i2], lang_auto_single_sel:=lang_auto_i2
    Goto Autocorrect

8Defaults:
    only_main_dict:=letter_ignore:=abbr_ignore:=start_symbols_enabled:=digit_borders:=end_symbols_enabled:=new_lang_ignore:=mouse_click_ignore:=backspace_ignore:=lang_note:=0, sound:=min_length:=1, start_symbols:="(_=+""", end_symbols:=").,!?"""
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
        If ch
            lang_auto_o.=lang_array[ch,1] "|"
    }
    lang_auto_o:=RegExReplace(lang_auto_o, "\|$")
    lang_auto_others:=lang_auto_o ? "(" lang_auto_o ")" : ""
    Sleep 200
    Reload


#If WinActive("ahk_id" Gui8 )
Esc::Goto 8GuiClose
#If

TextCursorToggle:
    text_cursor:=!text_cursor
    Goto Apply

ArrowCursorToggle:
    arrow_cursor:=!arrow_cursor, pArrowDraft:=""
    Goto Apply

LargeFlagToggle:
    large_flag:=!large_flag, pArrowDraft:=""
    Goto Apply

InvertArrowToggle:
    invert_arrow:=!invert_arrow, color_arrow:=0, pArrowDraft:=""
    Goto Apply

ArrowColorToggle:
    color_arrow:=!color_arrow, invert_arrow:=0, pArrowDraft:=""
    Goto Apply

ArrowColor:
    arrow_color:=ChooseColor("0x" arrow_color), pArrowDraft:=""
    Goto Apply

CursorSize:
    cursor_size:=RegExReplace(A_ThisMenuItem, "x.+$"), pArrowDraft:=""
    Goto Apply

OnNewWindow:
    on_new_window:=!on_new_window
    If !on_new_window
        on_mouse_click:=0
    Goto Apply

OnMouseClick:
    on_mouse_click:=!on_mouse_click
    Goto Apply

CursorShow:
    cursor_show:=RegExReplace(A_ThisMenuItem, "\s.+$")
    Goto Apply

#If ctrl_ctrl
<^RCtrl::
>^LCtrl::
    RegExMatch(A_ThisHotkey, "\w+$", ckey)
    KeyWait % ckey
    key_time:=A_TimeSinceThisHotkey
    If ((key_press=2) && (key_time>short_press)) || ((key_press=3) && (key_time<long_press))
        Return
AutocorrectToggle:
    autocorrect:=!autocorrect, ih.Stop()
    Menu Autocorrect, % autocorrect ? "Check" : "Uncheck", 1&
    If !autocorrect {
        ttip:=0
        ToolTip,,,, 10
    }
    Return
#If

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
    Gui 10:+LastFound +AlwaysOnTop +ToolWindow +HwndGui10
    Gui 10:Font, s9, Segoe UI
    Gui 10:Add, CheckBox, vconv_as_text section x16 y8 +Checked, Открыть как простой текст
    Gui 10:Add, CheckBox, vconv_min xp+12 y+6 +Checked, Выбирать слова длиннее
    Gui 10:Add, DropDownList, vconv_min_size x+0 yp-4 w32, 1|2||3|4|5|6
    Gui 10:Add, Text, x+8 yp+4, знаков
    Gui 10:Add, CheckBox, vconv_merge xs +Checked, Слияние и удаление дубликатов`nслов с учетом регистра
    Gui 10:Add, CheckBox, vconv_sort xs, Сортировка слов с учетом регистра

    Gui 10:Add, Radio, vfile_out xs +Checked, Добавить в словарь программы
    Gui 10:Add, Radio,  xs, Сохранить в отдельный dic-файл
    Gui 10:Add, CheckBox, vopen_dict xs +Checked, Открыть в редакторе по завершении

    Gui 10:Add, Button, gOpenClipboard xs w250, Вставить текст из буфера обмена
    Gui 10:Add, Button, gOpenFile vopen_file xs wp h42, Открыть или перетащить на кнопку`nтекстовый файл(ы) в кодировке utf-8

    Gui 10:Add, GroupBox, x+16 y4 w288 h254, Опции
    Gui 10:Add, CheckBox, vconv_accent_ignore section xp+12 yp+20, Удалять акценты (ё=е, á=a и т.д.)
    Gui 10:Add, CheckBox, vconv_en xs, Только слова с английскими буквами
    Gui 10:Add, CheckBox, vconv_ru xs, Только слова с русскими буквами
    Gui 10:Add, CheckBox, vconv_regexp xs, Регэксп слов:
    Gui 10:Add, ComboBox, x+4 yp-4 w140 vregexp, % regexp_list
    Gui 10:Add, CheckBox, vconv_abbr xs, Обработка аббревиатур
    Gui 10:Add, Radio, vconv_abbr_del xp+12 y+8 +Checked, Удалять все
    Gui 10:Add, Radio, x+4 yp, Только аббревиатуры
    Gui 10:Add, CheckBox, vconv_lowercase xs , Все слова в нижний регистр
    Gui 10:Add, CheckBox, vconv_del_digits xs +Checked, Удалять слова с цифрами
    Gui 10:Add, CheckBox, vconv_del_quot xs, Удалять слова с апострофами
    Gui 10:Add, CheckBox, vconv_crop xs, Обрезать слова до
    Gui 10:Add, DropDownList, vconv_crop_size x+8 yp-4 w48, 5|6||7|8|9|10|11|12
    Gui 10:Add, Text, x+8 yp+4, знаков
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
        FileRead t_in, % "*P65001 " A_LoopField
        text.="`r`n" t_in
        If (A_Index=1)
            file_path:=A_LoopField
    }
SaveText:
    CoordMode ToolTip
    ToolTip % "`n   Работаем...   `n  ", % A_ScreenWidth//2-50, % A_ScreenHeight//2-25, 11
    If conv_regexp && regexp {
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
            save_path:=dict_name "\" StrReplace(dir_name, "-", "_") "_" A_Index ".dic"
            If !FileExist(save_path)
                Break
        }
    }
    SplitPath save_path,, save_dir
    If FileExist(save_path)
        FileDelete % save_path
    FileAppend % dic0, % save_path, UTF-8
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
        If (StrLen(Trim(ds))<2) || (ds~="\s*^-+")
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
    SetFormat float, 0.2
    res1_all:=res2_all:=res3_all:=res4_all:=max:=0
    If FileExist("logs\transform.log") {
        FileRead transform, *P65001 logs\transform.log
        trans:=StrSplit(transform, "`n", "`r"), nl:=tr:=lpr:=ldt:=0
        For each, str in trans
        {
            If RegExMatch(str, "^;(\d+)/(\d+)", tl)
                nl+=1, lpr+=Format("{:d}", tl1), ldt+=Format("{:d}", tl2)

            If RegExMatch(str, "(?<!;)(\S+)/.+ (\d+)/(\d+)", res)
                tr+=1, rl:=StrLen(res1), res1_all+=rl, max:=Max(rl, max), res2_all+=Format("{:d}", res2), res3_all+=Format("{:d}", res3),
            If (str~="==$")
                res4_all++
        }
        MsgBox,, Статистика, % "Среднее время загрузки программы: " lpr/nl " mc`nИз них загрузки словарей: " ldt/nl " mc`n`nСреднее время обработки нажатий клавиш: " res2_all/tr " mc`nСреднее время преобразования текста: " res3_all/tr " mc`n`nСредняя длина преобразованного текста: " Format("{:.3}", res1_all/tr) "`nМаксимальная длина преобразованного текста: " max "`nЧисло преобразований: " tr "`nЧисло отмен преобразований: " res4_all " (" res4_all*100//tr "%)"
    }
    Return

; ----------- Автозамена -------------
Hotstrings:
    IniRead case_sens, % hs_cfg, Main, case_sens, 0
    IniRead replace_sound, % hs_cfg, Main, replace_sound, 1
    IniRead scrolllock_show, % hs_cfg, Main, scrolllock_show, 0
    IniRead empty_var, % hs_cfg, Main, empty_var, % " "
    IniRead end_space, % hs_cfg, Main, end_space, 1
    IniRead end_tab, % hs_cfg, Main, end_tab, 1
    IniRead end_enter, % hs_cfg, Main, end_enter, 0
    IniRead end_chars_enabled, % hs_cfg, Main, end_chars_enabled, 1
    IniRead end_chars, % hs_cfg, Main, end_chars, -()[]{}':;"/\,.?!
    If end_chars_enabled
        _end_chars.=end_chars
    If end_space
        _end_chars.=" "
    If end_tab
        _end_chars.="`t"
    If end_enter
        _end_chars.="`n"
    Hotstring("EndChars", _end_chars)

    hs:=[]
    Loop {
        h1:=h2:=h3:=h4:=hs_pr:=h2s:="", hsnn:=A_Index
        IniRead h1, % hs_cfg, % A_Index, enabled, % " "
        IniRead h2, % hs_cfg, % A_Index, hotstring, % " "
        IniRead h3, % hs_cfg, % A_Index, options, % " "
        IniRead h4, % hs_cfg, % A_Index, replacement, % " "
        IniRead h5, % hs_cfg, % A_Index, comment, % " "
        If !h2 || !h4
            Break
        If StrLen(h3)<4
            h3.="0"
        If RegExMatch(h4, "Clips\\\d{10,}", clipfile)
            used_files.=clipfile ","
        hs.Push([h1, h2, h3, h4, h5]), hs_numb:=A_Index
        hs_pr.=SubStr(h3, 2, 1) ? "*" : "*0",
        hs_pr.=SubStr(h3, 3, 1) ? "?" : "?0",
        hs_pr.=SubStr(h3, 4, 1) ? "C0" : (case_sens ? "C" : "C1"),
        h2s:=h2n:=h2
        If SubStr(h3, 1, 1) {
            Loop % lang_array.Length()
                If (lang_array[A_Index, 1]!=0x0409)
                    If !InStr(h2n, h2a:=StringToAnotherLayout(h2n, 0x0409, lang_array[A_Index, 1]))
                        h2s.="|" h2a
        }
        Hotkey IfWinNotActive, ahk_pid %pid%
        Loop Parse, h2s, |
        {
            Hotstring(":X" hs_pr ":" A_LoopField, "HS_Run", h1 ? 1 : 0)
            ;OutputDebug % hsnn "." A_Index " :X" hs_pr ":" A_LoopField
        }
        hs[hs_numb, 6]:=h2s
    }
    Hotkey If
    Loop Files, Clips\*
    If A_LoopFilePath not in % used_files
        FileRecycle % A_LoopFilePath
    Return

HS_Run:
    Critical
    text_convert:=1
    RegExMatch(A_ThisHotkey, "^(:\S*:)(.+)", hssp), hstr:=hssp2
    case_convert:=hstr2:=""
    bh:=InputHook("I"), bh.VisibleNonText:=1, bh.Start()
    SetTimer ResetBlock, -1500
    If (hssp1~="C0") {
        hstr2:=SubStr(ih.Input, -(StrLen(hstr)+(A_EndChar ? 1 : 0)), StrLen(hstr)),
        case_convert:="L"
        If (hstr2==Format("{:U}", hstr2))
            case_convert:="U"
        If (hstr2==Format("{:T}", hstr2))
            case_convert:="T"
    }
    Loop % hs.Length() {
        hsn:=A_Index
        If case_sense && !SubStr(hs[A_Index, 3], 4, 1)
            StringCaseSense On
        Else
            StringCaseSense Off
        Loop Parse, % hs[A_Index, 6], |
            If (hstr=A_LoopField) {
                hs_numb:=hsn
                Goto Out
            }
    }
Out:
    hs_out:=hs[hs_numb, 4]
    If RegExMatch(hs_out, "Clips\\\d{10,}", clipfile) {
        If !FileExist(clipfile) {
            ToolTip Отсутствует файл!, % x ? x-40 : A_ScreenWidth//2, % y ? y-40 : A_ScreenHeight//2
            SetTimer ToolTip, -1500
            Return
        }
        FileRead, Clipboard, % "*c " clipfile
        ClipWait 3, 1
        If !(hs_out~="-Clips\\\d{10,}")
            SendInput ^{vk56}
        Else {
            ToolTip % " `n   Буфер загружен!   `n ", % A_ScreenWidth//2-60, % A_ScreenHeight//2-20
            SetTimer ToolTip, -1500
            Critical Off
            bh.Stop()
            Return
        }
        Goto Final
    }
    hs_out:=StrReplace(hs_out, "``n", "{{Enter}}"), hs_out:=StrReplace(hs_out, "``t", "{{Tab}}")
    If (case_convert="L")
        hs_out:=Format("{:L}", hs_out)
    If (case_convert="U")
        hs_out:=Format("{:U}", hs_out)
    If (case_convert="T")
        hs_out:=Format("{:U}", SubStr(hs_out, 1, 1)) . SubStr(hs_out, 2)
LoadPreview:
    Critical On
    StringCaseSense Off
    If WinExist("ahk_id" Gui14)
        hs_out:=repeat
    L_Clipboard:=L_CaretX:=L_CaretY:=L_WindowX:=L_WindowY:=L_WindowW:=L_WindowH:=L_WindowTitle:=L_WindowClass:=L_ControlName:=L_ControlText:=L_ColorRGB:=L_ColorBGR:=L_WebAddRess:=L_KeyName:=L_VirtualCode:=L_ScanCode:=""
    If RegExMatch(hs_out, "i)%L_Clipboard%")
        L_Clipboard:=SubStr(Clipboard, 1, 200)
    If RegExMatch(hs_out, "i)%(L_MouseX|L_MouseY|L_CaretX|L_CaretY|L_WindowX|L_WindowY|L_WindowW|L_WindowH|L_WindowTitle|L_WindowClass|L_ControlName|L_ControlText|L_ColorRGB|L_ColorBGR|L_WebAddress)%") {
        GetCaretLocation(_x, _y)
        ToolTip Щелкните левой кнопкой мыши`nв интересующем месте!, % (_x && _y) ? _x-100 : A_ScreenWidth/2-100, % (_x && _y) ? _y-70 : A_ScreenHeight/2
        SetTimer ToolTip, -1000
        win_txt:=WinExist("A")
       SetTimer TrayIcon, Off
        Cursors = 32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651
        Loop, Parse, Cursors, `,
            DllCall("SetSystemCursor", Uint, DllCall( "LoadCursor", Uint,0, Int, 32512), Int, A_Loopfield)        
        td:=0       
        While !GetKeyState("LButton", "P") && (td<10000) {
            Sleep 10
            td+=10
        }
        If (td>=10000)
            Goto ResetBlock
        MouseGetPos mx, my, mwin, mctrl
        KeyWait LButton, T1
        DllCall("SystemParametersInfo", UInt, 0x57, UInt, 0, UInt, 0, UInt, 0 )
        SetTimer TrayIcon, On
        WinActivate ahk_id %mctrl%
        GetCaretLocation(L_CaretX, L_CaretY)
        L_MouseX:=mx, L_MouseY:=my
        WinGetPos L_WindowX, L_WindowY, L_WindowW, L_WindowH, ahk_id %mwin%
        WinGetTitle L_WindowTitle, ahk_id %mwin%
        WinGetClass L_WindowClass, ahk_id %mwin%
        L_ControlName:=mctrl
        ControlGetText mctrl_txt, % mctrl
        L_ControlText:=SubStr(mctrl_txt, 1, 200)
        PixelGetColor L_ColorBGR, % mx, % my
        PixelGetColor L_ColorRGB, % mx, % my, RGB
        L_ColorBGR:=Format("{:06X}", L_ColorBGR), L_ColorRGB:=Format("{:06X}", L_ColorRGB)
        L_WebAddress:=CopyAddress()
        If WinExist("ahk_id" Gui14) {
            WinActivate % "ahk_id" Gui14
            ControlFocus Preview, % "ahk_id" Gui14
        }
        Else {
            WinActivate ahk_id %win_txt%
            Sleep 50
            ControlFocus % ctrl_txt, ahk_id %win_txt%
            Sleep 10
        }
    }
    If RegExMatch(hs_out, "i)%(L_KeyName|L_VirtualCode|L_ScanCode)%") {
        GetCaretLocation(_x, _y)
        ToolTip Нажмите интересующую клавишу, % (_x && _y) ? _x-100 : A_ScreenWidth/2-100, % (_x && _y) ? _y-70 : A_ScreenHeight/2
        kh:=InputHook("I T5")
        kh.VisibleNonText:=false
        kh.KeyOpt("{All}", "E")
        kh.Start()
        kh.Wait()
        If (kh.EndReason="Timeout")
            Goto ResetBlock
        L_KeyName:=kh.EndKey,
        L_VirtualCode:=Format("vk{:X}", GetKeyVK(kh.EndKey)),
        L_ScanCode:=Format("sc{:X}", GetKeySC(kh.EndKey))
    }
    n:=0
    Loop {
        n:=RegExMatch(hs_out, "i)%(A|L)_\w+%", expr, n+1)
        If !expr
            Break
        ex:=StrReplace(expr, "%"), val:=%ex% ? %ex% : empty_var
        If (ex==Format("{:U}", ex))
            val:=Format("{:U}", val)
        If (ex==Format("{:L}", ex))
            val:=Format("{:L}", val)
        If (ex==Format("{:T}", ex))
            val:=Format("{:T}", val)
        hs_out:=StrReplace(hs_out, expr, val)
    }
    Loop {
        k:=RegExMatch(hs_out, "\{[!^+#<>]*\{[\w+ ]+}}", hk)
        If k {
            If (k>1)
                SendInput % "{Raw}" SubStr(hs_out, 1, k-1)
            SendInput % SubStr(hk, 2, -1)
            hs_out:=SubStr(hs_out, k+StrLen(hk))
        }
        If !hs_out || !k
            Break
    }
    SendInput % "{Raw}" hs_out . A_EndChar
    If RegExMatch(hs[hs_numb, 3], "-\K\w+$", hs_lang) {
        Loop % lang_array.Length() {
            If (hs_lang=lang_array[A_Index, 1])
                SetInputLayout(key_switch, hs_lang)
        }
    }
Final:
    If replace_sound && FileExist("sounds\autoreplace.wav")
        SetTimer ReplaceSound, -50
    If (scrolllock_show=1) || ((scrolllock_show=-1) && GetKeyState("ScrollLock", "T")) {
        Sleep 50
        GetCaretLocation(_x, _y)
        ToolTip % " Замена: " hs_numb "  " hs[hs_numb, 2] . (hstr!=hs[hs_numb, 2] ? " / " hstr : "") " ", % (_x && _y) ? _x-50 : A_ScreenWidth//2-20, % (_x && _y) ? _y-40 : A_ScreenHeight//2-50, 3
        SetTimer ToolTip, -2000
    }
    Return

ResetBlock:
    ToolTip
    bh.Stop()
    kh.Stop()
    SetTimer TrayIcon, On
    Return

ReplaceSound:
    SoundPlay sounds\autoreplace.wav
    Return

Autoreplace:
    Gui 12:Destroy
    Gui 12:+AlwaysOnTop +ToolWindow +LastFound +Hwndhwnd12
    Gui 12:Default
    Gui 12:Font, s9
    Gui 12:Add, Button, h28 gEdit, % " + Добавить "
    Gui 12:Add, CheckBox, x+8 yp+7 vcase_sens, С учетом регистра
    Gui 12:Add, CheckBox, x+4 yp vreplace_sound, Звук при автозамене
    Gui 12:Add, CheckBox, x+4 yp vscrolllock_show Check3, Тултип автозамены
    Gui 12:Add, Text, x20, Завершения:
    Gui 12:Add, CheckBox, x+8 yp vend_space, Пробел
    Gui 12:Add, CheckBox, x+4 yp vend_tab, Табуляция
    Gui 12:Add, CheckBox, x+4 yp vend_enter, Ввод
    Gui 12:Add, CheckBox, x+4 yp vend_chars_enabled, Символы:
    Gui 12:Add, Edit, x+4 yp-4 w100 vend_chars, % end_chars
    Gui 12:Add, Button, x+4 yp-2 h24 gReset_chars, Сброс
    Gui 12:Font, s9

    Gui 12:Add, ListView, x8 w620 r16 -Multi NoSortHdr Checked +Grid -LV0x10  vapp gHS +HwndLV2, % " №|Сокр-е|Комментарий|Опции|Автозамена"
    Loop % hs.Length() {
        h4:=hs[A_Index, 4],
        h4:=StrReplace(h4, "````", "``"),
        h4:=StrReplace(h4, "``n", "`r`n"),
        h4:=StrReplace(h4, "``t", A_Tab),
        h4:=StrReplace(h4, "```;", "`;")
        LV_Add(hs[A_Index, 1] ? "Check" : "", A_Index, hs[A_Index, 2], hs[A_Index, 5], hs[A_Index, 3], h4)
    }
    LV_ModifyCol(1,"40 Center")
    LV_ModifyCol(2,"50")
    LV_ModifyCol(3,"90")
    LV_ModifyCol(4,"72 Center")
    LV_ModifyCol(5,"344")
    Gui 12:Font, s9
    Gui 12:Add, Button, x32 w100 gHS, Редактировать
    Gui 12:Add, Button, x+4 yp w62 hp gRuleUp2, Вверх
    Gui 12:Add, Button, x+4 yp wp hp gRuleDown2, Вниз
    Gui 12:Add, Button, x+4 yp wp hp gRuleDelete2, Удалить
    Gui 12:Add, Button, x+80 yp wp hp g12GuiClose, Cancel
    Gui 12:Add, Button, x+4 yp wp hp gApplyRules, Apply
    Gui 12:Add, Button, x+4 yp wp hp gSaveRules, OK
    GuiControl,, case_sens, % case_sens
    GuiControl,, scrolllock_show, % scrolllock_show
    GuiControl,, replace_sound, % replace_sound
    GuiControl,, end_space, % end_space
    GuiControl,, end_tab, % end_tab
    GuiControl,, end_enter, % end_enter
    GuiControl,, end_chars_enabled, % end_chars_enabled
    Gui 12:Show,, Автозамена
    Return

Reset_chars:
    GuiControl,, end_chars, -()[]{}':;"/\,.?!
    Return

RuleUp2:
    row:=LV_GetNext(, "F")
    LV_MoveRow(LV2, row, row-1)
    Return

RuleDown2:
    row:=LV_GetNext(, "F")
    rn:=LV_MoveRow(LV2, row, row+2)
    Return

RuleDelete2:
    row:=LV_GetNext(, "F")
    MsgBox, 4129, , Удалить правило %row%?
    IfMsgBox OK
    {
        hs.RemoveAt(row)
        LV_Delete(row)
        Loop % LV_GetCount()
            LV_Modify(A_Index,, A_Index)
    }
    Return

ApplyRules:
SaveRules:
    Gui 12:Submit, % (A_ThisLabel="ApplyRules") ? "Nohide" : ""
    FileDelete % hs_cfg
    IniWrite % case_sens, % hs_cfg, Main, case_sens
    IniWrite % scrolllock_show, % hs_cfg, Main, scrolllock_show
    IniWrite % replace_sound, % hs_cfg, Main, replace_sound
    IniWrite % end_space, % hs_cfg, Main, end_space
    IniWrite % end_tab, % hs_cfg, Main, end_tab
    IniWrite % end_enter, % hs_cfg, Main, end_enter
    IniWrite % end_chars_enabled, % hs_cfg, Main, end_chars_enabled
    end_chars:=StrReplace(end_chars, ",", "`,")
    end_chars:=StrReplace(end_chars, "`", "``")
    end_chars:=StrReplace(end_chars, "%","`%")
    end_chars:=StrReplace(end_chars, """", """")
    IniWrite % end_chars, % hs_cfg, Main, end_chars
    IniWrite % empty_var, % hs_cfg, Main, empty_var
    Loop % LV_GetCount() {
        h1:=(LV_GetNext(A_Index-1, "C")=A_Index) ? 1 : 0
        LV_GetText(h2, A_Index, 2)
        LV_GetText(h3, A_Index, 3)
        LV_GetText(h4, A_Index, 4)
        LV_GetText(h5, A_Index, 5)
        IniWrite % h1, % hs_cfg, % A_Index, enabled
        h2:=Trim(h2), h3:=Trim(h3)
        IniWrite % """" h2 """", % hs_cfg, % A_Index, hotstring
        IniWrite % """" h3 """", % hs_cfg, % A_Index, comment
        IniWrite % """" h4 """", % hs_cfg, % A_Index, options
        h5:=StrReplace(h5, "`r`n", "``n"),
        h5:=StrReplace(h5, "`n", "``n"),
        h5:=StrReplace(h5, A_Tab, "``t"),
        IniWrite % """" h5 """", % hs_cfg, % A_Index, replacement
    }
    Sleep 200
    Goto Hotstrings

12GuiClose:
    Gui 12:Destroy
    Return

#If WinActive("ahk_id" hwnd12)
Esc::Goto 12GuiClose
#If

HS:
    Gui 12:Default
    row:=(A_GuiEvent="DoubleClick") ? A_EventInfo : LV_GetNext(, "F")
    If (row=0) || (row>LV_GetCount())
        Return
    LV_GetText(hse, row, 2)
    LV_GetText(hscomm, row, 3)
    LV_GetText(opt, row, 4)
    LV_GetText(replacement, row, 5)
    all_lang:=SubStr(opt, 1, 1) ? 1 : 0,
    exact:=SubStr(opt, 2, 1) ? 1 : 0,
    in_word:=SubStr(opt, 3, 1) ? 1 : 0,
    case_copy:=SubStr(opt, 4, 1) ? 1 : 0,
    add_rule:=0, hs_numb:=row

Edit:
    Gui 12:Default
    If (A_ThisLabel="Edit")
        hse:=hscomm:=replacement:="", add_rule:=1
    Gui 13:Destroy
    Gui 13:Margin, 10, 6
    Gui 13:Default
    Gui 13:+Owner12 -DPIScale +AlwaysOnTop +LastFound +ToolWindow +Hwndhwnd13
    Gui 13:Font, s8
    Gui 13:Add, Text, x20 y10 section, Сокращение:
    Gui 13:Font, s10
    Gui 13:Add, Edit, xs y+4 w156 r1 vhse, % hse
    Gui 13:Font, s8
    Gui 13:Add, Text, xs y+8, Комментарий:
    Gui 13:Font, s10
    Gui 13:Add, Edit, xs y+4 w156 r1 vhscomm, % hscomm
    Gui 13:Font, s8
    Gui 13:Add, CheckBox, x200 y16 section vall_lang, Все раскладки (только английские символы!)
    Gui 13:Add, CheckBox, xs vexact, Точное соответствие (без завершающих клавиш)
    Gui 13:Add, CheckBox, xs vin_word, Внутри слов, без предшествующего пробела
    Gui 13:Add, CheckBox, xs vcase_copy, Следовать регистру символов сокращения
    lang_menu_n:="Выкл.", lang_n:=1
    RegExMatch(opt, "-\K\w+$", hs_lang)
    Loop % lang_array.Length() {
        lang_menu_n.="|" lang_array[A_Index, 2]
        If (hs_lang=lang_array[A_Index, 1])
            lang_n:=A_Index+1
    }
    Gui 13:Add, DropDownList, vlang_n w120 xs AltSubmit Choose%lang_n%, % lang_menu_n
    Gui 13:Add, Text, x+8 yp+4, Раскладка после автозамены
    Gui 13:Font, s10
    Gui 13:Add, Edit, x10 w640 r6 vreplacement WantTab, % replacement
    Gui 13:Font, s8
    Gui 13:Add, Button, x52 y+8 w136 h48 gCharmap , Таблица`nсимволов
    Gui 13:Add, Button, x+6 yp wp hp gHotkeyGui, Сочетание`nклавиш

    Gui 13:Add, Button, x+6 yp wp hp gClipSave, Вставить`nиз буфера
    Gui 13:Add, Button, x+6 yp wp hp gClipLoad, Копировать`nв буфер

    Gui 13:Add, Button, x52 y+6 wp h36 gVariables, Переменные
    Gui 13:Add, Button, x+6 yp wp hp gPreview, Предпросмотр
    Gui 13:Add, Button, x+6 yp wp hp g13GuiClose, Cancel
    Gui 13:Add, Button, x+6 yp wp hp gHS_Save, OK
    If (A_ThisLabel="HS") {
        GuiControl,, all_lang, % all_lang
        GuiControl,, exact, % exact
        GuiControl,, in_word, % in_word
        GuiControl,, case_copy, % case_copy
    }
    Gui 13:Show, w660, % "Настройки правила " (row ? row : "")
    Send {End} 
    Return

#If WinActive("ahk_id" hwnd13)
~Enter::
~NumpadEnter::
    Critical
    Gui 13:Default
    GuiControlGet fctrl, Focus
    If (fctrl="Edit2") {
        ControlGetText comm, Edit2, A
        comm2:=StringToAnotherLayout(comm, InputLayout(), 0x409)
        If (StrLen(comm2)=StrLen(comm)) {
            GuiControl,, hse, % comm2
            GuiControl,, all_lang, 1
        }
        Else {
            ToolTip Неверная раскладка!
            SetTimer ToolTip, -1500
        }
    }
    Return

#If

13GuiClose:
    Gui 13:Destroy
    Return

#If WinActive("ahk_id" hwnd13)
Esc::Goto 13GuiClose
#If

Charmap:
    Try {
        Run %ComSpec% /c charmap,, Hide
        WinWait ahk_exe charmap.exe
        WinSet AlwaysOnTop
    }
    Catch {
        ToolTip Отсутствует в`nоперационной системе
        SetTimer ToolTip, -1500
    }
    Return

HotkeyGui:
    Gui 15:Destroy
    Gui 15:Font, s8
    Gui 15:Margin, 10, 6
    Gui 15:+Owner13 +AlwaysOnTop +LastFound +ToolWindow +Hwndhwnd15
    Gui 15:Add, Text,, Введите сочетание клавиш:
    Gui 15:Add, Edit, x10 r1 w120 vh_key
    Gui 15:Add, Text, x+4 yp+4, Код:
    Gui 15:Add, Edit, x+4 yp-4 r1 w120 vh_code
    Gui 15:Add, Button, x52 w60 g15GuiClose, Cancel
    Gui 15:Add, Button, x+4 w60 gKeys, Help
    Gui 15:Add, Button, wp hp x+4 yp gCopy, Copy
    Gui 15:Show,, LangBar++
    SetTimer KeyHook, -200
    Return

KeyHook:
    While WinExist("ahk_id" hwnd15) {
        SetInputLayout(0, 0x0409)
        kh:=InputHook()
        kh.VisibleNonText:=false
        kh.KeyOpt("{All}", "E")
        kh.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
        kh.Start()
        ErrorLevel:=kh.Wait()
        k_mod:=StrReplace(kh.EndMods, "<"), vcode:=Format("vk{:X}", GetKeyVK(kh.EndKey))
        h_key:=((StrLen(kh.EndKey)>1) || (kh.EndKey~="^\d$")) ? kh.EndKey : vcode
        mod:=StrReplace(k_mod, ">"),
        mod:=StrReplace(mod, "+", "Shift+"),
        mod:=StrReplace(mod, "^", "Ctrl+"),
        mod:=StrReplace(mod, "!", "Alt+"),
        mod:=StrReplace(mod, "#", "Win+")
        Gui 15:Default
        GuiControl,, h_key, % mod . Format("{:U}",  GetKeyName(vcode))
        GuiControl,, h_code, % k_mod "{" h_key "}"
    }
    Exit

Copy:
    Gui 15:Submit, NoHide
    GuiControlGet key_var,, h_code
    Clipboard:="{" key_var "}"

15GuiClose:
    Gui 15:Destroy
    Sleep 50
    kh.Stop()
    Return

#If WinActive("ahk_id" hwnd15)
Esc::Goto 15GuiClose
#If

Keys:
    If !FileExist(A_ScriptDir "\doc\Keys.html") {
        MsgBox, 16, , Отсутствует файл справки!, 2
        Return
    }
    Gui 16:Destroy
    wh:=A_ScreenWidth*2//3, ht:=A_ScreenHeight*5//6
    Gui 16:+Owner15 -DPIScale +AlwaysOnTop +LastFound +ToolWindow +HwndGui16
    Gui 16:Add, ActiveX, w%wh% h%ht% vWB, Shell.Explorer
    WB.Silent:=True
    WB.Navigate(A_ScriptDir "\doc\Keys.html")
    Gui 16:Show,, Горячие клавиши
    Return

Variables:
    If !FileExist(A_ScriptDir "\doc\Variables.html") {
        MsgBox, 16, , Отсутствует файл справки!, 2
        Return
    }
    Gui 16:Destroy
    wh:=A_ScreenWidth*2//3, ht:=A_ScreenHeight*5//6
    Gui 16:+Owner13 -DPIScale +AlwaysOnTop +LastFound +ToolWindow +HwndGui16
    Gui 16:Add, ActiveX, w%wh% h%ht% vWB, Shell.Explorer
    WB.Silent:=True
    WB.Navigate(A_ScriptDir "\doc\Variables.html")
    Gui 16:Show,, Переменные
    Return

16GuiClose:
    Gui 16:Destroy
    Return

#If WinActive("ahk_id" Gui16)
Esc::Goto 16GuiClose
#If

Preview:
    KeyWait LButton
    Gui 13:Submit, Nohide
    repeat:=replacement
    Gui 14:Destroy
    Gui 14:Margin, 10, 6
    Gui 14:Font, s12
    Gui 14:+Owner13 +AlwaysOnTop +LastFound +ToolWindow +HwndGui14
    Gui 14:Add, Edit, r10 w720 vpreview
    Gui 14:Font, s10
    Gui 14:Add, Button, x80 w220 h24 gPreviewUpdate, Обновить (F5)
    Gui 14:Add, Button, x+140 wp hp gPreviewClose, Закрыть
    Gui 14:Show,, Предпросмотр
    Sleep 300
    Goto LoadPreview

PreviewClose:
    Gui 14:Destroy
    Return

#If WinActive("ahk_id" Gui14)
Esc::Goto PreviewClose

F5::
PreviewUpdate:
    Gui 14:Default
    GuiControl Focus, preview
    GuiControl,, preview, % ""
    Goto LoadPreview
#If

HS_Save:
    Gui 13:Submit, Nohide
    If !hse || !replacement {
        ToolTip Пустые поля!, % A_ScreenWidth//2-50, % A_ScreenHeight//2-50
        SetTimer ToolTip, -1000
        Return
    }
    hse2:=RegExReplace(hse, "\s.*")
    If all_lang && (hse2~="[^[:ascii:]]") {
        ToolTip Для работы со всеми раскладками в строке`nввода допустимы только английские символы!, % A_ScreenWidth//2-200, A_ScreenHeight//2-50
        SetTimer ToolTip, -3000
        Return
    }
    If case_copy && (replacement~="(\{[!\^+#<>]*\{[\w+ ]+}}|%A_\w+%|Clips\\\d{10,})") {
        ToolTip Учет регистра сокращения несовместим с`nиспользованием переменных`, посылкой клавиш и`nвставкой из буфера обмена!, % A_ScreenWidth//2-200, A_ScreenHeight//2-50
        SetTimer ToolTip, -3000
        Return
    }
    If add_rule {
        Loop % hs.Length() {
            If (hse==hs[A_Index, 2]) {
                ToolTip Дубликат правила %A_Index%!, % A_ScreenWidth//2-100, A_ScreenHeight//2
                SetTimer ToolTip, -2000
                Return
            }
        }
    }
    Gui 13:Destroy
    opt:="",
    opt.=all_lang ? 1 : 0,
    opt.=exact ? 1 : 0,
    opt.=in_word ? 1 : 0,
    opt.=case_copy ? 1 : 0
    If (lang_n>1)
        opt.="-" lang_array[lang_n-1, 1]
    Gui 12:Default
    If add_rule {
        new_rule:=LV_GetNext(, "F") ? LV_GetNext(, "F")+1 : LV_GetCount()+1
        LV_Insert(new_rule, "Check", new_rule, hse, hscomm, opt, replacement)
        Loop % LV_GetCount()-new_rule
            LV_Modify(new_rule+A_Index,, new_rule+A_Index )
    }
    Else
        LV_Modify(row,,, hse, hscomm, opt, replacement)
    Return

ClipSave:
    FileCreateDir Clips
    clipfile:="Clips\" A_Now
    FileAppend % ClipboardAll, % clipfile
    Sleep 100
    FileGetSize fsize, % clipfile
    If !fsize {
        ToolTip Буфер обмена пуст!
        FileDelete % clipfile
        SetTimer ToolTip, -1500
        Return
    }
    fsize:=(fsize>1000000) ? Format("{:.3f}", fsize/1000000) " MB" : Format("{:.f}", fsize/1000) " KB"
    GuiControl,, replacement, % clipfile "  (" fsize ")"
    Return

ClipLoad:
    Critical
    st_load:=A_TickCount
    GuiControlGet clip ,, replacement
    If !RegExMatch(clip, "Clips\\\d{10,}", clipfile) {
        ToolTip Нет ссылок на файл!
        SetTimer ToolTip, -1500
        Return
    }
    If !FileExist(clipfile) {
        ToolTip Отсутствует файл!
        SetTimer ToolTip, -1500
        Return
    }
    Clipboard:=""
    FileRead, Clipboard, % "*c " clipfile
    ClipWait 3, 1
    If !ErrorLevel {
        tload:=A_TickCount-st_load
        ToolTip % "Буфер загружен за " tload " мс"
    }
    SetTimer ToolTip, -1500
    Return