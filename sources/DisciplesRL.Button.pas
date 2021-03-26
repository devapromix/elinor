unit DisciplesRL.Button;

interface

uses
{$IFDEF FPC}
  Graphics,
{$ELSE}
  Vcl.Graphics,
  Vcl.Imaging.PNGImage,
{$ENDIF}
  DisciplesRL.Resources;

type
  TButtonState = (bsNone, bsOver, bsSell, bsDown);

type
  TButton = class(TObject)
  private
    FLeft: Integer;
    FTop: Integer;
    FMouseX: Integer;
    FMouseY: Integer;
    FSellected: Boolean;
    FState: TButtonState;
    FCanvas: TCanvas;
    FText: TResEnum;
    FTextLeft: Integer;
    FTextTop: Integer;
    FSurface: array [TButtonState] of TPNGImage;
    procedure Refresh;
  public
    constructor Create(ALeft, ATop: Integer; ARes: TResEnum); overload;
    constructor Create(ALeft, ATop: Integer; ACanvas: TCanvas;
      ARes: TResEnum); overload;
    destructor Destroy; override;
    procedure Render;
    property Top: Integer read FTop;
    property Left: Integer read FLeft;
    property Sellected: Boolean read FSellected write FSellected;
    property State: TButtonState read FState write FState;
    property Canvas: TCanvas read FCanvas write FCanvas;
    procedure MouseMove(X, Y: Integer);
    function Width: Integer;
    function Height: Integer;
    function MouseOver(X, Y: Integer): Boolean; overload;
    function MouseOver: Boolean; overload;
    function MouseDown: Boolean;
  end;

implementation

{ TButton }

uses
  DisciplesRL.Scenes;

constructor TButton.Create(ALeft, ATop: Integer; ARes: TResEnum);
var
  I: TButtonState;
begin
  FTop := ATop;
  FLeft := ALeft;
  FCanvas := Surface.Canvas;
  FSellected := False;
  FText := ARes;
  for I := Low(TButtonState) to High(TButtonState) do
  begin
    FSurface[I] := TPNGImage.Create;
    case I of
      bsNone:
        FSurface[I].Assign(ResImage[reButtonDef]);
      bsOver:
        FSurface[I].Assign(ResImage[reButtonAct]);
      bsSell:
        FSurface[I].Assign(ResImage[reButtonAct]);
      bsDown:
        FSurface[I].Assign(ResImage[reButtonAct]);
    end;
  end;
  FTextLeft := FLeft + ((Width div 2) - (ResImage[ARes].Width div 2));
  FTextTop := FTop + ((Height div 2) - (ResImage[ARes].Height div 2));
end;

constructor TButton.Create(ALeft, ATop: Integer; ACanvas: TCanvas;
  ARes: TResEnum);
var
  I: TButtonState;
begin
  FTop := ATop;
  FLeft := ALeft;
  FCanvas := ACanvas;
  FSellected := False;
  FText := ARes;
  for I := Low(TButtonState) to High(TButtonState) do
  begin
    FSurface[I] := TPNGImage.Create;
    case I of
      bsNone:
        FSurface[I].Assign(ResImage[reButtonDef]);
      bsOver:
        FSurface[I].Assign(ResImage[reButtonAct]);
      bsSell:
        FSurface[I].Assign(ResImage[reButtonAct]);
      bsDown:
        FSurface[I].Assign(ResImage[reButtonAct]);
    end;
  end;
  FTextLeft := FLeft + ((Width div 2) - (ResImage[ARes].Width div 2));
  FTextTop := FTop + ((Height div 2) - (ResImage[ARes].Height div 2));
end;

destructor TButton.Destroy;
var
  I: TButtonState;
begin
  for I := Low(TButtonState) to High(TButtonState) do
    FSurface[I].Free;
  inherited;
end;

function TButton.Height: Integer;
begin
  Result := FSurface[bsNone].Height;
end;

function TButton.Width: Integer;
begin
  Result := FSurface[bsNone].Width;
end;

function TButton.MouseDown: Boolean;
begin
  Result := False;
  if MouseOver(FMouseX, FMouseY) then
  begin
    State := bsDown;
    Result := True;
  end
  else
    State := bsNone;
  Refresh;
end;

procedure TButton.MouseMove(X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;
end;

function TButton.MouseOver(X, Y: Integer): Boolean;
begin
  Result := (X > Left) and (X < Left + FSurface[bsNone].Width) and (Y > Top) and
    (Y < Top + FSurface[bsNone].Height);
end;

function TButton.MouseOver: Boolean;
begin
  Result := MouseOver(FMouseX, FMouseY);
end;

procedure TButton.Refresh;
begin
  case State of
    bsNone:
      if Sellected then
        FCanvas.Draw(Left, Top, FSurface[bsSell])
      else
        FCanvas.Draw(Left, Top, FSurface[bsNone]);
    bsOver:
      FCanvas.Draw(Left, Top, FSurface[bsOver]);
    bsDown:
      FCanvas.Draw(Left, Top, FSurface[bsDown]);
  end;
end;

procedure TButton.Render;
begin
  if (State <> bsDown) then
  begin
    if MouseOver and not Sellected then
      State := bsOver
    else
      State := bsNone;
  end;
  Refresh;
  FCanvas.Draw(FTextLeft, FTextTop, ResImage[FText]);
  if (State = bsDown) and not MouseOver then
    State := bsNone;
end;

end.
