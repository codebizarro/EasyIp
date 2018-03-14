unit ULogger;

interface

uses
  Windows,
  SysUtils,
  UServerTypes;

type
  TConsoleLogger = class(TInterfacedObject, ILogger)
  private
    FOemConvert: bool;
    FCritical: TRTLCriticalSection;
    function StringToOem(const value: string): AnsiString;
  public
    constructor Create(oemConvert: bool = true);
    destructor Destroy; override;
    procedure Log(messageText: string); overload;
    procedure Log(messageText: string; formatString: string); overload;
  end;

  TDebugLogger = class(TInterfacedObject, ILogger)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Log(messageText: string); overload;
    procedure Log(messageText: string; formatString: string); overload;
  end;

  TFileLogger = class(TInterfacedObject, ILogger)
  private
    FFileName: string;
  public
    constructor Create(fileName: string);
    destructor Destroy; override;
    procedure Log(messageText: string); overload; virtual; abstract; //TODO: need to implement
    procedure Log(messageText: string; formatString: string); overload; virtual; abstract; //TODO: need to implement
  end;

  TStubLogger = class(TInterfacedObject, ILogger)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Log(messageText: string); overload;
    procedure Log(messageText: string; formatString: string); overload;
  end;

implementation

constructor TConsoleLogger.Create(oemConvert: bool = true);
begin
  inherited Create();
  FOemConvert := oemConvert;
  InitializeCriticalSection(FCritical);
end;

destructor TConsoleLogger.Destroy;
begin
  DeleteCriticalSection(FCritical);
  inherited;
end;

procedure TConsoleLogger.Log(messageText: string);
var
  sDateTime: string;
  sOut: string;
const
  LOG_MESSAGE = '%s %s';
  DATETIME_FORMAT = 'yyyy-mm-dd hh:nn:ss.zzz';
begin
  sDateTime := FormatDateTime(DATETIME_FORMAT, Now);
  sOut := Format(LOG_MESSAGE, [sDateTime, messageText]);
  if FOemConvert then
    sOut := StringToOem(sOut);
  try
    EnterCriticalSection(FCritical);
    Writeln(sOut);
  finally
    LeaveCriticalSection(FCritical);
  end;
end;

procedure TConsoleLogger.Log(messageText, formatString: string);
begin
  Self.Log(Format(formatString, [messageText]));
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

procedure TDebugLogger.Log(messageText: string);
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

procedure TStubLogger.Log(messageText: string);
begin
  Exit;
end;

procedure TStubLogger.Log(messageText, formatString: string);
begin
  Exit;
end;

end.

