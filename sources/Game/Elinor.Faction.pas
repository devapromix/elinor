unit Elinor.Faction;

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
    class function GetDescription(const AFactionEnum: TFactionEnum): string;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.IOUtils;

var
  JSONData: TJSONObject;

procedure LoadFactionDescriptions(const FileName: string);
var
  JSONString: string;
begin
  try
    JSONString := TFile.ReadAllText(TResources.GetPath('resources') + FileName,
      TEncoding.UTF8);
    if Assigned(JSONData) then
      JSONData.Free;
    JSONData := TJSONObject.ParseJSONValue(JSONString) as TJSONObject;
  except
    on E: Exception do
      raise;
  end;
end;

class function TFaction.GetDescription(const AFactionEnum
  : TFactionEnum): string;
begin
  if Assigned(JSONData) and (JSONData.Values[FactionIdent[AFactionEnum]] <> nil)
  then
    Result := JSONData.GetValue<string>(FactionIdent[AFactionEnum])
  else
    Result := 'Description not available...';
end;

initialization

LoadFactionDescriptions('faction.description.json');

finalization

FreeAndNil(JSONData);

end.
