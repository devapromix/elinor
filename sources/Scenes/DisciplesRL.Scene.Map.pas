unit DisciplesRL.Scene.Map;

interface

uses
  System.Classes,
  DisciplesRL.Scenes,
  Vcl.Controls;

{ TSceneMap }

type
  TSceneMap = class(TScene)
  public
    procedure Show(const S: TSceneEnum); override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

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

{ TSceneMap }

procedure TSceneMap.Click;
begin
  inherited;
  if TSaga.Wizard and TMap.InMap(MousePos.X, MousePos.Y) then
    TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y)
  else if TMap.IsLeaderMove(MousePos.X, MousePos.Y) and
    TMap.InMap(MousePos.X, MousePos.Y) then
    TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y);
end;

procedure TSceneMap.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case Button of
    mbMiddle:
      begin
        TLeaderParty.Leader.PutAt(MousePos.X, MousePos.Y, True);
      end;
  end;
end;

procedure TSceneMap.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  MousePos := Point(X div TMap.TileSize, Y div TMap.TileSize);
  if (MousePos.X <> LastMousePos.X) or (MousePos.Y <> LastMousePos.Y) then
  begin
    Scenes.Render;
    LastMousePos.X := MousePos.X;
    LastMousePos.Y := MousePos.Y;
  end;
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
    LeftTextOut(75, 84, '+' + IntToStr(TSaga.GoldMines *
      TSaga.GoldFromMinePerDay));
    DrawImage(170, 70, reMana);
    LeftTextOut(205, 84, '+' + IntToStr(TSaga.ManaMines *
      TSaga.ManaFromMinePerDay));
  end;

begin
  inherited;
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
  // New Day Message
  if TSaga.ShowNewDayMessage > 0 then
    RenderNewDayMessage;
end;

procedure TSceneMap.Show;
begin
  inherited;
  MediaPlayer.Play(mmSettlement);
  Scenes.SetScene(scMap);
end;

procedure TSceneMap.Timer;
begin
  inherited;
  if TSaga.ShowNewDayMessage > 0 then
    Dec(TSaga.ShowNewDayMessage);
end;

procedure TSceneMap.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE:
      begin
        MediaPlayer.PlayMusic(mmMenu);
        MediaPlayer.Play(mmClick);
        MediaPlayer.Play(mmSettlement);
        Scenes.SetScene(scMenu);
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

end.
