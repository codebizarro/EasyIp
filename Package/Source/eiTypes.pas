unit eiTypes;

interface

type
  PDynamicByteArray = ^DynamicByteArray;

  DynamicByteArray = array of Byte;

  bool = Boolean;

  sbyte = ShortInt;

  short = Smallint;

  int = Integer;

  ushort = Word;

  uint = LongWord;

  float = Single;

  DataTypeEnum = (dtUndefined, dtFlag, dtInput, dtOutput, dtRegister, dtTimer, dtString);

  PacketModeEnum = (pmRead, pmWrite);

  DataLength = 1..256;

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

  IChannel = interface
    function GetTimeout: int;
    procedure SetTimeout(const value: int);
    function Execute(buffer: DynamicByteArray): DynamicByteArray;
    property Timeout: int read GetTimeout write SetTimeout;
  end;

  INetworkChannel = interface(IChannel)
    function GetHost: string;
    procedure SetHost(const value: string);
    property Host: string read GetHost write SetHost;
  end;

  IUdpChannel = interface(INetworkChannel)
    function GetPort: int;
    procedure SetPort(const value: int);
    property Port: int read GetPort write SetPort;
  end;

  IEasyIpChannel = interface(IUdpChannel)
    function Execute(packet: EasyIpPacket): EasyIpPacket;
  end;

  IProtocol = interface
    function GetBuffer: DynamicByteArray;
    property Buffer: DynamicByteArray read GetBuffer;
  end;

  IEasyIpProtocol = interface(IProtocol)
    function GetPacket: EasyIpPacket;
    function GetDataLength: DataLength;
    function GetDataOffset: ushort;
    function GetDataType: DataTypeEnum;
    procedure SetDataLength(const value: DataLength);
    procedure SetDataOffset(const value: ushort);
    procedure SetDataType(const value: DataTypeEnum);
    property DataLength: DataLength read GetDataLength write SetDataLength;
    property DataOffset: ushort read GetDataOffset write SetDataOffset;
    property DataType: DataTypeEnum read GetDataType write SetDataType;
    property Packet: EasyIpPacket read GetPacket;
  end;

  IClient = interface
  end;

implementation

end.

