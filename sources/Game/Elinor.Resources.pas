unit Elinor.Resources;

interface

uses
{$IFDEF FPC}
  Classes,
  Graphics,
{$ELSE}
  Vcl.Imaging.PNGImage,
  System.Classes,
{$ENDIF}
  IniFiles, Dialogs;

{$IFDEF FPC}

type
  TPNGImage = TPortableNetworkGraphic;
{$ENDIF}

type
  TResEnum = (reNone,
    //
    reAMark, reASell, rePlus, reElinorIntro,
    //
    reTheEmpireLogo, reUndeadHordesLogo, reLegionsOfTheDamnedLogo,
    //
    reMenuRecordsLogo, reMenuContinueLogo, reMenuDragonLogo,
    //
    reWarriorLogo, reScoutLogo, reMageLogo, reThiefLogo, reLordLogo,
    reTemplarLogo,
    //
    reBGCharacter, reBGEnemy, reBGParalyze, reDead,
    // Frames
    reFrameSlot, reFrameSlotActive, reFrameSlotPassive, reFrameSlotGlow,
    reFrameSlotTarget, reSmallFrame, reBigFrame, reHugeFrame, reInfoFrame,
    reFrameItem, reFrameItemActive, reBigFrameBackground, reHugeFrameBackground,
    //
    reTime, reNeutralTerrain, reTheEmpireTerrain, reUndeadHordesTerrain,
    reLegionsOfTheDamnedTerrain, reUnk, reEnemy, reCursorSpecial, reCursor,
    reNoWay, reCursorMagic, rePlayer, rePlayerInvisibility, reDark,
    reBGTransparent, reGold, reMana, reBag, reNeutralCity, reTheEmpireCity,
    reUndeadHordesCity, reLegionsOfTheDamnedCity, reTheEmpireCapital,
    reUndeadHordesCapital, reLegionsOfTheDamnedCapital, reRuin, reTower,
    reSTower, reMageTower, reMerchantPotions, reMerchantArtifacts, reMineGold,
    reMineMana, reMountain1, reMountain2, reMountain3, reMountain4,
    // Trees
    reTree1, reTree2, reTree3, reTree4, reTree5, reUndeadHordesTree,
    reLegionsOfTheDamnedTree,
    //
    reButtonDef, reButtonAct, reCorpse,
    // Creatures
    reMyzrael, rePaladin, reRanger, reArchmage, reSquire, reArcher, reThief,
    reWarlord, reApprentice, reAcolyte, reAshgan, reNosferat, reLichQueen,
    reThug, reDominator, reFighter, reInitiate, reWyvern, reDeathKnight,
    reAshkael, reDuke, reCounselor, reArchdevil, reRipper, reChieftain,
    rePossessed, reCultist, reDevil, reBlackDragon, reWhiteDragon, reRedDragon,
    reGreenDragon, reBlueDragon, reGoblin, reGoblinArcher, reGoblinElder,
    reBlackGoblin, reGiantSpider, reWolf, reDireWolf, reSpiritWolf, rePolarBear,
    reBrownBear, reBlackBear, reOrc, reGhost, reImp, reGhoul, reStoneGargoyle,
    reReaper, reRogue, reTrog,
    // Text
    reTextHighScores, reTextCapitalDef, reTextCityDef, reTextPlay,
    reTextVictory, reTextDefeat, reTextQuit, reTextContinue, reTextDismiss,
    reTextRecruit, reTextClose, reTextOk, reTextCancel, reTextLeadParty,
    reTextHeal, reTextRevive, reTextInventory, reTextAbilities, reTextParty,
    reTextTemple, reTextTower, reTextBarracks, reTextSpellbook, reTextCast,
    reTextLearn, reTextFaction, reTextClass, reTextRandom, reTextDarkogStudio,
    reTextPresents, reTextPickup, reTextMerchant, reTextInform, reTextLog,
    // Title
    reTitleTemple, reTitleRecruit, reTitleHighScores, reTitleVictory,
    reTitleDefeat, reTitleLogo, reTitleRace, reTitleScenario, reTitleLeader,
    reTextNewDay, reTitleLoot, reTitleParty, reTitleBattle, reTitleVorgel,
    reTitleEntarion, reTitleTardum, reTitleTemond, reTitleZerton, reTitleDoran,
    reTitleKront, reTitleHimor, reTitleSodek, reTitleSard, reTitleDifficulty,
    reTitleThief, reTitleWarrior, reTitleAbilities, reTitleInventory,
    reTitleSpellbook, reTitleJournal, reTitleMageTower, reTitleBarracks,
    reTitleEnterName, reTitleMerchant,

    // SCENARIO //
    reScenarioDarkTower, reScenarioOverlord, reScenarioAncientKnowledge,

    //
    reDifficultyEasyLogo, reDifficultyNormalLogo, reDifficultyHardLogo,
    //
    reThiefSpy, reThiefDuel, reThiefPoison,
    //
    reWarriorRest,
    //
    reWarriorRitual,
    //
    reWarriorWar3,
    //
    reWallpaperSettlement, reWallpaperMenu, reWallpaperLoot, reWallpaperDefeat,
    reWallpaperDifficulty, reWallpaperLeader, reWallpaperScenario,
    //
    reIconScores, reIconScoresOver, reIconClosedGates, reIconOpenedGates,
    // BG
    reBGTheEmpire, reBGUndeadHordes, reBGLegionsOfTheDamned, reBGMountainClans,
    reBGElvenAlliance, reBGGreenskinTribes, reBGNeutrals, reBGAbility,
    // Races
    reHumanMale,
    // Panel buttons
    reButtonMenu, reButtonParty, reButtonCancel, reButtonSpellbook, reButtonInv,
    reButtonAbility, reButtonScenario);

type
  TSpellResEnum = (srNone,
    // The Empire
    srTrueHealing, srSpeed, srBless, srLivingArmor, srEagleEye, srStrength,
    // Undead Hordes
    srPlague, srConcealment, srChainsOfDread,
    // Legions of the Damned
    srCurse, srWeaken);

type
  TAbilityResEnum = (arNone, arSharpEye, arUseStaffsAndScrolls, arArcaneLore);

type
  TItemResEnum = (irNone,
    // Special
    irItemGold, irItemMana,
    // Scenario
    irItemStoneTablet,
    // Elixirs
    irItemLifePotion, irItemPotionOfHealing, irItemPotionOfRestoration,
    irItemHealingOintment,
    // Artifacts
    irStoneRing, irBronzeRing, irSilverRing, irGoldRing, irRingOfStrength,
    irRunicKey, reItemIceCrystal, irItemArcaneScroll, irEmberSalts,
    irDwarvenBracer, irRunestone, irEmerald, irRuby, irSaphire, irDiamond,
    irHornOfAwareness, irBethrezensClaw, irHornOfIncubus,
    // TALISMANS
    irTalismanOfRestoration, irTalismanOfVigor, irTalismanOfProtection,
    // ORBS
    irGoblinOrb, irOrbOfHealing, irImpOrb, irOrbOfRestoration, irZombieOrb,
    irOrbOfLife, irLizardmanOrb,
    // Tomes
    irItemTomeOfWar,
    // Boots
    irBootsOfSpeed, irElvenBoots, irBootsOfHaste, irBootsOfDarkness,
    irBootsOfTravelling, irBootsOfTheElements, irBootsOfSevenLeagues,
    // HELMS
    irHoodOfDarkness,
    // ARMORS
    irShroudOfDarkness,
    // AMULETS
    irItemAmuletOfBloodbind, irHeartOfDarkness,
    // RINGS
    irHagsRing);

