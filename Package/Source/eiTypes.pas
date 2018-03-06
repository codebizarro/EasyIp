{******************************************************************************}
{                                                                              }
{   EasyIp communication Library                                               }
{   Common types unit                                                          }
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

unit eiTypes;

interface

uses
  Classes,
  SysUtils;

type
  PDynamicByteArray = ^DynamicByteArray;

  DynamicByteArray = array of Byte;

  DynamicWordArray = array of Word;

  bool = Boolean;

  sbyte = ShortInt;

  short = Smallint;

  int = Integer;

  ushort = Word;

  uint = LongWord;

  float = Single;

  DataTypeEnum = (dtUndefined, dtFlag, dtInput, dtOutput, dtRegister, dtTimer, _6, _7, _8, _9, _10, dtString);
  //TODO: ^^^^^ (_6..._10) for delphi version less than 6

  PacketModeEnum = (pmRead, pmWrite, pmBit, pmInfo);

  BitModeEnum = (bmNormal, bmOr, bmAnd, bmXor);

  DataLength = 1..256;

  PEasyIpPacket = ^EasyIpPacket;

/// <summary>
/// Encapsulate EasyIP packet
/// </summary>
  EasyIpPacket = packed record
/// <summary>
/// 1 byte
/// Bit 0 information packet (request or response)
/// Bit 1-2 bit operations 1
/// Bit 6 do not respond
/// Bit 7 response packet
/// </summary>
    Flags: byte;
/// <summary>
/// 1 byte
/// Only used in response packets
/// 0: no error
/// 1: operand type error
/// 2: offset error
/// 4: size error
/// 16: no support
/// </summary>
    Error: byte;
/// <summary>
/// 4 bytes
/// Set by client, copied by server
/// </summary>
    Counter: int;
/// <summary>
/// 1 byte
/// Reserved
/// Set to 0
/// </summary>
    Spare1: byte;
/// <summary>
/// 1 byte
/// Type of operand, some types may not be available
/// 1 memory word
/// 2 input word
/// 3 output word
/// 4 register
/// 5 timer
/// 11 strings3
/// </summary>
    SendDataType: byte;
/// <summary>
/// 2 bytes
/// Number of words
/// </summary>
    SendDataSize: ushort;
/// <summary>
/// 2 bytes
/// Target offset in server
/// </summary>
    SendDataOffset: ushort;
/// <summary>
/// 1 byte
/// Reserved
/// Set to 0
    Spare2: byte;
/// <summary>
/// 1 byte
/// Type of operand, some types may not be available (see senddata type for list of types)
/// </summary>
    RequestDataType: byte;
/// <summary>
/// 2 bytes
/// Number of words
/// </summary>
    RequestDataSize: ushort;
/// <summary>
/// 2 bytes
/// Offset in server
/// </summary>
    RequestDataOffsetServer: ushort;
/// <summary>
/// 2 bytes
/// Target offset in client
/// </summary>
    RequestDataOffsetClient: ushort;
/// <summary>
/// N*2 bytes
/// Data send by client or requested data
/// </summary>
    Data: array[1..256] of ushort;
  end;

  PEasyIpInfoPacket = ^EasyIpInfoPacket;

  EasyIpInfoPacket = packed record
/// <summary>
/// Type of information packet, 1=packet with
/// controller and operand info.
/// </summary>
    InformationType: ushort;
/// <summary>
/// Type of controller: 1=FST, 2=MWT, 3=DOS etc
/// </summary>
    ControllerType: ushort;
    ControllerRevisionHigh: ushort;
    ControllerRevisioLow: ushort;
    EasyIpRevisionHigh: ushort;
    EasyIpRevisionLow: ushort;
/// <summary>
/// 0 if unavailable otherwise number of
/// operands supported
/// </summary>
    OperandSize: array[1..32] of ushort;
  end;

  IChannel = interface
    ['{D789650F-C76E-42B3-B358-D78E98AD82C7}']
    function GetTimeout: int;
    procedure SetTimeout(const value: int);
    function Execute(const buffer: DynamicByteArray): DynamicByteArray;
    property Timeout: int read GetTimeout write SetTimeout;
  end;

  INetworkChannel = interface(IChannel)
    ['{F5995BE4-509D-498D-9A4C-68AD721822DE}']
    function GetHost: string;
    function GetPort: int;
    procedure SetHost(const value: string);
    procedure SetPort(const value: int);
    property Host: string read GetHost write SetHost;
    property Port: int read GetPort write SetPort;
  end;

  IUdpChannel = interface(INetworkChannel)
    ['{C65D3A64-E4E8-4C4E-83AF-A670BEFFEACF}']
  end;

  IEasyIpChannel = interface(IUdpChannel)
    ['{D907A69A-7C89-404B-9F2A-7162E73596D0}']
    function Execute(const packet: EasyIpPacket): EasyIpPacket;
  end;

  IProtocol = interface
    ['{F48C0963-8ACD-4AC3-8911-B793DC2E94AC}']
    function GetBuffer: DynamicByteArray;
    property Buffer: DynamicByteArray read GetBuffer;
  end;

  IEasyIpProtocol = interface(IProtocol)
    ['{790B9B4C-8B13-4862-9035-7CEA97708CBA}']
    function GetBitMode: BitModeEnum;
    function GetPacket: EasyIpPacket;
    function GetDataLength: DataLength;
    function GetDataOffset: ushort;
    function GetDataType: DataTypeEnum;
    function GetMode: PacketModeEnum;
    procedure SetDataLength(const value: DataLength);
    procedure SetDataOffset(const value: ushort);
    procedure SetDataType(const value: DataTypeEnum);
    procedure SetBitMode(const value: BitModeEnum);
    procedure SetMode(const value: PacketModeEnum);
    property BitMode: BitModeEnum read GetBitMode write SetBitMode;
    property DataLength: DataLength read GetDataLength write SetDataLength;
    property DataOffset: ushort read GetDataOffset write SetDataOffset;
    property DataType: DataTypeEnum read GetDataType write SetDataType;
    property Mode: PacketModeEnum read GetMode write SetMode;
    property Packet: EasyIpPacket read GetPacket;
  end;

  IClient = interface
    ['{9D474F20-AAB6-4F67-90EC-31696084450E}']
  end;

  IEasyIpClient = interface(IClient)
    ['{5A5CB45B-B6D5-4916-B074-48FF471D8858}']
    function InfoRead(): EasyIpInfoPacket;
    function BlockRead(const offset: short; const dataType: DataTypeEnum; const length: byte): DynamicWordArray;
    procedure BlockWrite(const offset: short; const value: DynamicWordArray; const dataType: DataTypeEnum);
    function WordRead(const offset: short; const dataType: DataTypeEnum): short;
    procedure WordWrite(const offset: short; const value: short; const dataType: DataTypeEnum);
    procedure BitOperation(const offset: short; const dataType: DataTypeEnum; const mask: ushort; const bitMode: BitModeEnum);
    function GetHost: string;
    function GetPort: int;
    function GetTimeout: int;
    procedure SetHost(const value: string);
    procedure SetPort(const value: int);
    procedure SetTimeout(const value: int);
    property Host: string read GetHost write SetHost;
    property Port: int read GetPort write SetPort;
    property Timeout: int read GetTimeout write SetTimeout;
  end;

  TCustomClient = class(TComponent, IClient)
  private
  protected
  end;

  TExceptionEvent = procedure(Sender: TObject; E: Exception) of object;

implementation

end.

