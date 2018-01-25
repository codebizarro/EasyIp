unit eiProtocol;

interface

uses
  Windows,
  SysUtils,
  Classes,
  eiTypes,
  eiHelpers,
  eiConstants;

type
  TEasyIpProtocol = class(TInterfacedObject, IEasyIpProtocol)
  private
    FPacket: EasyIpPacket;
    FMode: PacketModeEnum;
    constructor Create(const buffer: DynamicByteArray); overload;
    constructor Create(const packet: EasyIpPacket); overload;
    function GetPacket: EasyIpPacket;
    function GetBuffer: DynamicByteArray;
    function GetDataLength: DataLength;
    function GetDataOffset: ushort;
    function GetDataType: DataTypeEnum;
    function GetMode: PacketModeEnum;
    procedure SetDataLength(const value: DataLength);
    procedure SetDataOffset(const value: ushort);
    procedure SetDataType(const value: DataTypeEnum);
    procedure SetDebug(const value: string);
    procedure SetMode(const value: PacketModeEnum);
  protected
    property Debug: string write SetDebug;
  public
    constructor Create(const mode: PacketModeEnum); overload;
    destructor Destroy; override;
    property Buffer: DynamicByteArray read GetBuffer;
    property DataLength: DataLength read GetDataLength write SetDataLength;
    property DataOffset: ushort read GetDataOffset write SetDataOffset;
    property DataType: DataTypeEnum read GetDataType write SetDataType;
    property Mode: PacketModeEnum read GetMode write SetMode;
    property Packet: EasyIpPacket read GetPacket;
  end;

implementation

constructor TEasyIpProtocol.Create(const buffer: DynamicByteArray);
begin
  inherited Create;
  Debug := Format(DEBUG_MESSAGE_CREATE, ['TEasyIpProtocol']);
  FPacket := TPacketAdapter.ToEasyIpPacket(buffer);
end;

constructor TEasyIpProtocol.Create(const packet: EasyIpPacket);
begin
  inherited Create;
  Debug := Format(DEBUG_MESSAGE_CREATE, ['TEasyIpProtocol']);
  FPacket := packet;
end;

constructor TEasyIpProtocol.Create(const mode: PacketModeEnum);
begin
  inherited Create;
  Debug := Format(DEBUG_MESSAGE_CREATE, ['TEasyIpProtocol']);
  FMode := mode;
end;

destructor TEasyIpProtocol.Destroy;
begin
  inherited;
  Debug := Format(DEBUG_MESSAGE_DESTROY, ['TEasyIpProtocol']);
end;

function TEasyIpProtocol.GetBuffer: DynamicByteArray;
begin
  Result := TPacketAdapter.ToByteArray(FPacket);
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

function TEasyIpProtocol.GetMode: PacketModeEnum;
begin
  Result := FMode;
end;

function TEasyIpProtocol.GetPacket: EasyIpPacket;
begin
  Result := FPacket;
end;

procedure TEasyIpProtocol.SetDataLength(const value: DataLength);
begin
  FPacket.RequestDataSize := 0;
  FPacket.SendDataSize := 0;
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
  FPacket.RequestDataType := byte(dtUndefined);
  FPacket.SendDataType := byte(dtUndefined);
  if (FMode = pmRead) then
    FPacket.RequestDataType := dataType
  else
    FPacket.SendDataType := dataType;
end;

procedure TEasyIpProtocol.SetDebug(const value: string);
begin
  OutputDebugString(PChar(value));
end;

procedure TEasyIpProtocol.SetMode(const value: PacketModeEnum);
begin
  if value = pmInfo then
  begin
    FPacket.Flags := FPacket.Flags or EASYIP_FLAG_INFO;
//    FPacket.Counter := FPacket.Counter + 1;

    FPacket.RequestDataSize := 1;
    FPacket.Data[1] := 1;
  end

  else
    FPacket.Flags := 0;
  FMode := value;
end;

end.

