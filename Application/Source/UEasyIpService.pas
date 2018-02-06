unit UEasyIpService;

interface

uses
  UTypes,
  eiClient,
  eiTypes;

type
  TEasyIpPlcService = class(TInterfacedObject, IPlcService)
  private
    FClient: TEasyIpClient;
    function Read(host: string; offset: Integer; dataType: DataTypeEnum): Word;
    function ReadBlock(host: string; offset: Integer; dataType: DataTypeEnum; length: byte): DynamicWordArray;
    function ReadInfo(host: string): EasyIpInfoPacket;
  public
    constructor Create;
  end;

implementation

constructor TEasyIpPlcService.Create;
begin
  inherited Create;
end;

function TEasyIpPlcService.Read(host: string; offset: Integer; dataType: DataTypeEnum): Word;
begin
  FClient := TEasyIpClient.Create(host);
  Result := FClient.WordRead(offset, dtFlag);
end;

function TEasyIpPlcService.ReadBlock(host: string; offset: Integer; dataType: DataTypeEnum; length: byte): DynamicWordArray;
begin
  FClient := TEasyIpClient.Create(host);
  Result := FClient.BlockRead(offset, dataType, length);
end;

function TEasyIpPlcService.ReadInfo(host: string): EasyIpInfoPacket;
begin
  FClient := TEasyIpClient.Create(host);
  Result := FClient.InfoRead();
end;

end.

