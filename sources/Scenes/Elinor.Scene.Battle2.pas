unit Elinor.Scene.Battle2;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Scenes,
  Elinor.Scene.Frames,
  Elinor.Party,
  Elinor.Battle;

type
  TTurnType = (ttHeal, ttDamage, ttFear);

type
  TSceneBattle2 = class(TSceneFrames)
  private
    FBattle: TBattle;
    DuelEnemyParty: TParty;
    DuelLeaderParty: TParty;
    CurrentPosition: Integer;
    FTimer: Integer;
    IsNewAbility: Boolean;
    EnemyParty: TParty;
    LeaderParty: TParty;
    FEnabled: Boolean;
    DuelLeaderPosition: TPosition;
    FCurrentTargetPosition: TPosition;
    procedure ClickOnPosition;
    procedure ChExperience;
    procedure Turn(const ATurnType: TTurnType; AAtkParty, ADefParty: TParty;
      AAtkPos, ADefPos: TPosition);
    procedure Damage(AAtkParty, ADefParty: TParty; AAtkPos, ADefPos: TPosition);
    procedure Paralyze(AAtkParty, ADefParty: TParty;
      AAtkPos, ADefPos: TPosition);
    procedure Heal(AParty: TParty; AAtkPos, ADefPos: TPosition);
    procedure Defeat;
    procedure FinishBattle;
    procedure NextTurn;
    procedure StartBattle;
    procedure Victory;
    procedure StartRound;
    function GetHitPoints(const APosition: Integer): Integer;
    procedure AI;
    procedure Kill(DefCrEnum: TCreatureEnum);
    procedure DrawTargetFrames;
    procedure SelectNextTarget;
    procedure SelectPreviousTarget;
    procedure AttackCurrentTarget;
  public
    class var IsDuel: Boolean;
    class var IsSummon: Boolean;
    class var EnemyPartyIndex: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Show(const ASceneEnum: TSceneEnum); override;
    property Enabled: Boolean read FEnabled write FEnabled;
    class procedure AfterVictory;
    class procedure ShowScene();
    class procedure HideScene;
    class procedure SummonCreature(const APartyIndex: Integer;
      const ACreatureEnum: TCreatureEnum);
  end;

implementation

uses
  System.Math, Dialogs,
  System.SysUtils,
  Elinor.Map,
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Statistics,
  Elinor.Resources,
  Elinor.Button,
  Elinor.Ability,
  Elinor.Battle.AI,
  Elinor.Scene.Defeat,
  Elinor.Scene.NewAbility,
  Elinor.Scene.Loot2,
  Elinor.Scene.Party2,
  Elinor.Frame;

var
  CloseButton: TButton;

const
  CSpeed = 2;

  { TSceneBattle2 }

class procedure TSceneBattle2.AfterVictory;
begin
  IsSummon := False;
  TLeaderParty.Leader.UnParalyzeParty;
  TLeaderParty.Leader.ClearTempValuesAll;
  TLeaderParty.Summoned.UnParalyzeParty;
  TLeaderParty.Summoned.ClearTempValuesAll;
  TSceneLoot2.ShowScene;
end;

procedure TSceneBattle2.Kill(DefCrEnum: TCreatureEnum);
begin
  FBattle.BattleLog.Kill(TCreature.Character(DefCrEnum).Name[0]);
  Game.MediaPlayer.PlaySound(TCreature.Character(DefCrEnum).Sound[csDeath]);
end;

