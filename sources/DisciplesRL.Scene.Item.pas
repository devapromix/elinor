unit DisciplesRL.Scene.Item;

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

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Map, DisciplesRL.Game, DisciplesRL.Map,
  DisciplesRL.Resources, DisciplesRL.Player;

procedure Init;
begin

end;

procedure Render;
begin
//  RenderDark;

  CenterTextOut(100, 'ITEMS');
  CenterTextOut(200, 'GOLD ' + IntToStr(Gold));
  CenterTextOut(Surface.Height - 100, '[ENTER][ESC] Close');
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
    K_ESCAPE, K_ENTER:
      begin
        DisciplesRL.Scenes.CurrentScene := scMap;
        case MapTile[Player.X, Player.Y] of
          reTower:
              DisciplesRL.Scenes.CurrentScene := scVictory;
          reEmpireCity:
              DisciplesRL.Scenes.CurrentScene := scCity;
        end;
      end;
  end;
end;

procedure Free;
begin

end;

end.
