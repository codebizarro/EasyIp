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
  TListenSocketThread = class(TBaseSocketThread)
  private
    FLocalAddr: TSockAddrIn;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

constructor TListenSocketThread.Create;
var
  code: int;
begin
  inherited Create(true);
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
    FLocalAddr.sin_port := htons(EASYIP_PORT);
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

destructor TListenSocketThread.Destroy;
begin
  FLogger.Log('Listen thread destroyed');
  inherited;
end;

procedure TListenSocketThread.Execute;
var
  returnLength: int;
  recvBuffer: DynamicByteArray;
  len: int;
  FClientAddr: TSockAddrIn;
begin
  while true do
  begin
    try
      SetLength(recvBuffer, High(short));
      len := SizeOf(FClientAddr);
      returnLength := recvfrom(FSocket, Pointer(recvBuffer)^, Length(recvBuffer), 0, FClientAddr, len);
      if (returnLength = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());
        
      SetLength(recvBuffer, returnLength);
      FLogger.Log('Inbound data length ' + IntToStr(returnLength));
      FLogger.Log('From ' + inet_ntoa(FClientAddr.sin_addr));

      with TResponseSocketThread.Create(FClientAddr, recvBuffer) do
        Resume;
    except
      on Ex: Exception do
        FLogger.Log(Ex.Message);
    end;
  end;
end;

end.

