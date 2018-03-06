{******************************************************************************}
{                                                                              }
{   EasyIp communication Library                                               }
{   Transport layer unit                                                       }
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

unit eiChannel;

interface

uses
  eiTypes,
  eiConstants,
  eiExceptions,
  eiProtocol,
  eiHelpers,
  Classes,
  SysUtils,
  Windows,
  WinSock;

type
  TCustomChannel = class(TInterfacedObject, IChannel)
  private
    constructor Create;
    function GetTimeout: int;
    procedure SetDebug(const value: string);
    procedure SetTimeout(const value: int);
  protected
    FTimeout: int;
    property Debug: string write SetDebug;
  public
    destructor Destroy; override;
    function Execute(const buffer: DynamicByteArray): DynamicByteArray; virtual; abstract;
    property Timeout: int read GetTimeout write SetTimeout default CHANNEL_DEFAULT_TIMEOUT;
  end;

  TNetworkChannel = class(TCustomChannel, INetworkChannel)
  private
    function GetHost: string;
    function GetPort: int;
    procedure SetHost(const value: string);
    procedure SetPort(const value: int);
  protected
    FHost: string;
    FPort: int;
    FTarget: TSockAddrIn;
    function GetLastErrorString: string;
  public
    constructor Create(const host: string; const port: int); overload;
    destructor Destroy; override;
    property Host: string read GetHost write SetHost;
    property Port: int read GetPort write SetPort default EASYIP_PORT;
  end;

  TUdpChannel = class(TNetworkChannel, IUdpChannel)
  private
  protected
  public
    constructor Create(const host: string; const port: int); overload;
    destructor Destroy; override;
    function Execute(const buffer: DynamicByteArray): DynamicByteArray; overload; override;
  end;

  TMockChannel = class(TUdpChannel, IEasyIpChannel)
  private
  protected
  public
    destructor Destroy; override;
    function Execute(const buffer: DynamicByteArray): DynamicByteArray; overload; override;
    function Execute(const packet: EasyIpPacket): EasyIpPacket; overload;
  end;

  TEasyIpChannel = class(TUdpChannel, IEasyIpChannel)
  private
  protected
  public
    constructor Create(const host: string; const port: int = EASYIP_PORT); overload;
    destructor Destroy; override;
    function Execute(const packet: EasyIpPacket): EasyIpPacket; overload;
  end;

implementation

constructor TUdpChannel.Create(const host: string; const port: int);
begin
  inherited Create(host, port);
  Debug := Format(DEBUG_MESSAGE_CREATE, ['TUdpChannel']);
end;

destructor TMockChannel.Destroy;
begin
  Debug := Format(DEBUG_MESSAGE_DESTROY, ['TMockChannel']);
  inherited;
end;

destructor TUdpChannel.Destroy;
begin
  Debug := Format(DEBUG_MESSAGE_DESTROY, ['TUdpChannel']);
  inherited;
end;

function TUdpChannel.Execute(const buffer: DynamicByteArray): DynamicByteArray;
var
  init: TWSAData;
  sock: TSocket;
  returnCode: int;
  sendBuffer: DynamicByteArray;
  recvBuffer: DynamicByteArray;
  lenFrom: int;
begin
  try
    returnCode := WSAStartup(WINSOCK_VERSION, init);
    if returnCode <> 0 then
      raise ESocketException.Create(GetLastErrorString());
    try
      sock := Socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
      setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, @FTimeout, SizeOf(FTimeout));
      setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, @FTimeout, SizeOf(FTimeout));

      SetLength(sendBuffer, Length(buffer));
      SetLength(recvBuffer, High(short));
      sendBuffer := buffer;

      returnCode := sendto(sock, Pointer(sendBuffer)^, Length(sendBuffer), 0, FTarget, SizeOf(FTarget));
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      lenFrom := SizeOf(FTarget);
      returnCode := recvfrom(sock, Pointer(recvBuffer)^, Length(recvBuffer), 0, FTarget, lenFrom);
      if (returnCode = SOCKET_ERROR) then
        raise ESocketException.Create(GetLastErrorString());

      SetLength(recvBuffer, returnCode);

      closesocket(sock);
      Result := recvBuffer;
    except
      on E: ESocketException do
        raise;
      on E: Exception do
        raise EEasyIpException.Create(E.Message);
    end;
  finally
    WSACleanup;
  end;
