unit DisciplesRL.Saga;

interface

uses
  Types,
  DisciplesRL.Resources,
  DisciplesRL.Party,
  DisciplesRL.Creatures;

type
  TStatistics = class(TObject)
  public type
    TStatisticsEnum = (stKilledCreatures, stBattlesWon, stScore);
  private
    FValue: array [TStatisticsEnum] of Integer;
  public
    procedure Clear;
    procedure IncValue(const I: TStatisticsEnum; const Value: Integer = 1);
    function GetValue(const I: TStatisticsEnum): Integer;
  end;

  {
    Сценарии:
    [1] Темная Башня - победить чародея в башне.
    [2] Древние Знания - собрать на карте все каменные таблички с древними знаниями.
    [3] Властитель - захватить все города на карте.
    4  Захватить определенный город.
    5  Добыть определенный артефакт.
    6  Разорить все руины и другие опасные места.
    7  Победить всех врагов на карте.
    8  Что-то выполнить за N дней (лимит времени, возможно опция для каждого сценария).
  }

type
  TScenario = class(TObject)
  public type
    TScenarioEnum = (sgDarkTower, sgOverlord, sgAncientKnowledge);
  public const
    ScenarioStoneTabMax = 9;
    ScenarioCitiesMax = 7;
    ScenarioTowerIndex = ScenarioCitiesMax + 1;
    ScenarioName: array [TScenarioEnum] of string = ('Темная Башня',
      'Повелитель', 'Древние Знания');
    ScenarioDescription: array [TScenarioEnum] of array [0 .. 10] of string = (
      // Темная Башня
      ('', '', '', '', '', '', '', '', '', '', 'Цель: разрушить Темную Башню'),
      // Повелитель
      ('', '', '', '', '', '', '', '', '', '', 'Цель: захватить все города'),
      // Древние Знания
      ('', '', '', '', '', '', '', '', '', '',
      'Цель: найти все каменные таблички')
      //
      );
  public
    StoneTab: Integer;
    CurrentScenario: TScenarioEnum;
    FStoneTab: array [1 .. ScenarioStoneTabMax] of TPoint;
    StoneCounter: Integer;
    procedure Clear;
    function IsStoneTab(const X, Y: Integer): Boolean;
    procedure AddStoneTab(const X, Y: Integer);
    function ScenarioOverlordState: string;
    function ScenarioAncientKnowledgeState: string;
  end;

type
  TSaga = class(TObject)
  private

  public
  public type
    TDifficultyEnum = (dfEasy, dfNormal, dfHard);

  class var
    NewItem: Integer;
    LeaderRace: TRaceEnum;
    Difficulty: TDifficultyEnum;
    IsGame: Boolean;
  public const
    DifficultyName: array [TDifficultyEnum] of string = ('Легкий', 'Средний',
      'Сложный');
    DifficultyDescription: array [TDifficultyEnum] of array [0 .. 11]
      of string = (
      // Легкий
      ('Особо ценной в неспокойном мире,', 'где на каждом шагу можно ввязаться',
      'в кровопролитное сражение, становится', 'возможность повысить свои',
      'шансы в одном или нескольких', 'следующих боях, выпив магический',
      'элисир или прочитав могущественное', 'заклинание из книги магии. Шансы',
      'на победу в таком случае повышаются',
      'многократно и ценой таким усилиям', 'становится опыт, сфера, знамя или',
      'другой редкий артефакт.'),
      // Средний
      ('Магия создателей древних знаний', ' и реликвий жива до сих пор, как',
      'живы еще память и знания воинов', 'прошлого, чудесным образом заклю-',
      'ченные в их гробницах. Как следует',
      'обыскав покинутые и полуразрушенные',
      'здания, можно разжиться чем-нибудь',
      'полезным. Например, талисманом Тана-',
      'тоса или созданным мудрецами обере-',
      'гом чистоты разума. Обладателем этих',
      'артефатов, бесценных знаний и умений', 'можете стать именно вы.'),
      // Сложный
      ('Враги в Невендааре исключительно',
      'сильны, а потому многие прикладывают',
      'титанические усилия, чтобы защититься',
      'от их атак, если не полностью, то хотя',
      'бы частично. Грубая сила, сила веры,',
      'умения военачальника,ловкость и точ-',
      'ность искателя приключенийи воров-',
      'ские способности воров помогут вам',
      'избежать враждебных атак и отыскать',
      'могучие древние артефакты и реликвии',
      'и обрести ценные тайные знания канув-', 'ших в Лету эпох.')
      //
      );
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
    GoldForRevivePerLevel = 250;
    LeaderWarriorHealAllInPartyPerDay = 10;
    LeaderScoutMaxRadius = 3;
    LeaderScoutMaxSpeed = 12;
    LeaderLordMaxSpeed = 9;
    LeaderMageCanCastSpellsPerDay = 3;
    LeaderThiefSpyAttemptCountPerDay = 3;
    LeaderThiefPoisonDamageAllInPartyPerLevel = 10;
    LeaderDefaultMaxSpeed = 7;
    LeaderDefaultMaxRadius = 1;
  public
    class procedure Clear; static;
    class procedure PartyInit(const AX, AY: Integer; IsFinal: Boolean); static;
    class procedure PartyFree; static;
    class function GetPartyCount: Integer; static;
    class function GetPartyIndex(const AX, AY: Integer): Integer; static;
    class procedure AddPartyAt(const AX, AY: Integer;
      IsFinal: Boolean = False); static;
    class procedure AddLoot(LootRes: TResEnum); static;
  end;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Items;

