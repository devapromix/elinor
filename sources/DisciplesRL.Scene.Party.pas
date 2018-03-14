unit DisciplesRL.Scene.Party;

interface

uses DisciplesRL.Party, DisciplesRL.Resources;

type
  TPartySide = (psLeft, psRight);

function GetPartyPosition(const MX, MY: Integer): Integer;
procedure RenderParty(const V: TPartySide; const Party: TParty);
procedure DisplayUnit(AResEnum: TResEnum; const AX, AY: Integer);

var
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

implementation

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Creatures;

const
  Top = 220;
  Left = 15;

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
    Surface.Canvas.Draw(AX + 6, AY, ResImage[reActFrame])
  else
    Surface.Canvas.Draw(AX + 6, AY, ResImage[reFrame]);
end;

procedure DisplayUnit(AResEnum: TResEnum; const AX, AY: Integer);
begin
  Surface.Canvas.Draw(AX, AY, ResImage[AResEnum]);
end;

procedure RenderUnit(I: Integer; Party: TParty; AX, AY: Integer);
begin
  with Party.Creature[I] do
  begin
    if Active then
    begin
      DisplayUnit(ResEnum, AX + Left - 2, AY + 7);

      Surface.Canvas.TextOut(AX + Left + 64, AY + 6, Format('[%d] %s (Level %d)', [I, Name, Level]));
      Surface.Canvas.TextOut(AX + Left + 64, AY + 40 + 2, Format('HP %d/%d', [HitPoints, MaxHitPoints]));
      Surface.Canvas.TextOut(AX + Left + 64, AY + 80 - 2, Format('Value %d Armor %d', [Value, Armor]));
    end;
  end;
end;

procedure RenderParty(const V: TPartySide; const Party: TParty);
var
  I, X, Y, X4: Integer;
  F: Boolean;
begin
  X4 := Surface.Width div 4;
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
    RenderFrame(V, I, X, Y);
    if (Party <> nil) then
      RenderUnit(I, Party, X, Y);
    if F then
    begin
      F := False;
      Inc(Y, 120);
    end;
  end;
end;

end.
