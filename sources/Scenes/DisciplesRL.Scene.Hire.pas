unit DisciplesRL.Scene.Hire;

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  DisciplesRL.Saga,
  DisciplesRL.Creatures,
  DisciplesRL.Scenes,
  DisciplesRL.Resources,
  DisciplesRL.Party;

type
  THireSubSceneEnum = (stCharacter, stLeader, stRace, stScenario, stJournal,
    stVictory, stDefeat, stHighScores2, stLoot, stInform, stStoneTab,
    stDifficulty, stSpy);

type

  { TSceneHire }

  TSceneHire = class(TScene)
  private
    FMPX: Integer;
    FMPY: Integer;
    procedure Ok;
    procedure Back;
    procedure RenderRace(const Race: TRaceEnum; const AX, AY: Integer);
    procedure RenderSpy(const N: TLeaderThiefSpyVar; const AX, AY: Integer);
    procedure RenderDifficulty(const Difficulty: TSaga.TDifficultyEnum;
      const AX, AY: Integer);
    procedure RenderScenario(const AScenario: TScenario.TScenarioEnum;
      const AX, AY: Integer);
  public
    class var
      Msg: string;
      MPX: Integer;
      MPY: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DrawItem(ItemRes: array of TResEnum);
    class function HireIndex: Integer; static;
    procedure RenderCharacterInfo(C: TCreatureEnum);
    class procedure Show(const ASubScene: THireSubSceneEnum); overload;
    class procedure Show(const Party: TParty; const Position: Integer);
      overload;
    class procedure Show(const ASubScene: THireSubSceneEnum;
      const ABackScene: TSceneEnum; const ALootRes: TResEnum); overload;
    class procedure Show(const ASubScene: THireSubSceneEnum;
      const ABackScene: TSceneEnum); overload;
  end;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Button,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Settlement;

type
  TButtonEnum = (btOk, btClose);

const
  ButtonText: array [THireSubSceneEnum] of array [TButtonEnum] of TResEnum = (
    // Character
    (reTextHire, reTextClose),
    // Leader
    (reTextContinue, reTextCancel),
    // Race
    (reTextContinue, reTextCancel),
    // Scenario
    (reTextContinue, reTextCancel),
    // Journal
    (reTextClose, reTextClose),
    // Victory
    (reTextClose, reTextClose),
    // Defeat
    (reTextClose, reTextClose),
    // Scores
    (reTextClose, reTextClose),
    // Loot
    (reTextClose, reTextClose),
    // Inform
    (reTextOk, reTextOk),
    // StoneTab
    (reTextClose, reTextClose),
    // Spy
    (reTextContinue, reTextCancel),
    // Difficulty
    (reTextContinue, reTextCancel));

const
  AddButtonScene = [stLoot, stStoneTab, stInform];
  CloseButtonScene = [stJournal, stVictory, stDefeat, stInform, stHighScores2] +
    AddButtonScene;
  MainButtonsScene = [stCharacter, stLeader, stRace, stScenario, stHighScores2,
    stDifficulty, stSpy];

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;
  SubScene: THireSubSceneEnum = stCharacter;
  BackScene: TSceneEnum = scMenu;
  Button: array [THireSubSceneEnum] of array [TButtonEnum] of TButton;
  CurrentIndex: Integer = 0;
  Lf: Integer = 0;
  GC, MC: Integer;
  LootRes: TResEnum;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum);
begin
  case ASubScene of
    stJournal:
      CurrentIndex := Ord(TScenario.CurrentScenario);
  else
    CurrentIndex := 0;
  end;
  SubScene := ASubScene;
  Scenes.Show(scHire);
  if ASubScene = stVictory then
    MediaPlayer.PlayMusic(mmVictory);
end;

class procedure TSceneHire.Show(const Party: TParty; const Position: Integer);
begin
  HireParty := Party;
  HirePosition := Position;
  Show(stCharacter);
end;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum;
  const ABackScene: TSceneEnum);
begin
  SubScene := ASubScene;
  BackScene := ABackScene;
  Scenes.Show(scHire);
end;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum;
  const ABackScene: TSceneEnum; const ALootRes: TResEnum);
begin
  TSceneHire.Show(ASubScene, ABackScene);
  case SubScene of
    stLoot, stStoneTab:
      MediaPlayer.Play(mmLoot);
  end;
  LootRes := ALootRes;
  GC := RandomRange(0, 3);
  MC := RandomRange(0, 3);
