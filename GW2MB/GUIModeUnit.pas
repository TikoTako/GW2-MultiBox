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

unit GUIModeUnit;

interface

uses
  Utils.Logger,
  WinAPI.Windows, WinAPI.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    fClientExeName: string;
  public
    { Public declarations }
  strict private
    Log: TTheLogger;
  end;

var
  MainForm: TMainForm;

implementation

{
uses
  Utils.Logger;
}

{$R *.dfm}

{
var
  Log: TTheLogger;
}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Position := poDesktopCenter;
  Log := TTheLogger.Create('GUI');
  Log.Info('FormCreate');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Log.Info('FormDestroy');
  FreeAndNil(Log);
end;

{
initialization
  Log := TTheLogger.Create('GUI');
  Log.Info('Initialization');

finalization
  Log.Info('Finalization');
  FreeAndNil(Log);
}

end.

