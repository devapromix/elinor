unit DisciplesRL.Scene.Battle;

interface

uses
  System.Types,
  System.Classes,
  Vcl.Controls;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;
procedure CalcPoints;
function TransformTo(P: Integer): Integer;
function TransformFrom(P: Integer): Integer;

implementation

uses
  Math,
  Vcl.Dialogs,
  Vcl.Graphics,
  System.SysUtils,
  DisciplesRL.Scenes,
  DisciplesRL.Map,
  DisciplesRL.Saga,
  DisciplesRL.Party,
  DisciplesRL.Scene.Party,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button,
  DisciplesRL.PascalScript.Battle,
  DisciplesRL.Creatures,
  DisciplesRL.Scene.Hire;

var
  P: array [1 .. 12] of TPoint;

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
  Party[TSaga.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y)].Clear;
  if RandomRange(1, 100) = 1 then

  else
    TSaga.AddLoot(reBag);
end;

procedure Defeat;
begin
  DisciplesRL.Scene.Hire.Show(stDefeat);
end;

procedure Finish;
var
  I: Integer;
begin
  //Log.Clear;
  I := TSaga.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  if Party[TLeaderParty.LeaderPartyIndex].IsClear then
    Defeat;
  if Party[I].IsClear then
    Victory;
end;

var
  Button: TButton;

procedure Init;
begin
  Button := TButton.Create(Surface.Width - (ResImage[reButtonDef].Width + Left), DefaultButtonTop, Surface.Canvas, reTextClose);
  Button.Sellected := True;
  //Log := TLog.Create(Left, DefaultButtonTop - 20, Surface.Canvas);
end;

procedure Render2;
var
  I, G, H, L: Integer;
  ActSlot: Integer;
  F: Boolean;
begin
  ActSlot := V.GetInt('ActiveCell');
  CalcPoints;
  with Surface.Canvas do
  begin
    Brush.Style := bsClear;
    for I := 1 to 12 do
    begin
      F := I in [1 .. 6];
      Surface.Canvas.Draw(P[I].X, P[I].Y, ResImage[reFrame]);
      if V.GetInt('Slot' + IntToStr(I) + 'HP') > 0 then
      begin
        G := V.GetInt('Slot' + IntToStr(I) + 'Type');
        if (G > 0) then
        begin
          RenderUnit(TCreature.Character(TCreatureEnum(G)).ResEnum, P[I].X, P[I].Y, F);
          // RenderUnitInfo(V.GetStr('Slot' + IntToStr(I) + 'Name'), P[I].X, P[I].Y, V.GetInt('Slot' + IntToStr(I) + 'Level'),
          // V.GetInt('Slot' + IntToStr(I) + 'HP'), V.GetInt('Slot' + IntToStr(I) + 'MHP'), V.GetInt('Slot' + IntToStr(I) + 'Use'), 0);
        end;
      end
      else
      begin
        G := V.GetInt('Slot' + IntToStr(I) + 'Type');
        H := V.GetInt('Slot' + IntToStr(I) + 'Use');
        if (G > 0) and (H > 0) then
        begin
          RenderUnit(reDead, P[I].X, P[I].Y, F);
          // RenderUnitInfo(V.GetStr('Slot' + IntToStr(I) + 'Name'), P[I].X, P[I].Y, V.GetInt('Slot' + IntToStr(I) + 'Level'),
          // V.GetInt('Slot' + IntToStr(I) + 'HP'), V.GetInt('Slot' + IntToStr(I) + 'MHP'), V.GetInt('Slot' + IntToStr(I) + 'Use'), 0);
        end;
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
  if Party[TLeaderParty.LeaderPartyIndex].IsClear then
  begin
    DrawTitle(reTitleDefeat);
    F := True;
  end;
  J := TSaga.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  if Party[J].IsClear then
  begin
    DrawTitle(reTitleVictory);
    F := True;
  end;
  if F then
  begin
    V.SetInt('ActiveCell', -1);
    Button.Render;
  end;
  // else
  //Log.Render;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if Button.MouseDown then
    Finish;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  Button.MouseMove(X, Y);
  Render;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  N, I: Integer;
begin
  N := GetPartyPosition(X, Y);
  if (N < 0) then
    Exit;
  if Party[TLeaderParty.LeaderPartyIndex].IsClear then
    Exit;
  I := TSaga.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
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
  //FreeAndNil(Log);
  FreeAndNil(Button);
end;

end.
