{******************************************************************************}
{                                                                              }
{   EasyIp communication Library                                               }
{   Shared constants unit                                                      }
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

unit eiConstants;

interface

uses
  eiTypes;

const
  SHORT_SIZE = sizeof(short);
  EASYIP_PORT = 995;
  //
  EASYIP_HEADERSIZE = 20;
  EASYIP_DATASIZE = 256;
  //
  EASYIP_FLAG_INFO = $01;
  EASYIP_FLAG_BIT_OR = $02;
  EASYIP_FLAG_BIT_AND = $04;
  EASYIP_FLAG_NOACK = $40;
  EASYIP_FLAG_RESPONSE = $80;
  //
  EASYIP_ERROR_OPERAND = $01;
  EASYIP_ERROR_OFFSET = $02;
  EASYIP_ERROR_DATASIZE = $04;
  EASYIP_ERROR_NOSUPPORT = $10;
  //
  EASYIP_TYPE_FLAGWORD = 1;
  EASYIP_TYPE_INPUTWORD = 2;
  EASYIP_TYPE_OUTPUTWORD = 3;
  EASYIP_TYPE_REGISTER = 4;
  EASYIP_TYPE_TIMER = 5;
  EASYIP_TYPE_STRING = 11;
  CHANNEL_DEFAULT_TIMEOUT = 2000;
  WINSOCK_VERSION = $0202;
//  LANG_ID = $400;
  LANG_ID = $0409;
  //
  EASYIP_SIZE = SizeOf(EasyIpPacket);

resourcestring
  DEBUG_MESSAGE_DESTROY = '%s is destroyed';
  DEBUG_MESSAGE_CREATE = '%s is created';

implementation

end.

