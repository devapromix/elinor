unit Elinor.Ability;

interface

uses
  Elinor.Creature.Types,
  Elinor.Resources;

type
  TAbilityEnum = (abNone, abFlying, abStrength, abMight, abStealth, abSharpEye,
    abHawkEye, abFarSight, abArtifactLore, abBannerBearer, abTravelLore,
    abLeadership1, abLeadership2, abLeadership3, abLeadership4,
    abUseStaffsAndScrolls, abAccuracy, abPathfinding, abAdvancedPathfinding,
    abDealmaker, abHaggler, abNaturalArmor, abArcanePower, abWeaponMaster,
    abArcaneKnowledge, abArcaneLore, abSorcery, abTemplar, abMountaineering,
    abForestry, abDoragorPower, abVampirism, abNaturalHealing, abLogistics);

type
  TAbility = record
    Enum: TAbilityEnum;
    Name: string;
    Description: array [0 .. 1] of string;
    Level: Byte;
    Leaders: set of TCreatureEnum;
    ResEnum: TAbilityResEnum;
  end;

const
  CMaxAbilities = 12;

type
  TAbilities = class(TObject)
  private
    FAbility: array [0 .. CMaxAbilities - 1] of TAbility;
  public
    RandomAbilityEnum: array [0 .. 5] of TAbilityEnum;
    constructor Create;
    destructor Destroy; override;
    function IsAbility(const AAbilityEnum: TAbilityEnum): Boolean;
    procedure Add(const AAbilityEnum: TAbilityEnum);
    function GetEnum(const I: Integer): TAbilityEnum;
    procedure GenRandomList;
    procedure Clear;
    class function Ability(const A: TAbilityEnum): TAbility; static;
    class function IsAbilityLeadership(const AAbilityEnum: TAbilityEnum)
      : Boolean; static;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Ability.Base,
  Elinor.Party;

class function TAbilities.Ability(const A: TAbilityEnum): TAbility;
begin
  Result := AbilityBase[A];
end;

class function TAbilities.IsAbilityLeadership(const AAbilityEnum
  : TAbilityEnum): Boolean;
begin
  Result := (AAbilityEnum = abLeadership1) or (AAbilityEnum = abLeadership2) or
    (AAbilityEnum = abLeadership3) or (AAbilityEnum = abLeadership4);
end;

procedure TAbilities.Add(const AAbilityEnum: TAbilityEnum);
var
  I: Integer;
begin
  for I := 0 to CMaxAbilities - 1 do
    if (FAbility[I].Enum = abNone) then
    begin
      FAbility[I] := AbilityBase[AAbilityEnum];
      Exit;
    end;
end;

procedure TAbilities.Clear;
var
  I: Integer;
begin
  for I := 0 to CMaxAbilities - 1 do
    FAbility[I] := AbilityBase[abNone];
end;

constructor TAbilities.Create;
begin
  Self.Clear;
end;

destructor TAbilities.Destroy;
begin

  inherited;
end;

procedure TAbilities.GenRandomList;
var
  I: Integer;
  LAbilityEnum: TAbilityEnum;

  procedure ClearRandomAbilities;
  var
    I: Integer;
  begin
    for I := 0 to 5 do
      RandomAbilityEnum[I] := abNone;
  end;

  function GetRandomAbility: TAbilityEnum;
  begin
    Result := TAbilityEnum(RandomRange(Ord(Succ(Low(TAbilityEnum))),
      Ord(High(TAbilityEnum))));
  end;

  function CheckAbilityLevel(const AAbilityEnum: TAbilityEnum): Boolean;
  begin
    Result := (AbilityBase[AAbilityEnum].Level <= TLeaderParty.Leader.Level);
  end;

  function IsRandomAbility(const AAbilityEnum: TAbilityEnum): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to 5 do
      if AAbilityEnum = RandomAbilityEnum[I] then
      begin
        Result := True;
        Exit;
      end;
  end;

begin
  ClearRandomAbilities;
  for I := 0 to 5 do
  begin
    repeat
      LAbilityEnum := GetRandomAbility;
    until not IsAbility(LAbilityEnum) and not IsRandomAbility(LAbilityEnum) and
      CheckAbilityLevel(LAbilityEnum) and
      (TLeaderParty.Leader.Enum in AbilityBase[LAbilityEnum].Leaders);
    RandomAbilityEnum[I] := LAbilityEnum;
  end;
end;

function TAbilities.GetEnum(const I: Integer): TAbilityEnum;
begin
  Result := FAbility[I].Enum;
end;

function TAbilities.IsAbility(const AAbilityEnum: TAbilityEnum): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CMaxAbilities - 1 do
    if FAbility[I].Enum = AAbilityEnum then
    begin
      Result := True;
      Exit;
    end;
end;

end.
