unit Elinor.Attribute;

interface

type
  TCurrTempAttribute = record
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

type
  TCurrMaxAttribute = record
  private
    FCurr, FMax: Integer;
  public
    procedure Clear;
    procedure SetValue(const AValue: Integer);
    function GetCurrValue(): Integer;
    function GetMaxValue(): Integer;
    procedure SetToMaxValue;
    procedure SetCurrValue(const AValue: Integer);
    procedure ModifyCurrValue(const AValue: Integer);
    procedure ModifyMaxValue(const AValue: Integer);
    function IsMinCurrValue: Boolean;
    function IsMaxCurrValue: Boolean;
  end;

implementation

uses
  System.Math;

{ TAttribute }

procedure TCurrTempAttribute.ClearFull;
begin
  FCurr := 0;
  FTemp := 0;
end;

procedure TCurrTempAttribute.ClearTemp;
begin
  FTemp := 0;
end;

function TCurrTempAttribute.GetCurrValue: Integer;
begin
  Result := FCurr;
end;

function TCurrTempAttribute.GetFullValue: Integer;
begin
  Result := FCurr + FTemp;
end;

procedure TCurrTempAttribute.ModifyCurrValue(const AValue, AMin, AMax: Integer);
begin
  FCurr := EnsureRange(FCurr + AValue, AMin, AMax);
end;

procedure TCurrTempAttribute.ModifyTempValue(const AValue: Integer);
begin
  FTemp := FTemp + AValue;
end;

procedure TCurrTempAttribute.SetCurrValue(const AValue: Integer);
begin
  FCurr := AValue;
end;

{ TCurrMaxAttribute }

procedure TCurrMaxAttribute.Clear;
begin
  SetValue(0);
end;

function TCurrMaxAttribute.GetCurrValue: Integer;
begin
  Result := FCurr;
end;

function TCurrMaxAttribute.GetMaxValue: Integer;
begin
  Result := FMax;
end;

function TCurrMaxAttribute.IsMaxCurrValue: Boolean;
begin
  Result := FCurr = GetMaxValue;
end;

function TCurrMaxAttribute.IsMinCurrValue: Boolean;
begin
  Result := FCurr <= 0;
end;

procedure TCurrMaxAttribute.ModifyCurrValue(const AValue: Integer);
begin
  FCurr := EnsureRange(FCurr + AValue, 0, GetMaxValue);
end;

procedure TCurrMaxAttribute.ModifyMaxValue(const AValue: Integer);
begin
  FMax := FMax + AValue
end;

procedure TCurrMaxAttribute.SetCurrValue(const AValue: Integer);
begin
  FCurr := AValue;
end;

procedure TCurrMaxAttribute.SetToMaxValue;
begin
  FCurr := GetMaxValue;
end;

procedure TCurrMaxAttribute.SetValue(const AValue: Integer);
begin
  FCurr := AValue;
  FMax := AValue;
end;

end.
