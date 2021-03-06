{*******************************************************************************
*  Vladimir Georgiev, 2014                                                     *
*                                                                              *
*  Types used by the "Memory Loader" units                                    *
*                                                                              *
*******************************************************************************}

{$I MlDefines.inc}

unit mlTypes;

interface

uses
  SysUtils, Windows, Classes;

type
  /// A helper type for the handles used by the emulated functions
  /// Currently equal to the original HMODULE, but can be changed to another type to avoid
  /// mixing it with handles returned by the original APIs
  TLibHandle = type HMODULE;

  /// Exception classes raised by the "ML" library
  EMlError            = class(Exception);
  EMlLibraryLoadError = class(EMlError);

  /// A Callback function that is called when a library being loaded needs to load a dependent library
  /// The value set in aLoadAction defines how the dependent library should be loaded
  ///   laDiscard - don't load the library
  ///   laHardDrive - load the library with the standard LoadLibrary Windows API
  ///   laStream - load the library from the stream passed in aStream (which has to be freed later)
  ///   laLoaded - the library is loaded by the callback and the handle returned to the caller
  TLoadAction = (laHardDisk, laStream, laDiscard, laLoaded);
  TMlLoadDependentLibraryEvent = procedure(const aLibName, aDependentLib: String; var aLoadAction: TLoadAction; var
      aStream: TStream; var aFreeStream: Boolean; var aLoadedHandle: TLibHandle) of object;

{$IFDEF VER130}
  EOSError             = class(Exception);
  TValidatePackageProc = function (Module: HMODULE): Boolean;
{$ENDIF VER130}

type
  TLoadLibraryFunc       = function (lpLibFileName: PChar)                                : HMODULE; stdcall;
  TLoadLibraryExFunc     = function (lpLibFileName: PChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
  TFreeLibraryFunc       = function (hModule: HMODULE)                                    : BOOL; stdcall;
  TGetProcAddressFunc    = function (hModule: HMODULE; lpProcName: LPCSTR)                : FARPROC; stdcall;
  TFindResourceFunc      = function (hModule: HMODULE; lpName, lpType: PChar)             : HRSRC; stdcall;
  TLoadResourceFunc      = function (hModule: HMODULE; hResInfo: HRSRC)                   : HGLOBAL; stdcall;
  TSizeofResourceFunc    = function (hModule: HMODULE; hResInfo: HRSRC)                   : DWORD; stdcall;
  TGetModuleFileNameFunc = function (hModule: HINST; lpFilename: PChar; nSize: DWORD)     : DWORD; stdcall;
  TGetModuleHandleFunc   = function (lpModuleName: PChar)                                 : HMODULE; stdcall;
  TLoadPackageFunc       = function (const Name: string; AValidatePackage: TValidatePackageProc = nil): HMODULE;
  TUnloadPackageProc     = procedure (Module: HMODULE);

procedure ReportError(aExceptionClass: ExceptClass; const aMsg: String; aLastError: Cardinal);

implementation

/// Helper procedure for raising exceptions
procedure ReportError(aExceptionClass: ExceptClass; const aMsg: String; aLastError: Cardinal);
begin
{$IFDEF ML_ERROR_RAISE}
  {$IFDEF ML_TRAP_EXCEPTION}
     try
  {$ENDIF ML_TRAP_EXCEPTION}
       raise aExceptionClass.Create(aMsg);
  {$IFDEF ML_TRAP_EXCEPTION}
     except
     end;
   {$ENDIF ML_TRAP_EXCEPTION}
{$ELSE}
  SetLastError(aLastError);
{$ENDIF ML_ERROR_RAISE}
end;

end.

