unit DisciplesRL.Scene.Settlement;

interface

uses
  System.Classes,
  Vcl.Controls;

type
  TSettlementSubSceneEnum = (stCity, stCapital);

procedure Init;
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

var
  Button: array [TButtonEnum] of TButton;
  CurrentSettlementType: TSettlementSubSceneEnum;
  SettlementParty: TParty = nil;
  CurrentCityIndex: Integer = -1;

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

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].Render;
end;

function GetCityName: string;
begin
  Result := '';
end;

function GetCapitalName: string;
begin
  Result := '';
end;

procedure Render;
begin
  CalcPoints;
  // RenderDark;
  case CurrentSettlementType of
    stCity:
      begin
        CenterTextOut(100, Format('%s (Level %d)', [GetCityName, City[CurrentCityIndex].MaxLevel + 1]));
        CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage((Surface.Width div 2) + 20, 160, reTextCityDef);
      end;
    stCapital:
      begin
        CenterTextOut(100, Format('%s (Level %d)', [GetCapitalName, City[0].MaxLevel + 1]));
        CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage((Surface.Width div 2) + 20, 160, reTextCapitalDef);
      end;
  end;

  if (GetDistToCapital(Leader.X, Leader.Y) = 0) or (CurrentSettlementType = stCity) then
    RenderParty(psLeft, LeaderParty, LeaderParty.Count < Leader.MaxLeadership)
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
      if (((AParty = LeaderParty) and (LeaderParty.Count < Leader.MaxLeadership)) or (AParty <> LeaderParty)) then
        DisciplesRL.Scene.Hire.Show(AParty, APosition)
      else
      begin
        if (LeaderParty.Count = Leader.MaxLeadership) then
        InformDialog('Нужно развить лидерство!')
         else
        InformDialog('Не возможно нанять!');
        Exit;
      end;
    end;
  end;

begin
  case ActivePartyPosition of
    0 .. 5:
      Hire(LeaderParty, ActivePartyPosition);
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
      Dismiss(LeaderParty, ActivePartyPosition);
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
  case ActivePartyPosition of
    0 .. 5:
      Heal(LeaderParty, ActivePartyPosition);
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
  case ActivePartyPosition of
    0 .. 5:
      Revive(LeaderParty, ActivePartyPosition);
    6 .. 11:
      Revive(SettlementParty, ActivePartyPosition - 6);
  end;
end;

procedure Close;
begin
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
    SettlementParty := CapitalParty;
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
var
  I, J: Integer;
begin
  if (GetDistToCapital(Leader.X, Leader.Y) > 0) and (CurrentSettlementType = stCapital) and (Button = mbRight) and (GetPartyPosition(X, Y) < 6) then
    Exit;
  // Move party
  case Button of
    mbRight:
      begin
        ActivePartyPosition := GetPartyPosition(X, Y);
        if (CurrentPartyPosition = ActivePartyPosition) and (True) then
        begin
          case ActivePartyPosition of
            0 .. 5:
              DisciplesRL.Scene.Party.Show(LeaderParty, scSettlement);
          else
            DisciplesRL.Scene.Party.Show(SettlementParty, scSettlement);
          end;
          Exit;
        end;
        if (ActivePartyPosition < 0) or ((ActivePartyPosition < 6) and (CurrentPartyPosition >= 6) and (LeaderParty.Count >= Leader.MaxLeadership))
        then
          Exit;
        LeaderParty.ChPosition(SettlementParty, ActivePartyPosition, CurrentPartyPosition);
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