end;

class function TSceneHire.HireIndex: Integer;
begin
  Result := CurrentIndex;
end;

procedure TSceneHire.DrawItem(ItemRes: array of TResEnum);
var
  I, X: Integer;
begin
  DrawImage(ScrWidth - 59 - 120, 295, reSmallFrame);
  DrawImage(ScrWidth - 59, 295, reSmallFrame);
  DrawImage(ScrWidth - 59 + 120, 295, reSmallFrame);
  case Length(ItemRes) of
    1:
      if ItemRes[0] <> reNone then
        DrawImage(ScrWidth - 32, 300, ItemRes[0]);
    2, 3:
      begin
        X := -120;
        for I := 0 to Length(ItemRes) - 1 do
        begin
          if ItemRes[I] <> reNone then
            DrawImage(ScrWidth - 32 + X, 300, ItemRes[I]);
          Inc(X, 120);
        end;
      end;
  end;
end;

procedure TSceneHire.Back;
begin
  MediaPlayer.Play(mmClick);
  case SubScene of
    stCharacter:
      Scenes.Show(scSettlement);
    stDifficulty:
      TSceneHire.Show(stScenario);
    stLeader:
      TSceneHire.Show(stRace);
    stRace:
      TSceneHire.Show(stDifficulty);
    stScenario:
      Scenes.Show(scMenu);
    stJournal, stSpy:
      Scenes.Show(scMap);
    stDefeat:
      begin
        TSaga.IsGame := False;
        TSceneHire.Show(stHighScores2);
      end;
    stVictory:
      begin
        TSaga.IsGame := False;
        TSceneHire.Show(stHighScores2);
      end;
    stHighScores2:
      begin
        Scenes.Show(scMenu);
      end;
  end;
end;

procedure TSceneHire.Ok;
var
  F: Boolean;
  I: Integer;
begin
  MediaPlayer.Play(mmClick);
  case SubScene of
    stInform:
      begin
        Scenes.Show(BackScene);
      end;
    stRace:
      begin
        TSaga.LeaderRace := TRaceEnum(CurrentIndex + 1);
        TSceneHire.Show(stLeader);
      end;
    stLeader:
      begin
        TSaga.Clear;
        Party[TLeaderParty.LeaderPartyIndex].Owner := TSaga.LeaderRace;
        MediaPlayer.PlayMusic(mmGame);
        MediaPlayer.Play(mmExit);
        TSceneSettlement.Show(stCapital);
      end;
    stDifficulty:
      begin
        TSaga.Difficulty := TSaga.TDifficultyEnum(CurrentIndex);
        TSceneHire.Show(stRace);
      end;
    stCharacter:
      begin
        if HireParty.Hire(Characters[Party[TLeaderParty.LeaderPartyIndex].Owner]
          [cgCharacters][TRaceCharKind(CurrentIndex)], HirePosition) then
        begin
          MediaPlayer.Play(mmGold);
          Scenes.Show(scSettlement);
        end
        else
          InformDialog('Не хватает денег!');
      end;
    stScenario:
      begin
        TScenario.CurrentScenario := TScenario.TScenarioEnum(CurrentIndex);
        TSceneHire.Show(stDifficulty);
      end;
    stJournal:
      Scenes.Show(scMap);
    stDefeat:
      begin
        TSaga.IsGame := False;
        TSceneHire.Show(stHighScores2);
        MediaPlayer.PlayMusic(mmMenu);
      end;
    stVictory:
      begin
        TSaga.IsGame := False;
        TSceneHire.Show(stHighScores2);
        MediaPlayer.PlayMusic(mmMenu);
      end;
    stHighScores2:
      begin
        Scenes.Show(scMenu);
      end;
    stStoneTab:
      begin
        if (TScenario.CurrentScenario = sgAncientKnowledge) then
          if TScenario.StoneTab >= TScenario.ScenarioStoneTabMax then
          begin
            TSceneHire.Show(stVictory);
            Exit;
          end
          else
          begin
            F := True;
            Scenes.Show(scMap);
            Exit;
          end;
      end;
    stSpy:
      begin
        case TLeaderThiefSpyVar(CurrentIndex) of
          svIntroduceSpy:
            begin
              TLeaderParty.Leader.PutAt(MPX, MPY, True);
            end;
          svDuel:
            begin

            end;
          svPoison:
            begin
              I := TSaga.GetPartyIndex(MPX, MPY);
              Party[I].TakeDamageAll(10);
              Scenes.Show(scMap);
            end
          else
            Scenes.Show(scMap);
        end;
      end;
    stLoot:
      begin
        MediaPlayer.Play(mmLoot);
        F := True;
        Scenes.Show(scMap);
        begin
          if (TScenario.CurrentScenario = sgDarkTower) then
          begin
            case TMap.LeaderTile of
              reTower:
                begin
                  TSceneHire.Show(stVictory);
                  Exit;
                end;
            end;
          end;
          if TMap.LeaderTile = reNeutralCity then
          begin
            MediaPlayer.PlayMusic(mmGame);
            MediaPlayer.Play(mmSettlement);
            TSceneSettlement.Show(stCity);
            Exit;
          end;
          if F then
            TSaga.NewDay;
        end;
      end;
  end;
