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
    function GetData(offset: int; count: byte): DynamicWordArray;
    procedure SetData(offset: int; data: DynamicWordArray);
    function TryGetData(offset: int; count: byte; out OutResult): DynamicWordArray;
    procedure TrySetData(offset: int; data: DynamicWordArray; out OutResult);
  end;

implementation

function TBaseDevice.GetData(offset: int; count: byte): DynamicWordArray;
begin

end;

procedure TBaseDevice.SetData(offset: int; data: DynamicWordArray);
begin

end;

function TBaseDevice.TryGetData(offset: int; count: byte; out OutResult): DynamicWordArray;
begin

end;

procedure TBaseDevice.TrySetData(offset: int; data: DynamicWordArray; out OutResult);
begin

end;

end.

