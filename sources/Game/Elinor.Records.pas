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
    function JSONEscape(const s: string): string;
    function CompareRecordsByScore(Item1, Item2: Pointer): Integer;
  public
    constructor Create(const AName, AFaction, AClass: string; AScore: Integer);
    property Name: string read FName write FName;
    property Faction: string read FFaction write FFaction;
    property PlayerClass: string read FClass write FClass;
    property Score: Integer read FScore write FScore;
  end;

implementation

uses
  System.SysUtils;

{ TRecord }

constructor TRecord.Create(const AName, AFaction, AClass: string;
  AScore: Integer);
begin
  FName := AName;
  FFaction := AFaction;
  FClass := AClass;
  FScore := AScore;
end;

function TRecord.JSONEscape(const s: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
  begin
    case s[i] of
      '"', '\':
        Result := Result + '\' + s[i];
      #8:
        Result := Result + '\b';
      #9:
        Result := Result + '\t';
      #10:
        Result := Result + '\n';
      #12:
        Result := Result + '\f';
      #13:
        Result := Result + '\r';
    else
      if Ord(s[i]) < 32 then
        Result := Result + '\u' + IntToHex(Ord(s[i]), 4)
      else
        Result := Result + s[i];
    end;
  end;
end;

function TRecord.ToJSONString: string;
begin
  Result := Format('{"name":"%s","faction":"%s","class":"%s","score":%d}',
    [JSONEscape(FName), JSONEscape(FFaction), JSONEscape(FClass), FScore]);
end;

function TRecord.CompareRecordsByScore(Item1, Item2: Pointer): Integer;
begin
  Result := TRecord(Item2).Score - TRecord(Item1).Score;
end;

end.
