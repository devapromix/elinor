unit Elinor.Button;

interface

uses
{$IFDEF FPC}
  Graphics,
{$ELSE}
  Vcl.Graphics,
  Vcl.Imaging.PNGImage,
{$ENDIF}
  Classes,
  Elinor.Resources;

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

type
  TIconState = (isDef, isOver);

type
  TIcon = class(TObject)
  private
    FLeft: Integer;
    FTop: Integer;
    FMouseX: Integer;
    FMouseY: Integer;
    FSurface: array [TIconState] of TPNGImage;
    procedure Refresh;
  public
    constructor Create(ALeft, ATop: Integer; ADefRes, AOverRes: TResEnum);
    destructor Destroy; override;
    procedure Render;
    property Top: Integer read FTop;
    property Left: Integer read FLeft;
    procedure MouseMove(X, Y: Integer);
    function Width: Integer;
    function Height: Integer;
    function MouseOver(X, Y: Integer): Boolean; overload;
    function MouseOver: Boolean; overload;
    function MouseDown: Boolean;
  end;

implementation

uses
  Math,
  SysUtils,
  Elinor.Scenes;

const
  LogRows = 7;

procedure DrawText(const AX, AY: Integer; AText: string);
var
  LBrushStyle: TBrushStyle;
begin
  LBrushStyle := Game.Surface.Canvas.Brush.Style;
  Game.Surface.Canvas.Brush.Style := bsClear;
  Game.Surface.Canvas.TextOut(AX, AY, AText);
  Game.Surface.Canvas.Brush.Style := LBrushStyle;
end;

{ TIcon }

procedure TIcon.Refresh;
begin

end;

constructor TIcon.Create(ALeft, ATop: Integer; ADefRes, AOverRes: TResEnum);
var
  LIconState: TIconState;
begin
  FTop := ATop;
  FLeft := ALeft;
  for LIconState := Low(TIconState) to High(TIconState) do
  begin
    FSurface[LIconState] := TPNGImage.Create;
    case LIconState of
      isDef:
        FSurface[LIconState].Assign(ResImage[ADefRes]);
      isOver:
        FSurface[LIconState].Assign(ResImage[AOverRes]);
    end;
  end;
end;

destructor TIcon.Destroy;
var
  LIconState: TIconState;
begin
  for LIconState := Low(TIconState) to High(TIconState) do
    FSurface[LIconState].Free;
  inherited;
end;

procedure TIcon.Render;
begin
  if MouseOver then
    Game.Surface.Canvas.Draw(FLeft, FTop, FSurface[isOver])
  else
    Game.Surface.Canvas.Draw(FLeft, FTop, FSurface[isDef]);
  Refresh;
end;

procedure TIcon.MouseMove(X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;
end;

function TIcon.Width: Integer;
begin
  Result := FSurface[isOver].Width;
end;

function TIcon.Height: Integer;
begin
  Result := FSurface[isOver].Height;
end;

function TIcon.MouseOver(X, Y: Integer): Boolean;
begin
  Result := (X > Left) and (X < Left + FSurface[isOver].Width) and (Y > Top) and
    (Y < Top + FSurface[isOver].Height);
end;

function TIcon.MouseOver: Boolean;
begin
  Result := MouseOver(FMouseX, FMouseY);
end;

function TIcon.MouseDown: Boolean;
begin
  Result := MouseOver(FMouseX, FMouseY);
  Refresh;
end;

{ TButton }

constructor TButton.Create(ALeft, ATop: Integer; ARes: TResEnum);
var
  LButtonState: TButtonState;
begin
  FTop := ATop;
  FLeft := ALeft;
  // FCanvas := Game.Surface.Canvas;
  FSellected := False;
  FText := ARes;
  for LButtonState := Low(TButtonState) to High(TButtonState) do
  begin
    FSurface[LButtonState] := TPNGImage.Create;
    case LButtonState of
      bsNone:
        FSurface[LButtonState].Assign(ResImage[reButtonDef]);
      bsOver:
        FSurface[LButtonState].Assign(ResImage[reButtonAct]);
      bsSell:
        FSurface[LButtonState].Assign(ResImage[reButtonAct]);
      bsDown:
        FSurface[LButtonState].Assign(ResImage[reButtonAct]);
    end;
  end;
  FTextLeft := FLeft + ((Width div 2) - (ResImage[ARes].Width div 2));
  FTextTop := FTop + ((Height div 2) - (ResImage[ARes].Height div 2));
end;

constructor TButton.Create(ALeft, ATop: Integer; ACanvas: TCanvas;
  ARes: TResEnum);
var
  LButtonState: TButtonState;
begin
  FTop := ATop;
  FLeft := ALeft;
  FCanvas := ACanvas;
  FSellected := False;
  FText := ARes;
  for LButtonState := Low(TButtonState) to High(TButtonState) do
  begin
    FSurface[LButtonState] := TPNGImage.Create;
    case LButtonState of
      bsNone:
        FSurface[LButtonState].Assign(ResImage[reButtonDef]);
      bsOver:
        FSurface[LButtonState].Assign(ResImage[reButtonAct]);
      bsSell:
        FSurface[LButtonState].Assign(ResImage[reButtonAct]);
      bsDown:
        FSurface[LButtonState].Assign(ResImage[reButtonAct]);
    end;
  end;
  FTextLeft := FLeft + ((Width div 2) - (ResImage[ARes].Width div 2));
  FTextTop := FTop + ((Height div 2) - (ResImage[ARes].Height div 2));
end;

destructor TButton.Destroy;
var
  LButtonState: TButtonState;
begin
  for LButtonState := Low(TButtonState) to High(TButtonState) do
    FSurface[LButtonState].Free;
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
        Game.Surface.Canvas.Draw(Left, Top, FSurface[bsSell])
      else
        Game.Surface.Canvas.Draw(Left, Top, FSurface[bsNone]);
    bsOver:
      Game.Surface.Canvas.Draw(Left, Top, FSurface[bsOver]);
    bsDown:
      Game.Surface.Canvas.Draw(Left, Top, FSurface[bsDown]);
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
  Game.Surface.Canvas.Draw(FTextLeft, FTextTop, ResImage[FText]);
  if (State = bsDown) and not MouseOver then
    State := bsNone;
end;

{ TLog }

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
