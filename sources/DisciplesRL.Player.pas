unit DisciplesRL.Player;

interface

type
  TPlayer = record
    X, Y: Integer;
    Radius: Integer;
    Turn: Integer;
  end;

var
  Player: TPlayer;

procedure Init;
procedure Move(const AX, AY: ShortInt);
procedure PutAt(const AX, AY: ShortInt);
procedure RefreshRadius;

implementation

uses Vcl.Dialogs, System.SysUtils, DisciplesRL.Map, DisciplesRL.Resources, DisciplesRL.Utils, DisciplesRL.City, DisciplesRL.Party;

procedure Init;
begin
  Player.Turn := 0;
  Player.Radius := 91;
  RefreshRadius;
end;

procedure Move(const AX, AY: ShortInt);
begin
  PutAt(Player.X + AX, Player.Y + AY);
end;

procedure PutAt(const AX, AY: ShortInt);
var
  X, Y, I: Integer;
begin
  if not InMap(AX, AY) then
    Exit;
  if (MapObj[AX, AY] = reMountain) then
    Exit;
  Inc(Player.Turn);
  for I := 0 to High(City) do
  begin
    if (City[I].Owner = reTheEmpire) then
      if (City[I].CurLevel < City[I].MaxLevel) then
      begin
        Inc(City[I].CurLevel);
        DisciplesRL.City.UpdateRadius(I);
      end;
  end;
  Player.X := AX;
  Player.Y := AY;
  RefreshRadius;
  case MapObj[Player.X, Player.Y] of
    reGold:
      begin
        MapObj[Player.X, Player.Y] := reNone;
      end;
    reBag:
      begin
        MapObj[Player.X, Player.Y] := reNone;
      end;
    reEnemies:
      begin
        MapObj[Player.X, Player.Y] := reNone;
        ShowMessage(IntToStr(GetDistToCapital(Player.X, Player.Y)));
      end;
  end;
  case MapTile[Player.X, Player.Y] of
    reNeutralCity:
      begin
        MapTile[Player.X, Player.Y] := reEmpireCity;
        DisciplesRL.City.UpdateRadius(DisciplesRL.City.GetCityIndex(Player.X, Player.Y));
      end;
  end;
end;

procedure RefreshRadius;
begin
  DisciplesRL.Map.UpdateRadius(Player.X, Player.Y, Player.Radius, MapDark, reNone);
end;

end.
