unit eiTypes;

interface

type
  PDynamicByteArray = ^DynamicByteArray;

  DynamicByteArray = array of Byte;

  DynamicWordArray = array of Word;

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
    ['{D789650F-C76E-42B3-B358-D78E98AD82C7}']
    function GetTimeout: int;
    procedure SetTimeout(const value: int);
    function Execute(buffer: DynamicByteArray): DynamicByteArray;
    property Timeout: int read GetTimeout write SetTimeout;
  end;

  INetworkChannel = interface(IChannel)
    ['{F5995BE4-509D-498D-9A4C-68AD721822DE}']
    function GetHost: string;
    function GetPort: int;
    procedure SetHost(const value: string);
    procedure SetPort(const value: int);
    property Host: string read GetHost write SetHost;
    property Port: int read GetPort write SetPort;
  end;

  IUdpChannel = interface(INetworkChannel)
    ['{C65D3A64-E4E8-4C4E-83AF-A670BEFFEACF}']
  end;

  IEasyIpChannel = interface(IUdpChannel)
    ['{D907A69A-7C89-404B-9F2A-7162E73596D0}']
    function Execute(packet: EasyIpPacket): EasyIpPacket;
  end;

  IProtocol = interface
    ['{F48C0963-8ACD-4AC3-8911-B793DC2E94AC}']
    function GetBuffer: DynamicByteArray;
    property Buffer: DynamicByteArray read GetBuffer;
  end;

  IEasyIpProtocol = interface(IProtocol)
    ['{790B9B4C-8B13-4862-9035-7CEA97708CBA}']
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
    ['{9D474F20-AAB6-4F67-90EC-31696084450E}']
  end;

  IEasyIpClient = interface(IClient)
    ['{5A5CB45B-B6D5-4916-B074-48FF471D8858}']
    function BlockRead(offset: short; dataType: DataTypeEnum; length: byte): DynamicWordArray;
    procedure BlockWrite(offset: short; value: DynamicWordArray; dataType: DataTypeEnum);
    function GetChannel: IEasyIpChannel;
    function GetProtocol: IEasyIpProtocol;
    property Channel: IEasyIpChannel read GetChannel;
    property Protocol: IEasyIpProtocol read GetProtocol;
  end;

implementation

end.

