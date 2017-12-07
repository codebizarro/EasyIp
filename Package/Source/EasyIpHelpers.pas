unit EasyIpHelpers;

interface

uses
  EasyIpCommonTypes,
  EasyIpConstants,
  EasyIpPacket;

type
  TPacketFactory = class
  public
    class function GetReadPacket(offset: short; dataType, length: byte): TEasyIpPacket;
    class function GetWritePacket(offset: short; dataType, length: byte): TEasyIpPacket;
  end;

implementation

{ TPacketFactory }

class function TPacketFactory.GetReadPacket(offset: short; dataType, length: byte): TEasyIpPacket;
begin
  with Result do
  begin
    Flags := 0;
    Error := 0;
    Counter := 0; // Must increment in client
    SendDataType := 0;
    SendDataSize := 0;
    SendDataOffset := offset;
    RequestDataType := dataType;
    RequestDataSize := length;
    RequestDataOffsetServer := offset;
    RequestDataOffsetClient := 0;
  end;
end;

class function TPacketFactory.GetWritePacket(offset: short; dataType, length: byte): TEasyIpPacket;
begin
  with Result do
  begin
    Flags := 0;
    Error := 0;
    Counter := 0; // Must increment in client
    SendDataSize := length;
    SendDataOffset := offset;
    SendDataType := dataType;
    RequestDataSize := 0;
    RequestDataOffsetServer := offset;
    RequestDataOffsetClient := 0;
  end;
end;

end.

