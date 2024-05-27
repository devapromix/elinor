unit DisciplesRL.Scenes;

interface

uses
{$IFDEF FPC}
  Graphics,
  Controls,
{$ELSE}
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Imaging.PNGImage,
{$ENDIF}
  Classes,
  DisciplesRL.Saga,
  DisciplesRL.Map,
  DisciplesRL.Party,
  DisciplesRL.Player,
  DisciplesRL.Resources;

type
  TSceneEnum = (scHire, scMenu, scMap, scParty, scSettlement, scBattle,
    scSpellbook);

const
  ScreenWidth = 1344;
  ScreenHeight = 704;

var
  TextTop, TextLeft: Integer;

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
  K_K = ord('K');
  K_L = ord('L');
  K_M = ord('M');
  K_N = ord('N');
  K_P = ord('P');
  K_Q = ord('Q');
  K_R = ord('R');
  K_S = ord('S');
  K_T = ord('T');
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

type
  TConfirmMethod = procedure() of object;

type
  TBGStat = (bsCharacter, bsEnemy, bsParalyze);

type
  TScene = class(TObject)
  private
    FWidth: Integer;
    FScrWidth: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function TextLineHeight: Byte;
    class function DefaultButtonTop: Word;
    class function SceneTop: Byte;
    class function SceneLeft: Byte;
    procedure Show(const S: TSceneEnum); virtual;
    procedure Render; virtual;
    procedure Update(var Key: Word); virtual;
    procedure Timer; virtual;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure DrawTitle(Res: TResEnum);
    procedure DrawImage(X, Y: Integer; Image: TPNGImage); overload;
    procedure DrawImage(Res: TResEnum); overload;
    procedure DrawImage(X, Y: Integer; Res: TResEnum); overload;
    procedure RenderFrame(const PartySide: TPartySide; const I, AX, AY: Integer;
      const F: Boolean = False);
    procedure DrawUnit(AResEnum: TResEnum; const AX, AY: Integer;
      F: TBGStat); overload;
    procedure DrawUnit(AResEnum: TResEnum; const AX, AY: Integer; F: TBGStat;
      HP, MaxHP: Integer); overload;
    procedure ConfirmDialog(const S: string; OnYes: TConfirmMethod = nil);
    procedure InformDialog(const S: string);
    procedure DrawResources;
    function MouseOver(AX, AY, MX, MY: Integer): Boolean; overload;
    function MouseOver(MX, MY, X1, Y1, X2, Y2: Integer): Boolean; overload;
    function GetPartyPosition(const MX, MY: Integer): Integer;
    property ScrWidth: Integer read FScrWidth write FScrWidth;
    property Width: Integer read FWidth write FWidth;
    procedure DrawText(const AX, AY: Integer; AText: string); overload;
    procedure DrawText(const AY: Integer; AText: string); overload;
    procedure DrawText(const AX, AY: Integer; Value: Integer); overload;
    procedure DrawText(const AX, AY: Integer; AText: string;
      F: Boolean); overload;
    procedure AddTextLine; overload;
    procedure AddTextLine(const S: string); overload;
    procedure AddTextLine(const S: string; const F: Boolean); overload;
    procedure AddTextLine(const S, V: string); overload;
    procedure AddTextLine(const S: string; const V: Integer); overload;
    procedure AddTextLine(const S: string; const V, M: Integer); overload;
  end;

type
  TScenes = class(TScene)
  private
    FSceneEnum: TSceneEnum;
    FScene: array [TSceneEnum] of TScene;
    procedure SetScene(const ASceneEnum: TSceneEnum);
  public
    InformMsg: string;
    IsShowInform: Boolean;
    IsShowConfirm: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Show(const S: TSceneEnum); override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    property SceneEnum: TSceneEnum read FSceneEnum write FSceneEnum;
    function GetScene(const I: TSceneEnum): TScene;
  end;

