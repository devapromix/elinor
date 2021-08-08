unit DisciplesRL.Settlement;

interface

uses
  DisciplesRL.Resources;

type
  TSettlements = class(TObject)
  private type
    T = 0 .. 9;
  private const
    NameResEnum: array [T] of TResEnum = (reTitleVorgel, reTitleEntarion,
      reTitleTardum, reTitleTemond, reTitleZerton, reTitleDoran, reTitleKront,
      reTitleHimor, reTitleSodek, reTitleSard);
    NameText: array [T] of string = ('Vorgel', 'Entarion', 'Tardum', 'Temond',
      'Zerton', 'Doran', 'Kront', 'Himor', 'Sodek', 'Sard');
  private
    FName: array [T] of Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure GenNames;
    function GetNameText(const I: Integer): string; overload;
    function GetNameResEnum(const I: T): TResEnum; overload;
  end;

implementation

constructor TSettlements.Create;
begin

end;

destructor TSettlements.Destroy;
begin

  inherited;
end;

procedure TSettlements.GenNames;
var
  N: set of T;
  J, K: Integer;
begin
  N := [];
  for K := Low(T) to High(T) do
  begin
    repeat
      J := Random(10);
    until not(J in N);
    N := N + [J];
    FName[K] := J;
  end;
end;

function TSettlements.GetNameText(const I: Integer): string;
begin
  Result := NameText[FName[I]];
end;

function TSettlements.GetNameResEnum(const I: T): TResEnum;
begin
  Result := NameResEnum[FName[I]];
end;

end.
