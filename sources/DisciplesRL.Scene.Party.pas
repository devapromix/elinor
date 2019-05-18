unit DisciplesRL.Scene.Party;

interface

uses
  System.Types,
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
//function GetFrameXY(const Position: TPosition; const PartySide: TPartySide): Integer;
function MouseOver(AX, AY, MX, MY: Integer): Boolean;
function GetPartyPosition(const MX, MY: Integer): Integer;
procedure RenderParty(const V: TPartySide; const Party: TParty; CanHire: Boolean = False);
procedure RenderUnitInfo(Name: string; AX, AY, Level, HitPoints, MaxHitPoints, Damage, Heal, Armor: Integer); overload;
procedure RenderUnitInfo(I: TPosition; Party: TParty; AX, AY: Integer); overload;
procedure RenderUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum); overload;
procedure RenderUnit(AResEnum: TResEnum; const AX, AY: Integer; F: Boolean); overload;
procedure RenderUnit(I: Integer; Party: TParty; AX, AY: Integer; CanHire: Boolean = False); overload;

var
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  DisciplesRL.Scenes,
  DisciplesRL.Game,
  DisciplesRL.Leader,
  DisciplesRL.GUI.Frame;

var
  LeftFrame, RightFrame: array [TPosition] of TFrame;

procedure Init;
var
  X, Y, Position, W: Integer;
  F: Boolean;
  PartySide: TPartySide;
const
  S = 2;
begin
  W := Surface.Width div 4;
  for PartySide := Low(TPartySide) to High(TPartySide) do
  begin
    X := Left;
    Y := Top;
    F := False;
    for Position := Low(TPosition) to High(TPosition) do
    begin
      case Position of
        0, 2, 4:
          begin
            case PartySide of
              psLeft:
                X := (W + Left) - (W - TFrame.Width - S);
              psRight:
                X := Surface.Width - (Left + S + (TFrame.Width * 2));
            end;
          end;
        1, 3, 5:
          begin
            case PartySide of
              psLeft:
                X := Left;
              psRight:
                X := Surface.Width - TFrame.Width - Left;
            end;
            F := True;
          end;
      end;
      case PartySide of
        psLeft:
          LeftFrame[Position] := TFrame.Create(X, Y, Position, Surface.Canvas);
        psRight:
          RightFrame[Position] := TFrame.Create(X, Y, Position, Surface.Canvas);
      end;
      if F then
      begin
        F := False;
        Inc(Y, TFrame.Height + S);
      end;
    end;
  end;
end;

procedure Render;
var
  I: Integer;
begin
  for I := Low(TPosition) to High(TPosition) do
  begin
    LeftFrame[I].Render;
    RightFrame[I].Render;
  end;
end;

procedure Free;
var
  I: Integer;
begin
  for I := Low(TPosition) to High(TPosition) do
  begin
    FreeAndNil(LeftFrame[I]);
    FreeAndNil(RightFrame[I]);
  end;
end;

function MouseOver(AX, AY, MX, MY: Integer): Boolean;
begin
  Result := (MX > AX) and (MX < AX + ResImage[reFrame].Width) and (MY > AY) and (MY < AY + ResImage[reFrame].Height);
end;

function GetPartyPosition(const MX, MY: Integer): Integer;
var
  I, X, Y, X4: Integer;
  F: Boolean;
begin
  Result := -1;
  X4 := Surface.Width div 4;

  if MouseOver(Left + X4, Top, MX, MY) then
    Result := 0;
  if MouseOver(Left, Top, MX, MY) then
    Result := 1;

  if MouseOver(Left + X4, Top + 120, MX, MY) then
    Result := 2;
  if MouseOver(Left, Top + 120, MX, MY) then
    Result := 3;

  if MouseOver(Left + X4, Top + 240, MX, MY) then
    Result := 4;
  if MouseOver(Left, Top + 240, MX, MY) then
    Result := 5;

  if MouseOver(Left + (X4 * 3), Top, MX, MY) then
    Result := 7;
  if MouseOver(Left + (X4 * 2), Top, MX, MY) then
    Result := 6;

  if MouseOver(Left + (X4 * 3), Top + 120, MX, MY) then
    Result := 9;
  if MouseOver(Left + (X4 * 2), Top + 120, MX, MY) then
    Result := 8;

  if MouseOver(Left + (X4 * 3), Top + 240, MX, MY) then
    Result := 11;
  if MouseOver(Left + (X4 * 2), Top + 240, MX, MY) then
    Result := 10;
end;

procedure RenderFrame(const V: TPartySide; const I, AX, AY: Integer);
var
  J: Integer;
begin
  case V of
    psLeft:
      J := I;
  else
    J := I + 6;
  end;
  if (ActivePartyPosition = J) then
    Surface.Canvas.Draw(Left + AX, AY, ResImage[reActFrame])
  else
    Surface.Canvas.Draw(Left + AX, AY, ResImage[reFrame]);
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

procedure RenderUnitInfo(I: TPosition; Party: TParty; AX, AY: Integer);
begin
  with Party.Creature[I] do
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
  case F of
    True:
      DrawImage(AX + 7, AY + 7, reBGChar);
    False:
      DrawImage(AX + 7, AY + 7, reBGEnemy);
  end;
  Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[AResEnum]);
end;

procedure RenderUnit(I: Integer; Party: TParty; AX, AY: Integer; CanHire: Boolean = False);
var
  F: Boolean;
begin
  F := Party.Owner = Leader.Race;
  with Party.Creature[I] do
  begin
    if Active then
    begin
      if HitPoints <= 0 then
        RenderUnit(reDead, AX, AY, F)
      else
        RenderUnit(ResEnum, AX, AY, F);
      RenderUnitInfo(I, Party, AX, AY);
    end
    else if CanHire then
    begin
      DrawImage(AX + 7, AY + 7, rePlus);
    end;
  end;
end;

procedure RenderParty(const V: TPartySide; const Party: TParty; CanHire: Boolean = False);
var
  X, Y, X4: Integer;
  I: TPosition;
  F: Boolean;
begin
  X4 := Surface.Width div 4;
  X := 0;
  Y := Top;
  F := False;
  for I := 0 to 5 do
  begin
    case I of
      0, 2, 4:
        begin
          case V of
            psLeft:
              X := X4;
            psRight:
              X := X4 * 2;
          end;
        end;
      1, 3, 5:
        begin
          case V of
            psLeft:
              X := 0;
            psRight:
              X := X4 * 3;
          end;
          F := True;
        end;
    end;
  DisciplesRL.Scene.Party.Render;
    //RenderFrame(V, I, X, Y);
    if (Party <> nil) then
      RenderUnit(I, Party, Left + X, Y, CanHire);
    if F then
    begin
      F := False;
      Inc(Y, 120);
    end;
  end;
end;

end.
