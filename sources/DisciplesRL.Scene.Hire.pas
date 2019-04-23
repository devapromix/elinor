unit DisciplesRL.Scene.Hire;

interface

uses
  System.Classes,
  DisciplesRL.Party;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick(X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure SetHire(const Party: TParty; const Position: Integer);
procedure Free;

implementation

uses
  System.Math,
  System.SysUtils,
  DisciplesRL.Game,
  DisciplesRL.Scenes,
  DisciplesRL.Creatures,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button,
  DisciplesRL.Scene.Party;

type
  TButtonEnum = (btHire, btClose);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextHire, reTextClose);
  Characters: array [0 .. 2] of TCreatureEnum = (crSquire, crArcher, crArcher);

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;
  Button: array [TButtonEnum] of TButton;
  CurrentCharacter: Integer = 0;
  Lf: Integer = 0;

procedure SetHire(const Party: TParty; const Position: Integer);
begin
  HireParty := Party;
  HirePosition := Position;
end;

procedure Close;
begin
  DisciplesRL.Scenes.CurrentScene := scSettlement;
end;

procedure Hire;
begin
  HireParty.Hire(Characters[CurrentCharacter], HirePosition);
  DisciplesRL.Scenes.CurrentScene := scSettlement;
end;

procedure Init;
var
  R: TResEnum;
  I: TButtonEnum;
  L, W: Integer;
begin
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  Lf := (Surface.Width div 2) - (ResImage[reFrame].Width div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, 600, Surface.Canvas, ButtonText[I]);
    Inc(L, W);
    if (I = btClose) then
      Button[I].Sellected := True;
  end;
end;

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].Render;
end;

procedure Render;
var
  I, Y: Integer;
begin
  Surface.Canvas.Draw((Surface.Width div 2) - (ResImage[reVictory].Width div 2), 10, ResImage[reVictory]);

  Y := 0;
  for I := 0 to High(Characters) do
  begin
    if I = CurrentCharacter then
      Surface.Canvas.Draw(Lf, Top + Y, ResImage[reActFrame])
    else
      Surface.Canvas.Draw(Lf, Top + Y, ResImage[reFrame]);
    with CreatureBase[Characters[I]] do
    begin
      RenderUnit(ResEnum, Lf, Top + Y);
      RenderUnitInfo(Lf, Top + Y, Characters[I]);
    end;
    Inc(Y, 120);
  end;

  RenderButtons;
end;

procedure Timer;
begin

end;

procedure MouseClick(X, Y: Integer);
begin
  if MouseOver(Lf, Top, X, Y) then
  begin
    CurrentCharacter := 0;
  end;
  if MouseOver(Lf, Top + 120, X, Y) then
  begin
    CurrentCharacter := 1;
  end;
  if MouseOver(Lf, Top + 240, X, Y) then
  begin
    CurrentCharacter := 2;
  end;
  if Button[btHire].MouseDown then
    Hire;
  if Button[btClose].MouseDown then
    Close;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE:
      Close;
    K_ENTER:
      Hire;
    K_UP:
      CurrentCharacter := EnsureRange(CurrentCharacter - 1, 0, High(Characters));
    K_DOWN:
      CurrentCharacter := EnsureRange(CurrentCharacter + 1, 0, High(Characters));
  end;
end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
end;

end.
