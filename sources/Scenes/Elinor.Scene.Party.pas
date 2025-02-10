unit Elinor.Scene.Party;

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  Elinor.Party,
  Elinor.Scenes,
  Elinor.Resources,
  Elinor.Scene.Frames,
  Elinor.Direction,
  Elinor.Creatures;

type
  TSceneParty = class(TSceneFrames)
  private
  private
  class var
    FShowSkills: Boolean;
    FShowInventory: Boolean;
    FShowResources: Boolean;
    procedure MoveCursor(ADirectionEnum: TDirectionEnum);
    procedure Close;
    procedure OpenInventory;
    procedure OpenAbilities;
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
    class procedure RenderParty(const PartySide: TPartySide;
      const Party: TParty; CanHire: Boolean = False; ShowExp: Boolean = True);
    class procedure Show(Party: TParty; CloseScene: TSceneEnum;
      F: Boolean = False; H: Boolean = False); overload;
  end;

var
  SelectPartyPosition: Integer = -1;
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

implementation

uses
  SysUtils, dialogs,
  Elinor.Saga,
  Elinor.Statistics,
  Elinor.Creature.Types,
  Elinor.Ability,
  DisciplesRL.Scene.Hire,
  Elinor.Button,
  Elinor.Items,
  Elinor.Frame;

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
  Game.MediaPlayer.PlaySound(mmSettlement);
  FShowInventory := F;
  FShowSkills := False;
  if H then
  begin
    FShowInventory := False;
    FShowSkills := True;
  end;
end;

procedure TSceneParty.MoveCursor(ADirectionEnum: TDirectionEnum);
begin
  case ADirectionEnum of
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
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Render;
end;

procedure TSceneParty.OpenInventory;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  FShowSkills := False;
  FShowInventory := not FShowInventory;
  ActivePartyPosition := TLeaderParty.GetPosition;
end;

procedure TSceneParty.OpenAbilities;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  FShowInventory := False;
  FShowSkills := not FShowSkills;
  ActivePartyPosition := TLeaderParty.GetPosition;
end;

procedure TSceneParty.Close;
begin
  if CurrentParty <> PartyList.Party[TLeaderParty.LeaderPartyIndex] then
    ActivePartyPosition := ActivePartyPosition + 6;
  Game.Show(BackScene);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

class procedure TSceneParty.RenderParty(const PartySide: TPartySide;
  const Party: TParty; CanHire: Boolean = False; ShowExp: Boolean = True);
var
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
  begin
    Game.GetScene(scParty).RenderFrame(PartySide, Position,
      TFrame.Col(Position, PartySide), TFrame.Row(Position), FShowInventory or
      FShowSkills);
    if (Party <> nil) then
      TSceneParty(Game.GetScene(scParty)).DrawUnit(Position, Party,
        TFrame.Col(Position, PartySide), TFrame.Row(Position), CanHire,
        ShowExp);
  end;
end;

constructor TSceneParty.Create;
var
  I: TButtonEnum;
  Lt, W: Integer;
begin
  inherited Create(reWallpaperLeader, fgLS6, fgRM2);
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
  Lf := ScrWidth - (ResImage[reFrameSlot].Width) - 2;
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
          OpenAbilities;
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
        Game.MediaPlayer.PlaySound(mmClick);
        Render;
      end;
  end;
end;

procedure TSceneParty.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  if FShowInventory and MouseOver(X, Y, TFrame.Col(0, psRight) + 8,
    TFrame.Row(0) + 48, 320, TextLineHeight * 12) then
    EquipmentSelItemIndex := (Y - (TFrame.Row(0) + 48)) div TextLineHeight
  else
    EquipmentSelItemIndex := -1;
  if FShowInventory and MouseOver(X, Y, TFrame.Col(0, psRight) + 328,
    TFrame.Row(0) + 48, 320, TextLineHeight * 12) then
    InventorySelItemIndex := (Y - (TFrame.Row(0) + 48)) div TextLineHeight
  else
    InventorySelItemIndex := -1;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure TSceneParty.Render;
