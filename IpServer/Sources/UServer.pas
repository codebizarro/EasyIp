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
//    FDiscoverThread: TDiscoverResponseThread;
    constructor Create; overload;
    procedure OnEasyIpRequest(Sender: TObject; request: RequestStruct);
    procedure OnEchoRequest(Sender: TObject; request: RequestStruct);
    procedure OnChargenRequest(Sender: TObject; request: RequestStruct);
  public
    constructor Create(logger: ILogger); overload;
    destructor Destroy; override;
    procedure Run;
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
  FEasyIpListener.Cancel;
//  FDiscoverThread.Cancel;
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
  FLogger.Log('OnEasyIpRequest occured');
  request.Dispather := TEchoPacketDispatcher.Create(FLogger);
  with TUdpResponseThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.Run;
begin
  FEasyIpListener := TUdpListenThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEchoListener := TUdpListenThread.Create(FLogger, 7);
  FEchoListener.OnReceive := OnEchoRequest;
  FChargenListener := TUdpListenThread.Create(FLogger, 19);
  FChargenListener.OnReceive := OnChargenRequest;

  FEasyIpListener.Resume();
  FEchoListener.Resume();
  FChargenListener.Resume();

//  FDiscoverThread := TDiscoverResponseThread.Create(FLogger);
//  FDiscoverThread.Resume();
end;

end.

