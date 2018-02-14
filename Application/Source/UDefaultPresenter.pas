unit UDefaultPresenter;

interface

uses
  Windows,
  Classes,
  SysUtils,
  eiTypes,
  UTypes,
  UEasyIpService;

type
  TDefaultPresenter = class(TInterfacedObject, IPresenter)
  private
    FPlcService: IPlcService;
    FView: IView;
    procedure Refresh;
    procedure RefreshBlock;
    procedure RefreshInfo;
    procedure RefreshSingle;
  public
    constructor Create(view: IView); overload;
    constructor Create(view: IView; plcService: IPlcService); overload;
  end;

implementation

constructor TDefaultPresenter.Create(view: IView);
begin
  inherited Create;
  Self.Create(view, TEasyIpPlcService.Create);
end;

constructor TDefaultPresenter.Create(view: IView; plcService: IPlcService);
begin
  FView := view;
  FPlcService := plcService;
end;

procedure TDefaultPresenter.Refresh;
begin
  case FView.ViewMode of
    vmSingle:
      RefreshSingle();
    vmBlock:
      RefreshBlock();
    vmInfo:
      RefreshInfo();
  end;
end;

procedure TDefaultPresenter.RefreshBlock;
var
  returned: DynamicWordArray;
  values: TStrings;
  i: int;
begin
  try
    FView.Status := 'Reading data block ...';
    FView.SetValues(TStringList.Create());
    returned := FPlcService.ReadBlock(FView.Host, FView.Address, FView.DataType, FView.Length);
    values := TStringList.Create();
    for i := 0 to Length(returned) - 1 do
      values.Add('FW' + IntToStr(FView.Address + i) + ' - ' + IntToStr(returned[i]));
    FView.SetValues(values);
    values.Free();
  except
    on Ex: Exception do
      FView.Status := Ex.Message;
  end;
end;

procedure TDefaultPresenter.RefreshInfo;
var
  returned: EasyIpInfoPacket;
  values: TStrings;
  plcType: string;
  operandSizes: string;
  i: int;
begin
  try
    FView.Status := 'Reading device info ...';
    FView.SetInfoValues(TStringList.Create());
    returned := FPlcService.ReadInfo(FView.Host);
    values := TStringList.Create();
    with values, returned do
    begin
      case ControllerType of
        1:
          plcType := 'FST';
        2:
          plcType := 'MWT';
        3:
          plcType := 'DOS';
      else
        plcType := 'Unknown';
      end;
      Append('Controller type - ' + plcType);
      Append('Controller version - ' + IntToHex(ControllerRevisionHigh, 2) + '.' + IntToHex(ControllerRevisioLow, 2));
      Append('EasyIp version - ' + IntToStr(EasyIpRevisionHigh) + '.' + IntToStr(EasyIpRevisionLow));
      operandSizes := 'Operand sizes - ' + #13#10;
      for i := 1 to Length(OperandSize) do
        operandSizes := operandSizes + IntToStr(OperandSize[i]) + #13#10;
      Append(operandSizes);
    end;
    FView.SetInfoValues(values);
    values.Free();
  except
    on Ex: Exception do
      FView.Status := Ex.Message;
  end;
end;

procedure TDefaultPresenter.RefreshSingle;
var
  returned: Word;
begin
  try
    FView.Status := 'Reading single value ...';
    returned := FPlcService.Read(FView.Host, FView.Address, FView.DataType);
    FView.Value := returned;
  except
    on Ex: Exception do
      FView.Status := Ex.Message;
  end;
end;

end.

