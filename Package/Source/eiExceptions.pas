unit eiExceptions;

interface

uses
  SysUtils,
  eiConstants;

type
  TEasyIpError = Byte;

  ESocketException = class(Exception);

  EEasyIpException = class(Exception);

  EGeneralException = class(EEasyIpException)
  private
    FInnerException: EEasyIpException;
  public
    constructor Create(message: string; innerException: EEasyIpException);
    property InnerException: EEasyIpException read FInnerException write FInnerException;
  end;

  EDataSizeOverflow = class(EEasyIpException);

  ERequestedDataSize = class(EEasyIpException);

  EOperandException = class(EEasyIpException);

  EOffsetException = class(EEasyIpException);

  ENoSupportException = class(EEasyIpException);

  EDataSizeException = class(EEasyIpException);

  TEasyIpErrors = class
    class function CreateMessage(error: TEasyIpError): string;
    class function CreateException(error: TEasyIpError): EEasyIpException;
  end;

implementation

class function TEasyIpErrors.CreateException(error: TEasyIpError): EEasyIpException;
begin
  case error of
    EASYIP_ERROR_OPERAND:
      Result := EOperandException.Create(self.CreateMessage(error));
    EASYIP_ERROR_OFFSET:
      Result := EOffsetException.Create(self.CreateMessage(error));
    EASYIP_ERROR_DATASIZE:
      Result := EDataSizeException.Create(self.CreateMessage(error));
    EASYIP_ERROR_NOSUPPORT:
      Result := ENoSupportException.Create(self.CreateMessage(error));
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

constructor EGeneralException.Create(message: string; innerException: EEasyIpException);
begin
  inherited Create(message);
  FInnerException := innerException;
end;

end.

