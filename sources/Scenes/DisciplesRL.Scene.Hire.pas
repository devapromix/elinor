unit DisciplesRL.Scene.Hire;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Creatures,
  Elinor.Scenes,
  Elinor.Resources,
  Elinor.Party;

type
  THireSubSceneEnum = (stVictory, stDefeat, stHighScores2, stLoot, stStoneTab,
    stSpy, stWar);

type

  { TSceneHire }

  TSceneHire = class(TScene)
  private
    class var CurrentIndex: Integer;
  strict private
    function ThiefPoisonDamage: Integer;
    function ThiefChanceOfSuccess(V: TLeaderThiefSpyVar): Integer;
    function WarriorChanceOfSuccess(V: TLeaderWarriorActVar): Integer;
    procedure RenderButtons;
    procedure Ok;
    procedure Back;
    procedure RenderSpyInfo;
    procedure RenderWarInfo;
    procedure RenderSpy(const N: TLeaderThiefSpyVar; const AX, AY: Integer);
    procedure RenderWar(const N: TLeaderWarriorActVar; const AX, AY: Integer);
  private
    procedure RenderHighScores;
    procedure RenderFinalInfo;
    procedure UpdEnum<N>(AKey: Word);
    procedure Basic(AKey: Word);
  public
  class var
    MPX: Integer;
    MPY: Integer;
    CurCrAbilityEnum: TAbilityEnum;
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
  System.Math,
  System.SysUtils,
  Elinor.Faction,
  Elinor.Statistics,
  Elinor.Common,
  Elinor.Map,
  Elinor.Button,
  Elinor.Scene.Party,
  Elinor.Scene.Battle2,
  Elinor.Scene.Settlement,
  Elinor.Items,
  Elinor.Scene.Difficulty,
  Elinor.Scene.Faction, Elinor.Difficulty;

var
  CurCrEnum: TCreatureEnum;

type
  TButtonEnum = (btOk, btClose);

const
  ButtonText: array [THireSubSceneEnum] of array [TButtonEnum] of TResEnum = (
    // Victory
    (reTextClose, reTextClose),
    // Defeat
    (reTextClose, reTextClose),
    // Scores
    (reTextClose, reTextClose),
    // Loot
    (reTextClose, reTextClose),
    // StoneTab
    (reTextClose, reTextClose),
    // Thief Spy
    (reTextContinue, reTextClose),
    // Warrior War
    (reTextContinue, reTextClose)
    //
    );

const
  AddButtonScene = [stLoot, stStoneTab];
  CloseCloseScene = [];
  CloseButtonScene = [stVictory, stDefeat, stHighScores2] + AddButtonScene +
    CloseCloseScene;
  MainButtonsScene = [stHighScores2, stSpy, stWar];
  WideButtonScene = [];

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;
  SubScene: THireSubSceneEnum;
  BackScene: TSceneEnum = scMenu;
  Button: array [THireSubSceneEnum] of array [TButtonEnum] of TButton;
  Lf, Lk: Integer;
  GC, MC: Integer;
  LootRes: TResEnum;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum);
begin
  CurrentIndex := 0;
  SubScene := ASubScene;
  Game.Show(scHire);
  if ASubScene = stVictory then
    Game.MediaPlayer.PlayMusic(mmVictory);
end;

class procedure TSceneHire.Show(const Party: TParty; const Position: Integer);
begin

end;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum;
  const ABackScene: TSceneEnum);
begin
  SubScene := ASubScene;
  BackScene := ABackScene;
  Game.Show(scHire);
end;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum;
  const ABackScene: TSceneEnum; const ALootRes: TResEnum);
begin
  TSceneHire.Show(ASubScene, ABackScene);
  case SubScene of
    stLoot, stStoneTab:
      Game.MediaPlayer.PlaySound(mmLoot);
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
  Game.MediaPlayer.PlaySound(mmClick);
  case SubScene of
    stSpy, stWar:
      Game.Show(scMap);
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
        Game.Show(scMenu);
      end;
  end;
