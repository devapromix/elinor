unit Elinor.Scene.HighScores;

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
  TSceneHighScores = class(TSceneSimpleMenu)
  private
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Cancel; override;
    procedure Continue; override;
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

uses
  Math,
  SysUtils,
  Elinor.Scenario,
  Elinor.Frame, Elinor.Statistics;

{ TSceneHighScores }

procedure TSceneHighScores.Cancel;
begin
  HideScene;
end;

procedure TSceneHighScores.Continue;
begin
  HideScene;
end;

constructor TSceneHighScores.Create;
begin
  inherited Create(reWallpaperDifficulty);
end;

class procedure TSceneHighScores.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scMenu);
end;

procedure TSceneHighScores.Render;
var
  LScenarioEnum: TScenarioEnum;
begin
  inherited;
  IsOneButton := True;
  DrawTitle(reTitleHighScores);

  DrawImage(TFrame.Col(1), SceneTop + (Ord(LScenarioEnum) * 120),
    reFrameSlotPassive);
  TextTop := TFrame.Row(0) + 6;
  TextLeft := TFrame.Col(2) + 12;
  AddTextLine('Statistics', True);
  AddTextLine;
  AddTextLine('Battles Won', Game.Statistics.GetValue(stBattlesWon));
  AddTextLine('Killed Creatures', Game.Statistics.GetValue(stKilledCreatures));
  AddTextLine('Tiles Moved', Game.Statistics.GetValue(stTilesMoved));
  AddTextLine('Chests Found', Game.Statistics.GetValue(stChestsFound));
  AddTextLine('Items Found', Game.Statistics.GetValue(stItemsFound));
  AddTextLine('Scores', Game.Statistics.GetValue(stScores));
end;

class procedure TSceneHighScores.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scHighScores);
end;

procedure TSceneHighScores.Update(var Key: Word);
begin
  inherited;
  UpdateEnum<TScenarioEnum>(Key);
end;

end.
