unit DisciplesRL.Scene.Menu;

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

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Resources, DisciplesRL.GUI.Button;

var
  Top, Left: Integer;
  NewGameButton: TButton;

procedure Init;
var
  ButTop, ButLeft: Integer;
begin
  Top := (Surface.Height div 3) - (ResImage[reLogo].Height div 2);
  Left := (Surface.Width div 2) - (ResImage[reLogo].Width div 2);
  ButTop := ((Surface.Height div 3) * 2) - (ResImage[reButtonDef].Height div 2);
  ButLeft := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  NewGameButton := TButton.Create(ButLeft, ButTop, Surface.Canvas, reTower);
  NewGameButton.Sellected := True;
end;

procedure Render;
begin
  Surface.Canvas.Draw(Left, Top, ResImage[reLogo]);
  NewGameButton.Render;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if NewGameButton.MouseDown then
    DisciplesRL.Scenes.CurrentScene := scMap;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  NewGameButton.MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    DisciplesRL.Scenes.CurrentScene := scMap;
end;

procedure Free;
begin
  FreeAndNil(NewGameButton);
end;

end.
