function OpenSCManagerW(lpMachineName, lpDatabaseName: String; dwDesiredAccess: DWORD): THandle;
  external 'OpenSCManagerW@advapi32.dll stdcall';

function OpenServiceW(hSCManager: THandle; lpServiceName: String; dwDesiredAccess: DWORD): THandle;
  external 'OpenServiceW@advapi32.dll stdcall';

function QueryServiceStatus(hService: THandle; var lpServiceStatus: TServiceStatus): BOOL;
  external 'QueryServiceStatus@advapi32.dll stdcall';

function CloseServiceHandle(hSCObject: THandle): BOOL;
  external 'CloseServiceHandle@advapi32.dll stdcall';

function GetDiskFreeSpaceExW(
  lpDirectoryName: String;
  var lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes, lpTotalNumberOfFreeBytes: Int64
): BOOL;
  external 'GetDiskFreeSpaceExW@kernel32.dll stdcall';

function ServiceIsRunning(const ServiceName: String): Boolean;
var
  Manager, Service: THandle;
  Status: TServiceStatus;
begin
  Result := False;
  Manager := OpenSCManagerW('', '', SC_MANAGER_CONNECT);
  if Manager = 0 then
    Exit;
  try
    Service := OpenServiceW(Manager, ServiceName, SERVICE_QUERY_STATUS);
    if Service = 0 then
      Exit;
    try
      if QueryServiceStatus(Service, Status) then
        Result := Status.dwCurrentState = SERVICE_RUNNING;
    finally
      CloseServiceHandle(Service);
    end;
  finally
    CloseServiceHandle(Manager);
  end;
end;

function AppendUniqueLabel(const Existing, LabelName: String): String;
var
  Needle: String;
begin
  if Trim(LabelName) = '' then
  begin
    Result := Existing;
    Exit;
  end;
  Needle := ',' + LowerCase(LabelName) + ',';
  if Pos(Needle, ',' + LowerCase(Existing) + ',') > 0 then
  begin
    Result := Existing;
    Exit;
  end;
  if Existing = '' then
    Result := LabelName
  else
    Result := Existing + ', ' + LabelName;
end;

function DetectInstallerAntivirusLabel: String;
begin
  Result := '';
  if ServiceIsRunning('WinDefend') or
     RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows Defender') then
    Result := AppendUniqueLabel(Result, 'Windows Defender');
  if ServiceIsRunning('ArcticWolfAgent') then
    Result := AppendUniqueLabel(Result, 'Arctic Wolf Agent');
  if ServiceIsRunning('CSFalconService') then
    Result := AppendUniqueLabel(Result, 'CrowdStrike Falcon');
  if ServiceIsRunning('SentinelAgent') then
    Result := AppendUniqueLabel(Result, 'SentinelOne');
  if ServiceIsRunning('CylanceSvc') then
    Result := AppendUniqueLabel(Result, 'Cylance');
  if ServiceIsRunning('CarbonBlack') or ServiceIsRunning('CBDefense') then
    Result := AppendUniqueLabel(Result, 'Carbon Black');
  if Result = '' then
    Result := 'Not Detected';
end;

function AntivirusLooksLikeEnterpriseAgent(const LabelText: String): Boolean;
var
  Lower: String;
begin
  Lower := LowerCase(LabelText);
  Result :=
    (Pos('crowdstrike', Lower) > 0) or
    (Pos('sentinelone', Lower) > 0) or
    (Pos('arctic wolf', Lower) > 0) or
    (Pos('cylance', Lower) > 0) or
    (Pos('carbon black', Lower) > 0);
end;

function CopyHardTimeoutSec(FileCount: Integer; Bytes: Int64): Integer;
var
  BytesMiB: Integer;
begin
  if Bytes < 0 then
    Bytes := 0;
  BytesMiB := Integer(Bytes div (1024 * 1024));
  if FileCount < 0 then
    FileCount := 0;
  Result := CopyHardTimeoutMinSec + (FileCount div 200) + (BytesMiB div 2);
  if Result < CopyHardTimeoutMinSec then
    Result := CopyHardTimeoutMinSec;
  if Result > CopyHardTimeoutMaxSec then
    Result := CopyHardTimeoutMaxSec;
end;

procedure MeasureTreeBytes(const RootDir: String; var Bytes: Int64);
var
  FindRec: TFindRec;
  CurrentPath: String;
  Chunk: Int64;
begin
  if not FindFirst(AddBackslash(RootDir) + '*', FindRec) then
    Exit;
  try
    repeat
      if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
      begin
        CurrentPath := AddBackslash(RootDir) + FindRec.Name;
        if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
        begin
          if (FindRec.Attributes and FILE_ATTRIBUTE_REPARSE_POINT) = 0 then
            MeasureTreeBytes(CurrentPath, Bytes);
        end
        else
        begin
          Chunk := FindRec.SizeHigh;
          Chunk := (Chunk shl 32) + FindRec.SizeLow;
          Bytes := Bytes + Chunk;
        end;
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

procedure CountTreeFilesAndBytes(const RootDir: String; var FileCount: Integer; var Bytes: Int64);
var
  FindRec: TFindRec;
  CurrentPath: String;
  Chunk: Int64;
begin
  if not FindFirst(AddBackslash(RootDir) + '*', FindRec) then
    Exit;
  try
    repeat
      if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
      begin
        CurrentPath := AddBackslash(RootDir) + FindRec.Name;
        if (FindRec.Attributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0 then
          { Skip junctions/symlinks so counts match migration copy behavior. }
        else if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
          CountTreeFilesAndBytes(CurrentPath, FileCount, Bytes)
        else
        begin
          FileCount := FileCount + 1;
          Chunk := FindRec.SizeHigh;
          Chunk := (Chunk shl 32) + FindRec.SizeLow;
          Bytes := Bytes + Chunk;
        end;
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

function SameVolumePaths(const LeftPath, RightPath: String): Boolean;
begin
  Result :=
    CompareText(ExtractFileDrive(LeftPath), ExtractFileDrive(RightPath)) = 0;
end;

function GetPathFreeBytes(const PathValue: String; var FreeBytes: Int64): Boolean;
var
  TotalBytes, TotalFree: Int64;
  Probe: String;
begin
  FreeBytes := 0;
  Probe := Trim(PathValue);
  if Probe = '' then
  begin
    Result := False;
    Exit;
  end;
  if not DirExists(Probe) then
    Probe := ExtractFileDrive(Probe) + '\';
  Result := GetDiskFreeSpaceExW(Probe, FreeBytes, TotalBytes, TotalFree);
end;

function FormatByteSize(const Bytes: Int64): String;
var
  Mb: Extended;
begin
  if Bytes <= 0 then
  begin
    Result := '0 MB';
    Exit;
  end;
  Mb := Bytes / (1024.0 * 1024.0);
  if Mb < 10.0 then
    Result := Format('%.1f MB', [Mb])
  else if Mb < 1024.0 then
    Result := IntToStr(Round(Mb)) + ' MB'
  else
    Result := Format('%.2f GB', [Mb / 1024.0]);
end;

function ShouldWarnBeforeMigration(
  FileCount: Integer;
  Bytes: Int64;
  const AntivirusLabel: String
): Boolean;
begin
  Result :=
    (FileCount >= MigrationWarnMinFiles) or
    (Bytes >= MigrationWarnMinBytes) or
    AntivirusLooksLikeEnterpriseAgent(AntivirusLabel);
end;
