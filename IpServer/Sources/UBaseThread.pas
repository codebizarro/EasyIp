unit UBaseThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WinSock,
  eiTypes,
  eiConstants,
  UServerTypes,
  ULogger;

type
  TBaseSocketThread = class(TThread)
  private
  protected
    FLogger: ILogger;
    FSocket: TSocket;
    FWsaData: TWSAData;
    FCancel: bool;
    function GetLastErrorString: string;
    procedure Execute; override;
  public
    constructor Create(createSuspended: bool = true);
    destructor Destroy; override;
  end;

implementation

constructor TBaseSocketThread.Create(createSuspended: bool = true);
begin
  inherited Create(createSuspended);
  FreeOnTerminate := true;
end;

destructor TBaseSocketThread.Destroy;
begin

  inherited;
end;

procedure TBaseSocketThread.Execute;
begin
  inherited;

end;

function TBaseSocketThread.GetLastErrorString: string;
var
  Buffer: array[0..2047] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, WSAGetLastError, LANG_ID, @Buffer, SizeOf(Buffer), nil);
  Result := Buffer;
end;

end.

