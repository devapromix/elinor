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
  DisciplesRL.Party;

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
    function GetLogMessage(AttackEnum: TAttackEnum;
      SourceEnum: TSourceEnum): string;
    procedure StartCastSpell(CrName: string; SourceEnum: TSourceEnum);
  public
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
  RLLog,
  Math,
  SysUtils,
  DisciplesRL.Saga,
  DisciplesRL.Resources,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Button,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire;

var
  CloseButton: TButton;

const
  Rows = 7;
  Speed = 12;

{$REGION RLLog}

type
  TLog = class(TRLLog)
  private
    FTop: Integer;
    FLeft: Integer;
  public
    constructor Create(const ALeft, ATop: Integer);
    procedure Render;
  end;

var
  Log: TLog;

  { TLog }

constructor TLog.Create(const ALeft, ATop: Integer);
begin
  inherited Create;
  FTop := ATop;
  FLeft := ALeft;
end;

procedure TLog.Render;
var
  I, Y, D: Integer;
begin
  if Count <= 0 then
    Exit;
  Y := 0;
  D := EnsureRange(Count - Rows, 0, Count - 1);
  for I := D to Count - 1 do
  begin
    DrawText(FLeft, FTop + Y, Get(I));
    Inc(Y, 16);
  end;
end;

{$ENDREGION RLLog}
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
      if LeaderParty.Creature[Position].Active and
        (LeaderParty.Creature[Position].HitPoints > 0) then
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
      if LeaderParty.Creature[Position].Active and
        (LeaderParty.Creature[Position].HitPoints > 0) then
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
          if LeaderParty.Creature[Position].Active and
            (LeaderParty.Creature[Position].HitPoints > 0) then
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
          if Active and (HitPoints > 0) then
          begin
            LeaderParty.UpdateXP(CharExp, Position);
            Log.Add(Format('%s получил%s опыт +%d', [Name[0], GenderEnding,
              CharExp]));
          end;
    end;
    for Position := Low(TPosition) to High(TPosition) do
      with LeaderParty.Creature[Position] do
        if Active and (HitPoints > 0) then
          if Experience >= LeaderParty.GetMaxExperiencePerLevel(Level) then
          begin
            LeaderParty.UpdateLevel(Position);
            Log.Add(Format('%s повысил%s уровень до %d!',
              [Name[0], GenderEnding, Level + 1]));
          end;
  end;
end;

procedure TSceneBattle2.Victory;
begin
  MediaPlayer.PlayMusic(mmMap);
  Party[TSaga.GetPartyIndex(TLeaderParty.Leader.X,
    TLeaderParty.Leader.Y)].Clear;
  if (TScenario.CurrentScenario = sgAncientKnowledge) and
    TScenario.IsStoneTab(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) then
  begin
    Inc(TScenario.StoneTab);
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
begin
  Log.Clear;
  Enabled := True;
  I := TSaga.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  EnemyParty := Party[I];
  LeaderParty := Party[TLeaderParty.LeaderPartyIndex];
  ActivePartyPosition := Party[TLeaderParty.LeaderPartyIndex].GetRandomPosition;
  CurrentPartyPosition := ActivePartyPosition;
  // SelectPartyPosition := ActivePartyPosition;
  MediaPlayer.Play(mmWar);
  StartRound;
end;

procedure TSceneBattle2.StartCastSpell(CrName: string; SourceEnum: TSourceEnum);
begin
  case RandomRange(0, 2) of
    0:
      Log.Add(Format('%s готовит заклинание. Его источник: %s.',
        [CrName, SourceName[SourceEnum]]));
    1:
      Log.Add(Format('%s начинает колдовать. Источник магии: %s.',
        [CrName, SourceName[SourceEnum]]));
  end;
end;

procedure TSceneBattle2.FinishBattle;
begin
  Log.Clear;
  MediaPlayer.Stop;
  if LeaderParty.IsClear then
    Defeat;
  if EnemyParty.IsClear then
    Victory;
end;

