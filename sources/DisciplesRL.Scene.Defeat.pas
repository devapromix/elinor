unit DisciplesRL.Scene.Defeat;

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

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Resources, DisciplesRL.GUI.Button, DisciplesRL.MainForm;

var
  Top, Left: Integer;
  DefeatButton: TButton;

procedure Init;
var
  ButTop, ButLeft: Integer;
begin
  Top := (Surface.Height div 3) - (ResImage[reDefeat].Height div 2);
  Left := (Surface.Width div 2) - (ResImage[reDefeat].Width div 2);
  ButTop := ((Surface.Height div 3) * 2) - (ResImage[reButtonDef].Height div 2);
  ButLeft := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  DefeatButton := TButton.Create(ButLeft, ButTop, Surface.Canvas, reMDefeat);
  DefeatButton.Sellected := True;
end;

procedure Render;
begin
  Surface.Canvas.Draw(Left, Top, ResImage[reDefeat]);
  DefeatButton.Render;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if DefeatButton.MouseDown then
    DisciplesRL.MainForm.MainForm.Close;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  DefeatButton.MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = K_ENTER then
    DisciplesRL.MainForm.MainForm.Close;
end;

procedure Free;
begin
FreeAndNil(DefeatButton);
end;

end.
