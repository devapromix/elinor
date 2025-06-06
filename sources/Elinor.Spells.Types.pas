unit Elinor.Spells.Types;

interface

uses
  Elinor.Faction,
  Elinor.Resources;

type
  TSpellTarget = (stNone, stLeader, stEnemy);

type
  TSpellBase = record
    Name: string;
    Level: Integer;
    Mana: Byte;
    SoundEnum: TMusicEnum;
    ResEnum: TSpellResEnum;
    Faction: TFactionEnum;
    SpellTarget: TSpellTarget;
    Description: string;
  end;

implementation

end.
