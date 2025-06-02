unit Elinor.Spellbook;

interface

uses
  Elinor.Spells,
  Elinor.Faction,
  Elinor.Resources;

type
  TSpellbook = class(TObject)
  public
    function SpellBackground(const ASpellEnum: TSpellEnum): TResEnum;
  end;

const
  FactionSpellbookSpells: array [TFactionEnum] of array [0 .. 5]
    of TSpellEnum = (
    // The Empire Spellbook
    (spTrueHealing, spBless, spSpeed, spLivingArmor, spEagleEye, spStrength),
    // Undead Hordes Spellbook
    (spPlague, spCurse, spNone, spNone, spNone, spNone),
    // Legions Of The Damned Spellbook
    (spConcealment, spChainsOfDread, spWeaken, spNone, spNone, spNone),
    // MountainClans Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone),
    // ElvenAlliance Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone),
    // Greenskin Tribes Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone),
    // Neutrals Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone)
    //
    );

var
  Spellbook: TSpellbook;

implementation

uses
  System.SysUtils;

{ TSpellbook }

function TSpellbook.SpellBackground(const ASpellEnum: TSpellEnum): TResEnum;
const
  FactionSpellbookBackground: array [TFactionEnum] of TResEnum = (reBGTheEmpire,
    reBGUndeadHordes, reBGLegionsOfTheDamned, reBGMountainClans,
    reBGElvenAlliance, reBGGreenskinTribes, reBGNeutrals);
begin
  Result := FactionSpellbookBackground[TSpells.Spell(ASpellEnum).Faction];
end;

initialization

Spellbook := TSpellbook.Create;

finalization

FreeAndNil(Spellbook);

end.
