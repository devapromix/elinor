unit DisciplesRL.Scene.Battle3;

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  DisciplesRL.Button,
  DisciplesRL.Scenes;

type
  TSceneBattle3 = class(TScene)
  private
    Button: TButton;
    procedure Start;
    procedure Finish;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Show(const S: TSceneEnum); override;
  end;

implementation

uses
  SysUtils,
  DisciplesRL.Resources;

{ TSceneBattle3 }

procedure TSceneBattle3.Start;
begin
  Game.Player.PlaySound(mmWar);
end;

procedure TSceneBattle3.Finish;
begin

end;

constructor TSceneBattle3.Create;
begin
  inherited;
  Button := TButton.Create(1100 - (ResImage[reButtonDef].Width + SceneLeft),
    DefaultButtonTop, reTextClose);
  Button.Sellected := True;
end;

destructor TSceneBattle3.Destroy;
begin
  FreeAndNil(Button);
  inherited;
end;

procedure TSceneBattle3.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      if Button.MouseDown then
        Finish;
  end;
end;

procedure TSceneBattle3.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  Button.MouseMove(X, Y);
  Render;
end;

procedure TSceneBattle3.Render;
begin
  inherited;
  DrawTitle(reTitleBattle);
  Button.Render;
end;

procedure TSceneBattle3.Show(const S: TSceneEnum);
begin
  inherited;
  Start;
  Game.Player.PlayMusic(mmBattle);
end;

procedure TSceneBattle3.Timer;
begin
  inherited;

end;

procedure TSceneBattle3.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      Finish;
  end;
end;

end.
