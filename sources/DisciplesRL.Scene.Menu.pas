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

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Resources, DisciplesRL.GUI.Button, DisciplesRL.Scene.Settlement,
  DisciplesRL.MainForm;

type
  TButtonEnum = (btNew, btQuit);

var
  Top, Left: Integer;
  Button: array [TButtonEnum] of TButton;

procedure Init;
var
  L, T, H: Integer;
  I: TButtonEnum;
begin
  Top := (Surface.Height div 3) - (ResImage[reLogo].Height div 2);
  Left := (Surface.Width div 2) - (ResImage[reLogo].Width div 2);
  L := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  H := ResImage[reButtonDef].Height + 10;
  T := (Surface.Height div 3 * 2) - ((H * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, T, Surface.Canvas, reMNewGame);
    Inc(T, H);
    if (I = btNew) then
      Button[I].Sellected := True;
  end;
end;

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].Render;
end;

procedure Render;
begin
  Surface.Canvas.Draw(Left, Top, ResImage[reLogo]);
  RenderButtons;
  CenterTextOut(Surface.Height - 50, '2018 by Apromix')
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if Button[btNew].MouseDown then
    DisciplesRL.Scene.Settlement.Show(stCapital);
  if Button[btQuit].MouseDown then
    DisciplesRL.MainForm.MainForm.Close;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      DisciplesRL.Scene.Settlement.Show(stCapital);
  end;
end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
end;

end.
