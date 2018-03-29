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
  UPacketHandlers,
  UDiscoverResponseThread,
  UDevices;

type
  TServer = class(TInterfacedObject, IServer)
  private
    FChargenListener: TUdpListenThread;
    FCommandListener: TUdpListenThread;
    FDaytimeListener: TUdpListenThread;
    FEasyIpDevice: IDevice;
    FEasyIpListener: TUdpListenThread;
    FEchoListener: TUdpListenThread;
    FLogger: ILogger;
    FSearchListener: TUdpListenThread;
//    FDiscoverThread: TDiscoverResponseThread;
    constructor Create; overload;
    procedure OnChargenRequest(Sender: TObject; request: RequestStruct);
    procedure OnCommandRequest(Sender: TObject; request: RequestStruct);
    procedure OnDaytimeRequest(Sender: TObject; request: RequestStruct);
    procedure OnEasyIpRequest(Sender: TObject; request: RequestStruct);
    procedure OnEchoRequest(Sender: TObject; request: RequestStruct);
    procedure OnSearchRequest(Sender: TObject; request: RequestStruct);
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
  FEasyIpDevice := TEasyIpDevice.Create(logger);
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
  request.Handler := TChargenHandler.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnCommandRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnCommandRequest occured');
  request.Handler := TCommandHandler.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnDaytimeRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnDaytimeRequest occured');
  request.Handler := TDaytimeHandler.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEasyIpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEasyIpRequest occured');
  request.Handler := TEasyIpHandler.Create(FLogger, FEasyIpDevice);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEchoRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEchoRequest occured');
  request.Handler := TEchoHandler.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnSearchRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnSearchRequest occured');
  request.Handler := TSearchHandler.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.Start;
const
  ECHO_PORT = 7;
  CHARGEN_PORT = 19;
  DAYTIME_PORT = 13;
  SEARCH_PORT = 990;
  COMMAND_PORT = 991;
begin
  FEasyIpListener := TUdpListenThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEchoListener := TUdpListenThread.Create(FLogger, ECHO_PORT);
  FEchoListener.OnReceive := OnEchoRequest;
  FChargenListener := TUdpListenThread.Create(FLogger, CHARGEN_PORT);
  FChargenListener.OnReceive := OnChargenRequest;
  FDaytimeListener := TUdpListenThread.Create(FLogger, DAYTIME_PORT);
  FDaytimeListener.OnReceive := OnDaytimeRequest;
  FSearchListener := TUdpListenThread.Create(FLogger, SEARCH_PORT);
  FSearchListener.OnReceive := OnSearchRequest;
  FCommandListener := TUdpListenThread.Create(FLogger, COMMAND_PORT);
  FCommandListener.OnReceive := OnCommandRequest;

  FEasyIpListener.Resume();
  FEchoListener.Resume();
  FChargenListener.Resume();
  FDaytimeListener.Resume();
  FSearchListener.Resume();
  FCommandListener.Resume();
end;

procedure TServer.Stop;
begin
  FEasyIpListener.Cancel;
  FEchoListener.Cancel;
  FChargenListener.Cancel;
  FDaytimeListener.Cancel;
  FSearchListener.Cancel;
  FCommandListener.Cancel;
//  FDiscoverThread.Cancel;
end;

end.

