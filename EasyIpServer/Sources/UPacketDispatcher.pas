unit UPacketDispatcher;

interface

uses
  Windows,
  eiTypes,
  eiHelpers,
  eiProtocol,
  eiConstants,
  UServerTypes;

type
  TPacketDispatcher = class(TInterfacedObject, IPacketDispatcher)
  private
    FLogger: ILogger;
    function ProcessBitPacket(protocol: IEasyIpProtocol): DynamicByteArray;
    function ProcessDataPacket(protocol: IEasyIpProtocol): DynamicByteArray;
    function ProcessInfoPacket(protocol: IEasyIpProtocol): DynamicByteArray;
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
  eInPacket: EasyIpPacket;
  protocol: IEasyIpProtocol;
begin
  FLogger.Log('Packet dispatching ...');

  //TODO: To implement packet dispatching
  eInPacket := TPacketAdapter.ToEasyIpPacket(packet);
  protocol := TEasyIpProtocol.Create(eInPacket);

  if (protocol.Mode = pmRead) or (protocol.Mode = pmWrite) then
    Result := ProcessDataPacket(protocol)

  else if protocol.Mode = pmInfo then
    Result := ProcessInfoPacket(protocol)

  else if (protocol.Mode = pmBit) then
    Result := ProcessBitPacket(protocol);

  FLogger.Log('Packet processing is done');
end;

function TPacketDispatcher.ProcessBitPacket(protocol: IEasyIpProtocol): DynamicByteArray;
begin
  //TODO: To implement packet dispatching
  Result := TPacketAdapter.ToByteArray(protocol.Packet);
end;

function TPacketDispatcher.ProcessDataPacket(protocol: IEasyIpProtocol): DynamicByteArray;
begin
  //TODO: To implement packet dispatching
  Result := TPacketAdapter.ToByteArray(protocol.Packet);
end;

function TPacketDispatcher.ProcessInfoPacket(protocol: IEasyIpProtocol): DynamicByteArray;
var
  infoPacket: EasyIpInfoPacket;
  returnPacket: EasyIpPacket;
  returnBuffer: DynamicByteArray;
begin
  returnPacket := protocol.Packet;
  infoPacket := TPacketAdapter.ToEasyIpInfoPacket(protocol.Packet);

  infoPacket.ControllerType := 1;
  infoPacket.ControllerRevisionHigh := 1;
  infoPacket.ControllerRevisioLow := 2;
  infoPacket.EasyIpRevisionHigh := 1;
  infoPacket.EasyIpRevisionLow := 2;
  infoPacket.OperandSize[1] := 10000;
  infoPacket.OperandSize[2] := 256;
  infoPacket.OperandSize[3] := 256;
  infoPacket.OperandSize[4] := 256;
  infoPacket.OperandSize[5] := 256;

  SetLength(returnBuffer, EASYIP_HEADERSIZE + SizeOf(EasyIpInfoPacket));
  CopyMemory(@returnPacket.Data, @infoPacket, SizeOf(infoPacket));
  CopyMemory(returnBuffer, @returnPacket, Length(returnBuffer));

  Result := returnBuffer;
  sleep(0)
end;

end.

