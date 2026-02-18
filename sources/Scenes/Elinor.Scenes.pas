unit Elinor.Scenes;

interface

uses
  System.Classes,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Imaging.PNGImage,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Ability,
  Elinor.Spells,
  Elinor.Map,
  Elinor.Items,
  Elinor.Party,
  Elinor.RecordsTable,
  Elinor.Scenario,
  Elinor.MediaPlayer,
  Elinor.Treasure,
  Elinor.Statistics,
  Elinor.Resources;

type
  TSceneEnum = (scIntro, scRecruit, scMenu, scMap, scParty, scSettlement,
    scBattle, scSpellbook, scDifficulty, scScenario, scRace, scLeader, scTemple,
    scBarracks, scInventory, scAbilities, scNewAbility, scMageTower, scRecords,
    scVictory, scDefeat, scLoot, scName, scMerchant, scSelectUnit);

const
  ScreenWidth = 1344;
  ScreenHeight = 704;

var
  TextTop, TextLeft: Integer;
  PendingItemLogString: string = '';

const
  K_ESCAPE = 27;
  K_BACKSPACE = 8;
  K_ENTER = 13;
  K_SPACE = 32;
  K_TAB = 9;
  K_HOME = 36;
  K_END = 35;
  K_DELETE = 46;

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
  TLHandSlot = class(TObject)
  private
    FLeft, FTop: Integer;
  public
    constructor Create(const ALeft, ATop: Integer);
    property Left: Integer read FLeft;
    property Top: Integer read FTop;
    function MouseOver(const AX, AY: Integer): Boolean;
  end;

type
  TScene = class(TObject)
  private
    FWidth: Integer;
    FScrWidth: Integer;
    FLHandSlot: TLHandSlot;
    procedure DrawCreatureReach(const AReachEnum: TReachEnum);
    function GetItemDescription(const AItemEnum: TItemEnum): string;
    function AddName(const ACreature: TCreature): string;
    function GetClassName(const ACreature: TCreature): string;
    procedure SetItemsInformDialog(const AItemEnum: TItemEnum);
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
    procedure DrawTitle(ARes: TResEnum);
    procedure DrawImage(AX, AY: Integer; AImage: TPNGImage); overload;
    procedure DrawImage(ARes: TResEnum); overload;
    procedure DrawImage(AX, AY: Integer; ARes: TResEnum); overload;
    procedure DrawImage(AX, AY: Integer; ARes: TItemResEnum); overload;
    procedure RenderFrame(const APartySide: TPartySide;
      const APartyPosition, AX, AY: Integer; const F: Boolean = False);
    procedure DrawUnit(ACreatureResEnum: TCreatureResEnum;
      const AX, AY: Integer; ABGStat: TBGStat); overload;
    procedure DrawUnit(ACreatureResEnum: TCreatureResEnum;
      const AX, AY: Integer; ABGStat: TBGStat; AHP, AMaxHP: Integer;
      AIsMirrorHorizontally: Boolean = False); overload;
    procedure DrawUnit(APosition: TPosition; AParty: TParty; AX, AY: Integer;
      ACanHire: Boolean = False; AShowExp: Boolean = True;
      AIsMirrorHorizontally: Boolean = False); overload;
    procedure DrawCreatureInfo(AName: string; AX, AY, ALevel, AExperience,
      AHitPoints, AMaxHitPoints, ADamage, AHeal, AArmor, AInitiative,
      AChanceToHit: Integer; AIsShowExp: Boolean); overload;
    procedure DrawCreatureInfo(AEnum: TCreatureEnum; AName: string;
      AX, AY, ALevel, AExperience, AHitPoints, AMaxHitPoints, ADamage, AHeal,
      AArmor, AInitiative, AChanceToHit: Integer; AIsShowExp: Boolean);
      overload;
    procedure DrawCreatureInfo(APosition: TPosition; AParty: TParty;
      AX, AY: Integer; AIsShowExp: Boolean = True); overload;
    procedure DrawUnitInfo(AX, AY: Integer; ACreature: TCreatureEnum;
      AIsAdv: Boolean = True); overload;
    procedure ConfirmDialog(const AMessage: string;
      OnYes: TConfirmMethod = nil);
    procedure InformDialog(const AMessage: string);
    procedure ItemInformDialog(const AItemEnum: TItemEnum);
    procedure DrawInfoPanel;
    property LHandSlot: TLHandSlot read FLHandSlot;
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
    procedure DrawText(const AX, AY, AWidth: Integer;
      const AText: string); overload;
    procedure AddTextLine; overload;
    procedure AddTextLine(const S: string); overload;
    procedure AddTextLine(const S: string; const F: Boolean); overload;
    procedure AddTextLine(const S, V: string); overload;
    procedure AddTextLine(const S: string; const V: Integer); overload;
    procedure AddTextLine(const AMessage: string; const V, M: Integer);
      overload;
    procedure AddTableLine(const N, A, B, C: string);
    procedure DrawCreatureInfo(const ACreature: TCreatureBase); overload;
    procedure DrawCreatureInfo(const ACreature: TCreature); overload;
    procedure DrawSpell(AX, AY: Integer; ARes: TSpellResEnum); overload;
    procedure DrawSpell(const ASpellEnum: TSpellEnum; const AX, AY: Integer;
      AIsDrawTransparent: Boolean = False); overload;
    procedure DrawAbility(AX, AY: Integer; ARes: TAbilityResEnum); overload;
    procedure DrawAbility(const AAbilityEnum: TAbilityEnum;
      const AX, AY: Integer); overload;
    procedure DrawItem(const AItemEnum: TItemEnum; const AX, AY: Integer);
    procedure RenderLeaderInfo(const AIsOnlyStatistics: Boolean = False;
      const AIsShowFinalInfo: Boolean = False);
    procedure RenderGuardianInfo;
    procedure DrawItemDescription(const AItemEnum: TItemEnum);
    function GetCurrentIndexPos(const ACurrentIndex: Integer): TPoint;
    procedure RenderLHandSlot;
  end;