end;

procedure TSceneHire.RenderCharacterInfo(C: TCreatureEnum);
const
  H = 25;
var
  L, T, J: Integer;

  procedure Add; overload;
  begin
    Inc(T, H - 4);
  end;

  procedure Add(S, V: string); overload;
  begin
    DrawText(L, T, Format('%s: %s', [S, V]));
    Inc(T, H);
  end;

  procedure Add(S: string; V: Integer; R: string = ''); overload;
  begin
    DrawText(L, T, Format('%s: %d%s', [S, V, R]));
    Inc(T, H);
  end;

  procedure Add(S: string; F: Boolean = False); overload;
  var
    N: Integer;
  begin
    if F then
    begin
      N := Surface.Canvas.Font.Size;
      Surface.Canvas.Font.Size := N * 2;
    end;
    DrawText(L, T, S);
    if F then
      Surface.Canvas.Font.Size := N;
    Inc(T, H);
  end;

  procedure Add(S: string; V, M: Integer); overload;
  begin
    DrawText(L, T, Format('%s: %d/%d', [S, V, M]));
    Inc(T, H);
  end;

begin
  T := Top + 6;
  L := Lf + ResImage[reActFrame].Width + 12;
  with TCreature.Character(C) do
  begin
    Add(Name[0], True);
    Add;
    Add('Уровень', Level);
    Add('Точность', ChancesToHit, '%');
    Add('Инициатива', Initiative);
    Add('Здоровье', HitPoints, HitPoints);
    Add('Урон', Damage);
    Add('Броня', Armor);
    Add('Источник', SourceName[SourceEnum]);
    case ReachEnum of
      reAny:
        begin
          Add('Дистанция', 'Все поле боя');
          Add('Цели', 1);
        end;
      reAdj:
        begin
          Add('Дистанция', 'Ближайшие цели');
          Add('Цели', 1);
        end;
      reAll:
        begin
          Add('Дистанция', 'Все поле боя');
          Add('Цели', 6);
        end;
    end;
    for J := 0 to 2 do
      Add(Description[J]);
  end;
end;

procedure TSceneHire.RenderRace(const Race: TRaceEnum; const AX, AY: Integer);
begin
  case Race of
    reTheEmpire:
      DrawImage(AX + 7, AY + 7, reTheEmpireLogo);
    reUndeadHordes:
      DrawImage(AX + 7, AY + 7, reUndeadHordesLogo);
    reLegionsOfTheDamned:
      DrawImage(AX + 7, AY + 7, reLegionsOfTheDamnedLogo);
  end;
end;

procedure TSceneHire.RenderSpy(const N: TLeaderThiefSpyVar; const AX, AY: Integer);
begin
  case N of
    svIntroduceSpy:
      DrawImage(AX + 7, AY + 7, reTheEmpireLogo);
    svDuel:
      DrawImage(AX + 7, AY + 7, reUndeadHordesLogo);
    svPoison:
      DrawImage(AX + 7, AY + 7, reLegionsOfTheDamnedLogo);
  end;
end;

procedure TSceneHire.RenderDifficulty(const Difficulty: TSaga.TDifficultyEnum;
  const AX, AY: Integer);
begin
  case Difficulty of
    dfEasy:
      DrawImage(AX + 7, AY + 7, reDifficultyEasyLogo);
    dfNormal:
      DrawImage(AX + 7, AY + 7, reDifficultyNormalLogo);
    dfHard:
      DrawImage(AX + 7, AY + 7, reDifficultyHardLogo);
  end;
