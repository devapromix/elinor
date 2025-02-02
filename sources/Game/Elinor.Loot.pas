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
    Amount: Cardinal;
  end;

type
  TLoot = class(TObject)
  private
    FLootItem: array of TLootItem;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    procedure Clear; overload;
    procedure Clear(const AItemIndex: Integer); overload;
    procedure AddGoldAt(const AX, AY: Integer);
    procedure AddManaAt(const AX, AY: Integer);
    procedure AddItemAt(const AX, AY: Integer);
    procedure AddStoneTabAt(const AX, AY: Integer);
    function GetItemIndex(const AX, AY: Integer): Integer;
    function GetLootItem(const AItemIndex: Integer): TLootItem; overload;
    function GetLootItem(const AX, AY: Integer): TLootItem; overload;
  end;

var
  Loot: TLoot;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenes;

{ TLoot }

const
  MaxLevel = 8;

procedure TLoot.AddGoldAt(const AX, AY: Integer);
var
  LLevel: Integer;
begin
  if not Game.Map.InMap(AX, AY) then
    Exit;
  LLevel := EnsureRange(TSaga.GetTileLevel(AX, AY), 1, MaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    ItemEnum := iNone;
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
  LLevel := EnsureRange(TSaga.GetTileLevel(AX, AY), 1, MaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    repeat
      LItemIndex := RandomRange(1, TItemBase.Count);
    until (TItemBase.Item(LItemIndex).Level <= LLevel);
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
  LLevel := EnsureRange(TSaga.GetTileLevel(AX, AY), 1, MaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    ItemEnum := iNone;
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
  LLevel := EnsureRange(TSaga.GetTileLevel(AX, AY), 1, MaxLevel);
  SetLength(FLootItem, Count() + 1);
  with FLootItem[Count - 1] do
  begin
    X := AX;
    Y := AY;
    ItemEnum := iNone;
    LootType := ltStoneTab;
    Amount := 1;
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
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (FLootItem[I].X = AX) and (FLootItem[I].Y = AY) then
      Exit(I);
end;

initialization

Loot := TLoot.Create;

finalization

FreeAndNil(Loot);

end.
