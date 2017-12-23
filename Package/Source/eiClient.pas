unit eiClient;

interface

uses
  eiTypes,
  eiConstants,
  eiExceptions,
  eiProtocol,
  eiHelpers,
  eiChannel,
  Classes,
  SysUtils,
  Windows;

type
  TEasyIpClient = class(TInterfacedObject, IEasyIpProtocol, IEasyIpChannel, IEasyIpClient)
  private
    FProtocol: IEasyIpProtocol;
    FChannel: IEasyIpChannel;
    FHost: string;
    function GetChannel: IEasyIpChannel;
    function GetProtocol: IEasyIpProtocol;
    property Channel: IEasyIpChannel read GetChannel implements IEasyIpChannel;
    property Protocol: IEasyIpProtocol read GetProtocol implements IEasyIpProtocol;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function BlockRead(offset: short; dataType: DataTypeEnum; length: byte): DynamicWordArray;
    procedure BlockWrite(offset: short; value: DynamicWordArray; dataType: DataTypeEnum);
  published
    property Host: string read FHost write FHost;
  end;

implementation

function TEasyIpClient.BlockRead(offset: short; dataType: DataTypeEnum;
  length: byte): DynamicWordArray;
begin

end;

procedure TEasyIpClient.BlockWrite(offset: short; value: DynamicWordArray;
  dataType: DataTypeEnum);
begin

end;

constructor TEasyIpClient.Create;
begin
  inherited;
  // TODO: create
end;

destructor TEasyIpClient.Destroy;
begin
  inherited;
  // TODO: destroy
end;

function TEasyIpClient.GetChannel: IEasyIpChannel;
begin
  if Assigned(FChannel) then
    Result := FChannel
  else
    Result := TEasyIpChannel.Create;
end;

function TEasyIpClient.GetProtocol: IEasyIpProtocol;
begin
  if Assigned(FProtocol) then
    Result := FProtocol
  else
    Result := TEasyIpProtocol.Create(pmRead);
end;

end.

