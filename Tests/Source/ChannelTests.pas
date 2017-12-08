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
  TestFramework;

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
    procedure TestExecute;
  end;

implementation

{ TChannelTest }

procedure TChannelTest.SetUp;
begin
  inherited;
//  FChannel := TMockChannel.Create('127.0.0.1', EASYIP_PORT);
  FChannel := TUdpChannel.Create('10.20.0.104', EASYIP_PORT);
  FSendPacket := TPacketFactory.GetReadPacket(2, EASYIP_TYPE_FLAGWORD, 4);
  FSendBuffer := TPacketAdapter.ToByteArray(FSendPacket);
end;

procedure TChannelTest.TearDown;
begin
  inherited;

end;

procedure TChannelTest.TestExecute;
var
  receiveBuffer: TEiByteArray;
  receivePacket: TEasyIpPacket;
begin
  receiveBuffer := FChannel.Execute(FSendBuffer);

  Check(receiveBuffer <> nil);
  Check(Length(FSendBuffer) = Length(receiveBuffer));

  receivePacket := TPacketAdapter.ToEasyIpPacket(receiveBuffer);
end;

initialization
  TestFramework.RegisterTest(TChannelTest.Suite);

end.

