unit UServerTypes;

interface

uses
  WinSock,
  eiTypes;

type
  ILogger = interface
    ['{8178CD30-F04B-4B24-948E-734C8832FB94}']
    function LogPrefix(): string;
    procedure Log(messageText: string); overload;
    procedure Log(messageText: string; formatString: string); overload;
    procedure Log(formatString: string; const args: array of const); overload;
  end;

  IServer = interface
    ['{545E0E6C-4416-4578-8A27-26957BC16646}']
    procedure Start;
    procedure Stop;
  end;

  IPacketDispatcher = interface
    ['{E711FE7F-781D-457E-9529-C211B2BF2537}']
    function Process(packet: DynamicByteArray): DynamicByteArray;
  end;

  IDevice = interface
    ['{73C0D5DE-D613-4EE7-AEA6-F79CB198B24C}']
    function GetDataBlock(offset: int; count: byte): DynamicWordArray;
    procedure SetDataBlock(offset: int; data: DynamicWordArray);
    function TryGetDataBlock(offset: int; count: byte; out OutResult): DynamicWordArray;
    procedure TrySetDataBlock(offset: int; data: DynamicWordArray; out OutResult);
  end;

  RequestStruct = record
    Target: TSockAddrIn;
    Buffer: DynamicByteArray;
    Dispather: IPacketDispatcher;
  end;

  TRequestEvent = procedure(Sender: TObject; request: RequestStruct) of object;

implementation

end.