const
  Capitals = [reTheEmpireCapital, reUndeadHordesCapital,
    reLegionsOfTheDamnedCapital];
  Cities = [reTheEmpireCity, reUndeadHordesCity, reLegionsOfTheDamnedCity];
  Tiles = [reTheEmpireTerrain, reUndeadHordesTerrain,
    reLegionsOfTheDamnedTerrain];
  MountainTiles = [reMountain1, reMountain2, reMountain3, reMountain4];
  StopTiles = MountainTiles + [reDark];
  TreesTiles = [reTree1, reTree2, reTree3, reTree4, reTree5];

type
  TResTypeEnum = (teNone, teTree, teTile, teGUI, teSpell, tePath, teObject,
    tePlayer, teEnemy, teBag, teRes, teCapital, teCity, teRuin, teTower,
    teMageTower, teMerchant, teMine, teMusic, teSound, teItem, teBG, teIcon,
    teTheEmpireABC);

type
  TResBase = record
    FileName: string;
    ResType: TResTypeEnum;
  end;

const
  ResBase: array [TResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teNone;),

    // PATH //
    // AMark
    (FileName: 'path.amark.png'; ResType: tePath;),
    // ASell
    (FileName: 'path.asell.png'; ResType: tePath;),
    // Plus
    (FileName: 'plus.png'; ResType: teGUI;),
    // Intro,
    (FileName: 'elinor.intro.png'; ResType: teGUI;),

    // The Empire Logo
    (FileName: 'logo.the_empire.png'; ResType: teGUI;),
    // Undead Hordes Logo
    (FileName: 'logo.undead_hordes.png'; ResType: teGUI;),
    // Legions Of The Damned Logo
    (FileName: 'logo.legions_of_the_damned.png'; ResType: teGUI;),

    // Menu High Scores
    (FileName: 'logo.menu.records.png'; ResType: teGUI;),
    // Menu Quit
    (FileName: 'logo.menu.gate.png'; ResType: teGUI;),
    // Menu Dragon
    (FileName: 'logo.menu.dragon.png'; ResType: teGUI;),

    // Warrior Logo
    (FileName: 'logo.warrior.png'; ResType: teGUI;),
    // Scout Logo
    (FileName: 'logo.scout.png'; ResType: teGUI;),
    // Mage Logo
    (FileName: 'logo.mage.png'; ResType: teGUI;),
    // Thief Logo
    (FileName: 'logo.thief.png'; ResType: teGUI;),
    // Lord Logo
    (FileName: 'logo.lord.png'; ResType: teGUI;),
    // Templar Logo
    (FileName: 'logo.templar.png'; ResType: teGUI;),

    // Char
    (FileName: 'bg.character.png'; ResType: teGUI;),
    // Enemy
    (FileName: 'bg.enemy.png'; ResType: teGUI;),
    // Paralyze
    (FileName: 'bg.paralyze.png'; ResType: teGUI;),
    // Corpse
    (FileName: 'corpse.png'; ResType: teGUI;),

    // FRAMES //
    // Frame Slot
    (FileName: 'frame.slot.png'; ResType: teGUI;),
    // Frame Slot Active
    (FileName: 'frame.slot.active.png'; ResType: teGUI;),
    // Frame Slot Passive
    (FileName: 'frame.slot.passive.png'; ResType: teGUI;),
    // Frame Slot Glow
    (FileName: 'frame.slot.glow.png'; ResType: teGUI;),
    // Frame Slot Target
    (FileName: 'frame.slot.target.png'; ResType: teGUI;),
    // Small Frame
    (FileName: 'frame.small.png'; ResType: teGUI;),
    // Big Frame
    (FileName: 'frame.big.png'; ResType: teGUI;),
    // Huge Frame
    (FileName: 'frame.huge.png'; ResType: teGUI;),
    // Info Frame
    (FileName: 'frame.info.png'; ResType: teGUI;),
    // Frame Item
    (FileName: 'frame.item.png'; ResType: teGUI;),
    // Frame Item Active
    (FileName: 'frame.item.active.png'; ResType: teGUI;),
    // Frame Big Background,
    (FileName: 'frame.background.png'; ResType: teGUI;),
    // Frame Huge Background,
    (FileName: 'frame.huge.background.png'; ResType: teGUI;),

    // Time
    (FileName: 'time.png'; ResType: teGUI;),
    // Neutral Terrain
    (FileName: 'tile.dirt.png'; ResType: teTile;),
    // Empire Terrain
    (FileName: 'tile.the_empire.png'; ResType: teTile;),
    // Undead Hordes Terrain
    (FileName: 'tile.undead_hordes.png'; ResType: teTile;),
    // Legions Of The Damned Terrain
    (FileName: 'tile.legions_of_the_damned.png'; ResType: teTile;),
    // Unknown (?)
    (FileName: 'unknown.png'; ResType: teGUI;),
    // Enemy party
    (FileName: 'mapobject.enemy.png'; ResType: teEnemy;),
    // Special
    (FileName: 'cursor.special.png'; ResType: teGUI;),
    // Frame
    (FileName: 'cursor.select.png'; ResType: teGUI;),
    // NoFrame
    (FileName: 'cursor.noselect.png'; ResType: teGUI;),
    // Cursor Magic
    (FileName: 'cursor.magic.png'; ResType: teGUI;),
    // Player
    (FileName: 'mapobject.player.png'; ResType: tePlayer;),
    // Player Invisibility
    (FileName: 'mapobject.player.invisibility.png'; ResType: tePlayer;),
    // Fog
    (FileName: 'transparent.png'; ResType: teGUI;),
    // BG Transparent
    (FileName: 'bg.transparent.png'; ResType: teGUI;),
    // Gold
    (FileName: 'mapobject.gold.png'; ResType: teRes;),
    // Mana
    (FileName: 'mapobject.mana.png'; ResType: teRes;),
    // Bag
    (FileName: 'mapobject.chest.png'; ResType: teBag;),
    // Neutral City
    (FileName: 'city.neutrals.png'; ResType: teCity;),
    // The Empire City
    (FileName: 'city.the_empire.png'; ResType: teCity;),
    // Undead Hordes City
    (FileName: 'city.undead_hordes.png'; ResType: teCity;),
    // Legions Of The Damned City
    (FileName: 'city.legions_of_the_damned.png'; ResType: teCity;),
    // The Empire Capital
    (FileName: 'capital.the_empire.png'; ResType: teCapital;),
    // Undead Hordes Capital
    (FileName: 'capital.undead_hordes.png'; ResType: teCapital;),
    // Legions Of The Damned Capital
    (FileName: 'capital.legions_of_the_damned.png'; ResType: teCapital;),
    // Ruin
    (FileName: 'tile.ruin.png'; ResType: teRuin;),
    // Tower
    (FileName: 'tile.tower.png'; ResType: teTower;),
    // STower
    (FileName: 'tile.stower.png'; ResType: teTower;),
    // Mage Tower
    (FileName: 'tile.mage_tower.png'; ResType: teMageTower;),
    // Merchant Potions
    (FileName: 'tile.merchant.potions.png'; ResType: teMerchant;),
    // Merchant Artifacts
    (FileName: 'tile.merchant.artifacts.png'; ResType: teMerchant;),
    // Gold Mine
    (FileName: 'tile.mine.gold.png'; ResType: teMine;),
    // Mana Mine
    (FileName: 'tile.mine.mana.png'; ResType: teMine;),
    // Mountain #1
    (FileName: 'tile.mountain1.png'; ResType: teObject;),
    // Mountain #2
    (FileName: 'tile.mountain2.png'; ResType: teObject;),
    // Mountain #3
    (FileName: 'tile.mountain3.png'; ResType: teObject;),
    // Mountain #4
    (FileName: 'tile.mountain4.png'; ResType: teObject;),
    // Tree #1
    (FileName: 'tile.tree1.png'; ResType: teObject;),
    // Tree #2
    (FileName: 'tile.tree2.png'; ResType: teObject;),
    // Tree #3
    (FileName: 'tile.tree3.png'; ResType: teObject;),
    // Tree #4
    (FileName: 'tile.tree4.png'; ResType: teObject;),
    // Tree #5
    (FileName: 'tile.tree5.png'; ResType: teObject;),
    // Undead Hordes Tree
    (FileName: 'tile.tree.undead_hordes.png'; ResType: teTree;),
    // Legions Of The Damned Tree
    (FileName: 'tile.tree.legions_of_the_damned.png'; ResType: teTree;),
    // Button
    (FileName: 'button.def.png'; ResType: teGUI;),
    // Button
    (FileName: 'button.act.png'; ResType: teGUI;),
    // Corpse
    (FileName: 'corpse.png'; ResType: teGUI;),

    // CHARACTERS //
    // Myzrael
    (FileName: 'character.the_empire.myzrael.png'; ResType: teGUI;),
    // Paladin
    (FileName: 'character.the_empire.paladin.png'; ResType: teGUI;),
    // Ranger
    (FileName: 'character.the_empire.ranger.png'; ResType: teGUI;),
    // Archmage
    (FileName: 'character.the_empire.archmage.png'; ResType: teGUI;),
    // Squire
    (FileName: 'character.the_empire.squire.png'; ResType: teGUI;),
    // Archer
    (FileName: 'character.the_empire.archer.png'; ResType: teGUI;),
    // Thief
    (FileName: 'character.the_empire.thief.png'; ResType: teGUI;),
    // Warlord
    (FileName: 'character.the_empire.warlord.png'; ResType: teGUI;),
    // Apprentice
    (FileName: 'character.the_empire.apprentice.png'; ResType: teGUI;),
    // Acolyte
    (FileName: 'character.the_empire.acolyte.png'; ResType: teGUI;),
    // Ashgan
    (FileName: 'character.undead_hordes.ashgan.png'; ResType: teGUI;),
    // Nosferat
    (FileName: 'character.undead_hordes.nosferat.png'; ResType: teGUI;),
    // Lich Queen
    (FileName: 'character.undead_hordes.lich_queen.png'; ResType: teGUI;),
    // Thug
    (FileName: 'character.undead_hordes.thug.png'; ResType: teGUI;),
    // Dominator
    (FileName: 'character.undead_hordes.dominator.png'; ResType: teGUI;),
    // Fighter
    (FileName: 'character.undead_hordes.fighter.png'; ResType: teGUI;),
    // Initiate
    (FileName: 'character.undead_hordes.initiate.png'; ResType: teGUI;),
    // Wyvern
    (FileName: 'character.undead_hordes.wyvern.png'; ResType: teGUI;),
    // Death Knight
    (FileName: 'character.undead_hordes.death_knight.png'; ResType: teGUI;),
    // Ashkael
    (FileName: 'character.legions_of_the_damned.ashkael.png'; ResType: teGUI;),
    // Duke
    (FileName: 'character.legions_of_the_damned.duke.png'; ResType: teGUI;),
    // Counselor
    (FileName: 'character.legions_of_the_damned.counselor.png';
    ResType: teGUI;),
    // Archdevil
    (FileName: 'character.legions_of_the_damned.archdevil.png';
    ResType: teGUI;),
    // Ripper
    (FileName: 'character.legions_of_the_damned.ripper.png'; ResType: teGUI;),
    // Chieftain
    (FileName: 'character.legions_of_the_damned.chieftain.png';
    ResType: teGUI;),
    // Possessed
    (FileName: 'character.legions_of_the_damned.possessed.png';
    ResType: teGUI;),
    // Cultist
    (FileName: 'character.legions_of_the_damned.cultist.png'; ResType: teGUI;),
    // Devil
    (FileName: 'character.legions_of_the_damned.devil.png'; ResType: teGUI;),
    // Black Dragon
    (FileName: 'character.neutrals.black_dragon.png'; ResType: teGUI;),
    // White Dragon
    (FileName: 'character.white_dragon.png'; ResType: teGUI;),
    // Red Dragon
    (FileName: 'character.red_dragon.png'; ResType: teGUI;),
    // Green Dragon
    (FileName: 'character.neutrals.green_dragon.png'; ResType: teGUI;),
    // Blue Dragon
    (FileName: 'character.blue_dragon.png'; ResType: teGUI;),
    // Goblin
    (FileName: 'character.goblin.png'; ResType: teGUI;),
    // Goblin Archer
    (FileName: 'character.goblin.archer.png'; ResType: teGUI;),
    // Goblin Elder
    (FileName: 'character.goblin.elder.png'; ResType: teGUI;),
    // Black Goblin
    (FileName: 'character.neutrals.black_goblin.png'; ResType: teGUI;),
    // Giant Spider
    (FileName: 'character.giant_spider.png'; ResType: teGUI;),
    // Wolf
    (FileName: 'character.neutrals.wolf.png'; ResType: teGUI;),
    // Dire Wolf
    (FileName: 'character.neutrals.dire_wolf.png'; ResType: teGUI;),
    // Spirit Wolf
    (FileName: 'character.neutrals.spirit_wolf.png'; ResType: teGUI;),
    // Polar Bear
    (FileName: 'character.neutrals.polar_bear.png'; ResType: teGUI;),
    // Brown Bear
    (FileName: 'character.neutrals.brown_bear.png'; ResType: teGUI;),
    // Black Bear
    (FileName: 'character.neutrals.black_bear.png'; ResType: teGUI;),
    // Orc
    (FileName: 'character.neutrals.orc.png'; ResType: teGUI;),
    // Ghost
    (FileName: 'character.undead_hordes.ghost.png'; ResType: teGUI;),
    // Imp
    (FileName: 'character.neutrals.imp.png'; ResType: teGUI;),
    // Ghoul
    (FileName: 'character.neutrals.ghoul.png'; ResType: teGUI;),
    // Stone Gargoyle
    (FileName: 'character.legions_of_the_damned.gargoyle.png'; ResType: teGUI;),
    // Reaper
    (FileName: 'character.neutrals.reaper.png'; ResType: teGUI;),
    // Rogue
    (FileName: 'character.neutrals.rogue.png'; ResType: teGUI;),
    // Trog
    (FileName: 'character.neutrals.trog.png'; ResType: teGUI;),

    // Text "High Scores"
    (FileName: 'text.high_scores.png'; ResType: teGUI;),
    // Text "Capital defenses"
    (FileName: 'text.capital_def.png'; ResType: teGUI;),
    // Text "City defenses"
    (FileName: 'text.city_def.png'; ResType: teGUI;),
    // Text "Play"
    (FileName: 'text.play.png'; ResType: teGUI;),
    // Text "Victory"
    (FileName: 'text.victory.png'; ResType: teGUI;),
    // Text "Defeat"
    (FileName: 'text.defeat.png'; ResType: teGUI;),
    // Text "Quit"
    (FileName: 'text.quit.png'; ResType: teGUI;),
    // Text "Continue"
    (FileName: 'text.continue.png'; ResType: teGUI;),
    // Text "Dismiss"
    (FileName: 'text.dismiss.png'; ResType: teGUI;),
    // Text "Recruit"
    (FileName: 'text.recruit.png'; ResType: teGUI;),
    // Text "Close"
    (FileName: 'text.close.png'; ResType: teGUI;),
    // Text "Ok"
    (FileName: 'text.ok.png'; ResType: teGUI;),
    // Text "Cancel"
    (FileName: 'text.cancel.png'; ResType: teGUI;),
    // Text "Leader's party"
    (FileName: 'text.lead_party.png'; ResType: teGUI;),
    // Text "Heal"
    (FileName: 'text.heal.png'; ResType: teGUI;),
    // Text "Revive"
    (FileName: 'text.revive.png'; ResType: teGUI;),
    // Text "Inventory"
    (FileName: 'text.inventory.png'; ResType: teGUI;),
    // Text "Abilities"
    (FileName: 'text.abilities.png'; ResType: teGUI;),
    // Text "Party"
    (FileName: 'text.party.png'; ResType: teGUI;),
    // Text "Temple"
    (FileName: 'text.temple.png'; ResType: teGUI;),
    // Text "Tower"
    (FileName: 'text.tower.png'; ResType: teGUI;),
    // Text "Barracks"
    (FileName: 'text.barracks.png'; ResType: teGUI;),
    // Text "Spellbook"
    (FileName: 'text.spellbook.png'; ResType: teGUI;),
    // Text "Cast"
    (FileName: 'text.cast.png'; ResType: teGUI;),
    // Text "Learn"
    (FileName: 'text.learn.png'; ResType: teGUI;),
    // Text "Faction"
    (FileName: 'text.faction.png'; ResType: teGUI;),
    // Text "Class"
    (FileName: 'text.class.png'; ResType: teGUI;),
    // Text "Random"
    (FileName: 'text.random.png'; ResType: teGUI;),
    // Text "Darkog Studio"
    (FileName: 'text.darkog_studio.png'; ResType: teGUI;),
    // Text "Presents"
    (FileName: 'text.presents.png'; ResType: teGUI;),
    // Text "Pickup"
    (FileName: 'text.pickup.png'; ResType: teGUI;),
    // Text "Merchant"
    (FileName: 'text.merchant.png'; ResType: teGUI;),
    // Text "Inform"
    (FileName: 'text.inform.png'; ResType: teGUI;),
    // Text "Log"
    (FileName: 'text.log.png'; ResType: teGUI;),

    // Title "Temple"
    (FileName: 'title.temple.png'; ResType: teGUI;),
    // Title "Recruit"
    (FileName: 'title.recruit.png'; ResType: teGUI;),
    // Title "High Scores"
    (FileName: 'title.high_scores.png'; ResType: teGUI;),
    // Title "Victory"
    (FileName: 'title.victory.png'; ResType: teGUI;),
    // Title "Defeat"
    (FileName: 'title.defeat.png'; ResType: teGUI;),
    // Title "Disciples RL"
    (FileName: 'title.logo.png'; ResType: teGUI;),
    // Title "Race"
    (FileName: 'title.race.png'; ResType: teGUI;),
    // Title "Scenario"
    (FileName: 'title.scenario.png'; ResType: teGUI;),
    // Title "Leader"
    (FileName: 'title.leader.png'; ResType: teGUI;),
    // Title "New Day"
    (FileName: 'text.new_day.png'; ResType: teGUI;),
    // Title "Loot"
    (FileName: 'title.loot.png'; ResType: teGUI;),
    // Title "Party"
    (FileName: 'title.party.png'; ResType: teGUI;),
    // Title "Battle"
    (FileName: 'title.battle.png'; ResType: teGUI;),
    // Title "Vorgel"
    (FileName: 'title.city.vorgel.png'; ResType: teGUI;),
    // Title "Entarion"
    (FileName: 'title.city.entarion.png'; ResType: teGUI;),
    // Title "Tardum"
    (FileName: 'title.city.tardum.png'; ResType: teGUI;),
    // Title "Temond"
    (FileName: 'title.city.temond.png'; ResType: teGUI;),
    // Title "Zerton"
    (FileName: 'title.city.zerton.png'; ResType: teGUI;),
    // Title "Doran"
    (FileName: 'title.city.doran.png'; ResType: teGUI;),
    // Title "Kront"
    (FileName: 'title.city.kront.png'; ResType: teGUI;),
    // Title "Himor"
    (FileName: 'title.city.himor.png'; ResType: teGUI;),
    // Title "Sodek"
    (FileName: 'title.city.sodek.png'; ResType: teGUI;),
    // Title "Sard"
    (FileName: 'title.city.sard.png'; ResType: teGUI;),
    // Title Difficulty
    (FileName: 'title.difficulty.png'; ResType: teGUI;),
    // Title Thief
    (FileName: 'title.thief.png'; ResType: teGUI;),
    // Title Warrior
    (FileName: 'title.warrior.png'; ResType: teGUI;),
    // Title "Abilities"
    (FileName: 'title.abilities.png'; ResType: teGUI;),
    // Title "Inventory"
    (FileName: 'title.inventory.png'; ResType: teGUI;),
    // Title "Spellbook"
    (FileName: 'title.spellbook.png'; ResType: teGUI;),
    // Title "Journal"
    (FileName: 'title.journal.png'; ResType: teGUI;),
    // Title "Mage Tower"
    (FileName: 'title.mage_tower.png'; ResType: teGUI;),
    // Title "Barracks"
    (FileName: 'title.barracks.png'; ResType: teGUI;),
    // Title "Enter Name"
    (FileName: 'title.enter_name.png'; ResType: teGUI;),
    // Title "Merchant"
    (FileName: 'title.merchant.png'; ResType: teGUI;),

    // Scenario "Dark Tower"
    (FileName: 'logo.scenario.darktower.png'; ResType: teGUI;),
    // Scenario "Overlord"
    (FileName: 'logo.scenario.overlord.png'; ResType: teGUI;),
    // Scenario "Ancient Knowledge"
    (FileName: 'logo.scenario.ancientknowledge.png'; ResType: teGUI;),

    // Difficulty Easy
    (FileName: 'logo.difficulty.easy.png'; ResType: teGUI;),
    // Difficulty Normal
    (FileName: 'logo.difficulty.normal.png'; ResType: teGUI;),
    // Difficulty Hard
    (FileName: 'logo.difficulty.hard.png'; ResType: teGUI;),

    // Thief Spy
    (FileName: 'logo.thief.spy.png'; ResType: teGUI;),
    // Thief Duel
    (FileName: 'logo.thief.duel.png'; ResType: teGUI;),
    // Thief Poison
    (FileName: 'logo.thief.poison.png'; ResType: teGUI;),
    // Warrior Rest
    (FileName: 'logo.warrior.rest.png'; ResType: teGUI;),
    // Warrior Ritual
    (FileName: 'logo.warrior.ritual.png'; ResType: teGUI;),
    // Warrior #3
    (FileName: 'logo.warrior.war3.png'; ResType: teGUI;),

    // Wallpaper Settlement
    (FileName: 'wallpaper.settlement.png'; ResType: teBG;),
    // Wallpaper Menu
    (FileName: 'wallpaper.menu.png'; ResType: teBG;),
    // Wallpaper Loot
    (FileName: 'wallpaper.loot.png'; ResType: teBG;),
    // Wallpaper Defeat
    (FileName: 'wallpaper.defeat.png'; ResType: teBG;),
    // Wallpaper Difficulty
    (FileName: 'wallpaper.difficulty.png'; ResType: teBG;),
    // Wallpaper Leader
    (FileName: 'wallpaper.leader.png'; ResType: teBG;),
    // Wallpaper Scenario
    (FileName: 'wallpaper.scenario.png'; ResType: teBG;),
    // Scores
    (FileName: 'icon.scores.png'; ResType: teIcon;),
    // Scores
    (FileName: 'icon.scores.over.png'; ResType: teIcon;),
    // Closed Gates
    (FileName: 'icon.gates.closed.png'; ResType: teIcon;),
    // Opened Gates
    (FileName: 'icon.gates.opened.png'; ResType: teIcon;),

    // SPELLBOOK BG //
    // The Empire
    (FileName: 'bg.the_empire.png'; ResType: teGUI;),
    // Undead Hordes
    (FileName: 'bg.undead_hordes.png'; ResType: teGUI;),
    // Legions Of The Damned
    (FileName: 'bg.legions_of_the_damned.png'; ResType: teGUI;),
    // Mountain Clans
    (FileName: 'bg.mountain_clans.png'; ResType: teGUI;),
    // Elven Alliance
    (FileName: 'bg.elven_alliance.png'; ResType: teGUI;),
    // Greenskin Tribes
    (FileName: 'bg.greenskin_tribes.png'; ResType: teGUI;),
    // Neutrals
    (FileName: 'bg.neutrals.png'; ResType: teGUI;),
    // Abilities
    (FileName: 'bg.abilities.png'; ResType: teGUI;),

    // RACES //
    // Human male
    (FileName: 'race.human.male.png'; ResType: teGUI;),

    // PANEL //
    // Button Menu
    (FileName: 'panel.button.menu.png'; ResType: teGUI;),
    // Button Party
    (FileName: 'panel.button.party.png'; ResType: teGUI;),
    // Button Cancel
    (FileName: 'panel.button.cancel.png'; ResType: teGUI;),
    // Button Spellbook
    (FileName: 'panel.button.spellbook.png'; ResType: teGUI;),
    // Button Inv
    (FileName: 'panel.button.inventory.png'; ResType: teGUI;),
    // Button Abilities
    (FileName: 'panel.button.abilities.png'; ResType: teGUI;),
    // Button Scenarion (Journal)
    (FileName: 'panel.button.scenario.png'; ResType: teGUI;)
    //
    );

