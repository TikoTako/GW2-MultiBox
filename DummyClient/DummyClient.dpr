{ ******************************************************************** }
{                                                                      }
{                             DummyClient                              }
{  Program that just create a mutex simulating the "Guild Wars 2" one. }
{               https://github.com/TikoTako/GW2-MultiBox               }
{                     Copyright (c) 2003 TikoTako                      }
{                                                                      }
{ The MIT License (MIT)                                                }
{                                                                      }
{ Permission is hereby granted, free of charge, to any person          }
{ obtaining a copy of this software and associated documentation files }
{ (the “Software”), to deal in the Software without restriction,       }
{ including without limitation the rights to use, copy, modify, merge, }
{ publish, distribute, sublicense, and/or sell copies of the Software, }
{ and to permit persons to whom the Software is furnished to do so,    }
{ subject to the following conditions:                                 }
{                                                                      }
{ The above copyright notice and this permission notice shall be       }
{ included in all copies or substantial portions of the Software.      }
{                                                                      }
{ THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,      }
{ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   }
{ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                }
{ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS  }
{ BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN   }
{ ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN    }
{ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     }
{ SOFTWARE.                                                            }
{                                                                      }
{ "Guild Wars 2" (c) 2023 ArenaNet, LLC. All rights reserved.          }
{ All trademarks are the property of their respective owners.          }
{                                                                      }
{ ******************************************************************** }

program DummyClient;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinAPI.Windows,
  System.SysUtils;

const
  cMessage = '"["DD/MM/YYYY" "HH:NN:SS"] The mutex is ';
  GOTOLINESTART = #13;
  BLANKLINE = '                                                   '; // this should be long as the longest cMessage

procedure WaitExit(aSeconds: Integer);
var
  i: Integer;
begin
  for i := aSeconds downto 1 do
  begin
    Write(GOTOLINESTART, Format('Exiting in %d seconds', [i]));
    Sleep(1000);
  end;
end;

var
  gMutexHandle: THandle;
begin
  try
    gMutexHandle := CreateMutex(nil, True, 'AN-Mutex-Window-Guild Wars 2');
    if gMutexHandle = 0 then
      raise Exception.Create(SysErrorMessage(GetLastError))
    else if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      // CreateMutex open the existing mutex with a new handle if it exists so it appear in the system handles list too unless is closed
      CloseHandle(gMutexHandle);
      raise Exception.Create('ERROR_ALREADY_EXISTS')
    end
    else
    begin
      WriteLn('CreateMutex created a new mutex.');
      WriteLn('ParamCount > ', System.ParamCount);
      if System.ParamCount > 0 then
      begin
        // System.ParamStr(0) -> c:\blablabla\program.exe
        WriteLn(ExtractFileName(System.ParamStr(0)));
        // System.CmdLine -> "c:\blablabla\program.exe" -param1 -param2 potato
        WriteLn(string(System.CmdLine).Substring(System.ParamStr(0).Length + 3));
      end;
      while WaitForSingleObject(gMutexHandle, INFINITE) = WAIT_OBJECT_0 do
      begin
        Write(GOTOLINESTART, FormatDateTime(cMessage + 'still alive."', Now()));
        Sleep(1000);
      end;
      WriteLn(GOTOLINESTART, BLANKLINE, GOTOLINESTART, FormatDateTime(cMessage + 'kill."', Now()));
    end;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WaitExit(5);
end.

