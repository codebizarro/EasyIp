unit UDevices;

interface

uses
  Windows,
  Classes,
  eiTypes,
  eiHelpers,
  eiProtocol,
  eiConstants,
  UServerTypes,
  ULogger;

type
  TBaseDevice = class(TInterfacedObject)
  private
    FLogger: ILogger;
  public
//    function BlockRead(const offset: short; const dataType: DataTypeEnum; const length: byte): DynamicWordArray; virtual; abstract;
//    procedure BlockWrite(const offset: short; const value: DynamicWordArray; const dataType: DataTypeEnum); virtual; abstract;
  end;

  TEasyIpDevice = class(TBaseDevice, IDevice)
  private
    FFlags: array[0..9999] of short;
    FInputs: array[0..255] of short;
    FOutputs: array[0..255] of short;
    FRegisters: array[0..255] of short;
    FTimers: array[0..255] of short;
  public
    constructor Create(logger: ILogger);
    function BlockRead(const offset: short; const dataType: DataTypeEnum; const dataLength: byte): DynamicWordArray;
    procedure BlockWrite(const offset: short; const value: DynamicWordArray; const dataType: DataTypeEnum);
    function RangeCheck(const offset: short; const dataType: DataTypeEnum; const dataLength: byte): short;
  end;

implementation

constructor TEasyIpDevice.Create(logger: ILogger);
begin
  inherited Create;
  FLogger := logger;
end;

function TEasyIpDevice.BlockRead(const offset: short; const dataType: DataTypeEnum; const dataLength: byte): DynamicWordArray;
var
  resultArray: DynamicWordArray;
  copyLength: int;
begin
  SetLength(resultArray, dataLength);
  copyLength := dataLength * SHORT_SIZE;
  case dataType of
    dtFlag:
      CopyMemory(resultArray, @FFlags[offset], copyLength);
    dtInput:
      CopyMemory(resultArray, @FInputs[offset], copyLength);
    dtOutput:
      CopyMemory(resultArray, @FOutputs[offset], copyLength);
    dtRegister:
      CopyMemory(resultArray, @FRegisters[offset], copyLength);
    dtTimer:
      CopyMemory(resultArray, @FTimers[offset], copyLength);
  end;
//  FLogger.Log('Read device value: %d', [FFlags[offset]]);
  Result := resultArray;
end;

procedure TEasyIpDevice.BlockWrite(const offset: short; const value: DynamicWordArray; const dataType: DataTypeEnum);
var
  copyLength: int;
begin
  copyLength := Length(value) * 2;
  case dataType of
    dtFlag:
      CopyMemory(@FFlags[offset], value, copyLength);
    dtInput:
      CopyMemory(@FInputs[offset], value, copyLength);
    dtOutput:
      CopyMemory(@FOutputs[offset], value, copyLength);
    dtRegister:
      CopyMemory(@FRegisters[offset], value, copyLength);
    dtTimer:
      CopyMemory(@FTimers[offset], value, copyLength);
  end;
//  FLogger.Log('Write device value: %d', [FFlags[offset]]);
end;

function TEasyIpDevice.RangeCheck(const offset: short; const dataType: DataTypeEnum; const dataLength: byte): short;
var
  summaryLength: int;
  returnFlag: short;
begin
  returnFlag := 0;
  summaryLength := offset + dataLength;

  if dataLength > High(byte) then
    returnFlag := returnFlag or EASYIP_ERROR_DATASIZE;

  case dataType of
    dtFlag:
      begin
        if Length(FFlags) < summaryLength then
          returnFlag := returnFlag or EASYIP_ERROR_OFFSET;
      end;
    dtInput:
      begin
        if Length(FInputs) < summaryLength then
          returnFlag := returnFlag or EASYIP_ERROR_OFFSET;
      end;
    dtOutput:
      begin
        if Length(FOutputs) < summaryLength then
          returnFlag := returnFlag or EASYIP_ERROR_OFFSET;
      end;
    dtRegister:
      begin
        if Length(FRegisters) < summaryLength then
          returnFlag := returnFlag or EASYIP_ERROR_OFFSET;
      end;
    dtTimer:
      begin
        if Length(FTimers) < summaryLength then
          returnFlag := returnFlag or EASYIP_ERROR_OFFSET;
      end;
  else
    returnFlag := returnFlag or EASYIP_ERROR_NOSUPPORT;
  end;

  Result := returnFlag;
end;

end.

