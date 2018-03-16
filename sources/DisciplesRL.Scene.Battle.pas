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
function TransformTo(P: Integer): Integer;
function TransformFrom(P: Integer): Integer;

implementation

uses Vcl.Dialogs, Vcl.Graphics, System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Scene.Item, DisciplesRL.Map,
  DisciplesRL.Game,
  DisciplesRL.Player, DisciplesRL.Party, DisciplesRL.Scene.Party, DisciplesRL.Resources, DisciplesRL.GUI.Button,
  DisciplesRL.PascalScript.Battle, System.Types, DisciplesRL.Creatures;

var
  P: array [1 .. 12] of TPoint;

const
  Top = 220;
  Left = 15;

  // Трансформация координат из новой системы в старую
function TransformTo(P: Integer): Integer;
{
  1 |0 |   6 | 7
  3 |2 |   8 | 9
  5 |4 |   10|11

  1 |4 |   7 |10
  2 |5 |   8 |11
  3 |6 |   9 |12
}
begin
  if (P = -1) then
    Result := 0;

  if (P = 0) then
    Result := 4;
  if (P = 1) then
    Result := 1;
  if (P = 2) then
    Result := 5;
  if (P = 3) then
    Result := 2;
  if (P = 4) then
    Result := 6;
  if (P = 5) then
    Result := 3;

  if (P = 6) then
    Result := 7;
  if (P = 7) then
    Result := 10;
  if (P = 8) then
    Result := 8;
  if (P = 9) then
    Result := 11;
  if (P = 10) then
    Result := 9;
  if (P = 11) then
    Result := 12;
end;

// Трансформация координат из старой системы в новую
function TransformFrom(P: Integer): Integer;
{
  1 |4 |   7 |10
  2 |5 |   8 |11
  3 |6 |   9 |12

  1 |0 |   6 | 7
  3 |2 |   8 | 9
  5 |4 |   10|11
}
begin
  if (P = 0) then
    Result := -1;

  if (P = 4) then
    Result := 0;
  if (P = 1) then
    Result := 1;
  if (P = 5) then
    Result := 2;
  if (P = 2) then
    Result := 3;
  if (P = 6) then
    Result := 4;
  if (P = 3) then
    Result := 5;

  if (P = 7) then
    Result := 6;
  if (P = 10) then
    Result := 7;
  if (P = 8) then
    Result := 8;
  if (P = 11) then
    Result := 9;
  if (P = 9) then
    Result := 10;
  if (P = 12) then
    Result := 11;
end;

procedure CalcPoints;
var
  I: Byte;
  X, Y: Byte;
  X4: Integer;
begin
  X := 0;
  Y := 0;
  X4 := Surface.Width div 4;
  for I := 1 to 12 do
  begin
    P[I].X := Left + (X * X4);
    P[I].Y := Top + (Y * 120);
    Inc(Y);
    if (Y > 2) then
    begin
      Y := 0;
      Inc(X);
    end;
  end;
end;

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

procedure Render2;
var
  I, G, L: Integer;
  ActSlot: Integer;
begin
  ActSlot := V.GetInt('ActiveCell');
  CalcPoints;
  with Surface.Canvas do
  begin
    Brush.Style := bsClear;
    for I := 1 to 12 do
    begin
      Surface.Canvas.Draw(P[I].X, P[I].Y, ResImage[reFrame]);
      if V.GetInt('Slot' + IntToStr(I) + 'HP') > 0 then
      begin
        G := V.GetInt('Slot' + IntToStr(I) + 'Type');
        DisplayUnit(CreatureBase[TCreatureEnum(G)].ResEnum, P[I].X + 7, P[I].Y + 7);

        Surface.Canvas.TextOut(P[I].X + 10 + 64, P[I].Y + 6,
          Format('[%d] %s (Level %d)', [I, V.GetStr('Slot' + IntToStr(I) + 'Name'), 1]));
        Surface.Canvas.TextOut(P[I].X + 10 + 64, P[I].Y + 40 + 2,
          Format('HP %s/%s', [V.GetStr('Slot' + IntToStr(I) + 'HP'), V.GetStr('Slot' + IntToStr(I) + 'MHP')]));
        Surface.Canvas.TextOut(P[I].X + 10 + 64, P[I].Y + 80 - 2,
          Format('Damage %s Armor %d', [V.GetStr('Slot' + IntToStr(I) + 'Use'), 0]));

      end;
    end;
    if (ActSlot > 0) then
      Draw(P[ActSlot].X, P[ActSlot].Y, ResImage[reActFrame]);

    for I := 1 to 12 do
    begin
      G := V.GetInt('Slot' + IntToStr(I) + 'Type');
      if (G > 0) then
      begin
        with Surface.Canvas.Font do
        begin
          case UnitMessageColor[I] of
            4:
              Color := clRed;
            12:
              Color := $00FCAF39; // Blue
            14:
              Color := clYellow;
          else
            Color := clGreen;
          end;
        end;
        L := V.GetInt('Slot' + I.ToString + 'HP');
        if (L <= 0) then
          Continue;
        if (UnitMessage[I] <> '') then
        begin
          L := (64 div 2) - (TextWidth(UnitMessage[I]) div 2) + 7;
          TextOut(P[I].X + L, P[I].Y + 50, UnitMessage[I]);
        end;
        //
        Surface.Canvas.Font.Color := clGreen;
      end;
    end;
  end;
end;

procedure Render;
var
  J: Integer;
  F: Boolean;
begin
  Render2;
  //
  F := False;
  if LeaderParty.IsClear then
  begin
    Surface.Canvas.Draw((Surface.Width div 2) - (ResImage[reDefeat].Width div 2), 10, ResImage[reDefeat]);
    F := True;
  end;
  J := GetPartyIndex(Player.X, Player.Y);
  if Party[J].IsClear then
  begin
    Surface.Canvas.Draw((Surface.Width div 2) - (ResImage[reVictory].Width div 2), 10, ResImage[reVictory]);
    F := True;
  end;
  if F then
  begin
    CloseButton.Render;
  end;
  { /// //
    ActSlot := TransformFrom(V.GetInt('ActiveCell'));
    CalcPoints;
    if (ActSlot > 0) then
    Surface.Canvas.Draw(P[ActSlot].X, P[ActSlot].Y, ResImage[reActFrame]);
    for I := 1 to 12 do
    begin
    K := V.GetInt('Slot' + IntToStr(I) + 'Type');
    if (K > 0) then
    begin
    Surface.Canvas.Draw(P[I].X, P[I].Y, ResImage[reFrame]);
    Surface.Canvas.TextOut(P[I].X, P[I].Y, V.GetStr('Slot' + IntToStr(I) + 'HP'));
    // IntToStr(CreatureBase[TCreatureEnum(K)].HitPoints));
    end;
    end; }

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
        N := TransformTo(N);
        V.SetInt('SlotClick', N);
        Run('Battles\SlotClick.pas');
        DisciplesRL.Scenes.Render;
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