end;

procedure TSceneHire.RenderScenario(const AScenario: TScenario.TScenarioEnum;
  const AX, AY: Integer);
begin
  case AScenario of
    sgDarkTower:
      DrawImage(AX + 7, AY + 7, reScenarioDarkTower);
    sgOverlord:
      DrawImage(AX + 7, AY + 7, reScenarioOverlord);
    sgAncientKnowledge:
      DrawImage(AX + 7, AY + 7, reScenarioAncientKnowledge);
  end;
end;

procedure RenderRaceInfo;
const
  H = 25;
var
  R: TRaceEnum;
  T, L, J: Integer;

  procedure Add; overload;
  begin
    Inc(T, H);
  end;

  procedure Add(S: string; F: Boolean = False); overload;
  var
    N: Integer;
  begin
    if F then
    begin
      N := Surface.Canvas.Font.Size;
      Surface.Canvas.Font.Size := N * 2;
    end;
    DrawText(L, T, S);
    if F then
      Surface.Canvas.Font.Size := N;
    Inc(T, H);
  end;

begin
  T := Top + 6;
  L := Lf + ResImage[reActFrame].Width + 12;
  R := TRaceEnum(CurrentIndex + 1);
  Add(RaceName[R], True);
  Add;
  for J := 0 to 10 do
    Add(RaceDescription[R][J]);
end;

procedure RenderDifficultyInfo;
const
  H = 25;
var
  D: TSaga.TDifficultyEnum;
  T, L, J: Integer;

  procedure Add; overload;
  begin
    Inc(T, H - 4);
  end;

  procedure Add(S: string; F: Boolean = False); overload;
  var
    N: Integer;
  begin
    if F then
    begin
      N := Surface.Canvas.Font.Size;
      Surface.Canvas.Font.Size := N * 2;
    end;
    DrawText(L, T, S);
    if F then
      Surface.Canvas.Font.Size := N;
    Inc(T, H);
  end;

begin
  T := Top + 6;
  L := Lf + ResImage[reActFrame].Width + 12;
  D := TSaga.TDifficultyEnum(CurrentIndex);
  Add(TSaga.DifficultyName[D], True);
  Add;
  for J := 0 to 11 do
    Add(TSaga.DifficultyDescription[D][J]);
end;

procedure RenderScenarioInfo;
const
  H = 25;
var
  S: TScenario.TScenarioEnum;
  T, L, J: Integer;

  procedure Add; overload;
  begin
    Inc(T, H);
  end;

  procedure Add(S: string; F: Boolean = False); overload;
  var
    N: Integer;
  begin
    if F then
    begin
      N := Surface.Canvas.Font.Size;
      Surface.Canvas.Font.Size := N * 2;
    end;
    DrawText(L, T, S);
    if F then
      Surface.Canvas.Font.Size := N;
    Inc(T, H);
  end;

begin
  T := Top + 6;
  L := Lf + ResImage[reActFrame].Width + 12;
  S := TScenario.TScenarioEnum(CurrentIndex);
  Add(TScenario.ScenarioName[S], True);
  Add;
  for J := 0 to 10 do
    Add(TScenario.ScenarioDescription[S][J]);
  if TSaga.IsGame then
    case TScenario.CurrentScenario of
      sgOverlord:
        Add(TScenario.ScenarioOverlordState);
      sgAncientKnowledge:
        Add(TScenario.ScenarioAncientKnowledgeState);
    end;
end;

procedure RenderFinalInfo;
begin

end;

procedure RenderHighScores;
begin

end;

procedure RenderSpyInfo;
begin

end;

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  if (SubScene in CloseButtonScene) then
    Button[SubScene][btOk].Render
  else
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      Button[SubScene][I].Render;
end;

