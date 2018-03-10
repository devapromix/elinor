unit DisciplesRL.Scene.Capital;

interface

{
  Бетрезен умирает …
  Десять лет назад Великая Война пропитала эту землю потоками крови. Горные кланы были разгромлены.
  Половина гномов скрылась за огромными порталами под защитой рун. Вторая половина обезумела от страха,
  ибо они предчувствовали , что скоро тьма поглотит их .
  Во главе Империи стоит слабый монарх , охваченный скорбью по любимой жене и единственному сыну.
  Дети Империи поют песни о смерти . Империя , лишённая наследника постепенно погружается в хаос …
}

uses System.Classes, Vcl.Controls;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Resources, DisciplesRL.Game,
  DisciplesRL.Party, Vcl.Dialogs, DisciplesRL.Map, DisciplesRL.City, DisciplesRL.Scene.Party, DisciplesRL.Player,
  DisciplesRL.Creatures;

// var
// MX, MY: Integer;

var
  CurrentPartyPosition: Integer = 2;

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
  // DisciplesRL.Scenes.Render;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  // MX := X;
  // MY := Y;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, J: Integer;
begin
  if (GetDistToCapital(Player.X, Player.Y) > 0) then
    Exit;
  // Move party
  if (Button = mbRight) then
  begin
    if (CurrentPartyPosition < 0) then
      Exit;
    ActivePosition := GetPartyPosition(X, Y);
    case CurrentPartyPosition of
      0 .. 5:
        case ActivePosition of
          0 .. 5:
            LeaderParty.Swap(CurrentPartyPosition, ActivePosition);
          6 .. 11:
            LeaderParty.Swap(CapitalParty, CurrentPartyPosition, ActivePosition - 6);
        end;
      6 .. 11:
        case ActivePosition of
          0 .. 5:
            CapitalParty.Swap(LeaderParty, CurrentPartyPosition - 6, ActivePosition);
          6 .. 11:
            CapitalParty.Swap(CurrentPartyPosition - 6, ActivePosition - 6);
        end;
    end;
    CurrentPartyPosition := ActivePosition;
    Exit;
  end;
  CurrentPartyPosition := GetPartyPosition(X, Y);
  I := GetPartyIndex(Player.X, Player.Y);
  if CurrentPartyPosition < 0 then
    Exit;
  ActivePosition := CurrentPartyPosition;
  case ActivePosition of
    0 .. 5:
      begin

      end;
  else
    begin

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
begin

end;

end.
