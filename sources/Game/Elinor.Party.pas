unit Elinor.Party;

interface

uses
  System.Types,
  Elinor.Faction,
  Elinor.Creatures,
  Elinor.Creature.Types,
  Elinor.MapObject,
  Elinor.Ability,
  Elinor.Attribute,
  Elinor.Items,
  Elinor.Direction,
  Elinor.Map;

type
  TPartySide = (psLeft, psRight);

type
  TPosition = 0 .. 5;

type

  { TParty }

  TParty = class(TMapObject)
  public const
    MaxLevel = 8;
  strict private
    FOwner: TFactionEnum;
    FCreature: array [TPosition] of TCreature;
    function GetCreature(APosition: TPosition): TCreature;
    procedure SetCreature(APosition: TPosition; const Value: TCreature);
    function GetCount: Integer;
  private
    FCanAttack: Boolean;
    FLeaderClass: TFactionLeaderKind;
    function GetLeaderGender: TCreatureGender;
  public
    constructor Create(const AX, AY: Integer); overload;
    constructor Create(const AX, AY: Integer; AOwner: TFactionEnum); overload;
    destructor Destroy; override;
    property CanAttack: Boolean read FCanAttack write FCanAttack;
    procedure MoveCreature(FromParty: TParty; const APosition: TPosition);
    procedure AddCreature(const ACreatureEnum: TCreatureEnum;
      const APosition: TPosition);
    property Owner: TFactionEnum read FOwner write FOwner;
    property LeaderClass: TFactionLeaderKind read FLeaderClass
      write FLeaderClass;
    property LeaderGender: TCreatureGender read GetLeaderGender;
    procedure UnParalyze(const APosition: TPosition);
    procedure UnParalyzeParty;
    procedure ParalyzeParty;
    function IsParalyzeParty: Boolean;
    property Creature[APosition: TPosition]: TCreature read GetCreature
      write SetCreature;
    procedure SetHitPoints(const APosition: TPosition;
      const AHitPoints: Integer);
    function GetHitPoints(const APosition: TPosition): Integer;
    function GetInitiative(const APosition: TPosition): Integer;
    procedure SetState(const APosition: TPosition; const Flag: Boolean);
    procedure Clear;
    procedure ClearTempValuesAll;
    function IsClear: Boolean;
    function GetRandomPosition: TPosition;
    function Hire(const ACreatureEnum: TCreatureEnum;
      const APosition: TPosition): Boolean;
    function Dismiss(const APosition: TPosition): Boolean;
    procedure ReduceArmor(const APercent: Integer; const APosition: TPosition);
    procedure IncreaseArmorPermanently(const APercent: Integer;
      const APosition: TPosition);
    procedure Explosion(const ADamage: Integer; const APosition: TPosition);
    procedure IncreaseDamageTemp(const APercent: Integer;
      const APosition: TPosition);
    procedure IncreaseChancesToHitTemp(const APercent: Integer;
      const APosition: TPosition);
    procedure IncreaseChancesToHitPermanently(const APosition: TPosition);
    procedure IncreaseHitPointsPermanently(const APosition: TPosition);
    procedure Heal(const APosition: TPosition); overload;
    procedure Heal(const APosition: TPosition;
      const AHitPoints: Integer); overload;
    procedure HealParty(const AHitPoints: Integer);
    procedure Paralyze(const APosition: TPosition);
    procedure Revive(const APosition: TPosition);
    procedure ReviveParty;
    procedure UpdateHP(const AHitPoints: Integer; const APosition: TPosition);
    procedure UpdateDamage(const ADamage: Integer; const APosition: TPosition);
    procedure UpdateXP(const AExperience: Integer; const APosition: TPosition);
    procedure UpdateLevel(const APosition: TPosition); virtual;
    procedure TakeDamage(const ADamage: Integer; const APosition: TPosition);
    procedure TakeDamageAll(const ADamage: Integer);
    procedure Swap(Party: TParty; A, B: Integer); overload;
    procedure Swap(A, B: Integer); overload;
    property Count: Integer read GetCount;
    function GetAliveCreatures: Integer;
    function GetAliveAndNeedExpCreatures: Integer;
    procedure ChPosition(Party: TParty; const ActPosition: Integer;
      var CurPosition: Integer);
    function GetExperience: Integer;
    function GetMaxExperiencePerLevel(const Level: Integer): Integer;
    class procedure Gen(const AX, AY: Integer; IsFinal: Boolean); static;
    procedure ModifyPartyChancesToHit(const AValue: Integer);
    procedure ModifyPartyDamage(const AValue: Integer);
    function GetAllHitpointsSum: Integer;
    function GetAllDamageSum: Integer;
    procedure ModifyDamage(const APosition: TPosition; const ADamage: Integer);
    procedure ModifyArmor(const APosition: TPosition; const AArmor: Integer);
    procedure ModifyInitiative(const APosition: TPosition;
      const AInitiative: Integer);
  end;

