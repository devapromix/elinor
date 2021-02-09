unit DisciplesRL.Party;

interface

uses
{$IFDEF FPC}
  Types,
{$ELSE}
  System.Types,
{$ENDIF}
  DisciplesRL.Creatures,
  MapObject;

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
  TParty = class(TMapObject)
  strict private
    FOwner: TRaceEnum;
    FCreature: array [TPosition] of TCreature;
    function GetCreature(APosition: TPosition): TCreature;
    procedure SetCreature(APosition: TPosition; const Value: TCreature);
    function GetCount: Integer;
  public
    constructor Create(const AX, AY: Integer); overload;
    constructor Create(const AX, AY: Integer; AOwner: TRaceEnum); overload;
    destructor Destroy; override;
    procedure AddCreature(const ACreatureEnum: TCreatureEnum;
      const APosition: TPosition);
    property Owner: TRaceEnum read FOwner write FOwner;
    property Creature[APosition: TPosition]: TCreature read GetCreature
      write SetCreature;
    procedure SetHitPoints(const APosition: TPosition;
      const AHitPoints: Integer);
    function GetHitPoints(const APosition: TPosition): Integer;
    procedure SetState(const APosition: TPosition; const Flag: Boolean);
    procedure Clear;
    function IsClear: Boolean;
    function Hire(const ACreatureEnum: TCreatureEnum;
      const APosition: TPosition): Boolean;
    procedure Dismiss(const APosition: TPosition);
    procedure Heal(const APosition: TPosition); overload;
    procedure Heal(const APosition: TPosition;
      const AHitPoints: Integer); overload;
    procedure Revive(const APosition: TPosition);
    procedure UpdateHP(const AHitPoints: Integer; const APosition: TPosition);
    procedure UpdateXP(const AExperience: Integer; const APosition: TPosition);
    procedure UpdateLevel(const APosition: TPosition); virtual;
    procedure TakeDamage(const ADamage: Integer; const APosition: TPosition);
    procedure Swap(Party: TParty; A, B: Integer); overload;
    procedure Swap(A, B: Integer); overload;
    property Count: Integer read GetCount;
    procedure ChPosition(Party: TParty; const ActPosition: Integer;
      var CurPosition: Integer);
    function GetMaxExperience(const Level: Integer): Integer;
  end;

type
  TLeaderParty = class(TParty)
  private
    FMaxLeadership: Integer;
    FRadius: Integer;
  public
  class var
    LeaderPartyIndex: Byte;
    CapitalPartyIndex: Byte;
    Speed: Integer;
    MaxSpeed: Integer;
    constructor Create(const AX, AY: Integer; AOwner: TRaceEnum);
    destructor Destroy; override;
    procedure Clear;
    property MaxLeadership: Integer read FMaxLeadership;
    property Radius: Integer read FRadius;
    procedure UpdateRadius;
    procedure Turn(const ACount: Integer = 1);
    procedure ChCityOwner;
    procedure UpdateLevel(const APosition: TPosition); override;
    class function Leader: TLeaderParty;
    class procedure Move(const AX, AY: ShortInt); overload;
    class procedure Move(Dir: TDirectionEnum); overload;
    class procedure PutAt(const AX, AY: ShortInt;
      const IsInfo: Boolean = False);
  end;

var
  Party: array of TParty;

implementation

uses
{$IFDEF FPC}
  Math,
  DisciplesRL.Map,
  DisciplesRL.Saga,
  DisciplesRL.Scene,
  DisciplesRL.Resources;
{$ELSE}
  System.Math,
  DisciplesRL.Map,
  DisciplesRL.Saga,
  DisciplesRL.Resources,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Settlement;
{$ENDIF}
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
  I: TPosition;
begin
  Result := False;
  for I := Low(TPosition) to High(TPosition) do
    if (Creature[I].HitPoints > 0) then
      Exit;
  Result := True;
end;

procedure TParty.Clear;
var
  I: TPosition;
begin
  for I := Low(TPosition) to High(TPosition) do
    TCreature.Clear(FCreature[I]);
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

function TParty.GetHitPoints(const APosition: TPosition): Integer;
begin
  Result := FCreature[APosition].HitPoints;
end;

function TParty.GetMaxExperience(const Level: Integer): Integer;
begin
  Result := Level * 250;
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

