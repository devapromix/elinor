unit Elinor.Scene.Merchant;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Items,
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
    Button: array [TButtonEnum] of TButton;
    procedure SellItem;
    procedure BuyItem;
    procedure UpdateSelectionIndex(const AIsUp: Boolean);
    procedure GetLeaderItemPrice; overload;
    function GetLeaderItemPrice(const AItemEnum: TItemEnum): Integer; overload;
    class procedure GetMerchantItemPrice;
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
  Elinor.Common;

type
  TItemSectionEnum = (isMerchant, isInventory);

var
  ShowResources: Boolean;
  CurrentParty: TParty;
  CloseSceneEnum: TSceneEnum;
  ActiveSection: TItemSectionEnum;
  InventorySelItemIndex: Integer;
  MerchantSelItemIndex: Integer;
  LeaderSelectedItemPrice: Integer;
  MerchantSelectedItemPrice: Integer;

  { TSceneMerchant }

class procedure TSceneMerchant.ShowScene(AParty: TParty;
  const ACloseSceneEnum: TSceneEnum);
begin
  CurrentParty := AParty;
  CloseSceneEnum := ACloseSceneEnum;
  ShowResources := AParty = TLeaderParty.Leader;
  ActiveSection := isMerchant;
  GetMerchantItemPrice;
  Game.Show(scMerchant);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

class procedure TSceneMerchant.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(CloseSceneEnum);
end;

procedure TSceneMerchant.BuyItem;
var
  LItem: TItemEnum;
  LPrice: Integer;
begin
  if TLeaderParty.Leader.Inventory.Count >= CMaxInventoryItems then
  begin
    InformDialog(CNoFreeSpace);
    Exit;
  end;
  LItem := Merchants.GetMerchant(mtPotions).Inventory.ItemEnum
    (MerchantSelItemIndex);
  if LItem = iNone then
    Exit;
  LPrice := TItemBase.Item(LItem).Price;
  if Game.Gold.Value < LPrice then
  begin
    InformDialog(CNotEnoughGold);
    Exit;
  end;
  Game.Gold.Modify(-LPrice);
  TLeaderParty.Leader.Inventory.Add(LItem);
  Merchants.GetMerchant(mtPotions).Inventory.Clear(MerchantSelItemIndex);
  Game.MediaPlayer.PlaySound(mmGold);
  Render;
end;

procedure TSceneMerchant.SellItem;
var
  LItem: TItemEnum;
  LPrice: Integer;
begin
  LItem := TLeaderParty.Leader.Inventory.ItemEnum(InventorySelItemIndex);
  if LItem = iNone then
    Exit;
  LPrice := GetLeaderItemPrice(LItem);
  if Merchants.GetMerchant(mtPotions).Gold < LPrice then
  begin
    InformDialog(CNotEnoughGold);
    Exit;
  end;
  Game.Gold.Modify(LPrice);
  Merchants.GetMerchant(mtPotions).ModifyGold(-LPrice);
  TLeaderParty.Leader.Inventory.Clear(InventorySelItemIndex);
  Game.MediaPlayer.PlaySound(mmGold);
  Render;
end;

procedure TSceneMerchant.ChSection;
begin
  ActiveSection := TItemSectionEnum((Ord(ActiveSection) + 1) mod 2);
  case ActiveSection of
    isInventory:
      GetLeaderItemPrice;
    isMerchant:
      GetMerchantItemPrice;
  end;
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
  LeaderSelectedItemPrice := 0;
  MerchantSelectedItemPrice := 0;
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
        if Button[btClose].MouseDown then
        begin
          HideScene;
          Exit;
        end;
        case ActiveSection of
          isInventory:
            SellItem;
          isMerchant:
            BuyItem;
        end;
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
    GetMerchantItemPrice;
  end;

  if MouseOver(X, Y, TFrame.Col(2) + 8, TFrame.Row(1) + 48, 320,
    TextLineHeight * CMaxInventoryItems) then
  begin
    ActiveSection := isInventory;
    InventorySelItemIndex := (Y - (TFrame.Row(1) + 48)) div TextLineHeight;
    GetLeaderItemPrice;
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
    if MerchantSelectedItemPrice > 0 then
    begin
      AddTextLine('Item Details', True);
      AddTextLine('');
      AddTextLine(Merchants.GetMerchant(mtPotions)
        .Inventory.ItemName(MerchantSelItemIndex));
      AddTextLine('Price: ' + IntToStr(MerchantSelectedItemPrice));
      AddTextLine('');
      if ActiveSection = isMerchant then
        AddTextLine('Press ENTER or CLICK item to buy');
    end;
  end;

  procedure RenderLeaderItemDetails;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Gold', True);
    AddTextLine('');
    AddTextLine(IntToStr(Game.Gold.Value));
    if LeaderSelectedItemPrice > 0 then
    begin
      AddTextLine('Item Details', True);
      AddTextLine('');
      AddTextLine(TLeaderParty.Leader.Inventory.ItemName
        (InventorySelItemIndex));
      AddTextLine('Price: ' + IntToStr(LeaderSelectedItemPrice));
      AddTextLine('');
      if ActiveSection = isInventory then
        AddTextLine('Press ENTER or CLICK item to sell');
    end;
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

function TSceneMerchant.GetLeaderItemPrice(const AItemEnum: TItemEnum): Integer;
begin
  Result := (TItemBase.Item(AItemEnum).Price div 30) * 10;
end;

class procedure TSceneMerchant.GetMerchantItemPrice;
var
  LItemEnum: TItemEnum;
begin
  if (MerchantSelItemIndex >= 0) and (MerchantSelItemIndex < CMaxInventoryItems)
  then
  begin
    LItemEnum := Merchants.GetMerchant(mtPotions)
      .Inventory.ItemEnum(MerchantSelItemIndex);
    if LItemEnum = iNone then
    begin
      MerchantSelectedItemPrice := 0;
      Exit;
    end;
    MerchantSelectedItemPrice := TItemBase.Item(LItemEnum).Price;
    if MerchantSelectedItemPrice < 1 then
      MerchantSelectedItemPrice := 1;
  end
  else
    MerchantSelectedItemPrice := 0;
end;

procedure TSceneMerchant.GetLeaderItemPrice;
var
  LItemEnum: TItemEnum;
begin
  if (InventorySelItemIndex >=0) and
    (InventorySelItemIndex < CMaxInventoryItems) then
  begin
    LItemEnum := TLeaderParty.Leader.Inventory.ItemEnum(InventorySelItemIndex);
    if LItemEnum = iNone then
    begin
      LeaderSelectedItemPrice := 0;
      Exit;
    end;
    LeaderSelectedItemPrice := GetLeaderItemPrice(LItemEnum);
    if LeaderSelectedItemPrice < 1 then
      LeaderSelectedItemPrice := 1;
  end
  else
    LeaderSelectedItemPrice := 0;
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
        GetLeaderItemPrice;
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
        GetMerchantItemPrice;
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
    K_LEFT, K_RIGHT, K_SPACE:
      ChSection;
  end;
end;

end.
