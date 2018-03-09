unit DisciplesRL.Party;

interface

uses DisciplesRL.Creatures;

type
  TRaceEnum = (reEmpire, reNeutrals);

type
  TPosition = 0 .. 5;

type
  TParty = class(TObject)
  private
    FX, FY: Integer;
    FOwner: TRaceEnum;
    FCreature: array [TPosition] of TCreature;
    function GetCreature(APosition: TPosition): TCreature;
    procedure SetCreature(APosition: TPosition; const Value: TCreature);
  public
    constructor Create(const AX, AY: Integer);
    destructor Destroy; override;
    procedure AddCreature(const ACreatureEnum: TCreatureEnum; const APosition: TPosition);
    property X: Integer read FX;
    property Y: Integer read FY;
    property Owner: TRaceEnum read FOwner write FOwner;
    property Creature[APosition: TPosition]: TCreature read GetCreature write SetCreature;
    procedure Clear;
    function Hire(const ACreatureEnum: TCreatureEnum; const APosition: TPosition): Boolean;
    procedure Dismiss(const APosition: TPosition);
    procedure SetPoint(const AX, AY: Integer);
    procedure Heal(const APosition: TPosition);
    procedure Revive(const APosition: TPosition);
    procedure UpdateHP(const AHitPoints: Integer; const APosition: TPosition);
    procedure TakeDamage(const ADamage: Integer; const APosition: TPosition);
  end;

implementation

{ TParty }

procedure TParty.AddCreature(const ACreatureEnum: TCreatureEnum; const APosition: TPosition);
begin
  AssignCreature(FCreature[APosition], ACreatureEnum);
end;

procedure TParty.Clear;
var
  I: TPosition;
begin
  for I := Low(TPosition) to High(TPosition) do
    ClearCreature(FCreature[I]);
end;

constructor TParty.Create(const AX, AY: Integer);
begin
  FX := AX;
  FY := AY;
  Self.Clear;
  Owner := reNeutrals;
end;

destructor TParty.Destroy;
begin

  inherited;
end;

procedure TParty.Dismiss(const APosition: TPosition);
begin
  ClearCreature(FCreature[APosition])
end;

function TParty.GetCreature(APosition: TPosition): TCreature;
begin
  Result := FCreature[APosition]
end;

procedure TParty.Heal(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if (Active and (HitPoints > 0)) then
      HitPoints := MaxHitPoints;
end;

function TParty.Hire(const ACreatureEnum: TCreatureEnum; const APosition: TPosition): Boolean;
begin
  Result := False;
  if not FCreature[APosition].Active then
  begin
    Result := True;
    AddCreature(ACreatureEnum, APosition);
  end;
end;

procedure TParty.Revive(const APosition: TPosition);
begin
  with FCreature[APosition] do
    if (Active and (HitPoints = 0)) then
      HitPoints := 1;
end;

procedure TParty.SetCreature(APosition: TPosition; const Value: TCreature);
begin
  FCreature[APosition] := Value;
end;

procedure TParty.SetPoint(const AX, AY: Integer);
begin
  FX := AX;
  FY := AY;
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

procedure TParty.UpdateHP(const AHitPoints: Integer; const APosition: TPosition);
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

end.
