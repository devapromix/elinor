unit Elinor.Scenes;

interface

uses
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Imaging.PNGImage,
  Elinor.Creatures,
  Elinor.Saga,
  Elinor.Spells,
  Elinor.Map,
  Elinor.Party,
  Elinor.Scenario,
  Elinor.MediaPlayer,
  Elinor.Treasure,
  Elinor.Statistics,
  Elinor.Resources;

type
  TSceneEnum = (scHire, scHire2, scMenu, scMap, scParty, scSettlement, scBattle,
    scSpellbook, scDifficulty, scScenario, scRace, scLeader, scTemple,
    scBarracks, scInventory, scAbilities, scNewAbility, scMageTower,
    scHighScores, scVictory, scDefeat);

const
  ScreenWidth = 1344;
  ScreenHeight = 704;

var
  TextTop, TextLeft: Integer;

const
  K_ESCAPE = 27;
  K_ENTER = 13;
  K_SPACE = 32;
  K_TAB = 9;

  K_A = ord('A');
  K_B = ord('B');
  K_C = ord('C');
  K_D = ord('D');
  K_E = ord('E');
  K_F = ord('F');
  K_G = ord('G');
  K_H = ord('H');
  K_I = ord('I');
  K_J = ord('J');
  K_K = ord('K');
  K_L = ord('L');
  K_M = ord('M');
  K_N = ord('N');
  K_O = ord('O');
  K_P = ord('P');
  K_Q = ord('Q');
  K_R = ord('R');
  K_S = ord('S');
  K_T = ord('T');
  K_U = ord('U');
  K_V = ord('V');
  K_W = ord('W');
  K_X = ord('X');
  K_Y = ord('Y');
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
    procedure DrawCreatureReach(const AReachEnum: TReachEnum);
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
    procedure RenderFrame(const PartySide: TPartySide;
      const APartyPosition, AX, AY: Integer; const F: Boolean = False);
    procedure DrawUnit(AResEnum: TResEnum; const AX, AY: Integer;
      ABGStat: TBGStat); overload;
    procedure DrawUnit(AResEnum: TResEnum; const AX, AY: Integer;
      ABGStat: TBGStat; HP, MaxHP: Integer); overload;
    procedure DrawUnit(Position: TPosition; Party: TParty; AX, AY: Integer;
      CanHire: Boolean = False; ShowExp: Boolean = True); overload;
    procedure DrawCreatureInfo(Name: string; AX, AY, Level, Experience,
      HitPoints, MaxHitPoints, Damage, Heal, Armor, Initiative,
      ChToHit: Integer; IsExp: Boolean); overload;
    procedure DrawCreatureInfo(Position: TPosition; Party: TParty;
      AX, AY: Integer; ShowExp: Boolean = True); overload;
    procedure DrawUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
      IsAdv: Boolean = True); overload;
    procedure ConfirmDialog(const S: string; OnYes: TConfirmMethod = nil);
    procedure InformDialog(const S: string);
    procedure DrawResources;
    function MouseOver(AX, AY, MX, MY: Integer): Boolean; overload;
    function MouseOver(MX, MY, X1, Y1, X2, Y2: Integer): Boolean; overload;
    function GetPartyPosition(const AX, AY: Integer): Integer;
    function GetFramePosition(const AX, AY: Integer): Integer;
    property ScrWidth: Integer read FScrWidth write FScrWidth;
    property Width: Integer read FWidth write FWidth;
    procedure DrawText(const AX, AY: Integer; AText: string); overload;
    procedure DrawText(const AY: Integer; AText: string); overload;
    procedure DrawText(const AX, AY: Integer; Value: Integer); overload;
    procedure DrawText(const AX, AY: Integer; AText: string;
      AFlag: Boolean); overload;
    procedure AddTextLine; overload;
    procedure AddTextLine(const S: string); overload;
    procedure AddTextLine(const S: string; const F: Boolean); overload;
    procedure AddTextLine(const S, V: string); overload;
    procedure AddTextLine(const S: string; const V: Integer); overload;
    procedure AddTextLine(const S: string; const V, M: Integer); overload;
    procedure DrawCreatureInfo(const ACreature: TCreatureBase); overload;
    procedure DrawCreatureInfo(const ACreature: TCreature); overload;
    procedure DrawSpell(const ASpellEnum: TSpellEnum; const AX, AY: Integer;
      IsDrawTransparent: Boolean = False);
    procedure DrawAbility(const AAbilityEnum: TAbilityEnum;
      const AX, AY: Integer);
    procedure RenderLeaderInfo(const AIsOnlyStatistics: Boolean = False);
    procedure RenderGuardianInfo;

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
    procedure Show(const ASceneEnum: TSceneEnum); override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    property SceneEnum: TSceneEnum read FSceneEnum write FSceneEnum;
    function GetScene(const ASceneEnum: TSceneEnum): TScene;
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
    MediaPlayer: TMediaPlayer;
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
  Elinor.MainForm,
  Elinor.Button,
  Elinor.Scene.Map,
  DisciplesRL.Scene.Menu,
  DisciplesRL.Scene.Menu2,
  Elinor.Scene.Settlement,
  Elinor.Scene.Party,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.Battle2,
  Elinor.Scene.Battle3,
  Elinor.Scene.Spellbook,
  Elinor.Frame,
  Elinor.Scene.Difficulty,
  Elinor.Scene.Faction,
  Elinor.Scene.Leader,
  Elinor.Scene.Scenario,
  Elinor.Scene.Temple,
  Elinor.Scene.Barracks,
  Elinor.Spellbook,
  Elinor.Scene.Party2,
  Elinor.Scene.Hire,
  Elinor.Faction,
  Elinor.Scene.Inventory,
  Elinor.Scene.Abilities,
  Elinor.Scene.NewAbility,
  Elinor.Scene.MageTower,
  Elinor.Scene.HighScores,
  Elinor.Scene.Victory,
  Elinor.Scene.Defeat,
  Elinor.Difficulty;

