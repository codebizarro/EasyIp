unit EasyIpChannel;

interface

uses
  EasyIpCommonTypes,
  EasyIpConstants,
  EasyIpPacket,
  EasyIpHelpers,
  Classes,
  SysUtils,
  WinSock;

type
  IChannel = interface
    function Execute(buffer: TEiByteArray): TEiByteArray;
  end;

  TCustomChannel = class(TInterfacedObject, IChannel)
  private
  protected
    FHost: string;
    FPort: int;
  public
    constructor Create(host: string; port: int); overload;
    function Execute(buffer: TEiByteArray): TEiByteArray; virtual; abstract;
  end;

  TMockChannel = class(TCustomChannel)
  private
  protected
  public
    destructor Destroy; override;
    function Execute(buffer: TEiByteArray): TEiByteArray; override;
  end;

  TUdpChannel = class(TCustomChannel)
  private
  protected
  public
    constructor Create(host: string; port: int); overload;
    destructor Destroy; override;
    function Execute(buffer: TEiByteArray): TEiByteArray; override;
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

constructor TUdpChannel.Create(host: string; port: int);
begin
  inherited Create(host, port);

end;

destructor TUdpChannel.Destroy;
begin
  inherited;

end;

function TUdpChannel.Execute(buffer: TEiByteArray): TEiByteArray;
var
  Init: TWSAData;
//  SockOpt: BOOL;
  sock: TSocket;
  target: TSockAddrIn;
  err: Cardinal;
  sendPacket: TEasyIpPacket;
  recvPacket: TEasyIpPacket;
begin
  {
  WSAStartup($101, Init);
  sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
//  SockOpt:=TRUE;
//  SetSockOpt(sock,SOL_SOCKET,SO_BROADCAST, PChar(@SockOpt),SizeOf(SockOpt)) ;
  target.sin_port := htons(EASYIP_PORT);
  target.sin_addr.S_addr := inet_addr(PChar(FHost));
  target.sa_family := AF_INET;
  err := connect(sock, target, SizeOf(target));
  if (err = SOCKET_ERROR) then
    raise Exception.Create('Socket error');

  ZeroMemory(@sendPacket, SizeOf(sendPacket));
  ZeroMemory(@recvPacket, SizeOf(recvPacket));

  sendPacket.RequestDataType := EASYIP_TYPE_FLAGWORD;
  sendPacket.RequestDataSize := 3;
  sendPacket.RequestDataOffsetServer := 0;

  err := send(sock, sendPacket, EASYIP_HEADERSIZE, 0);
  err := recv(sock, recvPacket, sizeof(recvPacket), 0);

  closesocket(sock);
  WSACleanup;
  }
end;

end.