type
  TInfoDialogType = (idtNone, idtMessage, idtItemInfo, idtSetItemInfo);

type
  TScenes = class(TScene)
  private
    FSceneEnum: TSceneEnum;
    FScene: array [TSceneEnum] of TScene;
    procedure SetScene(const ASceneEnum: TSceneEnum);
  public
    InformMsg: string;
    InformSL: TStringList;
    InformImage: TResEnum;
    InformItemImage: TItemResEnum;
    IsShowInform: TInfoDialogType;
    IsShowConfirm: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Show(const ASceneEnum: TSceneEnum); override;
    procedure BackToScene(const ASceneEnum: TSceneEnum);
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
    IsGame: Boolean;
    Day: Integer;
    IsNewDay: Boolean;
    ShowNewDayMessageTime: ShortInt;
    Gold: TTreasure;
    Mana: TTreasure;
    Wizard: Boolean;
    Surface: Vcl.Graphics.TBitmap;
    Statistics: TStatistics;
    Scenario: TScenario;
    Map: TMap;
    MediaPlayer: TMediaPlayer;
    LeaderRecordsTable: TLeaderRecordsTable;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure NewDay;
    function GetDayInfo: string;
  end;

var
  Game: TGame;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  Elinor.MainForm,
  Elinor.Button,
  Elinor.Frame,
  Elinor.Scene.Map,
  Elinor.Scene.Menu3,
  Elinor.Scene.Settlement,
  Elinor.Scene.Battle2,
  Elinor.Scene.Battle3,
  Elinor.Scene.Spellbook,
  Elinor.Scene.Difficulty,
  Elinor.Scene.Faction,
  Elinor.Scene.Leader,
  Elinor.Scene.Scenario,
  Elinor.Scene.Temple,
  Elinor.Scene.Barracks,
  Elinor.Spellbook,
  Elinor.Scene.Party2,
  Elinor.Scene.Recruit,
  Elinor.Faction,
  Elinor.Scene.Inventory,
  Elinor.Scene.Abilities,
  Elinor.Scene.NewAbility,
  Elinor.Scene.MageTower,
  Elinor.Scene.Records,
  Elinor.Scene.Victory,
  Elinor.Scene.Defeat,
  Elinor.Scene.SelectUnit,
  Elinor.Difficulty,
  Elinor.Loot,
  Elinor.Scene.Loot2,
  Elinor.Common,
  Elinor.Scene.Name,
  Elinor.Scene.Intro,
  Elinor.Scene.Merchant,
  Elinor.Merchant;

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
  Surface := Vcl.Graphics.TBitmap.Create;
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
  LeaderRecordsTable := TLeaderRecordsTable.Create
    (TResources.GetPath('resources') + 'highscores.json');
  LeaderRecordsTable.LoadFromFile;
  Statistics := TStatistics.Create;
  Scenario := TScenario.Create;
  MediaPlayer := TMediaPlayer.Create;
  MediaPlayer.PlayMusic(mmMenu);
  SceneEnum := scIntro;
end;

destructor TGame.Destroy;
begin
  FreeAndNil(Statistics);
  FreeAndNil(Scenario);
  FreeAndNil(Map);
  FreeAndNil(LeaderRecordsTable);
  FreeAndNil(MediaPlayer);
  FreeAndNil(Surface);
  FreeAndNil(Gold);
  FreeAndNil(Mana);
  inherited;
end;

function TGame.GetDayInfo: string;
begin
  Result := Format('%d of %d', [Day, TScenario.GetDayLimit(Difficulty.Level,
    Game.Scenario.CurrentScenario, True)])
end;

