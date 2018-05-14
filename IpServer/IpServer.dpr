program EasyIpServer;
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  UServer in 'Sources\UServer.pas',
  UServerTypes in 'Sources\UServerTypes.pas',
  ULogger in 'Sources\ULogger.pas',
  UPacketHandlers in 'Sources\UPacketHandlers.pas',
  UDevices in 'Sources\UDevices.pas',
  UBaseThread in 'Sources\UBaseThread.pas',
  UListenThread in 'Sources\UListenThread.pas',
  UResponseThread in 'Sources\UResponseThread.pas',
  UListenTcpThread in 'Sources\UListenTcpThread.pas',
  UResponseTcpThread in 'Sources\UResponseTcpThread.pas';

procedure Main();
var
  server: IServer;
  buffer: string;
  logger: ILogger;
begin
  SetConsoleTitle('Ip Server');
  {$IFDEF DEBUG}
  logger := TConsoleLogger.Create();
  {$ELSE}
  logger := TStubLogger.Create();
  {$ENDIF}
  logger.Log('Type q and press Enter for exit', elNotice);
  server := TServer.Create(logger);
  server.Start();
  repeat
    ReadLn(buffer);
    if buffer = 'q' then
      Break;
  until false;
  server := nil;
  logger := nil;
//  Sleep(10000);
end;

begin
  Main();
end.

