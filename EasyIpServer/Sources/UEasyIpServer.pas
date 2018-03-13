unit UEasyIpServer;

interface

uses
  Windows,
  SysUtils,
  WinSock,
  eiTypes,
  eiHelpers,
  eiExceptions,
  eiConstants,
  UServerTypes,
  ULogger,
  UListenThread,
  UDiscoverResponseThread;

type
  TEasyIpServer = class(TInterfacedObject, IEasyIpServer)
  private
    FLogger: ILogger;
    FListenThread: TListenSocketThread;
    FDiscoverThread: TDiscoverResponseThread;
    constructor Create; overload;
  public
    constructor Create(logger: ILogger); overload;
    destructor Destroy; override;
    procedure Run;
  end;

implementation

constructor TEasyIpServer.Create;
begin

end;

constructor TEasyIpServer.Create(logger: ILogger);
begin
  inherited Create();
  FLogger := logger;
  FLogger.Log('Starting server...', '%s');
end;

destructor TEasyIpServer.Destroy;
begin
  FLogger.Log('Stopping server...');
  FListenThread.Cancel;
  FDiscoverThread.Cancel;
  inherited;
end;

procedure TEasyIpServer.Run;
begin
  FListenThread := TListenSocketThread.Create(FLogger);
  FListenThread.Resume;

  FDiscoverThread := TDiscoverResponseThread.Create(FLogger);
  FDiscoverThread.Resume();
end;

end.

