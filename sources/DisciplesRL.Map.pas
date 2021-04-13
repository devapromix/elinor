unit DisciplesRL.Map;

interface

uses
  DisciplesRL.Creatures,
  DisciplesRL.Resources;

type
  TLocation = record
    X: integer;
    Y: integer;
  end;

type
  TMapObject = class(TObject)
  private
    FLocation: TLocation;
  public
    constructor Create(const AX, AY: integer); overload;
    constructor Create; overload;
    destructor Destroy; override;
    property Location: TLocation read FLocation write FLocation;
    procedure SetLocation(const AX, AY: integer);
    function GetLocation: TLocation;
    property X: integer read FLocation.X;
    property Y: integer read FLocation.Y;
  end;

type

  { TMapPlace }

  TMapPlace = class(TMapObject)
    CurLevel: integer;
    MaxLevel: integer;
    Owner: TRaceEnum;
    constructor Create;
    class function GetIndex(const AX, AY: integer): integer; static;
    class procedure UpdateRadius(const AID: integer); static;
    class function GetCityCount: integer; static;
    class procedure Gen; static;
  end;

type

  { TMap }

  TMap = class(TObject)
  public type
    TMapLayer = array of array of TResEnum;
    TIgnoreRes = set of TResEnum;
    TLayerEnum = (lrTile, lrPath, lrDark, lrObj);
  public const
    TileSize = 32;
    MapPlacesCount = 30;
  private const
    MapWidth = 40 + 2;
    MapHeight = 20 + 2;
  private type
    T = 0 .. 9;
  private const
    CityNameTitle: array [T] of TResEnum = (reTitleVorgel, reTitleEntarion,
      reTitleTardum, reTitleTemond, reTitleZerton, reTitleDoran, reTitleKront,
      reTitleHimor, reTitleSodek, reTitleSard);
    CityNameText: array [T] of string = ('Vorgel', 'Entarion', 'Tardum', 'Temond',
      'Zerton', 'Doran', 'Kront', 'Himor', 'Sodek', 'Sard');
  private var
    CityArr: array [T] of integer;
  private
    FMap: array [TLayerEnum] of TMapLayer;
  public
    MapPlace: array [0 .. MapPlacesCount - 1] of TMapPlace;
    constructor Create;
    destructor Destroy; override;
    procedure Clear(const L: TLayerEnum); overload;
    procedure Clear; overload;
    procedure Gen;
    procedure UpdateRadius(const AX, AY, AR: integer; MapLayer: TMapLayer;
      const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []);
    function GetDist(X1, Y1, X2, Y2: integer): integer;
    function GetDistToCapital(const AX, AY: integer): integer;
    function InRect(const X, Y, X1, Y1, X2, Y2: integer): boolean;
    function InMap(const X, Y: integer): boolean;
    function LeaderTile: TResEnum;
    function IsLeaderMove(const X, Y: integer): boolean;
    function Width: integer;
    function Height: integer;
    function GetLayer(const L: TLayerEnum): TMapLayer;
    function GetTile(const L: TLayerEnum; X, Y: integer): TResEnum;
    procedure SetTile(const L: TLayerEnum; X, Y: integer; Tile: TResEnum);
    procedure GenCityName;
    function GetCityName(const I: integer): string;
    function GetCityNameTitleRes(const I: T): TResEnum;
  end;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.Party,
  DisciplesRL.Scenes,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Party;

type
  TGetXYVal = function(X, Y: integer): boolean; stdcall;

function DoAStar(MapX, MapY, FromX, FromY, ToX, ToY: integer;
  Callback: TGetXYVal; var TargetX, TargetY: integer): boolean;
  external 'BeaRLibPF.dll';

function ChTile(X, Y: integer): boolean; stdcall;
begin
  Result := True;
end;

