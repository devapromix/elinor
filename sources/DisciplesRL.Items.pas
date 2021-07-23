unit DisciplesRL.Items;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

// Предметы в Д1 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=328
// Предметы в Д2 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=223
// Список предм. -- https://www.ign.com/faqs/2005/disciples-ii-rise-of-the-elves-items-listfaq-677342
uses
  DisciplesRL.Resources;

type
  TItemType = (itSpecial, itValuable, itArtifact, itJewel,
    // Potions
    itTemporaryPotion, itPermanentPotion, itHealingPotion, itBoostPotion,
    // Scrolls
    itScroll,
    // Equipable
    itArmor, itWand, itOrb, itTalisman, itBoots, itBanner, itTome);

type
  TItemProp = (ipEquipable, ipConsumable, ipReadable, ipUsable, ipPermanent,
    ipTemporary);

type
  TItemEffect = (ieNone);

type
  TItemEnum = (iNone);

type
  TItem = record
    Enum: TItemEnum;
    Name: string;
    ItType: TItemType;
  end;

const
  MaxInventoryItems = 12;

type
  TInventory = class(TObject)
  private
    FItem: array [0 .. MaxInventoryItems - 1] of TItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    function Item(const I: Integer): TItem;
    function ItemEnum(const I: Integer): TItemEnum;
    procedure Add(const AItem: TItem); overload;
    procedure Add(const AItemEnum: TItemEnum); overload;
  end;

implementation

uses
  SysUtils;

const
  ItemBase: array [TItemEnum] of TItem = (
    // None
    (Enum: iNone; Name: ''; ItType: itSpecial;)
    //
    );

  { TInventory }

procedure TInventory.Add(const AItem: TItem);
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum = iNone then
    begin
      FItem[I] := AItem;
      Exit;
    end;
end;

procedure TInventory.Add(const AItemEnum: TItemEnum);
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum = iNone then
    begin
      FItem[I] := ItemBase[AItemEnum];
      Exit;
    end;
end;

procedure TInventory.Clear;
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    FItem[I] := ItemBase[iNone];
end;

function TInventory.Count: Integer;
begin

end;

constructor TInventory.Create;
begin
  Self.Clear;
end;

destructor TInventory.Destroy;
begin

  inherited;
end;

function TInventory.Item(const I: Integer): TItem;
begin
  Result := FItem[I];
end;

function TInventory.ItemEnum(const I: Integer): TItemEnum;
begin
  Result := FItem[I].Enum;
end;

end.