type

  { TLeaderParty }

  TLeaderParty = class(TParty)
  private
    FAbilities: TAbilities;
    FInventory: TInventory;
    FEquipment: TEquipment;
    FInvisibility: Boolean;
    FSpellsPerDay: TCurrMaxAttribute;
    FMovementPoints: TCurrMaxAttribute;
    function GetLeadership: Integer;
  private
    class var IsUnitSelected: Boolean;
    class function GetLeaderRegenerationValue: Integer; static;
  public
  class var
    LeaderPartyIndex: Byte;
    CreatureIndex: Byte;
    CapitalPartyIndex: Byte;
    SummonPartyIndex: Byte;
    LeaderName: string;
    LeaderRegenerationValue: Byte;
    LeaderChanceToParalyzeValue: Byte;
    LeaderVampiricAttackValue: Byte;
    PartyGainMoreExpValue: Byte;
    LeaderGainsMoreMovePointsValue: Byte;
    LeaderInvisibleValue: Byte;
  public
    constructor Create(const AX, AY: Integer; AOwner: TFactionEnum);
    destructor Destroy; override;
    procedure Clear;
    property MovementPoints: TCurrMaxAttribute read FMovementPoints
      write FMovementPoints;
    property SpellsPerDay: TCurrMaxAttribute read FSpellsPerDay
      write FSpellsPerDay;
    property Leadership: Integer read GetLeadership;
    procedure UpdateSightRadius;
    procedure Turn(const ACount: Integer = 1);
    procedure ChCityOwner;
    class function Leader: TLeaderParty;
    class function Summoned: TLeaderParty;
    class procedure Move(const AX, AY: ShortInt); overload;
    class procedure Move(Dir: TDirectionEnum); overload;
    class procedure PutAt(const AX, AY: ShortInt;
      const IsInfo: Boolean = False);
    class function GetPosition: TPosition;
    function InSightRadius(const AX, AY: Integer): Boolean;
    function Enum: TCreatureEnum;
    function Level: Integer;
    function GetMaxSpellsPerDay: Integer; overload;
    class function GetSpellsPerDay(const CrEnum: TCreatureEnum)
      : Integer; overload;
    function GetMaxMovementPoints: Integer; overload;
    class function GetMovementPoints(const CrEnum: TCreatureEnum)
      : Integer; overload;
    function IsPartyOwner(const AX, AY: Integer): Boolean;
    property Abilities: TAbilities read FAbilities write FAbilities;
    property Inventory: TInventory read FInventory write FInventory;
    property Equipment: TEquipment read FEquipment write FEquipment;
    function GetSightRadius: Integer; overload;
    class function GetSightRadius(const ACreatureEnum: TCreatureEnum)
      : Integer; overload;
    procedure Equip(const InventoryItemIndex: Integer);
    procedure Quaff(const AItemIndex: Integer; const APosition: TPosition);
    function UnEquip(const EquipmentItemIndex: Integer): Boolean;
    function GetGoldCost(const AGold: Integer): Integer;
    property Invisibility: Boolean read FInvisibility write FInvisibility;
    function GetInvisibility: Boolean;
    procedure SetMaxMovementPoints;
    procedure SetMaxSpellsPerDay;
    class function GetSpellCastingRange(const CrEnum: TCreatureEnum)
      : Integer; overload;
    function GetSpellCastingRange: Integer; overload;
    function InSpellCastingRange(const AX, AY: Integer): Boolean;
    procedure LeaderRegeneration;
    class procedure MoveUnit(AParty: TParty);
    class procedure UpdateMoveUnit(AParty: TParty); overload;
    class procedure UpdateMoveUnit(AParty: TParty;
      const AX, AY: Integer); overload;
    class procedure ModifyLeaderRegeneration(const AValue: Integer);
    class procedure ModifyLeaderChanceToParalyze(const AValue: Integer);
    class procedure ModifyLeaderVampiricAttack(const AValue: Integer);
    class procedure ModifyPartyGainMoreExp(const AValue: Integer);
    class procedure ModifyLeaderMovePoints(const AValue: Integer);
    class procedure ModifyLeaderInvisible(const AValue: Integer);
  end;

type
  TPartyList = class
  private
    procedure PartyInit(const AX, AY: Integer; IsFinal: Boolean);
  public
    Party: array of TParty;
    constructor Create;
    destructor Destroy; override;
    function GetPartyIndex(const AX, AY: Integer): Integer;
    function Count: Integer;
    procedure Clear;
    procedure AddPartyAt(const AX, AY: Integer; CanAttack: Boolean;
      IsFinal: Boolean = False);
  end;

var
  SelectPartyPosition: Integer = -1;
  ActivePartyPosition: Integer = 2;
  CurrentPartyPosition: Integer = 2;

type
  TPartyBase = record
    Level: Integer;
    Faction: TFactionEnum;
    Character: array [TPosition] of TCreatureEnum;
  end;

var
  PartyBase: array of TPartyBase;
  PartyList: TPartyList;

implementation

uses
  System.Math, dialogs,
  System.Classes,
  System.SysUtils,
  Elinor.Resources,
  Elinor.Scenes,
  Elinor.Scene.Settlement,
  DisciplesRL.Scene.Hire,
  Elinor.Statistics,
  Elinor.Loot,
  Elinor.Scene.Loot2,
  Elinor.Common,
  Elinor.Scene.MageTower,
  Elinor.Scene.Party2,
  Elinor.Scene.Merchant,
  Elinor.Merchant,
  Elinor.Difficulty;

{ TParty }

procedure TParty.AddCreature(const ACreatureEnum: TCreatureEnum;
  const APosition: TPosition);
begin
  TCreature.Assign(FCreature[APosition], ACreatureEnum);
end;

procedure TParty.ChPosition(Party: TParty; const ActPosition: Integer;
  var CurPosition: Integer);
begin
  if (CurPosition < 0) then
    Exit;
  case CurPosition of
    0 .. 5:
      case ActPosition of
        0 .. 5:
          Self.Swap(CurPosition, ActPosition);
        6 .. 11:
          Self.Swap(Party, CurPosition, ActPosition - 6);
      end;
    6 .. 11:
      case ActPosition of
        0 .. 5:
          Party.Swap(Self, CurPosition - 6, ActPosition);
        6 .. 11:
          Party.Swap(CurPosition - 6, ActPosition - 6);
      end;
  end;
  CurPosition := ActPosition;
end;

procedure TParty.IncreaseArmorPermanently(const APercent: Integer;
  const APosition: TPosition);
var
  LArmor: Integer;
begin
  with FCreature[APosition] do
    if Alive then
    begin
      LArmor := Percent(Armor.GetCurrValue, APercent);
      Armor.ModifyCurrValue(LArmor, 0, 250);
    end;
end;

procedure TParty.IncreaseChancesToHitPermanently(const APosition: TPosition);
var
  LBoostChancesToHit: Integer;
begin
  with FCreature[APosition] do
    if Alive then
    begin
      LBoostChancesToHit :=
        EnsureRange(ChancesToHit.GetCurrValue div 10, 1, 10);
      ChancesToHit.ModifyCurrValue(LBoostChancesToHit, 50, 100);
    end;
end;

procedure TParty.IncreaseChancesToHitTemp(const APercent: Integer;
  const APosition: TPosition);