procedure TSceneBattle2.AI;

  procedure AtkAny;
  var
    LPosition: TPosition;
    LCurPosition: Integer;
    LMinHitPoints: Integer;
  begin
    LMinHitPoints := 99999;
    LCurPosition := -1;
    for LPosition := 0 to 5 do
      if LeaderParty.Creature[LPosition].Alive then
      begin
        if (LeaderParty.Creature[LPosition].HitPoints.GetCurrValue <
          LMinHitPoints) then
        begin
          LMinHitPoints := LeaderParty.Creature[LPosition]
            .HitPoints.GetCurrValue;
          LCurPosition := LPosition;
        end;
      end;
    if (LCurPosition > -1) then
    begin
      CurrentPartyPosition := LCurPosition;
      ClickOnPosition;
    end;
  end;

  procedure AtkAll;
  var
    LPosition: TPosition;
  begin
    for LPosition := 0 to 5 do
      if LeaderParty.Creature[LPosition].Alive then
      begin
        CurrentPartyPosition := LPosition;
        ClickOnPosition;
      end;
  end;

  procedure AtkAdj;
  var
    LPosition: TPosition;
  begin
    begin
      if TBattleAI.HasWarriors(LeaderParty) then
      begin
        for LPosition := 0 to 5 do
        begin
          if LeaderParty.Creature[LPosition].Alive then
          begin
            CurrentPartyPosition := LPosition;
            ClickOnPosition;
            Exit;
          end;
        end
      end
      else
        AtkAny;
    end;
  end;

begin
  if LeaderParty.IsClear then
  begin
    CurrentPartyPosition := 0;
    ClickOnPosition;
    Exit;
  end;
  case ActivePartyPosition of
    6 .. 11:
      case EnemyParty.Creature[ActivePartyPosition - 6].ReachEnum of
        reAny:
          AtkAny;
        reAdj:
          AtkAdj;
        reAll:
          AtkAll;
      end;
  end;
end;

procedure TSceneBattle2.AttackCurrentTarget;
begin
  if ActivePartyPosition < 0 then
    Exit;
  if (FCurrentTargetPosition >= 0) and (FCurrentTargetPosition <= 5) and
    (EnemyParty.Creature[FCurrentTargetPosition].Alive) then
  begin
    CurrentPartyPosition := FCurrentTargetPosition + 6;
    ClickOnPosition;
  end;
end;

procedure TSceneBattle2.ChExperience;
var
  LPosition: TPosition;
  LCharacterExperience: Integer;
begin
  if (EnemyParty.GetExperience > 0) then
  begin
    if LeaderParty.GetAliveAndNeedExpCreatures > 0 then
    begin
      LCharacterExperience :=
        EnsureRange(EnemyParty.GetExperience div LeaderParty.
        GetAliveAndNeedExpCreatures, 1, 9999);
      for LPosition := Low(TPosition) to High(TPosition) do
        with LeaderParty.Creature[LPosition] do
          if AliveAndNeedExp then
          begin
            LeaderParty.UpdateXP(LCharacterExperience, LPosition);
            FBattle.BattleLog.UpdateExp(Name[0], GenderEnding,
              LCharacterExperience);
          end;
    end;
    for LPosition := Low(TPosition) to High(TPosition) do
      with LeaderParty.Creature[LPosition] do
        if Alive then
          if Experience >= LeaderParty.GetMaxExperiencePerLevel(Level) then
          begin
            LeaderParty.UpdateLevel(LPosition);
            FBattle.BattleLog.UpdateLevel(Name[0], GenderEnding, Level + 1);
            IsNewAbility := (Leadership > 0) and (Level <= CMaxAbilities);
          end;
  end;
end;

procedure TSceneBattle2.Victory;
begin
  Game.Statistics.IncValue(stBattlesWon);
  Game.Statistics.IncValue(stKilledCreatures, EnemyParty.Count + 1);
  //
  if IsDuel then
  begin
    IsDuel := False;
    InformDialog('Вы победили на дуэли и воины вражеского отряда разбежались!');
  end;
  Game.MediaPlayer.PlayMusic(mmMap);
  PartyList.Party[PartyList.GetPartyIndex(TLeaderParty.Leader.X,
    TLeaderParty.Leader.Y)].Clear;
  if IsNewAbility then
  begin
    IsNewAbility := False;
    TLeaderParty.Leader.Abilities.GenRandomList;
    TSceneNewAbility.ShowScene;
    Exit;
  end;
  AfterVictory;
