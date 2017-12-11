unit ChannelTests;

interface

uses
  Windows,
  SysUtils,
  Classes,
  EasyIpCommonTypes,
  EasyIpConstants,
  EasyIpPacket,
  EasyIpHelpers,
  EasyIpChannel,
  TestFramework , WinSock;

type
  TChannelTest = class(TTestCase)
  private
    FChannel: IChannel;
    FSendPacket: TEasyIpPacket;
    FSendBuffer: TEiByteArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExecuteBuffer;
    procedure TestExecuteRecord;
    procedure TestQuick;
  end;

implementation

{ TChannelTest }

procedure TChannelTest.SetUp;
begin
  inherited;
//  FChannel := TMockChannel.Create('127.0.0.1', EASYIP_PORT);
  FChannel := TUdpChannel.Create('10.20.0.104', EASYIP_PORT);
  FSendPacket := TPacketFactory.GetReadPacket(0, EASYIP_TYPE_FLAGWORD, 1);
  FSendBuffer := TPacketAdapter.ToByteArray(FSendPacket);
end;

procedure TChannelTest.TearDown;
begin
  inherited;

end;

procedure TChannelTest.TestExecuteBuffer;
var
  receiveBuffer: TEiByteArray;
  receivePacket: TEasyIpPacket;
begin
  receiveBuffer := FChannel.Execute(FSendBuffer);

  Check(receiveBuffer <> nil);
  Check(Length(FSendBuffer) = Length(receiveBuffer));

  receivePacket := TPacketAdapter.ToEasyIpPacket(receiveBuffer);
end;

procedure TChannelTest.TestExecuteRecord;
var
  receiveBuffer: TEiByteArray;
  receivePacket: TEasyIpPacket;
begin
  receivePacket := FChannel.Execute(FSendPacket);

  Check(SizeOf(receivePacket) > 0);
  Check(SizeOf(receivePacket) = SizeOf(FSendPacket));
end;

procedure TChannelTest.TestQuick;
var
  Init: TWSAData;
//  SockOpt: BOOL;
  sock: TSocket;
  target: TSockAddrIn;
  err: Cardinal;
  sendPacket: TEasyIpPacket;
  recvPacket: TEasyIpPacket;
  lenFrom: int;
  //buff: array[0..EASYIP_HEADERSIZE + EASYIP_DATASIZE] of Byte;
const
  Data =[$00, $00];
begin
  WSAStartup($101, Init);
  sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
//  SockOpt:=TRUE;
//  SetSockOpt(sock,SOL_SOCKET,SO_BROADCAST, PChar(@SockOpt),SizeOf(SockOpt)) ;
  target.sin_port := htons(EASYIP_PORT);
  target.sin_addr.S_addr := inet_addr(PChar('10.20.0.104'));
  target.sa_family := AF_INET;
  err := connect(sock, target, SizeOf(target));
  if (err = SOCKET_ERROR) then
    raise Exception.Create('Socket error');

  ZeroMemory(@sendPacket, SizeOf(sendPacket));
  ZeroMemory(@recvPacket, SizeOf(recvPacket));

  sendPacket.RequestDataType := EASYIP_TYPE_FLAGWORD;
  sendPacket.RequestDataSize := 3;
  sendPacket.RequestDataOffsetServer := 0;

  //err := send(sock, sendPacket, EASYIP_HEADERSIZE, 0);
  //err := recv(sock, recvPacket, sizeof(recvPacket), 0);

  err := sendto(sock, sendPacket, EASYIP_HEADERSIZE, 0, target, SizeOf(sendPacket));
  lenFrom := 20;
  err := recvfrom(sock, recvPacket, sizeof(recvPacket), 0, target, lenFrom);

  closesocket(sock);
  WSACleanup;
end;

initialization
  TestFramework.RegisterTest(TChannelTest.Suite);

end.

