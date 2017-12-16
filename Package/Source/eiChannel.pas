unit eiChannel;

interface

uses
  eiCommonTypes,
  eiConstants,
  eiExceptions,
  eiPacket,
  eiHelpers,
  Classes,
  SysUtils,
  Windows,
  WinSock;

type
  IChannel = interface
    function Execute(buffer: DynamicByteArray): DynamicByteArray;
  end;

  IEasyIpChannel = interface
    function Execute(packet: EasyIpPacket): EasyIpPacket;
  end;

  TCustomChannel = class(TInterfacedObject)
  private
  protected
    FHost: string;
    FPort: int;
    FTarget: TSockAddrIn;
    FTimeout: int;
    function GetLastErrorString(): string;
  public
    constructor Create(host: string; port: int); overload;
    property Timeout: int read FTimeout write FTimeout;
  end;

  TMockChannel = class(TCustomChannel, IChannel, IEasyIpChannel)
  private
  protected
  public
    destructor Destroy; override;
    function Execute(buffer: DynamicByteArray): DynamicByteArray; overload;
    function Execute(packet: EasyIpPacket): EasyIpPacket; overload;
  end;

  TEasyIpChannel = class(TCustomChannel, IChannel, IEasyIpChannel)
  private
  protected
  public
    constructor Create(host: string; port: int); overload;
    destructor Destroy; override;
    function Execute(buffer: DynamicByteArray): DynamicByteArray; overload;
    function Execute(packet: EasyIpPacket): EasyIpPacket; overload;
  end;

implementation

constructor TCustomChannel.Create(host: string; port: int);
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

function TCustomChannel.GetLastErrorString: string;
var
  Buffer: array[0..2047] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, WSAGetLastError, $400, @Buffer, SizeOf(Buffer), nil);
  Result := Buffer;
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

function TEasyIpChannel.Execute(buffer: DynamicByteArray): DynamicByteArray;
var
  init: TWSAData;
  sock: TSocket;
  returnCode: Cardinal;
  sendBuffer: DynamicByteArray;
  recvBuffer: DynamicByteArray;
  lenFrom: int;
begin
  WSAStartup($0202, init);
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
  if returnCode < 0 then
    raise ESocketException.Create(GetLastErrorString());

  lenFrom := SizeOf(FTarget);
  returnCode := recvfrom(sock, Pointer(recvBuffer)^, Length(recvBuffer), 0, FTarget, lenFrom);
  if returnCode < 0 then
    raise ESocketException.Create(GetLastErrorString());

  SetLength(recvBuffer, returnCode);

  closesocket(sock);
  WSACleanup;
  Result := recvBuffer;
end;

function TEasyIpChannel.Execute(packet: EasyIpPacket): EasyIpPacket;
var
  init: TWSAData;
  sock: TSocket;
  returnCode: Cardinal;
  sendPacket: EasyIpPacket;
  recvPacket: EasyIpPacket;
  lenFrom: int;
begin
  WSAStartup($0202, init);

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
  if returnCode < 0 then
    raise ESocketException.Create(GetLastErrorString());

  lenFrom := SizeOf(FTarget);
  returnCode := recvfrom(sock, recvPacket, sizeof(recvPacket), 0, FTarget, lenFrom);
  if returnCode < 0 then
    raise ESocketException.Create(GetLastErrorString());

  closesocket(sock);
  WSACleanup;

  Result := recvPacket;
end;

end.

