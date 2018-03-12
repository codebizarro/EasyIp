program EasyIpServer;
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  UEasyIpServer in 'Sources\UEasyIpServer.pas',
  UServerTypes in 'Sources\UServerTypes.pas',
  ULogger in 'Sources\ULogger.pas',
  UPacketDispatcher in 'Sources\UPacketDispatcher.pas',
  UDevices in 'Sources\UDevices.pas',
  UDiscoverResponseThread in 'Sources\UDiscoverResponseThread.pas',
  UBaseThread in 'Sources\UBaseThread.pas',
  UListenThread in 'Sources\UListenThread.pas',
  UResponseThread in 'Sources\UResponseThread.pas';

procedure Main();
var
  server: IEasyIpServer;
begin
  SetConsoleTitle('EasyIp Server');
  server := TEasyIpServer.Create();
//  with DiscoverResponseThread.Create() do
//    Resume();
  server.Run();
  server := nil;
  Sleep(1000);
end;

begin
  Main();
end.

