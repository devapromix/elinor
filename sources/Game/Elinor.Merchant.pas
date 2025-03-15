unit Elinor.Merchant;

interface

uses
  Elinor.Items;

type
  TMerchant = class(TObject)
  private
    FInventory: TInventory;
    FGold: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property Inventory: TInventory read FInventory write FInventory;
    property Gold: Integer read FGold write FGold;
    procedure GenNewItems;
    procedure Clear;
  end;

var
  Merchant: TMerchant;

implementation

uses
  System.Math,
  System.SysUtils;

{ TMerchant }

procedure TMerchant.Clear;
begin
  GenNewItems;
end;

constructor TMerchant.Create;
begin
  FInventory := TInventory.Create;
end;

destructor TMerchant.Destroy;
begin
  FreeAndNil(FInventory);
  inherited;
end;

procedure TMerchant.GenNewItems;
begin
  FGold := RandomRange(9, 12) * 100;

end;

initialization

Merchant := TMerchant.Create;

finalization

FreeAndNil(Merchant);

end.
