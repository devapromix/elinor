unit Elinor.Battle.Log;

interface

uses
  Elinor.Creatures,
  Elinor.Button;

type
  TBattleLog = class(TObject)
  public
    Log: TLog;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure WinInBattle;
    procedure LoseInBattle;
    procedure Kill(const CrName: string);
    procedure Heal(const AtkCrName, DefCrName: string; const Value: Integer);
    procedure Paralyze(const AtkCrName, DefCrName: string);
    procedure ParalPassed;
    procedure Miss(const AtkCrName, DefCrName: string);
    procedure UpdateExp(const CrName, GenderEnding: string; const Exp: Integer);
    procedure UpdateLevel(const CrName, GenderEnding: string;
      const Level: Integer);
    procedure StartCastSpell(const CrName, SourceName: string);
    procedure Attack(const AttackEnum: TAttackEnum;
      const SourceEnum: TSourceEnum; const AtkCrName, DefCrName: string;
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
  Log := TLog.Create(TScene.SceneLeft, TScene.DefaultButtonTop - 20);
end;

destructor TBattleLog.Destroy;
begin
  inherited;
  FreeAndNil(Log);
end;

procedure TBattleLog.UpdateExp(const CrName, GenderEnding: string;
  const Exp: Integer);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'update_exp'),
    [CrName, GenderEnding, Exp]));
end;

procedure TBattleLog.UpdateLevel(const CrName, GenderEnding: string;
  const Level: Integer);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'update_level'),
    [CrName, GenderEnding, Level]));
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
  const SourceEnum: TSourceEnum; const AtkCrName, DefCrName: string;
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
  Log.Add(Format(LStr, [AtkCrName, DefCrName, Value]));
  case AttackEnum of
    atDrainLife:
      begin
        LStr := TResources.RandomValue('battle.string', 'drain_life');
        Log.Add(Format(LStr, [AtkCrName, DefCrName, Value div 2]));
      end
  end;
end;

procedure TBattleLog.Clear;
begin
  Log.Clear;
end;

procedure TBattleLog.Miss(const AtkCrName, DefCrName: string);
begin
  case RandomRange(0, 2) of
    0:
      Log.Add(Format(TResources.RandomValue('battle.string', 'miss1'),
        [AtkCrName]));
  else
    Log.Add(Format(TResources.RandomValue('battle.string', 'miss2'),
      [AtkCrName, DefCrName]));
  end;
end;

procedure TBattleLog.ParalPassed;
begin
  Log.Add(TResources.RandomValue('battle.string', 'paral_passed'));
end;

procedure TBattleLog.Paralyze(const AtkCrName, DefCrName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'paralyze_attack'),
    [AtkCrName, DefCrName]));
end;

procedure TBattleLog.StartCastSpell(const CrName, SourceName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'start_cast'),
    [CrName, SourceName]));
end;

procedure TBattleLog.Heal(const AtkCrName, DefCrName: string;
  const Value: Integer);
begin
  case RandomRange(0, 2) of
    0:
      Log.Add(Format(TResources.RandomValue('battle.string', 'heal1'),
        [AtkCrName, DefCrName]));
  else
    Log.Add(Format(TResources.RandomValue('battle.string', 'heal2'),
      [AtkCrName, DefCrName, Value]));
  end;
end;

procedure TBattleLog.Kill(const CrName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'kill_creature'),
    [CrName]));
end;

end.
