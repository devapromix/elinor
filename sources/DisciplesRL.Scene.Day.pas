unit DisciplesRL.Scene.Day;

interface

uses
  System.Classes;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses
  System.SysUtils,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Map,
  DisciplesRL.Game,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Player,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.GUI.Button;

var
  Button: TButton;

procedure Action;
begin
  IsDay := False;
  DisciplesRL.Scenes.CurrentScene := scMap;
end;

procedure Init;
var
  ButTop, ButLeft: Integer;
begin
  ButTop := ((Surface.Height div 3) * 2) - (ResImage[reButtonDef].Height div 2);
  ButLeft := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  Button := TButton.Create(ButLeft, 600, Surface.Canvas, reMVictory);
  Button.Sellected := True;
end;

procedure Render;
begin
  // RenderDark;

  CenterTextOut(100, 'DAY ' + IntToStr(Days));
  CenterTextOut(200, 'GOLD +' + IntToStr(GoldMines * GoldFromMinePerDay));
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
