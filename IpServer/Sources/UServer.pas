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
  UDiscoverResponseThread;

type
  TServer = class(TInterfacedObject, IEasyIpServer)
  private
    FLogger: ILogger;
    FEasyIpListener: TListenSocketThread;
//    FDiscoverThread: TDiscoverResponseThread;
    constructor Create; overload;
    procedure OnEasyIpRequest(Sender: TObject; target: TSockAddrIn; buffer: DynamicByteArray);
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
begin
  FLogger.Log('OnEasyIpRequest occured');
  with TResponseSocketThread.Create(FLogger, target, buffer) do
    Resume;
end;

procedure TServer.Run;
begin
  FEasyIpListener := TListenSocketThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEasyIpListener.Resume();

//  FDiscoverThread := TDiscoverResponseThread.Create(FLogger);
//  FDiscoverThread.Resume();
end;

end.

