unit Elinor.Common;

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
    function Cycle(Cond, Limit, Change: Integer;
      DoSave: Boolean = False): Integer;
    function GetValue: T;
    function AsT(IntValue: Integer): T;
  public
    constructor Create(AInitialValue: Integer; AMinValue: Integer = -1;
      AMaxValue: Integer = -1);
    function Next(): T;
    function Prev(): T;
    function NextAsInt(): Integer;
    function PrevAsInt(): Integer;
    function Modify(Ascending: Boolean): Integer;
    property Value: T read GetValue;
    property ValueAsInt: Integer read FValue;
  end;

  // function IIF(Condition: Boolean; IfTrue: Variant; IfFalse: Variant): Variant;
function Percent(const AValue: Integer; APercent: Integer): Integer;
function TruncateString(const AStr: string; const AMaxLength: Integer): string;

const
  CGoldForRevivePerLevel = 25;
  CLeaderWarriorHealAllInPartyPerDay = 10;
  CLeaderScoutMaxRadius = 2;
  CLeaderScoutMaxSpeed = 12;
  CLeaderLordMaxSpeed = 9;
  CLeaderThiefSpyAttemptCountPerDay = 3;
  CLeaderThiefPoisonDamageAllInPartyPerLevel = 10;
  CLeaderDefaultMaxSpeed = 7;
  CLeaderDefaultMaxRadius = 1;

const
  CNoFreeSpace = 'There is no free space!';
  CChooseEmptySlot = 'Choose an empty slot!';
  CChooseNonEmptySlot = 'Choose a non-empty slot!';
  CNeedLeadership = 'Not enough leadership points!';
  CCannotHire = 'Cannot hire!';
  CCannotDismiss = 'Cannot dismiss!';
  CConfirmDismiss = 'Dismiss the warrior?';
  CQuaffThisElixir = 'Quaff this elixir?';
  CNeedResurrection = 'Must resurrect first!';
  CNoHealingNeeded = 'Does not need healing!';
  CNeedMoreGold = 'Need more gold!';
  CHealConfirmFormat = 'Heal for %d gold?';
  CNoRevivalNeeded = 'Does not need revival!';
  CRevivalGoldNeededFormat = 'Need %d gold for revival!';
  CRevivalConfirmFormat = 'Revive for %d gold?';
  COnlyLeaderCanEquipItem = 'Only the Leader can equip this item!';
  CNotEnoughGold = 'Not enough gold!';

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

constructor TEnumCycler<T>.Create(AInitialValue: Integer;
  AMinValue: Integer = -1; AMaxValue: Integer = -1);
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

function TEnumCycler<T>.Cycle(Cond, Limit, Change: Integer;
  DoSave: Boolean = False): Integer;
begin
  Result := IfThen(FValue = Cond, Limit, Change);
  FValue := IfThen(DoSave, Result, FValue);
end;

function TEnumCycler<T>.AsT(IntValue: Integer): T;
begin
  Result :=
{$IFDEF FPC}
    T(IntValue);
{$ELSE}
    TValue.FromOrdinal(FEnumeratorTypeInfo, IntValue).AsType<T>();
{$ENDIF}
end;

function TEnumCycler<T>.GetValue: T;
begin
  Result := AsT(FValue);
end;

function TEnumCycler<T>.Modify(Ascending: Boolean): Integer;
begin
  Result := IfThen(Ascending, NextAsInt, PrevAsInt);
end;

function TEnumCycler<T>.Next(): T;
begin
  Result := AsT(NextAsInt);
end;

function TEnumCycler<T>.Prev(): T;
begin
  Result := AsT(PrevAsInt);
end;

function TEnumCycler<T>.NextAsInt(): Integer;
begin
  Result := Cycle(FMaxValue, FMinValue, Succ(FValue));
end;

function TEnumCycler<T>.PrevAsInt(): Integer;
begin
  Result := Cycle(FMinValue, FMaxValue, Pred(FValue));
end;

function Percent(const AValue: Integer; APercent: Integer): Integer;
begin
  Result := (AValue * APercent) div 100;
end;

function TruncateString(const AStr: string; const AMaxLength: Integer): string;
var
  I: Integer;
begin
  if Length(AStr) <= AMaxLength then
  begin
    Result := AStr;
    Exit;
  end;

  for I := AMaxLength downto 1 do
  begin
    if AStr[I] = ' ' then
    begin
      Result := Copy(AStr, 1, I - 1) + '...';
      Exit;
    end;
  end;

  Result := Copy(AStr, 1, AMaxLength) + '...';
end;

end.
