unit Elinor.Scene.Settlement;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Direction,
  Elinor.Party,
  Elinor.Scenes;

type
  TSettlementSubSceneEnum = (stCity, stCapital);

  { TSceneMap }

type
  TSceneSettlement = class(TSceneFrames)
  private type
    TButtonEnum = (btTemple, btBarracks, btParty, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextTemple, reTextBarracks,
      reTextParty, reTextClose);
    procedure ShowTempleScene;
  private
  class var
    Button: array [TButtonEnum] of TButton;
    CurrentSettlementType: TSettlementSubSceneEnum;
    CurrentCityIndex: Integer;
  public
    class var SettlementParty: TParty;
  private
    IsUnitSelected: Boolean;
    ConfirmParty: TParty;
    ConfirmPartyPosition: TPosition;
    procedure MoveCursor(const AArrowKeyDirectionEnum: TArrowKeyDirectionEnum);
    procedure ShowPartyScene;
    procedure ShowBarracksScene;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(SettlementType: TSettlementSubSceneEnum);
      overload;
    class procedure HideScene;
  end;

implementation

uses
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Map,
  Elinor.Creatures,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.Temple,
  Elinor.Scene.Party2,
  Elinor.Scene.Recruit,
  Elinor.Scene.Barracks, Elinor.Scene.Victory;

const
  PositionTransitions: array [TArrowKeyDirectionEnum, 0 .. 11] of Integer = (
    // Left
    (1, 7, 3, 9, 5, 11, 0, 6, 2, 8, 4, 10),
    // Right
    (6, 0, 8, 2, 10, 4, 7, 1, 9, 3, 11, 5),
    // Up
    (4, 5, 0, 1, 2, 3, 10, 11, 6, 7, 8, 9),
    // Down
    (2, 3, 4, 5, 0, 1, 8, 9, 10, 11, 6, 7)
    //
    );

procedure TSceneSettlement.MoveCursor(const AArrowKeyDirectionEnum
  : TArrowKeyDirectionEnum);
begin
  ActivePartyPosition := PositionTransitions[AArrowKeyDirectionEnum,
    ActivePartyPosition];
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Render;
end;

class procedure TSceneSettlement.HideScene;
begin
  case Game.Map.LeaderTile of
    reNeutralCity:
      begin
        TLeaderParty.Leader.ChCityOwner;
        TMapPlace.UpdateRadius(TMapPlace.GetIndex(TLeaderParty.Leader.X,
          TLeaderParty.Leader.Y));
      end;
  end;
  if (Game.Scenario.CurrentScenario = sgOverlord) then
  begin
    if (TMapPlace.GetCityCount = TScenario.ScenarioCitiesMax) then
    begin
      TSceneVictory.ShowScene;
      Exit;
    end;
  end;
  Game.MediaPlayer.PlayMusic(mmMap);
  Game.Show(scMap);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.NewDay;
end;

{ TSceneSettlement }

constructor TSceneSettlement.Create;
var
  LButtonEnum: TButtonEnum;
  L, W: Integer;
begin
  inherited Create(reWallpaperSettlement, fgLS6, fgRS6);
  W := ResImage[reButtonDef].Width + 4;
  L := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(L, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(L, W);
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Sellected := True;
  end;
end;

destructor TSceneSettlement.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneSettlement.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPartyPosition: Integer;
begin
  inherited;
  if (Game.Map.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) >
    0) and (CurrentSettlementType = stCapital) and (AButton = mbRight) and
    (GetPartyPosition(X, Y) < 6) then
    Exit;
  case AButton of
    mbRight:
      begin
        LPartyPosition := GetPartyPosition(X, Y);
        case LPartyPosition of
          0 .. 11:
            begin
              ActivePartyPosition := LPartyPosition;
              TLeaderParty.MoveUnit(SettlementParty);
            end;
        end;
      end;
    mbLeft:
      begin
        if Button[btBarracks].MouseDown then
          ShowBarracksScene
        else if Button[btTemple].MouseDown then
          ShowTempleScene
        else if Button[btParty].MouseDown then
          ShowPartyScene
        else if Button[btClose].MouseDown then
          HideScene
        else
        begin
          LPartyPosition := GetPartyPosition(X, Y);
          case LPartyPosition of
            0 .. 11:
              begin
                CurrentPartyPosition := LPartyPosition;
                ActivePartyPosition := CurrentPartyPosition;
              end;
          end;
          Game.MediaPlayer.PlaySound(mmClick);
        end;
      end;
  end;
