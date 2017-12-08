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
  init: TWSAData;
  sock: TSocket;
  target: TSockAddrIn;
  error: Cardinal;
  receiveBuffer: TEiByteArray;
begin
  WSAStartup($101, init);
  sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  target.sin_port := htons(FPort);
  target.sin_addr.S_addr := inet_addr(PChar(FHost));
  target.sa_family := AF_INET;
  FillChar(target.sin_zero,SizeOf(target.sin_zero),0);
  error := connect(sock, target, SizeOf(target));
  if (error = SOCKET_ERROR) then
    raise Exception.Create('Socket error');

  SetLength(receiveBuffer, Length(buffer));
  SetLength(Result, Length(buffer));

  error := send(sock, buffer, Length(buffer), 0);

  error := recv(sock, Result, Length(buffer), 0);

  //closesocket(sock);
  WSACleanup;
end;

end.

