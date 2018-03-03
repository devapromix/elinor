unit uUtils;

interface

uses
  Forms;

type
  Utils = class(TObject)
  public
    class function GetPath(SubDir: string): string;
    class function ShowForm(const Form: TForm): Integer;
  end;

implementation

uses SysUtils;

class function Utils.GetPath(SubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + SubDir);
end;

class function Utils.ShowForm(const Form: TForm): Integer;
begin
  with Form do
  begin
    BorderStyle := bsDialog;
    Position := poOwnerFormCenter;
    Result := ShowModal;
  end;
end;

end.
