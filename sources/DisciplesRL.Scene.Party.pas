unit DisciplesRL.Scene.Party;

interface

uses
  DisciplesRL.Party,
  DisciplesRL.Resources,
  DisciplesRL.Creatures;

const
  Top = 220;
  Left = 10;

type
  TPartySide = (psLeft, psRight);

procedure Init;
procedure Render;
procedure Free;
function GetFrameX(const Position: TPosition; const PartySide: TPartySide): Integer;
function GetFrameY(const Position: TPosition; const PartySide: TPartySide): Integer;
function MouseOver(AX, AY, MX, MY: Integer): Boolean;
function GetPartyPosition(const MX, MY: Integer): Integer;
procedure RenderParty(const PartySide: TPartySide; const Party: TParty; CanHire: Boolean = False);
procedure RenderUnitInfo(Name: string; AX, AY, Level, HitPoints, MaxHitPoints, Damage, Heal, Armor: Integer); overload;
procedure RenderUnitInfo(Position: TPosition; Party: TParty; AX, AY: Integer); overload;
procedure RenderUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum); overload;
procedure RenderUnit(AResEnum: TResEnum; const AX, AY: Integer; F: Boolean); overload;
procedure RenderUnit(Position: TPosition; Party: TParty; AX, AY: Integer; CanHire: Boolean = False); overload;

var
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  DisciplesRL.Scenes,
  DisciplesRL.Game,
  DisciplesRL.Leader;

const
  S = 2;

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
          psRight:
            Result := Surface.Width - (Left + S + (ResImage[reFrame].Width * 2));
        end;
      end;
    1, 3, 5:
      begin
        case PartySide of
          psLeft:
            Result := Left;
          psRight:
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
    4, 5:
      Result := Top + ((ResImage[reFrame].Height + S) * 2);
  end;
end;

procedure Init;
begin

end;

procedure Render;
begin

end;

procedure Free;
begin

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
  if (ActivePartyPosition = J) then
    Surface.Canvas.Draw(AX, AY, ResImage[reActFrame])
  else
    Surface.Canvas.Draw(AX, AY, ResImage[reFrame]);
end;

procedure RenderUnitInfo(Name: string; AX, AY, Level, HitPoints, MaxHitPoints, Damage, Heal, Armor: Integer);
begin
  Surface.Canvas.TextOut(AX + Left + 64, AY + 6, Format('%s (Level %d)', [Name, Level]));
  Surface.Canvas.TextOut(AX + Left + 64, AY + 40 + 2, Format('HP %d/%d', [HitPoints, MaxHitPoints]));
  if Damage > 0 then
    Surface.Canvas.TextOut(AX + Left + 64, AY + 80 - 2, Format('Damage %d Armor %d', [Damage, Armor]))
  else
    Surface.Canvas.TextOut(AX + Left + 64, AY + 80 - 2, Format('Heal %d Armor %d', [Heal, Armor]));
end;

procedure RenderUnitInfo(Position: TPosition; Party: TParty; AX, AY: Integer);
begin
  with Party.Creature[Position] do
  begin
    if Active then
      RenderUnitInfo(Name, AX, AY, Level, HitPoints, MaxHitPoints, Damage, Heal, Armor);
  end;
end;

procedure RenderUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum);
begin
  with GetCharacter(ACreature) do
    RenderUnitInfo(Name, AX, AY, Level, HitPoints, HitPoints, Damage, Heal, Armor);
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
  F := Party.Owner = Leader.Race;
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
