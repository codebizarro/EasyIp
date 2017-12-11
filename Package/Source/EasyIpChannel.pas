unit EasyIpChannel;

interface

uses
  EasyIpCommonTypes,
  EasyIpConstants,
  EasyIpPacket,
  EasyIpHelpers,
  Classes,
  SysUtils,
  Windows,
  WinSock;

type
  IChannel = interface
    function Execute(buffer: TEiByteArray): TEiByteArray;
  end;

  IEasyIpChannel = interface
    function Execute(packet: TEasyIpPacket): TEasyIpPacket;
  end;

  TCustomChannel = class(TInterfacedObject, IChannel, IEasyIpChannel)
  private
  protected
    FHost: string;
    FPort: int;
    FTarget: TSockAddrIn;
  public
    constructor Create(host: string; port: int); overload;
    function Execute(buffer: TEiByteArray): TEiByteArray; overload; virtual; abstract;
    function Execute(packet: TEasyIpPacket): TEasyIpPacket; overload; virtual; abstract;
  end;

  TMockChannel = class(TCustomChannel)
  private
  protected
  public
    destructor Destroy; override;
    function Execute(buffer: TEiByteArray): TEiByteArray; overload; override;
    function Execute(packet: TEasyIpPacket): TEasyIpPacket; overload; override;
  end;

  TEasyIpChannel = class(TCustomChannel)
  private
  protected
  public
    constructor Create(host: string; port: int); overload;
    destructor Destroy; override;
    function Execute(buffer: TEiByteArray): TEiByteArray; override;
    function Execute(packet: TEasyIpPacket): TEasyIpPacket; overload; override;
  end;

implementation

constructor TCustomChannel.Create(host: string; port: int);
begin
  inherited Create;
  FHost := host;
  FPort := port;
  ZeroMemory(@FTarget, SizeOf(FTarget));
  FTarget.sin_port := htons(FPort);
  FTarget.sin_addr.S_addr := inet_addr(PChar(FHost));
  FTarget.sa_family := AF_INET;
end;

destructor TMockChannel.Destroy;
begin
  inherited;

end;

function TMockChannel.Execute(buffer: TEiByteArray): TEiByteArray;
var
  temp: TEiByteArray;
begin
  SetLength(temp, Length(buffer));
  temp := Copy(buffer, 0, Length(buffer));
  temp[0] := $80;
  Result := temp;
end;

function TMockChannel.Execute(packet: TEasyIpPacket): TEasyIpPacket;
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

function TEasyIpChannel.Execute(buffer: TEiByteArray): TEiByteArray;
var
  init: TWSAData;
  sock: TSocket;
  returnCode: Cardinal;
  sendBuffer: TEiByteArray;
  recvBuffer: TEiByteArray;
  lenFrom: int;
begin
  WSAStartup($101, init);
  sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

  returnCode := connect(sock, FTarget, SizeOf(FTarget));
  if (returnCode = SOCKET_ERROR) then
    raise Exception.Create('Socket error');

  SetLength(sendBuffer, Length(buffer));
  SetLength(recvBuffer, Length(buffer));
  sendBuffer := buffer;

  //returnCode := send(sock, Pointer(buffer)^, Length(buffer), 0);
  //returnCode := recv(sock, Pointer(receiveBuffer)^, Length(receiveBuffer), 0);

  returnCode := sendto(sock, Pointer(sendBuffer)^, Length(sendBuffer), 0, FTarget, Length(sendBuffer));
  lenFrom := Length(recvBuffer);
  returnCode := recvfrom(sock, Pointer(recvBuffer)^, Length(recvBuffer), 0, FTarget, lenFrom);

  closesocket(sock);
  WSACleanup;
  Result := recvBuffer;
end;

function TEasyIpChannel.Execute(packet: TEasyIpPacket): TEasyIpPacket;
var
  init: TWSAData;
  sock: TSocket;
  returnCode: Cardinal;
  sendPacket: TEasyIpPacket;
  recvPacket: TEasyIpPacket;
  lenFrom: int;
begin
  WSAStartup($101, init);

  sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

  returnCode := connect(sock, FTarget, SizeOf(FTarget));
  if (returnCode = SOCKET_ERROR) then
    raise Exception.Create('Socket error');

  ZeroMemory(@sendPacket, SizeOf(sendPacket));
  ZeroMemory(@recvPacket, SizeOf(recvPacket));

  sendPacket := packet;

  //err := send(sock, sendPacket, EASYIP_HEADERSIZE, 0);
  //err := recv(sock, recvPacket, sizeof(recvPacket), 0);

  returnCode := sendto(sock, sendPacket, SizeOf(sendPacket), 0, FTarget, SizeOf(sendPacket));
  lenFrom := SizeOf(recvPacket);
  returnCode := recvfrom(sock, recvPacket, sizeof(recvPacket), 0, FTarget, lenFrom);

  closesocket(sock);
  WSACleanup;

  Result := recvPacket;
end;

end.

