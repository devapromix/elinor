unit DisciplesRL.Scene.Battle2;

interface

uses
  System.Classes,
  DisciplesRL.Scenes,
  DisciplesRL.Party,
  Vcl.Controls;

type
  TSceneBattle2 = class(TScene)
  private
    procedure ClickOnPosition;
    procedure ChExperience;
    procedure Damage(AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
    procedure Defeat;
    procedure Finish;
    procedure Heal(AtkParty, DefParty: TParty; AtkPos, DefPos: TPosition);
    procedure NextTurn;
    procedure Start;
    procedure Victory;
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
  end;

implementation

uses
  RLLog,
  System.Math,
  System.SysUtils,
  DisciplesRL.Scene.Map,
  DisciplesRL.Saga,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Creatures,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Button,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Hire;

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

var
  Button: TButton;
  EnemyParty: TParty = nil;
  PartyExperience: Integer = 0;

const
  Rows = 7;

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

{ TSceneBattle2 }

procedure TSceneBattle2.ChExperience;
var
  P: TPosition;
  ChCnt, ChExp: Integer;
begin
  for P := Low(TPosition) to High(TPosition) do
    with EnemyParty.Creature[P] do
      if Active then
        Inc(PartyExperience, MaxHitPoints);
  if PartyExperience > 0 then
  begin
    ChCnt := 0;
    for P := Low(TPosition) to High(TPosition) do
      with Party[TLeaderParty.LeaderPartyIndex].Creature[P] do
        if Active and (HitPoints > 0) then
        begin
          Inc(ChCnt);
        end;
    if ChCnt > 0 then
    begin
      ChExp := EnsureRange(PartyExperience div ChCnt, 1, 9999);
      for P := Low(TPosition) to High(TPosition) do
        with Party[TLeaderParty.LeaderPartyIndex].Creature[P] do
          if Active and (HitPoints > 0) then
          begin
            Party[TLeaderParty.LeaderPartyIndex].UpdateXP(ChExp, P);
            Log.Add(Format('%s получил опыт +%d', [Name, ChExp]));
          end;
    end;
    for P := Low(TPosition) to High(TPosition) do
      with Party[TLeaderParty.LeaderPartyIndex].Creature[P] do
        if Active and (HitPoints > 0) then
          if Experience >= Party[TLeaderParty.LeaderPartyIndex].GetMaxExperience
            (Level) then
          begin
            Party[TLeaderParty.LeaderPartyIndex].UpdateLevel(P);
            Log.Add(Format('%s повысил уровень до %d!', [Name, Level + 1]));
          end;
    PartyExperience := 0;
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

procedure TSceneBattle2.Start;
var
  I: Integer;
begin
  Log.Clear;
  PartyExperience := 0;
  I := TSaga.GetPartyIndex(TLeaderParty.Leader.X, TLeaderParty.Leader.Y);
  EnemyParty := Party[I];
  ActivePartyPosition := Party[TLeaderParty.LeaderPartyIndex].GetRandomPosition;
  CurrentPartyPosition := ActivePartyPosition;
  MediaPlayer.Play(mmWar);
end;

procedure TSceneBattle2.Finish;
begin
  Log.Clear;
  MediaPlayer.Stop;
  if Party[TLeaderParty.LeaderPartyIndex].IsClear then
    Defeat;
  if EnemyParty.IsClear then
    Victory;
end;

procedure TSceneBattle2.NextTurn;
begin
  ActivePartyPosition := Party[TLeaderParty.LeaderPartyIndex].GetRandomPosition;
end;

procedure TSceneBattle2.Damage(AtkParty, DefParty: TParty;
  AtkPos, DefPos: TPosition);
var
  P: TPosition;
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
            for P := Low(TPosition) to High(TPosition) do
              if DefParty.Creature[P].Active and
                (DefParty.Creature[P].HitPoints > 0) then
              begin
                DefParty.TakeDamage(AtkParty.Creature[AtkPos].Damage, P);
                Log.Add('Damage');
                if (DefParty.Creature[P].HitPoints > 0) then
                  MediaPlayer.Play
                    (TCreature.Character(DefParty.Creature[P].Enum)
                    .Sound[csHit])
                else
                  MediaPlayer.Play
                    (TCreature.Character(DefParty.Creature[P].Enum)
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
  if Party[TLeaderParty.LeaderPartyIndex].IsClear then
  begin
    MediaPlayer.PlayMusic(mmDefeat);
  end;

end;

procedure TSceneBattle2.Heal(AtkParty, DefParty: TParty;
  AtkPos, DefPos: TPosition);
var
  P: TPosition;
begin
  if AtkParty.Creature[AtkPos].Active and DefParty.Creature[DefPos].Active then
    if (AtkParty.Creature[AtkPos].HitPoints > 0) and
      (DefParty.Creature[DefPos].HitPoints > 0) and
      (AtkParty.Creature[AtkPos].Heal > 0) then
    begin
      case AtkParty.Creature[AtkPos].ReachEnum of
        reAll:
          begin
            for P := Low(TPosition) to High(TPosition) do
              with DefParty.Creature[P] do
                if Active and (HitPoints > 0) and (HitPoints < MaxHitPoints)
                then
                begin
                  DefParty.Heal(P, AtkParty.Creature[AtkPos].Heal);
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
          Heal(Party[TLeaderParty.LeaderPartyIndex],
            Party[TLeaderParty.LeaderPartyIndex], ActivePartyPosition,
            CurrentPartyPosition);
        6 .. 11:
          Damage(EnemyParty, Party[TLeaderParty.LeaderPartyIndex],
            ActivePartyPosition - 6, CurrentPartyPosition);
      end;
    6 .. 11:
      case ActivePartyPosition of
        0 .. 5:
          Damage(Party[TLeaderParty.LeaderPartyIndex], EnemyParty,
            ActivePartyPosition, CurrentPartyPosition - 6);
        6 .. 11:
          Heal(EnemyParty, EnemyParty, ActivePartyPosition - 6,
            CurrentPartyPosition - 6);
      end;
  end;
end;

procedure TSceneBattle2.Click;
begin
  inherited;
  if Button.MouseDown then
    Finish;
end;

constructor TSceneBattle2.Create;
begin
  Button := TButton.Create(Surface.Width - (ResImage[reButtonDef].Width + Left),
    DefaultButtonTop, reTextClose);
  Button.Sellected := True;
  Log := TLog.Create(Left, DefaultButtonTop - 20);
end;

destructor TSceneBattle2.Destroy;
begin
  FreeAndNil(Button);
  FreeAndNil(Log);
  inherited;
end;

procedure TSceneBattle2.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  CurrentPartyPosition := GetPartyPosition(X, Y);
  if CurrentPartyPosition < 0 then
    Exit;
  if Party[TLeaderParty.LeaderPartyIndex].IsClear or EnemyParty.IsClear then
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
  Button.MouseMove(X, Y);
  Render;
end;

procedure TSceneBattle2.Render;
var
  F: Boolean;
begin
  inherited;
  TSceneParty.RenderParty(psLeft, Party[TLeaderParty.LeaderPartyIndex]);
  TSceneParty.RenderParty(psRight, EnemyParty, False, False);
  F := False;
  if Party[TLeaderParty.LeaderPartyIndex].IsClear then
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

procedure TSceneBattle2.Show(const S: TSceneEnum);
begin
  inherited;
  Start;
  MediaPlayer.PlayMusic(mmBattle);
end;

procedure TSceneBattle2.Timer;
begin
  inherited;

end;

procedure TSceneBattle2.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      Finish;
    K_SPACE:
      if TSaga.Wizard then
        NextTurn;
    K_C:
      if TSaga.Wizard then
      begin
        MediaPlayer.PlayMusic(mmDefeat);
        Party[TLeaderParty.LeaderPartyIndex].Clear;
      end;
    K_D:
      if TSaga.Wizard then
        Defeat;
    K_V:
      if TSaga.Wizard then
        Victory;
  end;
end;

end.
