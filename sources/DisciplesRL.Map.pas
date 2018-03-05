unit DisciplesRL.Map;

interface

uses DisciplesRL.Resources;

var
  MapWidth: Integer = 40;
  MapHeight: Integer = 20;

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

implementation

uses System.Math, DisciplesRL.Player, DisciplesRL.Utils, DisciplesRL.City, DisciplesRL.PathFind;

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
      MapObj[X, Y] := reMountain;
    end;
  // Bags
  // for X := 0 to 5 do
  // MapObj[RandomRange(0, MapWidth), RandomRange(0, MapHeight)] := reBag;
  // Capital and Cities
  DisciplesRL.City.Gen;
  X := City[0].X;
  Y := City[0].Y;
  for I := 1 to High(City) do
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
  // Enemies
  for I := 0 to High(City) do
  begin
    repeat
      X := RandomRange(1, MapWidth - 1);
      Y := RandomRange(1, MapHeight - 1);
    until (MapObj[X, Y] = reNone);
    MapObj[X, Y] := reEnemies;
  end;
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
          MapLayer[AX + X, AY + Y] := AResEnum;
end;

end.
