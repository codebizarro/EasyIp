unit EasyIpExceptions;

interface

uses
  SysUtils,
  EasyIpConstants;

type
  TEasyIpError = Byte;

  EEasyIpException = class(Exception);

  EDataSizeOverflow = class(EEasyIpException);

  ERequestedDataSize = class(EEasyIpException);

  EOperand = class(EEasyIpException);

  EOffset = class(EEasyIpException);

  ENoSupport = class(EEasyIpException);

  EDataSize = class(EEasyIpException);

  EGeneral = class(EEasyIpException)
  private
    FInnerException: EEasyIpException;
  public
    constructor Create(message: string; innerException: EEasyIpException);
    property InnerException: EEasyIpException read FInnerException write FInnerException;
  end;

  TEasyIpErrors = class
    class function CreateMessage(error: TEasyIpError): string;
    class function CreateException(error: TEasyIpError): EEasyIpException;
  end;

implementation

class function TEasyIpErrors.CreateException(error: TEasyIpError): EEasyIpException;
begin
  case error of
    EASYIP_ERROR_OPERAND:
      Result := EOperand.Create(self.CreateMessage(error));
    EASYIP_ERROR_OFFSET:
      Result := EOffset.Create(self.CreateMessage(error));
    EASYIP_ERROR_DATASIZE:
      Result := EDataSize.Create(self.CreateMessage(error));
    EASYIP_ERROR_NOSUPPORT:
      Result := ENoSupport.Create(self.CreateMessage(error));
  else
    Result := EEasyIpException.Create(self.CreateMessage(error));
  end;
end;

class function TEasyIpErrors.CreateMessage(error: TEasyIpError): string;
begin
  case error of
    EASYIP_ERROR_OPERAND:
      Result := 'EOperand exception';
    EASYIP_ERROR_OFFSET:
      Result := 'EOffset exception';
    EASYIP_ERROR_DATASIZE:
      Result := 'EDataSize exception';
    EASYIP_ERROR_NOSUPPORT:
      Result := 'ENoSupport exception';
  else
    Result := 'EEasyIpException exception';
  end;
end;

constructor EGeneral.Create(message: string; innerException: EEasyIpException);
begin
  inherited Create(message);
  FInnerException := innerException;
end;

end.

