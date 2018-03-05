unit DisciplesRL.Scene.Map;

interface

uses System.Classes, DisciplesRL.Scenes;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, System.Math, System.Types, Vcl.Imaging.PNGImage, DisciplesRL.Map, DisciplesRL.Resources,
  DisciplesRL.Player,
  DisciplesRL.Utils;

const
  K_RIGHT = 39;
  K_LEFT = 37;
  K_DOWN = 40;
  K_UP = 38;

var
  LastMousePos, MousePos: TPoint;

procedure Init;
begin

end;

procedure DrawImage(X, Y: Integer; Image: TPNGImage);
begin
  Surface.Canvas.Draw(X * TileSize, Y * TileSize, Image);
end;

procedure Render;
var
  X, Y: Integer;
  F: Boolean;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
    begin
      if (MapDark[X, Y] = reDark) then
        Continue;
      case MapTile[X, Y] of
        reEmpireTerrain, reEmpireCapital, reEmpireCity:
          DrawImage(X, Y, ResImage[reEmpireTerrain]);
      else
        DrawImage(X, Y, ResImage[reNeutral]);
      end;
      F := (GetDist(X, Y, Player.X, Player.Y) > Player.Radius) and
        not(MapTile[X, Y] in [reEmpireTerrain, reEmpireCapital, reEmpireCity]) and (MapDark[X, Y] = reNone);
      // Capital and Cities
      if (ResBase[MapTile[X, Y]].ResType in [teCapital, teCity]) then
        DrawImage(X, Y, ResImage[MapTile[X, Y]]);
      //
      if (ResBase[MapObj[X, Y]].ResType in [teEnemy, teBag]) then
        if F then
          DrawImage(X, Y, ResImage[reUnk])
        else
          DrawImage(X, Y, ResImage[MapObj[X, Y]])
      else if (MapObj[X, Y] <> reNone) then
          DrawImage(X, Y, ResImage[MapObj[X, Y]]);
        // Leader
        if (X = Player.X) and (Y = Player.Y) then
          DrawImage(X, Y, ResImage[rePlayer]);
      // Fog
      if F then
        DrawImage(X, Y, ResImage[reDark]);
    end;
  // Cursor
  DrawImage(MousePos.X, MousePos.Y, ResImage[reCursor]);
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if DisciplesRL.Map.InMap(MousePos.X, MousePos.Y) then
    DisciplesRL.Player.PutAt(MousePos.X, MousePos.Y);
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MousePos := Point(X div TileSize, Y div TileSize);
  if (MousePos.X <> LastMousePos.X) or (MousePos.Y <> LastMousePos.Y) then
  begin
    DisciplesRL.Scenes.Render;
    LastMousePos.X := MousePos.X;
    LastMousePos.Y := MousePos.Y;
  end;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_UP:
      DisciplesRL.Player.Move(0, -1);
    K_DOWN:
      DisciplesRL.Player.Move(0, 1);
    K_LEFT:
      DisciplesRL.Player.Move(-1, 0);
    K_RIGHT:
      DisciplesRL.Player.Move(1, 0);
  end;
end;

procedure Free;
begin

end;

end.
