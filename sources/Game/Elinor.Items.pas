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

// Causes an enemy unit to flee from battle
// Polymorphs enemy unit
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
// Gives an extra attack
// Leader gains a vampiric attack: his attacks heal him
// Petrifies enemy unit
// Leader inflicts 10% more damage
// Leader receives 25% less damage from attacks

// Boots:
// No move penalty when walking in forests
// No move penalty when sailing on water
// Leader gains 40% more move points

// Leader is unaffected by thieves
// 10% lower prices from merchants and mercenaries

type
  TItemType = (itSpecial, itValuable,
    // Potions and Scrolls
    itPotion, itScroll,
    // Equipable
    itRing, itArmor, itArtifact, itAmulet, itHelm, itWand, itOrb, itTalisman,
    itBoots, itBanner, itTome);

const
  ItemTypeName: array [TItemType] of string = ('', 'valuable', 'elixir',
    'scroll', 'ring', 'armor', 'artifact', 'amulet', 'helm', 'staff', 'sphere',
    'talisman', 'boots', 'banner', 'book');

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
    ieVampiricAttack25
    //
    );

type
  TJewlery = (jwNone, jwSteel, jwBronze, jwCopper, jwBrass, jwSilver, jwGold,
    jwAgate, jwOpal, jwAmethyst, jwRuby, jwEmerald, jwJade, jwPearl, jwQuartz,
    jwSapphire, jwDiamond);

type
  TItemEnum = (iNone,
    // Special
    iGold, iMana, iStoneTab,

    // Valuables
    iRunicKey, iArcaneScroll, iEmberSalts, iEmerald, iRuby, iSapphire, iDiamond,
    iAncientRelic,

    // Potions
    iLifePotion, iPotionOfHealing, iPotionOfRestoration, iHealingOintment,

    // Artifacts
    iDwarvenBracer, iRunestone, iHornOfAwareness, iIceCrystal, iSkullBracers,
    iLuteOfCharming, iSkullOfThanatos, iBethrezensClaw,

    // iRunicBlade,
    // iWightBlade,
    // iUnholyDagger,
    // iThanatosBlade,
    // iHornOfIncubus,
    // iRoyalScepter

    // Amulets
    iNecklaceOfBloodbind,

    // Armors

    // Boots

    // Talismans
    iTalismanOfLife,

    // Banners

    // Tomes
    iTomeOfWar,

    // Orbs
    iGoblinOrb, iImpOrb,
    // iZombieOrb, iVampireOrb,
    // iLichOrb, iOrcOrb, iLizardManOrb, iElfLordOrb,
    // iOrbOfRestoration, iOrbOfRegeneration, iOrbOfHealing,

    // Rings
    iStoneRing, iBronzeRing, iSilverRing, iGoldRing, iRingOfStrength,
    iRingOfTheAges, iRingOfHag, iThanatosRing,

    // Helms
    iTiaraOfPurity, iMjolnirsCrown, iThirstbornDiadem, iImperialCrown);

const
  QuaffItems = [iLifePotion, iPotionOfHealing, iPotionOfRestoration];

type
  TItem = record
    Enum: TItemEnum;
    Name: string;
    Level: Integer;
    ItType: TItemType;
    ItEffect: TItemEffect;
    ItSlot: TItemSlot;
    ItRes: TResEnum;
    Price: Integer;
    Description: string;
  end;

const
  CMaxInventoryItems = 12;

type
  TInventory = class(TObject)
  private
    FItem: array [0 .. CMaxInventoryItems - 1] of TItem;
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
  end;

type
  TItemBase = class(TObject)
    class function Item(const ItemEnum: TItemEnum): TItem; overload;
    class function Item(const ItemIndex: Integer): TItem; overload;
    class function Count: Integer;
  end;

implementation

uses
  SysUtils,
  Elinor.Party;

