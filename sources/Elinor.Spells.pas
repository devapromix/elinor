unit Elinor.Spells;

interface

type
  TSpellEnum = (spNone, spTrueHealing);

type
  TSpell = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
    function CastAt(const AX, AY: Integer): Boolean; virtual;
  end;

type
  TSpells = class(TSpell)
  private
    FSpell: array [TSpellEnum] of TSpell;
    FCurrent: TSpellEnum;
  public
    constructor Create;
    destructor Destroy; override;
    function CastAt(const AX, AY: Integer): Boolean; override;
    property Current: TSpellEnum read FCurrent write FCurrent;
  end;

type
  TTrueHealingSpell = class(TSpell)
    constructor Create;
    destructor Destroy; override;
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

var
  Spells: TSpells;

implementation

uses
  System.SysUtils, Dialogs,
  Elinor.Saga,
  Elinor.Party;

{ TSpell }

function TSpell.CastAt(const AX, AY: Integer): Boolean;
begin
  Result := False;
end;

constructor TSpell.Create;
begin

end;

destructor TSpell.Destroy;
begin

  inherited;
end;

{ TSpells }

function TSpells.CastAt(const AX, AY: Integer): Boolean;
begin
  inherited;
  if Current = spNone then
    Exit;
  Result := FSpell[Current].CastAt(AX, AY);
  if Result then
    Current := spNone;
end;

constructor TSpells.Create;
begin
  Current := spNone;
  FSpell[spTrueHealing] := TTrueHealingSpell.Create;
end;

destructor TSpells.Destroy;
var
  LSpellEnum: TSpellEnum;
begin
  for LSpellEnum := Succ(Low(TSpellEnum)) to High(TSpellEnum) do
    FreeAndNil(FSpell[LSpellEnum]);
  inherited;
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
    showmessage('True Healing');
    Party[LPartyIndex].HealAll(25);
  end;
end;

constructor TTrueHealingSpell.Create;
begin

end;

destructor TTrueHealingSpell.Destroy;
begin

  inherited;
end;

initialization

Spells := TSpells.Create;

finalization

FreeAndNil(Spells);

end.
