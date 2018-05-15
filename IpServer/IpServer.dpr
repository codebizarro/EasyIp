program EasyIpServer;
{$APPTYPE CONSOLE}

uses
  UServer in 'Sources\UServer.pas',
  UServerTypes in 'Sources\UServerTypes.pas',
  ULogger in 'Sources\ULogger.pas',
  UPacketHandlers in 'Sources\UPacketHandlers.pas',
  UDevices in 'Sources\UDevices.pas',
  UBaseThread in 'Sources\UBaseThread.pas',
  UListenUdpThread in 'Sources\UListenUdpThread.pas',
  UResponseUdpThread in 'Sources\UResponseUdpThread.pas',
  UListenTcpThread in 'Sources\UListenTcpThread.pas',
  UResponseTcpThread in 'Sources\UResponseTcpThread.pas',
  UMain in 'Sources\UMain.pas';

begin
  TProgram.Main();
end.

