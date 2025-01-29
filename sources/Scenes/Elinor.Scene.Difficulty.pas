unit Elinor.Scene.Difficulty;

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
  TSceneDifficulty = class(TSceneSimpleMenu)
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

{ TSceneDifficulty }

uses
  Math,
  SysUtils,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Scene.Frames,
  Elinor.Scene.Faction,
  Elinor.Scene.Scenario,
  Elinor.Difficulty;

procedure TSceneDifficulty.Cancel;
begin
  inherited;
  TSceneScenario.Show;
end;

procedure TSceneDifficulty.Continue;
begin
  inherited;
  TSaga.Difficulty := TDifficultyEnum(CurrentIndex);
  TSceneRace.Show;
end;

constructor TSceneDifficulty.Create;
begin
  inherited Create(reWallpaperDifficulty);
end;

procedure TSceneDifficulty.Render;
var
  I: Integer;
  LDifficultyEnum: TDifficultyEnum;
const
  LDifficultyImage: array [TDifficultyEnum] of TResEnum = (reDifficultyEasyLogo,
    reDifficultyNormalLogo, reDifficultyHardLogo);
begin
  inherited;
  DrawTitle(reTitleDifficulty);
  for LDifficultyEnum := dfEasy to dfHard do
  begin
    DrawImage(TFrame.Col(1) + 7, TFrame.Row(Ord(LDifficultyEnum)) + 7,
      LDifficultyImage[LDifficultyEnum]);
    if Ord(LDifficultyEnum) = CurrentIndex then
    begin
      DrawImage(TFrame.Col(1), SceneTop + (Ord(LDifficultyEnum) * 120),
        reFrameSlotActive);
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      AddTextLine(DifficultyName[LDifficultyEnum], True);
      AddTextLine;
      for I := 0 to 11 do
        AddTextLine(Difficulty.GetDescription(LDifficultyEnum, I));
    end;
  end;
end;

class procedure TSceneDifficulty.Show;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scDifficulty);
end;

procedure TSceneDifficulty.Update(var Key: Word);
begin
  inherited;
  UpdateEnum<TDifficultyEnum>(Key);
end;

end.
