unit Elinor.Attribute;

interface

type
  TAttribute = record
  private
    FCurr, FTemp: Integer;
  public
    procedure ClearFull;
    procedure ClearTemp;
    function GetCurrValue(): Integer;
    function GetFullValue(): Integer;
    procedure SetCurrValue(const AValue: Integer);
    procedure ModifyCurrValue(const AValue, AMin, AMax: Integer);
    procedure ModifyTempValue(const AValue: Integer);
  end;

implementation

uses
  System.Math;

{ TAttribute }

procedure TAttribute.ClearFull;
begin
  FCurr := 0;
  FTemp := 0;
end;

procedure TAttribute.ClearTemp;
begin
  FTemp := 0;
end;

function TAttribute.GetCurrValue: Integer;
begin
  Result := FCurr;
end;

function TAttribute.GetFullValue: Integer;
begin
  Result := FCurr + FTemp;
end;

procedure TAttribute.ModifyCurrValue(const AValue, AMin, AMax: Integer);
begin
  FCurr := EnsureRange(AValue, AMin, AMax);
end;

procedure TAttribute.ModifyTempValue(const AValue: Integer);
begin
  FTemp := FTemp + AValue;
end;

procedure TAttribute.SetCurrValue(const AValue: Integer);
begin
  FCurr := AValue;
end;

end.
