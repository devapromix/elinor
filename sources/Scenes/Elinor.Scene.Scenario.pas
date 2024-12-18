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
  DisciplesRL.Scene.Hire;

procedure TSceneScenario.Cancel;
begin
  inherited;
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scMenu);
end;

procedure TSceneScenario.Continue;
begin
  inherited;
  Game.Scenario.CurrentScenario := TScenario.TScenarioEnum(CurrentIndex);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scDifficulty);
end;

constructor TSceneScenario.Create;
begin
  inherited Create(reWallpaperScenario);
end;

procedure TSceneScenario.Render;
var
  I: Integer;
  LDifficultyEnum: TScenario.TScenarioEnum;
const
  LDifficultyImage: array [TScenario.TScenarioEnum] of TResEnum =
    (reDifficultyEasyLogo, reDifficultyNormalLogo, reDifficultyHardLogo);
begin
  inherited;
  DrawTitle(reTitleScenario);
  for LDifficultyEnum := Low(TScenario.TScenarioEnum)
    to High(TScenario.TScenarioEnum) do
  begin
    DrawImage(TFrame.Col(1) + 7, TFrame.Row(Ord(LDifficultyEnum)) + 7,
      LDifficultyImage[LDifficultyEnum]);
    if Ord(LDifficultyEnum) = CurrentIndex then
    begin
      DrawImage(TFrame.Col(1), SceneTop + (Ord(LDifficultyEnum) * 120),
        reActFrame);
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      AddTextLine(TSaga.DifficultyName[LDifficultyEnum], True);
      AddTextLine;
      for I := 0 to 11 do
        AddTextLine(TSaga.DifficultyDescription[LDifficultyEnum][I]);
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
