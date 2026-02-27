unit Elinor.Spells.Types;

interface

uses
  Elinor.Faction,
  Elinor.Ability,
  Elinor.Resources;

type
  TSpellTarget = (stNone, stLeader, stEnemy);

type
  TSpellBase = record
    Name: string;
    Level: Integer;
    Mana: Byte;
    RequireAbility: TAbilityEnum;
    SoundEnum: TMusicEnum;
    ResEnum: TSpellResEnum;
    Faction: TFactionEnum;
    SpellTarget: TSpellTarget;
    Description: string;
  end;

implementation

end.