end;

procedure TSceneSettlement.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
  Game.Render;
end;

procedure TSceneSettlement.Render;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;
  case CurrentSettlementType of
    stCity:
      begin
        DrawTitle(Game.Map.GetCityNameTitleRes(CurrentCityIndex + 1));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage(ScrWidth + 20, 160, reTextCityDef);
      end;
    stCapital:
      begin
        DrawTitle(Game.Map.GetCityNameTitleRes(0));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage(ScrWidth + 20, 160, reTextCapitalDef);
      end;
  end;
  with TSceneParty2 do
  begin
    if (Game.Map.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y)
      = 0) or (CurrentSettlementType = stCity) then
      RenderParty(psLeft, PartyList.Party[TLeaderParty.LeaderPartyIndex],
        PartyList.Party[TLeaderParty.LeaderPartyIndex].Count <
        TLeaderParty.Leader.Leadership)
    else
      RenderParty(psLeft, nil);
    RenderParty(psRight, SettlementParty, True);
  end;
  DrawResources;
  RenderButtons;
end;

class procedure TSceneSettlement.ShowScene(SettlementType
  : TSettlementSubSceneEnum);
begin
  CurrentSettlementType := SettlementType;
  case CurrentSettlementType of
    stCity:
      begin
        CurrentCityIndex := PartyList.GetPartyIndex(TLeaderParty.Leader.X,
          TLeaderParty.Leader.Y);
        SettlementParty := PartyList.Party[CurrentCityIndex];
        SettlementParty.Owner := PartyList.Party
          [TLeaderParty.LeaderPartyIndex].Owner;
      end
  else
    SettlementParty := PartyList.Party[TLeaderParty.CapitalPartyIndex];
  end;
  ActivePartyPosition := TLeaderParty.GetPosition;
  SelectPartyPosition := -1;
  Game.Show(scSettlement);
end;

procedure TSceneSettlement.ShowTempleScene;
begin
  case ActivePartyPosition of
    0 .. 5:
      begin
        TSceneTemple.ShowScene(TLeaderParty.Leader);
        Game.MediaPlayer.PlaySound(mmClick);
      end
  else
    if not SettlementParty.IsClear then
    begin
      TSceneTemple.ShowScene(SettlementParty);
      Game.MediaPlayer.PlaySound(mmClick);
    end;
  end;
end;

procedure TSceneSettlement.ShowBarracksScene;
begin
  case ActivePartyPosition of
    0 .. 5:
      begin
        TSceneBarracks.ShowScene(TLeaderParty.Leader);
        Game.MediaPlayer.PlaySound(mmClick);
      end
  else
    if not SettlementParty.IsClear then
    begin
      TSceneBarracks.ShowScene(SettlementParty);
      Game.MediaPlayer.PlaySound(mmClick);
    end;
  end;

end;

procedure TSceneSettlement.ShowPartyScene;
begin
  case ActivePartyPosition of
    0 .. 5:
      begin
        TSceneParty2.ShowScene(PartyList.Party[TLeaderParty.LeaderPartyIndex],
          scSettlement);
        Game.MediaPlayer.PlaySound(mmClick);
      end
  else
    if not SettlementParty.IsClear then
    begin
      TSceneParty2.ShowScene(SettlementParty, scSettlement);
      Game.MediaPlayer.PlaySound(mmClick);
    end;
  end;
end;

procedure TSceneSettlement.Timer;
begin
  inherited;

end;

procedure TSceneSettlement.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_SPACE:
      TLeaderParty.UpdateMoveUnit(SettlementParty);
    K_ESCAPE, K_ENTER:
      HideScene;
    K_B:
      ShowBarracksScene;
    K_P:
      ShowPartyScene;
    K_T:
      ShowTempleScene;
    K_LEFT, K_KP_4:
      MoveCursor(kdLeft);
    K_RIGHT, K_KP_6:
      MoveCursor(kdRight);
    K_UP, K_KP_8:
      MoveCursor(kdUp);
    K_DOWN, K_KP_2:
      MoveCursor(kdDown);
  end;
end;

end.
