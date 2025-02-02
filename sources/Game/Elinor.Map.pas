unit Elinor.Map;

interface

uses
  Elinor.Faction,
  Elinor.Creatures,
  Elinor.MapObject,
  Elinor.Resources;

type
  TMapPlace = class(TMapObject)
    CurLevel: Integer;
    MaxLevel: Integer;
    Owner: TFactionEnum;
    constructor Create;
    class function GetIndex(const AX, AY: Integer): Integer; static;
    class procedure UpdateRadius(const AID: Integer); static;
    class function GetCityCount: Integer; static;
    class procedure Gen; static;
  end;

type

  { TMap }

  TMap = class(TObject)
  public type
    TMapLayer = array of array of TResEnum;
    TIgnoreRes = set of TResEnum;
    TLayerEnum = (lrTile, lrPath, lrDark, lrObj, lrSee);
  public const
    TileSize = 32;
    MapPlacesCount = 30;
  private const
    MapWidth = 40 + 2;
    MapHeight = 20 + 2;
  private type
    TCityNum = 0 .. 9;
  private const
    CityNameTitle: array [TCityNum] of TResEnum = (reTitleVorgel,
      reTitleEntarion, reTitleTardum, reTitleTemond, reTitleZerton,
      reTitleDoran, reTitleKront, reTitleHimor, reTitleSodek, reTitleSard);
    CityNameText: array [TCityNum] of string = ('Vorgel', 'Entarion', 'Tardum',
      'Temond', 'Zerton', 'Doran', 'Kront', 'Himor', 'Sodek', 'Sard');
  private
  var
    CityArr: array [TCityNum] of Integer;
  private
    FMap: array [TLayerEnum] of TMapLayer;
  public
    MapPlace: array [0 .. MapPlacesCount - 1] of TMapPlace;
    constructor Create;
    destructor Destroy; override;
    procedure Clear(const ALayerEnum: TLayerEnum); overload;
    procedure Clear; overload;
    procedure Gen;
    procedure UpdateRadius(const AX, AY, AR: Integer; MapLayer: TMapLayer;
      const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []); overload;
    procedure UpdateRadius(const AX, AY, ARadius: Integer); overload;
    function GetDist(X1, Y1, X2, Y2: Integer): Integer;
    function GetDistToCapital(const AX, AY: Integer): Integer;
    function InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
    function InMap(const X, Y: Integer): Boolean;
    function LeaderTile: TResEnum;
    function IsLeaderMove(const X, Y: Integer): Boolean;
    function Width: Integer;
    function Height: Integer;
    function GetLayer(const ALayerEnum: TLayerEnum): TMapLayer;
    function GetTile(const ALayerEnum: TLayerEnum; X, Y: Integer): TResEnum;
    procedure SetTile(const ALayerEnum: TLayerEnum; X, Y: Integer;
      Tile: TResEnum);
    procedure GenCityName;
    function GetCityName(const I: Integer): string;
    function GetCityNameTitleRes(const I: TCityNum): TResEnum;
    procedure UnParalyzeAllParties;
  end;

function ChTile(AX, AY: Integer): Boolean; stdcall;
function IsMoveLeader(AX, AY: Integer): Boolean; stdcall;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Party,
  Elinor.Scenes,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.Party,
  Elinor.PathFind,
  Elinor.Scene.Leader,
  Elinor.Difficulty,
  Elinor.Loot;

function ChTile(AX, AY: Integer): Boolean; stdcall;
begin
  Result := True;
end;

function IsMoveLeader(AX, AY: Integer): Boolean; stdcall;
begin
  Result := not(Game.Map.GetTile(lrObj, AX, AY) in StopTiles);
end;

