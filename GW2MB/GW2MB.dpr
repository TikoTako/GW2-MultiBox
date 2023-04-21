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

program GW2MB;

uses
  Vcl.Forms,
  Utils.Logger in 'Utils.Logger.pas' { First this that have the logger initializaion },
  Utils.Processes in 'Utils.Processes.pas',
  Utils.Mutex in 'Utils.Mutex.pas',
  Utils.Global in 'Utils.Global.pas',
  ConsoleModeUnit in 'ConsoleModeUnit.pas' { This before the GUI cuz that wont start if is in console mode },
  GUIModeUnit in 'GUIModeUnit.pas' { MainForm, btw the initialization and finalization run in any case };

{$R *.res}

begin
  if CanStartGUI then // Set by Setup() in ConsoleMode, true by default in (Utils.Global)
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  end;
end.

