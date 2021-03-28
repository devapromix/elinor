unit DisciplesRL.Battle;

interface

uses
  DisciplesRL.Creatures;

type

  { TBattle }

  TBattle = class(TObject)
    function StartCastSpell: string;
    function GetLogMessage(AttackEnum: TAttackEnum;
      SourceEnum: TSourceEnum): string;
  end;

implementation

uses
  Classes,
  SysUtils,
  Math;

{ TBattle }

function TBattle.StartCastSpell: string;
begin
  case RandomRange(0, 2) of
    0:
      Result := '%s готовит заклинание. Его источник: %s.';
    else
      Result := '%s начинает колдовать. Источник магии: %s.';
  end;
end;

function TBattle.GetLogMessage(AttackEnum: TAttackEnum; SourceEnum: TSourceEnum
  ): string;
begin
  case AttackEnum of
    atLongSword:
      Result := '%s атакует мечом %s и наносит %d урона.';
    atBattleAxe:
      Result := '%s атакует боевым топором %s и наносит %d урона.';
    atDagger:
      Result := '%s атакует кинжалом %s и наносит %d урона.';
    atDaggerOfShadows:
      Result := '%s атакует Кинжалом Теней %s и наносит %d урона.';
    atFireDagger:
      Result := '%s атакует Кинжалом Пламени %s и наносит %d урона.';
    atBow:
      Result := 'Метким выстрелом %s поражает стрелой %s и наносит %d урона.';
    atClub:
      Result := '%s атакует булавой %s и наносит %d урона.';
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