const
  ItemResBase: array [TItemResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teItem;),
    // Gold
    (FileName: 'item.special.gold.png'; ResType: teItem;),
    // Mana
    (FileName: 'item.special.mana.png'; ResType: teItem;),
    // Stone Tablet
    (FileName: 'item.scenario.stone_tablet.png'; ResType: teItem;),
    // Life Potion
    (FileName: 'item.potion.life_potion.png'; ResType: teItem;),
    // Potion Of Healing
    (FileName: 'item.potion.potion_of_healing.png'; ResType: teItem;),
    // Potion Of Restoration
    (FileName: 'item.potion.potion_of_restoration.png'; ResType: teItem;),
    // Healing Ointment
    (FileName: 'item.potion.healing_oinment.png'; ResType: teItem;),

    // Stone Ring
    (FileName: 'item.ring.stone_ring.png'; ResType: teItem;),
    // Bronze Ring
    (FileName: 'item.ring.bronze_ring.png'; ResType: teItem;),
    // Gold Ring
    (FileName: 'item.ring.gold_ring.png'; ResType: teItem;),
    // Ring Of Strength
    (FileName: 'item.ring.ring_of_strength.png'; ResType: teItem;),
    // Silver Ring
    (FileName: 'item.ring.silver_ring.png'; ResType: teItem;),
    // Runic Key
    (FileName: 'item.valuable.runic_key.png'; ResType: teItem;),
    // Ice Crystal
    (FileName: 'item.artifact.ice_crystal.png'; ResType: teItem;),
    // Arcane Scroll
    (FileName: 'item.valuable.arcane_scroll.png'; ResType: teItem;),
    // Ember Salts
    (FileName: 'item.valuable.ember_salts.png'; ResType: teItem;),
    // Dwarven Bracer
    (FileName: 'item.artifact.dwarven_bracer.png'; ResType: teItem;),
    // Runestone
    (FileName: 'item.artifact.runestone.png'; ResType: teItem;),
    // Emerald
    (FileName: 'item.valuable.emerald.png'; ResType: teItem;),
    // Ruby
    (FileName: 'item.valuable.ruby.png'; ResType: teItem;),
    // Saphire
    (FileName: 'item.valuable.saphire.png'; ResType: teItem;),
    // Diamond
    (FileName: 'item.valuable.diamond.png'; ResType: teItem;),
    // Horn Of Awareness
    (FileName: 'item.artifact.horn_of_awareness.png'; ResType: teItem;),
    // Bethrezen's Claw
    (FileName: 'item.artifact.bethrezens_claw.png'; ResType: teItem;),
    // Horn Of Incubus
    (FileName: 'item.artifact.horn_of_incubus.png'; ResType: teItem;),

    // TALISMANS
    // Talisman of Restoration
    (FileName: 'item.talisman.talisman_of_restoration.png'; ResType: teItem;),
    // Talisman of Vigor
    (FileName: 'item.talisman.talisman_of_vigor.png'; ResType: teItem;),
    // Talisman of Protection
    (FileName: 'item.talisman.talisman_of_protection.png'; ResType: teItem;),

    // ORBS
    // Goblin Orb
    (FileName: 'item.orb.goblin_orb.png'; ResType: teItem;),
    // Orb Of Healing
    (FileName: 'item.orb.orb_of_healing.png'; ResType: teItem;),
    // Imp Orb
    (FileName: 'item.orb.imp_orb.png'; ResType: teItem;),
    // Orb Of Restoration
    (FileName: 'item.orb.orb_of_restoration.png'; ResType: teItem;),
    // Zombie Orb
    (FileName: 'item.orbs.zombie_orb.png'; ResType: teItem;),
    // Orb Of Life
    (FileName: 'item.orb.orb_of_life.png'; ResType: teItem;),
    // Lizardman Orb
    (FileName: 'item.orbs.lizardman_orb.png'; ResType: teItem;),

    // TOMES
    // Tome Of War
    (FileName: 'item.tome.tome_of_war.png'; ResType: teItem;),

    // BOOTS
    // Boots of Speed
    (FileName: 'item.boots.boots_of_speed.png'; ResType: teItem;),
    // Elven Boots
    (FileName: 'item.boots.elven_boots.png'; ResType: teItem;),
    // Boots Of Haste
    (FileName: 'item.boots.boots_of_haste.png'; ResType: teItem;),
    // Boots Of Darkness
    (FileName: 'item.boots.boots_of_darkness.png'; ResType: teItem;),
    // Boots Of Travelling
    (FileName: 'item.boots.boots_of_travelling.png'; ResType: teItem;),
    // Boots Of The Elements
    (FileName: 'item.boots.boots_of_the_elements.png'; ResType: teItem;),
    // Boots Of Seven Leagues
    (FileName: 'item.boots.boots_of_seven_leagues.png'; ResType: teItem;),

    // HELMS
    // Hood Of Darkness
    (FileName: 'item.helm.hood_of_darkness.png'; ResType: teItem;),

    // ARMORS
    // Shroud of Darkness
    (FileName: 'item.armor.shroud_of_darkness.png'; ResType: teItem;),

    // AMULETS
    // Amulet of Bloodbind
    (FileName: 'item.amulet.necklace_of_bloodbind.png'; ResType: teItem;),
    // Heart of Darkness
    (FileName: 'item.amulet.heart_of_darkness.png'; ResType: teItem;),

    // RINGS
    // Hag's Ring
    (FileName: 'item.ring.hags_ring.png'; ResType: teItem;)
    //
    );

