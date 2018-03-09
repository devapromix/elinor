unit DisciplesRL.Map;

interface

uses DisciplesRL.Resources, DisciplesRL.Party;

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
  MapTile: TMapLayer;
  MapPath: TMapLayer;
  MapDark: TMapLayer;
  MapObj: TMapLayer;

procedure Init;
procedure Clear(const L: TLayerEnum);
procedure Gen;
function InMap(X, Y: Integer): Boolean;
procedure UpdateRadius(const AX, AY, AR: Integer; var MapLayer: TMapLayer; const AResEnum: TResEnum;
  IgnoreRes: TIgnoreRes = []);
function GetDistToCapital(const AX, AY: Integer): Integer;

var
  Party: array of TParty;
  LeaderParty: TParty;
  CapitalParty: TParty;

procedure PartyInit(const AX, AY: Integer);
procedure PartyFree;
function PartyCount: Integer;
function PartyID(const AX, AY: Integer): Integer;

implementation

uses System.Math, System.SysUtils, DisciplesRL.Player, DisciplesRL.Utils, DisciplesRL.City, DisciplesRL.PathFind,
  DisciplesRL.Game, DisciplesRL.Creatures;

procedure Init;
var
  L: TLayerEnum;
begin
  SetLength(MapTile, MapWidth, MapHeight);
  SetLength(MapPath, MapWidth, MapHeight);
  SetLength(MapDark, MapWidth, MapHeight);
  SetLength(MapObj, MapWidth, MapHeight);
  for L := Low(TLayerEnum) to High(TLayerEnum) do
    Clear(L);
  DisciplesRL.City.Init;
  //
  LeaderParty := TParty.Create;
  CapitalParty := TParty.Create;
end;

function GetDistToCapital(const AX, AY: Integer): Integer;
begin
  Result := GetDist(City[0].X, City[0].Y, AX, AY);
end;

procedure Clear(const L: TLayerEnum);
var
  X, Y: Integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
      case L of
        lrTile:
          MapTile[X, Y] := reNone;
        lrPath:
          MapPath[X, Y] := reNone;
        lrDark:
          MapDark[X, Y] := reDark;
        lrObj:
          MapObj[X, Y] := reNone;
      end;
end;

function ChTile(X, Y: Integer): Boolean; stdcall;
begin
  Result := True;
end;

procedure Gen;
var
  X, Y, RX, RY, I: Integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
    begin
      MapTile[X, Y] := reNeutral;
      if (X = 0) or (X = MapWidth - 1) or (Y = 0) or (Y = MapHeight - 1) then
      begin
        MapObj[X, Y] := reMountain;
        Continue;
      end;
      case RandomRange(0, 5) of
        0:
          MapObj[X, Y] := reTreePine;
        1:
          MapObj[X, Y] := reTreeOak;
      else
        MapObj[X, Y] := reMountain;
      end;

    end;
  // Capital and Cities
  DisciplesRL.City.Gen;
  X := City[0].X;
  Y := City[0].Y;
  for I := 1 to High(City) do
  begin
    repeat
      if PathFind(X, Y, City[I].X, City[I].Y, ChTile, RX, RY) then
      begin
        // if (RandomRange(0, 2) = 0) then
        begin
          X := RX + RandomRange(-1, 2);
          Y := RY + RandomRange(-1, 2);
          if MapObj[X, Y] = reMountain then
            MapObj[X, Y] := reNone;
        end;
        X := RX;
        Y := RY;
        if MapObj[X, Y] = reMountain then
          MapObj[X, Y] := reNone;
      end;
    until ((X = City[I].X) and (Y = City[I].Y));
  end;
  // Golds and Bags
  for I := 0 to High(City) div 2 do
  begin
    repeat
      X := RandomRange(2, MapWidth - 2);
      Y := RandomRange(2, MapHeight - 2);
    until (MapTile[X, Y] = reNeutral) and (MapObj[X, Y] = reNone);
    if (GetDistToCapital(X, Y) <= 15) and (RandomRange(0, 9) > 2) then
      MapObj[X, Y] := reGold
    else
      MapObj[X, Y] := reBag;
  end;
  // Enemies
  for I := 0 to High(City) do
  begin
    repeat
      X := RandomRange(1, MapWidth - 1);
      Y := RandomRange(1, MapHeight - 1);
    until (MapObj[X, Y] = reNone) and (MapTile[X, Y] = reNeutral) and (GetDistToCapital(X, Y) >= 3);
    MapObj[X, Y] := reEnemies;
    PartyInit(X, Y);
  end;
  // Leader's party
  DisciplesRL.Player.Gen;
end;

function InMap(X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (X < MapWidth) and (Y >= 0) and (Y < MapHeight);
end;

procedure UpdateRadius(const AX, AY, AR: Integer; var MapLayer: TMapLayer; const AResEnum: TResEnum;
  IgnoreRes: TIgnoreRes = []);
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
          if (MapLayer = MapTile) and (MapObj[AX + X, AY + Y] = reMine) and (MapTile[AX + X, AY + Y] = reNeutral) then
            Inc(GoldMines);
          MapLayer[AX + X, AY + Y] := AResEnum;
        end;
end;

procedure PartyInit(const AX, AY: Integer);
var
  L: Integer;
begin
  L := GetDistToCapital(AX, AY);
  SetLength(Party, PartyCount + 1);
  Party[PartyCount - 1] := TParty.Create;
  with Party[PartyCount - 1] do
  begin
    AddCreature(crGoblin, 2);
  end;
end;

procedure PartyFree;
var
  I: Integer;
begin
  for I := 0 to PartyCount - 1 do
    FreeAndNil(Party[I]);
end;

function PartyCount: Integer;
begin
  Result := Length(Party);
end;

function PartyID(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to PartyCount - 1 do
    if (Party[I].X = AX) and (Party[I].Y = AY) then
    begin
      Result := I;
      Exit;
    end;
end;

end.