{ Malavien's Camp	My mercenaries will join your army ... for a price.
  Guther's Camp	My soldiers are the finest in the region.
  Turion's Camp	My soldiers are the most formidable in the land.
  Uther's Camp	Are you in need of recruits?
  Dennar's Camp	We will join your army, for a price.
  Purthen's Camp	My mercenaries will join your army ... for a price.
  Luther's Camp	My soldiers are the finest in the region.
  Richard's Camp	My soldiers are the most formidable in the land.
  Ebbon's Camp	Are you in need of recruits?
  Righon's Camp	We will join your army, for a price.
  Kigger's Camp	My mercenaries will join your army ... for a price.
  Luggen's Camp	My soldiers are the finest in the region.
  Werric's Camp	My soldiers are the most formidable in the land.
  Xennon's Camp	Are you in need of recruits? }

{ TSceneHire }

constructor TSceneHire.Create;
var
  I: TButtonEnum;
  J: THireSubSceneEnum;
  L, W: Integer;
begin
  inherited;
  MPX := 0;
  MPY := 0;
  for J := Low(THireSubSceneEnum) to High(THireSubSceneEnum) do
  begin
    W := ResImage[reButtonDef].Width + 4;
    if (J in CloseButtonScene) then
      L := ScrWidth - (ResImage[reButtonDef].Width div 2)
    else
      L := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
    for I := Low(TButtonEnum) to High(TButtonEnum) do
    begin
      Button[J][I] := TButton.Create(L, 600, ButtonText[J][I]);
      if not(J in CloseButtonScene) then
        Inc(L, W);
      if (I = btOk) then
        Button[J][I].Sellected := True;
    end;
  end;
  Lf := ScrWidth - (ResImage[reFrame].Width) - 2;
end;

destructor TSceneHire.Destroy;
var
  J: THireSubSceneEnum;
  I: TButtonEnum;
begin
  for J := Low(THireSubSceneEnum) to High(THireSubSceneEnum) do
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      FreeAndNil(Button[J][I]);
  inherited;
end;

procedure TSceneHire.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if not(SubScene in CloseButtonScene) then
        begin
          if MouseOver(Lf, Top, X, Y) then
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := 0;
          end;
          if MouseOver(Lf, Top + 120, X, Y) then
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := 1;
          end;
          if MouseOver(Lf, Top + 240, X, Y) then
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := 2;
          end;
        end;

        if SubScene in MainButtonsScene then
          if Button[SubScene][btOk].MouseDown then
            Ok
          else if Button[SubScene][btClose].MouseDown then
            Back;

        if (SubScene in CloseButtonScene) then
        begin
          if Button[SubScene][btOk].MouseDown then
            Ok;
        end;

      end;
  end;
end;

procedure TSceneHire.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  if (SubScene in CloseButtonScene) then
    Button[SubScene][btOk].MouseMove(X, Y)
  else
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      Button[SubScene][I].MouseMove(X, Y);
  Render;
end;

procedure TSceneHire.Render;
var
  Y: Integer;
  R: TRaceEnum;
  K: TRaceCharKind;
  S: TScenario.TScenarioEnum;
  D: TSaga.TDifficultyEnum;
  Z: TLeaderThiefSpyVar;
  ItemRes: TResEnum;
  GM, MM: Boolean;
  It1, It2, It3: TResEnum;
  C: TCreatureEnum;

  procedure DrawGold;
  begin
    case GC of
      0:
        DrawItem([reItemGold]);
      1:
        DrawItem([reItemGold, reItemGold]);
      2:
        DrawItem([reItemGold, reItemGold, reItemGold]);
    end;
  end;

  procedure DrawMana;
  begin
    case MC of
      0:
        DrawItem([reItemMana]);
      1:
        DrawItem([reItemMana, reItemMana]);
      2:
        DrawItem([reItemMana, reItemMana, reItemMana]);
    end;
  end;

begin
  inherited;
  Y := 0;
  It1 := reNone;
  It2 := reNone;
  It3 := reNone;
  GM := TSaga.GoldMines > 0;
  MM := TSaga.ManaMines > 0;
  case SubScene of
    stCharacter:
      begin
        DrawImage(reWallpaperSettlement);
        DrawTitle(reTitleHire);
        for K := Low(TRaceCharKind) to High(TRaceCharKind) do
        begin
          if K = TRaceCharKind(CurrentIndex) then
            DrawImage(Lf, Top + Y, reActFrame)
          else
            DrawImage(Lf, Top + Y, reFrame);
          with TCreature.Character
            (Characters[Party[TLeaderParty.LeaderPartyIndex].Owner]
            [cgCharacters][K]) do
          begin
            DrawUnit(ResEnum, Lf, Top + Y, bsCharacter);
            TSceneParty(Scenes.GetScene(scParty)).DrawUnitInfo(Lf, Top + Y,
              Characters[Party[TLeaderParty.LeaderPartyIndex].Owner]
              [cgCharacters][K], False);
          end;
          Inc(Y, 120);
        end;
      end;
    stLeader:
      begin
        DrawImage(reWallpaperLeader);
        DrawTitle(reTitleLeader);
        for K := Low(TRaceCharKind) to High(TRaceCharKind) do
        begin
          if K = TRaceCharKind(CurrentIndex) then
            DrawImage(Lf, Top + Y, reActFrame)
          else
            DrawImage(Lf, Top + Y, reFrame);
          with TCreature.Character(Characters[TSaga.LeaderRace]
            [cgLeaders][K]) do
          begin
            DrawUnit(ResEnum, Lf, Top + Y, bsCharacter);
            TSceneParty(Scenes.GetScene(scParty)).DrawUnitInfo(Lf, Top + Y,
              Characters[TSaga.LeaderRace][cgLeaders][K], False);
          end;
          Inc(Y, 120);
        end;
      end;
    stDifficulty:
      begin
        DrawImage(reWallpaperDifficulty);
        DrawTitle(reTitleDifficulty);
        for D := dfEasy to dfHard do
        begin
          if Ord(D) = CurrentIndex then
            DrawImage(Lf, Top + Y, reActFrame)
          else
            DrawImage(Lf, Top + Y, reFrame);
          RenderDifficulty(D, Lf, Top + Y);
          Inc(Y, 120);
        end;
      end;
    stRace:
      begin
        DrawTitle(reTitleRace);
        for R := reTheEmpire to reLegionsOfTheDamned do
        begin
          if Ord(R) - 1 = CurrentIndex then
            DrawImage(Lf, Top + Y, reActFrame)
          else
            DrawImage(Lf, Top + Y, reFrame);
          RenderRace(R, Lf, Top + Y);
          Inc(Y, 120);
        end;
      end;
    stSpy:
      begin
        DrawTitle(reTitleThief);
        for Z := svIntroduceSpy to svPoison do
        begin
          if Ord(Z) = CurrentIndex then
            DrawImage(Lf, Top + Y, reActFrame)
          else
            DrawImage(Lf, Top + Y, reFrame);
          RenderSpy(Z, Lf, Top + Y);
          Inc(Y, 120);
        end;
      end;
    stScenario, stJournal:
      begin
        DrawImage(reWallpaperScenario);
        DrawTitle(reTitleScenario);
        for S := Low(TScenario.TScenarioEnum)
          to High(TScenario.TScenarioEnum) do
        begin
          if Ord(S) = CurrentIndex then
            DrawImage(Lf, Top + Y, reActFrame)
          else
            DrawImage(Lf, Top + Y, reFrame);
          RenderScenario(S, Lf, Top + Y);
          Inc(Y, 120);
        end;
      end;
    stVictory:
      begin
        DrawTitle(reTitleVictory);
      end;
    stDefeat:
      begin
        DrawImage(reWallpaperDefeat);
        DrawTitle(reTitleDefeat);
      end;
    stHighScores2:
      begin
        DrawTitle(reTitleHighScores);
      end;
    stStoneTab:
      begin
        DrawTitle(reTitleLoot);
        DrawItem([reItemStoneTable]);
        DrawText(450, 'КАМЕННАЯ ТАБЛИЧКА');
        DrawText(470, TScenario.ScenarioAncientKnowledgeState);
      end;
    stLoot:
      begin
        DrawImage(reWallpaperLoot);
        DrawTitle(reTitleLoot);
        case LootRes of
          reGold:
            begin
              DrawGold;
              DrawText(450, 'СОКРОВИЩЕ');
              DrawText(470, 'ЗОЛОТО +' + IntToStr(TSaga.NewGold));
            end;
          reMana:
            begin
              DrawMana;
              DrawText(450, 'СОКРОВИЩЕ');
              DrawText(470, 'МАНА +' + IntToStr(TSaga.NewMana));
            end;
          reBag:
            begin
              Y := 470;
              DrawText(450, 'СОКРОВИЩЕ');
              if TSaga.NewGold > 0 then
              begin
                It1 := reItemGold;
                DrawText(Y, 'ЗОЛОТО +' + IntToStr(TSaga.NewGold));
                Inc(Y, 20);
              end;
              if TSaga.NewMana > 0 then
              begin
                if It1 = reNone then
                  It1 := reItemMana
                else
                  It2 := reItemMana;
                DrawText(Y, 'МАНА +' + IntToStr(TSaga.NewMana));
                Inc(Y, 20);
              end;
              if TSaga.NewItem > 0 then
              begin
                ItemRes := reAcolyte;
                if It1 = reNone then
                  It1 := ItemRes
                else if It2 = reNone then
                  It2 := ItemRes
                else
                  It3 := ItemRes;
                DrawText(Y, 'АРТЕФАКТ ' + IntToStr(TSaga.NewItem));
                Inc(Y, 20);
              end;
              DrawItem([It1, It2, It3]);
            end;
        end;
      end;
    stInform:
      begin
        DrawImage(reWallpaperScenario);
        DrawImage(ScrWidth - (ResImage[reBigFrame].Width div 2), 150,
          ResImage[reBigFrame]);
        DrawText(300, Msg);
      end;
  end;
  if SubScene in MainButtonsScene + CloseButtonScene - AddButtonScene then
    DrawImage(Lf + ResImage[reActFrame].Width + 2, Top, reInfoFrame);
  case SubScene of
    stCharacter, stLeader:
      begin
        K := TRaceCharKind(CurrentIndex);
        case SubScene of
          stCharacter:
            C := Characters[TSaga.LeaderRace][cgCharacters][K];
          stLeader:
            C := Characters[TSaga.LeaderRace][cgLeaders][K];
        end;
        RenderCharacterInfo(C);
        case SubScene of
          stCharacter:
            begin
              DrawResources;
              DrawImage(Lf + (ResImage[reActFrame].Width * 2) - 70,
                Top, reGold);
              DrawText(Lf + (ResImage[reActFrame].Width * 2) - 40, Top + 12,
                TCreature.Character(C).Gold);
            end;
          stLeader:
            begin
              { DrawImage(Lf + (ResImage[reActFrame].Width + 2) * 2, Top,
                reInfoFrame);
                T := Top + 6;
                L := Lf + (ResImage[reActFrame].Width * 2) + 14;
                Add('Умения', True);
                Add; }
            end;
        end;
      end;

    stRace:
      RenderRaceInfo;
    stDifficulty:
      RenderDifficultyInfo;
    stScenario, stJournal:
      RenderScenarioInfo;
    stVictory, stDefeat:
      RenderFinalInfo;
    stHighScores2:
      RenderHighScores;
    stSpy:
      RenderSpyInfo;
  end;
  RenderButtons;
end;

procedure TSceneHire.Timer;

begin
  inherited;

end;

procedure TSceneHire.Update(var Key: Word);

begin
  inherited;
  case SubScene of
    stCharacter:
      case Key of
        K_ESCAPE:
          Back;
        K_ENTER:
          Ok;
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TRaceCharKind)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TRaceCharKind)));
          end;
      end;
    stSpy:
      case Key of
        K_ESCAPE:
          Back;
        K_ENTER:
          Ok;
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TLeaderThiefSpyVar)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TLeaderThiefSpyVar)));
          end;
      end;
    stLeader:
      case Key of
        K_ESCAPE:
          Back;
        K_ENTER:
          Ok;
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TRaceCharKind)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TRaceCharKind)));
          end;
      end;
    stRace:
      case Key of
        K_ESCAPE:
          Back;
        K_ENTER:
          Ok;
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TRaceCharKind)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TRaceCharKind)));
          end;
      end;
    stDifficulty:
      case Key of
        K_ESCAPE:
          Back;
        K_ENTER:
          Ok;
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TSaga.TDifficultyEnum)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TSaga.TDifficultyEnum)));
          end;
      end;
    stScenario:
      case Key of
        K_ESCAPE:
          Back;
        K_ENTER:
          Ok;
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TScenario.TScenarioEnum)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TScenario.TScenarioEnum)));
          end;
      end;
    stVictory, stDefeat:
      case Key of
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TScenario.TScenarioEnum)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TScenario.TScenarioEnum)));
          end;
      end;
    stHighScores2:
      case Key of
        K_UP:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex - 1, 0,
              Ord(High(TScenario.TScenarioEnum)));
          end;
        K_DOWN:
          begin
            MediaPlayer.Play(mmClick);
            CurrentIndex := EnsureRange(CurrentIndex + 1, 0,
              Ord(High(TScenario.TScenarioEnum)));
          end;
      end;
  end;
  if (SubScene in CloseButtonScene) then
    case Key of
      K_ESCAPE, K_ENTER:
        Ok;
    end;
end;

end.
