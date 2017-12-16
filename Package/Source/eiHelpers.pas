unit eiHelpers;

interface

uses
  Windows,
  SysUtils,
  eiCommonTypes,
  eiConstants,
  eiPacket;

type
  TPacketFactory = class
  public
    class function GetReadPacket(offset: short; dataType, length: byte): EasyIpPacket;
    class function GetWritePacket(offset: short; dataType, length: byte): EasyIpPacket;
  end;

  TPacketAdapter = class
  public
    class function ToByteArray(packet: EasyIpPacket): DynamicByteArray;
    class function ToEasyIpPacket(buffer: DynamicByteArray): EasyIpPacket;
  end;

implementation

class function TPacketFactory.GetReadPacket(offset: short; dataType, length: byte):EasyIpPacket;
var
  packet: EasyIpPacket;
begin
  ZeroMemory(@packet, SizeOf(packet));
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
    RequestDataType := dataType;
    RequestDataSize := length;
    RequestDataOffsetServer := offset;
    RequestDataOffsetClient := 0;
  end;
  Result := packet;
end;

class function TPacketFactory.GetWritePacket(offset: short; dataType, length: byte): EasyIpPacket;
var
  packet: EasyIpPacket;
begin
  ZeroMemory(@packet, SizeOf(packet));
  with packet do
  begin
    Flags := 0;
    Error := 0;
    Counter := 0;
    Spare1 := 0;
    SendDataType := dataType;
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

class function TPacketAdapter.ToByteArray(packet: EasyIpPacket): DynamicByteArray;
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

class function TPacketAdapter.ToEasyIpPacket(buffer: DynamicByteArray): EasyIpPacket;
var
  tPacket: EasyIpPacket;
begin
  ZeroMemory(@tPacket, SizeOf(tPacket));
  CopyMemory(@tPacket, buffer, length(buffer));
  Result := tPacket;
end;

end.

