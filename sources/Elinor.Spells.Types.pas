unit Elinor.Spells.Types;

interface

uses
  Elinor.Resources;

type
  TSpellBase = record
    Name: string;
    Level: Integer;
    Mana: Byte;
    SoundEnum: TMusicEnum;
    ResEnum: TResEnum;
  end;

implementation

end.
