unit DisciplesRL.Scene.Settlement;

interface

uses
  System.Classes,
  Vcl.Controls;

type
  TSettlementSubSceneEnum = (stCity, stCapital);

procedure Init;
procedure Gen;
procedure Render;
procedure RenderButtons;
procedure Timer;
procedure MouseClick;
procedure Show(SettlementType: TSettlementSubSceneEnum);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses
  System.Math,
  System.SysUtils,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Map,
  DisciplesRL.Resources,
  DisciplesRL.Game,
  DisciplesRL.Party,
  DisciplesRL.Map,
  DisciplesRL.City,
  DisciplesRL.Scene.Party,
  DisciplesRL.Leader,
  DisciplesRL.Creatures,
  DisciplesRL.GUI.Button,
  DisciplesRL.Scene.Battle,
  DisciplesRL.Scene.Info,
  DisciplesRL.Scene.Hire;

type
  TButtonEnum = (btHeal, btRevive, btClose, btHire, btDismiss);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextHeal, reTextRevive, reTextClose, reTextHire, reTextDismiss);

type
  T = 0 .. 9;

const
  CityNameTitle: array [T] of TResEnum = (reTitleVorgel, reTitleEntarion, reTitleTardum, reTitleTemond, reTitleZerton, reTitleDoran, reTitleKront,
    reTitleHimor, reTitleSodek, reTitleSard);
  CityNameText: array [T] of string = ('Vorgel', 'Entarion', 'Tardum', 'Temond', 'Zerton', 'Doran', 'Kront', 'Himor', 'Sodek', 'Sard');

var
  Button: array [TButtonEnum] of TButton;
  CurrentSettlementType: TSettlementSubSceneEnum;
  SettlementParty: TParty = nil;
  CurrentCityIndex: Integer = -1;
  CityArr: array [T] of Integer;

procedure Init;
var
  R: TResEnum;
  I: TButtonEnum;
  L, W: Integer;
begin
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, DefaultButtonTop, Surface.Canvas, ButtonText[I]);
    Inc(L, W);
    if (I = btClose) then
      Button[I].Sellected := True;
  end;
end;

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

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].Render;
end;

function GetName(const I: Integer = 0): string;
begin
  Result := CityNameText[CityArr[I]];
end;

procedure Render;
begin
  CalcPoints;
  case CurrentSettlementType of
    stCity:
      begin
        DrawTitle(CityNameTitle[CityArr[CurrentCityIndex + 1]]);
        CenterTextOut(100, Format('%s (Level %d)', [GetName(CurrentCityIndex + 1), City[CurrentCityIndex].MaxLevel + 1]));
        CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage((Surface.Width div 2) + 20, 160, reTextCityDef);
      end;
    stCapital:
      begin
        DrawTitle(CityNameTitle[CityArr[0]]);
        CenterTextOut(100, Format('%s (Level %d)', [GetName, City[0].MaxLevel + 1]));
        CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage((Surface.Width div 2) + 20, 160, reTextCapitalDef);
      end;
  end;
  CenterTextOut(60, Format('ActivePartyPosition=%d, CurrentPartyPosition=%d, CurrentCityIndex=%d', [ActivePartyPosition, CurrentPartyPosition,
    CurrentCityIndex]));

  if (GetDistToCapital(Leader.X, Leader.Y) = 0) or (CurrentSettlementType = stCity) then
    RenderParty(psLeft, Party[LeaderPartyIndex], Party[LeaderPartyIndex].Count < Leader.MaxLeadership)
  else
    RenderParty(psLeft, nil);

  RenderParty(psRight, SettlementParty, True);
  RenderButtons;
end;

procedure Timer;
begin

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
      if (((AParty = Party[LeaderPartyIndex]) and (Party[LeaderPartyIndex].Count < Leader.MaxLeadership)) or (AParty <> Party[LeaderPartyIndex])) then
      begin
        DisciplesRL.Scene.Hire.Show(AParty, APosition);
      end
      else
      begin
        if (Party[LeaderPartyIndex].Count = Leader.MaxLeadership) then
          InformDialog('Нужно развить лидерство!')
        else
          InformDialog('Не возможно нанять!');
        Exit;
      end;
    end;
  end;

