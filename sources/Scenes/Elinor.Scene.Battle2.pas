﻿unit Elinor.Scene.Battle2;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Scenes,
  Elinor.Scene.Frames,
  Elinor.Party,
  Elinor.Battle,
  Elinor.Battle.Log;

type
  TTurnType = (ttHeal, ttDamage, ttFear);

type
  TSceneBattle2 = class(TSceneFrames)
  private
    FBattle: TBattle;
    DuelEnemyParty: TParty;
    DuelLeaderParty: TParty;
    CurrentPosition: Integer;
    ttt: Integer;
    IsNewAbility: Boolean;
    EnemyParty: TParty;
    LeaderParty: TParty;
    FEnabled: Boolean;
    BattleLog: TBattleLog;
    DuelLeaderPosition: TPosition;
    FCurrentTargetPosition: TPosition;
    procedure ClickOnPosition;
    procedure ChExperience;
    procedure Turn(const TurnType: TTurnType; AtkParty, DefParty: TParty;
      AtkPos, DefPos: TPosition);
    procedure Damage(AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
    procedure Paralyze(AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
    procedure Heal(Party: TParty; AtkPos, DefPos: TPosition);
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
    procedure Show(const S: TSceneEnum); override;
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
  BattleLog.Kill(TCreature.Character(DefCrEnum).Name[0]);
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
            BattleLog.UpdateExp(Name[0], GenderEnding, LCharacterExperience);
          end;
    end;
    for LPosition := Low(TPosition) to High(TPosition) do
      with LeaderParty.Creature[LPosition] do
        if Alive then
          if Experience >= LeaderParty.GetMaxExperiencePerLevel(Level) then
          begin
            LeaderParty.UpdateLevel(LPosition);
            BattleLog.UpdateLevel(Name[0], GenderEnding, Level + 1);
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
  DuelEnemyPosition: TPosition;
begin
  BattleLog.Clear;
  Enabled := True;
  I := PartyList.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  if IsDuel then
  begin
    DuelEnemyParty.Clear;
    DuelEnemyPosition := PartyList.Party[I].GetRandomPosition;
    DuelEnemyParty.MoveCreature(PartyList.Party[I], DuelEnemyPosition);
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
  BattleLog.Clear;
  if EnemyParty.IsClear then
    Victory;
  if LeaderParty.IsClear then
    Defeat;
end;

procedure TSceneBattle2.Turn(const TurnType: TTurnType;
  AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
var
  LHasWarriors: Boolean;
begin
  if AtkParty.Creature[AtkPos].Alive and DefParty.Creature[DefPos].Alive then
  begin
    begin
      LHasWarriors := TBattleAI.HasWarriors(DefParty);
      case AtkParty.Creature[AtkPos].ReachEnum of
        reAdj:
          if LHasWarriors and Odd(DefPos) then
            Exit;
      end;
      if AtkParty.Creature[AtkPos].ChancesToHit.GetFullValue() <
        RandomRange(0, 100) + 1 then
      begin
        BattleLog.Miss(AtkParty.Creature[AtkPos].Name[0],
          DefParty.Creature[DefPos].Name[1]);
        Game.MediaPlayer.PlaySound(mmMiss);
        Sleep(200);
        NextTurn;
        Exit;
      end;
      if AtkParty.Creature[AtkPos].Paralyze then
      begin
        BattleLog.ParalPassed;
        AtkParty.UnParalyze(AtkPos);
        NextTurn;
        Exit;
      end;
      case TurnType of
        ttDamage:
          Damage(AtkParty, DefParty, AtkPos, DefPos);
        ttHeal:
          Heal(AtkParty, AtkPos, DefPos);
      end;
    end;
  end;
  if EnemyParty.IsClear then
  begin
    BattleLog.WinInBattle;
    ChExperience;
    Game.MediaPlayer.PlaySound(mmWin);
    Game.MediaPlayer.PlayMusic(mmWinBattle);
  end;
  if LeaderParty.IsClear then
  begin
    BattleLog.LoseInBattle;
    Game.MediaPlayer.PlayMusic(mmDefeat);
    Enabled := True;
  end;
end;

procedure TSceneBattle2.Damage(AtkParty, DefParty: TParty;
  AtkPos, DefPos: TPosition);
var
  Position: TPosition;
  F, B: Boolean;
  AtkCrEnum, DefCrEnum: TCreatureEnum;
  LDamage: Integer;
begin
  AtkCrEnum := AtkParty.Creature[AtkPos].Enum;
  DefCrEnum := DefParty.Creature[DefPos].Enum;
  case TCreature.Character(AtkCrEnum).AttackEnum of
    atParalyze:
      begin
        Game.MediaPlayer.PlaySound(TCreature.Character(AtkCrEnum)
          .Sound[csAttack]);
        Sleep(200);
        Paralyze(AtkParty, DefParty, AtkPos, DefPos);
        Exit;
      end;
  end;
  if (AtkParty.Creature[AtkPos].Damage.GetFullValue() > 0) then
  begin
    B := False;
    case AtkParty.Creature[AtkPos].ReachEnum of
      reAny:
        begin
          Game.MediaPlayer.PlaySound(TCreature.Character(AtkCrEnum)
            .Sound[csAttack]);
          Sleep(200);
          LDamage := AtkParty.Creature[AtkPos].Damage.GetFullValue;
          DefParty.TakeDamage(LDamage, DefPos);
          case TCreature.Character(AtkCrEnum).AttackEnum of
            atDrainLife:
              AtkParty.Heal(AtkPos, EnsureRange(LDamage div 2, 5, 100));
          end;
          BattleLog.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
            TCreature.Character(AtkCrEnum).SourceEnum,
            AtkParty.Creature[AtkPos].Name[0], DefParty.Creature[DefPos].Name
            [1], LDamage);
          if (DefParty.Creature[DefPos].HitPoints.GetCurrValue > 0) then
            Game.MediaPlayer.PlaySound(TCreature.Character(DefCrEnum)
              .Sound[csHit])
          else
            Kill(DefCrEnum);
          B := True;
        end;
      reAdj:
        begin
          F := False;
          case AtkPos of
            1, 3, 5:
              F := (AtkParty.Creature[0].HitPoints.GetCurrValue > 0) or
                (AtkParty.Creature[2].HitPoints.GetCurrValue > 0) or
                (AtkParty.Creature[4].HitPoints.GetCurrValue > 0);
          end;
          if not F then
            case DefPos of
              0, 2, 4:
                begin
                  if (AtkPos = 0) and (DefPos = 4) and
                    ((DefParty.Creature[0].HitPoints.GetCurrValue > 0) or
                    (DefParty.Creature[2].HitPoints.GetCurrValue > 0)) then
                    Exit;
                  if (AtkPos = 4) and (DefPos = 0) and
                    ((DefParty.Creature[2].HitPoints.GetCurrValue > 0) or
                    (DefParty.Creature[4].HitPoints.GetCurrValue > 0)) then
                    Exit;
                  Game.MediaPlayer.PlaySound(TCreature.Character(AtkCrEnum)
                    .Sound[csAttack]);
                  Sleep(200);
                  DefParty.TakeDamage(AtkParty.Creature[AtkPos]
                    .Damage.GetFullValue, DefPos);
                  BattleLog.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
                    TCreature.Character(AtkCrEnum).SourceEnum,
                    AtkParty.Creature[AtkPos].Name[0],
                    DefParty.Creature[DefPos].Name[1],
                    AtkParty.Creature[AtkPos].Damage.GetFullValue);
                  if (DefParty.Creature[DefPos].HitPoints.GetCurrValue > 0) then
                    Game.MediaPlayer.PlaySound(TCreature.Character(DefCrEnum)
                      .Sound[csHit])
                  else
                    Kill(DefCrEnum);
                  B := True;
                end;
              1, 3, 5:
                begin
                  F := (DefParty.Creature[0].HitPoints.GetCurrValue > 0) or
                    (DefParty.Creature[2].HitPoints.GetCurrValue > 0) or
                    (DefParty.Creature[4].HitPoints.GetCurrValue > 0);
                  if not F then
                  begin
                    Game.MediaPlayer.PlaySound(TCreature.Character(AtkCrEnum)
                      .Sound[csAttack]);
                    Sleep(200);
                    DefParty.TakeDamage(AtkParty.Creature[AtkPos]
                      .Damage.GetFullValue, DefPos);
                    BattleLog.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
                      TCreature.Character(AtkCrEnum).SourceEnum,
                      AtkParty.Creature[AtkPos].Name[0],
                      DefParty.Creature[DefPos].Name[1],
                      AtkParty.Creature[AtkPos].Damage.GetFullValue);
                    if (DefParty.Creature[DefPos].HitPoints.GetCurrValue > 0)
                    then
                      Game.MediaPlayer.PlaySound(TCreature.Character(DefCrEnum)
                        .Sound[csHit])
                    else
                      Kill(DefCrEnum);
                    B := True;
                  end;
                end;
            end;
        end;
      reAll:
        begin
          case AtkCrEnum of
            crWyvern:
              ;
          else
            BattleLog.StartCastSpell(TCreature.Character(AtkCrEnum).Name[0],
              SourceName[TCreature.Character(AtkCrEnum).SourceEnum]);
          end;
          Game.MediaPlayer.PlaySound(TCreature.Character(AtkCrEnum)
            .Sound[csAttack]);
          Sleep(200);
          for Position := Low(TPosition) to High(TPosition) do
            if DefParty.Creature[Position].Alive then
            begin
              DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage.GetFullValue,
                Position);
              BattleLog.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
                TCreature.Character(AtkCrEnum).SourceEnum,
                AtkParty.Creature[AtkPos].Name[0],
                DefParty.Creature[Position].Name[1],
                AtkParty.Creature[AtkPos].Damage.GetFullValue);
              if (DefParty.Creature[Position].HitPoints.GetCurrValue > 0) then
                Game.MediaPlayer.PlaySound(TCreature.Character(DefCrEnum)
                  .Sound[csHit])
              else
                Kill(DefCrEnum);
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

