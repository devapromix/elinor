﻿unit DisciplesRL.Scene.Party;

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
  Elinor.Resources,
  DisciplesRL.Creatures;

type
  TSceneParty = class(TScene)
  private
  var
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
  private
    EquipmentSelItemIndex: Integer;
    InventorySelItemIndex: Integer;
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
      F: Boolean = False; H: Boolean = False); overload;
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
  SysUtils, dialogs,
  Elinor.Saga,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Button,
  DisciplesRL.Items;

type
  TButtonEnum = (btSkills, btClose, btInventory);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextAbilities, reTextClose,
    reTextInventory);

var
  Button: array [TButtonEnum] of TButton;
  CurrentParty: TParty;
  BackScene: TSceneEnum;
  Lf: Integer = 0;

const
  S = 2;

  { TSceneParty }

class procedure TSceneParty.Show(Party: TParty; CloseScene: TSceneEnum;
  F: Boolean = False; H: Boolean = False);
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
  Game.Player.PlaySound(mmSettlement);
  FShowInventory := F;
  FShowSkills := False;
  if H then
  begin
    FShowInventory := False;
    FShowSkills := True;
  end;
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
  Game.Player.PlaySound(mmClick);
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
            Result := (W + SceneLeft) - (W - ResImage[reFrame].Width - S);
        else
          Result := Game.Width -
            (SceneLeft + S + (ResImage[reFrame].Width * 2));
        end;
      end;
  else
    begin
      case PartySide of
        psLeft:
          Result := SceneLeft;
      else
        Result := Game.Width - ResImage[reFrame].Width - SceneLeft;
      end;
    end;
  end;
end;

class function TSceneParty.GetFrameY(const Position: TPosition;
  const PartySide: TPartySide): Integer;
begin
  case Position of
    0, 1:
      Result := SceneTop;
    2, 3:
      Result := SceneTop + ResImage[reFrame].Height + S;
  else
    Result := SceneTop + ((ResImage[reFrame].Height + S) * 2);
  end;
end;

procedure TSceneParty.OpenInventory;
begin
  Game.Player.PlaySound(mmClick);
  FShowSkills := False;
  FShowInventory := not FShowInventory;
  ActivePartyPosition := TLeaderParty.GetPosition;
end;

procedure TSceneParty.OpenSkills;
begin
  Game.Player.PlaySound(mmClick);
  FShowInventory := False;
  FShowSkills := not FShowSkills;
  ActivePartyPosition := TLeaderParty.GetPosition;
end;

procedure TSceneParty.Close;
begin
  if CurrentParty <> Party[TLeaderParty.LeaderPartyIndex] then
    ActivePartyPosition := ActivePartyPosition + 6;
  Game.Show(BackScene);
  Game.Player.PlaySound(mmClick);
  Game.Player.PlaySound(mmSettlement);
end;

procedure TSceneParty.DrawUnitInfo(Name: string;
  AX, AY, Level, Experience, HitPoints, MaxHitPoints, Damage, Heal, Armor,
  Initiative, ChToHit: Integer; IsExp: Boolean);
var
  S: string;
