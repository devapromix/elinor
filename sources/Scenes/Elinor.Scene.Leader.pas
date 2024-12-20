unit Elinor.Scene.Leader;

interface

uses
  Elinor.Scene.Menu.Wide,
  Vcl.Controls,
  System.Classes,
  Elinor.Creatures,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneLeader = class(TSceneWideMenu)
  private
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Cancel; override;
    procedure Continue; override;
    class procedure Show;
  end;

var
  RaceCharKind: TRaceCharKind;

implementation

{ TSceneLeader }

uses
  Math, dialogs,
  System.SysUtils,
  Elinor.Scene.Race,
  DisciplesRL.Scene.Hire,
  Elinor.Saga,
  Elinor.Scene.Settlement,
  Elinor.Scene.Party,
  Elinor.Frame;

var
  CurCrEnum: TCreatureEnum;

procedure TSceneLeader.Cancel;
begin
  inherited;
  TSceneRace.Show;
end;

procedure TSceneLeader.Continue;
begin
  inherited;
  Game.MediaPlayer.PlaySound(mmClick);
  TSceneHire.CurCrSkillEnum := TCreature.Character(CurCrEnum).SkillEnum;
  TSaga.Clear;
  Party[TLeaderParty.LeaderPartyIndex].Owner := TSaga.LeaderRace;
  Game.MediaPlayer.PlayMusic(mmGame);
  Game.MediaPlayer.PlaySound(mmExit);
  TSceneSettlement.Show(stCapital);
end;

constructor TSceneLeader.Create;
begin
  inherited Create(reWallpaperLeader);
end;

procedure TSceneLeader.Render;
var
  LRaceCharKind: TRaceCharKind;
  LLeft, LTop, X, Y, I, J, N: Integer;
begin
  inherited;
  DrawTitle(reTitleLeader);
  for LRaceCharKind := Low(TRaceCharKind) to High(TRaceCharKind) do
  begin
    LLeft := IfThen(Ord(LRaceCharKind) > 2, TFrame.Col(1), TFrame.Col(0));
    LTop := IfThen(Ord(LRaceCharKind) > 2, TFrame.Row(Ord(LRaceCharKind) - 3),
      TFrame.Row(Ord(LRaceCharKind)));
    with TCreature.Character(Characters[TSaga.LeaderRace][cgLeaders]
      [LRaceCharKind]) do
      if HitPoints > 0 then
      begin
        DrawUnit(ResEnum, LLeft, LTop, bsCharacter);
        TSceneParty(Game.GetScene(scParty)).DrawUnitInfo(LLeft, LTop,
          Characters[TSaga.LeaderRace][cgLeaders][LRaceCharKind], False);
      end;
  end;

  RaceCharKind := TRaceCharKind(CurrentIndex);
  CurCrEnum := Characters[TSaga.LeaderRace][cgLeaders][RaceCharKind];

  if CurCrEnum <> crNone then
  begin
    TextLeft := TFrame.Col(2) + 12;
    TextTop := TFrame.Row(0) + 6;
    with TCreature.Character(CurCrEnum) do
    begin
      AddTextLine(Name[0], True);
      AddTextLine;
      AddTextLine('Уровень', Level);
      AddTextLine('Точность', ChancesToHit);
      AddTextLine('Инициатива', Initiative);
      AddTextLine('Здоровье', HitPoints, HitPoints);
      AddTextLine('Урон', Damage);
      AddTextLine('Броня', Armor);
      AddTextLine('Источник', SourceName[SourceEnum]);
      case ReachEnum of
        reAny:
          begin
            AddTextLine('Дистанция', 'Все поле боя');
            AddTextLine('Цели', 1);
          end;
        reAdj:
          begin
            AddTextLine('Дистанция', 'Ближайшие цели');
            AddTextLine('Цели', 1);
          end;
        reAll:
          begin
            AddTextLine('Дистанция', 'Все поле боя');
            AddTextLine('Цели', 6);
          end;
      end;
      for I := 0 to 2 do
        AddTextLine(Description[I]);
    end;

  end;

  if CurCrEnum <> crNone then
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Умения Лидера', True);
    AddTextLine;
    AddTextLine(TSkills.Ability(TCreature.Character(CurCrEnum).SkillEnum).Name);
    for I := 0 to 1 do
      AddTextLine(TSkills.Ability(TCreature.Character(CurCrEnum).SkillEnum)
        .Description[I]);
    AddTextLine;
    AddTextLine;
    AddTextLine('Экипировка', True);
    AddTextLine;
    AddTextLine(Format('Оружие: %s',
      [TCreature.EquippedWeapon(TCreature.Character(CurCrEnum).AttackEnum,
      TCreature.Character(CurCrEnum).SourceEnum)]));
    AddTextLine;
    AddTextLine('Скорость Передвижения', TLeaderParty.GetMaxSpeed(CurCrEnum));
    AddTextLine('Радиус Обзора', TLeaderParty.GetRadius(CurCrEnum));
    AddTextLine('Заклинаний в день', TLeaderParty.GetMaxSpells(CurCrEnum));
  end;

end;

class procedure TSceneLeader.Show;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scLeader);
end;

procedure TSceneLeader.Update(var Key: Word);
begin
  inherited;

end;

end.
