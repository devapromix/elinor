unit Elinor.Scene.Race;

interface

uses
  Elinor.Scene.Menu.Simple,
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneRace = class(TSceneSimpleMenu)
  private
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Cancel; override;
    procedure Continue; override;
    class procedure Show;
  end;

implementation

{ TSceneRace }

uses
  Math,
  System.SysUtils,
  Elinor.Scene.Difficulty,
  Elinor.Saga,
  DisciplesRL.Scene.Hire,
  Elinor.Frame,
  Elinor.Creatures;

procedure TSceneRace.Cancel;
begin
  inherited;
  TSceneDifficulty.Show;
end;

procedure TSceneRace.Continue;
begin
  inherited;
  TSaga.LeaderRace := TFactionEnum(CurrentIndex);
  TSceneHire.Show(stLeader);
end;

constructor TSceneRace.Create;
begin
  inherited Create(reWallpaperDifficulty);
end;

procedure TSceneRace.Render;
var
  I: Integer;
  LPlayableRaces: TPlayableRaces;
  R: TFactionEnum;
const
  LPlayableRacesImage: array [TPlayableRaces] of TResEnum = (reTheEmpireLogo,
    reUndeadHordesLogo, reLegionsOfTheDamnedLogo);
begin
  inherited;
  DrawTitle(reTitleRace);
  for LPlayableRaces := Low(TPlayableRaces) to High(TPlayableRaces) do
  begin
    DrawImage(TFrame.Col(1) + 7, TFrame.Row(Ord(LPlayableRaces)) + 7,
      LPlayableRacesImage[LPlayableRaces]);
    if Ord(LPlayableRaces) = CurrentIndex then
    begin
      DrawImage(TFrame.Col(1), SceneTop + (Ord(LPlayableRaces) * 120),
        reActFrame);
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      R := TFactionEnum(CurrentIndex);
      AddTextLine(FactionName[R], True);
      AddTextLine;
      for I := 0 to 11 do
        AddTextLine(FactionDescription[R][i]);
    end;
  end;
end;

class procedure TSceneRace.Show;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scRace);
end;

procedure TSceneRace.Update(var Key: Word);
begin
  inherited;
  UpdateEnum<TPlayableRaces>(Key);
end;

end.
