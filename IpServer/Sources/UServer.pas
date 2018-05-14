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
    FChargenTcpListener: TListenTcpThread;
    FChargenUdpListener: TListenUdpThread;
    FCommandUdpListener: TListenUdpThread;
    FDaytimeTcpListener: TListenTcpThread;
    FDaytimeUdpListener: TListenUdpThread;
    FEasyIpDevice: IDevice;
    FEasyIpListener: TListenUdpThread;
    FEchoTcpListener: TListenTcpThread;
    FEchoUdpListener: TListenUdpThread;
    FLogger: ILogger;
    FSearchListener: TListenUdpThread;
    constructor Create; overload;
    procedure OnChargenTcpRequest(Sender: TObject; request: RequestStruct);
    procedure OnChargenUdpRequest(Sender: TObject; request: RequestStruct);
    procedure OnCommandUdpRequest(Sender: TObject; request: RequestStruct);
    procedure OnDaytimeTcpRequest(Sender: TObject; request: RequestStruct);
    procedure OnDaytimeUdpRequest(Sender: TObject; request: RequestStruct);
    procedure OnEasyIpRequest(Sender: TObject; request: RequestStruct);
    procedure OnEchoTcpRequest(Sender: TObject; request: RequestStruct);
    procedure OnEchoUdpRequest(Sender: TObject; request: RequestStruct);
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

procedure TServer.OnChargenTcpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnChargenTcpRequest occured');
  request.Handler := TChargenHandler.Create(FLogger);
  with TResponseTcpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnChargenUdpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnChargenUdpRequest occured');
  request.Handler := TChargenHandler.Create(FLogger);
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnCommandUdpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnCommandUdpRequest occured');
  request.Handler := TCommandHandler.Create(FLogger);
  with TResponseUdpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnDaytimeTcpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnDaytimeTcpRequest occured');
  request.Handler := TDaytimeHandler.Create(FLogger);
  with TResponseTcpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnDaytimeUdpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnDaytimeUdpRequest occured');
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

procedure TServer.OnEchoTcpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEchoTcpRequest occured');
  request.Handler := TEchoHandler.Create(FLogger);
  with TResponseTcpThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEchoUdpRequest(Sender: TObject; request: RequestStruct);
begin
  FLogger.Log('OnEchoUdpRequest occured');
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

procedure TServer.Start;
const
  ECHO_PORT = 7;
  CHARGEN_PORT = 19;
  DAYTIME_PORT = 13;
  SEARCH_PORT = 990;
  COMMAND_PORT = 991;
begin
  FChargenTcpListener := TListenTcpThread.Create(FLogger, CHARGEN_PORT);
  FChargenTcpListener.OnReceive := OnChargenTcpRequest;
  FChargenTcpListener.Resume();
  FChargenUdpListener := TListenUdpThread.Create(FLogger, CHARGEN_PORT);
  FChargenUdpListener.OnReceive := OnChargenUdpRequest;
  FChargenUdpListener.Resume();
  FCommandUdpListener := TListenUdpThread.Create(FLogger, COMMAND_PORT);
  FCommandUdpListener.OnReceive := OnCommandUdpRequest;
  FCommandUdpListener.Resume();
  FDaytimeTcpListener := TListenTcpThread.Create(FLogger, DAYTIME_PORT);
  FDaytimeTcpListener.OnReceive := OnDaytimeTcpRequest;
  FDaytimeTcpListener.Resume();
  FDaytimeUdpListener := TListenUdpThread.Create(FLogger, DAYTIME_PORT);
  FDaytimeUdpListener.OnReceive := OnDaytimeUdpRequest;
  FDaytimeUdpListener.Resume();
  FEasyIpListener := TListenUdpThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEasyIpListener.Resume();
  FEchoTcpListener := TListenTcpThread.Create(FLogger, ECHO_PORT);
  FEchoTcpListener.OnReceive := OnEchoTcpRequest;
  FEchoTcpListener.Resume();
  FEchoUdpListener := TListenUdpThread.Create(FLogger, ECHO_PORT);
  FEchoUdpListener.OnReceive := OnEchoUdpRequest;
  FEchoUdpListener.Resume();
  FSearchListener := TListenUdpThread.Create(FLogger, SEARCH_PORT);
  FSearchListener.OnReceive := OnSearchRequest;
  FSearchListener.Resume();
end;

procedure TServer.Stop;
begin
  FChargenTcpListener.Cancel();
  FChargenUdpListener.Cancel();
  FCommandUdpListener.Cancel();
  FDaytimeTcpListener.Cancel();
  FDaytimeUdpListener.Cancel();
  FEasyIpListener.Cancel();
  FEchoTcpListener.Cancel();
  FEchoUdpListener.Cancel();
  FSearchListener.Cancel();
end;

end.

