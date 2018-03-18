unit UServer;

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
  UResponseThread,
  UPacketDispatcher,
  UDiscoverResponseThread;

type
  TServer = class(TInterfacedObject, IServer)
  private
    FLogger: ILogger;
    FEasyIpListener: TUdpListenThread;
    FEchoListener: TUdpListenThread;
    FChargenListener: TUdpListenThread;
    FDaytimeListener: TUdpListenThread;
//    FDiscoverThread: TDiscoverResponseThread;
    constructor Create; overload;
    procedure OnEasyIpRequest(Sender: TObject; request: RequestStruct);
    procedure OnEchoRequest(Sender: TObject; request: RequestStruct);
    procedure OnChargenRequest(Sender: TObject; request: RequestStruct);
    procedure OnDaytimeRequest(Sender: TObject; request: RequestStruct);
  public
    constructor Create(logger: ILogger); overload;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
  end;

implementation

constructor TServer.Create;
begin

end;

constructor TServer.Create(logger: ILogger);
begin
  inherited Create();
  FLogger := logger;
  FLogger.Log('Starting server...', '%s');
end;

destructor TServer.Destroy;
begin
  FLogger.Log('Stopping server...');
  Stop();
  inherited;
end;

procedure TServer.OnChargenRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnChargenRequest occured');
  request.Dispather := TChargenPacketDispatcher.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEasyIpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEasyIpRequest occured');
  request.Dispather := TEasyIpPacketDispatcher.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEchoRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEchoRequest occured');
  request.Dispather := TEchoPacketDispatcher.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnDaytimeRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnDaytimeRequest occured');
  request.Dispather := TDaytimePacketDispatcher.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.Start;
const
  ECHO_PORT = 7;
  CHARGEN_PORT = 19;
  DAYTIME_PORT = 13;
begin
  FEasyIpListener := TUdpListenThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEchoListener := TUdpListenThread.Create(FLogger, ECHO_PORT);
  FEchoListener.OnReceive := OnEchoRequest;
  FChargenListener := TUdpListenThread.Create(FLogger, CHARGEN_PORT);
  FChargenListener.OnReceive := OnChargenRequest;
  FDaytimeListener := TUdpListenThread.Create(FLogger, DAYTIME_PORT);
  FDaytimeListener.OnReceive := OnDaytimeRequest;

  FEasyIpListener.Resume();
  FEchoListener.Resume();
  FChargenListener.Resume();
  FDaytimeListener.Resume();
end;

procedure TServer.Stop;
begin
  FEasyIpListener.Cancel;
  FEchoListener.Cancel;
  FChargenListener.Cancel;
  FDaytimeListener.Cancel;
//  FDiscoverThread.Cancel;
end;

end.

