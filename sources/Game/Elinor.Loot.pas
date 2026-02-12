unit Elinor.Loot;

interface

uses
  Elinor.Items;

type
  TLootType = (ltNone, ltGold, ltMana, ltItem, ltStoneTab);

type
  TLootItem = record
    X, Y: Integer;
    ItemEnum: TItemEnum;
    LootType: TLootType;
    Amount: Integer;
  end;

type
  TLoot = class(TObject)
  private
    FLootItem: array of TLootItem;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    function CountAt(const AX, AY: Integer): Integer;
    procedure Clear; overload;
    procedure Clear(const AItemIndex: Integer); overload;
    procedure AddGoldAt(const AX, AY: Integer);
    procedure AddManaAt(const AX, AY: Integer);
    procedure AddItemAt(const AX, AY: Integer);
    procedure AddStoneTabAt(const AX, AY: Integer);
    procedure AddGemAt(const AX, AY: Integer);
    function GetItemIndex(const AX, AY: Integer): Integer; overload;
    function GetItemIndex(const AX, AY, AIndex: Integer): Integer; overload;
    function GetLootItem(const AItemIndex: Integer): TLootItem; overload;
    function GetLootItem(const AX, AY: Integer): TLootItem; overload;
    procedure AttemptToPlaceLootObject;
  end;

var
  Loot: TLoot;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenes,
  Elinor.Map,
  Elinor.Party,
  Elinor.Resources;

{ TLoot }

const
  CMaxLevel = 8;

procedure TLoot.AddGemAt(const AX, AY: Integer);
var
  LLevel, LItemIndex: Integer;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  LLevel := EnsureRange(TMap.GetTileLevel(AX, AY), 1, CMaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    repeat
      LItemIndex := RandomRange(1, TItemBase.Count);
    until (TItemBase.Item(LItemIndex).Level <= LLevel) and
      (TItemBase.Item(LItemIndex).ItType = itGemstone);
    ItemEnum := TItemBase.Item(LItemIndex).Enum;
    LootType := ltItem;
    Amount := 1;
  end;
end;

procedure TLoot.AddGoldAt(const AX, AY: Integer);
var
  LLevel: Integer;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  LLevel := EnsureRange(TMap.GetTileLevel(AX, AY), 1, CMaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    ItemEnum := iGold;
    LootType := ltGold;
    Amount := RandomRange(LLevel * 2, LLevel * 4) * 10;
  end;
end;

procedure TLoot.AddItemAt(const AX, AY: Integer);
var
  LLevel, LItemIndex: Integer;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  LLevel := EnsureRange(TMap.GetTileLevel(AX, AY), 1, CMaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    repeat
      LItemIndex := RandomRange(1, TItemBase.Count);
    until (TItemBase.Item(LItemIndex).Level <= LLevel) and
      (TItemBase.Item(LItemIndex).ItType <> itSpecial);
    ItemEnum := TItemBase.Item(LItemIndex).Enum;
    LootType := ltItem;
    Amount := 1;
  end;
end;

procedure TLoot.AddManaAt(const AX, AY: Integer);
var
  LLevel: Integer;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  LLevel := EnsureRange(TMap.GetTileLevel(AX, AY), 1, CMaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    ItemEnum := iMana;
    LootType := ltMana;
    Amount := RandomRange(LLevel * 1, LLevel * 3);
  end;
end;

procedure TLoot.AddStoneTabAt(const AX, AY: Integer);
var
  LLevel: Integer;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  LLevel := EnsureRange(TMap.GetTileLevel(AX, AY), 1, CMaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    ItemEnum := iStoneTab;
    LootType := ltStoneTab;
    Amount := 1;
  end;
end;

procedure TLoot.AttemptToPlaceLootObject;
var
  LItemIndex, LX, LY: Integer;
begin
  LX := TLeaderParty.Leader.X;
  LY := TLeaderParty.Leader.Y;
  Game.Map.SetTile(lrObj, LX, LY, reNone);
  LItemIndex := Loot.GetItemIndex(LX, LY);
  if LItemIndex >= 0 then
    case FLootItem[LItemIndex].LootType of
      ltGold:
        Game.Map.SetTile(lrObj, LX, LY, reGold);
      ltMana:
        Game.Map.SetTile(lrObj, LX, LY, reMana);
    else
      Game.Map.SetTile(lrObj, LX, LY, reBag);
    end;
end;

procedure TLoot.Clear;
begin
  SetLength(FLootItem, 0);
end;

procedure TLoot.Clear(const AItemIndex: Integer);
begin
  with FLootItem[AItemIndex] do
  begin
    X := 0;
    Y := 0;
    ItemEnum := iNone;
    LootType := ltNone;
    Amount := 0;
  end;
end;

function TLoot.CountAt(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if (FLootItem[I].X = AX) and (FLootItem[I].Y = AY) then
      Inc(Result);
end;

function TLoot.Count: Integer;
begin
  Result := Length(FLootItem);
end;

constructor TLoot.Create;
begin

end;

destructor TLoot.Destroy;
begin
  SetLength(FLootItem, 0);
  inherited;
end;

function TLoot.GetItemIndex(const AX, AY, AIndex: Integer): Integer;
var
  I, LIndex: Integer;
begin
  Result := -1;
  LIndex := 0;
  for I := 0 to Count - 1 do
    if (FLootItem[I].X = AX) and (FLootItem[I].Y = AY) then
    begin
      if LIndex = AIndex then
        Exit(I)
      else
        Inc(LIndex);
    end;
end;

function TLoot.GetLootItem(const AX, AY: Integer): TLootItem;
var
  LItemIndex: Integer;
begin
  LItemIndex := GetItemIndex(AX, AY);
  Result := GetLootItem(LItemIndex);
end;

function TLoot.GetLootItem(const AItemIndex: Integer): TLootItem;
begin
  Result := FLootItem[AItemIndex];
end;

function TLoot.GetItemIndex(const AX, AY: Integer): Integer;
var
  LItemIndex: Integer;
begin
  Result := -1;
  for LItemIndex := 0 to Count - 1 do
    if (FLootItem[LItemIndex].X = AX) and (FLootItem[LItemIndex].Y = AY) then
      Exit(LItemIndex);
end;

initialization

Loot := TLoot.Create;

finalization

FreeAndNil(Loot);

end.
