unit Elinor.RecordsTable;

interface

uses
  System.Classes,
  System.Contnrs,
  Elinor.Creatures,
  Elinor.Faction;

type
  TLeaderRecordsTable = class(TObject)
  private
    FRecords: TObjectList;
    FFileName: string;
    function FormatJSON(const AJSON: string): string;
    procedure GenNewTable;
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    procedure SaveToFile;
    procedure LoadFromFile;
    procedure AddRecord(const AName: string; AFaction: TFactionEnum;
      AClass: TFactionLeaderKind; AScore: Integer);
    procedure SortRecords;
    procedure SortRecordsByFaction;
    function FilterByFaction(AFaction: Integer): TObjectList;
    function FilterByClass(AClass: Integer): TObjectList;
  end;

implementation

{ TLeaderRecordsTable }

uses
  System.Math,
  System.JSON,
  System.SysUtils,
  Elinor.Records,
  Elinor.Names,
  Elinor.Resources;

function CompareRecordsByScore(AItem1, AItem2: Pointer): Integer;
begin
  Result := TLeaderRecord(AItem2).Score - TLeaderRecord(AItem1).Score;
end;

function CompareRecordsByFaction(AItem1, AItem2: Pointer): Integer;
var
  LRecord1, LRecord2: TLeaderRecord;
begin
  LRecord1 := TLeaderRecord(AItem1);
  LRecord2 := TLeaderRecord(AItem2);
  if Integer(LRecord1.Faction) < Integer(LRecord2.Faction) then
    Result := -1
  else if Integer(LRecord1.Faction) > Integer(LRecord2.Faction) then
    Result := 1
  else
    Result := LRecord2.Score - LRecord1.Score;
end;

procedure TLeaderRecordsTable.AddRecord(const AName: string;
  AFaction: TFactionEnum; AClass: TFactionLeaderKind; AScore: Integer);
var
  LLeaderRecord: TLeaderRecord;
begin
  LLeaderRecord := TLeaderRecord.Create(AName, AFaction, AClass, AScore);
  FRecords.Add(LLeaderRecord);
  SortRecords;
end;

constructor TLeaderRecordsTable.Create(const AFileName: string);
begin
  FRecords := TObjectList.Create(True);
  FFileName := AFileName;
end;

destructor TLeaderRecordsTable.Destroy;
begin
  FreeAndNil(FRecords);
  inherited;
end;

function TLeaderRecordsTable.FilterByClass(AClass: Integer): TObjectList;
var
  I: Integer;
  LFilteredList: TObjectList;
  LRecord: TLeaderRecord;
  LClonedRecord: TLeaderRecord;
  LCount: Integer;
begin
  LFilteredList := TObjectList.Create(True);
  try
    LCount := 0;
    for I := 0 to FRecords.Count - 1 do
    begin
      LRecord := TLeaderRecord(FRecords[I]);
      if (Integer(LRecord.PlayerClass) = AClass) then
      begin
        LClonedRecord := TLeaderRecord.Create(LRecord.Name, LRecord.Faction,
          LRecord.PlayerClass, LRecord.Score);
        LFilteredList.Add(LClonedRecord);
        Inc(LCount);
        if LCount >= 11 then
          Break;
      end;
    end;
    LFilteredList.Sort(CompareRecordsByScore);
    Result := LFilteredList;
  except
    LFilteredList.Free;
    raise;
  end;
end;

function TLeaderRecordsTable.FilterByFaction(AFaction: Integer): TObjectList;
var
  I: Integer;
  LFilteredList: TObjectList;
  LRecord: TLeaderRecord;
  LClonedRecord: TLeaderRecord;
  LCount: Integer;
begin
  LFilteredList := TObjectList.Create(True);
  try
    LCount := 0;
    for I := 0 to FRecords.Count - 1 do
    begin
      LRecord := TLeaderRecord(FRecords[I]);
      if (Integer(LRecord.Faction) = AFaction) then
      begin
        LClonedRecord := TLeaderRecord.Create(LRecord.Name, LRecord.Faction,
          LRecord.PlayerClass, LRecord.Score);
        LFilteredList.Add(LClonedRecord);
        Inc(LCount);
        if LCount >= 11 then
          Break;
      end;
    end;
    LFilteredList.Sort(CompareRecordsByScore);
    Result := LFilteredList;
  except
    LFilteredList.Free;
    raise;
  end;
end;

function TLeaderRecordsTable.FormatJSON(const AJSON: string): string;
var
  I, LIndent, LBraceLevel: Integer;
  LInString: Boolean;
  LPrevChar, LChar: Char;
