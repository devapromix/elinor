unit DisciplesRL.Utils;

interface

uses
  Forms;

function GetDist(X1, Y1, X2, Y2: Integer): Integer;
function GetPath(SubDir: string): string;
function ShowForm(const Form: TForm): Integer;

implementation

uses SysUtils;

function GetDist(X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

function GetPath(SubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + SubDir);
end;

function ShowForm(const Form: TForm): Integer;
begin
  with Form do
  begin
    BorderStyle := bsDialog;
    Position := poOwnerFormCenter;
    Result := ShowModal;
  end;
end;

end.
