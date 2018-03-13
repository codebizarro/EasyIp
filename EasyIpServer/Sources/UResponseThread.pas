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
  UPacketDispatcher;

type
  TResponseSocketThread = class(TBaseSocketThread)
  private
    FClientAddr: TSockAddrIn;
    FPacketDispatcher: IPacketDispatcher;
    FBuffer: DynamicByteArray;
  public
    constructor Create(logger: ILogger; const target: TSockAddrIn; const buffer:
        DynamicByteArray);
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

constructor TResponseSocketThread.Create(logger: ILogger; const target:
    TSockAddrIn; const buffer: DynamicByteArray);
var
  code: int;
  bufferLength: int;
begin
  inherited Create(true);
  FLogger := logger;
  try
    ZeroMemory(@FClientAddr, SizeOf(TSockAddrIn));
    CopyMemory(@FClientAddr, @target, SizeOf(TSockAddrIn));
//    FClientAddr := target;
    bufferLength := Length(buffer);
    SetLength(FBuffer, bufferLength);
    CopyMemory(FBuffer, buffer, bufferLength);
    FPacketDispatcher := TPacketDispatcher.Create(FLogger);

    ZeroMemory(@FWsaData, SizeOf(TWsaData));
    code := WSAStartup(WINSOCK_VERSION, FWsaData);
    if code <> 0 then
      raise ESocketException.Create(GetLastErrorString());

    FSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if FSocket = INVALID_SOCKET then
      raise ESocketException.Create(GetLastErrorString());

    FLogger.Log('Response thread created');
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message);
  end;
end;

destructor TResponseSocketThread.Destroy;
begin
  FLogger.Log('Response thread destroyed');
  inherited;
end;

procedure TResponseSocketThread.Execute;
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
      FLogger.Log(Ex.Message);
  end;
end;

end.

