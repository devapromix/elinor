unit Elinor.Records;

interface

type
  TRecord = class
  private
    FName: string;
    FFaction: string;
    FClass: string;
    FScore: Integer;
    function ToJSONString: string;
  public
    constructor Create(const AName, AFaction, AClass: string; AScore: Integer);
    property Name: string read FName write FName;
    property Faction: string read FFaction write FFaction;
    property PlayerClass: string read FClass write FClass;
    property Score: Integer read FScore write FScore;
  end;

implementation

{ TRecord }

constructor TRecord.Create(const AName, AFaction, AClass: string;
  AScore: Integer);
begin
  FName := AName;
  FFaction := AFaction;
  FClass := AClass;
  FScore := AScore;
end;

function TRecord.ToJSONString: string;
begin
  Result := Format('{"name":"%s","faction":"%s","class":"%s","score":%d}',
    [JSONEscape(FName), JSONEscape(FFaction), JSONEscape(FClass), FScore]);
end;

end.