const
  SpellResBase: array [TSpellResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teSpell;),
    // TrueHealing
    (FileName: 'spell.true_healing.png'; ResType: teSpell;),
    // Speed
    (FileName: 'spell.speed.png'; ResType: teSpell;),
    // Bless
    (FileName: 'spell.bless.png'; ResType: teSpell;),
    // LivingArmor
    (FileName: 'spell.living_armor.png'; ResType: teSpell;),
    // EagleEye
    (FileName: 'spell.eagle_eye.png'; ResType: teSpell;),
    // Strength
    (FileName: 'spell.strength.png'; ResType: teSpell;),
    // Plague
    (FileName: 'spell.plague.png'; ResType: teSpell;),
    // Concealment
    (FileName: 'spell.concealment.png'; ResType: teSpell;),
    // ChainsOfDread
    (FileName: 'spell.chains_of_dread.png'; ResType: teSpell;),
    // Curse
    (FileName: 'spell.curse.png'; ResType: teSpell;),
    // Weaken
    (FileName: 'spell.weaken.png'; ResType: teSpell;)
    //
    );

const
  AbilityResBase: array [TAbilityResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teSpell;),
    // Sharp Eye
    (FileName: 'ability.sharp_eye.png'; ResType: teGUI;),
    // Use Staffs and Scrolls
    (FileName: 'ability.use_staffs_and_scrolls.png'; ResType: teGUI;),
    // Arcane Lore
    (FileName: 'ability.arcane_lore.png'; ResType: teGUI;)
    //
    );

