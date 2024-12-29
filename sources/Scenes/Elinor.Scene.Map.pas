unit Elinor.Scene.Map;

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Types,
  Vcl.Controls,
{$ENDIF}
  Classes,
  Elinor.Scenes;

{ TSceneMap }

type
  TSceneMap = class(TScene)
  private
  var
    LastMousePos, MousePos: TPoint;
    FM: Boolean;
    BB: Boolean;
    BT: Boolean;
    procedure ShowPartyScene;
  public
    procedure Show(const S: TSceneEnum); override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

uses
  SysUtils,
  Elinor.Map,
  Elinor.Resources,
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Scene.Party,
  DisciplesRL.Scene.Hire,
  Elinor.Party,
  Elinor.Creatures,
  Elinor.Scene.Spellbook,
  Elinor.Scene.Scenario,
  Elinor.PathFind,
  Elinor.Scene.Party2;

{ TSceneMap }

procedure TSceneMap.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  CurrentPartyIndex: Integer;
  NX, NY, FX, FY, SX, SY: Integer;
begin
  inherited;
  case Button of
    mbLeft:
      begin
        if BB then
          Exit;

        if FM then
        begin
          // Game.Map.UpdateRadius(MousePos.X, MousePos.Y, 1);
          CurrentPartyIndex := TSaga.GetPartyIndex(MousePos.X, MousePos.Y);
          if CurrentPartyIndex > 0 then
          begin
            Party[CurrentPartyIndex].HealAll(25);
            FM := False;
          end;
          Exit;
        end;

        if Game.Wizard and Game.Map.InMap(MousePos.X, MousePos.Y) then
          TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y)
        else if Game.Map.IsLeaderMove(MousePos.X, MousePos.Y) and
          Game.Map.InMap(MousePos.X, MousePos.Y) then
          TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y);
      end;
    mbRight:
      begin
        if BB then
          Exit;

        FX := MousePos.X;
        FY := MousePos.Y;
        SX := TLeaderParty.Leader.X;
        SY := TLeaderParty.Leader.Y;

        if ((FX = SX) and (FY = SY)) then
          Exit;
        if (Game.Map.GetLayer(lrPath)[FX, FY] = reASell) then
        begin
          BB := True;
          Exit;
        end;
        if not BB then
          Game.Map.Clear(lrPath);

        repeat
          if not DoAStar(Game.Map.Width, Game.Map.Height, SX, SY, FX, FY,
            @IsMoveLeader, NX, NY) then
            Exit;

          if ((NX = FX) and (NY = FY)) then
            Game.Map.GetLayer(lrPath)[NX, NY] := reASell
          else
            Game.Map.GetLayer(lrPath)[NX, NY] := reAMark;

          SX := NX;
          SY := NY;
        until ((SX = FX) and (SY = FY));
      end;
    mbMiddle:
      begin
        if BB then
          Exit;

        if TLeaderParty.Leader.InRadius(MousePos.X, MousePos.Y) then
          if not TLeaderParty.Leader.IsPartyOwner(MousePos.X, MousePos.Y) then
          begin
            TSceneHire.MPX := MousePos.X;
            TSceneHire.MPY := MousePos.Y;
            // Leader Thief
            if (TLeaderParty.Leader.Enum in LeaderThief) then
              if TSaga.GetPartyIndex(MousePos.X, MousePos.Y) > 0 then
                TSceneHire.Show(stSpy);
          end
          else
          begin
            // Leader Warrior
            if (TLeaderParty.Leader.Enum in LeaderWarrior) then
              if (MousePos.X = TLeaderParty.Leader.X) and
                (MousePos.Y = TLeaderParty.Leader.Y) then
                TSceneHire.Show(stWar);
          end;
      end;
  end;
end;

procedure TSceneMap.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  MousePos := Point(X div TMap.TileSize, Y div TMap.TileSize);
  if (MousePos.X <> LastMousePos.X) or (MousePos.Y <> LastMousePos.Y) then
  begin
    Game.Render;
    LastMousePos.X := MousePos.X;
    LastMousePos.Y := MousePos.Y;
  end;
end;

procedure TSceneMap.ShowPartyScene;
begin
  TSceneParty2.ShowScene(TLeaderParty.Leader, scMap);
end;

procedure TSceneMap.Render;
var
  X, Y: Integer;
  F: Boolean;

  procedure RenderNewDayMessage;
  begin
    DrawImage(10, 10, reFrame);
    DrawImage(60, 10, reTextNewDay);
    DrawImage(45, 70, reGold);
    DrawText(75, 84, '+' + IntToStr(Game.Gold.FromMinePerDay));
    DrawImage(170, 70, reMana);
    DrawText(205, 84, '+' + IntToStr(Game.Mana.FromMinePerDay));
  end;

