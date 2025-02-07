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
  TPartyBase = record
    Level: Integer;
    Faction: TFactionEnum;
    Character: array [TPosition] of TCreatureEnum;
  end;

type
  TSaga = class(TObject)
  public
  class var
    NewItem: Integer;
    LeaderFaction: TFactionEnum;
    Difficulty: TDifficultyEnum;
    PartyBase: array of TPartyBase;
    IsGame: Boolean;
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
    class procedure Clear; static;
    class procedure AddLoot(LootRes: TResEnum); static;
    class function GetTileLevel(const AX: Integer; const AY: Integer): Integer;
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
  Elinor.Scene.Loot,
  Elinor.Loot;

{ TSaga }

class procedure TSaga.AddLoot(LootRes: TResEnum);
var
  LLevel: Integer;

  procedure AddItem;
  begin
    if (TLeaderParty.Leader.Inventory.Count < MaxInventoryItems) then
    begin
      repeat
        NewItem := RandomRange(1, TItemBase.Count);
      until (TItemBase.Item(NewItem).Level <= LLevel);
      TLeaderParty.Leader.Inventory.Add(TItemBase.Item(NewItem).Enum);
      Game.Statistics.IncValue(stItemsFound);
    end
    else
    begin
      NewItem := 0;
    end;
  end;

begin
  Game.Gold.NewValue := 0;
  Game.Mana.NewValue := 0;
  NewItem := 0;
  LLevel := TSaga.GetTileLevel(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  case LootRes of
    reBag:
      begin
        AddItem;
      end;
  end;
  TSceneLoot.ShowScene(LootRes);
end;

class function TSaga.GetTileLevel(const AX: Integer; const AY: Integer)
  : Integer;
var
  LChance: Integer;
begin
  Result := EnsureRange(Game.Map.GetDistToCapital(AX, AY) div 3, 1, TParty.MaxLevel);
  case TSaga.Difficulty of
    dfEasy:
      LChance := 60;
    dfNormal:
      LChance := 30;
    dfHard:
      LChance := 10;
  end;
  if RandomRange(1, LChance) = 1 then
    Result := EnsureRange(Result + 1, 1, TParty.MaxLevel);
end;

class procedure TSaga.Clear;
begin
  IsGame := True;
  NewItem := 0;
  Game.Clear;
  TLeaderParty.Leader.Clear;
end;

end.