procedure TGame.Clear;
begin
  IsGame := True;
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
  Merchants.Clear;
  PartyList.Clear;
  Statistics.Clear;
  Spells.Clear;
  Scenario.Clear;
  Map.Clear;
  Loot.Clear;
  Map.Gen;
  TLeaderParty.Leader.Clear;
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
      TLeaderParty.Leader.HealParty(CLeaderWarriorHealAllInPartyPerDay);
    TLeaderParty.Leader.LeaderRegeneration;
    TLeaderParty.Leader.SpellsPerDay.SetToMaxValue;
    ShowNewDayMessageTime := 20;
    if (RandomRange(0, 100) <= 5) then
      Merchants.Clear;
    MediaPlayer.PlaySound(mmDay);
    IsNewDay := False;
    if (Game.Day > TScenario.GetDayLimit(Difficulty.Level,
      Game.Scenario.CurrentScenario, True)) then
    begin
      Dec(Game.Day);
      InformDialog(CYouDidNotCompleteTheScenario);
      TSceneDefeat.ShowScene;
    end;

  end;

end;

{ TScene }

constructor TScene.Create;
begin
  inherited;
  Width := ScreenWidth;
  ScrWidth := Width div 2;
  ConfirmHandler := nil;
  FLHandSlot := TLHandSlot.Create(10, 90);
end;

class function TScene.DefaultButtonTop: Word;
begin
  Result := 600;
end;

destructor TScene.Destroy;
begin
  FreeAndNil(FLHandSlot);
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

procedure TScene.DrawTitle(ARes: TResEnum);
begin
  DrawImage(ScrWidth - (ResImage[ARes].Width div 2), 10, ARes);
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

procedure TScene.AddTableLine(const N, A, B, C: string);
begin
  DrawText(TextLeft, TextTop, N, False);
  DrawText(TextLeft + 40, TextTop, A, False);
  DrawText(TextLeft + 250, TextTop, B, False);
  DrawText(TextLeft + 500, TextTop, C, False);
  Inc(TextTop, TextLineHeight);
end;

procedure TScene.AddTextLine(const AMessage: string; const V, M: Integer);
begin
  AddTextLine(Format('%s: %d/%d', [AMessage, V, M]));
end;

procedure TScene.ConfirmDialog(const AMessage: string; OnYes: TConfirmMethod);
begin
  Game.MediaPlayer.PlaySound(mmExit);
  Game.InformMsg := AMessage;
  Game.IsShowConfirm := True;
  ConfirmHandler := OnYes;
end;

procedure TScene.InformDialog(const AMessage: string);
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.InformMsg := AMessage;
  Game.IsShowInform := idtMessage;
end;

procedure TScene.ItemInformDialog(const AItemEnum: TItemEnum);
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.InformSL.Clear;
  Game.InformImage := reNone;
  Game.InformItemImage := TItemBase.Item(AItemEnum).ItRes;
  Game.InformSL.Append(TItemBase.Item(AItemEnum).Name);
  Game.InformSL.Append('');
  Game.InformSL.Append('Level ' + TItemBase.Item(AItemEnum).Level.ToString);
  Game.InformSL.Append('Price ' + TItemBase.Item(AItemEnum).Price.ToString);
  Game.InformSL.Append(GetItemDescription(AItemEnum));
  Game.InformSL.Append(TruncateString(TItemBase.Item(AItemEnum)
    .Description, 70));
  SetItemsInformDialog(AItemEnum);
  Game.IsShowInform := idtItemInfo;
  case TItemBase.Item(AItemEnum).ItEffect of
    ieInvisible:
      Game.IsShowInform := idtSetItemInfo;
  end;
end;

procedure TScene.SetItemsInformDialog(const AItemEnum: TItemEnum);
var
  I, LCount: Integer;
  LStr, LName: string;
const
  CPref = '    - ';

  function GetSetItem(const N: Integer): string;
  var
    I: Integer;
    LDiv, LPref, LSuff, LName: string;
  begin
    Result := '';
    if N < Length(CSetItems[siCoverOfDarkness].Items) - 1 then
      LDiv := ', '
    else
      LDiv := '';
    LName := TItemBase.Item(CSetItems[siCoverOfDarkness].Items[N]).Name;
    LPref := '';
    LSuff := '';
    for I := 0 to CMaxEquipmentItems - 1 do
      if (DollSlot[I] = TItemBase.Item(CSetItems[siCoverOfDarkness].Items[N])
        .ItSlot) then
        if TLeaderParty.Leader.Equipment.Item(I).Enum = CSetItems
          [siCoverOfDarkness].Items[N] then
        begin
          LPref := '[';
          LSuff := ']';
        end
        else
        begin
          LPref := '';
          LSuff := '';
        end;
    Result := LPref + LName + LSuff + LDiv;
  end;

