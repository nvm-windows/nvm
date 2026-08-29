#ifndef Version
  #error "Version is required. Build with /DVersion=x.y.z"
#endif

#ifndef AppId
  #error "AppId is required. Build with /DAppId=your-guid"
#endif

#ifndef Alias
  #error "Alias is required. Build with /DAlias=your-alias"
#endif

#ifndef Name
  #error "Name is required. Build with /DName=your-app-name"
#endif

#ifndef Description
  #error "Description is required. Build with /DDescription=your-description"
#endif

#ifndef URL
  #error "URL is required. Build with /DURL=https://example.com"
#endif

#ifndef Publisher
  #error "Publisher is required. Build with /DPublisher=your.publisher"
#endif

#ifndef OrgLabel
  #error "OrgLabel is required. Build with /DOrgLabel=your-org-label"
#endif

#ifndef Architecture
  #define Architecture "amd64"
#endif

#ifndef VersionInfoVersion
  #error "VersionInfoVersion is required. Build with /DVersionInfoVersion=a.b.c.d"
#endif

#define ProjectRoot SourcePath
#define Icon "assets\\" + Alias + ".ico"
#define RegistryKey "Software\\" + OrgLabel + "\\Preferences\\" + Alias
#define SyncTaskName Name + " Sync"
#define SyncExeBuildPath "..\\bin\\utils\\sync.exe"
#define IconFullPath AddBackslash(ProjectRoot) + Icon
#define IconErrorMessage "Icon file not found: " + IconFullPath
#ifndef OutputFileName
  #define OutputFileName Alias + "-" + Version + "-" + Architecture + "-setup"
#endif

#pragma message IconErrorMessage

#ifnexist IconFullPath
  #error IconErrorMessage
#endif

