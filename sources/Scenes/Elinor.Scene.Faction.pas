unit Elinor.Scene.Faction;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Scene.Menu.Wide,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneRace = class(TSceneWideMenu)
  private
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Cancel; override;
    procedure Continue; override;
    class procedure ShowScene;
  end;

implementation

{ TSceneRace }

uses
  System.Math,
  System.SysUtils,
  Elinor.Faction,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Scene.Leader,
  Elinor.Scene.Difficulty,
  Elinor.Scene.Frames;

procedure TSceneRace.Cancel;
begin
  inherited;
  TSceneDifficulty.Show;
end;

procedure TSceneRace.Continue;
begin
  inherited;
  if CurrentIndex > 2 then
    Exit;
  Game.Scenario.Faction := TFactionEnum(CurrentIndex);
  TSceneLeader.Show;
end;

constructor TSceneRace.Create;
begin
  inherited Create(reWallpaperDifficulty, True, fgRB);
end;

procedure TSceneRace.Render;
var
  LPlayableRaces: TPlayableFactions;
  LFactionEnum: TFactionEnum;
const
  LPlayableRacesImage: array [TPlayableFactions] of TResEnum = (reTheEmpireLogo,
    reUndeadHordesLogo, reLegionsOfTheDamnedLogo);
begin
  inherited;
  DrawTitle(reTitleRace);
  for LPlayableRaces := Low(TPlayableFactions) to High(TPlayableFactions) do
  begin
    DrawImage(TFrame.Col(0) + 7, TFrame.Row(Ord(LPlayableRaces)) + 7,
      LPlayableRacesImage[LPlayableRaces]);
    if Ord(LPlayableRaces) = CurrentIndex then
    begin
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      LFactionEnum := TFactionEnum(CurrentIndex);
      AddTextLine(FactionName[LFactionEnum], True);
      AddTextLine;
      Self.DrawText(TextLeft, TextTop, 600,
        TFaction.GetDescription(LFactionEnum));
      TextTop := TFrame.Row(0) + 200;
      AddTextLine('Faction Traits', True);
      AddTextLine;
      Self.DrawText(TextLeft, TextTop, 600,
        TFaction.GetTraits(LFactionEnum));
    end;
  end;
end;

class procedure TSceneRace.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scRace);
end;

procedure TSceneRace.Update(var Key: Word);
begin
  inherited;
end;

end.
