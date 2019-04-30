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
  DisciplesRL.Player,
  Vcl.Dialogs,
  DisciplesRL.Utils,
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
      else
        DrawImage(X * TileSize, Y * TileSize, ResImage[reNeutral]);
      end;
      F := (GetDist(X, Y, Player.X, Player.Y) > Player.Radius) and not(Map[lrTile][X, Y] in [reTheEmpireTerrain, reTheEmpireCapital, reTheEmpireCity])
        and (Map[lrDark][X, Y] = reNone);
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
      if (X = Player.X) and (Y = Player.Y) then
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
    K_ESCAPE:
      DisciplesRL.Scenes.CurrentScene := scMenu;
    K_ENTER:
      begin
        case PlayerTile of
          reTheEmpireCapital:
            begin
              DisciplesRL.Scene.Settlement.Show(stCapital);
            end;
          reTheEmpireCity:
            begin
              DisciplesRL.Scene.Settlement.Show(stCity);
            end;
        end;
      end;
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
