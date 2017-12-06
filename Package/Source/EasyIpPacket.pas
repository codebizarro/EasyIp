unit EasyIpPacket;

interface

type
  PEasyIpPacket = ^TEasyIpPacket;

  TEasyIpPacket = packed record
    Flags: Byte;
    Error: Byte;
    Counter: Integer;
    Spare1: Byte;
    SendDataType: Byte;
    SendDataSize: Word;
    SendDataOffset: Word;
    Spare2: Byte;
    RequestDataType: Byte;
    RequestDataSize: Word;
    RequestDataOffsetServer: Word;
    RequestDataOffsetClient: Word;
    Data: array[1..256] of Word;
  end;

implementation

end.