type
  TButtonEnum = (btOk, btCancel);

const
  ButtonsText: array [TButtonEnum] of TResEnum = (reTextOk, reTextCancel);
  MusicChannel = 0;

var
  Button: TButton;
  Buttons: array [TButtonEnum] of TButton;
  ConfirmHandler: TConfirmMethod;

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
  Surface.Canvas.Font.Color := clSilver;
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
  MediaPlayer := TMediaPlayer.Create;
  MediaPlayer.PlayMusic(mmMenu);
  SceneEnum := scMenu;
end;

destructor TGame.Destroy;
begin
  FreeAndNil(Statistics);
  FreeAndNil(Scenario);
  FreeAndNil(Map);
  FreeAndNil(MediaPlayer);
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
  if Wizard then
    Gold.Clear(5000)
  else
    Gold.Clear(250);
  if Wizard then
    Mana.Clear(500)
  else
    Mana.Clear(10);
  Statistics.Clear;
  Spells.Clear;
  Scenario.Clear;
  Map.Clear;
  Map.Gen;
end;

procedure TGame.NewDay;
begin
  if IsNewDay then
  begin
    Gold.Mine;
    Game.Statistics.IncValue(stGoldMined, Gold.FromMinePerDay);
    Mana.Mine;
    Game.Statistics.IncValue(stManaMined, Mana.FromMinePerDay);
    Map.Clear(lrSee);
    Map.UnParalyzeAllParties;
    if (TLeaderParty.Leader.Enum in FighterLeaders) then
      TLeaderParty.Leader.HealParty(TSaga.LeaderWarriorHealAllInPartyPerDay);
    TLeaderParty.Leader.SpellsPerDay.SetToMaxValue;
    ShowNewDayMessageTime := 20;
    MediaPlayer.PlaySound(mmDay);
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
  Game.MediaPlayer.PlaySound(mmExit);
  Game.InformMsg := S;
  Game.IsShowConfirm := True;
  ConfirmHandler := OnYes;
end;

procedure TScene.InformDialog(const S: string);
begin
  Game.MediaPlayer.PlaySound(mmExit);
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

procedure TScene.DrawSpell(const ASpellEnum: TSpellEnum; const AX, AY: Integer;
  IsDrawTransparent: Boolean = False);
begin
  DrawImage(AX + 7, AY + 29, TSpells.Spell(ASpellEnum).ResEnum);
  DrawImage(AX + 7, AY + 7, Spellbook.SpellBackground(ASpellEnum));
  if IsDrawTransparent then
    DrawImage(AX + 7, AY + 7, reBGTransparent);
