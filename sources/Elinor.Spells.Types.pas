unit Elinor.Spells.Types;

interface

uses
  Elinor.Factions,
  Elinor.Resources;

type
  TSpellBase = record
    Name: string;
    Level: Integer;
    Mana: Byte;
    SoundEnum: TMusicEnum;
    ResEnum: TResEnum;
    Faction: TFactionEnum;
  end;

implementation

end.
