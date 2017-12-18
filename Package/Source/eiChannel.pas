unit eiChannel;

interface

uses
  eiTypes,
  eiConstants,
  eiExceptions,
  eiProtocol,
  eiHelpers,
  Classes,
  SysUtils,
  Windows,
  WinSock;

type
  TUdpChannel = class(TInterfacedObject)
  private
    function GetTimeout: int;
    procedure SetTimeout(const value: int);
  protected
    FHost: string;
    FPort: int;
    FTimeout: int;
    FTarget: TSockAddrIn;
    function GetLastErrorString(): string;
  public
    constructor Create(host: string; port: int); overload;
    function Execute(buffer: DynamicByteArray): DynamicByteArray; overload;
    property Timeout: int read GetTimeout write SetTimeout default 2000;
  end;

  TMockChannel = class(TUdpChannel, IChannel, IEasyIpChannel)
  private
  protected
  public
    destructor Destroy; override;
    function Execute(buffer: DynamicByteArray): DynamicByteArray; overload;
    function Execute(packet: EasyIpPacket): EasyIpPacket; overload;
  end;

  TEasyIpChannel = class(TUdpChannel, IChannel, IEasyIpChannel)
  private
  protected
  public
    constructor Create(host: string; port: int); overload;
    destructor Destroy; override;
    function Execute(packet: EasyIpPacket): EasyIpPacket; overload;
  end;

implementation

const
  WINSOCK_VERSION = $0202;
  LANG_ID = $400;

constructor TUdpChannel.Create(host: string; port: int);
begin
  inherited Create;
  FHost := host;
  FPort := port;
  FTimeout := 2000;
  ZeroMemory(@FTarget, SizeOf(FTarget));
  FTarget.sin_port := htons(FPort);
  FTarget.sin_addr.S_addr := inet_addr(PChar(FHost));
  FTarget.sa_family := AF_INET;
end;

destructor TMockChannel.Destroy;
begin
  inherited;

end;

function TUdpChannel.Execute(buffer: DynamicByteArray): DynamicByteArray;
var
  init: TWSAData;
  sock: TSocket;
  returnCode: int;
  sendBuffer: DynamicByteArray;
  recvBuffer: DynamicByteArray;
  lenFrom: int;
begin
  try
    returnCode := WSAStartup(WINSOCK_VERSION, init);
    if returnCode <> 0 then
      raise ESocketException.Create(GetLastErrorString());
    try
      sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
      returnCode := connect(sock, FTarget, SizeOf(FTarget));
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());
      setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, @FTimeout, SizeOf(FTimeout));
      setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, @FTimeout, SizeOf(FTimeout));

      SetLength(sendBuffer, Length(buffer));
      SetLength(recvBuffer, High(short));
      sendBuffer := buffer;

      returnCode := sendto(sock, Pointer(sendBuffer)^, Length(sendBuffer), 0, FTarget, SizeOf(FTarget));
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      lenFrom := SizeOf(FTarget);
      returnCode := recvfrom(sock, Pointer(recvBuffer)^, Length(recvBuffer), 0, FTarget, lenFrom);
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      SetLength(recvBuffer, returnCode);

      closesocket(sock);
      Result := recvBuffer;
    except
      on E: ESocketException do
        raise;
      on E: Exception do
        raise EEasyIpException.Create(E.Message);
    end;
  finally
    WSACleanup;
  end;
end;

function TUdpChannel.GetLastErrorString: string;
var
  Buffer: array[0..2047] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, WSAGetLastError, LANG_ID, @Buffer, SizeOf(Buffer), nil);
  Result := Buffer;
end;

function TUdpChannel.GetTimeout: int;
begin
  Result := FTimeout;
end;

procedure TUdpChannel.SetTimeout(const value: int);
begin
  FTimeout := value;
end;

function TMockChannel.Execute(buffer: DynamicByteArray): DynamicByteArray;
var
  temp: DynamicByteArray;
begin
  SetLength(temp, Length(buffer));
  temp := Copy(buffer, 0, Length(buffer));
  temp[0] := $80;
  Result := temp;
end;

function TMockChannel.Execute(packet: EasyIpPacket): EasyIpPacket;
begin
  packet.Flags := $80;
  Result := packet;
end;

constructor TEasyIpChannel.Create(host: string; port: int);
begin
  inherited Create(host, port);

end;

destructor TEasyIpChannel.Destroy;
begin
  inherited;

end;

function TEasyIpChannel.Execute(packet: EasyIpPacket): EasyIpPacket;
var
  init: TWSAData;
  sock: TSocket;
  returnCode: int;
  sendPacket: EasyIpPacket;
  recvPacket: EasyIpPacket;
  lenFrom: int;
begin
  try
    returnCode := WSAStartup(WINSOCK_VERSION, init);
    if returnCode <> 0 then
      raise ESocketException.Create(GetLastErrorString());
    try
      sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
      returnCode := connect(sock, FTarget, SizeOf(FTarget));
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());
      setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, @FTimeout, SizeOf(FTimeout));
      setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, @FTimeout, SizeOf(FTimeout));

      ZeroMemory(@sendPacket, SizeOf(sendPacket));
      ZeroMemory(@recvPacket, SizeOf(recvPacket));
      sendPacket := packet;

      returnCode := sendto(sock, sendPacket, SizeOf(sendPacket), 0, FTarget, SizeOf(FTarget));
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      lenFrom := SizeOf(FTarget);
      returnCode := recvfrom(sock, recvPacket, sizeof(recvPacket), 0, FTarget, lenFrom);
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      closesocket(sock);
      Result := recvPacket;
    except
      on E: ESocketException do
        raise;
      on E: Exception do
        raise EEasyIpException.Create(E.Message);
    end;
  finally
    WSACleanup;
  end;
end;

end.

