unit DisciplesRL.Scene.Party;

interface

uses
  Vcl.Controls,
  System.Classes,
  DisciplesRL.Party,
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.Creatures;

const
  Top = 220;
  Left = 10;

type
  TPartySide = (psLeft, psRight);

procedure Init;
procedure Render;
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseClick;
procedure Timer;
function GetRandomActivePartyPosition(Party: TParty): TPosition;
procedure Show(Party: TParty; CloseScene: TSceneEnum);
procedure Free;
function GetFrameX(const Position: TPosition; const PartySide: TPartySide): Integer;
function GetFrameY(const Position: TPosition; const PartySide: TPartySide): Integer;
function MouseOver(AX, AY, MX, MY: Integer): Boolean;
function GetPartyPosition(const MX, MY: Integer): Integer;
procedure RenderParty(const PartySide: TPartySide; const Party: TParty; CanHire: Boolean = False);
procedure RenderUnitInfo(Name: string; AX, AY, Level, Experience, HitPoints, MaxHitPoints, Damage, Heal, Armor, Initiative,
  ChToHit: Integer; IsExp: Boolean); overload;
procedure RenderUnitInfo(Position: TPosition; Party: TParty; AX, AY: Integer); overload;
procedure RenderUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum; IsAdv: Boolean = True); overload;
procedure RenderUnit(AResEnum: TResEnum; const AX, AY: Integer; F: Boolean); overload;
procedure RenderUnit(Position: TPosition; Party: TParty; AX, AY: Integer; CanHire: Boolean = False); overload;

var
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

implementation

uses
  Math,
  System.SysUtils,
  System.TypInfo,
  DisciplesRL.Game,
  DisciplesRL.Leader,
  DisciplesRL.GUI.Button,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Map,
  DisciplesRL.Scene.Map;

type
  TButtonEnum = (btClose);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);

var
  Button: array [TButtonEnum] of TButton;
  CurrentParty: TParty;
  BackScene: TSceneEnum;

const
  S = 2;

procedure Show(Party: TParty; CloseScene: TSceneEnum);
begin
  CurrentParty := Party;
  BackScene := CloseScene;
  ActivePartyPosition := GetRandomActivePartyPosition(CurrentParty);
  DisciplesRL.Scenes.CurrentScene := scParty;
end;

function GetRandomActivePartyPosition(Party: TParty): TPosition;
var
  I: TPosition;
begin
  repeat
    I := RandomRange(Low(TPosition), High(TPosition) + 1);
  until Party.GetHitPoints(I) > 0;
  Result := I;
end;

function GetFrameX(const Position: TPosition; const PartySide: TPartySide): Integer;
var
  W: Integer;
begin
  W := Surface.Width div 4;
  case Position of
    0, 2, 4:
      begin
        case PartySide of
          psLeft:
            Result := (W + Left) - (W - ResImage[reFrame].Width - S);
        else
          Result := Surface.Width - (Left + S + (ResImage[reFrame].Width * 2));
        end;
      end;
  else
    begin
      case PartySide of
        psLeft:
          Result := Left;
      else
        Result := Surface.Width - ResImage[reFrame].Width - Left;
      end;
    end;
  end;
end;

function GetFrameY(const Position: TPosition; const PartySide: TPartySide): Integer;
begin
  case Position of
    0, 1:
      Result := Top;
    2, 3:
      Result := Top + ResImage[reFrame].Height + S;
  else
    Result := Top + ((ResImage[reFrame].Height + S) * 2);
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
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, DefaultButtonTop, Surface.Canvas, ButtonText[I]);
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
begin
  DrawTitle(reTitleParty);
  RenderParty(psLeft, CurrentParty);
  RenderButtons;
end;

procedure Close;
begin
  if CurrentParty <> Party[LeaderPartyIndex] then
    ActivePartyPosition := ActivePartyPosition + 6;
  DisciplesRL.Scenes.CurrentScene := BackScene;
end;

procedure MouseClick;
begin
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

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      Close;
  end;
end;

procedure Timer;
begin

end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
end;

function MouseOver(AX, AY, MX, MY: Integer): Boolean;
begin
  Result := (MX > AX) and (MX < AX + ResImage[reFrame].Width) and (MY > AY) and (MY < AY + ResImage[reFrame].Height);
end;

