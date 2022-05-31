; Скрипт создан через Мастер Inno Setup Script.
; ИСПОЛЬЗУЙТЕ ДОКУМЕНТАЦИЮ ДЛЯ ПОДРОБНОСТЕЙ ИСПОЛЬЗОВАНИЯ INNO SETUP!

#define MyAppName "LangBar++"
#define MyAppVersion GetFileVersion("LangBarXX.exe")
;#define MyAppPublisher "Horns'n'Hoofs Inc., Minsk, 2022"
#define MyAppURL "https://github.com/Krot66/LangBarXX"

[Setup]
; Примечание: Значение AppId идентифицирует это приложение.
; Не используйте одно и тоже значение в разных установках.
; (Для генерации значения GUID, нажмите Инструменты | Генерация GUID.)
AppId={{E64D3F85-C325-4133-9394-B3D65E1B1710}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={pf}\LangBarXX
DefaultGroupName={#MyAppName}
LicenseFile=_Installer\LGPL-3.0.txt
;InfoBeforeFile=Before.txt
Uninstallable=not IsTaskSelected('portablemode')
OutputDir=D:\Soft\LangBarXX
OutputBaseFilename=LangBarXX_setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=none
ArchitecturesInstallIn64BitMode=x64 ia64
WizardImageFile=_Installer\WizModernImage-IS.bmp
WizardSmallImageFile=_Installer\WizModernSmallImage-IS.bmp
SetupIconFile=_Installer\LB.ico

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: portablemode; Description:  "Портативная версия"; Flags: unchecked
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone

[Files]
Source: "LangBarXX64.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "LangBarXX.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "LB_WatchDog.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "portable.dat"; DestDir: "{app}"; Check: IsTaskSelected('portablemode');Flags: ignoreversion
Source: "ReadMe.html"; DestDir: "{app}"; Flags: ignoreversion
Source: "{app}\flags\*"; DestDir: "{app}\flags_old"; Flags: external skipifsourcedoesntexist
Source: "{app}\masks\*"; DestDir: "{app}\masks_old"; Flags: external skipifsourcedoesntexist
Source: "flags\*"; DestDir: "{app}\flags"; Flags: ignoreversion
Source: "masks\*"; DestDir: "{app}\masks"; Flags: ignoreversion
Source: "ReadMe.assets\*"; DestDir: "{app}\ReadMe.assets"; Flags: ignoreversion
Source: "{src}\flags\*"; DestDir: "{app}\flags"; Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\masks\*"; DestDir: "{app}\masks"; Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\LangBarXX.ini"; DestDir: "{userappdata}\LangBarXX"; Check: not IsTaskSelected('portablemode'); Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\LangBarXX.ini"; DestDir: "{app}\LangBarXX"; Check: IsTaskSelected('portablemode'); Flags: external skipifsourcedoesntexist ignoreversion
; Примечание: Не используйте "Flags: ignoreversion" для системных файлов

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\LangBarXX.exe"; Check: not IsTaskSelected('portablemode') and not Is64BitInstallMode
Name: "{group}\{#MyAppName}"; Filename: "{app}\LangBarXX64.exe"; Check: not IsTaskSelected('portablemode') and Is64BitInstallMode
Name: "{group}\ReadMe"; Filename: "{app}\ReadMe.html"; Check: not IsTaskSelected('portablemode')
Name: "{group}\Удаление"; Filename: "{uninstallexe}"; Check: not IsTaskSelected('portablemode')
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\LangBarXX.exe"; Tasks: desktopicon; Check: not IsTaskSelected('portablemode') and not Is64BitInstallMode
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\LangBarXX64.exe"; Tasks: desktopicon; Check: not IsTaskSelected('portablemode') and Is64BitInstallMode

[Run]
Filename: "{app}\LangBarXX.exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Check: not IsTaskSelected('portablemode') and not Is64BitInstallMode; Flags: nowait postinstall
Filename: "{app}\LangBarXX64.exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Check: not IsTaskSelected('portablemode') and Is64BitInstallMode; Flags: nowait postinstall

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "LangBarXX"; ValueData: """{app}\LangBarXX.exe"""; Check: not IsTaskSelected('portablemode') and not Is64BitInstallMode; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "LangBarXX"; ValueData: """{app}\LangBarXX64.exe"""; Check: not IsTaskSelected('portablemode') and Is64BitInstallMode; Flags: uninsdeletevalue


[UninstallRun]
Filename: "taskkill"; Parameters: "/im ""LB_WatchDog.exe"" /f"; Flags: runhidden
Filename: "taskkill"; Parameters: "/im ""LangBarXX.exe"" /f"; Flags: runhidden
Filename: "taskkill"; Parameters: "/im ""LangBarXX64.exe"" /f"; Flags: runhidden

[UninstallDelete]
Type: files; Name: "{userappdata}\LangBarXX\*.*"
Type: dirifempty; Name: "{userappdata}\LangBarXX"