var
  LChancesToHit: Integer;
begin
  with FCreature[APosition] do
    if Alive then
    begin
      LChancesToHit := EnsureRange(ChancesToHit.GetCurrValue div 5, 1, 60);
      ChancesToHit.ModifyTempValue(LChancesToHit);
    end;
end;

procedure TParty.IncreaseDamageTemp(const APercent: Integer;
  const APosition: TPosition);
var
  LDamage: Integer;
begin
  with FCreature[APosition] do
    if Alive then
    begin
      LDamage := EnsureRange(Damage.GetCurrValue div 5, 1, 60);
      Damage.ModifyTempValue(LDamage);
    end;
end;

procedure TParty.IncreaseHitPointsPermanently(const APosition: TPosition);
var
  LBoostHitPoints: Integer;
begin
  with FCreature[APosition] do
    if Alive then
    begin
      LBoostHitPoints := EnsureRange(HitPoints.GetMaxValue div 5, 1, 255);
      HitPoints.ModifyMaxValue(LBoostHitPoints);
      HitPoints.SetToMaxValue;
    end;
end;

function TParty.IsClear: Boolean;
var
  Position: TPosition;
begin
  Result := False;
  for Position := Low(TPosition) to High(TPosition) do
    if not Creature[Position].HitPoints.IsMinCurrValue then
      Exit;
  Result := True;
end;

procedure TParty.Paralyze(const APosition: TPosition);
begin
  FCreature[APosition].Paralyze := True;
end;

procedure TParty.ParalyzeParty;
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    FCreature[LPosition].Paralyze := True;
end;

procedure TParty.UnParalyze(const APosition: TPosition);
begin
  FCreature[APosition].Paralyze := False;
end;

procedure TParty.UnParalyzeParty;
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    FCreature[LPosition].Paralyze := False;
end;

function TParty.IsParalyzeParty: Boolean;
var
  LPosition: TPosition;
begin
  Result := False;
  for LPosition := Low(TPosition) to High(TPosition) do
    if FCreature[LPosition].Paralyze then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TParty.ClearTempValuesAll;
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    FCreature[LPosition].ClearTempValues;
end;

procedure TParty.Clear;
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    TCreature.Clear(FCreature[LPosition]);
end;

constructor TParty.Create(const AX, AY: Integer; AOwner: TFactionEnum);
begin
  inherited Create(AX, AY);
  Self.Clear;
  Owner := AOwner;
  CanAttack := True;
end;

constructor TParty.Create(const AX, AY: Integer);
begin
  inherited Create(AX, AY);
  Self.Clear;
  Owner := faNeutrals;
  LeaderClass := ckWarrior;
  CanAttack := True;
end;

destructor TParty.Destroy;
begin

  inherited;
end;

procedure TParty.ModifyArmor(const APosition: TPosition; const AArmor: Integer);
begin
  with FCreature[APosition] do
    if Alive then
      Armor.ModifyTempValue(AArmor);
end;

procedure TParty.ModifyDamage(const APosition: TPosition;
  const ADamage: Integer);
begin
  with FCreature[APosition] do
    if Alive then
      Damage.ModifyTempValue(ADamage);
end;

procedure TParty.ModifyInitiative(const APosition: TPosition;
  const AInitiative: Integer);
begin
  with FCreature[APosition] do
    if Alive then
      Initiative.ModifyTempValue(AInitiative);
end;

procedure TParty.ModifyPartyChancesToHit(const AValue: Integer);
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    FCreature[LPosition].ChancesToHit.ModifyTempValue(AValue);
end;

procedure TParty.ModifyPartyDamage(const AValue: Integer);
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    FCreature[LPosition].Damage.ModifyTempValue(AValue);
end;

procedure TParty.MoveCreature(FromParty: TParty; const APosition: TPosition);
begin
  FCreature[APosition] := FromParty.Creature[APosition];
end;

function TParty.Dismiss(const APosition: TPosition): Boolean;
begin
  Result := False;
  if FCreature[APosition].Leadership > 0 then
    Exit;
  TCreature.Clear(FCreature[APosition]);
  Result := True;
end;

