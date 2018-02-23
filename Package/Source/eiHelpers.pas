unit eiHelpers;

interface

uses
  Windows,
  SysUtils,
  eiTypes,
  eiConstants;

type
  TPacketFactory = class
  public
    class function GetReadPacket(const offset: short; const dataType: DataTypeEnum; const length: byte): EasyIpPacket;
    class function GetWritePacket(const offset: short; const dataType: DataTypeEnum; const length: byte): EasyIpPacket;
  end;

  TPacketAdapter = class
  public
    class function ToByteArray(const packet: EasyIpPacket; const infoPacket: EasyIpInfoPacket): DynamicByteArray; overload;
    class function ToByteArray(const packet: EasyIpPacket): DynamicByteArray; overload;
    class function ToEasyIpInfoPacket(const packet: EasyIpPacket): EasyIpInfoPacket;
    class function ToEasyIpPacket(const buffer: DynamicByteArray): EasyIpPacket;
  end;

implementation

class function TPacketFactory.GetReadPacket(const offset: short; const dataType: DataTypeEnum; const length: byte): EasyIpPacket;
var
  packet: EasyIpPacket;
begin
  ZeroMemory(@packet, SizeOf(EasyIpPacket));
  with packet do
  begin
    Flags := 0;
    Error := 0;
    Counter := 0;
    Spare1 := 0;
    SendDataType := 0;
    SendDataSize := 0;
    SendDataOffset := offset;
    Spare2 := 0;
    RequestDataType := byte(dataType);
    RequestDataSize := length;
    RequestDataOffsetServer := offset;
    RequestDataOffsetClient := 0;
  end;
  Result := packet;
end;

class function TPacketFactory.GetWritePacket(const offset: short; const dataType: DataTypeEnum; const length: byte): EasyIpPacket;
var
  packet: EasyIpPacket;
begin
  ZeroMemory(@packet, SizeOf(EasyIpPacket));
  with packet do
  begin
    Flags := 0;
    Error := 0;
    Counter := 0;
    Spare1 := 0;
    SendDataType := byte(dataType);
    SendDataSize := length;
    SendDataOffset := offset;
    Spare2 := 0;
    RequestDataType := 0; //!!!
    RequestDataSize := 0;
    RequestDataOffsetServer := offset;
    RequestDataOffsetClient := 0;
  end;
  Result := packet;
end;

class function TPacketAdapter.ToByteArray(const packet: EasyIpPacket; const infoPacket: EasyIpInfoPacket): DynamicByteArray;
var
  returnBuffer: DynamicByteArray;
begin
  //Length must be equal to EasyIpPacket
  SetLength(returnBuffer, SizeOf(EasyIpPacket));
  CopyMemory(@packet.Data, @infoPacket, SizeOf(infoPacket));
  CopyMemory(returnBuffer, @packet, Length(returnBuffer));
  Result := returnBuffer;
end;

class function TPacketAdapter.ToByteArray(const packet: EasyIpPacket): DynamicByteArray;
var
  tBuffer: DynamicByteArray;
  bufferLength: int;
begin
  bufferLength := EASYIP_HEADERSIZE + packet.RequestDataSize * SHORT_SIZE + packet.SendDataSize * SHORT_SIZE;
//  if packet.SendDataSize > 0 then
//    bufferLength := bufferLength + packet.SendDataSize * SHORT_SIZE;
  SetLength(tBuffer, bufferLength);
  CopyMemory(tBuffer, @packet, bufferLength);
  Result := tBuffer;
end;

//For application using, not for exchange data between PC<->PLC
class function TPacketAdapter.ToEasyIpInfoPacket(const packet: EasyIpPacket): EasyIpInfoPacket;
var
  infoPacket: EasyIpInfoPacket;
  dataLength: int;
begin
  dataLength := SizeOf(EasyIpInfoPacket);
  ZeroMemory(@infoPacket, dataLength);
  CopyMemory(@infoPacket, @packet.Data, dataLength);
  Result := infoPacket;
end;

class function TPacketAdapter.ToEasyIpPacket(const buffer: DynamicByteArray): EasyIpPacket;
var
  tPacket: EasyIpPacket;
begin
  ZeroMemory(@tPacket, SizeOf(EasyIpPacket));
  CopyMemory(@tPacket, buffer, length(buffer));
  Result := tPacket;
end;

end.