type
  TMusicEnum = (mmClick, mmStep, mmMagic, mmBattle, mmVictory, mmDefeat, mmWin,
    mmWinBattle, mmGame, mmMap, mmMenu, mmDay, mmSettlement, mmLoot, mmLevel,
    mmWar, mmExit, mmSwordAttack, mmAxeAttack, mmStaffAttack, mmBowAttack,
    mmSpearAttack, mmDaggerAttack, mmClubAttack, mmBlock, mmMiss,
    mmNosferatAttack, mmLichQueenAttack, mmHumHit, mmHumDeath, mmGoblinHit,
    mmGoblinDeath, mmSkeletonHit, mmSkeletonDeath, mmOrcHit, mmOrcDeath,
    mmWolfHit, mmWolfDeath, mmWolfAttack, mmBearHit, mmBearDeath, mmBearAttack,
    mmSpiderHit, mmSpiderDeath, mmSpiderAttack, mmGhostHit, mmGhostDeath,
    mmGhostAttack, mmGhoulAttack, mmGhoulHit, mmGhoulDeath, mmHit, mmDeath,
    mmAttack, mmGold, mmSpellbook, mmDismiss, mmPrepareMagic, mmDispell, mmHeal,
    mmPlague, mmInvisibility, mmRevive, mmMana, mmSpeed, mmLearn, mmDrink,
    mmUseOrb);

