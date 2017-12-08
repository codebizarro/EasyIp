unit EasyIpChannel;

interface

uses
  EasyIpCommonTypes;

type
  IChannel = interface
    function Execute(buffer: TByteArray): TByteArray;
  end;

  TCustomChannel = class(TInterfacedObject, IChannel)
  private
  protected
    FHost: string;
    FPort: int;
  public
    constructor Create(host: string; port: int); overload;
    function Execute(buffer: TByteArray): TByteArray; virtual; abstract;
  end;

  TMockChannel = class(TCustomChannel)
  private
  protected
  public
    destructor Destroy; override;
    function Execute(buffer: TByteArray): TByteArray; override;
  end;

implementation

constructor TCustomChannel.Create(host: string; port: int);
begin
  inherited Create;
  FHost := host;
  FPort := port;
end;

destructor TMockChannel.Destroy;
begin
  inherited;

end;

function TMockChannel.Execute(buffer: TByteArray): TByteArray;
var
  temp: TByteArray;
begin
  SetLength(temp, Length(buffer));
  temp := Copy(buffer, 0, Length(buffer));
  temp[0] := $80;
  Result := temp;
end;

end.

