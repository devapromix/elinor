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
    DuelEnemyParty: TParty;
    DuelLeaderParty: TParty;
    InitiativeList: TStringList;
    CurrentPosition: Integer;
    ttt: Integer;
    IsNewAbility: Boolean;
    EnemyParty: TParty;
    LeaderParty: TParty;
    FEnabled: Boolean;
    Battle: TBattle;
    DuelLeaderPosition: TPosition;
    procedure SetInitiative;
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
    function GetHitPoints(Position: Integer): Integer;
    procedure AI;
    procedure Kill(DefCrEnum: TCreatureEnum);
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
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Statistics,
  Elinor.Resources,
  Elinor.Button,
  Elinor.Ability,
  Elinor.Scene.Party,
  Elinor.Scene.Defeat,
  Elinor.Scene.NewAbility,
  DisciplesRL.Scene.Hire,
  Elinor.Map, Elinor.Scene.Loot2;

var
  CloseButton: TButton;

const
  Speed = 2;

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
  Battle.Kill(TCreature.Character(DefCrEnum).Name[0]);
  Game.MediaPlayer.PlaySound(TCreature.Character(DefCrEnum).Sound[csDeath]);
end;

procedure TSceneBattle2.AI;
var
  CurPosition: Integer;
  MinHitPoints: Integer;

  procedure AtkAny;
  var
    Position: TPosition;
  begin
    CurPosition := -1;
    MinHitPoints := 99999;
    if LeaderParty.IsClear then
    begin
      CurPosition := 0;
      ClickOnPosition;
      Exit;
    end;
    for Position := 0 to 5 do
      if LeaderParty.Creature[Position].Alive then
      begin
        if (LeaderParty.Creature[Position].HitPoints.GetCurrValue < MinHitPoints)
        then
        begin
          MinHitPoints := LeaderParty.Creature[Position].HitPoints.GetCurrValue;
          CurPosition := Position;
        end;
      end;
    if (CurPosition > -1) then
    begin
      CurrentPartyPosition := CurPosition;
      ClickOnPosition;
    end;
  end;

  procedure AtkAll;
  var
    Position: TPosition;
  begin
    if LeaderParty.IsClear then
    begin
      CurPosition := 0;
      ClickOnPosition;
      Exit;
    end;
    for Position := 0 to 5 do
      if LeaderParty.Creature[Position].Alive then
      begin
        CurrentPartyPosition := Position;
        ClickOnPosition;
        Break;
      end;
  end;

  function HasWarriors: Boolean;
  begin
    Result := (LeaderParty.Creature[1].HitPoints.GetCurrValue > 0) or
      (LeaderParty.Creature[3].HitPoints.GetCurrValue > 0) or
      (LeaderParty.Creature[5].HitPoints.GetCurrValue > 0);
  end;

  procedure AtkAdj;
  var
    Position: TPosition;
  begin
    begin
      if HasWarriors then
      begin
        if LeaderParty.IsClear then
        begin
          CurPosition := 0;
          ClickOnPosition;
          Exit;
        end;
        for Position := 0 to 5 do
        begin
          if LeaderParty.Creature[Position].Alive then
          begin
            CurrentPartyPosition := Position;
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
            Battle.UpdateExp(Name[0], GenderEnding, LCharacterExperience);
          end;
    end;
    for LPosition := Low(TPosition) to High(TPosition) do
      with LeaderParty.Creature[LPosition] do
        if Alive then
          if Experience >= LeaderParty.GetMaxExperiencePerLevel(Level) then
          begin
            LeaderParty.UpdateLevel(LPosition);
            Battle.UpdateLevel(Name[0], GenderEnding, Level + 1);
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
  Battle.Clear;
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
  ActivePartyPosition := PartyList.Party[TLeaderParty.LeaderPartyIndex].GetRandomPosition;
  CurrentPartyPosition := ActivePartyPosition;
  Game.MediaPlayer.PlaySound(mmWar);
  StartRound;
end;

procedure TSceneBattle2.FinishBattle;
begin
  if IsDuel then
    PartyList.Party[TLeaderParty.LeaderPartyIndex].MoveCreature(LeaderParty,
      DuelLeaderPosition);
  Battle.Clear;
  if EnemyParty.IsClear then
    Victory;
  if LeaderParty.IsClear then
    Defeat;
end;

