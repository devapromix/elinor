unit DisciplesRL.Game;

interface

uses
  DisciplesRL.Party;

const
  GoldFromMinePerDay = 100;
  GoldForRevivePerLevel = 250;

var
  Days: Integer = 0;
  Gold: Integer = 0;
  NewGold: Integer = 0;
  GoldMines: Integer = 0;
  BattlesWon: Integer = 0;
  IsDay: Boolean = False;

var
  Wizard: Boolean = False;
  IsGame: Boolean = False;

var
  Party: array of TParty;
  LeaderParty: TParty;
  CapitalParty: TParty;

procedure Init;
procedure PartyInit(const AX, AY: Integer; IsFinal: Boolean);
procedure PartyFree;
function GetPartyCount: Integer;
function GetPartyIndex(const AX, AY: Integer): Integer;
procedure AddPartyAt(const AX, AY: Integer; IsFinal: Boolean = False);
procedure Clear;
procedure AddLoot;
procedure NewDay;
procedure Free;

implementation

uses
  System.Math,
  System.SysUtils,
  DisciplesRL.Creatures,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Scenes,
  DisciplesRL.Player,
  DisciplesRL.Scene.Info;

type
  TPartyBase = record
    Level: Integer;
    Character: array [TPosition] of TCreatureEnum;
  end;

const
  PartyBase: array [1 .. 20] of TPartyBase = (
    //
    (Level: 1; Character: (crNone, crGoblin_Archer, crGoblin, crNone, crNone, crGoblin_Archer)),
    //
    (Level: 1; Character: (crGoblin, crNone, crGoblin, crNone, crGoblin, crNone)),
    //
    (Level: 1; Character: (crGoblin, crNone, crNone, crGoblin_Archer, crGoblin, crNone)),

    //
    (Level: 2; Character: (crGoblin, crNone, crGoblin, crGoblin_Archer, crGoblin, crNone)),
    //
    (Level: 2; Character: (crGoblin, crGoblin_Archer, crNone, crNone, crGoblin, crGoblin_Archer)),

    //
    (Level: 3; Character: (crGoblin, crGoblin_Archer, crNone, crGoblin_Archer, crGoblin, crGoblin_Archer)),
    //
    (Level: 3; Character: (crGoblin, crGoblin_Archer, crGoblin, crNone, crGoblin, crGoblin_Archer)),

    //
    (Level: 4; Character: (crGoblin, crGoblin_Archer, crGoblin, crGoblin_Archer, crGoblin, crGoblin_Archer)),
    //
    (Level: 4; Character: (crNone, crNone, crWolf, crNone, crNone, crNone)),

    //
    (Level: 5; Character: (crWolf, crNone, crNone, crNone, crWolf, crNone)),
    //
    (Level: 5; Character: (crWolf, crNone, crGoblin, crGoblin_Archer, crWolf, crNone)),

    //
    (Level: 6; Character: (crWolf, crNone, crWolf, crNone, crWolf, crNone)),
    //
    (Level: 6; Character: (crWolf, crNone, crWolf, crGoblin_Archer, crWolf, crNone)),

    //
    (Level: 7; Character: (crWolf, crNone, crOrc, crGoblin_Archer, crWolf, crNone)),
    //
    (Level: 7; Character: (crOrc, crGoblin_Archer, crNone, crNone, crOrc, crGoblin_Archer)),
    //
    (Level: 7; Character: (crOrc, crNone, crOrc, crNone, crOrc, crNone)),
    //
    (Level: 7; Character: (crOrc, crNone, crOrc, crGoblin_Archer, crOrc, crNone)),

    //
    (Level: 8; Character: (crOrc, crGoblin_Archer, crOrc, crNone, crOrc, crGoblin_Archer)),
    //
    (Level: 8; Character: (crOrc, crGoblin_Archer, crOrc, crGoblin_Archer, crOrc, crGoblin_Archer)),

    // Финальная партия в башне
    (Level: 99; Character: (crNone, crNone, crGiantSpider, crNone, crNone, crNone))
    //
    );

const
  MaxLevel = 8;

procedure Init;
begin
  IsGame := True;
  DisciplesRL.Game.Clear;
  DisciplesRL.Map.Init;
  DisciplesRL.Map.Gen;
  DisciplesRL.Player.Init;
end;

procedure PartyInit(const AX, AY: Integer; IsFinal: Boolean);
var
  Level, N: Integer;
  I: TPosition;
begin
  Level := EnsureRange(GetDistToCapital(AX, AY) div 3, 1, MaxLevel);
  SetLength(Party, GetPartyCount + 1);
  Party[GetPartyCount - 1] := TParty.Create(AX, AY);
  repeat
    N := RandomRange(0, High(PartyBase) - 1) + 1;
  until PartyBase[N].Level = Level;
  if IsFinal then
    N := High(PartyBase);
  with Party[GetPartyCount - 1] do
  begin
    for I := Low(TPosition) to High(TPosition) do
      AddCreature(PartyBase[N].Character[I], I);
  end;
end;

procedure PartyFree;
var
  I: Integer;
begin
  for I := 0 to GetPartyCount - 1 do
    FreeAndNil(Party[I]);
  SetLength(Party, 0);
end;

function GetPartyCount: Integer;
begin
  Result := Length(Party);
end;

function GetPartyIndex(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetPartyCount - 1 do
    if (Party[I].X = AX) and (Party[I].Y = AY) then
    begin
      Result := I;
      Exit;
    end;
end;

procedure AddPartyAt(const AX, AY: Integer; IsFinal: Boolean);
var
  I: Integer;
begin
  Map[lrObj][AX, AY] := reEnemy;
  PartyInit(AX, AY, IsFinal);
  I := GetPartyIndex(AX, AY);
  Party[I].Owner := reNeutrals;
end;

procedure Clear;
begin
  Days := 1;
  Gold := 250;
  NewGold := 0;
  GoldMines := 0;
  BattlesWon := 0;
  IsDay := False;
  Free;
end;

procedure AddLoot();
var
  Level: Integer;
begin
  Level := GetDistToCapital(Player.X, Player.Y);
  NewGold := RandomRange(Level * 20, Level * 30);
  Inc(Gold, NewGold);
  DisciplesRL.Scenes.CurrentScene := scItem;
end;

procedure NewDay;
begin
  if IsDay then
  begin
    Gold := Gold + (GoldMines * GoldFromMinePerDay);
    DisciplesRL.Scene.Info.Show(stDay, scMap);
  end;
end;

procedure Free;
begin
  PartyFree;
  if Assigned(LeaderParty) then
    FreeAndNil(LeaderParty);
  FreeAndNil(CapitalParty);
end;

end.
