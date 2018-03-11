unit DisciplesRL.Scene.Capital;

interface

uses System.Classes, Vcl.Controls;

procedure Init;
procedure Render;
procedure RenderButtons;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Resources, DisciplesRL.Game,
  DisciplesRL.Party, Vcl.Dialogs, DisciplesRL.Map, DisciplesRL.City, DisciplesRL.Scene.Party, DisciplesRL.Player,
  DisciplesRL.Creatures, DisciplesRL.GUI.Button;

type
  TButtonEnum = (btHeal, btRevive, btClose, btHire);

var
  Button: array [TButtonEnum] of TButton;

procedure Init;
var
  I: TButtonEnum;
  L, W: Integer;
begin
  W := ResImage[reButtonDef].Width + 10;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, 600, Surface.Canvas, reMNewGame);
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
  CenterTextOut(100, Format('THE EMPIRE CAPITAL (Level %d)', [City[0].MaxLevel + 1]));
  CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CAPITAL DEFENSES');
  if (GetDistToCapital(Player.X, Player.Y) = 0) then
    RenderParty(psLeft, LeaderParty)
  else
    RenderParty(psLeft, nil);
  RenderParty(psRight, CapitalParty);
  RenderButtons;
end;

procedure Timer;
begin

end;

procedure Hire;
begin

end;

procedure Heal;
begin
  case ActivePartyPosition of
    0 .. 5:
      LeaderParty.Heal(ActivePartyPosition);
    6 .. 11:
      CapitalParty.Heal(ActivePartyPosition - 6);
  end;
end;

procedure Revive;
begin
  case ActivePartyPosition of
    0 .. 5:
      LeaderParty.Revive(ActivePartyPosition);
    6 .. 11:
      CapitalParty.Revive(ActivePartyPosition - 6);
  end;
end;

procedure MouseClick;
begin
  if Button[btHire].MouseDown then
    Hire;
  if Button[btHeal].MouseDown then
    Heal;
  if Button[btRevive].MouseDown then
    Revive;
  if Button[btClose].MouseDown then
    DisciplesRL.Scenes.CurrentScene := scMap;
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
  if (GetDistToCapital(Player.X, Player.Y) > 0) then
    Exit;
  // Move party
  case Button of
    mbRight:
      begin
        ActivePartyPosition := GetPartyPosition(X, Y);
        LeaderParty.ChPosition(CapitalParty, ActivePartyPosition, CurrentPartyPosition);
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
      DisciplesRL.Scenes.CurrentScene := scMap;
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
