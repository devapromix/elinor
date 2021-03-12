unit DisciplesRL.MainForm;

{$MODE Delphi}

interface

uses
  {$IFDEF FPC}
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls;
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
  TMainForm = class(TForm)
    Timer1: TTimer;
    AutoTimer: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  DisciplesRL.Scenes,
  DisciplesRL.Map,
  DisciplesRL.Saga;

procedure TMainForm.FormClick(Sender: TObject);
begin
  Scenes.Click;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ClientWidth := TMap.Width * TMap.TileSize;
  ClientHeight := TMap.Height * TMap.TileSize;
  Scenes := TScenes.Create;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  Scenes.Render;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Scenes.Timer;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Scenes);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Scenes.Update(Key);
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Scenes.MouseDown(Button, Shift, X, Y);
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Scenes.MouseMove(Shift, X, Y);
end;

end.
