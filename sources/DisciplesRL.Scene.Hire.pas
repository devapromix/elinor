unit DisciplesRL.Scene.Hire;

interface

uses
  Vcl.Controls,
  System.Classes,
  DisciplesRL.Party;

type
  THireSubSceneEnum = (stCharacter, stLeader, stRace, stScenario, stJournal,
    stVictory, stDefeat, stHighScores2);

procedure Init;
procedure Render;
procedure Timer;
procedure Show(const ASubScene: THireSubSceneEnum); overload;
procedure Show(const Party: TParty; const Position: Integer); overload;
procedure MouseClick(X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
function HireIndex: Integer;
procedure Free;

implementation

uses
  System.Math,
  System.SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Saga,
  DisciplesRL.Scenes,
  DisciplesRL.Creatures,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Scene.Map,
  DisciplesRL.Scene.Info;

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
    (reTextClose, reTextClose)

    );

const
  CloseButtonScene = [stJournal, stVictory, stDefeat, stHighScores2];

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;
  SubScene: THireSubSceneEnum = stCharacter;
  Button: array [THireSubSceneEnum] of array [TButtonEnum] of TButton;
  CurrentIndex: Integer = 0;
  Lf: Integer = 0;

procedure Show(const ASubScene: THireSubSceneEnum);
begin
  case ASubScene of
    stJournal:
      CurrentIndex := Ord(TScenario.CurrentScenario);
  else
    CurrentIndex := 0;
  end;
  SubScene := ASubScene;
  SetScene(scHire);
end;

procedure Show(const Party: TParty; const Position: Integer);
begin
  HireParty := Party;
  HirePosition := Position;
  Show(stCharacter);
end;

function HireIndex: Integer;
begin
  Result := CurrentIndex;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Back;
begin
  MediaPlayer.Play(mmClick);
  case SubScene of
    stCharacter:
      SetScene(scSettlement);
    stLeader:
      DisciplesRL.Scene.Hire.Show(stRace);
    stRace:
      DisciplesRL.Scene.Hire.Show(stScenario);
    stScenario:
      SetScene(scMenu);
    stJournal:
      SetScene(scMap);
    stDefeat:
      begin
        TSaga.IsGame := False;
        DisciplesRL.Scene.Hire.Show(stHighScores2);
      end;
    stVictory:
      begin
        TSaga.IsGame := False;
        DisciplesRL.Scene.Hire.Show(stHighScores2);
      end;
    stHighScores2:
      SetScene(scMenu);
  end;
end;

procedure Ok;
begin
  MediaPlayer.Play(mmClick);
  case SubScene of
    stRace:
      begin
        TSaga.LeaderRace := TRaceEnum(CurrentIndex + 1);
        DisciplesRL.Scene.Hire.Show(stLeader);
      end;
    stLeader:
      begin
        TSaga.Clear;
        Party[TLeaderParty.LeaderPartyIndex].Owner := TSaga.LeaderRace;
        SetSceneMusic(scSettlement);
        DisciplesRL.Scene.Settlement.Show(stCapital);
      end;
    stCharacter:
      begin
        if HireParty.Hire(Characters[Party[TLeaderParty.LeaderPartyIndex].Owner]
          [cgCharacters][TRaceCharKind(CurrentIndex)], HirePosition) then
          SetScene(scSettlement)
        else
          InformDialog('Не хватает денег!');
      end;
    stScenario:
      begin
        TScenario.CurrentScenario := TScenario.TScenarioEnum(CurrentIndex);
        DisciplesRL.Scene.Hire.Show(stRace);
      end;
    stJournal:
      SetScene(scMap);
    stDefeat:
      begin
        TSaga.IsGame := False;
        DisciplesRL.Scene.Hire.Show(stHighScores2);
      end;
    stVictory:
      begin
        TSaga.IsGame := False;
        DisciplesRL.Scene.Hire.Show(stHighScores2);
      end;
    stHighScores2:
      SetScene(scMenu);
  end;
end;

procedure Init;
var
  I: TButtonEnum;
  J: THireSubSceneEnum;
  L, W: Integer;
begin
  for J := Low(THireSubSceneEnum) to High(THireSubSceneEnum) do
  begin
    W := ResImage[reButtonDef].Width + 4;
    if (J in CloseButtonScene) then
      L := (Surface.Width div 2) - (ResImage[reButtonDef].Width div 2)
    else
      L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
    for I := Low(TButtonEnum) to High(TButtonEnum) do
    begin
      Button[J][I] := TButton.Create(L, 600, Surface.Canvas, ButtonText[J][I]);
      if not(J in CloseButtonScene) then
        Inc(L, W);
      if (I = btOk) then
        Button[J][I].Sellected := True;
    end;
  end;
  Lf := (Surface.Width div 2) - (ResImage[reFrame].Width) - 2;
end;

procedure RenderCharacterInfo;
const
  H = 25;
var
  C: TCreatureEnum;
  K: TRaceCharKind;
  L, T: Integer;

  procedure Add; overload;
  begin
    Inc(T, H);
  end;

  procedure Add(S: string); overload;
  begin
    Surface.Canvas.TextOut(L, T, S);
    Inc(T, H);
  end;

  procedure Add(S, V: string); overload;
  begin
    Surface.Canvas.TextOut(L, T, Format('%s: %s', [S, V]));
    Inc(T, H);
  end;

  procedure Add(S: string; V: Integer; R: string = ''); overload;
  begin
    Surface.Canvas.TextOut(L, T, Format('%s: %d%s', [S, V, R]));
    Inc(T, H);
  end;

  procedure Add(S: string; V, M: Integer); overload;
  begin
    Surface.Canvas.TextOut(L, T, Format('%s: %d/%d', [S, V, M]));
    Inc(T, H);
  end;