begin
  case TItemBase.Item(AItemEnum).ItEffect of
    ieInvisible:
      begin
        LCount := TLeaderParty.LeaderInvisibleValue;
        Game.InformSL.Append('');
        Game.InformSL.Append('Set ' + UpperCase(CSetItems[siCoverOfDarkness]
          .Name) + ': ' + GetSetItem(0) + GetSetItem(1));
        LStr := '';
        for I := 2 to Length(CSetItems[siCoverOfDarkness].Items) - 1 do
          LStr := LStr + GetSetItem(I);
        Game.InformSL.Append(LStr);
        LStr := '';
        if LCount = 1 then
          LStr := ' (Equipped 1 item)'
        else
          LStr := ' (Equipped ' + IntToStr(LCount) + ' items)';
        Game.InformSL.Append('');
        if LCount > 0 then
        begin
          Game.InformSL.Append('Set bonus' + LStr + ':');
          Game.InformSL.Append(CPref + 'Stealth');
        end;
        if LCount > 1 then
          Game.InformSL.Append(CPref + 'Sight radius: +' +
            IntToStr(LCount - 1));
        if LCount > 2 then
          Game.InformSL.Append(CPref + 'Regeneration: +' +
            IntToStr((LCount - 2) * 10));
        if LCount > 3 then
          Game.InformSL.Append(CPref + 'Spell casting range: +1');
      end;
  end;
end;

procedure TScene.DrawImage(AX, AY: Integer; AImage: TPNGImage);
begin
  Game.Surface.Canvas.Draw(AX, AY, AImage);
end;

procedure TScene.DrawImage(ARes: TResEnum);
begin
  Game.Surface.Canvas.StretchDraw(Rect(0, 0, Game.Surface.Width,
    Game.Surface.Height), ResImage[ARes]);
end;

procedure TScene.DrawSpell(AX, AY: Integer; ARes: TSpellResEnum);
begin
  DrawImage(AX, AY, SpellResImage[ARes]);
end;

procedure TScene.DrawSpell(const ASpellEnum: TSpellEnum; const AX, AY: Integer;
  AIsDrawTransparent: Boolean = False);
begin
  DrawSpell(AX + 7, AY + 29, TSpells.Spell(ASpellEnum).ResEnum);
  DrawImage(AX + 7, AY + 7, Spellbook.SpellBackground(ASpellEnum));
  if AIsDrawTransparent then
    DrawImage(AX + 7, AY + 7, reBGTransparent);
end;

procedure TScene.DrawAbility(const AAbilityEnum: TAbilityEnum;
  const AX, AY: Integer);
begin
  DrawAbility(AX + 7, AY + 29, TAbilities.Ability(AAbilityEnum).ResEnum);
  DrawImage(AX + 7, AY + 7, reBGAbility);
end;

procedure TScene.DrawUnit(ACreatureResEnum: TCreatureResEnum;
  const AX, AY: Integer; ABGStat: TBGStat);
begin
  case ABGStat of
    bsCharacter:
      DrawImage(AX + 7, AY + 7, reBGCharacter);
    bsEnemy:
      DrawImage(AX + 7, AY + 7, reBGEnemy);
    bsParalyze:
      DrawImage(AX + 7, AY + 7, reBGParalyze);
  end;
  DrawImage(AX + 7, AY + 7, CreatureResImage[ACreatureResEnum]);
end;

// https://stackoverflow.com/questions/9975915/stretchdraw-on-tpngimage
procedure FlipPNG(ASource, ADest: TPNGImage);
var
  X, Y: Integer;
  AlphaPtr: Vcl.Imaging.PNGImage.PByteArray;
  RGBLine: pRGBLine;
  PalleteLine: Vcl.Imaging.PNGImage.PByteArray;
  AlphaPtrDest: Vcl.Imaging.PNGImage.PByteArray;
  RGBLineDest: pRGBLine;
  PalleteLineDest: Vcl.Imaging.PNGImage.PByteArray;
begin
  ADest.Assign(ASource);

  if (ASource.Header.ColorType = COLOR_PALETTE) or
    (ASource.Header.ColorType = COLOR_GRAYSCALEALPHA) or
    (ASource.Header.ColorType = COLOR_GRAYSCALE) then
  begin
    for Y := 0 to ASource.Height - 1 do
    begin
      AlphaPtr := ASource.AlphaScanline[Y];
      PalleteLine := ASource.Scanline[Y];
      AlphaPtrDest := ADest.AlphaScanline[Y];
      PalleteLineDest := ADest.Scanline[Y];
      for X := 0 to ASource.Width - 1 do
      begin
        PalleteLineDest^[ASource.Width - X - 1] := PalleteLine^[X];
        if Assigned(AlphaPtr) then
          AlphaPtrDest^[ASource.Width - X - 1] := AlphaPtr^[X];
      end;
    end;
  end
  else if (ASource.Header.ColorType = COLOR_RGBALPHA) or
    (ASource.Header.ColorType = COLOR_RGB) then
  begin
    for Y := 0 to ASource.Height - 1 do
    begin
      AlphaPtr := ASource.AlphaScanline[Y];
      RGBLine := ASource.Scanline[Y];
      AlphaPtrDest := ADest.AlphaScanline[Y];
      RGBLineDest := ADest.Scanline[Y];
      for X := 0 to ASource.Width - 1 do
      begin
        RGBLineDest^[ASource.Width - X - 1] := RGBLine^[X];
        if Assigned(AlphaPtr) then
          AlphaPtrDest^[ASource.Width - X - 1] := AlphaPtr^[X];
      end;
    end;
  end;
