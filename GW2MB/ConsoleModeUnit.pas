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

unit ConsoleModeUnit;

interface

uses
  WinAPI.Windows,
  System.IOUtils, System.SysUtils;

implementation

uses
  Utils.Logger, Utils.Global, Utils.Processes, Utils.Mutex;

var
  Log: TTheLogger;

procedure StartAsConsole(aHaveParams: Bool);
var
  i: Integer;
  vCanOpen: Bool;
  vClientExeName: string;
  vProcessInfo: TProcessInfo;
  vProcessesList: TArray<TProcessInfo>;
begin
  Log.Info('ConsoleMode');
  SetCanStartGUI(False);

  vCanOpen := False;

  if aHaveParams then
    Log.Debug(GetClientParams);

  vClientExeName := ExtractFileName(GetClientFilePath);
  Log.Debug(vClientExeName);

  if GetProcessesListByName(vClientExeName, vProcessesList) then
  begin
    Log.Debug('vProcessesList dump');
    for vProcessInfo in vProcessesList do
      Log.Debug('[%d] %s', [vProcessInfo.PID, vProcessInfo.Name]);

    if KillMutex(vProcessesList) then
      vCanOpen := True
    else
      Log.Error('KillMutex failed [%s]', [SysErrorMessage(GetLastError)]);
  end
  else
  begin
    vCanOpen := True;
    Log.Info('GetProcessesListByName nothing found.');
  end;

  if vCanOpen and OpenClient(GetClientParams) then
    Log.Info('OpenClient > ok')
  else
    Log.Error('OpenClient failed [%s]', [SysErrorMessage(GetLastError)]);

  CountDown(5, '');
end;

procedure SetStringAlsoPrintDebug(aString: string; aDebugString: string);
begin
  Log.Debug(aDebugString);
  SetClientFilePath(aString);
end;

procedure Setup();
var
  vClientPath: string;
  vClientParams: string;
begin
  // TODO -cMaybe -oTikoTako: add -? -h -help

  // TODO -high add -WaitFor:time for the exit instead of the hardcoded 5 sec

  // Client Path
  if FindCmdLineSwitch('UseDebugClient') then
    SetStringAlsoPrintDebug(TPath.Combine(ExtractFilePath(ParamStr(0)), 'DummyClient.exe'), 'UseDebugClient')
  else if FindCmdLineSwitch('UseClientPath', vClientPath) and (not vClientPath.IsEmpty) then
    SetStringAlsoPrintDebug(vClientPath, Format('UseClientPath [%s]', [vClientPath]))
  else
    SetStringAlsoPrintDebug('C:\Program Files\Guild Wars 2\Gw2-64.exe', 'UseDefaultPath');

  // Start as console/gui
  // Also Params if start as console
  if FindCmdLineSwitch('ConsoleMode') then
    StartAsConsole(FindCmdLineSwitch('Params', vClientParams) and (not vClientParams.IsEmpty) and SetClientParams(vClientParams))
  else
    Log.Info('GUI mode');
end;

initialization
  Log := TTheLogger.Create('Console');
  Log.Info('Initialization');
  Setup();

finalization
  Log.Info('Finalization');
  FreeAndNil(Log);

end.

