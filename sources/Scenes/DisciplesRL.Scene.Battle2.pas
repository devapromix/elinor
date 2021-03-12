unit DisciplesRL.Scene.Battle2;

interface

uses
  {$IFDEF FPC}
  Controls,
  {$ELSE}
  Vcl.Controls,
  {$ENDIF}
  Classes,
  DisciplesRL.Scenes,
  DisciplesRL.Party;

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
    procedure Damage(AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
    procedure Defeat;
    procedure FinishBattle;
    procedure Heal(AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
    procedure NextTurn;
    procedure StartBattle;
    procedure Victory;
    procedure StartRound;
    function GetHitPoints(Position: Integer): Integer;
    procedure AI;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure Click; override;
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
  DisciplesRL.Scene.Map,
  DisciplesRL.Saga,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Creatures,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Button,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire;

var
  Button: TButton;

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
    Surface.Canvas.TextOut(FLeft, FTop + Y, Get(I));
    Inc(Y, 16);
  end;
end;
{$ENDREGION RLLog}
{ TSceneBattle2 }

procedure TSceneBattle2.AI;
begin
  NextTurn;
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
            Log.Add(Format('%s получил опыт +%d', [Name, CharExp]));
          end;
    end;
    for Position := Low(TPosition) to High(TPosition) do
      with LeaderParty.Creature[Position] do
        if Active and (HitPoints > 0) then
          if Experience >= LeaderParty.GetMaxExperiencePerLevel(Level) then
          begin
            LeaderParty.UpdateLevel(Position);
            Log.Add(Format('%s повысил уровень до %d!', [Name, Level + 1]));
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
    TSceneHire.Show(stStoneTab, scHire);
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

procedure TSceneBattle2.FinishBattle;
begin
  Enabled := True;
  Log.Clear;
  MediaPlayer.Stop;
  if LeaderParty.IsClear then
    Defeat;
  if EnemyParty.IsClear then
    Victory;
end;

procedure TSceneBattle2.Damage(AtkParty, DefParty: TParty;
  AtkPos, DefPos: TPosition);
var
  Position: TPosition;
  F, B: Boolean;
begin
  if AtkParty.Creature[AtkPos].Active and DefParty.Creature[DefPos].Active then
    if (AtkParty.Creature[AtkPos].HitPoints > 0) and
      (DefParty.Creature[DefPos].HitPoints > 0) and
      (AtkParty.Creature[AtkPos].Damage > 0) then
    begin
      B := False;
      case AtkParty.Creature[AtkPos].ReachEnum of
        reAny:
          begin
            MediaPlayer.Play(TCreature.Character(AtkParty.Creature[AtkPos].Enum)
              .Sound[csAttack]);
            Sleep(200);
            DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, DefPos);
            Log.Add('Damage');
            if (DefParty.Creature[DefPos].HitPoints > 0) then
              MediaPlayer.Play(TCreature.Character(DefParty.Creature[DefPos]
                .Enum).Sound[csHit])
            else
              MediaPlayer.Play(TCreature.Character(DefParty.Creature[DefPos]
                .Enum).Sound[csDeath]);
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
                    MediaPlayer.Play
                      (TCreature.Character(AtkParty.Creature[AtkPos].Enum)
                      .Sound[csAttack]);
                    Sleep(200);
                    DefParty.TakeDamage(AtkParty.Creature[AtkPos]
                      .Damage, DefPos);
                    Log.Add('Damage');
                    if (DefParty.Creature[DefPos].HitPoints > 0) then
                      MediaPlayer.Play
                        (TCreature.Character(DefParty.Creature[DefPos].Enum)
                        .Sound[csHit])
                    else
                      MediaPlayer.Play
                        (TCreature.Character(DefParty.Creature[DefPos].Enum)
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
                      MediaPlayer.Play
                        (TCreature.Character(AtkParty.Creature[AtkPos].Enum)
                        .Sound[csAttack]);
                      Sleep(200);
                      DefParty.TakeDamage
                        (AtkParty.Creature[AtkPos].Damage, DefPos);
                      Log.Add('Damage');
                      if (DefParty.Creature[DefPos].HitPoints > 0) then
                        MediaPlayer.Play
                          (TCreature.Character(DefParty.Creature[DefPos].Enum)
                          .Sound[csHit])
                      else
                        MediaPlayer.Play
                          (TCreature.Character(DefParty.Creature[DefPos].Enum)
                          .Sound[csDeath]);
                      B := True;
                    end;
                  end;
              end;
          end;
        reAll:
          begin
            MediaPlayer.Play(TCreature.Character(AtkParty.Creature[AtkPos].Enum)
              .Sound[csAttack]);
            Sleep(200);
            for Position := Low(TPosition) to High(TPosition) do
              if DefParty.Creature[Position].Active and
                (DefParty.Creature[Position].HitPoints > 0) then
              begin
                DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, Position);
                Log.Add('Damage');
                if (DefParty.Creature[Position].HitPoints > 0) then
                  MediaPlayer.Play
                    (TCreature.Character(DefParty.Creature[Position].Enum)
                    .Sound[csHit])
                else
                  MediaPlayer.Play
                    (TCreature.Character(DefParty.Creature[Position].Enum)
                    .Sound[csDeath]);
              end;
            B := True;
          end;
      end;
      if B then
      begin
        NextTurn;
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
  end;

end;

procedure TSceneBattle2.Heal(AtkParty, DefParty: TParty;
  AtkPos, DefPos: TPosition);
var
  Position: TPosition;
begin
  if AtkParty.Creature[AtkPos].Active and DefParty.Creature[DefPos].Active then
    if (AtkParty.Creature[AtkPos].HitPoints > 0) and
      (DefParty.Creature[DefPos].HitPoints > 0) and
      (AtkParty.Creature[AtkPos].Heal > 0) then
    begin
      case AtkParty.Creature[AtkPos].ReachEnum of
        reAll:
          begin
            for Position := Low(TPosition) to High(TPosition) do
              with DefParty.Creature[Position] do
                if Active and (HitPoints > 0) and (HitPoints < MaxHitPoints)
                then
                begin
                  DefParty.Heal(Position, AtkParty.Creature[AtkPos].Heal);
                  Log.Add('Heal');
                end;
          end
      else
        with DefParty.Creature[DefPos] do
          if Active and (HitPoints > 0) and (HitPoints < MaxHitPoints) then
          begin
            DefParty.Heal(DefPos, AtkParty.Creature[AtkPos].Heal);
            Log.Add('Heal');
          end;
      end;
      NextTurn;
    end;
end;

procedure TSceneBattle2.ClickOnPosition;
begin
  case CurrentPartyPosition of
    0 .. 5:
      case ActivePartyPosition of
        0 .. 5:
          Heal(LeaderParty, LeaderParty, ActivePartyPosition,
            CurrentPartyPosition);
        6 .. 11:
          Damage(EnemyParty, LeaderParty, ActivePartyPosition - 6,
            CurrentPartyPosition);
      end;
    6 .. 11:
      case ActivePartyPosition of
        0 .. 5:
          Damage(LeaderParty, EnemyParty, ActivePartyPosition,
            CurrentPartyPosition - 6);
        6 .. 11:
          Heal(EnemyParty, EnemyParty, ActivePartyPosition - 6,
            CurrentPartyPosition - 6);
      end;
  end;
end;

procedure TSceneBattle2.Click;
begin
  inherited;
  if not Enabled then
    Exit;
  if Button.MouseDown then
    FinishBattle;
end;

constructor TSceneBattle2.Create;
begin
  Button := TButton.Create(Surface.Width - (ResImage[reButtonDef].Width + Left),
    DefaultButtonTop, reTextClose);
  Button.Sellected := True;
  Log := TLog.Create(Left, DefaultButtonTop - 20);
  InitiativeList := TStringList.Create;
end;

destructor TSceneBattle2.Destroy;
begin
  FreeAndNil(InitiativeList);
  FreeAndNil(Button);
  FreeAndNil(Log);
  inherited;
end;

procedure TSceneBattle2.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if not Enabled then
    Exit;
  CurrentPartyPosition := GetPartyPosition(X, Y);
  if CurrentPartyPosition < 0 then
    Exit;
  if LeaderParty.IsClear or EnemyParty.IsClear then
    Exit;
  case Button of
    mbLeft:
      begin
        ClickOnPosition;
        Scenes.Render;
      end;
  end;
end;

procedure TSceneBattle2.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if not Enabled then
    Exit;
  Button.MouseMove(X, Y);
  Scenes.Render;
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
    Button.Render;
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
  S: string;
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
  InitiativeList.Sort;
end;

procedure TSceneBattle2.NextTurn;
var
  Position: Integer;
  S: string;
  A: array of string;
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