procedure TSceneBattle2.Turn(const TurnType: TTurnType;
  AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
begin
  if AtkParty.Creature[AtkPos].Active and DefParty.Creature[DefPos].Active then
  begin
    if (AtkParty.Creature[AtkPos].HitPoints > 0) and
      (DefParty.Creature[DefPos].HitPoints > 0) then
    begin
      if AtkParty.Creature[AtkPos].ChancesToHit < RandomRange(0, 100) + 1 then
      begin
        case RandomRange(0, 6) of
          0:
            Log.Add(Format('%s пытается атаковать, но внезапно промахивается.',
              [AtkParty.Creature[AtkPos].Name[0]]));
          1:
            Log.Add(Format('%s атакует мимо цели.',
              [AtkParty.Creature[AtkPos].Name[0]]));
          2:
            Log.Add(Format('%s атакует... пустоту.',
              [AtkParty.Creature[AtkPos].Name[0]]));
          3:
            Log.Add(Format('%s тщетно пытается атаковать.',
              [AtkParty.Creature[AtkPos].Name[0]]));
          4:
            Log.Add(Format('%s атакует %s, но промахивается.',
              [AtkParty.Creature[AtkPos].Name[0],
              DefParty.Creature[DefPos].Name[1]]));
        else
          Log.Add(Format('%s промахивается.',
            [AtkParty.Creature[AtkPos].Name[0]]));
        end;
        MediaPlayer.Play(mmMiss);
        Sleep(200);
        NextTurn;
        Exit;
      end;
      if AtkParty.Creature[AtkPos].Paralyze then
      begin
        Log.Add('Паралич прошел.');
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
    MediaPlayer.Play(mmWin);
  end;
  if LeaderParty.IsClear then
  begin
    MediaPlayer.PlayMusic(mmDefeat);
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
        MediaPlayer.Play(TCreature.Character(AtkCrEnum).Sound[csAttack]);
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
          MediaPlayer.Play(TCreature.Character(AtkCrEnum).Sound[csAttack]);
          Sleep(200);
          DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, DefPos);
          Log.Add(Format(GetLogMessage(TCreature.Character(AtkCrEnum)
            .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
            [AtkParty.Creature[AtkPos].Name[0],
            DefParty.Creature[DefPos].Name[1],
            AtkParty.Creature[AtkPos].Damage]));
          if (DefParty.Creature[DefPos].HitPoints > 0) then
            MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csHit])
          else
            MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csDeath]);
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
                  MediaPlayer.Play(TCreature.Character(AtkCrEnum)
                    .Sound[csAttack]);
                  Sleep(200);
                  DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, DefPos);
                  Log.Add(Format(GetLogMessage(TCreature.Character(AtkCrEnum)
                    .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
                    [AtkParty.Creature[AtkPos].Name[0],
                    DefParty.Creature[DefPos].Name[1],
                    AtkParty.Creature[AtkPos].Damage]));
                  if (DefParty.Creature[DefPos].HitPoints > 0) then
                    MediaPlayer.Play(TCreature.Character(DefCrEnum)
                      .Sound[csHit])
                  else
                    MediaPlayer.Play(TCreature.Character(DefCrEnum)
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
                    MediaPlayer.Play(TCreature.Character(AtkCrEnum)
                      .Sound[csAttack]);
                    Sleep(200);
                    DefParty.TakeDamage(AtkParty.Creature[AtkPos]
                      .Damage, DefPos);
                    Log.Add(Format(GetLogMessage(TCreature.Character(AtkCrEnum)
                      .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
                      [AtkParty.Creature[AtkPos].Name[0],
                      DefParty.Creature[DefPos].Name[1],
                      AtkParty.Creature[AtkPos].Damage]));
                    if (DefParty.Creature[DefPos].HitPoints > 0) then
                      MediaPlayer.Play(TCreature.Character(DefCrEnum)
                        .Sound[csHit])
                    else
                      MediaPlayer.Play(TCreature.Character(DefCrEnum)
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
            StartCastSpell(TCreature.Character(AtkCrEnum).Name[0],
              TCreature.Character(AtkCrEnum).SourceEnum);
          end;
          MediaPlayer.Play(TCreature.Character(AtkCrEnum).Sound[csAttack]);
          Sleep(200);
          for Position := Low(TPosition) to High(TPosition) do
            if DefParty.Creature[Position].Active and
              (DefParty.Creature[Position].HitPoints > 0) then
            begin
              DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, Position);
              Log.Add(Format(GetLogMessage(TCreature.Character(AtkCrEnum)
                .AttackEnum, TCreature.Character(AtkCrEnum).SourceEnum),
                [AtkParty.Creature[AtkPos].Name[0],
                DefParty.Creature[Position].Name[1],
                AtkParty.Creature[AtkPos].Damage]));
              if (DefParty.Creature[Position].HitPoints > 0) then
                MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csHit])
              else
                MediaPlayer.Play(TCreature.Character(DefCrEnum).Sound[csDeath]);
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
              if Active and (HitPoints > 0) and (HitPoints < MaxHitPoints) then
              begin
                Party.Heal(Position, Party.Creature[AtkPos].Heal);
                Log.Add(Format('%s исцеляет %s.',
                  [Party.Creature[AtkPos].Name[0],
                  Party.Creature[Position].Name[1]]));
              end;
        end
    else
      with Party.Creature[DefPos] do
        if Active and (HitPoints > 0) and (HitPoints < MaxHitPoints) then
        begin
          Party.Heal(DefPos, Party.Creature[AtkPos].Heal);
          Log.Add(Format('%s исцеляет %s.', [Party.Creature[AtkPos].Name[0],
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
            if Active and (HitPoints > 0) then
            begin
              DefParty.Paralyze(Position);
              Log.Add(Format('%s парализует %s.',
                [AtkParty.Creature[AtkPos].Name[0],
                DefParty.Creature[Position].Name[1]]));
            end;
      end
  else
    with DefParty.Creature[DefPos] do
      if Active and (HitPoints > 0) then
      begin
        DefParty.Paralyze(DefPos);
        Log.Add(Format('%s парализует %s.', [AtkParty.Creature[AtkPos].Name[0],
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
  CloseButton := TButton.Create(Surface.Width - (ResImage[reButtonDef].Width +
    Left), DefaultButtonTop, reTextClose);
  CloseButton.Sellected := True;
  Log := TLog.Create(Left, DefaultButtonTop - 20);
  InitiativeList := TStringList.Create;
end;

destructor TSceneBattle2.Destroy;
begin
  FreeAndNil(InitiativeList);
  FreeAndNil(CloseButton);
  FreeAndNil(Log);
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
    Scenes.Render;
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
  Log.Render;
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
        if LeaderParty.Creature[I].Active and (LeaderParty.GetHitPoints(I) > 0)
        then
          InitiativeList[I] :=
            Format('%d:%d', [LeaderParty.GetInitiative(I), I]);
    else
      begin
        if EnemyParty.Creature[I - 6].Active and
          (EnemyParty.GetHitPoints(I - 6) > 0) then
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
  A:
{$IFDEF FPC} array of string{$ELSE}TArray<string>{$ENDIF};
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

function TSceneBattle2.GetLogMessage(AttackEnum: TAttackEnum;
  SourceEnum: TSourceEnum): string;
begin
  case AttackEnum of
    atLongSword:
      Result := '%s атакует мечом %s и наносит %d урона.';
    atBattleAxe:
      Result := '%s атакует боевым топором %s и наносит %d урона.';
    atDagger:
      Result := '%s атакует кинжалом %s и наносит %d урона.';
    atDaggerOfShadows:
      Result := '%s атакует Кинжалом Теней %s и наносит %d урона.';
    atBow:
      Result := 'Метким выстрелом %s поражает стрелой %s и наносит %d урона.';
    atClub:
      Result := '%s атакует булавой %s и наносит %d урона.';
    atCrossbow:
      Result := 'Молниеносно %s взводит арбалет и поражает %s, нанося %d урона.';
    atStones:
      Result := 'Метким броском %s поражает камнем %s и наносит %d урона.';
    atPoisonousBreath:
      Result := '%s атакует ядовитым дыханием %s и наносит %d урона.';
    atDrainLife:
      case RandomRange(0, 4) of
        0:
          Result := '%s пьет жизнь у %s и наносит %d урона.';
        1:
          Result := '%s забирает жизнь у %s и наносит %d урона.';
        2:
          Result := '%s выпивает жизнь у %s и наносит %d урона.';
      else
        Result := '%s высасывает жизнь у %s и наносит %d урона.';
      end;
    atHealing:
      ;
    atPoison:
      ;
    atMagic:
      case SourceEnum of
        seFire:
          Result := '%s атакует огнем %s и наносит %d урона.';
        seAir:
          Result := '%s атакует молниями %s и наносит %d урона.';
        seEarth:
          Result := '%s атакует магией земли %s и наносит %d урона.';
        seWater:
          Result := '%s атакует водной магией %s и наносит %d урона.';
      else
        Result := '%s атакует магией %s и наносит %d урона.';
      end;
    atClaws:
      Result := '%s разрывает когтями %s и наносит %d урона.';
    atBites:
      Result := '%s кусает %s и наносит %d урона.';
  else
    Result := '%s атакует %s и наносит %d урона.';
  end;
end;

procedure TSceneBattle2.Show(const S: TSceneEnum);
begin
  inherited;
  StartBattle;
  MediaPlayer.PlayMusic(mmBattle);
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
      Scenes.Render;
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
      if TSaga.Wizard then
        NextTurn;
    K_N:
      if TSaga.Wizard then
        NextTurn;
    K_D:
      if TSaga.Wizard then
        Defeat;
    K_V:
      if TSaga.Wizard then
        Victory;
  end;
end;

end.
