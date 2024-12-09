unit Elinor.Party;

interface

uses
  Types,

  DisciplesRL.Creatures,
  Elinor.MapObject,
  DisciplesRL.Items,
  DisciplesRL.Map;

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
    function IsClear: Boolean;
    function GetRandomPosition: TPosition;
    function Hire(const ACreatureEnum: TCreatureEnum;
      const APosition: TPosition): Boolean;
    procedure Dismiss(const APosition: TPosition);
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
    FSkills: TSkills;
    FInventory: TInventory;
    FEquipment: TEquipment;
    function GetRadius: Integer; overload;
    function GetLeadership: Integer;
  public
  class var
    LeaderPartyIndex: Byte;
    CapitalPartyIndex: Byte;
    Speed: Integer;
    MaxSpeed: Integer;
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
    property Skills: TSkills read FSkills write FSkills;
    property Inventory: TInventory read FInventory write FInventory;
    property Equipment: TEquipment read FEquipment write FEquipment;
    class function GetRadius(const CrEnum: TCreatureEnum): Integer; overload;
    procedure Equip(const InventoryItemIndex: Integer);
    procedure UnEquip(const EquipmentItemIndex: Integer);
  end;

var
  Party: array of TParty;

implementation

uses
  Math,
  SysUtils,
  Elinor.Saga,
  Elinor.Resources,
  DisciplesRL.Scenes,
  Elinor.Scene.Party,
  Elinor.Scene.Settlement,
  DisciplesRL.Scene.Hire;

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
    if (Creature[Position].HitPoints > 0) then
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
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
    FCreature[Position].Paralyze := False;
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
  Owner := reNeutrals;
end;

destructor TParty.Destroy;
begin

  inherited;
end;

procedure TParty.MoveCreature(FromParty: TParty; const APosition: TPosition);
begin
  FCreature[APosition] := FromParty.Creature[APosition];
end;

procedure TParty.Dismiss(const APosition: TPosition);
begin
  if FCreature[APosition].Leadership > 0 then
    Exit;
  TCreature.Clear(FCreature[APosition])
end;

function TParty.GetCreature(APosition: TPosition): TCreature;
begin
  Result := FCreature[APosition]
end;

function TParty.GetExperience: Integer;
var
  LPosition: TPosition;
begin
  Result := 0;
  for LPosition := Low(TPosition) to High(TPosition) do
    with Creature[LPosition] do
      if Active then
        Inc(Result, MaxHitPoints);
end;

function TParty.GetHitPoints(const APosition: TPosition): Integer;
begin
  Result := 0;
  if FCreature[APosition].Active then
    Result := FCreature[APosition].HitPoints;
end;

function TParty.GetInitiative(const APosition: TPosition): Integer;
begin
  Result := 0;
  if FCreature[APosition].Active then
    Result := FCreature[APosition].Initiative;
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