type

  { TTreasure }

  TTreasure = class(TObject)
  private
    FValuePerDay: Integer;
  public
    Value: Integer;
    Mines: Integer;
    NewValue: Integer;
    constructor Create(const ValuePerDay: Integer);
    procedure Clear(const StartValue: Integer);
    procedure Modify(Amount: Integer);
    procedure Mine;
    function FromMinePerDay: Integer;
    procedure AddMine;
  end;

type
  TGame = class(TScenes)
  public
    Day: Integer;
    IsNewDay: Boolean;
    ShowNewDayMessageTime: ShortInt;
    Gold: TTreasure;
    Mana: TTreasure;
    Wizard: Boolean;
    Surface: TBitmap;
    Statistics: TStatistics;
    Scenario: TScenario;
    Map: TMap;
    Player: TPlayer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure NewDay;
  end;

var
  Game: TGame;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.MainForm,
  DisciplesRL.Button,
  DisciplesRL.Creatures,
  DisciplesRL.Scene.Map,
  DisciplesRL.Scene.Menu,
  DisciplesRL.Scene.Menu2,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Battle3,
  DisciplesRL.Scene.Spellbook;

type
  TButtonEnum = (btOk, btCancel);

const
  ButtonsText: array [TButtonEnum] of TResEnum = (reTextOk, reTextCancel);
  MusicChannel = 0;

var
  Button: TButton;
  Buttons: array [TButtonEnum] of TButton;
  ConfirmHandler: TConfirmMethod;

  { TTreasure }

constructor TTreasure.Create(const ValuePerDay: Integer);
begin
  FValuePerDay := ValuePerDay;
end;

procedure TTreasure.Clear(const StartValue: Integer);
begin
  Value := StartValue;
  Mines := 0;
  NewValue := 0;
end;

procedure TTreasure.Modify(Amount: Integer);
begin
  Value := Value + Amount;
end;

procedure TTreasure.Mine;
begin
  Modify(FromMinePerDay);
end;

function TTreasure.FromMinePerDay: Integer;
begin
  Result := Mines * FValuePerDay;
end;

procedure TTreasure.AddMine;
begin
  Inc(Mines);
end;

{ TGame }

constructor TGame.Create;
var
  I: Integer;
begin
  inherited;
  Surface := TBitmap.Create;
  Surface.Width := ScreenWidth;
  Surface.Height := ScreenHeight;
  Surface.Canvas.Font.Size := 12;
  Surface.Canvas.Font.Color := clGreen;
  Surface.Canvas.Brush.Style := bsClear;
  Wizard := False;
  for I := 1 to ParamCount do
  begin
    if (LowerCase(ParamStr(I)) = '-w') then
      Wizard := True;
  end;
  Randomize;
  Gold := TTreasure.Create(100);
  Mana := TTreasure.Create(10);
  Map := TMap.Create;
  Statistics := TStatistics.Create;
  Scenario := TScenario.Create;
  Player := TPlayer.Create;
  Player.PlayMusic(mmMenu);
  SceneEnum := scMenu;
end;

destructor TGame.Destroy;
begin
  FreeAndNil(Statistics);
  FreeAndNil(Scenario);
  FreeAndNil(Map);
  FreeAndNil(Player);
  FreeAndNil(Surface);
  FreeAndNil(Gold);
  FreeAndNil(Mana);
  inherited;
end;

procedure TGame.Clear;
begin
  Day := 1;
  IsNewDay := False;
  ShowNewDayMessageTime := 0;
  Gold.Clear(250);
  Mana.Clear(10);
  Statistics.Clear;
  Scenario.Clear;
  Map.Clear;
  Map.Gen;
end;

procedure TGame.NewDay;
begin
  if IsNewDay then
  begin
    Gold.Mine;
    Mana.Mine;
    Map.Clear(lrSee);
    if (TLeaderParty.Leader.Enum in LeaderWarrior) then
      TLeaderParty.Leader.HealAll(TSaga.LeaderWarriorHealAllInPartyPerDay);
    TLeaderParty.Leader.Spells := TLeaderParty.Leader.GetMaxSpells;
    TLeaderParty.Leader.Spy := TLeaderParty.Leader.GetMaxSpy;
    ShowNewDayMessageTime := 20;
    Player.PlaySound(mmDay);
    IsNewDay := False;
  end;

