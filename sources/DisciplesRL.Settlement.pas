unit DisciplesRL.Settlement;

interface

uses
  DisciplesRL.Resources;

type
  TSettlement = class(TObject)
  private type
    T = 0 .. 9;
  private const
    CityNameTitle: array [T] of TResEnum = (reTitleVorgel, reTitleEntarion,
      reTitleTardum, reTitleTemond, reTitleZerton, reTitleDoran, reTitleKront,
      reTitleHimor, reTitleSodek, reTitleSard);
    CityNameText: array [T] of string = ('Vorgel', 'Entarion', 'Tardum', 'Temond',
      'Zerton', 'Doran', 'Kront', 'Himor', 'Sodek', 'Sard');
  private var
    CityArr: array [T] of Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure GenCityName;
    function GetCityName(const I: Integer): string;
    function GetCityNameTitleRes(const I: T): TResEnum;
  end;

implementation

uses
  Classes,
  SysUtils;

{ TSettlement }

constructor TSettlement.Create;
begin

end;

destructor TSettlement.Destroy;
begin
  inherited Destroy;
end;

procedure TSettlement.GenCityName;
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
    CityArr[K] := J;
  end;
end;

function TSettlement.GetCityName(const I: Integer): string;
begin
  Result := CityNameText[CityArr[I]];
end;

function TSettlement.GetCityNameTitleRes(const I: T): TResEnum;
begin
  Result := CityNameTitle[CityArr[I]];
end;

end.