end;

procedure TScene.DrawUnit(ACreatureResEnum: TCreatureResEnum;
  const AX, AY: Integer; ABGStat: TBGStat; AHP, AMaxHP: Integer;
  AIsMirrorHorizontally: Boolean);
const
  CMaxHeight = 104;
  CResImage: array [TBGStat] of TResEnum = (reBGCharacter, reBGEnemy,
    reBGParalyze);
var
  LImage: TPNGImage;
  LTempImage: TPNGImage;
  LHeight: Integer;

  function BarHeight(ACurrentHeight, AMaxHeight: Integer): Integer;
  var
    I: Integer;
  begin
    if (ACurrentHeight < 0) then
      ACurrentHeight := 0;
    if (ACurrentHeight = AMaxHeight) and (ACurrentHeight = 0) then
    begin
      Result := 0;
      Exit;
    end;
    if (AMaxHeight <= 0) then
      AMaxHeight := 1;
    I := (ACurrentHeight * CMaxHeight) div AMaxHeight;
    if I <= 0 then
      I := 0;
    if (ACurrentHeight >= AMaxHeight) then
      I := CMaxHeight;
    Result := I;
  end;

begin
  if AHP <> AMaxHP then
    DrawImage(AX + 7, AY + 7, reBGParalyze);
  LHeight := BarHeight(AHP, AMaxHP);
  if LHeight > 0 then
  begin
    LImage := TPNGImage.Create;
    try
      LImage.Assign(ResImage[CResImage[ABGStat]]);
      LHeight := EnsureRange(LHeight, 0, CMaxHeight);
      LImage.SetSize(64, LHeight);
      DrawImage(AX + 7, AY + 7 + (CMaxHeight - LHeight), LImage);
    finally
      FreeAndNil(LImage);
    end;
  end;
  if AIsMirrorHorizontally then
  begin
    LTempImage := TPNGImage.Create;
    try
      FlipPNG(CreatureResImage[ACreatureResEnum], LTempImage);
      DrawImage(AX + 7, AY + 7, LTempImage);
    finally
      FreeAndNil(LTempImage);
    end;
  end
  else
    DrawImage(AX + 7, AY + 7, CreatureResImage[ACreatureResEnum]);
end;

procedure TScene.DrawCreatureInfo(APosition: TPosition; AParty: TParty;
  AX, AY: Integer; AIsShowExp: Boolean);
begin
  with AParty.Creature[APosition] do
  begin
    if Active then
      DrawCreatureInfo(Enum, Name[0], AX, AY, Level, Experience,
        HitPoints.GetCurrValue, HitPoints.GetMaxValue, Damage.GetFullValue(),
        Heal, Armor.GetFullValue(), Initiative.GetFullValue(),
        ChancesToHit.GetFullValue(), AIsShowExp);
  end;
end;

procedure TScene.DrawCreatureInfo(AName: string; AX, AY, ALevel, AExperience,
  AHitPoints, AMaxHitPoints, ADamage, AHeal, AArmor, AInitiative,
  AChanceToHit: Integer; AIsShowExp: Boolean);
var
  LExp: string;
begin
  DrawText(AX + SceneLeft + 64, AY + 6, AName);
  LExp := '';
  if AIsShowExp then
    LExp := Format(' Exp %d/%d',
      [AExperience, PartyList.Party[TLeaderParty.LeaderPartyIndex]
      .GetMaxExperiencePerLevel(ALevel)]);
  DrawText(AX + SceneLeft + 64, AY + 27, Format('Level %d', [ALevel]) + LExp);
  DrawText(AX + SceneLeft + 64, AY + 48, Format('Hit points %d/%d',
    [AHitPoints, AMaxHitPoints]));
  if ADamage > 0 then
    DrawText(AX + SceneLeft + 64, AY + 69, Format('Damage %d Armor %d',
      [ADamage, AArmor]))
  else
    DrawText(AX + SceneLeft + 64, AY + 69, Format('Heal %d Armor %d',
      [AHeal, AArmor]));
  DrawText(AX + SceneLeft + 64, AY + 90,
    Format('Initiative %d Chances to hit %d',
    [AInitiative, AChanceToHit]) + '%');
end;

procedure TScene.DrawCreatureInfo(AEnum: TCreatureEnum; AName: string;
  AX, AY, ALevel, AExperience, AHitPoints, AMaxHitPoints, ADamage, AHeal,
  AArmor, AInitiative, AChanceToHit: Integer; AIsShowExp: Boolean);