end;

{ TScene }

constructor TScene.Create;
begin
  inherited;
  Width := ScreenWidth;
  ScrWidth := Width div 2;
  ConfirmHandler := nil;
end;

class function TScene.DefaultButtonTop: Word;
begin
  Result := 600;
end;

destructor TScene.Destroy;
begin

  inherited;
end;

procedure TScene.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin

end;

procedure TScene.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TScene.Render;
begin

end;

class function TScene.SceneLeft: Byte;
begin
  Result := 10;
end;

class function TScene.SceneTop: Byte;
begin
  Result := 220;
end;

procedure TScene.Show(const S: TSceneEnum);
begin

end;

function TScene.TextLineHeight: Byte;
begin
  Result := 24;
end;

procedure TScene.Timer;
begin

end;

procedure TScene.Update(var Key: Word);
begin

end;

procedure TScene.DrawTitle(Res: TResEnum);
begin
  DrawImage(ScrWidth - (ResImage[Res].Width div 2), 10, Res);
end;

procedure TScene.AddTextLine;
begin
  Inc(TextTop, TextLineHeight);
end;

procedure TScene.AddTextLine(const S: string; const F: Boolean);
begin
  DrawText(TextLeft, TextTop, S, F);
  Inc(TextTop, TextLineHeight);
end;

procedure TScene.AddTextLine(const S: string);
begin
  AddTextLine(S, False);
end;

procedure TScene.AddTextLine(const S: string; const V: Integer);
begin
  AddTextLine(Format('%s: %d', [S, V]));
end;

procedure TScene.AddTextLine(const S, V: string);
begin
  AddTextLine(Format('%s: %s', [S, V]));
end;

procedure TScene.AddTextLine(const S: string; const V, M: Integer);
begin
  AddTextLine(Format('%s: %d/%d', [S, V, M]));
end;

procedure TScene.ConfirmDialog(const S: string; OnYes: TConfirmMethod);
begin
  Game.Player.PlaySound(mmExit);
  Game.InformMsg := S;
  Game.IsShowConfirm := True;
  ConfirmHandler := OnYes;
end;

procedure TScene.InformDialog(const S: string);
begin
  Game.Player.PlaySound(mmExit);
  Game.InformMsg := S;
  Game.IsShowInform := True;
end;

procedure TScene.DrawImage(X, Y: Integer; Image: TPNGImage);
begin
  Game.Surface.Canvas.Draw(X, Y, Image);
end;

procedure TScene.DrawImage(Res: TResEnum);
begin
  Game.Surface.Canvas.StretchDraw(Rect(0, 0, Game.Surface.Width,
    Game.Surface.Height), ResImage[Res]);
end;

procedure TScene.DrawUnit(AResEnum: TResEnum; const AX, AY: Integer;
  F: TBGStat);
begin
  case F of
    bsCharacter:
      DrawImage(AX + 7, AY + 7, reBGChar);
    bsEnemy:
      DrawImage(AX + 7, AY + 7, reBGEnemy);
    bsParalyze:
      DrawImage(AX + 7, AY + 7, reBGParalyze);
  end;
  DrawImage(AX + 7, AY + 7, AResEnum);
end;

procedure TScene.DrawUnit(AResEnum: TResEnum; const AX, AY: Integer; F: TBGStat;
  HP, MaxHP: Integer);
var
  TmpImage: TPNGImage;
  CHP: Integer;

  function BarHeight(CY, MY, GS: Integer): Integer;
  var
    I: Integer;
  begin
    if (CY < 0) then
      CY := 0;
    if (CY = MY) and (CY = 0) then
    begin
      Result := 0;
      Exit;
    end;
    if (MY <= 0) then
      MY := 1;
    I := (CY * GS) div MY;
    if I <= 0 then
      I := 0;
    if (CY >= MY) then
      I := GS;
    Result := I;
  end;

