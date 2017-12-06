unit EasyIpChannel;

interface

uses
  EasyIpCommonTypes;

type
  IChannel = interface
    function Execute(buffer: TByteArray): TByteArray;
  end;

implementation

end.

