unit eiClient;

interface

uses
  eiTypes,
  eiConstants,
  eiExceptions,
  eiProtocol,
  eiHelpers,
  eiChannel,
  Classes,
  SysUtils,
  Windows;

type
  TEasyIpClient = class(TCustomClient, IEasyIpClient)
  private
    FChannel: IEasyIpChannel;
    FOnException: TExceptionEvent;
    FProtocol: IEasyIpProtocol;
    function DispatchException(E: Exception): bool;
    function GetChannel: IEasyIpChannel;
    function GetHost: string;
    function GetPort: int;
    function GetProtocol: IEasyIpProtocol;
    function GetTimeout: int;
    procedure InitInterfaces(const _host: string);
    procedure SetDebug(const value: string);
    procedure SetHost(const value: string);
    procedure SetPort(const value: int);
    procedure SetTimeout(const value: int);
    property Channel: IEasyIpChannel read GetChannel;
    property Debug: string write SetDebug;
    property Protocol: IEasyIpProtocol read GetProtocol;
  public
    constructor Create(const _host: string); reintroduce; overload;
    constructor Create(AOwner: TComponent); overload; override;
    destructor Destroy; override;
    procedure BitOperation(const offset: short; const dataType: DataTypeEnum; const mask: ushort; const bitMode: BitModeEnum);
    function BlockRead(const offset: short; const dataType: DataTypeEnum; const length: byte): DynamicWordArray;
    procedure BlockWrite(const offset: short; const value: DynamicWordArray; const dataType: DataTypeEnum);
    function WordRead(const offset: short; const dataType: DataTypeEnum): short;
    procedure WordWrite(const offset: short; const value: short; const dataType: DataTypeEnum);
    function InfoRead: EasyIpInfoPacket;
  published
    property Host: string read GetHost write SetHost;
    property Port: int read GetPort write SetPort default EASYIP_PORT;
    property Timeout: int read GetTimeout write SetTimeout default CHANNEL_DEFAULT_TIMEOUT;
    property OnException: TExceptionEvent read FOnException write FOnException;
  end;

procedure Register();

implementation

procedure Register();
begin
  RegisterComponents('AESoft', [TEasyIpClient]);
end;

constructor TEasyIpClient.Create(const _host: string);
begin
  inherited Create(nil);
  Debug := Format(DEBUG_MESSAGE_CREATE, [ClassName]);
  InitInterfaces(_host);
end;

constructor TEasyIpClient.Create(AOwner: TComponent);
begin
  inherited;
  Debug := Format(DEBUG_MESSAGE_CREATE, [ClassName]);
  InitInterfaces('');
end;

destructor TEasyIpClient.Destroy;
begin
  inherited;
  FChannel := nil;
  FProtocol := nil;
  Debug := Format(DEBUG_MESSAGE_DESTROY, [ClassName]);
end;

procedure TEasyIpClient.BitOperation(const offset: short; const dataType: DataTypeEnum; const mask: ushort; const bitMode: BitModeEnum);
var
  sendedPacket: EasyIpPacket;
  returnedPacket: EasyIpPacket;
  arrayLength: int;
  dataLength: int;
begin
  dataLength := 1;
  Protocol.Mode := pmBit;
  Protocol.BitMode := bitMode;
  Protocol.DataOffset := offset;
  Protocol.DataType := dataType;
  Protocol.DataLength := dataLength;
  sendedPacket := Protocol.Packet;

  arrayLength := dataLength * SHORT_SIZE;

  CopyMemory(@sendedPacket.Data, @mask, arrayLength);
  try
    returnedPacket := Channel.Execute(sendedPacket);
  except
    on E: Exception do
      if DispatchException(E) then
        raise;
  end;
end;

function TEasyIpClient.BlockRead(const offset: short; const dataType: DataTypeEnum; const length: byte): DynamicWordArray;
var
  returnedPacket: EasyIpPacket;
  returnArray: DynamicWordArray;
  arrayLength: int;
begin
  Protocol.Mode := pmRead;
  Protocol.DataOffset := offset;
  Protocol.DataType := dataType;
  Protocol.DataLength := length;
  try
    returnedPacket := Channel.Execute(Protocol.Packet);
  except
    on E: Exception do
      if DispatchException(E) then
        raise;
  end;
  arrayLength := returnedPacket.RequestDataSize * SHORT_SIZE;
  SetLength(returnArray, length);
  CopyMemory(returnArray, @returnedPacket.Data, arrayLength);
  Result := returnArray;
end;

procedure TEasyIpClient.BlockWrite(const offset: short; const value: DynamicWordArray; const dataType: DataTypeEnum);
var
  sendedPacket: EasyIpPacket;
  returnedPacket: EasyIpPacket;
  arrayLength: int;
  dataLength: int;
begin
  dataLength := length(value);
  Protocol.Mode := pmWrite;
  Protocol.DataOffset := offset;
  Protocol.DataType := dataType;
  Protocol.DataLength := dataLength;
  sendedPacket := Protocol.Packet;

  arrayLength := dataLength * SHORT_SIZE;

  CopyMemory(@sendedPacket.Data, value, arrayLength);
  try
    returnedPacket := Channel.Execute(sendedPacket);
  except
    on E: Exception do
      if DispatchException(E) then
        raise;
  end;
end;

function TEasyIpClient.DispatchException(E: Exception): bool;
begin
  Debug := E.Message;
  if Assigned(FOnException) then
  begin
    FOnException(Self, E);
    Result := False;
  end
  else
    Result := True;
end;

function TEasyIpClient.GetChannel: IEasyIpChannel;
begin
  Result := FChannel;
end;

function TEasyIpClient.GetHost: string;
begin
  Result := Channel.Host;
end;

function TEasyIpClient.GetPort: int;
begin
  Result := Channel.Port;
end;

function TEasyIpClient.GetProtocol: IEasyIpProtocol;
begin
  Result := FProtocol;
end;

function TEasyIpClient.GetTimeout: int;
begin
  Result := Channel.Timeout;
end;

function TEasyIpClient.InfoRead: EasyIpInfoPacket;
var
  returnedPacket: EasyIpPacket;
  returnPacket: EasyIpInfoPacket;
begin
  Protocol.Mode := pmInfo;
  try
    returnedPacket := Channel.Execute(Protocol.Packet);
  except
    on E: Exception do
      if DispatchException(E) then
        raise;
  end;
  returnPacket := TPacketAdapter.ToEasyIpInfoPacket(returnedPacket);
  Result := returnPacket;
end;

procedure TEasyIpClient.InitInterfaces(const _host: string);
begin
  FChannel := TEasyIpChannel.Create(_host, EASYIP_PORT);
  FProtocol := TEasyIpProtocol.Create();
end;

procedure TEasyIpClient.SetDebug(const value: string);
begin
  OutputDebugString(PChar(value));
end;

procedure TEasyIpClient.SetHost(const value: string);
begin
  Channel.Host := value;
end;

procedure TEasyIpClient.SetPort(const value: int);
begin
  Channel.Port := value;
end;

procedure TEasyIpClient.SetTimeout(const value: int);
begin
  Channel.Timeout := value;
end;

function TEasyIpClient.WordRead(const offset: short; const dataType: DataTypeEnum): short;
var
  readed: DynamicWordArray;
begin
  readed := BlockRead(offset, dataType, 1);
  Result := readed[0];
end;

procedure TEasyIpClient.WordWrite(const offset, value: short; const dataType: DataTypeEnum);
var
  writed: DynamicWordArray;
begin
  SetLength(writed, 1);
  writed[0] := value;
  BlockWrite(offset, writed, dataType);
end;

end.

