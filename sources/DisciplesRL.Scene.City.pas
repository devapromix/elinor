unit DisciplesRL.Scene.City;

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

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Game;

procedure Init;
begin

end;

procedure Render;
var
  I, Y, X4: Integer;
begin
  RenderDark;

  CenterTextOut(100, 'CITY');
  CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CITY DEFENSES');
  CenterTextOut(Surface.Height - 100, '[ESC] Close');

  X4 := Surface.Width div 4;
  Y := 220;
  for I := 0 to 5 do
  begin
    case I of
      0, 2, 4:
        begin
          Surface.Canvas.TextOut(X4, Y, Format('%d', [I]));
        end;
      1, 3, 5:
        begin
          Surface.Canvas.TextOut(0, Y, Format('%d', [I]));
        end;
    end;
    Inc(Y, 40);
  end;
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
