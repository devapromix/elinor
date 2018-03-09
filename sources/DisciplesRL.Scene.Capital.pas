unit DisciplesRL.Scene.Capital;

interface

uses System.Classes;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Resources, DisciplesRL.Game,
  DisciplesRL.Party, Vcl.Dialogs, DisciplesRL.Map, DisciplesRL.City, DisciplesRL.Scene.Party, DisciplesRL.Player;

var
  MX, MY: Integer;

procedure Init;
begin

end;

procedure Render;
begin
  RenderDark;

  CenterTextOut(100, Format('THE EMPIRE CAPITAL (Level %d)', [City[0].MaxLevel + 1]));
  CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CAPITAL DEFENSES');
  if (GetDistToCapital(Player.X, Player.Y) = 0) then
    RenderParty(psLeft, LeaderParty)
  else
    RenderParty(psLeft, nil);
  RenderParty(psRight, CapitalParty);
  CenterTextOut(Surface.Height - 100, '[ENTER][ESC] Close');
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  ShowMessage(IntToStr(GetPartyPosition(MX, MY)));
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MX := X;
  MY := Y;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      DisciplesRL.Scenes.CurrentScene := scMap;
  end;
end;

procedure Free;
begin

end;

end.
