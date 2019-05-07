unit DisciplesRL.Scene.Hire;

interface

uses
  Vcl.Controls,
  System.Classes,
  DisciplesRL.Party;

type
  THireSubSceneEnum = (stCharacter, stLeader);

procedure Init;
procedure Render;
procedure Timer;
procedure Show; overload;
procedure Show(const ASubScene: THireSubSceneEnum); overload;
procedure Show(const Party: TParty; const Position: Integer); overload;
procedure MouseClick(X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
function HireLeaderIndex: Integer;
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
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Settlement;

type
  TButtonEnum = (btOk, btClose);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextHire, reTextClose);

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;
  SubScene: THireSubSceneEnum = stCharacter;
  ButtonCharacter: array [TButtonEnum] of TButton;
  CurrentCharacter: Integer = 0;
  Lf: Integer = 0;

procedure Show;
begin

end;

procedure Show(const ASubScene: THireSubSceneEnum);
begin
  CurrentCharacter := 0;
  SubScene := ASubScene;
  DisciplesRL.Scenes.CurrentScene := scHire;
end;

procedure Show(const Party: TParty; const Position: Integer);
begin
  HireParty := Party;
  HirePosition := Position;
  CurrentCharacter := 0;
  SubScene := stCharacter;
  DisciplesRL.Scenes.CurrentScene := scHire;
end;

function HireLeaderIndex: Integer;
begin
  Result := CurrentCharacter;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Cancel;
begin
  case SubScene of
    stCharacter:
      DisciplesRL.Scenes.CurrentScene := scSettlement;
    stLeader:
      DisciplesRL.Scenes.CurrentScene := scMenu;
  end;
end;

procedure Ok;
begin
  case SubScene of
    stCharacter:
      begin
        HireParty.Hire(TheEmpireCharacters[CurrentCharacter], HirePosition);
        DisciplesRL.Scenes.CurrentScene := scSettlement;
      end;
    stLeader:
      begin
        IsGame := True;
        DisciplesRL.Game.Init;
        DisciplesRL.Scene.Settlement.Show(stCapital);
      end;
  end;
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
    ButtonCharacter[I] := TButton.Create(L, 600, Surface.Canvas, ButtonText[I]);
    Inc(L, W);
    if (I = btOk) then
      ButtonCharacter[I].Sellected := True;
  end;
end;

procedure RenderCharacterInfo;
const
  H = 25;
var
  C: TCreatureEnum;
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
  case SubScene of
    stCharacter:
      C := TheEmpireCharacters[CurrentCharacter];
    stLeader:
      C := TheEmpireLeaders[CurrentCharacter];
  end;
  with CreatureBase[C] do
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
        Add('ИСТОЧНИК', 'ЖИЗНЬ');
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
        begin
          Add('ДИСТАНЦИЯ', 'ВСЕ ПОЛЕ БОЯ');
          Add('ЦЕЛИ', 1);
        end;
      reAdj:
        begin
          Add('ДИСТАНЦИЯ', 'ОДИНОЧНАЯ');
          Add('ЦЕЛИ', 1);
        end;
      reAll:
        begin
          Add('ДИСТАНЦИЯ', 'ВСЕ ПОЛЕ БОЯ');
          Add('ЦЕЛИ', 6);
        end;
    end;
    Add('ЦЕНА', 0);
    Add('ЗОЛОТО', Gold);
  end;
end;

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    ButtonCharacter[I].Render;
end;

procedure Render;
var
  I, Y: Integer;
begin
  DrawTitle(reTitleHire);

  Y := 0;
  case SubScene of
    stCharacter:
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
    stLeader:
      for I := 0 to High(TheEmpireLeaders) do
      begin
        if I = CurrentCharacter then
          Surface.Canvas.Draw(Lf, Top + Y, ResImage[reActFrame])
        else
          Surface.Canvas.Draw(Lf, Top + Y, ResImage[reFrame]);
        with CreatureBase[TheEmpireLeaders[I]] do
        begin
          RenderUnit(ResEnum, Lf, Top + Y, True);
          RenderUnitInfo(Lf, Top + Y, TheEmpireLeaders[I]);
        end;
        Inc(Y, 120);
      end;
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
  if ButtonCharacter[btOk].MouseDown then
    Ok;
  if ButtonCharacter[btClose].MouseDown then
    Cancel;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    ButtonCharacter[I].MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case SubScene of
    stCharacter:
      case Key of
        K_ESCAPE:
          Cancel;
        K_ENTER:
          Ok;
        K_UP:
          CurrentCharacter := EnsureRange(CurrentCharacter - 1, 0, High(TheEmpireCharacters));
        K_DOWN:
          CurrentCharacter := EnsureRange(CurrentCharacter + 1, 0, High(TheEmpireCharacters));
      end;
    stLeader:
      ;
  end;
end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(ButtonCharacter[I]);
end;

end.
