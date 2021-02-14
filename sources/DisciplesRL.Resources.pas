unit DisciplesRL.Resources;

interface

{$IFDEF FPC}

type
  TResEnum = Cardinal;

const
  //
  reNone = 0;
  reDark = 0;

  //
  //
  reTreePine = $E009;
  reTreeOak = $E010;
  reMountain1 = $E006;
  reMountain2 = $E007;
  reMountain3 = $E008;

  //
  reNeutralTerrain = $E000;
  reTheEmpireTerrain = 1;
  reUndeadHordesTerrain = 2;
  reLegionsOfTheDamnedTerrain = 3;

  //
  reTheEmpireCapital = 0;
  reUndeadHordesCapital = 1;
  reLegionsOfTheDamnedCapital = 2;

  //
  reNeutralCity = -1;
  reTheEmpireCity = 0;
  reUndeadHordesCity = 1;
  reLegionsOfTheDamnedCity = 2;

  //
  reEnemy = 0;
  reGold = 1;
  reBag = 2;

  //
  reMyzrael = 0;
  rePegasusKnight = 0;
  reRanger = 0;
  reArchmage = 0;
  reSquire = 0;
  reArcher = 0;
  reApprentice = 0;
  reAcolyte = 0;
  reAshgan = 0;
  reAshkael = 0;
  reGoblin = 0;
  reGoblinArcher = 0;
  reOrc = 0;
  reGiantSpider = 0;
  reWolf = 0;

type
  TResources = class(TObject)
    constructor Create;
  end;

{$ELSE}

uses
  Vcl.Imaging.PNGImage;

type
  TResEnum = (reNone, reDay, rePlus, reTheEmpireLogo, reUndeadHordesLogo,
    reLegionsOfTheDamnedLogo, reBGChar, reBGEnemy, reDead, reFrame,
    reSmallFrame, reActFrame, reBigFrame, reInfoFrame, reNeutralTerrain,
    reTheEmpireTerrain, reUndeadHordesTerrain, reLegionsOfTheDamnedTerrain,
    reUnk, reEnemy, reCursorSpecial, reCursor, reNoWay, rePlayer, reDark,
    reGold, reMana, reBag, reNeutralCity, reTheEmpireCity, reUndeadHordesCity,
    reLegionsOfTheDamnedCity, reTheEmpireCapital, reUndeadHordesCapital,
    reLegionsOfTheDamnedCapital, reRuin, reTower, reTreePine, reTreeOak,
    reMineGold, reMineMana, reMountain1, reMountain2, reMountain3, reMountain4,
    reButtonDef, reButtonAct, reCorpse, reMyzrael, rePegasusKnight, reRanger,
    reArchmage, reSquire, reArcher, reApprentice, reAcolyte, reAshkael,
    reAshgan, reBlackDragon, reWhiteDragon, reRedDragon, reGreenDragon,
    reBlueDragon, reGoblin, reGoblinArcher, reGiantSpider, reWolf, reOrc,
    reTextHighScores, reTextCapitalDef, reTextCityDef, reTextPlay,
    reTextVictory, reTextDefeat, reTextQuit, reTextContinue, reTextDismiss,
    reTextHire, reTextClose, reTextOk, reTextCancel, reTextLeadParty,
    reTextHeal, reTextRevive, reTitleHire, reTitleHighScores, reTitleVictory,
    reTitleDefeat, reTitleLogo, reTitleRace, reTitleScenario, reTitleLeader,
    reTitleNewDay, reTitleLoot, reTitleParty, reTitleBattle, reTitleVorgel,
    reTitleEntarion, reTitleTardum, reTitleTemond, reTitleZerton, reTitleDoran,
    reTitleKront, reTitleHimor, reTitleSodek, reTitleSard, reTitleDifficulty,
    reScenarioDarkTower, reScenarioOverlord, reScenarioAncientKnowledge,
    reItemGold, reItemMana, reItemStoneTable, reDifficultyEasyLogo,
    reDifficultyNormalLogo, reDifficultyHardLogo, reWallpaperSettlement,
    reWallpaperMenu, reWallpaperLoot, reWallpaperDefeat);

{$ENDIF}

const
  Capitals = [reTheEmpireCapital, reUndeadHordesCapital,
    reLegionsOfTheDamnedCapital];
  Cities = [reTheEmpireCity, reUndeadHordesCity, reLegionsOfTheDamnedCity];
  Tiles = [reTheEmpireTerrain, reUndeadHordesTerrain,
    reLegionsOfTheDamnedTerrain];
  MountainTiles = [reMountain1, reMountain2, reMountain3, reMountain4];
  StopTiles = MountainTiles + [reDark];

{$IFDEF FPC}
{$ELSE}

type
  TResTypeEnum = (teNone, teTree, teTile, teGUI, tePath, teObject, tePlayer,
    teEnemy, teBag, teRes, teCapital, teCity, teRuin, teTower, teMine, teMusic,
    teSound, teItem, teBG);

