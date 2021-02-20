unit DisciplesRL.Scenes;

interface

uses
  Vcl.Graphics,
  Vcl.Controls,
  System.Types,
  System.Classes,
  Vcl.Imaging.PNGImage,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button,
  SimplePlayer;

type
  TSceneEnum = (scHire, scMenu, scMap, scParty, scSettlement, scBattle2,
    scBattle3);

const
  DefaultButtonTop = 600;

var
  Surface: TBitmap;

type
  TMediaPlayer = class(TSimplePlayer)
    procedure Play(const MusicEnum: TMusicEnum); overload;
    procedure PlayMusic(const MusicEnum: TMusicEnum);
  end;

procedure LeftTextOut(const AX, AY: Integer; AText: string);
procedure CenterTextOut(const AY: Integer; AText: string);
procedure RenderDark;
procedure DrawTitle(Res: TResEnum);
procedure DrawImage(X, Y: Integer; Image: TPNGImage); overload;
procedure DrawImage(Res: TResEnum); overload;
procedure DrawImage(X, Y: Integer; Res: TResEnum); overload;
function ConfirmDialog(const S: string): Boolean;
procedure InformDialog(const S: string);

const
  K_ESCAPE = 27;
  K_ENTER = 13;
  K_SPACE = 32;

  K_A = ord('A');
  K_B = ord('B');
  K_C = ord('C');
  K_D = ord('D');
  K_E = ord('E');
  K_I = ord('I');
  K_J = ord('J');
  K_H = ord('H');
  K_P = ord('P');
  K_Q = ord('Q');
  K_R = ord('R');
  K_S = ord('S');
  K_V = ord('V');
  K_W = ord('W');
  K_X = ord('X');
  K_Z = ord('Z');

  K_RIGHT = 39;
  K_LEFT = 37;
  K_DOWN = 40;
  K_UP = 38;

  K_KP_1 = 97;
  K_KP_2 = 98;
  K_KP_3 = 99;
  K_KP_4 = 100;
  K_KP_5 = 101;
  K_KP_6 = 102;
  K_KP_7 = 103;
  K_KP_8 = 104;
  K_KP_9 = 105;

  { TScene }

type
  IScene = interface
    procedure Show(const S: TSceneEnum);
    procedure Render;
    procedure Update(var Key: Word);
    procedure Timer;
    procedure Click;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
  end;

type
  TScene = class(TInterfacedObject, IScene)
  private

  public
    MouseX, MouseY: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Show(const S: TSceneEnum); virtual;
    procedure Render; virtual;
    procedure Update(var Key: Word); virtual;
    procedure Timer; virtual;
    procedure Click; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
  end;

type
  TScenes = class(TScene)
  private
    FSceneEnum: TSceneEnum;
    FScene: array [TSceneEnum] of IScene;
    FPrevSceneEnum: TSceneEnum;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Show(const S: TSceneEnum); override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    property SceneEnum: TSceneEnum read FSceneEnum write FSceneEnum;
    property PrevSceneEnum: TSceneEnum read FPrevSceneEnum;
    function GetScene(const I: TSceneEnum): TScene;
    procedure SetScene(const ASceneEnum: TSceneEnum); overload;
    procedure SetScene(const ASceneEnum: TSceneEnum;
      const CurrSceneEnum: TSceneEnum); overload;
    procedure GoBack;
  end;

var
  Scenes: TScenes;
  MediaPlayer: TMediaPlayer;

implementation

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.MainForm,
  DisciplesRL.ConfirmationForm,
  DisciplesRL.Scene.Map,
  DisciplesRL.Scene.Menu,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Battle3,
  DisciplesRL.Scene.Party,
  DisciplesRL.Saga;

var
  CurrentScene: TSceneEnum;
  MediaAvailable: Boolean;
  MouseX, MouseY: Integer;

  { TScene }

procedure TScene.Click;
begin

end;

constructor TScene.Create;
begin
  inherited;

end;

destructor TScene.Destroy;
begin

  inherited;
end;

procedure TScene.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin

end;

procedure TScene.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MouseX := X;
  MouseY := Y;
end;

procedure TScene.Render;
begin

end;

procedure TScene.Show;
begin

end;

procedure TScene.Timer;
begin

end;

procedure TScene.Update(var Key: Word);
begin

end;

function ConfirmDialog(const S: string): Boolean;
begin
  Result := False;
  ConfirmationForm.Msg := S;
  ConfirmationForm.SubScene := stConfirm;
  ConfirmationForm.ShowModal;
  case ConfirmationForm.ModalResult of
    mrOk:
      Result := True;
  end;
end;

procedure InformDialog(const S: string);
begin
  ConfirmationForm.Msg := S;
  ConfirmationForm.SubScene := stInform;
  ConfirmationForm.ShowModal;
end;

procedure DrawTitle(Res: TResEnum);
begin
  DrawImage((Surface.Width div 2) - (ResImage[Res].Width div 2), 10, Res);
end;

