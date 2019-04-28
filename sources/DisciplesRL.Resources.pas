unit DisciplesRL.Resources;

interface

uses
  Vcl.Imaging.PNGImage;

type
  TResEnum = (reNone, reBGChar, reBGEnemy, reDead, reFrame, reActFrame, reInfoFrame, reNeutral, reTheEmpireTerrain, reUnk, reEnemies, reCursor,
    rePlayer, reDark, reGold, reBag, reNeutralCity, reTheEmpireCity, reTheEmpireCapital, reRuin, reTower, reTreePine, reTreeOak, reMine, reMountain,
    reTextHighScores, reTextCapitalDef, reTextCityDef, reTextPlay, reTextVictory, reTextDefeat, reButtonDef, reButtonAct, reCorpse, reDragon,
    reGoblin, reSpider, reTextQuit, reTextDismiss, reTextHire, reTextClose, reTextLeadParty, reTextHeal, reTextRevive, reTitleHire, reTitleHighScores,
    reTitleVictory, reTitleDefeat, reTitleLogo);

type
  TResTypeEnum = (teNone, teTree, teTile, teGUI, tePath, teObject, teEnemy, teBag, teRes, teCapital, teCity, teRuin, teTower, teMine);

type
  TResBase = record
    FileName: string;
    ResType: TResTypeEnum;
  end;

const
  ResBase: array [TResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teNone;),
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
    // Neutral
    (FileName: 'dirt.png'; ResType: teTile;),
    // Empire terrain
    (FileName: 'grass.png'; ResType: teTile;),
    // Unknown (?)
    (FileName: 'unknown.png'; ResType: teGUI;),
    // Enemy party
    (FileName: 'enemies.png'; ResType: teEnemy;),
    // Frame
    (FileName: 'select.png'; ResType: teGUI;),
    // Player
    (FileName: 'player.png'; ResType: teObject;),
    // Fog
    (FileName: 'transparent.png'; ResType: teGUI;),
    // Gold
    (FileName: 'gold.png'; ResType: teRes;),
    // Bag
    (FileName: 'chest.png'; ResType: teBag;),
    // Neutral City
    (FileName: 'city.png'; ResType: teCity;),
    // Empire City
    (FileName: 'city.png'; ResType: teCity;),
    // Empire Capital
    (FileName: 'castle.png'; ResType: teCapital;),
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
    // Button
    (FileName: 'buttondef.png'; ResType: teGUI;),
    // Button
    (FileName: 'buttonact.png'; ResType: teGUI;),
    // Corpse
    (FileName: 'corpse.png'; ResType: teGUI;),
    // Dragon
    (FileName: 'dragon.png'; ResType: teGUI;),
    // Goblin
    (FileName: 'goblin.png'; ResType: teGUI;),
    // Spider
    (FileName: 'spider.png'; ResType: teGUI;),
    // Text "Quit"
    (FileName: 'text.quit.png'; ResType: teGUI;),
    // Text "Dismiss"
    (FileName: 'text.dismiss.png'; ResType: teGUI;),
    // Text "Hire"
    (FileName: 'text.hire.png'; ResType: teGUI;),
    // Text "Close"
    (FileName: 'text.close.png'; ResType: teGUI;),
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
    (FileName: 'title.logo.png'; ResType: teGUI;)
    //
    );

var
  ResImage: array [TResEnum] of TPNGImage;

procedure Init;
procedure Free;

implementation

uses
  System.SysUtils,
  Vcl.Graphics,
  DisciplesRL.Utils;

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