var
  LName: string;
begin
  LName := AName;
  if AEnum in AllLeaders then
    LName := TLeaderParty.LeaderName;
  DrawCreatureInfo(LName, AX, AY, ALevel, AExperience, AHitPoints,
    AMaxHitPoints, ADamage, AHeal, AArmor, AInitiative, AChanceToHit,
    AIsShowExp);
end;

procedure TScene.DrawCreatureReach(const AReachEnum: TReachEnum);
begin
  AddTextLine('Distance', ReachInfo[AReachEnum].Distance);
  AddTextLine('Targets', ReachInfo[AReachEnum].Targets);
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

procedure TScene.DrawAbility(AX, AY: Integer; ARes: TAbilityResEnum);
begin
  DrawImage(AX, AY, AbilityResImage[ARes]);
end;

function TScene.AddName(const ACreature: TCreature): string;
var
  LName: string;
begin
  LName := '';
  with ACreature do
    if Enum in AllLeaders then
      LName := TLeaderParty.LeaderName
    else
      LName := Name[0];
  AddTextLine(LName, True);
end;

function TScene.GetClassName(const ACreature: TCreature): string;
begin
  Result := '';
  with ACreature do
  begin
    if Enum in MageUnits then
      Result := 'Mage ';
    if Enum in AllLeaders then
      Result := Name[0] + ' ';
    if Enum in CapitalGuardians then
      Result := 'Capital Guardian ';
  end;
end;

procedure TScene.DrawCreatureInfo(const ACreature: TCreature);
var
  I: Integer;
  LClassName, LStr, LExp: string;
begin
  with ACreature do
  begin
    AddName(ACreature);
    AddTextLine;
    LExp := Format(' Exp %d/%d',
      [Experience, PartyList.Party[TLeaderParty.LeaderPartyIndex]
      .GetMaxExperiencePerLevel(Level)]);
    LClassName := GetClassName(ACreature);
    LStr := LClassName + 'Level ' + Level.ToString + LExp;
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

procedure TScene.DrawImage(AX, AY: Integer; ARes: TResEnum);
begin
  DrawImage(AX, AY, ResImage[ARes]);
end;

procedure TScene.DrawItem(const AItemEnum: TItemEnum; const AX, AY: Integer);
begin
  DrawImage(AX + 7, AY + 7, reBGCharacter);
  DrawImage(AX + 7, AY + 29, TItemBase.Item(AItemEnum).ItRes);
end;

procedure TScene.DrawItemDescription(const AItemEnum: TItemEnum);
begin
  AddTextLine(GetItemDescription(AItemEnum));
end;

function TScene.GetItemDescription(const AItemEnum: TItemEnum): string;
begin
  case AItemEnum of
    iLifePotion:
      Result := 'Revives dead units';
    iPotionOfHealing:
      Result := 'Restores 50 hit points';
    iPotionOfRestoration:
      Result := 'Restores 100 hit points';
    iHealingOintment:
      Result := 'Restores 200 hit points';
  end;
  case TItemBase.Item(AItemEnum).ItEffect of
    ieRegen5:
      Result := 'Regeneration +5';
    ieRegen10:
      Result := 'Regeneration +10';
    ieRegen15:
      Result := 'Regeneration +15';
    ieRegen20:
      Result := 'Regeneration +20';
    ieRegen25:
      Result := 'Regeneration +25';
    ieChanceToParalyze5:
      Result := 'Has a 5% chance to paralyze the unit';
    ieChanceToParalyze10:
      Result := 'Has a 10% chance to paralyze the unit';
    ieChanceToParalyze15:
      Result := 'Has a 15% chance to paralyze the unit';
    ieInvisible:
      Result := 'Invisibility';
  end;

end;

procedure TScene.DrawText(const AX, AY: Integer; AText: string);
var
  LBrushStyle: TBrushStyle;
  LFontSize: Integer;
begin
  LBrushStyle := Game.Surface.Canvas.Brush.Style;
  Game.Surface.Canvas.Brush.Style := bsClear;
  Game.Surface.Canvas.TextOut(AX, AY, AText);
  Game.Surface.Canvas.Brush.Style := LBrushStyle;
  LFontSize := Game.Surface.Canvas.Font.Size;
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

procedure TScene.DrawText(const AX, AY, AWidth: Integer; const AText: string);
var
  S: string;
  LineY: Integer;
  Words: TArray<string>;
  CurrentLine: string;
  I: Integer;
  LineHeight: Integer;
  TextWidth: Integer;
  Canvas: TCanvas;
