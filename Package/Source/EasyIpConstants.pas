unit EasyIpConstants;

interface

uses
  EasyIpCommonTypes;

const
  SHORT_SIZE: byte = sizeof(short);
  EASYIP_PORT: int = 995;
  //
  EASYIP_HEADERSIZE: int = 20;
  EASYIP_DATASIZE: int = 256;
  //
  EASYIP_FLAG_INFO: byte = $01;
  EASYIP_FLAG_BIT_OR: byte = $02;
  EASYIP_FLAG_BIT_AND: byte = $04;
  EASYIP_FLAG_NOACK: byte = $40;
  EASYIP_FLAG_RESP: byte = $80;
  //
  EASYIP_ERROR_OPERAND: byte = $01;
  EASYIP_ERROR_OFFSET: byte = $02;
  EASYIP_ERROR_DATASIZE: byte = $04;
  EASYIP_ERROR_NOSUPPORT: byte = $10;
  //
  EASYIP_TYPE_FLAGWORD: byte = 1;
  EASYIP_TYPE_INPUTWORD: byte = 2;
  EASYIP_TYPE_OUTPUTWORD: byte = 3;
  EASYIP_TYPE_REGISTERS: byte = 4;
  EASYIP_TYPE_STRINGS: byte = 11;

implementation

end.

