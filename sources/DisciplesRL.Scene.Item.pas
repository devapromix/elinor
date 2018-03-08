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

uses DisciplesRL.Scenes, DisciplesRL.Scene.Map;

procedure Init;
begin

end;

procedure Render;
begin
  RenderDark;

  CenterTextOut(100, 'CITY');
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
