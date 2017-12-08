unit EasyIpPacket;

interface

type
  PEasyIpPacket = ^TEasyIpPacket;

/// <summary>
/// Encapsulate EasyIP packet
/// </summary>
  TEasyIpPacket = packed record
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

implementation

end.

