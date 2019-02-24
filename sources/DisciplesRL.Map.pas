unit DisciplesRL.Map;

interface

uses
  DisciplesRL.Resources,
  DisciplesRL.Party;

var
  MapWidth: Integer = 40 + 2;
  MapHeight: Integer = 20 + 2;

const
  TileSize = 32;

type
  TLayerEnum = (lrTile, lrPath, lrDark, lrObj);

type
  TMapLayer = array of array of TResEnum;
  TIgnoreRes = set of TResEnum;

var
  LeaderPartyIndex: Byte;
  CapitalPartyIndex: Byte;

var
  Map: array [TLayerEnum] of TMapLayer;

procedure Gen;
function GetDist(X1, Y1, X2, Y2: Integer): Integer;
function GetDistToCapital(const AX, AY: Integer): Integer;
procedure Init;
procedure Clear(const L: TLayerEnum);
function InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
function InMap(const X, Y: Integer): Boolean;
procedure UpdateRadius(const AX, AY, AR: Integer; var MapLayer: TMapLayer; const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []);
function LeaderTile: TResEnum;
function IsLeaderMove(const X, Y: Integer): Boolean;

implementation

uses
  Vcl.Dialogs,
  System.Math,
  System.SysUtils,
  DisciplesRL.Leader,
  DisciplesRL.Places,
  DisciplesRL.Game,
  DisciplesRL.Creatures,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Party,
  PathFind;

