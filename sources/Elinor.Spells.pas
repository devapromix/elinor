unit Elinor.Spells;

interface

uses
  Elinor.Faction,
  Elinor.Resources,
  Elinor.Spells.Types;

type
  TSpellEnum = (spNone,
    // The Empire Spellbook
    spTrueHealing, spSpeed, spBless, spLivingArmor, spEagleEye, spStrength,
    // Undead Hordes Spellbook
    spPlague, spCurse,
    // Legions of the Damned Spellbook
    spConcealment, spChainsOfDread, spWeaken
    //
    );
  // enum class SpellType
  {
    Attack,
    Lower,
    Heal,
    Boost,
    Summon,
    Fog
    Unfog,
    RestoreMove,
    Invisibility,
  }

type
  TSpell = class(TObject)
  private
    FSpellEnum: TSpellEnum;
  protected
    constructor Create(ASpellEnum: TSpellEnum);
    function IsValidTarget(const AX, AY: Integer): Boolean;
    procedure PlaySpellEffects; virtual;
    procedure ApplySpellEffect(const APartyIndex: Integer); virtual; abstract;
  public
    destructor Destroy; override;
    function CastAt(const AX, AY: Integer): Boolean; virtual;
  end;

type
  TActiveSpell = class(TObject)
  private
    FSpellEnum: TSpellEnum;
  public
    constructor Create;
    property SpellEnum: TSpellEnum read FSpellEnum;
    procedure SetActiveSpell(const ASpellEnum: TSpellEnum);
    function IsSpell: Boolean;
    procedure Clear;
  end;

type
  TSpells = class(TSpell)
  private
    FSpell: array [TSpellEnum] of TSpell;
    FLearned: array [TSpellEnum] of Boolean;
    FActiveSpell: TActiveSpell;
    procedure RegisterSpells;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Learn(const ASpellEnum: TSpellEnum);
    function IsLearned(const ASpellEnum: TSpellEnum): Boolean;
    function CastAt(const AX, AY: Integer): Boolean; override;
    property ActiveSpell: TActiveSpell read FActiveSpell write FActiveSpell;
    class function Spell(const ASpellEnum: TSpellEnum): TSpellBase; static;
  end;

  { Spells }

type
  TTrueHealingSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TSpeedSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TLivingArmorSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TPlagueSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TCurseSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TBlessSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TConcealmentSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TChainsOfDreadSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TWeakenSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type
  TEagleEyeSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

type

  TStrengthSpell = class(TSpell)
  public
    constructor Create;
  protected
    procedure ApplySpellEffect(const APartyIndex: Integer); override;
  end;

var
  Spells: TSpells;

implementation

uses
  System.SysUtils, Dialogs,
  Elinor.Saga,
  Elinor.Party,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Scenes,
  Elinor.Scene.Battle2;

type
  TSpellBaseArray = array [TSpellEnum] of TSpellBase;

