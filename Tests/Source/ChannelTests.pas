unit ChannelTests;

interface

uses
  Windows,
  SysUtils,
  Classes,
  eiCommonTypes,
  eiConstants,
  eiExceptions,
  eiPacket,
  eiHelpers,
  eiChannel,
  TestFramework,
  TestExtensions,
  WinSock;

type
  TChannelTest = class(TTestCase)
  private
    FBufferChannel: IChannel;
    FPacketChannel: IEasyIpChannel;
    FSendPacket: EasyIpPacket;
    FSendBuffer: DynamicByteArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExecuteBuffer;
    procedure TestExecuteRecord;
  end;

implementation

{ TChannelTest }

procedure TChannelTest.SetUp;
begin
  inherited;
//  FChannel := TMockChannel.Create('127.0.0.1', EASYIP_PORT);
  FBufferChannel := TEasyIpChannel.Create('10.20.0.104', EASYIP_PORT);
  FPacketChannel := TEasyIpChannel.Create('10.20.0.104', EASYIP_PORT);
  FSendPacket := TPacketFactory.GetReadPacket(0, EASYIP_TYPE_FLAGWORD, 20);
  FSendBuffer := TPacketAdapter.ToByteArray(FSendPacket);
end;

procedure TChannelTest.TearDown;
begin
  inherited;

end;

procedure TChannelTest.TestExecuteBuffer;
var
  receiveBuffer: DynamicByteArray;
  receivePacket: EasyIpPacket;
begin
  receiveBuffer := FBufferChannel.Execute(FSendBuffer);

  Check(receiveBuffer <> nil);
  Check(Length(FSendBuffer) = Length(receiveBuffer));

  receivePacket := TPacketAdapter.ToEasyIpPacket(receiveBuffer);
  Check(receivePacket.Error = 0);
  Check(receivePacket.Flags = EASYIP_FLAG_RESPONSE);
end;

procedure TChannelTest.TestExecuteRecord;
var
  receivePacket: EasyIpPacket;
begin
  receivePacket := FPacketChannel.Execute(FSendPacket);

  Check(SizeOf(receivePacket) = SizeOf(FSendPacket));
  Check(receivePacket.Error = 0);
  Check(receivePacket.Flags = EASYIP_FLAG_RESPONSE);
end;

initialization
  //TestFramework.RegisterTest(TChannelTest.Suite);
  TestFramework.RegisterTest(TRepeatedTest.Create(TChannelTest.Suite, 1));

end.

