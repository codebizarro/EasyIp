program EasyIpServer;
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  UEasyIpServer in 'Sources\UEasyIpServer.pas',
  UServerTypes in 'Sources\UServerTypes.pas',
  ULogger in 'Sources\ULogger.pas';

procedure Main();
var
  server: IEasyIpServer;
begin
  server := TEasyIpServer.Create();
  server.Run();
  server := nil;
  Sleep(1000);
end;

begin
  Main();
end.

