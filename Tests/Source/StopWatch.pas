unit StopWatch;

interface

uses
  Windows,
  SysUtils;

type
  IStopWatch = interface
    procedure SetTickStamp(var lInt: TLargeInteger);
    function GetElapsedTicks: TLargeInteger;
    function GetElapsedMilliseconds: TLargeInteger;
    function GetElapsed: string;
    function GetIsHighResolution: Boolean;
    function GetIsRunning: Boolean;
    procedure Start;
    procedure Stop;
    property ElapsedTicks: TLargeInteger read GetElapsedTicks;
    property ElapsedMilliseconds: TLargeInteger read GetElapsedMilliseconds;
    property Elapsed: string read GetElapsed;
    property IsHighResolution: boolean read GetIsHighResolution;
    property IsRunning: boolean read GetIsRunning;
  end;

  TStopWatch = class(TInterfacedObject, IStopWatch)
  private
    fFrequency: TLargeInteger;
    fIsRunning: boolean;
    fIsHighResolution: boolean;
    fStartCount, fStopCount: TLargeInteger;
    procedure SetTickStamp(var lInt: TLargeInteger);
    function GetElapsedTicks: TLargeInteger;
    function GetElapsedMilliseconds: TLargeInteger;
    function GetElapsed: string;
    function GetIsHighResolution: Boolean;
    function GetIsRunning: Boolean;
  public
    constructor Create(const startOnCreate: boolean = false);
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    property IsHighResolution: boolean read GetIsHighResolution;
    property ElapsedTicks: TLargeInteger read GetElapsedTicks;
    property ElapsedMilliseconds: TLargeInteger read GetElapsedMilliseconds;
    property Elapsed: string read GetElapsed;
    property IsRunning: boolean read GetIsRunning;
  end;

implementation

const
  MSecsPerSec = 1000;

function MilliSecondOf(const AValue: TDateTime): Word;
var
  LHour, LMinute, LSecond: Word;
begin
  DecodeTime(AValue, LHour, LMinute, LSecond, Result);
end;

constructor TStopWatch.Create(const startOnCreate: boolean = false);
begin
  inherited Create;

  fIsRunning := false;

  fIsHighResolution := QueryPerformanceFrequency(fFrequency);
  if not fIsHighResolution then
    fFrequency := MSecsPerSec;

  if startOnCreate then
    Start;
end;

destructor TStopWatch.Destroy;
begin
  OutputDebugString('Destroyed');
  inherited;
end;

function TStopWatch.GetElapsedTicks: TLargeInteger;
begin
  result := fStopCount - fStartCount;
end;

procedure TStopWatch.SetTickStamp(var lInt: TLargeInteger);
begin
  if fIsHighResolution then
    QueryPerformanceCounter(lInt)
  else
    lInt := MilliSecondOf(Now);
end;

function TStopWatch.GetElapsed: string;
var
  dt: TDateTime;
begin
  dt := ElapsedMilliseconds / MSecsPerSec / SecsPerDay;
  result := Format('%d days, %s', [trunc(dt), FormatDateTime('hh:nn:ss.z', Frac(dt))]);
end;

function TStopWatch.GetElapsedMilliseconds: TLargeInteger;
begin
  result := (MSecsPerSec * (fStopCount - fStartCount)) div fFrequency;
end;

procedure TStopWatch.Start;
begin
  SetTickStamp(fStartCount);
  fIsRunning := true;
end;

procedure TStopWatch.Stop;
begin
  SetTickStamp(fStopCount);
  fIsRunning := false;
end;

function TStopWatch.GetIsHighResolution: Boolean;
begin
  Result := fIsHighResolution;
end;

function TStopWatch.GetIsRunning: Boolean;
begin
  Result := fIsRunning;
end;

end.

 (*  //Usage example
 var
   sw : TStopWatch;
   elapsedMilliseconds : cardinal;
 begin
   sw := TStopWatch.Create() ;
   try
     sw.Start;
     //TimeOutThisFunction()
     sw.Stop;
 
     elapsedMilliseconds := sw.ElapsedMilliseconds;
   finally
     sw.Free;
   end;
 end;
 *)


