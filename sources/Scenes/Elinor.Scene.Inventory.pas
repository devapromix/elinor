unit Elinor.Scene.Inventory;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Scene.Base.Party,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneInventory = class(TSceneBaseParty)
  private type
    TButtonEnum = (btInfo, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextInform, reTextClose);
  private
    EquipmentSelItemIndex: Integer;
    Button: array [TButtonEnum] of TButton;
    ConfirmGold: Integer;
    ConfirmParty: TParty;
    ConfirmPartyPosition: TPosition;
    procedure UnEquip;
    procedure Equip;
    procedure QuaffElixir;
    procedure ShowItemInfo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(AParty: TParty;
      const ACloseSceneEnum: TSceneEnum);
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Scene.Settlement,
  Elinor.Scene.Party2,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Items,
  Elinor.Common,
  Elinor.Ability;

type
  TItemSectionEnum = (isParty, isEquipment, isInventory);

var
  ShowResources: Boolean;
  CurrentParty: TParty;
  CloseSceneEnum: TSceneEnum;
  ActiveSection: TItemSectionEnum;
  InventorySelItemIndex: Integer;

procedure TSceneInventory.QuaffElixir;
begin
  TLeaderParty.Leader.Quaff(InventorySelItemIndex, ActivePartyPosition);
end;

{ TSceneInventory }

procedure TSceneInventory.ShowItemInfo;
var
  LItemEnum: TItemEnum;
begin
  case ActiveSection of
    isEquipment:
      begin
        LItemEnum := TLeaderParty.Leader.Equipment.Item
          (EquipmentSelItemIndex).Enum;
        if (LItemEnum <> iNone) then
          Game.ItemInformDialog(LItemEnum);
      end;
    isInventory:
      begin
        LItemEnum := TLeaderParty.Leader.Inventory.Item
          (InventorySelItemIndex).Enum;
        if (LItemEnum <> iNone) then
          Game.ItemInformDialog(LItemEnum);
      end;
  end;
end;

class procedure TSceneInventory.ShowScene(AParty: TParty;
  const ACloseSceneEnum: TSceneEnum);
begin
  CurrentParty := AParty;
  CloseSceneEnum := ACloseSceneEnum;
  ShowResources := AParty = TLeaderParty.Leader;
  if ShowResources then
    ActivePartyPosition := TLeaderParty.GetPosition
  else
    ActivePartyPosition := AParty.GetRandomPosition;
  ActiveSection := isParty;
  Game.Show(scInventory);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

class procedure TSceneInventory.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(CloseSceneEnum);
end;

constructor TSceneInventory.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperSettlement);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Selected := True;
  end;
  EquipmentSelItemIndex := 0;
  InventorySelItemIndex := 0;
end;

destructor TSceneInventory.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneInventory.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btInfo].MouseDown then
        begin
          ShowItemInfo;
          Exit;
        end
        else if Button[btClose].MouseDown then
        begin
          HideScene;
          Exit;
        end;
        case ActiveSection of
          isEquipment:
            UnEquip;
          isInventory:
            Equip;
        end;
      end;
    mbRight:
      ShowItemInfo;
  end;
end;

procedure TSceneInventory.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  if MouseOver(X, Y, TFrame.Col(1, psLeft) + 8, TFrame.Row(0) + 48, 640,
    TextLineHeight * 12) then
    ActiveSection := isParty;
  if MouseOver(X, Y, TFrame.Col(0, psRight) + 8, TFrame.Row(0) + 48, 320,
    TextLineHeight * 12) then
  begin
    ActiveSection := isEquipment;
    EquipmentSelItemIndex := (Y - (TFrame.Row(0) + 48)) div TextLineHeight;
  end;
  if MouseOver(X, Y, TFrame.Col(1, psRight) + 8, TFrame.Row(0) + 48, 320,
    TextLineHeight * 12) then
  begin
    ActiveSection := isInventory;
    InventorySelItemIndex := (Y - (TFrame.Row(0) + 48)) div TextLineHeight;
  end;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneInventory.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
    LX, LY: Integer;
  begin
    if (CurrentParty <> nil) then
      for LPosition := Low(TPosition) to High(TPosition) do
        DrawUnit(LPosition, CurrentParty, TFrame.Col(LPosition, psLeft),
          TFrame.Row(LPosition), False, True);
    if ActiveSection <> isParty then
    begin
      GetSceneActivePartyPosition(LX, LY);
      DrawImage(LX, LY, reFrameSlotPassive);
    end;
  end;

  procedure RenderEquipment;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    case ActiveSection of
      isEquipment:
        DrawImage(TextLeft - 4,
          TextTop + (EquipmentSelItemIndex * TextLineHeight) + 42,
          reFrameItemActive);
    else
      DrawImage(TextLeft - 4, TextTop + (EquipmentSelItemIndex * TextLineHeight)
        + 42, reFrameItem);
    end;
    AddTextLine('Equipment', True);
    AddTextLine;
    for I := 0 to CMaxEquipmentItems - 1 do
      case I of
        5:
          AddTextLine(TLeaderParty.Leader.Equipment.ItemName(I,
            TCreature.EquippedWeapon(TCreature.Character
            (TLeaderParty.Leader.Enum).AttackEnum,
            TCreature.Character(TLeaderParty.Leader.Enum).SourceEnum)));
      else
        AddTextLine(TLeaderParty.Leader.Equipment.ItemName(I));
      end;
  end;

  procedure RenderInventory;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    case ActiveSection of
      isInventory:
        DrawImage(TextLeft - 4,
          TextTop + (InventorySelItemIndex * TextLineHeight) + 42,
          reFrameItemActive);
    else
      DrawImage(TextLeft - 4, TextTop + (InventorySelItemIndex * TextLineHeight)
        + 42, reFrameItem);
    end;
    AddTextLine('Inventory', True);
    AddTextLine;
    for I := 0 to CMaxInventoryItems - 1 do
      AddTextLine(TLeaderParty.Leader.Inventory.ItemName(I));
  end;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;

  DrawTitle(reTitleInventory);
  RenderParty;
  RenderEquipment;
  RenderInventory;

  RenderButtons;
  RenderLHandSlot;
