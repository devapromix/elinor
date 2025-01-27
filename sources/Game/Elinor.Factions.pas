unit Elinor.Factions;

interface

uses
  Elinor.Resources;

type
  TFactionEnum = (faTheEmpire, faUndeadHordes, faLegionsOfTheDamned,
    faMountainClans, faElvenAlliance, faGreenskinTribes, faNeutrals);

type
  TPlayableFactions = faTheEmpire .. faLegionsOfTheDamned;

const
  PlayableFactions = [faTheEmpire, faUndeadHordes, faLegionsOfTheDamned];

const
  FactionIdent: array [TFactionEnum] of string = ('the-empire', 'undead-hordes',
    'legions-of-the-damned', 'mountain-clans', 'elven-alliance',
    'greenskin-tribes', 'neutrals');

const
  FactionName: array [TFactionEnum] of string = ('The Empire', 'Undead Hordes',
    'Legions of the Damned', 'Mountain Clans', 'Elven Alliance',
    'Greenskin Tribes', 'Neutrals');

const
  FactionTerrain: array [TFactionEnum] of TResEnum = (reTheEmpireTerrain,
    reUndeadHordesTerrain, reLegionsOfTheDamnedTerrain, reNeutralTerrain,
    reNeutralTerrain, reNeutralTerrain, reNeutralTerrain);

type
  TFaction = class(TObject)
  public
    class function GetDescription(const AFactionEnum: TFactionEnum;
      const AIndex: Integer): string;
  end;

implementation

{ TFaction }

class function TFaction.GetDescription(const AFactionEnum: TFactionEnum;
  const AIndex: Integer): string;
begin
  Result := TResources.IndexValue('factions.descriptions',
    FactionIdent[AFactionEnum], AIndex);
end;

end.
