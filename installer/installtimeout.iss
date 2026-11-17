function GetTickCount: Cardinal;
  external 'GetTickCount@kernel32.dll stdcall';

function WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD;
  external 'WaitForSingleObject@kernel32.dll stdcall';

function TerminateProcess(hProcess: THandle; uExitCode: DWORD): BOOL;
  external 'TerminateProcess@kernel32.dll stdcall';

function GetExitCodeProcess(hProcess: THandle; var lpExitCode: DWORD): BOOL;
  external 'GetExitCodeProcess@kernel32.dll stdcall';

function SHGetFolderPathWReport(hwnd: HWND; csidl: Integer; hToken: THandle; dwFlags: DWORD; pszPath: String): Integer;
  external 'SHGetFolderPathW@shell32.dll stdcall';

function InstallerReportScript: String;
begin
  Result := ExpandConstant('{tmp}\InstallerReport.ps1');
  if not FileExists(Result) then
    Result := ExpandConstant('{app}\utils\InstallerReport.ps1');
end;

function GetInstallerReportDirectory: String;
var
  Buf: String;
  Nul: Integer;
begin
  SetLength(Buf, 260);
  if SHGetFolderPathWReport(0, CSIDL_COMMON_APPDATA, 0, 0, Buf) = 0 then
  begin
    Nul := Pos(#0, Buf);
    if Nul > 1 then
      Result := Copy(Buf, 1, Nul - 1)
    else
      Result := Trim(Buf);
  end
  else
    Result := ExpandConstant('{commonappdata}');
  if Result = '' then
    Result := ExpandConstant('{sd}\ProgramData');
  Result := AddBackslash(Result) + 'Author Software';
end;

function GetInstallerSetupLogPath: String;
begin
  Result := AddBackslash(GetInstallerReportDirectory) + 'nvm-setup.log';
end;

function GetInstallerFailureRecordPath: String;
begin
  Result := AddBackslash(GetInstallerReportDirectory) + 'nvm-setup-failure.txt';
end;

procedure AppendProgramDataSetupLog(const Message: String);
var
  Dir, LogPath, Line, OneLine: String;
begin
  Dir := GetInstallerReportDirectory;
  if not ForceDirectories(Dir) then
    Exit;
  LogPath := AddBackslash(Dir) + 'nvm-setup.log';
  OneLine := Trim(Message);
  StringChangeEx(OneLine, #13, ' ', True);
  StringChangeEx(OneLine, #10, ' ', True);
  Line :=
    GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':') + ' ' + OneLine;
  SaveStringToFile(LogPath, Line + #13#10, True);
end;

procedure WriteInstallerFailureRecord(const FailureCode, FailureMessage: String);
var
  Dir, LogPath, RecordPath, OneLine, Body: String;
begin
  Dir := GetInstallerReportDirectory;
  if not ForceDirectories(Dir) then
    Exit;
  LogPath := AddBackslash(Dir) + 'nvm-setup.log';
  RecordPath := AddBackslash(Dir) + 'nvm-setup-failure.txt';
  OneLine := Trim(FailureMessage);
  StringChangeEx(OneLine, #13, ' ', True);
  StringChangeEx(OneLine, #10, ' ', True);
  AppendProgramDataSetupLog(FailureCode + ' ' + OneLine);
  Body := FailureCode + #13#10 + OneLine + #13#10 + LogPath + #13#10;
  SaveStringToFile(RecordPath, Body, False);
  LastInstallerFailureCode := FailureCode;
  LastInstallerFailureMessage := OneLine;
  LastInstallerFailureLogPath := LogPath;
end;

procedure BeginStepBudget(const Code, Message: String; TimeoutSec: Integer);
begin
  BudgetCode := Code;
  BudgetMessage := Message;
  StepBudgetArmed := TimeoutSec > 0;
  if StepBudgetArmed then
    BudgetDeadline := GetTickCount + Cardinal(TimeoutSec) * 1000
  else
    BudgetDeadline := 0;
end;

function WalkTimeoutSec(const VersionCount: Integer): Integer;
begin
  if VersionCount < 1 then
    Result := 600
  else
    Result := VersionCount * 120;
  if Result < 600 then
    Result := 600;
  if Result > 1800 then
    Result := 1800;
end;

function RemainingBudgetSec: Integer;
var
  LeftMs: Integer;
begin
  if not StepBudgetArmed then
  begin
    Result := 180;
    Exit;
  end;
  LeftMs := Integer(BudgetDeadline - GetTickCount);
  if LeftMs < 1000 then
    Result := 0
  else
    Result := LeftMs div 1000;
end;

procedure ClearExecStepSoftWarn;
begin
  ExecStepProgressPage := nil;
  ExecStepSoftWarnSec := 0;
  ExecStepSoftWarnDetail := '';
  ExecStepSoftWarnVersion := '';
end;

procedure ArmExecStepSoftWarn(
  Page: TOutputProgressWizardPage;
  SoftWarnSec: Integer;
  const VersionLabel, Detail: String
);
begin
  ExecStepProgressPage := Page;
  ExecStepSoftWarnSec := SoftWarnSec;
  ExecStepSoftWarnVersion := VersionLabel;
  ExecStepSoftWarnDetail := Detail;
end;

procedure NotifyExecStepSoftWarn;
var
  Detail: String;
begin
  if ExecStepProgressPage = nil then
    Exit;
  Detail := Trim(ExecStepSoftWarnDetail);
  if Detail = '' then
    Detail :=
      'Still copying. Large installs or security software can slow this step.';
  if Trim(ExecStepSoftWarnVersion) <> '' then
    ExecStepProgressPage.SetText(
      'Migrating Node.js versions',
      'Copying ' + Trim(ExecStepSoftWarnVersion) + '... ' + Detail
    )
  else
    ExecStepProgressPage.SetText('Migrating Node.js versions', Detail);
  try
    WizardForm.Refresh;
  except
  end;
end;

function ExecStepElevatedViaPowerShell(
  const FileName, Params, Code, Message: String;
  TimeoutSec: Integer;
  SoftFail: Boolean;
  var ResultCode: Integer
): Boolean;
var
  ScriptPath, ArgPath, CommandLine, Flags: String;
  LaunchCode: Integer;
begin
  { Narrow elevate path only: ShellExecuteEx runas packing is fragile on x64 Inno. }
  Result := False;
  ScriptPath := InstallerReportScript;
  if not FileExists(ScriptPath) then
  begin
    Result := Exec(FileName, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exit;
  end;
  ArgPath := ExpandConstant('{tmp}\nvm-step-args.txt');
  SaveStringToFile(ArgPath, Params, False);
  Flags := ' -RunAs';
  if SoftFail then
    Flags := Flags + ' -SoftFail';
  CommandLine :=
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '"' +
    ' -Action run -Exe "' + FileName + '" -ArgumentsFile "' + ArgPath + '"' +
    ' -TimeoutSec ' + IntToStr(TimeoutSec) +
    ' -Code ' + Code +
    ' -Message "' + Message + '"' +
    Flags;
  if not Exec(ExpandConstant('{cmd}'), CommandLine, '', SW_HIDE, ewWaitUntilTerminated, LaunchCode) then
  begin
    ResultCode := LaunchCode;
    Exit;
  end;
  ResultCode := LaunchCode;
  if LaunchCode = 1460 then
  begin
    InstallerHardFailed := True;
    WriteInstallerFailureRecord(Code, Message);
    Exit;
  end;
  Result := True;
end;

function ExecStepNative(
  const FileName, Params, Code, Message: String;
  TimeoutSec: Integer;
  SoftFail: Boolean;
  var ResultCode: Integer
): Boolean;
var
  Pid: Integer;
  Process: THandle;
  WaitMs, ElapsedMs, SliceMs, SoftWarnMs: Cardinal;
  WaitRc, ExitCode: DWORD;
  SoftWarned: Boolean;
  Msg: String;
begin
  Result := False;
  ResultCode := 0;
  SoftWarned := False;
  SoftWarnMs := 0;
  if ExecStepSoftWarnSec > 0 then
    SoftWarnMs := Cardinal(ExecStepSoftWarnSec) * 1000;

  if not Exec(FileName, Params, '', SW_HIDE, ewNoWait, Pid) then
  begin
    ResultCode := Pid;
    Exit;
  end;
  if Pid <= 0 then
  begin
    ResultCode := 1;
    Exit;
  end;

  Process := OpenProcess(
    SYNCHRONIZE or PROCESS_TERMINATE or PROCESS_QUERY_LIMITED_INFORMATION,
    False,
    DWORD(Pid)
  );
  ElapsedMs := 0;
  WaitMs := Cardinal(TimeoutSec) * 1000;
  try
    while True do
    begin
      SliceMs := 2000;
      if (WaitMs - ElapsedMs) < SliceMs then
        SliceMs := WaitMs - ElapsedMs;
      if SliceMs < 1 then
        SliceMs := 1;

      if Process = 0 then
      begin
        { Limited wait without terminate rights if the full open failed. }
        Process := OpenProcess(SYNCHRONIZE, False, DWORD(Pid));
        if Process = 0 then
        begin
          ResultCode := 0;
          Result := True;
          Exit;
        end;
        WaitRc := WaitForSingleObject(Process, SliceMs);
        CloseHandle(Process);
        Process := 0;
        if WaitRc = WAIT_OBJECT_0 then
        begin
          ResultCode := 0;
          Result := True;
          Exit;
        end;
      end
      else
      begin
        WaitRc := WaitForSingleObject(Process, SliceMs);
        if WaitRc = WAIT_OBJECT_0 then
        begin
          ExitCode := 1;
          if not GetExitCodeProcess(Process, ExitCode) then
            ExitCode := 1;
          ResultCode := Integer(ExitCode);
          if (not SoftFail) and (ResultCode <> 0) and (ResultCode >= 8) and (Code <> '') then
          begin
            Msg := Message;
            if Msg = '' then
              Msg := 'The setup step failed with exit code ' + IntToStr(ResultCode) + '.';
            WriteInstallerFailureRecord(Code, Msg);
          end;
          Result := True;
          Exit;
        end;
      end;

      ElapsedMs := ElapsedMs + SliceMs;
      if (not SoftWarned) and (SoftWarnMs > 0) and (ElapsedMs >= SoftWarnMs) then
      begin
        SoftWarned := True;
        NotifyExecStepSoftWarn;
      end;

      try
        WizardForm.Refresh;
      except
      end;

      if ElapsedMs >= WaitMs then
      begin
        if Process <> 0 then
        begin
          TerminateProcess(Process, 1);
          WaitForSingleObject(Process, 5000);
        end;
        ResultCode := 1460;
        InstallerHardFailed := True;
        Msg := Message;
        if Msg = '' then
          Msg := 'The setup step exceeded its time limit.';
        WriteInstallerFailureRecord(Code, Msg);
        Exit;
      end;
    end;
  finally
    if Process <> 0 then
      CloseHandle(Process);
  end;
end;

function ExecStep(
  const FileName, Params, Code, Message: String;
  TimeoutSec: Integer;
  SoftFail, RunAs: Boolean;
  var ResultCode: Integer
): Boolean;
begin
  Result := False;
  ResultCode := 0;
  if InstallerHardFailed then
  begin
    ResultCode := 1460;
    Exit;
  end;
  if SuppressStepFailure then
  begin
    Result := Exec(FileName, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exit;
  end;
  if TimeoutSec <= 0 then
  begin
    ResultCode := 1460;
    InstallerHardFailed := True;
    WriteInstallerFailureRecord(Code, Message);
    Exit;
  end;

  if RunAs then
    Result := ExecStepElevatedViaPowerShell(
      FileName, Params, Code, Message, TimeoutSec, SoftFail, ResultCode
    )
  else
    Result := ExecStepNative(
      FileName, Params, Code, Message, TimeoutSec, SoftFail, ResultCode
    );
end;

function ShowInstallerFailureDialog(): Boolean;
var
  ScriptPath: String;
  ResultCode: Integer;
begin
  Result := False;
  ScriptPath := InstallerReportScript;
  if not FileExists(ScriptPath) then
    Exit;
  if not Exec(
    ExpandConstant('{cmd}'),
    '/C powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '" -Action dialog',
    '',
    SW_SHOWNORMAL,
    ewWaitUntilTerminated,
    ResultCode
  ) then
    Exit;
  Result := ResultCode = 0;
end;

procedure ShowInstallerFailureMsgBoxFallback();
var
  LogPath, Code, Msg: String;
begin
  Code := LastInstallerFailureCode;
  Msg := LastInstallerFailureMessage;
  LogPath := LastInstallerFailureLogPath;
  if LogPath = '' then
    LogPath := GetInstallerSetupLogPath;
  if Code = '' then
    Code := 'NVM4100';
  if Msg = '' then
    Msg := 'Setup failed and will roll back this installation.';
  MsgBox(
    Code + #13#10 + Msg + #13#10 + #13#10 +
    'Details were saved to:' + #13#10 + LogPath + #13#10 +
    GetInstallerFailureRecordPath(),
    mbError,
    MB_OK
  );
end;

procedure ScheduleInstallerRollback();
var
  Uninstaller, CommandLine: String;
  ResultCode: Integer;
begin
  Uninstaller := ExpandConstant('{app}\unins000.exe');
  if not FileExists(Uninstaller) then
    Exit;
  CommandLine :=
    '/C ping -n 8 127.0.0.1 >nul & "' + Uninstaller + '" /SILENT';
  Exec(ExpandConstant('{cmd}'), CommandLine, '', SW_HIDE, ewNoWait, ResultCode);
end;
