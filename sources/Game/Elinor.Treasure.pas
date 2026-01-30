unit Elinor.Treasure;

interface

type
  TTreasure = class(TObject)
  private
    FValuePerDay: Integer;
  public
    Value: Integer;
    Mines: Integer;
    NewValue: Integer;
    constructor Create(const ValuePerDay: Integer);
    procedure Clear(const StartValue: Integer);
    procedure Modify(Amount: Integer);
    procedure Mine;
    function FromMinePerDay: Integer;
    procedure AddMine;
  end;

implementation

{ TTreasure }

constructor TTreasure.Create(const ValuePerDay: Integer);
begin
  FValuePerDay := ValuePerDay;
end;

procedure TTreasure.Clear(const StartValue: Integer);
begin
  Value := StartValue;
  Mines := 0;
  NewValue := 0;
end;

procedure TTreasure.Modify(Amount: Integer);
begin
  Value := Value + Amount;
end;

procedure TTreasure.Mine;
begin
  Modify(FromMinePerDay);
end;

function TTreasure.FromMinePerDay: Integer;
begin
  Result := Mines * FValuePerDay;
end;

procedure TTreasure.AddMine;
begin
  Inc(Mines);
end;

end.
