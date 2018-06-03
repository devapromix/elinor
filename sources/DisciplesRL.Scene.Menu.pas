unit DisciplesRL.Scene.Menu;

interface

uses System.Classes;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, DisciplesRL.Scenes, DisciplesRL.Resources,
  DisciplesRL.GUI.Button, DisciplesRL.Scene.Settlement,
  DisciplesRL.MainForm, DisciplesRL.Game;

type
  TButtonEnum = (btNew, btContinue, btHighScores, btQuit);

var
  Top, Left: Integer;
  MainMenuCursorPos: Integer = 0;
  Button: array [TButtonEnum] of TButton;

procedure Action(K: Integer = -1);
begin
  if (K >= 0) then
    MainMenuCursorPos := K;
  case MainMenuCursorPos of
    0:
      begin
        IsGame := True;
        DisciplesRL.Game.Init;
        DisciplesRL.Scene.Settlement.Show(stCapital);
      end;
    1: if IsGame then
      DisciplesRL.Scenes.CurrentScene := scMap;
    2:
      DisciplesRL.Scenes.CurrentScene := scHighScores;
  end;
end;

procedure Init;
var
  L, T, H: Integer;
  I: TButtonEnum;
begin
  Top := (Surface.Height div 5) - (ResImage[reLogo].Height div 2);
  Left := (Surface.Width div 2) - (ResImage[reLogo].Width div 2);
  L := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  H := ResImage[reButtonDef].Height + 10;
  T := (Surface.Height div 3 * 2) - ((H * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    case I of
      btNew:
        Button[I] := TButton.Create(L, T, Surface.Canvas, reMNewGame);
      btContinue:
        Button[I] := TButton.Create(L, T, Surface.Canvas, reMNewGame);
      btHighScores:
        Button[I] := TButton.Create(L, T, Surface.Canvas, reMNewGame);
      btQuit:
        Button[I] := TButton.Create(L, T, Surface.Canvas, reMQuit);
    end;
    Inc(T, H);
  end;
end;

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I].Sellected := (Ord(I) = MainMenuCursorPos);
    Button[I].Render;
  end;
end;

procedure Render;
begin
  Surface.Canvas.Draw(Left, Top, ResImage[reLogo]);
  RenderButtons;
  CenterTextOut(Surface.Height - 50, '2018 by Apromix')
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if Button[btNew].MouseDown then
    Action(0);
  if Button[btContinue].MouseDown then
    Action(1);
  if Button[btHighScores].MouseDown then
    Action(2);
  if Button[btQuit].MouseDown then
    DisciplesRL.MainForm.MainForm.Close;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ENTER:
      Action;
    K_ESCAPE:
      DisciplesRL.MainForm.MainForm.Close;
  end;
end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
end;

end.