function GetDist(X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

function GetDistToCapital(const AX, AY: Integer): Integer;
begin
  Result := GetDist(Place[0].X, Place[0].Y, AX, AY);
end;

procedure Init;
var
  L: TLayerEnum;
begin
  for L := Low(TLayerEnum) to High(TLayerEnum) do
  begin
    SetLength(Map[L], MapWidth, MapHeight);
    Clear(L);
  end;
  DisciplesRL.Places.Init;
end;

procedure Clear(const L: TLayerEnum);
var
  X, Y: Integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
      case L of
        lrTile, lrPath, lrObj:
          Map[L][X, Y] := reNone;
        lrDark:
          Map[L][X, Y] := reDark;
      end;
end;

function ChTile(X, Y: Integer): Boolean; stdcall;
begin
  Result := True;
end;

procedure AddCapitalParty;
begin
  CapitalPartyIndex := High(Party) + 1;
  SetLength(Party, GetPartyCount + 1);
  Party[GetPartyCount - 1] := TParty.Create(Place[0].X, Place[0].Y, LeaderRace);
  Party[GetPartyCount - 1].AddCreature(Characters[LeaderRace][cgGuardian][ckGuardian], 3);
end;

procedure AddLeaderParty;
var
  C: TCreatureEnum;
begin
  LeaderPartyIndex := High(Party) + 1;
  SetLength(Party, GetPartyCount + 1);
  Party[GetPartyCount - 1] := TLeaderParty.Create(Place[0].X, Place[0].Y, LeaderRace);
  C := Characters[LeaderRace][cgLeaders][TRaceCharKind(HireIndex)];
  case TCreature.Character(C).ReachEnum of
    reAdj:
      begin
        Party[LeaderPartyIndex].AddCreature(C, 2);
        ActivePartyPosition := 2;
      end
  else
    begin
      Party[LeaderPartyIndex].AddCreature(C, 3);
      ActivePartyPosition := 3;
    end;
  end;
end;

procedure Gen;
var
  X, Y, RX, RY, I: Integer;

  procedure AddTree(const X, Y: Integer);
  begin
    case Random(2) of
      0:
        Map[lrObj][X, Y] := reTreePine;
      1:
        Map[lrObj][X, Y] := reTreeOak;
    end;
  end;

  procedure AddMountain(const X, Y: Integer);
  begin
    case Random(3) of
      0:
        Map[lrObj][X, Y] := reMountain1;
      1:
        Map[lrObj][X, Y] := reMountain2;
      2:
        Map[lrObj][X, Y] := reMountain3;
    end;
  end;

begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
    begin
      Map[lrTile][X, Y] := reNeutralTerrain;
      if (X = 0) or (X = MapWidth - 1) or (Y = 0) or (Y = MapHeight - 1) then
      begin
        AddMountain(X, Y);
        Continue;
      end;
      case RandomRange(0, 3) of
        0:
          AddTree(X, Y);
      else
        AddMountain(X, Y);
      end;

    end;
  // Capital and Cities
  DisciplesRL.Places.Gen;
  X := Place[0].X;
  Y := Place[0].Y;
  for I := 1 to High(Place) do
  begin
    repeat
      if IsPathFind(MapWidth, MapHeight, X, Y, Place[I].X, Place[I].Y, ChTile, RX, RY) then
      begin
        // if (RandomRange(0, 2) = 0) then
        begin
          X := RX + RandomRange(-1, 2);
          Y := RY + RandomRange(-1, 2);
          if Map[lrObj][X, Y] in MountainTiles then
            Map[lrObj][X, Y] := reNone;
        end;
        X := RX;
        Y := RY;
        if Map[lrObj][X, Y] in MountainTiles then
          Map[lrObj][X, Y] := reNone;
      end;
    until ((X = Place[I].X) and (Y = Place[I].Y));
  end;
  // Golds and Bags
  for I := 0 to High(Place) div 2 do
  begin
    repeat
      X := RandomRange(2, MapWidth - 2);
      Y := RandomRange(2, MapHeight - 2);
    until (Map[lrTile][X, Y] = reNeutralTerrain) and (Map[lrObj][X, Y] = reNone);
    if (GetDistToCapital(X, Y) <= 15) and (RandomRange(0, 9) > 2) then
      Map[lrObj][X, Y] := reGold
    else
      Map[lrObj][X, Y] := reBag;
  end;
  // Enemies
  for I := 0 to High(Place) do
  begin
    repeat
      X := RandomRange(1, MapWidth - 1);
      Y := RandomRange(1, MapHeight - 1);
    until (Map[lrObj][X, Y] = reNone) and (Map[lrTile][X, Y] = reNeutralTerrain) and (GetDistToCapital(X, Y) >= 3);
    AddPartyAt(X, Y);
    if (CurrentScenario = sgAncientKnowledge) and (I < TScenario.ScenarioStoneTabMax) then
      TScenario.AddStoneTab(X, Y);
  end;
  AddCapitalParty;
  AddLeaderParty;
end;

function InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
begin
  Result := (X >= X1) and (Y >= Y1) and (X <= X2) and (Y <= Y2);
end;

function InMap(const X, Y: Integer): Boolean;
begin
  Result := InRect(X, Y, 0, 0, MapWidth - 1, MapHeight - 1);
end;

procedure UpdateRadius(const AX, AY, AR: Integer; var MapLayer: TMapLayer; const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []);
var
  X, Y: Integer;
begin
  for Y := -AR to AR do
    for X := -AR to AR do
      if (GetDist(AX + X, AY + Y, AX, AY) <= AR) and DisciplesRL.Map.InMap(AX + X, AY + Y) then
        if (MapLayer[AX + X, AY + Y] in IgnoreRes) then
          Continue
        else
        begin
          // Add mine
          if (MapLayer = Map[lrTile]) and (Map[lrObj][AX + X, AY + Y] = reMine) and (Map[lrTile][AX + X, AY + Y] = reNeutralTerrain) then
            Inc(GoldMines);
          MapLayer[AX + X, AY + Y] := AResEnum;
        end;
end;

function LeaderTile: TResEnum;
begin
  Result := Map[lrTile][Leader.X, Leader.Y];
end;

function IsLeaderMove(const X, Y: Integer): Boolean;
begin
  Result := (InRect(X, Y, Leader.X - 1, Leader.Y - 1, Leader.X + 1, Leader.Y + 1) or Wizard) and not(Map[lrObj][X, Y] in StopTiles);
end;

end.
