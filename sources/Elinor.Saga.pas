unit Elinor.Saga;

interface

uses
  System.Types,
  Elinor.Faction,
  Elinor.Resources,
  Elinor.Difficulty,
  Elinor.Party,
  Elinor.Creatures;

type
  TSaga = class(TObject)
  public
  class var
    LeaderFaction: TFactionEnum;
    Difficulty: TDifficultyEnum;
  public const
    SpyName: array [TLeaderThiefSpyVar] of string = ('Заслать Шпиона',
      'Вызвать на Дуэль', 'Отравить Колодцы');
    SpyDescription: array [TLeaderThiefSpyVar] of array [0 .. 4] of string = (
      // Заслать Шпиона
      ('Возможность видеть состав войск', 'противника.', '', '', ''),
      // Вызвать на Дуэль
      ('Позволяет вору выйти против', 'предводителя отряда один на один.',
      '', '', ''),
      // Отравить Колодцы
      ('Травятся монстры, травятся герои,',
      'травятся колодцы в городах. Старая,', 'добрая, проверенная временем',
      'гадость.', '')
      //
      );
    WarName: array [TLeaderWarriorActVar] of string = ('War1', 'War2', 'War3');
    WarDescription: array [TLeaderWarriorActVar] of array [0 .. 4] of string = (
      //
      ('', '', '', '', ''),
      //
      ('', '', '', '', ''),
      //
      ('', '', '', '', '')
      //
      );
    GoldForRevivePerLevel = 25;
    LeaderWarriorHealAllInPartyPerDay = 10;
    LeaderScoutMaxRadius = 2;
    LeaderScoutMaxSpeed = 12;
    LeaderLordMaxSpeed = 9;
    LeaderThiefSpyAttemptCountPerDay = 3;
    LeaderThiefPoisonDamageAllInPartyPerLevel = 10;
    LeaderDefaultMaxSpeed = 7;
    LeaderDefaultMaxRadius = 1;
  public
  end;

implementation

uses
  System.Math,
  System.Classes,
  System.SysUtils,
  Elinor.Map,
  Elinor.Scenes,
  Elinor.Items,
  Elinor.Statistics,
  Elinor.Loot;

end.
