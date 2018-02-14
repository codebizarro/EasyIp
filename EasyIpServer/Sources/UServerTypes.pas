unit UServerTypes;

interface

uses
  eiTypes;

type
  ILogger = interface
    procedure Log(messageText: string);
  end;

  IEasyIpServer = interface
    procedure Run;
  end;

  IPacketDispatcher = interface
    function Process(packet: DynamicByteArray): DynamicByteArray;
  end;

implementation

end.

