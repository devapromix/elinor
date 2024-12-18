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
  Math, dialogs,
  SysUtils,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Scene.Frames, DisciplesRL.Scene.Hire;

procedure TSceneDifficulty.Cancel;
begin
  inherited;
  showmessage('cancel!');
end;

procedure TSceneDifficulty.Continue;
begin
  inherited;
  TSaga.Difficulty := TSaga.TDifficultyEnum(CurrentIndex);
  TSceneHire.Show(stRace)
end;

constructor TSceneDifficulty.Create;
begin
  inherited Create(reWallpaperDifficulty);
end;

procedure TSceneDifficulty.Render;
var
  I: Integer;
  LDifficultyEnum: TSaga.TDifficultyEnum;
const
  LDifficultyImage: array [TSaga.TDifficultyEnum] of TResEnum =
    (reDifficultyEasyLogo, reDifficultyNormalLogo, reDifficultyHardLogo);
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

class procedure TSceneDifficulty.Show;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scDifficulty);
end;

procedure TSceneDifficulty.Update(var Key: Word);
begin
  inherited;
  UpdateEnum<TSaga.TDifficultyEnum>(Key);
end;

end.
