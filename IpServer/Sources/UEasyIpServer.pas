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
  UResponseThread,
  UDiscoverResponseThread;

type
  TEasyIpServer = class(TInterfacedObject, IEasyIpServer)
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
  FEasyIpListener.Cancel;
//  FDiscoverThread.Cancel;
  inherited;
end;

procedure TEasyIpServer.OnEasyIpRequest(Sender: TObject; target: TSockAddrIn; buffer: DynamicByteArray);
begin
  FLogger.Log('OnEasyIpRequest occured');
  with TResponseSocketThread.Create(FLogger, target, buffer) do
    Resume;
end;

procedure TEasyIpServer.Run;
begin
  FEasyIpListener := TListenSocketThread.Create(FLogger, EASYIP_PORT);
  FEasyIpListener.OnReceive := OnEasyIpRequest;
  FEasyIpListener.Resume();

//  FDiscoverThread := TDiscoverResponseThread.Create(FLogger);
//  FDiscoverThread.Resume();
end;

end.

