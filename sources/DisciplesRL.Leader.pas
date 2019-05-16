unit DisciplesRL.Leader;

interface

uses
  DisciplesRL.Creatures,
  DisciplesRL.MapObject;

type
  TLeader = class(TMapObject)
  private
    FRadius: Integer;
    FMaxLeadership: Integer;
  public
    Speed: Integer;
    MaxSpeed: Integer;
    Race: TRaceEnum;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AddToParty;
    procedure RefreshRadius;
    procedure PutAt(const AX, AY: ShortInt);
    procedure Turn(const Count: Integer = 1);
    procedure Move(const AX, AY: ShortInt);
    property Radius: Integer read FRadius;
    property MaxLeadership: Integer read FMaxLeadership;
  end;

var
  Leader: TLeader;

implementation

uses
  System.Math,
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.City,
  DisciplesRL.Party,
  DisciplesRL.Scenes,
  DisciplesRL.Game,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.PascalScript.Battle,
  DisciplesRL.PascalScript.Vars,
  DisciplesRL.Scene.Battle,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Party;

procedure InitParty(const X, Y: Integer);
var
  I, J: Integer;
  SlotType: string;
begin
  for I := 0 to 11 do
  begin
    SlotType := 'Slot' + IntToStr(TransformTo(I)) + 'Type';
    case I of
      0 .. 5:
        begin
          if LeaderParty.Creature[I].Active then
            V.SetInt(SlotType, Ord(LeaderParty.Creature[I].Enum))
          else
            V.SetInt(SlotType, 0);
        end;
      6 .. 11:
        begin
          J := GetPartyIndex(Leader.X, Leader.Y);
          if Party[J].Creature[I - 6].Active then
            V.SetInt(SlotType, Ord(Party[J].Creature[I - 6].Enum))
          else
            V.SetInt(SlotType, 0);
        end;
    end;
  end;
end;

function GetClass(ReachEnum: TReachEnum; Targets, Heal: Integer): Integer;
begin
  case ReachEnum of
    reAny:
      case Targets of
        1: // Ranger
          if Heal = 0 then
            Result := 4
          else
            // Healer
            Result := 3;
      end;
    reAll:
      case Targets of
        6: // Mage
          Result := 2;
      end;
    reAdj:
      case Targets of
        1: // Warrior
          Result := 1;
      end;
  end;
end;

procedure FullParty(const X, Y: Integer);
var
  I, J: Integer;
  S: string;
begin
  for I := 0 to 11 do
  begin
    S := 'Slot' + IntToStr(TransformTo(I));
    case I of
      0 .. 5:
        begin
          with LeaderParty.Creature[I] do
            if Active then
            begin
              V.SetStr(S + 'Name', Name);
              V.SetInt(S + 'Level', Level);
              V.SetInt(S + 'MHP', MaxHitPoints);
              V.SetInt(S + 'HP', HitPoints);
              V.SetInt(S + 'INI', Initiative);
              V.SetInt(S + 'Use', IfThen(Heal = 0, Damage, Heal));
              V.SetInt(S + 'TCH', ChancesToHit);
              // V.SetInt(S + 'Class', GetClass(ReachEnum, Targets, Heal));
            end;
        end;
      6 .. 11:
        begin
          J := GetPartyIndex(Leader.X, Leader.Y);
          with Party[J].Creature[I - 6] do
            if Active then
            begin
              V.SetStr(S + 'Name', Name);
              V.SetInt(S + 'Level', Level);
              V.SetInt(S + 'MHP', MaxHitPoints);
              V.SetInt(S + 'HP', HitPoints);
              V.SetInt(S + 'INI', Initiative);
              V.SetInt(S + 'Use', IfThen(Heal = 0, Damage, Heal));
              V.SetInt(S + 'TCH', ChancesToHit);
              // V.SetInt(S + 'Class', GetClass(ReachEnum, Targets, Heal));
            end;
        end;
    end;
  end;
end;

