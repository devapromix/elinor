unit Elinor.Records;

interface

type
  TRecord = class
  private
    FName: string;
    FFaction: string;
    FClass: string;
    FScore: Integer;
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

end;

end.
