unit UTypes;

interface

uses
  Classes,
  eiTypes;

type
  ViewModeEnum = (vmSingle, vmBlock, vmInfo);

  HelperTypeEnum = (htNone, htStatusClear);

  IView = interface
    procedure ClearStatus();
    function GetAddress: int;
    function GetDataType: DataTypeEnum;
    function GetHost: string;
    function GetLength: byte;
    function GetStatus: string;
    function GetViewMode: ViewModeEnum;
    procedure SetAddress(const value: int);
    procedure SetHost(const value: string);
    procedure SetInfoValues(const values: TStrings);
    procedure SetStatus(const value: string);
    procedure SetValue(const value: Integer);
    procedure SetValues(const values: TStrings);
    property Address: int read GetAddress write SetAddress;
    property DataType: DataTypeEnum read GetDataType;
    property Host: string read GetHost write SetHost;
    property Length: byte read GetLength;
    property Status: string read GetStatus write SetStatus;
    property Value: Integer write SetValue;
    property ViewMode: ViewModeEnum read GetViewMode;
  end;

  IPresenter = interface
    procedure Refresh;
  end;

  IPlcService = interface
    function Read(host: string; offset: Integer; dataType: DataTypeEnum): Word;
    function ReadBlock(host: string; offset: Integer; dataType: DataTypeEnum; length: byte): DynamicWordArray;
    function ReadInfo(host: string): EasyIpInfoPacket;
  end;

  ISettings = interface
    procedure Load(view: IView);
    procedure Save(view: IView);
  end;

implementation

end.

