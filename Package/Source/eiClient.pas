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
  TEasyIpClient = class(TInterfacedObject, IEasyIpProtocol, IEasyIpChannel, IEasyIpClient)
  private
    FProtocol: IEasyIpProtocol;
    FChannel: IEasyIpChannel;
    FHost: string;
    function GetChannel: IEasyIpChannel;
    function GetProtocol: IEasyIpProtocol;
    property Channel: IEasyIpChannel read GetChannel implements IEasyIpChannel;
    property Protocol: IEasyIpProtocol read GetProtocol implements IEasyIpProtocol;
  protected
  public
    constructor Create(_host: string); overload;
    destructor Destroy; override;
    function BlockRead(offset: short; dataType: DataTypeEnum; length: byte): DynamicWordArray;
    procedure BlockWrite(offset: short; value: DynamicWordArray; dataType: DataTypeEnum);
  published
    property Host: string read FHost write FHost;
  end;

implementation

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
  dataLength := Length(value);
  FProtocol := TEasyIpProtocol.Create(pmWrite);
  Protocol.DataOffset := offset;
  Protocol.DataType := dataType;
  Protocol.DataLength := dataLength;
  sendedPacket := Protocol.Packet;

  arrayLength := dataLength * SHORT_SIZE;

  CopyMemory(@sendedPacket.Data, value, arrayLength);

  returnedPacket := Channel.Execute(sendedPacket);
end;

constructor TEasyIpClient.Create(_host: string);
begin
  inherited Create;
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

function TEasyIpClient.GetProtocol: IEasyIpProtocol;
begin
  Result := FProtocol;
end;

end.

