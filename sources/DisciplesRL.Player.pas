unit DisciplesRL.Player;

interface

type
  TPlayer = record
    X: Integer;
    Y: Integer;
    Radius: Integer;
  end;

var
  Player: TPlayer;
  Wizard: Boolean;

procedure Init;
procedure Move(const AX, AY: ShortInt);
procedure PutAt(const AX, AY: ShortInt);
procedure RefreshRadius;
procedure RefreshParties;
procedure Gen;

implementation

uses System.Math, Vcl.Dialogs, System.SysUtils, DisciplesRL.Map,
  DisciplesRL.Resources, DisciplesRL.Utils, DisciplesRL.City,
  DisciplesRL.Party, DisciplesRL.Scenes, DisciplesRL.Game,
  DisciplesRL.Creatures, DisciplesRL.Scene.Settlement,
  DisciplesRL.PascalScript.Battle, DisciplesRL.PascalScript.Vars,
  DisciplesRL.Scene.Battle;

procedure Init;
begin
  Player.Radius := IfThen(Wizard, 9, 1);
  RefreshRadius;
end;

procedure Move(const AX, AY: ShortInt);
begin
  PutAt(Player.X + AX, Player.Y + AY);
end;

procedure RefreshParties;
var
  I, J: Integer;
begin
  for I := 0 to 11 do
  begin
    case I of
      0 .. 5:
        begin
          LeaderParty.SetHitPoints(I,
            V.GetInt('Slot' + IntToStr(TransformTo(I)) + 'HP'));
        end;
      6 .. 11:
        begin
          J := GetPartyIndex(Player.X, Player.Y);
          Party[J].SetHitPoints(I - 6,
            V.GetInt('Slot' + IntToStr(TransformTo(I)) + 'HP'));
        end;
    end;
  end;
end;

procedure InitParty(const X, Y: Integer);
var
  I, J: Integer;
  T: string;
begin
  for I := 0 to 11 do
  begin
    T := 'Slot' + IntToStr(TransformTo(I)) + 'Type';
    case I of
      0 .. 5:
        begin
          if LeaderParty.Creature[I].Active then
            V.SetInt(T, Ord(LeaderParty.Creature[I].Enum))
          else
            V.SetInt(T, 0);
        end;
      6 .. 11:
        begin
          J := GetPartyIndex(Player.X, Player.Y);
          if Party[J].Creature[I - 6].Active then
            V.SetInt(T, Ord(Party[J].Creature[I - 6].Enum))
          else
            V.SetInt(T, 0);
        end;
    end;
  end;
end;

function GetClass(ReachEnum: TReachEnum; Targets: Integer): Integer;
begin
  case ReachEnum of
    reAny:
      case Targets of
        1: // Ranger
          Result := 4;
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
              V.SetInt(S + 'MHP', MaxHitPoints);
              V.SetInt(S + 'HP', HitPoints);
              V.SetInt(S + 'INI', Initiative);
              V.SetInt(S + 'Use', Value);
              V.SetInt(S + 'TCH', ChancesToHit);
              V.SetInt(S + 'Class', GetClass(ReachEnum, Targets));
            end;
        end;
      6 .. 11:
        begin
          J := GetPartyIndex(Player.X, Player.Y);
          with Party[J].Creature[I - 6] do
            if Active then
            begin
              V.SetStr(S + 'Name', Name);
              V.SetInt(S + 'MHP', MaxHitPoints);
              V.SetInt(S + 'HP', HitPoints);
              V.SetInt(S + 'INI', Initiative);
              V.SetInt(S + 'Use', Value);
              V.SetInt(S + 'TCH', ChancesToHit);
              V.SetInt(S + 'Class', GetClass(ReachEnum, Targets));
            end;
        end;
    end;
  end;
end;

procedure PutAt(const AX, AY: ShortInt);
var
  X, Y, I: Integer;
begin
  if not InMap(AX, AY) then
    Exit;
  if (MapObj[AX, AY] = reMountain) then
    Exit;
  if (MapDark[AX, AY] = reDark) then
    Exit;
  Inc(Days);
  for I := 0 to High(City) do
  begin
    if (City[I].Owner = reEmpire) then
      if (City[I].CurLevel < City[I].MaxLevel) then
      begin
        Inc(City[I].CurLevel);
        DisciplesRL.City.UpdateRadius(I);
      end;
  end;
  Player.X := AX;
  Player.Y := AY;
  RefreshRadius;
  case MapObj[Player.X, Player.Y] of
    reGold:
      begin
        MapObj[Player.X, Player.Y] := reNone;
        Inc(Gold, GetDistToCapital(Player.X, Player.Y));
        DisciplesRL.Scenes.CurrentScene := scItem;
      end;
    reBag:
      begin
        MapObj[Player.X, Player.Y] := reNone;
        Inc(Gold, GetDistToCapital(Player.X, Player.Y));
        DisciplesRL.Scenes.CurrentScene := scItem;
      end;
    reEnemies:
      begin
        InitParty(Player.X, Player.Y);
        Run('Battles\BattleInit.pas');
        FullParty(Player.X, Player.Y);
        Run('Battles\Start.pas');

        DisciplesRL.Scenes.CurrentScene := scBattle;
        MapObj[Player.X, Player.Y] := reNone;
      end;
  end;
  case PlayerTile of
    reNeutralCity:
      begin
        MapTile[Player.X, Player.Y] := reEmpireCity;
        DisciplesRL.City.UpdateRadius(DisciplesRL.City.GetCityIndex(Player.X,
          Player.Y));
      end;
    reEmpireCity:
      begin
        DisciplesRL.Scene.Settlement.Show(stCity);
      end;
    reEmpireCapital:
      begin
        DisciplesRL.Scene.Settlement.Show(stCapital);
      end;
  end;
end;

procedure RefreshRadius;
begin
  DisciplesRL.Map.UpdateRadius(Player.X, Player.Y, Player.Radius,
    MapDark, reNone);
end;

procedure Gen;
begin
  LeaderParty.SetPoint(Player.X, Player.Y);
  LeaderParty.AddCreature(crSquire, 0);
  LeaderParty.AddCreature(crPegasus_Knight, 2);
  LeaderParty.AddCreature(crArcher, 3);
  LeaderParty.AddCreature(crSquire, 4);
end;

end.
