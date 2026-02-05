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
  Elinor.Scenario,
  Elinor.Frame,
  Elinor.Scene.Frames,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.Difficulty;

procedure TSceneScenario.Cancel;
begin
  if Game.IsGame then
    Game.Show(scMap)
  else
    Game.Show(scMenu);
end;

procedure TSceneScenario.Continue;
begin
  inherited;
  if Game.IsGame then
    Game.Show(scMap)
  else
  begin
    Game.Scenario.CurrentScenario := TScenarioEnum(CurrentIndex);
    TSceneDifficulty.Show;
  end;
end;

constructor TSceneScenario.Create;
begin
  inherited Create(reWallpaperScenario);
end;

procedure TSceneScenario.Render;
var
  I: Integer;
  LScenarioEnum: TScenarioEnum;
const
  LScenarioImage: array [TScenarioEnum] of TResEnum = (reScenarioDarkTower,
    reScenarioOverlord, reScenarioAncientKnowledge);
begin
  inherited;
  IsOneButton := Game.IsGame;
  IsBlockFrames := Game.IsGame;
  if Game.IsGame then
    DrawTitle(reTitleJournal)
  else
    DrawTitle(reTitleScenario);
  for LScenarioEnum := Low(TScenarioEnum) to High(TScenarioEnum) do
  begin
    DrawImage(TFrame.Col(1) + 7, TFrame.Row(Ord(LScenarioEnum)) + 7,
      LScenarioImage[LScenarioEnum]);
    if Ord(LScenarioEnum) = CurrentIndex then
    begin
      if Game.IsGame then
        DrawImage(TFrame.Col(1), SceneTop + (Ord(LScenarioEnum) * 120),
          reFrameSlotPassive)
      else
        DrawImage(TFrame.Col(1), SceneTop + (Ord(LScenarioEnum) * 120),
          reFrameSlotActive);
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      AddTextLine(TScenario.GetScenario(LScenarioEnum).Name, True);
      AddTextLine;
      for I := 0 to 9 do
        AddTextLine(TScenario.GetDescription(LScenarioEnum, I));
      AddTextLine('Objective: ' + TScenario.GetScenario(LScenarioEnum)
        .Objective);
      if Game.IsGame then
        AddTextLine('Day: ' + Game.GetDayInfo)
      else
        AddTextLine('Days: ' + Game.Scenario.ScenarioDayLimit.ToString);
      if Game.IsGame then
      begin
        CurrentIndex := Ord(Game.Scenario.CurrentScenario);
        case Game.Scenario.CurrentScenario of
          sgOverlord:
            AddTextLine(Game.Scenario.ScenarioOverlordState);
          sgAncientKnowledge:
            AddTextLine(Game.Scenario.ScenarioAncientKnowledgeState);
        end;
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
  if Game.IsGame then
  begin
    Basic(Key);
    Exit;
  end;
  inherited;
  UpdateEnum<TScenarioEnum>(Key);
end;

end.
