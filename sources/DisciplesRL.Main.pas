unit DisciplesRL.Main;

interface

var
  MapWidth: Integer = 28 + 2; //40 + 2;
  MapHeight: Integer = 20 + 2;

type
  TLayerEnum = (lrTile, lrPath, lrDark, lrObj);
  TMapLayer = array of array of Cardinal;

var
    Map: array [TLayerEnum] of TMapLayer;

implementation

uses
  Math;

procedure Clear(const L: TLayerEnum);
var
  X, Y: Integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
      case L of
        lrTile, lrPath, lrObj:
          Map[L][X, Y] := 0;
        lrDark:
          Map[L][X, Y] := 0;
      end;
end;

procedure AddTree(const X, Y: Integer);
begin
  case Random(2) of
      0:
        Map[lrObj][X, Y] := $E009;
      1:
        Map[lrObj][X, Y] := $E010;
  end;
end;

procedure AddMountain(const X, Y: Integer);
begin
  case Random(3) of
      0:
        Map[lrObj][X, Y] := $E006;
      1:
        Map[lrObj][X, Y] := $E007;
      2:
        Map[lrObj][X, Y] := $E008;
  end;
end;

procedure Gen;
var
  X, Y: Integer;
  L: TLayerEnum;
begin
  for L := Low(TLayerEnum) to High(TLayerEnum) do
  begin
    SetLength(Map[L], MapWidth, MapHeight);
    Clear(L);
  end;
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
    begin
      Map[lrTile][X, Y] := $E000;
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
end;

initialization
  Gen;

end.