end;

procedure TSceneBattle2.Defeat;
begin
  if IsSummon then
  begin
    IsSummon := False;
    Game.MediaPlayer.PlayMusic(mmMap);
    Game.Show(scMap);
    Exit;
  end;
  TSceneDefeat.ShowScene;
end;

procedure TSceneBattle2.StartBattle;
var
  I: Integer;
  LDuelEnemyPosition: TPosition;
begin
  FBattle.BattleLog.Clear;
  Enabled := True;
  I := PartyList.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  if IsDuel then
  begin
    DuelEnemyParty.Clear;
    LDuelEnemyPosition := PartyList.Party[I].GetRandomPosition;
    DuelEnemyParty.MoveCreature(PartyList.Party[I], LDuelEnemyPosition);
    EnemyParty := DuelEnemyParty;
    DuelLeaderParty.Clear;
    DuelLeaderPosition := TLeaderParty.GetPosition;
    DuelLeaderParty.MoveCreature(PartyList.Party[TLeaderParty.LeaderPartyIndex],
      DuelLeaderPosition);
    LeaderParty := DuelLeaderParty;
  end
  else
  begin
    if IsSummon then
    begin
      EnemyParty := PartyList.Party[EnemyPartyIndex];
      LeaderParty := PartyList.Party[TLeaderParty.SummonPartyIndex]
    end
    else
    begin
      EnemyParty := PartyList.Party[I];
      LeaderParty := PartyList.Party[TLeaderParty.LeaderPartyIndex];
    end;
  end;
  ActivePartyPosition := PartyList.Party[TLeaderParty.LeaderPartyIndex]
    .GetRandomPosition;
  CurrentPartyPosition := ActivePartyPosition;
  Game.MediaPlayer.PlaySound(mmWar);
  StartRound;
end;

procedure TSceneBattle2.FinishBattle;
begin
  if IsDuel then
    PartyList.Party[TLeaderParty.LeaderPartyIndex].MoveCreature(LeaderParty,
      DuelLeaderPosition);
  FBattle.BattleLog.Clear;
  if EnemyParty.IsClear then
    Victory;
  if LeaderParty.IsClear then
    Defeat;
end;

procedure TSceneBattle2.Turn(const ATurnType: TTurnType;
  AAtkParty, ADefParty: TParty; AAtkPos, ADefPos: TPosition);
var
  LHasWarriors: Boolean;
begin
  if AAtkParty.Creature[AAtkPos].Alive and ADefParty.Creature[ADefPos].Alive
  then
  begin
    begin
      LHasWarriors := TBattleAI.HasWarriors(ADefParty);
      case AAtkParty.Creature[AAtkPos].ReachEnum of
        reAdj:
          if LHasWarriors and Odd(ADefPos) then
            Exit;
      end;
      if AAtkParty.Creature[AAtkPos].ChancesToHit.GetFullValue() <
        RandomRange(0, 100) + 1 then
      begin
        FBattle.BattleLog.Miss(AAtkParty.Creature[AAtkPos].Name[0],
          ADefParty.Creature[ADefPos].Name[1]);
        Game.MediaPlayer.PlaySound(mmMiss);
        Sleep(200);
        NextTurn;
        Exit;
      end;
      if AAtkParty.Creature[AAtkPos].Paralyze then
      begin
        FBattle.BattleLog.ParalPassed;
        AAtkParty.UnParalyze(AAtkPos);
        NextTurn;
        Exit;
      end;
      case ATurnType of
        ttDamage:
          Damage(AAtkParty, ADefParty, AAtkPos, ADefPos);
        ttHeal:
          Heal(AAtkParty, AAtkPos, ADefPos);
      end;
    end;
  end;
  if EnemyParty.IsClear then
  begin
    FBattle.BattleLog.WinInBattle;
    ChExperience;
    Game.MediaPlayer.PlaySound(mmWin);
    Game.MediaPlayer.PlayMusic(mmWinBattle);
  end;
  if LeaderParty.IsClear then
  begin
    FBattle.BattleLog.LoseInBattle;
    Game.MediaPlayer.PlayMusic(mmDefeat);
    Enabled := True;
  end;
