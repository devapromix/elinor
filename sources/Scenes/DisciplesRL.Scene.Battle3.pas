unit DisciplesRL.Scene.Battle3;

interface

uses
  System.Classes,
  Vcl.Controls;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses
  System.SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.GUI.Button,
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.Scene.Party;

var
  Button: TButton;

procedure Init;
begin
  Button := TButton.Create(Surface.Width - (ResImage[reButtonDef].Width + Left),
    DefaultButtonTop, Surface.Canvas, reTextClose);
  Button.Sellected := True;
end;

procedure Start;
begin
  MediaPlayer.Play(mmWar);
end;

procedure Finish;
begin
  MediaPlayer.Stop;
end;

procedure Render;
begin
  DrawTitle(reTitleBattle);
  Button.Render;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if Button.MouseDown then
    Finish;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  Button.MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      Finish;
  end;
end;

procedure Free;
begin
  FreeAndNil(Button);
end;

end.