procedure TSceneBattle2.Heal(Party: TParty; AtkPos, DefPos: TPosition);
var
  Position: TPosition;
begin
  if (Party.Creature[AtkPos].Heal > 0) then
  begin
    case Party.Creature[AtkPos].ReachEnum of
      reAll:
        begin
          for Position := Low(TPosition) to High(TPosition) do
            with Party.Creature[Position] do
              if Alive and (HitPoints.GetCurrValue < HitPoints.GetMaxValue) then
              begin
                Game.MediaPlayer.PlaySound(mmHeal);
                Party.Heal(Position, Party.Creature[AtkPos].Heal);
                BattleLog.Heal(Party.Creature[AtkPos].Name[0],
                  Party.Creature[Position].Name[1],
                  Party.Creature[AtkPos].Heal);
              end;
        end
    else
      with Party.Creature[DefPos] do
        if Alive and (HitPoints.GetCurrValue < HitPoints.GetMaxValue) then
        begin
          Party.Heal(DefPos, Party.Creature[AtkPos].Heal);
          BattleLog.Heal(Party.Creature[AtkPos].Name[0],
            Party.Creature[DefPos].Name[1], Party.Creature[AtkPos].Heal);
        end;
    end;
    NextTurn;
  end;
end;

class procedure TSceneBattle2.HideScene;
begin

