unit UListenThread;

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
  UBaseThread,
  UResponseThread;

type
  TUdpListenThread = class(TBaseSocketThread)
  private
    FLocalAddr: TSockAddrIn;
    FReceiveEvent: TRequestEvent;
    procedure DoReceiveEvent(clientAddr: TSockAddrIn; buffer: DynamicByteArray);
  public
    constructor Create(logger: ILogger; listenPort: int);
    destructor Destroy; override;
    procedure Execute; override;
    property OnReceive: TRequestEvent read FReceiveEvent write FReceiveEvent;
  end;

implementation

constructor TUdpListenThread.Create(logger: ILogger; listenPort: int);
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

    FLogger.Log('Listen thread created');
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message);
  end;
end;

destructor TUdpListenThread.Destroy;
begin
  FLogger.Log('Listen thread destroyed');
  inherited;
end;

procedure TUdpListenThread.DoReceiveEvent(clientAddr: TSockAddrIn; buffer: DynamicByteArray);
var
  request: RequestStruct;
begin
  if Assigned(FReceiveEvent) then
  begin
    request.Target := clientAddr;
    request.Buffer := buffer;
    FReceiveEvent(Self, request);
  end;
end;

procedure TUdpListenThread.Execute;
var
  returnLength: int;
  len: int;
  FBuffer: DynamicByteArray;
  FClientAddr: TSockAddrIn;
begin
  while not Terminated do
  begin
    try
      SetLength(FBuffer, High(short));
      len := SizeOf(FClientAddr);
      returnLength := recvfrom(FSocket, Pointer(FBuffer)^, Length(FBuffer), 0, FClientAddr, len);
      if (returnLength = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      SetLength(FBuffer, returnLength);
      FLogger.Log('Inbound data length ' + IntToStr(returnLength));
      FLogger.Log('From ' + inet_ntoa(FClientAddr.sin_addr));

      DoReceiveEvent(FClientAddr, FBuffer);
    except
      on Ex: Exception do
        FLogger.Log(Ex.Message);
    end;
  end;
end;

end.

