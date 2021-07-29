unit DisciplesRL.Items;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

// Предметы в Д1 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=328
// Предметы в Д2 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=223
// Список предм. -- https://www.ign.com/faqs/2005/disciples-ii-rise-of-the-elves-items-listfaq-677342
uses
  DisciplesRL.Resources;

type
  TItemType = (itSpecial, itValuable, itArtifact, itJewel,
    // Potions
    itTemporaryPotion, itPermanentPotion, itHealingPotion, itBoostPotion,
    // Scrolls
    itScroll,
    // Equipable
    itArmor, itWand, itOrb, itTalisman, itBoots, itBanner, itTome);

type
  TItemProp = (ipEquipable, ipConsumable, ipReadable, ipUsable, ipPermanent,
    ipTemporary);

type
  TItemEffect = (ieNone);

type
  TItemEnum = (iNone,
    // Valuables
    iBronzeRing, iSilverRing, iGoldRing, iEmerald, iRuby, iSapphire, iDiamond,
    iImperialCrown
    //
    );

type
  TItem = record
    Enum: TItemEnum;
    Name: string;
    Level: Integer;
    ItType: TItemType;
  end;

const
  MaxInventoryItems = 12;

type
  TInventory = class(TObject)
  private
    FItem: array [0 .. MaxInventoryItems - 1] of TItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    function Item(const I: Integer): TItem;
    function ItemEnum(const I: Integer): TItemEnum;
    procedure Add(const AItem: TItem); overload;
    procedure Add(const AItemEnum: TItemEnum); overload;
  end;

type
  TItemBase = class(TObject)
    class function Item(const ItemEnum: TItemEnum): TItem; overload;
    class function Item(const ItemIndex: Integer): TItem; overload;
    class function Count: Integer;
  end;

implementation

uses
  SysUtils;

const
  ItemBase: array [TItemEnum] of TItem = (
    // None
    (Enum: iNone; Name: ''; Level: 0; ItType: itSpecial;),
    // Bronze Ring
    (Enum: iBronzeRing; Name: 'Бронзовое Кольцо'; Level: 1;
    ItType: itValuable;),
    // Silver Ring
    (Enum: iSilverRing; Name: 'Серебряное Кольцо'; Level: 2;
    ItType: itValuable;),
    // Gold Ring
    (Enum: iGoldRing; Name: 'Золотое Кольцо'; Level: 3; ItType: itValuable;),
    // Emerald
    (Enum: iEmerald; Name: 'Изумруд'; Level: 4; ItType: itValuable;),
    // Ruby
    (Enum: iRuby; Name: 'Рубин'; Level: 5; ItType: itValuable;),
    // Sapphire
    (Enum: iSapphire; Name: 'Сапфир'; Level: 6; ItType: itValuable;),
    // Diamond
    (Enum: iDiamond; Name: 'Бриллиант'; Level: 7; ItType: itValuable;),
    // Imperial Crown
    (Enum: iImperialCrown; Name: 'Корона Империи'; Level: 8;
    ItType: itValuable;)
    //
    );

  { TInventory }

procedure TInventory.Add(const AItem: TItem);
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum = iNone then
    begin
      FItem[I] := AItem;
      Exit;
    end;
end;

procedure TInventory.Add(const AItemEnum: TItemEnum);
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum = iNone then
    begin
      FItem[I] := ItemBase[AItemEnum];
      Exit;
    end;
end;

procedure TInventory.Clear;
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    FItem[I] := ItemBase[iNone];
end;

function TInventory.Count: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum <> iNone then
      Inc(Result);
end;

constructor TInventory.Create;
begin
  Self.Clear;
end;

destructor TInventory.Destroy;
begin

  inherited;
end;

function TInventory.Item(const I: Integer): TItem;
begin
  Result := FItem[I];
end;

function TInventory.ItemEnum(const I: Integer): TItemEnum;
begin
  Result := FItem[I].Enum;
end;

{ TItemBase }

class function TItemBase.Count: Integer;
begin
  Result := Length(ItemBase);
end;

class function TItemBase.Item(const ItemEnum: TItemEnum): TItem;
begin
  Result := ItemBase[ItemEnum];
end;

class function TItemBase.Item(const ItemIndex: Integer): TItem;
begin
  Result := ItemBase[TItemEnum(ItemIndex)];
end;

end.
