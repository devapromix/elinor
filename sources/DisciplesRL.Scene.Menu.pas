unit DisciplesRL.Scene.Menu;

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
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button,
  DisciplesRL.MainForm,
  DisciplesRL.Game,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Info,
  DisciplesRL.GUI.Frame;

type
  TButtonEnum = (btPlay, btContinue, btHighScores, btQuit);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextPlay, reTextContinue, reTextHighScores, reTextQuit);

var
  MainMenuCursorPos: Integer = 0;
  Button: array [TButtonEnum] of TButton;
  Fr: TFrame;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Ok(K: Integer = -1);
begin
  if (K >= 0) then
    MainMenuCursorPos := K;
  case MainMenuCursorPos of
    0: // Play
      begin
        IsGame := False;
        DisciplesRL.Scene.Hire.Show(stRace);
      end;
    1: // Continue
      if IsGame then
        DisciplesRL.Scenes.CurrentScene := scMap;
    2: // High Scores
      DisciplesRL.Scene.Info.Show(stHighScores, scMenu);
  end;
end;

procedure Init;
var
  L, T, H: Integer;
  I: TButtonEnum;
begin
  L := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  H := ResImage[reButtonDef].Height + 10;
  T := (Surface.Height div 3 * 2) - ((H * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, T, Surface.Canvas, ButtonText[I]);
    if (I = btPlay) then
      Button[I].Sellected := True;
    Inc(T, H);
  end;

  Fr := TFrame.Create(10, 10, Surface.Canvas);
  Fr.Tag := 1;
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
  DrawTitle(reTitleLogo);
  RenderButtons;
  CenterTextOut(Surface.Height - 50, '2018-2019 by Apromix');
  Fr.Render;
end;

procedure Timer;
begin

end;

procedure MouseClick;
begin
  if Button[btPlay].MouseDown then
    Ok(0);
  if Button[btContinue].MouseDown then
    Ok(1);
  if Button[btHighScores].MouseDown then
    Ok(2);
  if Button[btQuit].MouseDown then
    DisciplesRL.MainForm.MainForm.Close;
  if Fr.MouseDown then
  begin
    Fr.Sellected := True;
    ShowMessage(IntToStr(Fr.Tag));
  end;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Fr.MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ENTER:
      Ok;
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
  FreeAndNil(Fr);
end;

end.
