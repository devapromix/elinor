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
begin
  Button := TButton.Create((Surface.Width div 2) - (ResImage[reButtonDef].Width div 2), DefaultButtonTop, Surface.Canvas, reTextClose);
  Button.Sellected := True;
end;

procedure Render;
begin
  // RenderDark;

  CenterTextOut(100, Format('Õ¿—“”œ»À ÕŒ¬€… ƒ≈Õ‹ (ƒÂÌ¸ %d-È)',[Days]));
  CenterTextOut(200, '«ŒÀŒ“Œ +' + IntToStr(GoldMines * GoldFromMinePerDay));
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
