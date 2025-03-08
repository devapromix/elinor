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
  Result := (AParty.Creature[1].HitPoints.GetCurrValue > 0) or
    (AParty.Creature[3].HitPoints.GetCurrValue > 0) or
    (AParty.Creature[5].HitPoints.GetCurrValue > 0);
end;

end.