var
  C: TCreatureEnum;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      if FShowResources or (not FShowResources and (LButtonEnum = btClose)) then
        Button[LButtonEnum].Render;
  end;

  procedure ShowSkills;
  var
    I: Integer;
    LSkillEnum: TAbilityEnum;
  begin
    DrawTitle(reTitleAbilities);
    TextLeft := 250 + TFrame.Col(0, psRight) + 12;
    TextTop := TFrame.Row(0) + 6 + (TextLineHeight div 2);
    TextLeft := TFrame.Col(0, psRight) + 12;
    TextTop := TFrame.Row(0) + 6;
    AddTextLine('Умения Лидера', True);
    AddTextLine;
    for I := 0 to CMaxAbilities - 1 do
    begin
      LSkillEnum := TLeaderParty.Leader.Abilities.GetEnum(I);
      if LSkillEnum <> abNone then
      begin
        AddTextLine(TAbilities.Ability(LSkillEnum).Name);
        AddTextLine(TAbilities.Ability(LSkillEnum).Description[0]);
        AddTextLine(TAbilities.Ability(LSkillEnum).Description[1]);
        if I = 3 then
        begin
          TextLeft := TFrame.Col(0, psRight) + 320 + 12;
          TextTop := TFrame.Row(0) + 6;

        end;
      end;
    end;
  end;

  procedure ShowInventory;
  var
    I: Integer;
  begin
    DrawTitle(reTitleInventory);
    TextLeft := TFrame.Col(0, psRight) + 12;
    TextTop := TFrame.Row(0) + 6;
    //
    if EquipmentSelItemIndex >= 0 then
      DrawImage(TextLeft - 4, TextTop + (EquipmentSelItemIndex * TextLineHeight)
        + 42, reFrameItem);
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

    TextLeft := TFrame.Col(0, psRight) + 320 + 12;
    TextTop := TFrame.Row(0) + 6;
    //
    if (InventorySelItemIndex >= 0) and
      (TLeaderParty.Leader.Inventory.Item(InventorySelItemIndex).Enum <> iNone)
    then
      DrawImage(TextLeft - 4, TextTop + (InventorySelItemIndex * TextLineHeight)
        + 42, reFrameItem);
    //
    AddTextLine('Инвентарь', True);
    AddTextLine;
    for I := 0 to MaxInventoryItems - 1 do
      AddTextLine(TLeaderParty.Leader.Inventory.ItemName(I));
  end;

  procedure ShowInfo;
  begin
    DrawTitle(reTitleParty);
    C := CurrentParty.Creature[ActivePartyPosition].Enum;
    // if (C <> crNone) then
    // TSceneHire(Game.GetScene(scHire)).RenderCharacterInfo(C, 20);
    TextTop := SceneTop + 6;
    TextLeft := Lf + (ResImage[reFrameSlotActive].Width * 2) + 14 + 20;
    AddTextLine('Statistics', True);
    AddTextLine;
  end;

begin
  inherited;
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
    K_P:
      if FShowSkills or FShowInventory then
      begin
        FShowSkills := False;
        FShowInventory := False;
      end
      else
        Close;
    K_I:
      if FShowResources then
        OpenInventory;
    K_T:
      if FShowResources then
        OpenAbilities;
    K_LEFT, K_KP_4, K_A:
      if FShowSkills or FShowInventory then

      else
        MoveCursor(drWest);
    K_RIGHT, K_KP_6, K_D:
      if FShowSkills or FShowInventory then

      else
        MoveCursor(drEast);
    K_UP, K_KP_8, K_W:
      if FShowSkills or FShowInventory then
        Exit
      else
        MoveCursor(drNorth);
    K_DOWN, K_KP_2, K_X:
      if FShowSkills or FShowInventory then
        Exit
      else
        MoveCursor(drSouth);
  end;
end;

end.