function TMap.GetDist(X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

function TMap.GetDistToCapital(const AX, AY: Integer): Integer;
begin
  Result := GetDist(MapPlace[0].X, MapPlace[0].Y, AX, AY);
end;

function TMap.GetLayer(const ALayerEnum: TLayerEnum): TMapLayer;
begin
  Result := FMap[ALayerEnum];
end;

function TMap.GetTile(const ALayerEnum: TLayerEnum; X, Y: Integer): TResEnum;
begin
  if InMap(X, Y) then
    Result := FMap[ALayerEnum][X, Y]
  else
    Result := reNone;
end;

function TMap.Height: Integer;
begin
  Result := MapHeight;
end;

procedure TMap.Clear;
var
  LLayerEnum: TLayerEnum;
begin
  for LLayerEnum := Low(TLayerEnum) to High(TLayerEnum) do
  begin
    SetLength(FMap[LLayerEnum], MapWidth, MapHeight);
    Clear(LLayerEnum);
  end;
end;

constructor TMap.Create;
var
  LMapPlaceIndex: Integer;
begin
  for LMapPlaceIndex := 0 to High(MapPlace) do
    MapPlace[LMapPlaceIndex] := TMapPlace.Create;
end;

destructor TMap.Destroy;
var
  LMapPlaceIndex: Integer;
begin
  inherited;
  for LMapPlaceIndex := 0 to High(MapPlace) do
    FreeAndNil(MapPlace[LMapPlaceIndex]);
end;

procedure TMap.Clear(const ALayerEnum: TLayerEnum);
var
  LX, LY: Integer;
begin
  for LY := 0 to MapHeight - 1 do
    for LX := 0 to MapWidth - 1 do
      case ALayerEnum of
        lrTile, lrPath, lrObj:
          FMap[ALayerEnum][LX, LY] := reNone;
      else
        FMap[ALayerEnum][LX, LY] := reDark;
      end;
end;

procedure AddCapitalParty;
begin
  TLeaderParty.CapitalPartyIndex := High(Party) + 1;
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TParty.Create(Game.Map.MapPlace[0].X,
    Game.Map.MapPlace[0].Y, TSaga.LeaderFaction);
  Party[TSaga.GetPartyCount - 1].AddCreature(Characters[TSaga.LeaderFaction]
    [cgGuardian][ckGuardian], 3);
end;

procedure AddSummonParty;
var
  LCreatureEnum: TCreatureEnum;
begin
  TLeaderParty.SummonPartyIndex := High(Party) + 1;
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TParty.Create(Game.Map.MapPlace[0].X,
    Game.Map.MapPlace[0].Y, TSaga.LeaderFaction);
  LCreatureEnum := crGoblin;
  Party[TLeaderParty.SummonPartyIndex].AddCreature(LCreatureEnum, 2);
end;

procedure AddLeaderParty;
var
  LCreatureEnum: TCreatureEnum;
begin
  TLeaderParty.LeaderPartyIndex := High(Party) + 1;
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TLeaderParty.Create(Game.Map.MapPlace[0].X,
    Game.Map.MapPlace[0].Y, TSaga.LeaderFaction);
  LCreatureEnum := Characters[TSaga.LeaderFaction][cgLeaders][RaceCharKind];
  case TCreature.Character(LCreatureEnum).ReachEnum of
    reAdj:
      begin
        Party[TLeaderParty.LeaderPartyIndex].AddCreature(LCreatureEnum, 2);
        ActivePartyPosition := 2;
      end
  else
    begin
      Party[TLeaderParty.LeaderPartyIndex].AddCreature(LCreatureEnum, 3);
      ActivePartyPosition := 3;
    end;
  end;
end;

procedure TMap.Gen;
var
  LX, LY, RX, RY, LMapPlaceIndex: Integer;

  procedure AddObjectAt(const AX, AY, AObjID: Integer);
  var
    LResEnum: TResEnum;
  begin
    case AObjID of
      0:
        LResEnum := reSTower;
    else
      LResEnum := reSTower;
    end;
    FMap[lrObj][AX, AY] := LResEnum;
  end;

  procedure AddTree(const AX, AY: Integer);
  begin
    case Random(5) of
      0:
        FMap[lrObj][AX, AY] := reTree1;
      1:
        FMap[lrObj][AX, AY] := reTree2;
      2:
        FMap[lrObj][AX, AY] := reTree3;
      3:
        FMap[lrObj][AX, AY] := reTree4;
      4:
        FMap[lrObj][AX, AY] := reTree5;
    end;
  end;

  procedure AddMountain(const AX, AY: Integer);
  begin
    case RandomRange(0, 4) of
      0:
        FMap[lrObj][AX, AY] := reMountain1;
      1:
        FMap[lrObj][AX, AY] := reMountain2;
      2:
        FMap[lrObj][AX, AY] := reMountain3;
    else
      FMap[lrObj][AX, AY] := reMountain4;
    end;
  end;

begin
  GenCityName;
  for LY := 0 to MapHeight - 1 do
    for LX := 0 to MapWidth - 1 do
    begin
      FMap[lrTile][LX, LY] := reNeutralTerrain;
      if (LX = 0) or (LX = MapWidth - 1) or (LY = 0) or (LY = MapHeight - 1)
      then
      begin
        AddMountain(LX, LY);
        Continue;
      end;
      case RandomRange(0, 3) of
        0:
          AddTree(LX, LY);
      else
        AddMountain(LX, LY);
      end;

    end;
  // Capital and Cities
  TMapPlace.Gen;
  RX := 0;
  RY := 0;
  LX := MapPlace[0].X;
  LY := MapPlace[0].Y;
  for LMapPlaceIndex := 1 to High(MapPlace) do
  begin
    repeat
      if DoAStar(MapWidth, MapHeight, LX, LY, MapPlace[LMapPlaceIndex].X,
        MapPlace[LMapPlaceIndex].Y, @ChTile, RX, RY) then
      begin
        // if (RandomRange(0, 2) = 0) then
        begin
          LX := RX + RandomRange(-1, 2);
          LY := RY + RandomRange(-1, 2);
          if FMap[lrObj][LX, LY] in MountainTiles then
            FMap[lrObj][LX, LY] := reNone;
        end;
        LX := RX;
        LY := RY;
        if FMap[lrObj][LX, LY] in MountainTiles then
          FMap[lrObj][LX, LY] := reNone;
      end;
    until ((LX = MapPlace[LMapPlaceIndex].X) and
      (LY = MapPlace[LMapPlaceIndex].Y));
  end;
  // Mana, Golds and Bags
  for LMapPlaceIndex := 0 to High(MapPlace) div 2 do
  begin
    repeat
      LX := RandomRange(2, MapWidth - 2);
      LY := RandomRange(2, MapHeight - 2);
    until (FMap[lrTile][LX, LY] = reNeutralTerrain) and
      (FMap[lrObj][LX, LY] = reNone);
    if (GetDistToCapital(LX, LY) <= (15 - (Ord(TSaga.Difficulty) * 2))) and
      (RandomRange(0, 9) > 2) then
      case RandomRange(0, 2) of
        0:
          begin
            FMap[lrObj][LX, LY] := reGold;
            Loot.AddGoldAt(LX, LY);
          end;
        1:
          begin
            FMap[lrObj][LX, LY] := reMana;
            Loot.AddManaAt(LX, LY);
          end;
      end
    else
    begin
      FMap[lrObj][LX, LY] := reBag;
      Loot.AddItemAt(LX, LY);
    end;
  end;
  // Enemies
  for LMapPlaceIndex := 0 to High(MapPlace) do
  begin
    repeat
      LX := RandomRange(1, MapWidth - 1);
      LY := RandomRange(1, MapHeight - 1);
    until (FMap[lrObj][LX, LY] = reNone) and
      (FMap[lrTile][LX, LY] = reNeutralTerrain) and
      (GetDistToCapital(LX, LY) >= 3);
    TSaga.AddPartyAt(LX, LY, True);
    Loot.AddItemAt(LX, LY);
    if (Game.Scenario.CurrentScenario = sgAncientKnowledge) and
      (LMapPlaceIndex < TScenario.ScenarioStoneTabMax) then
      Game.Scenario.AddStoneTab(LX, LY);
  end;
  // Objects
  for LMapPlaceIndex := 0 to 9 do
  begin
    repeat
      LX := RandomRange(5, MapWidth - 5);
      LY := RandomRange(5, MapHeight - 5);
    until (FMap[lrObj][LX, LY] = reNone) and
      (FMap[lrTile][LX, LY] = reNeutralTerrain) and
      (GetDistToCapital(LX, LY) >= 5);
    AddObjectAt(LX, LY, LMapPlaceIndex);
  end;
  // Parties
  AddCapitalParty;
  AddSummonParty;
  AddLeaderParty;
end;

function TMap.InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
begin
  Result := (X >= X1) and (Y >= Y1) and (X <= X2) and (Y <= Y2);
end;

function TMap.InMap(const X, Y: Integer): Boolean;
begin
  Result := InRect(X, Y, 0, 0, MapWidth - 1, MapHeight - 1);
end;

procedure TMap.UpdateRadius(const AX, AY, AR: Integer; MapLayer: TMapLayer;
  const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []);
var
  X, Y: Integer;
begin
  for Y := -AR to AR do
    for X := -AR to AR do
      if (GetDist(AX + X, AY + Y, AX, AY) <= AR) and InMap(AX + X, AY + Y) then
        if (MapLayer[AX + X, AY + Y] in IgnoreRes) then
          Continue
        else
        begin
          // Dead Trees
          if (FMap[lrObj][AX + X, AY + Y] in TreesTiles) then
            case FMap[lrTile][AX + X, AY + Y] of
              reUndeadHordesTerrain:
                FMap[lrObj][AX + X, AY + Y] := reUndeadHordesTree;
              reLegionsOfTheDamnedTerrain:
                FMap[lrObj][AX + X, AY + Y] := reLegionsOfTheDamnedTree;
            end;
          // Add Gold Mine
          if (MapLayer = FMap[lrTile]) and
            (FMap[lrObj][AX + X, AY + Y] = reMineGold) and
            (FMap[lrTile][AX + X, AY + Y] = reNeutralTerrain) then
            Game.Gold.AddMine;
          // Add Mana Mine
          if (MapLayer = FMap[lrTile]) and
            (FMap[lrObj][AX + X, AY + Y] = reMineMana) and
            (FMap[lrTile][AX + X, AY + Y] = reNeutralTerrain) then
            Game.Mana.AddMine;
          MapLayer[AX + X, AY + Y] := AResEnum;
        end;
end;

procedure TMap.UnParalyzeAllParties;
var
  I: Integer;
begin
  for I := Low(Party) to High(Party) do
    Party[I].UnParalyzeParty;
end;

procedure TMap.UpdateRadius(const AX, AY, ARadius: Integer);
var
  CX, CY: Integer;
begin
  UpdateRadius(AX, AY, ARadius, GetLayer(lrDark), reNone);
  for CX := AX - ARadius to AX + ARadius do
    for CY := AY - ARadius to AY + ARadius do
      if (GetDist(CX, CY, AX, AY) <= ARadius) and InMap(CX, CY) then
        Game.Map.SetTile(lrSee, CX, CY, reNone);
end;

function TMap.Width: Integer;
begin
  Result := MapWidth;
end;

function TMap.LeaderTile: TResEnum;
begin
  Result := FMap[lrTile][TLeaderParty.Leader.X, TLeaderParty.Leader.Y];
end;

procedure TMap.SetTile(const ALayerEnum: TLayerEnum; X, Y: Integer;
  Tile: TResEnum);
begin
  FMap[ALayerEnum][X, Y] := Tile;
end;

procedure TMap.GenCityName;
var
  N: set of TCityNum;
  J, K: Integer;
begin
  N := [];
  for K := Low(TCityNum) to High(TCityNum) do
  begin
    repeat
      J := Random(High(TCityNum) + 1);
    until not(J in N);
    N := N + [J];
    CityArr[K] := J;
  end;
end;

function TMap.GetCityName(const I: Integer): string;
begin
  Result := CityNameText[CityArr[I]];
end;

function TMap.GetCityNameTitleRes(const I: TCityNum): TResEnum;
begin
  Result := CityNameTitle[CityArr[I]];
end;

function TMap.IsLeaderMove(const X, Y: Integer): Boolean;
begin
  Result := (InRect(X, Y, TLeaderParty.Leader.X - 1, TLeaderParty.Leader.Y - 1,
    TLeaderParty.Leader.X + 1, TLeaderParty.Leader.Y + 1)) and
    not(FMap[lrObj][X, Y] in StopTiles);
end;

function GetRadius(const N: Integer): Integer;
begin
  case N of
    0: // Capital
      Result := 7;
    1 .. TScenario.ScenarioCitiesMax: // City
      Result := 6;
    TScenario.ScenarioTowerIndex: // Tower
      Result := 3;
  else // Ruin
    Result := 2;
  end;
end;

function ChCity(N: Integer): Boolean;
var
  I: Integer;
begin
  Result := True;
  if (N = 0) then
    Exit;
  for I := 0 to N - 1 do
  begin
    if (Game.Map.GetDist(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y,
      Game.Map.MapPlace[N].X, Game.Map.MapPlace[N].Y) <= GetRadius(N)) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure ClearObj(const AX, AY: Integer);
var
  X, Y: Integer;
begin
  for X := AX - 2 to AX + 2 do
    for Y := AY - 2 to AY + 2 do
      if (X = AX - 2) or (X = AX + 2) or (Y = AY - 2) or (Y = AY + 2) then
      begin
        if (RandomRange(0, 5) = 0) then
          Game.Map.FMap[lrObj][X, Y] := reNone;
      end
      else
        Game.Map.FMap[lrObj][X, Y] := reNone;
end;

{ TMapPlace }

class procedure TMapPlace.Gen;
var
  DX, DY, FX, FY, PX, PY, I: Integer;
begin
  for I := 0 to High(Game.Map.MapPlace) do
  begin
    repeat
      case I of
        0: // Capital
          case TSaga.Difficulty of
            dfEasy:
              PX := RandomRange(17, Game.Map.Width - 17);
            dfNormal:
              case RandomRange(0, 2) of
                0:
                  PX := RandomRange(8, 15);
                1:
                  PX := RandomRange(Game.Map.Width - 15, Game.Map.Width - 8);
              end;
            dfHard:
              case RandomRange(0, 2) of
                0:
                  PX := RandomRange(3, 5);
                1:
                  PX := RandomRange(Game.Map.Width - 5, Game.Map.Width - 3);
              end;
          end
      else
        PX := RandomRange(3, Game.Map.Width - 3);
      end;
      PY := RandomRange(3, Game.Map.Height - 3);
      Game.Map.MapPlace[I].SetLocation(PX, PY);
    until ChCity(I);
    case I of
      0: // Capital
        begin
          case TSaga.LeaderFaction of
            faTheEmpire:
              Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X,
                Game.Map.MapPlace[I].Y] := reTheEmpireCapital;
            faUndeadHordes:
              Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X,
                Game.Map.MapPlace[I].Y] := reUndeadHordesCapital;
            faLegionsOfTheDamned:
              Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X,
                Game.Map.MapPlace[I].Y] := reLegionsOfTheDamnedCapital;
          end;
          ClearObj(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y);
          TMapPlace.UpdateRadius(I);
        end;

      1 .. TScenario.ScenarioCitiesMax: // City
        begin
          Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y]
            := reNeutralCity;
          ClearObj(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y);
          TSaga.AddPartyAt(Game.Map.MapPlace[I].X,
            Game.Map.MapPlace[I].Y, False);
        end;

      TScenario.ScenarioTowerIndex: // Tower
        begin
          Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y]
            := reTower;
          TSaga.AddPartyAt(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y,
            False, True);
        end
    else // Ruin
      begin
        Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y]
          := reRuin;
        TSaga.AddPartyAt(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y, False);
      end;
    end;
    // Mines
    repeat
      DX := RandomRange(-1, 2);
      DY := RandomRange(-1, 2);
    until ((DX <> 0) and (DY <> 0));
    repeat
      FX := RandomRange(-1, 2);
      FY := RandomRange(-1, 2);
    until ((FX <> 0) and (FY <> 0) and (FX <> DX) and (FY <> DY));
    case I of
      0 .. TScenario.ScenarioCitiesMax:
        begin
          Game.Map.FMap[lrObj][Game.Map.MapPlace[I].X + DX,
            Game.Map.MapPlace[I].Y + DY] := reMineGold;
          Game.Map.FMap[lrObj][Game.Map.MapPlace[I].X + FX,
            Game.Map.MapPlace[I].Y + FY] := reMineMana;
        end;
    end;
  end;
