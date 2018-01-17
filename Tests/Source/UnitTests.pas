unit UnitTests;

interface

uses
  SysUtils,
  Classes,
  eiTypes,
  eiConstants,
  eiProtocol,
  eiHelpers,
  TestFramework,
  TestExtensions,
  StopWatch,
  Windows;

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

  TStopWatchTest = class(TTestCase)
  private
    FStopWatch: IStopWatch;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
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

{ TStopWatchTest }

procedure TStopWatchTest.SetUp;
begin
  inherited;
  FStopWatch := TStopWatch.Create;
end;

procedure TStopWatchTest.TearDown;
begin
  inherited;
  FStopWatch := nil;
end;

procedure TStopWatchTest.TestRun;
const
  startSleepTime = 1;
  multiplier = 2;
  stopSleepTime = 500;
var
  delta: int;
  sleepValue: int;
begin
  sleepValue := startSleepTime;
  while (sleepValue < stopSleepTime) do
  begin
    FStopWatch.Start;
    Sleep(sleepValue);
    FStopWatch.Stop;
    delta := FStopWatch.ElapsedMilliseconds - sleepValue;
    OutputDebugString(PChar(FStopWatch.Elapsed));
    Check(Abs(delta) < 15);
//    OutputDebugString(PChar('delta ' + IntToStr(delta)));
    sleepValue := sleepValue * multiplier;
  end;
end;

initialization
  TestFramework.RegisterTest(TPacketFactoryTest.Suite);
  TestFramework.RegisterTest(TRepeatedTest.Create(TStopWatchTest.Suite, 2));

end.

