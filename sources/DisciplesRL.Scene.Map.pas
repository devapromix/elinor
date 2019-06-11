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
  DisciplesRL.Saga,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Party;

var
  LastMousePos, MousePos: TPoint;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbMiddle:
      begin
        TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y, True);
      end;
  end;
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
      F := (GetDist(X, Y, Leader.X, Leader.Y) > TLeaderParty.Leader.Radius) and not(Map[lrTile][X, Y] in Tiles + Capitals + Cities) and
        (Map[lrDark][X, Y] = reNone);

      // Special
      if TSaga.Wizard and (((TScenario.CurrentScenario = sgAncientKnowledge) and TScenario.IsStoneTab(X, Y)) or
        ((TScenario.CurrentScenario = sgDarkTower) and (ResBase[Map[lrTile][X, Y]].ResType = teTower)) or
        ((TScenario.CurrentScenario = sgOverlord) and (ResBase[Map[lrTile][X, Y]].ResType = teCity))) then
        DrawImage(X * TileSize, Y * TileSize, ResImage[reCursorSpecial]);

      // Capital, Cities, Ruins and Tower
      if (ResBase[Map[lrTile][X, Y]].ResType in [teCapital, teCity, teRuin, teTower]) then
        DrawImage(X * TileSize, Y * TileSize, ResImage[Map[lrTile][X, Y]]);

      //
      if (ResBase[Map[lrObj][X, Y]].ResType in [teEnemy, teBag]) then
        if F then
          DrawImage(X * TileSize, Y * TileSize, ResImage[reUnk])
        else
          DrawImage(X * TileSize, Y * TileSize, ResImage[Map[lrObj][X, Y]])
          /// else if (ResBase[Map[lrObj][X, Y]].ResType in [teTree]) then
          /// begin
          /// end
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
  if IsLeaderMove(MousePos.X, MousePos.Y) then
    DrawImage(MousePos.X * TileSize, MousePos.Y * TileSize, ResImage[reCursor])
  else
    DrawImage(MousePos.X * TileSize, MousePos.Y * TileSize, ResImage[reNoWay]);
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if TSaga.Wizard and DisciplesRL.Map.InMap(MousePos.X, MousePos.Y) then
    TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y)
  else if IsLeaderMove(MousePos.X, MousePos.Y) and DisciplesRL.Map.InMap(MousePos.X, MousePos.Y) then
    TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y);
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
    K_LEFT, K_KP_4, K_A:
      TLeaderParty.Leader.Move(drWest);
    K_RIGHT, K_KP_6, K_D:
      TLeaderParty.Leader.Move(drEast);
    K_UP, K_KP_8, K_W:
      TLeaderParty.Leader.Move(drNorth);
    K_DOWN, K_KP_2, K_X:
      TLeaderParty.Leader.Move(drSouth);
    K_KP_7, K_Q:
      TLeaderParty.Leader.Move(drNorthWest);
    K_KP_9, K_E:
      TLeaderParty.Leader.Move(drNorthEast);
    K_KP_1, K_Z:
      TLeaderParty.Leader.Move(drSouthWest);
    K_KP_3, K_C:
      TLeaderParty.Leader.Move(drSouthEast);
    K_KP_5, K_S:
      TLeaderParty.Leader.Move(drOrigin);
    K_P:
      DisciplesRL.Scene.Party.Show(Party[LeaderPartyIndex], scMap);
    K_J:
      DisciplesRL.Scene.Hire.Show(stJournal);
  end;

end;

procedure Free;
begin

end;

end.
