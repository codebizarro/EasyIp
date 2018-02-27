program EasyIpServer;
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  UEasyIpServer in 'Sources\UEasyIpServer.pas',
  UServerTypes in 'Sources\UServerTypes.pas',
  ULogger in 'Sources\ULogger.pas',
  UPacketDispatcher in 'Sources\UPacketDispatcher.pas',
  UDevices in 'Sources\UDevices.pas';

procedure Main();
var
  server: IEasyIpServer;
begin
  SetConsoleTitle('EasyIp Server');
  server := TEasyIpServer.Create();
  server.Run();
  server := nil;
  Sleep(1000);
end;

begin
  Main();
end.

