unit DisciplesRL.Scene.Battle2;

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  DisciplesRL.Creatures,
  DisciplesRL.Scenes,
  DisciplesRL.Party,
  DisciplesRL.Battle;

type
  TTurnType = (ttHeal, ttDamage, ttFear);

type
  TSceneBattle2 = class(TScene)
  private
    InitiativeList: TStringList;
    CurrentPosition: Integer;
    ttt: Integer;
    EnemyParty: TParty;
    LeaderParty: TParty;
    FEnabled: Boolean;
    Battle: TBattle;
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
  public
    class var
    IsDuel: Boolean;
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
  end;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.Resources,
  DisciplesRL.Button,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire;

var
  CloseButton: TButton;
  DuelEnemyParty: TParty;

const
  Speed = 12;

{ TSceneBattle2 }

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
    for Position := 0 to 5 do
      if LeaderParty.Creature[Position].Alive then
      begin
        if (LeaderParty.Creature[Position].HitPoints < MinHitPoints) then
        begin
          MinHitPoints := LeaderParty.Creature[Position].HitPoints;
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
    Result := (LeaderParty.Creature[1].HitPoints > 0) or
      (LeaderParty.Creature[3].HitPoints > 0) or
      (LeaderParty.Creature[5].HitPoints > 0);
  end;

  procedure AtkAdj;
  var
    Position: TPosition;
  begin
    begin
      if HasWarriors then
      begin
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
  Position: TPosition;
  CharExp: Integer;
begin
  if (EnemyParty.GetExperience > 0) then
  begin
    if LeaderParty.GetAliveCreatures > 0 then
    begin
      CharExp := EnsureRange(EnemyParty.GetExperience div LeaderParty.
        GetAliveCreatures, 1, 9999);
      for Position := Low(TPosition) to High(TPosition) do
        with LeaderParty.Creature[Position] do
          if Alive then
          begin
            LeaderParty.UpdateXP(CharExp, Position);
            Battle.Log.Add(Format('%s получил%s опыт +%d', [Name[0], GenderEnding,
              CharExp]));
          end;
    end;
    for Position := Low(TPosition) to High(TPosition) do
      with LeaderParty.Creature[Position] do
        if Alive then
          if Experience >= LeaderParty.GetMaxExperiencePerLevel(Level) then
          begin
            LeaderParty.UpdateLevel(Position);
            Battle.Log.Add(Format('%s повысил%s уровень до %d!',
              [Name[0], GenderEnding, Level + 1]));
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
  Party[TSaga.GetPartyIndex(TLeaderParty.Leader.X,
    TLeaderParty.Leader.Y)].Clear;
  if (Game.Scenario.CurrentScenario = sgAncientKnowledge) and
    Game.Scenario.IsStoneTab(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) then
  begin
    Inc(Game.Scenario.StoneTab);
    TSceneHire.Show(stStoneTab, scHire, reGold);
  end
  else
    TSaga.AddLoot(reBag);
end;

procedure TSceneBattle2.Defeat;
begin
  TSceneHire.Show(stDefeat);
end;

procedure TSceneBattle2.StartBattle;
var
  I: Integer;
  Position: TPosition;
begin
  Battle.Clear;
  Enabled := True;
  I := TSaga.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  if IsDuel then
  begin
    DuelEnemyParty.Clear;
    Position := Party[I].GetRandomPosition;
    DuelEnemyParty.AddCreature(Party[I].Creature[Position].Enum, Position);
    EnemyParty := DuelEnemyParty;
    LeaderParty := Party[TLeaderParty.LeaderPartyIndex];
  end
  else
  begin
    EnemyParty := Party[I];
    LeaderParty := Party[TLeaderParty.LeaderPartyIndex];
  end;
  ActivePartyPosition := Party[TLeaderParty.LeaderPartyIndex].GetRandomPosition;
  CurrentPartyPosition := ActivePartyPosition;
  // SelectPartyPosition := ActivePartyPosition;
  Game.MediaPlayer.Play(mmWar);
  StartRound;
end;