begin
  inherited;
  for Y := 0 to Game.Map.Height - 1 do
    for X := 0 to Game.Map.Width - 1 do
    begin
      if (Game.Map.GetTile(lrDark, X, Y) = reDark) then
        Continue;
      case Game.Map.GetTile(lrTile, X, Y) of
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
      F := not TLeaderParty.Leader.InRadius(X, Y) and
        not(Game.Map.GetTile(lrTile, X, Y) in Tiles + Capitals + Cities) and
        (Game.Map.GetTile(lrDark, X, Y) = reNone) and
        not(Game.Map.GetTile(lrSee, X, Y) = reNone);

      // Special
      if Game.Wizard and
        (((Game.Scenario.CurrentScenario = sgAncientKnowledge) and
        Game.Scenario.IsStoneTab(X, Y)) or
        ((Game.Scenario.CurrentScenario = sgDarkTower) and
        (ResBase[Game.Map.GetTile(lrTile, X, Y)].ResType = teTower)) or
        ((Game.Scenario.CurrentScenario = sgOverlord) and
        (ResBase[Game.Map.GetTile(lrTile, X, Y)].ResType = teCity))) then
        DrawImage(X * TMap.TileSize, Y * Game.Map.TileSize,
          ResImage[reCursorSpecial]);

      // Capital, Cities, Ruins and Tower
      if (ResBase[Game.Map.GetTile(lrTile, X, Y)].ResType in [teCapital, teCity,
        teRuin, teTower]) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
          ResImage[Game.Map.GetTile(lrTile, X, Y)]);
      //

      //
      if (ResBase[Game.Map.GetTile(lrObj, X, Y)].ResType in [teEnemy, teBag])
      then
        if F then
          DrawImage(X * Game.Map.TileSize, Y * Game.Map.TileSize,
            ResImage[reUnk])
        else
          DrawImage(X * Game.Map.TileSize, Y * Game.Map.TileSize,
            ResImage[Game.Map.GetTile(lrObj, X, Y)])
      else if (Game.Map.GetTile(lrObj, X, Y) <> reNone) then
        DrawImage(X * Game.Map.TileSize, Y * Game.Map.TileSize,
          ResImage[Game.Map.GetTile(lrObj, X, Y)]);

      // Leader
      if (X = TLeaderParty.Leader.X) and (Y = TLeaderParty.Leader.Y) then
        DrawImage(X * Game.Map.TileSize, Y * Game.Map.TileSize,
          ResImage[rePlayer]);

      // Path
      if (Game.Map.GetTile(lrPath, X, Y) <> reNone) then
        DrawImage(X * TMap.TileSize, Y * TMap.TileSize,
          ResImage[Game.Map.GetTile(lrPath, X, Y)]);

      // Fog
      if F then
        DrawImage(X * Game.Map.TileSize, Y * Game.Map.TileSize,
          ResImage[reDark]);
    end;
  // Cursor
  if FM then
  begin
    // for X := MousePos.X - 1 to MousePos.X + 1 do
    // for Y := MousePos.Y - 1 to MousePos.Y + 1 do
    // DrawImage(X * Game.Map.TileSize, Y * Game.Map.TileSize, ResImage[reCursorMagic])
    DrawImage(MousePos.X * Game.Map.TileSize, MousePos.Y * Game.Map.TileSize,
      ResImage[reCursorMagic]);
  end
  else if Game.Map.IsLeaderMove(MousePos.X, MousePos.Y) then
    DrawImage(MousePos.X * Game.Map.TileSize, MousePos.Y * Game.Map.TileSize,
      ResImage[reCursor])
  else
    DrawImage(MousePos.X * Game.Map.TileSize, MousePos.Y * Game.Map.TileSize,
      ResImage[reNoWay]);
  // New Day Message
  if Game.ShowNewDayMessageTime > 0 then
    RenderNewDayMessage;
end;

procedure TSceneMap.Show(const S: TSceneEnum);
begin
  inherited Show(S);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

procedure TSceneMap.Timer;
var
  X, Y: Integer;
begin
  inherited;
  if BB then
  begin
    for X := TLeaderParty.Leader.X - 1 to TLeaderParty.Leader.X + 1 do
      for Y := TLeaderParty.Leader.Y - 1 to TLeaderParty.Leader.Y + 1 do
        if Game.Map.GetLayer(lrPath)[X, Y] in [reASell, reAMark] then
        begin
          TLeaderParty.Leader.PutAt(X, Y);
          Game.Map.GetLayer(lrPath)[X, Y] := reNone;
          Game.Render;
          Exit;
        end;
    BB := False;
    Game.Map.Clear(lrPath);
  end;

  if Game.ShowNewDayMessageTime > 0 then
    Dec(Game.ShowNewDayMessageTime);
end;

procedure TSceneMap.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE:
      begin
        if FM then
        begin
          FM := False;
          Exit;
        end;
        Game.MediaPlayer.PlayMusic(mmMenu);
        Game.MediaPlayer.PlaySound(mmClick);
        Game.MediaPlayer.PlaySound(mmSettlement);
        Game.Show(scMenu);
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
    K_M:
      FM := not FM;
    K_K:
      Game.Map.Clear(lrPath);
    K_I:
      TSceneParty.Show(Party[TLeaderParty.LeaderPartyIndex], scMap, True);
    K_T:
      TSceneParty.Show(Party[TLeaderParty.LeaderPartyIndex], scMap,
        False, True);
    K_V:
      if (TLeaderParty.Leader.Enum in LeaderWarrior) then
        TSceneHire.Show(stWar);
    K_P:
      ShowPartyScene;
    K_J:
      TSceneScenario.Show;
    K_H:
      TSceneSpellbook.Show;
  end;
end;

end.
