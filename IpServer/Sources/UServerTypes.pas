unit UServerTypes;

interface

uses
  WinSock,
  eiTypes;

type
  ILogger = interface
    ['{8178CD30-F04B-4B24-948E-734C8832FB94}']
    procedure Log(messageText: string); overload;
    procedure Log(messageText: string; formatString: string); overload;
  end;

  IServer = interface
    ['{545E0E6C-4416-4578-8A27-26957BC16646}']
    procedure Run;
  end;

  IPacketDispatcher = interface
    ['{E711FE7F-781D-457E-9529-C211B2BF2537}']
    function Process(packet: DynamicByteArray): DynamicByteArray;
  end;

  IDevice = interface
    ['{73C0D5DE-D613-4EE7-AEA6-F79CB198B24C}']
    function GetData(offset: int; count: byte): DynamicWordArray;
    procedure SetData(offset: int; data: DynamicWordArray);
    function TryGetData(offset: int; count: byte; out OutResult): DynamicWordArray;
    procedure TrySetData(offset: int; data: DynamicWordArray; out OutResult);
  end;

  TReceiveEvent = procedure(Sender: TObject; target: TSockAddrIn; buffer: DynamicByteArray) of object;

implementation

end.

