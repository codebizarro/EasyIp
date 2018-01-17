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
  TCustomClient = class(TComponent, IClient)
  private
  protected
  end;

  TEasyIpClient = class(TCustomClient, IEasyIpClient)
  private
    FProtocol: IEasyIpProtocol;
    FChannel: IEasyIpChannel;
    function GetChannel: IEasyIpChannel;
    function GetHost: string;
    function GetPort: int;
    function GetProtocol: IEasyIpProtocol;
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: int);
    property Channel: IEasyIpChannel read GetChannel;
    property Protocol: IEasyIpProtocol read GetProtocol;
  protected
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(_host: string); reintroduce; overload;
    destructor Destroy; override;
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

function TEasyIpClient.BlockRead(offset: short; dataType: DataTypeEnum; length: byte): DynamicWordArray;
var
  returnedPacket: EasyIpPacket;
  returnArray: DynamicWordArray;
  arrayLength: int;
begin
  FProtocol := TEasyIpProtocol.Create(pmRead);
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
  FProtocol := TEasyIpProtocol.Create(pmWrite);
  Protocol.DataOffset := offset;
  Protocol.DataType := dataType;
  Protocol.DataLength := dataLength;
  sendedPacket := Protocol.Packet;

  arrayLength := dataLength * SHORT_SIZE;

  CopyMemory(@sendedPacket.Data, value, arrayLength);

  returnedPacket := Channel.Execute(sendedPacket);
end;

constructor TEasyIpClient.Create(AOwner: TComponent);
begin
  inherited;
  FChannel := TEasyIpChannel.Create('', EASYIP_PORT);
end;

constructor TEasyIpClient.Create(_host: string);
begin
  inherited Create(nil);
  FChannel := TEasyIpChannel.Create(_host, EASYIP_PORT);
end;

destructor TEasyIpClient.Destroy;
begin
  inherited;
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

procedure TEasyIpClient.SetHost(const Value: string);
begin
  Channel.Host := Value;
end;

procedure TEasyIpClient.SetPort(const Value: int);
begin
  Channel.Port := Value;
end;

end.

