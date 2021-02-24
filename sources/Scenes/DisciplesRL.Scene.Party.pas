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

type
  TSceneParty = class(TScene)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

function GetRandomActivePartyPosition(Party: TParty): TPosition;
procedure Show(Party: TParty; CloseScene: TSceneEnum; F: Boolean = False);
function GetFrameX(const Position: TPosition;
  const PartySide: TPartySide): Integer;
function GetFrameY(const Position: TPosition;
  const PartySide: TPartySide): Integer;
function MouseOver(AX, AY, MX, MY: Integer): Boolean;
function GetPartyPosition(const MX, MY: Integer): Integer;
procedure RenderParty(const PartySide: TPartySide; const Party: TParty;
  CanHire: Boolean = False; ShowExp: Boolean = True);
procedure RenderUnitInfo(Name: string; AX, AY, Level, Experience, HitPoints,
  MaxHitPoints, Damage, Heal, Armor, Initiative, ChToHit: Integer;
  IsExp: Boolean); overload;
procedure RenderUnitInfo(Position: TPosition; Party: TParty; AX, AY: Integer;
  ShowExp: Boolean = True); overload;
procedure RenderUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
  IsAdv: Boolean = True); overload;
procedure RenderUnit(AResEnum: TResEnum; const AX, AY: Integer;
  F: Boolean); overload;
procedure RenderUnit(Position: TPosition; Party: TParty; AX, AY: Integer;
  CanHire: Boolean = False; ShowExp: Boolean = True); overload;

var
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

implementation

uses
  Math,
  System.SysUtils,
  System.TypInfo,
  DisciplesRL.Saga,
  DisciplesRL.GUI.Button,
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
  ShowInventory: Boolean = False;
  Lf: Integer = 0;

const
  S = 2;

procedure Show(Party: TParty; CloseScene: TSceneEnum; F: Boolean = False);
begin
  CurrentParty := Party;
  BackScene := CloseScene;
  ActivePartyPosition := GetRandomActivePartyPosition(CurrentParty);
  Scenes.SetScene(scParty);
  MediaPlayer.Play(mmSettlement);
  ShowInventory := F;
end;

procedure MoveCursor(Dir: TDirectionEnum);
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

function GetRandomActivePartyPosition(Party: TParty): TPosition;
var
  I: TPosition;
begin
  repeat
    I := RandomRange(Low(TPosition), High(TPosition) + 1);
  until Party.GetHitPoints(I) > 0;
  Result := I;
end;

function GetFrameX(const Position: TPosition;
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

function GetFrameY(const Position: TPosition;
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

procedure Inventory;
begin
  MediaPlayer.Play(mmClick);
  ShowInventory := not ShowInventory;
end;

procedure Close;
begin
  if CurrentParty <> Party[TLeaderParty.LeaderPartyIndex] then
    ActivePartyPosition := ActivePartyPosition + 6;
  Scenes.SetScene(BackScene);
  MediaPlayer.Play(mmClick);
  MediaPlayer.Play(mmSettlement);
end;

function MouseOver(AX, AY, MX, MY: Integer): Boolean;
begin
  Result := (MX > AX) and (MX < AX + ResImage[reFrame].Width) and (MY > AY) and
    (MY < AY + ResImage[reFrame].Height);
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
      if MouseOver(GetFrameX(Position, PartySide),
        GetFrameY(Position, PartySide), MX, MY) then
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

procedure RenderUnitInfo(Name: string; AX, AY, Level, Experience, HitPoints,
  MaxHitPoints, Damage, Heal, Armor, Initiative, ChToHit: Integer;
  IsExp: Boolean);
var
  S: string;
begin
  LeftTextOut(AX + Left + 64, AY + 6, Name);
  S := '';
  if IsExp then
    S := Format(' Опыт %d/%d', [Experience, Party[TLeaderParty.LeaderPartyIndex]
      .GetMaxExperience(Level)]);
  LeftTextOut(AX + Left + 64, AY + 27, Format('Уровень %d', [Level]) + S);
  LeftTextOut(AX + Left + 64, AY + 48, Format('Здоровье %d/%d',
    [HitPoints, MaxHitPoints]));
  if Damage > 0 then
    LeftTextOut(AX + Left + 64, AY + 69, Format('Урон %d Броня %d',
      [Damage, Armor]))
  else
    LeftTextOut(AX + Left + 64, AY + 69, Format('Исцеление %d Броня %d',
      [Heal, Armor]));
  LeftTextOut(AX + Left + 64, AY + 90, Format('Инициатива %d Точность %d',
    [Initiative, ChToHit]) + '%');
end;

procedure RenderUnitInfo(Position: TPosition; Party: TParty; AX, AY: Integer;
  ShowExp: Boolean = True);
begin
  with Party.Creature[Position] do
  begin
    if Active then
      RenderUnitInfo(Name, AX, AY, Level, Experience, HitPoints, MaxHitPoints,
        Damage, Heal, Armor, Initiative, ChancesToHit, ShowExp);
  end;
end;

procedure RenderUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
  IsAdv: Boolean = True);
begin
  with TCreature.Character(ACreature) do
    RenderUnitInfo(Name, AX, AY, Level, 0, HitPoints, HitPoints, Damage, Heal,
      Armor, Initiative, ChancesToHit, IsAdv);
end;

procedure RenderUnit(AResEnum: TResEnum; const AX, AY: Integer; F: Boolean);
begin
  if F then
    DrawImage(AX + 7, AY + 7, reBGChar)
  else
    DrawImage(AX + 7, AY + 7, reBGEnemy);
  Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[AResEnum]);
end;

procedure RenderUnit(Position: TPosition; Party: TParty; AX, AY: Integer;
  CanHire: Boolean = False; ShowExp: Boolean = True);
var
  F: Boolean;
begin
  F := Party.Owner = TSaga.LeaderRace;
  with Party.Creature[Position] do
  begin
    if Active then
    begin
      if HitPoints <= 0 then
        RenderUnit(reDead, AX, AY, F)
      else
        RenderUnit(ResEnum, AX, AY, F);
      RenderUnitInfo(Position, Party, AX, AY, ShowExp);
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

procedure RenderParty(const PartySide: TPartySide; const Party: TParty;
  CanHire: Boolean = False; ShowExp: Boolean = True);
var
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
  begin
    RenderFrame(PartySide, Position, GetFrameX(Position, PartySide),
      GetFrameY(Position, PartySide));
    if (Party <> nil) then
      RenderUnit(Position, Party, GetFrameX(Position, PartySide),
        GetFrameY(Position, PartySide), CanHire, ShowExp);
  end;
end;

{ TSceneParty }

procedure TSceneParty.Click;
begin
  inherited;
  if Button[btClose].MouseDown then
    Close;
  if Button[btInventory].MouseDown then
    Inventory;
end;

constructor TSceneParty.Create;
var
  I: TButtonEnum;
  L, W: Integer;
begin
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, DefaultButtonTop, Surface.Canvas,
      ButtonText[I]);
    Inc(L, W);
    if (I = btClose) then
      Button[I].Sellected := True;
  end;
  ShowInventory := False;
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

procedure TSceneParty.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case Button of
    mbLeft:
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
    LeftTextOut(L, T, S);
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
  if ShowInventory then
  begin
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reBigFrame);

  end
  else
  begin
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reInfoFrame);
    C := CurrentParty.Creature[ActivePartyPosition].Enum;
    if (C <> crNone) then
      RenderCharacterInfo(C);
  end;
  RenderResources;
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
