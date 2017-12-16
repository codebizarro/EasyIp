unit eiPacket;

interface

uses
  Windows,
  SysUtils,
  Classes,
  eiCommonTypes,
  eiConstants;

type
  PEasyIpPacket = ^EasyIpPacket;

/// <summary>
/// Encapsulate EasyIP packet
/// </summary>
  EasyIpPacket = packed record
/// <summary>
/// 1 byte
/// Bit 0 information packet (request or response)
/// Bit 1-2 bit operations 1
/// Bit 6 do not respond
/// Bit 7 response packet
/// </summary>
    Flags: Byte;
/// <summary>
/// 1 byte
/// Only used in response packets
/// 0: no error
/// 1: operand type error
/// 2: offset error
/// 4: size error
/// 16: no support
/// </summary>
    Error: Byte;
/// <summary>
/// 4 bytes
/// Set by client, copied by server
/// </summary>
    Counter: Integer;
/// <summary>
/// 1 byte
/// Reserved
/// Set to 0
/// </summary>
    Spare1: Byte;
/// <summary>
/// 1 byte
/// Type of operand, some types may not be available
/// 1 memory word
/// 2 input word
/// 3 output word
/// 4 register
/// 5 timer
/// 11 strings3
/// </summary>
    SendDataType: Byte;
/// <summary>
/// 2 bytes
/// Number of words
/// </summary>
    SendDataSize: Word;
/// <summary>
/// 2 bytes
/// Target offset in server
/// </summary>
    SendDataOffset: Word;
/// <summary>
/// 1 byte
/// Reserved
/// Set to 0
    Spare2: Byte;
/// <summary>
/// 1 byte
/// Type of operand, some types may not be available (see senddata type for list of types)
/// </summary>
    RequestDataType: Byte;
/// <summary>
/// 2 bytes
/// Number of words
/// </summary>
    RequestDataSize: Word;
/// <summary>
/// 2 bytes
/// Offset in server
/// </summary>
    RequestDataOffsetServer: Word;
/// <summary>
/// 2 bytes
/// Target offset in client
/// </summary>
    RequestDataOffsetClient: Word;
/// <summary>
/// N*2 bytes
/// Data send by client or requested data
/// </summary>
    Data: array[1..256] of Word;
  end;

  DataTypeEnum = (dtFlag, dtInput, dtOutput, dtRegister, dtTimer, dtString);

  PacketModeEnum = (pmRead, pmWrite);

  DataLength = 1..256;

  TEasyIpPacket = class
  private
    FPacket: EasyIpPacket;
    FMode: PacketModeEnum;
    constructor Create(buffer: DynamicByteArray); overload;
    constructor Create(packet: EasyIpPacket); overload;
    function GetBuffer: DynamicByteArray;
    function GetDataLength: DataLength;
    function GetDataOffset: ushort;
    function GetDataType: DataTypeEnum;
    procedure SetDataLength(const value: DataLength);
    procedure SetDataOffset(const value: ushort);
    procedure SetDataType(const value: DataTypeEnum);
  public
    constructor Create(mode: PacketModeEnum); overload;
    property Buffer: DynamicByteArray read GetBuffer;
    property DataLength: DataLength read GetDataLength write SetDataLength;
    property DataOffset: ushort read GetDataOffset write SetDataOffset;
    property DataType: DataTypeEnum read GetDataType write SetDataType;
    property Packet: EasyIpPacket read FPacket;
  end;

implementation

constructor TEasyIpPacket.Create(buffer: DynamicByteArray);
var
  tPacket: EasyIpPacket;
begin
  inherited Create;
  ZeroMemory(@tPacket, SizeOf(tPacket));
  CopyMemory(@tPacket, buffer, length(buffer));
  FPacket := tPacket;
end;

constructor TEasyIpPacket.Create(packet: EasyIpPacket);
begin
  inherited Create;
  FPacket := packet;
end;

constructor TEasyIpPacket.Create(mode: PacketModeEnum);
begin
  inherited Create;
  FMode := mode;
end;

function TEasyIpPacket.GetBuffer: DynamicByteArray;
var
  tBuffer: DynamicByteArray;
  length: int;
begin
  length := SizeOf(FPacket);
  SetLength(tBuffer, length);
  CopyMemory(tBuffer, @packet, length);
  Result := tBuffer;
end;

function TEasyIpPacket.GetDataLength: DataLength;
begin
  if (FMode = pmRead) then
    Result := FPacket.RequestDataSize
  else if (FMode = pmWrite) then
    Result := FPacket.SendDataSize;
end;

function TEasyIpPacket.GetDataOffset: ushort;
begin
  if (FMode = pmRead) then
    Result := FPacket.RequestDataOffsetServer
  else if (FMode = pmWrite) then
    Result := FPacket.SendDataOffset;
end;

function TEasyIpPacket.GetDataType: DataTypeEnum;
var
  dataType: byte;
begin
  if (FMode = pmRead) then
    dataType := FPacket.RequestDataType
  else if (FMode = pmWrite) then
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

procedure TEasyIpPacket.SetDataLength(const value: DataLength);
begin
  if (FMode = pmRead) then
    FPacket.RequestDataSize := value
  else if (FMode = pmWrite) then
    FPacket.SendDataSize := value;
end;

procedure TEasyIpPacket.SetDataOffset(const value: ushort);
begin
  FPacket.SendDataOffset := value;
  FPacket.RequestDataOffsetServer := value;
end;

procedure TEasyIpPacket.SetDataType(const value: DataTypeEnum);
var
  dataType: byte;
begin
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
  else if (FMode = pmWrite) then
    FPacket.SendDataType := dataType;
end;

end.

