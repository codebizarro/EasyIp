unit UEasyIpServer;

interface

uses
  Windows,
  SysUtils,
  WinSock,
  eiTypes,
  eiHelpers,
  eiExceptions,
  eiConstants,
  UServerTypes,
  ULogger,
  UPacketDispatcher;

type
  TEasyIpServer = class(TInterfacedObject, IEasyIpServer)
  private
    FLogger: ILogger;
    FPacketDispatcher: IPacketDispatcher;
    FSocket: TSocket;
    FTarget: TSockAddrIn;
    function GetLastErrorString: string;
  public
    constructor Create; overload;
    constructor Create(logger: ILogger); overload;
    destructor Destroy; override;
    procedure Run;
  end;

implementation

constructor TEasyIpServer.Create;
begin
  Create(TConsoleLogger.Create());
end;

constructor TEasyIpServer.Create(logger: ILogger);
var
  code: int;
  init: TWSAData;
begin
  inherited Create();
  FLogger := logger;
  FLogger.Log('Starting server...');
  FPacketDispatcher := TPacketDispatcher.Create(FLogger);
  code := WSAStartup(WINSOCK_VERSION, init);
  if code <> 0 then
    raise ESocketException.Create(GetLastErrorString());
  FSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if FSocket < 0 then
    raise ESocketException.Create(GetLastErrorString());
  ZeroMemory(@FTarget, SizeOf(TSockAddrIn));
  FTarget.sin_family := AF_INET;
  FTarget.sin_port := htons(EASYIP_PORT);
  FTarget.sin_addr.s_addr := INADDR_ANY;
  code := bind(FSocket, FTarget, SizeOf(FTarget));
  if code < 0 then
    raise ESocketException.Create(GetLastErrorString());
  FLogger.Log('Server is started.');
end;

destructor TEasyIpServer.Destroy;
begin
  FLogger.Log('Stopping server...');
  closesocket(FSocket);
  WSACleanup();
  FLogger.Log('Server is stopped.');
  inherited;
end;

function TEasyIpServer.GetLastErrorString: string;
var
  Buffer: array[0..2047] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, WSAGetLastError, LANG_ID, @Buffer, SizeOf(Buffer), nil);
  Result := Buffer;
end;

procedure TEasyIpServer.Run;
var
  returnLength: int;
  sendBuffer: DynamicByteArray;
  recvBuffer: DynamicByteArray;
  len: int;
begin
  while true do
  begin
    try
      SetLength(recvBuffer, High(short));
      len := SizeOf(FTarget);
      returnLength := recvfrom(FSocket, Pointer(recvBuffer)^, Length(recvBuffer), 0, FTarget, len);
      if (returnLength = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());
      SetLength(recvBuffer, returnLength);
      FLogger.Log('Inbound data length ' + IntToStr(returnLength));

      sendBuffer := FPacketDispatcher.Process(recvBuffer);

      returnLength := sendto(FSocket, Pointer(sendBuffer)^, Length(sendBuffer), 0, FTarget, len);
      if (returnLength = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());
      FLogger.Log('Outbound data length ' + IntToStr(returnLength));
    except
      on Ex: Exception do
        FLogger.Log(Ex.Message);
    end;
  end;
end;

end.