begin
  Result := '';
  LBraceLevel := 0;
  LInString := False;
  LPrevChar := #0;

  for I := 1 to Length(AJSON) do
  begin
    LChar := AJSON[I];

    if (LChar = '"') and (LPrevChar <> '\') then
      LInString := not LInString;

    if LInString then
    begin
      Result := Result + LChar;
    end
    else
    begin
      case LChar of
        '{', '[':
          begin
            Result := Result + LChar + #13#10;
            Inc(LBraceLevel);
            LIndent := LBraceLevel * 2;
            Result := Result + StringOfChar(' ', LIndent);
          end;
        '}', ']':
          begin
            Dec(LBraceLevel);
            Result := Result + #13#10;
            LIndent := LBraceLevel * 2;
            Result := Result + StringOfChar(' ', LIndent) + LChar;
          end;
        ',':
          begin
            Result := Result + LChar + #13#10;
            LIndent := LBraceLevel * 2;
            Result := Result + StringOfChar(' ', LIndent);
          end;
        ':':
          begin
            Result := Result + LChar + ' ';
          end;
      else
        if not(LChar in [' ', #9, #10, #13]) then
          Result := Result + LChar;
      end;
    end;
    LPrevChar := LChar;
  end;
end;

procedure TLeaderRecordsTable.GenNewTable;
var
  I, LCount: Integer;
  LNames: TAllFactionNames;
  LName: string;
  LFaction: TFactionEnum;
  LClass: TFactionLeaderKind;
begin
  LCount := RandomRange(32, 48);
  LNames := LoadNamesFromJSON(TResources.GetPath('resources') +
    'faction.names.json');
  for I := 0 to LCount - 1 do
  begin
    LFaction := TFactionEnum(RandomRange(0, 3));
    LClass := TFactionLeaderKind(RandomRange(0, 5));
    LName := GetRandomNameForFaction(LNames, LFaction, cgMale);
    AddRecord(LName, LFaction, LClass, RandomRange(3000, 10000));
  end;
  SaveToFile;
end;

procedure TLeaderRecordsTable.LoadFromFile;
var
  I: Integer;
  LJSONStr: string;
  LJSONValue: TJSONValue;
  LJSONArray: TJSONArray;
  LJSONObject: TJSONObject;
  LLeaderRec: TLeaderRecord;
begin
  if FileExists(FFileName) then
  begin
    try
      with TStringList.Create do
        try
          LoadFromFile(FFileName);
          LJSONStr := Text;
        finally
          Free;
        end;
      FRecords.Clear;
      LJSONValue := TJSONObject.ParseJSONValue(LJSONStr);
      if Assigned(LJSONValue) and (LJSONValue is TJSONArray) then
      begin
        try
          LJSONArray := TJSONArray(LJSONValue);
          for I := 0 to LJSONArray.Count - 1 do
          begin
            if LJSONArray.Items[I] is TJSONObject then
            begin
              LJSONObject := TJSONObject(LJSONArray.Items[I]);
              try
                LLeaderRec := TLeaderRecord.FromJSONObject(LJSONObject);
                FRecords.Add(LLeaderRec);
              except
                on E: Exception do
                  WriteLn('Error: ', E.Message);
              end;
            end;
          end;
        finally
          LJSONValue.Free;
        end;
      end;
      SortRecords;
    except
      on E: Exception do
        WriteLn('Error: ', E.Message);
    end;
  end;
  if FRecords.Count = 0 then
    GenNewTable;
end;

procedure TLeaderRecordsTable.SaveToFile;
var
  I: Integer;
  LJSONArray: TJSONArray;
  LJSONStr: string;
begin
  LJSONArray := TJSONArray.Create;
  try
    for I := 0 to FRecords.Count - 1 do
      LJSONArray.AddElement(TLeaderRecord(FRecords[I]).ToJSONObject);
    LJSONStr := LJSONArray.ToString;
    LJSONStr := FormatJSON(LJSONStr);
    with TStringList.Create do
      try
        Text := LJSONStr;
        SaveToFile(FFileName);
      finally
        Free;
      end;
  finally
    LJSONArray.Free;
  end;
end;

procedure TLeaderRecordsTable.SortRecords;
begin
  FRecords.Sort(CompareRecordsByScore);
end;

procedure TLeaderRecordsTable.SortRecordsByFaction;
begin
  FRecords.Sort(CompareRecordsByFaction);
end;

end.
