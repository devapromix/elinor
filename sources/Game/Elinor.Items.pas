unit Elinor.Items;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

// https://www.ign.com/articles/2005/12/19/disciples-ii-rise-of-the-elves-items-listfaq-677342
// Предметы в Д1 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=328
// Предметы в Д2 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=223
uses
  Elinor.Resources;

type
  TItemType = (itSpecial, itValuable,
    // Potions and Scrolls
    itPotion, itScroll,
    // Equipable
    itRing, itArmor, itArtifact, itAmulet, itHelm, itWand, itOrb, itTalisman,
    itBoots, itBanner, itTome);

const
  ItemTypeName: array [TItemType] of string = ('', 'ценность', 'эликсир',
    'свиток', 'кольцо', 'доспех', 'артефакт', 'амулет', 'шлем', 'посох',
    'сфера', 'талисман', 'обувь', 'знамя', 'книга');

type
  TItemSlot = (isNone, isHelm, isAmulet, isBanner, isTome, isArmor, isRHand,
    isLHand, isRing, isArtifact, isBoots);

const
  SlotName: array [TItemSlot] of string = ('', 'Шлем', 'Амулет', 'Знамя',
    'Книга', 'Доспех', 'Правая рука', 'Левая рука', 'Кольцо',
    'Артефакт', 'Обувь');

type
  TItemProp = (ipEquipable, ipConsumable, ipReadable, ipUsable, ipPermanent,
    ipTemporary);

type
  TItemEffect = (ieNone);

type
  TJewlery = (jwNone, jwSteel, jwBronze, jwCopper, jwBrass, jwSilver, jwGold,
    jwAgate, jwOpal, jwAmethyst, jwRuby, jwEmerald, jwJade, jwPearl, jwQuartz,
    jwSapphire, jwDiamond);

type
  TItemEnum = (iNone,
    // Special
    iGold, iMana,
    // Valuables
    iRunicKey, iWotansScroll, iEmberSalts, iEmerald, iRuby, iSapphire, iDiamond,
    iAncientRelic,

    // Potions
    // iLifePotion,
    iPotionOfHealing,
    // iPotionOfRestoration, iHealingOintment,

    // Artifacts
    iDwarvenBracer, iRunestone, iHornOfAwareness, iSoulCrystal, iSkullBracers,
    iLuteOfCharming, iSkullOfThanatos, iBethrezensClaw,

    // iRunicBlade,
    // iWightBlade,
    // iUnholyDagger,
    // iThanatosBlade,
    // iHornOfIncubus,
    // iRoyalScepter

    // Orbs
    // iGoblinOrb, iImpOrb, iZombieOrb, iVampireOrb,
    // iLichOrb, iOrcOrb, iLizardManOrb, iElfLordOrb,
    // iOrbOfRestoration, iOrbOfRegeneration, iOrbOfHealing, iOrbOfLife,

    // Rings
    iStoneRing, iBronzeRing, iSilverRing, iGoldRing, iRingOfStrength,
    iRingOfTheAges, iRingOfHag, iThanatosRing,

    // Helms
    iTiaraOfPurity, iMjolnirsCrown, { ... } iImperialCrown);

type
  TItem = record
    Enum: TItemEnum;
    Name: string;
    Level: Integer;
    ItType: TItemType;
    ItSlot: TItemSlot;
    ItRes: TResEnum;
  end;

const
  MaxInventoryItems = 12;

type
  TInventory = class(TObject)
  private
    FItem: array [0 .. MaxInventoryItems - 1] of TItem;
  public
    constructor Create;
    procedure Clear; overload;
    procedure Clear(const I: Integer); overload;
    function Count: Integer;
    function Item(const I: Integer): TItem;
    function ItemEnum(const I: Integer): TItemEnum;
    procedure Add(const AItem: TItem); overload;
    procedure Add(const AItemEnum: TItemEnum); overload;
    function ItemName(const I: Integer): string;
  end;

const
  MaxEquipmentItems = 12;

