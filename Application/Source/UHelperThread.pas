unit UHelperThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  UTypes;

type
  THelperThread = class(TThread)
  private
    FView: IView;
    FHelperType: HelperTypeEnum;
    FPreviousStatus: string;
    procedure ClearStatus;
  protected
    procedure Execute; override;
  public
    constructor Create(createSuspended: bool; view: IView; helperType: HelperTypeEnum); overload;
    destructor Destroy; override;
  end;

implementation

constructor THelperThread.Create(createSuspended: bool; view: IView; helperType: HelperTypeEnum);
begin
  inherited Create(createSuspended);
  FView := view;
  FHelperType := helperType;
  FPreviousStatus := FView.Status;
end;

destructor THelperThread.Destroy;
begin
  FView := nil;
  inherited;
end;

procedure THelperThread.ClearStatus;
begin
  if (Length(FView.Status) > 0) and (FPreviousStatus = FView.Status) then
    FView.ClearStatus();
  FPreviousStatus := FView.Status;
end;

procedure THelperThread.Execute;
begin
  while true do
  begin
    case FHelperType of
      htNone:
        Self.Terminate;
      htStatusClear:
        begin
          Sleep(2000);
          Synchronize(ClearStatus);
        end;
    end;
  end;
end;

end.

