unit ULogger;

interface

uses
  Windows,
  SysUtils,
  UServerTypes;

type
  TConsoleLogger = class(TInterfacedObject, ILogger)
    procedure Log(messageText: string);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TConsoleLogger.Create;
begin
  inherited;
end;

destructor TConsoleLogger.Destroy;
begin
  inherited;
end;

procedure TConsoleLogger.Log(messageText: string);
var
  sDateTime: string;
const
  LOG_MESSAGE = '%s %s';
  DATETIME_FORMAT = 'yyyy-mm-dd hh:nn:ss.zzz';
begin
  sDateTime := FormatDateTime(DATETIME_FORMAT, Now);
  Writeln(Format(LOG_MESSAGE, [sDateTime, messageText]));
end;

end.

