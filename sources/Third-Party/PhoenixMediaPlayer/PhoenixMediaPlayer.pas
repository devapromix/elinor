unit PhoenixMediaPlayer;

interface

uses
  Vcl.MPlayer,
  System.Classes;

type
  TPhoenixMediaPlayer = class(TObject)
  private
    FMediaPlayer: TMediaPlayer;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure Play;
    procedure Stop;
  end;

implementation

uses
  Vcl.Controls,
  System.SysUtils,
  DisciplesRL.MainForm;

{ TPhoenixMediaPlayer }

constructor TPhoenixMediaPlayer.Create(const FileName: string);
begin
  FMediaPlayer := TMediaPlayer.Create(MainForm);
  FMediaPlayer.Parent := MainForm;
  FMediaPlayer.Visible := False;
  FMediaPlayer.FileName := FileName;
  FMediaPlayer.Open;
end;

destructor TPhoenixMediaPlayer.Destroy;
begin
  FreeAndNil(FMediaPlayer);
  inherited;
end;

procedure TPhoenixMediaPlayer.Play;
begin
  FMediaPlayer.Play;
end;

procedure TPhoenixMediaPlayer.Stop;
begin
  FMediaPlayer.Pause;
  FMediaPlayer.Rewind;
end;

end.
