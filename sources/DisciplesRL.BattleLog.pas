unit DisciplesRL.BattleLog;

interface

uses
  System.Classes,
  Vcl.Graphics;

type
  TLog = class(TObject)
  private
    FTop: Integer;
    FLeft: Integer;
    FLog: TStringList;
    FCanvas: TCanvas;
  public
    constructor Create(const ALeft, ATop: Integer; ACanvas: TCanvas);
    destructor Destroy; override;
    procedure Add(const Msg: string);
    function Get(const I: Integer): string;
    function Count: Integer;
    procedure Render;
    procedure Clear;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

{ TLog }

procedure TLog.Add(const Msg: string);
begin
  FLog.Append(Msg);
end;

procedure TLog.Clear;
begin
  FLog.Clear;
end;

function TLog.Count: Integer;
begin
  Result := FLog.Count;
end;

constructor TLog.Create(const ALeft, ATop: Integer; ACanvas: TCanvas);
begin
  FTop := ATop;
  FLeft := ALeft;
  FCanvas := ACanvas;
  FLog := TStringList.Create;
  FLog.Clear;
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

procedure TLog.Render;
var
  I, Y, D: Integer;
begin
  if Count <= 0 then
    Exit;
  Y := 0;
  D := EnsureRange(Count - 6, 0, Count - 1);
  FCanvas.Font.Size := 10;
  for I := D to Count - 1 do
  begin
    FCanvas.TextOut(FLeft, FTop + Y, FLog[I]);
    Inc(Y, 16);
  end;
  FCanvas.Font.Size := 12;
end;

end.
