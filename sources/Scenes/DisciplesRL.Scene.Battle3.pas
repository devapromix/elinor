unit DisciplesRL.Scene.Battle3;

interface

uses
  System.Classes,
  DisciplesRL.Scenes,
  Vcl.Controls;

type
  TSceneBattle3 = class(TScene)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

uses
  System.SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.GUI.Button,
  DisciplesRL.Resources,
  DisciplesRL.Scene.Party;

var
  Button: TButton;

procedure Start;
begin
  MediaPlayer.Play(mmWar);
end;

procedure Finish;
begin
  MediaPlayer.Stop;
end;

{ TSceneBattle3 }

procedure TSceneBattle3.Click;
begin
  inherited;
  if Button.MouseDown then
    Finish;
end;

constructor TSceneBattle3.Create;
begin
  Button := TButton.Create(Surface.Width - (ResImage[reButtonDef].Width + Left),
    DefaultButtonTop, Surface.Canvas, reTextClose);
  Button.Sellected := True;
end;

destructor TSceneBattle3.Destroy;
begin
  FreeAndNil(Button);
  inherited;
end;

procedure TSceneBattle3.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

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
