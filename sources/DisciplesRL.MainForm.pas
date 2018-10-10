unit DisciplesRL.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    AutoTimer: TTimer;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormClick(Sender: TObject);
    procedure AutoTimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses DisciplesRL.Scenes, DisciplesRL.Resources, DisciplesRL.Map,
  DisciplesRL.Player, DisciplesRL.Game, DisciplesRL.PascalScript.Battle;

procedure TMainForm.AutoTimerTimer(Sender: TObject);
begin
  ClearMessages;
  FlagEnabled := True;
  AutoTimer.Enabled := False;
  Run(ATimerScript);
end;

type
  TEx = procedure;

  TP = record
    Ex: TEx;
  end;

var
  FF: array [0 .. 1] of TP;

procedure D1;
begin
  MainForm.Label1.Caption := 'Приветствую вас, добрые воины!..';
end;

procedure D2;
begin
  MainForm.Label1.Caption :=
    'Oчистите эти земли от наводнившей их нежити... завершите мое дело... именем Небесного Отца благославляю вас на священный бой!';
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  FF[0].Ex := D1;
  FF[1].Ex := D2;
  for I := 0 to 1 do
  begin
    FF[I].Ex;
    Application.ProcessMessages;
    Sleep(1000);
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  // Run('battles\test.pas');
  Run('battles\test2.pas');
end;

procedure TMainForm.FormClick(Sender: TObject);
begin
  DisciplesRL.Scenes.MouseClick;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Top := 0;
  Left := 0;
  //
  Randomize;
  for I := 1 to ParamCount do
  begin
    if (LowerCase(ParamStr(I)) = '-w') then
      Wizard := True;
  end;
  //
  ClientWidth := MapWidth * TileSize;
  ClientHeight := MapHeight * TileSize;
  //
  DisciplesRL.Resources.Init;
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
  DisciplesRL.Game.Free;
  DisciplesRL.Resources.Free;
  DisciplesRL.Scenes.Free;
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
  Caption := Format('DisciplesRL (%d:%d) [m:%d]', [X, Y, GoldMines]);
end;

end.
