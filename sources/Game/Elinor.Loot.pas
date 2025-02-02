unit Elinor.Loot;

interface

uses
  Elinor.Items;

type
  TLootType = (ltGold, ltMana, ltItem);

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
    procedure Clear;
    procedure AddGoldAt(const AX, AY: Integer);
    procedure AddManaAt(const AX, AY: Integer);
    procedure AddItemAt(const AX, AY: Integer);
    function Count: Integer;
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
    Amount := RandomRange(LLevel * 7, LLevel * 10) * 10;
  end;
end;

procedure TLoot.AddItemAt(const AX, AY: Integer);
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
    LootType := ltItem;
    Amount := RandomRange(LLevel * 7, LLevel * 10) * 10;
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
    Amount := RandomRange(LLevel * 7, LLevel * 10) * 10;
  end;
end;

procedure TLoot.Clear;
begin
  SetLength(FLootItem, 0);
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

initialization

Loot := TLoot.Create;

finalization

FreeAndNil(Loot);

end.
