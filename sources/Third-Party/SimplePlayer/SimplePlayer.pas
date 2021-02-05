unit SimplePlayer;

interface

uses
  Bass;

type
  TChannelType = (ctUnknown, ctStream, ctMusic);

type
  TSimplePlayer = class
  private
    FC: Byte;
    FChannelType: TChannelType;
    FChannel: array [0 .. 7] of DWORD;
    FVolume: ShortInt;
    procedure SetVolume(const Value: ShortInt);
    function GetVolume: ShortInt;
  public
    constructor Create;
    property Volume: ShortInt read GetVolume write SetVolume;
    function Play(const FileName: string): Boolean; overload;
    procedure Stop;
  end;

implementation

{ TSimplePlayer }

constructor TSimplePlayer.Create;
var
  BassInfo: BASS_INFO;
  I: Integer;
begin
  BASS_Init(1, 44100, BASS_DEVICE_3D, 0, nil);
  BASS_Start;
  BASS_GetInfo(BassInfo);
  Volume := 100;
end;

function TSimplePlayer.GetVolume: ShortInt;
begin
  if (FVolume > 100) then
    FVolume := 100;
  if (FVolume < 0) then
    FVolume := 0;
  Result := FVolume;
end;

function TSimplePlayer.Play(const FileName: string): Boolean;
begin
  Result := False;
  if (Volume <= 0) then
    Exit;
  FChannel[FC] := BASS_StreamCreateFile(False, PChar(FileName), 0, 0, 0
    {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
  if (FChannel[FC] <> 0) then
  begin
    FChannelType := ctStream;
    BASS_ChannelSetAttribute(FChannel[FC], BASS_ATTRIB_VOL, Volume / 100);
    BASS_ChannelPlay(FChannel[FC], False);
  end;
  Result := FChannel[FC] <> 0;
  Inc(FC);
  if (FC > High(FChannel)) then
    FC := 0;
end;

procedure TSimplePlayer.SetVolume(const Value: ShortInt);
begin
  FVolume := Value;
  if (FVolume > 100) then
    FVolume := 100;
  if (FVolume < 0) then
    FVolume := 0;
end;

procedure TSimplePlayer.Stop;
var
  I: Byte;
begin
  for I := 0 to High(FChannel) do
    BASS_ChannelStop(FChannel[I]);
end;

end.
