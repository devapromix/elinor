unit DisciplesRL.Scene.Party;

interface

uses
  {$IFDEF FPC}
  Controls,
  {$ELSE}
  Vcl.Controls,
  {$ENDIF}
  Classes,
  DisciplesRL.Party,
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.Creatures;

type
  TSceneParty = class(TScene)
  private
  class var
    FShowInventory: Boolean;
    FShowResources: Boolean;
    procedure MoveCursor(Dir: TDirectionEnum);
    procedure Close;
    procedure Inventory;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DrawUnit(Position: TPosition; Party: TParty; AX, AY: Integer;
      CanHire: Boolean = False; ShowExp: Boolean = True); overload;
    class procedure RenderParty(const PartySide: TPartySide;
      const Party: TParty; CanHire: Boolean = False; ShowExp: Boolean = True);
    class function GetFrameY(const Position: TPosition;
      const PartySide: TPartySide): Integer;
    class function GetFrameX(const Position: TPosition;
      const PartySide: TPartySide): Integer;
    class procedure Show(Party: TParty; CloseScene: TSceneEnum;
      F: Boolean = False); overload;
    procedure DrawUnitInfo(Name: string; AX, AY, Level, Experience, HitPoints,
      MaxHitPoints, Damage, Heal, Armor, Initiative, ChToHit: Integer;
      IsExp: Boolean); overload;
    procedure DrawUnitInfo(Position: TPosition; Party: TParty; AX, AY: Integer;
      ShowExp: Boolean = True); overload;
    procedure DrawUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
      IsAdv: Boolean = True); overload;
  end;

var
  SelectPartyPosition: Integer = -1;
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.Button,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Map,
  DisciplesRL.Scene.Map;

type
  TButtonEnum = (btClose, btInventory);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextClose, reTextInventory);

var
  Button: array [TButtonEnum] of TButton;
  CurrentParty: TParty;
  BackScene: TSceneEnum;
  Lf: Integer = 0;

const
  S = 2;

class procedure TSceneParty.Show(Party: TParty; CloseScene: TSceneEnum;
  F: Boolean = False);
begin
  CurrentParty := Party;
  BackScene := CloseScene;
  FShowResources := Party = TLeaderParty.Leader;
  if FShowResources then
    ActivePartyPosition := TLeaderParty.GetPosition
  else
    ActivePartyPosition := Party.GetRandomPosition;
  Scenes.Show(scParty);
  MediaPlayer.Play(mmSettlement);
  FShowInventory := F;
end;

procedure TSceneParty.MoveCursor(Dir: TDirectionEnum);
begin
  case Dir of
    drWest, drEast:
      case ActivePartyPosition of
        0, 2, 4:
          Inc(ActivePartyPosition);
        1, 3, 5:
          Dec(ActivePartyPosition);
      end;
    drNorth:
      case ActivePartyPosition of
        0, 1:
          Inc(ActivePartyPosition, 4);
        2 .. 5:
          Dec(ActivePartyPosition, 2);
      end;
    drSouth:
      case ActivePartyPosition of
        0 .. 3:
          Inc(ActivePartyPosition, 2);
        4, 5:
          Dec(ActivePartyPosition, 4);
      end;
  end;
  MediaPlayer.Play(mmClick);
  Scenes.Render;
end;

class function TSceneParty.GetFrameX(const Position: TPosition;
  const PartySide: TPartySide): Integer;
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

class function TSceneParty.GetFrameY(const Position: TPosition;
  const PartySide: TPartySide): Integer;
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

procedure TSceneParty.Inventory;
begin
  MediaPlayer.Play(mmClick);
  FShowInventory := not FShowInventory;
end;

procedure TSceneParty.Close;
begin
  if CurrentParty <> Party[TLeaderParty.LeaderPartyIndex] then
    ActivePartyPosition := ActivePartyPosition + 6;
  Scenes.Show(BackScene);
  MediaPlayer.Play(mmClick);
  MediaPlayer.Play(mmSettlement);
end;

procedure TSceneParty.DrawUnitInfo(Name: string;
  AX, AY, Level, Experience, HitPoints, MaxHitPoints, Damage, Heal, Armor,
  Initiative, ChToHit: Integer; IsExp: Boolean);
var
  S: string;
begin
  DrawText(AX + Left + 64, AY + 6, Name);
  S := '';
  if IsExp then
    S := Format(' Опыт %d/%d', [Experience, Party[TLeaderParty.LeaderPartyIndex]
      .GetMaxExperiencePerLevel(Level)]);
  DrawText(AX + Left + 64, AY + 27, Format('Уровень %d', [Level]) + S);
  DrawText(AX + Left + 64, AY + 48, Format('Здоровье %d/%d',
    [HitPoints, MaxHitPoints]));
  if Damage > 0 then
    DrawText(AX + Left + 64, AY + 69, Format('Урон %d Броня %d',
      [Damage, Armor]))
  else
    DrawText(AX + Left + 64, AY + 69, Format('Исцеление %d Броня %d',
      [Heal, Armor]));
  DrawText(AX + Left + 64, AY + 90, Format('Инициатива %d Точность %d',
    [Initiative, ChToHit]) + '%');
