unit UTypes;

interface
uses
  eiTypes;

type
  ViewModeEnum = (vmSingle, vmBlock, vmInfo);

  IView = interface
    function GetAddress: int;
    function GetDataType: DataTypeEnum;
    function GetHost: string;
    function GetViewMode: ViewModeEnum; 
    procedure SetStatus(const value: string);
    procedure SetValue(const value: Integer);
    property Address: int read GetAddress;
    property DataType: DataTypeEnum read GetDataType;
    property Host: string read GetHost;
    property Status: string write SetStatus;
    property Value: Integer write SetValue;
    property ViewMode: ViewModeEnum read GetViewMode;
  end;

  IPresenter = interface
    procedure Refresh;
  end;

  IPlcService = interface
    function Read(host: string; offset: Integer; dataType: DataTypeEnum): Word;
  end;

implementation

end.

