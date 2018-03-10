unit DisciplesRL.Scene.Battle;

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

uses Vcl.Dialogs, System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Item, DisciplesRL.Map, DisciplesRL.Game,
  DisciplesRL.Player, DisciplesRL.Party, DisciplesRL.Scene.Party;

var
  MX, MY: Integer;

procedure Victory;
begin
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CAPITAL DEFENSES');
  Party[GetPartyIndex(Player.X, Player.Y)].Clear;
  Inc(Gold, GetDistToCapital(Player.X, Player.Y));
  DisciplesRL.Scenes.CurrentScene := scItem;
end;

procedure Init;
begin

end;

procedure Render;
begin
  RenderDark;
  RenderParty(psLeft, LeaderParty);
  RenderParty(psRight, Party[GetPartyIndex(Player.X, Player.Y)]);
end;

procedure Timer;
begin

end;

procedure MouseClick;
var
  N, I, J: Integer;
begin
  N := GetPartyPosition(MX, MY);
  I := GetPartyIndex(Player.X, Player.Y);
  if N < 0 then
    Exit;
  case N of
    0 .. 5: // Leader
      begin

      end;
  else // Enemy
    begin
      Party[I].TakeDamage(25, N - 6);
      Party[I].SetState(N - 6, (Party[I].Creature[N - 6].HitPoints > 0));
      DisciplesRL.Scenes.Render;
      for J := 0 to 5 do
        if Party[I].Creature[J].Active then
          Exit;
      Victory;
    end;
  end;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MX := X;
  MY := Y;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_D:
      begin
        DisciplesRL.Scenes.CurrentScene := scDefeat;
      end;
  end;
end;

procedure Free;
begin

end;

end.
