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
  FLogger := TDebugLogger.Create();
end;

destructor TBaseSocketThread.Destroy;
var
  shutResult: int;
begin
  shutResult := shutdown(FSocket, 2);
  if shutResult = SOCKET_ERROR then
  begin
    FLogger.Log(GetLastErrorString(), 'Shutdown failed: %s');
  end;
  closesocket(FSocket);
  WSACleanup();
  FLogger.Log('Base thread destroyed.');
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