begin
  T := Top + 6;
  L := Lf + ResImage[reActFrame].Width + 12;
  K := TRaceCharKind(CurrentIndex);
  case SubScene of
    stCharacter:
      C := Characters[TSaga.LeaderRace][cgCharacters][K];
    stLeader:
      C := Characters[TSaga.LeaderRace][cgLeaders][K];
  end;
  with TCreature.Character(C) do
  begin
    Add(Name);
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
    if SubScene = stCharacter then
    begin
      Add('Цена', Gold);
      Add('Золото', TSaga.Gold);
    end;
  end;
end;

procedure RenderRace(const Race: TRaceEnum; const AX, AY: Integer);
begin
  // DrawImage(AX + 7, AY + 7, reBGChar);
  case Race of
    reTheEmpire:
      Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[reTheEmpireLogo]);
    reUndeadHordes:
      Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[reUndeadHordesLogo]);
    reLegionsOfTheDamned:
      Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[reLegionsOfTheDamnedLogo]);
  end;
end;

procedure RenderScenario(const AScenario: TScenario.TScenarioEnum;
  const AX, AY: Integer);
begin
  case AScenario of
    sgDarkTower:
      Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[reScenarioDarkTower]);
    sgOverlord:
      Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[reScenarioOverlord]);
    sgAncientKnowledge:
      Surface.Canvas.Draw(AX + 7, AY + 7, ResImage[reScenarioAncientKnowledge]);
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
    Surface.Canvas.TextOut(L, T, S);
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
    Surface.Canvas.TextOut(L, T, S);
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

procedure Render;
var
  Y: Integer;
  R: TRaceEnum;
  K: TRaceCharKind;
  S: TScenario.TScenarioEnum;
begin
  Y := 0;
  case SubScene of
    stCharacter:
      begin
        DrawTitle(reTitleHire);
        for K := Low(TRaceCharKind) to High(TRaceCharKind) do
        begin
          if K = TRaceCharKind(CurrentIndex) then
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reActFrame])
          else
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reFrame]);
          with TCreature.Character
            (Characters[Party[TLeaderParty.LeaderPartyIndex].Owner]
            [cgCharacters][K]) do
          begin
            RenderUnit(ResEnum, Lf, Top + Y, True);
            RenderUnitInfo(Lf, Top + Y,
              Characters[Party[TLeaderParty.LeaderPartyIndex].Owner]
              [cgCharacters][K], False);
          end;
          Inc(Y, 120);
        end;
      end;
    stLeader:
      begin
        DrawTitle(reTitleLeader);
        for K := Low(TRaceCharKind) to High(TRaceCharKind) do
        begin
          if K = TRaceCharKind(CurrentIndex) then
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reActFrame])
          else
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reFrame]);
          with TCreature.Character(Characters[TSaga.LeaderRace]
            [cgLeaders][K]) do
          begin
            RenderUnit(ResEnum, Lf, Top + Y, True);
            RenderUnitInfo(Lf, Top + Y, Characters[TSaga.LeaderRace][cgLeaders]
              [K], False);
          end;
          Inc(Y, 120);
        end;
      end;
    stRace:
      begin
        DrawTitle(reTitleRace);
        for R := reTheEmpire to reLegionsOfTheDamned do
        begin
          if Ord(R) - 1 = CurrentIndex then
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reActFrame])
          else
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reFrame]);
          RenderRace(R, Lf, Top + Y);
          Inc(Y, 120);
        end;
      end;
    stScenario, stJournal:
      begin
        DrawTitle(reTitleScenario);
        for S := Low(TScenario.TScenarioEnum)
          to High(TScenario.TScenarioEnum) do
        begin
          if Ord(S) = CurrentIndex then
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reActFrame])
          else
            Surface.Canvas.Draw(Lf, Top + Y, ResImage[reFrame]);
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
        DrawTitle(reTitleDefeat);
      end;
    stHighScores2:
      begin
        DrawTitle(reTitleHighScores);
      end;
  end;
  Surface.Canvas.Draw(Lf + ResImage[reActFrame].Width + 2, Top,
    ResImage[reInfoFrame]);
  case SubScene of
    stCharacter, stLeader:
      RenderCharacterInfo;
    stRace:
      RenderRaceInfo;
    stScenario, stJournal:
      RenderScenarioInfo;
    stVictory, stDefeat:
      RenderFinalInfo;
    stHighScores2:
      RenderHighScores;
  end;
  RenderButtons;
end;

procedure Timer;
begin

end;

procedure MouseClick(X, Y: Integer); { TODO: Можно сократить код }
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

  if SubScene in [stCharacter, stLeader, stRace, stScenario, stHighScores2] then
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

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  if (SubScene in CloseButtonScene) then
    Button[SubScene][btOk].MouseMove(X, Y)
  else
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      Button[SubScene][I].MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
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
      K_ESCAPE:
        Back;
      K_ENTER:
        Ok;
    end;
end;

procedure Free;
var
  J: THireSubSceneEnum;
  I: TButtonEnum;
begin
  for J := Low(THireSubSceneEnum) to High(THireSubSceneEnum) do
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      FreeAndNil(Button[J][I]);
end;

end.
