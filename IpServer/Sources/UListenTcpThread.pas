unit UListenTcpThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WinSock,
  eiTypes,
  eiExceptions,
  eiConstants,
  UServerTypes,
  UBaseThread;

type
  TListenTcpThread = class(TBaseSocketThread)
  private
    FLocalAddr: TSockAddrIn;
    FReceiveEvent: TRequestEvent;
    procedure DoReceiveEvent(clientAddr: TSockAddrIn; clientSocket: TSocket);
  public
    constructor Create(logger: ILogger; listenPort: int);
    destructor Destroy; override;
    procedure Cancel;
    procedure Execute; override;
    property OnReceive: TRequestEvent read FReceiveEvent write FReceiveEvent;
  end;

implementation

procedure TListenTcpThread.Cancel;
var
  shutResult: int;
begin
  FCancel := true;
  Terminate;
  shutResult := shutdown(FSocket, 2);
  if shutResult = SOCKET_ERROR then
  begin
    FLogger.Log(GetLastErrorString(), 'Shutdown failed: %s');
  end;
  closesocket(FSocket);
  WSACleanup();
end;

constructor TListenTcpThread.Create(logger: ILogger; listenPort: int);
var
  code: int;
begin
  inherited Create(true);
  FLogger := logger;
  try
    ZeroMemory(@FWsaData, SizeOf(TWsaData));
    code := WSAStartup(WINSOCK_VERSION, FWsaData);
    if code <> 0 then
      raise ESocketException.Create(GetLastErrorString());

    FSocket := Socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if FSocket = INVALID_SOCKET then
      raise ESocketException.Create(GetLastErrorString());

    ZeroMemory(@FLocalAddr, SizeOf(FLocalAddr));
    FLocalAddr.sin_family := AF_INET;
    FLocalAddr.sin_port := htons(listenPort);
    FLocalAddr.sin_addr.s_addr := INADDR_ANY;
    code := bind(FSocket, FLocalAddr, SizeOf(FLocalAddr));
    if code < 0 then
      raise ESocketException.Create(GetLastErrorString());
    code := listen(FSocket, 4);
    if code = SOCKET_ERROR then
      raise ESocketException.Create(GetLastErrorString());

    FLogger.Log('Listen thread created on ' + IntToStr(listenPort) + ' TCP port');
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message, elError);
  end;
end;

destructor TListenTcpThread.Destroy;
begin
  if not FCancel then
    Cancel;
  FLogger.Log('Base thread destroyed.');
  FLogger.Log('Listen thread destroyed');
  inherited;
end;

procedure TListenTcpThread.DoReceiveEvent(clientAddr: TSockAddrIn; clientSocket: TSocket);
var
  request: RequestStruct;
begin
  if Assigned(FReceiveEvent) then
  begin
    request.Socket := clientSocket;
    request.Target := clientAddr;
    SetLength(request.Buffer, 0);
    FReceiveEvent(Self, request);
  end;
end;

procedure TListenTcpThread.Execute;
var
  returnLength: int;
  len: int;
  FClientAddr: TSockAddrIn;
  clientSocket: TSocket;
begin
  while not Terminated do
  begin
    try
      clientSocket := INVALID_SOCKET;
      len := SizeOf(TSockAddrIn);
      clientSocket := accept(FSocket, @FClientAddr, @len);
      if clientSocket = INVALID_SOCKET then
        raise ESocketException.Create(GetLastErrorString());
      FLogger.Log('Request from ' + inet_ntoa(FClientAddr.sin_addr) + ' : ' + IntToStr(FClientAddr.sin_port));

      DoReceiveEvent(FClientAddr, clientSocket);
    except
      on Ex: Exception do
        FLogger.Log(Ex.Message, elError);
    end;
  end;
end;

end.