procedure TParty.Heal(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Alive then
      HitPoints := MaxHitPoints;
end;

procedure TParty.Heal(const APosition: TPosition; const AHitPoints: Integer);
begin
  with FCreature[APosition] do
    if Alive then
      HitPoints := EnsureRange(HitPoints + AHitPoints, 0, MaxHitPoints);
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
      HitPoints := 1;
end;

procedure TParty.SetCreature(APosition: TPosition; const Value: TCreature);
begin
  FCreature[APosition] := Value;
end;

procedure TParty.SetHitPoints(const APosition: TPosition;
  const AHitPoints: Integer);
begin
  FCreature[APosition].HitPoints := AHitPoints;
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
begin
  if ADamage <= 0 then
    Exit;
  with FCreature[APosition] do
    if Active then
    begin
      if (HitPoints > 0) then
        if (ADamage - Armor > 0) then
        begin
          HitPoints := HitPoints - (ADamage - Armor);
        end
        else
          Game.MediaPlayer.PlaySound(mmBlock);
      if (HitPoints < 0) then
        HitPoints := 0;
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
        if (HitPoints + AHitPoints <= MaxHitPoints) then
          HitPoints := HitPoints + AHitPoints
        else
          HitPoints := MaxHitPoints;
end;

procedure TParty.UpdateLevel(const APosition: TPosition);
begin
  with FCreature[APosition] do
  begin
    if Level >= TSaga.MaxLevel then
      Exit;
    Experience := 0;
    Game.MediaPlayer.PlaySound(mmLevel);
    MaxHitPoints := EnsureRange(MaxHitPoints + (MaxHitPoints div 10), 25, 1000);
    HitPoints := MaxHitPoints;
    Initiative := EnsureRange(Initiative + 1, 10, 80);
    ChancesToHit := EnsureRange(ChancesToHit + 1, 10, 95);
    if Damage > 0 then
      Damage := EnsureRange(Damage + (Damage div 10), 0, 300);
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
    reTheEmpire:
      Game.Map.SetTile(lrTile, X, Y, reTheEmpireCity);
    reUndeadHordes:
      Game.Map.SetTile(lrTile, X, Y, reUndeadHordesCity);
    reLegionsOfTheDamned:
      Game.Map.SetTile(lrTile, X, Y, reLegionsOfTheDamnedCity);
  end;
end;

procedure TLeaderParty.Clear;
begin
  Skills.Clear;
  Leader.Skills.Add(TSceneHire.CurCrSkillEnum);
  Inventory.Clear;
  Equipment.Clear;
  MaxSpeed := GetMaxSpeed;
  Speed := MaxSpeed;
  FRadius := IfThen(Game.Wizard, 9, 1);
  FSpells := GetMaxSpells;
  FSpy := GetMaxSpy;
  Self.UpdateRadius;
end;

constructor TLeaderParty.Create(const AX, AY: Integer; AOwner: TFactionEnum);
begin
  inherited Create(AX, AY, AOwner);
  FSkills := TSkills.Create;
  FInventory := TInventory.Create;
  FEquipment := TEquipment.Create;
  FRadius := 1;
end;

destructor TLeaderParty.Destroy;
begin
  FreeAndNil(FEquipment);
  FreeAndNil(FInventory);
  FreeAndNil(FSkills);
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
  if Skills.Has(skOri) then
    Result := Result + 5;
end;

class function TLeaderParty.GetMaxSpeed(const CrEnum: TCreatureEnum): Integer;
begin
  if (CrEnum in LeaderScout) then
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

function TLeaderParty.GetLeadership: Integer;
begin
  Result := 1;
  if Self.Skills.Has(skLeadership1) then
    Result := Result + 1;
  if Self.Skills.Has(skLeadership2) then
    Result := Result + 1;
  if Self.Skills.Has(skLeadership3) then
    Result := Result + 1;
  if Self.Skills.Has(skLeadership4) then
    Result := Result + 1;
end;

function TLeaderParty.GetMaxSpells: Integer;
begin
  Result := 1;
  if Self.Skills.Has(skSorcery) then
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

class function TLeaderParty.GetRadius(const CrEnum: TCreatureEnum): Integer;
begin
  Result := IfThen(CrEnum in LeaderScout, TSaga.LeaderScoutMaxRadius,
    TSaga.LeaderDefaultMaxRadius);
end;

function TLeaderParty.GetRadius: Integer;
begin
  Result := TLeaderParty.GetRadius(TLeaderParty.Leader.Enum);
  if Self.Skills.Has(skHawkEye1) then
    Result := Result + 1;
  if Self.Skills.Has(skHawkEye2) then
    Result := Result + 1;
  if Self.Skills.Has(skHawkEye3) then
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
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reGold);
          F := False;
        end;
      reMana:
        begin
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reMana);
          F := False;
        end;
      reBag:
        begin
          Game.Map.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reBag);
          F := False;
        end;
      reEnemy:
        begin
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
    TSceneSettlement.Show(stCapital);
    F := False;
  end;
  if Game.Map.LeaderTile in Cities then
  begin
    Game.MediaPlayer.PlayMusic(mmGame);
    Game.MediaPlayer.PlaySound(mmSettlement);
    TSceneSettlement.Show(stCity);
    F := False;
  end;
  if (RandomRange(0, 100) < 25) and not Leader.Skills.Has(skSpy) then
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
    Dec(Speed);
    if (Speed = 0) then
    begin
      Inc(Game.Day);
      Game.IsNewDay := True;
      Speed := MaxSpeed;
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
