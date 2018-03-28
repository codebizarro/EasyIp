unit ULogger;

interface

uses
  Windows,
  SysUtils,
  UServerTypes;

type
  TBaseLogger = class(TInterfacedObject, ILogger)
    function LogPrefix(): string;
    procedure Log(messageText: string; level: TErrorLevel); overload; virtual; abstract;
    procedure Log(messageText: string; formatString: string); overload; virtual; abstract;
    procedure Log(formatString: string; const args: array of const); overload; virtual; abstract;
  end;

  TConsoleLogger = class(TBaseLogger)
  private
    FOemConvert: bool;
    FCritical: TRTLCriticalSection;
    function StringToOem(const value: string): AnsiString;
  public
    constructor Create(oemConvert: bool = true);
    destructor Destroy; override;
    procedure Log(messageText: string; level: TErrorLevel = elInformation); overload; override;
    procedure Log(messageText: string; formatString: string); overload; override;
    procedure Log(formatString: string; const args: array of const); overload; override;
  end;

  TDebugLogger = class(TBaseLogger)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Log(messageText: string; level: TErrorLevel = elInformation); overload; override;
    procedure Log(messageText: string; formatString: string); overload; override;
  end;

  TFileLogger = class(TBaseLogger)
  private
    FFileName: string;
  public
    constructor Create(fileName: string);
    destructor Destroy; override;
  end;

  TStubLogger = class(TBaseLogger)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Log(messageText: string; level: TErrorLevel = elInformation); overload; override;
    procedure Log(messageText: string; formatString: string); overload; override;
  end;

implementation

const
  DATETIME_FORMAT = 'yyyy-mm-dd hh:nn:ss.zzz';
  LOG_MESSAGE = '%s %s';

constructor TConsoleLogger.Create(oemConvert: bool = true);
begin
  inherited Create();
  FOemConvert := oemConvert;
  InitializeCriticalSection(FCritical);
end;

destructor TConsoleLogger.Destroy;
begin
  Log('Console log destroyed');
  DeleteCriticalSection(FCritical);
  inherited;
end;

procedure TConsoleLogger.Log(messageText: string; level: TErrorLevel = elInformation);
var
  sDateTime: string;
  sOut: string;
  color: byte;
  hConsole: THandle;
const
  hlNotice = 240;
  hlWarning = 14;
  hlError = 12;
  hlInfo = 15;
begin
  sDateTime := FormatDateTime(DATETIME_FORMAT, Now);
  sOut := Format(LOG_MESSAGE, [sDateTime, messageText]);
  if FOemConvert then
    sOut := StringToOem(sOut);
  case level of
    elInformation:
      color := hlInfo;
    elNotice:
      color := hlNotice;
    elWarning:
      color := hlWarning;
    elError:
      color := hlError;
  end;
  try
    EnterCriticalSection(FCritical);
    hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
    SetConsoleTextAttribute(hConsole, color);
    Writeln(sOut);
    SetConsoleTextAttribute(hConsole, hlInfo);
  finally
    LeaveCriticalSection(FCritical);
  end;
end;

procedure TConsoleLogger.Log(messageText, formatString: string);
begin
  Self.Log(Format(formatString, [messageText]));
end;

procedure TConsoleLogger.Log(formatString: string; const args: array of const);
begin
  Self.Log(Format(formatString, args));
end;

function TConsoleLogger.StringToOem(const value: string): AnsiString;
begin
  SetLength(Result, Length(value));
  if value <> '' then
    CharToOem(PChar(value), PAnsiChar(Result));
end;

constructor TDebugLogger.Create;
begin
  inherited;
end;

destructor TDebugLogger.Destroy;
begin
  inherited;
end;

procedure TDebugLogger.Log(messageText: string; level: TErrorLevel = elInformation);
begin
  OutputDebugString(PChar(messageText));
end;

procedure TDebugLogger.Log(messageText, formatString: string);
begin
  Self.Log(Format(formatString, [messageText]));
end;

constructor TFileLogger.Create(fileName: string);
begin
  inherited Create();
  FFileName := fileName;
end;

destructor TFileLogger.Destroy;
begin
  inherited;
end;

constructor TStubLogger.Create;
begin

end;

destructor TStubLogger.Destroy;
begin
  inherited;
end;

procedure TStubLogger.Log(messageText: string; level: TErrorLevel = elInformation);
begin
  Exit;
end;

procedure TStubLogger.Log(messageText, formatString: string);
begin
  Exit;
end;

function TBaseLogger.LogPrefix: string;
begin
  Result := FormatDateTime(DATETIME_FORMAT, Now);
end;

end.