procedure TSceneBattle2.Turn(const TurnType: TTurnType;
  AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
begin
  if AtkParty.Creature[AtkPos].Alive and DefParty.Creature[DefPos].Alive then
  begin
    begin
      if AtkParty.Creature[AtkPos].ChancesToHit.GetFullValue() <
        RandomRange(0, 100) + 1 then
      begin
        Battle.Miss(AtkParty.Creature[AtkPos].Name[0],
          DefParty.Creature[DefPos].Name[1]);
        Game.MediaPlayer.PlaySound(mmMiss);
        Sleep(200);
        NextTurn;
        Exit;
      end;
      if AtkParty.Creature[AtkPos].Paralyze then
      begin
        Battle.Log.Add('Паралич прошел.');
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
    Battle.WinInBattle;
    ChExperience;
    Game.MediaPlayer.PlaySound(mmWin);
    Game.MediaPlayer.PlayMusic(mmWinBattle);
  end;
  if LeaderParty.IsClear then
  begin
    Battle.LoseInBattle;
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
          Battle.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
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
                  Battle.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
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
                    Battle.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
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
            Battle.StartCastSpell(TCreature.Character(AtkCrEnum).Name[0],
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
              Battle.Attack(TCreature.Character(AtkCrEnum).AttackEnum,
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
                Battle.Heal(Party.Creature[AtkPos].Name[0],
                  Party.Creature[Position].Name[1],
                  Party.Creature[AtkPos].Heal);
              end;
        end
    else
      with Party.Creature[DefPos] do
        if Alive and (HitPoints.GetCurrValue < HitPoints.GetMaxValue) then
        begin
          Party.Heal(DefPos, Party.Creature[AtkPos].Heal);
          Battle.Heal(Party.Creature[AtkPos].Name[0],
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
              Battle.Paralyze(AtkParty.Creature[AtkPos].Name[0],
                DefParty.Creature[Position].Name[1]);
            end;
      end
  else
    with DefParty.Creature[DefPos] do
      if Alive then
      begin
        DefParty.Paralyze(DefPos);
        Battle.Paralyze(AtkParty.Creature[AtkPos].Name[0],
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
  InitiativeList := TStringList.Create;
  DuelEnemyParty := TParty.Create;
  DuelLeaderParty := TParty.Create;
  Battle := TBattle.Create;
end;

destructor TSceneBattle2.Destroy;
begin
  FreeAndNil(Battle);
  FreeAndNil(DuelLeaderParty);
  FreeAndNil(DuelEnemyParty);
  FreeAndNil(InitiativeList);
  FreeAndNil(CloseButton);
  inherited;
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
begin
  inherited;
  if not Enabled then
    Exit;
  CloseButton.MouseMove(X, Y);
  // Scenes.Render;
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
  TSceneParty.RenderParty(psLeft, LeaderParty);
  TSceneParty.RenderParty(psRight, EnemyParty, False, False);
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
  Battle.Log.Render;
end;

procedure TSceneBattle2.StartRound;
begin
  SetInitiative;
  NextTurn;
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

procedure TSceneBattle2.SetInitiative;
var
  I: Integer;
begin
  InitiativeList.Clear;
  CurrentPosition := 11;
  for I := 0 to 11 do
  begin
    InitiativeList.Add('');
    case I of
      0 .. 5:
        if LeaderParty.Creature[I].Alive then
          InitiativeList[I] :=
            Format('%d:%d', [LeaderParty.GetInitiative(I), I]);
    else
      begin
        if EnemyParty.Creature[I - 6].Alive then
          InitiativeList[I] :=
            Format('%d:%d', [EnemyParty.GetInitiative(I - 6), I]);
      end;
    end;
  end;
  for I := 0 to 11 do
    InitiativeList.Exchange(Random(I), Random(I));
  InitiativeList.Sort;
end;

procedure TSceneBattle2.NextTurn;
var
  Position: Integer;
  S: string;
  A: TArray<string>;
begin
  Position := -1;
  repeat
    S := InitiativeList[CurrentPosition];
    if S <> '' then
    begin
      A := S.Split([':']);
      Position := A[1].ToInteger;
    end;
    Enabled := Position <= 5;
    InitiativeList[CurrentPosition] := '';
    Dec(CurrentPosition);
    if CurrentPosition < 0 then
    begin
      StartRound;
      Exit;
    end;
  until (Position <> -1) and (GetHitPoints(Position) > 0);
  ActivePartyPosition := Position;
  if Position > 5 then
    ttt := Speed;
  Render;
end;

function TSceneBattle2.GetHitPoints(Position: Integer): Integer;
begin
  Result := 0;
  if Position < 0 then
    Exit;
  case Position of
    0 .. 5:
      if LeaderParty.Creature[Position].Active then
        Result := LeaderParty.GetHitPoints(Position);
    6 .. 11:
      if EnemyParty.Creature[Position - 6].Active then
        Result := EnemyParty.GetHitPoints(Position - 6);
  end;
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
