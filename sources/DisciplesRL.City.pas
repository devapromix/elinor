unit DisciplesRL.City;

interface

uses
  DisciplesRL.Creatures,
  DisciplesRL.Party;

type
  TCity = record
    X, Y: Integer;
    CurLevel: Integer;
    MaxLevel: Integer;
    Owner: TRaceEnum;
  end;

var
  City: array [0 .. 29] of TCity;

procedure Init;
function GetCityIndex(const AX, AY: Integer): Integer;
procedure UpdateRadius(const AID: Integer);
procedure Gen;

implementation

uses
  System.Math,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Utils,
  DisciplesRL.Player,
  DisciplesRL.Game;

const
  NCity = 7;

procedure Init;
var
  I: Integer;
begin
  for I := 0 to High(City) do
  begin
    City[I].X := 0;
    City[I].Y := 0;
    City[I].CurLevel := 0;
    City[I].MaxLevel := 2;
    City[I].Owner := reNeutrals;
  end;
end;

function GetCityIndex(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(City) do
    if ((City[I].X = AX) and (City[I].Y = AY)) then
    begin
      Result := I;
      Break;
    end;
end;

procedure UpdateRadius(const AID: Integer);
begin
  DisciplesRL.Map.UpdateRadius(City[AID].X, City[AID].Y, City[AID].CurLevel, Map[lrTile], reTheEmpireTerrain,
    [reTheEmpireCity, reNeutralCity, reTheEmpireCapital, reRuin, reTower]);
  DisciplesRL.Map.UpdateRadius(City[AID].X, City[AID].Y, City[AID].CurLevel, Map[lrDark], reNone);
  City[AID].Owner := reTheEmpire;
end;

function GetRadius(const N: Integer): Integer;
begin
  case N of
    0: // Capital
      Result := 7;
    1 .. NCity: // City
      Result := 6;
    NCity + 1: // Tower
      Result := 3;
  else // Ruin
    Result := 2;
  end;
end;

function ChCity(N: Integer): Boolean;
var
  I: Integer;
begin
  Result := True;
  if (N = 0) then
    Exit;
  for I := 0 to N - 1 do
  begin
    if (GetDist(City[I].X, City[I].Y, City[N].X, City[N].Y) <= GetRadius(N)) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure ClearObj(const AX, AY: Integer);
var
  X, Y: Integer;
begin
  for X := AX - 2 to AX + 2 do
    for Y := AY - 2 to AY + 2 do
      if (X = AX - 2) or (X = AX + 2) or (Y = AY - 2) or (Y = AY + 2) then
      begin
        if (RandomRange(0, 5) = 0) then
          Map[lrObj][X, Y] := reNone
      end
      else
        Map[lrObj][X, Y] := reNone;
end;

procedure Gen;
var
  X, Y, DX, DY, I: Integer;
begin
  for I := 0 to High(City) do
  begin
    repeat
      City[I].X := RandomRange(3, MapWidth - 3);
      City[I].Y := RandomRange(3, MapHeight - 3);
    until ChCity(I);
    case I of
      0: // Capital
        begin
          Player.X := City[I].X;
          Player.Y := City[I].Y;
          Map[lrTile][City[I].X, City[I].Y] := reTheEmpireCapital;
          ClearObj(City[I].X, City[I].Y);
          UpdateRadius(I);
          // Party
          CapitalParty.SetLocation(Player.X, Player.Y);
          CapitalParty.AddCreature(TheEmpireCapitalGuardian, 3);
        end;
      1 .. NCity: // City
        begin
          Map[lrTile][City[I].X, City[I].Y] := reNeutralCity;
          ClearObj(City[I].X, City[I].Y);
          AddPartyAt(City[I].X, City[I].Y);
        end;
      NCity + 1: // Tower
        begin
          Map[lrTile][City[I].X, City[I].Y] := reTower;
          AddPartyAt(City[I].X, City[I].Y, True);
        end
    else // Ruin
      begin
        Map[lrTile][City[I].X, City[I].Y] := reRuin;
        AddPartyAt(City[I].X, City[I].Y);
      end;
    end;
    // Mine
    repeat
      DX := RandomRange(-2, 2);
      DY := RandomRange(-2, 2);
    until ((DX <> 0) and (DY <> 0));
    case I of
      0 .. NCity:
        Map[lrObj][City[I].X + DX, City[I].Y + DY] := reMine;
    end;
  end;
end;

end.
