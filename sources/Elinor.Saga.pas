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
    MaxLevel = 8;
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
    class procedure PartyInit(const AX, AY: Integer; IsFinal: Boolean); static;
    class procedure PartyFree; static;
    class function GetPartyCount: Integer; static;
    class function GetPartyIndex(const AX, AY: Integer): Integer; static;
    class procedure AddPartyAt(const AX, AY: Integer; CanAttack: Boolean;
      IsFinal: Boolean = False); static;
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

class procedure TSaga.PartyInit(const AX, AY: Integer; IsFinal: Boolean);
var
  LLevel, LPartyIndex: Integer;
  LPosition: TPosition;
  LCreatureEnum: TCreatureEnum;
begin
  LLevel := EnsureRange(GetTileLevel(AX, AY), 1, MaxLevel);
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TParty.Create(AX, AY);
  repeat
    LPartyIndex := RandomRange(0, Length(PartyBase));
  until (PartyBase[LPartyIndex].Level = LLevel) and
    (PartyBase[LPartyIndex].Faction <> TSaga.LeaderFaction);
  if IsFinal then
    LPartyIndex := High(PartyBase);
  with Party[TSaga.GetPartyCount - 1] do
  begin
    for LPosition := Low(TPosition) to High(TPosition) do
      AddCreature(PartyBase[LPartyIndex].Character[LPosition], LPosition);
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

class procedure TSaga.AddPartyAt(const AX, AY: Integer; CanAttack: Boolean;
  IsFinal: Boolean);
var
  LPartyIndex: Integer;
  LStringList: TStringList;
  LPosition: TPosition;
  LText: string;
begin
  Game.Map.SetTile(lrObj, AX, AY, reEnemy);
  TSaga.PartyInit(AX, AY, IsFinal);
  LPartyIndex := GetPartyIndex(AX, AY);
  Party[LPartyIndex].Owner := faNeutrals;
  Party[LPartyIndex].CanAttack := CanAttack;
  if IsFinal then
    Party[LPartyIndex].CanAttack := False;
  Loot.AddItemAt(AX, AY);

  Loot.AddGoldAt(AX, AY);
  Loot.AddGoldAt(AX, AY);
  Loot.AddGoldAt(AX, AY);

  { if Game.Wizard then
    begin
    LStringList := TStringList.Create;
    try
    if FileExists('parties.txt') then
    LStringList.LoadFromFile('parties.txt');
    LText := Format('Level-%d ', [TSaga.GetTileLevel(Party[LPartyIndex].X,
    Party[LPartyIndex].Y)]);
    for LPosition := Low(TPosition) to High(TPosition) do
    LText := LText + Format('%d-%s ',
    [LPosition, Party[LPartyIndex].Creature[LPosition].Name[0]]);
    LStringList.Append(Trim(LText));
    LStringList.Sort;
    LStringList.SaveToFile('parties.txt');
    finally
    FreeAndNil(LStringList);
    end;
    end; }
end;

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
  Result := EnsureRange(Game.Map.GetDistToCapital(AX, AY) div 3, 1, MaxLevel);
  case TSaga.Difficulty of
    dfEasy:
      LChance := 60;
    dfNormal:
      LChance := 30;
    dfHard:
      LChance := 10;
  end;
  if RandomRange(1, LChance) = 1 then
    Result := EnsureRange(Result + 1, 1, MaxLevel);
end;

class procedure TSaga.Clear;
begin
  IsGame := True;
  NewItem := 0;
  PartyFree;
  Game.Clear;
  TLeaderParty.Leader.Clear;
end;

end.