end;

function TSceneHire.ThiefChanceOfSuccess(V: TLeaderThiefSpyVar): Integer;
const
  S: array [TLeaderThiefSpyVar] of Byte = (95, 80, 65);
begin
  Result := S[V] - (20 - EnsureRange(TLeaderParty.Leader.Level * 2, 0, 20));
end;

function TSceneHire.WarriorChanceOfSuccess(V: TLeaderWarriorActVar): Integer;
const
  S: array [TLeaderWarriorActVar] of Byte = (100, 80, 60);
begin
  Result := S[V];
end;

function TSceneHire.ThiefPoisonDamage: Integer;
begin
  Result := TSaga.LeaderThiefPoisonDamageAllInPartyPerLevel;
end;

procedure TSceneHire.Ok;
var
  F: Boolean;
  I: Integer;

  procedure NoSpy;
  begin
    InformDialog('Вы использовали все попытки!');
  end;

  function TrySpy(V: TLeaderThiefSpyVar): Boolean;
  begin
    Result := (RandomRange(0, 100) <= ThiefChanceOfSuccess(V)) or Game.Wizard;
    if not Result then
    begin
      InformDialog('Вы потерпели неудачу и вступаете в схватку!');
      TLeaderParty.Leader.PutAt(MPX, MPY);
    end;
  end;

  function TryWar(V: TLeaderWarriorActVar): Boolean;
  begin
    Result := (RandomRange(0, 100) <= WarriorChanceOfSuccess(V)) or Game.Wizard;
    if not Result then
    begin
      InformDialog('Вы потерпели неудачу и вступаете в схватку!');
      TLeaderParty.Leader.PutAt(MPX, MPY);
    end;
  end;

begin
  Game.MediaPlayer.PlaySound(mmClick);
  case SubScene of
    stDefeat:
      begin
        TSaga.IsGame := False;
        TSceneHire.Show(stHighScores2);
        Game.MediaPlayer.PlayMusic(mmMenu);
      end;
    stVictory:
      begin
        TSaga.IsGame := False;
        TSceneHire.Show(stHighScores2);
        Game.MediaPlayer.PlayMusic(mmMenu);
      end;
    stHighScores2:
      begin
        Game.Show(scMenu);
      end;
    stStoneTab:
      begin
        if (Game.Scenario.CurrentScenario = sgAncientKnowledge) then
          if Game.Scenario.StoneTab >= TScenario.ScenarioStoneTabMax then
          begin
            TSceneHire.Show(stVictory);
            Exit;
          end
          else
          begin
            F := True;
            Game.Show(scMap);
            Exit;
          end;
      end;
    stSpy:
      begin
        case TLeaderThiefSpyVar(CurrentIndex) of
          svIntroduceSpy:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TrySpy(svIntroduceSpy) then
                begin
                TLeaderParty.Leader.PutAt(MPX, MPY, True);
                end;
                end
                else
                NoSpy; }
            end;
          svDuel:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TrySpy(svDuel) then
                begin
                InformDialog('Вы вызвали противника на дуэль!');
                TSceneBattle2.IsDuel := True;
                TLeaderParty.Leader.PutAt(MPX, MPY);
                end;
                end
                else
                NoSpy; }
            end;
          svPoison:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TrySpy(svPoison) then
                begin
                I := TSaga.GetPartyIndex(MPX, MPY);
                Party[I].TakeDamageAll(ThiefPoisonDamage);
                InformDialog('Вы отравили все колодцы в округе!');
                end;
                end
                else
                NoSpy; }
            end
        else
          Game.Show(scMap);
        end;
      end;
    stWar:
      begin
        case TLeaderWarriorActVar(CurrentIndex) of
          avRest:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TryWar(avRest) then
                begin
                // TLeaderParty.Leader.PutAt(MPX, MPY, True);
                end;
                end
                else
                NoSpy; }
            end;
          avRitual:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TryWar(avRitual) then
                begin
                // InformDialog('Вы вызвали противника на дуэль!');
                // TSceneBattle2.IsDuel := True;
                // TLeaderParty.Leader.PutAt(MPX, MPY);
                end;
                end
                else
                NoSpy; }
            end;
          avWar3:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TryWar(avWar3) then
                begin
                // I := TSaga.GetPartyIndex(MPX, MPY);
                // Party[I].TakeDamageAll(ThiefPoisonDamage);
                // InformDialog('Вы отравили все колодцы в округе!');
                end;
                end
                else
                NoSpy; }
            end
        else
          Game.Show(scMap);
        end;
      end;
    stLoot:
      begin
        Game.MediaPlayer.PlaySound(mmLoot);
        F := True;
        Game.Show(scMap);
        begin
          if (Game.Scenario.CurrentScenario = sgDarkTower) then
          begin
            case Game.Map.LeaderTile of
              reTower:
                begin
                  TSceneHire.Show(stVictory);
                  Exit;
                end;
            end;
          end;
          if Game.Map.LeaderTile = reNeutralCity then
          begin
            Game.MediaPlayer.PlayMusic(mmGame);
            Game.MediaPlayer.PlaySound(mmSettlement);
            TSceneSettlement.ShowScene(stCity);
            Exit;
          end;
          if F then
            Game.NewDay;
        end;
      end;
  end;