end;

procedure TScene.DrawAbility(const AAbilityEnum: TAbilityEnum;
  const AX, AY: Integer);
begin
  DrawImage(AX + 7, AY + 29, TAbilities.Ability(AAbilityEnum).ResEnum);
  DrawImage(AX + 7, AY + 7, reBGAbility);
end;

procedure TScene.DrawUnit(AResEnum: TResEnum; const AX, AY: Integer;
  ABGStat: TBGStat);
begin
  case ABGStat of
    bsCharacter:
      DrawImage(AX + 7, AY + 7, reBGCharacter);
    bsEnemy:
      DrawImage(AX + 7, AY + 7, reBGEnemy);
    bsParalyze:
      DrawImage(AX + 7, AY + 7, reBGParalyze);
  end;
  DrawImage(AX + 7, AY + 7, AResEnum);
end;

procedure TScene.DrawUnit(AResEnum: TResEnum; const AX, AY: Integer;
  ABGStat: TBGStat; HP, MaxHP: Integer);
const
  MaxHeight = 104;
var
  LImage: TPNGImage;
  LHeight: Integer;

  function BarHeight(CY, MY: Integer): Integer;
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
    I := (CY * MaxHeight) div MY;
    if I <= 0 then
      I := 0;
    if (CY >= MY) then
      I := MaxHeight;
    Result := I;
  end;

begin
  DrawImage(AX + 7, AY + 7, reBGParalyze);
  LHeight := BarHeight(HP, MaxHP);
  LImage := TPNGImage.Create;
  try
    case ABGStat of
      bsCharacter:
        LImage.Assign(ResImage[reBGCharacter]);
      bsEnemy:
        LImage.Assign(ResImage[reBGEnemy]);
      bsParalyze:
        LImage.Assign(ResImage[reBGParalyze]);
    end;
    if (LHeight > 0) then
    begin
      LImage.SetSize(64, EnsureRange(LHeight, 0, 104));
      DrawImage(AX + 7, AY + 7 + (MaxHeight - LHeight), LImage);
    end;
    DrawImage(AX + 7, AY + 7, AResEnum);
  finally
    FreeAndNil(LImage);
  end;
end;

procedure TScene.DrawCreatureInfo(Position: TPosition; Party: TParty;
  AX, AY: Integer; ShowExp: Boolean);
begin
  with Party.Creature[Position] do
  begin
    if Active then
      DrawCreatureInfo(Name[0], AX, AY, Level, Experience,
        HitPoints.GetCurrValue, HitPoints.GetMaxValue, Damage.GetFullValue(),
        Heal, Armor.GetFullValue(), Initiative.GetFullValue(),
        ChancesToHit.GetFullValue(), ShowExp);
  end;
end;

procedure TScene.DrawCreatureInfo(Name: string;
  AX, AY, Level, Experience, HitPoints, MaxHitPoints, Damage, Heal, Armor,
  Initiative, ChToHit: Integer; IsExp: Boolean);
var
  LExp: string;
begin
  DrawText(AX + SceneLeft + 64, AY + 6, Name);
  LExp := '';
  if IsExp then
    LExp := Format(' Exp %d/%d',
      [Experience, Party[TLeaderParty.LeaderPartyIndex]
      .GetMaxExperiencePerLevel(Level)]);
  DrawText(AX + SceneLeft + 64, AY + 27, Format('Level %d', [Level]) + LExp);
  DrawText(AX + SceneLeft + 64, AY + 48, Format('Hit points %d/%d',
    [HitPoints, MaxHitPoints]));
  if Damage > 0 then
    DrawText(AX + SceneLeft + 64, AY + 69, Format('Damage %d Armor %d',
      [Damage, Armor]))
  else
    DrawText(AX + SceneLeft + 64, AY + 69, Format('Heal %d Armor %d',
      [Heal, Armor]));
  DrawText(AX + SceneLeft + 64, AY + 90,
    Format('Initiative %d Chances to hit %d', [Initiative, ChToHit]) + '%');
end;

procedure TScene.DrawCreatureReach(const AReachEnum: TReachEnum);
begin
  case AReachEnum of
    reAny:
      begin
        AddTextLine('Distance', 'Any unit');
        AddTextLine('Targets', 1);
      end;
    reAdj:
      begin
        AddTextLine('Distance', 'Adjacent units');
        AddTextLine('Targets', 1);
      end;
    reAll:
      begin
        AddTextLine('Distance', 'All units');
        AddTextLine('Targets', 6);
      end;
  end;
