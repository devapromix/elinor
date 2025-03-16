unit Elinor.Scene.Merchant;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Merchant,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneMerchant = class(TSceneFrames)
  private type
    TButtonEnum = (btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);
    procedure ChSection;
  private
    InventorySelItemIndex: Integer;
    MerchantSelItemIndex: Integer;
    Button: array [TButtonEnum] of TButton;
    SelectedItemPrice: Integer;
    procedure SellItem;
    procedure BuyItem;
    procedure GetItemPrice;
    procedure UpdateSelectionIndex(const AIsUp: Boolean);
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
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Items,
  Elinor.Common;

type
  TItemSectionEnum = (isMerchant, isInventory);

var
  ShowResources: Boolean;
  CurrentParty: TParty;
  CloseSceneEnum: TSceneEnum;
  ActiveSection: TItemSectionEnum;

  { TSceneMerchant }

class procedure TSceneMerchant.ShowScene(AParty: TParty;
  const ACloseSceneEnum: TSceneEnum);
begin
  CurrentParty := AParty;
  CloseSceneEnum := ACloseSceneEnum;
  ShowResources := AParty = TLeaderParty.Leader;
  ActiveSection := isMerchant;
  Game.Show(scMerchant);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

class procedure TSceneMerchant.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(CloseSceneEnum);
end;

procedure TSceneMerchant.ChSection;
begin
  ActiveSection := TItemSectionEnum((Ord(ActiveSection) + 1) mod 2);
end;

procedure TSceneMerchant.BuyItem;
begin
  if TLeaderParty.Leader.Inventory.Count >= CMaxInventoryItems then
  begin
    InformDialog(CNoFreeSpace);
    Exit;
  end;
  Game.MediaPlayer.PlaySound(mmLoot);
  // TLeaderParty.Leader.Inventory.Add(LLootItem.ItemEnum);
end;

constructor TSceneMerchant.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperSettlement, fgLM2, fgRM2);
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
  InventorySelItemIndex := 0;
  MerchantSelItemIndex := 0;
  SelectedItemPrice := 0;
end;

destructor TSceneMerchant.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneMerchant.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        case ActiveSection of
          isInventory:
            GetItemPrice;
          isMerchant:
            ;
        end;
        if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneMerchant.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;

  if MouseOver(X, Y, TFrame.Col(0) + 8, TFrame.Row(0) + 48, 320,
    TextLineHeight * CMaxInventoryItems) then
  begin
    ActiveSection := isMerchant;
    MerchantSelItemIndex := (Y - (TFrame.Row(0) + 48)) div TextLineHeight;
  end;

  if MouseOver(X, Y, TFrame.Col(2) + 8, TFrame.Row(1) + 48, 320,
    TextLineHeight * CMaxInventoryItems) then
  begin
    ActiveSection := isInventory;
    InventorySelItemIndex := (Y - (TFrame.Row(1) + 48)) div TextLineHeight;
    GetItemPrice;
  end;

  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneMerchant.Render;

  procedure RenderMerchantInventory;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(0) + 12;

    case ActiveSection of
      isMerchant:
        DrawImage(TextLeft - 4,
          TextTop + (MerchantSelItemIndex * TextLineHeight) + 42,
          reFrameItemActive);
    else
      DrawImage(TextLeft - 4, TextTop + (MerchantSelItemIndex * TextLineHeight)
        + 42, reFrameItem);
    end;

    AddTextLine('Inventory', True);
    AddTextLine('');

    for I := 0 to CMaxInventoryItems - 1 do
      AddTextLine(Merchants.GetMerchant(mtPotions).Inventory.ItemName(I));
  end;

  procedure RenderLeaderInventory;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;

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
    AddTextLine('');

    for I := 0 to CMaxInventoryItems - 1 do
      AddTextLine(TLeaderParty.Leader.Inventory.ItemName(I));
  end;

  procedure RenderMerchantItemDetails;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(1) + 12;

    AddTextLine('Gold', True);
    AddTextLine('');
    AddTextLine(IntToStr(Merchants.GetMerchant(mtPotions).Gold));
    AddTextLine('Item Details', True);
    AddTextLine('');

    if SelectedItemPrice > 0 then
    begin
      case ActiveSection of
        isInventory:
          begin
            AddTextLine('Selected Item:');
            AddTextLine(TLeaderParty.Leader.Inventory.ItemName
              (InventorySelItemIndex));
            AddTextLine('Price: ' + IntToStr(SelectedItemPrice));
            AddTextLine('');
            AddTextLine('Press ENTER to sell');
          end;
        isMerchant:
          begin
            AddTextLine('Selected Merchant Item:');
            AddTextLine('Item ' + IntToStr(MerchantSelItemIndex + 1));
          end;
      end;
    end;
  end;

  procedure RenderLeaderItemDetails;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Gold', True);
    AddTextLine('');
    AddTextLine(IntToStr(Game.Gold.Value));
    AddTextLine('Item Details', True);
    AddTextLine('');
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

  DrawTitle(reTitleMerchant);
  DrawImage(20, 160, reTextMerchant);
  DrawImage(ScrWidth + 20, 160, reTextLeadParty);

  RenderMerchantInventory;
  RenderMerchantItemDetails;

  RenderLeaderInventory;
  RenderLeaderItemDetails;

  RenderButtons;
