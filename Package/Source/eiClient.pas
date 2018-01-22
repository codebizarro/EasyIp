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
    FProtocol: IEasyIpProtocol;
    function GetChannel: IEasyIpChannel;
    function GetHost: string;
    function GetPort: int;
    function GetProtocol: IEasyIpProtocol;
    procedure InitInterfaces(_host: string);
    procedure SetDebug(const value: string);
    procedure SetHost(const value: string);
    procedure SetPort(const value: int);
    property Channel: IEasyIpChannel read GetChannel;
    property Debug: string write SetDebug;
    property Protocol: IEasyIpProtocol read GetProtocol;
  public
    constructor Create(_host: string); reintroduce; overload;
    constructor Create(AOwner: TComponent); overload; override;
    destructor Destroy; override;
    function InfoRead(): DynamicWordArray;
    function BlockRead(offset: short; dataType: DataTypeEnum; length: byte): DynamicWordArray;
    procedure BlockWrite(offset: short; value: DynamicWordArray; dataType: DataTypeEnum);
  published
    property Host: string read GetHost write SetHost;
    property Port: int read GetPort write SetPort;
  end;

  procedure Register();

implementation

procedure Register();
begin
  RegisterComponents('AESoft', [TEasyIpClient]);
end;

constructor TEasyIpClient.Create(_host: string);
begin
  inherited Create(nil);
  InitInterfaces(_host);
end;

constructor TEasyIpClient.Create(AOwner: TComponent);
begin
  inherited;
  InitInterfaces('127.0.0.1');
end;

destructor TEasyIpClient.Destroy;
begin
  inherited;
  FChannel := nil;
  FProtocol := nil;
  Debug := Format(DEBUG_MESSAGE_DESTROY, [ClassName]);
end;

function TEasyIpClient.BlockRead(offset: short; dataType: DataTypeEnum; length: byte): DynamicWordArray;
var
  returnedPacket: EasyIpPacket;
  returnArray: DynamicWordArray;
  arrayLength: int;
begin
  Protocol.Mode := pmRead;
  Protocol.DataOffset := offset;
  Protocol.DataType := dataType;
  Protocol.DataLength := length;
  returnedPacket := Channel.Execute(Protocol.Packet);
  arrayLength := returnedPacket.RequestDataSize * SHORT_SIZE;
  SetLength(returnArray, length);
  CopyMemory(returnArray, @returnedPacket.Data, arrayLength);
  Result := returnArray;
end;

procedure TEasyIpClient.BlockWrite(offset: short; value: DynamicWordArray; dataType: DataTypeEnum);
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

  returnedPacket := Channel.Execute(sendedPacket);
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

procedure TEasyIpClient.InitInterfaces(_host: string);
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

function TEasyIpClient.InfoRead: DynamicWordArray;
var
  returnedPacket: EasyIpPacket;
  returnArray: DynamicWordArray;
  arrayLength: int;
begin
  Protocol.Mode := pmInfo;
  returnedPacket := Channel.Execute(Protocol.Packet);
  arrayLength := returnedPacket.RequestDataSize * SHORT_SIZE;
  SetLength(returnArray, arrayLength); //38
  CopyMemory(returnArray, @returnedPacket.Data, arrayLength);
  Result := returnArray;
end;

end.

