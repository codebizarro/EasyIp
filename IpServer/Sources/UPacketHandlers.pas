unit UPacketHandlers;

interface

uses
  Windows,
  eiTypes,
  eiHelpers,
  eiProtocol,
  eiConstants,
  UServerTypes,
  UDevices;

type
  TBaseHandler = class(TInterfacedObject, IHandler)
  private
    FLogger: ILogger;
    procedure DoneMessage(message: string);
    procedure StartMessage(message: string);
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray; virtual; abstract;
  end;

  TEasyIpHandler = class(TBaseHandler)
  private
    FDevice: IDevice;
    function ProcessBitPacket(protocol: IEasyIpProtocol): DynamicByteArray;
    function ProcessDataPacket(protocol: IEasyIpProtocol): DynamicByteArray;
    function ProcessInfoPacket(protocol: IEasyIpProtocol): DynamicByteArray;
  public
    constructor Create(logger: ILogger; device: IDevice);
    function Process(packet: DynamicByteArray): DynamicByteArray; override;
  end;

  TEchoHandler = class(TBaseHandler)
  private
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray; override;
  end;

  TChargenHandler = class(TBaseHandler)
  private
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray; override;
  end;

  TDaytimeHandler = class(TBaseHandler)
  private
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray; override;
  end;

  TSearchHandler = class(TBaseHandler)
  private
    FBuffer: string;
    FSearchPattern: string;
    FResponsePattern: string;
  public
    constructor Create(logger: ILogger);
    function Process(packet: DynamicByteArray): DynamicByteArray; override;
  end;

implementation

constructor TEasyIpHandler.Create(logger: ILogger; device: IDevice);
begin
  inherited Create(logger);
  FDevice := device;
end;

function TEasyIpHandler.Process(packet: DynamicByteArray): DynamicByteArray;
var
  eInPacket: EasyIpPacket;
  protocol: IEasyIpProtocol;
begin
  StartMessage(ClassName);

  //TODO: To implement packet dispatching
  eInPacket := TPacketAdapter.ToEasyIpPacket(packet);
  protocol := TEasyIpProtocol.Create(eInPacket);

  if (protocol.Mode = pmRead) or (protocol.Mode = pmWrite) then
    Result := ProcessDataPacket(protocol)

  else if protocol.Mode = pmInfo then
    Result := ProcessInfoPacket(protocol)

  else if (protocol.Mode = pmBit) then
    Result := ProcessBitPacket(protocol);

  DoneMessage(ClassName);
end;

function TEasyIpHandler.ProcessBitPacket(protocol: IEasyIpProtocol): DynamicByteArray;
begin
  //TODO: To implement packet dispatching
  FLogger.Log('Dispatching bit request...');
  Result := TPacketAdapter.ToByteArray(protocol.Packet);
end;

function TEasyIpHandler.ProcessDataPacket(protocol: IEasyIpProtocol): DynamicByteArray;
var
  packet: EasyIpPacket;
  mode: PacketModeEnum;
  dataType: DataTypeEnum;
  offset: ushort;
  length: DataLength;
  resultData: DynamicWordArray;
  errorFlag: short;
begin
  FLogger.Log('Dispatching data request...');
  packet := protocol.Packet;
  mode := protocol.Mode;
  dataType := protocol.DataType;
  offset := protocol.DataOffset;
  length := protocol.DataLength;
  FLogger.Log('mode: %d  dataType: %d offset: %d length: %d', [Byte(mode), Byte(dataType), offset, length]);

  SetLength(resultData, length);
  errorFlag := FDevice.RangeCheck(offset, dataType, length);
  if errorFlag = 0 then
  begin
    if mode = pmRead then
    begin
      FLogger.Log('Reading data ...');
      resultData := FDevice.BlockRead(offset, dataType, length);
      CopyMemory(@packet.Data, resultData, length * SHORT_SIZE);
    end;
    if mode = pmWrite then
    begin
      FLogger.Log('Writing data request...');
      CopyMemory(resultData, @packet.Data, length * SHORT_SIZE);
      FDevice.BlockWrite(offset, resultData, dataType);
    end;
  end;
  packet.Flags := EASYIP_FLAG_RESPONSE;
  packet.Error := errorFlag;
  Result := TPacketAdapter.ToByteArray(packet);
end;

function TEasyIpHandler.ProcessInfoPacket(protocol: IEasyIpProtocol): DynamicByteArray;
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

