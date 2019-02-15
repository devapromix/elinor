unit DisciplesRL.BattleLog;

interface

uses
  System.Classes,
  Vcl.Graphics,
  RLLog;

type
  TLog = class(TRLLog)
  private
    FTop: Integer;
    FLeft: Integer;
    FCanvas: TCanvas;
  public
    constructor Create(const ALeft, ATop: Integer; ACanvas: TCanvas);
    procedure Render;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

const
  Rows = 7;

  { TLog }

constructor TLog.Create(const ALeft, ATop: Integer; ACanvas: TCanvas);
begin
  inherited Create;
  FTop := ATop;
  FLeft := ALeft;
  FCanvas := ACanvas;
end;

procedure TLog.Render;
var
  I, Y, D: Integer;
begin
  if Count <= 0 then
    Exit;
  Y := 0;
  D := EnsureRange(Count - Rows, 0, Count - 1);
  FCanvas.Font.Size := 10;
  for I := D to Count - 1 do
  begin
    FCanvas.TextOut(FLeft, FTop + Y, Get(I));
    Inc(Y, 16);
  end;
  FCanvas.Font.Size := 12;
end;

end.
