unit UHelperThread;

interface

uses
  Windows,
  Classes,
  UTypes;

type
  THelperThread = class(TThread)
  private
    FView: IView;
    FHelperType: HelperTypeEnum;
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
end;

destructor THelperThread.Destroy;
begin
  FView := nil;
  inherited;
end;

procedure THelperThread.ClearStatus;
begin
  FView.ClearStatus();
end;

procedure THelperThread.Execute;
begin
  case FHelperType of
    htNone:
      Self.Terminate;
    htStatusClear:
      begin
        Sleep(2000);
        Synchronize(ClearStatus);
        Self.Terminate;
      end;
  end;
end;

end.

