{ ******************************************************************** }
{                                                                      }
{                            GW2-MultiBox                              }
{    Program that allow to open multiple instances of "Guild Wars 2"   }
{               https://github.com/TikoTako/GW2-MultiBox               }
{                     Copyright (c) 2003 TikoTako                      }
{                                                                      }
{ This program is free software: you can redistribute it and/or modify }
{ it under the terms of the GNU General Public License as published by }
{ the Free Software Foundation, either version 3 of the License, or    }
{ (at your option) any later version.                                  }
{                                                                      }
{ This program is distributed in the hope that it will be useful,      }
{ but WITHOUT ANY WARRANTY; without even the implied warranty of       }
{ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                 }
{ See the GNU General Public License for more details.                 }
{                                                                      }
{ You should have received a copy of the GNU General Public License    }
{ along with this program.                                             }
{ If not, see <https://www.gnu.org/licenses/>.                         }
{                                                                      }
{ "Guild Wars 2" (c) 2023 ArenaNet, LLC. All rights reserved.          }
{ All trademarks are the property of their respective owners.          }
{                                                                      }
{ ******************************************************************** }

unit Utils.Processes;

interface

uses
  WinAPI.Windows, WinAPI.PsAPI, WinAPI.ShellAPI,
  System.SysUtils;

type
  TProcessInfo = record
    PID: UInt32;
    Name: string;
  end;

function GetProcessNameByPID(aPID: UInt32; out oModuleName: string): Bool;

function GetProcessesListByName(aProcessName: string; out oProcessInfoArray: TArray<TProcessInfo>): Bool;

function OpenClient(aCommandLines: string): Bool;

implementation

uses
  Utils.Logger, Utils.Global;

var
  Log: TTheLogger;

function GetProcessNameByPID(aPID: UInt32; out oModuleName: string): Bool;
var
  cbNeeded: DWord;
  vProcessName: PChar;
  vModuleHandle: HMODULE;
  vProcessHandle: THandle;
begin
  Result := False;
  vProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, aPID);
  if vProcessHandle <> 0 then
    try
      if EnumProcessModules(vProcessHandle, @vModuleHandle, SizeOf(vModuleHandle), cbNeeded) then
        // this work only for the current process, maybe if clone the handle work too ?
        // oModuleName := System.SysUtils.GetModuleName(vModuleHandle);
      begin
        GetMem(vProcessName, 256);
        try
          GetModuleBaseName(vProcessHandle, vModuleHandle, vProcessName, (256 * SizeOf(char)) - 1);
          oModuleName := string(vProcessName).Trim;
          Log.Debug('oModuleName "%s" len [%d]', [oModuleName, oModuleName.Length]);
          Result := True;
        finally
          FreeMem(vProcessName);
        end;
      end
      else
        Log.Error('EnumProcessModules FAIL');
    finally
      CloseHandle(vProcessHandle);
    end
  else
    Log.Error('OpenProcess FAIL');
end;

function InternalEnumProcesses(lPidProcess: LPDWORD; var lPidProcessSize: DWord; var cbNeeded: DWord; out oResult: Bool): Bool;
begin
  oResult := EnumProcesses(lPidProcess, lPidProcessSize, cbNeeded);
  Result := oResult;
end;

function GetProcessesListByName(aProcessName: string; out oProcessInfoArray: TArray<TProcessInfo>): Bool;
var
  i: Integer; { inline var break the refactor in 10.4 Community but also in 11.3 Enterprise, lol. }
  vGotProcessesList: Bool;
  vTmpProcessName: string;
  vProcessListSize: UInt32;
  vProcessListCount: UInt32;
  vProcessList: array of DWord;
  vValidProcessesCount: Integer;
  vProcessListActualSize: UInt32;
begin
  Result := False;
  vProcessListCount := 1000;
  vGotProcessesList := False;
  vProcessListSize := vProcessListCount * SizeOf(DWord);
  SetLength(vProcessList, vProcessListSize);
  while InternalEnumProcesses(@vProcessList[0], vProcessListSize, vProcessListActualSize, vGotProcessesList) and (vProcessListSize = vProcessListActualSize) do
  begin
    { Yeah with a big enough vProcessListSize this loop never start, i have like 140 processes open rn }
    Inc(vProcessListCount, 100);
    vProcessListSize := vProcessListCount * SizeOf(DWord);
    SetLength(vProcessList, vProcessListSize);
  end;

  if vGotProcessesList then
  begin
    vValidProcessesCount := 0;
    vProcessListCount := vProcessListActualSize div SizeOf(DWord);
    SetLength(oProcessInfoArray, vProcessListCount);
    for i := 0 to vProcessListCount - 1 do
      // CanGetName and (WholeListIfNameEmpty or OnlyTheName)
      if GetProcessNameByPID(vProcessList[i], vTmpProcessName) and (aProcessName.IsEmpty or aProcessName.Equals(vTmpProcessName)) then
      begin
        { Ackchyually.meme can just use a TArray<UIn32> but whatever i already got the name }
        oProcessInfoArray[vValidProcessesCount].PID := vProcessList[i];
        oProcessInfoArray[vValidProcessesCount].Name := vTmpProcessName;
        Inc(vValidProcessesCount, 1);
      end;
    // Resize the out array with the correct len
    SetLength(oProcessInfoArray, vValidProcessesCount);
    Result := vValidProcessesCount > 0;
  end
  else
    Log.Error('EnumProcesses FAIL');
  // Result := vGotProcessesList and (vValidProcessesCount > 0); not sure if is ok only this here or better the false at start and the other one to set true
end;

function OpenClient(aCommandLines: string): Bool;
begin
  // TODO -high -cImplementMeDaddy -oTikoTako: For the auto-login change to createprocess then wait for the window
  Log.Debug('OpenClient [%s] [%s]', [GetClientFilePath, aCommandLines]);
  Result := ShellExecute(0, 'open', PChar(GetClientFilePath), PChar(aCommandLines), '', SW_SHOWNORMAL) > 32;
end;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

initialization
  Log := TTheLogger.Create('Utils.Processes');
  Log.Info('Initialization');

finalization
  Log.Info('Finalization');
  FreeAndNil(Log);

end.

