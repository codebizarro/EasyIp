unit UDiscoverResponseThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WinSock,
  eiTypes,
  eiHelpers,
  eiExceptions,
  eiConstants,
  UServerTypes,
  ULogger,
  UPacketHandlers,
  UBaseThread;

type
  TDiscoverResponseThread = class(TBaseSocketThread)
  private
    FSendSocket: TSocket;
    FClientAddr: TSockAddrIn;
    FLocalAddr: TSockAddrIn;
  protected
    procedure Execute; override;
  public
    constructor Create(logger: ILogger);
  end;

implementation

constructor TDiscoverResponseThread.Create(logger: ILogger);
var
  code: int;
  wsaData: TWSAData;
  b: bool;
begin
  inherited Create(true);
  FLogger := logger;
  try
    ZeroMemory(@wsaData, SizeOf(TWsaData));
    code := WSAStartup(WINSOCK_VERSION, wsaData);

    FSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    FSendSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

    ZeroMemory(@FLocalAddr, SizeOf(FLocalAddr));
    FLocalAddr.sin_family := AF_INET;
    FLocalAddr.sin_port := htons(990);
//  FLocalAddr.sin_addr.s_addr := INADDR_ANY;

    FLocalAddr.sin_addr.s_addr := INADDR_BROADCAST;
    b := true;

    setsockopt(FSendSocket, SOL_SOCKET, SO_BROADCAST, PChar(@b), SizeOf(b));

    code := bind(FSocket, FLocalAddr, SizeOf(FLocalAddr));
    setsockopt(FSocket, SOL_SOCKET, SO_BROADCAST, PChar(@b), SizeOf(b));
    FLogger.Log('Discover Response thread created');
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message);
  end;
end;

procedure TDiscoverResponseThread.Execute;
var
  returnLength: int;
  sendBuffer: DynamicByteArray;
  recvBuffer: DynamicByteArray;
  len: int;
  recvData: PChar;
  query: string;
begin
  query := 'WhereAreYou.01';
  while not Terminated do
  begin
    try
      SetLength(recvBuffer, High(short));
      len := SizeOf(FClientAddr);
//    returnLength := recvfrom(FSocket, Pointer(recvBuffer)^, Length(recvBuffer), MSG_PEEK, FClientAddr, len);

      returnLength := sendto(FSendSocket, query[1], Length(query), 0, FLocalAddr, len);

      returnLength := recvfrom(FSocket, Pointer(recvBuffer)^, Length(recvBuffer), 0, FClientAddr, len);
      if returnLength < 0 then
        Continue;
//    if (returnLength = SOCKET_ERROR) then
//          raise ESocketException.Create(GetLastErrorString());
      SetLength(recvBuffer, returnLength);
      FLogger.Log('Inbound data length ' + IntToStr(returnLength));
      FLogger.Log('From ' + inet_ntoa(FClientAddr.sin_addr));
      recvData := PChar(recvBuffer);
      FLogger.Log(StrPas(recvData));
//        sendBuffer := FPacketDispatcher.Process(recvBuffer);
      SetLength(sendBuffer, returnLength);
      CopyMemory(sendBuffer, recvBuffer, returnLength);
      returnLength := sendto(FSocket, Pointer(sendBuffer)^, Length(sendBuffer), 0, FClientAddr, len);
//        if (returnLength = SOCKET_ERROR) then
//          raise ESocketException.Create(GetLastErrorString());
      FLogger.Log('Outbound data length ' + IntToStr(returnLength));
      FLogger.Log('To ' + inet_ntoa(FClientAddr.sin_addr));
    except
      on Ex: Exception do
        FLogger.Log(Ex.Message);
    end;
  end;
end;

end.
 
