unit DisciplesRL.Map;

interface

uses DisciplesRL.Resources;

var
  MapWidth: Integer = 20;
  MapHeight: Integer = 12;

const
  TileSize = 32;

type
  TLayerEnum = (lTile, lPath, lDark);

var
  MapTile: array of array of TResEnum;
  MapPath: array of array of TResEnum;
  MapDark: array of array of TResEnum;

procedure Init;
procedure Clear(const L: TLayerEnum);
procedure Gen;
function InMap(X, Y: Integer): Boolean;

implementation

uses System.Math, DisciplesRL.Player;

procedure Init;
var
  L: TLayerEnum;
begin
  SetLength(MapTile, MapWidth, MapHeight);
  SetLength(MapPath, MapWidth, MapHeight);
  SetLength(MapDark, MapWidth, MapHeight);
  for L := Low(TLayerEnum) to High(TLayerEnum) do
    Clear(L);
end;

procedure Clear(const L: TLayerEnum);
var
  X, Y: Integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
      case L of
        lTile:
          MapTile[X, Y] := reNone;
        lPath:
          MapPath[X, Y] := reNone;
        lDark:
          MapDark[X, Y] := reDark;
      end;
end;

procedure Gen;
var
  X, Y: Integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
      MapTile[X, Y] := reGrass;
  for X := 0 to 7 do
    MapTile[RandomRange(0, MapWidth), RandomRange(0, MapHeight)] := reEnemies;
  for X := 0 to 5 do
    MapTile[RandomRange(0, MapWidth), RandomRange(0, MapHeight)] := reBag;
  for X := 0 to 3 do
    MapTile[RandomRange(0, MapWidth), RandomRange(0, MapHeight)] := reCity;
  // Player
  X := RandomRange(0, MapWidth);
  Y := RandomRange(0, MapHeight);
  MapTile[X, Y] := reCapital;
  Player.X := X;
  Player.Y := Y;
end;

function InMap(X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (X < MapWidth) and (Y >= 0) and (Y < MapHeight);
end;

end.
