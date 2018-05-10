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
  USettings,
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
    listValues: TListBox;
    memoInfo: TMemo;
    pager: TPageControl;
    sheetBlockRead: TTabSheet;
    sheetInfo: TTabSheet;
    sheetOnePoint: TTabSheet;
    spinLength: TSpinEdit;
    statusBar: TStatusBar;
    btnWrite: TButton;
    procedure btnRefreshClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPresenter: IPresenter;
    FSettings: ISettings;
    FThread: THelperThread;
    function GetAddress: int;
    function GetDataType: DataTypeEnum;
    function GetHost: string;
    function GetLength: byte;
    function GetStatus: string;
    function GetValue: Integer;
    function GetViewMode: ViewModeEnum;
    procedure SetAddress(const value: int);
    procedure SetHost(const value: string);
    procedure SetLength(const value: byte);
    procedure SetStatus(const value: string);
    procedure SetValue(const value: Integer);
    procedure SetValues(const values: TStrings);
  public
    procedure ClearStatus();
    procedure SetInfoValues(const values: TStrings);
    property Address: int read GetAddress write SetAddress;
    property DataType: DataTypeEnum read GetDataType;
    property Host: string read GetHost write SetHost;
    property Length: byte read GetLength write SetLength;
    property Status: string read GetStatus write SetStatus;
    property Value: Integer read GetValue write SetValue;
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

procedure TmainForm.btnWriteClick(Sender: TObject);
begin
  FPresenter.WriteSingle();
end;

procedure TmainForm.ClearStatus;
begin
  statusBar.SimpleText := '';
end;

procedure TmainForm.FormCreate(Sender: TObject);
begin
  comboDataType.ItemIndex := 1;
  FPresenter := TDefaultPresenter.Create(self);
  FSettings := TSettings.Create();
  FSettings.Load(Self);
  FThread := THelperThread.Create(true, self, htStatusClear);
  FThread.FreeOnTerminate := true;
  FThread.Resume();
end;

procedure TmainForm.FormDestroy(Sender: TObject);
begin
  FThread.Terminate();
  FPresenter := nil;
  FSettings.Save(Self);
  FSettings := nil;
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

function TmainForm.GetValue: Integer;
begin
  Result := StrToInt(editValue.Text);
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

procedure TmainForm.SetAddress(const value: int);
begin
  editOffset.Text := IntToStr(value);
end;

procedure TmainForm.SetHost(const value: string);
begin
  editHost.Text := value;
end;

procedure TmainForm.SetInfoValues(const values: TStrings);
begin
  memoInfo.Lines := values;
end;

procedure TmainForm.SetLength(const value: byte);
begin
  spinLength.Value := value;
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

initialization
  RegisterClass(TLabel);

end.

