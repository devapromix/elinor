unit DisciplesRL.Scenes;

interface

uses
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Imaging.PNGImage,
  System.Types,
  System.Classes,
  SimplePlayer,
  DisciplesRL.Party,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button;

type
  TSceneEnum = (scHire, scMenu, scMap, scParty, scSettlement, scBattle2,
    scBattle3);

const
  Top = 220;
  Left = 10;
  DefaultButtonTop = 600;

type
  TMediaPlayer = class(TSimplePlayer)
    procedure Play(const MusicEnum: TMusicEnum); overload;
    procedure PlayMusic(const MusicEnum: TMusicEnum);
  end;

procedure DrawText(const AX, AY: Integer; AText: string); overload;
procedure DrawText(const AY: Integer; AText: string); overload;
procedure DrawText(const AX, AY: Integer; Value: Integer); overload;

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
    MouseX: Integer;
    MouseY: Integer;
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
    procedure DrawTitle(Res: TResEnum);
    procedure DrawImage(X, Y: Integer; Image: TPNGImage); overload;
    procedure DrawImage(Res: TResEnum); overload;
    procedure DrawImage(X, Y: Integer; Res: TResEnum); overload;
    procedure RenderFrame(const PartySide: TPartySide;
      const I, AX, AY: Integer);
    procedure DrawUnit(AResEnum: TResEnum; const AX, AY: Integer; F: Boolean);
    function ConfirmDialog(const S: string): Boolean;
    procedure InformDialog(const S: string);
    procedure DrawResources;
    function MouseOver(AX, AY, MX, MY: Integer): Boolean;
    function GetPartyPosition(const MX, MY: Integer): Integer;
  end;

type
  TScenes = class(TScene)
  private
    FSceneEnum: TSceneEnum;
    FScene: array [TSceneEnum] of IScene;
    procedure SetScene(const ASceneEnum: TSceneEnum);
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
    function GetScene(const I: TSceneEnum): TScene;
  end;

var
  Scenes: TScenes;
  Surface: TBitmap;
  MediaPlayer: TMediaPlayer;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.MainForm,
  DisciplesRL.ConfirmationForm,
  DisciplesRL.Scene.Map,
  DisciplesRL.Scene.Menu,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Battle3,
  DisciplesRL.Saga;

var
  MediaAvailable: Boolean;

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

procedure TScene.DrawTitle(Res: TResEnum);
begin
  DrawImage((Surface.Width div 2) - (ResImage[Res].Width div 2), 10, Res);
end;

function TScene.ConfirmDialog(const S: string): Boolean;
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

procedure TScene.InformDialog(const S: string);
begin
  ConfirmationForm.Msg := S;
  ConfirmationForm.SubScene := stInform;
  ConfirmationForm.ShowModal;
end;

procedure TScene.DrawImage(X, Y: Integer; Image: TPNGImage);
begin
  Surface.Canvas.Draw(X, Y, Image);
end;

procedure TScene.DrawImage(Res: TResEnum);
begin
  Surface.Canvas.StretchDraw(Rect(0, 0, Surface.Width, Surface.Height),
    ResImage[Res]);
end;

procedure TScene.DrawUnit(AResEnum: TResEnum; const AX, AY: Integer;
  F: Boolean);
begin
  if F then
    DrawImage(AX + 7, AY + 7, reBGChar)
  else
    DrawImage(AX + 7, AY + 7, reBGEnemy);
  DrawImage(AX + 7, AY + 7, AResEnum);
end;

procedure TScene.DrawImage(X, Y: Integer; Res: TResEnum);
begin
  DrawImage(X, Y, ResImage[Res]);
end;

procedure DrawText(const AX, AY: Integer; AText: string);
begin
  Surface.Canvas.TextOut(AX, AY, AText);
end;

procedure DrawText(const AX, AY: Integer; Value: Integer);
begin
  DrawText(AX, AY, Value.ToString);
end;

procedure DrawText(const AY: Integer; AText: string);
var
  S: Integer;
begin
  S := Surface.Canvas.TextWidth(AText);
  DrawText((Surface.Width div 2) - (S div 2), AY, AText);
end;

procedure TScene.RenderFrame(const PartySide: TPartySide;
  const I, AX, AY: Integer);
var
  J: Integer;
begin
  case PartySide of
    psLeft:
      J := I;
  else
    J := I + 6;
  end;
  if (ActivePartyPosition = J) and (CurrentPartyPosition > -1) then
    DrawImage(AX, AY, reActFrame)
  else
    DrawImage(AX, AY, reFrame);
end;

procedure TScene.DrawResources;
begin
  DrawImage(10, 10, reSmallFrame);
  DrawImage(15, 10, reGold);
  DrawText(45, 24, TSaga.Gold);
  DrawImage(15, 40, reMana);
  DrawText(45, 54, TSaga.Mana);
end;

function TScene.MouseOver(AX, AY, MX, MY: Integer): Boolean;
begin
  Result := (MX > AX) and (MX < AX + ResImage[reFrame].Width) and (MY > AY) and
    (MY < AY + ResImage[reFrame].Height);
end;

function TScene.GetPartyPosition(const MX, MY: Integer): Integer;
var
  R: Integer;
  Position: TPosition;
  PartySide: TPartySide;
begin
  R := -1;
  Result := R;
  for PartySide := Low(TPartySide) to High(TPartySide) do
    for Position := Low(TPosition) to High(TPosition) do
    begin
      Inc(R);
      if MouseOver(TSceneParty.GetFrameX(Position, PartySide),
        TSceneParty.GetFrameY(Position, PartySide), MX, MY) then
      begin
        Result := R;
        Exit;
      end;
    end;
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
    Self.Render;
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
