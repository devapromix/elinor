unit DisciplesRL.Player;

interface

type
  TPlayer = record
    X, Y: Integer;
    Rad: Integer;
  end;

var
  Player: TPlayer;

procedure Init;
procedure RefreshRad;

implementation

uses DisciplesRL.Map, DisciplesRL.Resources, DisciplesRL.Utils;

procedure Init;
begin
  Player.Rad := 2;
  RefreshRad;
end;

procedure RefreshRad;
var
  X, Y: Integer;
begin
  for Y := -(Player.Rad + 2) to Player.Rad + 2 do
    for X := -(Player.Rad + 2) to Player.Rad + 2 do
      if (Utils.GetDist(Player.X + X, Player.Y + Y, Player.X, Player.Y) <= Player.Rad) and
        DisciplesRL.Map.InMap(Player.X + X, Player.Y + Y) then
        MapDark[Player.X + X, Player.Y + Y] := reNone;
end;

end.
