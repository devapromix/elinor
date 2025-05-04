unit Elinor.Merchant;

interface

uses
  System.Generics.Collections,
  Elinor.Items;

type
  TMerchantType = (mtPotions, mtArtifacts);

  TMerchant = class(TObject)
  private
    FGold: Integer;
    FInventory: TInventory;
    FMerchantType: TMerchantType;
  protected
    procedure GenerateGold; virtual; abstract;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Inventory: TInventory read FInventory write FInventory;
    property Gold: Integer read FGold;
    property MerchantType: TMerchantType read FMerchantType;
    procedure GenNewItems; virtual; abstract;
    procedure Clear; virtual;
    procedure ModifyGold(AAmount: Integer);
    procedure AddRandomItems(const AItemEnum: TItemEnum;
      const AMin, AMax: Integer);
  end;

  TPotionMerchant = class(TMerchant)
  protected
    procedure GenerateGold; override;
  public
    constructor Create; override;
    procedure GenNewItems; override;
  end;

  TArtifactMerchant = class(TMerchant)
  protected
    procedure GenerateGold; override;
  public
    constructor Create; override;
    procedure GenNewItems; override;
  end;

  TMerchants = class(TObject)
  private
    FMerchantList: TObjectList<TMerchant>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GetMerchant(AMerchantType: TMerchantType): TMerchant;
  end;

var
  Merchants: TMerchants;

implementation

uses
  System.Math,
  System.SysUtils;

{ TMerchant }

constructor TMerchant.Create;
begin
  FInventory := TInventory.Create;
  GenerateGold;
  GenNewItems;
end;

destructor TMerchant.Destroy;
begin
  FreeAndNil(FInventory);
  inherited;
end;

procedure TMerchant.AddRandomItems(const AItemEnum: TItemEnum;
  const AMin, AMax: Integer);
var
  I, LAmount: Integer;
begin
  LAmount := RandomRange(AMin, AMax + 1);
  for I := 1 to LAmount do
    FInventory.Add(TItemBase.Item(AItemEnum));
end;

procedure TMerchant.Clear;
begin
  GenerateGold;
  GenNewItems;
end;

procedure TMerchant.ModifyGold(AAmount: Integer);
begin
  FGold := FGold + AAmount;
end;

{ TPotionMerchant }

constructor TPotionMerchant.Create;
begin
  FMerchantType := mtPotions;
  inherited;
end;

procedure TPotionMerchant.GenerateGold;
begin
  FGold := 0;
  ModifyGold(RandomRange(9, 12) * 100);
end;

procedure TPotionMerchant.GenNewItems;
begin
  FInventory.Clear;
  AddRandomItems(iLifePotion, 1, 2);
  AddRandomItems(iPotionOfHealing, 2, 4);
  AddRandomItems(iPotionOfRestoration, 1, 2);
  AddRandomItems(iHealingOintment, 1, 1);
end;

{ TArtifactMerchant }

constructor TArtifactMerchant.Create;
begin
  FMerchantType := mtArtifacts;
  inherited;
end;

procedure TArtifactMerchant.GenerateGold;
begin
  FGold := 0;
  ModifyGold(RandomRange(20, 30) * 100);
end;

procedure TArtifactMerchant.GenNewItems;
begin
  FInventory.Clear;
  AddRandomItems(iDwarvenBracer, 1, 1);
  AddRandomItems(iRunestone, 1, 1);
  AddRandomItems(iHornOfAwareness, 1, 1);
end;

{ TMerchants }

constructor TMerchants.Create;
begin
  FMerchantList := TObjectList<TMerchant>.Create(True);
  FMerchantList.Add(TPotionMerchant.Create);
  FMerchantList.Add(TArtifactMerchant.Create);
end;

destructor TMerchants.Destroy;
begin
  FreeAndNil(FMerchantList);
  inherited;
end;

function TMerchants.GetMerchant(AMerchantType: TMerchantType): TMerchant;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FMerchantList.Count - 1 do
    if FMerchantList[I].MerchantType = AMerchantType then
    begin
      Result := FMerchantList[I];
      Break;
    end;
end;

procedure TMerchants.Clear;
var
  I: Integer;
begin
  for I := 0 to FMerchantList.Count - 1 do
    FMerchantList[I].Clear;
end;

initialization

Merchants := TMerchants.Create;

finalization

FreeAndNil(Merchants);

end.
