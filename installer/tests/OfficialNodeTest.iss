; Compiles the real officialnode.iss choices without uninstalling Node.js.
; The PowerShell suite passes /OFFICIALNODELOG so Drop records msiexec instead of launching it.

#define Alias "nvm"

[Setup]
AppId={{7E4C1A2B-9D10-4F55-A111-0FF1C1A10002}
AppName=NVM Official Node Choice Test
AppVersion=1.0.0
DefaultDirName={localappdata}\nvm-officialnode-inno-test
PrivilegesRequired=lowest
OutputBaseFilename=officialnode-choice-test
DisableDirPage=yes
DisableProgramGroupPage=yes
Uninstallable=no
CreateAppDir=yes
Compression=none
SolidCompression=no
CloseApplications=no

[Code]
var
  OfficialNodePage: TInputOptionWizardPage;
  OfficialNodeDetected: Boolean;
  OfficialNodePath: String;
  OfficialNodeVersion: String;
  OfficialNodeProductCode: String;
  OfficialNodeUninstallString: String;
  OfficialNodeIsMsi: Boolean;
  OfficialNodeModuleCount: Integer;
  OfficialNodeModuleSize: Int64;
  OfficialNodeAction: String;
  OfficialNodeCopyFailed: Boolean;
  OfficialNodeDropFailed: Boolean;
  OfficialNodeDropError: String;
  InstallerHardFailed: Boolean;
  SuppressStepFailure: Boolean;
  StepBudgetArmed: Boolean;
  BudgetDeadline: Cardinal;
  BudgetCode: String;
  BudgetMessage: String;
  ExecStepProgressPage: TOutputProgressWizardPage;
  ExecStepSoftWarnSec: Integer;
  ExecStepSoftWarnDetail: String;
  ExecStepSoftWarnVersion: String;
  LastInstallerFailureCode: String;
  LastInstallerFailureMessage: String;
  LastInstallerFailureLogPath: String;
  DeferOfficialNodeOnV2Upgrade: Boolean;

const
  WAIT_OBJECT_0 = 0;
  WAIT_TIMEOUT = $00000102;
  SYNCHRONIZE = $00100000;
  PROCESS_TERMINATE = $0001;
  PROCESS_QUERY_LIMITED_INFORMATION = $1000;
  CSIDL_COMMON_APPDATA = $0023;
  InstallLogSliceMaxChars = 49152;
  SC_MANAGER_CONNECT = $0001;
  SERVICE_QUERY_STATUS = $0004;
  SERVICE_RUNNING = $00000004;
  CopySoftWarnSecDefault = 90;
  CopyHardTimeoutMinSec = 300;
  CopyHardTimeoutMaxSec = 900;
  MigrationWarnMinFiles = 100000;
  MigrationWarnMinBytes = 1073741824;

type
  TServiceStatus = record
    dwServiceType: DWORD;
    dwCurrentState: DWORD;
    dwControlsAccepted: DWORD;
    dwWin32ExitCode: DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint: DWORD;
    dwWaitHint: DWORD;
  end;

function OpenProcess(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): THandle;
  external 'OpenProcess@kernel32.dll stdcall';
function CloseHandle(hObject: THandle): BOOL;
  external 'CloseHandle@kernel32.dll stdcall';

#include "..\installtimeout.iss"
#include "..\installpreflight.iss"

function NormalizePath(const PathValue: String): String;
begin
  Result := Trim(PathValue);
  while (Length(Result) > 3) and (Result[Length(Result)] = '\') do
    Result := Copy(Result, 1, Length(Result) - 1);
end;

function GetRealProgramRoot(Param: String): String;
begin
  Result := ExpandConstant('{localappdata}\Author Software\nvm');
end;

function GetInstallRoot(Param: String): String;
begin
  Result := ExpandConstant('{param:INSTALLROOT}');
end;

procedure AppendInstallLog(const Message: String);
var
  LogPath: String;
begin
  LogPath := Trim(ExpandConstant('{param:INSTALLLOG}'));
  if LogPath <> '' then
    SaveStringToFile(LogPath, Message + #13#10, True);
end;

procedure AppendInstallLogWarn(const Message: String);
begin
  AppendInstallLog('WARN ' + Message);
end;

function CopyTreeWithProgress(
  const SourceDir, DestDir: String;
  ProgressPage: TOutputProgressWizardPage;
  var CopiedCount: Integer;
  const TotalCount: Integer;
  const VersionLabel: String
): Boolean;
var
  ResultCode: Integer;
begin
  Result := False;
  if not ForceDirectories(DestDir) then
    Exit;
  if not Exec(
    'robocopy.exe',
    '"' + SourceDir + '" "' + DestDir + '" /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
    Exit;
  Result := ResultCode < 8;
  if Result then
    CopiedCount := CopiedCount + 1;
end;

#include "..\officialnode.iss"

procedure InitializeWizard();
begin
  OfficialNodeDetected := ExpandConstant('{param:NODEFOUND}') = '1';
  OfficialNodePath := ExpandConstant('{param:NODESOURCE}');
  OfficialNodeVersion := '22.14.0';
  OfficialNodeUninstallString := '';
  OfficialNodeIsMsi := True;
  OfficialNodeModuleCount := 1;
  OfficialNodeModuleSize := 1024;
  OfficialNodeCopyFailed := False;
  OfficialNodeDropFailed := False;
  OfficialNodeDropError := '';
  OfficialNodeAction := OfficialNodeParam();
  if ExpandConstant('{param:SKIPPRODUCT}') = '1' then
    OfficialNodeProductCode := ''
  else
    OfficialNodeProductCode := '{AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE}';
  if OfficialNodeDetected then
    CreateOfficialNodePage();
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep <> ssPostInstall then
    Exit;
  ApplyOfficialNodeChoice();
end;

procedure DeinitializeSetup();
var
  Path: String;
  Body: String;
begin
  Path := Trim(ExpandConstant('{param:OFFICIALNODERESULT}'));
  if Path = '' then
    Exit;
  Body :=
    'action=' + OfficialNodeAction + #13#10 +
    'detected=' + IntToStr(Integer(OfficialNodeDetected)) + #13#10 +
    'copyfailed=' + IntToStr(Integer(OfficialNodeCopyFailed)) + #13#10 +
    'dropfailed=' + IntToStr(Integer(OfficialNodeDropFailed)) + #13#10 +
    'error=' + OfficialNodeDropError + #13#10;
  SaveStringToFile(Path, Body, False);
end;
