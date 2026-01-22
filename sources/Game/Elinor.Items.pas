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

// Effects:

// Tome:
// All the units in the party gain 25% more experience in battle
// Leader can use Orbs
// Leader can use Talismans

// 40% Better chance of finding magic items
// 2% Chance of critical hit
// Magic damage reduced by 2
// Damage reduced by 2
// Attacker takes lightning damage of 4
// Causes an enemy unit to flee from battle
// Polymorphs enemy unit
// 10% Increased chance of blocking (shield)
// Increase maximum hp 5%
// Attacker takes damage of 3
// 3% Life stolen per hit
// Paralyzes enemy unit
// Revives dead units
// Units inflict 25% more damage
// Increases the initiative by 10%
// Transforms enemy unit into imps
// Increases the damage inflicted by 10%
// 10% greater chance to hit
// Adds 15% hit points
// Receive 10% less damage from attacks
// 15% greater chance to hit
// Inflict 30% more damage
// Prevent monster heal
// 37% Extra gold from monsters
// Leader gains a vampiric attack: his attacks heal him
// Petrifies enemy unit
// Leader inflicts 10% more damage
// Leader receives 25% less damage from attacks
// Leader is unaffected by thieves
// 10% lower prices from merchants and mercenaries

type
  TItemType = (itSpecial, itValuable,
    // Consumable
    itPotion, itElixir, itEssence, itFlask, itScroll,
    // Equipable
    itRing, itArmor, itArtifact, itAmulet, itHelm, itWand, itOrb, itTalisman,
    itBoots, itBanner, itTome);

const
  CUseItemType = [itPotion, itOrb, itFlask, itTalisman];

const
  ItemTypeName: array [TItemType] of string = ('', 'valuable', 'potion',
    'elixir', 'essence', 'flask', 'scroll', 'ring', 'armor', 'artifact',
    'amulet', 'helm', 'staff', 'orb', 'talisman', 'boots', 'banner', 'book');

type
  TItemSlot = (isNone, isHelm, isAmulet, isBanner, isTome, isArmor, isRHand,
    isLHand, isRing, isArtifact, isBoots);

const
  SlotName: array [TItemSlot] of string = ('', 'Helm', 'Amulet', 'Banner',
    'Tome', 'Armor', 'Right hand', 'Left hand', 'Ring', 'Artifact', 'Boots');

type
  TItemProp = (ipEquipable, ipConsumable, ipReadable, ipUsable, ipPermanent,
    ipTemporary);

type
  TItemEffect = (ieNone,
    // Regeneration
    ieRegen5, ieRegen10, ieRegen15, ieRegen20, ieRegen25,
    // Chance to paralyze
    ieChanceToParalyze5, ieChanceToParalyze10, ieChanceToParalyze15,
    // Vampiric attack
    ieVampiricAttack10, ieVampiricAttack15, ieVampiricAttack20,
    ieVampiricAttack25,
    // Gain more experience
    ieGain20MoreExp,
    // Leader gains more move points
    ieGains20MoreMovePoints, ieGains40MoreMovePoints, ieGains60MoreMovePoints,
    ieGains80MoreMovePoints, ieGains100MoreMovePoints,
    // Invisible
    ieInvisible
    //
    );

type
  TJewlery = (jwNone, jwSteel, jwBronze, jwCopper, jwBrass, jwSilver, jwGold,
    jwAgate, jwOpal, jwAmethyst, jwRuby, jwEmerald, jwJade, jwPearl, jwQuartz,
    jwSapphire, jwDiamond);

