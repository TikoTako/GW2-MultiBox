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

unit Utils.Mutex;

interface

uses
  WinAPI.Windows,
  System.SysUtils,
  Utils.Processes;

function KillMutex(aPidArray: TArray<TProcessInfo>): Bool;

implementation

uses
  Utils.Logger;

type
  // https://github.com/mingw-w64/mingw-w64/blob/master/mingw-w64-headers/include/winternl.h
  PSystemHandleEntry = ^TSystemHandleEntry;

  TSystemHandleEntry = record
    OwnerPid: ULong;
    ObjectType: BYTE;
    HandleFlags: BYTE;
    HandleValue: USHORT;
    ObjectPointer: PVoid;
    AccessMask: ULong;
  end;

  PSystemHandleInformation = ^TSystemHandleInformation;
  TSystemHandleInformation = record
    Count: ULong;
    Handles: PSystemHandleEntry;
  end;

  PUnicodeString = ^TUnicodeString;

  // https://learn.microsoft.com/en-us/windows/win32/api/subauth/ns-subauth-unicode_string
  TUnicodeString = record // if packed -> align fuckup in memory
    Length: UInt16;
    MaximumLength: UInt16;
    Buffer: PWideChar;
  end;

var
  Log: TTheLogger;

const
  // https://www.pinvoke.net/default.aspx/Enums.OBJECT_INFORMATION_CLASS
  ObjectNameInformation = 1;
  // http://iforgot.derp
  SystemHandleInformation = 16;
  // https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/596a1078-e883-4972-9bbc-49e60bebca55
  // NTSTATUS is long here (delphi) and is variable not const can be 32 or 64 ?
  // but it say that is 32bit on the page, also in the c header file
  STATUS_SUCCESS: UInt32 = $00000000;
  STATUS_BUFFER_OVERFLOW: UInt32 = $80000005;
  STATUS_BUFFER_TOO_SMALL: UInt32 = $C0000023;
  STATUS_FLT_BUFFER_TOO_SMALL: UInt32 = $801C0001;
  STATUS_INFO_LENGTH_MISMATCH: UInt32 = $C0000004;
  // got it by checking with sysinternal process explorer
  TYPE_MUTANT = $11;

  { Imports }

function NtQuerySystemInformation(SystemInformationClass: ULong; SystemInformation: PVoid; SystemInformationLength: ULong; ReturnLength: PULong): NTSTATUS; stdcall; external 'ntdll.dll';

function NtQueryObject(ObjectHandle: THandle; ObjectInformationClass: ULong; ObjectInformation: PVoid; ObjectInformationLength: ULong; ReturnLength: PULong): NTSTATUS; stdcall; external 'ntdll.dll';

{ Implementation }

function GetSystemHandles(out oSystemHandleInformation: PSystemHandleInformation): Bool;
var
  vQueryResult: UInt32;
  vBufferSize: Cardinal;
  vActualBufferSize: ULong;
begin
  // maybe is better sizeof(TSystemHandleInformation) + (sizeof(TSystemHandleEntry) * 100000orsomething) but whatever
  // i have ~62k handle rn so ~2 mb
  vBufferSize := 1024 * 1024 * 5; // just use 5 mb as start
  GetMem(oSystemHandleInformation, vBufferSize);
  while True do
  begin
    vQueryResult := NtQuerySystemInformation(SystemHandleInformation, oSystemHandleInformation, vBufferSize, @vActualBufferSize);
    Log.Debug('GetSystemHandles > vBufferSize [%d] vActualBufferSize [%d] vQueryResult [%d] (0x%x)', [vBufferSize, vActualBufferSize, vQueryResult, vQueryResult]);
    if (vQueryResult = STATUS_BUFFER_OVERFLOW) or //
      (vQueryResult = STATUS_BUFFER_TOO_SMALL) or //
      (vQueryResult = STATUS_FLT_BUFFER_TOO_SMALL) or //
      (vQueryResult = STATUS_INFO_LENGTH_MISMATCH) then
    begin
      vBufferSize := vActualBufferSize + 1024; // Justin Case 1 kb more
      ReallocMem(oSystemHandleInformation, vActualBufferSize);
    end
    else
      Exit(vQueryResult = STATUS_SUCCESS); // Yeah no realloc to trim also no free here
  end;
end;

function KillMutex(aPidArray: TArray<TProcessInfo>): Bool;
var
  i: Integer;
  vActualSize: Integer;
  vDupedHandle: THandle;
  vProcessHandle: THandle;
  vHandleName: PUnicodeString;
  vSystemHandleEntryMax: Pointer;
  vHandleNameQueryResult: UInt32;
  vSystemHandleEntry: PSystemHandleEntry;
  vSystemHandleInformation: PSystemHandleInformation;
