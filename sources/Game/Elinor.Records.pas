unit Elinor.Records;

interface

uses
  System.JSON,
  Elinor.Creatures,
  Elinor.Faction;

type
  TLeaderRecord = class
  private
    FName: string;
    FFaction: TFactionEnum;
    FClass: TFactionLeaderKind;
    FScore: Integer;
  public
    constructor Create(const AName: string; AFaction: TFactionEnum;
      AClass: TFactionLeaderKind; AScore: Integer);
    property Name: string read FName write FName;
    property Faction: TFactionEnum read FFaction write FFaction;
    property PlayerClass: TFactionLeaderKind read FClass write FClass;
    property Score: Integer read FScore write FScore;
    function ToJSONObject: TJSONObject;
    class function FromJSONObject(JSONObj: TJSONObject): TLeaderRecord;
  end;

implementation

uses
  System.SysUtils;

{ TLeaderRecord }

constructor TLeaderRecord.Create(const AName: string; AFaction: TFactionEnum;
  AClass: TFactionLeaderKind; AScore: Integer);
begin
  FName := AName;
  FFaction := AFaction;
  FClass := AClass;
  FScore := AScore;
end;

class function TLeaderRecord.FromJSONObject(JSONObj: TJSONObject)
  : TLeaderRecord;
var
  LNamePair, LFactionPair, LClassPair, LScorePair: TJSONPair;
  LName: string;
  LFactionValue, LClassValue, LScore: Integer;
begin
  LNamePair := JSONObj.Get('name');
  LFactionPair := JSONObj.Get('faction');
  LClassPair := JSONObj.Get('class');
  LScorePair := JSONObj.Get('score');
  if not(Assigned(LNamePair) and Assigned(LFactionPair) and Assigned(LClassPair)
    and Assigned(LScorePair)) then
    raise Exception.Create('JSON Error');
  LName := LNamePair.JsonValue.Value;
  if not TJSONNumber(LFactionPair.JsonValue).TryGetValue<Integer>(LFactionValue)
  then
    LFactionValue := Integer(faTheEmpire);
  if not TJSONNumber(LClassPair.JsonValue).TryGetValue<Integer>(LClassValue)
  then
    LClassValue := Integer(ckWarrior);
  if not TJSONNumber(LScorePair.JsonValue).TryGetValue<Integer>(LScore) then
    LScore := 0;
  if (LFactionValue < Integer(faTheEmpire)) or
    (LFactionValue > Integer(faGreenskinTribes)) then
    LFactionValue := Integer(faTheEmpire);
  if (LClassValue < Integer(ckWarrior)) or (LClassValue > Integer(ckTemplar))
  then
    LClassValue := Integer(ckWarrior);
  Result := TLeaderRecord.Create(LName, TFactionEnum(LFactionValue),
    TFactionLeaderKind(LClassValue), LScore);
end;

function TLeaderRecord.ToJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  try
    Result.AddPair(TJSONPair.Create('name', TJSONString.Create(FName)));
    Result.AddPair(TJSONPair.Create('faction',
      TJSONNumber.Create(Integer(FFaction))));
    Result.AddPair(TJSONPair.Create('class',
      TJSONNumber.Create(Integer(FClass))));
    Result.AddPair(TJSONPair.Create('score', TJSONNumber.Create(FScore)));
  except
    Result.Free;
    raise;
  end;
end;

end.
