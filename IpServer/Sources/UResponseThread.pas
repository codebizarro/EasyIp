unit UResponseThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WinSock,
  eiTypes,
  eiConstants,
  eiExceptions,
  UServerTypes,
  UBaseThread,
  UPacketHandlers;

type
  TUdpResponseThread = class(TBaseSocketThread)
  private
    FClientAddr: TSockAddrIn;
    FPacketDispatcher: IHandler;
    FBuffer: DynamicByteArray;
  public
    constructor Create(logger: ILogger; const request: RequestStruct);
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

constructor TUdpResponseThread.Create(logger: ILogger; const request: RequestStruct);
var
  code: int;
  bufferLength: int;
begin
  inherited Create(true);
  FLogger := logger;
  try
    ZeroMemory(@FClientAddr, SizeOf(TSockAddrIn));
    CopyMemory(@FClientAddr, @request.Target, SizeOf(TSockAddrIn));
//    FClientAddr := target;
    bufferLength := Length(request.Buffer);
    SetLength(FBuffer, bufferLength);
    CopyMemory(FBuffer, request.Buffer, bufferLength);
    FPacketDispatcher := request.Handler;

    ZeroMemory(@FWsaData, SizeOf(TWsaData));
    code := WSAStartup(WINSOCK_VERSION, FWsaData);
    if code <> 0 then
      raise ESocketException.Create(GetLastErrorString());

    FSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if FSocket = INVALID_SOCKET then
      raise ESocketException.Create(GetLastErrorString());

    FLogger.Log('Response thread created', elNotice);
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message, elError);
  end;
end;

destructor TUdpResponseThread.Destroy;
begin
  FLogger.Log('Response thread destroyed');
  inherited;
end;

procedure TUdpResponseThread.Execute;
var
  returnLength: int;
  sendBuffer: DynamicByteArray;
  len: int;
begin
  try
    sendBuffer := FPacketDispatcher.Process(FBuffer);
    len := SizeOf(FClientAddr);
    returnLength := sendto(FSocket, Pointer(sendBuffer)^, Length(sendBuffer), 0, FClientAddr, len);
    if (returnLength = SOCKET_ERROR) then
      raise ESocketException.Create(GetLastErrorString());
    FLogger.Log('Outbound data length ' + IntToStr(returnLength));
    FLogger.Log('To ' + inet_ntoa(FClientAddr.sin_addr));
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message, elError);
  end;
end;

end.

