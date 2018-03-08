unit DisciplesRL.Scene.Battle;

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

uses DisciplesRL.Scenes, DisciplesRL.Scene.Item, DisciplesRL.Map, DisciplesRL.Game, DisciplesRL.Player;

procedure Init;
begin

end;

procedure Render;
begin
  RenderDark;

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
      begin
        Inc(Gold, GetDistToCapital(Player.X, Player.Y));
        DisciplesRL.Scenes.CurrentScene := scItem;
      end;
  end;
end;

procedure Free;
begin

end;

end.
