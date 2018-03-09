unit DisciplesRL.Player;

interface

type
  TPlayer = record
    X, Y: Integer;
    Radius: Integer;
  end;

var
  Player: TPlayer;
  Wizard: Boolean;

procedure Init;
procedure Move(const AX, AY: ShortInt);
procedure PutAt(const AX, AY: ShortInt);
procedure RefreshRadius;
procedure Gen;

implementation

uses System.Math, Vcl.Dialogs, System.SysUtils, DisciplesRL.Map, DisciplesRL.Resources, DisciplesRL.Utils, DisciplesRL.City,
  DisciplesRL.Party, DisciplesRL.Scenes, DisciplesRL.Game, DisciplesRL.Creatures;

procedure Init;
begin
  Player.Radius := IfThen(Wizard, 99, 1);
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
  if (MapDark[AX, AY] = reDark) then
    Exit;
  Inc(Days);
  for I := 0 to High(City) do
  begin
    if (City[I].Owner = reEmpire) then
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
        Inc(Gold, GetDistToCapital(Player.X, Player.Y));
        DisciplesRL.Scenes.CurrentScene := scItem;
      end;
    reBag:
      begin
        MapObj[Player.X, Player.Y] := reNone;
        Inc(Gold, GetDistToCapital(Player.X, Player.Y));
        DisciplesRL.Scenes.CurrentScene := scItem;
      end;
    reEnemies:
      begin
        DisciplesRL.Scenes.CurrentScene := scBattle;
        MapObj[Player.X, Player.Y] := reNone;
      end;
  end;
  case MapTile[Player.X, Player.Y] of
    reNeutralCity:
      begin
        MapTile[Player.X, Player.Y] := reEmpireCity;
        DisciplesRL.City.UpdateRadius(DisciplesRL.City.GetCityIndex(Player.X, Player.Y));
      end;
    reEmpireCity:
      begin
        DisciplesRL.Scenes.CurrentScene := scCity;
      end;
    reEmpireCapital:
      begin
        DisciplesRL.Scenes.CurrentScene := scCapital;
      end;
  end;
end;

procedure RefreshRadius;
begin
  DisciplesRL.Map.UpdateRadius(Player.X, Player.Y, Player.Radius, MapDark, reNone);
end;

procedure Gen;
begin
  LeaderParty.SetPoint(Player.X, Player.Y);
  LeaderParty.AddCreature(crSquire, 0);
  LeaderParty.AddCreature(crLeader, 2);
  LeaderParty.AddCreature(crSquire, 4);
end;

end.