constructor TEchoHandler.Create(logger: ILogger);
begin
  inherited Create(logger);
end;

function TEchoHandler.Process(packet: DynamicByteArray): DynamicByteArray;
begin
  StartMessage(ClassName);

  Result := packet;

  DoneMessage(ClassName);
end;

constructor TChargenHandler.Create(logger: ILogger);
begin
  inherited Create(logger);
end;

//TODO: need to test
function TChargenHandler.Process(packet: DynamicByteArray): DynamicByteArray;
const
  rowlength = 75;
var
  s: string;
  i, row, ln: integer;
  c: Char;
begin
  StartMessage(ClassName);
  Randomize();
  SetLength(s, rowlength);
  i := 1;
  c := '0';
  s := '';
  ln := Random(512);
  row := 0;
  while i <= ln do
  begin
    if c > #95 then
    begin
      c := '0';
    end;
    if i mod (rowlength + 1) = 0 then
    begin
      s := s + #13;
      c := chr(ord('0') + row mod (95 - ord('0')));
      inc(row);
    end
    else
    begin
      s := s + c;
    end;
    inc(i);
    inc(c);
  end;
  SetLength(Result, rowlength);
  CopyMemory(Result, @s[1], rowlength);
  DoneMessage(ClassName);
end;

constructor TBaseHandler.Create(logger: ILogger);
begin
  inherited Create();
  FLogger := logger;
end;

constructor TDaytimeHandler.Create(logger: ILogger);
begin
  inherited Create(logger);
end;

function TDaytimeHandler.Process(packet: DynamicByteArray): DynamicByteArray;
var
  sDateTime: string;
begin
  StartMessage(ClassName);

  sDateTime := FLogger.LogPrefix;
  SetLength(Result, length(sDateTime));
  CopyMemory(Result, @sDateTime[1], length(sDateTime));

  DoneMessage(ClassName);
end;

procedure TBaseHandler.DoneMessage(message: string);
begin
  FLogger.Log(message + ' is done');
end;

procedure TBaseHandler.StartMessage(message: string);
begin
  FLogger.Log(message + ' is starting ...');
end;

constructor TSearchHandler.Create(logger: ILogger);
begin
  inherited Create(logger);
  FSearchPattern := 'WhereAreYou.01';
  FResponsePattern := 'WhereAreYou.02003056600127    192.168.001.020 255.255.255.000 Vi '
  +'                                                             FESTO IPC V2.24                                                 (c)1998-2000 FESTO TCP/IP Driver v1.10                          HC2X        ';
//  FResponsePattern := 'WhereAreYou.02C62AD328CFE5    020.020.020.020 020.020.020.020 TCP/IP App'
//  +'                                                      '
//  +'Windows NT'
//  +'                                                                                                                                  ';
end;

function TSearchHandler.Process(packet: DynamicByteArray): DynamicByteArray;
var
 // inputBuffer: string;
  inputLength: short;
  outputLength: short;
//  outputBuffer: DynamicByteArray;
//  RESPONSE_STRING: string;
//const

  //RESPONSE_STRING = 'WhereAreYou.02003056600127    010.020.000.004 255.255.255.000 C2                                                              FESTO IPC V2.24                                                 (c)1998-2000 FESTO TCP/IP Driver v1.10                          HC2X        ';
  //RESPONSE_STRING = 'WhereAreYou.02%s    %s %s %s                                                              FESTO IPC V2.24                                                 (c)1998-2000 FESTO TCP/IP Driver v1.10                          HC2X        ';
//  RESPONSE_STRING: string = 'WhereAreYou.02003056600127    010.000.020.015 255.000.000.000 Vi'+'                                                              FESTO IPC V2.24                                                 (c)1998-2000 FESTO TCP/IP Driver v1.10                          HC2X        ';
begin
  StartMessage(ClassName);
  inputLength := length(packet);
  SetLength(FBuffer, inputLength);
  CopyMemory(@FBuffer[1], packet, inputLength);
  FLogger.Log('packet length: %d', [inputLength]);
  FLogger.Log('packet: %s', [FBuffer]);
  if FBuffer = FSearchPattern then
  begin
    outputLength := Length(FResponsePattern);
    SetLength(Result, outputLength);
    CopyMemory(Result, @FResponsePattern, outputLength);
    FLogger.Log('result length: %d', [outputLength]);
    FLogger.Log('result: %s', [FResponsePattern]);
  end;
  DoneMessage(ClassName);
end;

end.