begin
  DrawImage(AX + 7, AY + 7, reBGParalyze);
  CHP := BarHeight(HP, MaxHP, 104);
  TmpImage := TPNGImage.Create;
  try
    case F of
      bsCharacter:
        TmpImage.Assign(ResImage[reBGChar]);
      bsEnemy:
        TmpImage.Assign(ResImage[reBGEnemy]);
      bsParalyze:
        TmpImage.Assign(ResImage[reBGParalyze]);
    end;
    if (CHP > 0) then
    begin
      TmpImage.SetSize(64, EnsureRange(CHP, 0, 104));
      DrawImage(AX + 7, AY + 7 + (104 - CHP), TmpImage);
    end;
    DrawImage(AX + 7, AY + 7, AResEnum);
  finally
    FreeAndNil(TmpImage);
  end;
end;

procedure TScene.DrawImage(X, Y: Integer; Res: TResEnum);
begin
  DrawImage(X, Y, ResImage[Res]);
end;

procedure TScene.DrawText(const AX, AY: Integer; AText: string);
var
  vStyle: TBrushStyle;
begin
  vStyle := Game.Surface.Canvas.Brush.Style;
  Game.Surface.Canvas.Brush.Style := bsClear;
  Game.Surface.Canvas.TextOut(AX, AY, AText);
  Game.Surface.Canvas.Brush.Style := vStyle;
end;

procedure TScene.DrawText(const AX, AY: Integer; Value: Integer);
begin
  DrawText(AX, AY, Value.ToString);
end;

procedure TScene.DrawText(const AY: Integer; AText: string);
var
  S: Integer;
begin
  S := Game.Surface.Canvas.TextWidth(AText);
  DrawText((Game.Surface.Width div 2) - (S div 2), AY, AText);
end;

procedure TScene.DrawText(const AX, AY: Integer; AText: string; F: Boolean);
var
  N: Integer;
begin
  if F then
  begin
    N := Game.Surface.Canvas.Font.Size;
    Game.Surface.Canvas.Font.Size := N * 2;
  end;
  DrawText(AX, AY, AText);
  if F then
    Game.Surface.Canvas.Font.Size := N;
end;

procedure TScene.RenderFrame(const PartySide: TPartySide;
  const I, AX, AY: Integer; const F: Boolean);
var
  J: Integer;
begin
  case PartySide of
    psLeft:
      J := I;
  else
    J := I + 6;
  end;
  if (ActivePartyPosition = J) then
  begin
    if F then
      DrawImage(AX, AY, rePasFrame)
    else
      DrawImage(AX, AY, reActFrame);
  end
  else if (SelectPartyPosition = J) then
    DrawImage(AX, AY, reSelectFrame)
  else
    DrawImage(AX, AY, reFrame);
end;

procedure TScene.DrawResources;
begin
  DrawImage(10, 10, reSmallFrame);
  DrawImage(15, 10, reGold);
  DrawText(45, 24, Game.Gold.Value);
  DrawImage(15, 40, reMana);
  DrawText(45, 54, Game.Mana.Value);

  DrawText(45, 84, Game.Day);
end;

function TScene.MouseOver(MX, MY, X1, Y1, X2, Y2: Integer): Boolean;
begin
  Result := (MX > X1) and (MX < X1 + X2) and (MY > Y1) and (MY < Y1 + Y2);
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

{ TScenes }

constructor TScenes.Create;
var
  L: Integer;
  I: TButtonEnum;