procedure TParty.Heal(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if (Active and (HitPoints > 0)) then
      HitPoints := MaxHitPoints;
end;

procedure TParty.Heal(const APosition: TPosition; const AHitPoints: Integer);
begin
  with FCreature[APosition] do
    if (Active and (HitPoints > 0)) then
      HitPoints := EnsureRange(HitPoints + AHitPoints, 0, MaxHitPoints);
end;

function TParty.Hire(const ACreatureEnum: TCreatureEnum;
  const APosition: TPosition): Boolean;
var
  ACreature: TCreatureBase;
begin
  Result := False;
  ACreature := TCreature.Character(ACreatureEnum);
  if ACreature.Gold > TSaga.Gold then
    Exit;
  if not FCreature[APosition].Active then
  begin
    Result := True;
    AddCreature(ACreatureEnum, APosition);
    TSaga.ModifyGold(-ACreature.Gold);
  end;
end;

procedure TParty.Revive(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if (Active and (HitPoints <= 0)) then
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
  with FCreature[APosition] do
    if Active then
    begin
      if (HitPoints > 0) then
        if (ADamage - Armor > 0) then
          HitPoints := HitPoints - (ADamage - Armor);
      if (HitPoints < 0) then
        HitPoints := 0;
    end;
end;

procedure TParty.UpdateHP(const AHitPoints: Integer;
  const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Active then
      if (HitPoints > 0) then
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
    MaxHitPoints := MaxHitPoints + (MaxHitPoints div 10);
    HitPoints := MaxHitPoints;
    Initiative := EnsureRange(Initiative + 1, 10, 100);
    ChancesToHit := EnsureRange(ChancesToHit + 1, 10, 100);
    Damage := Damage + (Damage div 10);
    Level := Level + 1;
  end;
end;

procedure TParty.UpdateXP(const AExperience: Integer;
  const APosition: TPosition);
begin
  with FCreature[APosition] do
    if Active then
      if (HitPoints > 0) then
        if (AExperience > 0) then
          Experience := Experience + AExperience;
end;

{ TLeaderParty }

procedure TLeaderParty.ChCityOwner;
begin
{$IFDEF FPC}
  case Party[LeaderPartyIndex].Owner of
    reTheEmpire:
      Game.Map.SetTile(lrTile, X, Y, reTheEmpireCity);
    reUndeadHordes:
      Game.Map.SetTile(lrTile, X, Y, reUndeadHordesCity);
    reLegionsOfTheDamned:
      Game.Map.SetTile(lrTile, X, Y, reLegionsOfTheDamnedCity);
  end;
{$ELSE}
  case Party[LeaderPartyIndex].Owner of
    reTheEmpire:
      TMap.SetTile(lrTile, X, Y, reTheEmpireCity);
    reUndeadHordes:
      TMap.SetTile(lrTile, X, Y, reUndeadHordesCity);
    reLegionsOfTheDamned:
      TMap.SetTile(lrTile, X, Y, reLegionsOfTheDamnedCity);
  end;
{$ENDIF}
end;

procedure TLeaderParty.Clear;
begin
  MaxSpeed := 7;
  Speed := MaxSpeed;
  FMaxLeadership := 1;
  FRadius := IfThen(TSaga.Wizard, 9, 1);
  Self.UpdateRadius;
end;

constructor TLeaderParty.Create(const AX, AY: Integer; AOwner: TRaceEnum);
begin
  inherited Create(AX, AY, AOwner);
  FMaxLeadership := 1;
  FRadius := 1;
end;

destructor TLeaderParty.Destroy;
begin

  inherited;
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
{$IFDEF FPC}
  if not Game.Map.InMap(AX, AY) then
    Exit;
  if (Game.Map.GetTile(lrObj, AX, AY) in StopTiles) then
    Exit;
{$ELSE}
  if not TMap.InMap(AX, AY) then
    Exit;
  if (TMap.GetTile(lrObj, AX, AY) in StopTiles) then
    Exit;
  if not IsInfo then
    for I := 0 to High(TMap.Place) do
    begin
      if (TMap.Place[I].Owner in Races) then
        if (TMap.Place[I].CurLevel < TMap.Place[I].MaxLevel) then
        begin
          Inc(TMap.Place[I].CurLevel);
          TPlace.UpdateRadius(I);
        end;
    end;
  if IsInfo then
  begin
    if TMap.GetTile(lrTile, AX, AY) in Capitals then
    begin
      DisciplesRL.Scene.Party.Show(Party[CapitalPartyIndex], scMap);
      Exit;
    end;
    if TMap.GetTile(lrTile, AX, AY) in Cities then
    begin
      I := TSaga.GetPartyIndex(AX, AY);
      if not Party[I].IsClear then
        DisciplesRL.Scene.Party.Show(Party[I], scMap);
      Exit;
    end;
    case TMap.GetTile(lrObj, AX, AY) of
      reEnemy:
        begin
          I := TSaga.GetPartyIndex(AX, AY);
          DisciplesRL.Scene.Party.Show(Party[I], scMap);
        end;
    end;
    Exit;
  end
  else
  begin
    Leader.SetLocation(AX, AY);
    with TLeaderParty(Party[LeaderPartyIndex]) do
    begin
      SetLocation(AX, AY);
      UpdateRadius;
      Turn(1);
    end;
    F := True;
    case TMap.GetTile(lrObj, Leader.X, Leader.Y) of
      reGold:
        begin
          TMap.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reGold);
          F := False;
        end;
      reMana:
        begin
          TMap.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reMana);
          F := False;
        end;
      reBag:
        begin
          TMap.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          TSaga.AddLoot(reBag);
          F := False;
        end;
      reEnemy:
        begin
          DisciplesRL.Scene.Battle2.Start;
          SetSceneMusic(scBattle2);
          SetScene(scBattle2);
          TMap.SetTile(lrObj, Leader.X, Leader.Y, reNone);
          F := False;
          Exit;
        end;
    end;
  end;
  case TMap.LeaderTile of
    reNeutralCity:
      begin
        TLeaderParty.Leader.ChCityOwner;
        TPlace.UpdateRadius(TPlace.GetIndex(Leader.X, Leader.Y));
        F := False;
      end;
  end;
  if TMap.LeaderTile in Capitals then
  begin
    SetSceneMusic(scSettlement);
    DisciplesRL.Scene.Settlement.Show(stCapital);
    F := False;
  end;
  if TMap.LeaderTile in Cities then
  begin
    SetSceneMusic(scSettlement);
    DisciplesRL.Scene.Settlement.Show(stCity);
    F := False;
  end;
  if F then
    TSaga.NewDay;
{$ENDIF}
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
      Inc(TSaga.Days);
      TSaga.IsDay := True;
      Speed := MaxSpeed;
    end;
    Inc(C);
  until (C >= ACount);
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
{$IFDEF FPC}
{$ELSE}
  TMap.UpdateRadius(Self.X, Self.Y, Self.Radius, TMap.Map[lrDark], reNone);
{$ENDIF}
end;

end.
