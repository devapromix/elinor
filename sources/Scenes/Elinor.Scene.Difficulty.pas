unit Elinor.Scene.Difficulty;

interface

uses
  Elinor.Scene.Menu.Simple,
  Vcl.Controls,
  System.Classes,
  DisciplesRL.Button,
  Elinor.Resources,
  Elinor.Party,
  DisciplesRL.Scenes;

type
  TSceneDifficulty = class(TSceneSimpleMenu)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Cancel;  override;
    procedure Continue;  override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

{ TSceneDifficulty }

uses
  Math,  dialogs,
  SysUtils,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Scene.Frames;

procedure TSceneDifficulty.Cancel;
begin
  inherited;
  showmessage('cancel!');
end;

procedure TSceneDifficulty.Continue;
begin
  inherited;
  showmessage('continue!');
end;

constructor TSceneDifficulty.Create;
begin
  inherited Create(reWallpaperDifficulty);
end;

destructor TSceneDifficulty.Destroy;
begin
  inherited;
end;

procedure TSceneDifficulty.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TSceneDifficulty.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TSceneDifficulty.Render;
var
  LDifficultyEnum: TSaga.TDifficultyEnum;
begin
  inherited;
  DrawTitle(reTitleDifficulty);
  for LDifficultyEnum := dfEasy to dfHard do
    if Ord(LDifficultyEnum) = CurrentIndex then
      DrawImage(TFrame.Col(1), SceneTop + (Ord(LDifficultyEnum) * 120),
        reActFrame);
end;

procedure TSceneDifficulty.Timer;
begin
  inherited;

end;

procedure TSceneDifficulty.Update(var Key: Word);
begin
  inherited;
  UpdateEnum<TSaga.TDifficultyEnum>(Key);
end;

end.
