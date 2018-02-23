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
    FStarted: bool;
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
  //Create(TDebugLogger.Create());
end;

constructor TEasyIpServer.Create(logger: ILogger);
var
  code: int;
  wsaData: TWSAData;
begin
  inherited Create();
  FLogger := logger;
  FLogger.Log('Starting server...', '%s');
  FStarted := false;
  FPacketDispatcher := TPacketDispatcher.Create(FLogger);
  try
    ZeroMemory(@wsaData, SizeOf(TWsaData));
    code := WSAStartup(WINSOCK_VERSION, wsaData);
    if code <> 0 then
      raise ESocketException.Create(GetLastErrorString());

    FSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if FSocket = INVALID_SOCKET then
      raise ESocketException.Create(GetLastErrorString());

    ZeroMemory(@FTarget, SizeOf(TSockAddrIn));
    FTarget.sin_family := AF_INET;
    FTarget.sin_port := htons(EASYIP_PORT);
    FTarget.sin_addr.s_addr := INADDR_ANY;
    
    code := bind(FSocket, FTarget, SizeOf(FTarget));
    if code < 0 then
      raise ESocketException.Create(GetLastErrorString());

    FStarted := true;
    FLogger.Log('Server is started.');
  except
    on Ex: Exception do
    begin
      FLogger.Log(Ex.Message);
      if (wsaData.wVersion <> 0) or (wsaData.wHighVersion <> 0) then
        WSACleanup();
      FLogger.Log('Server is not started.');
    end;
  end;
end;

destructor TEasyIpServer.Destroy;
var
  shutResult: int;
begin
  FLogger.Log('Stopping server...');
  shutResult := shutdown(FSocket, 2);
  if shutResult = SOCKET_ERROR then
  begin
    FLogger.Log(GetLastErrorString(), 'Shutdown failed: %s');
  end;
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
  if FStarted then
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