function GetPartyPosition(const MX, MY: Integer): Integer;
var
  R: Integer;
  Position: TPosition;
  PartySide: TPartySide;
begin
  R := -1;
  Result := R;
  for PartySide := Low(TPartySide) to High(TPartySide) do
    for Position := Low(TPosition) to High(TPosition) do
    begin
      Inc(R);
      if MouseOver(GetFrameX(Position, PartySide), GetFrameY(Position, PartySide), MX, MY) then
      begin
        Result := R;
        Exit;
      end;
    end;
end;

procedure RenderFrame(const PartySide: TPartySide; const I, AX, AY: Integer);
var
  J: Integer;
begin
  case PartySide of
    psLeft:
      J := I;
  else
    J := I + 6;
  end;
  if (ActivePartyPosition = J) and (CurrentPartyPosition > -1) then
    Surface.Canvas.Draw(AX, AY, ResImage[reActFrame])
  else
    Surface.Canvas.Draw(AX, AY, ResImage[reFrame]);
end;

procedure RenderUnitInfo(Name: string; AX, AY, Level, Experience, HitPoints, MaxHitPoints, Damage, Heal, Armor, Initiative, ChToHit: Integer; IsExp: Boolean);
var
  S: string;
begin
  Surface.Canvas.TextOut(AX + Left + 64, AY + 6, Name);
  S := '';
  if IsExp then
    S := Format(' Опыт %d/%d', [Experience, Party[LeaderPartyIndex].GetMaxExperience(Level)]);
  Surface.Canvas.TextOut(AX + Left + 64, AY + 27, Format('Уровень %d', [Level]));
  Surface.Canvas.TextOut(AX + Left + 64, AY + 48, Format('Здоровье %d/%d', [HitPoints, MaxHitPoints]));
  if Damage > 0 then
    Surface.Canvas.TextOut(AX + Left + 64, AY + 69, Format('Урон %d Броня %d', [Damage, Armor]))
  else
    Surface.Canvas.TextOut(AX + Left + 64, AY + 69, Format('Исцеление %d Броня %d', [Heal, Armor]));
  Surface.Canvas.TextOut(AX + Left + 64, AY + 90, Format('Инициатива %d Точность %d', [Initiative, ChToHit]) + '%');
end;

procedure RenderUnitInfo(Position: TPosition; Party: TParty; AX, AY: Integer);
begin
  with Party.Creature[Position] do
  begin
    if Active then
      RenderUnitInfo(Name, AX, AY, Level, Experience, HitPoints, MaxHitPoints, Damage, Heal, Armor, Initiative, ChancesToHit, True);
  end;
end;

procedure RenderUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum; IsAdv: Boolean = True);
begin
  with GetCharacter(ACreature) do
    RenderUnitInfo(Name, AX, AY, Level, 0, HitPoints, HitPoints, Damage, Heal, Armor, Initiative, ChancesToHit, IsAdv);
end;

procedure RenderUnit(AResEnum: TResEnum; const AX, AY: Integer; F: Boolean);
begin
  if F then
    DrawImage(AX + 7, AY + 7, reBGChar)
  else
    DrawImage(AX + 7, AY + 7, reBGEnemy);
  Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[AResEnum]);
end;

procedure RenderUnit(Position: TPosition; Party: TParty; AX, AY: Integer; CanHire: Boolean = False);
var
  F: Boolean;
begin
  F := Party.Owner = LeaderRace;
  with Party.Creature[Position] do
  begin
    if Active then
    begin
      if HitPoints <= 0 then
        RenderUnit(reDead, AX, AY, F)
      else
        RenderUnit(ResEnum, AX, AY, F);
      RenderUnitInfo(Position, Party, AX, AY);
    end
    else if CanHire then
    begin
      DrawImage(((ResImage[reFrame].Width div 2) - (ResImage[rePlus].Width div 2)) + AX,
        ((ResImage[reFrame].Height div 2) - (ResImage[rePlus].Height div 2)) + AY, rePlus);
    end;
  end;
end;

procedure RenderParty(const PartySide: TPartySide; const Party: TParty; CanHire: Boolean = False);
var
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
  begin
    RenderFrame(PartySide, Position, GetFrameX(Position, PartySide), GetFrameY(Position, PartySide));
    if (Party <> nil) then
      RenderUnit(Position, Party, GetFrameX(Position, PartySide), GetFrameY(Position, PartySide), CanHire);
  end;
end;

end.
