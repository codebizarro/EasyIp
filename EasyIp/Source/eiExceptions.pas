{******************************************************************************}
{                                                                              }
{   EasyIp communication Library                                               }
{   Custom exceptions unit                                                     }
{                                                                              }
{   Copyright 2017-2018 Artem Rudenko                                          }
{                                                                              }
{   Licensed under the Apache License, Version 2.0 (the "License");            }
{   you may not use this file except in compliance with the License.           }
{   You may obtain a copy of the License at                                    }
{                                                                              }
{       http://www.apache.org/licenses/LICENSE-2.0                             }
{                                                                              }
{   Unless required by applicable law or agreed to in writing, software        }
{   distributed under the License is distributed on an "AS IS" BASIS,          }
{   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   }
{   See the License for the specific language governing permissions and        }
{   limitations under the License.                                             }
{                                                                              }
{******************************************************************************}

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

