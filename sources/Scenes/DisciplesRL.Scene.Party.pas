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
  private const
    H = 25;
  private
  var
    T, L: Integer;
    P: Boolean;
  private
  class var
    FShowSkills: Boolean;
    FShowInventory: Boolean;
    FShowResources: Boolean;
    procedure MoveCursor(Dir: TDirectionEnum);
    procedure Close;
    procedure OpenInventory;
    procedure OpenSkills;
    procedure Add(S, V: string); overload;
    procedure Add; overload;
    procedure Add(S: string; F: Boolean); overload;
    procedure Add(S: string); overload;
    procedure Add2(S: string);
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
  SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Button,
  DisciplesRL.Skills;

type
  TButtonEnum = (btSkills, btClose, btInventory);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextInventory, reTextClose,
    reTextInventory);

var
  Button: array [TButtonEnum] of TButton;
  CurrentParty: TParty;
  BackScene: TSceneEnum;
  Lf: Integer = 0;

const
  S = 2;

  { TSceneParty }

procedure TSceneParty.Add;
begin
  Inc(T, H);
end;

procedure TSceneParty.Add(S, V: string);
begin
  DrawText(L, T, Format('%s: %s', [S, V]));
  Inc(T, H);
end;

procedure TSceneParty.Add(S: string; F: Boolean);
begin
  DrawText(L, T, S, F);
  Inc(T, H);
end;

procedure TSceneParty.Add(S: string);
begin
  DrawText(L, T, S, False);
  Inc(T, H);
end;

procedure TSceneParty.Add2(S: string);
begin
  DrawText(L + 250, T - (H div 2), S);
end;

class procedure TSceneParty.Show(Party: TParty; CloseScene: TSceneEnum;
  F: Boolean = False);
begin
  CurrentParty := Party;
  BackScene := CloseScene;
  FShowResources := Party = TLeaderParty.Leader;
  if FShowResources then
  begin
    ActivePartyPosition := TLeaderParty.GetPosition;
  end
  else
    ActivePartyPosition := Party.GetRandomPosition;
  Game.Show(scParty);
  Game.MediaPlayer.Play(mmSettlement);
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
  Game.MediaPlayer.Play(mmClick);
  Game.Render;
end;

class function TSceneParty.GetFrameX(const Position: TPosition;
  const PartySide: TPartySide): Integer;
var
  W: Integer;
begin
  W := Game.Width div 4;
  case Position of
    0, 2, 4:
      begin
        case PartySide of
          psLeft:
            Result := (W + Left) - (W - ResImage[reFrame].Width - S);
        else
          Result := Game.Width - (Left + S + (ResImage[reFrame].Width * 2));
        end;
      end;
  else
    begin
      case PartySide of
        psLeft:
          Result := Left;
      else
        Result := Game.Width - ResImage[reFrame].Width - Left;
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

procedure TSceneParty.OpenInventory;
begin
  Game.MediaPlayer.Play(mmClick);
  FShowSkills := False;
  FShowInventory := not FShowInventory;
end;

procedure TSceneParty.OpenSkills;
begin
  Game.MediaPlayer.Play(mmClick);
  FShowInventory := False;
  FShowSkills := not FShowSkills;
end;

procedure TSceneParty.Close;
begin
  if CurrentParty <> Party[TLeaderParty.LeaderPartyIndex] then
    ActivePartyPosition := ActivePartyPosition + 6;
  Game.Show(BackScene);
  Game.MediaPlayer.Play(mmClick);
  Game.MediaPlayer.Play(mmSettlement);
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
      DrawUnitInfo(Name[0], AX, AY, Level, Experience, HitPoints, MaxHitPoints,
        Damage, Heal, Armor, Initiative, ChancesToHit, ShowExp);
  end;
end;

procedure TSceneParty.DrawUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
  IsAdv: Boolean = True);
begin
  with TCreature.Character(ACreature) do
    DrawUnitInfo(Name[0], AX, AY, Level, 0, HitPoints, HitPoints, Damage, Heal,
      Armor, Initiative, ChancesToHit, IsAdv);
end;

procedure TSceneParty.DrawUnit(Position: TPosition; Party: TParty;
  AX, AY: Integer; CanHire: Boolean = False; ShowExp: Boolean = True);
var
  F: Boolean;
  V: TBGStat;
