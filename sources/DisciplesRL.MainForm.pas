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
    procedure AutoTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

  {
    Сценарии:
    [1] Темная Башня - победить чародея в башне.
    [2] Древние Знания - собрать на карте все каменные таблички с древними знаниями.
    [3] Властитель - захватить все города на карте.
    4  Захватить определенный город.
    5  Добыть определенный артефакт.
    6  Разорить все руины и другие опасные места.
    7  Победить всех врагов на карте.
    8  Что-то выполнить за N дней (лимит времени, возможно опция для каждого сценария).
  }

implementation

{$R *.dfm}

uses
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.Map,
  DisciplesRL.Leader,
  DisciplesRL.Saga,
  DisciplesRL.PascalScript.Battle;

procedure TMainForm.AutoTimerTimer(Sender: TObject);
begin
  ClearMessages;
  FlagEnabled := True;
  AutoTimer.Enabled := False;
  Run(ATimerScript);
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
  Left := 8;
  //
  Randomize;
  for I := 1 to ParamCount do
  begin
    if (LowerCase(ParamStr(I)) = '-w') then
      TSaga.Wizard := True;
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
  DisciplesRL.Resources.Free;
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
    Caption := Format('DisciplesRL (%d:%d) [gold mines: %d]', [X, Y, TSaga.GoldMines])
  else
    Caption := 'DisciplesRL';
end;

end.
