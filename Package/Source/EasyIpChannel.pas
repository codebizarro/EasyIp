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
    function Execute(buffer: TEiByteArray): TEiByteArray; overload;
    function Execute(buffer: TEasyIpPacket): TEasyIpPacket; overload;
  end;

  TCustomChannel = class(TInterfacedObject, IChannel)
  private
  protected
    FHost: string;
    FPort: int;
  public
    constructor Create(host: string; port: int); overload;
    function Execute(buffer: TEiByteArray): TEiByteArray; overload; virtual; abstract;
    function Execute(buffer: TEasyIpPacket): TEasyIpPacket; overload; virtual; abstract;
  end;

  TMockChannel = class(TCustomChannel)
  private
  protected
  public
    destructor Destroy; override;
    function Execute(buffer: TEiByteArray): TEiByteArray; overload; override;
    function Execute(buffer: TEasyIpPacket): TEasyIpPacket; overload; override;
  end;

  TEasyIpChannel = class(TCustomChannel)
  private
  protected
  public
    constructor Create(host: string; port: int); overload;
    destructor Destroy; override;
    function Execute(buffer: TEiByteArray): TEiByteArray; override;
    function Execute(buffer: TEasyIpPacket): TEasyIpPacket; overload; override;
  end;

implementation

constructor TCustomChannel.Create(host: string; port: int);
begin
  inherited Create;
  FHost := host;
  FPort := port;
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

function TMockChannel.Execute(buffer: TEasyIpPacket): TEasyIpPacket;
begin
  buffer.Flags := $80;
  Result := buffer;
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
  target: TSockAddrIn;
  error: Cardinal;
  //localBuffer: TEiByteArray;
  localBuffer: array[0..1024 - 1] of Byte;
  lenFrom: int;
begin
  WSAStartup($101, init);
  sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  target.sin_port := htons(FPort);
  target.sin_addr.S_addr := inet_addr(PChar(FHost));
  target.sa_family := AF_INET;
  //FillChar(target.sin_zero,SizeOf(target.sin_zero),0);
  error := connect(sock, target, SizeOf(target));
  if (error = SOCKET_ERROR) then
    raise Exception.Create('Socket error');

//  SetLength(localBuffer, Length(buffer));
  ZeroMemory(@localBuffer, Length(localBuffer));
  //localBuffer := buffer;
  lenFrom := SizeOf(buffer);
  lenFrom := Length(buffer);
  error := send(sock, buffer, Length(buffer), 0);
  //lenFrom := SizeOf(localBuffer);
  lenFrom := Length(localBuffer);
  //error := recvfrom(sock, localBuffer, Length(localBuffer), 0, target, lenFrom);
  error := recv(sock, localBuffer[0], 1024 {Length(buffer)}, 0);

  closesocket(sock);
  WSACleanup;
  //Result := localBuffer;
end;

function TEasyIpChannel.Execute(buffer: TEasyIpPacket): TEasyIpPacket;
var
  init: TWSAData;
  sock: TSocket;
  target: TSockAddrIn;
  returnCode: Cardinal;
  sendPacket: TEasyIpPacket;
  recvPacket: TEasyIpPacket;
  lenFrom: int;
begin
  WSAStartup($101, init);

  sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);

  //FillChar(target, SizeOf(target), 0); //target.sin_zero
  ZeroMemory(@target, SizeOf(target));
  target.sin_port := htons(FPort);
  target.sin_addr.S_addr := inet_addr(PChar(FHost));
  target.sa_family := AF_INET;

  returnCode := connect(sock, target, SizeOf(target));
  if (returnCode = SOCKET_ERROR) then
    raise Exception.Create('Socket error');

  ZeroMemory(@sendPacket, SizeOf(sendPacket));
  ZeroMemory(@recvPacket, SizeOf(recvPacket));

  sendPacket := buffer;

  //err := send(sock, sendPacket, EASYIP_HEADERSIZE, 0);
  //err := recv(sock, recvPacket, sizeof(recvPacket), 0);

  returnCode := sendto(sock, sendPacket, SizeOf(sendPacket), 0, target, SizeOf(sendPacket));
  lenFrom := SizeOf(recvPacket);
  returnCode := recvfrom(sock, recvPacket, sizeof(recvPacket), 0, target, lenFrom);

  closesocket(sock);
  WSACleanup;

  Result := recvPacket;
end;

end.