const
  SpellBase: TSpellBaseArray = (
    // None
    (Name: ''; Level: 0; Mana: 0; SoundEnum: mmBlock; ResEnum: srNone;
    Faction: faNeutrals; SpellTarget: stNone; Description: '';),

    // The Empire
    // True Healing
    (Name: 'True Healing'; Level: 1; Mana: 15; SoundEnum: mmHeal;
    ResEnum: srTrueHealing; Faction: faTheEmpire; SpellTarget: stLeader;
    Description: 'Replenishes lost HP';),
    // Speed
    (Name: 'Speed'; Level: 1; Mana: 25; SoundEnum: mmHeal; ResEnum: srSpeed;
    Faction: faTheEmpire; SpellTarget: stLeader; Description: '';),
    // Bless
    (Name: 'Bless'; Level: 1; Mana: 5; SoundEnum: mmHeal; ResEnum: srBless;
    Faction: faTheEmpire; SpellTarget: stLeader; Description: '';),
    // Living Armor
    (Name: 'Living Armor'; Level: 1; Mana: 25; SoundEnum: mmAttack;
    ResEnum: srLivingArmor; Faction: faTheEmpire; SpellTarget: stEnemy;
    Description: '';),
    // Eagle Eye
    (Name: 'Eagle Eye'; Level: 1; Mana: 5; SoundEnum: mmHeal;
    ResEnum: srEagleEye; Faction: faTheEmpire; SpellTarget: stLeader;
    Description: 'Allows the leader to see further';),
    // Strength
    (Name: 'Strength'; Level: 1; Mana: 5; SoundEnum: mmHeal;
    ResEnum: srStrength; Faction: faTheEmpire; SpellTarget: stLeader;
    Description: 'Increases damage by 20%';),

    // Undead Hordes
    // Plague
    (Name: 'Plague'; Level: 1; Mana: 25; SoundEnum: mmPlague; ResEnum: srPlague;
    Faction: faUndeadHordes; SpellTarget: stEnemy; Description: '';),
    // Curse
    (Name: 'Curse'; Level: 1; Mana: 5; SoundEnum: mmPlague; ResEnum: srCurse;
    Faction: faUndeadHordes; SpellTarget: stEnemy; Description: '';),

    // Legions of the Damned
    // Concealment
    (Name: 'Concealment'; Level: 1; Mana: 20; SoundEnum: mmInvisibility;
    ResEnum: srConcealment; Faction: faLegionsOfTheDamned;
    SpellTarget: stLeader; Description: '';),
    // Chains Of Dread
    (Name: 'Chains Of Dread'; Level: 1; Mana: 2; SoundEnum: mmInvisibility;
    ResEnum: srChainsOfDread; Faction: faLegionsOfTheDamned;
    SpellTarget: stEnemy; Description: '';),
    // Weaken
    (Name: 'Weaken'; Level: 1; Mana: 2; SoundEnum: mmInvisibility;
    ResEnum: srWeaken; Faction: faLegionsOfTheDamned; SpellTarget: stEnemy;
    Description: '';)
    //
    );

  { TSpell }

function TSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  Result := False;
  LPartyIndex := PartyList.GetPartyIndex(AX, AY);
  if IsValidTarget(AX, AY) then
  begin
    Result := True;
    PlaySpellEffects;
    ApplySpellEffect(LPartyIndex);
  end;
end;

constructor TSpell.Create(ASpellEnum: TSpellEnum);
begin
  inherited Create;
  FSpellEnum := ASpellEnum;
end;

destructor TSpell.Destroy;
begin

  inherited;
end;

