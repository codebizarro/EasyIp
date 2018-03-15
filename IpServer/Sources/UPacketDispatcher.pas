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
  TEasyIpPacketDispatcher = class(TInterfacedObject, IPacketDispatcher)
  private
    FLogger: ILogger;
    function ProcessBitPacket(protocol: IEasyIpProtocol): DynamicByteArray;
    function ProcessDataPacket(protocol: IEasyIpProtocol): DynamicByteArray;
    function ProcessInfoPacket(protocol: IEasyIpProtocol): DynamicByteArray;
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray;
  end;

  TEchoPacketDispatcher = class(TInterfacedObject, IPacketDispatcher)
  private
    FLogger: ILogger;
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray;
  end;

implementation

constructor TEasyIpPacketDispatcher.Create(logger: ILogger);
begin
  inherited Create();
  FLogger := logger;
end;

function TEasyIpPacketDispatcher.Process(packet: DynamicByteArray): DynamicByteArray;
var
  eInPacket: EasyIpPacket;
  protocol: IEasyIpProtocol;
begin
  FLogger.Log('EasyIp packet dispatching ...');

  //TODO: To implement packet dispatching
  eInPacket := TPacketAdapter.ToEasyIpPacket(packet);
  protocol := TEasyIpProtocol.Create(eInPacket);

  if (protocol.Mode = pmRead) or (protocol.Mode = pmWrite) then
    Result := ProcessDataPacket(protocol)

  else if protocol.Mode = pmInfo then
    Result := ProcessInfoPacket(protocol)

  else if (protocol.Mode = pmBit) then
    Result := ProcessBitPacket(protocol);

  FLogger.Log('EasyIp packet processing is done');
end;

function TEasyIpPacketDispatcher.ProcessBitPacket(protocol: IEasyIpProtocol): DynamicByteArray;
begin
  //TODO: To implement packet dispatching
  FLogger.Log('Dispatching bit request...');
  Result := TPacketAdapter.ToByteArray(protocol.Packet);
end;

function TEasyIpPacketDispatcher.ProcessDataPacket(protocol: IEasyIpProtocol): DynamicByteArray;
var
  packet: EasyIpPacket;
begin
  //TODO: To implement packet dispatching
  FLogger.Log('Dispatching data request...');
  packet := protocol.Packet;
  Result := TPacketAdapter.ToByteArray(protocol.Packet);
end;

function TEasyIpPacketDispatcher.ProcessInfoPacket(protocol: IEasyIpProtocol): DynamicByteArray;
var
  infoPacket: EasyIpInfoPacket;
  packet: EasyIpPacket;
begin
  FLogger.Log('Dispatching info request...');
  packet := protocol.Packet;
  infoPacket := TPacketAdapter.ToEasyIpInfoPacket(packet);

  infoPacket.ControllerType := 1;
  infoPacket.ControllerRevisionHigh := 1;
  infoPacket.ControllerRevisioLow := 2;
  infoPacket.EasyIpRevisionHigh := 1;
  infoPacket.EasyIpRevisionLow := 2;

  //Operand sizes depends on concrete device
  infoPacket.OperandSize[1] := 10000;
  infoPacket.OperandSize[2] := 256;
  infoPacket.OperandSize[3] := 256;
  infoPacket.OperandSize[4] := 256;
  infoPacket.OperandSize[5] := 256;

  //Required by documentation
  packet.Flags := packet.Flags or EASYIP_FLAG_RESPONSE or EASYIP_FLAG_INFO;
  packet.RequestDataSize := 38;

  Result := TPacketAdapter.ToByteArray(packet, infoPacket);
end;

constructor TEchoPacketDispatcher.Create(logger: ILogger);
begin
  FLogger := logger;
end;

function TEchoPacketDispatcher.Process(packet: DynamicByteArray): DynamicByteArray;
begin
  FLogger.Log('Echo packet dispatching ...');

  Result := packet;

  FLogger.Log('Echo packet processing is done');
end;

end.

