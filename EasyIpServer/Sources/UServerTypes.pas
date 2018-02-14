unit UServerTypes;

interface

type
  ILogger = interface
    procedure Log(messageText: string);
  end;

  IEasyIpServer = interface
    procedure Run;
  end;

implementation

end.

