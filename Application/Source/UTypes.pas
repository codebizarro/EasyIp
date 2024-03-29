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
    function GetValue: Integer;
    function GetViewMode: ViewModeEnum;
    procedure SetAddress(const value: int);
    procedure SetHost(const value: string);
    procedure SetInfoValues(const values: TStrings);
    procedure SetLength(const value: byte);
    procedure SetStatus(const value: string);
    procedure SetValue(const value: Integer);
    procedure SetValues(const values: TStrings);
    property Address: int read GetAddress write SetAddress;
    property DataType: DataTypeEnum read GetDataType;
    property Host: string read GetHost write SetHost;
    property Length: byte read GetLength write SetLength;
    property Status: string read GetStatus write SetStatus;
    property Value: Integer read GetValue write SetValue;
    property ViewMode: ViewModeEnum read GetViewMode;
  end;

  IPresenter = interface
    procedure Refresh;
    procedure WriteSingle;
  end;

  IPlcService = interface
    function Read(host: string; offset: Integer; dataType: DataTypeEnum): Word;
    function ReadBlock(host: string; offset: Integer; dataType: DataTypeEnum; length: byte): DynamicWordArray;
    function ReadInfo(host: string): EasyIpInfoPacket;
    procedure Write(host: string; offset: Integer; dataType: DataTypeEnum; value: Word);
  end;

  ISettings = interface
    procedure Load(view: IView);
    procedure Save(view: IView);
  end;

implementation

end.