type
  TResBase = record
    FileName: string;
    ResType: TResTypeEnum;
  end;

const
  ResBase: array [TResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teNone;),
    // Day
    (FileName: 'day.png'; ResType: teGUI;),
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
    // Череп
    (FileName: 'corpse.png'; ResType: teGUI;),
    // Frame
    (FileName: 'frame.png'; ResType: teGUI;),
    // Small Frame
    (FileName: 'frame.small.png'; ResType: teGUI;),
    // Active Frame
    (FileName: 'actframe.png'; ResType: teGUI;),
    // Big Frame
    (FileName: 'big_frame.png'; ResType: teGUI;),
    // Info Frame
    (FileName: 'info_frame.png'; ResType: teGUI;),
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
    (FileName: 'select.png'; ResType: teGUI;),
    // NoFrame
    (FileName: 'noselect.png'; ResType: teGUI;),
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
    // Pine
    (FileName: 'tile.tree.pine.png'; ResType: teTree;),
    // Oak
    (FileName: 'tile.tree.oak.png'; ResType: teTree;),
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
    // Button
    (FileName: 'buttondef.png'; ResType: teGUI;),
    // Button
    (FileName: 'buttonact.png'; ResType: teGUI;),
    // Corpse
    (FileName: 'corpse.png'; ResType: teGUI;),
    // Myzrael
    (FileName: 'character.myzrael.png'; ResType: teGUI;),
    // Pegasus Knight
    (FileName: 'character.pegasus_knight.png'; ResType: teGUI;),
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
    (FileName: 'character.ashkael.png'; ResType: teGUI;),
    // Ashgan
    (FileName: 'character.ashgan.png'; ResType: teGUI;),
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
    (FileName: 'character.goblin_archer.png'; ResType: teGUI;),
    // Giant Spider
    (FileName: 'character.giant_spider.png'; ResType: teGUI;),
    // Wolf
    (FileName: 'character.wolf.png'; ResType: teGUI;),
    // Orc
    (FileName: 'character.orc.png'; ResType: teGUI;),
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
    (FileName: 'title.new_day.png'; ResType: teGUI;),
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
    (FileName: 'logo.scenario.darktower.png'; ResType: teGUI;),
    // Difficulty Normal
    (FileName: 'logo.scenario.overlord.png'; ResType: teGUI;),
    // Difficulty Hard
    (FileName: 'logo.scenario.ancientknowledge.png'; ResType: teGUI;),
    // Wallpaper Settlement
    (FileName: 'wallpaper.settlement.png'; ResType: teBG;),
    // Wallpaper Menu
    (FileName: 'wallpaper.menu.png'; ResType: teBG;),
    // Wallpaper Loot
    (FileName: 'wallpaper.loot.png'; ResType: teBG;),
    // Wallpaper Defeat
    (FileName: 'wallpaper.defeat.png'; ResType: teBG;)
    //
    );

type
  TMusicEnum = (mmClick, mmBattle, mmVictory, mmDefeat, mmWin, mmGame, mmMap,
    mmMenu, mmDay, mmSettlement, mmLoot, mmLevel, mmWar, mmExit);

var
  ResImage: array [TResEnum] of TPNGImage;
  ResMusicPath: array [TMusicEnum] of string;

const
  MusicBase: array [TMusicEnum] of TResBase = (
    // Click
    (FileName: 'click.wav'; ResType: teSound;),
    // Battle
    (FileName: 'wasteland-showdown.mp3'; ResType: teMusic;),
    // Victory
    (FileName: 'warsong.mp3'; ResType: teMusic;),
    // Defeat
    (FileName: 'defeat.mp3'; ResType: teMusic;),
    // Win in battle
    (FileName: 'himwar.wav'; ResType: teSound;),
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
    //
    (FileName: 'exit.wav'; ResType: teSound;)
    //
    );

{$ENDIF}

implementation

{$IFDEF FPC}

uses
  SysUtils,
  Classes,
  BearLibTerminal;

{ TResources }

constructor TResources.Create;
var
  I: Word;
  Resources: TStringList;
begin
  Resources := TStringList.Create;
  try
    writeln('LOADING RESOURCES...');
    Resources.LoadFromFile('resources\resources.txt');
    for I := 0 to Resources.Count - 1 do
      if (Trim(Resources[I]) <> '') then
      begin
        terminal_set(Resources[I]);
        writeln(Resources[I]);
      end;
  finally
    FreeAndNil(Resources);
  end;
end;

{$ELSE}

uses
  System.SysUtils,
  Vcl.Graphics;

function GetPath(SubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + SubDir);
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
end;

procedure Free;
var
  I: TResEnum;
begin
  for I := Low(TResEnum) to High(TResEnum) do
    FreeAndNil(ResImage[I]);
end;

{$ENDIF}

initialization

{$IFNDEF FPC}
  Init;
{$ENDIF}

finalization

{$IFNDEF FPC}
  Free;
{$ENDIF}

end.
