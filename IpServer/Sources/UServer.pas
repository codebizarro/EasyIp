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
    FEasyIpListener: TListenSocketThread;
    FEchoListener: TListenSocketThread;
//    FDiscoverThread: TDiscoverResponseThread;
    constructor Create; overload;
    procedure OnEasyIpRequest(Sender: TObject; target: TSockAddrIn; buffer: DynamicByteArray);
    procedure OnEchoRequest(Sender: TObject; target: TSockAddrIn; buffer: DynamicByteArray);
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

procedure TServer.OnEasyIpRequest(Sender: TObject; target: TSockAddrIn; buffer: DynamicByteArray);
var
  request: RequestStruct;
begin
  FLogger.Log('OnEasyIpRequest occured');
  request.Target := target;
  request.Buffer := buffer;
  request.Dispather := TEasyIpPacketDispatcher.Create(FLogger);
  with TResponseSocketThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.OnEchoRequest(Sender: TObject; target: TSockAddrIn; buffer: DynamicByteArray);
var
  request: RequestStruct;
begin
  FLogger.Log('OnEasyIpRequest occured');
  request.Target := target;
  request.Buffer := buffer;
  request.Dispather := TEchoPacketDispatcher.Create(FLogger);
  with TResponseSocketThread.Create(FLogger, request) do
    Resume;
end;

procedure TServer.Run;
begin
  FEasyIpListener := TListenSocketThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEchoListener := TListenSocketThread.Create(FLogger, 7);
  FEchoListener.OnReceive := OnEchoRequest;

  FEasyIpListener.Resume();
  FEchoListener.Resume();


//  FDiscoverThread := TDiscoverResponseThread.Create(FLogger);
//  FDiscoverThread.Resume();
end;

end.

