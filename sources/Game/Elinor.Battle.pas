unit Elinor.Battle;

interface

uses
  System.Classes,
  Elinor.Party,
  Elinor.Creatures;

type
  TBattle = class(TObject)
  private
    FInitiativeList: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    property InitiativeList: TStringList read FInitiativeList;
    procedure SetInitiative(const ALeaderParty, AEnemyParty: TParty);
    function GetHitPoints(const APosition: Integer;
      const ALeaderParty, AEnemyParty: TParty): Integer;
  end;

implementation

uses
  System.SysUtils,
  System.Math;

{ TBattle }

constructor TBattle.Create;
begin
  inherited;
  FInitiativeList := TStringList.Create;
end;

destructor TBattle.Destroy;
begin
  inherited;
  FreeAndNil(FInitiativeList);
end;

function TBattle.GetHitPoints(const APosition: Integer;
  const ALeaderParty, AEnemyParty: TParty): Integer;
begin
  case APosition of
    0 .. 5:
      if ALeaderParty.Creature[APosition].Active then
        Result := ALeaderParty.GetHitPoints(APosition);
    6 .. 11:
      if AEnemyParty.Creature[APosition - 6].Active then
        Result := AEnemyParty.GetHitPoints(APosition - 6);
  end;
end;

procedure TBattle.SetInitiative(const ALeaderParty, AEnemyParty: TParty);
var
  I: Integer;
begin
  InitiativeList.Clear;
  for I := 0 to 11 do
  begin
    InitiativeList.Add('');
    case I of
      0 .. 5:
        if ALeaderParty.Creature[I].Alive then
          InitiativeList[I] :=
            Format('%d:%d', [ALeaderParty.GetInitiative(I), I]);
    else
      begin
        if AEnemyParty.Creature[I - 6].Alive then
          InitiativeList[I] :=
            Format('%d:%d', [AEnemyParty.GetInitiative(I - 6), I]);
      end;
    end;
  end;
  for I := 0 to 11 do
    InitiativeList.Exchange(Random(I), Random(I));
  InitiativeList.Sort;

end;

end.