constructor TMapObject.Create(const AX, AY: integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
end;

constructor TMapObject.Create;
begin
  Create(0, 0);
end;

destructor TMapObject.Destroy;
begin

  inherited;
end;

function TMapObject.GetLocation: TLocation;
begin
  Result := FLocation;
end;

procedure TMapObject.SetLocation(const AX, AY: integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
end;

function TMap.GetDist(X1, Y1, X2, Y2: integer): integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

function TMap.GetDistToCapital(const AX, AY: integer): integer;
begin
  Result := GetDist(MapPlace[0].X, MapPlace[0].Y, AX, AY);
end;

function TMap.GetLayer(const L: TLayerEnum): TMapLayer;
begin
  Result := FMap[L];
end;

function TMap.GetTile(const L: TLayerEnum; X, Y: integer): TResEnum;
begin
  if InMap(X, Y) then
    Result := FMap[L][X, Y]
  else
    Result := reNone;
end;

function TMap.Height: integer;
begin
  Result := MapHeight;
end;

procedure TMap.Clear;
var
  L: TLayerEnum;
begin
  for L := Low(TLayerEnum) to High(TLayerEnum) do
  begin
    SetLength(FMap[L], MapWidth, MapHeight);
    Clear(L);
  end;
end;

constructor TMap.Create;
var
  I: integer;
begin
  for I := 0 to High(MapPlace) do
    MapPlace[I] := TMapPlace.Create;
end;

destructor TMap.Destroy;
var
  I: integer;
begin
  inherited;
  for I := 0 to High(MapPlace) do
    FreeAndNil(MapPlace[I]);
end;

procedure TMap.Clear(const L: TLayerEnum);
var
  X, Y: integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
      case L of
        lrTile, lrPath, lrObj:
          FMap[L][X, Y] := reNone;
        lrDark:
          FMap[L][X, Y] := reDark;
      end;
end;

procedure AddCapitalParty;
begin
  TLeaderParty.CapitalPartyIndex := High(Party) + 1;
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] :=
    TParty.Create(Game.Map.MapPlace[0].X, Game.Map.MapPlace[0].Y, TSaga.LeaderRace);
  Party[TSaga.GetPartyCount - 1].AddCreature
  (Characters[TSaga.LeaderRace][cgGuardian][ckGuardian], 3);
end;

procedure AddLeaderParty;
var
  C: TCreatureEnum;
begin
  TLeaderParty.LeaderPartyIndex := High(Party) + 1;
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] :=
    TLeaderParty.Create(Game.Map.MapPlace[0].X, Game.Map.MapPlace[0].Y,
    TSaga.LeaderRace);
  C := Characters[TSaga.LeaderRace][cgLeaders]  [TRaceCharKind(TSceneHire.HireIndex)];
  case TCreature.Character(C).ReachEnum of
    reAdj:
    begin
      Party[TLeaderParty.LeaderPartyIndex].AddCreature(C, 2);
      ActivePartyPosition := 2;
    end
    else
    begin
      Party[TLeaderParty.LeaderPartyIndex].AddCreature(C, 3);
      ActivePartyPosition := 3;
    end;
  end;
end;

procedure TMap.Gen;
var
  X, Y, RX, RY, I: integer;

  procedure AddTree(const X, Y: integer);
  begin
    case Random(6) of
      0:
        FMap[lrObj][X, Y] := reTree1;
      1:
        FMap[lrObj][X, Y] := reTree2;
      2:
        FMap[lrObj][X, Y] := reTree3;
      3:
        FMap[lrObj][X, Y] := reTree4;
      4:
        FMap[lrObj][X, Y] := reTreeOak;
      5:
        FMap[lrObj][X, Y] := reTreePine;
    end;
  end;

  procedure AddMountain(const X, Y: integer);
  begin
    case RandomRange(0, 4) of
      0:
        FMap[lrObj][X, Y] := reMountain1;
      1:
        FMap[lrObj][X, Y] := reMountain2;
      2:
        FMap[lrObj][X, Y] := reMountain3;
      else
        FMap[lrObj][X, Y] := reMountain4;
    end;
  end;

begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
    begin
      FMap[lrTile][X, Y] := reNeutralTerrain;
      if (X = 0) or (X = MapWidth - 1) or (Y = 0) or (Y = MapHeight - 1) then
      begin
        AddMountain(X, Y);
        Continue;
      end;
      case RandomRange(0, 3) of
        0:
          AddTree(X, Y);
        else
          AddMountain(X, Y);
      end;

    end;
  // Capital and Cities
  TMapPlace.Gen;
  RX := 0;
  RY := 0;
  X := MapPlace[0].X;
  Y := MapPlace[0].Y;
  for I := 1 to High(MapPlace) do
  begin
    repeat
      if DoAStar(MapWidth, MapHeight, X, Y, MapPlace[I].X, MapPlace[I].Y,
        @ChTile, RX, RY) then
      begin
        // if (RandomRange(0, 2) = 0) then
        begin
          X := RX + RandomRange(-1, 2);
          Y := RY + RandomRange(-1, 2);
          if FMap[lrObj][X, Y] in MountainTiles then
            FMap[lrObj][X, Y] := reNone;
        end;
        X := RX;
        Y := RY;
        if FMap[lrObj][X, Y] in MountainTiles then
          FMap[lrObj][X, Y] := reNone;
      end;
    until ((X = MapPlace[I].X) and (Y = MapPlace[I].Y));
  end;
  // Mana, Golds and Bags
  for I := 0 to High(MapPlace) div 2 do
  begin
    repeat
      X := RandomRange(2, MapWidth - 2);
      Y := RandomRange(2, MapHeight - 2);
    until (FMap[lrTile][X, Y] = reNeutralTerrain) and (FMap[lrObj][X, Y] = reNone);
    if (GetDistToCapital(X, Y) <= (15 - (Ord(TSaga.Difficulty) * 2))) and
      (RandomRange(0, 9) > 2) then
      case RandomRange(0, 2) of
        0:
          FMap[lrObj][X, Y] := reGold;
        1:
          FMap[lrObj][X, Y] := reMana;
      end
    else
      FMap[lrObj][X, Y] := reBag;
  end;
  // Enemies
  for I := 0 to High(MapPlace) do
  begin
    repeat
      X := RandomRange(1, MapWidth - 1);
      Y := RandomRange(1, MapHeight - 1);
    until (FMap[lrObj][X, Y] = reNone) and (FMap[lrTile][X, Y] =
        reNeutralTerrain) and (GetDistToCapital(X, Y) >= 3);
    TSaga.AddPartyAt(X, Y);
    if (Game.Scenario.CurrentScenario = sgAncientKnowledge) and
      (I < TScenario.ScenarioStoneTabMax) then
      Game.Scenario.AddStoneTab(X, Y);
  end;
  AddCapitalParty;
  AddLeaderParty;
end;

function TMap.InRect(const X, Y, X1, Y1, X2, Y2: integer): boolean;
begin
  Result := (X >= X1) and (Y >= Y1) and (X <= X2) and (Y <= Y2);
end;

function TMap.InMap(const X, Y: integer): boolean;
begin
  Result := InRect(X, Y, 0, 0, MapWidth - 1, MapHeight - 1);
end;

procedure TMap.UpdateRadius(const AX, AY, AR: integer; MapLayer: TMapLayer;
  const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []);
var
  X, Y: integer;
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
            Inc(TSaga.GoldMines);
          // Add Mana Mine
          if (MapLayer = FMap[lrTile]) and
            (FMap[lrObj][AX + X, AY + Y] = reMineMana) and
            (FMap[lrTile][AX + X, AY + Y] = reNeutralTerrain) then
            Inc(TSaga.ManaMines);
          MapLayer[AX + X, AY + Y] := AResEnum;
        end;
end;

function TMap.Width: integer;
begin
  Result := MapWidth;
end;

function TMap.LeaderTile: TResEnum;
begin
  Result := FMap[lrTile][TLeaderParty.Leader.X, TLeaderParty.Leader.Y];
end;

procedure TMap.SetTile(const L: TLayerEnum; X, Y: integer; Tile: TResEnum);
begin
  FMap[L][X, Y] := Tile;
end;

procedure TMap.GenCityName;
var
  N: set of T;
  J, K: integer;
begin
  N := [];
  for K := Low(T) to High(T) do
  begin
    repeat
      J := Random(10);
    until not (J in N);
    N := N + [J];
    CityArr[K] := J;
  end;
end;

function TMap.GetCityName(const I: integer): string;
begin
  Result := CityNameText[CityArr[I]];
end;

