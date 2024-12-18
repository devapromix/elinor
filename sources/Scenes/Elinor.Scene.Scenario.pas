unit Elinor.Scene.Scenario;

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
  TSceneScenario = class(TSceneSimpleMenu)
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

{ TSceneScenario }

uses
  Math,
  SysUtils,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Scene.Frames,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.Difficulty;

procedure TSceneScenario.Cancel;
begin
  inherited;
  Game.Show(scMenu);
end;

procedure TSceneScenario.Continue;
begin
  inherited;
  Game.Scenario.CurrentScenario := TScenario.TScenarioEnum(CurrentIndex);
  TSceneDifficulty.Show;
end;

constructor TSceneScenario.Create;
begin
  inherited Create(reWallpaperScenario);
end;

procedure TSceneScenario.Render;
var
  I: Integer;
  LScenarioEnum: TScenario.TScenarioEnum;
const
  LDifficultyImage: array [TScenario.TScenarioEnum] of TResEnum =
    (reScenarioDarkTower, reScenarioOverlord, reScenarioAncientKnowledge);
begin
  inherited;
  DrawTitle(reTitleScenario);
  for LScenarioEnum := Low(TScenario.TScenarioEnum)
    to High(TScenario.TScenarioEnum) do
  begin
    DrawImage(TFrame.Col(1) + 7, TFrame.Row(Ord(LScenarioEnum)) + 7,
      LDifficultyImage[LScenarioEnum]);
    if Ord(LScenarioEnum) = CurrentIndex then
    begin
      DrawImage(TFrame.Col(1), SceneTop + (Ord(LScenarioEnum) * 120),
        reActFrame);
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      AddTextLine(TScenario.ScenarioName[LScenarioEnum], True);
      AddTextLine;
      for I := 0 to 11 do
        AddTextLine(TScenario.ScenarioDescription[LScenarioEnum][I]);
      if TSaga.IsGame then
        case Game.Scenario.CurrentScenario of
          sgOverlord:
            AddTextLine(Game.Scenario.ScenarioOverlordState);
          sgAncientKnowledge:
            AddTextLine(Game.Scenario.ScenarioAncientKnowledgeState);
        end;
    end;
  end;
end;

class procedure TSceneScenario.Show;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scScenario);
end;

procedure TSceneScenario.Update(var Key: Word);
begin
  inherited;
  UpdateEnum<TScenario.TScenarioEnum>(Key);
end;

end.
