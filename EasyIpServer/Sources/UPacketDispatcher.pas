unit UPacketDispatcher;

interface

uses
  eiTypes,
  eiHelpers,
  eiProtocol,
  UServerTypes;

type
  TPacketDispatcher = class(TInterfacedObject, IPacketDispatcher)
  private
    FLogger: ILogger;
    function ProcessBitPacket(protocol: IEasyIpProtocol): EasyIpPacket;
    function ProcessDataPacket(protocol: IEasyIpProtocol): EasyIpPacket;
    function ProcessInfoPacket(protocol: IEasyIpProtocol): EasyIpPacket;
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray;
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
  eInPacket, eOutPacket: EasyIpPacket;
  protocol: IEasyIpProtocol;
  len: int;
begin
  FLogger.Log('Packet dispatching ...');

  //TODO: To implement packet dispatching
  eInPacket := TPacketAdapter.ToEasyIpPacket(packet);
  protocol := TEasyIpProtocol.Create(eInPacket);

  if (protocol.Mode = pmRead) or (protocol.Mode = pmWrite) then
    eOutPacket := ProcessDataPacket(protocol)
  else if protocol.Mode = pmInfo then
    eOutPacket := ProcessInfoPacket(protocol)
  else if (protocol.Mode = pmBit) then
    eOutPacket := ProcessBitPacket(protocol);

  Result := TPacketAdapter.ToByteArray(eOutPacket);
end;

function TPacketDispatcher.ProcessBitPacket(protocol: IEasyIpProtocol): EasyIpPacket;
begin
  //TODO: To implement packet dispatching
  Result := protocol.Packet;
end;

function TPacketDispatcher.ProcessDataPacket(protocol: IEasyIpProtocol): EasyIpPacket;
begin
  //TODO: To implement packet dispatching
  Result := protocol.Packet;
end;

function TPacketDispatcher.ProcessInfoPacket(protocol: IEasyIpProtocol): EasyIpPacket;
begin
  //TODO: To implement packet dispatching
  Result := protocol.Packet;
end;

end.

