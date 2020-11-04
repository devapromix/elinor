unit DisciplesRL.Saga;

interface
{$IFDEF FPC}

uses
  DisciplesRL.Party,
  DisciplesRL.Creatures;

type
  TScenario = class(TObject)
  public const
    ScenarioPlacesMax = 30;
  end;

type
  TSaga = class(TObject)
  public
  class var
    Days: Integer;
    Gold: Integer;
    NewGold: Integer;
    Scores: Integer;
    GoldMines: Integer;
    BattlesWon: Integer;
    LeaderRace: TRaceEnum;
    IsDay: Boolean;
    Wizard: Boolean;
    IsGame: Boolean;
  public const
    GoldFromMinePerDay = 100;
    GoldForRevivePerLevel = 250;
  public
    class function GetPartyCount: Integer; static;
    class function GetPartyIndex(const AX, AY: Integer): Integer;
    class procedure AddLoot; static;
    class procedure NewDay; static;
  end;

implementation

uses
  Math, SysUtils,
  DisciplesRL.Map;

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

class procedure TSaga.AddLoot();
var
  Level: Integer;
begin
  Level := TMap.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  NewGold := RandomRange(Level * 20, Level * 30);
  Inc(Gold, NewGold);
  //DisciplesRL.Scene.Info.Show(stLoot, scMap);
end;

class procedure TSaga.NewDay;
begin
  if IsDay then
  begin
    Gold := Gold + (GoldMines * GoldFromMinePerDay);
    //DisciplesRL.Scene.Info.Show(stDay, scMap);
  end;
end;

{$ELSE}

