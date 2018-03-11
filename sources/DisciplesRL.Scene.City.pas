unit DisciplesRL.Scene.City;

interface

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

uses Vcl.Dialogs, System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Game, DisciplesRL.Scene.Party,
  DisciplesRL.Map, DisciplesRL.City, DisciplesRL.Player, DisciplesRL.Party, DisciplesRL.Scene.Capital;

procedure Init;
begin

end;

procedure Render;
var
  I, Y, X4: Integer;
begin
//  RenderDark;
  CenterTextOut(100, Format('CITY (Level %d)', [City[GetCityIndex(Player.X, Player.Y)].MaxLevel + 1]));
  CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CITY DEFENSES');
  RenderParty(psLeft, LeaderParty);
  RenderParty(psRight, Party[GetPartyIndex(Player.X, Player.Y)]);
  DisciplesRL.Scene.Capital.RenderButtons;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  // ShowMessage(IntToStr(GetPartyPosition(MX, MY)));
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, J: Integer;
begin
  I := GetPartyIndex(Player.X, Player.Y);
  // Move party
  case Button of
    mbRight:
      begin
        ActivePartyPosition := GetPartyPosition(X, Y);
        LeaderParty.ChPosition(Party[I], ActivePartyPosition, CurrentPartyPosition);
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
      DisciplesRL.Scenes.CurrentScene := scMap;
  end;
end;

procedure Free;
begin

end;

end.
