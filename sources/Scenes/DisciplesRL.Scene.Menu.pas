unit DisciplesRL.Scene.Menu;

interface

uses
  System.Classes,
  Vcl.Controls,
  DisciplesRL.Scenes;

type
  TSceneMenu = class(TScene)
  private
    procedure Next;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

uses
  Math,
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Resources,
  DisciplesRL.Button,
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

procedure TSceneMenu.Next;
begin
  case MainMenuCursorPos of
    0: // Play
      begin
        TSaga.IsGame := False;
        TSceneHire.Show(stScenario);
      end;
    1: // Continue
      begin
        if TSaga.IsGame then
        begin
          MediaPlayer.PlayMusic(mmMap);
          Scenes.Show(scMap);
        end;
      end;
    2: // High Scores
        TSceneHire.Show(stHighScores2);
    3: // Exit;
        DisciplesRL.MainForm.MainForm.Close;
  end;
end;

{ TSceneMenu }

procedure TSceneMenu.Click;
var
  I: TButtonEnum;
begin
  inherited;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    if Button[I].MouseDown then
    begin
      MainMenuCursorPos := Ord(I);
      MediaPlayer.Play(mmClick);
      Next;
    end;
end;

constructor TSceneMenu.Create;
var
  L, T, H: Integer;
  I: TButtonEnum;
begin
  L := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2);
  H := ResImage[reButtonDef].Height + 10;
  T := (Surface.Height div 3 * 2) - ((H * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, T, ButtonText[I]);
    if (I = btPlay) then
      Button[I].Sellected := True;
    Inc(T, H);
  end;
end;

destructor TSceneMenu.Destroy;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
  inherited;
end;

procedure TSceneMenu.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TSceneMenu.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  Render;
end;

procedure TSceneMenu.Render;

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

begin
  inherited;
  DrawImage(reWallpaperMenu);
  DrawTitle(reTitleLogo);
  RenderButtons;
  DrawText(Surface.Height - 50, '2018-2021 by Apromix');
end;

procedure TSceneMenu.Timer;
begin
  inherited;

end;

procedure TSceneMenu.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ENTER:
      Next;
    K_ESCAPE:
      DisciplesRL.MainForm.MainForm.Close;
    K_UP:
      MainMenuCursorPos := EnsureRange(MainMenuCursorPos - 1, 0,
        Ord(High(TButtonEnum)));
    K_DOWN:
      MainMenuCursorPos := EnsureRange(MainMenuCursorPos + 1, 0,
        Ord(High(TButtonEnum)));
  end;
end;

end.
