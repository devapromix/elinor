unit DisciplesRL.Scene.Victory;

interface

uses System.Classes;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Resources,
  DisciplesRL.GUI.Button, DisciplesRL.MainForm, DisciplesRL.Scene.HighScores,
  DisciplesRL.Game;

var
  Top, Left: Integer;
  Button: TButton;

procedure Action;
begin
  IsGame := False;
  DisciplesRL.Scene.HighScores.Show;
end;

procedure Init;
var
  ButTop, ButLeft: Integer;
begin
  Top := (Surface.Height div 3) - (ResImage[reVictory].Height div 2);
  Left := (Surface.Width div 2) - (ResImage[reVictory].Width div 2);
  ButTop := ((Surface.Height div 3) * 2) - (ResImage[reButtonDef].Height div 2);
  ButLeft := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  Button := TButton.Create(ButLeft, ButTop, Surface.Canvas, reMVictory);
  Button.Sellected := True;
end;

procedure Render;
begin
  Surface.Canvas.Draw(Left, Top, ResImage[reVictory]);
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