end;

procedure TSceneBattle2.Damage(AAtkParty, ADefParty: TParty;
  AAtkPos, ADefPos: TPosition);
var
  LPosition: TPosition;
  LAtkCrEnum, LDefCrEnum: TCreatureEnum;
  LDamage: Integer;
  F, B: Boolean;
begin
  LAtkCrEnum := AAtkParty.Creature[AAtkPos].Enum;
  LDefCrEnum := ADefParty.Creature[ADefPos].Enum;

  if FBattle.CheckArtifactParalyze(AAtkParty, ADefParty, AAtkPos, ADefPos,
    LAtkCrEnum, LDefCrEnum) then
  begin
    Sleep(200);
  end;

  case TCreature.Character(LAtkCrEnum).AttackEnum of
    atParalyze:
      begin
        Game.MediaPlayer.PlaySound(TCreature.Character(LAtkCrEnum)
          .Sound[csAttack]);
        Sleep(200);
        Paralyze(AAtkParty, ADefParty, AAtkPos, ADefPos);
        Exit;
      end;
  end;
  if (AAtkParty.Creature[AAtkPos].Damage.GetFullValue() > 0) then
  begin
    B := False;
    case AAtkParty.Creature[AAtkPos].ReachEnum of
      reAny:
        begin
          Game.MediaPlayer.PlaySound(TCreature.Character(LAtkCrEnum)
            .Sound[csAttack]);
          Sleep(200);
          LDamage := AAtkParty.Creature[AAtkPos].Damage.GetFullValue;
          ADefParty.TakeDamage(LDamage, ADefPos);
          case TCreature.Character(LAtkCrEnum).AttackEnum of
            atDrainLife:
              AAtkParty.Heal(AAtkPos, EnsureRange(LDamage div 2, 5, 100));
          end;
          FBattle.BattleLog.Attack(TCreature.Character(LAtkCrEnum).AttackEnum,
            TCreature.Character(LAtkCrEnum).SourceEnum,
            AAtkParty.Creature[AAtkPos].Name[0],
            ADefParty.Creature[ADefPos].Name[1], LDamage);
          if (ADefParty.Creature[ADefPos].HitPoints.GetCurrValue > 0) then
            Game.MediaPlayer.PlaySound(TCreature.Character(LDefCrEnum)
              .Sound[csHit])
          else
            Kill(LDefCrEnum);
          B := True;
        end;
      reAdj:
        begin
          F := False;
          case AAtkPos of
            1, 3, 5:
              F := (AAtkParty.Creature[0].HitPoints.GetCurrValue > 0) or
                (AAtkParty.Creature[2].HitPoints.GetCurrValue > 0) or
                (AAtkParty.Creature[4].HitPoints.GetCurrValue > 0);
          end;
          if not F then
            case ADefPos of
              0, 2, 4:
                begin
                  if (AAtkPos = 0) and (ADefPos = 4) and
                    ((ADefParty.Creature[0].HitPoints.GetCurrValue > 0) or
                    (ADefParty.Creature[2].HitPoints.GetCurrValue > 0)) then
                    Exit;
                  if (AAtkPos = 4) and (ADefPos = 0) and
                    ((ADefParty.Creature[2].HitPoints.GetCurrValue > 0) or
                    (ADefParty.Creature[4].HitPoints.GetCurrValue > 0)) then
                    Exit;
                  Game.MediaPlayer.PlaySound(TCreature.Character(LAtkCrEnum)
                    .Sound[csAttack]);
                  Sleep(200);
                  ADefParty.TakeDamage(AAtkParty.Creature[AAtkPos]
                    .Damage.GetFullValue, ADefPos);
                  FBattle.BattleLog.Attack(TCreature.Character(LAtkCrEnum)
                    .AttackEnum, TCreature.Character(LAtkCrEnum).SourceEnum,
                    AAtkParty.Creature[AAtkPos].Name[0],
                    ADefParty.Creature[ADefPos].Name[1],
                    AAtkParty.Creature[AAtkPos].Damage.GetFullValue);
                  if (ADefParty.Creature[ADefPos].HitPoints.GetCurrValue > 0)
                  then
                    Game.MediaPlayer.PlaySound(TCreature.Character(LDefCrEnum)
                      .Sound[csHit])
                  else
                    Kill(LDefCrEnum);
                  B := True;
                end;
              1, 3, 5:
                begin
                  F := (ADefParty.Creature[0].HitPoints.GetCurrValue > 0) or
                    (ADefParty.Creature[2].HitPoints.GetCurrValue > 0) or
                    (ADefParty.Creature[4].HitPoints.GetCurrValue > 0);
                  if not F then
                  begin
                    Game.MediaPlayer.PlaySound(TCreature.Character(LAtkCrEnum)
                      .Sound[csAttack]);
                    Sleep(200);
                    ADefParty.TakeDamage(AAtkParty.Creature[AAtkPos]
                      .Damage.GetFullValue, ADefPos);
                    FBattle.BattleLog.Attack(TCreature.Character(LAtkCrEnum)
                      .AttackEnum, TCreature.Character(LAtkCrEnum).SourceEnum,
                      AAtkParty.Creature[AAtkPos].Name[0],
                      ADefParty.Creature[ADefPos].Name[1],
                      AAtkParty.Creature[AAtkPos].Damage.GetFullValue);
                    if (ADefParty.Creature[ADefPos].HitPoints.GetCurrValue > 0)
                    then
                      Game.MediaPlayer.PlaySound(TCreature.Character(LDefCrEnum)
                        .Sound[csHit])
                    else
                      Kill(LDefCrEnum);
                    B := True;
                  end;
                end;
            end;
        end;
      reAll:
        begin
          case LAtkCrEnum of
            crWyvern:
              ;
          else
            FBattle.BattleLog.StartCastSpell(TCreature.Character(LAtkCrEnum)
              .Name[0], SourceName[TCreature.Character(LAtkCrEnum).SourceEnum]);
          end;
          Game.MediaPlayer.PlaySound(TCreature.Character(LAtkCrEnum)
            .Sound[csAttack]);
          Sleep(200);
          for LPosition := Low(TPosition) to High(TPosition) do
            if ADefParty.Creature[LPosition].Alive then
            begin
              ADefParty.TakeDamage(AAtkParty.Creature[AAtkPos]
                .Damage.GetFullValue, LPosition);
              FBattle.BattleLog.Attack(TCreature.Character(LAtkCrEnum)
                .AttackEnum, TCreature.Character(LAtkCrEnum).SourceEnum,
                AAtkParty.Creature[AAtkPos].Name[0],
                ADefParty.Creature[LPosition].Name[1],
                AAtkParty.Creature[AAtkPos].Damage.GetFullValue);
              if (ADefParty.Creature[LPosition].HitPoints.GetCurrValue > 0) then
                Game.MediaPlayer.PlaySound(TCreature.Character(LDefCrEnum)
                  .Sound[csHit])
              else
                Kill(LDefCrEnum);
            end;
          B := True;
        end;
    end;
    if B then
    begin
      NextTurn;
    end;
  end;
