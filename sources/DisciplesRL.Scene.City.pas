unit DisciplesRL.Scene.City;

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

uses Vcl.Dialogs, System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Game, DisciplesRL.Scene.Party,
  DisciplesRL.Map, DisciplesRL.City, DisciplesRL.Player;

var
  MX, MY: Integer;

procedure Init;
begin

end;

procedure Render;
var
  I, Y, X4: Integer;
begin
  RenderDark;
  CenterTextOut(100, Format('CITY (Level %d)', [City[GetCityIndex(Player.X, Player.Y)].MaxLevel + 1]));
  CenterTextOut(140, 'GOLD ' + IntToStr(Gold));
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CITY DEFENSES');
  RenderParty(psLeft, LeaderParty);
  RenderParty(psRight, Party[GetPartyIndex(Player.X, Player.Y)]);
  CenterTextOut(Surface.Height - 100, '[ENTER][ESC] Close');
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
//  ShowMessage(IntToStr(GetPartyPosition(MX, MY)));
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