function TMap.GetCityNameTitleRes(const I: T): TResEnum;
begin
  Result := CityNameTitle[CityArr[I]];
end;

function TMap.IsLeaderMove(const X, Y: integer): boolean;
begin
  Result := (InRect(X, Y, TLeaderParty.Leader.X - 1, TLeaderParty.Leader.Y -
    1, TLeaderParty.Leader.X + 1, TLeaderParty.Leader.Y + 1) or Game.Wizard) and
    not (FMap[lrObj][X, Y] in StopTiles);
end;

function GetRadius(const N: integer): integer;
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

function ChCity(N: integer): boolean;
var
  I: integer;
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

procedure ClearObj(const AX, AY: integer);
var
  X, Y: integer;
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
  DX, DY, FX, FY, PX, PY, I: integer;
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
        case TSaga.LeaderRace of
          reTheEmpire:
            Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y] :=
              reTheEmpireCapital;
          reUndeadHordes:
            Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y] :=
              reUndeadHordesCapital;
          reLegionsOfTheDamned:
            Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y] :=
              reLegionsOfTheDamnedCapital;
        end;
        ClearObj(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y);
        TMapPlace.UpdateRadius(I);
      end;
      1 .. TScenario.ScenarioCitiesMax: // City
      begin
        Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y] :=
          reNeutralCity;
        ClearObj(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y);
        TSaga.AddPartyAt(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y);
      end;
      TScenario.ScenarioTowerIndex: // Tower
      begin
        Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y] :=
          reTower;
        TSaga.AddPartyAt(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y, True);
      end
      else // Ruin
      begin
        Game.Map.FMap[lrTile][Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y] := reRuin;
        TSaga.AddPartyAt(Game.Map.MapPlace[I].X, Game.Map.MapPlace[I].Y);
      end;
    end;
    // Mines
    repeat
      DX := RandomRange(-2, 2);
      DY := RandomRange(-2, 2);
    until ((DX <> 0) and (DY <> 0));
    repeat
      FX := RandomRange(-2, 2);
      FY := RandomRange(-2, 2);
    until ((FX <> 0) and (FY <> 0) and (FX <> DX) and (FY <> DY));
    case I of
      0 .. TScenario.ScenarioCitiesMax:
      begin
        Game.Map.FMap[lrObj][Game.Map.MapPlace[I].X + DX,
          Game.Map.MapPlace[I].Y + DY] :=
          reMineGold;
        Game.Map.FMap[lrObj][Game.Map.MapPlace[I].X + FX,
          Game.Map.MapPlace[I].Y + FY] :=
          reMineMana;
      end;
    end;
  end;
end;

constructor TMapPlace.Create;
begin
  inherited;
  CurLevel := 0;
  MaxLevel := 2;
  Owner := reNeutrals;
end;

class function TMapPlace.GetIndex(const AX, AY: integer): integer;
var
  I: integer;
begin
  Result := -1;
  for I := 0 to High(Game.Map.MapPlace) do
    if ((Game.Map.MapPlace[I].X = AX) and (Game.Map.MapPlace[I].Y = AY)) then
    begin
      Result := I;
      Break;
    end;
end;

class procedure TMapPlace.UpdateRadius(const AID: integer);
begin
  Game.Map.UpdateRadius(Game.Map.MapPlace[AID].X, Game.Map.MapPlace[AID].Y,
    Game.Map.MapPlace[AID].CurLevel, Game.Map.FMap[lrTile],
    RaceTerrain[TSaga.LeaderRace],
    [reNeutralCity, reRuin, reTower] + Capitals + Cities);
  Game.Map.UpdateRadius(Game.Map.MapPlace[AID].X, Game.Map.MapPlace[AID].Y,
    Game.Map.MapPlace[AID].CurLevel, Game.Map.FMap[lrDark], reNone);
  Game.Map.MapPlace[AID].Owner := TSaga.LeaderRace;
end;

class function TMapPlace.GetCityCount: integer;
var
  I: integer;
begin
  Result := 0;
  for I := 1 to TScenario.ScenarioCitiesMax do
  begin
    if (Game.Map.MapPlace[I].Owner in Races) then
      Inc(Result);
  end;
end;

end.
