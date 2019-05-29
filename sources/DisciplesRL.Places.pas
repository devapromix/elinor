unit DisciplesRL.Places;

interface

uses
  DisciplesRL.Creatures,
  DisciplesRL.Party,
  DisciplesRL.Saga;

type
  TPlace = record
    X, Y: Integer;
    CurLevel: Integer;
    MaxLevel: Integer;
    Owner: TRaceEnum;
    class function GetIndex(const AX, AY: Integer): Integer; static;
    class procedure UpdateRadius(const AID: Integer); static;
    class function GetCityCount: Integer; static;
    class procedure Gen; static;
  end;

var
  Place: array [0 .. TScenario.ScenarioPlacesMax - 1] of TPlace;

procedure Init;

implementation

uses
  Vcl.Dialogs,
  System.Math,
  System.SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Leader;

procedure Init;
var
  I: Integer;
begin
  for I := 0 to High(Place) do
  begin
    Place[I].X := 0;
    Place[I].Y := 0;
    Place[I].CurLevel := 0;
    Place[I].MaxLevel := 2;
    Place[I].Owner := reNeutrals;
  end;
end;

function GetRadius(const N: Integer): Integer;
begin
  case N of
    0: // Capital
      Result := 7;
    1 .. TScenario.ScenarioCitiesMax: // City
      Result := 6;
    TScenario.ScenarioTowerIndex: // Tower
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
    if (GetDist(Place[I].X, Place[I].Y, Place[N].X, Place[N].Y) <= GetRadius(N)) then
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

{ TPlace }

class procedure TPlace.Gen;
var
  DX, DY, I: Integer;
begin
  for I := 0 to High(Place) do
  begin
    repeat
      Place[I].X := RandomRange(3, MapWidth - 3);
      Place[I].Y := RandomRange(3, MapHeight - 3);
    until ChCity(I);
    case I of
      0: // Capital
        begin
          Leader.SetLocation(Place[I].X, Place[I].Y);
          case TSaga.LeaderRace of
            reTheEmpire:
              Map[lrTile][Place[I].X, Place[I].Y] := reTheEmpireCapital;
            reUndeadHordes:
              Map[lrTile][Place[I].X, Place[I].Y] := reUndeadHordesCapital;
            reLegionsOfTheDamned:
              Map[lrTile][Place[I].X, Place[I].Y] := reLegionsOfTheDamnedCapital;
          end;
          ClearObj(Place[I].X, Place[I].Y);
          TPlace.UpdateRadius(I);
        end;
      1 .. TScenario.ScenarioCitiesMax: // City
        begin
          Map[lrTile][Place[I].X, Place[I].Y] := reNeutralCity;
          ClearObj(Place[I].X, Place[I].Y);
          TSaga.AddPartyAt(Place[I].X, Place[I].Y);
        end;
      TScenario.ScenarioTowerIndex: // Tower
        begin
          Map[lrTile][Place[I].X, Place[I].Y] := reTower;
          TSaga.AddPartyAt(Place[I].X, Place[I].Y, True);
        end
    else // Ruin
      begin
        Map[lrTile][Place[I].X, Place[I].Y] := reRuin;
        TSaga.AddPartyAt(Place[I].X, Place[I].Y);
      end;
    end;
    // Mine
    repeat
      DX := RandomRange(-2, 2);
      DY := RandomRange(-2, 2);
    until ((DX <> 0) and (DY <> 0));
    case I of
      0 .. TScenario.ScenarioCitiesMax:
        Map[lrObj][Place[I].X + DX, Place[I].Y + DY] := reMine;
    end;
  end;
end;

class function TPlace.GetIndex(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(Place) do
    if ((Place[I].X = AX) and (Place[I].Y = AY)) then
    begin
      Result := I;
      Break;
    end;
end;

class procedure TPlace.UpdateRadius(const AID: Integer);
begin
  DisciplesRL.Map.UpdateRadius(Place[AID].X, Place[AID].Y, Place[AID].CurLevel, Map[lrTile], RaceTerrain[TSaga.LeaderRace],
    [reNeutralCity, reRuin, reTower] + Capitals + Cities);
  DisciplesRL.Map.UpdateRadius(Place[AID].X, Place[AID].Y, Place[AID].CurLevel, Map[lrDark], reNone);
  Place[AID].Owner := TSaga.LeaderRace;
end;

class function TPlace.GetCityCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to TScenario.ScenarioCitiesMax do
  begin
    if (Place[I].Owner in Races) then
      Inc(Result);
  end;
end;

end.
