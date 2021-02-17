unit DisciplesRL.Scene.Map;

interface

{$IFDEF FPC}

uses
  DisciplesRL.Scene;

type

  { TSceneMap }

  TSceneMap = class(TScene)
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  Classes,
  BearLibTerminal,
  DisciplesRL.Map;

procedure TSceneMap.Render;
var
  X, Y, MX, MY: Integer;
begin
  terminal_layer(0);
  for Y := 0 to Game.Map.Height - 1 do
    for X := 0 to Game.Map.Width - 1 do
    begin
      terminal_layer(1);
      terminal_put(X * 4, Y * 2, Game.Map.GetTile(lrTile, X, Y));
      terminal_layer(2);
      if (Game.Map.GetTile(lrObj, X, Y) <> 0) then
        terminal_put(X * 4, Y * 2, Game.Map.GetTile(lrObj, X, Y));
    end;
  MX := terminal_state(TK_MOUSE_X) div 4;
  MY := terminal_state(TK_MOUSE_Y) div 2;
  terminal_layer(7);
  terminal_put(MX * 4, MY * 2, $E005);
  if Game.IsDebug then
  begin
    terminal_layer(9);
    terminal_print(1, 1, Format('%dx%d', [MX, MY]));
  end;
end;

procedure TSceneMap.Update(var Key: Word);
begin
  case Key of
    TK_ESCAPE:
      Game.SetScene(scMenu);
  end;
end;

{$ELSE}

uses
  System.Classes,
  DisciplesRL.Scenes,
  Vcl.Controls;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure Show;
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

procedure Show;
begin
  MediaPlayer.Play(mmSettlement);
  SetScene(scMap);
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
      if (TMap.GetTile(lrDark, X, Y) = reDark) then
        Continue;
      case TMap.GetTile(lrTile, X, Y) of
        reTheEmpireTerrain, reTheEmpireCapital, reTheEmpireCity:
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
            ResImage[reTheEmpireTerrain]);
        reUndeadHordesTerrain, reUndeadHordesCapital, reUndeadHordesCity:
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
            ResImage[reUndeadHordesTerrain]);
        reLegionsOfTheDamnedTerrain, reLegionsOfTheDamnedCapital,
          reLegionsOfTheDamnedCity:
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
            ResImage[reLegionsOfTheDamnedTerrain]);
      else
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
          ResImage[reNeutralTerrain]);
      end;
      F := (TMap.GetDist(X, Y, TLeaderParty.Leader.X, TLeaderParty.Leader.Y) >
        TLeaderParty.Leader.Radius) and
        not(TMap.GetTile(lrTile, X, Y) in Tiles + Capitals + Cities) and
        (TMap.GetTile(lrDark, X, Y) = reNone);

      // Special
      if TSaga.Wizard and (((TScenario.CurrentScenario = sgAncientKnowledge) and
        TScenario.IsStoneTab(X, Y)) or
        ((TScenario.CurrentScenario = sgDarkTower) and
        (ResBase[TMap.GetTile(lrTile, X, Y)].ResType = teTower)) or
        ((TScenario.CurrentScenario = sgOverlord) and
        (ResBase[TMap.GetTile(lrTile, X, Y)].ResType = teCity))) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
          ResImage[reCursorSpecial]);

      // Capital, Cities, Ruins and Tower
      if (ResBase[TMap.GetTile(lrTile, X, Y)].ResType in [teCapital, teCity,
        teRuin, teTower]) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
          ResImage[TMap.GetTile(lrTile, X, Y)]);

      //
      if (ResBase[TMap.GetTile(lrObj, X, Y)].ResType in [teEnemy, teBag]) then
        if F then
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reUnk])
        else
          DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
            ResImage[TMap.GetTile(lrObj, X, Y)])
      else if (TMap.GetTile(lrObj, X, Y) <> reNone) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
          ResImage[TMap.GetTile(lrObj, X, Y)]);

      // Leader
      if (X = TLeaderParty.Leader.X) and (Y = TLeaderParty.Leader.Y) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[rePlayer]);
      // Fog
      if F then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize, ResImage[reDark]);
    end;
  // Cursor
  if TMap.IsLeaderMove(MousePos.X, MousePos.Y) then
    DrawImage(MousePos.X * TMap.TileSize, MousePos.Y * TMap.TileSize,
      ResImage[reCursor])
  else
    DrawImage(MousePos.X * TMap.TileSize, MousePos.Y * TMap.TileSize,
      ResImage[reNoWay]);
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if TSaga.Wizard and TMap.InMap(MousePos.X, MousePos.Y) then
    TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y)
  else if TMap.IsLeaderMove(MousePos.X, MousePos.Y) and
    TMap.InMap(MousePos.X, MousePos.Y) then
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
        MediaPlayer.PlayMusic(mmMenu);
        MediaPlayer.Play(mmClick);
        MediaPlayer.Play(mmSettlement);
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
    K_ENTER, K_KP_5, K_S:
      TLeaderParty.Leader.Move(drOrigin);
    K_P:
      DisciplesRL.Scene.Party.Show(Party[TLeaderParty.LeaderPartyIndex], scMap);
    K_J:
      DisciplesRL.Scene.Hire.Show(stJournal);
  end;

end;

procedure Free;
begin

end;

{$ENDIF}

end.