end;

procedure TSceneMerchant.Timer;
begin
  inherited;

end;

procedure TSceneMerchant.GetItemPrice;
var
  LItemEnum: TItemEnum;
begin
  if (InventorySelItemIndex > -1) then
  begin
    LItemEnum := TLeaderParty.Leader.Inventory.ItemEnum(InventorySelItemIndex);
    if LItemEnum = iNone then
    begin
      SelectedItemPrice := 0;
      Exit;
    end;

    // Получаем базовую цену предмета и применяем коэффициент для продажи
    // (обычно цена продажи ниже цены покупки)
    // SelectedItemPrice := TItems.GetItemPrice(LItemEnum) div 2;
    SelectedItemPrice := 10; // Временное значение для демонстрации

    if SelectedItemPrice < 1 then
      SelectedItemPrice := 1;
  end;
end;

procedure TSceneMerchant.SellItem;
var
  LItemEnum: TItemEnum;
  LSellPrice: Integer;
begin
  if (InventorySelItemIndex > -1) and (ActiveSection = isInventory) then
  begin
    LItemEnum := TLeaderParty.Leader.Inventory.ItemEnum(InventorySelItemIndex);
    if LItemEnum = iNone then
      Exit;
    LSellPrice := SelectedItemPrice;
    if Merchants.GetMerchant(mtPotions).Gold < LSellPrice then
    begin
      InformDialog('The merchant does not have enough gold!');
      Exit;
    end;
    Game.Gold.Modify(LSellPrice);
    Merchants.GetMerchant(mtPotions).ModifyGold(-LSellPrice);

    // TLeaderParty.Leader.Inventory.SetItem(InventorySelItemIndex, iNone);
    SelectedItemPrice := 0;
    Game.MediaPlayer.PlaySound(mmGold);
  end;
end;

procedure TSceneMerchant.UpdateSelectionIndex(const AIsUp: Boolean);
begin
  case ActiveSection of
    isInventory:
      begin
        if AIsUp then
        begin
          Dec(InventorySelItemIndex);
          if InventorySelItemIndex < 0 then
            InventorySelItemIndex := CMaxInventoryItems - 1;
        end
        else
        begin
          Inc(InventorySelItemIndex);
          if InventorySelItemIndex > CMaxInventoryItems - 1 then
            InventorySelItemIndex := 0;
        end;
        GetItemPrice;
      end;
    isMerchant:
      begin
        if AIsUp then
        begin
          Dec(MerchantSelItemIndex);
          if MerchantSelItemIndex < 0 then
            MerchantSelItemIndex := CMaxInventoryItems;
        end
        else
        begin
          Inc(MerchantSelItemIndex);
          if MerchantSelItemIndex > CMaxInventoryItems then
            MerchantSelItemIndex := 0;
        end;
      end;
  end;
end;

procedure TSceneMerchant.Update(var Key: Word);
begin
  case Key of
    K_ESCAPE:
      HideScene;
    K_UP:
      UpdateSelectionIndex(True);
    K_DOWN:
      UpdateSelectionIndex(False);
    K_ENTER:
      case ActiveSection of
        isInventory:
          SellItem;
        isMerchant:
          BuyItem;
      end;
    K_SPACE:
      ChSection;
  end;
end;

end.
