unit DisciplesRL.Creatures;

interface

type
  TCreatureEnum = (crNone, crLeader, crGoblin, crWolf, crOrc);

type
  TCreature = record
    Active: Boolean;
    Enum: TCreatureEnum;
    Name: string;
    MaxHitPoints: Integer;
    HitPoints: Integer;
    Level: Integer;
    Damage: Integer;
    Armor: Integer;
  end;

type
  TCreatureBase = record
    HitPoints: Integer;
    Level: Integer;
    Damage: Integer;
    Armor: Integer;
  end;

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (HitPoints: 0; Level: 0; Damage: 0; Armor: 0),
    // Leader
    (HitPoints: 150; Level: 1; Damage: 12; Armor: 5),
    // Goblin
    (HitPoints: 40; Level: 1; Damage: 8; Armor: 2),
    // Wolf
    (HitPoints: 100; Level: 1; Damage: 15; Armor: 3),
    // Orc
    (HitPoints: 180; Level: 1; Damage: 18; Armor: 5)
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
    Name := '';
    MaxHitPoints := 0;
    HitPoints := 0;
    Level := 0;
    Damage := 0;
    Armor := 0;
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
    Name := StringReplace(GetEnumName(P, Ord(Enum)), 'cr', '', [rfReplaceAll]);
    MaxHitPoints := CreatureBase[ACreatureEnum].HitPoints;
    HitPoints := CreatureBase[ACreatureEnum].HitPoints;
    Level := CreatureBase[ACreatureEnum].Level;
    Damage := CreatureBase[ACreatureEnum].Damage;
    Armor := CreatureBase[ACreatureEnum].Armor;
  end;
end;


end.