begin
  Result := False;
  try
    if GetSystemHandles(vSystemHandleInformation) then
    begin
      Log.Debug('KillMutex');
      Log.Debug('GetSystemHandles OK');
      Log.Debug('vSystemHandleInformation.Count %d ', [vSystemHandleInformation.Count]);
      Log.Debug('sizeof(entry) * count = %d', [SizeOf(TSystemHandleEntry) * vSystemHandleInformation.Count]);
      Log.Debug('vSystemHandleInformation [%p] - @Count [%p] - @Handles [%p]',
        [vSystemHandleInformation, @vSystemHandleInformation.Count, @vSystemHandleInformation.Handles]);
      vSystemHandleEntry := @vSystemHandleInformation.Handles;
      vSystemHandleEntryMax := Pointer(NativeUint(vSystemHandleEntry) + SizeOf(TSystemHandleEntry) * vSystemHandleInformation.Count);
      repeat
        for i := Low(aPidArray) to High(aPidArray) do
          if (vSystemHandleEntry.OwnerPid = aPidArray[i].PID) and (vSystemHandleEntry.ObjectType = TYPE_MUTANT) then
          begin
            // check name
            with vSystemHandleEntry^ do
              Log.Debug('[%d] MUTANT HandleValue [%x] ObjectPointer [%p]', [OwnerPid, HandleValue, ObjectPointer]);

            vProcessHandle := OpenProcess(PROCESS_DUP_HANDLE, False, vSystemHandleEntry.OwnerPid);
            try
              if vProcessHandle > 0 then
              begin
                if DuplicateHandle(vProcessHandle, vSystemHandleEntry.HandleValue, GetCurrentProcess(), @vDupedHandle, 0, True, DUPLICATE_SAME_ACCESS) then
                begin
                  GetMem(vHandleName, 9001);
                  try
                    vHandleNameQueryResult := NtQueryObject(vDupedHandle, ObjectNameInformation, vHandleName, 9001, @vActualSize);
                    if vHandleNameQueryResult = STATUS_SUCCESS then
                    begin
                      CloseHandle(vDupedHandle);
                      // so at this point i have only the client mutex and it should be with a name
                      Log.Debug('vHandleName > QueryResult [%x] ActualSize %d - len %d - max len %d -  %d - %p', //
                        [vHandleNameQueryResult, vActualSize, vHandleName.Length, vHandleName.MaximumLength, Length(string(WideString(vHandleName.Buffer))), @(vHandleName.Buffer)]);

                      // \Sessions\1\BaseNamedObjects\AN-Mutex-Window-Guild Wars 2
                      if ('\Sessions\1\BaseNamedObjects\AN-Mutex-Window-Guild Wars 2').Equals(WideString(vHandleName.Buffer)) then
                      begin
                        Log.Info('GW2 mutant found > %s', [WideString(vHandleName.Buffer)]);
                        if DuplicateHandle(vProcessHandle, vSystemHandleEntry.HandleValue, GetCurrentProcess(), @vDupedHandle, 0, True, DUPLICATE_CLOSE_SOURCE) and CloseHandle(vDupedHandle) then
                        begin
                          Log.Info('Mutant killed with fire!!11ones');
                          Result := True;
                        end
                        else
                          Log.Error('DuplicateHandle [DUPLICATE_CLOSE_SOURCE] FAIL');
                      end
                      else
                        Log.Debug('Some other mutex > %s', [WideString(vHandleName.Buffer)]);
                    end
                    else
                      Log.Error('NtQueryObject for Handle name failed [%x]', [vHandleNameQueryResult]);
                  finally
                    CloseHandle(vDupedHandle);
                    FreeMem(vHandleName);
                  end;
                end
                else
                  Log.Error('DuplicateHandle [DUPLICATE_SAME_ACCESS] FAIL');
              end
              else
                Log.Error('OpenProcess FAIL');

            finally
              CloseHandle(vProcessHandle);
            end;
          end;
        Inc(vSystemHandleEntry);
      until (vSystemHandleEntry = vSystemHandleEntryMax) or (Result = True); // if find one gtfo cuz there can be only one duh
    end
    else
      Log.Error('GetSystemHandles FAIL');
  finally
    FreeMem(vSystemHandleInformation);
  end;
end;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

initialization
  Log := TTheLogger.Create('Utils.Mutex');
  Log.Info('Initialization');

finalization
  Log.Info('Finalization');
  FreeAndNil(Log);

end.

