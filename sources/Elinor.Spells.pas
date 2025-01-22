﻿unit Elinor.Spells;

interface

uses
  Elinor.Factions,
  Elinor.Resources,
  Elinor.Spells.Types;

type
  TSpellEnum = (spNone,
    // The Empire Spellbook
    spTrueHealing, spSpeed, spLivingArmor,
    // Undead Hordes Spellbook
    spPlague,
    // Legions of the Damned Spellbook
    spConcealment
    //
    );
  // enum class SpellType
  {
    Attack,
    Lower,
    Heal,
    Boost,
    Summon,
    Fog = 6,
    Unfog,
    RestoreMove,
    Invisibility,
    RemoveRod,
    ChangeTerrain,
    GiveWards,
  }

type
  TSpell = class(TObject)
  private
    FSpellEnum: TSpellEnum;
  protected
    constructor Create(ASpellEnum: TSpellEnum);
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
    FActiveSpell: TActiveSpell;
  public
    constructor Create;
    destructor Destroy; override;
    function CastAt(const AX, AY: Integer): Boolean; override;
    property ActiveSpell: TActiveSpell read FActiveSpell write FActiveSpell;
    class function Spell(const ASpellEnum: TSpellEnum): TSpellBase; static;
  end;

  { Spells }

type
  TTrueHealingSpell = class(TSpell)
    constructor Create;
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

type
  TSpeedSpell = class(TSpell)
    constructor Create;
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

type
  TLivingArmorSpell = class(TSpell)
    constructor Create;
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

type
  TPlagueSpell = class(TSpell)
    constructor Create;
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

type
  TConcealmentSpell = class(TSpell)
    constructor Create;
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

var
  Spells: TSpells;

implementation

uses
  System.SysUtils, Dialogs,
  Elinor.Saga,
  Elinor.Party,
  Elinor.Creatures,
  Elinor.Scenes;

type
  TSpellBaseArray = array [TSpellEnum] of TSpellBase;

const
  SpellBase: TSpellBaseArray = (
    // None
    (Name: ''; Level: 0; Mana: 0; SoundEnum: mmBlock; ResEnum: reNone;
    Faction: faNeutrals),
    // True Healing
    (Name: 'True Healing'; Level: 1; Mana: 15; SoundEnum: mmHeal;
    ResEnum: reTrueHealing; Faction: faTheEmpire),
    // Speed
    (Name: 'Speed'; Level: 1; Mana: 25; SoundEnum: mmHeal; ResEnum: reSpeed;
    Faction: faTheEmpire),
    // Living Armor
    (Name: 'Living Armor'; Level: 1; Mana: 25; SoundEnum: mmAttack;
    ResEnum: reLivingArmor; Faction: faTheEmpire),
    // Plague
    (Name: 'Plague'; Level: 1; Mana: 25; SoundEnum: mmPlague; ResEnum: rePlague;
    Faction: faUndeadHordes),
    // Concealment
    (Name: 'Concealment'; Level: 1; Mana: 20; SoundEnum: mmInvisibility;
    ResEnum: reConcealment; Faction: faLegionsOfTheDamned)
    //
    );

  { TSpell }

function TSpell.CastAt(const AX, AY: Integer): Boolean;
begin
  Result := False;
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

constructor TSpells.Create;
begin
  inherited Create(spNone);
  FActiveSpell := TActiveSpell.Create;
  FSpell[spTrueHealing] := TTrueHealingSpell.Create;
  FSpell[spSpeed] := TSpeedSpell.Create;
  FSpell[spLivingArmor] := TLivingArmorSpell.Create;
  FSpell[spPlague] := TPlagueSpell.Create;
  FSpell[spConcealment] := TConcealmentSpell.Create;
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

class function TSpells.Spell(const ASpellEnum: TSpellEnum): TSpellBase;
begin
  Result := SpellBase[ASpellEnum];
end;

{ TTrueHealingSpell }

function TTrueHealingSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex = TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('True Healing');
    Game.MediaPlayer.PlaySound(SpellBase[FSpellEnum].SoundEnum);
    Party[LPartyIndex].HealAll(25);
  end;
end;

constructor TTrueHealingSpell.Create;
begin
  inherited Create(spTrueHealing);
end;

{ TSpeedSpell }

function TSpeedSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex = TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('Speed');
    Game.MediaPlayer.PlaySound(SpellBase[FSpellEnum].SoundEnum);
    TLeaderParty.Leader.SetMaxMovementPoints;
  end;
end;

constructor TSpeedSpell.Create;
begin
  inherited Create(spSpeed);
end;

{ TLivingArmorSpell }

function TLivingArmorSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex <> TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('Living Armor');
    Game.MediaPlayer.PlaySound(SpellBase[FSpellEnum].SoundEnum);
    Game.Show(scBattle);
  end;
end;

constructor TLivingArmorSpell.Create;
begin
  inherited Create(spLivingArmor);
end;

{ TPlagueSpell }

function TPlagueSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex <> TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('Plague');
    Game.MediaPlayer.PlaySound(SpellBase[FSpellEnum].SoundEnum);
    Party[LPartyIndex].TakeDamageAll(35);
  end;
end;

constructor TPlagueSpell.Create;
begin
  inherited Create(spPlague);
end;

{ TConcealmentSpell }

function TConcealmentSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex = TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('Concealment');
    Game.MediaPlayer.PlaySound(SpellBase[FSpellEnum].SoundEnum);
    TLeaderParty.Leader.Invisibility := True;
  end;
end;

constructor TConcealmentSpell.Create;
begin
  inherited Create(spConcealment);
end;

initialization

Spells := TSpells.Create;

finalization

FreeAndNil(Spells);

end.