var
  ResImage: array [TResEnum] of TPNGImage;
  SpellResImage: array [TSpellResEnum] of TPNGImage;
  ItemResImage: array [TItemResEnum] of TPNGImage;
  AbilityResImage: array [TAbilityResEnum] of TPNGImage;
  ResMusicPath: array [TMusicEnum] of string;

const
  MusicBase: array [TMusicEnum] of TResBase = (
    // Click
    (FileName: 'click.wav'; ResType: teSound;),
    // Step
    (FileName: 'step.wav'; ResType: teSound;),
    // Magic
    (FileName: 'wasteland-theme.mp3'; ResType: teMusic;),
    // Battle
    (FileName: 'wasteland-showdown.mp3'; ResType: teMusic;),
    // Victory
    (FileName: 'warsong.mp3'; ResType: teMusic;),
    // Defeat
    (FileName: 'defeat.mp3'; ResType: teMusic;),
    // Win in battle
    (FileName: 'himwar.wav'; ResType: teSound;),
    // Win in battle
    (FileName: 'ubermensch.mp3'; ResType: teMusic;),
    // Game
    (FileName: 'soliloquy.mp3'; ResType: teMusic;),
    // Map
    (FileName: 'prologue.mp3'; ResType: teMusic;),
    // Menu
    (FileName: 'stellardrone.mp3'; ResType: teMusic;),
    // New Day
    (FileName: 'day.ogg'; ResType: teSound;),
    // Settlement
    (FileName: 'settlement.wav'; ResType: teSound;),
    // Loot
    (FileName: 'loot.wav'; ResType: teSound;),
    // New level
    (FileName: 'level.wav'; ResType: teSound;),
    // Round in battle
    (FileName: 'war.wav'; ResType: teSound;),
    // Exit
    (FileName: 'exit.wav'; ResType: teSound;),
    // Sword attack
    (FileName: 'sword_attack.wav'; ResType: teSound;),
    // Axe attack
    (FileName: 'axe_attack.wav'; ResType: teSound;),
    // Staff attack
    (FileName: 'staff_attack.wav'; ResType: teSound;),
    // Bow attack
    (FileName: 'bow_attack.wav'; ResType: teSound;),
    // Spear attack
    (FileName: 'spear_attack.wav'; ResType: teSound;),
    // Dagger attack
    (FileName: 'dagger_attack.wav'; ResType: teSound;),
    // Club attack
    (FileName: 'club_attack.wav'; ResType: teSound;),
    // Block
    (FileName: 'block.wav'; ResType: teSound;),
    // Miss
    (FileName: 'miss.ogg'; ResType: teSound;),
    // Nosferat Attack
    (FileName: 'nosferat_attack.mp3'; ResType: teSound;),
    // Lich Queen Attack
    (FileName: 'lich_queen_attack.mp3'; ResType: teSound;),
    // Humanoid Hit
    (FileName: 'hum_hit.wav'; ResType: teSound;),
    // Humanoid Death
    (FileName: 'hum_death.ogg'; ResType: teSound;),
    // Goblin Hit
    (FileName: 'goblin_hit.wav'; ResType: teSound;),
    // Goblin Death
    (FileName: 'goblin_death.wav'; ResType: teSound;),
    // Skeleton Hit
    (FileName: 'skeleton_hit.wav'; ResType: teSound;),
    // Skeleton Death
    (FileName: 'skeleton_death.wav'; ResType: teSound;),
    // Orc Hit
    (FileName: 'orc_hit.ogg'; ResType: teSound;),
    // Orc Death
    (FileName: 'orc_death.ogg'; ResType: teSound;),
    // Wolf Hit
    (FileName: 'wolf_hit.wav'; ResType: teSound;),
    // Wolf Death
    (FileName: 'wolf_death.wav'; ResType: teSound;),
    // Wolf Attack
    (FileName: 'wolf_attack.wav'; ResType: teSound;),
    // Bear Hit
    (FileName: 'bear_hit.wav'; ResType: teSound;),
    // Bear Death
    (FileName: 'bear_death.wav'; ResType: teSound;),
    // Bear Attack
    (FileName: 'bear_attack.wav'; ResType: teSound;),
    // Spider Hit
    (FileName: 'spider_hit.wav'; ResType: teSound;),
    // Spider Death
    (FileName: 'spider_death.wav'; ResType: teSound;),
    // Spider Attack
    (FileName: 'spider_attack.wav'; ResType: teSound;),
    // Ghost Hit
    (FileName: 'spider_hit.wav'; ResType: teSound;),
    // Ghost Death
    (FileName: 'spider_death.wav'; ResType: teSound;),
    // Ghost Attack
    (FileName: 'spider_attack.wav'; ResType: teSound;),
    // Ghoul Attack
    (FileName: 'ghoul_attack.ogg'; ResType: teSound;),
    // Ghoul Hit
    (FileName: 'ghoul_hit.ogg'; ResType: teSound;),
    // Ghoul Death
    (FileName: 'ghoul_death.ogg'; ResType: teSound;),
    // Hit
    (FileName: 'step.wav'; ResType: teSound;),
    // Death
    (FileName: 'step.wav'; ResType: teSound;),
    // Attack
    (FileName: 'step.wav'; ResType: teSound;),
    // Gold Coins
    (FileName: 'coin.wav'; ResType: teSound;),
    // Spellbook
    (FileName: 'spellbook.mp3'; ResType: teSound;),
    // Dismiss
    (FileName: 'dismiss.wav'; ResType: teSound;),
    // Prepare Magic
    (FileName: 'prepare_magic.wav'; ResType: teSound;),
    // Dispell
    (FileName: 'dispell.wav'; ResType: teSound;),
    // Heal
    (FileName: 'heal.wav'; ResType: teSound;),
    // Plague
    (FileName: 'plague.wav'; ResType: teSound;),
    // Invisibility
    (FileName: 'invisibility.wav'; ResType: teSound;),
    // Revive
    (FileName: 'revive.wav'; ResType: teSound;),
    // Mana
    (FileName: 'mana.wav'; ResType: teSound;),
    // Speed
    (FileName: 'speed.wav'; ResType: teSound;),
    // Learn
    (FileName: 'learn.wav'; ResType: teSound;),
    // Drink
    (FileName: 'use_elixir.ogg'; ResType: teSound;),
    // Use Orb or Talisman
    (FileName: 'use_orb.ogg'; ResType: teSound;)
    //
    );

