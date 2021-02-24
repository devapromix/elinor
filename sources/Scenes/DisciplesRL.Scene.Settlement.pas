unit DisciplesRL.Scene.Settlement;

interface

uses
  System.Classes,
  Vcl.Controls,
  DisciplesRL.Scenes;

type
  TSettlementSubSceneEnum = (stCity, stCapital);

  { TSceneMap }

type
  TSceneSettlement = class(TScene)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Show(const S: TSceneEnum); override;
    procedure Show2(const S: TSceneEnum;
      const SettlementType: TSettlementSubSceneEnum); overload;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

procedure Gen;
procedure RenderResources;
procedure Show(SettlementType: TSettlementSubSceneEnum);

implementation

uses
  System.Math,
  System.Types,
  System.SysUtils,
  DisciplesRL.Scene.Map,
  DisciplesRL.Resources,
  DisciplesRL.Saga,
  DisciplesRL.Party,
  DisciplesRL.Map,
  DisciplesRL.Scene.Party,
  DisciplesRL.Creatures,
  DisciplesRL.GUI.Button,
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
  P: array [1 .. 12] of TPoint;

procedure Gen;
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

function GetName(const I: Integer = 0): string;
begin
  Result := CityNameText[CityArr[I]];
end;

procedure RenderResources;
begin
  DrawImage(10, 10, reSmallFrame);
  DrawImage(15, 10, reGold);
  LeftTextOut(45, 24, IntToStr(TSaga.Gold));
  DrawImage(15, 40, reMana);
  LeftTextOut(45, 54, IntToStr(TSaga.Mana));
  // DrawImage(15, 70, reMana);
  // LeftTextOut(45, 82, IntToStr(TMap.Place[0].MaxLevel + 1));
end;

procedure MoveCursor(Dir: TDirectionEnum);
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

procedure Hire;

  procedure Hire(const AParty: TParty; const APosition: Integer);
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
        DisciplesRL.Scene.Hire.Show(AParty, APosition);
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
      Hire(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      Hire(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure Dismiss;

  procedure Dismiss(const AParty: TParty; const APosition: Integer);
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
      Dismiss(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      Dismiss(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure Heal;

  procedure Heal(const AParty: TParty; const APosition: Integer);
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
      Heal(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      Heal(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure Revive;

  procedure Revive(const AParty: TParty; const APosition: Integer);
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
      Revive(Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      Revive(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure Close;
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
      DisciplesRL.Scene.Hire.Show(stVictory);
      Exit;
    end;
  end;
  MediaPlayer.PlayMusic(mmMap);
  Scenes.Show(scMap);
  MediaPlayer.Play(mmClick);
  TSaga.NewDay;
end;

procedure Show(SettlementType: TSettlementSubSceneEnum);
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
  Scenes.Show(scSettlement);
end;

{ TSceneSettlement }

procedure TSceneSettlement.Click;
begin
  inherited;
  if Button[btHire].MouseDown then
    Hire;
  if Button[btHeal].MouseDown then
    Heal;
  if Button[btDismiss].MouseDown then
    Dismiss;
  if Button[btRevive].MouseDown then
    Revive;
  if Button[btClose].MouseDown then
    Close;
end;

constructor TSceneSettlement.Create;
var
  I: TButtonEnum;
  L, W: Integer;
begin
  inherited;
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, DefaultButtonTop, Surface.Canvas,
      ButtonText[I]);
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

procedure TSceneSettlement.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (TMap.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) > 0)
    and (CurrentSettlementType = stCapital) and (Button = mbRight) and
    (GetPartyPosition(X, Y) < 6) then
    Exit;
  // Move party
  case Button of
    mbRight:
      begin
        ActivePartyPosition := GetPartyPosition(X, Y);
        if (ActivePartyPosition < 0) or
          ((ActivePartyPosition < 6) and (CurrentPartyPosition >= 6) and
          (Party[TLeaderParty.LeaderPartyIndex].Count >=
          TLeaderParty.Leader.MaxLeadership)) then
          Exit;
        Party[TLeaderParty.LeaderPartyIndex].ChPosition(SettlementParty,
          ActivePartyPosition, CurrentPartyPosition);
        MediaPlayer.Play(mmClick);
      end;
    mbMiddle:
      begin
        case GetPartyPosition(X, Y) of
          0 .. 5:
            DisciplesRL.Scene.Party.Show(Party[TLeaderParty.LeaderPartyIndex],
              scSettlement);
        else
          if not SettlementParty.IsClear then
            DisciplesRL.Scene.Party.Show(SettlementParty, scSettlement);
        end;
        MediaPlayer.Play(mmClick);
        Exit;
      end;
    mbLeft:
      begin
        CurrentPartyPosition := GetPartyPosition(X, Y);
        if CurrentPartyPosition < 0 then
          Exit;
        ActivePartyPosition := CurrentPartyPosition;
        MediaPlayer.Play(mmClick);
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

procedure CalcPoints;
var
  I: Byte;
  X, Y: Byte;
  X4: Integer;
begin
  X := 0;
  Y := 0;
  X4 := Surface.Width div 4;
  for I := 1 to 12 do
  begin
    P[I].X := Left + (X * X4);
    P[I].Y := Top + (Y * 120);
    Inc(Y);
    if (Y > 2) then
    begin
      Y := 0;
      Inc(X);
    end;
  end;
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
  CalcPoints;
  DrawImage(reWallpaperSettlement);
  case CurrentSettlementType of
    stCity:
      begin
        DrawTitle(CityNameTitle[CityArr[CurrentCityIndex + 1]]);
        // CenterTextOut(100, Format('%s (Level %d)',
        // [GetName(CurrentCityIndex + 1), TMap.Place[CurrentCityIndex]
        // .MaxLevel + 1]));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage((Surface.Width div 2) + 20, 160, reTextCityDef);
      end;
    stCapital:
      begin
        DrawTitle(CityNameTitle[CityArr[0]]);
        DrawImage(20, 160, reTextLeadParty);
        DrawImage((Surface.Width div 2) + 20, 160, reTextCapitalDef);
      end;
  end;
  // CenterTextOut(60,
  // Format('ActivePartyPosition=%d, CurrentPartyPosition=%d, CurrentCityIndex=%d',
  // [ActivePartyPosition, CurrentPartyPosition, CurrentCityIndex]));
  if (TMap.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) = 0)
    or (CurrentSettlementType = stCity) then
    RenderParty(psLeft, Party[TLeaderParty.LeaderPartyIndex],
      Party[TLeaderParty.LeaderPartyIndex].Count <
      TLeaderParty.Leader.MaxLeadership)
  else
    RenderParty(psLeft, nil);
  RenderParty(psRight, SettlementParty, True);
  RenderResources;
  RenderButtons;
end;

procedure TSceneSettlement.Show(const S: TSceneEnum);
begin

end;

procedure TSceneSettlement.Show2(const S: TSceneEnum;
  const SettlementType: TSettlementSubSceneEnum);
begin

end;

procedure TSceneSettlement.Timer;
begin
  inherited;

end;

procedure TSceneSettlement.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      Close;
    K_P:
      DisciplesRL.Scene.Party.Show(Party[TLeaderParty.LeaderPartyIndex],
        scSettlement);
    K_I:
      DisciplesRL.Scene.Party.Show(Party[TLeaderParty.LeaderPartyIndex],
        scSettlement, True);
    // K_A:
    // Hire;
    K_H:
      Heal;
    // K_D:
    // Dismiss;
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