begin
  inherited;
  FScene[scMap] := TSceneMap.Create;
  FScene[scMenu] := TSceneMenu2.Create;
  FScene[scHire] := TSceneHire.Create;
  FScene[scParty] := TSceneParty.Create;
  FScene[scBattle] := TSceneBattle2.Create;
  FScene[scSettlement] := TSceneSettlement.Create;
  FScene[scSpellbook] := TSceneSpellbook.Create;
  // Inform
  InformMsg := '';
  IsShowInform := False;
  L := ScrWidth - (ResImage[reButtonDef].Width div 2);
  Button := TButton.Create(L, 400, reTextOk);
  Button.Sellected := True;
  // Confirm
  IsShowConfirm := False;
  L := ScrWidth - ((ResImage[reButtonDef].Width * 2) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Buttons[I] := TButton.Create(L, 400, ButtonsText[I]);
    Inc(L, ResImage[reButtonDef].Width);
    if (I = btOk) then
      Buttons[I].Sellected := True;
  end;
end;

destructor TScenes.Destroy;
var
  I: TButtonEnum;
  S: TSceneEnum;
begin
  for S := Low(TSceneEnum) to High(TSceneEnum) do
    FreeAndNil(FScene[S]);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Buttons[I]);
  FreeAndNil(Button);
  TSaga.PartyFree;
  inherited;
end;

function TScenes.GetScene(const I: TSceneEnum): TScene;
begin
  Result := TScene(FScene[I]);
end;

procedure TScenes.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (FScene[SceneEnum] <> nil) then
  begin
    if IsShowInform then
    begin
      case AButton of
        mbLeft:
          begin
            if Button.MouseDown then
            begin
              IsShowInform := False;
              Self.Render;
              Exit;
            end
            else
              Exit;
          end;
      end;
      Exit;
    end;
    if IsShowConfirm then
    begin
      case AButton of
        mbLeft:
          begin
            if Buttons[btOk].MouseDown then
            begin
              IsShowConfirm := False;
              if Assigned(ConfirmHandler) then
              begin
                ConfirmHandler();
                ConfirmHandler := nil;
              end;
              Self.Render;
              Exit;
            end
            else if Buttons[btCancel].MouseDown then
            begin
              IsShowConfirm := False;
              Self.Render;
              Exit;
            end
            else
              Exit;
          end;
      end;
      Exit;
    end;
    FScene[SceneEnum].MouseDown(AButton, Shift, X, Y);
    Self.Render;
  end;
end;

procedure TScenes.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  if (FScene[SceneEnum] <> nil) then
  begin
    if IsShowInform then
    begin
      Button.MouseMove(X, Y);
      Exit;
    end;
    if IsShowConfirm then
    begin
      for I := Low(TButtonEnum) to High(TButtonEnum) do
        Buttons[I].MouseMove(X, Y);
      Exit;
    end;
    FScene[SceneEnum].MouseMove(Shift, X, Y);
    Self.Render;
  end;
end;

procedure TScenes.Render;
var
  I: TButtonEnum;
begin
  inherited;
  if (FScene[SceneEnum] <> nil) then
  begin
    Game.Surface.Canvas.Brush.Color := clBlack;
    Game.Surface.Canvas.FillRect(Rect(0, 0, Game.Surface.Width,
      Game.Surface.Height));
    FScene[SceneEnum].Render;
    if IsShowInform or IsShowConfirm then
    begin
      DrawImage(ScrWidth - (ResImage[reBigFrame].Width div 2), 150,
        ResImage[reBigFrame]);
      DrawText(250, InformMsg);
      if IsShowInform then
        Button.Render;
      if IsShowConfirm then
        for I := Low(Buttons) to High(Buttons) do
          Buttons[I].Render;
    end;
    MainForm.Canvas.Draw(0, 0, Game.Surface);
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
    Game.Render;
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
    if IsShowInform then
    begin
      case Key of
        K_ESCAPE, K_ENTER:
          begin
            IsShowInform := False;
            Self.Render;
            Exit;
          end
      else
        Exit;
      end;
    end;
    if IsShowConfirm then
    begin
      case Key of
        K_ENTER:
          begin
            IsShowConfirm := False;
            if Assigned(ConfirmHandler) then
            begin
              ConfirmHandler();
              ConfirmHandler := nil;
            end;
            Self.Render;
            Exit;
          end;
        K_ESCAPE:
          begin
            IsShowConfirm := False;
            Self.Render;
            Exit;
          end
      else
        Exit;
      end;
    end;
    FScene[SceneEnum].Update(Key);
    Self.Render;
  end;
end;

end.
