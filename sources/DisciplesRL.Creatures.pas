unit DisciplesRL.Creatures;

interface

uses DisciplesRL.Resources;

type
  TCreatureEnum = (crNone, crMyzrael, crLeader, crSquire, crGoblin, crSpider, crWolf, crOrc);

type
  TCreature = record
    Active: Boolean;
    Enum: TCreatureEnum;
    ResEnum: TResEnum;
    Name: string;
    MaxHitPoints: Integer;
    HitPoints: Integer;
    Leader: Boolean;
    Level: Integer;
    Value: Integer;
    Armor: Integer;
    RaceClass: Integer;
  end;

type
  TCreatureBase = record
    ResEnum: TResEnum;
    HitPoints: Integer;
    Leader: Boolean;
    Level: Integer;
    Value: Integer;
    Armor: Integer;
    RaceClass: Integer;
  end;

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (ResEnum: reNone; HitPoints: 0; Leader: False; Level: 0; Value: 0; Armor: 0),
    // Myzrael
    (ResEnum: reDragon; HitPoints: 900; Leader: True; Level: 1; Value: 250; Armor: 50),
    // Leader
    (ResEnum: reCorpse; HitPoints: 100; Leader: True; Level: 1; Value: 10; Armor: 0),
    // Squire
    (ResEnum: reDragon; HitPoints: 100; Leader: False; Level: 1; Value: 25; Armor: 0),
    // Goblin
    (ResEnum: reGoblin; HitPoints: 30; Leader: False; Level: 1; Value: 10; Armor: 0),
    // Spider
    (ResEnum: reSpider; HitPoints: 100; Leader: False; Level: 1; Value: 15; Armor: 0),
    // Wolf
    (ResEnum: reUnk; HitPoints: 100; Leader: False; Level: 1; Value: 15; Armor: 0),
    // Orc
    (ResEnum: reUnk; HitPoints: 180; Leader: False; Level: 1; Value: 18; Armor: 0)
    //
    );

procedure ClearCreature(var ACreature: TCreature);
procedure AssignCreature(var ACreature: TCreature; const ACreatureEnum: TCreatureEnum);

implementation

uses System.SysUtils, System.TypInfo;

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
    Leader := False;
    Level := 0;
    Value := 0;
    Armor := 0;
    RaceClass := 0;
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
    HitPoints := CreatureBase[ACreatureEnum].HitPoints;
    Leader := CreatureBase[ACreatureEnum].Leader;
    Level := CreatureBase[ACreatureEnum].Level;
    Value := CreatureBase[ACreatureEnum].Value;
    Armor := CreatureBase[ACreatureEnum].Armor;
    RaceClass := CreatureBase[ACreatureEnum].RaceClass;
  end;
end;

end.
