unit Elinor.Names;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  Elinor.Creatures,
  Elinor.Faction;

type
  TGenderNames = record
    Gender: TCreatureGender;
    Names: TArray<string>;
  end;

  TFactionNames = record
    Faction: TFactionEnum;
    GenderNames: array [TCreatureGender] of TGenderNames;
  end;

  TAllFactionNames = TArray<TFactionNames>;

  // Основні функції для роботи з іменами
function LoadNamesFromJSON(const FileName: string): TAllFactionNames;
function GetRandomNameForFaction(const AllNames: TAllFactionNames;
  const Faction: TFactionEnum; const Gender: TCreatureGender): string;
function FindFactionIndex(const AllNames: TAllFactionNames;
  const Faction: TFactionEnum): Integer;

implementation

function ReadFileToString(const FileName: string): string;
var
  FileStream: TFileStream;
  StringStream: TStringStream;
begin
  Result := '';
  if not FileExists(FileName) then
    Exit;

  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    StringStream := TStringStream.Create('', TEncoding.UTF8);
    try
      StringStream.CopyFrom(FileStream, 0);
      Result := StringStream.DataString;
    finally
      StringStream.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

function LoadNamesFromJSON(const FileName: string): TAllFactionNames;
var
  JsonText: string;
  JsonValue, GenderValue: TJSONValue;
  JsonObject, FactionObject: TJSONObject;
  JsonArray: TJSONArray;
  FactionEnum: TFactionEnum;
  Gender: TCreatureGender;
  I, J, FactionCount: Integer;
begin
  // Визначаємо кількість TPlayableFactions
  FactionCount := 0;
  for FactionEnum := Low(TPlayableFactions) to High(TPlayableFactions) do
    Inc(FactionCount);

  // Ініціалізуємо масив тільки для TPlayableFactions
  SetLength(Result, FactionCount);

  // Ініціалізуємо кожну фракцію та відповідну стать
  I := 0;
  for FactionEnum := Low(TPlayableFactions) to High(TPlayableFactions) do
  begin
    Result[I].Faction := FactionEnum;

    for Gender := Low(TCreatureGender) to High(TCreatureGender) do
    begin
      Result[I].GenderNames[Gender].Gender := Gender;
      SetLength(Result[I].GenderNames[Gender].Names, 0);
    end;

    Inc(I);
  end;

  JsonText := ReadFileToString(FileName);
  if JsonText = '' then
    Exit;

  JsonValue := TJSONObject.ParseJSONValue(JsonText);
  if not Assigned(JsonValue) then
    Exit;

  try
    if JsonValue is TJSONObject then
    begin
      JsonObject := TJSONObject(JsonValue);

      // Завантажуємо імена тільки для TPlayableFactions
      I := 0;
      for FactionEnum := Low(TPlayableFactions) to High(TPlayableFactions) do
      begin
        if JsonObject.TryGetValue<TJSONObject>(FactionIdent[FactionEnum],
          FactionObject) then
        begin
          // Завантажуємо імена для кожної статі
          for Gender := Low(TCreatureGender) to High(TCreatureGender) do
          begin
            if FactionObject.TryGetValue<TJSONArray>(GenderIdent[Gender],
              JsonArray) then
            begin
              SetLength(Result[I].GenderNames[Gender].Names, JsonArray.Count);

              for J := 0 to JsonArray.Count - 1 do
              begin
                if JsonArray.Items[J] is TJSONString then
                  Result[I].GenderNames[Gender].Names[J] :=
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
  Names: TArray<string>;
  NameCount: Integer;
  RandomIndex, FactionIndex: Integer;
begin
  Result := 'Unknown';

  // Знаходимо індекс фракції в AllNames
  FactionIndex := FindFactionIndex(AllNames, Faction);
  if FactionIndex = -1 then
    Exit;

  Names := AllNames[FactionIndex].GenderNames[Gender].Names;
  NameCount := Length(Names);

  if NameCount > 0 then
  begin
    Randomize;
    RandomIndex := Random(NameCount);
    Result := Names[RandomIndex];
  end;
end;

end.
