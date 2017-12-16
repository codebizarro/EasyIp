unit UnitTests;

interface

uses
  SysUtils,
  Classes,
  eiCommonTypes,
  eiConstants,
  eiPacket,
  eiHelpers,
  TestFramework;

type
  TPacketFactoryTest = class(TTestCase)
  private
    FPacketSize: int;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetReadPacket;
    procedure TestGetWritePacket;
  end;

implementation

{ TPacketFactoryTest }

procedure TPacketFactoryTest.SetUp;
begin
  inherited;
  FPacketSize := SizeOf(EasyIpPacket);
end;

procedure TPacketFactoryTest.TearDown;
begin
  inherited;

end;

procedure TPacketFactoryTest.TestGetReadPacket;
var
  readPacket: EasyIpPacket;
begin
  readPacket := TPacketFactory.GetReadPacket(0, EASYIP_TYPE_FLAGWORD, EASYIP_DATASIZE - 1);
end;

procedure TPacketFactoryTest.TestGetWritePacket;
var
  writePacket: EasyIpPacket;
begin
  writePacket := TPacketFactory.GetWritePacket(0, EASYIP_TYPE_FLAGWORD, EASYIP_DATASIZE - 1);
end;

initialization
  TestFramework.RegisterTest(TPacketFactoryTest.Suite);

end.

