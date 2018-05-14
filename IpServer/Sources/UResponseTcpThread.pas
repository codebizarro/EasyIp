unit UResponseTcpThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WinSock,
  eiTypes,
  eiConstants,
  eiExceptions,
  UServerTypes,
  UBaseThread,
  UPacketHandlers;

type
  TResponseTcpThread = class(TBaseSocketThread)
  private
    FClientAddr: TSockAddrIn;
    FHandler: IHandler;
    FBuffer: DynamicByteArray;
  public
    constructor Create(logger: ILogger; const request: RequestStruct);
    destructor Destroy; override;
    procedure Execute; override;
  end;

implementation

constructor TResponseTcpThread.Create(logger: ILogger; const request: RequestStruct);
var
  code: int;
  bufferLength: int;
begin
  inherited Create(true);
  FLogger := logger;
  try
    ZeroMemory(@FClientAddr, SizeOf(TSockAddrIn));
    CopyMemory(@FClientAddr, @request.Target, SizeOf(TSockAddrIn));
    FHandler := request.Handler;
    FSocket := request.Socket;
    if FSocket = INVALID_SOCKET then
      raise ESocketException.Create(GetLastErrorString());

    FLogger.Log('Response thread created', elNotice);
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message, elError);
  end;
end;

destructor TResponseTcpThread.Destroy;
begin
  FLogger.Log('Response thread destroyed');
  inherited;
end;

procedure TResponseTcpThread.Execute;
var
  recvLength: int;
  recvBuffer: DynamicByteArray;
  returnLength: int;
  sendBuffer: DynamicByteArray;
begin
  try
    SetLength(recvBuffer, High(short));
    while (true) do
    begin
      recvLength := recv(FSocket, Pointer(recvBuffer)^, Length(recvBuffer), 0);
      if recvLength = 0 then
        Break;
      if recvLength = SOCKET_ERROR then
        raise ESocketException.Create(GetLastErrorString());
      if recvLength > 0 then
      begin
        SetLength(recvBuffer, recvLength);
        sendBuffer := FHandler.Process(recvBuffer);
        returnLength := send(FSocket, Pointer(sendBuffer)^, Length(sendBuffer), 0);
        if (returnLength = SOCKET_ERROR) then
          raise ESocketException.Create(GetLastErrorString());
        FLogger.Log('Outbound data length ' + IntToStr(returnLength));
      end;
    end;
  except
    on Ex: Exception do
      FLogger.Log(Ex.Message, elError);
  end;
  closesocket(FSocket);
  FLogger.Log('To ' + inet_ntoa(FClientAddr.sin_addr) + ' : ' + IntToStr(FClientAddr.sin_port));
end;

end.