end;

function TMockChannel.Execute(const buffer: DynamicByteArray): DynamicByteArray;
var
  temp: DynamicByteArray;
begin
  SetLength(temp, Length(buffer));
  temp := Copy(buffer, 0, Length(buffer));
  temp[0] := $80;
  Result := temp;
end;

function TMockChannel.Execute(const packet: EasyIpPacket): EasyIpPacket;
var
  returnPacket: EasyIpPacket;
begin
  ZeroMemory(@returnPacket, SizeOf(EasyIpPacket));
  returnPacket := packet;
  returnPacket.Flags := $80;
  Result := returnPacket;
end;

constructor TEasyIpChannel.Create(const host: string; const port: int = EASYIP_PORT);
begin
  inherited Create(host, port);
  Debug := Format(DEBUG_MESSAGE_CREATE, ['TEasyIpChannel']);
end;

destructor TEasyIpChannel.Destroy;
begin
  Debug := Format(DEBUG_MESSAGE_DESTROY, ['TEasyIpChannel']);
  inherited;
end;

function TEasyIpChannel.Execute(const packet: EasyIpPacket): EasyIpPacket;
var
  sendPacket: DynamicByteArray;
  recvPacket: DynamicByteArray;
begin
  sendPacket := TPacketAdapter.ToByteArray(packet);
  recvPacket := inherited Execute(sendPacket);
  Result := TPacketAdapter.ToEasyIpPacket(recvPacket);
end;

constructor TNetworkChannel.Create(const host: string; const port: int);
begin
  inherited Create;
  ZeroMemory(@FTarget, SizeOf(TSockAddrIn));
  FTarget.sa_family := AF_INET;
  Self.Host := host;
  Self.Port := port;
  Timeout := 2000;
  Debug := Format(DEBUG_MESSAGE_CREATE, ['TNetworkChannel']);
end;

destructor TNetworkChannel.Destroy;
begin
  Debug := Format(DEBUG_MESSAGE_DESTROY, ['TNetworkChannel']);
  inherited;
end;

function TNetworkChannel.GetHost: string;
begin
  Result := FHost;
end;

function TNetworkChannel.GetLastErrorString: string;
var
  Buffer: array[0..2047] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, WSAGetLastError, LANG_ID, @Buffer, SizeOf(Buffer), nil);
  Result := Buffer;
end;

function TNetworkChannel.GetPort: int;
begin
  Result := FPort;
end;

procedure TNetworkChannel.SetHost(const value: string);
begin
  FHost := value;
  FTarget.sin_addr.S_addr := inet_addr(PChar(FHost));
end;

procedure TNetworkChannel.SetPort(const value: int);
begin
  FPort := value;
  FTarget.sin_port := htons(FPort);
end;

constructor TCustomChannel.Create;
begin
  inherited;
  Timeout := CHANNEL_DEFAULT_TIMEOUT;
  Debug := Format(DEBUG_MESSAGE_CREATE, ['TCustomChannel']);
end;

destructor TCustomChannel.Destroy;
begin
  Debug := Format(DEBUG_MESSAGE_DESTROY, ['TCustomChannel']);
  inherited;
end;

function TCustomChannel.GetTimeout: int;
begin
  Result := FTimeout;
end;

procedure TCustomChannel.SetDebug(const value: string);
begin
  OutputDebugString(PChar(value));
end;

procedure TCustomChannel.SetTimeout(const value: int);
begin
  FTimeout := value;
end;

end.

