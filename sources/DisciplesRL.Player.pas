unit DisciplesRL.Player;

interface

uses
  DisciplesRL.Creatures;

type
  TPlayer = record
    X: Integer;
    Y: Integer;
    Radius: Integer;
    Speed: Integer;
    MaxSpeed: Integer;
    Race: TRaceEnum;
  end;

var
  Player: TPlayer;

procedure Init;
procedure Move(const AX, AY: ShortInt);
procedure PutAt(const AX, AY: ShortInt);
procedure RefreshRadius;
procedure RefreshParties;
procedure Turn(const Count: Integer = 1);
procedure Gen;

implementation

uses
  System.Math,
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Utils,
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

procedure Init;
begin
  Player.MaxSpeed := 7;
  Player.Speed := Player.MaxSpeed;
  Player.Radius := IfThen(Wizard, 9, 1);
  RefreshRadius;
end;

procedure Move(const AX, AY: ShortInt);
begin
  PutAt(Player.X + AX, Player.Y + AY);
end;

procedure RefreshParties;
// var
// I, J: Integer;
begin
  { for I := 0 to 11 do
    begin
    case I of
    0 .. 5:
    begin
    LeaderParty.SetHitPoints(I, V.GetInt('Slot' + IntToStr(TransformTo(I)) + 'HP'));
    end;
    6 .. 11:
    begin
    J := GetPartyIndex(Player.X, Player.Y);
    Party[J].SetHitPoints(I - 6, V.GetInt('Slot' + IntToStr(TransformTo(I)) + 'HP'));
    end;
    end;
    end; }
end;

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
          J := GetPartyIndex(Player.X, Player.Y);
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
          J := GetPartyIndex(Player.X, Player.Y);
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

procedure Turn(const Count: Integer = 1);
var
  C: Integer;
begin
  if (Count < 1) then
    Exit;
  C := 0;
  repeat
    Dec(Player.Speed);
    if (Player.Speed = 0) then
    begin
      Inc(Days);
      IsDay := True;
      Player.Speed := Player.MaxSpeed;
    end;
    Inc(C);
  until (C >= Count);
end;

procedure PutAt(const AX, AY: ShortInt);
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
    if (City[I].Owner = reTheEmpire) then
      if (City[I].CurLevel < City[I].MaxLevel) then
      begin
        Inc(City[I].CurLevel);
        DisciplesRL.City.UpdateRadius(I);
      end;
  end;
  Player.X := AX;
  Player.Y := AY;
  RefreshRadius;
  Turn(1);
  F := True;
  case Map[lrObj][Player.X, Player.Y] of
    reGold:
      begin
        Map[lrObj][Player.X, Player.Y] := reNone;
        AddLoot();
        F := False;
      end;
    reBag:
      begin
        Map[lrObj][Player.X, Player.Y] := reNone;
        AddLoot();
        F := False;
      end;
    reEnemy:
      begin
        DisciplesRL.Scene.Battle2.Start;
        DisciplesRL.Scenes.CurrentScene := scBattle2;
        Map[lrObj][Player.X, Player.Y] := reNone;
        F := False;
      end;
  end;
  case PlayerTile of
    reNeutralCity:
      begin
        Map[lrTile][Player.X, Player.Y] := reTheEmpireCity;
        DisciplesRL.City.UpdateRadius(DisciplesRL.City.GetCityIndex(Player.X, Player.Y));
        F := False;
      end;
    reTheEmpireCity:
      begin
        DisciplesRL.Scene.Settlement.Show(stCity);
        F := False;
      end;
    reTheEmpireCapital:
      begin
        DisciplesRL.Scene.Settlement.Show(stCapital);
        F := False;
      end;
  end;
  if F then
    NewDay;
end;

procedure RefreshRadius;
begin
  DisciplesRL.Map.UpdateRadius(Player.X, Player.Y, Player.Radius, Map[lrDark], reNone);
end;

procedure Gen;
var
  C: TCreatureEnum;
begin
  LeaderParty.SetLocation(Player.X, Player.Y);
  C := Characters[Player.Race][cgLeaders][TRaceCharKind(HireIndex)];
  case CreatureBase[C].ReachEnum of
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

end.
