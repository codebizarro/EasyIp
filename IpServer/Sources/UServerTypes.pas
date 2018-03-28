unit UServerTypes;

interface

uses
  WinSock,
  eiTypes;

type
  TErrorLevel = (elInformation, elNotice, elWarning, elError);

  ILogger = interface
    ['{8178CD30-F04B-4B24-948E-734C8832FB94}']
    function LogPrefix(): string;
    procedure Log(messageText: string; level: TErrorLevel = elInformation); overload;
    procedure Log(messageText: string; formatString: string); overload;
    procedure Log(formatString: string; const args: array of const); overload;
  end;

  IServer = interface
    ['{545E0E6C-4416-4578-8A27-26957BC16646}']
    procedure Start;
    procedure Stop;
  end;

  IHandler = interface
    ['{E711FE7F-781D-457E-9529-C211B2BF2537}']
    function Process(packet: DynamicByteArray): DynamicByteArray;
  end;

  IDevice = interface
    ['{73C0D5DE-D613-4EE7-AEA6-F79CB198B24C}']
    function BlockRead(const offset: short; const dataType: DataTypeEnum; const dataLength: byte): DynamicWordArray;
    procedure BlockWrite(const offset: short; const value: DynamicWordArray; const dataType: DataTypeEnum);
    function RangeCheck(const offset: short; const dataType: DataTypeEnum; const dataLength: byte): short;
  end;

  RequestStruct = record
    Target: TSockAddrIn;
    Buffer: DynamicByteArray;
    Handler: IHandler;
  end;

  TRequestEvent = procedure(Sender: TObject; request: RequestStruct) of object;

implementation

end.

