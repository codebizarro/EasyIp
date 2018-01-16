program Tests;

uses
  SysUtils,
  Forms,
  TestFrameWork,
  GUITestRunner,
  ChannelTests in 'Source\ChannelTests.pas',
  ClientTests in 'Source\ClientTests.pas',
  UnitTests in 'Source\UnitTests.pas',
  PacketWrapperTests in 'Source\PacketWrapperTests.pas',
  StopWatch in 'Source\StopWatch.pas',
  TestConstants in 'Source\TestConstants.pas';

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.