type
  TItemEnum = (iNone,
    // SPECIAL
    iGold, iMana,

    // SCENARIO
    iStoneTab,

    // VALUABLES
    iRunicKey, iArcaneScroll, iEmberSalts, iEmerald, iRuby, iSapphire, iDiamond,
    iAncientRelic,

    // POTIONS
    iLifePotion, iPotionOfHealing, iPotionOfRestoration, iHealingOintment,

    // ELIXIRS


    // ESSENCES

    // FLASK
    iAcidFlask,

    // ARTIFACTS
    iDwarvenBracer, iRunestone, iHornOfAwareness, iIceCrystal, iSkullBracers,
    iLuteOfCharming, iSkullOfThanatos, iBethrezensClaw,

    // iRunicBlade,
    // iWightBlade,
    // iUnholyDagger,
    // iThanatosBlade,
    iHornOfIncubus,
    // iRoyalScepter

    // AMULETS
    iNecklaceOfBloodbind, iHeartOfDarkness,

    // ARMORS
    iShroudOfDarkness,

    // BOOTS
    iBootsOfSpeed, iElvenBoots, iBootsOfHaste, iBootsOfDarkness,
    iBootsOfTravelling, iBootsOfTheElements, iBootsOfSevenLeagues,

    // TALISMANS
    iTalismanOfRestoration, iTalismanOfVigor, iTalismanOfProtection,
    iTalismanOfNosferat, iTalismanOfFear, iTalismanOfRage, iTalismanOfCelerity,

    // BANNERS

    // TOMES
    iTomeOfWar,

    // ORBS
    iGoblinOrb, iOrbOfHealing, iImpOrb, iSkeletonOrb, iOrbOfRestoration,
    iZombieOrb, iOrbOfLife, iLizardmanOrb, iOrbOfWitches,

    // RINGS
    iStoneRing, iBronzeRing, iSilverRing, iGoldRing, iRingOfStrength,
    iRingOfTheAges, iRingOfHag, iThanatosRing,

    // HELMS
    iHoodOfDarkness, iTiaraOfPurity, iMjolnirsCrown, iThirstbornDiadem,
    iImperialCrown);

const
  CQuaffItems = [iLifePotion, iPotionOfHealing, iPotionOfRestoration,
    iHealingOintment];
  CTestItems = [iAcidFlask];

type
  TSetItemsEnum = (siCoverOfDarkness);

type
  TSetItems = record
    Name: string;
    Items: array of TItemEnum;
  end;

type
  TItem = record
    Enum: TItemEnum;
    Name: string;
    Level: Integer;
    ItType: TItemType;
    ItEffect: TItemEffect;
    ItSlot: TItemSlot;
    ItRes: TItemResEnum;
    Price: Integer;
    Description: string;
  end;

const
  CMaxInventoryItems = 12;

type
  TInventory = class(TObject)
  private
    FItem: array [0 .. CMaxInventoryItems - 1] of TItem;
    procedure AddTestItems;
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
  CMaxEquipmentItems = 12;

const
  DollSlot: array [0 .. CMaxEquipmentItems - 1] of TItemSlot = (isHelm,
    isAmulet, isBanner, isTome, isArmor, isRHand, isLHand, isRing, isRing,
    isArtifact, isArtifact, isBoots);

type
  TEquipment = class(TObject)
  private
    FItem: array [0 .. CMaxEquipmentItems - 1] of TItem;
    procedure Update;
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
    function LHandSlotItem: TItem;
  end;

type
  TItemBase = class(TObject)
    class function Item(const ItemEnum: TItemEnum): TItem; overload;
    class function Item(const ItemIndex: Integer): TItem; overload;
    class function Count: Integer;
  end;

const
  CSetItems: array [TSetItemsEnum] of TSetItems = (
    // Cover Of Darkness
    (Name: 'Cover Of Darkness'; Items: [iHoodOfDarkness, iHeartOfDarkness,
    iShroudOfDarkness, iBootsOfDarkness])
    //
    );

implementation

uses
  SysUtils,
  Elinor.Party;

