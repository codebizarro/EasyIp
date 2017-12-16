program Tests;

uses
  SysUtils,
  Forms,
  TestFrameWork,
  GUITestRunner,
  ChannelTests in 'Source\ChannelTests.pas',
  ClientTests in 'Source\ClientTests.pas',
  UnitTests in 'Source\UnitTests.pas',
  PacketWrapperTests in 'Source\PacketWrapperTests.pas';

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.

