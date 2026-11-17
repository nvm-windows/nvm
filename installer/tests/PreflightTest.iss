#define Name "NVM for Windows"
#define Version "0.0.0-test"

[Setup]
AppId={{8A1B2C3D-4E5F-6071-8293-A4B5C6D7E8F0}
AppName={#Name}
AppVersion={#Version}
DefaultDirName={localappdata}\nvm-preflight-inno-test
PrivilegesRequired=lowest
OutputBaseFilename=preflight-compile-test
DisableDirPage=yes
DisableProgramGroupPage=yes
Uninstallable=no
CreateAppDir=yes
Compression=none
SolidCompression=no
CloseApplications=no

[Code]
var
  InstallLogPath: String;
  InstallLogBuffer: String;
  InstallLogHasIssues: Boolean;
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

procedure AppendInstallLog(const Message: String);
begin
  InstallLogBuffer := InstallLogBuffer + Message + #13#10;
end;

procedure AppendInstallLogWarn(const Message: String);
begin
  InstallLogHasIssues := True;
  AppendInstallLog(Message);
end;

#include "..\installtimeout.iss"
#include "..\installpreflight.iss"

procedure AssertTrue(const Cond: Boolean; const LabelText: String);
begin
  if not Cond then
    RaiseException('Assertion failed: ' + LabelText);
end;

procedure AssertEqualInt(Expected, Actual: Integer; const LabelText: String);
begin
  if Expected <> Actual then
    RaiseException(
      'Assertion failed: ' + LabelText +
      ' expected=' + IntToStr(Expected) +
      ' actual=' + IntToStr(Actual)
    );
end;

function InitializeSetup(): Boolean;
var
  Dir, LogPath, RecordPath, Marker: String;
  Contents: AnsiString;
  Bytes200MiB, Bytes1GiB, Bytes10GiB: Int64;
begin
  Marker := ExpandConstant('{localappdata}\nvm-preflight-test-result.txt');
  Result := False;
  try
    Bytes200MiB := 200 * 1024;
    Bytes200MiB := Bytes200MiB * 1024;
    Bytes1GiB := 1024 * 1024;
    Bytes1GiB := Bytes1GiB * 1024;
    Bytes10GiB := 10 * 1024;
    Bytes10GiB := Bytes10GiB * 1024 * 1024;

    AssertEqualInt(300, CopyHardTimeoutSec(0, 0), 'empty tree floor');
    AssertEqualInt(300, CopyHardTimeoutSec(100, 1024 * 1024), 'small tree stays at floor');
    AssertEqualInt(350, CopyHardTimeoutSec(10000, 0), 'file-count bump');
    AssertEqualInt(400, CopyHardTimeoutSec(0, Bytes200MiB), 'bytes bump');
    AssertEqualInt(900, CopyHardTimeoutSec(1000000, Bytes10GiB), 'clamp max');

    AssertTrue(AntivirusLooksLikeEnterpriseAgent('CrowdStrike Falcon'), 'crowdstrike agent');
    AssertTrue(not AntivirusLooksLikeEnterpriseAgent('Windows Defender'), 'defender alone');
    AssertTrue(not AntivirusLooksLikeEnterpriseAgent('Not Detected'), 'not detected');
    AssertTrue(ShouldWarnBeforeMigration(100000, 0, 'Windows Defender'), 'file threshold');
    AssertTrue(ShouldWarnBeforeMigration(1, Bytes1GiB, 'Windows Defender'), 'byte threshold');
    AssertTrue(ShouldWarnBeforeMigration(1, 1, 'SentinelOne'), 'edr threshold');
    AssertTrue(not ShouldWarnBeforeMigration(10, 10, 'Windows Defender'), 'small defender tree');

    AssertTrue(SameVolumePaths('C:\a', 'C:\b'), 'same volume');
    AssertTrue(not SameVolumePaths('C:\a', 'D:\b'), 'cross volume');

    WriteInstallerFailureRecord('NVM4105', 'unit test failure message');
    Dir := GetInstallerReportDirectory;
    LogPath := GetInstallerSetupLogPath;
    RecordPath := GetInstallerFailureRecordPath;
    AssertTrue(DirExists(Dir), 'report dir exists');
    AssertTrue(FileExists(LogPath), 'setup log exists');
    AssertTrue(FileExists(RecordPath), 'failure record exists');
    if not LoadStringFromFile(RecordPath, Contents) then
      RaiseException('could not read failure record');
    AssertTrue(Pos('NVM4105', Contents) > 0, 'failure code present');
    AssertTrue(Pos('unit test failure message', Contents) > 0, 'failure message body');
    AssertTrue(Pos('nvm-setup.log', Contents) > 0, 'failure log path body');

    if not LoadStringFromFile(LogPath, Contents) then
      RaiseException('could not read setup log');
    AssertTrue(Pos('NVM4105', Contents) > 0, 'setup log contains code');

    SaveStringToFile(Marker, 'PASS' + #13#10, False);
    Log('PreflightTest passed marker=' + Marker);
  except
    SaveStringToFile(Marker, 'FAIL ' + GetExceptionMessage + #13#10, False);
    Log('PreflightTest failed: ' + GetExceptionMessage);
  end;
end;