const
  ItemBase: array [TItemEnum] of TItem = (
    // None
    (Enum: iNone; Name: ''; Level: 0; ItType: itSpecial; ItEffect: ieNone;
    ItSlot: isNone; ItRes: irNone; Price: 0; Description: ''),

    // SPECIAL
    // Gold
    (Enum: iGold; Name: 'Gold'; Level: 1; ItType: itSpecial; ItEffect: ieNone;
    ItSlot: isNone; ItRes: irItemGold; Price: 0;
    Description: 'A shiny gold coin, valued' +
    ' by merchants and traders across the land'),
    // Mana
    (Enum: iMana; Name: 'Mana'; Level: 1; ItType: itSpecial; ItEffect: ieNone;
    ItSlot: isNone; ItRes: irItemMana; Price: 0;
    Description: 'A shimmering crystal pulsating with magical energy'),

    // SCENARIO
    // Stone Tablet
    (Enum: iStoneTab; Name: 'Stone Tablet'; Level: 1; ItType: itSpecial;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irItemStoneTablet; Price: 0;
    Description: 'An ancient stone tablet etched with forgotten knowledge.' +
    ' Its inscriptions hold the wisdom of past civilizations'),

    // VALUABLES
    // (1) Runic Key
    (Enum: iRunicKey; Name: 'Runic Key'; Level: 1; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irRunicKey; Price: 100;
    Description: 'An ancient key engraved with glowing runes.' +
    ' Unlocks hidden paths and sealed doors'),
    // (2) Arcane Scroll
    (Enum: iArcaneScroll; Name: 'Arcane Scroll'; Level: 2; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irItemArcaneScroll; Price: 200;
    Description: 'A used magical scroll, its words faded,' +
    ' yet a trace of its power still lingers'),
    // (3) Ember Salts
    (Enum: iEmberSalts; Name: 'Ember Salts'; Level: 3; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irEmberSalts; Price: 300;
    Description: 'Glowing embers crystallized into fine salts.' +
    ' Used in powerful alchemical rituals'),
    // (4) Emerald
    (Enum: iEmerald; Name: 'Emerald'; Level: 4; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irEmerald; Price: 400;
    Description: 'A vibrant green gem, expertly cut' +
    ' and highly prized for its rich color'),
    // (5) Ruby
    (Enum: iRuby; Name: 'Ruby'; Level: 5; ItType: itValuable; ItEffect: ieNone;
    ItSlot: isNone; ItRes: irRuby; Price: 550;
    Description: 'A fiery red gemstone that blazes with inner light.' +
    ' Symbolizes passion and power in many cultures'),
    // (6) Sapphire
    (Enum: iSapphire; Name: 'Sapphire'; Level: 6; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irSaphire; Price: 750;
    Description: 'Deep blue stone embodying the sea and sky,' +
    ' prized for its royal beauty and mystique'),
    // (7) Diamond
    (Enum: iDiamond; Name: 'Diamond'; Level: 7; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irDiamond; Price: 850;
    Description
    : 'The most precious of stones, a crystalline marvel of pure light.' +
    ' Rare, unyielding, and incredibly valuable'),
    // (8) Ancient Relic
    (Enum: iAncientRelic; Name: 'Ancient Relic'; Level: 8; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irNone; Price: 1000;
    Description: 'An old and weathered object from a bygone age,' +
    ' holding secrets of the past'),

    // POTIONS
    // (1) Life Potion
    (Enum: iLifePotion; Name: 'Life Potion'; Level: 1; ItType: itPotion;
    ItEffect: ieNone; ItSlot: isNone; ItRes: irItemLifePotion; Price: 250;
    Description: 'A powerful elixir that restores life,' +
    ' bringing the dead back to the world of the living'),
    // (1) Potion of Healing
    (Enum: iPotionOfHealing; Name: 'Potion of Healing'; Level: 1;
    ItType: itPotion; ItEffect: ieNone; ItSlot: isNone;
    ItRes: irItemPotionOfHealing; Price: 100;
    Description: 'A soothing potion that restores' +
    ' health and heals wounds'),
    // (2) Potion of Restoration
    (Enum: iPotionOfRestoration; Name: 'Potion of Restoration'; Level: 2;
    ItType: itPotion; ItEffect: ieNone; ItSlot: isNone;
    ItRes: irItemPotionOfRestoration; Price: 200;
    Description: 'A potent potion that' +
    ' greatly restores health and accelerates healing'),
    // (3) Healing Ointment
    (Enum: iHealingOintment; Name: 'Healing Ointment'; Level: 3;
    ItType: itPotion; ItEffect: ieNone; ItSlot: isNone;
    ItRes: irItemHealingOintment; Price: 400;
    Description: 'A crimson nectar that fills the body with energy,' +
    ' healing wounds and restoring strength.'),

    // ELIXIRS

    // ESSENCES

    // FLASKS
    // (4) Acid Flask
    (Enum: iAcidFlask; Name: 'Acid Flask'; Level: 4; ItType: itFlask;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irAcidFlask; Price: 250;
    Description: ''),

    // ARTIFACTS
    // (1) Dwarven Bracer
    (Enum: iDwarvenBracer; Name: 'Dwarven Bracer'; Level: 1; ItType: itArtifact;
    ItEffect: ieRegen5; ItSlot: isArtifact; ItRes: irDwarvenBracer; Price: 250;
    Description: ''),
    // (2) Runestone
    (Enum: iRunestone; Name: 'Runestone'; Level: 2; ItType: itArtifact;
    ItEffect: ieRegen20; ItSlot: isArtifact; ItRes: irRunestone; Price: 400;
    Description: 'A mystical runestone that enhances' +
    ' natural health regeneration'),
    // (3) Horn Of Awareness
    (Enum: iHornOfAwareness; Name: 'Horn Of Awareness'; Level: 3;
    ItType: itArtifact; ItEffect: ieNone; ItSlot: isArtifact;
    ItRes: irHornOfAwareness; Price: 500; Description: ''),
    // (4) Ice Crystal
    (Enum: iIceCrystal; Name: 'Ice Crystal'; Level: 4; ItType: itArtifact;
    ItEffect: ieChanceToParalyze10; ItSlot: isArtifact; ItRes: reItemIceCrystal;
    Price: 650; Description: ''),
    // (5) Skull Bracers
    (Enum: iSkullBracers; Name: 'Skull Bracers'; Level: 5; ItType: itArtifact;
    ItEffect: ieNone; ItSlot: isArtifact; ItRes: irNone; Price: 750;
    Description: ''),
    // (6) Lute Of Charming
    (Enum: iLuteOfCharming; Name: 'Lute Of Charming'; Level: 6;
    ItType: itArtifact; ItEffect: ieNone; ItSlot: isArtifact; ItRes: irNone;
    Price: 1000; Description: ''),
    // (7) Skull Of Thanatos
    (Enum: iSkullOfThanatos; Name: 'Skull Of Thanatos'; Level: 7;
    ItType: itArtifact; ItEffect: ieChanceToParalyze15; ItSlot: isArtifact;
    ItRes: irNone; Price: 1250; Description: ''),
    // (8) Bethrezen's Claw
    (Enum: iBethrezensClaw; Name: 'Bethrezen''s Claw'; Level: 8;
    ItType: itArtifact; ItEffect: ieNone; ItSlot: isArtifact;
    ItRes: irBethrezensClaw; Price: 1500; Description: ''),
    // (8) Horn Of Incubus
    (Enum: iHornOfIncubus; Name: 'Horn Of Incubus'; Level: 8;
    ItType: itArtifact; ItEffect: ieNone; ItSlot: isArtifact;
    ItRes: irHornOfIncubus; Price: 1700; Description: ''),

    // AMULETS
    // (3) Necklace of Bloodbind
    (Enum: iNecklaceOfBloodbind; Name: 'Necklace of Bloodbind'; Level: 3;
    ItType: itAmulet; ItEffect: ieVampiricAttack10; ItSlot: isAmulet;
    ItRes: irItemAmuletOfBloodbind; Price: 900;
    Description: 'This amulet grants its' + ' wearer the power ' +
    'to drink the life of ' + 'their enemies'),
    // (4) Heart of Darkness
    (Enum: iHeartOfDarkness; Name: 'Heart of Darkness'; Level: 4;
    ItType: itAmulet; ItEffect: ieInvisible; ItSlot: isAmulet;
    ItRes: irHeartOfDarkness; Price: 1200;
    Description: 'A beating heart of endless darkness'),

    // ARMORS
    // (4) Shroud of Darkness
    (Enum: iShroudOfDarkness; Name: 'Shroud of Darkness'; Level: 4;
    ItType: itArmor; ItEffect: ieInvisible; ItSlot: isArmor;
    ItRes: irShroudOfDarkness; Price: 800;
    Description: 'A living shadow wrapped' + ' around its bearer'),

    // BOOTS
    // (1) Boots of Speed
    (Enum: iBootsOfSpeed; Name: 'Boots of Speed'; Level: 1; ItType: itBoots;
    ItEffect: ieGains20MoreMovePoints; ItSlot: isBoots; ItRes: irBootsOfSpeed;
    Price: 400; Description: 'Leader gains 20% more move points'),
    // (2) Elven Boots
    (Enum: iElvenBoots; Name: 'Elven Boots'; Level: 2; ItType: itBoots;
    ItEffect: ieNone; ItSlot: isBoots; ItRes: irElvenBoots; Price: 500;
    Description: 'No move penalty when ' + 'walking in forests'),
    // (3) Boots Of Haste
    (Enum: iBootsOfHaste; Name: 'Boots of Haste'; Level: 3; ItType: itBoots;
    ItEffect: ieGains40MoreMovePoints; ItSlot: isBoots; ItRes: irBootsOfHaste;
    Price: 600; Description: 'Leader gains 40% more move points'),
    // (4) Boots Of Darkness
    (Enum: iBootsOfDarkness; Name: 'Boots of Darkness'; Level: 4;
    ItType: itBoots; ItEffect: ieInvisible; ItSlot: isBoots;
    ItRes: irBootsOfDarkness; Price: 700;
    Description: 'The leader who wears ' + 'these shoes becomes ' +
    'invisible to enemies'),
    // (5) Boots Of Travelling
    (Enum: iBootsOfTravelling; Name: 'Boots of Travelling'; Level: 5;
    ItType: itBoots; ItEffect: ieGains60MoreMovePoints; ItSlot: isBoots;
    ItRes: irBootsOfTravelling; Price: 800;
    Description: 'Leader gains 60% more move points'),
    // (6) Boots Of The Elements
    (Enum: iBootsOfTheElements; Name: 'Boots of the Elements'; Level: 6;
    ItType: itBoots; ItEffect: ieNone; ItSlot: isBoots;
    ItRes: irBootsOfTheElements; Price: 900;
    Description: 'No move penalty when sailing on water'),
    // (7) Boots Of Seven Leagues
    (Enum: iBootsOfSevenLeagues; Name: 'Boots of Seven Leagues'; Level: 7;
    ItType: itBoots; ItEffect: ieGains80MoreMovePoints; ItSlot: isBoots;
    ItRes: irBootsOfSevenLeagues; Price: 1000;
    Description: 'Leader gains 80% more move points'),

    // TALISMANS
    // (1) Talisman of Restoration
    (Enum: iTalismanOfRestoration; Name: 'Talisman of Restoration'; Level: 1;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand;
    ItRes: irTalismanOfRestoration; Price: 450;
    Description: 'Heals the Leader for 55 hp'),
    // (2) Talisman of Vigor
    (Enum: iTalismanOfVigor; Name: 'Talisman of Vigor'; Level: 2;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand;
    ItRes: irTalismanOfVigor; Price: 600;
    Description: 'Leader inflict 25% more damage'),
    // (3) Talisman of Protection
    (Enum: iTalismanOfProtection; Name: 'Talisman of Protection'; Level: 3;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand;
    ItRes: irTalismanOfProtection; Price: 750;
    Description: 'Leader receives 10% less damage from attacks'),
    // (4) Talisman of Nosferat
    (Enum: iTalismanOfNosferat; Name: 'Talisman of Nosferat'; Level: 4;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand;
    ItRes: irTalismanOfNosferat; Price: 900;
    Description: 'Drains 25 hp of life from enemy units'),
    // (5) Talisman of Fear
    (Enum: iTalismanOfFear; Name: 'Talisman of Fear'; Level: 5;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand;
    ItRes: irTalismanOfFear; Price: 1050; Description: 'Paralyzes enemy unit'),
    // (6) Talisman of Rage
    (Enum: iTalismanOfRage; Name: 'Talisman of Rage'; Level: 6;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand;
    ItRes: irTalismanOfRage; Price: 1200; Description: 'Gives an extra attack'),
    // (7) Talisman of Celerity
    (Enum: iTalismanOfCelerity; Name: 'Talisman of Celerity'; Level: 7;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand;
    ItRes: irTalismanOfCelerity; Price: 1350;
    Description: 'Grants the Leader 20% increased initiative'),

    // TOMES
    // (3) Tome of War
    (Enum: iTomeOfWar; Name: 'Tome of War'; Level: 3; ItType: itTome;
    ItEffect: ieGain20MoreExp; ItSlot: isTome; ItRes: irItemTomeOfWar;
    Price: 2500; Description: 'All the units in the party gain 20% ' +
    'more experience in battle'),

    // ORBS
    // (1) Goblin Orb
    (Enum: iGoblinOrb; Name: 'Goblin Orb'; Level: 1; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irGoblinOrb; Price: 200;
    Description: 'Summon a Goblin'),
    // (2) Orb Of Healing
    (Enum: iOrbOfHealing; Name: 'Orb Of Healing'; Level: 2; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irOrbOfHealing; Price: 250;
    Description: 'Heals units 50 hp'),
    // (3) Imp Orb
    (Enum: iImpOrb; Name: 'Imp Orb'; Level: 3; ItType: itOrb; ItEffect: ieNone;
    ItSlot: isLHand; ItRes: irImpOrb; Price: 350; Description: 'Summon an Imp'),
    // (4) Skeleton Orb
    (Enum: iSkeletonOrb; Name: 'Skeleton Orb'; Level: 4; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irSkeletonOrb; Price: 400;
    Description: 'Summon a Skeleton Warrior'),
    // (4) Orb Of Restoration
    (Enum: iOrbOfRestoration; Name: 'Orb Of Restoration'; Level: 4;
    ItType: itOrb; ItEffect: ieNone; ItSlot: isLHand; ItRes: irOrbOfRestoration;
    Price: 500; Description: 'Heals units 100 hp'),
    // (5) Zombie Orb
    (Enum: iZombieOrb; Name: 'Zombie Orb'; Level: 5; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irZombieOrb; Price: 600;
    Description: 'Summon a Zombie'),
    // (6) Orb Of Life
    (Enum: iOrbOfLife; Name: 'Orb of Life'; Level: 6; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irOrbOfLife; Price: 750;
    Description: 'Revives dead units'),
    // (7) Lizardman Orb
    (Enum: iLizardmanOrb; Name: 'Lizardman Orb'; Level: 7; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irLizardmanOrb; Price: 850;
    Description: 'Summon a Lizardman'),
    // (8) Orb of Witches
    (Enum: iOrbOfWitches; Name: 'Orb of Witches'; Level: 8; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: irOrbOfWitches; Price: 1000;
    Description: 'Polymorphs an enemy unit'),

    // RINGS
    // (1) Stone Ring
    (Enum: iStoneRing; Name: 'Stone Ring'; Level: 1; ItType: itRing;
    ItEffect: ieRegen5; ItSlot: isRing; ItRes: irStoneRing; Price: 300;
    Description: 'A stone ring with a faint glow,' +
    ' holding dormant magical energy'),
    // (2) Bronze Ring
    (Enum: iBronzeRing; Name: 'Bronze Ring'; Level: 2; ItType: itRing;
    ItEffect: ieRegen10; ItSlot: isRing; ItRes: irBronzeRing; Price: 400;
    Description: 'A simple bronze ring,' + ' sturdy and unassuming'),
    // (3) Silver Ring
    (Enum: iSilverRing; Name: 'Silver Ring'; Level: 3; ItType: itRing;
    ItEffect: ieRegen15; ItSlot: isRing; ItRes: irSilverRing; Price: 500;
    Description: 'A sleek silver ring,' +
    ' reflecting a subtle, elegant shine'),
    // (4) Gold Ring
    (Enum: iGoldRing; Name: 'Gold Ring'; Level: 4; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: irGoldRing; Price: 700;
    Description: 'A luxurious gold ring,' +
    ' gleaming with wealth and prestige'),
    // (5) Ring Of Strength,
    (Enum: iRingOfStrength; Name: 'Ring Of Strength'; Level: 5; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: irRingOfStrength; Price: 900;
    Description: 'A massive ring pulses ' + 'with hidden energy'),
    // (6) Ring Of The Ages,
    (Enum: iRingOfTheAges; Name: 'Ring Of The Ages'; Level: 6; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: irNone; Price: 1000;
    Description: ''),
    // (7) Hag's Ring,
    (Enum: iRingOfHag; Name: 'Ring of Hag'; Level: 7; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: irHagsRing; Price: 1200;
    Description: ''),
    // (8) Thanatos Ring
    (Enum: iThanatosRing; Name: 'Thanatos Ring'; Level: 8; ItType: itRing;
    ItEffect: ieChanceToParalyze5; ItSlot: isRing; ItRes: irNone; Price: 1500;
    Description: ''),

    // HELMS
    // (4) Hood Of Darkness
    (Enum: iHoodOfDarkness; Name: 'Hood Of Darkness'; Level: 4; ItType: itHelm;
    ItEffect: ieInvisible; ItSlot: isHelm; ItRes: irHoodOfDarkness; Price: 800;
    Description: 'This headgear renders' + ' the leader entirely ' +
    'invisible to enemies'),
    // (5) Tiara Of Purity
    (Enum: iTiaraOfPurity; Name: 'Tiara Of Purity'; Level: 5; ItType: itHelm;
    ItEffect: ieNone; ItSlot: isHelm; ItRes: irNone; Price: 1000;
    Description: ''),
    // (6) Mjolnir's Crown
    (Enum: iMjolnirsCrown; Name: 'Mjolnir''s Crown'; Level: 6; ItType: itHelm;
    ItEffect: ieNone; ItSlot: isHelm; ItRes: irNone; Price: 1500;
    Description: ''),
    // (7) Thirstborn Diadem
    (Enum: iMjolnirsCrown; Name: 'Thirstborn Diadem'; Level: 7; ItType: itHelm;
    ItEffect: ieVampiricAttack25; ItSlot: isHelm; ItRes: irNone; Price: 2000;
    Description: 'Drains enemy life with ' + 'every blow you strike'),
    // (8) Imperial Crown
    (Enum: iImperialCrown; Name: 'Imperial Crown'; Level: 8; ItType: itHelm;
    ItEffect: ieRegen25; ItSlot: isHelm; ItRes: irNone; Price: 2500;
    Description: 'Gradually restores your ' + 'health during every day'));

  { TInventory }

