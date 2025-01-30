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
  Elinor.Frame;

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
    reFrameSlotActive);
  TextTop := TFrame.Row(0) + 6;
  TextLeft := TFrame.Col(2) + 12;
  AddTextLine(TScenario.ScenarioName[LScenarioEnum], True);
  AddTextLine;
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
