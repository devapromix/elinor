unit DisciplesRL.Map;

interface

uses
  DisciplesRL.Creatures,
  DisciplesRL.Resources,
  DisciplesRL.Saga,
  DisciplesRL.Party;

{$IFDEF FPC}

type
  TLayerEnum = (lrTile, lrPath, lrDark, lrObj);

type
  TMapLayer = array of array of Cardinal;

 type
  TPlace = record
    X, Y: Integer;
    CurLevel: Integer;
    MaxLevel: Integer;
    Owner: TRaceEnum;
    //class function GetIndex(const AX, AY: Integer): Integer; static;
    // class procedure UpdateRadius(const AID: Integer); static;
    //class function GetCityCount: Integer; static;
    //class procedure Gen; static;
  end;

type

  { TMap }

  TMap = class(TObject)
  private
    FTileSize: Byte;
    FWidth: Word;
    FHeight: Word;
    FMap: array [TLayerEnum] of TMapLayer;
    procedure AddTree(const X, Y: Integer);
    procedure AddMountain(const X, Y: Integer);
  public
    class var Place: array [0 .. TScenario.ScenarioPlacesMax - 1] of TPlace;
    constructor Create;
    procedure Gen;
    procedure Clear; overload;
    procedure Clear(const L: TLayerEnum); overload;
    function InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
    function InMap(const X, Y: Integer): Boolean;
    property TileSize: Byte read FTileSize;
    property Width: Word read FWidth;
    property Height: Word read FHeight;
    function GetTile(const L: TLayerEnum; X, Y: Integer): Cardinal;
    procedure SetTile(const L: TLayerEnum; X, Y: Integer; Tile: Cardinal);
    class function GetDist(X1, Y1, X2, Y2: Integer): Integer;
  end;

{$ELSE}

type
  TPlace = record
    X, Y: Integer;
    CurLevel: Integer;
    MaxLevel: Integer;
    Owner: TRaceEnum;
    class function GetIndex(const AX, AY: Integer): Integer; static;
    class procedure UpdateRadius(const AID: Integer); static;
    class function GetCityCount: Integer; static;
    class procedure Gen; static;
  end;

type
  TMap = class(TObject)
  public type
    TMapLayer = array of array of TResEnum;
    TIgnoreRes = set of TResEnum;
    TLayerEnum = (lrTile, lrPath, lrDark, lrObj);
  public const
    TileSize = 32;
  public
    class var Place: array [0 .. TScenario.ScenarioPlacesMax - 1] of TPlace;
    class var Map: array [TLayerEnum] of TMapLayer;
    class procedure Clear(const L: TLayerEnum);
    class procedure Init; static;
    class procedure Gen; static;
    class procedure UpdateRadius(const AX, AY, AR: Integer; var MapLayer: TMapLayer; const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []);
    class function GetDist(X1, Y1, X2, Y2: Integer): Integer;
    class function GetDistToCapital(const AX, AY: Integer): Integer;
    class function InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
    class function InMap(const X, Y: Integer): Boolean;
    class function LeaderTile: TResEnum;
    class function IsLeaderMove(const X, Y: Integer): Boolean;
    class function Width: Integer;
    class function Height: Integer;
  end;

{$ENDIF}

implementation

{$IFDEF FPC}

uses
  Math;

{ TMap }

