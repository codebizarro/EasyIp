unit UDevices;

interface

uses
  Windows,
  eiTypes,
  eiHelpers,
  eiProtocol,
  eiConstants,
  UServerTypes;

type
  TBaseDevice = class(TInterfacedObject, IDevice)
  private
  protected
  public
    function GetDataBlock(offset: int; count: byte): DynamicWordArray;
    procedure SetDataBlock(offset: int; data: DynamicWordArray);
    function TryGetDataBlock(offset: int; count: byte; out OutResult): DynamicWordArray;
    procedure TrySetDataBlock(offset: int; data: DynamicWordArray; out OutResult);
  end;

implementation

function TBaseDevice.GetDataBlock(offset: int; count: byte): DynamicWordArray;
begin

end;

procedure TBaseDevice.SetDataBlock(offset: int; data: DynamicWordArray);
begin

end;

function TBaseDevice.TryGetDataBlock(offset: int; count: byte; out OutResult): DynamicWordArray;
begin

end;

procedure TBaseDevice.TrySetDataBlock(offset: int; data: DynamicWordArray; out OutResult);
begin

end;

end.

