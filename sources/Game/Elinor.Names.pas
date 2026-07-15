unit Elinor.Names;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.IOUtils,
  System.Generics.Collections,
  Elinor.Creatures,
  Elinor.Faction;

type
  TGenderNames = record
    Gender: TCreatureGender;
    Names: TArray<string>;
  end;

type
  TFactionNames = record
    Faction: TFactionEnum;
    GenderNames: array [TCreatureGender] of TGenderNames;
  end;

type
  TAllFactionNames = TArray<TFactionNames>;

function LoadNamesFromJSON(const AFileName: string): TAllFactionNames;
function GetRandomNameForFaction(const AllNames: TAllFactionNames;
  const Faction: TFactionEnum; const Gender: TCreatureGender): string;
function FindFactionIndex(const AllNames: TAllFactionNames;
  const Faction: TFactionEnum): Integer;

var
  AllFactionNames: TAllFactionNames;

implementation

function ReadFileToString(const FileName: string): string;
begin
  Result := '';
  if FileExists(FileName) then
    Result := TFile.ReadAllText(FileName, TEncoding.UTF8);
end;

function LoadNamesFromJSON(const AFileName: string): TAllFactionNames;
var
  LJSONText: string;
  JsonValue: TJSONValue;
  JsonObject, FactionObject: TJSONObject;
  JsonArray: TJSONArray;
  LFactionEnum: TFactionEnum;
  LGender: TCreatureGender;
  I, J, LFactionCount: Integer;
begin
  LFactionCount := Ord(High(TPlayableFactions)) -
    Ord(Low(TPlayableFactions)) + 1;

  SetLength(Result, LFactionCount);

  I := 0;
  for LFactionEnum := Low(TPlayableFactions) to High(TPlayableFactions) do
  begin
    Result[I].Faction := LFactionEnum;

    for LGender := Low(TCreatureGender) to High(TCreatureGender) do
    begin
      Result[I].GenderNames[LGender].Gender := LGender;
      SetLength(Result[I].GenderNames[LGender].Names, 0);
    end;

    Inc(I);
  end;

  LJSONText := ReadFileToString(AFileName);
  if LJSONText = '' then
    Exit;

  JsonValue := TJSONObject.ParseJSONValue(LJSONText);
  if not Assigned(JsonValue) then
    Exit;

  try
    if JsonValue is TJSONObject then
    begin
      JsonObject := TJSONObject(JsonValue);
      I := 0;
      for LFactionEnum := Low(TPlayableFactions) to High(TPlayableFactions) do
      begin
        if JsonObject.TryGetValue<TJSONObject>(FactionIdent[LFactionEnum],
          FactionObject) then
        begin
          for LGender := Low(TCreatureGender) to High(TCreatureGender) do
          begin
            if FactionObject.TryGetValue<TJSONArray>(GenderIdent[LGender],
              JsonArray) then
            begin
              SetLength(Result[I].GenderNames[LGender].Names, JsonArray.Count);
              for J := 0 to JsonArray.Count - 1 do
              begin
                if JsonArray.Items[J] is TJSONString then
                  Result[I].GenderNames[LGender].Names[J] :=
                    JsonArray.Items[J].Value;
              end;
            end;
          end;
        end;

        Inc(I);
      end;
    end;
  finally
    JsonValue.Free;
  end;
end;

function FindFactionIndex(const AllNames: TAllFactionNames;
  const Faction: TFactionEnum): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(AllNames) - 1 do
  begin
    if AllNames[I].Faction = Faction then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function GetRandomNameForFaction(const AllNames: TAllFactionNames;
  const Faction: TFactionEnum; const Gender: TCreatureGender): string;
var
  LNames: TArray<string>;
  LNameCount: Integer;
  LFactionIndex: Integer;
begin
  Result := 'Unknown';
  LFactionIndex := FindFactionIndex(AllNames, Faction);
  if LFactionIndex = -1 then
    Exit;
  LNames := AllNames[LFactionIndex].GenderNames[Gender].Names;
  LNameCount := Length(LNames);
  if LNameCount > 0 then
    Result := LNames[Random(LNameCount)];
end;

initialization

Randomize;

end.