class function TMap.GetDist(X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

function TMap.InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
begin
  Result := (X >= X1) and (Y >= Y1) and (X <= X2) and (Y <= Y2);
end;

function TMap.InMap(const X, Y: Integer): Boolean;
begin
  Result := InRect(X, Y, 0, 0, FWidth - 1, FHeight - 1);
end;

procedure TMap.AddTree(const X, Y: Integer);
begin
  case Random(2) of
      0:
        FMap[lrObj][X, Y] := reTreePine;
      1:
        FMap[lrObj][X, Y] := reTreeOak;
  end;
end;

procedure TMap.AddMountain(const X, Y: Integer);
begin
  case Random(3) of
      0:
        FMap[lrObj][X, Y] := reMountain1;
      1:
        FMap[lrObj][X, Y] := reMountain2;
      2:
        FMap[lrObj][X, Y] := reMountain3;
  end;
end;

constructor TMap.Create;
begin
  FWidth := 28 + 2; //40 + 2;
  FHeight := 20 + 2;
  FTileSize := 32;
end;

procedure TMap.Gen;
var
  X, Y: Integer;
begin
  Clear;
  for Y := 0 to Height - 1 do
    for X := 0 to Width - 1 do
    begin
      FMap[lrTile][X, Y] := reNeutralTerrain;
      if (X = 0) or (X = Width - 1) or (Y = 0) or (Y = Height - 1) then
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
end;

procedure TMap.Clear;
var
  L: TLayerEnum;
begin
  for L := Low(TLayerEnum) to High(TLayerEnum) do
  begin
    SetLength(FMap[L], Width, Height);
    Clear(L);
  end;
end;

procedure TMap.Clear(const L: TLayerEnum);
var
  X, Y: Integer;
begin
  for Y := 0 to Height - 1 do
    for X := 0 to Width - 1 do
      case L of
        lrTile, lrPath, lrObj:
          FMap[L][X, Y] := 0;
        lrDark:
          FMap[L][X, Y] := 0;
      end;
end;

function TMap.GetTile(const L: TLayerEnum; X, Y: Integer): Cardinal;
begin
  if InMap(X, Y) then
    Result := FMap[L][X, Y]
  else
    Result := 0;
end;

procedure TMap.SetTile(const L: TLayerEnum; X, Y: Integer; Tile: Cardinal);
begin
  FMap[L][X, Y] := Tile;
end;

{$ELSE}

uses
  Vcl.Dialogs,
  System.Math,
  System.SysUtils,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Party,
  PathFind;

var
  MapWidth: Integer = 40 + 2;
  MapHeight: Integer = 20 + 2;

class function TMap.GetDist(X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

class function TMap.GetDistToCapital(const AX, AY: Integer): Integer;
begin
  Result := GetDist(TMap.Place[0].X, TMap.Place[0].Y, AX, AY);
end;

class function TMap.Height: Integer;
begin
  Result := MapHeight;
end;

class procedure TMap.Init;
var
  L: TLayerEnum;
  I: Integer;
begin
  for L := Low(TLayerEnum) to High(TLayerEnum) do
  begin
    SetLength(Map[L], MapWidth, MapHeight);
    Clear(L);
  end;
  for I := 0 to High(TMap.Place) do
  begin
    TMap.Place[I].X := 0;
    TMap.Place[I].Y := 0;
    TMap.Place[I].CurLevel := 0;
    TMap.Place[I].MaxLevel := 2;
    TMap.Place[I].Owner := reNeutrals;
  end;
end;

class procedure TMap.Clear(const L: TLayerEnum);
var
  X, Y: Integer;
begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
      case L of
        lrTile, lrPath, lrObj:
          Map[L][X, Y] := reNone;
        lrDark:
          Map[L][X, Y] := reDark;
      end;
end;

function ChTile(X, Y: Integer): Boolean; stdcall;
begin
  Result := True;
end;

procedure AddCapitalParty;
begin
  TLeaderParty.CapitalPartyIndex := High(Party) + 1;
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TParty.Create(TMap.Place[0].X, TMap.Place[0].Y, TSaga.LeaderRace);
  Party[TSaga.GetPartyCount - 1].AddCreature(Characters[TSaga.LeaderRace][cgGuardian][ckGuardian], 3);
end;

procedure AddLeaderParty;
var
  C: TCreatureEnum;
begin
  TLeaderParty.LeaderPartyIndex := High(Party) + 1;
  SetLength(Party, TSaga.GetPartyCount + 1);
  Party[TSaga.GetPartyCount - 1] := TLeaderParty.Create(TMap.Place[0].X, TMap.Place[0].Y, TSaga.LeaderRace);
  C := Characters[TSaga.LeaderRace][cgLeaders][TRaceCharKind(HireIndex)];
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

class procedure TMap.Gen;
var
  X, Y, RX, RY, I: Integer;

  procedure AddTree(const X, Y: Integer);
  begin
    case Random(2) of
      0:
        Map[lrObj][X, Y] := reTreePine;
      1:
        Map[lrObj][X, Y] := reTreeOak;
    end;
  end;

  procedure AddMountain(const X, Y: Integer);
  begin
    case Random(3) of
      0:
        Map[lrObj][X, Y] := reMountain1;
      1:
        Map[lrObj][X, Y] := reMountain2;
      2:
        Map[lrObj][X, Y] := reMountain3;
    end;
  end;

begin
  for Y := 0 to MapHeight - 1 do
    for X := 0 to MapWidth - 1 do
    begin
      Map[lrTile][X, Y] := reNeutralTerrain;
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
  TPlace.Gen;
  X := TMap.Place[0].X;
  Y := TMap.Place[0].Y;
  for I := 1 to High(TMap.Place) do
  begin
    repeat
      if IsPathFind(MapWidth, MapHeight, X, Y, TMap.Place[I].X, TMap.Place[I].Y, ChTile, RX, RY) then
      begin
        // if (RandomRange(0, 2) = 0) then
        begin
          X := RX + RandomRange(-1, 2);
          Y := RY + RandomRange(-1, 2);
          if Map[lrObj][X, Y] in MountainTiles then
            Map[lrObj][X, Y] := reNone;
        end;
        X := RX;
        Y := RY;
        if Map[lrObj][X, Y] in MountainTiles then
          Map[lrObj][X, Y] := reNone;
      end;
    until ((X = TMap.Place[I].X) and (Y = TMap.Place[I].Y));
  end;
  // Golds and Bags
  for I := 0 to High(TMap.Place) div 2 do
  begin
    repeat
      X := RandomRange(2, MapWidth - 2);
      Y := RandomRange(2, MapHeight - 2);
    until (Map[lrTile][X, Y] = reNeutralTerrain) and (Map[lrObj][X, Y] = reNone);
    if (GetDistToCapital(X, Y) <= 15) and (RandomRange(0, 9) > 2) then
      Map[lrObj][X, Y] := reGold
    else
      Map[lrObj][X, Y] := reBag;
  end;
  // Enemies
  for I := 0 to High(TMap.Place) do
  begin
    repeat
      X := RandomRange(1, MapWidth - 1);
      Y := RandomRange(1, MapHeight - 1);
    until (Map[lrObj][X, Y] = reNone) and (Map[lrTile][X, Y] = reNeutralTerrain) and (GetDistToCapital(X, Y) >= 3);
    TSaga.AddPartyAt(X, Y);
    if (TScenario.CurrentScenario = sgAncientKnowledge) and (I < TScenario.ScenarioStoneTabMax) then
      TScenario.AddStoneTab(X, Y);
  end;
  AddCapitalParty;
  AddLeaderParty;
end;

class function TMap.InRect(const X, Y, X1, Y1, X2, Y2: Integer): Boolean;
begin
  Result := (X >= X1) and (Y >= Y1) and (X <= X2) and (Y <= Y2);
end;

class function TMap.InMap(const X, Y: Integer): Boolean;
begin
  Result := InRect(X, Y, 0, 0, MapWidth - 1, MapHeight - 1);
end;

class procedure TMap.UpdateRadius(const AX, AY, AR: Integer; var MapLayer: TMapLayer; const AResEnum: TResEnum; IgnoreRes: TIgnoreRes = []);
var
  X, Y: Integer;
begin
  for Y := -AR to AR do
    for X := -AR to AR do
      if (GetDist(AX + X, AY + Y, AX, AY) <= AR) and TMap.InMap(AX + X, AY + Y) then
        if (MapLayer[AX + X, AY + Y] in IgnoreRes) then
          Continue
        else
        begin
          // Add mine
          if (MapLayer = Map[lrTile]) and (Map[lrObj][AX + X, AY + Y] = reMine) and (Map[lrTile][AX + X, AY + Y] = reNeutralTerrain) then
            Inc(TSaga.GoldMines);
          MapLayer[AX + X, AY + Y] := AResEnum;
        end;
end;

class function TMap.Width: Integer;
begin
  Result := MapWidth;
end;

class function TMap.LeaderTile: TResEnum;
begin
  Result := Map[lrTile][TLeaderParty.Leader.X, TLeaderParty.Leader.Y];
end;

class function TMap.IsLeaderMove(const X, Y: Integer): Boolean;
begin
  Result := (InRect(X, Y, TLeaderParty.Leader.X - 1, TLeaderParty.Leader.Y - 1, TLeaderParty.Leader.X + 1, TLeaderParty.Leader.Y + 1) or TSaga.Wizard)
    and not(Map[lrObj][X, Y] in StopTiles);
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
    if (TMap.GetDist(TMap.Place[I].X, TMap.Place[I].Y, TMap.Place[N].X, TMap.Place[N].Y) <= GetRadius(N)) then
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
          TMap.Map[lrObj][X, Y] := reNone
      end
      else
        TMap.Map[lrObj][X, Y] := reNone;
end;

{ TPlace }

class procedure TPlace.Gen;
var
  DX, DY, I: Integer;
begin
  for I := 0 to High(TMap.Place) do
  begin
    repeat
      TMap.Place[I].X := RandomRange(3, MapWidth - 3);
      TMap.Place[I].Y := RandomRange(3, MapHeight - 3);
    until ChCity(I);
    case I of
      0: // Capital
        begin
          case TSaga.LeaderRace of
            reTheEmpire:
              TMap.Map[lrTile][TMap.Place[I].X, TMap.Place[I].Y] := reTheEmpireCapital;
            reUndeadHordes:
              TMap.Map[lrTile][TMap.Place[I].X, TMap.Place[I].Y] := reUndeadHordesCapital;
            reLegionsOfTheDamned:
              TMap.Map[lrTile][TMap.Place[I].X, TMap.Place[I].Y] := reLegionsOfTheDamnedCapital;
          end;
          ClearObj(TMap.Place[I].X, TMap.Place[I].Y);
          TPlace.UpdateRadius(I);
        end;
      1 .. TScenario.ScenarioCitiesMax: // City
        begin
          TMap.Map[lrTile][TMap.Place[I].X, TMap.Place[I].Y] := reNeutralCity;
          ClearObj(TMap.Place[I].X, TMap.Place[I].Y);
          TSaga.AddPartyAt(TMap.Place[I].X, TMap.Place[I].Y);
        end;
      TScenario.ScenarioTowerIndex: // Tower
        begin
          TMap.Map[lrTile][TMap.Place[I].X, TMap.Place[I].Y] := reTower;
          TSaga.AddPartyAt(TMap.Place[I].X, TMap.Place[I].Y, True);
        end
    else // Ruin
      begin
        TMap.Map[lrTile][TMap.Place[I].X, TMap.Place[I].Y] := reRuin;
        TSaga.AddPartyAt(TMap.Place[I].X, TMap.Place[I].Y);
      end;
    end;
    // Mine
    repeat
      DX := RandomRange(-2, 2);
      DY := RandomRange(-2, 2);
    until ((DX <> 0) and (DY <> 0));
    case I of
      0 .. TScenario.ScenarioCitiesMax:
        TMap.Map[lrObj][TMap.Place[I].X + DX, TMap.Place[I].Y + DY] := reMine;
    end;
  end;
end;

class function TPlace.GetIndex(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(TMap.Place) do
    if ((TMap.Place[I].X = AX) and (TMap.Place[I].Y = AY)) then
    begin
      Result := I;
      Break;
    end;
end;

class procedure TPlace.UpdateRadius(const AID: Integer);
begin
  TMap.UpdateRadius(TMap.Place[AID].X, TMap.Place[AID].Y, TMap.Place[AID].CurLevel, TMap.Map[lrTile], RaceTerrain[TSaga.LeaderRace],
    [reNeutralCity, reRuin, reTower] + Capitals + Cities);
  TMap.UpdateRadius(TMap.Place[AID].X, TMap.Place[AID].Y, TMap.Place[AID].CurLevel, TMap.Map[lrDark], reNone);
  TMap.Place[AID].Owner := TSaga.LeaderRace;
end;

class function TPlace.GetCityCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to TScenario.ScenarioCitiesMax do
  begin
    if (TMap.Place[I].Owner in Races) then
      Inc(Result);
  end;
end;

{$ENDIF}

end.
