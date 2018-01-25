unit ClientTests;

interface

uses
  Windows,
  SysUtils,
  Classes,
  eiTypes,
  eiConstants,
  eiExceptions,
  eiProtocol,
  eiHelpers,
  eiChannel,
  eiClient,
  TestFramework,
  TestExtensions;

type
  TClientTest = class(TTestCase)
  private
    FClient: IEasyIpClient;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
  published
    procedure TestBlockRead;
    procedure TestBlockWrite;
    procedure LifeCycleTest;
    procedure TestBitOperation;
    procedure TestInfoRead;
    procedure TestReadWrite;
    procedure TestWordReadWrite;
  end;

implementation

uses
  TestConstants;

procedure TClientTest.LifeCycleTest;
var
  ic: TEasyIpClient;
begin
  ;
  ic := TEasyIpClient.Create(nil);
  ic.Host := TEST_PLC_HOST;
  //ic := nil;
  ic.free
end;

{ TClientTest }

procedure TClientTest.SetUp;
begin
  inherited;
  FClient := TEasyIpClient.Create(nil);
  FClient.Host := TEST_PLC_HOST;
end;

procedure TClientTest.TearDown;
begin
  inherited;
  FClient := nil;
end;

procedure TClientTest.TestBitOperation;
var
  writed: DynamicWordArray;
  readed: DynamicWordArray;
  i: int;
const
  VALUE = $FF00; //1
  MASKAND = $F000; //2
  MASKOR = $0F0F; //3
  MASKXOR = $FF00; //4
  exAND = $F000;
  exOR = $FF0F;
  exXOR = $000F;
begin
  SetLength(writed, 1);
  for i := 0 to 1 - 1 do
    writed[i] := VALUE;
  FClient.BlockWrite(TEST_OFFSET, writed, dtFlag);

  FClient.BitOperation(TEST_OFFSET, dtFlag, MASKAND, bmAnd);
  readed := FClient.BlockRead(TEST_OFFSET, dtFlag, 1);
  Check(readed[0] = exAND);

  FClient.BitOperation(TEST_OFFSET, dtFlag, MASKOR, bmOr);
  readed := FClient.BlockRead(TEST_OFFSET, dtFlag, 1);
  Check(readed[0] = exOR);

  FClient.BitOperation(TEST_OFFSET, dtFlag, MASKXOR, bmXor);
  readed := FClient.BlockRead(TEST_OFFSET, dtFlag, 1);
  Check(readed[0] = exXOR);
end;

procedure TClientTest.TestBlockRead;
var
  data: DynamicWordArray;
begin
  data := FClient.BlockRead(TEST_OFFSET, dtFlag, TEST_LENGTH);
  Check(data <> nil);
  Check(Length(data) > 0);
  Check(Length(data) = TEST_LENGTH);
end;

procedure TClientTest.TestBlockWrite;
var
  values: DynamicWordArray;
  i: int;
begin
  SetLength(values, TEST_LENGTH);
  for i := 0 to TEST_LENGTH - 1 do
    values[i] := i + 1;
  FClient.BlockWrite(TEST_OFFSET, values, dtFlag);
end;

procedure TClientTest.TestInfoRead;
var
  data: EasyIpInfoPacket;
begin
  data := FClient.InfoRead();
  Check(data.InformationType = 1);
end;

procedure TClientTest.TestReadWrite;
var
  writed: DynamicWordArray;
  readed: DynamicWordArray;
  i: int;
begin
  SetLength(writed, TEST_LENGTH);
  Randomize;
  for i := 0 to TEST_LENGTH - 1 do
    writed[i] := i + Random(10000);
  FClient.BlockWrite(TEST_OFFSET, writed, dtFlag);
  readed := FClient.BlockRead(TEST_OFFSET, dtFlag, TEST_LENGTH);
  for i := 0 to TEST_LENGTH - 1 do
    Check(writed[i] = readed[i]);
  for i := 0 to TEST_LENGTH - 1 do
    writed[i] := 0;
  FClient.BlockWrite(TEST_OFFSET, writed, dtFlag);
end;

procedure TClientTest.TestWordReadWrite;
var
  readed: short;
  writed: short;
begin
  Randomize;
  writed := Random(10000);
  FClient.WordWrite(TEST_OFFSET, writed, dtFlag);
  readed:= 0;
  readed := FClient.WordRead(TEST_OFFSET, dtFlag);
  Check(readed = writed);
end;

initialization
  TestFramework.RegisterTest(TRepeatedTest.Create(TClientTest.Suite, 2));

end.