end;

procedure TSceneParty.DrawUnitInfo(Position: TPosition; Party: TParty;
  AX, AY: Integer; ShowExp: Boolean = True);
begin
  with Party.Creature[Position] do
  begin
    if Active then
      DrawUnitInfo(Name, AX, AY, Level, Experience, HitPoints, MaxHitPoints,
        Damage, Heal, Armor, Initiative, ChancesToHit, ShowExp);
  end;
end;

procedure TSceneParty.DrawUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
  IsAdv: Boolean = True);
begin
  with TCreature.Character(ACreature) do
    DrawUnitInfo(Name, AX, AY, Level, 0, HitPoints, HitPoints, Damage, Heal,
      Armor, Initiative, ChancesToHit, IsAdv);
end;

procedure TSceneParty.DrawUnit(Position: TPosition; Party: TParty;
  AX, AY: Integer; CanHire: Boolean = False; ShowExp: Boolean = True);
var
  F: Boolean;
begin
  F := Party.Owner = TSaga.LeaderRace;
  with Party.Creature[Position] do
  begin
    if Active then
      with Scenes.GetScene(scParty) do
      begin
        if HitPoints <= 0 then
          DrawUnit(reDead, AX, AY, F)
        else
          DrawUnit(ResEnum, AX, AY, F);
        DrawUnitInfo(Position, Party, AX, AY, ShowExp);
      end
    else if CanHire then
    begin
      DrawImage(((ResImage[reFrame].Width div 2) -
        (ResImage[rePlus].Width div 2)) + AX,
        ((ResImage[reFrame].Height div 2) - (ResImage[rePlus].Height div 2)) +
        AY, rePlus);
    end;
  end;
end;

class procedure TSceneParty.RenderParty(const PartySide: TPartySide;
  const Party: TParty; CanHire: Boolean = False; ShowExp: Boolean = True);
var
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
  begin
    Scenes.GetScene(scParty).RenderFrame(PartySide, Position,
      TSceneParty.GetFrameX(Position, PartySide),
      TSceneParty.GetFrameY(Position, PartySide));
    if (Party <> nil) then
      TSceneParty(Scenes.GetScene(scParty)).DrawUnit(Position, Party,
        GetFrameX(Position, PartySide), GetFrameY(Position, PartySide),
        CanHire, ShowExp);
  end;
end;

{ TSceneParty }

constructor TSceneParty.Create;
var
  I: TButtonEnum;
  L, W: Integer;
begin
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, DefaultButtonTop, ButtonText[I]);
    Inc(L, W);
    if (I = btClose) then
      Button[I].Sellected := True;
  end;
  FShowInventory := False;
  Lf := (Surface.Width div 2) - (ResImage[reFrame].Width) - 2;
end;

destructor TSceneParty.Destroy;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
  inherited;
end;

procedure TSceneParty.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btClose].MouseDown then
          Close else
        if Button[btInventory].MouseDown then
           Inventory else
        begin
          CurrentPartyPosition := GetPartyPosition(X, Y);
          if (CurrentPartyPosition < 0) or (CurrentPartyPosition > 5) then
            Exit;
          ActivePartyPosition := CurrentPartyPosition;
          MediaPlayer.Play(mmClick);
          Render;
        end;
      end;
  end;
end;

procedure TSceneParty.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure TSceneParty.Render;
const
  H = 25;
var
  C: TCreatureEnum;
  L, T, J: Integer;

  procedure RenderButtons;
  var
    I: TButtonEnum;
  begin
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      Button[I].Render;
  end;

  procedure Add(S: string; F: Boolean = False); overload;
  var
    N: Integer;
  begin
    if F then
    begin
      N := Surface.Canvas.Font.Size;
      Surface.Canvas.Font.Size := N * 2;
    end;
    DrawText(L, T, S);
    if F then
      Surface.Canvas.Font.Size := N;
    Inc(T, H);
  end;

begin
  inherited;
  T := Top + 6;
  L := Lf + ResImage[reActFrame].Width + 12;
  DrawImage(reWallpaperLeader);
  DrawTitle(reTitleParty);
  RenderParty(psLeft, CurrentParty);
  if FShowInventory then
  begin
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reBigFrame);

  end
  else
  begin
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reInfoFrame);
    C := CurrentParty.Creature[ActivePartyPosition].Enum;
    if (C <> crNone) then
      TSceneHire(Scenes.GetScene(scHire)).RenderCharacterInfo(C);
  end;
  if FShowResources then
    DrawResources;
  RenderButtons;
end;

procedure TSceneParty.Timer;
begin
  inherited;

end;

procedure TSceneParty.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      Close;
    K_I:
      Inventory;
    K_LEFT, K_KP_4, K_A:
      MoveCursor(drWest);
    K_RIGHT, K_KP_6, K_D:
      MoveCursor(drEast);
    K_UP, K_KP_8, K_W:
      MoveCursor(drNorth);
    K_DOWN, K_KP_2, K_X:
      MoveCursor(drSouth);
  end;
end;

end.
