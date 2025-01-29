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
    TButtonEnum = (btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);
  private
    EquipmentSelItemIndex: Integer;
    InventorySelItemIndex: Integer;
    Button: array [TButtonEnum] of TButton;
    ConfirmGold: Integer;
    ConfirmParty: TParty;
    ConfirmPartyPosition: TPosition;
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
  Elinor.Scene.Party,
  Elinor.Scene.Party2,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Items;

type
  TItemSectionEnum = (isParty, isEquipment, isInventory);

var
  ShowResources: Boolean;
  CurrentParty: TParty;
  CloseSceneEnum: TSceneEnum;
  ActiveSection: TItemSectionEnum;

  { TSceneInventory }

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
      Button[LButtonEnum].Sellected := True;
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
        if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneInventory.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneInventory.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
  begin
    if (CurrentParty <> nil) then
      for LPosition := Low(TPosition) to High(TPosition) do
        DrawUnit(LPosition, CurrentParty, TFrame.Col(LPosition, psLeft),
          TFrame.Row(LPosition), False, True);
  end;

  procedure RenderEquipment;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    DrawImage(TextLeft - 4, TextTop + (EquipmentSelItemIndex * TextLineHeight) +
      42, reFrameItem);
    AddTextLine('Equipment', True);
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
  end;

  procedure RenderInventory;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    DrawImage(TextLeft - 4, TextTop + (InventorySelItemIndex * TextLineHeight) +
      42, reFrameItem);
    AddTextLine('Inventory', True);
    AddTextLine;
    for I := 0 to MaxInventoryItems - 1 do
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
end;

procedure TSceneInventory.Timer;
begin
  inherited;

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
                EquipmentSelItemIndex := MaxEquipmentItems - 1;
              Exit;
            end;
          isInventory:
            begin
              Dec(InventorySelItemIndex);
              if InventorySelItemIndex < 0 then
                InventorySelItemIndex := MaxEquipmentItems - 1;
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
              if EquipmentSelItemIndex > MaxEquipmentItems - 1 then
                EquipmentSelItemIndex := 0;
              Exit;
            end;
          isInventory:
            begin
              Inc(InventorySelItemIndex);
              if InventorySelItemIndex > MaxEquipmentItems - 1 then
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
            TLeaderParty.Leader.UnEquip(EquipmentSelItemIndex);
          isInventory:
            TLeaderParty.Leader.Equip(InventorySelItemIndex);
        end;
      end;
    K_SPACE:
      ActiveSection := TItemSectionEnum((Ord(ActiveSection) + 1) mod 3);
  end;
end;

end.
