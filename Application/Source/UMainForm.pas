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
  ComCtrls,
  Spin;

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
    Label6: TLabel;
    Label7: TLabel;
    listValues: TListBox;
    memoInfo: TMemo;
    pager: TPageControl;
    sheetBlockRead: TTabSheet;
    sheetInfo: TTabSheet;
    sheetOnePoint: TTabSheet;
    spinLength: TSpinEdit;
    statusBar: TStatusBar;
    procedure FormDestroy(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FPresenter: IPresenter;
    FThread: THelperThread;
    function GetAddress: int;
    function GetDataType: DataTypeEnum;
    function GetHost: string;
    function GetLength: byte;
    function GetStatus: string;
    function GetViewMode: ViewModeEnum;
    procedure SetStatus(const value: string);
    procedure SetValue(const value: Integer);
    procedure SetValues(const values: TStrings);
  public
    procedure ClearStatus();
    procedure SetInfoValues(const values: TStrings);
    property Address: int read GetAddress;
    property DataType: DataTypeEnum read GetDataType;
    property Host: string read GetHost;
    property Length: byte read GetLength;
    property Status: string read GetStatus write SetStatus;
    property Value: Integer write SetValue;
    property ViewMode: ViewModeEnum read GetViewMode;
  end;

var
  mainForm: TmainForm;

implementation

{$R *.DFM}

procedure TmainForm.FormDestroy(Sender: TObject);
begin
  FThread.Terminate();
  FPresenter := nil;
end;

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
  FThread := THelperThread.Create(true, self, htStatusClear);
  FThread.FreeOnTerminate := true;
  FThread.Resume();
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

function TmainForm.GetLength: byte;
begin
  Result := spinLength.Value;
end;

function TmainForm.GetStatus: string;
begin
  Result := statusBar.SimpleText;
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
end;

procedure TmainForm.SetValue(const value: Integer);
begin
  editValue.Text := IntToStr(value);
end;

procedure TmainForm.SetValues(const values: TStrings);
begin
  listValues.Items := values;
end;

end.