function TSpell.IsValidTarget(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  LPartyIndex := PartyList.GetPartyIndex(AX, AY);
  case SpellBase[FSpellEnum].SpellTarget of
    stLeader:
      Result := (LPartyIndex > 0) and
        (LPartyIndex = TLeaderParty.LeaderPartyIndex);
    stEnemy:
      Result := (LPartyIndex > 0) and
        (LPartyIndex <> TLeaderParty.LeaderPartyIndex);
  else
    Result := False;
  end;
end;

procedure TSpell.PlaySpellEffects;
begin
  if Game.Wizard then
    ShowMessage('Spell: ' + SpellBase[FSpellEnum].Name);
  Game.MediaPlayer.PlaySound(SpellBase[FSpellEnum].SoundEnum);
end;

{ TCurrentSpell }

procedure TActiveSpell.Clear;
begin
  Game.MediaPlayer.PlaySound(mmDispell);
  FSpellEnum := spNone;
end;

constructor TActiveSpell.Create;
begin
  FSpellEnum := spNone;
end;

function TActiveSpell.IsSpell: Boolean;
begin
  Result := FSpellEnum <> spNone;
end;

procedure TActiveSpell.SetActiveSpell(const ASpellEnum: TSpellEnum);
begin
  FSpellEnum := ASpellEnum;
end;

{ TSpells }

function TSpells.CastAt(const AX, AY: Integer): Boolean;
begin
  inherited;
  if not ActiveSpell.IsSpell then
    Exit;
  Result := FSpell[ActiveSpell.SpellEnum].CastAt(AX, AY);
  if Result then
    ActiveSpell.Clear;
end;

procedure TSpells.Clear;
var
  LSpellEnum: TSpellEnum;
begin
  for LSpellEnum := Succ(Low(TSpellEnum)) to High(TSpellEnum) do
    FLearned[LSpellEnum] := False;
end;

constructor TSpells.Create;
begin
  inherited Create(spNone);
  FActiveSpell := TActiveSpell.Create;
  RegisterSpells;
end;

destructor TSpells.Destroy;
var
  LSpellEnum: TSpellEnum;
begin
  for LSpellEnum := Succ(Low(TSpellEnum)) to High(TSpellEnum) do
    FreeAndNil(FSpell[LSpellEnum]);
  FreeAndNil(FActiveSpell);
  inherited;
end;

function TSpells.IsLearned(const ASpellEnum: TSpellEnum): Boolean;
begin
  Result := FLearned[ASpellEnum];
end;

procedure TSpells.Learn(const ASpellEnum: TSpellEnum);
begin
  if not FLearned[ASpellEnum] then
  begin
    FLearned[ASpellEnum] := True;
    Game.MediaPlayer.PlaySound(mmDispell);
  end
end;

class function TSpells.Spell(const ASpellEnum: TSpellEnum): TSpellBase;
begin
  Result := SpellBase[ASpellEnum];
end;

procedure TSpells.RegisterSpells;
begin
  FSpell[spTrueHealing] := TTrueHealingSpell.Create;
  FSpell[spSpeed] := TSpeedSpell.Create;
  FSpell[spBless] := TBlessSpell.Create;
  FSpell[spLivingArmor] := TLivingArmorSpell.Create;
  FSpell[spPlague] := TPlagueSpell.Create;
  FSpell[spCurse] := TCurseSpell.Create;
  FSpell[spConcealment] := TConcealmentSpell.Create;
  FSpell[spChainsOfDread] := TChainsOfDreadSpell.Create;
  FSpell[spWeaken] := TWeakenSpell.Create;
  FSpell[spEagleEye] := TEagleEyeSpell.Create;
  FSpell[spStrength] := TStrengthSpell.Create;
end;

{ TTrueHealingSpell }

procedure TTrueHealingSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  PartyList.Party[APartyIndex].HealParty(25);
end;

constructor TTrueHealingSpell.Create;
begin
  inherited Create(spTrueHealing);
end;

{ TSpeedSpell }

procedure TSpeedSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  TLeaderParty.Leader.SetMaxMovementPoints;
end;

constructor TSpeedSpell.Create;
begin
  inherited Create(spSpeed);
end;

{ TLivingArmorSpell }

procedure TLivingArmorSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  TSceneBattle2.SummonCreature(APartyIndex, crGoblin);
end;

constructor TLivingArmorSpell.Create;
begin
  inherited Create(spLivingArmor);
end;

{ TPlagueSpell }

procedure TPlagueSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  PartyList.Party[APartyIndex].TakeDamageAll(35);
end;

constructor TPlagueSpell.Create;
begin
  inherited Create(spPlague);
end;

{ TConcealmentSpell }

procedure TConcealmentSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  TLeaderParty.Leader.Invisibility := True;
end;

constructor TConcealmentSpell.Create;
begin
  inherited Create(spConcealment);
end;

{ TChainsOfDreadSpell }

procedure TChainsOfDreadSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  PartyList.Party[APartyIndex].ParalyzeParty;
end;

constructor TChainsOfDreadSpell.Create;
begin
  inherited Create(spChainsOfDread);
end;

{ TCurseSpell }

procedure TCurseSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  PartyList.Party[APartyIndex].ModifyPartyChancesToHit(-15);
end;

constructor TCurseSpell.Create;
begin
  inherited Create(spCurse);
end;

{ TBlessSpell }

procedure TBlessSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  PartyList.Party[APartyIndex].ModifyPartyChancesToHit(15);
end;

constructor TBlessSpell.Create;
begin
  inherited Create(spBless);
end;

{ TWeakenSpell }

procedure TWeakenSpell.ApplySpellEffect(const APartyIndex: Integer);
begin
  PartyList.Party[APartyIndex].ModifyPartyDamage(10);
end;

constructor TWeakenSpell.Create;
begin
  inherited Create(spWeaken);
end;

{ TEagleEyeSpell }

procedure TEagleEyeSpell.ApplySpellEffect(const APartyIndex: Integer);
begin

end;

constructor TEagleEyeSpell.Create;
begin
  inherited Create(spEagleEye);
end;

{ TStrengthSpell }

procedure TStrengthSpell.ApplySpellEffect(const APartyIndex: Integer);
begin

end;

constructor TStrengthSpell.Create;
begin
  inherited Create(spStrength);
end;

initialization

Spells := TSpells.Create;

finalization

FreeAndNil(Spells);

end.
