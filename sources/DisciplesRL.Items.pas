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
  TItemType = (itSpecial, itValuable,
    // Potions
    itTemporaryPotion, itPermanentPotion, itHealingPotion, itBoostPotion,
    // Scrolls
    itScroll,
    // Equipable
    itRing, itArmor, itArtifact, itAmulet, itHelm, itWand, itOrb, itTalisman,
    itBoots, itBanner, itTome);

type
  TItemProp = (ipEquipable, ipConsumable, ipReadable, ipUsable, ipPermanent,
    ipTemporary);

type
  TItemEffect = (ieNone);

type
  TItemEnum = (iNone,
    // Valuables
    iRunicKey, iWotansScroll, iEmberSalts, iEmerald, iRuby, iSapphire, iDiamond,
    iAncientRelic,

    // Artifacts
    iDwarvenBracer, iRunestone, iHornOfAwareness, iSoulCrystal, iSkullBracers,
    iLuteOfCharming, iSkullOfThanatos, iBethrezensClaw,

    // iRunicBlade,
    // iWightBlade,
    // iUnholyDagger,
    // iThanatosBlade,
    // iHornOfIncubus,
    // iRoyalScepter

    // Rings
    iStoneRing,
    // iBronzeRing, iSilverRing, iGoldRing,
    // iRingOfStrength, iRingOfTheAges, iHagsRing, iThanatosRing

    // Helms
    iTiaraOfPurity, iMjolnirsCrown, { ... } iImperialCrown);

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
    function Item(const i: Integer): TItem;
    function ItemEnum(const i: Integer): TItemEnum;
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

    // Valuables
    // Runic Key
    (Enum: iRunicKey; Name: 'Рунический Ключ'; Level: 1; ItType: itValuable;),
    // Wotan's Scroll
    (Enum: iWotansScroll; Name: 'Свиток Вотана'; Level: 2; ItType: itValuable;),
    // Ember Salts
    (Enum: iEmberSalts; Name: 'Тлеющая Соль'; Level: 3; ItType: itValuable;),
    // Emerald
    (Enum: iEmerald; Name: 'Изумруд'; Level: 4; ItType: itValuable;),
    // Ruby
    (Enum: iRuby; Name: 'Рубин'; Level: 5; ItType: itValuable;),
    // Sapphire
    (Enum: iSapphire; Name: 'Сапфир'; Level: 6; ItType: itValuable;),
    // Diamond
    (Enum: iDiamond; Name: 'Бриллиант'; Level: 7; ItType: itValuable;),
    // Ancient Relic
    (Enum: iAncientRelic; Name: 'Древняя Реликвия'; Level: 8;
    ItType: itValuable;),

    // Artifacts
    // Dwarven Bracer
    (Enum: iDwarvenBracer; Name: 'Гномьи Наручи'; Level: 1;
    ItType: itArtifact;),
    // Runestone
    (Enum: iRunestone; Name: 'Рунный Камень'; Level: 2; ItType: itArtifact;),
    // Horn Of Awareness
    (Enum: iHornOfAwareness; Name: 'Рог Чистого Сознания'; Level: 3;
    ItType: itArtifact;),
    // Soul Crystal
    (Enum: iSoulCrystal; Name: 'Кристалл Души'; Level: 4; ItType: itArtifact;),
    // Skull Bracers
    (Enum: iSkullBracers; Name: 'Браслет из Черепов'; Level: 5;
    ItType: itArtifact;),
    // Lute Of Charming
    (Enum: iLuteOfCharming; Name: 'Лютня Обаяния'; Level: 6;
    ItType: itArtifact;),
    // Skull Of Thanatos
    (Enum: iSkullOfThanatos; Name: 'Череп Танатоса'; Level: 7;
    ItType: itArtifact;),
    // Bethrezen's Claw
    (Enum: iBethrezensClaw; Name: 'Коготь Бетрезена'; Level: 8;
    ItType: itArtifact;),

    // Rings
    // Stone Ring
    (Enum: iStoneRing; Name: 'Каменное Кольцо'; Level: 1; ItType: itRing;),

    // Helms
    // Tiara Of Purity
    (Enum: iTiaraOfPurity; Name: 'Тиара Чистоты'; Level: 5; ItType: itHelm;),
    // Mjolnir's Crown
    (Enum: iMjolnirsCrown; Name: 'Корона Мьельнира'; Level: 6; ItType: itHelm;),

    // Imperial Crown
    (Enum: iImperialCrown; Name: 'Корона Империи'; Level: 8; ItType: itHelm;));

  { TInventory }

procedure TInventory.Add(const AItem: TItem);
var
  i: Integer;
begin
  for i := 0 to MaxInventoryItems - 1 do
    if FItem[i].Enum = iNone then
    begin
      FItem[i] := AItem;
      Exit;
    end;
end;

procedure TInventory.Add(const AItemEnum: TItemEnum);
var
  i: Integer;
begin
  for i := 0 to MaxInventoryItems - 1 do
    if FItem[i].Enum = iNone then
    begin
      FItem[i] := ItemBase[AItemEnum];
      Exit;
    end;
end;

procedure TInventory.Clear;
var
  i: Integer;
begin
  for i := 0 to MaxInventoryItems - 1 do
    FItem[i] := ItemBase[iNone];
end;

function TInventory.Count: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to MaxInventoryItems - 1 do
    if FItem[i].Enum <> iNone then
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

function TInventory.Item(const i: Integer): TItem;
begin
  Result := FItem[i];
end;

function TInventory.ItemEnum(const i: Integer): TItemEnum;
begin
  Result := FItem[i].Enum;
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
