unit UTestParams;

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
  StdCtrls;

type
  TTestParams = class(TForm)
    ipList: TListBox;
    btOk: TButton;
    btCancel: TButton;
    function GetSelectedAddress: string;
    procedure FormCreate(Sender: TObject);
    procedure ipListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    property SelectedAddress: string read GetSelectedAddress;
  end;

implementation

{$R *.DFM}

procedure TTestParams.FormCreate(Sender: TObject);
begin
  ipList.Items.Clear();
  ipList.Items.Add('127.0.0.1');
  ipList.Items.Add('10.20.0.104');
  ipList.Items.Add('10.20.5.72');
end;

function TTestParams.GetSelectedAddress: string;
begin
  Result := ipList.Items[ipList.ItemIndex];
end;

procedure TTestParams.ipListDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.

