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
  DisciplesRL.Player, DisciplesRL.Party, DisciplesRL.Scene.Party, DisciplesRL.Resources, DisciplesRL.GUI.Button,
  DisciplesRL.PascalScript.Battle;

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
  ActivePartyPosition := V.GetInt('ActivePos');
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

  {
    var
    I, V, L: Integer;
    begin
    ActSlot := VM.GetInt('ActiveCell');
    CalcPoints;
    with Graph.Surface.Canvas do
    begin
    Brush.Style := bsClear;
    Draw((Graph.Surface.Width div 2) - (BG.Width div 2), (Graph.Surface.Height div 2) - (BG.Height div 2), BG);

    if (ActSlot > 0) then Draw(P[ActSlot].X - 6, P[ActSlot].Y + 145, CM);
    //    if (ActSlot > 0) then Draw(P[ActSlot].X, P[ActSlot].Y, U[0][1]);

    for I := 1 to 12 do
    begin
    V := VM.GetInt('Slot' + IntToStr(I) + 'Type');
    if (V > 0) then
    begin
    with Graph.Surface.Canvas.Font do
    begin
    case UnitMessageColor[I] of
    4  : Color := clRed;
    12 : Color := $00FCAF39; // Blue
    14 : Color := clYellow;
    else Color := clWhite;
    end;
    Size := 14;
    end;
    L := VM.GetInt('Slot' + I.ToString + 'HP');
    if (L <= 0) then Continue;
    BR.Assign(Red);
    BR.Width := BarWidth(L, VM.GetInt('Slot' + IntToStr(I) + 'MHP'));
    Draw(P[I].X, P[I].Y + 180, Bar);
    Draw(P[I].X + 2, P[I].Y + 182, BR);
    if (I < 7) then
    begin
    Draw(P[I].X, P[I].Y, U[V][1]);
    if VM.GetBool('FlagSlepotaSlot' + IntToStr(I)) then
    Draw(P[I].X + 5, P[I].Y + 5, Eff[1]);
    end else begin
    Draw(P[I].X, P[I].Y, U[V][2]);
    if VM.GetBool('FlagSlepotaSlot' + IntToStr(I)) then
    Draw(P[I].X + 79, P[I].Y + 5, Eff[1]);
    end;
    if (UnitMessage[I] <> '') then
    begin
    L := 50 - (TextWidth(UnitMessage[I]) div 2);
    TextOut(P[I].X + L, P[I].Y + 80, UnitMessage[I]);
    end;
    //

    end;
    end;
    TextOut(140, 20, '[SPACE] - Закрыть');
    end;
    Graph.Render; }
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
  N, I: Integer;
begin
  N := GetPartyPosition(X, Y);
  if (N < 0) then
    Exit;
  if LeaderParty.IsClear then
    Exit;
  I := GetPartyIndex(Player.X, Player.Y);
  if Party[I].IsClear then
    Exit;
  ClearMessages;
  case Button of
    mbLeft:
      begin
        V.SetInt('PosClick', N);
        Run('Click.pas');
      end;
  end;
  { case N of
    0 .. 5: // Leader
    begin
    LeaderParty.TakeDamage(25, N);
    DisciplesRL.Scenes.Render;
    end;
    6 .. 11: // Enemy
    begin
    Party[I].TakeDamage(25, N - 6);
    Party[I].SetState(N - 6, (Party[I].Creature[N - 6].HitPoints > 0));
    DisciplesRL.Scenes.Render;
    end;
    end; }
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
