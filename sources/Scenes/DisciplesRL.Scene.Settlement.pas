unit DisciplesRL.Scene.Settlement;

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  DisciplesRL.Party,
  DisciplesRL.Scenes;

type
  TSettlementSubSceneEnum = (stCity, stCapital);

  { TSceneMap }

type
  TSceneSettlement = class(TScene)
  private
    IsUnitSelected: Boolean;
    procedure Heal;
    procedure Dismiss;
    procedure Revive;
    procedure Hire;
    procedure Close;
    procedure MoveCursor(Dir: TDirectionEnum);
    function GetName(const I: Integer): string;
    procedure MoveUnit;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure Gen;
    class procedure Show(SettlementType: TSettlementSubSceneEnum); overload;
  end;

implementation

uses
  Math,
  Types,
  SysUtils,
  DisciplesRL.Resources,
  DisciplesRL.Saga,
  DisciplesRL.Map,
  DisciplesRL.Scene.Party,
  DisciplesRL.Creatures,
  DisciplesRL.Button,
  DisciplesRL.Scene.Hire;

type
  TButtonEnum = (btHeal, btRevive, btClose, btHire, btDismiss);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextHeal, reTextRevive,
    reTextClose, reTextHire, reTextDismiss);

type
  T = 0 .. 9;

const
  CityNameTitle: array [T] of TResEnum = (reTitleVorgel, reTitleEntarion,
    reTitleTardum, reTitleTemond, reTitleZerton, reTitleDoran, reTitleKront,
    reTitleHimor, reTitleSodek, reTitleSard);
  CityNameText: array [T] of string = ('Vorgel', 'Entarion', 'Tardum', 'Temond',
    'Zerton', 'Doran', 'Kront', 'Himor', 'Sodek', 'Sard');

var
  Button: array [TButtonEnum] of TButton;
  CurrentSettlementType: TSettlementSubSceneEnum;
  SettlementParty: TParty = nil;
  CurrentCityIndex: Integer = -1;
  CityArr: array [T] of Integer;

class procedure TSceneSettlement.Gen;
var
  N: set of T;
  J, K: Integer;
begin
  N := [];
  for K := Low(T) to High(T) do
  begin
    repeat
      J := Random(10);
    until not(J in N);
    N := N + [J];
    CityArr[K] := J;
  end;
end;

function TSceneSettlement.GetName(const I: Integer): string;
begin
  Result := CityNameText[CityArr[I]];
end;

procedure TSceneSettlement.MoveCursor(Dir: TDirectionEnum);
begin
  case Dir of
    drWest:
      case ActivePartyPosition of
        1, 3, 5:
          Inc(ActivePartyPosition, 6);
        0, 2, 4:
          Inc(ActivePartyPosition);
        6, 8, 10:
          Dec(ActivePartyPosition, 6);
        7, 9, 11:
          Dec(ActivePartyPosition);
      end;
    drEast:
      case ActivePartyPosition of
        1, 3, 5:
          Dec(ActivePartyPosition);
        0, 2, 4:
          Inc(ActivePartyPosition, 6);
        6, 8, 10:
          Inc(ActivePartyPosition);
        7, 9, 11:
          Dec(ActivePartyPosition, 6);
      end;
    drNorth:
      case ActivePartyPosition of
        0, 1, 6, 7:
          Inc(ActivePartyPosition, 4);
        2 .. 5, 8 .. 11:
          Dec(ActivePartyPosition, 2);
      end;
    drSouth:
      case ActivePartyPosition of
        0 .. 3, 6 .. 9:
          Inc(ActivePartyPosition, 2);
        4, 5, 10, 11:
          Dec(ActivePartyPosition, 4);
      end;
  end;
  Scenes.Render;
end;

procedure TSceneSettlement.Hire;

  procedure HireIt(const AParty: TParty; const APosition: Integer);
  begin
    with AParty.Creature[APosition] do
    begin
      if Active then
      begin
        InformDialog('Выберите пустой слот!');
        Exit;
      end;
      if (((AParty = Party[TLeaderParty.LeaderPartyIndex]) and
        (Party[TLeaderParty.LeaderPartyIndex].Count <
        TLeaderParty.Leader.MaxLeadership)) or
        (AParty <> Party[TLeaderParty.LeaderPartyIndex])) then
      begin
        TSceneHire.Show(AParty, APosition);
      end
      else
      begin
        if (Party[TLeaderParty.LeaderPartyIndex].Count = TLeaderParty.Leader.
          MaxLeadership) then
          InformDialog('Нужно развить лидерство!')
        else
          InformDialog('Не возможно нанять!');
        Exit;
      end;
    end;
  end;