end;

procedure TSceneHire.RenderSpy(const N: TLeaderThiefSpyVar;
  const AX, AY: Integer);
begin
  case N of
    svIntroduceSpy:
      DrawImage(AX + 7, AY + 7, reThiefSpy);
    svDuel:
      DrawImage(AX + 7, AY + 7, reThiefDuel);
    svPoison:
      DrawImage(AX + 7, AY + 7, reThiefPoison);
  end;
end;

procedure TSceneHire.RenderWar(const N: TLeaderWarriorActVar;
  const AX, AY: Integer);
begin
  case N of
    avRest:
      DrawImage(AX + 7, AY + 7, reWarriorRest);
    avRitual:
      DrawImage(AX + 7, AY + 7, reWarriorRitual);
    avWar3:
      DrawImage(AX + 7, AY + 7, reWarriorWar3);
  end;
end;

procedure TSceneHire.RenderFinalInfo;
begin
  TextTop := SceneTop + 6;
  TextLeft := Lf + ResImage[reActFrame].Width + 12;
  AddTextLine('Statistics', True);
  AddTextLine;
  AddTextLine('Battles Won', Game.Statistics.GetValue(stBattlesWon));
  AddTextLine('Killed Creatures', Game.Statistics.GetValue(stKilledCreatures));
  AddTextLine('Scores', Game.Statistics.GetValue(stScores));
end;

procedure TSceneHire.RenderHighScores;
begin

end;

procedure TSceneHire.RenderSpyInfo;
var
  J: Integer;
  S: TLeaderThiefSpyVar;
begin
  TextTop := SceneTop + 6;
  TextLeft := Lf + ResImage[reActFrame].Width + 12;
  S := TLeaderThiefSpyVar(CurrentIndex);
  AddTextLine(TSaga.SpyName[S], True);
  AddTextLine;
  for J := 0 to 4 do
    AddTextLine(TSaga.SpyDescription[S][J]);
  AddTextLine;
  AddTextLine;
  AddTextLine;
  AddTextLine;
  // AddTextLine(Format('Попыток на день: %d/%d', [TLeaderParty.Leader.Spy,
  // TLeaderParty.Leader.GetMaxSpy]));
  AddTextLine(Format('Вероятность успеха: %d %', [ThiefChanceOfSuccess(S)]));
  case S of
    svPoison:
      AddTextLine(Format('Сила ядов: %d', [ThiefPoisonDamage]));
  end;
end;

procedure TSceneHire.RenderWarInfo;
var
  J: Integer;
  S: TLeaderWarriorActVar;
