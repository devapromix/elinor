unit Elinor.Scene.Menu3;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  System.Classes,
  Elinor.Scene.Menu.Wide,
  Elinor.Button,
  Elinor.Common,
  Elinor.Resources,
  Elinor.Scenes;

type

  { TSceneMenu3 }

  TSceneMenu3 = class(TSceneWideMenu)
  private
    procedure Quit;
    procedure ConfirmQuit;
    procedure StartNewGame;
    procedure ContinueGame;
    procedure ShowHighScores;
    procedure Credits;
    procedure SelectMenuItem;
  private type
    TButtonEnum = (btQuit, btContinue);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextQuit, reTextContinue);
  private
    Button: array [TButtonEnum] of TButton;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Cancel; override;
    procedure Continue; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Scene.Records;

{ TSceneMenu3 }

procedure TSceneMenu3.Quit;
begin
  Halt;
end;

procedure TSceneMenu3.Credits;
begin
  TextTop := TFrame.Row(0) + 6;
  TextLeft := TFrame.Col(3) + 12;
  AddTextLine('About', True);
  AddTextLine;
  AddTextLine('Set in the magical realm of the Sacred');
  AddTextLine('Lands, three races - the Empire, the Legi-');
  AddTextLine('ons of the Damned, and the Undead Hor-');
  AddTextLine('des - battle for the destiny of their gods.');
  AddTextLine('Credits', True);
  AddTextLine;
  AddTextLine('Design and programming:');
  AddTextLine('Apromix');
  AddTextLine('Programming, testing and ideas:');
  AddTextLine('Phomm');

end;

procedure TSceneMenu3.Cancel;
begin
  inherited;
  ConfirmQuit;
end;

procedure TSceneMenu3.ConfirmQuit;
begin
  ConfirmDialog('Leave the game?', {$IFDEF MODEOBJFPC}@{$ENDIF}Quit);
end;

procedure TSceneMenu3.StartNewGame;
begin
  Game.IsGame := False;
  Game.Show(scScenario);
end;

procedure TSceneMenu3.SelectMenuItem;
begin
  case CurrentIndex of
    0:
      StartNewGame;
    1:
      ContinueGame;
    2:
      ShowHighScores;
  end;
end;

procedure TSceneMenu3.Continue;
begin
  inherited;
  SelectMenuItem;
end;

procedure TSceneMenu3.ContinueGame;
begin
  if Game.IsGame then
  begin
    Game.MediaPlayer.PlayMusic(mmMap);
    Game.Show(scMap);
  end;
end;

procedure TSceneMenu3.ShowHighScores;
begin
  TSceneRecords.ShowScene;
end;

constructor TSceneMenu3.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperMenu, False);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btContinue) then
      Button[LButtonEnum].Sellected := True;
  end;
end;

destructor TSceneMenu3.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneMenu3.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPartyPosition: Integer;
begin
  case AButton of
    mbLeft:
      begin
        LPartyPosition := GetFramePosition(X, Y);
        case LPartyPosition of
          0 .. 5:
            begin
              CurrentIndex := LPartyPosition;
              Game.MediaPlayer.PlaySound(mmClick);
              Exit;
            end;
        end;
        if Button[btQuit].MouseDown then
          ConfirmQuit;
        if Button[btContinue].MouseDown then
          SelectMenuItem;
      end;
  end;
end;

procedure TSceneMenu3.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneMenu3.Render;

  procedure RenderMenu;
  var
    I, LLeft, LTop, LX, LY: Integer;
  const
    MENU_SPRITE: array [0 .. 2] of TResEnum = (reMenuDragonLogo,
      reMenuContinueLogo, reMenuRecordsLogo);
    MENU_NAME: array [0 .. 2] of string = ('Play Game', 'Continue Game...',
      'High Scores Table');
  begin
    for I := 0 to High(MENU_SPRITE) do
    begin
      LX := IfThen(I > 2, 1, 0);
      LY := IfThen(I > 2, I - 3, I);
      LLeft := TFrame.Col(LX);
      LTop := TFrame.Row(LY);
      DrawImage(LLeft + 7, LTop + 7, MENU_SPRITE[I]);
      if (I = CurrentIndex) then
      begin
        if ((CurrentIndex = 1) and not Game.IsGame) then
          DrawImage(LLeft, LTop, reFrameSlotPassive);
        TextTop := TFrame.Row(0) + 6;
        TextLeft := TFrame.Col(2) + 12;
        AddTextLine(MENU_NAME[I], True);
        AddTextLine;
      end;
    end;
  end;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;
  DrawTitle(reTitleLogo);

  Credits;

  RenderMenu;
  RenderButtons;
end;

procedure TSceneMenu3.Timer;
begin
  inherited;

end;

procedure TSceneMenu3.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ENTER:
      SelectMenuItem;
    K_ESCAPE:
      if Game.IsGame then
        ContinueGame
      else
        ConfirmQuit;
    K_Q:
      ConfirmQuit;
  end;
end;

end.