type
  TResources = class(TObject)
  public
    class function GetPath(SubDir: string): string;
    class procedure ReadSections(const FileName: string; Sections: TStrings;
      Section: string = '');
    class function LoadFromFile(const FileName, SectionName, KeyName,
      DefaultValue: string): string; overload;
    class function LoadFromFile(const FileName, SectionName, KeyName: string;
      DefaultValue: Integer): Integer; overload;
    class procedure LoadFromFile(const FileName: string;
      var StringList: TStringList); overload;
    class function KeysCount(const FileName, SectionName: string): Integer;
    class function RandomValue(const FileName, SectionName: string): string;
    class function IndexValue(const AFileName, ASectionName: string;
      const AIndex: Integer): string;
    class function RandomSectionIdent(const FileName: string): string;
    class procedure LoadParties(const FileName: string);
  end;

implementation

uses
{$IFDEF FPC}
  FPJson,
  JsonParser,
  JsonScanner,
{$ELSE}
  JSON,
{$ENDIF}
  Math,
  SysUtils,
  Elinor.Saga,
  Elinor.Creatures,
  Elinor.Party;

class function TResources.GetPath(SubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + SubDir);
end;

class function TResources.RandomValue(const FileName,
  SectionName: string): string;
var
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    SL.LoadFromFile(GetPath('resources') + LowerCase(FileName) + '.json');
    JSONObject := TJSONObject.ParseJSONValue(SL.Text) as TJSONObject;
    try
      JSONArray := JSONObject.Get(SectionName).JsonValue as TJSONArray;
      Result := JSONArray.Items[RandomRange(0, JSONArray.Count)].Value;
    finally
      FreeAndNil(JSONObject);
    end;
  finally
    FreeAndNil(SL);
  end;
end;

class function TResources.IndexValue(const AFileName, ASectionName: string;
  const AIndex: Integer): string;
var
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    SL.LoadFromFile(GetPath('resources') + LowerCase(AFileName) + '.json');
    JSONObject := TJSONObject.ParseJSONValue(SL.Text) as TJSONObject;
    try
      JSONArray := JSONObject.Get(ASectionName).JsonValue as TJSONArray;
      Result := JSONArray.Items[AIndex].Value;
    finally
      FreeAndNil(JSONObject);
    end;
  finally
    FreeAndNil(SL);
  end;
end;

