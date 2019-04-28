unit DisciplesRL.Creatures;

interface

uses
  DisciplesRL.Resources;

type
  TRaceEnum = (reNeutrals, reTheEmpire, reTheMountainClans, reTheUndeadHordes, reTheLegionsOfTheDamned, reTheElvenAlliance);

type
  TCreatureEnum = (crNone,
    // The Empire Capital Guardian
    crMyzrael,
    // The Empire Warrior Leader
    crPegasusKnight,
    // The Empire Mage Leader
    // The Empire Scout Leader
    // The Empire Fighters
    crSquire,
    // The Empire Ranged Attack Units
    crArcher,
    // The Empire Mage Units
    crApprentice,
    // The Empire Support units
    crAcolyte,

    // Neutrals
    crGoblin, crGoblin_Archer, crSpider, crWolf, crOrc);

type
  TReachEnum = (reAny, reAdj, reAll);

type
  TSourceEnum = (seWeapon, seLife, seMind, seDeath, seAir, seEarth, seFire, seWater);

const
  TheEmpireCharacters: array [0 .. 2] of TCreatureEnum = (crSquire, crArcher, crAcolyte);

const
  TheEmpireLeaders: array [0 .. 0] of TCreatureEnum = (
    // The Empire
    crPegasusKnight);

type
  TCreature = record
    Active: Boolean;
    Enum: TCreatureEnum;
    ResEnum: TResEnum;
    Name: string;
    MaxHitPoints: Integer;
    HitPoints: Integer;
    Initiative: Integer;
    ChancesToHit: Integer;
    Leadership: Integer;
    Level: Integer;
    Damage: Integer;
    Armor: Integer;
    Heal: Integer;
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
    Targets: Integer;
  end;

type
  TCreatureBase = record
    ResEnum: TResEnum;
    Name: string;
    HitPoints: Integer;
    Initiative: Integer;
    ChancesToHit: Integer;
    Leadership: Integer;
    Level: Integer;
    Damage: Integer;
    Armor: Integer;
    Heal: Integer;
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
    Targets: Integer;
  end;

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (ResEnum: reNone; Name: ''; HitPoints: 0; Initiative: 0; ChancesToHit: 0; Leadership: 0; Level: 0; Damage: 0; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Targets: 0;),
    // Myzrael
    (ResEnum: reDragon; Name: 'Мизраэль'; HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAll; Targets: 6;),
    // Pegasus Knight
    (ResEnum: reDragon; Name: 'Рыцарь на Пегасе'; HitPoints: 150; Initiative: 50; ChancesToHit: 80; Leadership: 5; Level: 1; Damage: 50; Armor: 0;
    Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny; Targets: 1;),
    // Squire
    (ResEnum: reDragon; Name: 'Сквайр'; HitPoints: 100; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Targets: 1;),
    // Archer
    (ResEnum: reDragon; Name: 'Лучник'; HitPoints: 45; Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny; Targets: 1;),
    // Apprentice
    (ResEnum: reDragon; Name: 'Ученик'; HitPoints: 35; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seAir; ReachEnum: reAll; Targets: 6;),
    // Acolyte
    (ResEnum: reDragon; Name: 'Служка'; HitPoints: 50; Initiative: 10; ChancesToHit: 100; Leadership: 0; Level: 1; Damage: 0; Armor: 0; Heal: 20;
    SourceEnum: seAir; ReachEnum: reAny; Targets: 1;),
    // Goblin
    (ResEnum: reGoblin; Name: 'Гоблин'; HitPoints: 50; Initiative: 30; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAny; Targets: 1;),
    // Goblin Archer
    (ResEnum: reGoblin; Name: 'Гоблин-лучник'; HitPoints: 40; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0;
    Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny; Targets: 1;),
    // Spider
    (ResEnum: reSpider; Name: 'Паук'; HitPoints: 420; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Targets: 1;),
    // Wolf
    (ResEnum: reUnk; Name: 'Волк'; HitPoints: 180; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Targets: 1;),
    // Orc
    (ResEnum: reUnk; Name: 'Орк'; HitPoints: 200; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Targets: 1;)
    //
    );

procedure ClearCreature(var ACreature: TCreature);
procedure AssignCreature(var ACreature: TCreature; const ACreatureEnum: TCreatureEnum);

implementation

uses
  System.SysUtils;

procedure ClearCreature(var ACreature: TCreature);
begin
  with ACreature do
  begin
    Active := False;
    Enum := crNone;
    ResEnum := reNone;
    Name := '';
    MaxHitPoints := 0;
    HitPoints := 0;
    Initiative := 0;
    ChancesToHit := 0;
    Leadership := 0;
    Level := 0;
    Damage := 0;
    Armor := 0;
    Heal := 0;
    SourceEnum := seWeapon;
    ReachEnum := reAdj;
    Targets := 1;
  end;
end;

procedure AssignCreature(var ACreature: TCreature; const ACreatureEnum: TCreatureEnum);
begin
  with ACreature do
  begin
    Active := True;
    Enum := ACreatureEnum;
    ResEnum := CreatureBase[ACreatureEnum].ResEnum;
    Name := CreatureBase[ACreatureEnum].Name;
    MaxHitPoints := CreatureBase[ACreatureEnum].HitPoints;
    HitPoints := CreatureBase[ACreatureEnum].HitPoints;
    Initiative := CreatureBase[ACreatureEnum].Initiative;
    ChancesToHit := CreatureBase[ACreatureEnum].ChancesToHit;
    Leadership := CreatureBase[ACreatureEnum].Leadership;
    Level := CreatureBase[ACreatureEnum].Level;
    Damage := CreatureBase[ACreatureEnum].Damage;
    Armor := CreatureBase[ACreatureEnum].Armor;
    Heal := CreatureBase[ACreatureEnum].Heal;
    SourceEnum := CreatureBase[ACreatureEnum].SourceEnum;
    ReachEnum := CreatureBase[ACreatureEnum].ReachEnum;
    Targets := CreatureBase[ACreatureEnum].Targets;
  end;
end;

end.