begin
  MediaPlayer.Play(mmClick);
  CurrentPartyPosition := ActivePartyPosition;
  case ActivePartyPosition of
    0 .. 5:
      HireIt(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      HireIt(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure TSceneSettlement.Dismiss;

  procedure DismissIt(const AParty: TParty; const APosition: Integer);
  begin
    with AParty.Creature[APosition] do
    begin
      if not Active then
      begin
        InformDialog('Выберите не пустой слот!');
        Exit;
      end;
      if Leadership > 0 then
      begin
        InformDialog('Не возможно уволить!');
        Exit;
      end
      else
      begin
        if not ConfirmDialog('Отпустить?') then
          Exit;
      end;
    end;
    AParty.Dismiss(APosition);
  end;

begin
  MediaPlayer.Play(mmClick);
  case ActivePartyPosition of
    0 .. 5:
      DismissIt(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      DismissIt(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure TSceneSettlement.Heal;

  procedure HealIt(const AParty: TParty; const APosition: Integer);
  var
    V, R: Integer;
  begin
    with AParty.Creature[APosition] do
    begin
      if not Active then
      begin
        InformDialog('Выберите не пустой слот!');
        Exit;
      end;
      if HitPoints <= 0 then
      begin
        InformDialog('Сначала нужно воскресить!');
        Exit;
      end;
      if HitPoints = MaxHitPoints then
      begin
        InformDialog('Не нуждается в исцелении!');
        Exit;
      end;
      V := Min((MaxHitPoints - HitPoints) * Level, TSaga.Gold);
      if (V <= 0) then
      begin
        InformDialog('Нужно больше золота!');
        Exit;
      end;
      R := (V div Level) * Level;
      if (HitPoints + (V div Level) < MaxHitPoints) then
      begin
        if not ConfirmDialog(Format('Исцелить на %d HP за %d золота?',
          [V div Level, R])) then
          Exit;
      end
      else
      begin
        if not ConfirmDialog(Format('Полностью исцелить за %d золота?', [R]))
        then
          Exit;
      end;
      TSaga.Gold := TSaga.Gold - R;
      AParty.Heal(APosition, V div Level);
    end;

  end;

begin
  MediaPlayer.Play(mmClick);
  CurrentPartyPosition := ActivePartyPosition;
  case ActivePartyPosition of
    0 .. 5:
      HealIt(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      HealIt(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure TSceneSettlement.Revive;

  procedure ReviveIt(const AParty: TParty; const APosition: Integer);
  var
    V: Integer;
  begin
    with AParty.Creature[APosition] do
    begin
      if not Active then
      begin
        InformDialog('Выберите не пустой слот!');
        Exit;
      end;
      if HitPoints > 0 then
      begin
        InformDialog('Не нуждается в воскрешении!');
        Exit;
      end
      else
      begin
        V := Level * TSaga.GoldForRevivePerLevel;
        if (TSaga.Gold < V) then
        begin
          InformDialog(Format('Для воскрешения нужно %d золота!', [V]));
          Exit;
        end;
        if not ConfirmDialog(Format('Воскресить за %d золота?', [V])) then
          Exit;
        TSaga.Gold := TSaga.Gold - V;
      end;
    end;
    AParty.Revive(APosition);
  end;

begin
  MediaPlayer.Play(mmClick);
  CurrentPartyPosition := ActivePartyPosition;
  case ActivePartyPosition of
    0 .. 5:
      ReviveIt(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      ReviveIt(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure TSceneSettlement.Close;
begin
  case TMap.LeaderTile of
    reNeutralCity:
      begin
        TLeaderParty.Leader.ChCityOwner;
        TPlace.UpdateRadius(TPlace.GetIndex(TLeaderParty.Leader.X,
          TLeaderParty.Leader.Y));
      end;
  end;
  if (TScenario.CurrentScenario = sgOverlord) then
  begin
    if (TPlace.GetCityCount = TScenario.ScenarioCitiesMax) then
    begin
      TSceneHire.Show(stVictory);
      Exit;
    end;
  end;
  MediaPlayer.PlayMusic(mmMap);
  Scenes.Show(scMap);
  MediaPlayer.Play(mmClick);
  TSaga.NewDay;
end;

{ TSceneSettlement }

constructor TSceneSettlement.Create;
var
  I: TButtonEnum;
  L, W: Integer;
begin
  inherited;
  W := ResImage[reButtonDef].Width + 4;
  L := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, DefaultButtonTop, ButtonText[I]);
    Inc(L, W);
    if (I = btClose) then
      Button[I].Sellected := True;
  end;
end;

destructor TSceneSettlement.Destroy;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
  inherited;
end;

procedure TSceneSettlement.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (TMap.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) > 0)
    and (CurrentSettlementType = stCapital) and (AButton = mbRight) and
    (GetPartyPosition(X, Y) < 6) then
    Exit;
  // Move party
  case AButton of
    mbRight:
      begin
        ActivePartyPosition := GetPartyPosition(X, Y);
        Self.MoveUnit;
      end;
    mbMiddle:
      begin
        case GetPartyPosition(X, Y) of
          0 .. 5:
            TSceneParty.Show(Party[TLeaderParty.LeaderPartyIndex],
              scSettlement);
        else
          if not SettlementParty.IsClear then
            TSceneParty.Show(SettlementParty, scSettlement);
        end;
        MediaPlayer.Play(mmClick);
        Exit;
      end;
    mbLeft:
      begin
        if Button[btHire].MouseDown then
          Hire
        else if Button[btHeal].MouseDown then
          Heal
        else if Button[btDismiss].MouseDown then
          Dismiss
        else if Button[btRevive].MouseDown then
          Revive
        else if Button[btClose].MouseDown then
          Close
        else
        begin
          CurrentPartyPosition := GetPartyPosition(X, Y);
          if CurrentPartyPosition < 0 then
            Exit;
          ActivePartyPosition := CurrentPartyPosition;
          MediaPlayer.Play(mmClick);
        end;
      end;
  end;
end;

procedure TSceneSettlement.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Scenes.Render;
end;

procedure TSceneSettlement.Render;

  procedure RenderButtons;
  var
    I: TButtonEnum;
  begin
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      Button[I].Render;
  end;

begin
  inherited;
  DrawImage(reWallpaperSettlement);
  case CurrentSettlementType of
    stCity:
      begin
        DrawTitle(CityNameTitle[CityArr[CurrentCityIndex + 1]]);
        DrawImage(20, 160, reTextLeadParty);
        DrawImage(ScrWidth + 20, 160, reTextCityDef);
      end;
    stCapital:
      begin
        DrawTitle(CityNameTitle[CityArr[0]]);
        DrawImage(20, 160, reTextLeadParty);
        DrawImage(ScrWidth + 20, 160, reTextCapitalDef);
      end;
  end;
  with TSceneParty do
  begin
    if (TMap.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) = 0)
      or (CurrentSettlementType = stCity) then
      RenderParty(psLeft, Party[TLeaderParty.LeaderPartyIndex],
        Party[TLeaderParty.LeaderPartyIndex].Count <
        TLeaderParty.Leader.MaxLeadership)
    else
      RenderParty(psLeft, nil);
    RenderParty(psRight, SettlementParty, True);
  end;
  DrawResources;
  RenderButtons;
end;

class procedure TSceneSettlement.Show(SettlementType: TSettlementSubSceneEnum);
begin
  CurrentSettlementType := SettlementType;
  case CurrentSettlementType of
    stCity:
      begin
        CurrentCityIndex := TSaga.GetPartyIndex(TLeaderParty.Leader.X,
          TLeaderParty.Leader.Y);
        SettlementParty := Party[CurrentCityIndex];
        SettlementParty.Owner := Party[TLeaderParty.LeaderPartyIndex].Owner;
      end
  else
    SettlementParty := Party[TLeaderParty.CapitalPartyIndex];
  end;
  ActivePartyPosition := TLeaderParty.GetPosition;
  SelectPartyPosition := -1;
  Scenes.Show(scSettlement);
end;

procedure TSceneSettlement.MoveUnit;
begin
  if not((ActivePartyPosition < 0) or ((ActivePartyPosition < 6) and
    (CurrentPartyPosition >= 6) and (Party[TLeaderParty.LeaderPartyIndex].Count
    >= TLeaderParty.Leader.MaxLeadership))) then
  begin
    Party[TLeaderParty.LeaderPartyIndex].ChPosition(SettlementParty,
      ActivePartyPosition, CurrentPartyPosition);
    MediaPlayer.Play(mmClick);
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
      begin
        if IsUnitSelected then
        begin
          IsUnitSelected := False;
          SelectPartyPosition := -1;
          Self.MoveUnit;
        end
        else
        begin
          IsUnitSelected := True;
          SelectPartyPosition := ActivePartyPosition;
          CurrentPartyPosition := ActivePartyPosition;
        end;
      end;
    K_ESCAPE, K_ENTER:
      Close;
    K_P:
      TSceneParty.Show(Party[TLeaderParty.LeaderPartyIndex], scSettlement);
    K_I:
      TSceneParty.Show(Party[TLeaderParty.LeaderPartyIndex],
        scSettlement, True);
    K_V:
      Hire;
    K_H:
      Heal;
    K_J:
      Dismiss;
    K_R:
      Revive;
    K_LEFT, K_KP_4, K_A:
      MoveCursor(drWest);
    K_RIGHT, K_KP_6, K_D:
      MoveCursor(drEast);
    K_UP, K_KP_8, K_W:
      MoveCursor(drNorth);
    K_DOWN, K_KP_2, K_X:
      MoveCursor(drSouth);
  end;
end;

end.
