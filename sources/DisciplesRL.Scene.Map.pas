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
      DrawImage(X, Y, ResImage[reGrass]);
      F := (Utils.GetDist(X, Y, Player.X, Player.Y) > Player.Rad) and (MapDark[X, Y] = reNone);
      //
      if (ResBase[MapTile[X, Y]].ResType in [teEnemy, teBag]) then
        if F then
          DrawImage(X, Y, ResImage[reUnk])
        else
          DrawImage(X, Y, ResImage[MapTile[X, Y]]);
      if (ResBase[MapTile[X, Y]].ResType in [teCapital, teCity, teObject]) then
        DrawImage(X, Y, ResImage[MapTile[X, Y]]);
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
  begin
    Player.X := MousePos.X;
    Player.Y := MousePos.Y;
    DisciplesRL.Player.RefreshRad;
    if (MapTile[Player.X, Player.Y] in [reBag, reEnemies]) then
      MapTile[Player.X, Player.Y] := reNone;

  end;
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

end;

procedure Free;
begin

end;

end.
