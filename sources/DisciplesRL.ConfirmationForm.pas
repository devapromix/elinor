unit DisciplesRL.ConfirmationForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TConfirmationSubSceneEnum = (stConfirm, stInform);

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
  public
    { Public declarations }
    Msg: string;
    SubScene: TConfirmationSubSceneEnum;
  end;

var
  ConfirmationForm: TConfirmationForm;

implementation

{$R *.dfm}

uses
  DisciplesRL.MainForm,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button;

type
  TButtonEnum = (btOk, btCancel);

const
  ButtonsText: array [TButtonEnum] of TResEnum = (reTextHire, reTextClose);

var
  MouseX, MouseY: Integer;
  Buttons: array [TButtonEnum] of TButton;
  Button: TButton;
  Lf: Integer;

procedure TConfirmationForm.CenterTextOut(const Y: Integer; const Msg: string);
var
  S: Integer;
begin
  S := Surface.Canvas.TextWidth(Msg);
  Surface.Canvas.TextOut((Surface.Width div 2) - (S div 2), Y, Msg);
end;

procedure TConfirmationForm.FormClick(Sender: TObject);
begin
  //
end;

procedure TConfirmationForm.FormCreate(Sender: TObject);
var
  I: TButtonEnum;
  L, W: Integer;
begin
  ClientWidth := MainForm.ClientWidth - 300;
  ClientHeight := MainForm.ClientHeight - 300;
  Position := poOwnerFormCenter;
  Surface := TBitmap.Create;
  Surface.Width := ClientWidth;
  Surface.Height := ClientHeight;
  Surface.Canvas.Font.Size := 18;
  Surface.Canvas.Font.Color := clGreen;
  Surface.Canvas.Brush.Style := bsClear;
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  Lf := (Surface.Width div 2) - (ResImage[reFrame].Width) - 2;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Buttons[I] := TButton.Create(L, 300, Surface.Canvas, ButtonsText[I]);
    Inc(L, W);
    if (I = btOk) then
      Buttons[I].Sellected := True;
  end;
  Button := TButton.Create((Surface.Width div 2) - (ResImage[reButtonDef].Width div 2), 300, Surface.Canvas, reTextClose);
  Button.Sellected := True;
end;

procedure TConfirmationForm.FormDestroy(Sender: TObject);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Buttons[I]);
  FreeAndNil(Button);
  FreeAndNil(Surface);
end;

procedure TConfirmationForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  MouseX := X;
  MouseY := Y;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Buttons[I].MouseMove(X, Y);
  Button.MouseMove(X, Y);
end;

procedure TConfirmationForm.FormPaint(Sender: TObject);
var
  I: TButtonEnum;
begin
  Surface.Canvas.Brush.Color := clBlack;
  Surface.Canvas.FillRect(Rect(0, 0, Surface.Width, Surface.Height));
  case SubScene of
    stInform:
      begin
        CenterTextOut(150, Msg);
        Button.Render;
      end;
    stConfirm:
      begin
        CenterTextOut(150, Msg);
        for I := Low(Buttons) to High(Buttons) do
          Buttons[I].Render;
      end;
  end;
  Canvas.Draw(0, 0, Surface);
end;

end.
