unit UnitTests;

interface

uses
  SysUtils,
  Classes,
  EasyIpCommonTypes,
  EasyIpConstants,
  EasyIpPacket,
  EasyIpHelpers,
  TestFramework;

type
  TTestCaseStub = class(TTestCase)
  private
    Fsl: TStringList;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPopulateStringList;
    procedure TestSortStringList;
  end;

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

procedure TTestCaseStub.SetUp;
begin
  inherited;
  Fsl := TStringList.Create
end;

procedure TTestCaseStub.TearDown;
begin
  inherited;
  Fsl.Free
end;

procedure TTestCaseStub.TestPopulateStringList;
var
  i: int;
const
  count: int = 10;
begin
  Check(Fsl.Count = 0);
  for i := 1 to count do
    Fsl.Add('i');
  Check(Fsl.Count = count);
end;

procedure TTestCaseStub.TestSortStringList;
begin
  Check(Fsl.Sorted = False);
  Check(Fsl.Count = 0);
  Fsl.Add('One');
  Fsl.Add('Two');
  Fsl.Add('Three');
  Fsl.Sorted := True;
  Check(Fsl[2] = 'Two');
  Check(Fsl[1] = 'Three');
  Check(Fsl[0] = 'One');
end;

{ TPacketFactoryTest }

procedure TPacketFactoryTest.SetUp;
begin
  inherited;
  FPacketSize := SizeOf(TEasyIpPacket);
end;

procedure TPacketFactoryTest.TearDown;
begin
  inherited;

end;

procedure TPacketFactoryTest.TestGetReadPacket;
var
  readPacket: TEasyIpPacket;
begin
  readPacket := TPacketFactory.GetReadPacket(0, EASYIP_TYPE_FLAGWORD, EASYIP_DATASIZE-1);//TODO: overflow
end;

procedure TPacketFactoryTest.TestGetWritePacket;
var
  writePacket: TEasyIpPacket;
begin
  writePacket := TPacketFactory.GetWritePacket(0, EASYIP_TYPE_FLAGWORD, EASYIP_DATASIZE-1);//TODO: overflow
end;

initialization
  TestFramework.RegisterTest(TTestCaseStub.Suite);
  TestFramework.RegisterTest(TPacketFactoryTest.Suite);

end.

