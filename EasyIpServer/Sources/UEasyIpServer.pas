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
  ULogger;

type
  TEasyIpServer = class(TInterfacedObject, IEasyIpServer)
  private
    FLogger: ILogger;
    FSocket: TSocket;
    FTarget: TSockAddrIn;
    function GetLastErrorString: string;
  public
    constructor Create; overload;
    constructor Create(logger: ILogger); overload;
    destructor Destroy; override;
    procedure Run;
  end;

implementation

constructor TEasyIpServer.Create;
begin
  Create(TDefaultLogger.Create());
end;

constructor TEasyIpServer.Create(logger: ILogger);
var
  code: int;
  init: TWSAData;
begin
  inherited Create();
  FLogger := logger;
  FLogger.Log('Starting server...');
  code := WSAStartup(WINSOCK_VERSION, init);
  if code <> 0 then
    raise ESocketException.Create(GetLastErrorString());
  FSocket := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if FSocket < 0 then
    raise ESocketException.Create(GetLastErrorString());
  ZeroMemory(@FTarget, SizeOf(TSockAddrIn));
  FTarget.sin_family := AF_INET;
  FTarget.sin_port := htons(EASYIP_PORT);
  FTarget.sin_addr.s_addr := INADDR_ANY;
  code := bind(FSocket, FTarget, SizeOf(FTarget));
  if code < 0 then
    raise ESocketException.Create(GetLastErrorString());
end;

destructor TEasyIpServer.Destroy;
begin
  FLogger.Log('Stopping server...');
  closesocket(FSocket);
  WSACleanup();
  inherited;
end;

function TEasyIpServer.GetLastErrorString: string;
var
  Buffer: array[0..2047] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, WSAGetLastError, LANG_ID, @Buffer, SizeOf(Buffer), nil);
  Result := Buffer;
end;

procedure TEasyIpServer.Run;
var
  code: int;
  sendBuffer: DynamicByteArray;
  recvBuffer: DynamicByteArray;
  lenFrom: int;
begin
  while true do
  begin
    try
      SetLength(recvBuffer, High(short));
      lenFrom := SizeOf(FTarget);
      code := recvfrom(FSocket, Pointer(recvBuffer)^, Length(recvBuffer), 0, FTarget, lenFrom);
      if (code = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());
      FLogger.Log('Data length ' + IntToStr(code));
    except
      on Ex: Exception do
        FLogger.Log(Ex.Message);
    end;
  end;
end;



end.

