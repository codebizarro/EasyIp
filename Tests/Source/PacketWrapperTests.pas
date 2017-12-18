unit PacketWrapperTests;

interface

uses
  SysUtils,
  Classes,
  eiTypes,
  eiConstants,
  eiPacket,
  eiHelpers,
  TestFramework;

type
  TPacketWrapperTest = class(TTestCase)
  private
    FOffset: ushort;
    FDataType: DataTypeEnum;
    FLength: DataLength;
    FPacket: EasyIpPacket;
    FWrapperPacket: IEasyIpProtocol;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReadPacket;
    procedure TestWritePacket;
  end;

implementation

{ TPacketWrapperTest }

procedure TPacketWrapperTest.SetUp;
begin
  inherited;
  FOffset := 5555;
  FDataType := dtFlag;
  FLength := 222;
end;

procedure TPacketWrapperTest.TearDown;
begin
  inherited;

end;

procedure TPacketWrapperTest.TestReadPacket;
var
  i: int;
begin
  FPacket := TPacketFactory.GetReadPacket(FOffset, EASYIP_TYPE_FLAGWORD, FLength);
  FWrapperPacket := TEasyIpProtocol.Create(pmRead);
  with FWrapperPacket do
  begin
    DataLength := FLength;
    DataType := FDataType;
    DataOffset := FOffset;
  end;
  Check(FPacket.SendDataType = FWrapperPacket.Packet.SendDataType);
  Check(FPacket.RequestDataType = FWrapperPacket.Packet.RequestDataType);
  Check(FPacket.RequestDataSize = FWrapperPacket.Packet.RequestDataSize);
  Check(FPacket.RequestDataOffsetServer = FWrapperPacket.Packet.RequestDataOffsetServer);
  for i := 1 to Length(FPacket.Data) do
  begin
    Check(FPacket.Data[i] = 0);
    Check(FWrapperPacket.Packet.Data[i] = 0);
  end;
  FWrapperPacket := nil;
end;

procedure TPacketWrapperTest.TestWritePacket;
var
  i: int;
begin
  FPacket := TPacketFactory.GetWritePacket(FOffset, EASYIP_TYPE_FLAGWORD, FLength);
  FWrapperPacket := TEasyIpProtocol.Create(pmWrite);
  with FWrapperPacket do
  begin
    DataLength := FLength;
    DataType := FDataType;
    DataOffset := FOffset;
  end;
  Check(FPacket.SendDataType = FWrapperPacket.Packet.SendDataType);
  Check(FPacket.RequestDataType = FWrapperPacket.Packet.RequestDataType);
  Check(FPacket.SendDataSize = FWrapperPacket.Packet.SendDataSize);
  Check(FPacket.SendDataOffset = FWrapperPacket.Packet.SendDataOffset);
  for i := 1 to Length(FPacket.Data) do
  begin
    Check(FWrapperPacket.Packet.Data[i] = FPacket.Data[i]);
  end;
  FWrapperPacket := nil;
end;

initialization
  TestFramework.RegisterTest(TPacketWrapperTest.Suite);

end.

