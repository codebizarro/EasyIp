unit UPacketDispatcher;

interface

uses
  eiTypes,
  eiHelpers,
  UServerTypes;

type
  TPacketDispatcher = class(TInterfacedObject, IPacketDispatcher)
  private
    FLogger: ILogger;
  public
    function Process(packet: DynamicByteArray): DynamicByteArray;
    constructor Create(logger: ILogger);
  end;

implementation

constructor TPacketDispatcher.Create(logger: ILogger);
begin
  inherited Create();
  FLogger := logger;
end;

function TPacketDispatcher.Process(packet: DynamicByteArray): DynamicByteArray;
var
  returnPacket: DynamicByteArray;
  len: int;
begin
  FLogger.Log('Packet dispatching ...');
  //TODO: To implement packet dispatching
  len := Length(packet);
  SetLength(returnPacket, len);
  Result := returnPacket;
end;

end.

