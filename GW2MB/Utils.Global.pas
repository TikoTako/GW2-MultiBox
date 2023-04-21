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

unit Utils.Global;

interface

uses
  System.SysUtils;

function GetClientFilePath: string;
procedure SetClientFilePath(aFullPathPlusExe: string);

function GetClientParams: string;
function SetClientParams(aParams: string): Boolean; // read implementation

function CanStartGUI: Boolean;
procedure SetCanStartGUI(aAllow: Boolean);

procedure CountDown(aSeconds: Integer; aMessage: string; aInitialDelayMilliSec: Integer = 1000);

implementation

var
  gClientParams: string;
  gStartGUI: Boolean = True;
  gClientExeWithPath: string;

function GetClientFilePath: string;
begin
  Result := gClientExeWithPath;
end;

procedure SetClientFilePath(aFullPathPlusExe: string);
begin
  gClientExeWithPath := aFullPathPlusExe;
end;

function GetClientParams: string;
begin
  Result := gClientParams;
end;

function SetClientParams(aParams: string): Boolean;
begin
  // Result is a dummy so i can set the string in the if in ConsoleModeUnit -> Setup()
  gClientParams := aParams;
  Result := True;
end;

function CanStartGUI: Boolean;
begin
  Result := gStartGUI;
end;

procedure SetCanStartGUI(aAllow: Boolean);
begin
  gStartGUI := aAllow;
end;

procedure CountDown(aSeconds: Integer; aMessage: string; aInitialDelayMilliSec: Integer = 1000);
var
  i: Integer;
begin
  // Wait a bit for the logger thread to do his stuff
  // This is ok because i log only from one thread
  Sleep(aInitialDelayMilliSec);
  if aMessage.IsEmpty then
    aMessage := 'Exiting in %d seconds';
  for i := aSeconds downto 1 do
  begin
    Write(#13, Format(aMessage, [i]));
    Sleep(1000);
  end;
  WriteLn('');
end;

end.

