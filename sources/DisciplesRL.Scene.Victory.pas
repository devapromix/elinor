unit DisciplesRL.Scene.Victory;

interface

uses
  System.Classes,
  Vcl.Controls;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses
  System.SysUtils,
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button,
  DisciplesRL.MainForm,
  DisciplesRL.Game,
  DisciplesRL.Scene.Info;

var
  Button: TButton;

procedure Action;
begin
  IsGame := False;
  DisciplesRL.Scene.Info.Show(stHighScores, scMenu);
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Init;
begin
  Button := TButton.Create((Surface.Width div 2) - (ResImage[reButtonDef].Width div 2), DefaultButtonTop, Surface.Canvas, reTextClose);
  Button.Sellected := True;
end;

procedure Render;
begin
  DrawTitle(reTitleVictory);
  Button.Render;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if Button.MouseDown then
    Action;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  Button.MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      Action;
  end;
end;

procedure Free;
begin
  FreeAndNil(Button);
end;

end.
