unit DisciplesRL.Party;

interface

uses
  Types,
  DisciplesRL.Creatures,
  DisciplesRL.Skills,
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
    FOwner: TRaceEnum;
    FCreature: array [TPosition] of TCreature;
    function GetCreature(APosition: TPosition): TCreature;
    procedure SetCreature(APosition: TPosition; const Value: TCreature);
    function GetCount: Integer;
  private
  public
    constructor Create(const AX, AY: Integer); overload;
    constructor Create(const AX, AY: Integer; AOwner: TRaceEnum); overload;
    destructor Destroy; override;
    procedure MoveCreature(FromParty: TParty; const APosition: TPosition);
    procedure AddCreature(const ACreatureEnum: TCreatureEnum;
      const APosition: TPosition);
    property Owner: TRaceEnum read FOwner write FOwner;
    procedure ClearParalyze(const APosition: TPosition);
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
  end;

type

  { TLeaderParty }

  TLeaderParty = class(TParty)
  private
    FMaxLeadership: Integer;
    FRadius: Integer;
    FSpells: Integer;
    FSpy: Integer;
    FSkills: TSkills;
    function GetRadius: Integer;
  public
  class var
    LeaderPartyIndex: Byte;
    CapitalPartyIndex: Byte;
    Speed: Integer;
    MaxSpeed: Integer;
  public
    constructor Create(const AX, AY: Integer; AOwner: TRaceEnum);
    destructor Destroy; override;
    procedure Clear;
    property MaxLeadership: Integer read FMaxLeadership;
    property Radius: Integer read GetRadius;
    property Spells: Integer read FSpells write FSpells;
    property Spy: Integer read FSpy write FSpy;
    procedure UpdateRadius;
    procedure Turn(const ACount: Integer = 1);
    procedure ChCityOwner;
    procedure UpdateLevel(const APosition: TPosition); override;
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
    function GetMaxSpells: Integer;
    function IsPartyOwner(const AX, AY: Integer): Boolean;
    property Skills: TSkills read FSkills write FSkills;
  end;

var
  Party: array of TParty;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.Resources,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Settlement;

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

procedure TParty.Clear;
var
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
    TCreature.Clear(FCreature[Position]);
end;

constructor TParty.Create(const AX, AY: Integer; AOwner: TRaceEnum);
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
  Position: TPosition;
begin
  Result := 0;
  for Position := Low(TPosition) to High(TPosition) do
    with Creature[Position] do
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
  Position: TPosition;
begin
  Result := -1;
  for Position := Low(TPosition) to High(TPosition) do
    with FCreature[Position] do
      if Active then
        Inc(Result);
end;

function TParty.GetAliveCreatures: Integer;
var
  Position: TPosition;
begin
  Result := 0;
  for Position := Low(TPosition) to High(TPosition) do
    with FCreature[Position] do
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
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
    Heal(Position, AHitPoints);
end;

function TParty.Hire(const ACreatureEnum: TCreatureEnum;
  const APosition: TPosition): Boolean;
var
  ACreature: TCreatureBase;
begin
  Result := False;
  ACreature := TCreature.Character(ACreatureEnum);
  if ACreature.Gold > Game.Gold.Value then
    Exit;
  if not FCreature[APosition].Active then
  begin
    Result := True;
    AddCreature(ACreatureEnum, APosition);
    Game.Gold.Modify(-ACreature.Gold);
  end;
end;

