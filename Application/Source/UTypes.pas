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
    procedure SetInfoValues(const values: TStrings);
    procedure SetStatus(const value: string);
    procedure SetValue(const value: Integer);
    procedure SetValues(const values: TStrings);
    property Address: int read GetAddress;
    property DataType: DataTypeEnum read GetDataType;
    property Host: string read GetHost;
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

implementation

end.

