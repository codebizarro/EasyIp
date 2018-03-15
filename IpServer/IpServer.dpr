program EasyIpServer;
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  UServer in 'Sources\UServer.pas',
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
  server: IServer;
  buffer: string;
  logger: ILogger;
begin
  SetConsoleTitle('EasyIp Server');
  {$IFDEF DEBUG}
  logger := TConsoleLogger.Create();
  {$ELSE}
  logger := TStubLogger.Create();
  {$ENDIF}
  Writeln('Type q and press Enter for exit');
  server := TServer.Create(logger);
  server.Run();
  repeat
    ReadLn(buffer);
    if buffer = 'q' then
      Break;
  until false;
  server := nil;
//  Sleep(10000);
end;

begin
  Main();
end.

