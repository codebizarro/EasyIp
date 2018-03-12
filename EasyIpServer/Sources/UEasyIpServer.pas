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
  UListenThread;

type
  TEasyIpServer = class(TInterfacedObject, IEasyIpServer)
  private
    FLogger: ILogger;
  public
    constructor Create; overload;
    constructor Create(logger: ILogger); overload;
    destructor Destroy; override;
    procedure Run;
  end;

implementation

constructor TEasyIpServer.Create;
begin
  Create(TConsoleLogger.Create());
  //Create(TDebugLogger.Create());
end;

constructor TEasyIpServer.Create(logger: ILogger);
begin
  inherited Create();
  FLogger := logger;
  FLogger.Log('Starting server...', '%s');
end;

destructor TEasyIpServer.Destroy;
var
  shutResult: int;
begin
  FLogger.Log('Stopping server...');
  inherited;
end;

procedure TEasyIpServer.Run;
//var
//  returnLength: int;
//  sendBuffer: DynamicByteArray;
//  recvBuffer: DynamicByteArray;
//  len: int;
begin
  with TListenSocketThread.Create() do
    Resume;
  Sleep(100000000);
  {
  if FStarted then
    while true do
    begin
      try
        SetLength(recvBuffer, High(short));
        len := SizeOf(FClientAddr);
        returnLength := recvfrom(FSocket, Pointer(recvBuffer)^, Length(recvBuffer), 0, FClientAddr, len);
        if (returnLength = SOCKET_ERROR) then
          raise ESocketException.Create(GetLastErrorString());
        SetLength(recvBuffer, returnLength);
        FLogger.Log('Inbound data length ' + IntToStr(returnLength));
        FLogger.Log('From ' + inet_ntoa(FClientAddr.sin_addr));

        sendBuffer := FPacketDispatcher.Process(recvBuffer);

        returnLength := sendto(FSocket, Pointer(sendBuffer)^, Length(sendBuffer), 0, FClientAddr, len);
        if (returnLength = SOCKET_ERROR) then
          raise ESocketException.Create(GetLastErrorString());
        FLogger.Log('Outbound data length ' + IntToStr(returnLength));
        FLogger.Log('To ' + inet_ntoa(FClientAddr.sin_addr));
      except
        on Ex: Exception do
          FLogger.Log(Ex.Message);
      end;
    end;
    }
end;

end.