begin
  DrawText(AX + SceneLeft + 64, AY + 6, Name);
  S := '';
  if IsExp then
    S := Format(' Опыт %d/%d', [Experience, Party[TLeaderParty.LeaderPartyIndex]
      .GetMaxExperiencePerLevel(Level)]);
  DrawText(AX + SceneLeft + 64, AY + 27, Format('Уровень %d', [Level]) + S);
  DrawText(AX + SceneLeft + 64, AY + 48, Format('Здоровье %d/%d',
    [HitPoints, MaxHitPoints]));
  if Damage > 0 then
    DrawText(AX + SceneLeft + 64, AY + 69, Format('Урон %d Броня %d',
      [Damage, Armor]))
  else
    DrawText(AX + SceneLeft + 64, AY + 69, Format('Исцеление %d Броня %d',
      [Heal, Armor]));
  DrawText(AX + SceneLeft + 64, AY + 90, Format('Инициатива %d Точность %d',
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
          DrawUnit(reDead, AX, AY, V, 0, MaxHitPoints)
        else
          DrawUnit(ResEnum, AX, AY, V, HitPoints, MaxHitPoints);
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
      TSceneParty.GetFrameY(Position, PartySide), FShowInventory or
      FShowSkills);
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
  EquipmentSelItemIndex := -1;
  InventorySelItemIndex := -1;
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
        if FShowInventory and (EquipmentSelItemIndex > -1) then
        begin
          TLeaderParty.Leader.UnEquip(EquipmentSelItemIndex);
        end;
        if FShowInventory and (InventorySelItemIndex > -1) then
        begin
          TLeaderParty.Leader.Equip(InventorySelItemIndex);
        end;
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
        if FShowInventory or FShowSkills then
          Exit;
        ActivePartyPosition := CurrentPartyPosition;
        Game.Player.PlaySound(mmClick);
        Render;
      end;
  end;
end;

procedure TSceneParty.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  if FShowInventory and MouseOver(X, Y, GetFrameX(0, psRight) + 8,
    GetFrameY(0, psRight) + 48, 320, TextLineHeight * 12) then
    EquipmentSelItemIndex := (Y - (GetFrameY(0, psRight) + 48))
      div TextLineHeight
  else
    EquipmentSelItemIndex := -1;
  if FShowInventory and MouseOver(X, Y, GetFrameX(0, psRight) + 328,
    GetFrameY(0, psRight) + 48, 320, TextLineHeight * 12) then
    InventorySelItemIndex := (Y - (GetFrameY(0, psRight) + 48))
      div TextLineHeight
  else
    InventorySelItemIndex := -1;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure TSceneParty.Render;
var
  C, CurCrEnum: TCreatureEnum;

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
    DrawTitle(reTitleAbilities);
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reBigFrame);
    TextLeft := 250 + GetFrameX(0, psRight) + 12;
    TextTop := GetFrameY(0, psRight) + 6 + (TextLineHeight div 2);
    if P then
      AddTextLine('Страница 1/2')
    else
      AddTextLine('Страница 2/2');
    TextLeft := GetFrameX(0, psRight) + 12;
    TextTop := GetFrameY(0, psRight) + 6;
    AddTextLine('Умения Лидера', True);
    AddTextLine;
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
        AddTextLine(TSkills.Ability(S).Name);
        AddTextLine(Format('%s %s', [TSkills.Ability(S).Description[0],
          TSkills.Ability(S).Description[1]]));
      end;
    end;
  end;

  procedure ShowInventory;
  var
    I: Integer;
  begin
    DrawTitle(reTitleInventory);
    CurCrEnum := TLeaderParty.Leader.Enum;
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reBigFrame);
    TextLeft := GetFrameX(0, psRight) + 12;
    TextTop := GetFrameY(0, psRight) + 6;
    //
    if EquipmentSelItemIndex >= 0 then
      DrawImage(TextLeft - 4, TextTop + (EquipmentSelItemIndex * TextLineHeight)
        + 42, reItemFrame);
    //
    AddTextLine('Экипировка', True);
    AddTextLine;
    for I := 0 to MaxEquipmentItems - 1 do
      case I of
        5:
          AddTextLine(TLeaderParty.Leader.Equipment.ItemName(I,
            TCreature.EquippedWeapon(TCreature.Character
            (TLeaderParty.Leader.Enum).AttackEnum,
            TCreature.Character(TLeaderParty.Leader.Enum).SourceEnum)));
      else
        AddTextLine(TLeaderParty.Leader.Equipment.ItemName(I));
      end;

    TextLeft := GetFrameX(0, psRight) + 320 + 12;
    TextTop := GetFrameY(0, psRight) + 6;
    //
    if (InventorySelItemIndex >= 0) and
      (TLeaderParty.Leader.Inventory.Item(InventorySelItemIndex).Enum <> iNone)
    then
      DrawImage(TextLeft - 4, TextTop + (InventorySelItemIndex * TextLineHeight)
        + 42, reItemFrame);
    //
    AddTextLine('Инвентарь', True);
    AddTextLine;
    for I := 0 to MaxInventoryItems - 1 do
      AddTextLine(TLeaderParty.Leader.Inventory.ItemName(I));
  end;

  procedure ShowInfo;
  begin
    DrawTitle(reTitleParty);
    DrawImage(GetFrameX(0, psRight), GetFrameY(0, psRight), reInfoFrame);
    C := CurrentParty.Creature[ActivePartyPosition].Enum;
    if (C <> crNone) then
      TSceneHire(Game.GetScene(scHire)).RenderCharacterInfo(C, 20);
    DrawImage(Lf + (ResImage[reActFrame].Width + 2) * 2 + 20, SceneTop,
      reInfoFrame);
    TextTop := SceneTop + 6;
    TextLeft := Lf + (ResImage[reActFrame].Width * 2) + 14 + 20;
    AddTextLine('Статистика', True);
    AddTextLine;
    AddTextLine('Выиграно битв', Game.Statistics.GetValue(stBattlesWon));
    AddTextLine('Убито врагов', Game.Statistics.GetValue(stKilledCreatures));
    AddTextLine('Очки', Game.Statistics.GetValue(stScore));
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine(Format('Скорость передвижения %d/%d',
      [TLeaderParty.Leader.Speed, TLeaderParty.Leader.MaxSpeed]));
    AddTextLine(Format('Лидерство %d', [TLeaderParty.Leader.MaxLeadership]));
    AddTextLine(Format('Радиус обзора %d', [TLeaderParty.Leader.Radius]));
  end;

begin
  inherited;
  DrawImage(reWallpaperLeader);
  RenderParty(psLeft, CurrentParty);
  if FShowInventory then
    ShowInventory
  else if FShowSkills then
    ShowSkills
  else
    ShowInfo;
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
      if FShowResources then
        OpenInventory;
    K_T:
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