[Setup]
PrivilegesRequired=lowest
CloseApplications=yes
CloseApplicationsFilter=*.exe
AppId={#AppId}
AppName={#Name}
AppVersion={#Version}
AppVerName={#Name} {#Version}
AppPublisher={#Publisher}
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DefaultDirName={localappdata}\{#OrgLabel}\{#Alias}
UsePreviousAppDir=no
LicenseFile={#ProjectRoot}\LICENSE
OutputDir={#ProjectRoot}\..\.dist\
OutputBaseFilename={#OutputFileName}
; OutputBaseFilename={#Alias}-setup-{#Version}.{#GetDateTimeString('yyyymmddHHnnss', '', '')}
SetupIconFile={#ProjectRoot}\{#Icon}
UninstallDisplayName={#Name}
UninstallDisplayIcon={app}\{#Alias}.exe
WizardImageFile={#ProjectRoot}\assets\left-banner.png
WizardStyle=classic
Compression=lzma
SolidCompression=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=no
VersionInfoVersion={#VersionInfoVersion}
VersionInfoCompany={#Publisher}
VersionInfoDescription={#Description}
VersionInfoProductName={#Name}
VersionInfoProductTextVersion={#Version}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=[name] Setup Wizard

[Registry]
; Register nvm protocol
Root: HKCU; Subkey: "Software\Classes\{#Alias}"; ValueType: string; ValueName: ""; ValueData: "URL:{#Alias}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\{#Alias}"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\{#Alias}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#Alias}.exe,0"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\{#Alias}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#Alias}.exe"" ""%1"""; Flags: uninsdeletekey

; Register AUMID for Windows notification center integration
Root: HKCU; Subkey: "Software\Classes\AppUserModelId\AuthorSoftware.NVMWindows"; ValueType: string; ValueName: "DisplayName"; ValueData: "{#Name}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\AppUserModelId\AuthorSoftware.NVMWindows"; ValueType: string; ValueName: "IconUri"; ValueData: "{app}\.icons\{#Alias}.ico"; Flags: uninsdeletekey

; Runtime settings under HKCU\{#RegistryKey}
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "Enabled"; ValueData: "1"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "InstallRoot"; ValueData: "{code:GetInstallRoot}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "ActiveVersion"; ValueData: "{code:GetActiveVersionRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "OperatingMode"; ValueData: "{code:GetOperatingModeRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: multisz; ValueName: "MirrorNode"; ValueData: "{code:GetNodeMirrorRegistryValue}"; Flags: uninsdeletevalue; Check: ShouldWriteNodeMirror
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: multisz; ValueName: "MirrorNpm"; ValueData: "{code:GetNpmMirrorRegistryValue}"; Flags: uninsdeletevalue; Check: ShouldWriteNpmMirror
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: multisz; ValueName: "AutoDetect"; ValueData: "{code:GetAutoDetectRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "DisableAutoUpgrade"; ValueData: "0"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "AutoUse"; ValueData: "{code:GetAutoUseRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "CacheDownloads"; ValueData: "{code:GetCacheDownloadsRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "AutoInstall"; ValueData: "{code:GetAutoInstallRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "AutoInstallPrompt"; ValueData: "{code:GetAutoInstallPromptRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "AllowInsecureDownloads"; ValueData: "{code:GetAllowInsecureDownloadsRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "AnnounceNVM"; ValueData: "1"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: dword; ValueName: "AnnounceAuthor"; ValueData: "1"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "LastUpdateCheck"; ValueData: "{code:GetCurrentDateTimeRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "LastNewsCheck"; ValueData: "{code:GetCurrentDateTimeRegistryValue}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "ReleaseFeedURL"; ValueData: "https://updates.nvm-windows.com/releases"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "NewsFeedURL"; ValueData: "https://updates.nvm-windows.com/news"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "{#RegistryKey}"; ValueType: string; ValueName: "PackageManagerMismatchAction"; ValueData: "error"; Flags: uninsdeletevalue

; Per-user environment variables for runtime discovery.
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "NVM_HOME"; ValueData: "{app}"; Flags: uninsdeletevalue

[Dirs]
Name: "{code:GetInstallRoot}"
Name: "{app}\.sync"; Attribs: hidden
Name: "{app}\.shim"; Attribs: hidden
Name: "{app}\.link"; Attribs: hidden
Name: "{app}\.icons"; Attribs: hidden
Name: "{app}\utils"; Attribs: hidden

[Files]
Source: "..\bin\nvm.exe"; DestDir: "{app}"; Flags: ignoreversion
; ETW provider assets for nvm --register-eventlog (wevtutil). Must sit next to nvm.exe.
Source: "..\bin\NVMWindows.Events.man"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\NVMWindows.Events.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\utils\*"; DestDir: "{app}\utils"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\bin\.shim\*"; DestDir: "{app}\.shim"; Flags: ignoreversion recursesubdirs createallsubdirs
#ifexist SyncExeBuildPath
Source: "..\bin\.sync\*"; DestDir: "{app}\.sync"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
#endif
Source: "updater\bin\nvm-upgrader.exe"; DestDir: "{tmp}"; Flags: ignoreversion deleteafterinstall
Source: "{#ProjectRoot}\{#Icon}"; DestDir: "{app}\.icons"; DestName: "{#Alias}.ico"; Flags: ignoreversion

[Icons]
Name: "{userprograms}\{#Name}"; Filename: "{app}\{#Alias}.exe"; IconFilename: "{app}\.icons\{#Alias}.ico"; Comment: "Node Version Manager"; AppUserModelID: "AuthorSoftware.NVMWindows"
Name: "{userprograms}\{#Name}\Sync"; Filename: "{app}\utils\sync.exe"; IconFilename: "{app}\.icons\{#Alias}.ico"; Comment: "Background synchronization service"; AppUserModelID: "AuthorSoftware.NVMWindows"

[UninstallRun]
Filename: "{cmd}"; Parameters: "/C schtasks /Delete /TN ""{#SyncTaskName}"" /F"; Flags: runhidden; RunOnceId: "RemoveNVMSyncTask"

[Code]
var
  NodeStoragePage: TInputDirWizardPage;
  OperatingModePage: TInputOptionWizardPage;
  PreferencesPage: TInputOptionWizardPage;
  EmailPage: TWizardPage;
  EmailEdit: TEdit;
  EmailLabel: TLabel;
  EmailPlaceholder: String;
  EmailFirstFocus: Boolean;
  DetectedActiveVersion: String;
  PreviousInstallRoot: String;
  MigrationPerformed: Boolean;
  MigrationSource: String;
  MigrationDest: String;
  InstallCompleted: Boolean;
  RemoveLegacyTasks: Boolean;
  IsPreV2Upgrade: Boolean;
  IsConcreteLegacyUpgrade: Boolean;
  LegacyInstallDir: String;
  LegacySettingsLoaded: Boolean;
  LegacySettingsRoot: String;
  LegacySettingsPath: String;
  LegacySettingsNodeMirror: String;
  LegacySettingsNpmMirror: String;
  LegacyNodeMirrorFound: Boolean;
  LegacyNpmMirrorFound: Boolean;
  InstallLogPath: String;
  InstallLogBuffer: String;
  InstallLogHasIssues: Boolean;
  SkippedSymlinkLogPath: String;
  SkippedSymlinkLogBuffer: String;
  SkippedSymlinkCount: Integer;
  WizardDefaultInstallRoot: String;
  WizardDefaultUseLinkMode: Boolean;
  WizardDefaultCacheDownloads: Boolean;
  WizardDefaultAutoDetect: Boolean;
  WizardDefaultAutoInstall: Boolean;
  WizardDefaultAutoInstallPrompt: Boolean;
  WizardDefaultRequireTls: Boolean;
  LegacyCleanupWarnings: String;
  UninstallInstallRoot: String;
  UninstallAppRoot: String;

const
  WM_SETTINGCHANGE = $001A;
  SMTO_ABORTIFHUNG = 2;
  WindowsAppsUninstallRoot = 'Software\Microsoft\Windows\CurrentVersion\Uninstall';
  SyncTaskName = '{#SyncTaskName}';

function SendMessageTimeoutW(hWnd: HWND; Msg: UINT; wParam: UINT; lParam: String;
  fuFlags: UINT; uTimeout: UINT; var lpdwResult: DWORD): DWORD;
  external 'SendMessageTimeoutW@user32.dll stdcall';

function NormalizePath(const PathValue: String): String; forward;
procedure SplitPathString(const PathStr: String; var Segments: TArrayOfString); forward;
function ExpandPathSegment(const Segment: String): String; forward;

procedure BroadcastEnvironmentChange();
var
  MsgResult: DWORD;
begin
  MsgResult := 0;
  SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment',
    SMTO_ABORTIFHUNG, 5000, MsgResult);
end;

procedure ResetInstallLog();
begin
  InstallLogPath := ExpandConstant('{app}\install.log');
  InstallLogBuffer := 'NVM for Windows install log' + #13#10;
  InstallLogHasIssues := False;
end;

procedure AppendInstallLog(const Message: String);
begin
  if InstallLogPath = '' then
    Exit;
  InstallLogBuffer := InstallLogBuffer + Message + #13#10;
end;

procedure AppendInstallLogWarn(const Message: String);
begin
  InstallLogHasIssues := True;
  AppendInstallLog(Message);
end;

procedure FlushInstallLog();
begin
  if (InstallLogPath = '') or not InstallLogHasIssues then
    Exit;
  DeleteFile(InstallLogPath);
  SaveStringToFile(InstallLogPath, InstallLogBuffer, False);
end;

procedure ResetLegacyCleanupWarnings();
begin
  LegacyCleanupWarnings := '';
end;

procedure AppendLegacyCleanupWarning(const Message: String);
begin
  if Message = '' then
    Exit;

  if LegacyCleanupWarnings = '' then
    LegacyCleanupWarnings := Message
  else
    LegacyCleanupWarnings := LegacyCleanupWarnings + #13#10 + Message;

  AppendInstallLogWarn('Legacy cleanup: ' + Message);
end;

function HasLegacyCleanupWarnings(): Boolean;
begin
  Result := Trim(LegacyCleanupWarnings) <> '';
end;

procedure ResetSkippedSymlinkLog();
begin
  SkippedSymlinkLogPath := ExpandConstant('{app}\symlinks.log');
  SkippedSymlinkLogBuffer :=
    'NVM for Windows could not recreate the following migrated links automatically.' + #13#10 +
    'Run these commands manually after setup if you still need the links.' + #13#10 + #13#10;
  SkippedSymlinkCount := 0;
  if SkippedSymlinkLogPath <> '' then
    DeleteFile(SkippedSymlinkLogPath);
end;

procedure AppendSkippedSymlink(const SourcePath, CommandLine, FailureReason: String);
begin
  if (SourcePath = '') and (CommandLine = '') then
    Exit;

  SkippedSymlinkCount := SkippedSymlinkCount + 1;
  if SourcePath <> '' then
    SkippedSymlinkLogBuffer := SkippedSymlinkLogBuffer + 'Source: ' + SourcePath + #13#10;
  if CommandLine <> '' then
    SkippedSymlinkLogBuffer := SkippedSymlinkLogBuffer + CommandLine + #13#10;
  if FailureReason <> '' then
    SkippedSymlinkLogBuffer := SkippedSymlinkLogBuffer + 'Reason: ' + FailureReason + #13#10;
  SkippedSymlinkLogBuffer := SkippedSymlinkLogBuffer + #13#10;

  AppendInstallLogWarn('Automatic junction recreation failed for ' + SourcePath + ': ' + FailureReason);
end;

procedure FlushSkippedSymlinkLog();
begin
  if SkippedSymlinkLogPath = '' then
    Exit;

  if SkippedSymlinkCount = 0 then
  begin
    DeleteFile(SkippedSymlinkLogPath);
    Exit;
  end;

  DeleteFile(SkippedSymlinkLogPath);
  SaveStringToFile(SkippedSymlinkLogPath, SkippedSymlinkLogBuffer, False);
end;

function HasSkippedSymlinks(): Boolean;
begin
  Result := SkippedSymlinkCount > 0;
end;

function EscapeSingleQuotedPowerShellString(const Value: String): String;
begin
  Result := Value;
  StringChangeEx(Result, '''', '''''', True);
end;

function EscapeDoubleQuotedCommandArgument(const Value: String): String;
begin
  Result := Value;
  StringChangeEx(Result, '"', '""', True);
end;

function BuildMklinkJunctionCommand(const LinkPath, TargetPath: String): String;
begin
  Result :=
    'cmd.exe /C mklink /J "' + EscapeDoubleQuotedCommandArgument(LinkPath) +
    '" "' + EscapeDoubleQuotedCommandArgument(TargetPath) + '"';
end;

function PathIsUnderOrEqualRoot(const Candidate, Root: String): Boolean;
var
  NormCandidate: String;
  NormRoot: String;
begin
  NormRoot := LowerCase(NormalizePath(Root));
  if NormRoot = '' then
  begin
    Result := True;
    Exit;
  end;

  NormCandidate := LowerCase(NormalizePath(Candidate));
  if CompareText(NormCandidate, NormRoot) = 0 then
  begin
    Result := True;
    Exit;
  end;

  Result :=
    (Length(NormCandidate) > Length(NormRoot)) and
    (Copy(NormCandidate, 1, Length(NormRoot) + 1) = NormRoot + '\');
end;

function ExtractNodeVersionFromDirectoryPath(const PathValue: String): String;
var
  Name: String;
  I: Integer;
begin
  Result := '';
  Name := ExtractFileName(NormalizePath(PathValue));
  if (Length(Name) > 0) and ((Name[1] = 'v') or (Name[1] = 'V')) then
    Delete(Name, 1, 1);
  Name := Trim(Name);
  if Name = '' then
    Exit;

  for I := 1 to Length(Name) do
  begin
    if not (((Name[I] >= '0') and (Name[I] <= '9')) or (Name[I] = '.')) then
      Exit;
  end;

  if (Name[1] < '0') or (Name[1] > '9') then
    Exit;

  Result := Name;
end;

{ Resolve a junction/symlink target without executing anything under that path. }
function ResolveReparseTarget(const LinkPath: String): String;
var
  ScriptFile: String;
  ResultFile: String;
  ScriptText: String;
  ScriptOutput: AnsiString;
  ResultCode: Integer;
  FindRec: TFindRec;
  Attr: Integer;
begin
  Result := '';

  if not DirExists(LinkPath) then
    Exit;

  if FindFirst(LinkPath, FindRec) then
  begin
    Attr := FindRec.Attributes;
    FindClose(FindRec);
  end
  else
    Attr := -1;

  if (Attr = -1) or ((Attr and FILE_ATTRIBUTE_REPARSE_POINT) = 0) then
    Exit;

  ScriptFile := ExpandConstant('{tmp}\nvm-resolve-symlink.ps1');
  ResultFile := ExpandConstant('{tmp}\nvm-resolve-symlink-result.txt');
  DeleteFile(ResultFile);

  ScriptText :=
    '$link = ''' + EscapeSingleQuotedPowerShellString(LinkPath) + '''' + #13#10 +
    '$resultFile = ''' + EscapeSingleQuotedPowerShellString(ResultFile) + '''' + #13#10 +
    'try {' + #13#10 +
    '  $item = Get-Item -LiteralPath $link -Force -ErrorAction Stop' + #13#10 +
    '  $target = $item.Target' + #13#10 +
    '  if ($null -eq $target) { throw "Link target not available." }' + #13#10 +
    '  if ($target -is [array]) { $target = $target[0] }' + #13#10 +
    '  $target = [string]$target' + #13#10 +
    '  if ([string]::IsNullOrWhiteSpace($target)) { throw "Link target is empty." }' + #13#10 +
    '  if (-not [System.IO.Path]::IsPathRooted($target)) {' + #13#10 +
    '    $target = Join-Path -Path (Split-Path -Parent $link) -ChildPath $target' + #13#10 +
    '  }' + #13#10 +
    '  $target = [System.IO.Path]::GetFullPath($target)' + #13#10 +
    '  [System.IO.File]::WriteAllText($resultFile, $target)' + #13#10 +
    '  exit 0' + #13#10 +
    '} catch {' + #13#10 +
    '  exit 1' + #13#10 +
    '}' ;

  SaveStringToFile(ScriptFile, ScriptText, False);
  if not Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + ScriptFile + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    DeleteFile(ScriptFile);
    Exit;
  end;

  if (ResultCode = 0) and LoadStringFromFile(ResultFile, ScriptOutput) then
    Result := Trim(String(ScriptOutput));

  DeleteFile(ScriptFile);
  DeleteFile(ResultFile);
end;

{ Derive the v1 active Node version from NVM_SYMLINK metadata only. }
{ Never execute legacy node.exe — a replaced junction must not run code. }
function GetNodeVersionFromSymlinkEnv(const SymlinkPath: String): String;
var
  TargetPath: String;
  TrustedRoot: String;
begin
  Result := '';

  TargetPath := ResolveReparseTarget(Trim(SymlinkPath));
  if TargetPath = '' then
    Exit;

  TrustedRoot := Trim(LegacySettingsRoot);
  if (TrustedRoot <> '') and (not PathIsUnderOrEqualRoot(TargetPath, TrustedRoot)) then
    Exit;

  { Presence check only — do not execute this binary. }
  if not FileExists(AddBackslash(TargetPath) + 'node.exe') then
    Exit;

  Result := ExtractNodeVersionFromDirectoryPath(TargetPath);
end;

procedure DeleteLegacySymlinkEnv();
begin
  RegDeleteValue(HKCU, 'Environment', 'NVM_SYMLINK');
  RegDeleteValue(HKLM, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'NVM_SYMLINK');
end;

procedure CaptureLegacyActiveVersionFromSymlink();
var
  SymlinkPath: String;
begin
  DetectedActiveVersion := '';
  SymlinkPath := Trim(GetEnv('NVM_SYMLINK'));
  if SymlinkPath = '' then
    Exit;

  DetectedActiveVersion := GetNodeVersionFromSymlinkEnv(SymlinkPath);
  DeleteLegacySymlinkEnv();
end;

function GetActiveVersionRegistryValue(Param: String): String;
begin
  Result := DetectedActiveVersion;

  if Result <> '' then
    Exit;

  if not RegQueryStringValue(HKCU, '{#RegistryKey}', 'ActiveVersion', Result) then
    Result := '';
end;

function GetInstallRoot(Param: String): String;
begin
  Result := ExpandConstant('{localappdata}\{#OrgLabel}\{#Alias}\installs');

  if (NodeStoragePage <> nil) and (Trim(NodeStoragePage.Values[0]) <> '') then
    Result := Trim(NodeStoragePage.Values[0]);
end;

function GetLegacySettingValue(const SettingsText: String; const Key: String): String;
var
  Normalized: String;
  Line: String;
  SearchKey: String;
  P: Integer;
  L: Integer;
begin
  Result := '';
  Normalized := SettingsText;
  SearchKey := LowerCase(Key) + ':';

  while Length(Normalized) > 0 do
  begin
    P := Pos(#10, Normalized);
    if P > 0 then
    begin
      Line := Trim(Copy(Normalized, 1, P - 1));
      Delete(Normalized, 1, P);
    end
    else
    begin
      Line := Trim(Normalized);
      Normalized := '';
    end;

    L := Length(SearchKey);
    if (Length(Line) >= L) and (Copy(LowerCase(Line), 1, L) = SearchKey) then
    begin
      Result := Trim(Copy(Line, L + 1, Length(Line)));
      Exit;
    end;
  end;
end;

procedure LoadLegacySettings();
var
  SettingsText: AnsiString;
  SettingsFile: String;
begin
  LegacySettingsLoaded := False;
  LegacySettingsRoot := '';
  LegacySettingsPath := '';
  LegacySettingsNodeMirror := '';
  LegacySettingsNpmMirror := '';
  LegacyNodeMirrorFound := False;
  LegacyNpmMirrorFound := False;

  if LegacyInstallDir = '' then
    Exit;

  SettingsFile := AddBackslash(LegacyInstallDir) + 'settings.txt';
  if not LoadStringFromFile(SettingsFile, SettingsText) then
    Exit;

  LegacySettingsLoaded := True;
  LegacySettingsRoot := GetLegacySettingValue(String(SettingsText), 'root');
  LegacySettingsPath := GetLegacySettingValue(String(SettingsText), 'path');
  LegacySettingsNodeMirror := GetLegacySettingValue(String(SettingsText), 'node_mirror');
  LegacySettingsNpmMirror := GetLegacySettingValue(String(SettingsText), 'npm_mirror');
  LegacyNodeMirrorFound := Trim(LegacySettingsNodeMirror) <> '';
  LegacyNpmMirrorFound := Trim(LegacySettingsNpmMirror) <> '';
end;

function ParseSettingsTxtRoot(const NvmDir: String): String;
var
  FilePath: String;
  Content: AnsiString;
  ContentStr: String;
  LineStart, LineEnd: Integer;
  Line: String;
  ColonPos: Integer;
begin
  Result := '';
  FilePath := AddBackslash(NvmDir) + 'settings.txt';
  if not FileExists(FilePath) then
    Exit;
  if not LoadStringFromFile(FilePath, Content) then
    Exit;
  ContentStr := String(Content);
  LineStart := 1;
  while LineStart <= Length(ContentStr) do
  begin
    LineEnd := LineStart;
    while (LineEnd <= Length(ContentStr)) and
          (ContentStr[LineEnd] <> #13) and
          (ContentStr[LineEnd] <> #10) do
      LineEnd := LineEnd + 1;
    Line := Trim(Copy(ContentStr, LineStart, LineEnd - LineStart));
    LineStart := LineEnd + 1;
    if (LineStart <= Length(ContentStr)) and
       (ContentStr[LineStart - 1] = #13) and
       (ContentStr[LineStart] = #10) then
      LineStart := LineStart + 1;
    ColonPos := Pos(':', Line);
    if ColonPos > 0 then
    begin
      if CompareText(Trim(Copy(Line, 1, ColonPos - 1)), 'root') = 0 then
      begin
        Result := Trim(Copy(Line, ColonPos + 1, Length(Line)));
        Exit;
      end;
    end;
  end;
end;

function GetLegacyV1NodeStorageRoot(): String;
begin
  Result := Trim(LegacySettingsRoot);
  if Result = '' then
    Result := ExpandConstant('{localappdata}\{#OrgLabel}\{#Alias}\installs');
end;

function GetLegacyV1InstalledVersion(): String;
begin
  Result := '';
  if not RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\nvm_is1', 'DisplayVersion', Result) then
    Result := '';
  Result := Trim(Result);
end;

function ConvertCsvToMultiSz(const Value: String): String;
var
  Remaining: String;
  Part: String;
  P: Integer;
begin
  Result := '';
  Remaining := Trim(Value);
  if Remaining = '' then
    Exit;

  P := Pos(',', Remaining);
  while P > 0 do
  begin
    Part := Trim(Copy(Remaining, 1, P - 1));
    if Part <> '' then
    begin
      if Result = '' then
        Result := Part
      else
        Result := Result + #0 + Part;
    end;
    Delete(Remaining, 1, P);
    P := Pos(',', Remaining);
  end;

  Part := Trim(Remaining);
  if Part <> '' then
  begin
    if Result = '' then
      Result := Part
    else
      Result := Result + #0 + Part;
  end;
end;

function GetNodeMirrorRegistryValue(Param: String): String;
begin
  if IsPreV2Upgrade then
  begin
    if LegacyNodeMirrorFound then
      Result := ConvertCsvToMultiSz(LegacySettingsNodeMirror)
    else
      Result := '';
    Exit;
  end;

  if LegacySettingsLoaded and LegacyNodeMirrorFound then
    Result := ConvertCsvToMultiSz(LegacySettingsNodeMirror)
  else
    Result := 'https://nodejs.org/dist';
end;

function GetNpmMirrorRegistryValue(Param: String): String;
begin
  if IsPreV2Upgrade then
  begin
    if LegacyNpmMirrorFound then
      Result := ConvertCsvToMultiSz(LegacySettingsNpmMirror)
    else
      Result := '';
    Exit;
  end;

  if LegacySettingsLoaded and LegacyNpmMirrorFound then
    Result := ConvertCsvToMultiSz(LegacySettingsNpmMirror)
  else
    Result := 'https://registry.npmjs.org';
end;

function ShouldWriteNodeMirror(): Boolean;
begin
  if IsPreV2Upgrade then
    Result := LegacyNodeMirrorFound
  else
    Result := True;
end;

function ShouldWriteNpmMirror(): Boolean;
begin
  if IsPreV2Upgrade then
    Result := LegacyNpmMirrorFound
  else
    Result := True;
end;

procedure RemoveLegacyScheduledTasks();
var
  TaskCleanupScript: String;
  TaskCleanupScriptFile: String;
  ResultCode: Integer;
begin
  TaskCleanupScriptFile := ExpandConstant('{tmp}\nvm-legacy-task-cleanup.ps1');
  TaskCleanupScript :=
    '$knownNames = @(''NVM Sync'', ''NVM for Windows Sync'')' + #13#10 +
    'Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {' + #13#10 +
    '  $isKnownName = $knownNames -contains $_.TaskName' + #13#10 +
    '  $isNvmSyncAction = $false' + #13#10 +
    '  foreach ($a in $_.Actions) {' + #13#10 +
    '    $exeFull = (($a.Execute | Out-String).Trim()).ToLowerInvariant()' + #13#10 +
    '    $exeFull = $exeFull -replace ''/'', ''\''' + #13#10 +
    '    $exe = [System.IO.Path]::GetFileName($exeFull)' + #13#10 +
    '    $args = (($a.Arguments | Out-String).Trim()).ToLowerInvariant()' + #13#10 +
    '    if (($exe -eq ''nvm.exe'') -and ($args -match ''(^|\s)sync(\s|$)'')) { $isNvmSyncAction = $true; break }' + #13#10 +
    '  }' + #13#10 +
    '  $isKnownName -or $isNvmSyncAction' + #13#10 +
    '} | ForEach-Object {' + #13#10 +
    '  Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -Confirm:$false -ErrorAction SilentlyContinue' + #13#10 +
    '}';

  SaveStringToFile(TaskCleanupScriptFile, TaskCleanupScript, False);
  Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + TaskCleanupScriptFile + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );
  DeleteFile(TaskCleanupScriptFile);
end;

procedure CreateSyncScheduledTask();
var
  TaskCreateCommand: String;
  TaskAuthorScript: String;
  TaskAuthorScriptFile: String;
  QueryOutputFile: String;
  QueryOutputRaw: AnsiString;
  SyncExePath: String;
  ResultCode: Integer;
begin
  SyncExePath := ExpandConstant('{app}\utils\sync.exe');
  if not FileExists(SyncExePath) then
  begin
    Log('Sync executable not found at "' + SyncExePath + '"; skipping sync task setup.');
    Exit;
  end;

  TaskCreateCommand :=
    '/C schtasks /Create /SC HOURLY /MO 1 /TN "' + SyncTaskName +
    '" /TR "\"' + SyncExePath + '\" --background sync" /F';

  if not Exec(
    ExpandConstant('{cmd}'),
    TaskCreateCommand,
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    Log('Unable to create sync scheduled task.');
    Exit;
  end;

  if ResultCode <> 0 then
    Log('Sync scheduled task creation returned exit code ' + IntToStr(ResultCode) + '.');

  { Ensure task metadata shows the product author, while keeping task principal as current user }
  TaskAuthorScriptFile := ExpandConstant('{tmp}\nvm-sync-task-author.ps1');
  TaskAuthorScript :=
    '$taskName = ''' + SyncTaskName + '''' + #13#10 +
    '$taskAuthor = ''{#OrgLabel}''' + #13#10 +
    '$service = New-Object -ComObject ''Schedule.Service''' + #13#10 +
    '$service.Connect()' + #13#10 +
    '$folder = $service.GetFolder(''\'')' + #13#10 +
    '$task = $folder.GetTask($taskName)' + #13#10 +
    'if ($null -eq $task) { exit 2 }' + #13#10 +
    '$definition = $task.Definition' + #13#10 +
    '$definition.RegistrationInfo.Author = $taskAuthor' + #13#10 +
    '$folder.RegisterTaskDefinition($taskName, $definition, 6, $null, $null, $definition.Principal.LogonType, $null) | Out-Null';

  SaveStringToFile(TaskAuthorScriptFile, TaskAuthorScript, False);
  if not Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + TaskAuthorScriptFile + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    Log('Unable to update sync task author metadata.');
  end
  else if ResultCode <> 0 then
  begin
    Log('Sync task author metadata update returned exit code ' + IntToStr(ResultCode) + '.');
  end;
  DeleteFile(TaskAuthorScriptFile);

  QueryOutputFile := ExpandConstant('{tmp}') + '\nvm-sync-task-query.txt';
  DeleteFile(QueryOutputFile);

  if not Exec(
    ExpandConstant('{cmd}'),
    '/C schtasks /Query /TN "' + SyncTaskName + '" /FO LIST /V > "' + QueryOutputFile + '" 2>&1',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    Log('Unable to verify sync scheduled task registration (query command failed to start).');
  end
  else if ResultCode <> 0 then
  begin
    Log('Unable to verify sync scheduled task registration (query exit code ' + IntToStr(ResultCode) + ').');
  end
  else if LoadStringFromFile(QueryOutputFile, QueryOutputRaw) then
  begin
    Log('Sync scheduled task verified by schtasks query.');
    Log('Sync task query output: ' + Trim(String(QueryOutputRaw)));
  end
  else
  begin
    Log('Sync scheduled task query completed, but output could not be read.');
  end;

  DeleteFile(QueryOutputFile);
end;

function IsSafeRemovableDirectory(const PathValue: String): Boolean;
var
  Normalized: String;
begin
  Normalized := Trim(PathValue);
  StringChangeEx(Normalized, '/', '\\', True);
  while (Length(Normalized) > 0) and (Normalized[Length(Normalized)] = '\\') do
    Delete(Normalized, Length(Normalized), 1);

  Result := (Length(Normalized) > 3) and
    not ((Length(Normalized) = 2) and (Normalized[2] = ':'));
end;

procedure RemoveLegacyFilesFromSameDirectory(const RootDir: String);
var
  CleanupScriptFile: String;
  CleanupScript: String;
  RootEscaped: String;
  ResultCode: Integer;
begin
  RootEscaped := RootDir;
  StringChangeEx(RootEscaped, '''', '''''', True);

  CleanupScriptFile := ExpandConstant('{tmp}\\nvm-legacy-file-cleanup.ps1');
  CleanupScript :=
    '$root = ''' + RootEscaped + '''' + #13#10 +
    '$keep = @(''nvm.exe'',''NVMWindows.Events.man'',''NVMWindows.Events.dll'',''utils'',''.shim'',''.sync'',''.icons'')' + #13#10 +
    'if (Test-Path -LiteralPath $root) {' + #13#10 +
    '  Get-ChildItem -LiteralPath $root -Force -ErrorAction SilentlyContinue | ForEach-Object {' + #13#10 +
    '    $n = $_.Name' + #13#10 +
    '    if ($keep -contains $n) { return }' + #13#10 +
    '    if ($n -like ''unins*.exe'' -or $n -like ''unins*.dat'' -or $n -like ''unins*.msg'') { return }' + #13#10 +
    '    Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue' + #13#10 +
    '  }' + #13#10 +
    '}';

  SaveStringToFile(CleanupScriptFile, CleanupScript, False);
  Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + CleanupScriptFile + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );
  DeleteFile(CleanupScriptFile);
end;

procedure CleanupLegacyInstallLocationIfNeeded();
var
  LegacyRoot: String;
  CurrentAppRoot: String;
  PreviousRoot: String;
begin
  if not IsPreV2Upgrade then
    Exit;

  LegacyRoot := Trim(LegacyInstallDir);
  if LegacyRoot = '' then
    Exit;

  CurrentAppRoot := ExpandConstant('{app}');

  if SameText(RemoveBackslashUnlessRoot(Trim(LegacyRoot)), RemoveBackslashUnlessRoot(Trim(CurrentAppRoot))) then
  begin
    RemoveLegacyFilesFromSameDirectory(CurrentAppRoot);
    Exit;
  end;

  PreviousRoot := Trim(PreviousInstallRoot);
  if (PreviousRoot <> '') and
     SameText(RemoveBackslashUnlessRoot(Trim(LegacyRoot)), RemoveBackslashUnlessRoot(Trim(PreviousRoot))) and
     (not MigrationPerformed) then
    Exit;

  if IsSafeRemovableDirectory(LegacyRoot) and DirExists(LegacyRoot) then
    DelTree(LegacyRoot, True, True, True);
end;

function IsNvmDisplayName(const DisplayName: String): Boolean;
var
  L: String;
begin
  L := LowerCase(Trim(DisplayName));
  Result := (Pos('nvm for windows', L) > 0) or (Pos('node version manager for windows', L) > 0);
end;

procedure RemoveLegacyWindowsAppsEntries();
var
  SubKeys: TArrayOfString;
  I: Integer;
  KeyName: String;
  DisplayName: String;
begin
  if not RegGetSubkeyNames(HKCU, WindowsAppsUninstallRoot, SubKeys) then
    Exit;

  for I := 0 to GetArrayLength(SubKeys) - 1 do
  begin
    KeyName := SubKeys[I];
    if CompareText(KeyName, '{#AppId}_is1') = 0 then
      Continue;

    DisplayName := '';
    if RegQueryStringValue(HKCU, WindowsAppsUninstallRoot + '\\' + KeyName, 'DisplayName', DisplayName) and
       IsNvmDisplayName(DisplayName) then
      RegDeleteKeyIncludingSubkeys(HKCU, WindowsAppsUninstallRoot + '\\' + KeyName);
  end;
end;

function IsSameExpandedPath(const Segment, OtherPath: String): Boolean;
var
  ExpandedSeg: String;
begin
  ExpandedSeg := NormalizePath(ExpandPathSegment(Segment));
  Result := (ExpandedSeg <> '') and (CompareText(ExpandedSeg, NormalizePath(OtherPath)) = 0);
end;

function ContainsNormalizedPath(const SeenPaths: TArrayOfString; const Value: String): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Value = '' then
    Exit;

  for I := 0 to GetArrayLength(SeenPaths) - 1 do
  begin
    if CompareText(SeenPaths[I], Value) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure AddNormalizedPath(var SeenPaths: TArrayOfString; const Value: String);
var
  N: Integer;
begin
  if Value = '' then
    Exit;

  N := GetArrayLength(SeenPaths);
  SetArrayLength(SeenPaths, N + 1);
  SeenPaths[N] := Value;
end;

function BuildCleanedPath(
  const OriginalPath: String;
  const RemoveLegacyEntries: Boolean;
  const ShouldPrependCurrentNvm: Boolean
): String;
var
  Segments: TArrayOfString;
  Seen: TArrayOfString;
  NewPath: String;
  Segment: String;
  NormalizedExpanded: String;
  NormalizedLegacyHome: String;
  NormalizedLegacyNodePath: String;
  NormalizedCurrentHome: String;
  NormalizedCurrentNodePath: String;
  I: Integer;
  RemoveLegacyHome: Boolean;
  RemoveLegacyNodePath: Boolean;
begin
  Result := OriginalPath;
  NewPath := '';
  SetArrayLength(Seen, 0);

  SplitPathString(OriginalPath, Segments);

  NormalizedLegacyHome := NormalizePath(Trim(LegacyInstallDir));
  NormalizedLegacyNodePath := NormalizePath(Trim(LegacySettingsPath));
  NormalizedCurrentHome := NormalizePath(ExpandConstant('{app}'));
  NormalizedCurrentNodePath := NormalizePath(ExpandConstant('{app}\\.nodejs'));

  RemoveLegacyHome := RemoveLegacyEntries and (NormalizedLegacyHome <> '') and
    (CompareText(NormalizedLegacyHome, NormalizedCurrentHome) <> 0);
  RemoveLegacyNodePath := RemoveLegacyEntries and (NormalizedLegacyNodePath <> '') and
    (CompareText(NormalizedLegacyNodePath, NormalizedCurrentNodePath) <> 0);

  for I := 0 to GetArrayLength(Segments) - 1 do
  begin
    Segment := Segments[I];
    if Segment = '' then
      Continue;

    if CompareText(Segment, '%NVM_SYMLINK%') = 0 then
      Continue;

    if ShouldPrependCurrentNvm then
    begin
      if (CompareText(Segment, '%NVM_HOME%') = 0) or
         (CompareText(Segment, '%NVM_HOME%\\.nodejs') = 0) or
         IsSameExpandedPath(Segment, NormalizedCurrentHome) or
         IsSameExpandedPath(Segment, NormalizedCurrentNodePath) then
        Continue;
    end;

    if RemoveLegacyHome and IsSameExpandedPath(Segment, NormalizedLegacyHome) then
      Continue;

    if RemoveLegacyNodePath and IsSameExpandedPath(Segment, NormalizedLegacyNodePath) then
      Continue;

    NormalizedExpanded := NormalizePath(ExpandPathSegment(Segment));
    if (NormalizedExpanded <> '') and ContainsNormalizedPath(Seen, NormalizedExpanded) then
      Continue;

    if NormalizedExpanded <> '' then
      AddNormalizedPath(Seen, NormalizedExpanded);

    if NewPath = '' then
      NewPath := Segment
    else
      NewPath := NewPath + ';' + Segment;
  end;

  if ShouldPrependCurrentNvm then
  begin
    if NewPath = '' then
      NewPath := NormalizedCurrentHome + ';' + NormalizedCurrentNodePath
    else
      NewPath := NormalizedCurrentHome + ';' + NormalizedCurrentNodePath + ';' + NewPath;
  end;

  Result := NewPath;
end;

procedure RemoveLegacySystemPathEntries();
var
  SystemPath: String;
  NewSystemPath: String;
begin
  if not IsPreV2Upgrade then
    Exit;

  if not RegQueryStringValue(HKLM, 'SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment', 'Path', SystemPath) then
    Exit;

  NewSystemPath := BuildCleanedPath(SystemPath, True, False);
  if CompareText(NewSystemPath, SystemPath) = 0 then
    Exit;

  if not RegWriteExpandStringValue(HKLM, 'SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment', 'Path', NewSystemPath) then
    AppendLegacyCleanupWarning('Could not update the System PATH to remove legacy NVM entries (permissions may be required).');
end;

function IsLegacyUninstallEntry(const Root: Integer; const SubKey: String; const KeyName: String): Boolean;
var
  DisplayName: String;
  UninstallString: String;
  DisplayIcon: String;
  NormalizedLegacyInstallDir: String;
  LowerUninstall: String;
  LowerIcon: String;
begin
  Result := False;

  if CompareText(KeyName, '{#AppId}_is1') = 0 then
    Exit;

  if CompareText(KeyName, 'nvm_is1') = 0 then
  begin
    Result := True;
    Exit;
  end;

  DisplayName := '';
  RegQueryStringValue(Root, SubKey, 'DisplayName', DisplayName);
  if IsNvmDisplayName(DisplayName) then
  begin
    Result := True;
    Exit;
  end;

  NormalizedLegacyInstallDir := LowerCase(NormalizePath(Trim(LegacyInstallDir)));
  if NormalizedLegacyInstallDir = '' then
    Exit;

  UninstallString := '';
  DisplayIcon := '';
  RegQueryStringValue(Root, SubKey, 'UninstallString', UninstallString);
  RegQueryStringValue(Root, SubKey, 'DisplayIcon', DisplayIcon);

  LowerUninstall := LowerCase(UninstallString);
  LowerIcon := LowerCase(DisplayIcon);

  StringChangeEx(LowerUninstall, '/', '\\', True);
  StringChangeEx(LowerIcon, '/', '\\', True);

  if (Pos(NormalizedLegacyInstallDir, LowerUninstall) > 0) or
     (Pos(NormalizedLegacyInstallDir, LowerIcon) > 0) then
    Result := True;
end;

procedure RemoveLegacyUninstallEntriesFromRoot(const Root: Integer; const UninstallRoot: String; const RootLabel: String);
var
  SubKeys: TArrayOfString;
  I: Integer;
  KeyName: String;
  FullSubKey: String;
begin
  if not RegGetSubkeyNames(Root, UninstallRoot, SubKeys) then
    Exit;

  for I := 0 to GetArrayLength(SubKeys) - 1 do
  begin
    KeyName := SubKeys[I];
    FullSubKey := UninstallRoot + '\\' + KeyName;

    if not IsLegacyUninstallEntry(Root, FullSubKey, KeyName) then
      Continue;

    if not RegDeleteKeyIncludingSubkeys(Root, FullSubKey) then
      AppendLegacyCleanupWarning(
        'Could not remove legacy uninstall entry "' + KeyName + '" from ' + RootLabel +
        ' (permissions may be required).'
      );
  end;
end;

procedure RemoveLegacyV1UninstallEntries();
begin
  if not IsPreV2Upgrade then
    Exit;

  RemoveLegacyUninstallEntriesFromRoot(HKCU, 'Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall', 'HKCU');
  RemoveLegacyUninstallEntriesFromRoot(HKLM, 'Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall', 'HKLM');
  RemoveLegacyUninstallEntriesFromRoot(HKLM, 'Software\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall', 'HKLM\\WOW6432Node');
end;

procedure RemoveLegacySymlinkPathIfNeeded();
var
  LegacySymlinkPath: String;
  NewNodePath: String;
  Attr: Integer;
  ResultCode: Integer;
  FindRec: TFindRec;
begin
  if not IsPreV2Upgrade then
    Exit;

  LegacySymlinkPath := NormalizePath(Trim(LegacySettingsPath));
  if LegacySymlinkPath = '' then
    Exit;

  NewNodePath := NormalizePath(ExpandConstant('{app}\\.nodejs'));
  if CompareText(LegacySymlinkPath, NewNodePath) = 0 then
    Exit;

  if not DirExists(LegacySymlinkPath) then
    Exit;

  if FindFirst(LegacySymlinkPath, FindRec) then
  begin
    Attr := FindRec.Attributes;
    FindClose(FindRec);
  end
  else
    Attr := -1;

  if (Attr = -1) or ((Attr and FILE_ATTRIBUTE_REPARSE_POINT) = 0) then
  begin
    AppendInstallLog('Legacy symlink path exists but is not a reparse point, skipping removal: ' + LegacySymlinkPath);
    Exit;
  end;

  if not Exec(
    ExpandConstant('{cmd}'),
    '/C rmdir "' + LegacySymlinkPath + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    AppendLegacyCleanupWarning('Could not remove the legacy symlink path: ' + LegacySymlinkPath);
    Exit;
  end;

  if ResultCode <> 0 then
    AppendLegacyCleanupWarning('Could not remove the legacy symlink path: ' + LegacySymlinkPath + ' (exit code ' + IntToStr(ResultCode) + ').');
end;

{ ── Elevated migration helper ────────────────────────────────────────────── }

{ Run nvm-upgrader.exe (elevated) to perform all privileged v1-cleanup tasks  }
{ in a single UAC prompt: remove NVM_SYMLINK/NVM_HOME env vars from user and  }
{ system environments, strip v1 PATH entries from both, delete v1 uninstall   }
{ registry keys, remove the old install directory, and register the Windows   }
{ Event Log source in the new nvm.exe.                                         }
procedure RunUpgraderHelper();
var
  UpgraderArgs: String;
  ResultCode: Integer;
  ElevatedExecOk: Boolean;
begin
  UpgraderArgs := '';

  { Pass --install-dir only when the v1 location differs from the new install directory. }
  if (LegacyInstallDir <> '') and
     not SameText(
       RemoveBackslashUnlessRoot(Trim(LegacyInstallDir)),
       RemoveBackslashUnlessRoot(ExpandConstant('{app}'))
     ) then
    UpgraderArgs := UpgraderArgs + ' --install-dir "' + LegacyInstallDir + '"';

  { Pass --symlink-path only when it differs from the new .nodejs junction. }
  if (LegacySettingsPath <> '') and
     not SameText(
       RemoveBackslashUnlessRoot(Trim(LegacySettingsPath)),
       RemoveBackslashUnlessRoot(ExpandConstant('{app}\.nodejs'))
     ) then
    UpgraderArgs := UpgraderArgs + ' --symlink-path "' + LegacySettingsPath + '"';

  UpgraderArgs := UpgraderArgs + ' --new-nvm "' + ExpandConstant('{app}\{#Alias}.exe') + '"';
  UpgraderArgs := Trim(UpgraderArgs);

  AppendInstallLog('RunUpgraderHelper: args=' + UpgraderArgs);

  ElevatedExecOk := ShellExec(
    'runas',
    ExpandConstant('{tmp}\nvm-upgrader.exe'),
    UpgraderArgs,
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );

  if not ElevatedExecOk then
  begin
    AppendInstallLogWarn('RunUpgraderHelper: ShellExec failed, code=' + IntToStr(ResultCode));
    if ResultCode = 1223 then
      MsgBox(
        'NVM for Windows could not run the v1 migration cleanup helper because the UAC prompt was canceled.' + #13#10 + #13#10 +
        'Your previous NVM v1 installation may leave behind environment variables (NVM_HOME, NVM_SYMLINK)' + #13#10 +
        'and PATH entries that could conflict with NVM for Windows 2.' + #13#10 + #13#10 +
        'To clean up manually: Start > "Edit the system environment variables" > Environment Variables' + #13#10 +
        '> delete NVM_HOME and NVM_SYMLINK from System variables, and remove any references to' + #13#10 +
        'those variables from the System PATH.' + #13#10 + #13#10 +
        'Event Log registration can be completed later from an elevated terminal:' + #13#10 +
        ExpandConstant('{app}\{#Alias}.exe') + ' --register-eventlog',
        mbInformation,
        MB_OK
      )
    else
      AppendInstallLogWarn(
        'RunUpgraderHelper: elevation failed with system error ' + IntToStr(ResultCode)
      );
  end
  else if ResultCode <> 0 then
  begin
    AppendInstallLogWarn('RunUpgraderHelper: helper exited with code ' + IntToStr(ResultCode));
    MsgBox(
      'The NVM v1 migration cleanup helper exited with an unexpected code (' + IntToStr(ResultCode) + ').' + #13#10 + #13#10 +
      'Some v1 leftovers (environment variables, PATH entries, or the old install folder) may not have been removed.' + #13#10 + #13#10 +
      'Check the log for details:' + #13#10 +
      ExpandConstant('{app}\upgrade.log'),
      mbInformation,
      MB_OK
    );
  end;
end;

function GetOperatingModeRegistryValue(Param: String): String;
begin
  Result := 'shim';
  if (OperatingModePage <> nil) and OperatingModePage.Values[1] then
    Result := 'link';
end;

function IsShimModeSelected(): Boolean;
begin
  Result := CompareText(GetOperatingModeRegistryValue(''), 'shim') = 0;
end;

function GetCacheDownloadsRegistryValue(Param: String): String;
begin
  Result := '0';
  if (PreferencesPage <> nil) and PreferencesPage.Values[0] then
    Result := '1';
end;

function GetAutoUseRegistryValue(Param: String): String;
begin
  Result := '1';
  if (PreferencesPage <> nil) and not PreferencesPage.Values[1] then
    Result := '0';
end;

function IsExistingInstallDetected(): Boolean;
begin
  // Only treat the current v2 uninstall entry as proof of an installed copy.
  // Preferences can survive an uninstall failure and should only be reused as
  // wizard defaults, not as a reinstall/upgrade signal.
  Result := RegValueExists(
    HKCU,
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#AppId}_is1',
    'DisplayVersion'
  );
end;

function GetExistingInstallVersion(): String;
var
  InstalledVersion: String;
begin
  Result := 'unknown version';

  if RegQueryStringValue(
    HKCU,
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#AppId}_is1',
    'DisplayVersion',
    InstalledVersion
  ) and (Trim(InstalledVersion) <> '') then
  begin
    Result := Trim(InstalledVersion);
    Exit;
  end;

  if RegQueryStringValue(HKCU, '{#RegistryKey}', 'Version', InstalledVersion) and
     (Trim(InstalledVersion) <> '') then
    Result := Trim(InstalledVersion);
end;

function GetExistingInstallRoot(var InstallRoot: String): Boolean;
begin
  Result := RegQueryStringValue(HKCU, '{#RegistryKey}', 'InstallRoot', InstallRoot) and
    (Trim(InstallRoot) <> '');
  if Result then
    InstallRoot := Trim(InstallRoot);
end;

function ConfirmExistingInstallMigration(const ExistingVersion: String): Boolean;
var
  Prompt: String;
begin
  Prompt :=
    'An existing NVM for Windows installation was detected.' + #13#10#13#10;

  if Trim(ExistingVersion) <> '' then
    Prompt := Prompt + 'Current installed version: ' + ExistingVersion + #13#10#13#10;

  Prompt := Prompt +
    'Your prior settings and Node.js versions will be migrated.' + #13#10#13#10 +
    'Do you want to continue?';

  Result := MsgBox(
    Prompt,
    mbConfirmation,
    MB_YESNO or MB_DEFBUTTON2
  ) = IDYES;
end;

function ReadRegistryDwordBool(const ValueName: String; const DefaultValue: Boolean): Boolean;
var
  Value: Cardinal;
begin
  Result := DefaultValue;
  if RegQueryDWordValue(HKCU, '{#RegistryKey}', ValueName, Value) then
    Result := Value <> 0;
end;

procedure ResetWizardDefaults();
begin
  WizardDefaultInstallRoot := ExpandConstant('{localappdata}\{#OrgLabel}\{#Alias}\installs');
  WizardDefaultUseLinkMode := False;
  WizardDefaultCacheDownloads := False;
  WizardDefaultAutoDetect := True;
  WizardDefaultAutoInstall := False;
  WizardDefaultAutoInstallPrompt := False;
  // Secure by default: require valid TLS (AllowInsecureDownloads=0).
  WizardDefaultRequireTls := True;
end;

procedure LoadExistingV2WizardDefaults();
var
  ExistingInstallRoot: String;
  OperatingMode: String;
begin
  if GetExistingInstallRoot(ExistingInstallRoot) then
    WizardDefaultInstallRoot := ExistingInstallRoot;

  if RegQueryStringValue(HKCU, '{#RegistryKey}', 'OperatingMode', OperatingMode) then
    WizardDefaultUseLinkMode := CompareText(Trim(OperatingMode), 'link') = 0;

  WizardDefaultCacheDownloads := ReadRegistryDwordBool('CacheDownloads', WizardDefaultCacheDownloads);
  WizardDefaultAutoDetect := ReadRegistryDwordBool('AutoUse', WizardDefaultAutoDetect);
  WizardDefaultAutoInstall := ReadRegistryDwordBool('AutoInstall', WizardDefaultAutoInstall);
  WizardDefaultAutoInstallPrompt := ReadRegistryDwordBool('AutoInstallPrompt', WizardDefaultAutoInstallPrompt);
  // Missing AllowInsecureDownloads → treat as False → RequireTls stays True.
  if RegValueExists(HKCU, '{#RegistryKey}', 'AllowInsecureDownloads') then
    WizardDefaultRequireTls := not ReadRegistryDwordBool('AllowInsecureDownloads', False);

  if not WizardDefaultAutoInstall then
    WizardDefaultAutoInstallPrompt := False;
end;

function HasExistingV2Preferences(): Boolean;
begin
  Result :=
    RegValueExists(HKCU, '{#RegistryKey}', 'InstallRoot') or
    RegValueExists(HKCU, '{#RegistryKey}', 'OperatingMode') or
    RegValueExists(HKCU, '{#RegistryKey}', 'CacheDownloads') or
    RegValueExists(HKCU, '{#RegistryKey}', 'AutoUse') or
    RegValueExists(HKCU, '{#RegistryKey}', 'AutoInstall') or
    RegValueExists(HKCU, '{#RegistryKey}', 'AutoInstallPrompt') or
    RegValueExists(HKCU, '{#RegistryKey}', 'AllowInsecureDownloads');
end;

function NormalizePath(const PathValue: String): String;
begin
  Result := RemoveBackslashUnlessRoot(Trim(PathValue));
end;

function IsReparsePoint(const Attributes: Integer): Boolean;
begin
  Result := (Attributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0;
end;

procedure CountFilesInTree(const RootDir: String; var FileCount: Integer);
var
  FindRec: TFindRec;
  CurrentPath: String;
begin
  if not FindFirst(AddBackslash(RootDir) + '*', FindRec) then
    Exit;

  try
    repeat
      if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
      begin
        CurrentPath := AddBackslash(RootDir) + FindRec.Name;
        if IsReparsePoint(FindRec.Attributes) then
          AppendInstallLog('CountFilesInTree: skipping reparse point ' + NormalizePath(CurrentPath))
        else if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
          CountFilesInTree(CurrentPath, FileCount)
        else
          FileCount := FileCount + 1;
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

function IsLegacyVersionDirectoryName(const DirectoryName: String): Boolean;
begin
  Result :=
    (Length(DirectoryName) > 0) and
    ((DirectoryName[1] = 'v') or (DirectoryName[1] = 'V'));
end;

procedure CountFilesInLegacyVersionDirectories(
  const RootDir: String;
  var FileCount: Integer;
  var DirCount: Integer
);
var
  FindRec: TFindRec;
  CurrentPath: String;
begin
  if not FindFirst(AddBackslash(RootDir) + '*', FindRec) then
    Exit;

  try
    repeat
      if (FindRec.Name <> '.') and (FindRec.Name <> '..') and
         ((FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) and
         IsLegacyVersionDirectoryName(FindRec.Name) then
      begin
        CurrentPath := AddBackslash(RootDir) + FindRec.Name;
        DirCount := DirCount + 1;
        CountFilesInTree(CurrentPath, FileCount);
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

function TryMigrateReparsePointAsJunction(
  const SourcePath, DestPath, SourceRoot, DestRoot: String
): Boolean;
var
  ScriptFile: String;
  ResultFile: String;
  ScriptText: String;
  ScriptOutput: AnsiString;
  OutputText: String;
  FailureReason: String;
  CommandLine: String;
  ResultCode: Integer;
begin
  Result := False;
  ScriptFile := ExpandConstant('{tmp}\nvm-migrate-junction.ps1');
  ResultFile := ExpandConstant('{tmp}\nvm-migrate-junction-result.txt');
  DeleteFile(ResultFile);

  ScriptText :=
    '$source = ''' + EscapeSingleQuotedPowerShellString(SourcePath) + '''' + #13#10 +
    '$dest = ''' + EscapeSingleQuotedPowerShellString(DestPath) + '''' + #13#10 +
    '$sourceRoot = ''' + EscapeSingleQuotedPowerShellString(SourceRoot) + '''' + #13#10 +
    '$destRoot = ''' + EscapeSingleQuotedPowerShellString(DestRoot) + '''' + #13#10 +
    '$resultFile = ''' + EscapeSingleQuotedPowerShellString(ResultFile) + '''' + #13#10 +
    '$command = ""' + #13#10 +
    'try {' + #13#10 +
    '  $item = Get-Item -LiteralPath $source -Force -ErrorAction Stop' + #13#10 +
    '  $target = $item.Target' + #13#10 +
    '  if ($null -eq $target) { throw "Link target not available." }' + #13#10 +
    '  if ($target -is [array]) { $target = $target[0] }' + #13#10 +
    '  $target = [string]$target' + #13#10 +
    '  if ([string]::IsNullOrWhiteSpace($target)) { throw "Link target is empty." }' + #13#10 +
    '  if (-not [System.IO.Path]::IsPathRooted($target)) {' + #13#10 +
    '    $target = Join-Path -Path (Split-Path -Parent $source) -ChildPath $target' + #13#10 +
    '  }' + #13#10 +
    '  $target = [System.IO.Path]::GetFullPath($target)' + #13#10 +
    '  $sourceRoot = [System.IO.Path]::GetFullPath($sourceRoot)' + #13#10 +
    '  $destRoot = [System.IO.Path]::GetFullPath($destRoot)' + #13#10 +
    '  if ($target.StartsWith($sourceRoot, [System.StringComparison]::OrdinalIgnoreCase)) {' + #13#10 +
    '    $suffix = $target.Substring($sourceRoot.Length).TrimStart(''\'')' + #13#10 +
    '    if ([string]::IsNullOrEmpty($suffix)) {' + #13#10 +
    '      $target = $destRoot' + #13#10 +
    '    } else {' + #13#10 +
    '      $target = Join-Path -Path $destRoot -ChildPath $suffix' + #13#10 +
    '    }' + #13#10 +
    '  }' + #13#10 +
    '  if (-not (Test-Path -LiteralPath $target -PathType Container)) { throw "Junction targets must be directories." }' + #13#10 +
    '  $command = ''cmd.exe /C mklink /J "'' + $dest.Replace(''"'', ''""'') + ''" "'' + $target.Replace(''"'', ''""'') + ''"''' + #13#10 +
    '  if (Test-Path -LiteralPath $dest) {' + #13#10 +
    '    Remove-Item -LiteralPath $dest -Recurse -Force -ErrorAction Stop' + #13#10 +
    '  }' + #13#10 +
    '  New-Item -ItemType Junction -Path $dest -Target $target -Force -ErrorAction Stop | Out-Null' + #13#10 +
    '  Set-Content -LiteralPath $resultFile -Value @(''status: ok'', ''command: '' + $command) -Encoding UTF8' + #13#10 +
    '  exit 0' + #13#10 +
    '} catch {' + #13#10 +
    '  if ([string]::IsNullOrWhiteSpace($command)) {' + #13#10 +
    '    $command = ''cmd.exe /C mklink /J "'' + $dest.Replace(''"'', ''""'') + ''" "<target>"''' + #13#10 +
    '  }' + #13#10 +
    '  Set-Content -LiteralPath $resultFile -Value @(''status: fail'', ''command: '' + $command, ''reason: '' + $_.Exception.Message) -Encoding UTF8' + #13#10 +
    '  exit 1' + #13#10 +
    '}';

  SaveStringToFile(ScriptFile, ScriptText, False);
  if not Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + ScriptFile + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    AppendSkippedSymlink(NormalizePath(SourcePath), BuildMklinkJunctionCommand(NormalizePath(DestPath), '<target>'), 'Unable to launch PowerShell to recreate junction.');
    DeleteFile(ScriptFile);
    Exit;
  end;

  if not LoadStringFromFile(ResultFile, ScriptOutput) then
  begin
    AppendSkippedSymlink(NormalizePath(SourcePath), BuildMklinkJunctionCommand(NormalizePath(DestPath), '<target>'), 'No junction migration result was returned.');
    DeleteFile(ScriptFile);
    DeleteFile(ResultFile);
    Exit;
  end;

  OutputText := Trim(String(ScriptOutput));
  CommandLine := GetLegacySettingValue(OutputText, 'command');
  FailureReason := GetLegacySettingValue(OutputText, 'reason');

  if CompareText(GetLegacySettingValue(OutputText, 'status'), 'ok') = 0 then
  begin
    AppendInstallLog('Recreated migrated link as junction: ' + NormalizePath(DestPath));
    Result := True;
  end
  else
    AppendSkippedSymlink(NormalizePath(SourcePath), CommandLine, FailureReason);

  DeleteFile(ScriptFile);
  DeleteFile(ResultFile);
end;

procedure MigrateReparsePointsAsJunctions(
  const SourceDir, DestDir, SourceRoot, DestRoot: String
);
var
  FindRec: TFindRec;
  CurrentPath: String;
  CurrentDestPath: String;
begin
  if not FindFirst(AddBackslash(SourceDir) + '*', FindRec) then
    Exit;

  try
    repeat
      if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
      begin
        CurrentPath := AddBackslash(SourceDir) + FindRec.Name;
        CurrentDestPath := AddBackslash(DestDir) + FindRec.Name;

        if IsReparsePoint(FindRec.Attributes) then
          TryMigrateReparsePointAsJunction(CurrentPath, CurrentDestPath, SourceRoot, DestRoot)
        else if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
          MigrateReparsePointsAsJunctions(CurrentPath, CurrentDestPath, SourceRoot, DestRoot);
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

function CopyTreeWithProgress(
  const SourceDir, DestDir: String;
  ProgressPage: TOutputProgressWizardPage;
  var CopiedCount: Integer;
  const TotalCount: Integer
): Boolean;
var
  ResultCode: Integer;
  ExecResult: Boolean;
  SourceFileCount: Integer;
  SourceArg: String;
  DestArg: String;
begin
  Result := True;

  SourceArg := NormalizePath(SourceDir);
  DestArg := NormalizePath(DestDir);
  AppendInstallLog('CopyTreeWithProgress (robocopy): ' + SourceArg + ' -> ' + DestArg);

  SourceFileCount := 0;
  CountFilesInTree(SourceArg, SourceFileCount);

  if not ForceDirectories(DestArg) then
  begin
    AppendInstallLogWarn('ForceDirectories failed for ' + DestArg);
    Result := False;
    Exit;
  end;

  if ProgressPage <> nil then
  begin
    ProgressPage.SetText(
      'Migrating Node.js versions',
      'Copying existing Node.js installations...'
    );
    ProgressPage.SetProgress(CopiedCount, TotalCount);
  end;

  ExecResult :=
    Exec(
      'robocopy.exe',
      '"' + SourceArg + '" "' + DestArg + '" /E /MT:16 /R:1 /W:1 /V /NP /XJF /XJD /SJ',
      '',
      SW_HIDE,
      ewWaitUntilTerminated,
      ResultCode
    );

  if not ExecResult then
  begin
    AppendInstallLogWarn('Robocopy execution failed for ' + SourceArg);
    Result := False;
    Exit;
  end;

  if ResultCode >= 8 then
  begin
    AppendInstallLogWarn('Robocopy failed with code ' + IntToStr(ResultCode));
    AppendInstallLogWarn('Robocopy command source=' + SourceArg + ' dest=' + DestArg);
    Result := False;
    Exit;
  end;

  MigrateReparsePointsAsJunctions(SourceArg, DestArg, SourceArg, DestArg);

  CopiedCount := CopiedCount + SourceFileCount;
  if CopiedCount > TotalCount then
    CopiedCount := TotalCount;

  if ProgressPage <> nil then
    ProgressPage.SetProgress(CopiedCount, TotalCount);

  AppendInstallLog('CopyTreeWithProgress completed');
end;

procedure MigrateNodeStorageIfNeeded();
var
  ExistingRoot: String;
  TargetRoot: String;
  FileCount: Integer;
  CopiedCount: Integer;
  ProgressPage: TOutputProgressWizardPage;
  TargetExistedBefore: Boolean;
  VersionDirCount: Integer;
  CopiedVersionDirCount: Integer;
  SourceVersionDir: String;
  TargetVersionDir: String;
  FindRec: TFindRec;
begin
  AppendInstallLog('MigrateNodeStorageIfNeeded: begin');
  ResetSkippedSymlinkLog();
  AppendInstallLog('MigrateNodeStorageIfNeeded: IsPreV2Upgrade=' + IntToStr(Integer(IsPreV2Upgrade)));
  AppendInstallLog('MigrateNodeStorageIfNeeded: LegacyInstallDir=' + LegacyInstallDir);
  AppendInstallLog('MigrateNodeStorageIfNeeded: LegacySettingsRoot=' + LegacySettingsRoot);
  AppendInstallLog('MigrateNodeStorageIfNeeded: PreviousInstallRoot=' + PreviousInstallRoot);
  ExistingRoot := Trim(PreviousInstallRoot);
  if ExistingRoot = '' then
  begin
    AppendInstallLog('MigrateNodeStorageIfNeeded: PreviousInstallRoot empty, querying existing install root');
    if not GetExistingInstallRoot(ExistingRoot) then
    begin
      AppendInstallLogWarn('MigrateNodeStorageIfNeeded: no existing install root found, exiting');
      Exit;
    end;
  end;

  TargetRoot := GetInstallRoot('');
  AppendInstallLog('MigrateNodeStorageIfNeeded: resolved source=' + ExistingRoot);
  AppendInstallLog('MigrateNodeStorageIfNeeded: resolved target=' + TargetRoot);

  if CompareText(NormalizePath(ExistingRoot), NormalizePath(TargetRoot)) = 0 then
  begin
    AppendInstallLog('MigrateNodeStorageIfNeeded: source and target are the same, exiting');
    Exit;
  end;

  if not DirExists(ExistingRoot) then
  begin
    AppendInstallLogWarn('MigrateNodeStorageIfNeeded: source directory does not exist, exiting');
    Exit;
  end;

  FileCount := 0;
  VersionDirCount := 0;
  CountFilesInLegacyVersionDirectories(ExistingRoot, FileCount, VersionDirCount);
  AppendInstallLog('MigrateNodeStorageIfNeeded: version directory count=' + IntToStr(VersionDirCount));
  AppendInstallLog('MigrateNodeStorageIfNeeded: source version file count=' + IntToStr(FileCount));

  if VersionDirCount = 0 then
  begin
    AppendInstallLogWarn('MigrateNodeStorageIfNeeded: no version directories (v*) found, skipping migration');
    Exit;
  end;

  if FileCount = 0 then
  begin
    AppendInstallLogWarn('MigrateNodeStorageIfNeeded: version directories are empty, skipping migration');
    Exit;
  end;

  ProgressPage := CreateOutputProgressPage(
    'Migrating Node.js versions',
    'Moving installed Node.js versions to your new storage directory.'
  );
  ProgressPage.SetProgress(0, FileCount);
  ProgressPage.Show;

  TargetExistedBefore := DirExists(TargetRoot);
  AppendInstallLog('MigrateNodeStorageIfNeeded: target existed before copy=' + IntToStr(Integer(TargetExistedBefore)));
  CopiedCount := 0;
  CopiedVersionDirCount := 0;
  try
    if not FindFirst(AddBackslash(ExistingRoot) + '*', FindRec) then
    begin
      AppendInstallLogWarn('MigrateNodeStorageIfNeeded: no source entries found during copy, aborting migration');
      if not TargetExistedBefore then
      begin
        AppendInstallLogWarn('MigrateNodeStorageIfNeeded: cleaning up newly-created target root after failure');
        DelTree(TargetRoot, True, True, True);
      end;
      MsgBox(
        'Node.js versions could not be fully migrated to the new storage directory.' + #13#10 +
        'The destination has been cleaned up. Your versions remain at:' + #13#10 + ExistingRoot,
        mbError,
        MB_OK
      );
    end
    else
    begin
      try
        repeat
          if (FindRec.Name <> '.') and (FindRec.Name <> '..') and
             ((FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) and
             IsLegacyVersionDirectoryName(FindRec.Name) then
          begin
            SourceVersionDir := AddBackslash(ExistingRoot) + FindRec.Name;
            TargetVersionDir := AddBackslash(TargetRoot) + FindRec.Name;
            AppendInstallLog('MigrateNodeStorageIfNeeded: copying version directory ' + FindRec.Name);

            if not CopyTreeWithProgress(SourceVersionDir, TargetVersionDir, ProgressPage, CopiedCount, FileCount) then
            begin
              AppendInstallLogWarn('MigrateNodeStorageIfNeeded: copy failed after ' + IntToStr(CopiedCount) + ' files');
              if not TargetExistedBefore then
              begin
                AppendInstallLogWarn('MigrateNodeStorageIfNeeded: cleaning up newly-created target root after failure');
                DelTree(TargetRoot, True, True, True);
              end;
              MsgBox(
                'Node.js versions could not be fully migrated to the new storage directory.' + #13#10 +
                'The destination has been cleaned up. Your versions remain at:' + #13#10 + ExistingRoot,
                mbError,
                MB_OK
              );
              Exit;
            end;

            CopiedVersionDirCount := CopiedVersionDirCount + 1;
          end;
        until not FindNext(FindRec);
      finally
        FindClose(FindRec);
      end;

      if CopiedVersionDirCount <> VersionDirCount then
      begin
        AppendInstallLogWarn('MigrateNodeStorageIfNeeded: copied version directory count mismatch');
        AppendInstallLogWarn('MigrateNodeStorageIfNeeded: expected=' + IntToStr(VersionDirCount) + ' actual=' + IntToStr(CopiedVersionDirCount));
      end;

      MigrationSource := ExistingRoot;
      MigrationDest := TargetRoot;
      MigrationPerformed := True;
      AppendInstallLog('MigrateNodeStorageIfNeeded: migration succeeded, deleting source root');
      DelTree(ExistingRoot, True, True, True);
    end;
  finally
    AppendInstallLog('MigrateNodeStorageIfNeeded: end');
    FlushSkippedSymlinkLog();
    FlushInstallLog();
    ProgressPage.Hide;
  end;
end;

function GetCoreVersion(const VersionText: String): String;
var
  SeparatorPos: Integer;
begin
  Result := Trim(VersionText);

  SeparatorPos := Pos('-', Result);
  if SeparatorPos > 0 then
    Result := Copy(Result, 1, SeparatorPos - 1);

  SeparatorPos := Pos('+', Result);
  if SeparatorPos > 0 then
    Result := Copy(Result, 1, SeparatorPos - 1);
end;

function NextVersionPart(const VersionText: String; var Position: Integer): Integer;
var
  StartPos: Integer;
  PartText: String;
begin
  while (Position <= Length(VersionText)) and
        not ((VersionText[Position] >= '0') and (VersionText[Position] <= '9')) do
    Position := Position + 1;

  if Position > Length(VersionText) then
  begin
    Result := -1;
    Exit;
  end;

  StartPos := Position;
  while (Position <= Length(VersionText)) and
        ((VersionText[Position] >= '0') and (VersionText[Position] <= '9')) do
    Position := Position + 1;

  PartText := Copy(VersionText, StartPos, Position - StartPos);
  Result := StrToIntDef(PartText, 0);
end;

function GetMajorVersion(const VersionText: String): Integer;
var
  Position: Integer;
  CoreVersion: String;
begin
  CoreVersion := GetCoreVersion(VersionText);
  Position := 1;
  Result := NextVersionPart(CoreVersion, Position);
end;

function CompareVersions(const LeftVersion, RightVersion: String): Integer;
var
  LeftPos, RightPos: Integer;
  LeftPart, RightPart: Integer;
  LeftCore, RightCore: String;
begin
  LeftCore := GetCoreVersion(LeftVersion);
  RightCore := GetCoreVersion(RightVersion);
  LeftPos := 1;
  RightPos := 1;

  while True do
  begin
    LeftPart := NextVersionPart(LeftCore, LeftPos);
    RightPart := NextVersionPart(RightCore, RightPos);

    if (LeftPart = -1) and (RightPart = -1) then
    begin
      Result := 0;
      Exit;
    end;

    if LeftPart = -1 then
      LeftPart := 0;
    if RightPart = -1 then
      RightPart := 0;

    if LeftPart < RightPart then
    begin
      Result := -1;
      Exit;
    end;

    if LeftPart > RightPart then
    begin
      Result := 1;
      Exit;
    end;
  end;
end;

function GetAutoDetectRegistryValue(Param: String): String;
begin
  Result := '.nvmrc' + #0 + '.node-version' + #0 + 'package.json';
  if (PreferencesPage <> nil) and not PreferencesPage.Values[1] then
    Result := '';
end;

function GetAutoInstallRegistryValue(Param: String): String;
begin
  Result := '0';
  if (PreferencesPage <> nil) and PreferencesPage.Values[2] then
    Result := '1';
end;

function GetAutoInstallPromptRegistryValue(Param: String): String;
begin
  Result := '0';
  if (PreferencesPage <> nil) and PreferencesPage.Values[3] then
    Result := '1';
end;

function GetAllowInsecureDownloadsRegistryValue(Param: String): String;
begin
  // Default secure when wizard page missing (silent) or TLS required is checked.
  Result := '0';
  if (PreferencesPage <> nil) and not PreferencesPage.Values[4] then
    Result := '1';
end;

function GetCurrentDateTimeRegistryValue(Param: String): String;
begin
  Result := GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':');
end;

function IsValidEmail(const Email: string): Boolean;
var
  AtPos, DotPos: Integer;
begin
  AtPos := Pos('@', Email);
  DotPos := Pos('.', Copy(Email, AtPos + 1, Length(Email)));
  if AtPos > 0 then
    DotPos := DotPos + AtPos;
  Result := (AtPos > 1) and (DotPos > AtPos + 1) and (DotPos < Length(Email));
end;

function GetSubscriptionEmail(): String;
begin
  Result := '';

  if EmailEdit = nil then
    Exit;

  Result := Trim(EmailEdit.Text);
  if (Result = '') or (CompareText(Result, EmailPlaceholder) = 0) then
    Result := '';
end;

function ShouldRunSubscriptionCommand(): Boolean;
begin
  Result := GetSubscriptionEmail() <> '';
end;

procedure EmailEditEnter(Sender: TObject);
begin
  if EmailFirstFocus then
  begin
    EmailFirstFocus := False;
    Exit;
  end;
  if EmailEdit.Text = EmailPlaceholder then
    EmailEdit.Text := '';
end;

procedure EmailEditExit(Sender: TObject);
begin
  if Trim(EmailEdit.Text) = '' then
    EmailEdit.Text := EmailPlaceholder;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (EmailPage <> nil) and (CurPageID = EmailPage.ID) then
    EmailFirstFocus := True;
end;

procedure UpdateAutoInstallPromptState();
var
  PromptEnabled: Boolean;
begin
  if PreferencesPage = nil then Exit;
  PromptEnabled := PreferencesPage.Values[2];

  PreferencesPage.CheckListBox.ItemEnabled[3] := PromptEnabled;
  if not PromptEnabled then
  begin
    PreferencesPage.Values[3] := False;
  end;

  PreferencesPage.CheckListBox.Invalidate;
end;

procedure PreferencesCheckChanged(Sender: TObject);
begin
  UpdateAutoInstallPromptState();
end;

function InitializeSetup(): Boolean;
var
  ExistingVersion: String;
  InstallingVersion: String;
  ExistingMajorVersion: Integer;
  ExistingInstallDetected: Boolean;
  V1NodeRoot: String;
begin
  Result := True;
  RemoveLegacyTasks := False;
  IsPreV2Upgrade := False;
  IsConcreteLegacyUpgrade := False;
  ResetWizardDefaults();
  LegacyInstallDir := Trim(GetEnv('NVM_HOME'));
  LoadLegacySettings();
  PreviousInstallRoot := '';
  GetExistingInstallRoot(PreviousInstallRoot);
  CaptureLegacyActiveVersionFromSymlink();
  InstallingVersion := '{#Version}';
  ExistingInstallDetected := IsExistingInstallDetected();

  if ExistingInstallDetected then
  begin
    ExistingVersion := GetExistingInstallVersion();

    if CompareVersions(ExistingVersion, InstallingVersion) > 0 then
    begin
      MsgBox(
        'A newer version of NVM for Windows is already installed (' + ExistingVersion + ').' + #13#10#13#10 +
        'You are trying to install an older version (' + InstallingVersion + ').' + #13#10#13#10 +
        'Uninstall the newer version first, then install this older version.',
        mbCriticalError,
        MB_OK
      );
      Result := False;
      Exit;
    end;

    ExistingMajorVersion := GetMajorVersion(ExistingVersion);

    if (ExistingMajorVersion >= 0) and (ExistingMajorVersion < 2) then
    begin
      IsPreV2Upgrade := True;
      IsConcreteLegacyUpgrade := True;
      RemoveLegacyTasks := True;
      V1NodeRoot := GetLegacyV1NodeStorageRoot();
      if V1NodeRoot <> '' then
        PreviousInstallRoot := V1NodeRoot;
    end;

    if not ConfirmExistingInstallMigration(ExistingVersion) then
    begin
      Result := False;
      Exit;
    end;

    if Result and (not IsPreV2Upgrade) and HasExistingV2Preferences() then
      LoadExistingV2WizardDefaults();
  end;

  // Pure v1 install: no current v2 markers exist, but legacy settings or uninstall
  // metadata are still present. Detect it here and enable migration so installed
  // Node versions are moved without double-prompting current v2 installs.
  ExistingVersion := GetLegacyV1InstalledVersion();
  if (not IsPreV2Upgrade) and
     (not ExistingInstallDetected) and
     (LegacyInstallDir <> '') and
     DirExists(LegacyInstallDir) and
     (LegacySettingsLoaded or (ExistingVersion <> '')) then
  begin
    IsPreV2Upgrade := True;
    RemoveLegacyTasks := True;
    V1NodeRoot := GetLegacyV1NodeStorageRoot();
    if V1NodeRoot <> '' then
      PreviousInstallRoot := V1NodeRoot;

    if ExistingVersion <> '' then
      IsConcreteLegacyUpgrade := True;

    if not ConfirmExistingInstallMigration(ExistingVersion) then
      Result := False;
  end;

  if Result and (not IsPreV2Upgrade) and HasExistingV2Preferences() then
    LoadExistingV2WizardDefaults();
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ShimDir: String;
  ResultCode: Integer;
  UserGrant: String;
begin
  Result := '';
  NeedsRestart := False;
  ShimDir := ExpandConstant('{app}\.shim');
  if not DirExists(ShimDir) then
    Exit;

  { Runtime LockShimDirectory makes .shim a protected read-only DACL.
    Community ProgramRoot == DataRoot, so reinstall extracts node.exe here
    and Inno reports "create a file in the destination directory: Access is denied."
    User still has WRITE_DAC, so icacls /reset works without elevation. }
  if Exec(
    ExpandConstant('{sys}\icacls.exe'),
    '"' + ShimDir + '" /reset /T /C /Q',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
    Log('PrepareToInstall: reset .shim ACL, icacls exit=' + IntToStr(ResultCode))
  else
    Log('PrepareToInstall: icacls /reset failed to start for ' + ShimDir);

  UserGrant := '"' + ShimDir + '" /grant:r "' + GetUserNameString + ':(OI)(CI)(F)" /T /C /Q';
  if Exec(
    ExpandConstant('{sys}\icacls.exe'),
    UserGrant,
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
    Log('PrepareToInstall: grant .shim write, icacls exit=' + IntToStr(ResultCode))
  else
    Log('PrepareToInstall: icacls /grant failed to start for ' + ShimDir);
end;

procedure InitializeWizard;
begin
  NodeStoragePage := CreateInputDirPage(
    wpLicense,
    'Node.js Storage Location',
    'Select where Node.js versions will be stored.',
    'NVM for Windows will store Node.js and npm installations in this directory.',
    False,
    ''
  );

  NodeStoragePage.Add('Node.js storage path:');
  NodeStoragePage.Values[0] := WizardDefaultInstallRoot;

  OperatingModePage := CreateInputOptionPage(
    NodeStoragePage.ID,
    'Operating Mode',
    'Select how Node.js should be made available on your system.',
    'Shim mode offers an enhanced modern workflow. Link mode offers guaranteed minimum latency with no extra features. This can be changed at any time by running "nvm use <mode>".',
    True,
    False
  );

  OperatingModePage.Add('Shim');
  OperatingModePage.Add('Link (Legacy)');
  OperatingModePage.Values[1] := WizardDefaultUseLinkMode;
  OperatingModePage.Values[0] := not WizardDefaultUseLinkMode;

  PreferencesPage := CreateInputOptionPage(
    OperatingModePage.ID,
    'Preferences',
    'Choose your default settings',
    'These settings can be changed at any time using the "nvm config" command.',
    False,
    False
  );

  PreferencesPage.Add('Keep downloaded Node.js setup files (cache for reinstall)');
  PreferencesPage.Add('Auto-detect Node.js version, e.g. .nvmrc, .node-version, package.json (shim mode)');
  PreferencesPage.Add('Auto-install missing Node.js versions (nvm use, shim mode)');
  PreferencesPage.Add('Prompt before installing missing Node.js versions (shim mode)');
  PreferencesPage.Add('Require valid TLS/SSL certificates from download mirrors');

  PreferencesPage.Values[0] := WizardDefaultCacheDownloads;
  PreferencesPage.Values[1] := WizardDefaultAutoDetect;
  PreferencesPage.Values[2] := WizardDefaultAutoInstall;
  PreferencesPage.Values[3] := WizardDefaultAutoInstallPrompt;
  PreferencesPage.Values[4] := WizardDefaultRequireTls;
  // Belt-and-suspenders: some Inno builds desync Values vs Checked on non-exclusive pages.
  PreferencesPage.CheckListBox.Checked[4] := WizardDefaultRequireTls;
  PreferencesPage.CheckListBox.ItemEnabled[3] := WizardDefaultAutoInstall;
  PreferencesPage.CheckListBox.OnClickCheck := @PreferencesCheckChanged;

  EmailPlaceholder := 'name@example.com';
  EmailFirstFocus := True;

  EmailPage := CreateCustomPage(
    PreferencesPage.ID,
    'Author Software Updates',
    'Get details about development milestones in your inbox (optional)'
  );

  UpdateAutoInstallPromptState();

  EmailLabel := TLabel.Create(EmailPage);
  EmailLabel.Parent := EmailPage.Surface;
  EmailLabel.Left := ScaleX(0);
  EmailLabel.Top := ScaleY(0);
  EmailLabel.Width := EmailPage.SurfaceWidth;
  EmailLabel.Height := ScaleY(50);
  EmailLabel.AutoSize := False;
  EmailLabel.Caption := 'Be informed of development milestones, release timelines, and enterprise capabilities. Leave it blank if you do not wish to receive notifications.';
  EmailLabel.WordWrap := True;

  EmailEdit := TEdit.Create(EmailPage);
  EmailEdit.Parent := EmailPage.Surface;
  EmailEdit.Left := ScaleX(0);
  EmailEdit.Top := ScaleY(60);
  EmailEdit.Width := EmailPage.SurfaceWidth;
  EmailEdit.Height := ScaleY(23);
  EmailEdit.Text := EmailPlaceholder;
  EmailEdit.OnEnter := @EmailEditEnter;
  EmailEdit.OnExit := @EmailEditExit;
end;

function UpdateReadyMemo(
  Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String
): String;
var
  Mode: String;
  Email: String;
begin
  if (OperatingModePage <> nil) and OperatingModePage.Values[1] then
    Mode := 'Link'
  else
    Mode := 'Shim (recommended)';

  if (EmailEdit <> nil) and (Trim(EmailEdit.Text) <> '') and (Trim(EmailEdit.Text) <> EmailPlaceholder) then
    Email := Trim(EmailEdit.Text)
  else
    Email := 'Not provided';

  Result :=
    'NVM for Windows will be installed with the following settings:' + NewLine + NewLine +
    Space + 'Node.js storage: ' + GetInstallRoot('') + NewLine +
    Space + 'Operating mode: ' + Mode + NewLine + NewLine +
    Space + 'Keep downloaded Node.js setup files (cache for reinstall): ';
  if (PreferencesPage <> nil) and PreferencesPage.Values[0] then
    Result := Result + 'Yes' + NewLine
  else
    Result := Result + 'No' + NewLine;

  Result := Result + Space + 'Auto-detect Node.js version, e.g. .nvmrc, .node-version, package.json: ';
  if (PreferencesPage <> nil) and PreferencesPage.Values[1] then
    Result := Result + 'Yes' + NewLine
  else
    Result := Result + 'No' + NewLine;

  Result := Result + Space + 'Auto-install missing Node.js versions: ';
  if (PreferencesPage <> nil) and PreferencesPage.Values[2] then
    Result := Result + 'Yes' + NewLine
  else
    Result := Result + 'No' + NewLine;

  Result := Result + Space + 'Prompt before installing: ';
  if (PreferencesPage <> nil) and PreferencesPage.Values[3] then
    Result := Result + 'Yes' + NewLine
  else
    Result := Result + 'No' + NewLine;

  Result := Result + Space + 'Validate TLS/SSL certificates: ';
  if (PreferencesPage <> nil) and PreferencesPage.Values[4] then
    Result := Result + 'Yes' + NewLine
  else
    Result := Result + 'No' + NewLine;

  Result := Result + NewLine + Space + 'Announcements email: ' + Email;

  Result := Result + NewLine + NewLine +
    'Note: You may be prompted to allow NVM for Windows to register as a Windows event source.';

  if IsPreV2Upgrade then
    Result := Result + NewLine + NewLine +
      'Note: A prior NVM for Windows installation was detected.' + NewLine +
      'Your settings and Node.js versions will be migrated.';
end;

function ReplaceVarCI(const S, VarName, Value: String): String;
var
  Upper: String;
  P: Integer;
begin
  Result := S;
  Upper := UpperCase(Result);
  P := Pos(UpperCase(VarName), Upper);
  while P > 0 do
  begin
    Result := Copy(Result, 1, P - 1) + Value + Copy(Result, P + Length(VarName), Length(Result));
    Upper := UpperCase(Result);
    P := Pos(UpperCase(VarName), Upper);
  end;
end;

function ExpandPathSegment(const Segment: String): String;
begin
  Result := Segment;
  Result := ReplaceVarCI(Result, '%USERPROFILE%',    GetEnv('USERPROFILE'));
  Result := ReplaceVarCI(Result, '%LOCALAPPDATA%',   GetEnv('LOCALAPPDATA'));
  Result := ReplaceVarCI(Result, '%APPDATA%',        GetEnv('APPDATA'));
  Result := ReplaceVarCI(Result, '%SYSTEMROOT%',     GetEnv('SystemRoot'));
  Result := ReplaceVarCI(Result, '%WINDIR%',         GetEnv('SystemRoot'));
  Result := ReplaceVarCI(Result, '%PROGRAMFILES%',   GetEnv('ProgramFiles'));
  Result := ReplaceVarCI(Result, '%PROGRAMFILES(X86)%', GetEnv('ProgramFiles(x86)'));
  Result := ReplaceVarCI(Result, '%NVM_HOME%',       ExpandConstant('{app}'));
end;

procedure SplitPathString(const PathStr: String; var Segments: TArrayOfString);
var
  Remaining: String;
  P: Integer;
  Count: Integer;
  Seg: String;
begin
  Count := 0;
  SetArrayLength(Segments, 0);
  Remaining := PathStr + ';';
  P := Pos(';', Remaining);
  while P > 0 do
  begin
    Seg := Trim(Copy(Remaining, 1, P - 1));
    Remaining := Copy(Remaining, P + 1, Length(Remaining));
    P := Pos(';', Remaining);
    if Seg = '' then Continue;
    SetArrayLength(Segments, Count + 1);
    Segments[Count] := Seg;
    Count := Count + 1;
  end;
end;

procedure EnsureNvmPathPriority();
var
  UserPath: String;
  NewPath: String;
begin
  if not RegQueryStringValue(HKCU, 'Environment', 'Path', UserPath) then
    UserPath := '';

  NewPath := BuildCleanedPath(UserPath, True, True);

  RegWriteStringValue(HKCU, 'Environment', 'Path', NewPath);
  BroadcastEnvironmentChange();
end;

function EnsureShimModeNodePathJunction(): Boolean;
var
  NodePath: String;
  ShimPath: String;
  CommandLine: String;
  ResultCode: Integer;
begin
  Result := True;

  if not IsShimModeSelected() then
    Exit;

  NodePath := ExpandConstant('{app}\.nodejs');
  ShimPath := ExpandConstant('{app}\.shim');
  AppendInstallLog('EnsureShimModeNodePathJunction: source=' + ShimPath + ' target=' + NodePath);

  if not DirExists(ShimPath) then
  begin
    AppendInstallLogWarn('EnsureShimModeNodePathJunction: missing shim directory: ' + ShimPath);
    Result := False;
    Exit;
  end;

  CommandLine :=
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ' +
    '"$target = ''' + NodePath + '''; ' +
    '$source = ''' + ShimPath + '''; ' +
    'if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Force -Recurse -ErrorAction Stop }; ' +
    'New-Item -ItemType Junction -Path $target -Target $source -Force -ErrorAction Stop | Out-Null; ' +
    '(Get-Item -LiteralPath $target -Force -ErrorAction Stop).Attributes = ' +
    '([System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::Directory -bor [System.IO.FileAttributes]::ReparsePoint)"';

  if not Exec(ExpandConstant('{cmd}'), CommandLine, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    AppendInstallLogWarn('EnsureShimModeNodePathJunction: failed to execute junction command');
    Result := False;
    Exit;
  end;

  if ResultCode <> 0 then
  begin
    AppendInstallLogWarn('EnsureShimModeNodePathJunction: mklink returned exit code ' + IntToStr(ResultCode));
    Result := False;
    Exit;
  end;

  AppendInstallLog('EnsureShimModeNodePathJunction: created hidden .nodejs -> .shim');
end;

procedure RegisterInstalledVersionsInWindowsApps();
var
  ResultCode: Integer;
begin
  if not Exec(
    ExpandConstant('{app}\{#Alias}.exe'),
    '--register-installed-versions',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    Log('Unable to start installed-version registration for Windows Apps.');
    Exit;
  end;

  if ResultCode <> 0 then
    Log('Installed-version registration returned exit code ' + IntToStr(ResultCode) + '.');
end;

procedure RunForceReshimAtEnd();
var
  ResultCode: Integer;
begin
  if not Exec(
    ExpandConstant('{app}\utils\reshim.exe'),
    '--force',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    AppendInstallLogWarn('RunForceReshimAtEnd: unable to start reshim.exe --force');
    Exit;
  end;

  if ResultCode <> 0 then
    AppendInstallLogWarn('RunForceReshimAtEnd: reshim.exe --force returned exit code ' + IntToStr(ResultCode));
end;

procedure EnsureShimHardlinkForPrewarm(const ShimBaseName: String);
var
  ResultCode: Integer;
  ShimPath: String;
  ProxyPath: String;
  CommandLine: String;
begin
  ShimPath := ExpandConstant('{app}\.shim\' + ShimBaseName + '.exe');
  ProxyPath := ExpandConstant('{app}\utils\proxy.exe');

  if FileExists(ShimPath) then
    Exit;

  if not FileExists(ProxyPath) then
  begin
    AppendInstallLogWarn('EnsureShimHardlinkForPrewarm: missing proxy.exe: ' + ProxyPath);
    Exit;
  end;

  if not DirExists(ExpandConstant('{app}\.shim')) then
  begin
    AppendInstallLogWarn('EnsureShimHardlinkForPrewarm: missing .shim directory');
    Exit;
  end;

  CommandLine :=
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ' +
    '"$shim = ''' + ShimPath + '''; ' +
    '$proxy = ''' + ProxyPath + '''; ' +
    'if (-not (Test-Path -LiteralPath $shim)) { New-Item -ItemType HardLink -Path $shim -Target $proxy -ErrorAction Stop | Out-Null }"';

  if not Exec(ExpandConstant('{cmd}'), CommandLine, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    AppendInstallLogWarn('EnsureShimHardlinkForPrewarm: failed to create hardlink for ' + ShimBaseName);
    Exit;
  end;

  if ResultCode <> 0 then
    AppendInstallLogWarn('EnsureShimHardlinkForPrewarm: hardlink creation returned exit code ' + IntToStr(ResultCode) + ' for ' + ShimBaseName);
end;

procedure TryPrewarmShim(const ShimBaseName: String);
var
  ResultCode: Integer;
begin
  ResultCode := -1;
  if Exec(
    ExpandConstant('{app}\.shim\' + ShimBaseName + '.exe'),
    '--version',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
    AppendInstallLog('TryPrewarmShim: ' + ShimBaseName + '.exe exit code ' + IntToStr(ResultCode))
  else
    AppendInstallLog('TryPrewarmShim: unable to start ' + ShimBaseName + '.exe (ignored)');
end;

procedure PrewarmNpmAndNpxShims();
begin
  EnsureShimHardlinkForPrewarm('npm');
  EnsureShimHardlinkForPrewarm('npx');
  TryPrewarmShim('npm');
  TryPrewarmShim('npx');
end;

procedure UpdateFinalizingProgress(
  ProgressPage: TOutputProgressWizardPage;
  const DetailText: String;
  CurrentStep, TotalSteps: Integer
);
begin
  if ProgressPage = nil then
    Exit;

  ProgressPage.SetText('Finalizing installation', DetailText);
  ProgressPage.SetProgress(CurrentStep, TotalSteps);
end;

procedure ConfigureAUMIDForNotifications();
begin
  { Always refresh AUMID values so upgrades fix stale notification icon settings }
  RegWriteStringValue(HKCU, 'Software\Classes\AppUserModelId\AuthorSoftware.NVMWindows', 'DisplayName', '{#Name}');
  RegWriteStringValue(HKCU, 'Software\Classes\AppUserModelId\AuthorSoftware.NVMWindows', 'IconUri', ExpandConstant('{app}\.icons\{#Alias}.ico'));
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  ElevatedExecOk: Boolean;
  FinalizingPage: TOutputProgressWizardPage;
  FinalizingStep: Integer;
  FinalizingTotal: Integer;
begin
  if CurStep = ssDone then
  begin
    InstallCompleted := True;
    Exit;
  end;

  if CurStep <> ssPostInstall then
    Exit;

  FinalizingTotal := 7;
  if RemoveLegacyTasks then
    FinalizingTotal := FinalizingTotal + 1;
  FinalizingTotal := FinalizingTotal + 1;  { for AUMID configuration }
  FinalizingTotal := FinalizingTotal + 1;  { for forced reshim at final step }

  FinalizingStep := 0;
  FinalizingPage := CreateOutputProgressPage(
    'Finalizing installation',
    'Completing migration and Windows integration.'
  );
  FinalizingPage.SetProgress(0, FinalizingTotal);
  FinalizingPage.Show;
  ResetInstallLog();
  AppendInstallLog('CurStepChanged: ssPostInstall start');
  AppendInstallLog('CurStepChanged: app=' + ExpandConstant('{app}'));
  AppendInstallLog('CurStepChanged: install root=' + GetInstallRoot(''));
  AppendInstallLog('CurStepChanged: LegacyInstallDir=' + LegacyInstallDir);
  AppendInstallLog('CurStepChanged: LegacySettingsRoot=' + LegacySettingsRoot);
  AppendInstallLog('CurStepChanged: LegacySettingsPath=' + LegacySettingsPath);
  AppendInstallLog('CurStepChanged: PreviousInstallRoot=' + PreviousInstallRoot);
  AppendInstallLog('CurStepChanged: RemoveLegacyTasks=' + IntToStr(Integer(RemoveLegacyTasks)));
  AppendInstallLog('CurStepChanged: IsPreV2Upgrade=' + IntToStr(Integer(IsPreV2Upgrade)));
  ResetLegacyCleanupWarnings();

  try
    if RemoveLegacyTasks then
    begin
      FinalizingStep := FinalizingStep + 1;
      UpdateFinalizingProgress(FinalizingPage, 'Removing legacy scheduled tasks...', FinalizingStep, FinalizingTotal);
      RemoveLegacyScheduledTasks();
    end;

    FinalizingStep := FinalizingStep + 1;
    UpdateFinalizingProgress(FinalizingPage, 'Migrating installed Node.js versions...', FinalizingStep, FinalizingTotal);
    MigrateNodeStorageIfNeeded();
    if MigrationPerformed and HasSkippedSymlinks() then
      MsgBox(
        'Some migrated links could not be recreated automatically.' + #13#10 + #13#10 +
        'Review the mklink commands in:' + #13#10 +
        SkippedSymlinkLogPath + #13#10 + #13#10 +
        'If you still need them, run those commands manually after setup.',
        mbInformation,
        MB_OK
      );

    FinalizingStep := FinalizingStep + 1;
    UpdateFinalizingProgress(FinalizingPage, 'Registering installed Node.js versions in Windows Apps...', FinalizingStep, FinalizingTotal);
    RegisterInstalledVersionsInWindowsApps();

    FinalizingStep := FinalizingStep + 1;
    UpdateFinalizingProgress(FinalizingPage, 'Creating background sync scheduled task...', FinalizingStep, FinalizingTotal);
    CreateSyncScheduledTask();

    FinalizingStep := FinalizingStep + 1;
    UpdateFinalizingProgress(FinalizingPage, 'Configuring internal Node.js shim junction...', FinalizingStep, FinalizingTotal);
    if not EnsureShimModeNodePathJunction() then
      MsgBox(
        'NVM for Windows could not create the internal .nodejs junction required for shim mode.' + #13#10 + #13#10 +
        'Shim mode may not work correctly until the junction is repaired.',
        mbInformation,
        MB_OK
      );

    FinalizingStep := FinalizingStep + 1;
    UpdateFinalizingProgress(FinalizingPage, 'Updating environment variables and PATH priority...', FinalizingStep, FinalizingTotal);

    if IsPreV2Upgrade then
    begin
      { For v1 upgrades: one UAC prompt covers all privileged cleanup + event log registration. }
      { The helper clears NVM_HOME/NVM_SYMLINK from user+system env and PATH, removes the old  }
      { uninstall keys and install directory, then runs nvm.exe --register-eventlog internally. }
      UpdateFinalizingProgress(FinalizingPage, 'Running v1 migration cleanup (UAC prompt may appear)...', FinalizingStep, FinalizingTotal);
      RunUpgraderHelper();
      { Re-establish the new v2 NVM_HOME in user env and user PATH after the helper cleared them. }
      EnsureNvmPathPriority();
    end
    else
    begin
      EnsureNvmPathPriority();

      FinalizingStep := FinalizingStep + 1;
      UpdateFinalizingProgress(FinalizingPage, 'Registering Windows Event Log source (UAC prompt may appear)...', FinalizingStep, FinalizingTotal);

      ElevatedExecOk := ShellExec(
        'runas',
        ExpandConstant('{app}\{#Alias}.exe'),
        '--register-eventlog',
        '',
        SW_HIDE,
        ewWaitUntilTerminated,
        ResultCode
      );

      { Event source registration is best-effort. Non-admin / declined UAC is expected;
        continue install silently — logs still work as "Unknown" source in Event Viewer. }
      if not ElevatedExecOk then
      begin
        if ResultCode = 1223 then
          AppendInstallLogWarn('Event Log source registration skipped: UAC prompt canceled')
        else
          AppendInstallLogWarn(
            'Event Log source registration skipped: elevation failed (system error ' + IntToStr(ResultCode) + ')'
          );
      end
      else if ResultCode <> 0 then
        AppendInstallLogWarn(
          'Event Log source registration returned exit code ' + IntToStr(ResultCode)
        )
      else
        AppendInstallLog('Event Log source registered successfully');
    end;

    FinalizingStep := FinalizingStep + 1;
    UpdateFinalizingProgress(FinalizingPage, 'Configuring notification center integration...', FinalizingStep, FinalizingTotal);
    ConfigureAUMIDForNotifications();

    FinalizingStep := FinalizingStep + 1;
    UpdateFinalizingProgress(FinalizingPage, 'Rebuilding and prewarming module shims...', FinalizingStep, FinalizingTotal);
    RunForceReshimAtEnd();
    PrewarmNpmAndNpxShims();

    if ShouldRunSubscriptionCommand() then
    begin
      if not Exec(
        ExpandConstant('{cmd}'),
        '/C start "" /B "' + ExpandConstant('{app}\{#Alias}.exe') + '" subscribe "' + EscapeDoubleQuotedCommandArgument(GetSubscriptionEmail()) + '"',
        '',
        SW_HIDE,
        ewNoWait,
        ResultCode
      ) then
      begin
        AppendInstallLogWarn('Failed to launch nvm subscribe command (system error ' + IntToStr(ResultCode) + ')');
      end;
    end
    else
      AppendInstallLog('Subscription command skipped: no email provided');
  finally
    FlushInstallLog();
    FinalizingPage.Hide;
  end;
end;
procedure DeinitializeSetup();
var
  RollbackTotal, RollbackCount: Integer;
begin
  AppendInstallLog('DeinitializeSetup: begin');
  if InstallCompleted or not MigrationPerformed then
  begin
    AppendInstallLog('DeinitializeSetup: no rollback needed');
    Exit;
  end;

  if not DirExists(MigrationDest) then
  begin
    AppendInstallLogWarn('DeinitializeSetup: migration destination missing, skipping rollback');
    Exit;
  end;

  if not ForceDirectories(MigrationSource) then
  begin
    AppendInstallLogWarn('DeinitializeSetup: could not recreate migration source for rollback');
    Exit;
  end;

  RollbackTotal := 0;
  CountFilesInTree(MigrationDest, RollbackTotal);
  RollbackCount := 0;

  if CopyTreeWithProgress(MigrationDest, MigrationSource, nil, RollbackCount, RollbackTotal) then
  begin
    AppendInstallLog('DeinitializeSetup: rollback copy succeeded, deleting migration destination');
    DelTree(MigrationDest, True, True, True);
    MigrationPerformed := False;
  end;
  FlushInstallLog();
end;

procedure RemoveAllNodeVersionsWindowsAppsEntries();
var
  SubKeys: TArrayOfString;
  I: Integer;
  KeyName: String;
begin
  if not RegGetSubkeyNames(HKCU, WindowsAppsUninstallRoot, SubKeys) then
    Exit;

  for I := 0 to GetArrayLength(SubKeys) - 1 do
  begin
    KeyName := SubKeys[I];
    if Pos('nvm4w-node-v', KeyName) = 1 then
      RegDeleteKeyIncludingSubkeys(HKCU, WindowsAppsUninstallRoot + '\' + KeyName);
  end;
end;

function GetInstallRootForUninstall(): String;
begin
  Result := '';
  if not RegQueryStringValue(HKCU, '{#RegistryKey}', 'InstallRoot', Result) then
    Result := ExpandConstant('{localappdata}\{#OrgLabel}\{#Alias}\installs');
  Result := Trim(Result);
end;

procedure CleanupInstallRootOnUninstall();
var
  RootToRemove: String;
begin
  RootToRemove := Trim(UninstallInstallRoot);
  if RootToRemove = '' then
    RootToRemove := GetInstallRootForUninstall();

  if RootToRemove = '' then
    Exit;

  if not DirExists(RootToRemove) then
    Exit;

  if not IsSafeRemovableDirectory(RootToRemove) then
  begin
    Log('Skipping install root removal due to safety check: ' + RootToRemove);
    Exit;
  end;

  if DelTree(RootToRemove, True, True, True) then
    Log('Removed install root directory: ' + RootToRemove)
  else
    Log('Failed to remove install root directory: ' + RootToRemove);
end;

procedure CleanupAppRootOnUninstall();
var
  AppRoot: String;
  OrgRoot: String;
  CleanupScriptFile: String;
  CleanupScript: String;
  AppRootEscaped: String;
  OrgRootEscaped: String;
  ResultCode: Integer;
begin
  AppRoot := Trim(UninstallAppRoot);
  if AppRoot = '' then
    AppRoot := ExpandConstant('{app}');

  AppRoot := RemoveBackslashUnlessRoot(AppRoot);

  if (AppRoot = '') or (not DirExists(AppRoot)) then
    Exit;

  OrgRoot := RemoveBackslashUnlessRoot(ExtractFileDir(AppRoot));

  if not IsSafeRemovableDirectory(AppRoot) then
  begin
    Log('Skipping app root removal due to safety check: ' + AppRoot);
    Exit;
  end;

  if RemoveDir(AppRoot) then
  begin
    Log('Removed app root directory: ' + AppRoot);

    if (OrgRoot <> '') and DirExists(OrgRoot) and IsSafeRemovableDirectory(OrgRoot) then
    begin
      if RemoveDir(OrgRoot) then
        Log('Removed empty org root directory: ' + OrgRoot)
      else
        Log('Org root not removed (not empty or in use): ' + OrgRoot);
    end;

    Exit;
  end;

  if (OrgRoot <> '') and (not IsSafeRemovableDirectory(OrgRoot)) then
  begin
    Log('Skipping org root removal due to safety check: ' + OrgRoot);
    OrgRoot := '';
  end;

  Log('Immediate app root removal failed, scheduling delayed cleanup: ' + AppRoot);

  AppRootEscaped := EscapeSingleQuotedPowerShellString(AppRoot);
  OrgRootEscaped := EscapeSingleQuotedPowerShellString(OrgRoot);
  CleanupScriptFile := ExpandConstant('{tmp}\nvm-uninstall-app-cleanup.ps1');
  CleanupScript :=
    '$app = ''' + AppRootEscaped + '''' + #13#10 +
    '$org = ''' + OrgRootEscaped + '''' + #13#10 +
    'Start-Sleep -Seconds 4' + #13#10 +
    'if (Test-Path -LiteralPath $app) { Remove-Item -LiteralPath $app -Recurse -Force -ErrorAction SilentlyContinue }' + #13#10 +
    'if ($org -ne '''') {' + #13#10 +
    '  if (Test-Path -LiteralPath $org) {' + #13#10 +
    '    $items = @(Get-ChildItem -LiteralPath $org -Force -ErrorAction SilentlyContinue)' + #13#10 +
    '    if ($items.Count -eq 0) { Remove-Item -LiteralPath $org -Force -ErrorAction SilentlyContinue }' + #13#10 +
    '  }' + #13#10 +
    '}';

  SaveStringToFile(CleanupScriptFile, CleanupScript, False);
  Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + CleanupScriptFile + '"',
    '',
    SW_HIDE,
    ewNoWait,
    ResultCode
  );
end;

procedure CleanupSettingsRegistryOnUninstall();
var
  RegistryCleanupScriptFile: String;
  RegistryCleanupScript: String;
  ResultCode: Integer;
begin
  RegistryCleanupScriptFile := ExpandConstant('{tmp}\nvm-registry-cleanup.ps1');
  RegistryCleanupScript :=
    '$orgKey = ''Software\{#OrgLabel}''' + #13#10 +
    '$preferencesKey = $orgKey + ''\Preferences''' + #13#10 +
    '$aliasKey = $preferencesKey + ''\{#Alias}''' + #13#10 +
    '$hkcu = [Microsoft.Win32.Registry]::CurrentUser' + #13#10 +
    'try { $hkcu.DeleteSubKeyTree($aliasKey, $false) } catch {}' + #13#10 +
    'function Remove-IfEmpty([Microsoft.Win32.RegistryKey]$root, [string]$path) {' + #13#10 +
    '  $k = $root.OpenSubKey($path, $true)' + #13#10 +
    '  if ($null -eq $k) { return }' + #13#10 +
    '  $isEmpty = ($k.SubKeyCount -eq 0) -and ($k.ValueCount -eq 0)' + #13#10 +
    '  $k.Close()' + #13#10 +
    '  if ($isEmpty) {' + #13#10 +
    '    try { $root.DeleteSubKey($path, $false) } catch {}' + #13#10 +
    '  }' + #13#10 +
    '}' + #13#10 +
    'Remove-IfEmpty -root $hkcu -path $preferencesKey' + #13#10 +
    'Remove-IfEmpty -root $hkcu -path $orgKey';

  SaveStringToFile(RegistryCleanupScriptFile, RegistryCleanupScript, False);
  Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + RegistryCleanupScriptFile + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );
  DeleteFile(RegistryCleanupScriptFile);

  if ResultCode <> 0 then
    Log('Registry cleanup script returned exit code ' + IntToStr(ResultCode) + '.');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    UninstallAppRoot := ExpandConstant('{app}');
    UninstallInstallRoot := GetInstallRootForUninstall();
    RemoveAllNodeVersionsWindowsAppsEntries();
  end;

  if CurUninstallStep = usPostUninstall then
  begin
    CleanupSettingsRegistryOnUninstall();
    CleanupInstallRootOnUninstall();
  end;

  if CurUninstallStep = usDone then
    CleanupAppRootOnUninstall();
end;