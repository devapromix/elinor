unit DisciplesRL.Scene.Map;

interface

uses
  System.Classes,
  DisciplesRL.Scenes,
  Vcl.Controls;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses
  System.SysUtils,
  System.Math,
  System.Types,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Leader,
  Vcl.Dialogs,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Game;

var
  LastMousePos, MousePos: TPoint;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Init;
begin

end;

procedure Render;
var
  X, Y: Integer;
  F: Boolean;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
    begin
      if (Map[lrDark][X, Y] = reDark) then
        Continue;
      case Map[lrTile][X, Y] of
        reTheEmpireTerrain, reTheEmpireCapital, reTheEmpireCity:
          DrawImage(X * TileSize, Y * TileSize, ResImage[reTheEmpireTerrain]);
        reUndeadHordesTerrain, reUndeadHordesCapital, reUndeadHordesCity:
          DrawImage(X * TileSize, Y * TileSize, ResImage[reUndeadHordesTerrain]);
        reLegionsOfTheDamnedTerrain, reLegionsOfTheDamnedCapital, reLegionsOfTheDamnedCity:
          DrawImage(X * TileSize, Y * TileSize, ResImage[reLegionsOfTheDamnedTerrain]);
      else
        DrawImage(X * TileSize, Y * TileSize, ResImage[reNeutralTerrain]);
      end;
      F := (GetDist(X, Y, Leader.X, Leader.Y) > Leader.Radius) and not(Map[lrTile][X, Y] in Tiles + Capitals + Cities) and
        (Map[lrDark][X, Y] = reNone);
      // Capital, Cities, Ruins and Tower
      if (ResBase[Map[lrTile][X, Y]].ResType in [teCapital, teCity, teRuin, teTower]) then
        DrawImage(X * TileSize, Y * TileSize, ResImage[Map[lrTile][X, Y]]);
      //
      if (ResBase[Map[lrObj][X, Y]].ResType in [teEnemy, teBag]) then
        if F then
          DrawImage(X * TileSize, Y * TileSize, ResImage[reUnk])
        else
          DrawImage(X * TileSize, Y * TileSize, ResImage[Map[lrObj][X, Y]])
      else if (Map[lrObj][X, Y] <> reNone) then
        DrawImage(X * TileSize, Y * TileSize, ResImage[Map[lrObj][X, Y]]);
      // Leader
      if (X = Leader.X) and (Y = Leader.Y) then
        DrawImage(X * TileSize, Y * TileSize, ResImage[rePlayer]);
      // Fog
      if F then
        DrawImage(X * TileSize, Y * TileSize, ResImage[reDark]);
    end;
  // Cursor
  DrawImage(MousePos.X * TileSize, MousePos.Y * TileSize, ResImage[reCursor]);
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if Wizard and DisciplesRL.Map.InMap(MousePos.X, MousePos.Y) then
    Leader.PutAt(MousePos.X, MousePos.Y);
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
    K_ESCAPE:
      DisciplesRL.Scenes.CurrentScene := scMenu;
    K_ENTER:
      begin
        if LeaderTile in Capitals then
          DisciplesRL.Scene.Settlement.Show(stCapital);
        if LeaderTile in Cities then
          DisciplesRL.Scene.Settlement.Show(stCity);
      end;
    K_UP:
      Leader.Move(0, -1);
    K_DOWN:
      Leader.Move(0, 1);
    K_LEFT:
      Leader.Move(-1, 0);
    K_RIGHT:
      Leader.Move(1, 0);
  end;
end;

procedure Free;
begin

end;

end.
