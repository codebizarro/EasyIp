program Tests;

uses
  Windows,
  SysUtils,
  Forms,
  Controls,
  TestFrameWork,
  GUITestRunner,
  ChannelTests in 'Source\ChannelTests.pas',
  ClientTests in 'Source\ClientTests.pas',
  UnitTests in 'Source\UnitTests.pas',
  PacketWrapperTests in 'Source\PacketWrapperTests.pas',
  StopWatch in 'Source\StopWatch.pas',
  TestConstants in 'Source\TestConstants.pas',
  UTestParams in 'Source\UTestParams.pas';

procedure main();
var
  testParams: TTestParams;
begin
  Application.Initialize;
  testParams := TTestParams.Create(Application);
  if testParams.ShowModal = mrOK then
  begin
    TEST_PLC_HOST := testParams.SelectedAddress;
  end;
  GUITestRunner.RunRegisteredTests;
end;

begin
  main();
end.

