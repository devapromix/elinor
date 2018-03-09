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
  DisciplesRL.Party, DisciplesRL.Map, DisciplesRL.City;

procedure Init;
begin

end;

procedure Render;
var
  I, Y, X4: Integer;

  procedure Add(I: Integer; Party: TParty; AX, AY: Integer);
  begin
    with Party.Creature[I] do
      if Active then
      begin
        Surface.Canvas.TextOut(AX, AY, Format('[%d] %s', [I, Name]));
        Surface.Canvas.TextOut(AX, AY + 40, Format('HP %d/%d', [HitPoints, MaxHitPoints]));
        Surface.Canvas.TextOut(AX, AY + 80, Format('Damage %d Armor %d', [Damage, Armor]));
      end;
  end;

begin
  RenderDark;

  CenterTextOut(100, Format('THE EMPIRE CAPITAL (%d)', [City[0].MaxLevel]));
  CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CAPITAL DEFENSES');
  CenterTextOut(Surface.Height - 100, '[ESC] Close');

  X4 := Surface.Width div 4;
  Y := 220;
  for I := 0 to 5 do
  begin
    case I of
      0, 2, 4:
        begin
          Add(I, LeaderParty, X4, Y);
        end;
      1, 3, 5:
        begin
          Add(I, LeaderParty, 0, Y);
          Inc(Y, 120);
        end;
    end;
  end;

  Y := 220;
  for I := 0 to 5 do
  begin
    case I of
      1, 3, 5:
        begin
          Add(I, CapitalParty, X4 * 3, Y);
        end;
      0, 2, 4:
        begin
          Add(I, CapitalParty, X4 * 2, Y);
          Inc(Y, 120);
        end;
    end;
  end;
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
    K_ESCAPE:
      DisciplesRL.Scenes.CurrentScene := scMap;
  end;
end;

procedure Free;
begin

end;

end.
