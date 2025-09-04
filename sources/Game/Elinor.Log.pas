unit Elinor.Log;

interface

uses
  System.Classes;

type
  TLog = class(TObject)
  private
    FTop: Integer;
    FLeft: Integer;
    FMsg: string;
    FLog: TStringList;
  public
    constructor Create(const ALeft, ATop: Integer);
    procedure Render;
    procedure RenderAll;
    destructor Destroy; override;
    procedure Append(const S: string);
    property Msg: string read FMsg write FMsg;
    function Get(const I: Integer): string;
    function GetLast(const I: Integer): string;
    procedure Add(const S: string);
    function Count: Integer;
    procedure Clear;
    procedure Turn;
  end;

implementation

uses
  Vcl.Graphics,
  System.Math,
  Elinor.Scenes,
  System.SysUtils;

const
  LogRows = 7;

  { TLog }

procedure DrawText(const AX, AY: Integer; AText: string);
var
  LBrushStyle: TBrushStyle;
begin
  LBrushStyle := Game.Surface.Canvas.Brush.Style;
  Game.Surface.Canvas.Brush.Style := bsClear;
  Game.Surface.Canvas.TextOut(AX, AY, AText);
  Game.Surface.Canvas.Brush.Style := LBrushStyle;
end;

constructor TLog.Create(const ALeft, ATop: Integer);
begin
  FLog := TStringList.Create;
  FTop := ATop;
  FLeft := ALeft;
end;

procedure TLog.Render;
var
  I, Y, D: Integer;
begin
  if Count <= 0 then
    Exit;
  Y := 0;
  D := EnsureRange(Count - LogRows, 0, Count - 1);
  for I := D to Count - 1 do
  begin
    DrawText(FLeft, FTop + Y, Get(I));
    Inc(Y, 16);
  end;
end;

procedure TLog.RenderAll;
var
  I, Y, D: Integer;
begin
  if Count <= 0 then
    Exit;
  Y := 0;
  D := EnsureRange(Count - 35, 0, Count - 1);
  for I := D to Count - 1 do
  begin
    DrawText(FLeft, FLeft + Y, Get(I));
    Inc(Y, 16);
  end;
end;

procedure TLog.Add(const S: string);
begin
  FLog.Append(S);
end;

procedure TLog.Append(const S: string);
begin
  FMsg := FMsg + ' ' + Trim(S);
end;

procedure TLog.Clear;
begin
  FMsg := '';
  FLog.Clear;
end;

function TLog.Count: Integer;
begin
  Result := FLog.Count;
end;

destructor TLog.Destroy;
begin
  FreeAndNil(FLog);
  inherited;
end;

function TLog.Get(const I: Integer): string;
begin
  Result := FLog[I];
end;

function TLog.GetLast(const I: Integer): string;
begin
  Result := FLog[Count - I];
end;

procedure TLog.Turn;
begin
  if not FMsg.Trim.IsEmpty then
    FLog.Append(FMsg.Trim);
end;

end.
