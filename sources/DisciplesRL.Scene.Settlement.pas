unit DisciplesRL.Scene.Settlement;

interface

uses
  System.Classes,
  Vcl.Controls;

type
  TSettlementTypeEnum = (stCity, stCapital);

procedure Init;
procedure Render;
procedure RenderButtons;
procedure Timer;
procedure MouseClick;
procedure Show(SettlementType: TSettlementTypeEnum);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Map,
  DisciplesRL.Resources,
  DisciplesRL.Game,
  DisciplesRL.Party,
  DisciplesRL.Map,
  DisciplesRL.City,
  DisciplesRL.Scene.Party,
  DisciplesRL.Player,
  DisciplesRL.Creatures,
  DisciplesRL.GUI.Button;

type
  TButtonEnum = (btHeal, btRevive, btClose, btHire, btDismiss);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextHeal, reTextRevive, reTextClose, reTextHire, reTextHire);

var
  Button: array [TButtonEnum] of TButton;
  CurrentSettlementType: TSettlementTypeEnum;
  SettlementParty: TParty;
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
    Button[I] := TButton.Create(L, 600, Surface.Canvas, ButtonText[I]);
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

procedure Render;
begin
  // RenderDark;
  case CurrentSettlementType of
    stCity:
      begin
        CenterTextOut(100, Format('CITY (Level %d)', [City[CurrentCityIndex].MaxLevel + 1]));
        CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
        Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
        Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CITY DEFENSES');
      end;
    stCapital:
      begin
        CenterTextOut(100, Format('THE EMPIRE CAPITAL (Level %d)', [City[0].MaxLevel + 1]));
        CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
        Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
        Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CAPITAL DEFENSES');
      end;
  end;

  if (GetDistToCapital(Player.X, Player.Y) = 0) or (CurrentSettlementType = stCity) then
    RenderParty(psLeft, LeaderParty)
  else
    RenderParty(psLeft, nil);

  RenderParty(psRight, SettlementParty);
  RenderButtons;
end;

procedure Timer;
begin

end;

procedure Hire;
begin
  ShowMessage('HIRE');
end;

procedure Dismiss;
begin
  case ActivePartyPosition of
    0 .. 5:
      LeaderParty.Dismiss(ActivePartyPosition);
    6 .. 11:
      SettlementParty.Dismiss(ActivePartyPosition - 6);
  end;
end;

procedure Heal;
begin
  case ActivePartyPosition of
    0 .. 5:
      LeaderParty.Heal(ActivePartyPosition);
    6 .. 11:
      SettlementParty.Heal(ActivePartyPosition - 6);
  end;
end;

procedure Revive;
begin
  case ActivePartyPosition of
    0 .. 5:
      LeaderParty.Revive(ActivePartyPosition);
    6 .. 11:
      SettlementParty.Revive(ActivePartyPosition - 6);
  end;
end;

procedure Action;
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
    Action;
end;

procedure Show(SettlementType: TSettlementTypeEnum);
begin
  CurrentSettlementType := SettlementType;
  case CurrentSettlementType of
    stCity:
      begin
        CurrentCityIndex := GetPartyIndex(Player.X, Player.Y);
        SettlementParty := Party[CurrentCityIndex];
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
  if (GetDistToCapital(Player.X, Player.Y) > 0) and (CurrentSettlementType = stCapital) and (Button = mbRight) and (GetPartyPosition(X, Y) < 6) then
    Exit;
  // Move party
  case Button of
    mbRight:
      begin
        ActivePartyPosition := GetPartyPosition(X, Y);
        LeaderParty.ChPosition(SettlementParty, ActivePartyPosition, CurrentPartyPosition);
      end;
    mbLeft:
      begin
        CurrentPartyPosition := GetPartyPosition(X, Y);
        I := GetPartyIndex(Player.X, Player.Y);
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
      Action;
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