const
  DollSlot: array [0 .. MaxEquipmentItems - 1] of TItemSlot = (isHelm, isAmulet,
    isBanner, isTome, isArmor, isRHand, isLHand, isRing, isRing, isArtifact,
    isArtifact, isBoots);

type
  TEquipment = class(TObject)
  private
    FItem: array [0 .. MaxEquipmentItems - 1] of TItem;
  public
    constructor Create;
    procedure Clear; overload;
    procedure Clear(const I: Integer); overload;
    function Item(const I: Integer): TItem;
    function ItemName(const I: Integer): string; overload;
    function ItemName(const I: Integer; const S: string): string; overload;
    procedure Add(const SlotIndex: Integer;
      const AItemEnum: TItemEnum); overload;
    function ItemSlotName(const I: Integer): string;
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
    (Enum: iNone; Name: ''; Level: 0; ItType: itSpecial; ItSlot: isNone;
    ItRes: reNone),

    // Special
    // Gold
    (Enum: iGold; Name: 'Gold'; Level: 1; ItType: itSpecial; ItSlot: isNone;
    ItRes: reItemGold),
    // Mana
    (Enum: iMana; Name: 'Mana'; Level: 1; ItType: itSpecial; ItSlot: isNone;
    ItRes: reItemMana),

    // Valuables
    // Runic Key
    (Enum: iRunicKey; Name: 'Runic Key'; Level: 1; ItType: itValuable;
    ItSlot: isNone; ItRes: reNone),
    // Wotan's Scroll
    (Enum: iWotansScroll; Name: 'Свиток Вотана'; Level: 2; ItType: itValuable;
    ItSlot: isNone; ItRes: reNone),
    // Ember Salts
    (Enum: iEmberSalts; Name: 'Ember Salts'; Level: 3; ItType: itValuable;
    ItSlot: isNone; ItRes: reNone),
    // Emerald
    (Enum: iEmerald; Name: 'Emerald'; Level: 4; ItType: itValuable;
    ItSlot: isNone; ItRes: reNone),
    // Ruby
    (Enum: iRuby; Name: 'Ruby'; Level: 5; ItType: itValuable; ItSlot: isNone;
    ItRes: reNone),
    // Sapphire
    (Enum: iSapphire; Name: 'Sapphire'; Level: 6; ItType: itValuable;
    ItSlot: isNone; ItRes: reNone),
    // Diamond
    (Enum: iDiamond; Name: 'Diamond'; Level: 7; ItType: itValuable;
    ItSlot: isNone; ItRes: reNone),
    // Ancient Relic
    (Enum: iAncientRelic; Name: 'Ancient Relic'; Level: 8; ItType: itValuable;
    ItSlot: isNone; ItRes: reNone),

    // Potions
    // Potion of Healing
    (Enum: iPotionOfHealing; Name: 'Potion of Healing'; Level: 1;
    ItType: itPotion; ItSlot: isNone; ItRes: reItemPotionOfHealing),

    // Artifacts
    // Dwarven Bracer
    (Enum: iDwarvenBracer; Name: 'Dwarven Bracer'; Level: 1; ItType: itArtifact;
    ItSlot: isArtifact; ItRes: reNone),
    // Runestone
    (Enum: iRunestone; Name: 'Runestone'; Level: 2; ItType: itArtifact;
    ItSlot: isArtifact; ItRes: reNone),
    // Horn Of Awareness
    (Enum: iHornOfAwareness; Name: 'Horn Of Awareness'; Level: 3;
    ItType: itArtifact; ItSlot: isArtifact; ItRes: reNone),
    // Soul Crystal
    (Enum: iSoulCrystal; Name: 'Soul Crystal'; Level: 4; ItType: itArtifact;
    ItSlot: isArtifact; ItRes: reNone),
    // Skull Bracers
    (Enum: iSkullBracers; Name: 'Skull Bracers'; Level: 5; ItType: itArtifact;
    ItSlot: isArtifact; ItRes: reNone),
    // Lute Of Charming
    (Enum: iLuteOfCharming; Name: 'Lute Of Charming'; Level: 6;
    ItType: itArtifact; ItSlot: isArtifact; ItRes: reNone),
    // Skull Of Thanatos
    (Enum: iSkullOfThanatos; Name: 'Skull Of Thanatos'; Level: 7;
    ItType: itArtifact; ItSlot: isArtifact; ItRes: reNone),
    // Bethrezen's Claw
    (Enum: iBethrezensClaw; Name: 'Коготь Бетрезена'; Level: 8;
    ItType: itArtifact; ItSlot: isArtifact; ItRes: reNone),

    // Rings
    // Stone Ring
    (Enum: iStoneRing; Name: 'Stone Ring'; Level: 1; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),
    // Bronze Ring
    (Enum: iBronzeRing; Name: 'Бронзовое Кольцо'; Level: 2; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),
    // Silver Ring
    (Enum: iSilverRing; Name: 'Серебрянное Кольцо'; Level: 3; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),
    // Gold Ring
    (Enum: iGoldRing; Name: 'Золотое Кольцо'; Level: 4; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),
    // Ring Of Strength,
    (Enum: iRingOfStrength; Name: 'Кольцо Силы'; Level: 5; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),
    // Ring Of The Ages,
    (Enum: iRingOfTheAges; Name: 'Кольцо Веков'; Level: 6; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),
    // Hag's Ring,
    (Enum: iRingOfHag; Name: 'Кольцо Ведьмы'; Level: 7; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),
    // Thanatos Ring
    (Enum: iThanatosRing; Name: 'Кольцо Танатоса'; Level: 8; ItType: itRing;
    ItSlot: isRing; ItRes: reNone),

    // Helms
    // Tiara Of Purity
    (Enum: iTiaraOfPurity; Name: 'Тиара Чистоты'; Level: 5; ItType: itHelm;
    ItSlot: isHelm; ItRes: reNone),
    // Mjolnir's Crown
    (Enum: iMjolnirsCrown; Name: 'Корона Мьельнира'; Level: 6; ItType: itHelm;
    ItSlot: isHelm; ItRes: reNone),
    // Imperial Crown
    (Enum: iImperialCrown; Name: 'Корона Империи'; Level: 8; ItType: itHelm;
    ItSlot: isHelm; ItRes: reNone));

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
    Clear(I);
