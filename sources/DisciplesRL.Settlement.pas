unit DisciplesRL.Settlement;

interface

uses
  DisciplesRL.Creatures,
  DisciplesRL.Resources;

type
  TSettlementTypeEnum = (stCity, stCapital);

type
  TSettlements = class(TObject)
  private type
    T = 0 .. 9;
    V = 0 .. 1;
  private const
    CityNameResEnum: array [T] of TResEnum = (
      // Neutrals
      reTitleVorgel, reTitleEntarion, reTitleTardum, reTitleTemond,
      reTitleZerton, reTitleDoran, reTitleKront, reTitleHimor, reTitleSodek,
      reTitleSard);
    CapitalNameResEnum: array [TPlayableRaces, V] of TResEnum = (
      // The Empire
      (reTitleTarn, reTitleHaman),
      // Undead Hordes
      (reTitleShindar, reTitleKenoshan),
      // Legions Of The Damned
      (reTitleFergal, reTitleInmiris));
  private
    FNameN: array [T] of Integer;
    FCapitalN: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure GenNames;
    function GetNameResEnum(const SettlementTypeEnum: TSettlementTypeEnum;
      const I: T = 0): TResEnum;
  end;

implementation

uses
  DisciplesRL.Saga;

constructor TSettlements.Create;
begin

end;

destructor TSettlements.Destroy;
begin

  inherited;
end;

procedure TSettlements.GenNames;
var
  N: set of T;
  J, K: Integer;
begin
  N := [];
  for K := Low(T) to High(T) do
  begin
    repeat
      J := Random(High(T) + 1);
    until not(J in N);
    N := N + [J];
    FNameN[K] := J;
  end;
  FCapitalN := Random(High(V) + 1);
end;

function TSettlements.GetNameResEnum(const SettlementTypeEnum
  : TSettlementTypeEnum; const I: T): TResEnum;
begin
  case SettlementTypeEnum of
    stCapital:
      Result := CapitalNameResEnum[TSaga.LeaderRace, FCapitalN];
  else
    Result := CityNameResEnum[FNameN[I]];
  end;
end;

end.
