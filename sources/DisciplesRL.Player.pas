unit DisciplesRL.Player;

interface

uses
  Bass,
  Elinor.Resources;

type
  TChannelType = (ctUnknown, ctStream, ctMusic);

type
  TMediaType = (mtSound, mtMusic);

type
  TPlayer = class(TObject)
  private
    FCurrentChannel: Integer;
    FChannelType: TChannelType;
    FChannel: array [Byte] of DWORD;
    FSoundVolume: ShortInt;
    FMusicVolume: ShortInt;
    function Play(const FileName: string; F: Boolean; T: TMediaType): Boolean;
    function GetMusicVolume: ShortInt;
    function GetSoundVolume: ShortInt;
    procedure SetMusicVolume(const Value: ShortInt);
    procedure SetSoundVolume(const Value: ShortInt);
  public
    constructor Create;
    destructor Destroy; override;
    function IsPlayMusic: Boolean;
    property SoundVolume: ShortInt read GetSoundVolume write SetSoundVolume;
    property MusicVolume: ShortInt read GetMusicVolume write SetMusicVolume;
    property CurrentChannel: Integer read FCurrentChannel write FCurrentChannel;
    function PlaySound(const FileName: string; F: Boolean = False)
      : Boolean; overload;
    function PlaySound(const MusicEnum: TMusicEnum; F: Boolean = False)
      : Boolean; overload;
    function PlayMusic(const FileName: string; F: Boolean = True)
      : Boolean; overload;
    function PlayMusic(const MusicEnum: TMusicEnum; F: Boolean = True)
      : Boolean; overload;
    procedure StopSound;
    procedure StopMusic;
  end;

implementation

const
  MusicChannel = 0;
  SoundChannel = 1;

  { TMediaPlayer }

constructor TPlayer.Create;
begin
  BASS_Init(1, 44100, BASS_DEVICE_3D, 0, nil);
  BASS_Start;
  SoundVolume := 10;
  MusicVolume := 10;
  FCurrentChannel := SoundChannel;
end;

destructor TPlayer.Destroy;
var
  LChannel: Byte;
begin
  for LChannel := 0 to High(FChannel) do
  begin
    BASS_ChannelStop(FChannel[LChannel]);
    BASS_StreamFree(FChannel[LChannel]);
  end;
  BASS_Free();
  inherited;
end;

function TPlayer.GetMusicVolume: ShortInt;
begin
  Result := FMusicVolume;
end;

function TPlayer.GetSoundVolume: ShortInt;
begin
  Result := FSoundVolume;
end;

function TPlayer.IsPlayMusic: Boolean;
begin
  Result := BASS_ChannelIsActive(FChannel[MusicChannel]) = BASS_ACTIVE_PLAYING;
end;

function TPlayer.PlayMusic(const FileName: string; F: Boolean): Boolean;
begin
  StopMusic;
  CurrentChannel := MusicChannel;
  Play(FileName, F, mtMusic);
  CurrentChannel := SoundChannel;
end;

function TPlayer.PlayMusic(const MusicEnum: TMusicEnum; F: Boolean): Boolean;
begin
  PlayMusic(ResMusicPath[MusicEnum], F);
end;

function TPlayer.PlaySound(const MusicEnum: TMusicEnum; F: Boolean): Boolean;
begin
  PlaySound(ResMusicPath[MusicEnum], F);
end;

function TPlayer.PlaySound(const FileName: string; F: Boolean): Boolean;
begin
  Play(FileName, F, mtSound);
end;

function TPlayer.Play(const FileName: string; F: Boolean;
  T: TMediaType): Boolean;
begin
  Result := False;
  case T of
    mtSound:
      if (SoundVolume <= 0) then
        Exit;
    mtMusic:
      if (MusicVolume <= 0) then
        Exit;
  end;
  case F of
    True:
      FChannel[FCurrentChannel] := BASS_StreamCreateFile(False, PChar(FileName),
        0, 0, BASS_MUSIC_LOOP {$IFDEF UNICODE} or BASS_UNICODE
{$ENDIF});
    False:
      FChannel[FCurrentChannel] := BASS_StreamCreateFile(False,
        PChar(FileName), 0, 0, 0
{$IFDEF UNICODE } or BASS_UNICODE {$ENDIF});
  end;
  if (FChannel[FCurrentChannel] <> 0) then
  begin
    FChannelType := ctStream;
    case T of
      mtSound:
        BASS_ChannelSetAttribute(FChannel[FCurrentChannel], BASS_ATTRIB_VOL,
          SoundVolume / 100);
      mtMusic:
        BASS_ChannelSetAttribute(FChannel[CurrentChannel], BASS_ATTRIB_VOL,
          MusicVolume / 100);
    end;
    BASS_ChannelPlay(FChannel[FCurrentChannel], False);
  end;
  Result := FChannel[FCurrentChannel] <> 0;
  Inc(FCurrentChannel);
  if (FCurrentChannel > High(FChannel)) then
    FCurrentChannel := SoundChannel;
end;

procedure TPlayer.SetMusicVolume(const Value: ShortInt);
begin
  FMusicVolume := Value;
  if (FMusicVolume > 100) then
    FMusicVolume := 100;
  if (FMusicVolume < 0) then
    FMusicVolume := 0;
  BASS_ChannelSetAttribute(FChannel[MusicChannel], BASS_ATTRIB_VOL,
    MusicVolume / 100);
end;

procedure TPlayer.SetSoundVolume(const Value: ShortInt);
var
  LChannel: Byte;
begin
  FSoundVolume := Value;
  if (FSoundVolume > 100) then
    FSoundVolume := 100;
  if (FSoundVolume < 0) then
    FSoundVolume := 0;
  for LChannel := SoundChannel to High(FChannel) do
    BASS_ChannelSetAttribute(FChannel[LChannel], BASS_ATTRIB_VOL,
      SoundVolume / 100);
end;

procedure TPlayer.StopSound;
var
  LChannel: Byte;
begin
  for LChannel := SoundChannel to High(FChannel) do
    BASS_ChannelStop(FChannel[LChannel]);
  FCurrentChannel := SoundChannel;
end;

procedure TPlayer.StopMusic;
begin
  BASS_ChannelStop(FChannel[MusicChannel]);
end;

end.
