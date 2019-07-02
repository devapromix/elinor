unit DisciplesRL.MainForm;

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    AutoTimer: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DisciplesRL.Scenes,
  DisciplesRL.Map,
  DisciplesRL.Saga;

procedure TMainForm.FormClick(Sender: TObject);
begin
  DisciplesRL.Scenes.MouseClick;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Top := 0;
  Left := 8;
  //
  Randomize;
  TSaga.Wizard := False;
  for I := 1 to ParamCount do
  begin
    if (LowerCase(ParamStr(I)) = '-w') then
      TSaga.Wizard := True;
  end;
  //
  ClientWidth := MapWidth * TMap.TileSize;
  ClientHeight := MapHeight * TMap.TileSize;
  //
  DisciplesRL.Scenes.Init;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  DisciplesRL.Scenes.Render;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  DisciplesRL.Scenes.Timer;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DisciplesRL.Scenes.Free;
  TSaga.PartyFree;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  DisciplesRL.Scenes.KeyDown(Key, Shift);
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DisciplesRL.Scenes.MouseDown(Button, Shift, X, Y);
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  DisciplesRL.Scenes.MouseMove(Shift, X, Y);
  if TSaga.Wizard then
    Caption := Format('DisciplesRL (%d:%d) [gold mines: %d]', [X, Y, TSaga.GoldMines]);
end;

end.
