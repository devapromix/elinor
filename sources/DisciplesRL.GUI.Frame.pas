unit DisciplesRL.GUI.Frame;

interface

uses
  Vcl.Graphics,
  DisciplesRL.Party,
  DisciplesRL.Resources,
  Vcl.Imaging.PNGImage;

type
  TFrame = class(TObject)
  private
    FLeft: Integer;
    FTop: Integer;
    FMouseX: Integer;
    FMouseY: Integer;
    FSellected: Boolean;
    FCanHire: Boolean;
    FCanvas: TCanvas;
    FTag: Integer;
  public
    constructor Create(ALeft, ATop, ATag: Integer; ACanvas: TCanvas);
    destructor Destroy; override;
    procedure MouseMove(X, Y: Integer);
    function MouseOver(X, Y: Integer): Boolean; overload;
    function MouseOver: Boolean; overload;
    function MouseDown: Boolean;
    procedure Render;
    property Sellected: Boolean read FSellected write FSellected;
    property Tag: Integer read FTag write FTag;
    class function Width: Integer; static;
    class function Height: Integer; static;
  end;

implementation

{ TFrame }

constructor TFrame.Create(ALeft, ATop, ATag: Integer; ACanvas: TCanvas);
begin
  FTop := ATop;
  FLeft := ALeft;
  FTag := ATag;
  FCanvas := ACanvas;
  FSellected := False;
  FCanHire := False;
end;

destructor TFrame.Destroy;
begin

  inherited;
end;

function TFrame.MouseDown: Boolean;
begin
  Result := False;
  if MouseOver then
  begin
    Result := True;
  end;
end;

procedure TFrame.MouseMove(X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;
end;

procedure TFrame.Render;
begin
  if FSellected then
    FCanvas.Draw(FLeft, FTop, ResImage[reActFrame])
  else
    FCanvas.Draw(FLeft, FTop, ResImage[reFrame]);
end;

class function TFrame.Width: Integer;
begin
  Result := ResImage[reFrame].Width
end;

class function TFrame.Height: Integer;
begin
  Result := ResImage[reFrame].Height
end;

function TFrame.MouseOver(X, Y: Integer): Boolean;
begin
  Result := (X > FLeft) and (X < FLeft + ResImage[reFrame].Width) and (Y > FTop) and (Y < FTop + ResImage[reFrame].Height);
end;

function TFrame.MouseOver: Boolean;
begin
  Result := MouseOver(FMouseX, FMouseY);
end;

end.
