unit DisciplesRL.Common;

interface

{$IFDEF FPC}
{$MODE DELPHI}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

uses
  TypInfo,
  Variants;

type

  { TEnumCycler }

  TEnumCycler<T> = record
  private
    FMinValue: Integer;
    FMaxValue: Integer;
    FValue: Integer;
    FEnumeratorTypeInfo: PTypeInfo;
    function Cycle(Cond, Limit, Change: Integer; DoSave: Boolean = False): Integer;
  public
    constructor Create(AInitialValue: Integer; AMinValue: Integer = -1;
      AMaxValue: Integer = -1);
    function Next(): T;
    function Prev(): T;
    function NextAsValue(): Integer;
    function PrevAsValue(): Integer;
  end;

//function IIF(Condition: Boolean; IfTrue: Variant; IfFalse: Variant): Variant;

implementation

uses
  Math,
  Rtti;

function IIF(Condition: Boolean; IfTrue: Variant; IfFalse: Variant): Variant;
begin
  if Condition then
    Result := IfTrue
  else
    Result := IfFalse;
end;

{ TEnumCycler }

constructor TEnumCycler<T>.Create(AInitialValue: Integer; AMinValue: Integer = -1;
  AMaxValue: Integer = -1);
var
  LEnumerationTypeData: PTypeData;
  LEnumeratorTypeInfo: PTypeInfo;
begin
  LEnumeratorTypeInfo := TypeInfo(T);
  Assert(LEnumeratorTypeInfo^.Kind = tkEnumeration);
  LEnumerationTypeData := GetTypeData(LEnumeratorTypeInfo);
  FMinValue := IfThen(AMinValue < 0, LEnumerationTypeData^.MinValue, AMinValue);
  FMaxValue := IfThen(AMaxValue < 0, LEnumerationTypeData^.MaxValue, AMaxValue);
  Assert((AInitialValue >= FMinValue) and (AInitialValue <= FMaxValue));
  FValue := AInitialValue;
  FEnumeratorTypeInfo := LEnumeratorTypeInfo;
end;

function TEnumCycler<T>.Cycle(Cond, Limit, Change: Integer; DoSave: Boolean = False): Integer;
begin
  Result := IfThen(FValue = Cond, Limit, Change);
  FValue := IfThen(DoSave, Result, FValue);
end;

function TEnumCycler<T>.Next(): T;
begin
  Result :=
  {$IFDEF FPC}
    T(NextAsValue);
  {$ELSE}
    TValue.FromOrdinal(FEnumeratorTypeInfo, NextAsValue).AsType<T>();
  {$ENDIF}
end;

function TEnumCycler<T>.Prev(): T;
begin
  Result :=
  {$IFDEF FPC}
    T(PrevAsValue);
  {$ELSE}
    TValue.FromOrdinal(FEnumeratorTypeInfo, PrevAsValue).AsType<T>();
  {$ENDIF}
end;

function TEnumCycler<T>.NextAsValue(): Integer;
begin
  Result := Cycle(FMaxValue, FMinValue, Succ(FValue));
end;

function TEnumCycler<T>.PrevAsValue(): Integer;
begin
  Result := Cycle(FMinValue, FMaxValue, Pred(FValue));
end;

end.