end;

procedure TSceneBattle2.Heal(AParty: TParty; AAtkPos, ADefPos: TPosition);
var
  LPosition: TPosition;
begin
  if (AParty.Creature[AAtkPos].Heal > 0) then
  begin
    case AParty.Creature[AAtkPos].ReachEnum of
      reAll:
        begin
          for LPosition := Low(TPosition) to High(TPosition) do
            with AParty.Creature[LPosition] do
              if Alive and (HitPoints.GetCurrValue < HitPoints.GetMaxValue) then
              begin
                Game.MediaPlayer.PlaySound(mmHeal);
                AParty.Heal(LPosition, AParty.Creature[AAtkPos].Heal);
                FBattle.BattleLog.Heal(AParty.Creature[AAtkPos].Name[0],
                  AParty.Creature[LPosition].Name[1],
                  AParty.Creature[AAtkPos].Heal);
              end;
        end
    else
      with AParty.Creature[ADefPos] do
        if Alive and (HitPoints.GetCurrValue < HitPoints.GetMaxValue) then
        begin
          AParty.Heal(ADefPos, AParty.Creature[AAtkPos].Heal);
          FBattle.BattleLog.Heal(AParty.Creature[AAtkPos].Name[0],
            AParty.Creature[ADefPos].Name[1], AParty.Creature[AAtkPos].Heal);
        end;
    end;
    NextTurn;
  end;