begin
  TextTop := SceneTop + 6;
  TextLeft := Lf + ResImage[reActFrame].Width + 12;
  S := TLeaderWarriorActVar(CurrentIndex);
  AddTextLine(TSaga.WarName[S], True);
  AddTextLine;
  for J := 0 to 4 do
    AddTextLine(TSaga.WarDescription[S][J]);
  AddTextLine;
  AddTextLine;
  AddTextLine;
  AddTextLine;
  //AddTextLine(Format('Попыток на день: %d/%d', [TLeaderParty.Leader.Spy,
  //  TLeaderParty.Leader.GetMaxSpy]));
  AddTextLine(Format('Вероятность успеха: %d %', [WarriorChanceOfSuccess(S)]));
end;

procedure TSceneHire.RenderButtons;
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
  Lc, W: Integer;
begin
  inherited;
  MPX := 0;
  MPY := 0;
  for J := Low(THireSubSceneEnum) to High(THireSubSceneEnum) do
  begin
    W := ResImage[reButtonDef].Width + 4;
    if (J in CloseButtonScene) then
      Lc := ScrWidth - (ResImage[reButtonDef].Width div 2)
    else
      Lc := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
    for I := Low(TButtonEnum) to High(TButtonEnum) do
    begin
      Button[J][I] := TButton.Create(Lc, 600, ButtonText[J][I]);
      if not(J in CloseButtonScene) then
        Inc(Lc, W);
      if (I = btOk) then
        Button[J][I].Sellected := True;
    end;
  end;
  Lf := ScrWidth - (ResImage[reFrame].Width) - 2;
  Lk := ScrWidth - (((ResImage[reFrame].Width) * 2) + 2);
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
        if (SubScene in WideButtonScene) then
        begin
          if MouseOver(Lk, SceneTop, X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := 0;
          end;
          if MouseOver(Lk, SceneTop + 120, X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := 1;
          end;
          if MouseOver(Lk, SceneTop + 240, X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := 2;
          end;
        end;
        if not(SubScene in CloseButtonScene) or (SubScene in CloseCloseScene)
        then
        begin
          if MouseOver(Lf, SceneTop, X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := IfThen(SubScene in WideButtonScene, 3, 0);
          end;
          if MouseOver(Lf, SceneTop + 120, X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := IfThen(SubScene in WideButtonScene, 4, 1);
          end;
          if MouseOver(Lf, SceneTop + 240, X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := IfThen(SubScene in WideButtonScene, 5, 2);
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
  Left, X, Y, I: Integer;
  R: TFactionEnum;
  K: TFactionLeaderKind;
  S: TScenario.TScenarioEnum;
  D: TDifficultyEnum;
  Z: TLeaderThiefSpyVar;
  N: TLeaderWarriorActVar;
  ItemRes: TResEnum;
  It1, It2, It3: TResEnum;

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
  X := 0;
  It1 := reNone;
  It2 := reNone;
  It3 := reNone;
  case SubScene of
    stSpy:
      begin
        DrawImage(reWallpaperDifficulty);
        DrawTitle(reTitleThief);
        for Z := svIntroduceSpy to svPoison do
        begin
          if Ord(Z) = CurrentIndex then
            DrawImage(Lf, SceneTop + Y, reActFrame)
          else
            DrawImage(Lf, SceneTop + Y, reFrame);
          RenderSpy(Z, Lf, SceneTop + Y);
          Inc(Y, 120);
        end;
      end;
    stWar:
      begin
        DrawImage(reWallpaperDifficulty);
        DrawTitle(reTitleWarrior);
        for N := avRest to avWar3 do
        begin
          if Ord(N) = CurrentIndex then
            DrawImage(Lf, SceneTop + Y, reActFrame)
          else
            DrawImage(Lf, SceneTop + Y, reFrame);
          RenderWar(N, Lf, SceneTop + Y);
          Inc(Y, 120);
        end;
      end;
    stVictory:
      begin
        DrawImage(reWallpaperDefeat);
        DrawTitle(reTitleVictory);
      end;
    stDefeat:
      begin
        DrawImage(reWallpaperDefeat);
        DrawTitle(reTitleDefeat);
      end;
    stHighScores2:
      begin
        DrawImage(reWallpaperDefeat);
        DrawTitle(reTitleHighScores);
      end;
    stStoneTab:
      begin
        DrawImage(reWallpaperLoot);
        DrawTitle(reTitleLoot);
        DrawItem([reItemStoneTable]);
        DrawText(450, 'КАМЕННАЯ ТАБЛИЧКА');
        DrawText(470, Game.Scenario.ScenarioAncientKnowledgeState);
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
              DrawText(470, 'ЗОЛОТО +' + IntToStr(Game.Gold.NewValue));
            end;
          reMana:
            begin
              DrawMana;
              DrawText(450, 'СОКРОВИЩЕ');
              DrawText(470, 'МАНА +' + IntToStr(Game.Mana.NewValue));
            end;
          reBag:
            begin
              Y := 470;
              DrawText(450, 'СОКРОВИЩЕ');
              if Game.Gold.NewValue > 0 then
              begin
                It1 := reItemGold;
                DrawText(Y, 'ЗОЛОТО +' + IntToStr(Game.Gold.NewValue));
                Inc(Y, 20);
              end;
              if Game.Mana.NewValue > 0 then
              begin
                if It1 = reNone then
                  It1 := reItemMana
                else
                  It2 := reItemMana;
                DrawText(Y, 'МАНА +' + IntToStr(Game.Mana.NewValue));
                Inc(Y, 20);
              end;
              if TSaga.NewItem > 0 then
              begin
                ItemRes := TItemBase.Item(TSaga.NewItem).ItRes;
                if It1 = reNone then
                  It1 := ItemRes
                else if It2 = reNone then
                  It2 := ItemRes
                else
                  It3 := ItemRes;
                DrawText(Y, TItemBase.Item(TSaga.NewItem).Name);
                Inc(Y, 20);
              end;
              DrawItem([It1, It2, It3]);
            end;
        end;
      end;
  end;
  if SubScene in MainButtonsScene + CloseButtonScene - AddButtonScene then
    DrawImage(Lf + ResImage[reActFrame].Width + 2, SceneTop, reInfoFrame);
  case SubScene of
    stVictory, stDefeat:
      RenderFinalInfo;
    stHighScores2:
      RenderHighScores;
    stSpy:
      RenderSpyInfo;
    stWar:
      RenderWarInfo;
  end;
  RenderButtons;
end;

procedure TSceneHire.Timer;

begin
  inherited;

end;

procedure TSceneHire.Basic(AKey: Word);
begin
  case AKey of
    K_ESCAPE:
      Back;
    K_ENTER:
      Ok;
  end;
end;

procedure TSceneHire.UpdEnum<N>(AKey: Word);
var
  Cycler: TEnumCycler<N>;
begin
  Basic(AKey);
  if not(AKey in [K_UP, K_Down]) then
    Exit;
  Game.MediaPlayer.PlaySound(mmClick);
  Cycler := TEnumCycler<N>.Create(CurrentIndex);
  CurrentIndex := Cycler.Modify(AKey = K_Down);
end;

procedure TSceneHire.Update(var Key: Word);
var
  FF: Boolean;

  procedure Upd(const MaxValue: Integer);
  begin
    Basic(Key);
    if not(Key in [K_UP, K_Down]) then
      Exit;
    Game.MediaPlayer.PlaySound(mmClick);
    CurrentIndex := EnsureRange(CurrentIndex + IfThen(Key = K_UP, -1, 1), 0,
      MaxValue);
  end;

begin
  inherited;
  case SubScene of
    stSpy:
      Upd(Ord(High(TLeaderThiefSpyVar)));
    stWar:
      Upd(Ord(High(TLeaderWarriorActVar)));
    stVictory, stDefeat, stHighScores2:
      Basic(Key);
  end;
  if (SubScene in CloseButtonScene) then
    case Key of
      K_ESCAPE, K_ENTER:
        Ok;
    end;
end;

end.
