#define MyAppName "LangBarXX"
#define MyAppVersion GetFileVersion("LangBarXX.exe")
;#define MyAppPublisher "Horns'n'Hoofs Inc., Minsk, 2022"
#define MyAppURL "https://github.com/Krot66/LangBarXX"

[Setup]
; Примечание: Значение AppId идентифицирует это приложение.
; Не используйте одно и тоже значение в разных установках.
; (Для генерации значения GUID, нажмите Инструменты | Генерация GUID)
AppId={{E64D3F85-C325-4133-9394-B3D65E1B1710}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
UsePreviousAppDir=yes
DefaultDirName={code:GetDefRoot}\LangBarXX
DefaultGroupName={#MyAppName}
LicenseFile=_Installer\LGPL-3.0.txt
;InfoBeforeFile=Before.txt
Uninstallable=not IsTaskSelected('portablemode')
OutputDir=D:\Soft\LangBarXX
OutputBaseFilename=LangBarXX_setup
DisableDirPage=auto
SolidCompression=yes
PrivilegesRequired=none
ArchitecturesInstallIn64BitMode=x64 ia64
WizardImageFile=_Installer\WizModernImage-IS.bmp
WizardSmallImageFile=_Installer\WizModernSmallImage-IS.bmp
SetupIconFile=_Installer\Install.ico
ShowLanguageDialog=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: portablemode; Description:  "Portable version"; Flags: unchecked
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone

[Types]
Name: "standard"; Description: "Standard (En-Ru) installation"
Name: "full"; Description: "Full installation"
Name: "minimal"; Description: "Minimal installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "program"; Description: "Program Files"; Types: full standard minimal custom; Flags: fixed
Name: "hunspell"; Description: "Hunspell-based autocorrect"; Types: full standard
Name: "hunspell\en"; Description: "English dictionary"; Types: full standard
Name: "hunspell\fr"; Description: "French dictionary"; Types: full
Name: "hunspell\de"; Description: "Deutch dictionary"; Types: full
Name: "hunspell\ru"; Description: "Russian dictionary"; Types: full standard
Name: "hunspell\be"; Description: "Belarussian dictionary"; Types: full
Name: "hunspell\uk"; Description: "Ukrainian dictionary"; Types: full


[Files]
Source: "LangBarXX64.exe"; DestDir: "{app}"; Components: program; Flags: ignoreversion
Source: "LangBarXX.exe"; DestDir: "{app}"; Components: program; Flags: ignoreversion
Source: "doc\*"; DestDir: "{app}\doc"; Components: program; Flags: ignoreversion recursesubdirs
Source: "{app}\masks\*"; DestDir: "{app}\masks_old"; Components: program; Flags: external skipifsourcedoesntexist
Source: "masks\*"; DestDir: "{app}\masks"; Components: program; Flags: ignoreversion
Source: "{app}\cursors\*"; DestDir: "{app}\cursors_old"; Components: program; Flags: external skipifsourcedoesntexist
Source: "cursors\*"; DestDir: "{app}\cursors"; Components: program; Flags: ignoreversion

Source: "{app}\flags\*"; DestDir: "{app}\flags_old"; Components: program; Flags: external skipifsourcedoesntexist
Source: "flags\*"; DestDir: "{app}\flags"; Components: program; Flags: ignoreversion

Source: "hunspell\*"; DestDir: "{app}\hunspell"; Components: hunspell; Flags: ignoreversion
Source: "sounds\*"; DestDir: "{app}\sounds"; Components: program; Flags: ignoreversion

Source: "dict\en-US\*"; DestDir: "{app}\dict\en-US"; Components: hunspell\en; Flags: ignoreversion recursesubdirs
Source: "dict\fr-FR\*"; DestDir: "{app}\dict\fr-FR"; Components: hunspell\fr; Flags: ignoreversion recursesubdirs
Source: "dict\de-DE\*"; DestDir: "{app}\dict\de-DE"; Components: hunspell\de; Flags: ignoreversion recursesubdirs
Source: "dict\ru-RU\*"; DestDir: "{app}\dict\ru-RU"; Components: hunspell\ru; Flags: ignoreversion recursesubdirs
Source: "dict\be-BY\*"; DestDir: "{app}\dict\be-BY"; Components: hunspell\be; Flags: ignoreversion recursesubdirs
Source: "dict\uk-UA\*"; DestDir: "{app}\dict\uk-UA"; Components: hunspell\uk; Flags: ignoreversion recursesubdirs

; Import
Source: "{src}\flags\*"; DestDir: "{app}\flags"; Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\masks\*"; DestDir: "{app}\masks"; Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\config\*"; DestDir: "{userappdata}\LangBarXX"; Check: not IsTaskSelected('portablemode'); Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\config\*"; DestDir: "{app}\config"; Check: IsTaskSelected('portablemode'); Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\Clips\*"; DestDir: "{app}\Clips"; Flags: external skipifsourcedoesntexist ignoreversion
Source: "{src}\dict\*"; DestDir: "{app}\dict"; Flags: external skipifsourcedoesntexist ignoreversion

[Dirs]
Name: "{app}\config"; Check: IsTaskSelected('portablemode')

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\LangBarXX.exe"; Check: not IsTaskSelected('portablemode') and not Is64BitInstallMode
Name: "{group}\{#MyAppName}"; Filename: "{app}\LangBarXX64.exe"; Check: not IsTaskSelected('portablemode') and Is64BitInstallMode
Name: "{group}\ReadMe"; Filename: "{app}\doc\ReadMe.html"; Check: not IsTaskSelected('portablemode')
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"; Check: not IsTaskSelected('portablemode')
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

[Code]
function GetDefRoot(Param: String): String;
begin
  if not IsAdminLoggedOn then
    Result := ExpandConstant('{localappdata}')
  else
    Result := ExpandConstant('{pf}')
end;