procedure TSceneBattle2.FinishBattle;
begin
  Battle.Clear;
  Game.MediaPlayer.Stop;
  if LeaderParty.IsClear then
    Defeat;
  if EnemyParty.IsClear then
    Victory;
end;

procedure TSceneBattle2.Turn(const TurnType: TTurnType;
  AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
begin
  if AtkParty.Creature[AtkPos].Alive and DefParty.Creature[DefPos].Alive then
  begin
    begin
      if AtkParty.Creature[AtkPos].ChancesToHit < RandomRange(0, 100) + 1 then
      begin
        Battle.Miss(AtkParty.Creature[AtkPos].Name[0],
          DefParty.Creature[DefPos].Name[1]);
        Game.MediaPlayer.Play(mmMiss);
        Sleep(200);
        NextTurn;
        Exit;
      end;
      if AtkParty.Creature[AtkPos].Paralyze then
      begin
        Battle.Log.Add('Паралич прошел.');
        AtkParty.ClearParalyze(AtkPos);
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
    ChExperience;
    Game.MediaPlayer.Play(mmWin);
  end;
  if LeaderParty.IsClear then
  begin
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
begin
  AtkCrEnum := AtkParty.Creature[AtkPos].Enum;
  DefCrEnum := DefParty.Creature[DefPos].Enum;
  case TCreature.Character(AtkCrEnum).AttackEnum of
    atParalyze:
      begin
        Game.MediaPlayer.Play(TCreature.Character(AtkCrEnum).Sound[csAttack]);
        Sleep(200);
        Paralyze(AtkParty, DefParty, AtkPos, DefPos);
        Exit;
      end;
  end;
  if (AtkParty.Creature[AtkPos].Damage > 0) then
  begin
    B := False;
    case AtkParty.Creature[AtkPos].ReachEnum of
      reAny:
        begin
          Game.MediaPlayer.Play(TCreature.Character(AtkCrEnum).Sound[csAttack]);
          Sleep(200);
          DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, DefPos);
          Battle.Log.Add(Format(Battle.GetLogMessage(TCreature.Character(AtkCrEnum)
            .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
            [AtkParty.Creature[AtkPos].Name[0],
            DefParty.Creature[DefPos].Name[1],
            AtkParty.Creature[AtkPos].Damage]));
          if (DefParty.Creature[DefPos].HitPoints > 0) then
            Game.MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csHit])
          else
            Game.MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csDeath]);
          B := True;
        end;
      reAdj:
        begin
          F := False;
          case AtkPos of
            1, 3, 5:
              F := (AtkParty.Creature[0].HitPoints > 0) or
                (AtkParty.Creature[2].HitPoints > 0) or
                (AtkParty.Creature[4].HitPoints > 0);
          end;
          if not F then
            case DefPos of
              0, 2, 4:
                begin
                  if (AtkPos = 0) and (DefPos = 4) and
                    ((DefParty.Creature[0].HitPoints > 0) or
                    (DefParty.Creature[2].HitPoints > 0)) then
                    Exit;
                  if (AtkPos = 4) and (DefPos = 0) and
                    ((DefParty.Creature[2].HitPoints > 0) or
                    (DefParty.Creature[4].HitPoints > 0)) then
                    Exit;
                  Game.MediaPlayer.Play(TCreature.Character(AtkCrEnum)
                    .Sound[csAttack]);
                  Sleep(200);
                  DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, DefPos);
                  Battle.Log.Add(Format(Battle.GetLogMessage(TCreature.Character(AtkCrEnum)
                    .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
                    [AtkParty.Creature[AtkPos].Name[0],
                    DefParty.Creature[DefPos].Name[1],
                    AtkParty.Creature[AtkPos].Damage]));
                  if (DefParty.Creature[DefPos].HitPoints > 0) then
                    Game.MediaPlayer.Play(TCreature.Character(DefCrEnum)
                      .Sound[csHit])
                  else
                    Game.MediaPlayer.Play(TCreature.Character(DefCrEnum)
                      .Sound[csDeath]);
                  B := True;
                end;
              1, 3, 5:
                begin
                  F := (DefParty.Creature[0].HitPoints > 0) or
                    (DefParty.Creature[2].HitPoints > 0) or
                    (DefParty.Creature[4].HitPoints > 0);
                  if not F then
                  begin
                    Game.MediaPlayer.Play(TCreature.Character(AtkCrEnum)
                      .Sound[csAttack]);
                    Sleep(200);
                    DefParty.TakeDamage(AtkParty.Creature[AtkPos]
                      .Damage, DefPos);
                    Battle.Log.Add(Format(Battle.GetLogMessage(TCreature.Character(AtkCrEnum)
                      .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
                      [AtkParty.Creature[AtkPos].Name[0],
                      DefParty.Creature[DefPos].Name[1],
                      AtkParty.Creature[AtkPos].Damage]));
                    if (DefParty.Creature[DefPos].HitPoints > 0) then
                      Game.MediaPlayer.Play(TCreature.Character(DefCrEnum)
                        .Sound[csHit])
                    else
                      Game.MediaPlayer.Play(TCreature.Character(DefCrEnum)
                        .Sound[csDeath]);
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
            Battle.Log.Add(Format(Battle.StartCastSpell,[
              TCreature.Character(AtkCrEnum).Name[0],
              SourceName[TCreature.Character(AtkCrEnum).SourceEnum]]));
          end;
          Game.MediaPlayer.Play(TCreature.Character(AtkCrEnum).Sound[csAttack]);
          Sleep(200);
          for Position := Low(TPosition) to High(TPosition) do
            if DefParty.Creature[Position].Alive then
            begin
              DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, Position);
              Battle.Log.Add(Format(Battle.GetLogMessage(TCreature.Character(AtkCrEnum)
                .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
                [AtkParty.Creature[AtkPos].Name[0],
                DefParty.Creature[Position].Name[1],
                AtkParty.Creature[AtkPos].Damage]));
              if (DefParty.Creature[Position].HitPoints > 0) then
                Game.MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csHit])
              else
                Game.MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csDeath]);
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
              if Alive and (HitPoints < MaxHitPoints) then
              begin
                Party.Heal(Position, Party.Creature[AtkPos].Heal);
                Battle.Log.Add(Format('%s исцеляет %s.',
                  [Party.Creature[AtkPos].Name[0],
                  Party.Creature[Position].Name[1]]));
              end;
        end
    else
      with Party.Creature[DefPos] do
        if Alive and (HitPoints < MaxHitPoints) then
        begin
          Party.Heal(DefPos, Party.Creature[AtkPos].Heal);
          Battle.Log.Add(Format('%s исцеляет %s.', [Party.Creature[AtkPos].Name[0],
            Party.Creature[DefPos].Name[1]]));
        end;
    end;
    NextTurn;
  end;
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
              Battle.Log.Add(Format('%s парализует %s.',
                [AtkParty.Creature[AtkPos].Name[0],
                DefParty.Creature[Position].Name[1]]));
            end;
      end
  else
    with DefParty.Creature[DefPos] do
      if Alive then
      begin
        DefParty.Paralyze(DefPos);
        Battle.Log.Add(Format('%s парализует %s.', [AtkParty.Creature[AtkPos].Name[0],
          DefParty.Creature[DefPos].Name[1]]));
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
  inherited;
  CloseButton := TButton.Create(1100 - (ResImage[reButtonDef].Width +
    Left), DefaultButtonTop, reTextClose);
  CloseButton.Sellected := True;
  InitiativeList := TStringList.Create;
  DuelEnemyParty := TParty.Create;
  Battle := TBattle.Create;
end;

destructor TSceneBattle2.Destroy;
begin
  FreeAndNil(Battle);
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
  A: {$IFDEF FPC}specialize{$ENDIF}TArray<string>;
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
  StartBattle;
  Game.MediaPlayer.PlayMusic(mmBattle);
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
    K_SPACE:
      if Game.Wizard then
        NextTurn;
    K_N:
      if Game.Wizard then
        NextTurn;
    K_H:
      if Game.Wizard then
        TLeaderParty.Leader.HealAll(100);
    K_D:
      if Game.Wizard then
        Defeat;
    K_V:
      if Game.Wizard then
        Victory;
  end;
end;

end.
