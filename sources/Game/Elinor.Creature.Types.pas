unit Elinor.Creature.Types;

interface

type
  TCreatureEnum = (crNone,
    // The Empire Capital Guardian
    crMyzrael,
    // The Empire Warrior Leader
    crPaladin,
    // The Empire Scout Leader
    crRanger,
    // The Empire Mage Leader
    crArchmage,
    // The Empire Thief Leader
    crThief,
    // The Empire Lord Leader
    crWarlord,
    // The Empire Fighters
    crSquire,
    // The Empire Ranged Attack Units
    crArcher,
    // The Empire Mage Units
    crApprentice,
    // The Empire Support units
    crAcolyte,

    // Undead Hordes Capital Guardian
    crAshgan,
    // Undead Hordes Warrior Leader
    crDeathKnight,
    // Undead Hordes Scout Leader
    crNosferatu,
    // Undead Hordes Mage Leader
    crLichQueen,
    // Undead Hordes Thief Leader
    crThug,
    // Undead Hordes Lord Leader
    crDominator,
    // Undead Hordes Fighters
    crFighter,
    // Undead Hordes Ranged Attack Units
    crGhost,
    // Undead Hordes Mage Units
    crInitiate,
    // Undead Hordes Support units
    crWyvern,

    // Legions Of The Damned Capital Guardian
    crAshkael,
    // Legions Of The Damned Warrior Leader
    crDuke,
    // Legions Of The Damned Scout Leader
    crCounselor,
    // Legions Of The Damned Mage Leader
    crArchDevil,
    // Legions Of The Damned Thief Leader
    crRipper,
    // Legions Of The Damned Lord Leader
    crChieftain,
    // Legions Of The Damned Fighters
    crPossessed,
    // Legions Of The Damned Ranged Attack Units
    crGargoyle,
    // Legions Of The Damned Mage Units
    crCultist,
    // Legions Of The Damned Support units
    crDevil,

    // Goblins
    crGoblin, crGoblin_Rider, crGoblin_Archer, crGoblin_Elder,
    // Orcs
    crOrc,
    // Ogres
    crOgre,

    // Humans
    crPeasant, crManAtArms, crRogue,

    // Undeads
    crGhoul, crDarkElfGast, crReaper,

    // Heretics
    crImp,

    // Spiders
    crGiantSpider,
    // Wolves
    crWolf,
    // Bears
    crPolarBear, crBrownBear, crBlackBear
    //
    );

const
  FighterLeaders = [crPaladin, crDeathKnight, crDuke];
  ScoutingLeaders = [crRanger, crNosferatu, crCounselor];
  MageLeaders = [crArchmage, crLichQueen, crArchDevil];
  ThiefLeaders = [crThief, crThug, crRipper];
  LordLeaders = [crWarlord, crDominator, crChieftain];
  TemplarLeaders = [];
  AllLeaders = FighterLeaders + ScoutingLeaders + MageLeaders + ThiefLeaders +
    LordLeaders + TemplarLeaders;
  FlyLeaders = [crDuke, crArchDevil, crChieftain];

implementation

end.