begin
  Canvas := Game.Surface.Canvas;
  Canvas.Brush.Style := bsClear;
  LineHeight := Canvas.TextHeight('Tg');
  LineY := AY;
  Words := AText.Split([' ']);
  CurrentLine := '';
  for I := 0 to Length(Words) - 1 do
  begin
    if CurrentLine = '' then
      S := Words[I]
    else
      S := CurrentLine + ' ' + Words[I];
    TextWidth := Canvas.TextWidth(S);
    if TextWidth > AWidth then
    begin
      if CurrentLine <> '' then
      begin
        Canvas.TextOut(AX, LineY, CurrentLine);
        LineY := LineY + LineHeight;
        CurrentLine := Words[I];
      end
      else
      begin
        Canvas.TextOut(AX, LineY, Words[I]);
        LineY := LineY + LineHeight;
        CurrentLine := '';
      end;
    end
    else
    begin
      CurrentLine := S;
    end;
  end;
  if CurrentLine <> '' then
    Canvas.TextOut(AX, LineY, CurrentLine);
end;

procedure TScene.RenderFrame(const APartySide: TPartySide;
  const APartyPosition, AX, AY: Integer; const F: Boolean);
var
  LPartyPosition: Integer;
begin
  case APartySide of
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
  AddTextLine('Game Difficulty', DifficultyName[Difficulty.Level]);
  AddTextLine('Day', Game.GetDayInfo);
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

procedure TScene.RenderLeaderInfo(const AIsOnlyStatistics: Boolean = False;
  const AIsShowFinalInfo: Boolean = False);
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
  if AIsShowFinalInfo then
  begin
    AddTextLine('Day', Game.GetDayInfo);
  end;
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

procedure TScene.RenderLHandSlot;
begin
  DrawImage(LHandSlot.Left, LHandSlot.Top, reSmallFrame);
  with TLeaderParty.Leader.Equipment.LHandSlotItem do
    if (Enum <> iNone) and (ItRes <> irNone) then
    begin
      DrawImage(LHandSlot.Left + 30, LHandSlot.Top + 25, ItemResImage[ItRes]);

    end;
end;

procedure TScene.DrawInfoPanel;
begin
  DrawImage(10, 10, reSmallFrame);
  DrawImage(15, 10, reGold);
  DrawText(45, 24, Game.Gold.Value);
  DrawImage(15, 40, reMana);
  DrawText(45, 54, Game.Mana.Value);
  DrawText(45, 84, Game.GetDayInfo);
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

function TScene.GetCurrentIndexPos(const ACurrentIndex: Integer): TPoint;
begin
  Result.X := 0;
  Result.Y := 0;
  case ACurrentIndex of
    0 .. 2:
      begin
        Result.X := TFrame.Col(0);
        Result.Y := TFrame.Row(ACurrentIndex);
      end;
    3 .. 5:
      begin
        Result.X := TFrame.Col(1);
        Result.Y := TFrame.Row(ACurrentIndex - 3);
      end;
  end;
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
  AIsAdv: Boolean);
begin
  with TCreature.Character(ACreature) do
    DrawCreatureInfo(Name[0], AX, AY, Level, 0, HitPoints, HitPoints, Damage,
      Heal, Armor, Initiative, ChancesToHit, AIsAdv);
end;

procedure TScene.DrawUnit(APosition: TPosition; AParty: TParty; AX, AY: Integer;
  ACanHire: Boolean = False; AShowExp: Boolean = True;
  AIsMirrorHorizontally: Boolean = False);
var
  F: Boolean;
  LBGStat: TBGStat;
begin
  F := AParty.Owner = Game.Scenario.Faction;
  with AParty.Creature[APosition] do
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
          DrawImage(AX + 7, AY + 7, reDead)
        else
          DrawUnit(ResEnum, AX, AY, LBGStat, HitPoints.GetCurrValue,
            HitPoints.GetMaxValue, AIsMirrorHorizontally);
        DrawCreatureInfo(APosition, AParty, AX, AY, AShowExp);
      end
    else if ACanHire then
    begin
      DrawImage(((ResImage[reFrameSlot].Width div 2) -
        (ResImage[rePlus].Width div 2)) + AX,
        ((ResImage[reFrameSlot].Height div 2) - (ResImage[rePlus].Height div 2))
        + AY, rePlus);
    end;
  end;
end;

procedure TScene.DrawImage(AX, AY: Integer; ARes: TItemResEnum);
begin
  DrawImage(AX, AY, ItemResImage[ARes]);
end;

{ TScenes }

procedure TScenes.BackToScene(const ASceneEnum: TSceneEnum);
begin
  SetScene(ASceneEnum);
  Game.Render;
end;

constructor TScenes.Create;
var
  LLeft: Integer;
  LButtonEnum: TButtonEnum;
