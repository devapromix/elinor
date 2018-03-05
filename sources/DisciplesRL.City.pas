unit DisciplesRL.City;

interface

uses DisciplesRL.Party;

type
  TCity = record
    X, Y: Integer;
    CurLevel: Integer;
    MaxLevel: Integer;
    Owner: TRaceEnum;
  end;

var
  City: array [0 .. 3] of TCity;

procedure Init;
function GetCityIndex(const AX, AY: Integer): Integer;
procedure UpdateRadius(const AID: Integer);
procedure Gen;

implementation

uses System.Math, DisciplesRL.Map, DisciplesRL.Resources, DisciplesRL.Utils, DisciplesRL.Player;

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
  DisciplesRL.Map.UpdateRadius(City[AID].X, City[AID].Y, City[AID].CurLevel, MapTile, reEmpireTerrain,
    [reEmpireCity, reNeutralCity, reEmpireCapital]);
  DisciplesRL.Map.UpdateRadius(City[AID].X, City[AID].Y, City[AID].CurLevel, MapDark, reNone);
  City[AID].Owner := reTheEmpire;
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
    if (GetDist(City[I].X, City[I].Y, City[N].X, City[N].Y) <= 6) then
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
            MapObj[X, Y] := reNone
        end
        else
          MapObj[X, Y] := reNone;
end;

procedure Gen;
var
  I, X, Y: Integer;
begin
  for I := 0 to High(City) do
  begin
    repeat
      City[I].X := RandomRange(3, MapWidth - 3);
      City[I].Y := RandomRange(3, MapHeight - 3);
    until ChCity(I);
    // Capital
    if (I = 0) then
    begin
      Player.X := City[I].X;
      Player.Y := City[I].Y;
      MapTile[City[I].X, City[I].Y] := reEmpireCapital;
      ClearObj(City[I].X, City[I].Y);
      UpdateRadius(I);
      Continue;
    end;
    // City
    MapTile[City[I].X, City[I].Y] := reNeutralCity;
    ClearObj(City[I].X, City[I].Y);
    MapObj[City[I].X, City[I].Y] := reEnemies;
  end;
end;

end.
