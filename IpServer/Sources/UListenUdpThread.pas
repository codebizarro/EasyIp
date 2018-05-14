unit UListenUdpThread;

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
  TListenUdpThread = class(TBaseSocketThread)
  private
    FLocalAddr: TSockAddrIn;
    FReceiveEvent: TRequestEvent;
    procedure DoReceiveEvent(clientAddr: TSockAddrIn; buffer: DynamicByteArray);
  public
    constructor Create(logger: ILogger; listenPort: int);
    destructor Destroy; override;
    procedure Cancel;
    procedure Execute; override;
    property OnReceive: TRequestEvent read FReceiveEvent write FReceiveEvent;
  end;

implementation

procedure TListenUdpThread.Cancel;
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

constructor TListenUdpThread.Create(logger: ILogger; listenPort: int);
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

    FSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if FSocket = INVALID_SOCKET then
      raise ESocketException.Create(GetLastErrorString());

    ZeroMemory(@FLocalAddr, SizeOf(FLocalAddr));
    FLocalAddr.sin_family := AF_INET;
    FLocalAddr.sin_port := htons(listenPort);
    FLocalAddr.sin_addr.s_addr := INADDR_ANY;
    code := bind(FSocket, FLocalAddr, SizeOf(FLocalAddr));
    if code < 0 then
      raise ESocketException.Create(GetLastErrorString());
    FStarted := True;
    FLogger.Log('Listen thread created on ' + IntToStr(listenPort) + ' UDP port');
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message, elError);
  end;
end;

destructor TListenUdpThread.Destroy;
begin
  if not FCancel then
    Cancel;
  FLogger.Log('Base thread destroyed.');
  FLogger.Log('Listen thread destroyed');
  inherited;
end;

procedure TListenUdpThread.DoReceiveEvent(clientAddr: TSockAddrIn; buffer: DynamicByteArray);
var
  request: RequestStruct;
begin
  if Assigned(FReceiveEvent) then
  begin
    request.Socket := FSocket;
    request.Target := clientAddr;
    request.Buffer := buffer;
    FReceiveEvent(Self, request);
  end;
end;

procedure TListenUdpThread.Execute;
var
  returnLength: int;
  len: int;
  FBuffer: DynamicByteArray;
  FClientAddr: TSockAddrIn;
begin
  while not Terminated and FStarted do
  begin
    try
      SetLength(FBuffer, High(short));
      len := SizeOf(TSockAddrIn);
      returnLength := recvfrom(FSocket, Pointer(FBuffer)^, Length(FBuffer), 0, FClientAddr, len);
      if (returnLength = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      SetLength(FBuffer, returnLength);
      FLogger.Log('Inbound data length ' + IntToStr(returnLength));
      FLogger.Log('From ' + inet_ntoa(FClientAddr.sin_addr) + ' : ' + IntToStr(FClientAddr.sin_port));

      DoReceiveEvent(FClientAddr, FBuffer);
    except
      on Ex: Exception do
        FLogger.Log(Ex.Message, elError);
    end;
  end;
end;

end.