end;

procedure TScene.DrawCreatureInfo(const ACreature: TCreatureBase);
var
  I: Integer;
begin
  with ACreature do
  begin
    AddTextLine(Name[0], True);
    AddTextLine;
    AddTextLine('Level', Level);
    AddTextLine('Chances to hit', ChancesToHit);
    AddTextLine('Initiative', Initiative);
    AddTextLine('Hit points', HitPoints, HitPoints);
    AddTextLine('Damage', Damage);
    AddTextLine('Armor', Armor);
    AddTextLine('Source', SourceName[SourceEnum]);
    DrawCreatureReach(ReachEnum);
    for I := 0 to 2 do
      AddTextLine(Description[I]);
  end;
end;

procedure TScene.DrawCreatureInfo(const ACreature: TCreature);
var
  I: Integer;
  LStr, LExp: string;
begin
  with ACreature do
  begin
    AddTextLine(Name[0], True);
    AddTextLine;
    LExp := Format(' Exp %d/%d',
      [Experience, Party[TLeaderParty.LeaderPartyIndex]
      .GetMaxExperiencePerLevel(Level)]);
    LStr := 'Level ' + Level.ToString + LExp;
    AddTextLine(LStr);
    AddTextLine('Chances to hit', ChancesToHit.GetFullValue());
    AddTextLine('Initiative', Initiative.GetFullValue());
    AddTextLine('Hit points', HitPoints.GetCurrValue, HitPoints.GetMaxValue);
    AddTextLine('Damage', Damage.GetFullValue());
    AddTextLine('Armor', Armor.GetFullValue());
    AddTextLine('Source', SourceName[SourceEnum]);
    DrawCreatureReach(ReachEnum);
    with TCreature.Character(ACreature.Enum) do
      for I := 0 to 2 do
        AddTextLine(Description[I]);
  end;
end;

procedure TScene.DrawImage(X, Y: Integer; Res: TResEnum);
begin
  DrawImage(X, Y, ResImage[Res]);
end;

procedure TScene.DrawText(const AX, AY: Integer; AText: string);
var
  LBrushStyle: TBrushStyle;
begin
  LBrushStyle := Game.Surface.Canvas.Brush.Style;
  Game.Surface.Canvas.Brush.Style := bsClear;
  Game.Surface.Canvas.TextOut(AX, AY, AText);
  Game.Surface.Canvas.Brush.Style := LBrushStyle;
end;

procedure TScene.DrawText(const AX, AY: Integer; Value: Integer);
begin
  DrawText(AX, AY, Value.ToString);
end;

procedure TScene.DrawText(const AY: Integer; AText: string);
var
  LWidth: Integer;
begin
  LWidth := Game.Surface.Canvas.TextWidth(AText);
  DrawText((Game.Surface.Width div 2) - (LWidth div 2), AY, AText);
end;

procedure TScene.DrawText(const AX, AY: Integer; AText: string; AFlag: Boolean);
var
  LFontSize: Integer;
begin
  if AFlag then
  begin
    LFontSize := Game.Surface.Canvas.Font.Size;
    Game.Surface.Canvas.Font.Size := LFontSize * 2;
  end;
  DrawText(AX, AY, AText);
  if AFlag then
    Game.Surface.Canvas.Font.Size := LFontSize;
end;

procedure TScene.RenderFrame(const PartySide: TPartySide;
  const APartyPosition, AX, AY: Integer; const F: Boolean);
var
  LPartyPosition: Integer;
begin
  case PartySide of
    psLeft:
      LPartyPosition := APartyPosition;
  else
    LPartyPosition := APartyPosition + 6;
  end;
  if (ActivePartyPosition = LPartyPosition) then
  begin
    if F then
      DrawImage(AX, AY, reFrameSlotPassive)
    else
      DrawImage(AX, AY, reFrameSlotActive);
  end
  else if (SelectPartyPosition = LPartyPosition) then
    DrawImage(AX, AY, reFrameSlotPassive);
end;