begin
  inherited;
  FScene[scIntro] := TSceneIntro.Create;
  FScene[scMap] := TSceneMap.Create;
  FScene[scMenu] := TSceneMenu3.Create;
  FScene[scRecruit] := TSceneRecruit.Create;
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
  FScene[scRecords] := TSceneRecords.Create;
  FScene[scVictory] := TSceneVictory.Create;
  FScene[scDefeat] := TSceneDefeat.Create;
  FScene[scLoot] := TSceneLoot2.Create;
  FScene[scName] := TSceneName.Create;
  FScene[scMerchant] := TSceneMerchant.Create;
  FScene[scSelectUnit] := TSceneSelectUnit.Create;
  // Inform
  InformMsg := '';
  IsShowInform := idtNone;
  LLeft := ScrWidth - (ResImage[reButtonDef].Width div 2);
  Button := TButton.Create(LLeft, 400, reTextOk);
  Button.Selected := True;
  // Confirm
  IsShowConfirm := False;
  LLeft := ScrWidth - ((ResImage[reButtonDef].Width * 2) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Buttons[LButtonEnum] := TButton.Create(LLeft, 400,
      ButtonsText[LButtonEnum]);
    Inc(LLeft, ResImage[reButtonDef].Width);
    if (LButtonEnum = btOk) then
      Buttons[LButtonEnum].Selected := True;
  end;
  // Item
  InformSL := TStringList.Create;
end;

destructor TScenes.Destroy;
var
  LButtonEnum: TButtonEnum;
  LSceneEnum: TSceneEnum;
begin
  FreeAndNil(InformSL);
  for LSceneEnum := Low(TSceneEnum) to High(TSceneEnum) do
    FreeAndNil(FScene[LSceneEnum]);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Buttons[LButtonEnum]);
  FreeAndNil(Button);
  PartyList.Clear;
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
    if (IsShowInform <> idtNone) then
    begin
      case AButton of
        mbLeft:
          begin
            if Button.MouseDown then
            begin
              IsShowInform := idtNone;
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
    if IsShowInform <> idtNone then
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
  LLeft, LTop: Integer;
  LShowSetItemDialog: Boolean;
  I: Integer;
begin
  inherited;
  if (FScene[SceneEnum] <> nil) then
  begin
    Game.Surface.Canvas.Brush.Color := clBlack;
    Game.Surface.Canvas.FillRect(Rect(0, 0, Game.Surface.Width,
      Game.Surface.Height));
    FScene[SceneEnum].Render;
    Button.Top := 400;
    LShowSetItemDialog := False;
    if (IsShowInform = idtSetItemInfo) then
    begin
      LShowSetItemDialog := True;
      LLeft := ScrWidth - (ResImage[reBigFrame].Width div 2);
      LTop := 70;
      DrawImage(LLeft - 10, LTop - 10, reHugeFrameBackground);
      DrawImage(LLeft, LTop, ResImage[reHugeFrame]);
      TextLeft := 400;
      TextTop := LTop + 40;
      if (Game.InformImage <> reNone) then
      begin
        DrawImage(850, LTop + 25, reSmallFrame);
        DrawImage(880, LTop + 50, Game.InformImage);
      end;
      if (Game.InformItemImage <> irNone) then
      begin
        DrawImage(850, LTop + 25, reSmallFrame);
        DrawImage(880, LTop + 50, Game.InformItemImage);
      end;
      for I := 0 to Game.InformSL.Count - 1 do
        AddTextLine(Game.InformSL[I], I = 0);
      Button.Top := 500;
      Button.Render;
    end;
    if not LShowSetItemDialog then
      if (IsShowInform <> idtNone) or IsShowConfirm then
      begin
        LLeft := ScrWidth - (ResImage[reBigFrame].Width div 2);
        LTop := 150;
        DrawImage(LLeft - 10, LTop - 10, reBigFrameBackground);
        DrawImage(LLeft, LTop, ResImage[reBigFrame]);
        if (IsShowInform = idtMessage) or IsShowConfirm then
          DrawText(LTop + 100, InformMsg)
        else
        begin
          TextLeft := 400;
          TextTop := LTop + 40;
          if (Game.InformImage <> reNone) then
          begin
            DrawImage(850, LTop + 25, reSmallFrame);
            DrawImage(880, LTop + 50, Game.InformImage);
          end;
          if (Game.InformItemImage <> irNone) then
          begin
            DrawImage(850, LTop + 25, reSmallFrame);
            DrawImage(880, LTop + 50, Game.InformItemImage);
          end;
          for I := 0 to Game.InformSL.Count - 1 do
            AddTextLine(Game.InformSL[I], I = 0);
        end;
        if (IsShowInform <> idtNone) then
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
    if (IsShowInform <> idtNone) then
    begin
      case Key of
        K_ESCAPE, K_ENTER:
          begin
            IsShowInform := idtNone;
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

{ TLHandSlot }

function TLHandSlot.MouseOver(const AX, AY: Integer): Boolean;
begin
  Result := (AX > Left) and (AX < Left + 120) and (AY > Top) and
    (AY < Top + 120);
end;

constructor TLHandSlot.Create(const ALeft, ATop: Integer);
begin
  FLeft := ALeft;
  FTop := ATop;
end;

end.