procedure TInventory.Add(const AItem: TItem);
var
  I: Integer;
begin
  for I := 0 to CMaxInventoryItems - 1 do
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
  for I := 0 to CMaxInventoryItems - 1 do
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
  for I := 0 to CMaxInventoryItems - 1 do
    Clear(I);
  AddTestItems;
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
  for I := 0 to CMaxInventoryItems - 1 do
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

procedure TInventory.AddTestItems;
var
  LItem: TItemEnum;
begin
  for LItem in CTestItems do
    Add(LItem);
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
  Update;
end;

procedure TEquipment.Clear;
var
  I: Integer;
begin
  for I := 0 to CMaxEquipmentItems - 1 do
    Clear(I);
end;

procedure TEquipment.Clear(const I: Integer);
begin
  FItem[I] := ItemBase[iNone];
  Update;
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

function TEquipment.LHandSlotItem: TItem;
begin
  Result := FItem[6];
end;

procedure TEquipment.Update;
var
  I: Integer;
begin
  TLeaderParty.LeaderRegenerationValue := 0;
  TLeaderParty.LeaderChanceToParalyzeValue := 0;
  TLeaderParty.LeaderVampiricAttackValue := 0;
  TLeaderParty.PartyGainMoreExpValue := 0;
  TLeaderParty.LeaderGainsMoreMovePointsValue := 0;
  TLeaderParty.LeaderInvisibleValue := 0;
  for I := 0 to CMaxEquipmentItems - 1 do
  begin
    if FItem[I].Enum = iNone then
      Continue;
    // Regeneration
    if FItem[I].ItEffect = ieRegen5 then
      TLeaderParty.ModifyLeaderRegeneration(5);
    if FItem[I].ItEffect = ieRegen10 then
      TLeaderParty.ModifyLeaderRegeneration(10);
    if FItem[I].ItEffect = ieRegen15 then
      TLeaderParty.ModifyLeaderRegeneration(15);
    if FItem[I].ItEffect = ieRegen20 then
      TLeaderParty.ModifyLeaderRegeneration(20);
    if FItem[I].ItEffect = ieRegen25 then
      TLeaderParty.ModifyLeaderRegeneration(25);
    // Chance to paralyze
    if FItem[I].ItEffect = ieChanceToParalyze5 then
      TLeaderParty.ModifyLeaderChanceToParalyze(5);
    if FItem[I].ItEffect = ieChanceToParalyze10 then
      TLeaderParty.ModifyLeaderChanceToParalyze(10);
    if FItem[I].ItEffect = ieChanceToParalyze15 then
      TLeaderParty.ModifyLeaderChanceToParalyze(15);
    // Vampiric attack
    if FItem[I].ItEffect = ieVampiricAttack10 then
      TLeaderParty.ModifyLeaderVampiricAttack(10);
    if FItem[I].ItEffect = ieVampiricAttack15 then
      TLeaderParty.ModifyLeaderVampiricAttack(15);
    if FItem[I].ItEffect = ieVampiricAttack20 then
      TLeaderParty.ModifyLeaderVampiricAttack(20);
    if FItem[I].ItEffect = ieVampiricAttack25 then
      TLeaderParty.ModifyLeaderVampiricAttack(25);
    // Gain more experience
    if FItem[I].ItEffect = ieGain20MoreExp then
      TLeaderParty.ModifyPartyGainMoreExp(20);
    // Leader gains more move points
    if FItem[I].ItEffect = ieGains20MoreMovePoints then
      TLeaderParty.ModifyLeaderMovePoints(20);
    if FItem[I].ItEffect = ieGains40MoreMovePoints then
      TLeaderParty.ModifyLeaderMovePoints(40);
    if FItem[I].ItEffect = ieGains60MoreMovePoints then
      TLeaderParty.ModifyLeaderMovePoints(60);
    if FItem[I].ItEffect = ieGains80MoreMovePoints then
      TLeaderParty.ModifyLeaderMovePoints(80);
    if FItem[I].ItEffect = ieGains100MoreMovePoints then
      TLeaderParty.ModifyLeaderMovePoints(100);
    // Invisible
    if FItem[I].ItEffect = ieInvisible then
      TLeaderParty.ModifyLeaderInvisible(1);
  end;
end;

end.
