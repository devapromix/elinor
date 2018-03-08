unit DisciplesRL.Scene.Capital;

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

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Resources, DisciplesRL.Game;

procedure Init;
begin

end;

procedure Render;
begin
  RenderDark;

  CenterTextOut(100, 'THE EMPIRE CAPITAL');
  CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CAPITAL DEFENSES');
  CenterTextOut(Surface.Height - 100, '[ESC] Close');
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin

end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE:
      DisciplesRL.Scenes.CurrentScene := scMap;
  end;
end;

procedure Free;
begin

end;

end.