procedure DrawImage(X, Y: Integer; Image: TPNGImage);
begin
  Surface.Canvas.Draw(X, Y, Image);
end;

procedure DrawImage(Res: TResEnum);
begin
  Surface.Canvas.StretchDraw(Rect(0, 0, Surface.Width, Surface.Height),
    ResImage[Res]);
end;

procedure DrawImage(X, Y: Integer; Res: TResEnum);
begin
  DrawImage(X, Y, ResImage[Res]);
end;

procedure LeftTextOut(const AX, AY: Integer; AText: string);
begin
  Surface.Canvas.TextOut(AX, AY, AText);
end;

procedure CenterTextOut(const AY: Integer; AText: string);
var
  S: Integer;
begin
  S := Surface.Canvas.TextWidth(AText);
  LeftTextOut((Surface.Width div 2) - (S div 2), AY, AText);
end;

procedure RenderDark;
begin
  Scenes.Render;
  Surface.Canvas.StretchDraw(Rect(0, 0, Surface.Width, Surface.Height),
    ResImage[reDark]);
end;

{ TMediaPlayer }

procedure TMediaPlayer.Play(const MusicEnum: TMusicEnum);
begin
  Play(ResMusicPath[MusicEnum], MusicBase[MusicEnum].ResType = teMusic);
end;

procedure TMediaPlayer.PlayMusic(const MusicEnum: TMusicEnum);
begin
  if TSaga.NoMusic or not MediaAvailable then
    Exit;
  StopMusic;
  CurrentChannel := MusicChannel;
  Play(MusicEnum);
  CurrentChannel := 1;
end;

{ TScenes }

procedure TScenes.Click;
begin
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].Click;
  end;
end;

constructor TScenes.Create;
var
  J: Integer;
begin
  Randomize;
  //
  Surface := TBitmap.Create;
  Surface.Width := MainForm.ClientWidth;
  Surface.Height := MainForm.ClientHeight;
  Surface.Canvas.Font.Size := 12;
  Surface.Canvas.Font.Color := clGreen;
  Surface.Canvas.Brush.Style := bsClear;
  //
  TSaga.Wizard := False;
  TSaga.NoMusic := False;
  TSaga.NewBattle := False;
  for J := 1 to ParamCount do
  begin
    if (LowerCase(ParamStr(J)) = '-w') then
      TSaga.Wizard := True;
    if (LowerCase(ParamStr(J)) = '-m') then
      TSaga.NoMusic := True;
    if (LowerCase(ParamStr(J)) = '-b') then
      TSaga.NewBattle := True;
  end;
  //
  try
    MediaPlayer := TMediaPlayer.Create;
    MediaAvailable := True;
  except
    MediaAvailable := False;
  end;
  MediaPlayer.PlayMusic(mmMenu);
  SceneEnum := scMenu;
  //
  FScene[scMap] := TSceneMap.Create;
  FScene[scMenu] := TSceneMenu.Create;
  FScene[scHire] := TSceneHire.Create;
  FScene[scParty] := TSceneParty.Create;
  FScene[scBattle2] := TSceneBattle2.Create;
  FScene[scBattle3] := TSceneBattle3.Create;
  FScene[scSettlement] := TSceneSettlement.Create;
end;

destructor TScenes.Destroy;
begin
  MediaPlayer.Stop;
  FreeAndNil(MediaPlayer);
  FreeAndNil(Surface);
  TSaga.PartyFree;
  inherited;
end;

function TScenes.GetScene(const I: TSceneEnum): TScene;
begin
  Result := TScene(FScene[I]);
end;

procedure TScenes.GoBack;
begin
  Self.SceneEnum := FPrevSceneEnum;
end;

procedure TScenes.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].MouseDown(Button, Shift, X, Y);
    Self.Render;
  end;
end;

procedure TScenes.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].MouseMove(Shift, X, Y);
  end;
end;

procedure TScenes.Render;
begin
  if (FScene[SceneEnum] <> nil) then
  begin
    Surface.Canvas.Brush.Color := clBlack;
    Surface.Canvas.FillRect(Rect(0, 0, Surface.Width, Surface.Height));
    FScene[SceneEnum].Render;
    MainForm.Canvas.Draw(0, 0, Surface);
  end;
end;

procedure TScenes.SetScene(const ASceneEnum: TSceneEnum);
begin
  Self.SceneEnum := ASceneEnum;
  Scenes.SetScene(ASceneEnum);
end;

procedure TScenes.SetScene(const ASceneEnum, CurrSceneEnum: TSceneEnum);
begin
  FPrevSceneEnum := CurrSceneEnum;
  Self.SetScene(ASceneEnum);
end;

procedure TScenes.Show(const S: TSceneEnum);
begin
  SetScene(S);
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].Show(S);
    Scenes.Render;
  end;
end;

procedure TScenes.Timer;
begin
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].Timer;
  end;
end;

procedure TScenes.Update(var Key: Word);
begin
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].Update(Key);
    Self.Render;
  end;
end;

end.