end;

class procedure TSceneBattle2.HideScene;
begin

end;

procedure TSceneBattle2.Paralyze(AAtkParty, ADefParty: TParty;
  AAtkPos, ADefPos: TPosition);
var
  LPosition: TPosition;
begin
  case AAtkParty.Creature[AAtkPos].ReachEnum of
    reAll:
      begin
        for LPosition := Low(TPosition) to High(TPosition) do
          with ADefParty.Creature[LPosition] do
            if Alive then
            begin
              ADefParty.Paralyze(LPosition);
              FBattle.BattleLog.Paralyze(AAtkParty.Creature[AAtkPos].Name[0],
                ADefParty.Creature[LPosition].Name[1]);
            end;
      end
  else
    with ADefParty.Creature[ADefPos] do
      if Alive then
      begin
        ADefParty.Paralyze(ADefPos);
        FBattle.BattleLog.Paralyze(AAtkParty.Creature[AAtkPos].Name[0],
          ADefParty.Creature[ADefPos].Name[1]);
      end;
  end;
  NextTurn;
end;

procedure TSceneBattle2.ClickOnPosition;
begin
  case CurrentPartyPosition of
    0 .. 5:
      case ActivePartyPosition of
        0 .. 5:
          Turn(ttHeal, LeaderParty, LeaderParty, ActivePartyPosition,
            CurrentPartyPosition);
        6 .. 11:
          Turn(ttDamage, EnemyParty, LeaderParty, ActivePartyPosition - 6,
            CurrentPartyPosition);
      end;
    6 .. 11:
      case ActivePartyPosition of
        0 .. 5:
          Turn(ttDamage, LeaderParty, EnemyParty, ActivePartyPosition,
            CurrentPartyPosition - 6);
        6 .. 11:
          Turn(ttHeal, EnemyParty, EnemyParty, ActivePartyPosition - 6,
            CurrentPartyPosition - 6);
      end;
  end;
end;

constructor TSceneBattle2.Create;
begin
  inherited Create(reWallpaperScenario, fgLS6, fgRS6);
  CloseButton := TButton.Create(1100 - (ResImage[reButtonDef].Width +
    SceneLeft), DefaultButtonTop, reTextClose);
  CloseButton.Sellected := True;
  DuelEnemyParty := TParty.Create;
  DuelLeaderParty := TParty.Create;
  FBattle := TBattle.Create;
end;

destructor TSceneBattle2.Destroy;
begin
  FreeAndNil(FBattle);
  FreeAndNil(DuelLeaderParty);
  FreeAndNil(DuelEnemyParty);
  FreeAndNil(CloseButton);
  inherited;
end;