const
  MaxLevel = 8;

  { TStatistics }

procedure TStatistics.Clear;
var
  I: TStatisticsEnum;
begin
  for I := Low(TStatisticsEnum) to High(TStatisticsEnum) do
    FValue[I] := 0;
end;

procedure TStatistics.IncValue(const I: TStatisticsEnum; const Value: Integer);
begin
  FValue[I] := FValue[I] + Value;
end;

function TStatistics.GetValue(const I: TStatisticsEnum): Integer;
begin
  Result := FValue[I];
end;

{ TSaga }

class procedure TSaga.PartyInit(const AX, AY: Integer; IsFinal: Boolean);
var
  Level, P: Integer;
  Cr: TCreatureEnum;
begin
  Level := EnsureRange((Game.Map.GetDistToCapital(AX, AY) div 3) +
    Ord(TSaga.Difficulty), 1, MaxLevel);
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TParty.Create(AX, AY);
  { repeat
    N := RandomRange(0, High(PartyBase) - 1) + 1;
    until PartyBase[N].Level = Level;
    if IsFinal then
    N := High(PartyBase);
    with Party[TSaga.GetPartyCount - 1] do
    begin
    for I := Low(TPosition) to High(TPosition) do
    AddCreature(PartyBase[N].Character[I], I);
    end;
  }
  P := EnsureRange(Level * 50, 1, 100);
  // P := 50;
  {
    1: 25..75
    2: 75..125
    3: 125..175
    4: 175..225
    5: 225..275
    6: 275..325
    7: 325..375
    8: 375..425
  }
  with Party[TSaga.GetPartyCount - 1] do
  begin
    //
    Cr := TCreature.GetRandomEnum(P, 2);
    // TCreature.Character(Cr).Race
    case RandomRange(0, 1) of
      0:
        AddCreature(Cr, 2);
      1:
        begin
          AddCreature(Cr, 0);
          AddCreature(Cr, 4);
        end;
      2:
        begin
          AddCreature(Cr, 0);
          AddCreature(Cr, 2);
          AddCreature(Cr, 4);
        end;
      3:
        begin
          AddCreature(Cr, 0);
          AddCreature(Cr, 4);
          Cr := TCreature.GetRandomEnum(P, 2);
          AddCreature(Cr, 2);
        end;
    end;
    //
    Cr := TCreature.GetRandomEnum(P, 3);
    case RandomRange(0, 1) of
      0:
        AddCreature(Cr, 3);
      1:
        begin
          AddCreature(Cr, 1);
          AddCreature(Cr, 5);
        end;
      2:
        begin
          AddCreature(Cr, 1);
          AddCreature(Cr, 3);
          AddCreature(Cr, 5);
        end;
      3:
        begin
          AddCreature(Cr, 1);
          AddCreature(Cr, 5);
          Cr := TCreature.GetRandomEnum(P, 3);
          AddCreature(Cr, 3);
        end;
    end;
  end;