const
  ItemBase: array [TItemEnum] of TItem = (
    // None
    (Enum: iNone; Name: ''; Level: 0; ItType: itSpecial; ItEffect: ieNone;
    ItSlot: isNone; ItRes: reNone; Price: 0; Description: ''),

    // Special
    // Gold
    (Enum: iGold; Name: 'Gold'; Level: 1; ItType: itSpecial; ItEffect: ieNone;
    ItSlot: isNone; ItRes: reItemGold; Price: 0;
    Description: 'A shiny gold coin, valued' +
    ' by merchants and traders across the land'),
    // Mana
    (Enum: iMana; Name: 'Mana'; Level: 1; ItType: itSpecial; ItEffect: ieNone;
    ItSlot: isNone; ItRes: reItemMana; Price: 0;
    Description: 'A shimmering crystal pulsating with magical energy'),
    // Stone Tablet
    (Enum: iStoneTab; Name: 'Stone Tablet'; Level: 1; ItType: itSpecial;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reItemStoneTablet; Price: 0;
    Description: 'An ancient stone tablet etched with forgotten knowledge.' +
    ' Its inscriptions hold the wisdom of past civilizations'),

    // Valuables
    // Runic Key
    (Enum: iRunicKey; Name: 'Runic Key'; Level: 1; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reItemRunicKey; Price: 100;
    Description: 'An ancient key engraved with glowing runes.' +
    ' Unlocks hidden paths and sealed doors'),
    // Arcane Scroll
    (Enum: iArcaneScroll; Name: 'Arcane Scroll'; Level: 2; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reItemArcaneScroll; Price: 200;
    Description: 'A used magical scroll, its words faded,' +
    ' yet a trace of its power still lingers'),
    // Ember Salts
    (Enum: iEmberSalts; Name: 'Ember Salts'; Level: 3; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reNone; Price: 300;
    Description: 'Glowing embers crystallized into fine salts.' +
    ' Used in powerful alchemical rituals'),
    // Emerald
    (Enum: iEmerald; Name: 'Emerald'; Level: 4; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reNone; Price: 400;
    Description: 'A vibrant green gem, expertly cut' +
    ' and highly prized for its rich color'),
    // Ruby
    (Enum: iRuby; Name: 'Ruby'; Level: 5; ItType: itValuable; ItEffect: ieNone;
    ItSlot: isNone; ItRes: reNone; Price: 550;
    Description: 'A fiery red gemstone that blazes with inner light.' +
    ' Symbolizes passion and power in many cultures'),
    // Sapphire
    (Enum: iSapphire; Name: 'Sapphire'; Level: 6; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reItemSaphire; Price: 750;
    Description: 'Deep blue stone embodying the sea and sky,' +
    ' prized for its royal beauty and mystique'),
    // Diamond
    (Enum: iDiamond; Name: 'Diamond'; Level: 7; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reNone; Price: 850;
    Description
    : 'The most precious of stones, a crystalline marvel of pure light.' +
    ' Rare, unyielding, and incredibly valuable'),
    // Ancient Relic
    (Enum: iAncientRelic; Name: 'Ancient Relic'; Level: 8; ItType: itValuable;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reNone; Price: 1000;
    Description: 'An old and weathered object from a bygone age,' +
    ' holding secrets of the past'),

    // Potions
    // Life Potion
    (Enum: iLifePotion; Name: 'Life Potion'; Level: 1; ItType: itPotion;
    ItEffect: ieNone; ItSlot: isNone; ItRes: reItemLifePotion; Price: 250;
    Description: 'A powerful elixir that restores life,' +
    ' bringing the dead back to the world of the living'),
    // Potion of Healing
    (Enum: iPotionOfHealing; Name: 'Potion of Healing'; Level: 1;
    ItType: itPotion; ItEffect: ieNone; ItSlot: isNone;
    ItRes: reItemPotionOfHealing; Price: 100;
    Description: 'A soothing potion that restores' +
    ' health and heals wounds'),
    // Potion of Restoration
    (Enum: iPotionOfRestoration; Name: 'Potion of Restoration'; Level: 2;
    ItType: itPotion; ItEffect: ieNone; ItSlot: isNone;
    ItRes: reItemPotionOfRestoration; Price: 200;
    Description: 'A potent potion that' +
    ' greatly restores health and accelerates healing'),
    // Healing Ointment
    (Enum: iHealingOintment; Name: 'Healing Ointment'; Level: 3;
    ItType: itPotion; ItEffect: ieNone; ItSlot: isNone;
    ItRes: reItemHealingOintment; Price: 400;
    Description: 'A crimson nectar that fills the body with energy,' +
    ' healing wounds and restoring strength.'),

    // Artifacts
    // Dwarven Bracer
    (Enum: iDwarvenBracer; Name: 'Dwarven Bracer'; Level: 1; ItType: itArtifact;
    ItEffect: ieRegen5; ItSlot: isArtifact; ItRes: reNone; Price: 250;
    Description: ''),
    // Runestone
    (Enum: iRunestone; Name: 'Runestone'; Level: 2; ItType: itArtifact;
    ItEffect: ieRegen20; ItSlot: isArtifact; ItRes: reItemRunestone; Price: 400;
    Description: 'A mystical runestone that enhances' +
    ' natural health regeneration'),
    // Horn Of Awareness
    (Enum: iHornOfAwareness; Name: 'Horn Of Awareness'; Level: 3;
    ItType: itArtifact; ItEffect: ieNone; ItSlot: isArtifact; ItRes: reItemHorn;
    Price: 500; Description: ''),
    // Ice Crystal
    (Enum: iIceCrystal; Name: 'Ice Crystal'; Level: 4; ItType: itArtifact;
    ItEffect: ieChanceToParalyze10; ItSlot: isArtifact; ItRes: reItemIceCrystal;
    Price: 650; Description: ''),
    // Skull Bracers
    (Enum: iSkullBracers; Name: 'Skull Bracers'; Level: 5; ItType: itArtifact;
    ItEffect: ieNone; ItSlot: isArtifact; ItRes: reNone; Price: 750;
    Description: ''),
    // Lute Of Charming
    (Enum: iLuteOfCharming; Name: 'Lute Of Charming'; Level: 6;
    ItType: itArtifact; ItEffect: ieNone; ItSlot: isArtifact; ItRes: reNone;
    Price: 1000; Description: ''),
    // Skull Of Thanatos
    (Enum: iSkullOfThanatos; Name: 'Skull Of Thanatos'; Level: 7;
    ItType: itArtifact; ItEffect: ieChanceToParalyze15; ItSlot: isArtifact;
    ItRes: reNone; Price: 1250; Description: ''),
    // Bethrezen's Claw
    (Enum: iBethrezensClaw; Name: 'Bethrezen''s Claw'; Level: 8;
    ItType: itArtifact; ItEffect: ieNone; ItSlot: isArtifact; ItRes: reNone;
    Price: 1500; Description: ''),

    // Amulets
    (Enum: iNecklaceOfBloodbind; Name: 'Necklace of Bloodbind'; Level: 3;
    ItType: itAmulet; ItEffect: ieVampiricAttack10; ItSlot: isAmulet;
    ItRes: reNone; Price: 800; Description: 'This amulet grants its' +
    ' wearer the power ' + 'to drink the life of ' + 'their enemies'),

    // Talismans
    (Enum: iTalismanOfLife; Name: 'Talisman of Life'; Level: 2;
    ItType: itTalisman; ItEffect: ieNone; ItSlot: isLHand; ItRes: reNone;
    Price: 350; Description: ''),

    // Tomes
    (Enum: iTomeOfWar; Name: 'Tome of War'; Level: 3; ItType: itTome;
    ItEffect: ieNone; ItSlot: isTome; ItRes: reNone; Price: 2000;
    Description: 'All the units in the party gain 20% ' +
    'more experience in battle'),

    // Orbs
    // Goblin Orb
    (Enum: iGoblinOrb; Name: 'Goblin Orb'; Level: 1; ItType: itOrb;
    ItEffect: ieNone; ItSlot: isLHand; ItRes: reNone; Price: 400;
    Description: 'Summon a Golin'),
    // Imp Orb
    (Enum: iImpOrb; Name: 'Imp Orb'; Level: 1; ItType: itOrb; ItEffect: ieNone;
    ItSlot: isLHand; ItRes: reNone; Price: 450; Description: 'Summon an Imp'),

    // Rings
    // Stone Ring
    (Enum: iStoneRing; Name: 'Stone Ring'; Level: 1; ItType: itRing;
    ItEffect: ieRegen5; ItSlot: isRing; ItRes: reItemStoneRing; Price: 300;
    Description: 'A stone ring with a faint glow,' +
    ' holding dormant magical energy'),
    // Bronze Ring
    (Enum: iBronzeRing; Name: 'Bronze Ring'; Level: 2; ItType: itRing;
    ItEffect: ieRegen10; ItSlot: isRing; ItRes: reItemBronzeRing; Price: 400;
    Description: 'A simple bronze ring,' + ' sturdy and unassuming'),
    // Silver Ring
    (Enum: iSilverRing; Name: 'Silver Ring'; Level: 3; ItType: itRing;
    ItEffect: ieRegen15; ItSlot: isRing; ItRes: reItemSilverRing; Price: 500;
    Description: 'A sleek silver ring,' +
    ' reflecting a subtle, elegant shine'),
    // Gold Ring
    (Enum: iGoldRing; Name: 'Gold Ring'; Level: 4; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: reNone; Price: 700;
    Description: 'A luxurious gold ring,' +
    ' gleaming with wealth and prestige'),
    // Ring Of Strength,
    (Enum: iRingOfStrength; Name: 'Ring Of Strength'; Level: 5; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: reItemRingOfStrength; Price: 900;
    Description: ''),
    // Ring Of The Ages,
    (Enum: iRingOfTheAges; Name: 'Ring Of The Ages'; Level: 6; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: reNone; Price: 1000;
    Description: ''),
    // Hag's Ring,
    (Enum: iRingOfHag; Name: 'Ring of Hag'; Level: 7; ItType: itRing;
    ItEffect: ieNone; ItSlot: isRing; ItRes: reNone; Price: 1200;
    Description: ''),
    // Thanatos Ring
    (Enum: iThanatosRing; Name: 'Thanatos Ring'; Level: 8; ItType: itRing;
    ItEffect: ieChanceToParalyze5; ItSlot: isRing; ItRes: reNone; Price: 1500;
    Description: ''),

    // Helms
    // Tiara Of Purity
    (Enum: iTiaraOfPurity; Name: 'Tiara Of Purity'; Level: 5; ItType: itHelm;
    ItEffect: ieNone; ItSlot: isHelm; ItRes: reNone; Price: 1000;
    Description: ''),
    // Mjolnir's Crown
    (Enum: iMjolnirsCrown; Name: 'Mjolnir''s Crown'; Level: 6; ItType: itHelm;
    ItEffect: ieNone; ItSlot: isHelm; ItRes: reNone; Price: 1500;
    Description: ''),
    // Thirstborn Diadem
    (Enum: iMjolnirsCrown; Name: 'Thirstborn Diadem'; Level: 7; ItType: itHelm;
    ItEffect: ieVampiricAttack25; ItSlot: isHelm; ItRes: reNone; Price: 1800;
    Description: ''),
    // Imperial Crown
    (Enum: iImperialCrown; Name: 'Imperial Crown'; Level: 8; ItType: itHelm;
    ItEffect: ieRegen25; ItSlot: isHelm; ItRes: reNone; Price: 2500;
    Description: ''));

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
  for I := 0 to MaxEquipmentItems - 1 do
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

procedure TEquipment.Update;
var
  I: Integer;
begin
  TLeaderParty.LeaderRegenerationValue := 0;
  TLeaderParty.LeaderChanceToParalyzeValue := 0;
  TLeaderParty.LeaderVampiricAttackValue := 50;
  for I := 0 to MaxEquipmentItems - 1 do
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
  end;
end;

end.
