unit Elinor.Battle.AI;

interface

uses
  Elinor.Party;

type
  TBattleAI = class(TObject)
  public
    class function HasWarriors(AParty: TParty): Boolean;
  end;

implementation

{ TBattleAI }

class function TBattleAI.HasWarriors(AParty: TParty): Boolean;
begin
  Result := (AParty.Creature[0].HitPoints.GetCurrValue > 0) or
    (AParty.Creature[2].HitPoints.GetCurrValue > 0) or
    (AParty.Creature[4].HitPoints.GetCurrValue > 0);
end;

end.