end;

procedure TSceneInventory.Timer;
begin
  inherited;

end;

procedure TSceneInventory.Equip;
var
  LItemEnum: TItemEnum;
begin
  if (InventorySelItemIndex > -1) then
  begin
    LItemEnum := TLeaderParty.Leader.Inventory.ItemEnum(InventorySelItemIndex);
    if (LItemEnum = iNone) then
      Exit;
    if LItemEnum in CQuaffItems then
      ConfirmDialog(CQuaffThisElixir, {$IFDEF MODEOBJFPC}@{$ENDIF}QuaffElixir)
    else if TAbilities.CheckItemAbility(LItemEnum, itBoots, abTravelLore) then
      InformDialog(CLeaderCannotWearShoes)
    else if TAbilities.CheckItemAbility(LItemEnum, itTome, abArcaneKnowledge) then
      InformDialog(CLeaderCannotUseTomes)
    else if TAbilities.CheckItemAbility(LItemEnum, itOrb, abArcaneLore) then
      InformDialog(CLeaderCannotUseOrb)
    else if TAbilities.CheckItemAbility(LItemEnum, itScroll,
      abUseStaffsAndScrolls) then
      InformDialog(CLeaderCannotReadScroll)
    else if TAbilities.CheckItemAbility(LItemEnum, itWand, abUseStaffsAndScrolls)
    then
      InformDialog(CLeaderCannotWearStaves)
    else if ActivePartyPosition = TLeaderParty.GetPosition then
      TLeaderParty.Leader.Equip(InventorySelItemIndex)
    else
      InformDialog(COnlyLeaderCanEquipItem);
  end;
end;

procedure TSceneInventory.UnEquip;
begin
  if (EquipmentSelItemIndex > -1) then
    if TLeaderParty.Leader.UnEquip(EquipmentSelItemIndex) then
      InformDialog(CNoFreeSpace);
end;

procedure TSceneInventory.Update(var Key: Word);
begin
  case Key of
    K_UP:
      begin
        case ActiveSection of
          isEquipment:
            begin
              Dec(EquipmentSelItemIndex);
              if EquipmentSelItemIndex < 0 then
                EquipmentSelItemIndex := CMaxEquipmentItems - 1;
              Exit;
            end;
          isInventory:
            begin
              Dec(InventorySelItemIndex);
              if InventorySelItemIndex < 0 then
                InventorySelItemIndex := CMaxEquipmentItems - 1;
              Exit;
            end;
        end;
      end;
    K_DOWN:
      begin
        case ActiveSection of
          isEquipment:
            begin
              Inc(EquipmentSelItemIndex);
              if EquipmentSelItemIndex > CMaxEquipmentItems - 1 then
                EquipmentSelItemIndex := 0;
              Exit;
            end;
          isInventory:
            begin
              Inc(InventorySelItemIndex);
              if InventorySelItemIndex > CMaxEquipmentItems - 1 then
                InventorySelItemIndex := 0;
              Exit;
            end;
        end;
      end
  end;
  if ActiveSection = isParty then
    inherited;
  case Key of
    K_ESCAPE:
      HideScene;
    K_ENTER:
      begin
        case ActiveSection of
          isParty:
            HideScene;
          isEquipment:
            UnEquip;
          isInventory:
            Equip;
        end;
      end;
    K_SPACE:
      ActiveSection := TItemSectionEnum((Ord(ActiveSection) + 1) mod 3);
    K_I:
      ShowItemInfo;
  end;
end;

end.
