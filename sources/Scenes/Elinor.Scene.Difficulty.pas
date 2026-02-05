unit Elinor.Scene.Difficulty;

interface

uses
  Elinor.Scene.Menu.Wide,
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneDifficulty = class(TSceneWideMenu)
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
  Elinor.Difficulty,
  Elinor.Scenario;

procedure TSceneDifficulty.Cancel;
begin
  inherited;
  TSceneScenario.Show;
end;

procedure TSceneDifficulty.Continue;
begin
  inherited;
  case CurrentIndex of
    0 .. 2:
      begin
        Difficulty.Level := TDifficultyEnum(CurrentIndex);
        TSceneRace.ShowScene;
      end;
  end;
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

  procedure DrawBonuses;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Bonuses', True);
    AddTextLine;
    if LDifficultyEnum = dfHard then
    begin
      AddTextLine('None');
      Exit;
    end;
    AddTextLine('Days: +' + TScenario.GetDayLimit(LDifficultyEnum,
      Game.Scenario.CurrentScenario, False).ToString);
    if LDifficultyEnum = dfEasy then
    begin
      AddTextLine('Regeneration: +5');
    end;

  end;

begin
  inherited;
  DrawTitle(reTitleDifficulty);
  for LDifficultyEnum := dfEasy to dfHard do
  begin
    DrawImage(TFrame.Col(0) + 7, TFrame.Row(Ord(LDifficultyEnum)) + 7,
      LDifficultyImage[LDifficultyEnum]);
    if Ord(LDifficultyEnum) = CurrentIndex then
    begin
      TextTop := TFrame.Row(0) + 6;
      TextLeft := TFrame.Col(2) + 12;
      AddTextLine(DifficultyName[LDifficultyEnum], True);
      AddTextLine;
      for I := 0 to 11 do
        AddTextLine(Difficulty.GetDescription(LDifficultyEnum, I));
      DrawBonuses;
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
end;

end.