procedure TParty.Revive(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Alive then
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
  Cr: TCreature;
begin
  if (Party.Creature[B].Leadership > 0) or (Creature[A].Leadership > 0) or
    (Party = nil) then
    Exit;
  Cr := Party.Creature[B];
  Party.Creature[B] := FCreature[A];
  FCreature[A] := Cr;
end;

procedure TParty.Swap(A, B: Integer);
var
  Cr: TCreature;
begin
  Cr := FCreature[B];
  FCreature[B] := FCreature[A];
  FCreature[A] := Cr;
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
          Game.MediaPlayer.Play(mmBlock);
      if (HitPoints < 0) then
        HitPoints := 0;
    end;
end;

procedure TParty.TakeDamageAll(const ADamage: Integer);
var
  Position: TPosition;
begin
  for Position := Low(TPosition) to High(TPosition) do
    TakeDamage(ADamage, Position);
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
    Experience := 0;
    Game.MediaPlayer.Play(mmLevel);
    MaxHitPoints := MaxHitPoints + (MaxHitPoints div 10);
    HitPoints := MaxHitPoints;
    Initiative := EnsureRange(Initiative + 1, 10, 100);
    ChancesToHit := EnsureRange(ChancesToHit + 1, 10, 100);
    if Damage > 0 then
      Damage := Damage + (Damage div 10);
    if Heal > 0 then
      Heal := Heal + (Heal div 15);
    Level := Level + 1;
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
  MaxSpeed := 7;
  Speed := MaxSpeed;
  FMaxLeadership := 1;
  FRadius := IfThen(Game.Wizard, 9, 1);
  FSpells := GetMaxSpells;
  FSpy := GetMaxSpy;
  Self.UpdateRadius;
end;

constructor TLeaderParty.Create(const AX, AY: Integer; AOwner: TRaceEnum);
begin
  inherited Create(AX, AY, AOwner);
  FSkills := TSkills.Create;
  FMaxLeadership := 1;
  FRadius := 1;
end;

destructor TLeaderParty.Destroy;
begin
  FreeAndNil(FSkills);
  inherited;
end;

function TLeaderParty.Enum: TCreatureEnum;
begin
  Result := TLeaderParty.Leader.Creature[TLeaderParty.GetPosition].Enum;
end;

function TLeaderParty.Level: Integer;
begin
  Result := TLeaderParty.Leader.Creature[TLeaderParty.GetPosition].Level;
end;

function TLeaderParty.GetMaxSpells: Integer;
begin
  Result := IfThen(TLeaderParty.Leader.Enum in LeaderMage,
    TSaga.LeaderMageCanCastSpellsPerDay, 1);
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

function TLeaderParty.GetRadius: Integer;
begin
  Result := IfThen(TLeaderParty.Leader.Enum in LeaderScout,
    FRadius + TSaga.LeaderScoutAdvRadius, FRadius);
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
  I: Integer;
  F: Boolean;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  if (Game.Map.GetTile(lrObj, AX, AY) in StopTiles) then
    Exit;
  if not IsInfo then
    for I := 0 to High(Game.Map.MapPlace) do
    begin
      if (Game.Map.MapPlace[I].Owner in Races) then
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
    Game.MediaPlayer.Play(mmStep);
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
    Game.MediaPlayer.Play(mmSettlement);
    TSceneSettlement.Show(stCapital);
    F := False;
  end;
  if Game.Map.LeaderTile in Cities then
  begin
    Game.MediaPlayer.PlayMusic(mmGame);
    Game.MediaPlayer.Play(mmSettlement);
    TSceneSettlement.Show(stCity);
    F := False;
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
  C: Integer;
begin
  if (ACount < 1) then
    Exit;
  C := 0;
  repeat
    Dec(Speed);
    if (Speed = 0) then
    begin
      Inc(Game.Day);
      Game.IsNewDay := True;
      Speed := MaxSpeed;
    end;
    Inc(C);
  until (C >= ACount);
  Game.ShowNewDayMessageTime := 0;
end;

procedure TLeaderParty.UpdateLevel(const APosition: TPosition);
begin
  inherited;
  with Creature[APosition] do
    if IsLeader and (Level mod 3 = 0) then
      Inc(FMaxLeadership);
end;

procedure TLeaderParty.UpdateRadius;
begin
  Game.Map.UpdateRadius(Self.X, Self.Y, Self.Radius,
    Game.Map.GetLayer(lrDark), reNone);
end;

end.
