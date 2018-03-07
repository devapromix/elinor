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

uses DisciplesRL.Scenes, DisciplesRL.Resources;

var
  Top, Left: Integer;

procedure Init;
begin
  Top := (Surface.Height div 3) - (ResImage[reVictory].Height div 2);
  Left := (Surface.Width div 2) - (ResImage[reVictory].Width div 2);
end;

procedure Render;
begin
  Surface.Canvas.Draw(Left, Top, ResImage[reVictory]);
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

end;

procedure Free;
begin

end;

end.
