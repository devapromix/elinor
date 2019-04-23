unit DisciplesRL.Creatures;

interface

uses
  DisciplesRL.Resources;

type
  TRaceEnum = (rcTheEmpire);

type
  TCreatureEnum = (crNone,
    // The Empire
    crMyzrael,
    // The Empire Leaders
    crPegasusKnight,
    // The Empire
    crSquire, crArcher,
    //
    crGoblin, crGoblin_Archer, crSpider, crWolf, crOrc);

type
  TReachEnum = (reAny, reAdj, reAll);

type
  TSourceEnum = (seWeapon, seLife, seMind, seDeath, seAir, seEarth, seFire, seWater);

const
  Characters: array [0 .. 2] of TCreatureEnum = (crSquire, crArcher, crArcher);

const
  Leaders: array [0 .. 0] of TCreatureEnum = (crPegasusKnight);

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
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
    Targets: Integer;
  end;

type
  TCreatureBase = record
    ResEnum: TResEnum;
    HitPoints: Integer;
    Initiative: Integer;
    ChancesToHit: Integer;
    Leadership: Integer;
    Level: Integer;
    Damage: Integer;
    Armor: Integer;
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
    Targets: Integer;
  end;

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (ResEnum: reNone; HitPoints: 0; Initiative: 0; ChancesToHit: 0; Leadership: 0; Level: 0; Damage: 0; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAdj; Targets: 0;),
    // Myzrael
    (ResEnum: reDragon; HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; SourceEnum: seWeapon;
    ReachEnum: reAll; Targets: 6;),
    // Pegasus Knight
    (ResEnum: reDragon; HitPoints: 150; Initiative: 50; ChancesToHit: 80; Leadership: 5; Level: 1; Damage: 50; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAny; Targets: 1;),
    // Squire
    (ResEnum: reDragon; HitPoints: 100; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAdj; Targets: 1;),
    // Archer
    (ResEnum: reDragon; HitPoints: 45; Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAny; Targets: 1;),
    // Goblin
    (ResEnum: reGoblin; HitPoints: 50; Initiative: 30; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAdj; Targets: 1;),
    // Goblin Archer
    (ResEnum: reGoblin; HitPoints: 40; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAny; Targets: 1;),
    // Spider
    (ResEnum: reSpider; HitPoints: 420; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAdj; Targets: 1;),
    // Wolf
    (ResEnum: reUnk; HitPoints: 180; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAdj; Targets: 1;),
    // Orc
    (ResEnum: reUnk; HitPoints: 200; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; SourceEnum: seWeapon;
    ReachEnum: reAdj; Targets: 1;)
    //
    );

procedure ClearCreature(var ACreature: TCreature);
procedure AssignCreature(var ACreature: TCreature; const ACreatureEnum: TCreatureEnum);

implementation

uses
  System.SysUtils,
  System.TypInfo;

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
    SourceEnum := seWeapon;
    ReachEnum := reAdj;
    Targets := 1;
  end;
end;

procedure AssignCreature(var ACreature: TCreature; const ACreatureEnum: TCreatureEnum);
var
  P: Pointer;
begin
  P := TypeInfo(TCreatureEnum);
  with ACreature do
  begin
    Active := True;
    Enum := ACreatureEnum;
    ResEnum := CreatureBase[ACreatureEnum].ResEnum;
    Name := StringReplace(GetEnumName(P, Ord(Enum)), 'cr', '', [rfReplaceAll]);
    MaxHitPoints := CreatureBase[ACreatureEnum].HitPoints;
    HitPoints := CreatureBase[ACreatureEnum].HitPoints div 2;
    Initiative := CreatureBase[ACreatureEnum].Initiative;
    ChancesToHit := CreatureBase[ACreatureEnum].ChancesToHit;
    Leadership := CreatureBase[ACreatureEnum].Leadership;
    Level := CreatureBase[ACreatureEnum].Level;
    Damage := CreatureBase[ACreatureEnum].Damage;
    Armor := CreatureBase[ACreatureEnum].Armor;
    SourceEnum := CreatureBase[ACreatureEnum].SourceEnum;
    ReachEnum := CreatureBase[ACreatureEnum].ReachEnum;
    Targets := CreatureBase[ACreatureEnum].Targets;
  end;
end;

end.
