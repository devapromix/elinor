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

    reAMark, reASell,

    rePlus, reTheEmpireLogo, reUndeadHordesLogo, reLegionsOfTheDamnedLogo,
    reBGChar, reBGEnemy, reBGParalyze, reDead,

    reFrame, reSelectFrame, reSmallFrame, reActFrame, rePasFrame, reBigFrame,
    reInfoFrame, reItemFrame,

    reTime, reNeutralTerrain, reTheEmpireTerrain, reUndeadHordesTerrain,
    reLegionsOfTheDamnedTerrain, reUnk, reEnemy, reCursorSpecial, reCursor,
    reNoWay, reCursorMagic, rePlayer, reDark, reGold, reMana, reBag,
    reNeutralCity, reTheEmpireCity, reUndeadHordesCity,
    reLegionsOfTheDamnedCity, reTheEmpireCapital, reUndeadHordesCapital,
    reLegionsOfTheDamnedCapital, reRuin, reTower, reSTower, reTreePine,
    reTreeOak, reUndeadHordesTree, reLegionsOfTheDamnedTree, reMineGold,
    reMineMana, reMountain1, reMountain2, reMountain3, reMountain4, reTree1,
    reTree2, reTree3, reTree4, reButtonDef, reButtonAct, reCorpse,
    // Creatures
    reMyzrael, rePaladin, reDeathKnight, reRanger, reArchmage, reSquire,
    reArcher, reApprentice, reAcolyte, reAshkael, reAshgan, reDuke, reCounselor,
    reArchdevil, reRipper, reChieftain, rePossessed, reCultist, reDevil,
    reBlackDragon, reWhiteDragon, reRedDragon, reGreenDragon, reBlueDragon,
    reGoblin, reGoblinArcher, reGoblinElder, reGiantSpider, reWolf, reBear,
    reOrc, reGhost, reImp, reGhoul, reStoneGargoyle,
    // Text
    reTextHighScores, reTextCapitalDef, reTextCityDef, reTextPlay,
    reTextVictory, reTextDefeat, reTextQuit, reTextContinue, reTextDismiss,
    reTextHire, reTextClose, reTextOk, reTextCancel, reTextLeadParty,
    reTextHeal, reTextRevive, reTextInventory, reTextAbilities,
    // Title
    reTitleHire, reTitleHighScores, reTitleVictory, reTitleDefeat, reTitleLogo,
    reTitleRace, reTitleScenario, reTitleLeader, reTextNewDay, reTitleLoot,
    reTitleParty, reTitleBattle, reTitleVorgel, reTitleEntarion, reTitleTardum,
    reTitleTemond, reTitleZerton, reTitleDoran, reTitleKront, reTitleHimor,
    reTitleSodek, reTitleSard, reTitleDifficulty, reTitleThief, reTitleWarrior,
    reTitleAbilities, reTitleInventory, reTitleSpellbook,

    reScenarioDarkTower, reScenarioOverlord, reScenarioAncientKnowledge,
    reItemGold, reItemMana, reItemStoneTable, reDifficultyEasyLogo,
    reDifficultyNormalLogo, reDifficultyHardLogo, reThiefSpy, reThiefDuel,
    reThiefPoison,

    reWarriorRest,

    reWarriorRitual,

    reWarriorWar3, reWallpaperSettlement, reWallpaperMenu, reWallpaperLoot,
    reWallpaperDefeat, reWallpaperDifficulty, reWallpaperLeader,
    reWallpaperScenario, reIconScores, reIconScoresOver, reIconClosedGates,
    reIconOpenedGates);

const
  Capitals = [reTheEmpireCapital, reUndeadHordesCapital,
    reLegionsOfTheDamnedCapital];
  Cities = [reTheEmpireCity, reUndeadHordesCity, reLegionsOfTheDamnedCity];
  Tiles = [reTheEmpireTerrain, reUndeadHordesTerrain,
    reLegionsOfTheDamnedTerrain];
  MountainTiles = [reMountain1, reMountain2, reMountain3, reMountain4];
  StopTiles = MountainTiles + [reDark];
  TreesTiles = [reTreePine, reTreeOak, reTree1, reTree2, reTree3, reTree4];

type
  TResTypeEnum = (teNone, teTree, teTile, teGUI, tePath, teObject, tePlayer,
    teEnemy, teBag, teRes, teCapital, teCity, teRuin, teTower, teMine, teMusic,
    teSound, teItem, teBG, teIcon, teTheEmpireABC);

type
  TResBase = record
    FileName: string;
    ResType: TResTypeEnum;
  end;