procedure TSceneBattle2.DrawTargetFrames;
var
  LHasWarriors: Boolean;
  LPosition: TPosition;
begin
  case ActivePartyPosition of
    0 .. 5:
      begin
        LHasWarriors := TBattleAI.HasWarriors(EnemyParty);
        for LPosition := Low(TPosition) to High(TPosition) do
        begin
          if not EnemyParty.Creature[LPosition].Alive then
            Continue;
          case LeaderParty.Creature[ActivePartyPosition].ReachEnum of
            reAdj:
              if LHasWarriors and Odd(LPosition) then
                Continue;
          end;
          DrawImage(TFrame.Col(LPosition, psRight), TFrame.Row(LPosition),
            reFrameSlotGlow);
        end;
        if (FCurrentTargetPosition >= 0) and (FCurrentTargetPosition <= 5) and
          (EnemyParty.Creature[FCurrentTargetPosition].Alive) then
        begin
          DrawImage(TFrame.Col(FCurrentTargetPosition, psRight),
            TFrame.Row(FCurrentTargetPosition), reFrameSlotTarget);
        end;
      end;
  end;
end;

procedure TSceneBattle2.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if not Enabled or (Button <> mbLeft) then
    Exit;
  if CloseButton.MouseDown then
    FinishBattle
  else
  begin
    CurrentPartyPosition := GetPartyPosition(X, Y);
    if CurrentPartyPosition < 0 then
      Exit;
    if LeaderParty.IsClear or EnemyParty.IsClear then
      Exit;
    ClickOnPosition;
    Game.Render;
  end;
end;

procedure TSceneBattle2.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LPosition: Integer;
begin
  inherited;
  if not Enabled then
    Exit;
  CloseButton.MouseMove(X, Y);
  LPosition := GetPartyPosition(X, Y);
  if (LPosition >= 6) and (LPosition <= 11) and
    (EnemyParty.Creature[LPosition - 6].Alive) then
  begin
    if (ActivePartyPosition >= 0) and (ActivePartyPosition <= 5) then
    begin
      if LeaderParty.Creature[ActivePartyPosition].ReachEnum = reAdj then
      begin
        if not TBattleAI.HasWarriors(EnemyParty) or not Odd(LPosition - 6) then
          FCurrentTargetPosition := LPosition - 6;
      end
      else
        FCurrentTargetPosition := LPosition - 6;
      Game.Render;
    end;
  end;
end;

procedure TSceneBattle2.Render;
var
  F: Boolean;

  procedure RenderWait;
  begin
    DrawImage(reDark);
    DrawImage(reTime);
  end;

begin
  inherited;
  TSceneParty2.RenderParty(psLeft, LeaderParty);
  TSceneParty2.RenderParty(psRight, EnemyParty, False, False);
  DrawTargetFrames;
  // if not Enabled then
  // RenderWait;
  F := False;
  if LeaderParty.IsClear then
  begin
    DrawTitle(reTitleDefeat);
    F := True;
  end
  else if EnemyParty.IsClear then
  begin
    DrawTitle(reTitleVictory);
    F := True;
  end
  else
    DrawTitle(reTitleBattle);
  if F then
  begin
    ActivePartyPosition := -1;
    CloseButton.Render;
  end;
  FBattle.BattleLog.Log.Render;
end;

procedure TSceneBattle2.StartRound;
begin
  CurrentPosition := 11;
  FCurrentTargetPosition := 0;
  FBattle.SetInitiative(LeaderParty, EnemyParty);
  NextTurn;
  SelectNextTarget;
end;

class procedure TSceneBattle2.SummonCreature(const APartyIndex: Integer;
  const ACreatureEnum: TCreatureEnum);
begin
  TLeaderParty.Leader.Invisibility := False;
  EnemyPartyIndex := APartyIndex;
  IsSummon := True;
  TLeaderParty.Summoned.ReviveParty;
  TLeaderParty.Summoned.HealParty(9999);
  TLeaderParty.Summoned.UnParalyzeParty;
  TLeaderParty.Summoned.ClearTempValuesAll;
  Game.Show(scBattle);
