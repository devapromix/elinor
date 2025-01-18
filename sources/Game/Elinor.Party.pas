unit Elinor.Party;

interface

uses
  System.Types,
  Elinor.Factions,
  Elinor.Creatures,
  Elinor.MapObject,
  Elinor.Attribute,
  Elinor.Items,
  Elinor.Map;

type
  TPartySide = (psLeft, psRight);

type
  TPosition = 0 .. 5;

type
  TDirectionEnum = (drEast, drWest, drSouth, drNorth, drSouthEast, drSouthWest,
    drNorthEast, drNorthWest, drOrigin);

const
  Direction: array [TDirectionEnum] of TPoint = ((X: 1; Y: 0), (X: - 1; Y: 0),
    (X: 0; Y: 1), (X: 0; Y: - 1), (X: 1; Y: 1), (X: - 1; Y: 1), (X: 1; Y: - 1),
    (X: - 1; Y: - 1), (X: 0; Y: 0));

type

  { TParty }

  TParty = class(TMapObject)
  strict private
    FOwner: TFactionEnum;
    FCreature: array [TPosition] of TCreature;
    function GetCreature(APosition: TPosition): TCreature;
    procedure SetCreature(APosition: TPosition; const Value: TCreature);
    function GetCount: Integer;
  private
  public
    constructor Create(const AX, AY: Integer); overload;
    constructor Create(const AX, AY: Integer; AOwner: TFactionEnum); overload;
    destructor Destroy; override;
    procedure MoveCreature(FromParty: TParty; const APosition: TPosition);
    procedure AddCreature(const ACreatureEnum: TCreatureEnum;
      const APosition: TPosition);
    property Owner: TFactionEnum read FOwner write FOwner;
    procedure ClearParalyze(const APosition: TPosition);
    procedure ClearParalyzeAll;
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
    procedure Heal(const APosition: TPosition); overload;
    procedure Heal(const APosition: TPosition;
      const AHitPoints: Integer); overload;
    procedure HealAll(const AHitPoints: Integer);
    procedure Paralyze(const APosition: TPosition);
    procedure Revive(const APosition: TPosition);
    procedure UpdateHP(const AHitPoints: Integer; const APosition: TPosition);
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
  end;

type

  { TLeaderParty }

  TLeaderParty = class(TParty)
  private
    FRadius: Integer;
    FSpells: Integer;
    FSpy: Integer;
    FAbilities: TAbilities;
    FInventory: TInventory;
    FEquipment: TEquipment;
    FInvisibility: Boolean;
    function GetRadius: Integer; overload;
    function GetLeadership: Integer;
  public
  class var
    LeaderPartyIndex: Byte;
    CreatureIndex: Byte;
    CapitalPartyIndex: Byte;
    SummonPartyIndex: Byte;
    Speed: TCurrMaxAttribute;
  public
    constructor Create(const AX, AY: Integer; AOwner: TFactionEnum);
    destructor Destroy; override;
    procedure Clear;
    property Radius: Integer read GetRadius;
    property Leadership: Integer read GetLeadership;
    property Spells: Integer read FSpells write FSpells;
    property Spy: Integer read FSpy write FSpy;
    procedure UpdateRadius;
    procedure Turn(const ACount: Integer = 1);
    procedure ChCityOwner;
    class function Leader: TLeaderParty;
    class procedure Move(const AX, AY: ShortInt); overload;
    class procedure Move(Dir: TDirectionEnum); overload;
    class procedure PutAt(const AX, AY: ShortInt;
      const IsInfo: Boolean = False);
    class function GetPosition: TPosition;
    function InRadius(const AX, AY: Integer): Boolean;
    function Enum: TCreatureEnum;
    function Level: Integer;
    function GetMaxSpy: Integer;
    function GetMaxSpells: Integer; overload;
    class function GetMaxSpells(const CrEnum: TCreatureEnum): Integer; overload;
    function GetMaxSpeed: Integer; overload;
    class function GetMaxSpeed(const CrEnum: TCreatureEnum): Integer; overload;
    function IsPartyOwner(const AX, AY: Integer): Boolean;
    property Abilities: TAbilities read FAbilities write FAbilities;
    property Inventory: TInventory read FInventory write FInventory;
    property Equipment: TEquipment read FEquipment write FEquipment;
    class function GetRadius(const ACreatureEnum: TCreatureEnum)
      : Integer; overload;
    procedure Equip(const InventoryItemIndex: Integer);
    procedure UnEquip(const EquipmentItemIndex: Integer);
    function GetGold(const AGold: Integer): Integer;
    property Invisibility: Boolean read FInvisibility write FInvisibility;
    function GetInvisibility: Boolean;
    class procedure SetMaxSpeed;
  end;