class procedure TResources.LoadParties(const FileName: string);
var
  JSONObject, LParty: TJSONObject;
  JSONArray: TJSONArray;
  SL, CL: TStringList;
  I, J, LLevel: Integer;
  LParties, LFaction, LCharacters: string;
  FF: TArray<string>;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(GetPath('resources') + LowerCase(FileName) + '.json');
    JSONObject := TJSONObject.ParseJSONValue(SL.Text) as TJSONObject;
    try
      LParties := JSONObject.GetValue('parties').ToJSON;
      JSONArray := TJSONObject.ParseJSONValue(LParties) as TJSONArray;
      for I := 0 to JSONArray.Count - 1 do
      begin
        LParty := TJSONObject.ParseJSONValue(JSONArray.Get(I).ToJSON)
          as TJSONObject;
        try
          LLevel := LParty.GetValue('level').ToString.ToInteger;
          LFaction := LParty.GetValue('faction').Value;
          LCharacters := LParty.GetValue('characters').Value;
          SetLength(PartyBase, Length(PartyBase) + 1);
          with PartyBase[Length(PartyBase) - 1] do
          begin
            Level := LLevel;
            Faction := TCreature.StrToFactionEnum(LFaction);
            FF := LCharacters.Split([',']);
            for J := Low(FF) to High(FF) do
              Character[J] := TCreature.StrToCharEnum(FF[J]);
          end;
        finally
          FreeAndNil(LParty);
        end;
      end;
    finally
      FreeAndNil(JSONArray);
      FreeAndNil(JSONObject);
    end;
  finally
    FreeAndNil(SL);
  end;
end;

class function TResources.KeysCount(const FileName,
  SectionName: string): Integer;
var
  IniFile: TMemIniFile;
  Keys: TStringList;
begin
  IniFile := TMemIniFile.Create(GetPath('resources') + FileName + '.ini',
    TEncoding.UTF8);
  try
    Keys := TStringList.Create;
    try
      IniFile.ReadSection(SectionName, Keys);
      Result := Keys.Count;
    finally
      FreeAndNil(Keys);
    end;
  finally
    FreeAndNil(IniFile);
  end;
end;

class function TResources.LoadFromFile(const FileName, SectionName,
  KeyName: string; DefaultValue: Integer): Integer;
var
  IniFile: TMemIniFile;
begin
  IniFile := TMemIniFile.Create(GetPath('resources') + FileName + '.ini',
    TEncoding.UTF8);
  try
    Result := IniFile.ReadInteger(SectionName, KeyName, DefaultValue);
  finally
    FreeAndNil(IniFile);
  end;
end;

class procedure TResources.LoadFromFile(const FileName: string;
  var StringList: TStringList);
begin
  StringList.LoadFromFile(GetPath('resources') + FileName + '.txt',
    TEncoding.UTF8);
end;

class function TResources.LoadFromFile(const FileName, SectionName, KeyName,
  DefaultValue: string): string;
var
  IniFile: TMemIniFile;
begin
  Result := DefaultValue;
  IniFile := TMemIniFile.Create(GetPath('resources') + FileName + '.ini',
    TEncoding.UTF8);
  try
    Result := IniFile.ReadString(SectionName.ToLower, KeyName, DefaultValue)
      .Trim.Replace('|', #13#10);
  finally
    FreeAndNil(IniFile);
  end;
end;

class function TResources.RandomSectionIdent(const FileName: string): string;
var
  FSections: TStringList;
begin
  FSections := TStringList.Create;
  try
    ReadSections(FileName, FSections);
    Result := FSections[Math.RandomRange(0, FSections.Count)].Trim;
  finally
    FreeAndNil(FSections);
  end;
end;

class procedure TResources.ReadSections(const FileName: string;
  Sections: TStrings; Section: string = '');
var
  IniFile: TMemIniFile;
  I: Integer;
begin
  IniFile := TMemIniFile.Create(GetPath('resources') + FileName + '.ini',
    TEncoding.UTF8);
  try
    IniFile.ReadSections(Sections);
    if Section <> '' then
      for I := Sections.Count - 1 downto 0 do
        if Sections[I].ToLower = Section.ToLower then
          Sections.Delete(I);
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure Init;
var
  LResEnum: TResEnum;
  LMusicEnum: TMusicEnum;
  LPartyLevel: Integer;
  LItemResEnum: TItemResEnum;
  LSpellResEnum: TSpellResEnum;
  LAbilityResEnum: TAbilityResEnum;
begin
  for LResEnum := Low(TResEnum) to High(TResEnum) do
  begin
    ResImage[LResEnum] := TPNGImage.Create;
    if (ResBase[LResEnum].FileName <> '') then
      ResImage[LResEnum].LoadFromFile(TResources.GetPath('resources') +
        ResBase[LResEnum].FileName);
  end;
  for LMusicEnum := Low(TMusicEnum) to High(TMusicEnum) do
  begin
    case MusicBase[LMusicEnum].ResType of
      teSound:
        ResMusicPath[LMusicEnum] := TResources.GetPath('resources\sounds') +
          MusicBase[LMusicEnum].FileName;
      teMusic:
        ResMusicPath[LMusicEnum] := TResources.GetPath('resources\music') +
          MusicBase[LMusicEnum].FileName;
    end;
  end;
  for LPartyLevel := 1 to 9 do
    TResources.LoadParties(Format('parties.level%d', [LPartyLevel]));
  for LSpellResEnum := Low(TSpellResEnum) to High(TSpellResEnum) do
  begin
    SpellResImage[LSpellResEnum] := TPNGImage.Create;
    if (SpellResBase[LSpellResEnum].FileName <> '') then
      SpellResImage[LSpellResEnum].LoadFromFile(TResources.GetPath('resources')
        + SpellResBase[LSpellResEnum].FileName);
  end;
  for LItemResEnum := Low(TItemResEnum) to High(TItemResEnum) do
  begin
    ItemResImage[LItemResEnum] := TPNGImage.Create;
    if (ItemResBase[LItemResEnum].FileName <> '') then
      ItemResImage[LItemResEnum].LoadFromFile(TResources.GetPath('resources') +
        ItemResBase[LItemResEnum].FileName);
  end;
  for LAbilityResEnum := Low(TAbilityResEnum) to High(TAbilityResEnum) do
  begin
    AbilityResImage[LAbilityResEnum] := TPNGImage.Create;
    if (AbilityResBase[LAbilityResEnum].FileName <> '') then
      AbilityResImage[LAbilityResEnum].LoadFromFile
        (TResources.GetPath('resources') + AbilityResBase[LAbilityResEnum]
        .FileName);
  end;
end;

procedure Free;
var
  LResEnum: TResEnum;
  LItemResEnum: TItemResEnum;
  LSpellResEnum: TSpellResEnum;
  LAbilityResEnum: TAbilityResEnum;
begin
  for LResEnum := Low(TResEnum) to High(TResEnum) do
    FreeAndNil(ResImage[LResEnum]);
  for LItemResEnum := Low(TItemResEnum) to High(TItemResEnum) do
    FreeAndNil(ItemResImage[LItemResEnum]);
  for LSpellResEnum := Low(TSpellResEnum) to High(TSpellResEnum) do
    FreeAndNil(SpellResImage[LSpellResEnum]);
  for LAbilityResEnum := Low(TAbilityResEnum) to High(TAbilityResEnum) do
    FreeAndNil(AbilityResImage[LAbilityResEnum]);
end;

initialization

Init;

finalization

Free;

end.
