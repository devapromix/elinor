unit Elinor.Scene.Faction;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Scene.Menu.Simple,
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
  System.Math,
  System.SysUtils,
  Elinor.Faction,
  Elinor.Scene.Difficulty,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Scene.Leader;

procedure TSceneRace.Cancel;
begin
  inherited;
  TSceneDifficulty.Show;
end;

procedure TSceneRace.Continue;
begin
  inherited;
  Game.Scenario.Faction := TFactionEnum(CurrentIndex);
  TSceneLeader.Show;
end;

constructor TSceneRace.Create;
begin
  inherited Create(reWallpaperDifficulty);
end;

procedure TSceneRace.Render;
var
  I: Integer;
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
    DrawImage(TFrame.Col(1) + 7, TFrame.Row(Ord(LPlayableRaces)) + 7,
      LPlayableRacesImage[LPlayableRaces]);
    if Ord(LPlayableRaces) = CurrentIndex then
    begin
      DrawImage(TFrame.Col(1), SceneTop + (Ord(LPlayableRaces) * 120),
        reFrameSlotActive);
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      LFactionEnum := TFactionEnum(CurrentIndex);
      AddTextLine(FactionName[LFactionEnum], True);
      AddTextLine;
      for I := 0 to 10 do
        AddTextLine(TFaction.GetDescription(LFactionEnum, I));
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
  UpdateEnum<TPlayableFactions>(Key);
end;

end.