begin
  CurrentPartyPosition := ActivePartyPosition;
  case ActivePartyPosition of
    0 .. 5:
      Hire(Party[LeaderPartyIndex], ActivePartyPosition);
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
  case ActivePartyPosition of
    0 .. 5:
      Dismiss(Party[LeaderPartyIndex], ActivePartyPosition);
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
      V := Min((MaxHitPoints - HitPoints) * Level, Gold);
      if (V <= 0) then
      begin
        InformDialog('Нужно больше золота!');
        Exit;
      end;
      R := (V div Level) * Level;
      if (HitPoints + (V div Level) < MaxHitPoints) then
      begin
        if not ConfirmDialog(Format('Исцелить на %d HP за %d золота?', [V div Level, R])) then
          Exit;
      end
      else
      begin
        if not ConfirmDialog(Format('Полностью исцелить за %d золота?', [R])) then
          Exit;
      end;
      Gold := Gold - R;
      AParty.Heal(APosition, V div Level);
    end;

  end;

begin
  CurrentPartyPosition := ActivePartyPosition;
  case ActivePartyPosition of
    0 .. 5:
      Heal(Party[LeaderPartyIndex], ActivePartyPosition);
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
        V := Level * GoldForRevivePerLevel;
        if (Gold < V) then
        begin
          InformDialog(Format('Для воскрешения нужно %d золота!', [V]));
          Exit;
        end;
        if not ConfirmDialog(Format('Воскресить за %d золота?', [V])) then
          Exit;
        Gold := Gold - V;
      end;
    end;
    AParty.Revive(APosition);
  end;

begin
  CurrentPartyPosition := ActivePartyPosition;
  case ActivePartyPosition of
    0 .. 5:
      Revive(Party[LeaderPartyIndex], ActivePartyPosition);
    6 .. 11:
      Revive(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure Close;
begin
  if (CurrentScenario = sgScenario2) then
  begin
    if (GetOwnerCount = NCity) then
    begin
      DisciplesRL.Scene.Info.Show(stVictory, scInfo);
      Exit;
    end;
  end;
  case LeaderTile of
    reNeutralCity:
      begin
        Leader.ChCityOwner;
        DisciplesRL.City.UpdateRadius(DisciplesRL.City.GetCityIndex(Leader.X, Leader.Y));
      end;
  end;
  DisciplesRL.Scenes.CurrentScene := scMap;
  NewDay;
end;

procedure MouseClick;
begin
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

procedure Show(SettlementType: TSettlementSubSceneEnum);
begin
  CurrentSettlementType := SettlementType;
  case CurrentSettlementType of
    stCity:
      begin
        CurrentCityIndex := GetPartyIndex(Leader.X, Leader.Y);
        SettlementParty := Party[CurrentCityIndex];
        SettlementParty.Owner := Leader.Race;
      end
  else
    SettlementParty := Party[CapitalPartyIndex];
  end;
  DisciplesRL.Scenes.CurrentScene := scSettlement;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (GetDistToCapital(Leader.X, Leader.Y) > 0) and (CurrentSettlementType = stCapital) and (Button = mbRight) and (GetPartyPosition(X, Y) < 6) then
    Exit;
  // Move party
  case Button of
    mbRight:
      begin
        ActivePartyPosition := GetPartyPosition(X, Y);
        if (ActivePartyPosition < 0) or ((ActivePartyPosition < 6) and (CurrentPartyPosition >= 6) and (Party[LeaderPartyIndex].Count >= Leader.MaxLeadership))
        then
          Exit;
        Party[LeaderPartyIndex].ChPosition(SettlementParty, ActivePartyPosition, CurrentPartyPosition);
      end;
    mbMiddle:
      begin
        case GetPartyPosition(X, Y) of
          0 .. 5:
            DisciplesRL.Scene.Party.Show(Party[LeaderPartyIndex], scSettlement);
        else
          DisciplesRL.Scene.Party.Show(SettlementParty, scSettlement);
        end;
        Exit;
      end;
    mbLeft:
      begin
        CurrentPartyPosition := GetPartyPosition(X, Y);
        if CurrentPartyPosition < 0 then
          Exit;
        ActivePartyPosition := CurrentPartyPosition;
      end;
  end;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      Close;
    K_P:
      DisciplesRL.Scene.Party.Show(Party[LeaderPartyIndex], scSettlement);
    K_A:
      Hire;
    K_H:
      Heal;
    K_D:
      Dismiss;
    K_R:
      Revive;
  end;
end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
end;

end.
