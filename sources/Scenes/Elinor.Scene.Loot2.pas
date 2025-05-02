unit Elinor.Scene.Loot2;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Spells,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scene.Menu.Wide,
  Elinor.Scenes;

type
  TSceneLoot2 = class(TSceneWideMenu)
  private type
    TButtonEnum = (btPickup, btClose, btInfo);
    TLootSectionEnum = (lsLoot, lsInventory);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextPickup, reTextClose,
      reTextInform);
  private
  class var
    Button: array [TButtonEnum] of TButton;
    InventorySelItemIndex: Integer;
    ActiveSection: TLootSectionEnum;
    procedure PickupItem;
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
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.Types,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Map,
  Elinor.Creatures,
  Elinor.Frame,
  Elinor.Spells.Types,
  Elinor.Loot,
  Elinor.Items,
  Elinor.Statistics,
  Elinor.Common,
  Elinor.Scene.Victory,
  Elinor.Scenario;

{ TSceneLoot }

procedure TSceneLoot2.ShowItemInfo;
var
  LItemEnum: TItemEnum;
  LLootItem: TLootItem;
  LX, LY, LItemIndex: Integer;
begin
  case ActiveSection of
    lsInventory:
      begin
        if InventorySelItemIndex >= 0 then
        begin
          LItemEnum := TLeaderParty.Leader.Inventory.Item
            (InventorySelItemIndex).Enum;
          if (LItemEnum <> iNone) then
            Game.ItemInformDialog(LItemEnum);
        end;
      end;
  end;
end;

procedure TSceneLoot2.PickupItem;
var
  LLootItem: TLootItem;
  LX, LY, LItemIndex: Integer;
begin
  LX := TLeaderParty.Leader.X;
  LY := TLeaderParty.Leader.Y;
  if Loot.CountAt(LX, LY) = 0 then
  begin
    HideScene;
    Exit;
  end;
  LItemIndex := Loot.GetItemIndex(LX, LY, CurrentIndex);
  if LItemIndex >= 0 then
  begin
    LLootItem := Loot.GetLootItem(LItemIndex);
    case LLootItem.LootType of
      ltGold:
        begin
          Game.MediaPlayer.PlaySound(mmGold);
          Game.Gold.Modify(LLootItem.Amount);
          Loot.Clear(LItemIndex);
        end;
      ltMana:
        begin
          Game.MediaPlayer.PlaySound(mmMana);
          Game.Mana.Modify(LLootItem.Amount);
          Loot.Clear(LItemIndex);
        end;
      ltStoneTab:
        begin
          Game.MediaPlayer.PlaySound(mmLoot);
          Inc(Game.Scenario.StoneTab);
          Loot.Clear(LItemIndex);
          InformDialog(Game.Scenario.ScenarioAncientKnowledgeState);
        end;
      ltItem:
        begin
          if TLeaderParty.Leader.Inventory.Count >= CMaxInventoryItems then
          begin
            InformDialog(CNoFreeSpace);
            Exit;
          end;
          Game.MediaPlayer.PlaySound(mmLoot);
          TLeaderParty.Leader.Inventory.Add(LLootItem.ItemEnum);
          Game.Statistics.IncValue(stItemsFound);
          Loot.Clear(LItemIndex);
        end;
    end;
  end;
end;

class procedure TSceneLoot2.HideScene;
begin
  Loot.AttemptToPlaceLootObject;

  if (Game.Scenario.CurrentScenario = sgAncientKnowledge) then
    if Game.Scenario.StoneTab >= TScenario.ScenarioStoneTabMax then
    begin
      TSceneVictory.ShowScene;
      Exit;
    end;
  Game.Show(scMap);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmLoot);
end;

constructor TSceneLoot2.Create;
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
  ShowButtons := False;
  InventorySelItemIndex := 0;
  ActiveSection := lsLoot;
end;

destructor TSceneLoot2.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneLoot2.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btInfo].MouseDown then
          ShowItemInfo
        else if Button[btPickup].MouseDown then
          PickupItem
        else if Button[btClose].MouseDown then
          HideScene;
      end;
    mbRight:
      ShowItemInfo;
  end;
end;

procedure TSceneLoot2.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;

  if MouseOver(X, Y, TFrame.Col(0), TFrame.Row(0) + 48,
    TFrame.Col(1) + 320 - TFrame.Col(0), TextLineHeight * 12) then
  begin
    ActiveSection := lsLoot;
  end;

  if MouseOver(X, Y, TFrame.Col(3) + 8, TFrame.Row(0) + 48, 320,
    TextLineHeight * 12) then
  begin
    ActiveSection := lsInventory;
    InventorySelItemIndex := (Y - (TFrame.Row(0) + 48)) div TextLineHeight;
  end;

  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneLoot2.Render;
