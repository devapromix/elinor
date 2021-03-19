unit DisciplesRL.Saga;

interface

uses
  Types,
  DisciplesRL.Resources,
  DisciplesRL.Party,
  DisciplesRL.Creatures;

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
    ScenarioPlacesMax = 30;
    ScenarioStoneTabMax = 9;
    ScenarioCitiesMax = 7;
    ScenarioTowerIndex = ScenarioCitiesMax + 1;
  public const
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
    class var StoneTab: Integer;
    class var CurrentScenario: TScenarioEnum;
  strict private
  class var
    FStoneTab: array [1 .. ScenarioStoneTabMax] of TPoint;
    J: Integer;
  public
    class procedure Init; static;
    class function IsStoneTab(const X, Y: Integer): Boolean; static;
    class procedure AddStoneTab(const X, Y: Integer); static;
    class function ScenarioOverlordState: string; static;
    class function ScenarioAncientKnowledgeState: string; static;
  end;

type
  TSaga = class(TObject)
  private

  public
  public type
    TDifficultyEnum = (dfEasy, dfNormal, dfHard);
  class var
    Days: Integer;
    Gold: Integer;
    NewGold: Integer;
    Mana: Integer;
    NewMana: Integer;
    NewItem: Integer;
    Scores: Integer;
    GoldMines: Integer;
    ManaMines: Integer;
    BattlesWon: Integer;
    LeaderRace: TRaceEnum;
    Difficulty: TDifficultyEnum;
    IsDay: Boolean;
    Wizard: Boolean;
    NoMusic: Boolean;
    NewBattle: Boolean;
    IsGame: Boolean;
    ShowNewDayMessage: ShortInt;
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
    GoldFromMinePerDay = 100;
    GoldForRevivePerLevel = 250;
    ManaFromMinePerDay = 10;
    LeaderWarriorHealAllInPartyPerDay = 10;
    LeaderScoutAdvRadius = 2;
    LeaderMageCanCastSpellsPerDay = 3;
  public
    class procedure Clear; static;
    class procedure PartyInit(const AX, AY: Integer; IsFinal: Boolean); static;
    class procedure PartyFree; static;
    class function GetPartyCount: Integer; static;
    class function GetPartyIndex(const AX, AY: Integer): Integer; static;
    class procedure AddPartyAt(const AX, AY: Integer;
      IsFinal: Boolean = False); static;
    class procedure AddLoot(LootRes: TResEnum); static;
    class procedure ModifyGold(Amount: Integer); static;
    class procedure ModifyMana(Amount: Integer); static;
    class procedure NewDay; static;
    class procedure AddScores(I: Integer); static;
  end;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Settlement;

const
  MaxLevel = 8;

  { TSaga }

class procedure TSaga.PartyInit(const AX, AY: Integer; IsFinal: Boolean);
var
  Level, N, P: Integer;
  I: TPosition;
  Cr: TCreatureEnum;
begin
  Level := EnsureRange((TMap.GetDistToCapital(AX, AY) div 3) +
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
  P := 50;
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
  TMap.SetTile(lrObj, AX, AY, reEnemy);
  TSaga.PartyInit(AX, AY, IsFinal);
  I := GetPartyIndex(AX, AY);
  Party[I].Owner := reNeutrals;
end;

class procedure TSaga.AddScores(I: Integer);
begin
  if (I < 0) then
    I := 0;
  Scores := Scores + I;
end;

class procedure TSaga.ModifyGold(Amount: Integer);
begin
  Inc(Gold, Amount);
end;

class procedure TSaga.ModifyMana(Amount: Integer);
begin
  Inc(Mana, Amount);
end;

class procedure TSaga.AddLoot(LootRes: TResEnum);
var
  Level, N: Integer;

  procedure AddGold;
  begin
    NewGold := RandomRange(Level * 2, Level * 3) * 10;
    ModifyGold(NewGold);
  end;

  procedure AddMana;
  begin
    NewMana := RandomRange(Level * 1, Level * 3);
    if NewMana < 3 then
      NewMana := 3;
    ModifyMana(NewMana);
  end;

  procedure AddItem;
  begin
    N := 0;
    if (NewGold = 0) and (NewMana = 0) then
      N := 1;
    NewItem := RandomRange(N, 4);

  end;

begin
  NewGold := 0;
  NewMana := 0;
  NewItem := 0;
  Level := TMap.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
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
      end;
  end;
  TSceneHire.Show(stLoot, scMap, LootRes);
end;

class procedure TSaga.NewDay;
begin
  if IsDay then
  begin
    Gold := Gold + (GoldMines * GoldFromMinePerDay);
    Mana := Mana + (ManaMines * ManaFromMinePerDay);
    if (TLeaderParty.Leader.Enum in LeaderWarrior) then
      TLeaderParty.Leader.HealAll(LeaderWarriorHealAllInPartyPerDay);
    TLeaderParty.Leader.Spells := TLeaderParty.Leader.MaxSpells;
    ShowNewDayMessage := 20;
    MediaPlayer.Play(mmDay);
    IsDay := False;
  end;
end;

{ TScenario }

class procedure TScenario.AddStoneTab(const X, Y: Integer);
begin
  Inc(J);
  FStoneTab[J].X := X;
  FStoneTab[J].Y := Y;
end;

class procedure TScenario.Init;
begin
  J := 0;
  StoneTab := 0;
end;

class function TScenario.IsStoneTab(const X, Y: Integer): Boolean;
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

class function TScenario.ScenarioAncientKnowledgeState: string;
begin
  Result := Format('Найдено каменных табличек: %d из %d',
    [StoneTab, ScenarioStoneTabMax]);
end;

class function TScenario.ScenarioOverlordState: string;
begin
  Result := Format('Захвачено городов: %d из %d',
    [TPlace.GetCityCount, ScenarioCitiesMax]);
end;

{ TSaga }

class procedure TSaga.Clear;
begin
  IsGame := True;
  TScenario.Init;
  Days := 1;
  Gold := 250;
  NewGold := 0;
  Mana := 250;
  NewMana := 0;
  NewItem := 0;
  Scores := 0;
  GoldMines := 0;
  ManaMines := 0;
  BattlesWon := 0;
  IsDay := False;
  ShowNewDayMessage := 0;
  PartyFree;
  TMap.Init;
  TMap.Gen;
  TSceneSettlement.GenCityName;
  TLeaderParty.Leader.Clear;
end;

end.