end;

class procedure TSaga.PartyFree;
var
  I: Integer;
begin
  for I := 0 to TSaga.GetPartyCount - 1 do
    FreeAndNil(Party[I]);
  SetLength(Party, 0);
end;

class function TSaga.GetPartyCount: Integer;
begin
  Result := Length(Party);
end;

class function TSaga.GetPartyIndex(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetPartyCount - 1 do
    if (Party[I].X = AX) and (Party[I].Y = AY) then
    begin
      Result := I;
      Exit;
    end;
end;

class procedure TSaga.AddPartyAt(const AX, AY: Integer; IsFinal: Boolean);
var
  I: Integer;
begin
  Game.Map.SetTile(lrObj, AX, AY, reEnemy);
  TSaga.PartyInit(AX, AY, IsFinal);
  I := GetPartyIndex(AX, AY);
  Party[I].Owner := reNeutrals;
end;

class procedure TSaga.AddLoot(LootRes: TResEnum);
var
  Level, N: Integer;

  procedure AddGold;
  begin
    Game.Gold.NewValue := RandomRange(Level * 2, Level * 3) * 10;
    Game.Gold.Modify(Game.Gold.NewValue);
  end;

  procedure AddMana;
  begin
    Game.Mana.NewValue := RandomRange(Level * 1, Level * 3);
    if Game.Mana.NewValue < 3 then
      Game.Mana.NewValue := 3;
    Game.Mana.Modify(Game.Mana.NewValue);
  end;

  procedure AddItem;
  begin
    if (TLeaderParty.Leader.Inventory.Count < MaxInventoryItems) then
    begin
      repeat
        NewItem := RandomRange(1, TItemBase.Count);
      until (TItemBase.Item(NewItem).Level <= Level);
      TLeaderParty.Leader.Inventory.Add(TItemBase.Item(NewItem).Enum);
    end
    else
      NewItem := 0;
  end;

begin
  Game.Gold.NewValue := 0;
  Game.Mana.NewValue := 0;
  NewItem := 0;
  Level := EnsureRange((Game.Map.GetDistToCapital(TLeaderParty.Leader.X,
    TLeaderParty.Leader.Y) div 3) + Ord(TSaga.Difficulty), 1, MaxLevel);
  case LootRes of
    reGold:
      AddGold;
    reMana:
      AddMana;
    reBag:
      begin
        case RandomRange(0, 3) of
          0:
            AddGold;
        end;
        case RandomRange(0, 3) of
          0:
            AddMana;
        end;
        AddItem;
        if (NewItem = 0) then
          if (RandomRange(0, 2) = 0) then
            AddGold
          else
            AddMana;
      end;
  end;
  TSceneHire.Show(stLoot, scMap, LootRes);
end;

{ TScenario }

procedure TScenario.AddStoneTab(const X, Y: Integer);
begin
  Inc(StoneCounter);
  FStoneTab[StoneCounter].X := X;
  FStoneTab[StoneCounter].Y := Y;
end;

procedure TScenario.Clear;
begin
  StoneCounter := 0;
  StoneTab := 0;
end;

function TScenario.IsStoneTab(const X, Y: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ScenarioStoneTabMax do
    if (FStoneTab[I].X = X) and (FStoneTab[I].Y = Y) then
    begin
      Result := True;
      Exit;
    end;
end;

function TScenario.ScenarioAncientKnowledgeState: string;
begin
  Result := Format('Найдено каменных табличек: %d из %d',
    [StoneTab, ScenarioStoneTabMax]);
end;

function TScenario.ScenarioOverlordState: string;
begin
  Result := Format('Захвачено городов: %d из %d',
    [TMapPlace.GetCityCount, ScenarioCitiesMax]);
end;

{ TSaga }

class procedure TSaga.Clear;
begin
  IsGame := True;
  NewItem := 0;
  PartyFree;
  Game.Clear;
  TLeaderParty.Leader.Clear;
end;

end.