uses
  System.Types,
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
    ScenarioName: array [TScenarioEnum] of string = ('Темная Башня', 'Повелитель', 'Древние Знания');
    ScenarioDescription: array [TScenarioEnum] of array [0 .. 10] of string = (
      // Темная Башня
      ('', '', '', '', '', '', '', '', '', '', 'Цель: разрушить Темную Башню'),
      // Повелитель
      ('', '', '', '', '', '', '', '', '', '', 'Цель: захватить все города'),
      // Древние Знания
      ('', '', '', '', '', '', '', '', '', '', 'Цель: найти все каменные таблички')
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
  class var
    Days: Integer;
    Gold: Integer;
    NewGold: Integer;
    Scores: Integer;
    GoldMines: Integer;
    BattlesWon: Integer;
    LeaderRace: TRaceEnum;
    IsDay: Boolean;
    Wizard: Boolean;
    IsGame: Boolean;
  public const
    GoldFromMinePerDay = 100;
    GoldForRevivePerLevel = 250;
  public
    class procedure Clear; static;
    class procedure PartyInit(const AX, AY: Integer; IsFinal: Boolean); static;
    class procedure PartyFree; static;
    class function GetPartyCount: Integer; static;
    class function GetPartyIndex(const AX, AY: Integer): Integer; static;
    class procedure AddPartyAt(const AX, AY: Integer; IsFinal: Boolean = False); static;
    class procedure AddLoot; static;
    class procedure NewDay; static;
    class procedure AddScores(I: Integer); static;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Vcl.Dialogs,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Info,
  DisciplesRL.Scene.Settlement;

type
  TPartyBase = record
    Level: Integer;
    Character: array [TPosition] of TCreatureEnum;
  end;

const
  PartyBase: array [1 .. 20] of TPartyBase = (
    //
    (Level: 1; Character: (crNone, crGoblin_Archer, crGoblin, crNone, crNone, crGoblin_Archer)),
    //
    (Level: 1; Character: (crGoblin, crNone, crGoblin, crNone, crGoblin, crNone)),
    //
    (Level: 1; Character: (crGoblin, crNone, crNone, crGoblin_Archer, crGoblin, crNone)),

    //
    (Level: 2; Character: (crGoblin, crNone, crGoblin, crGoblin_Archer, crGoblin, crNone)),
    //
    (Level: 2; Character: (crGoblin, crGoblin_Archer, crNone, crNone, crGoblin, crGoblin_Archer)),

    //
    (Level: 3; Character: (crGoblin, crGoblin_Archer, crNone, crGoblin_Archer, crGoblin, crGoblin_Archer)),
    //
    (Level: 3; Character: (crGoblin, crGoblin_Archer, crGoblin, crNone, crGoblin, crGoblin_Archer)),

    //
    (Level: 4; Character: (crGoblin, crGoblin_Archer, crGoblin, crGoblin_Archer, crGoblin, crGoblin_Archer)),
    //
    (Level: 4; Character: (crNone, crNone, crWolf, crNone, crNone, crNone)),

    //
    (Level: 5; Character: (crWolf, crNone, crNone, crNone, crWolf, crNone)),
    //
    (Level: 5; Character: (crWolf, crNone, crGoblin, crGoblin_Archer, crWolf, crNone)),

    //
    (Level: 6; Character: (crWolf, crNone, crWolf, crNone, crWolf, crNone)),
    //
    (Level: 6; Character: (crWolf, crNone, crWolf, crGoblin_Archer, crWolf, crNone)),

    //
    (Level: 7; Character: (crWolf, crNone, crOrc, crGoblin_Archer, crWolf, crNone)),
    //
    (Level: 7; Character: (crOrc, crGoblin_Archer, crNone, crNone, crOrc, crGoblin_Archer)),
    //
    (Level: 7; Character: (crOrc, crNone, crOrc, crNone, crOrc, crNone)),
    //
    (Level: 7; Character: (crOrc, crNone, crOrc, crGoblin_Archer, crOrc, crNone)),

    //
    (Level: 8; Character: (crOrc, crGoblin_Archer, crOrc, crNone, crOrc, crGoblin_Archer)),
    //
    (Level: 8; Character: (crOrc, crGoblin_Archer, crOrc, crGoblin_Archer, crOrc, crGoblin_Archer)),

    // Финальная партия в башне
    (Level: 99; Character: (crNone, crNone, crGiantSpider, crNone, crNone, crNone))
    //
    );

const
  MaxLevel = 8;

  { TSaga }

class procedure TSaga.PartyInit(const AX, AY: Integer; IsFinal: Boolean);
var
  Level, N: Integer;
  I: TPosition;
begin
  Level := EnsureRange(TMap.GetDistToCapital(AX, AY) div 3, 1, MaxLevel);
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TParty.Create(AX, AY);
  repeat
    N := RandomRange(0, High(PartyBase) - 1) + 1;
  until PartyBase[N].Level = Level;
  if IsFinal then
    N := High(PartyBase);
  with Party[TSaga.GetPartyCount - 1] do
  begin
    for I := Low(TPosition) to High(TPosition) do
      AddCreature(PartyBase[N].Character[I], I);
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
  TMap.Map[lrObj][AX, AY] := reEnemy;
  TSaga.PartyInit(AX, AY, IsFinal);
  I := GetPartyIndex(AX, AY);
  Party[I].Owner := reNeutrals;
end;

class procedure TSaga.AddScores(I: Integer);
begin
  if (I < 0) then I := 0;
  Scores := Scores + I;
end;

class procedure TSaga.AddLoot();
var
  Level: Integer;
begin
  Level := TMap.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  NewGold := RandomRange(Level * 20, Level * 30);
  Inc(Gold, NewGold);
  DisciplesRL.Scene.Info.Show(stLoot, scMap);
end;

class procedure TSaga.NewDay;
begin
  if IsDay then
  begin
    Gold := Gold + (GoldMines * GoldFromMinePerDay);
    DisciplesRL.Scene.Info.Show(stDay, scMap);
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
  Result := Format('Найдено каменных табличек: %d из %d', [StoneTab, ScenarioStoneTabMax]);
end;

class function TScenario.ScenarioOverlordState: string;
begin
  Result := Format('Захвачено городов: %d из %d', [TPlace.GetCityCount, ScenarioCitiesMax]);
end;

{ TSaga }

class procedure TSaga.Clear;
begin
  IsGame := True;
  TScenario.Init;
  Days := 1;
  Gold := 250;
  NewGold := 0;
  Scores := 0;
  GoldMines := 0;
  BattlesWon := 0;
  IsDay := False;
  PartyFree;
  TMap.Init;
  TMap.Gen;
  DisciplesRL.Scene.Settlement.Gen;
  TLeaderParty.Leader.Clear;
end;

{$ENDIF}

end.
