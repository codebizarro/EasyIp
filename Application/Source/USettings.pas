unit USettings;

interface

uses
  Windows,
  classes,
  SysUtils,
  Forms,
  IniFiles,
  UTypes;

type
  TSettings = class(TInterfacedObject, ISettings)
  private
    FIniFile: TIniFile;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load(view: IView);
    procedure Save(view: IView);
  end;

implementation

const
  SECTION_DEVICE = 'DEVICE';
  PARAM_HOST = 'Host';
  PARAM_ADDRESS = 'Address';
  PARAM_LENGTH = 'Length';

constructor TSettings.Create;
var
  iniFileName: string;
begin
  inherited;
  iniFileName := ChangeFileExt(ParamStr(0), '.ini');
  FIniFile := TIniFile.Create(iniFileName);
end;

destructor TSettings.Destroy;
begin
  FIniFile.Free();
  inherited;
end;

{ TSettings }

procedure TSettings.Load(view: IView);
begin
  view.Host := FIniFile.ReadString(SECTION_DEVICE, PARAM_HOST, '');
  view.Address := FIniFile.ReadInteger(SECTION_DEVICE, PARAM_ADDRESS, 0);
  view.Length :=  FIniFile.ReadInteger(SECTION_DEVICE, PARAM_LENGTH, 1);
end;

procedure TSettings.Save(view: IView);
begin
  FIniFile.WriteString(SECTION_DEVICE, PARAM_HOST, view.Host);
  FIniFile.WriteInteger(SECTION_DEVICE, PARAM_ADDRESS, view.Address);
  FIniFile.WriteInteger(SECTION_DEVICE, PARAM_LENGTH, view.Length);
end;

end.

