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

unit Utils.Logger;

interface

uses
  System.Classes, System.SysUtils;

type
  TTheLogger = class
  private
    fCaller: string;
  public
    constructor Create(aCaller: string); reintroduce;
    destructor Destroy(); override;
    procedure Info(aMessage: string); overload;
    procedure Info(const aMessage: string; const aParameters: array of const); overload;
    procedure Error(aMessage: string); overload;
    procedure Error(const aMessage: string; const aParameters: array of const); overload;
    procedure Debug(aMessage: string); overload;
    procedure Debug(const aMessage: string; const aParameters: array of const); overload;
    procedure Warning(aMessage: string); overload;
    procedure Warning(const aMessage: string; const aParameters: array of const); overload;
  end;

implementation

uses
  LoggerPro,
  LoggerPro.FileAppender,
  LoggerPro.ConsoleAppender;

var
  lgRawLogger: ILogWriter; // lg > "local" global

constructor TTheLogger.Create(aCaller: string);
begin
  inherited Create();
  fCaller := aCaller;
end;

destructor TTheLogger.Destroy();
begin
  inherited;
end;

procedure TTheLogger.Info(aMessage: string);
begin
  lgRawLogger.Info(aMessage, fCaller);
end;

procedure TTheLogger.Info(const aMessage: string; const aParameters: array of const);
begin
  lgRawLogger.Info(aMessage, aParameters, fCaller);
end;

procedure TTheLogger.Error(aMessage: string);
begin
  lgRawLogger.Error(aMessage, fCaller);
end;

procedure TTheLogger.Error(const aMessage: string; const aParameters: array of const);
begin
  lgRawLogger.Error(aMessage, aParameters, fCaller);
end;

procedure TTheLogger.Debug(aMessage: string);
begin
  lgRawLogger.Debug(aMessage, fCaller);
end;

procedure TTheLogger.Debug(const aMessage: string; const aParameters: array of const);
begin
  lgRawLogger.Debug(aMessage, aParameters, fCaller);
end;

procedure TTheLogger.Warning(aMessage: string);
begin
  lgRawLogger.Warn(aMessage, fCaller);
end;

procedure TTheLogger.Warning(const aMessage: string; const aParameters: array of const);
begin
  lgRawLogger.Warn(aMessage, aParameters, fCaller);
end;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

procedure SetupLogger;
begin
  // TODO -high -cAdd -oTikoTako: add -DumpDebugStrings and set the create to not log the debug strings if that isnt set

  lgRawLogger := BuildLogWriter([
      TLoggerProFileAppender.Create(
        5,
        1024 * 100, // 100 mb log :^D
        'Logs', [],
        Format('%s [%s].log', ['%0:s', FormatDateTime('DD-MM-YYYY HH_NN_SS', Now)]),
        '%0:s[%2:s] [%4:s] %3:s', nil
        )]);
  { For some reason time to time FindCmdLineSwitch bug and return false instead of true }
  if string(CmdLine).Contains('-ShowDebugWindow') then
    lgRawLogger.AddAppender(TLoggerProConsoleAppender.Create('%0:s[%2:s] [%4:s] %3:s'));
  lgRawLogger.Info('SetupLogger done.', 'Utils.Logger');
end;

initialization
  ReportMemoryLeaksOnShutdown := True;
  SetupLogger;

finalization
  lgRawLogger.Info('Finalization', 'Utils.Logger');
  Sleep(1000); // Poor hackerman fix
  // The logger run in another thread so when the program is at this point it exit too fast
  // and the logger thread is killed before it can write to the log file.

end.