var
  LPos: TPoint;

  procedure RenderItems;
  var
    X, Y, I, J, LCount: Integer;
    LLeft, LTop: Integer;
    LLootItem: TLootItem;
  begin
    X := TLeaderParty.Leader.X;
    Y := TLeaderParty.Leader.Y;
    LCount := Loot.CountAt(X, Y);
    for I := 0 to LCount - 1 do
    begin
      LLeft := IfThen(I > 2, TFrame.Col(1), TFrame.Col(0));
      LTop := IfThen(I > 2, TFrame.Row(I - 3), TFrame.Row(I));
      J := Loot.GetItemIndex(X, Y, I);
      LLootItem := Loot.GetLootItem(J);
      DrawItem(LLootItem.ItemEnum, LLeft, LTop);
      DrawText(LLeft + 74, LTop + 6, TItemBase.Item(LLootItem.ItemEnum).Name);
    end;
  end;

  procedure RenderItemInfo;
  var
    LLootItem: TLootItem;
    LItemEnum: TItemEnum;
    X, Y, I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    X := TLeaderParty.Leader.X;
    Y := TLeaderParty.Leader.Y;
    I := Loot.GetItemIndex(X, Y, CurrentIndex);
    if I >= 0 then
    begin
      LLootItem := Loot.GetLootItem(I);
      LItemEnum := LLootItem.ItemEnum;
      AddTextLine(TItemBase.Item(LItemEnum).Name, True);
      AddTextLine;
      case LLootItem.LootType of
        ltGold, ltMana:
          AddTextLine('Amount', LLootItem.Amount);
        ltStoneTab:
          AddTextLine('Quest item');
      else
        begin
          AddTextLine('Level', TItemBase.Item(LItemEnum).Level);
          AddTextLine('Price', TItemBase.Item(LItemEnum).Price);
        end;
      end;
      DrawItemDescription(LItemEnum);
      DrawText(TextLeft, TextTop, 300, TItemBase.Item(LItemEnum).Description);
    end;
  end;

  procedure RenderInventory;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    if (ActiveSection = lsInventory) then
      DrawImage(TextLeft - 4, TextTop + (InventorySelItemIndex * TextLineHeight)
        + 42, reFrameItemActive)
    else
      DrawImage(TextLeft - 4, TextTop + (InventorySelItemIndex * TextLineHeight)
        + 42, reFrameItem);
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
  DrawTitle(reTitleLoot);
  RenderItems;
  RenderItemInfo;
  RenderInventory;
  RenderButtons;
  case ActiveSection of
    lsInventory:
      begin
        LPos := GetCurrentIndexPos(CurrentIndex);
        DrawImage(LPos.X, LPos.Y, reFrameSlotPassive);
      end;
  end;
end;

class procedure TSceneLoot2.ShowScene;
begin
  ActiveSection := lsLoot;
  Game.MediaPlayer.PlaySound(mmLoot);
  Game.Show(scLoot);
end;

procedure TSceneLoot2.Timer;
begin
  inherited;

end;

procedure TSceneLoot2.Update(var Key: Word);
begin
  case Key of
    K_UP:
      case ActiveSection of
        lsInventory:
          begin
            Dec(InventorySelItemIndex);
            if InventorySelItemIndex < 0 then
              InventorySelItemIndex := CMaxInventoryItems - 1;
            Exit;
          end;
      end;
    K_DOWN:
      case ActiveSection of
        lsInventory:
          begin
            Inc(InventorySelItemIndex);
            if InventorySelItemIndex > CMaxInventoryItems - 1 then
              InventorySelItemIndex := 0;
            Exit;
          end;
      end;
    K_LEFT, K_RIGHT:
      case ActiveSection of
        lsInventory:
          Exit;
      end;
  end;
  inherited;
  case Key of
    K_ESCAPE:
      HideScene;
    K_ENTER:
      case ActiveSection of
        lsLoot:
          PickupItem;
        lsInventory:
          ShowItemInfo;
      end;
    K_I:
      ShowItemInfo;
    K_SPACE:
      case ActiveSection of
        lsLoot:
          ActiveSection := lsInventory;
        lsInventory:
          ActiveSection := lsLoot;
      end;
  end;
end;

end.
