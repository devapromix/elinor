unit DisciplesRL.ConfirmationForm;

interface

uses
{$IFDEF FPC}
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls,
  StdCtrls;
{$ELSE}
  Winapi.Windows,
  Winapi.Messages,
  SysUtils,
  Variants,
  Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls;
{$ENDIF}

type
  TConfirmationForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    Surface: TBitmap;
    procedure CenterTextOut(const Y: Integer; const Msg: string);
    procedure Ok;
    procedure Back;
  public
    { Public declarations }
    Msg: string;
  end;

var
  ConfirmationForm: TConfirmationForm;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

uses
  DisciplesRL.Resources,
  DisciplesRL.Button,
  DisciplesRL.Scenes;

type
  TButtonEnum = (btOk, btCancel);

const
  ButtonsText: array [TButtonEnum] of TResEnum = (reTextOk, reTextCancel);

var
  Buttons: array [TButtonEnum] of TButton;

procedure TConfirmationForm.Ok;
begin
  MediaPlayer.Play(mmClick);
  Button1.Click;
end;

procedure TConfirmationForm.Back;
begin
  MediaPlayer.Play(mmClick);
  Button2.Click;
end;

procedure TConfirmationForm.CenterTextOut(const Y: Integer; const Msg: string);
var
  S: Integer;
begin
  S := Surface.Canvas.TextWidth(Msg);
  Surface.Canvas.TextOut((Surface.Width div 2) - (S div 2), Y, Msg);
end;

procedure TConfirmationForm.FormClick(Sender: TObject);
begin
  if Buttons[btOk].MouseDown then
    Ok;
  if Buttons[btCancel].MouseDown then
    Back;
end;

procedure TConfirmationForm.FormCreate(Sender: TObject);
var
  I: TButtonEnum;
  L, W, Y: Integer;
begin
  ClientWidth := ResImage[reBigFrame].Width;
  ClientHeight := ResImage[reBigFrame].Height;
  Position := poOwnerFormCenter;
  Surface := TBitmap.Create;
  Surface.Width := ClientWidth;
  Surface.Height := ClientHeight;
  Surface.Canvas.Font.Size := 18;
  Surface.Canvas.Font.Color := clGreen;
  Surface.Canvas.Brush.Style := bsClear;
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  Y := ResImage[reBigFrame].Height - (ResImage[reButtonDef].Height + 10);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Buttons[I] := TButton.Create(L, Y, ButtonsText[I]);
    Buttons[I].Canvas := Surface.Canvas;
    Inc(L, W);
    if (I = btOk) then
      Buttons[I].Sellected := True;
  end;
end;

procedure TConfirmationForm.FormDestroy(Sender: TObject);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Buttons[I]);
  FreeAndNil(Surface);
end;

procedure TConfirmationForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Buttons[I].MouseMove(X, Y);
end;

procedure TConfirmationForm.FormPaint(Sender: TObject);
var
  I: TButtonEnum;
begin
  Surface.Canvas.Brush.Color := clBlack;
  Surface.Canvas.FillRect(Rect(0, 0, Surface.Width, Surface.Height));
  Surface.Canvas.Draw(0, 0, ResImage[reBigFrame]);
  CenterTextOut(150, Msg);
  for I := Low(Buttons) to High(Buttons) do
    Buttons[I].Render;
  Canvas.Draw(0, 0, Surface);
end;

end.
