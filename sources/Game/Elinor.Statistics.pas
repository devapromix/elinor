unit Elinor.Statistics;

interface

type
  TStatistics = class(TObject)
  public type
    TStatisticsEnum = (stKilledCreatures, stBattlesWon, stTilesMoved, stScores,
      stGoldMined, stManaMined, stChestsFound, stItemsFound);
  private const
    ScoresModif: array [TStatisticsEnum] of Integer = (10, 35, 1, 0, 2,
      2, 20, 5);
  private
    FValue: array [TStatisticsEnum] of Integer;
  public
    procedure Clear;
    procedure IncValue(const AStatisticsEnum: TStatisticsEnum;
      const Value: Integer = 1);
    function GetValue(const AStatisticsEnum: TStatisticsEnum): Integer;
  end;

implementation

{ TStatistics }

procedure TStatistics.Clear;
var
  LStatisticsEnum: TStatisticsEnum;
begin
  for LStatisticsEnum := Low(TStatisticsEnum) to High(TStatisticsEnum) do
    FValue[LStatisticsEnum] := 0;
end;

procedure TStatistics.IncValue(const AStatisticsEnum: TStatisticsEnum;
  const Value: Integer);
begin
  FValue[AStatisticsEnum] := FValue[AStatisticsEnum] + Value;
  if AStatisticsEnum <> stScores then
    IncValue(stScores, Value * ScoresModif[AStatisticsEnum]);
end;

function TStatistics.GetValue(const AStatisticsEnum: TStatisticsEnum): Integer;
begin
  Result := FValue[AStatisticsEnum];
end;

end.
