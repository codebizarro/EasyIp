unit eiPacket;

interface

uses
  Windows,
  SysUtils,
  Classes,
  eiTypes,
  eiConstants;

type
  TEasyIpProtocol = class(TInterfacedObject, IEasyIpProtocol)
  private
    FPacket: EasyIpPacket;
    FMode: PacketModeEnum;
    constructor Create(buffer: DynamicByteArray); overload;
    constructor Create(packet: EasyIpPacket); overload;
    function GetPacket: EasyIpPacket;
    function GetBuffer: DynamicByteArray;
    function GetDataLength: DataLength;
    function GetDataOffset: ushort;
    function GetDataType: DataTypeEnum;
    procedure SetDataLength(const value: DataLength);
    procedure SetDataOffset(const value: ushort);
    procedure SetDataType(const value: DataTypeEnum);
  public
    constructor Create(mode: PacketModeEnum); overload;
    destructor Destroy; override;
    property Buffer: DynamicByteArray read GetBuffer;
    property DataLength: DataLength read GetDataLength write SetDataLength;
    property DataOffset: ushort read GetDataOffset write SetDataOffset;
    property DataType: DataTypeEnum read GetDataType write SetDataType;
    property Packet: EasyIpPacket read GetPacket;
  end;

implementation

constructor TEasyIpProtocol.Create(buffer: DynamicByteArray);
var
  tPacket: EasyIpPacket;
begin
  inherited Create;
  ZeroMemory(@tPacket, SizeOf(tPacket));
  CopyMemory(@tPacket, buffer, length(buffer));
  FPacket := tPacket;
end;

constructor TEasyIpProtocol.Create(packet: EasyIpPacket);
begin
  inherited Create;
  FPacket := packet;
end;

constructor TEasyIpProtocol.Create(mode: PacketModeEnum);
begin
  inherited Create;
  FMode := mode;
end;

destructor TEasyIpProtocol.Destroy;
begin
  inherited;

end;

function TEasyIpProtocol.GetBuffer: DynamicByteArray;
var
  tBuffer: DynamicByteArray;
  length: int;
begin
  length := SizeOf(FPacket);
  SetLength(tBuffer, length);
  CopyMemory(tBuffer, @FPacket, length);
  Result := tBuffer;
end;

function TEasyIpProtocol.GetDataLength: DataLength;
begin
  if (FMode = pmRead) then
    Result := FPacket.RequestDataSize
  else
    Result := FPacket.SendDataSize;
end;

function TEasyIpProtocol.GetDataOffset: ushort;
begin
  if (FMode = pmRead) then
    Result := FPacket.RequestDataOffsetServer
  else
    Result := FPacket.SendDataOffset;
end;

function TEasyIpProtocol.GetDataType: DataTypeEnum;
var
  dataType: byte;
begin
  Result := dtUndefined;
  if (FMode = pmRead) then
    dataType := FPacket.RequestDataType
  else
    dataType := FPacket.SendDataType;
  case dataType of
    EASYIP_TYPE_FLAGWORD:
      Result := dtFlag;
    EASYIP_TYPE_INPUTWORD:
      Result := dtInput;
    EASYIP_TYPE_OUTPUTWORD:
      Result := dtOutput;
    EASYIP_TYPE_REGISTER:
      Result := dtRegister;
    EASYIP_TYPE_TIMER:
      Result := dtTimer;
    EASYIP_TYPE_STRING:
      Result := dtString;
  end;
end;

function TEasyIpProtocol.GetPacket: EasyIpPacket;
begin
  Result := FPacket;
end;

procedure TEasyIpProtocol.SetDataLength(const value: DataLength);
begin
  if (FMode = pmRead) then
    FPacket.RequestDataSize := value
  else if (FMode = pmWrite) then
    FPacket.SendDataSize := value;
end;

procedure TEasyIpProtocol.SetDataOffset(const value: ushort);
begin
  FPacket.SendDataOffset := value;
  FPacket.RequestDataOffsetServer := value;
end;

procedure TEasyIpProtocol.SetDataType(const value: DataTypeEnum);
var
  dataType: byte;
begin
  dataType := 0;
  case value of
    dtFlag:
      dataType := EASYIP_TYPE_FLAGWORD;
    dtInput:
      dataType := EASYIP_TYPE_INPUTWORD;
    dtOutput:
      dataType := EASYIP_TYPE_OUTPUTWORD;
    dtRegister:
      dataType := EASYIP_TYPE_REGISTER;
    dtTimer:
      dataType := EASYIP_TYPE_TIMER;
    dtString:
      dataType := EASYIP_TYPE_STRING;
  end;
  if (FMode = pmRead) then
    FPacket.RequestDataType := dataType
  else
    FPacket.SendDataType := dataType;
end;

end.