end;

procedure TInventory.Clear(const I: Integer);
begin
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

function TInventory.Item(const I: Integer): TItem;
begin
  Result := FItem[I];
end;

function TInventory.ItemEnum(const I: Integer): TItemEnum;
begin
  Result := FItem[I].Enum;
end;

function TInventory.ItemName(const I: Integer): string;
begin
  if (FItem[I].Name <> '') then
    Result := Format(' %s (%s)', [FItem[I].Name, ItemTypeName[FItem[I].ItType]])
  else
    Result := '';
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

{ TEquipment }

procedure TEquipment.Add(const SlotIndex: Integer; const AItemEnum: TItemEnum);
begin
  FItem[SlotIndex] := ItemBase[AItemEnum];
end;

procedure TEquipment.Clear;
var
  I: Integer;
begin
  for I := 0 to MaxEquipmentItems - 1 do
    Clear(I);
end;

procedure TEquipment.Clear(const I: Integer);
begin
  FItem[I] := ItemBase[iNone];
end;

constructor TEquipment.Create;
begin
  Self.Clear;
end;

function TEquipment.Item(const I: Integer): TItem;
begin
  Result := FItem[I];
end;

function TEquipment.ItemName(const I: Integer; const S: string): string;
begin
  Result := Format(' %s: %s', [ItemSlotName(I), S]);
end;

function TEquipment.ItemName(const I: Integer): string;
begin
  Result := Format(' %s: %s', [ItemSlotName(I), FItem[I].Name]);
end;

function TEquipment.ItemSlotName(const I: Integer): string;
begin
  Result := SlotName[DollSlot[I]];
end;

end.
