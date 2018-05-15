unit UMain;

interface

uses
  Windows,
  ULogger,
  UServer,
  UServerTypes;

type
  TProgram = class
    class procedure Main();
  end;

implementation

class procedure TProgram.Main;
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
end;

end.