const
  ResBase: array [TResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teNone;),

    // AMark
    (FileName: 'path.amark.png'; ResType: tePath;),
    // ASell
    (FileName: 'path.asell.png'; ResType: tePath;),

    // Plus
    (FileName: 'plus.png'; ResType: teGUI;),
    // The Empire Logo
    (FileName: 'logo.the_empire.png'; ResType: teGUI;),
    // Undead Hordes Logo
    (FileName: 'logo.undead_hordes.png'; ResType: teGUI;),
    // Legions Of The Damned Logo
    (FileName: 'logo.legions_of_the_damned.png'; ResType: teGUI;),
    // Фон для друж. юнитов
    (FileName: 'bg.character.png'; ResType: teGUI;),
    // Фон для врагов
    (FileName: 'bg.enemy.png'; ResType: teGUI;),
    // Фон для эф. паралич
    (FileName: 'bg.paralyze.png'; ResType: teGUI;),
    // Череп
    (FileName: 'corpse.png'; ResType: teGUI;),
    // Frame
    (FileName: 'frame.png'; ResType: teGUI;),
    // Select Frame
    (FileName: 'frame.select.png'; ResType: teGUI;),
    // Small Frame
    (FileName: 'frame.small.png'; ResType: teGUI;),
    // Active Frame
    (FileName: 'actframe.png'; ResType: teGUI;),
    // Passive Frame
    (FileName: 'pasframe.png'; ResType: teGUI;),
    // Big Frame
    (FileName: 'big_frame.png'; ResType: teGUI;),
    // Info Frame
    (FileName: 'frame.info.png'; ResType: teGUI;),
    // Item Frame
    (FileName: 'frame.item.png'; ResType: teGUI;),
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
    // Fog
    (FileName: 'transparent.png'; ResType: teGUI;),
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
    // Pine
    (FileName: 'tile.tree.pine.png'; ResType: teTree;),
    // Oak
    (FileName: 'tile.tree.oak.png'; ResType: teTree;),
    // Undead Hordes Tree
    (FileName: 'tile.tree.undead_hordes.png'; ResType: teTree;),
    // Legions Of The Damned Tree
    (FileName: 'tile.tree.legions_of_the_damned.png'; ResType: teTree;),
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
    // Button
    (FileName: 'button.def.png'; ResType: teGUI;),
    // Button
    (FileName: 'button.act.png'; ResType: teGUI;),
    // Corpse
    (FileName: 'corpse.png'; ResType: teGUI;),
    // Myzrael
    (FileName: 'character.myzrael.png'; ResType: teGUI;),
    // Paladin
    (FileName: 'character.paladin.png'; ResType: teGUI;),
    // Death Knight
    (FileName: 'character.death_knight.png'; ResType: teGUI;),
    // Ranger
    (FileName: 'character.ranger.png'; ResType: teGUI;),
    // Archmage
    (FileName: 'character.archmage.png'; ResType: teGUI;),
    // Squire
    (FileName: 'character.squire.png'; ResType: teGUI;),
    // Archer
    (FileName: 'character.archer.png'; ResType: teGUI;),
    // Apprentice
    (FileName: 'character.apprentice.png'; ResType: teGUI;),
    // Acolyte
    (FileName: 'character.acolyte.png'; ResType: teGUI;),
    // Ashkael
    (FileName: 'character.legions_of_the_damned.ashkael.png'; ResType: teGUI;),
    // Ashgan
    (FileName: 'character.ashgan.png'; ResType: teGUI;),
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
    (FileName: 'character.black_dragon.png'; ResType: teGUI;),
    // White Dragon
    (FileName: 'character.white_dragon.png'; ResType: teGUI;),
    // Red Dragon
    (FileName: 'character.red_dragon.png'; ResType: teGUI;),
    // Green Dragon
    (FileName: 'character.green_dragon.png'; ResType: teGUI;),
    // Blue Dragon
    (FileName: 'character.blue_dragon.png'; ResType: teGUI;),
    // Goblin
    (FileName: 'character.goblin.png'; ResType: teGUI;),
    // Goblin Archer
    (FileName: 'character.goblin.archer.png'; ResType: teGUI;),
    // Goblin Elder
    (FileName: 'character.goblin.elder.png'; ResType: teGUI;),
    // Giant Spider
    (FileName: 'character.giant_spider.png'; ResType: teGUI;),
    // Wolf
    (FileName: 'character.wolf.png'; ResType: teGUI;),
    // Bear
    (FileName: 'character.bear.png'; ResType: teGUI;),
    // Orc
    (FileName: 'character.orc.png'; ResType: teGUI;),
    // Ghost
    (FileName: 'character.ghost.png'; ResType: teGUI;),
    // Imp
    (FileName: 'character.neutrals.imp.png'; ResType: teGUI;),
    // Ghoul
    (FileName: 'character.ghoul.png'; ResType: teGUI;),
    // Stone Gargoyle
    (FileName: 'character.legions_of_the_damned.gargoyle.png'; ResType: teGUI;),
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
    // Text "Hire"
    (FileName: 'text.hire.png'; ResType: teGUI;),
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

    // Title "Hire"
    (FileName: 'title.hire.png'; ResType: teGUI;),
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

    // Scenario "Dark Tower"
    (FileName: 'logo.scenario.darktower.png'; ResType: teGUI;),
    // Scenario "Overlord"
    (FileName: 'logo.scenario.overlord.png'; ResType: teGUI;),
    // Scenario "Ancient Knowledge"
    (FileName: 'logo.scenario.ancientknowledge.png'; ResType: teGUI;),
    // Item Gold
    (FileName: 'item.gold.png'; ResType: teItem;),
    // Item Mana
    (FileName: 'item.mana.png'; ResType: teItem;),
    // Item Stone Table
    (FileName: 'item.stone_table.png'; ResType: teItem;),
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
    (FileName: 'icon.gates.opened.png'; ResType: teIcon;)
    );