end;

procedure TSceneBattle2.Paralyze(AtkParty, DefParty: TParty;
  AtkPos, DefPos: TPosition);
var
  Position: TPosition;
begin
  case AtkParty.Creature[AtkPos].ReachEnum of
    reAll:
      begin
        for Position := Low(TPosition) to High(TPosition) do
          with DefParty.Creature[Position] do
            if Alive then
            begin
              DefParty.Paralyze(Position);
              BattleLog.Paralyze(AtkParty.Creature[AtkPos].Name[0],
                DefParty.Creature[Position].Name[1]);
            end;
      end
  else
    with DefParty.Creature[DefPos] do
      if Alive then
      begin
        DefParty.Paralyze(DefPos);
        BattleLog.Paralyze(AtkParty.Creature[AtkPos].Name[0],
          DefParty.Creature[DefPos].Name[1]);
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
  BattleLog := TBattleLog.Create;
  FBattle := TBattle.Create;
end;

destructor TSceneBattle2.Destroy;
begin
  FreeAndNil(FBattle);
  FreeAndNil(BattleLog);
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
        if not TBattleAI.HasWarriors(EnemyParty) or not Odd(LPosition - 6)
        then
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
  BattleLog.Log.Render;
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
  Position: Integer;
  S: string;
  A: TArray<string>;
begin
  Position := -1;
  repeat
    S := FBattle.InitiativeList[CurrentPosition];
    if S <> '' then
    begin
      A := S.Split([':']);
      Position := A[1].ToInteger;
    end;
    Enabled := Position <= 5;
    FBattle.InitiativeList[CurrentPosition] := '';
    Dec(CurrentPosition);
    if CurrentPosition < 0 then
    begin
      StartRound;
      Exit;
    end;
  until (Position <> -1) and (GetHitPoints(Position) > 0);
  ActivePartyPosition := Position;
  if Position > 5 then
    ttt := CSpeed;
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

procedure TSceneBattle2.Show(const S: TSceneEnum);
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
  if ttt > 0 then
  begin
    Dec(ttt);
    if ttt = 0 then
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
