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
  Vcl.Dialogs,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Saga,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Party;

var
  LastMousePos, MousePos: TPoint;

procedure Init;
begin

end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbMiddle:
      begin
        TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y, True);
      end;
  end;
end;

procedure Render;
var
  X, Y: Integer;
  F: Boolean;
begin
  for Y := 0 to TMap.Height - 1 do
    for X := 0 to TMap.Width - 1 do
    begin
      if (TMap.Map[lrDark][X, Y] = reDark) then
        Continue;
      case TMap.Map[lrTile][X, Y] of
        reTheEmpireTerrain, reTheEmpireCapital, reTheEmpireCity:
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reTheEmpireTerrain]);
        reUndeadHordesTerrain, reUndeadHordesCapital, reUndeadHordesCity:
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reUndeadHordesTerrain]);
        reLegionsOfTheDamnedTerrain, reLegionsOfTheDamnedCapital, reLegionsOfTheDamnedCity:
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reLegionsOfTheDamnedTerrain]);
      else
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reNeutralTerrain]);
      end;
      F := (TMap.GetDist(X, Y, TLeaderParty.Leader.X, TLeaderParty.Leader.Y) > TLeaderParty.Leader.Radius) and
        not(TMap.Map[lrTile][X, Y] in Tiles + Capitals + Cities) and (TMap.Map[lrDark][X, Y] = reNone);

      // Special
      if TSaga.Wizard and (((TScenario.CurrentScenario = sgAncientKnowledge) and TScenario.IsStoneTab(X, Y)) or
        ((TScenario.CurrentScenario = sgDarkTower) and (ResBase[TMap.Map[lrTile][X, Y]].ResType = teTower)) or
        ((TScenario.CurrentScenario = sgOverlord) and (ResBase[TMap.Map[lrTile][X, Y]].ResType = teCity))) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reCursorSpecial]);

      // Capital, Cities, Ruins and Tower
      if (ResBase[TMap.Map[lrTile][X, Y]].ResType in [teCapital, teCity, teRuin, teTower]) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[TMap.Map[lrTile][X, Y]]);

      //
      if (ResBase[TMap.Map[lrObj][X, Y]].ResType in [teEnemy, teBag]) then
        if F then
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reUnk])
        else
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[TMap.Map[lrObj][X, Y]])
      else if (TMap.Map[lrObj][X, Y] <> reNone) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[TMap.Map[lrObj][X, Y]]);

      // Leader
      if (X = TLeaderParty.Leader.X) and (Y = TLeaderParty.Leader.Y) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[rePlayer]);
      // Fog
      if F then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reDark]);
    end;
  // Cursor
  if TMap.IsLeaderMove(MousePos.X, MousePos.Y) then
    DrawImage(MousePos.X * TMap.TileSize, MousePos.Y * TMap.TileSize, ResImage[reCursor])
  else
    DrawImage(MousePos.X * TMap.TileSize, MousePos.Y * TMap.TileSize, ResImage[reNoWay]);
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if TSaga.Wizard and TMap.InMap(MousePos.X, MousePos.Y) then
    TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y)
  else if TMap.IsLeaderMove(MousePos.X, MousePos.Y) and TMap.InMap(MousePos.X, MousePos.Y) then
    TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y);
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MousePos := Point(X div TMap.TileSize, Y div TMap.TileSize);
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
    begin
      SetSceneMusic(scMenu);
      SetScene(scMenu);
    end;
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
