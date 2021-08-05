unit DisciplesRL.Battle;

interface

uses
  DisciplesRL.Creatures,
  DisciplesRL.Button;

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
    function GetLogMessage(AttackEnum: TAttackEnum;
      SourceEnum: TSourceEnum): string;
  end;

implementation

uses
  Classes,
  SysUtils,
  Math,
  DisciplesRL.Resources,
  DisciplesRL.Scenes;

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
  Log.Add(Format(TResources.RandomValue('battle.strings', 'update_exp'),
    [CrName, GenderEnding, Exp]));
end;

procedure TBattle.UpdateLevel(const CrName, GenderEnding: string;
  const Level: Integer);
begin
  Log.Add(Format(TResources.RandomValue('battle.strings', 'update_level'),
    [CrName, GenderEnding, Level]));
end;

procedure TBattle.WinInBattle;
begin
  Log.Add(TResources.RandomValue('battle.strings', 'win_in_battle'));
end;

procedure TBattle.LoseInBattle;
begin
  Log.Add(TResources.RandomValue('battle.strings', 'lose_in_battle'));
end;

procedure TBattle.Clear;
begin
  Log.Clear;
end;

procedure TBattle.Miss(const AtkCrName, DefCrName: string);
begin
  case RandomRange(0, 2) of
    0:
      Log.Add(Format(TResources.RandomValue('battle.strings', 'miss1'),
        [AtkCrName]));
  else
    Log.Add(Format(TResources.RandomValue('battle.strings', 'miss2'),
      [AtkCrName, DefCrName]));
  end;
end;

procedure TBattle.Paralyze(const AtkCrName, DefCrName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.strings', 'paralyze'),
    [AtkCrName, DefCrName]));
end;

procedure TBattle.StartCastSpell(const CrName, SourceName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.strings', 'start_cast'),
    [CrName, SourceName]));
end;

procedure TBattle.Heal(const AtkCrName, DefCrName: string;
  const Value: Integer);
begin
  case RandomRange(0, 2) of
    0:
      Log.Add(Format(TResources.RandomValue('battle.strings', 'heal1'),
        [AtkCrName, DefCrName]));
  else
    Log.Add(Format(TResources.RandomValue('battle.strings', 'heal2'),
      [AtkCrName, DefCrName, Value]));
  end;
end;

procedure TBattle.Kill(const CrName: string);
begin
  Log.Add(Format(TResources.RandomValue('battle.strings', 'kill_creature'),
    [CrName]));
end;

function TBattle.GetLogMessage(AttackEnum: TAttackEnum;
  SourceEnum: TSourceEnum): string;
begin
  case AttackEnum of
    atLongSword, atSlayerSword, atPaladinSword:
      Result := '%s атакует мечом %s и наносит %d урона.';
    atBattleAxe:
      Result := '%s атакует боевым топором %s и наносит %d урона.';
    atDagger:
      Result := '%s атакует кинжалом %s и наносит %d урона.';
    atDaggerOfShadows:
      Result := '%s атакует Кинжалом Теней %s и наносит %d урона.';
    atFireDagger:
      Result := '%s атакует Кинжалом Пламени %s и наносит %d урона.';
    atBow, atHunterBow:
      Result := 'Метким выстрелом %s поражает стрелой %s и наносит %d урона.';
    atClub:
      Result := '%s атакует булавой %s и наносит %d урона.';
    atFireHammer:
      Result := '%s атакует Тлеющим Молотом %s и наносит %d урона.';
    atPhoenixSword:
      Result := '%s атакует Мечом Феникса %s и наносит %d урона.';
    atCrossbow:
      Result := 'Молниеносно %s взводит арбалет и поражает %s, нанося %d урона.';
    atStones:
      Result := 'Метким броском %s поражает камнем %s и наносит %d урона.';
    atPoisonousBreath:
      Result := '%s атакует ядовитым дыханием %s и наносит %d урона.';
    atDrainLife:
      case RandomRange(0, 4) of
        0:
          Result := '%s пьет жизнь у %s и наносит %d урона.';
        1:
          Result := '%s забирает жизнь у %s и наносит %d урона.';
        2:
          Result := '%s выпивает жизнь у %s и наносит %d урона.';
      else
        Result := '%s высасывает жизнь у %s и наносит %d урона.';
      end;
    atHealing:
      ;
    atPoison:
      ;
    atMagic:
      case SourceEnum of
        seFire:
          Result := '%s атакует огнем %s и наносит %d урона.';
        seAir:
          Result := '%s атакует молниями %s и наносит %d урона.';
        seEarth:
          Result := '%s атакует магией земли %s и наносит %d урона.';
        seWater:
          Result := '%s атакует водной магией %s и наносит %d урона.';
      else
        Result := '%s атакует магией %s и наносит %d урона.';
      end;
    atClaws:
      Result := '%s разрывает когтями %s и наносит %d урона.';
    atBites:
      Result := '%s кусает %s и наносит %d урона.';
  else
    Result := '%s атакует %s и наносит %d урона.';
  end;
end;

end.