procedure TScene.RenderGuardianInfo;
begin
  TextTop := TFrame.Row(0) + 6;
  TextLeft := TFrame.Col(3) + 12;
  AddTextLine('Information', True);
  AddTextLine;
  AddTextLine('Game Difficulty', DifficultyName[TSaga.Difficulty]);
  AddTextLine('Day', Game.Day);
  AddTextLine;
  AddTextLine('Statistics', True);
  AddTextLine;
  AddTextLine('Gold Mines/Gold', Game.Gold.Mines, Game.Gold.Value);
  AddTextLine('Mana Mines/Mana', Game.Mana.Mines, Game.Mana.Value);
  AddTextLine('Gold/Mana Mined', Game.Statistics.GetValue(stGoldMined),
    Game.Statistics.GetValue(stManaMined));
  AddTextLine;
  AddTextLine('Parameters', True);
  AddTextLine;
  AddTextLine('Leadership 5');
end;

procedure TScene.RenderLeaderInfo(const AIsOnlyStatistics: Boolean = False);
begin
  TextTop := TFrame.Row(0) + 6;
  TextLeft := TFrame.Col(3) + 12;
  AddTextLine('Statistics', True);
  AddTextLine;
  AddTextLine('Battles Won', Game.Statistics.GetValue(stBattlesWon));
  AddTextLine('Killed Creatures', Game.Statistics.GetValue(stKilledCreatures));
  AddTextLine('Tiles Moved', Game.Statistics.GetValue(stTilesMoved));
  AddTextLine('Chests Found', Game.Statistics.GetValue(stChestsFound));
  AddTextLine('Items Found', Game.Statistics.GetValue(stItemsFound));
  AddTextLine('Scores', Game.Statistics.GetValue(stScores));
  if AIsOnlyStatistics then
    Exit;
  AddTextLine('Parameters', True);
  AddTextLine;
  AddTextLine(Format('Movement points %d/%d',
    [TLeaderParty.Leader.MovementPoints.GetCurrValue,
    TLeaderParty.Leader.MovementPoints.GetMaxValue]));
  AddTextLine('Sight radius', TLeaderParty.Leader.GetSightRadius);
  AddTextLine(Format('Spells per day %d/%d',
    [TLeaderParty.Leader.SpellsPerDay.GetCurrValue,
    TLeaderParty.Leader.SpellsPerDay.GetMaxValue]));
  AddTextLine('Spell casting range', TLeaderParty.Leader.GetSpellCastingRange);
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
  Result := (MX > AX) and (MX < AX + ResImage[reFrameSlot].Width) and (MY > AY)
    and (MY < AY + ResImage[reFrameSlot].Height);
end;

function TScene.GetFramePosition(const AX, AY: Integer): Integer;
var
  LY, LX: Integer;
begin
  Result := -1;
  for LX := 0 to 1 do
    for LY := 0 to 2 do
      if MouseOver(TFrame.Col(LX), TFrame.Row(LY), AX, AY) then
      begin
        Result := (LX * 3) + LY;
        Exit;
      end;
end;

function TScene.GetPartyPosition(const AX, AY: Integer): Integer;
var
  LPosition: TPosition;
  LPartySide: TPartySide;
begin
  Result := -1;
  for LPartySide := Low(TPartySide) to High(TPartySide) do
    for LPosition := Low(TPosition) to High(TPosition) do
    begin
      Inc(Result);
      if MouseOver(TFrame.Col(LPosition, LPartySide), TFrame.Row(LPosition),
        AX, AY) then
        Exit;
    end;
  if Result = 11 then
    Result := -1;
end;

procedure TScene.DrawUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
  IsAdv: Boolean);
begin
  with TCreature.Character(ACreature) do
    DrawCreatureInfo(Name[0], AX, AY, Level, 0, HitPoints, HitPoints, Damage,
      Heal, Armor, Initiative, ChancesToHit, IsAdv);
end;

procedure TScene.DrawUnit(Position: TPosition; Party: TParty; AX, AY: Integer;
  CanHire, ShowExp: Boolean);
var
  F: Boolean;
  LBGStat: TBGStat;
