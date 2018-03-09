unit DisciplesRL.Scene.Party;

interface

uses DisciplesRL.Party;

type
  TPartySide = (psLeft, psRight);

procedure RenderParty(const V: TPartySide; const Party: TParty);

implementation

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Creatures, DisciplesRL.Resources;

const
  Top = 220;
  Left = 10;

procedure RenderFrame(const AX, AY: Integer);
begin
  Surface.Canvas.Draw(AX + 6, AY, ResImage[reFrame]);
end;

procedure RenderUnit(I: Integer; Party: TParty; AX, AY: Integer);
begin
  with Party.Creature[I] do
  begin
    if Active then
    begin
      Surface.Canvas.TextOut(AX + 15, AY + 6, Format('[%d] %s (Level %d)', [I, Name, Level]));
      Surface.Canvas.TextOut(AX + 15, AY + 40 + 2, Format('HP %d/%d', [HitPoints, MaxHitPoints]));
      Surface.Canvas.TextOut(AX + 15, AY + 80 - 2, Format('Damage %d Armor %d', [Damage, Armor]));
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
    RenderFrame(X, Y);
    if Party <> nil then
      RenderUnit(I, Party, X, Y);
    if F then
    begin
      F := False;
      Inc(Y, 120);
    end;
  end;
end;

end.
