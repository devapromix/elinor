unit Elinor.Battle.Log;

interface

uses
  Elinor.Creatures,
  Elinor.Button,
  Elinor.Log;

type
  TBattleLog = class(TObject)
  private
    FLog: TLog;
  public
    property Log: TLog read FLog write FLog;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure WinInBattle;
    procedure LoseInBattle;
    procedure Kill(const ACreatureName: string);
    procedure Heal(const AAtkCrName, ADefCrName: string; const AValue: Integer);
    procedure Paralyze(const AAtkCrName, ADefCrName: string;
      const IsArtifact: Boolean = False);
    procedure ParalPassed;
    procedure Miss(const AAtkCrName, ADefCrName: string);
    procedure UpdateExp(const CrName: string; const Exp: Integer);
    procedure UpdateLevel(const CrName: string;
      const Level: Integer);
    procedure StartCastSpell(const CrName, SourceName: string);
    procedure Attack(const AttackEnum: TAttackEnum;
      const SourceEnum: TSourceEnum; const AAtkCrName, ADefCrName: string;
      const Value: Integer);
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  Elinor.Resources,
  Elinor.Scenes;

{ TBattleLog }

constructor TBattleLog.Create;
begin
  inherited;
  FLog := TLog.Create(TScene.SceneLeft, TScene.DefaultButtonTop - 20);
end;

destructor TBattleLog.Destroy;
begin
  inherited;
  FreeAndNil(FLog);
end;

procedure TBattleLog.UpdateExp(const CrName: string;
  const Exp: Integer);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'update_exp'),
    [CrName, Exp]));
end;

procedure TBattleLog.UpdateLevel(const CrName: string;
  const Level: Integer);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'update_level'),
    [CrName, Level]));
end;

procedure TBattleLog.WinInBattle;
begin
  Log.Add(TResources.RandomValue('battle.string', 'win_in_battle'));
end;

procedure TBattleLog.LoseInBattle;
begin
  Log.Add(TResources.RandomValue('battle.string', 'lose_in_battle'));
end;

procedure TBattleLog.Attack(const AttackEnum: TAttackEnum;
  const SourceEnum: TSourceEnum; const AAtkCrName, ADefCrName: string;
  const Value: Integer);
var
  LStr: string;
begin
  case AttackEnum of
    atMagic:
      begin
        LStr := TResources.RandomValue('battle.string',
          LowerCase(SourceName[SourceEnum]) + '_magic_attack');
        if (Trim(LStr) = '') then
          LStr := TResources.RandomValue('battle.string',
            'default_magic_attack');
      end;
    atHealing:
      LStr := TResources.RandomValue('battle.string', 'heal2');
  else
    begin
      case AttackEnum of
        atDrainLife:
          LStr := TResources.RandomValue('battle.string', 'bites_attack');
      else
        LStr := TResources.RandomValue('battle.string', AtkSecName[AttackEnum] +
          '_attack');
      end;
      if (Trim(LStr) = '') then
        LStr := TResources.RandomValue('battle.string', 'default_attack');
    end;
  end;
  Log.Add(Format(LStr, [AAtkCrName, ADefCrName, Value]));
  case AttackEnum of
    atDrainLife:
      begin
        LStr := TResources.RandomValue('battle.string', 'drain_life');
        Log.Add(Format(LStr, [AAtkCrName, ADefCrName, Value div 2]));
      end
  end;
end;

procedure TBattleLog.Clear;
begin
  Log.Clear;
end;

procedure TBattleLog.Miss(const AAtkCrName, ADefCrName: string);
begin
  case RandomRange(0, 2) of
    0:
      Log.Add(Format(TResources.RandomValue('battle.string', 'miss1'),
        [AAtkCrName]));
  else
    Log.Add(Format(TResources.RandomValue('battle.string', 'miss2'),
      [AAtkCrName, ADefCrName]));
  end;
end;

procedure TBattleLog.ParalPassed;
begin
  Log.Add(TResources.RandomValue('battle.string', 'paral_passed'));
end;

procedure TBattleLog.Paralyze(const AAtkCrName, ADefCrName: string;
  const IsArtifact: Boolean = False);
begin
  if IsArtifact then
    Log.Add(Format(TResources.RandomValue('battle.string',
      'paralyze_artifact_attack'), [AAtkCrName, ADefCrName]))
  else
    Log.Add(Format(TResources.RandomValue('battle.string',
      'paralyze_ghost_attack'), [AAtkCrName, ADefCrName]));
end;

procedure TBattleLog.StartCastSpell(const CrName, SourceName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'start_cast'),
    [CrName, SourceName]));
end;

procedure TBattleLog.Heal(const AAtkCrName, ADefCrName: string;
  const AValue: Integer);
begin
  case RandomRange(0, 2) of
    0:
      Log.Add(Format(TResources.RandomValue('battle.string', 'heal1'),
        [AAtkCrName, ADefCrName]));
  else
    Log.Add(Format(TResources.RandomValue('battle.string', 'heal2'),
      [AAtkCrName, ADefCrName, AValue]));
  end;
end;

procedure TBattleLog.Kill(const ACreatureName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'kill_creature'),
    [ACreatureName]));
end;

end.
