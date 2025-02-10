unit Elinor.Battle;

interface

uses
  Elinor.Creatures,
  Elinor.Button;

type
  TBattle = class(TObject)
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
  Classes,
  SysUtils,
  Math,
  Elinor.Resources,
  Elinor.Scenes;

{ TBattle }

constructor TBattle.Create;
begin
  inherited;
  Log := TLog.Create(TScene.SceneLeft, TScene.DefaultButtonTop - 20);
end;

destructor TBattle.Destroy;
begin
  inherited;
  FreeAndNil(Log);
end;

procedure TBattle.UpdateExp(const CrName, GenderEnding: string;
  const Exp: Integer);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'update_exp'),
    [CrName, GenderEnding, Exp]));
end;

procedure TBattle.UpdateLevel(const CrName, GenderEnding: string;
  const Level: Integer);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'update_level'),
    [CrName, GenderEnding, Level]));
end;

procedure TBattle.WinInBattle;
begin
  Log.Add(TResources.RandomValue('battle.string', 'win_in_battle'));
end;

procedure TBattle.LoseInBattle;
begin
  Log.Add(TResources.RandomValue('battle.string', 'lose_in_battle'));
end;

procedure TBattle.Attack(const AttackEnum: TAttackEnum;
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

procedure TBattle.Clear;
begin
  Log.Clear;
end;

procedure TBattle.Miss(const AtkCrName, DefCrName: string);
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

procedure TBattle.Paralyze(const AtkCrName, DefCrName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'paralyze_attack'),
    [AtkCrName, DefCrName]));
end;

procedure TBattle.StartCastSpell(const CrName, SourceName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'start_cast'),
    [CrName, SourceName]));
end;

procedure TBattle.Heal(const AtkCrName, DefCrName: string;
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

procedure TBattle.Kill(const CrName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.string', 'kill_creature'),
    [CrName]));
end;

end.
