﻿unit Elinor.Battle;

interface

uses
  System.Classes,
  Elinor.Party,
  Elinor.Creatures,
  Elinor.Battle.Log,
  Elinor.Creature.Types;

type
  TBattle = class(TObject)
  private
    FInitiativeList: TStringList;
    FBattleLog: TBattleLog;
  public
    constructor Create;
    destructor Destroy; override;
    property InitiativeList: TStringList read FInitiativeList;
    procedure SetInitiative(const ALeaderParty, AEnemyParty: TParty);
    function CheckArtifactParalyze(const AAtkParty, ADefParty: TParty;
      AAtkPos, ADefPos: TPosition;
      AAtkCrEnum, ADefCrEnum: TCreatureEnum): Boolean;
    function GetHitPoints(const APosition: Integer;
      const ALeaderParty, AEnemyParty: TParty): Integer;
    property BattleLog: TBattleLog read FBattleLog;
  end;

implementation

uses
  System.SysUtils, dialogs,
  System.Math;

{ TBattle }

function TBattle.CheckArtifactParalyze(const AAtkParty, ADefParty: TParty;
  AAtkPos, ADefPos: TPosition; AAtkCrEnum, ADefCrEnum: TCreatureEnum): Boolean;
begin
  Result := False;
  if AAtkCrEnum <> TLeaderParty.Leader.Enum then
    Exit;
  if AAtkCrEnum <> AAtkParty.Creature[TLeaderParty.GetPosition].Enum then
    Exit;
  if TLeaderParty.LeaderChanceToParalyzeValue = 0 then
    Exit;
  if RandomRange(0, 100) > TLeaderParty.LeaderChanceToParalyzeValue then
    Exit;
  Result := True;
  with ADefParty.Creature[ADefPos] do
    if Alive then
    begin
      ADefParty.Paralyze(ADefPos);
      BattleLog.Paralyze(AAtkParty.Creature[AAtkPos].Name[0],
        ADefParty.Creature[ADefPos].Name[1]);
    end;
end;

constructor TBattle.Create;
begin
  inherited;
  FInitiativeList := TStringList.Create;
  FBattleLog := TBattleLog.Create;
end;

destructor TBattle.Destroy;
begin
  inherited;
  FreeAndNil(FBattleLog);
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
