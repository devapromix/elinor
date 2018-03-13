unit DisciplesRL.PascalScript.Vars;

interface

uses System.Classes;

type
  TVars = class(TObject)
  private
    FID: TStringList;
    FValue: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    function IsVar(const AVar: String): Boolean;
    function GetStr(const AVar: String): String;
    procedure SetStr(const AVar, AValue: String);
    function GetInt(const AVar: String): Integer;
    procedure SetInt(const AVar: String; const AValue: Integer);
    function GetBool(const AVar: String): Boolean;
    procedure SetBool(const AVar: String; const AValue: Boolean);
    procedure Inc(const VarName: String; Count: Integer = 1);
    procedure Dec(const VarName: String; Count: Integer = 1);
    procedure Let(Var1, Var2: String);
  end;

implementation

uses System.SysUtils;

{ TVars }

procedure TVars.Clear;
begin
  FID.Clear;
  FValue.Clear;
end;

function TVars.Count: Integer;
begin
  Result := FID.Count;
end;

constructor TVars.Create;
begin
  FID := TStringList.Create;
  FValue := TStringList.Create;
end;

procedure TVars.Dec(const VarName: String; Count: Integer);
var
  I: Integer;
begin
  I := GetInt(VarName);
  System.Dec(I, Count);
  SetInt(VarName, I);
end;

destructor TVars.Destroy;
begin
  FreeAndNil(FID);
  FreeAndNil(FValue);
  inherited;
end;

function TVars.GetBool(const AVar: String): Boolean;
begin
  Result := Trim(GetStr(AVar)) = 'TRUE';
end;

function TVars.GetInt(const AVar: String): Integer;
var
  S: string;
begin
  S := Trim(GetStr(AVar));
  if S = '' then
    Result := 0
  else
    Result := StrToInt(S);
end;

function TVars.GetStr(const AVar: String): String;
var
  I: Integer;
begin
  I := FID.IndexOf(AVar);
  if I < 0 then
    Result := ''
  else
    Result := FValue[I];
end;

procedure TVars.Inc(const VarName: String; Count: Integer);
var
  I: Integer;
begin
  I := GetInt(VarName);
  System.Inc(I, Count);
  SetInt(VarName, I);
end;

function TVars.IsVar(const AVar: String): Boolean;
begin
  Result := FID.IndexOf(Trim(AVar)) > -1;
end;

procedure TVars.Let(Var1, Var2: String);
var
  I: Integer;
  S: string;
begin
  I := FID.IndexOf(Var2);
  if I < 0 then
    S := ''
  else
    S := FValue[I];
  I := FID.IndexOf(Var1);
  if I < 0 then
  begin
    FID.Append(Var1);
    FValue.Append(S);
  end
  else
    FValue[I] := S;
end;

procedure TVars.SetBool(const AVar: String; const AValue: Boolean);
begin
  if AValue then
    SetStr(AVar, 'TRUE')
  else
    SetStr(AVar, 'FALSE');
end;

procedure TVars.SetInt(const AVar: String; const AValue: Integer);
begin
  SetStr(AVar, IntToStr(AValue));
end;

procedure TVars.SetStr(const AVar, AValue: String);
var
  I: Integer;
begin
  I := FID.IndexOf(AVar);
  if I < 0 then
  begin
    FID.Append(AVar);
    FValue.Append(AValue);
  end
  else
    FValue[I] := AValue;
end;

end.
