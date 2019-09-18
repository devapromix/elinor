unit DisciplesRL.Resources;

interface

uses
  Vcl.Imaging.PNGImage;

type
  TResEnum = (reNone, rePlus, reTheEmpireLogo, reUndeadHordesLogo, reLegionsOfTheDamnedLogo, reBGChar, reBGEnemy, reDead, reFrame, reActFrame,
    reInfoFrame, reNeutralTerrain, reTheEmpireTerrain, reUndeadHordesTerrain, reLegionsOfTheDamnedTerrain, reUnk, reEnemy, reCursor, rePlayer, reDark,
    reGold, reBag, reNeutralCity, reTheEmpireCity, reUndeadHordesCity, reLegionsOfTheDamnedCity, reTheEmpireCapital, reUndeadHordesCapital,
    reLegionsOfTheDamnedCapital, reRuin, reTower, reTreePine, reTreeOak, reMine, reMountain, reButtonDef, reButtonAct, reCorpse, reMyzrael,
    rePegasusKnight, reRanger, reArchmage, reSquire, reArcher, reApprentice, reAcolyte, reBlackDragon, reWhiteDragon, reRedDragon, reGreenDragon,
    reBlueDragon, reGoblin, reGoblinArcher, reGiantSpider, reWolf, reOrc, reTextHighScores, reTextCapitalDef, reTextCityDef, reTextPlay,
    reTextVictory, reTextDefeat, reTextQuit, reTextContinue, reTextDismiss, reTextHire, reTextClose, reTextOk, reTextCancel, reTextLeadParty,
    reTextHeal, reTextRevive, reTitleHire, reTitleHighScores, reTitleVictory, reTitleDefeat, reTitleLogo, reTitleRace, reTitleScenario, reTitleLeader,
    reTitleNewDay, reTitleLoot, reTitleParty);

const
  Capitals = [reTheEmpireCapital, reUndeadHordesCapital, reLegionsOfTheDamnedCapital];
  Cities = [reTheEmpireCity, reUndeadHordesCity, reLegionsOfTheDamnedCity];
  Tiles = [reTheEmpireTerrain, reUndeadHordesTerrain, reLegionsOfTheDamnedTerrain];

type
  TResTypeEnum = (teNone, teTree, teTile, teGUI, tePath, teObject, tePlayer, teEnemy, teBag, teRes, teCapital, teCity, teRuin, teTower, teMine);

type
  TResBase = record
    FileName: string;
    ResType: TResTypeEnum;
  end;

const
  ResBase: array [TResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teNone;),
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
    // Active Frame
    (FileName: 'actframe.png'; ResType: teGUI;),
    // Info Frame
    (FileName: 'info_frame.png'; ResType: teGUI;),
    // Neutral Terrain
    (FileName: 'dirt.png'; ResType: teTile;),
    // Empire Terrain
    (FileName: 'tile.the_empire.png'; ResType: teTile;),
    // Undead Hordes Terrain
    (FileName: 'tile.undead_hordes.png'; ResType: teTile;),
    // Legions Of The Damned Terrain
    (FileName: 'tile.legions_of_the_damned.png'; ResType: teTile;),
    // Unknown (?)
    (FileName: 'unknown.png'; ResType: teGUI;),
    // Enemy party
    (FileName: 'enemy.png'; ResType: teEnemy;),
    // Frame
    (FileName: 'select.png'; ResType: teGUI;),
    // Player
    (FileName: 'player.png'; ResType: tePlayer;),
    // Fog
    (FileName: 'transparent.png'; ResType: teGUI;),
    // Gold
    (FileName: 'gold.png'; ResType: teRes;),
    // Bag
    (FileName: 'chest.png'; ResType: teBag;),
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
    (FileName: 'ruin.png'; ResType: teRuin;),
    // Tower
    (FileName: 'tower.png'; ResType: teTower;),
    // Pine
    (FileName: 'tree.pine.png'; ResType: teTree;),
    // Oak
    (FileName: 'tree.oak.png'; ResType: teTree;),
    // Gold Mine
    (FileName: 'mine.gold.png'; ResType: teMine;),
    // Mountain
    (FileName: 'mountain.png'; ResType: teObject;),
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
    (FileName: 'title.party.png'; ResType: teGUI;)
    //
    );

var
  ResImage: array [TResEnum] of TPNGImage;

function GetPath(SubDir: string): string;
procedure Init;
procedure Free;

implementation

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
begin
  for I := Low(TResEnum) to High(TResEnum) do
  begin
    ResImage[I] := TPNGImage.Create;
    if (ResBase[I].FileName <> '') then
      ResImage[I].LoadFromFile(GetPath('resources') + ResBase[I].FileName);
  end;
end;

procedure Free;
var
  I: TResEnum;
begin
  for I := Low(TResEnum) to High(TResEnum) do
    FreeAndNil(ResImage[I]);
end;

end.
