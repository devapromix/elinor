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

uses DisciplesRL.Scenes, DisciplesRL.Scene.Item, DisciplesRL.Map, DisciplesRL.Game, DisciplesRL.Player,
  DisciplesRL.Party, DisciplesRL.Scene.Party;

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
begin

end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_V:
      begin
        Victory;
      end;
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