begin
  F := Party.Owner = TSaga.LeaderRace;
  with Party.Creature[Position] do
  begin
    if Active then
      with Game.GetScene(scParty) do
      begin
        if F then
          V := bsCharacter
        else
          V := bsEnemy;
        if Paralyze then
          V := bsParalyze;
        if HitPoints <= 0 then
          DrawUnit(reDead, AX, AY, V)
        else
          DrawUnit(ResEnum, AX, AY, V);
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
    Game.GetScene(scParty).RenderFrame(PartySide, Position,
      TSceneParty.GetFrameX(Position, PartySide),
      TSceneParty.GetFrameY(Position, PartySide));
    if (Party <> nil) then
      TSceneParty(Game.GetScene(scParty)).DrawUnit(Position, Party,
        GetFrameX(Position, PartySide), GetFrameY(Position, PartySide),
        CanHire, ShowExp);
  end;
end;

constructor TSceneParty.Create;
var
  I: TButtonEnum;
  Lt, W: Integer;
begin
  inherited;
  W := ResImage[reButtonDef].Width + 4;
  Lt := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(Lt, DefaultButtonTop, ButtonText[I]);
    Inc(Lt, W);
    if (I = btClose) then
      Button[I].Sellected := True;
  end;
  FShowSkills := False;
  FShowInventory := False;
  Lf := ScrWidth - (ResImage[reFrame].Width) - 2;
  P := True;
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
        if Button[btSkills].MouseDown and FShowResources then
        begin
          OpenSkills;
          Exit;
        end;
        if Button[btClose].MouseDown then
        begin
          Close;
          Exit;
        end;
        if Button[btInventory].MouseDown and FShowResources then
        begin
          OpenInventory;
          Exit;
        end;
        CurrentPartyPosition := GetPartyPosition(X, Y);
        if (CurrentPartyPosition < 0) or (CurrentPartyPosition > 5) then
          Exit;
        ActivePartyPosition := CurrentPartyPosition;
        Game.MediaPlayer.Play(mmClick);
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
var
  C: TCreatureEnum;

  procedure RenderButtons;
  var
    I: TButtonEnum;
  begin
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      if FShowResources or (not FShowResources and (I = btClose)) then
        Button[I].Render;
  end;

  procedure ShowSkills;
  var
    I, Mn, Mx: Integer;
    S: TSkillEnum;
  begin
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reBigFrame);
    L := GetFrameX(0, psRight) + 12;
    T := GetFrameY(0, psRight) + 6;
    Add('Умения Лидера', True);
    if P then
      Add2('Страница 1/2')
    else
      Add2('Страница 2/2');
    Add;
    if P then
    begin
      Mn := 0;
      Mx := 5;
    end
    else
    begin
      Mn := 6;
      Mx := MaxSkills - 1;
    end;
    for I := Mn to Mx do
    begin
      S := TLeaderParty.Leader.Skills.Get(I);
      if S <> skNone then
      begin
        Add(SkillBase[S].Name);
        Add(Format('%s %s', [SkillBase[S].Description[0],
          SkillBase[S].Description[1]]));
      end;
    end;
  end;

  procedure ShowInventory;
  begin
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reBigFrame);
    L := GetFrameX(0, psRight) + 12;
    T := GetFrameY(0, psRight) + 6;
  end;

begin
  inherited;
  DrawImage(reWallpaperLeader);
  DrawTitle(reTitleParty);
  RenderParty(psLeft, CurrentParty);
  if FShowInventory then
    ShowInventory
  else if FShowSkills then
    ShowSkills
  else
  begin
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reInfoFrame);
    C := CurrentParty.Creature[ActivePartyPosition].Enum;
    if (C <> crNone) then
      TSceneHire(Game.GetScene(scHire)).RenderCharacterInfo(C);
  end;
  if FShowResources then
  begin
    DrawResources;
    DrawImage(140, 10, reSmallFrame);
    DrawText(149, 24, Format('Скорость %d/%d', [TLeaderParty.Leader.Speed,
      TLeaderParty.Leader.MaxSpeed]));
    DrawText(149, 54, Format('Обзор %d', [TLeaderParty.Leader.Radius]));
    DrawText(149, 84, Format('Лидерство %d',
      [TLeaderParty.Leader.MaxLeadership]));
  end;
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
      if FShowResources then
        OpenInventory;
    K_S:
      if FShowResources then
        OpenSkills;
    K_LEFT, K_KP_4, K_A:
      if FShowSkills then
        P := True
      else
        MoveCursor(drWest);
    K_RIGHT, K_KP_6, K_D:
      if FShowSkills then
        P := False
      else
        MoveCursor(drEast);
    K_UP, K_KP_8, K_W:
      if FShowSkills then
        Exit
      else
        MoveCursor(drNorth);
    K_DOWN, K_KP_2, K_X:
      if FShowSkills then
        Exit
      else
        MoveCursor(drSouth);
  end;
end;

end.