end;

procedure TSceneBattle2.NextTurn;
var
  LPosition: Integer;
  S: string;
  A: TArray<string>;
begin
  LPosition := -1;
  repeat
    S := FBattle.InitiativeList[CurrentPosition];
    if S <> '' then
    begin
      A := S.Split([':']);
      LPosition := A[1].ToInteger;
    end;
    Enabled := LPosition <= 5;
    FBattle.InitiativeList[CurrentPosition] := '';
    Dec(CurrentPosition);
    if CurrentPosition < 0 then
    begin
      StartRound;
      Exit;
    end;
  until (LPosition <> -1) and (GetHitPoints(LPosition) > 0);
  ActivePartyPosition := LPosition;
  if LPosition > 5 then
    FTimer := CSpeed;
  Render;
end;

function TSceneBattle2.GetHitPoints(const APosition: Integer): Integer;
begin
  Result := 0;
  if APosition < 0 then
    Exit;
  Result := FBattle.GetHitPoints(APosition, LeaderParty, EnemyParty);
end;

procedure TSceneBattle2.SelectNextTarget;
var
  LPosition: Integer;
  LHasWarriors: Boolean;
begin
  if ActivePartyPosition < 0 then
    Exit;
  LHasWarriors := TBattleAI.HasWarriors(EnemyParty);
  repeat
    Inc(FCurrentTargetPosition);
    if FCurrentTargetPosition > 5 then
      FCurrentTargetPosition := 0;
  until (FCurrentTargetPosition >= 0) and (FCurrentTargetPosition <= 5) and
    (EnemyParty.Creature[FCurrentTargetPosition].Alive) and
    not(LHasWarriors and Odd(FCurrentTargetPosition));
  Game.Render;
end;

procedure TSceneBattle2.SelectPreviousTarget;
var
  LHasWarriors: Boolean;
begin
  if ActivePartyPosition < 0 then
    Exit;
  LHasWarriors := TBattleAI.HasWarriors(EnemyParty);
  repeat
    Dec(FCurrentTargetPosition);
    if FCurrentTargetPosition < 0 then
      FCurrentTargetPosition := 5;
  until (FCurrentTargetPosition >= 0) and (FCurrentTargetPosition <= 5) and
    (EnemyParty.Creature[FCurrentTargetPosition].Alive) and
    not(LHasWarriors and Odd(FCurrentTargetPosition));
  Game.Render;
end;

procedure TSceneBattle2.Show(const ASceneEnum: TSceneEnum);
begin
  inherited;
  IsNewAbility := False;
  StartBattle;
  Game.MediaPlayer.PlayMusic(mmBattle);
end;

class procedure TSceneBattle2.ShowScene;
begin

end;

procedure TSceneBattle2.Timer;
begin
  inherited;
  if FTimer > 0 then
  begin
    Dec(FTimer);
    if FTimer = 0 then
    begin
      AI;
      Game.Render;
    end;
  end;
end;

procedure TSceneBattle2.Update(var Key: Word);
begin
  if not Enabled then
    Exit;
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      FinishBattle;
    K_RIGHT, K_DOWN:
      SelectNextTarget;
    K_LEFT, K_UP:
      SelectPreviousTarget;
    K_SPACE:
      AttackCurrentTarget;
    K_N:
      if Game.Wizard then
        NextTurn;
    K_E:
      if Game.Wizard then
        TLeaderParty.Leader.UpdateXP(100, TLeaderParty.Leader.GetPosition);
    K_H:
      if Game.Wizard then
        TLeaderParty.Leader.HealParty(100);
    K_D:
      if Game.Wizard then
        Defeat;
    K_V:
      if Game.Wizard then
        Victory;
  end;
end;

end.
