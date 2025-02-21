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
    FMaxRecords: Integer;
    FFileName: string;
    function FormatJSON(const AJSON: string): string;
  public
    constructor Create(const AFileName: string; AMaxRecords: Integer = 11);
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
  System.SysUtils,
  Elinor.Records;

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
  while FRecords.Count > FMaxRecords do
    FRecords.Delete(FRecords.Count - 1);
end;

constructor TLeaderRecordsTable.Create(const AFileName: string;
  AMaxRecords: Integer);
begin
  FRecords := TObjectList.Create(True);
  FMaxRecords := AMaxRecords;
  FFileName := AFileName;
end;

destructor TLeaderRecordsTable.Destroy;
begin
  FreeAndNil(FRecords);
  inherited;
end;

function TLeaderRecordsTable.FilterByClass(AClass: Integer): TObjectList;
begin

end;

function TLeaderRecordsTable.FilterByFaction(AFaction: Integer): TObjectList;
begin

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

procedure TLeaderRecordsTable.LoadFromFile;
begin

end;

procedure TLeaderRecordsTable.SaveToFile;
begin

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