type
  TMusicEnum = (mmClick, mmStep, mmBattle, mmVictory, mmDefeat, mmWin,
    mmWinBattle, mmGame, mmMap, mmMenu, mmDay, mmSettlement, mmLoot, mmLevel,
    mmWar, mmExit, mmSwordAttack, mmAxeAttack, mmStaffAttack, mmBowAttack,
    mmSpearAttack, mmDaggerAttack, mmClubAttack, mmBlock, mmMiss,
    mmNosferatAttack, mmLichQueenAttack, mmHumHit, mmHumDeath, mmGoblinHit,
    mmGoblinDeath, mmSkeletonHit, mmSkeletonDeath, mmOrcHit, mmOrcDeath,
    mmWolfHit, mmWolfDeath, mmWolfAttack, mmBearHit, mmBearDeath, mmBearAttack,
    mmSpiderHit, mmSpiderDeath, mmSpiderAttack, mmGhostHit, mmGhostDeath,
    mmGhostAttack, mmGhoulAttack, mmGhoulHit, mmGhoulDeath, mmHit, mmDeath,
    mmAttack, mmGold, mmSpellbook);

var
  ResImage: array [TResEnum] of TPNGImage;
  ResMusicPath: array [TMusicEnum] of string;

const
  MusicBase: array [TMusicEnum] of TResBase = (
    // Click
    (FileName: 'click.wav'; ResType: teSound;),
    // Step
    (FileName: 'step.wav'; ResType: teSound;),
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
    (FileName: 'spellbook.mp3'; ResType: teSound;)
    //
    );

type
  TResources = class(TObject)
  public
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
  DisciplesRL.Creatures;

function GetPath(SubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + SubDir);
end;

class function TResources.RandomValue(const FileName,
  SectionName: string): string;
var
{$IFDEF FPC}
  JSONData: TJSONData;
  S: string;
  I: Integer;
{$ELSE}
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
{$ENDIF}
  SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    SL.LoadFromFile(GetPath('resources') + LowerCase(FileName) + '.json');
{$IFDEF FPC}
    JSONData := GetJSON(SL.Text);
    I := JSONData.FindPath(SectionName).Count;
    Result := JSONData.FindPath(SectionName).Items[RandomRange(0, I)].AsString;
{$ELSE}
    JSONObject := TJSONObject.ParseJSONValue(SL.Text) as TJSONObject;
    try
      JSONArray := JSONObject.Get(SectionName).JsonValue as TJSONArray;
      Result := JSONArray.Items[RandomRange(0, JSONArray.Count)].Value;
    finally
      FreeAndNil(JSONObject);
    end;
{$ENDIF}
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
          SetLength(TSaga.PartyBase, Length(TSaga.PartyBase) + 1);
          with TSaga.PartyBase[Length(TSaga.PartyBase) - 1] do
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
  I: TResEnum;
  J: TMusicEnum;
begin
  for I := Low(TResEnum) to High(TResEnum) do
  begin
    ResImage[I] := TPNGImage.Create;
    if (ResBase[I].FileName <> '') then
      ResImage[I].LoadFromFile(GetPath('resources') + ResBase[I].FileName);
  end;
  for J := Low(TMusicEnum) to High(TMusicEnum) do
  begin
    case MusicBase[J].ResType of
      teSound:
        ResMusicPath[J] := GetPath('resources\sounds') + MusicBase[J].FileName;
      teMusic:
        ResMusicPath[J] := GetPath('resources\music') + MusicBase[J].FileName;
    end;
  end;
  TResources.LoadParties('parties');
end;

procedure Free;
var
  I: TResEnum;
begin
  for I := Low(TResEnum) to High(TResEnum) do
    FreeAndNil(ResImage[I]);
end;

initialization

Init;

finalization

Free;

end.
