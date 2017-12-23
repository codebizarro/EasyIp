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
  published
    procedure TestBlockRead;
    procedure TestBlockWrite;
  end;

implementation

{ TClientTest }

procedure TClientTest.SetUp;
begin
  inherited;
  FClient := TEasyIpClient.Create();
end;

procedure TClientTest.TearDown;
begin
  inherited;
  FClient := nil;
end;

procedure TClientTest.TestBlockRead;
begin

end;

procedure TClientTest.TestBlockWrite;
begin

end;

initialization
  TestFramework.RegisterTest(TRepeatedTest.Create(TClientTest.Suite, 1));

end.