var
  Party: array of TParty;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Resources,
  Elinor.Scenes,
  Elinor.Scene.Party,
  Elinor.Scene.Settlement,
  DisciplesRL.Scene.Hire,
  Elinor.Statistics;

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

procedure TParty.ClearParalyze(const APosition: TPosition);
begin
  FCreature[APosition].Paralyze := False;
end;

procedure TParty.ClearParalyzeAll;
var
  LPosition: TPosition;
begin
  for LPosition := Low(TPosition) to High(TPosition) do
    FCreature[LPosition].Paralyze := False;
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
end;

constructor TParty.Create(const AX, AY: Integer);
begin
  inherited Create(AX, AY);
  Self.Clear;
  Owner := faNeutrals;
end;

destructor TParty.Destroy;
begin

  inherited;
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
  Result := 0;
  if FCreature[APosition].Active then
    Result := FCreature[APosition].HitPoints.GetCurrValue;
end;

function TParty.GetInitiative(const APosition: TPosition): Integer;
begin
  Result := 0;
  if FCreature[APosition].Active then
    Result := FCreature[APosition].Initiative.GetFullValue();
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

procedure TParty.HealAll(const AHitPoints: Integer);
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

procedure TParty.Revive(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if not Alive then
      HitPoints.SetCurrValue(1);
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
    Level := EnsureRange(Level + 1, 0, TSaga.MaxLevel);
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
  case Party[LeaderPartyIndex].Owner of
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
  Leader.Abilities.Add(TSceneHire.CurCrSkillEnum);
  Inventory.Clear;
  Equipment.Clear;
  SetMaxSpeed;
  FRadius := IfThen(Game.Wizard, 9, 1);
  FSpells := GetMaxSpells;
  FSpy := GetMaxSpy;
  Self.UpdateRadius;
end;

constructor TLeaderParty.Create(const AX, AY: Integer; AOwner: TFactionEnum);
begin
  inherited Create(AX, AY, AOwner);
  FAbilities := TAbilities.Create;
  FInventory := TInventory.Create;
  FEquipment := TEquipment.Create;
  FInvisibility := False;
  FRadius := 1;
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
  for I := 0 to MaxEquipmentItems - 1 do
    if (DollSlot[I] = TItemBase.Item(InvItemEnum).ItSlot) then
      if Equipment.Item(I).Enum = iNone then
      begin
        Equipment.Add(I, InvItemEnum);
        Inventory.Clear(InventoryItemIndex);
        Break;
      end;
end;

procedure TLeaderParty.UnEquip(const EquipmentItemIndex: Integer);
var
  InvItemEnum: TItemEnum;
  EqItemEnum: TItemEnum;
  SlotIndex: Integer;
begin
  EqItemEnum := Equipment.Item(EquipmentItemIndex).Enum;
  if EqItemEnum = iNone then
    Exit;
  if Inventory.Count = MaxInventoryItems then
    Exit;
  Equipment.Clear(EquipmentItemIndex);
  Inventory.Add(EqItemEnum);
end;

function TLeaderParty.Level: Integer;
begin
  Result := TLeaderParty.Leader.Creature[TLeaderParty.GetPosition].Level;
end;

function TLeaderParty.GetMaxSpeed: Integer;
begin
  Result := TLeaderParty.GetMaxSpeed(TLeaderParty.Leader.Enum);
  if Abilities.IsAbility(skOri) then
    Result := Result + 5;
end;

class function TLeaderParty.GetMaxSpeed(const CrEnum: TCreatureEnum): Integer;
begin
  if (CrEnum in ScoutingLeader) then
    Result := TSaga.LeaderScoutMaxSpeed
  else if (CrEnum in LeaderLord) then
    Result := TSaga.LeaderLordMaxSpeed
  else
    Result := TSaga.LeaderDefaultMaxSpeed;
end;

class function TLeaderParty.GetMaxSpells(const CrEnum: TCreatureEnum): Integer;
begin
  Result := IfThen(CrEnum in LeaderMage, 2, 1);
end;

function TLeaderParty.GetGold(const AGold: Integer): Integer;
begin
  Result := AGold;
  if Abilities.IsAbility(skTemplar) then
    Result := AGold div 2;
end;

function TLeaderParty.GetInvisibility: Boolean;
begin
  Result := Invisibility or Abilities.IsAbility(skStealth);
end;

function TLeaderParty.GetLeadership: Integer;
begin
  Result := 1;
  if Self.Abilities.IsAbility(skLeadership1) then
    Result := Result + 1;
  if Self.Abilities.IsAbility(skLeadership2) then
    Result := Result + 1;
  if Self.Abilities.IsAbility(skLeadership3) then
    Result := Result + 1;
  if Self.Abilities.IsAbility(skLeadership4) then
    Result := Result + 1;
end;

function TLeaderParty.GetMaxSpells: Integer;
begin
  Result := 1;
  if Self.Abilities.IsAbility(skSorcery) then
    Result := Result + 1;
end;

function TLeaderParty.IsPartyOwner(const AX, AY: Integer): Boolean;
var
  CurrentPartyIndex: Integer;
begin
  CurrentPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if CurrentPartyIndex < 0 then
    Result := False
  else
    Result := TLeaderParty.Leader.Owner = Party[CurrentPartyIndex].Owner;
end;

class function TLeaderParty.GetPosition: TPosition;
begin
  Result := 0;
  while not Leader.Creature[Result].IsLeader do
    Inc(Result);
end;

class function TLeaderParty.GetRadius(const ACreatureEnum
  : TCreatureEnum): Integer;
begin
  Result := IfThen(ACreatureEnum in ScoutingLeader, TSaga.LeaderScoutMaxRadius,
    TSaga.LeaderDefaultMaxRadius);
end;

function TLeaderParty.GetRadius: Integer;
begin
  Result := TLeaderParty.GetRadius(TLeaderParty.Leader.Enum);
  if Self.Abilities.IsAbility(skSharpEye) then
    Result := Result + 1;
  if Self.Abilities.IsAbility(skHawkEye) then
    Result := Result + 1;
  if Self.Abilities.IsAbility(skFarSight) then
    Result := Result + 1;
end;

function TLeaderParty.GetMaxSpy: Integer;
begin
  Result := IfThen(TLeaderParty.Leader.Enum in LeaderThief,
    TSaga.LeaderThiefSpyAttemptCountPerDay, 1);
end;

function TLeaderParty.InRadius(const AX, AY: Integer): Boolean;
begin
  Result := (Game.Map.GetDist(AX, AY, X, Y) <= Radius);
end;

class function TLeaderParty.Leader: TLeaderParty;
begin
  Result := TLeaderParty(Party[LeaderPartyIndex]);
end;

class procedure TLeaderParty.Move(Dir: TDirectionEnum);
begin
  PutAt(Leader.X + Direction[Dir].X, Leader.Y + Direction[Dir].Y);
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
      if (Game.Map.MapPlace[I].Owner in Factions) then
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
      TSceneParty.Show(Party[CapitalPartyIndex], scMap);
      Exit;
    end;
    if Game.Map.GetTile(lrTile, AX, AY) in Cities then
    begin
      I := TSaga.GetPartyIndex(AX, AY);
      if not Party[I].IsClear then
        TSceneParty.Show(Party[I], scMap);
      Exit;
    end;
    case Game.Map.GetTile(lrObj, AX, AY) of
      reEnemy:
        begin
          I := TSaga.GetPartyIndex(AX, AY);
          TSceneParty.Show(Party[I], scMap);
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
      UpdateRadius;
      Turn(1);
    end;
    F := True;
    case Game.Map.GetTile(lrObj, Leader.X, Leader.Y) of
      reGold:
        begin
          TLeaderParty.Leader.Invisibility := False;
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reGold);
          F := False;
        end;
      reMana:
        begin
          TLeaderParty.Leader.Invisibility := False;
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reMana);
          F := False;
        end;
      reBag:
        begin
          TLeaderParty.Leader.Invisibility := False;
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          Game.Statistics.IncValue(stChestsFound);
          TSaga.AddLoot(reBag);
          F := False;
        end;
      reEnemy:
        begin
          TLeaderParty.Leader.Invisibility := False;
          Game.Show(scBattle);
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          F := False;
          Exit;
        end;
      reSTower:
        begin
          Game.Map.UpdateRadius(Leader.X, Leader.Y, 3);
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
  if (RandomRange(0, 100) < 25) and not Leader.GetInvisibility() then
    for JX := Leader.X - 1 to Leader.X + 1 do
      for JY := Leader.Y - 1 to Leader.Y + 1 do
        if Game.Map.InMap(JX, JY) then
        begin
          case Game.Map.GetTile(lrObj, JX, JY) of
            reEnemy:
              begin
                TLeaderParty.PutAt(JX, JY);
                F := False;
                Exit;
              end;
          end;
        end;
  if F then
    Game.NewDay;
end;

class procedure TLeaderParty.SetMaxSpeed;
begin
  Speed.SetValue(Leader.GetMaxSpeed);
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
    Speed.ModifyCurrValue(-1);
    if Speed.IsMinCurrValue then
    begin
      Inc(Game.Day);
      Game.IsNewDay := True;
      SetMaxSpeed;
    end;
    Inc(LCount);
  until (LCount >= ACount);
  Game.ShowNewDayMessageTime := 0;
end;

procedure TLeaderParty.UpdateRadius;
begin
  Game.Map.UpdateRadius(Self.X, Self.Y, Self.Radius,
    Game.Map.GetLayer(lrDark), reNone);
end;

end.
