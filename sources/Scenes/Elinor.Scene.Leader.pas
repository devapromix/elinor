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
  RaceCharKind: TFactionLeaderKind;

implementation

{ TSceneLeader }

uses
  Math, dialogs,
  System.SysUtils,
  Elinor.Scene.Faction,
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
  TSceneHire.CurCrAbilityEnum := TCreature.Character(CurCrEnum).AbilityEnum;
  TSaga.Clear;
  Party[TLeaderParty.LeaderPartyIndex].Owner := TSaga.LeaderFaction;
  Game.MediaPlayer.PlayMusic(mmGame);
  Game.MediaPlayer.PlaySound(mmExit);
  TSceneSettlement.ShowScene(stCapital);
end;

constructor TSceneLeader.Create;
begin
  inherited Create(reWallpaperLeader);
end;

procedure TSceneLeader.Render;
var
  LRaceCharKind: TFactionLeaderKind;
  LLeft, LTop, X, Y, I, J, N: Integer;
begin
  inherited;
  DrawTitle(reTitleLeader);
  for LRaceCharKind := Low(TFactionLeaderKind) to High(TFactionLeaderKind) do
  begin
    LLeft := IfThen(Ord(LRaceCharKind) > 2, TFrame.Col(1), TFrame.Col(0));
    LTop := IfThen(Ord(LRaceCharKind) > 2, TFrame.Row(Ord(LRaceCharKind) - 3),
      TFrame.Row(Ord(LRaceCharKind)));
    with TCreature.Character(Characters[TSaga.LeaderFaction][cgLeaders]
      [LRaceCharKind]) do
      if HitPoints > 0 then
      begin
        DrawUnit(ResEnum, LLeft, LTop, bsCharacter);
        DrawUnitInfo(LLeft, LTop, Characters[TSaga.LeaderFaction][cgLeaders]
          [LRaceCharKind], False);
      end;
  end;

  RaceCharKind := TFactionLeaderKind(CurrentIndex);
  CurCrEnum := Characters[TSaga.LeaderFaction][cgLeaders][RaceCharKind];

  if CurCrEnum <> crNone then
  begin
    TextLeft := TFrame.Col(2) + 12;
    TextTop := TFrame.Row(0) + 6;
    DrawCreatureInfo(TCreature.Character(CurCrEnum));
  end;

  if CurCrEnum <> crNone then
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Ability', True);
    AddTextLine;
    AddTextLine(TAbilities.Ability(TCreature.Character(CurCrEnum)
      .AbilityEnum).Name);
    for I := 0 to 1 do
      AddTextLine(TAbilities.Ability(TCreature.Character(CurCrEnum).AbilityEnum)
        .Description[I]);
    AddTextLine('Equipment', True);
    AddTextLine;
    AddTextLine(Format('Weapon: %s',
      [TCreature.EquippedWeapon(TCreature.Character(CurCrEnum).AttackEnum,
      TCreature.Character(CurCrEnum).SourceEnum)]));
    AddTextLine('Parameters', True);
    AddTextLine;
    AddTextLine('Movement points', TLeaderParty.GetMovementPoints(CurCrEnum));
    AddTextLine('Sight radius', TLeaderParty.GetSightRadius(CurCrEnum));
    AddTextLine('Spells per day', TLeaderParty.GetSpellsPerDay(CurCrEnum));
    AddTextLine('Spell casting range',
      TLeaderParty.GetSpellCastingRange(CurCrEnum));
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
