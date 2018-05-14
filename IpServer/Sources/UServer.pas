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
  UListenUdpThread,
  UResponseUdpThread,
  UListenTcpThread,
  UResponseTcpThread,
  UPacketHandlers,
  UDevices;

type
  TServer = class(TInterfacedObject, IServer)
  private
    FChargenListener: TListenUdpThread;
    FCommandListener: TListenUdpThread;
    FDaytimeListener: TListenUdpThread;
    FEasyIpDevice: IDevice;
    FEasyIpListener: TListenUdpThread;
    FEchoListener: TListenUdpThread;
    FLogger: ILogger;
    FSearchListener: TListenUdpThread;
    FEchoTcpListener: TListenTcpThread;
    constructor Create; overload;
    procedure OnChargenRequest(Sender: TObject; request: RequestStruct);
    procedure OnCommandRequest(Sender: TObject; request: RequestStruct);
    procedure OnDaytimeRequest(Sender: TObject; request: RequestStruct);
    procedure OnEasyIpRequest(Sender: TObject; request: RequestStruct);
    procedure OnEchoRequest(Sender: TObject; request: RequestStruct);
    procedure OnSearchRequest(Sender: TObject; request: RequestStruct);
    procedure OnTcpEchoRequest(Sender: TObject; request: RequestStruct);
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
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnCommandRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnCommandRequest occured');
  request.Handler := TCommandHandler.Create(FLogger);
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnDaytimeRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnDaytimeRequest occured');
  request.Handler := TDaytimeHandler.Create(FLogger);
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEasyIpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEasyIpRequest occured');
  request.Handler := TEasyIpHandler.Create(FLogger, FEasyIpDevice);
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEchoRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEchoRequest occured');
  request.Handler := TEchoHandler.Create(FLogger);
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnSearchRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnSearchRequest occured');
  request.Handler := TSearchHandler.Create(FLogger);
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnTcpEchoRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnTcpEchoRequest occured');
  request.Handler := TEchoHandler.Create(FLogger);
  with TResponseTcpThread.Create(FLogger, request) do
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
  FEasyIpListener := TListenUdpThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEchoListener := TListenUdpThread.Create(FLogger, ECHO_PORT);
  FEchoListener.OnReceive := OnEchoRequest;
  FChargenListener := TListenUdpThread.Create(FLogger, CHARGEN_PORT);
  FChargenListener.OnReceive := OnChargenRequest;
  FDaytimeListener := TListenUdpThread.Create(FLogger, DAYTIME_PORT);
  FDaytimeListener.OnReceive := OnDaytimeRequest;
  FSearchListener := TListenUdpThread.Create(FLogger, SEARCH_PORT);
  FSearchListener.OnReceive := OnSearchRequest;
  FCommandListener := TListenUdpThread.Create(FLogger, COMMAND_PORT);
  FCommandListener.OnReceive := OnCommandRequest;
  FEchoTcpListener := TListenTcpThread.Create(FLogger, ECHO_PORT);
  FEchoTcpListener.OnReceive := OnTcpEchoRequest;

  FEasyIpListener.Resume();
  FEchoListener.Resume();
  FChargenListener.Resume();
  FDaytimeListener.Resume();
  FSearchListener.Resume();
  FCommandListener.Resume();
  FEchoTcpListener.Resume();
end;

procedure TServer.Stop;
begin
  FEasyIpListener.Cancel;
  FEchoListener.Cancel;
  FChargenListener.Cancel;
  FDaytimeListener.Cancel;
  FSearchListener.Cancel;
  FCommandListener.Cancel;
  FEchoTcpListener.Cancel;
end;

end.