{ TLeader }

procedure TLeader.PutAt(const AX, AY: ShortInt);
var
  I: Integer;
  F: Boolean;
begin
  if not InMap(AX, AY) then
    Exit;
  if (Map[lrObj][AX, AY] = reMountain) then
    Exit;
  if (Map[lrDark][AX, AY] = reDark) then
    Exit;
  for I := 0 to High(City) do
  begin
    if (City[I].Owner = reTheEmpire) or (City[I].Owner = reUndeadHordes) or (City[I].Owner = reLegionsOfTheDamned) then
      if (City[I].CurLevel < City[I].MaxLevel) then
      begin
        Inc(City[I].CurLevel);
        DisciplesRL.City.UpdateRadius(I);
      end;
  end;
  SetLocation(AX, AY);
  RefreshRadius;
  Turn(1);
  F := True;
  case Map[lrObj][X, Y] of
    reGold:
      begin
        Map[lrObj][X, Y] := reNone;
        AddLoot();
        F := False;
      end;
    reBag:
      begin
        Map[lrObj][X, Y] := reNone;
        AddLoot();
        F := False;
      end;
    reEnemy:
      begin
        DisciplesRL.Scene.Battle2.Start;
        DisciplesRL.Scenes.CurrentScene := scBattle2;
        Map[lrObj][X, Y] := reNone;
        F := False;
        Exit;
      end;
  end;
  case LeaderTile of
    reNeutralCity:
      begin
        case Leader.Race of
          reTheEmpire:
            Map[lrTile][X, Y] := reTheEmpireCity;
          reUndeadHordes:
            Map[lrTile][X, Y] := reUndeadHordesCity;
          reLegionsOfTheDamned:
            Map[lrTile][X, Y] := reLegionsOfTheDamnedCity;
        end;
        DisciplesRL.City.UpdateRadius(DisciplesRL.City.GetCityIndex(X, Y));
        F := False;
      end;
  end;
  if LeaderTile in Capitals then
  begin
    DisciplesRL.Scene.Settlement.Show(stCapital);
    F := False;
  end;
  if LeaderTile in Cities then
  begin
    DisciplesRL.Scene.Settlement.Show(stCity);
    F := False;
  end;
  if F then
    NewDay;
end;

procedure TLeader.RefreshRadius;
begin
  DisciplesRL.Map.UpdateRadius(X, Y, Radius, Map[lrDark], reNone);
end;

procedure TLeader.Turn(const Count: Integer = 1);
var
  C: Integer;
begin
  if (Count < 1) then
    Exit;
  C := 0;
  repeat
    Dec(Speed);
    if (Speed = 0) then
    begin
      Inc(Days);
      IsDay := True;
      Speed := MaxSpeed;
    end;
    Inc(C);
  until (C >= Count);
end;

procedure TLeader.Move(const AX, AY: ShortInt);
begin
  PutAt(X + AX, Y + AY);
end;

procedure TLeader.Clear;
begin
  MaxSpeed := 7;
  Speed := MaxSpeed;
  FRadius := IfThen(Wizard, 9, 1);
  RefreshRadius;
end;

procedure TLeader.AddToParty;
var
  C: TCreatureEnum;
begin
  LeaderParty.SetLocation(Leader.X, Leader.Y);
  C := Characters[Leader.Race][cgLeaders][TRaceCharKind(HireIndex)];
  case GetCharacter(C).ReachEnum of
    reAdj:
      begin
        LeaderParty.AddCreature(C, 2);
        ActivePartyPosition := 2;
      end
  else
    begin
      LeaderParty.AddCreature(C, 3);
      ActivePartyPosition := 3;
    end;
  end;
end;

constructor TLeader.Create;
begin
  inherited;
  FRadius := 1;
  FMaxLeadership := 1;
end;

destructor TLeader.Destroy;
begin

  inherited;
end;

initialization

Leader := TLeader.Create;

finalization

FreeAndNil(Leader);

end.
