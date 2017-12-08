unit EasyIpHelpers;

interface

uses
  Windows,
  EasyIpCommonTypes,
  EasyIpConstants,
  EasyIpPacket;

type
  TPacketFactory = class
  public
    class function GetReadPacket(offset: short; dataType, length: byte): TEasyIpPacket;
    class function GetWritePacket(offset: short; dataType, length: byte): TEasyIpPacket;
  end;

  TPacketAdapter = class
  public
    class function ToByteArray(packet: TEasyIpPacket): TByteArray;
    class function ToEasyIpPacket(buffer: TByteArray): TEasyIpPacket;
  end;

implementation

{ TPacketFactory }

class function TPacketFactory.GetReadPacket(offset: short; dataType, length: byte): TEasyIpPacket;
var
  tempArray: TByteArray;
begin
  //TODO: fill Data with zeroes

  with Result do
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
end;

class function TPacketFactory.GetWritePacket(offset: short; dataType, length: byte): TEasyIpPacket;
begin
  //TODO: fill Data with zeroes
  
  with Result do
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
end;

class function TPacketAdapter.ToByteArray(packet: TEasyIpPacket): TByteArray;
var
  tBuffer: TByteArray;
begin
  SetLength(tBuffer, SizeOf(packet));
  CopyMemory(tBuffer, @packet, SizeOf(packet));
  Result := tBuffer;
end;

class function TPacketAdapter.ToEasyIpPacket(buffer: TByteArray): TEasyIpPacket;
var
  tPacket: TEasyIpPacket;
begin
  CopyMemory(@tPacket, buffer, length(buffer));
  Result := tPacket;
end;

end.

