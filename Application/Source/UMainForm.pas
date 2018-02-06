unit UMainForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  eiTypes,
  UTypes,
  UDefaultPresenter,
  UHelperThread,
  StdCtrls,
  ComCtrls;

type
  TmainForm = class(TForm, IView)
    btnRefresh: TButton;
    comboDataType: TComboBox;
    editHost: TEdit;
    editOffset: TEdit;
    editValue: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    pager: TPageControl;
    sheetBlockRead: TTabSheet;
    sheetInfo: TTabSheet;
    sheetOnePoint: TTabSheet;
    statusBar: TStatusBar;
    memoInfo: TMemo;
    procedure btnRefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FPresenter: IPresenter;
    FThread: THelperThread;
    function GetAddress: int;
    function GetDataType: DataTypeEnum;
    function GetHost: string;
    function GetViewMode: ViewModeEnum;
    procedure SetStatus(const value: string);
    procedure SetValue(const value: Integer);
  public
    procedure ClearStatus();
    procedure SetInfoValues(const values: TStrings);
    property Address: int read GetAddress;
    property DataType: DataTypeEnum read GetDataType;
    property Host: string read GetHost;
    property Status: string write SetStatus;
    property Value: Integer write SetValue;
    property ViewMode: ViewModeEnum read GetViewMode;
  end;

var
  mainForm: TmainForm;

implementation

{$R *.DFM}

procedure TmainForm.btnRefreshClick(Sender: TObject);
begin
  FPresenter.Refresh();
end;

procedure TmainForm.ClearStatus;
begin
  statusBar.SimpleText := '';
end;

procedure TmainForm.FormCreate(Sender: TObject);
begin
  comboDataType.ItemIndex := 1;
  FPresenter := TDefaultPresenter.Create(self);
end;

function TmainForm.GetAddress: int;
begin
  Result := StrToInt(editOffset.Text);
end;

function TmainForm.GetDataType: DataTypeEnum;
begin
  Result := DataTypeEnum(comboDataType.ItemIndex);
end;

function TmainForm.GetHost: string;
begin
  Result := editHost.Text;
end;

function TmainForm.GetViewMode: ViewModeEnum;
begin
  case pager.ActivePageIndex of
    0:
      Result := vmSingle;
    1:
      Result := vmBlock;
    2:
      Result := vmInfo;
  else
    Result := vmInfo;
  end;
end;

procedure TmainForm.SetInfoValues(const values: TStrings);
begin
  memoInfo.Lines := values;
end;

procedure TmainForm.SetStatus(const value: string);
begin
  statusBar.SimpleText := value;
  FThread := THelperThread.Create(true, self, htStatusClear);
  FThread.FreeOnTerminate := true;
  FThread.Resume();
end;

procedure TmainForm.SetValue(const value: Integer);
begin
  editValue.Text := IntToStr(value);
end;

end.
