unit DisciplesRL.Scene.Menu;

interface

{$IFDEF FPC}

uses
  DisciplesRL.Scene;

type

  { TSceneMenu }

  TSceneMenu = class(TScene)
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal;

procedure TSceneMenu.Render;
begin

end;

procedure TSceneMenu.Update(var Key: Word);
begin
  case Key of
    TK_ENTER:
      Game.SetScene(scMap);
  end;
end;

{$ELSE}

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
  Math,
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button,
  DisciplesRL.MainForm,
  DisciplesRL.Saga,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Map;

type
  TButtonEnum = (btPlay, btContinue, btHighScores, btQuit);

const
  ButtonText: array [TButtonEnum] of TResEnum = (reTextPlay, reTextContinue,
    reTextHighScores, reTextQuit);

var
  MainMenuCursorPos: Integer = 0;
  Button: array [TButtonEnum] of TButton;

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
        MediaPlayer.Play(mmClick);
        TSaga.IsGame := False;
        DisciplesRL.Scene.Hire.Show(stScenario);
      end;
    1: // Continue
      begin
        if TSaga.IsGame then
        begin
          MediaPlayer.Play(mmClick);
          MediaPlayer.PlayMusic(mmMap);
          DisciplesRL.Scene.Map.Show;
        end;
      end;
    2: // High Scores
      begin
        MediaPlayer.Play(mmClick);
        DisciplesRL.Scene.Hire.Show(stHighScores2);
      end;
    3: // Exit;
      begin
        MediaPlayer.Play(mmClick);
        DisciplesRL.MainForm.MainForm.Close;
      end;
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
  DrawImage(reWallpaperMenu);
  DrawTitle(reTitleLogo);
  RenderButtons;
  CenterTextOut(Surface.Height - 50, '2018-2021 by Apromix');
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
    Ok(3);
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
      Ok;
    K_ESCAPE:
      DisciplesRL.MainForm.MainForm.Close;
    K_UP:
      MainMenuCursorPos := Math.EnsureRange(MainMenuCursorPos - 1, 0,
        Ord(High(TButtonEnum)));
    K_DOWN:
      MainMenuCursorPos := Math.EnsureRange(MainMenuCursorPos + 1, 0,
        Ord(High(TButtonEnum)));
  end;
end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
end;

{$ENDIF}

end.