procedure TParty.Explosion(const ADamage: Integer; const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Alive then
    begin
      HitPoints.ModifyCurrValue(-ADamage);
    end;
end;

function TParty.GetCreature(APosition: TPosition): TCreature;
begin
  Result := FCreature[APosition];
end;

function TParty.GetExperience: Integer;
var
  LPosition: TPosition;
begin
  Result := 0;
  for LPosition := Low(TPosition) to High(TPosition) do
    with Creature[LPosition] do
      if Active then
        Inc(Result, HitPoints.GetMaxValue);
end;

function TParty.GetHitPoints(const APosition: TPosition): Integer;
begin
  if not FCreature[APosition].Active then
    Exit(0);
  Result := FCreature[APosition].HitPoints.GetCurrValue;
end;

function TParty.GetInitiative(const APosition: TPosition): Integer;
begin
  if not FCreature[APosition].Active then
    Exit(0);
  Result := FCreature[APosition].Initiative.GetFullValue();
end;

function TParty.GetLeaderGender: TCreatureGender;
var
  LPosition: TPosition;
  LCreature: TCreatureBase;
begin
  Result := cgFeMale;
  for LPosition := Low(TPosition) to High(TPosition) do
    if FCreature[LPosition].IsLeader then
    begin
      LCreature := TCreature.Character(FCreature[LPosition].Enum);
      Exit(LCreature.Gender);
    end;
end;

function TParty.GetMaxExperiencePerLevel(const Level: Integer): Integer;
begin
  Result := Level * 250;
end;

function TParty.GetRandomPosition: TPosition;
begin
  repeat
    Result := RandomRange(Low(TPosition), High(TPosition) + 1);
  until FCreature[Result].Alive;
end;

function TParty.GetCount: Integer;
var
  LPosition: TPosition;
begin
  Result := -1;
  for LPosition := Low(TPosition) to High(TPosition) do
    with FCreature[LPosition] do
      if Active then
        Inc(Result);
end;

class procedure TParty.Gen(const AX, AY: Integer; IsFinal: Boolean);
begin

end;

function TParty.GetAliveCreatures: Integer;
var
  LPosition: TPosition;
begin
  Result := 0;
  for LPosition := Low(TPosition) to High(TPosition) do
    with FCreature[LPosition] do
      if Alive then
        Inc(Result);
end;

function TParty.GetAllHitpointsSum: Integer;
var
  LPosition: TPosition;
begin
  Result := 0;
  for LPosition := Low(TPosition) to High(TPosition) do
    with FCreature[LPosition] do
      if Alive then
        Inc(Result, HitPoints.GetMaxValue);
end;

function TParty.GetAllDamageSum: Integer;
var
  LPosition: TPosition;
begin
  Result := 0;
  for LPosition := Low(TPosition) to High(TPosition) do
    with FCreature[LPosition] do
      if Alive then
        Inc(Result, Damage.GetFullValue);
end;

function TParty.GetAliveAndNeedExpCreatures: Integer;
var
  LPosition: TPosition;
begin
  Result := 0;
  for LPosition := Low(TPosition) to High(TPosition) do
    with FCreature[LPosition] do
      if Alive and not IsMaxLevel then
        Inc(Result);
end;

procedure TParty.Heal(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Alive then
      HitPoints.SetToMaxValue;
end;

procedure TParty.Heal(const APosition: TPosition; const AHitPoints: Integer);
begin
  with FCreature[APosition] do
    if Alive then
      HitPoints.ModifyCurrValue(AHitPoints);
end;

procedure TParty.HealParty(const AHitPoints: Integer);
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    Heal(LPosition, AHitPoints);
end;

function TParty.Hire(const ACreatureEnum: TCreatureEnum;
  const APosition: TPosition): Boolean;
var
  LCreature: TCreatureBase;
begin
  Result := False;
  LCreature := TCreature.Character(ACreatureEnum);
  if LCreature.Gold > Game.Gold.Value then
    Exit;
  if not FCreature[APosition].Active then
  begin
    Result := True;
    AddCreature(ACreatureEnum, APosition);
    Game.Gold.Modify(-LCreature.Gold);
  end;
end;

procedure TParty.ReduceArmor(const APercent: Integer;
  const APosition: TPosition);
var
  LArmor: Integer;
begin
  with FCreature[APosition] do
    if Alive then
    begin
      LArmor := Percent(Armor.GetCurrValue, APercent);
      Armor.SetCurrValue(LArmor);
    end;
end;

procedure TParty.Revive(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if not Alive then
      HitPoints.SetCurrValue(1);
end;

procedure TParty.ReviveParty;
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    Revive(LPosition);
end;

procedure TParty.SetCreature(APosition: TPosition; const Value: TCreature);
begin
  FCreature[APosition] := Value;
end;

procedure TParty.SetHitPoints(const APosition: TPosition;
  const AHitPoints: Integer);
begin
  FCreature[APosition].HitPoints.SetCurrValue(AHitPoints);
end;

procedure TParty.SetState(const APosition: TPosition; const Flag: Boolean);
begin
  FCreature[APosition].Active := Flag;
end;

procedure TParty.Swap(Party: TParty; A, B: Integer);
var
  LCreature: TCreature;
begin
  if (Party.Creature[B].Leadership > 0) or (Creature[A].Leadership > 0) or
    (Party = nil) then
    Exit;
  LCreature := Party.Creature[B];
  Party.Creature[B] := FCreature[A];
  FCreature[A] := LCreature;
end;

procedure TParty.Swap(A, B: Integer);
var
  LCreature: TCreature;
begin
  LCreature := FCreature[B];
  FCreature[B] := FCreature[A];
  FCreature[A] := LCreature;
end;

procedure TParty.TakeDamage(const ADamage: Integer; const APosition: TPosition);
var
  LDamage: Integer;
begin
  if ADamage <= 0 then
    Exit;
  with FCreature[APosition] do
    if Active then
    begin
      if not HitPoints.IsMinCurrValue then
      begin
        LDamage := ADamage - Armor.GetFullValue();
        if (LDamage > 0) then
          HitPoints.ModifyCurrValue(-LDamage)
        else
          Game.MediaPlayer.PlaySound(mmBlock);
      end;
    end;
end;

procedure TParty.TakeDamageAll(const ADamage: Integer);
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    TakeDamage(ADamage, LPosition);
end;

procedure TParty.UpdateDamage(const ADamage: Integer;
  const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Alive then
      if (ADamage > 0) then
        Damage.ModifyCurrValue(ADamage, 1, 500);
end;

procedure TParty.UpdateHP(const AHitPoints: Integer;
  const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Alive then
      if (AHitPoints > 0) then
        if (HitPoints.GetCurrValue + AHitPoints <= HitPoints.GetMaxValue) then
          HitPoints.ModifyCurrValue(AHitPoints)
        else
          HitPoints.SetToMaxValue;
end;

procedure TParty.UpdateLevel(const APosition: TPosition);
var
  LMaxHitPoints: Integer;
begin
  with FCreature[APosition] do
  begin
    if IsMaxLevel then
      Exit;
    Experience := 0;
    Game.MediaPlayer.PlaySound(mmLevel);

    LMaxHitPoints := EnsureRange(HitPoints.GetMaxValue +
      (HitPoints.GetMaxValue div 10), 25, 1000);
    HitPoints.SetValue(LMaxHitPoints);
    Initiative.ModifyCurrValue(1, 10, 80);
    ChancesToHit.ModifyCurrValue(1, 10, 95);
    if Damage.GetCurrValue > 0 then
      Damage.ModifyCurrValue((Damage.GetCurrValue div 10), 0, 300);
    if Heal > 0 then
      Heal := EnsureRange(Heal + (Heal div 15), 0, 150);
    Level := EnsureRange(Level + 1, 0, MaxLevel);
  end;
end;

procedure TParty.UpdateXP(const AExperience: Integer;
  const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Alive then
      if (AExperience > 0) then
        Experience := Experience + AExperience;
end;

{ TLeaderParty }

procedure TLeaderParty.ChCityOwner;
begin
  case PartyList.Party[LeaderPartyIndex].Owner of
    faTheEmpire:
      Game.Map.SetTile(lrTile, X, Y, reTheEmpireCity);
    faUndeadHordes:
      Game.Map.SetTile(lrTile, X, Y, reUndeadHordesCity);
    faLegionsOfTheDamned:
      Game.Map.SetTile(lrTile, X, Y, reLegionsOfTheDamnedCity);
  end;
end;

procedure TLeaderParty.Clear;
begin
  Abilities.Clear;
  Leader.Abilities.Add(TSceneHire.CurCrAbilityEnum);
  Inventory.Clear;
  Equipment.Clear;
  SetMaxMovementPoints;
  SetMaxSpellsPerDay;
  Self.UpdateSightRadius;
  IsUnitSelected := False;
  LeaderRegenerationValue := IfThen(Difficulty.Level = dfEasy, 5, 0);
  LeaderChanceToParalyzeValue := 0;
  LeaderVampiricAttackValue := 0;
  PartyGainMoreExpValue := 0;
  LeaderGainsMoreMovePointsValue := 0;
  LeaderInvisibleValue := 0;
end;

constructor TLeaderParty.Create(const AX, AY: Integer; AOwner: TFactionEnum);
begin
  inherited Create(AX, AY, AOwner);
  FAbilities := TAbilities.Create;
  FInventory := TInventory.Create;
  FEquipment := TEquipment.Create;
  FInvisibility := False;
  IsUnitSelected := False;
end;

destructor TLeaderParty.Destroy;
begin
  FreeAndNil(FEquipment);
  FreeAndNil(FInventory);
  FreeAndNil(FAbilities);
  inherited;
end;

function TLeaderParty.Enum: TCreatureEnum;
begin
  Result := TLeaderParty.Leader.Creature[TLeaderParty.GetPosition].Enum;
end;

procedure TLeaderParty.Equip(const InventoryItemIndex: Integer);
var
  InvItemEnum: TItemEnum;
  EqItemEnum: TItemEnum;
  I: Integer;
begin
  InvItemEnum := Inventory.ItemEnum(InventoryItemIndex);
  if InvItemEnum = iNone then
    Exit;
  for I := 0 to CMaxEquipmentItems - 1 do
    if (DollSlot[I] = TItemBase.Item(InvItemEnum).ItSlot) then
      if Equipment.Item(I).Enum = iNone then
      begin
        Equipment.Add(I, InvItemEnum);
        Inventory.Clear(InventoryItemIndex);
        Break;
      end;
end;

procedure TLeaderParty.Quaff(const AItemIndex: Integer;
  const APosition: TPosition);
var
  LItemEnum: TItemEnum;

  function CanUseHealingItem: Boolean;
  begin
    Result := Creature[APosition].Alive;
    if not Result then
      Game.InformDialog(CNeedResurrection);
  end;

  function NeedsHealing: Boolean;
  begin
    Result := Creature[APosition].Alive and not TLeaderParty.Leader.Creature
      [APosition].HitPoints.IsMaxCurrValue;
    if Creature[APosition].Alive and not Result then
      Game.InformDialog(CNoHealingNeeded);
  end;

  procedure HealCreature(const Amount: Integer);
  begin
    Game.MediaPlayer.PlaySound(mmDrink);
    Game.MediaPlayer.PlaySound(mmHeal);
    TLeaderParty.Leader.Heal(APosition, Amount);
    Inventory.Clear(AItemIndex);
  end;

  procedure ReviveCreature;
  begin
    Game.MediaPlayer.PlaySound(mmDrink);
    Game.MediaPlayer.PlaySound(mmRevive);
    TLeaderParty.Leader.Revive(APosition);
    Inventory.Clear(AItemIndex);
  end;

  procedure IncreaseDamageTemp(const APercent: Integer);
  begin
    Game.MediaPlayer.PlaySound(mmDrink);
    Game.MediaPlayer.PlaySound(mmBoost);
    TLeaderParty.Leader.IncreaseDamageTemp(APercent, APosition);
    Inventory.Clear(AItemIndex);
  end;

  procedure IncreaseChancesToHitTemp(const APercent: Integer);
  begin
    Game.MediaPlayer.PlaySound(mmDrink);
    Game.MediaPlayer.PlaySound(mmBoost);
    TLeaderParty.Leader.IncreaseChancesToHitTemp(APercent, APosition);
    Inventory.Clear(AItemIndex);
  end;

  procedure IncreaseHitPointsPermanently;
  begin
    Game.MediaPlayer.PlaySound(mmDrink);
    Game.MediaPlayer.PlaySound(mmBoost);
    TLeaderParty.Leader.IncreaseHitPointsPermanently(APosition);
    Inventory.Clear(AItemIndex);
  end;

  procedure IncreaseChancesToHitPermanently;
  begin
    Game.MediaPlayer.PlaySound(mmDrink);
    Game.MediaPlayer.PlaySound(mmBoost);
    TLeaderParty.Leader.IncreaseChancesToHitPermanently(APosition);
    Inventory.Clear(AItemIndex);
  end;

begin
  LItemEnum := Inventory.ItemEnum(AItemIndex);
  if (LItemEnum = iNone) or not(LItemEnum in CQuaffItems) then
    Exit;

  case LItemEnum of
    iLifePotion:
      if not Creature[APosition].Alive then
        ReviveCreature
      else
        Game.InformDialog(CNoRevivalNeeded);
    iPotionOfHealing:
      if CanUseHealingItem and NeedsHealing then
        HealCreature(50);
    iPotionOfRestoration:
      if CanUseHealingItem and NeedsHealing then
        HealCreature(100);
    iHealingOintment:
      if CanUseHealingItem and NeedsHealing then
        HealCreature(200);
    iElixirOfStrength:
      if CanUseHealingItem then
        IncreaseDamageTemp(20);
    iElixirOfAccuracy:
      if CanUseHealingItem then
        IncreaseChancesToHitTemp(20);
    iHighfathersEssence:
      if CanUseHealingItem then
        IncreaseHitPointsPermanently;
    iEssenceOfFortune:
      if CanUseHealingItem then
        IncreaseChancesToHitPermanently;
  end;
end;

function TLeaderParty.UnEquip(const EquipmentItemIndex: Integer): Boolean;
var
  InvItemEnum: TItemEnum;
  EqItemEnum: TItemEnum;
  SlotIndex: Integer;
begin
  Result := False;
  EqItemEnum := Equipment.Item(EquipmentItemIndex).Enum;
  if EqItemEnum = iNone then
    Exit;
  if Inventory.Count >= CMaxInventoryItems then
    Exit(True);
  Equipment.Clear(EquipmentItemIndex);
  Inventory.Add(EqItemEnum);
end;

function TLeaderParty.Level: Integer;
begin
  Result := TLeaderParty.Leader.Creature[TLeaderParty.GetPosition].Level;
end;

function TLeaderParty.GetMaxMovementPoints: Integer;
var
  LBonusMovePoints: Integer;
begin
  Result := TLeaderParty.GetMovementPoints(TLeaderParty.Leader.Enum);
  if Abilities.IsAbility(abPathfinding) then
    Result := Result + 5;
  if Abilities.IsAbility(abAdvancedPathfinding) then
    Result := Result + 7;
  if Abilities.IsAbility(abLogistics) then
    Result := Result + 9;
  if LeaderGainsMoreMovePointsValue > 0 then
  begin
    LBonusMovePoints := (Result * LeaderGainsMoreMovePointsValue) div 10;
    if LBonusMovePoints > 0 then
      Result := Result + LBonusMovePoints;
  end;
end;

class function TLeaderParty.GetMovementPoints(const CrEnum
  : TCreatureEnum): Integer;
begin
  if (CrEnum in ScoutingLeaders) then
    Result := CLeaderScoutMaxSpeed
  else if (CrEnum in LordLeaders) then
    Result := CLeaderLordMaxSpeed
  else
    Result := CLeaderDefaultMaxSpeed;
end;

class function TLeaderParty.GetSpellCastingRange(const CrEnum
  : TCreatureEnum): Integer;
begin
  Result := IfThen(CrEnum in MageLeaders, 2, 1);
end;

function TLeaderParty.GetSpellCastingRange: Integer;
begin
  Result := TLeaderParty.GetSpellCastingRange(TLeaderParty.Leader.Enum);
  if Abilities.IsAbility(abDoragorPower) then
    Result := Result + 1;
  if Self.LeaderInvisibleValue > 3 then
    Result := Result + 1;
end;

class function TLeaderParty.GetSpellsPerDay(const CrEnum
  : TCreatureEnum): Integer;
begin
  Result := IfThen(CrEnum in MageLeaders, 2, 1);
end;

function TLeaderParty.GetGoldCost(const AGold: Integer): Integer;
begin
  Result := AGold;
  if Abilities.IsAbility(abTemplar) then
    Result := AGold div 2;
end;

function TLeaderParty.GetInvisibility: Boolean;
begin
  Result := Invisibility or Abilities.IsAbility(abStealth) or
    (LeaderInvisibleValue > 0);
end;

function TLeaderParty.GetLeadership: Integer;
const
  LeadershipAbilities: array [0 .. 3] of TAbilityEnum = (abLeadership1,
    abLeadership2, abLeadership3, abLeadership4);
var
  LAbilityEnum: TAbilityEnum;
begin
  Result := 1;
  for LAbilityEnum in LeadershipAbilities do
    if Self.Abilities.IsAbility(LAbilityEnum) then
      Inc(Result);
end;

function TLeaderParty.GetMaxSpellsPerDay: Integer;
begin
  Result := 1;
  if Self.Abilities.IsAbility(abSorcery) then
    Result := Result + 1;
end;

function TLeaderParty.IsPartyOwner(const AX, AY: Integer): Boolean;
var
  CurrentPartyIndex: Integer;
begin
  CurrentPartyIndex := PartyList.GetPartyIndex(AX, AY);
  if CurrentPartyIndex < 0 then
    Result := False
  else
    Result := TLeaderParty.Leader.Owner = PartyList.Party
      [CurrentPartyIndex].Owner;
end;

class function TLeaderParty.GetPosition: TPosition;
begin
  Result := 0;
  while not Leader.Creature[Result].IsLeader do
    Inc(Result);
end;

class function TLeaderParty.GetSightRadius(const ACreatureEnum
  : TCreatureEnum): Integer;
begin
  Result := IfThen(ACreatureEnum in ScoutingLeaders, CLeaderScoutMaxRadius,
    CLeaderDefaultMaxRadius);
end;

function TLeaderParty.GetSightRadius: Integer;
begin
  Result := TLeaderParty.GetSightRadius(TLeaderParty.Leader.Enum);
  if Self.Abilities.IsAbility(abSharpEye) then
    Result := Result + 1;
  if Self.Abilities.IsAbility(abHawkEye) then
    Result := Result + 1;
  if Self.Abilities.IsAbility(abFarSight) then
    Result := Result + 1;
  if Self.LeaderInvisibleValue > 1 then
    Result := Result + (Self.LeaderInvisibleValue - 1);
end;

function TLeaderParty.InSightRadius(const AX, AY: Integer): Boolean;
begin
  Result := (Game.Map.GetDist(AX, AY, X, Y) <= GetSightRadius);
end;

function TLeaderParty.InSpellCastingRange(const AX, AY: Integer): Boolean;
begin
  Result := (Game.Map.GetDist(AX, AY, X, Y) <= GetSpellCastingRange);
end;

class function TLeaderParty.Leader: TLeaderParty;
begin
  Result := TLeaderParty(PartyList.Party[LeaderPartyIndex]);
end;

procedure TLeaderParty.LeaderRegeneration;
var
  LPosition: TPosition;
  LHitPoints: Integer;
begin
  LPosition := Leader.GetPosition;
  LHitPoints := Leader.Creature[LPosition].HitPoints.GetMaxValue;
  Heal(LPosition, Percent(LHitPoints, EnsureRange(GetLeaderRegenerationValue,
    0, 100)));
  if Abilities.IsAbility(abNaturalHealing) then
    Heal(LPosition, Percent(LHitPoints, 10));
end;

class function TLeaderParty.GetLeaderRegenerationValue: Integer;
begin
  Result := LeaderRegenerationValue;
  if LeaderInvisibleValue > 2 then
    Result := Result + ((LeaderInvisibleValue - 2) * 10);
end;

class procedure TLeaderParty.ModifyLeaderChanceToParalyze
  (const AValue: Integer);
begin
  LeaderChanceToParalyzeValue := LeaderChanceToParalyzeValue + AValue;
end;

class procedure TLeaderParty.ModifyLeaderInvisible(const AValue: Integer);
begin
  LeaderInvisibleValue := LeaderInvisibleValue + AValue;
end;

class procedure TLeaderParty.ModifyLeaderMovePoints(const AValue: Integer);
begin
  LeaderGainsMoreMovePointsValue := AValue;
end;

class procedure TLeaderParty.ModifyLeaderRegeneration(const AValue: Integer);
begin
  LeaderRegenerationValue := LeaderRegenerationValue + AValue;
end;

class procedure TLeaderParty.ModifyLeaderVampiricAttack(const AValue: Integer);
begin
  LeaderVampiricAttackValue := LeaderVampiricAttackValue + AValue;
end;

class procedure TLeaderParty.ModifyPartyGainMoreExp(const AValue: Integer);
begin
  PartyGainMoreExpValue := AValue;
end;

class procedure TLeaderParty.Move(Dir: TDirectionEnum);
begin
  PutAt(Leader.X + Direction[Dir].X, Leader.Y + Direction[Dir].Y);
end;

class procedure TLeaderParty.MoveUnit(AParty: TParty);
begin
  if not((ActivePartyPosition < 0) or ((ActivePartyPosition < 6) and
    (CurrentPartyPosition >= 6) and
    (PartyList.Party[TLeaderParty.LeaderPartyIndex].Count >=
    TLeaderParty.Leader.Leadership))) then
  begin
    PartyList.Party[TLeaderParty.LeaderPartyIndex].ChPosition(AParty,
      ActivePartyPosition, CurrentPartyPosition);
    Game.MediaPlayer.PlaySound(mmClick);
  end;
end;

class procedure TLeaderParty.PutAt(const AX, AY: ShortInt;
  const IsInfo: Boolean);
var
  I, JX, JY: Integer;
  F: Boolean;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  if (Game.Map.GetTile(lrObj, AX, AY) in StopTiles) then
    Exit;
  if not IsInfo then
    for I := 0 to High(Game.Map.MapPlace) do
    begin
      if (Game.Map.MapPlace[I].Owner in PlayableFactions) then
        if (Game.Map.MapPlace[I].CurLevel < Game.Map.MapPlace[I].MaxLevel) then
        begin
          Inc(Game.Map.MapPlace[I].CurLevel);
          TMapPlace.UpdateRadius(I);
        end;
    end;
  if IsInfo then
  begin
    if Game.Map.GetTile(lrTile, AX, AY) in Capitals then
    begin
      TSceneParty2.Show(PartyList.Party[CapitalPartyIndex], scMap);
      Exit;
    end;
    if Game.Map.GetTile(lrTile, AX, AY) in Cities then
    begin
      I := PartyList.GetPartyIndex(AX, AY);
      if not PartyList.Party[I].IsClear then
        TSceneParty2.Show(PartyList.Party[I], scMap);
      Exit;
    end;
    case Game.Map.GetTile(lrObj, AX, AY) of
      reEnemy:
        begin
          I := PartyList.GetPartyIndex(AX, AY);
          TSceneParty2.Show(PartyList.Party[I], scMap);
        end;
    end;
    Exit;
  end
  else
  begin
    Leader.SetLocation(AX, AY);
    Game.Statistics.IncValue(stTilesMoved);
    Game.MediaPlayer.PlaySound(mmStep);
    with TLeaderParty.Leader do
    begin
      SetLocation(AX, AY);
      UpdateSightRadius;
      Turn(1);
    end;
    F := True;
    case Game.Map.GetTile(lrObj, Leader.X, Leader.Y) of
      reGold:
        begin
          TLeaderParty.Leader.Invisibility := False;
          TSceneLoot2.ShowScene;
          Exit;
        end;
      reMana:
        begin
          TLeaderParty.Leader.Invisibility := False;
          TSceneLoot2.ShowScene;
          Exit;
        end;
      reBag:
        begin
          TLeaderParty.Leader.Invisibility := False;
          Game.Statistics.IncValue(stChestsFound);
          TSceneLoot2.ShowScene;
          Exit;
        end;
      reEnemy:
        begin
          TLeaderParty.Leader.Invisibility := False;
          Game.Show(scBattle);
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          Exit;
        end;
      reSTower:
        begin
          Game.MediaPlayer.PlaySound(mmSettlement);
          Game.Map.UpdateRadius(Leader.X, Leader.Y, 3);
          F := False;
        end;
      reMageTower:
        begin
          Game.MediaPlayer.PlayMusic(mmMagic);
          Game.MediaPlayer.PlaySound(mmSettlement);
          TSceneMageTower.ShowScene;
          F := False;
        end;
      reMerchantPotions:
        begin
          Game.MediaPlayer.PlaySound(mmSettlement);
          TSceneMerchant.ShowScene(TLeaderParty.Leader, mtPotions, scMap);
          F := False;
        end;
      reMerchantArtifacts:
        begin
          Game.MediaPlayer.PlaySound(mmSettlement);
          TSceneMerchant.ShowScene(TLeaderParty.Leader, mtArtifacts, scMap);
          F := False;
        end;
    end;
  end;
  case Game.Map.LeaderTile of
    reNeutralCity:
      begin
        TLeaderParty.Leader.ChCityOwner;
        TMapPlace.UpdateRadius(TMapPlace.GetIndex(Leader.X, Leader.Y));
        F := False;
      end;
  end;
  if Game.Map.LeaderTile in Capitals then
  begin
    Game.MediaPlayer.PlayMusic(mmGame);
    Game.MediaPlayer.PlaySound(mmSettlement);
    TSceneSettlement.ShowScene(stCapital);
    F := False;
  end;
  if Game.Map.LeaderTile in Cities then
  begin
    Game.MediaPlayer.PlayMusic(mmGame);
    Game.MediaPlayer.PlaySound(mmSettlement);
    TSceneSettlement.ShowScene(stCity);
    F := False;
  end;
  if not Leader.GetInvisibility() then
    for JX := Leader.X - 1 to Leader.X + 1 do
      for JY := Leader.Y - 1 to Leader.Y + 1 do
        if Game.Map.InMap(JX, JY) then
        begin
          case Game.Map.GetTile(lrObj, JX, JY) of
            reEnemy:
              begin
                I := PartyList.GetPartyIndex(JX, JY);

                if not PartyList.Party[I].IsClear and PartyList.Party[I]
                  .CanAttack and not PartyList.Party[I].IsParalyzeParty() then
                begin
                  TLeaderParty.PutAt(JX, JY);
                  F := False;
                  Exit;
                end;
              end;
          end;
        end;
  if F then
    Game.NewDay;
end;

procedure TLeaderParty.SetMaxMovementPoints;
begin
  MovementPoints.SetValue(Leader.GetMaxMovementPoints);
end;

procedure TLeaderParty.SetMaxSpellsPerDay;
begin
  SpellsPerDay.SetValue(Leader.GetMaxSpellsPerDay);
end;

class function TLeaderParty.Summoned: TLeaderParty;
begin
  Result := TLeaderParty(PartyList.Party[SummonPartyIndex]);
end;

class procedure TLeaderParty.Move(const AX, AY: ShortInt);
begin
  Leader.PutAt(Leader.X + AX, Leader.Y + AY);
end;

procedure TLeaderParty.Turn(const ACount: Integer);
var
  LCount: Integer;
begin
  if (ACount < 1) then
    Exit;
  LCount := 0;
  repeat
    MovementPoints.ModifyCurrValue(-1);
    if MovementPoints.IsMinCurrValue then
    begin
      Inc(Game.Day);
      Game.IsNewDay := True;
      SetMaxMovementPoints;
      SetMaxSpellsPerDay;
    end;
    Inc(LCount);
  until (LCount >= ACount);
  Game.ShowNewDayMessageTime := 0;
end;

class procedure TLeaderParty.UpdateMoveUnit(AParty: TParty);
begin
  if IsUnitSelected then
  begin
    IsUnitSelected := False;
    SelectPartyPosition := -1;
    MoveUnit(AParty);
  end
  else
  begin
    IsUnitSelected := True;
    SelectPartyPosition := ActivePartyPosition;
    CurrentPartyPosition := ActivePartyPosition;
  end;

end;

class procedure TLeaderParty.UpdateMoveUnit(AParty: TParty;
  const AX, AY: Integer);
var
  LPosition: TPosition;
begin
  IsUnitSelected := False;
  LPosition := Game.GetPartyPosition(AX, AY);
  case LPosition of
    0 .. 5:
      begin
        ActivePartyPosition := LPosition;
        TLeaderParty.MoveUnit(AParty);
      end;
  end;
end;

procedure TLeaderParty.UpdateSightRadius;
begin
  Game.Map.UpdateRadius(Self.X, Self.Y, Self.GetSightRadius,
    Game.Map.GetLayer(lrDark), reNone);
end;

{ TParties }

constructor TPartyList.Create;
begin

end;

destructor TPartyList.Destroy;
begin

  inherited;
end;

function TPartyList.Count: Integer;
begin
  Result := Length(Party);
end;

function TPartyList.GetPartyIndex(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (Party[I].X = AX) and (Party[I].Y = AY) then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TPartyList.PartyInit(const AX, AY: Integer; IsFinal: Boolean);
var
  LLevel, LPartyIndex: Integer;
  LPosition: TPosition;
  LCreatureEnum: TCreatureEnum;
begin
  LLevel := EnsureRange(TMap.GetTileLevel(AX, AY), 1, TParty.MaxLevel);
  SetLength(Party, PartyList.Count + 1);
  Party[PartyList.Count - 1] := TParty.Create(AX, AY);
  repeat
    LPartyIndex := RandomRange(0, Length(PartyBase));
  until (PartyBase[LPartyIndex].Level = LLevel) and
    (PartyBase[LPartyIndex].Faction <> Game.Scenario.Faction);
  if IsFinal then
    LPartyIndex := High(PartyBase);
  with Party[PartyList.Count - 1] do
  begin
    for LPosition := Low(TPosition) to High(TPosition) do
      AddCreature(PartyBase[LPartyIndex].Character[LPosition], LPosition);
  end;
end;

procedure TPartyList.AddPartyAt(const AX, AY: Integer;
  CanAttack, IsFinal: Boolean);
var
  LPartyIndex: Integer;
  LStringList: TStringList;
  LPosition: TPosition;
  LText: string;
begin
  Game.Map.SetTile(lrObj, AX, AY, reEnemy);
  PartyInit(AX, AY, IsFinal);
  LPartyIndex := PartyList.GetPartyIndex(AX, AY);
  Party[LPartyIndex].Owner := faNeutrals;
  Party[LPartyIndex].CanAttack := CanAttack;
  if IsFinal then
  begin
    Party[LPartyIndex].CanAttack := False;
    Loot.AddItemAt(AX, AY);
    Loot.AddItemAt(AX, AY);
    Loot.AddGemAt(AX, AY);
  end;
  Loot.AddItemAt(AX, AY);
  if (RandomRange(0, 2) = 0) and TLeaderParty.Leader.Abilities.IsAbility
    (abGemology) then
    Loot.AddGemAt(AX, AY);
  if (RandomRange(0, 2) = 0) then
    Loot.AddGoldAt(AX, AY);
  if (RandomRange(0, 2) = 0) then
    Loot.AddManaAt(AX, AY);

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

procedure TPartyList.Clear;
var
  I: Integer;
begin
  for I := 0 to PartyList.Count - 1 do
    FreeAndNil(Party[I]);
  SetLength(Party, 0);
end;

initialization

PartyList := TPartyList.Create;

finalization

FreeAndNil(PartyList);

end.