end;

constructor TMapPlace.Create;
begin
  inherited;
  CurLevel := 0;
  MaxLevel := 2;
  Owner := faNeutrals;
end;

class function TMapPlace.GetIndex(const AX, AY: Integer): Integer;
var
  LMapPlaceIndex: Integer;
begin
  Result := -1;
  for LMapPlaceIndex := 0 to High(Game.Map.MapPlace) do
    if ((Game.Map.MapPlace[LMapPlaceIndex].X = AX) and
      (Game.Map.MapPlace[LMapPlaceIndex].Y = AY)) then
    begin
      Result := LMapPlaceIndex;
      Break;
    end;
end;

class procedure TMapPlace.UpdateRadius(const AID: Integer);
begin
  Game.Map.UpdateRadius(Game.Map.MapPlace[AID].X, Game.Map.MapPlace[AID].Y,
    Game.Map.MapPlace[AID].CurLevel, Game.Map.FMap[lrTile],
    FactionTerrain[TSaga.LeaderFaction], [reNeutralCity, reRuin, reTower] +
    Capitals + Cities);
  Game.Map.UpdateRadius(Game.Map.MapPlace[AID].X, Game.Map.MapPlace[AID].Y,
    Game.Map.MapPlace[AID].CurLevel, Game.Map.FMap[lrDark], reNone);
  Game.Map.MapPlace[AID].Owner := TSaga.LeaderFaction;
end;

class function TMapPlace.GetCityCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to TScenario.ScenarioCitiesMax do
  begin
    if (Game.Map.MapPlace[I].Owner in PlayableFactions) then
      Inc(Result);
  end;
end;

end.
