unit PhoenixMediaPlayer;

interface

uses
  Vcl.MPlayer,
  System.Classes,
  DisciplesRL.Resources;

type
  TPhoenixMediaPlayer = class(TObject)
  private
    FMediaPlayer: array [TMusicEnum] of TMediaPlayer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Play(const MusicEnum: TMusicEnum);
    procedure Stop(const MusicEnum: TMusicEnum);
    procedure StopAll;
  end;

implementation

uses
  Vcl.Controls,
  System.SysUtils,
  DisciplesRL.MainForm;

{ TPhoenixMediaPlayer }

constructor TPhoenixMediaPlayer.Create;
var
  MusicEnum: TMusicEnum;
begin
  for MusicEnum := Low(TMusicEnum) to High(TMusicEnum) do
  begin
    FMediaPlayer[MusicEnum] := TMediaPlayer.Create(MainForm);
    FMediaPlayer[MusicEnum].Parent := MainForm;
    FMediaPlayer[MusicEnum].Visible := False;
    FMediaPlayer[MusicEnum].FileName := ResMusicPath[MusicEnum];
    FMediaPlayer[MusicEnum].Open;
  end;
end;

destructor TPhoenixMediaPlayer.Destroy;
var
  MusicEnum: TMusicEnum;
begin
  for MusicEnum := Low(TMusicEnum) to High(TMusicEnum) do
    FreeAndNil(FMediaPlayer[MusicEnum]);
  inherited;
end;

procedure TPhoenixMediaPlayer.Stop(const MusicEnum: TMusicEnum);
begin
  FMediaPlayer[MusicEnum].Pause;
  FMediaPlayer[MusicEnum].Rewind;
end;

procedure TPhoenixMediaPlayer.StopAll;
var
  MusicEnum: TMusicEnum;
begin
  for MusicEnum := Low(TMusicEnum) to High(TMusicEnum) do
    Stop(MusicEnum);
end;

procedure TPhoenixMediaPlayer.Play(const MusicEnum: TMusicEnum);
begin
  FMediaPlayer[MusicEnum].Play;
end;

end.
