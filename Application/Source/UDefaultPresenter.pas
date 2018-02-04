unit UDefaultPresenter;

interface

uses
  Windows,
  SysUtils,
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
begin
  // TODO -cMM: TDefaultPresenter.RefreshBlock default body inserted
    FView.Status := 'Reading data block ...';
end;

procedure TDefaultPresenter.RefreshInfo;
begin
  // TODO -cMM: TDefaultPresenter.RefreshInfo default body inserted
      FView.Status := 'Reading device info ...';
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

