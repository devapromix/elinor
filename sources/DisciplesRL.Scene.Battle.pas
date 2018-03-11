unit DisciplesRL.Scene.Battle;

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

uses Vcl.Dialogs, System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Item, DisciplesRL.Map, DisciplesRL.Game,
  DisciplesRL.Player, DisciplesRL.Party, DisciplesRL.Scene.Party, DisciplesRL.Resources, DisciplesRL.GUI.Button;

procedure Victory;
begin
  Surface.Canvas.TextOut(50, 180, 'LEADER''S PARTY');
  Surface.Canvas.TextOut((Surface.Width div 2) + 50, 180, 'CAPITAL DEFENSES');
  Party[GetPartyIndex(Player.X, Player.Y)].Clear;
  Inc(Gold, GetDistToCapital(Player.X, Player.Y));
  DisciplesRL.Scenes.CurrentScene := scItem;
end;

procedure Defeat;
begin
  DisciplesRL.Scenes.CurrentScene := scDefeat;
end;

procedure Finish;
var
  I: Integer;
begin
  I := GetPartyIndex(Player.X, Player.Y);
  if LeaderParty.IsClear then
    Defeat;
  if Party[I].IsClear then
    Victory;
end;

var
  CloseButton: TButton;

procedure Init;
var
  ButLeft: Integer;
begin
  ButLeft := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  CloseButton := TButton.Create(ButLeft, 600, Surface.Canvas, reMNewGame);
  CloseButton.Sellected := True;
end;

procedure Render;
var
  I: Integer;
  F: Boolean;
begin
  // RenderDark;
  F := False;
  RenderParty(psLeft, LeaderParty);
  RenderParty(psRight, Party[GetPartyIndex(Player.X, Player.Y)]);
  if LeaderParty.IsClear then
  begin
    Surface.Canvas.Draw((Surface.Width div 2) - (ResImage[reDefeat].Width div 2), 10, ResImage[reDefeat]);
    F := True;
  end;
  I := GetPartyIndex(Player.X, Player.Y);
  if Party[I].IsClear then
  begin
    Surface.Canvas.Draw((Surface.Width div 2) - (ResImage[reVictory].Width div 2), 10, ResImage[reVictory]);
    F := True;
  end;
  if F then
  begin
    CloseButton.Render;
  end;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if CloseButton.MouseDown then
    Finish;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  CloseButton.MouseMove(X, Y);
  Render;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  N, I, J: Integer;
begin
  N := GetPartyPosition(X, Y);
  if N < 0 then
    Exit;
  case N of
    0 .. 5: // Leader
      begin
        LeaderParty.TakeDamage(25, N);
        DisciplesRL.Scenes.Render;
      end;
  else // Enemy
    begin
      I := GetPartyIndex(Player.X, Player.Y);
      Party[I].TakeDamage(25, N - 6);
      Party[I].SetState(N - 6, (Party[I].Creature[N - 6].HitPoints > 0));
      DisciplesRL.Scenes.Render;
    end;
  end;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      Finish;
  end;
end;

procedure Free;
begin
  FreeAndNil(CloseButton);
end;

end.
