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
  end;

implementation

uses
  TestConstants;

procedure TClientTest.LifeCycleTest;
var
  ic: TEasyIpClient;
begin
;  ic := TEasyIpClient.Create(nil);
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

initialization
  TestFramework.RegisterTest(TRepeatedTest.Create(TClientTest.Suite, 2));

end.

