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
  HireParty.Hire(TheEmpireCharacters[CurrentCharacter], HirePosition);
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
  Lf := (Surface.Width div 2) - (ResImage[reFrame].Width) - 2;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, 600, Surface.Canvas, ButtonText[I]);
    Inc(L, W);
    if (I = btHire) then
      Button[I].Sellected := True;
  end;
end;

procedure RenderCharacterInfo;
const
  H = 25;
var
  L, T: Integer;

  procedure Add; overload;
  begin
    Inc(T, H);
  end;

  procedure Add(S: string); overload;
  begin
    Surface.Canvas.TextOut(L, T, S);
    Inc(T, H);
  end;

  procedure Add(S, V: string); overload;
  begin
    Surface.Canvas.TextOut(L, T, Format('%s: %s', [S, V]));
    Inc(T, H);
  end;

  procedure Add(S: string; V: Integer; R: string = ''); overload;
  begin
    Surface.Canvas.TextOut(L, T, Format('%s: %d%s', [S, V, R]));
    Inc(T, H);
  end;

  procedure Add(S: string; V, M: Integer); overload;
  begin
    Surface.Canvas.TextOut(L, T, Format('%s: %d/%d', [S, V, M]));
    Inc(T, H);
  end;

begin
  T := Top + 6;
  L := Lf + ResImage[reActFrame].Width + 12;
  with CreatureBase[TheEmpireCharacters[CurrentCharacter]] do
  begin
    Add('ЮНИТ');
    Add('УРОВЕНЬ', Level);
    Add('ТОЧНОСТЬ', ChancesToHit, '%');
    Add('ИНИЦИАТИВА', Initiative);
    Add('ЗДОРОВЬЕ', HitPoints, HitPoints);
    Add('УРОН', Damage);
    Add('БРОНЯ', Armor);
    case SourceEnum of
      seWeapon:
        Add('ИСТОЧНИК', 'ОРУЖИЕ');
      seLife:
        ;
      seMind:
        ;
      seDeath:
        ;
      seAir:
        ;
      seEarth:
        ;
      seFire:
        ;
      seWater:
        ;
    end;
    case ReachEnum of
      reAny:
        Add('ДИСТАНЦИЯ', 'ВСЕ ПОЛЕ БОЯ');
      reAdj:
        Add('ДИСТАНЦИЯ', 'ОДИНОЧНАЯ');
      reAll:
        Add('ДИСТАНЦИЯ', 'ВСЕ ПОЛЕ БОЯ');
    end;
    Add('ЦЕЛИ', Targets);
    Add('ЦЕНА', 0);
    Add('ЗОЛОТО', Gold);
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
  DrawTitle(reTitleHire);

  Y := 0;
  for I := 0 to High(TheEmpireCharacters) do
  begin
    if I = CurrentCharacter then
      Surface.Canvas.Draw(Lf, Top + Y, ResImage[reActFrame])
    else
      Surface.Canvas.Draw(Lf, Top + Y, ResImage[reFrame]);
    with CreatureBase[TheEmpireCharacters[I]] do
    begin
      RenderUnit(ResEnum, Lf, Top + Y, True);
      RenderUnitInfo(Lf, Top + Y, TheEmpireCharacters[I]);
    end;
    Inc(Y, 120);
  end;
  Surface.Canvas.Draw(Lf + ResImage[reActFrame].Width + 2, Top, ResImage[reInfoFrame]);
  RenderCharacterInfo;
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
      CurrentCharacter := EnsureRange(CurrentCharacter - 1, 0, High(TheEmpireCharacters));
    K_DOWN:
      CurrentCharacter := EnsureRange(CurrentCharacter + 1, 0, High(TheEmpireCharacters));
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
