unit EasyIpChannel;

interface

uses
  EasyIpCommonTypes;

type
  IChannel = interface
    function Execute(buffer: TByteArray): TByteArray;
  end;

  TMockChannel = class(TInterfacedObject, IChannel)
  private
    FHost: string;
    FPort: int;
  protected
  public
    constructor Create(host: string; port: int); overload;
    destructor Destroy; override;
    function Execute(buffer: TByteArray): TByteArray;
  end;

implementation

constructor TMockChannel.Create(host: string; port: int);
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