begin
  F := Party.Owner = TSaga.LeaderFaction;
  with Party.Creature[Position] do
  begin
    if Active then
      with Game.GetScene(scParty) do
      begin
        if F then
          LBGStat := bsCharacter
        else
          LBGStat := bsEnemy;
        if Paralyze then
          LBGStat := bsParalyze;
        if HitPoints.IsMinCurrValue then
          DrawUnit(reDead, AX, AY, LBGStat, 0, HitPoints.GetMaxValue)
        else
          DrawUnit(ResEnum, AX, AY, LBGStat, HitPoints.GetCurrValue,
            HitPoints.GetMaxValue);
        DrawCreatureInfo(Position, Party, AX, AY, ShowExp);
      end
    else if CanHire then
    begin
      DrawImage(((ResImage[reFrameSlot].Width div 2) -
        (ResImage[rePlus].Width div 2)) + AX,
        ((ResImage[reFrameSlot].Height div 2) - (ResImage[rePlus].Height div 2))
        + AY, rePlus);
    end;
  end;
end;

{ TScenes }

constructor TScenes.Create;
var
  L: Integer;
  LButtonEnum: TButtonEnum;
begin
  inherited;
  FScene[scMap] := TSceneMap.Create;
  FScene[scMenu] := TSceneMenu2.Create;
  FScene[scHire] := TSceneHire.Create;
  FScene[scHire2] := TSceneRecruit.Create;
  FScene[scParty] := TSceneParty2.Create;
  FScene[scInventory] := TSceneInventory.Create;
  FScene[scBattle] := TSceneBattle2.Create;
  FScene[scSettlement] := TSceneSettlement.Create;
  FScene[scSpellbook] := TSceneSpellbook.Create;
  FScene[scDifficulty] := TSceneDifficulty.Create;
  FScene[scScenario] := TSceneScenario.Create;
  FScene[scRace] := TSceneRace.Create;
  FScene[scLeader] := TSceneLeader.Create;
  FScene[scTemple] := TSceneTemple.Create;
  FScene[scBarracks] := TSceneBarracks.Create;
  FScene[scAbilities] := TSceneAbilities.Create;
  FScene[scNewAbility] := TSceneNewAbility.Create;
  FScene[scMageTower] := TSceneMageTower.Create;
  FScene[scHighScores] := TSceneHighScores.Create;
  FScene[scVictory] := TSceneVictory.Create;
  FScene[scDefeat] := TSceneDefeat.Create;
  // Inform
  InformMsg := '';
  IsShowInform := False;
  L := ScrWidth - (ResImage[reButtonDef].Width div 2);
  Button := TButton.Create(L, 400, reTextOk);
  Button.Sellected := True;
  // Confirm
  IsShowConfirm := False;
  L := ScrWidth - ((ResImage[reButtonDef].Width * 2) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Buttons[LButtonEnum] := TButton.Create(L, 400, ButtonsText[LButtonEnum]);
    Inc(L, ResImage[reButtonDef].Width);
    if (LButtonEnum = btOk) then
      Buttons[LButtonEnum].Sellected := True;
  end;
end;

destructor TScenes.Destroy;
var
  LButtonEnum: TButtonEnum;
  LSceneEnum: TSceneEnum;
begin
  for LSceneEnum := Low(TSceneEnum) to High(TSceneEnum) do
    FreeAndNil(FScene[LSceneEnum]);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Buttons[LButtonEnum]);
  FreeAndNil(Button);
  TSaga.PartyFree;
  inherited;
end;

function TScenes.GetScene(const ASceneEnum: TSceneEnum): TScene;
begin
  Result := TScene(FScene[ASceneEnum]);
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
  LButtonEnum: TButtonEnum;
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
      for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
        Buttons[LButtonEnum].MouseMove(X, Y);
      Exit;
    end;
    FScene[SceneEnum].MouseMove(Shift, X, Y);
    Self.Render;
  end;
end;

procedure TScenes.Render;
var
  LButtonEnum: TButtonEnum;
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
        for LButtonEnum := Low(Buttons) to High(Buttons) do
          Buttons[LButtonEnum].Render;
    end;
    MainForm.Canvas.Draw(0, 0, Game.Surface);
  end;
end;

procedure TScenes.SetScene(const ASceneEnum: TSceneEnum);
begin
  Self.SceneEnum := ASceneEnum;
end;

procedure TScenes.Show(const ASceneEnum: TSceneEnum);
begin
  SetScene(ASceneEnum);
  if (FScene[SceneEnum] <> nil) then
  begin
    FScene[SceneEnum].Show(ASceneEnum);
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
