program Elinor;

{$DEFINE BLT}



uses
  {$IFDEF FPC}
  Forms,
  {$ELSE}
  Vcl.Forms,
  {$ENDIF }
  Elinor.MainForm in 'Forms\Elinor.MainForm.pas' {MainForm},
  Bass in 'Third-Party\Bass\Bass.pas',
  Elinor.Map in 'Game\Elinor.Map.pas',
  Elinor.Resources in 'Game\Elinor.Resources.pas',
  Elinor.Creatures in 'Game\Elinor.Creatures.pas',
  Elinor.Items in 'Game\Elinor.Items.pas',
  Elinor.Party in 'Game\Elinor.Party.pas',
  Elinor.Battle in 'Game\Elinor.Battle.pas',
  Elinor.Scenes in 'Scenes\Elinor.Scenes.pas',
  Elinor.Scene.Map in 'Scenes\Elinor.Scene.Map.pas',
  Elinor.Scene.Menu3 in 'Scenes\Elinor.Scene.Menu3.pas',
  Elinor.Scene.Settlement in 'Scenes\Elinor.Scene.Settlement.pas',
  DisciplesRL.Scene.Hire in 'Scenes\DisciplesRL.Scene.Hire.pas',
  Elinor.Scene.Battle2 in 'Scenes\Elinor.Scene.Battle2.pas',
  Elinor.Scene.Battle3 in 'Scenes\Elinor.Scene.Battle3.pas',
  Elinor.Saga in 'Elinor.Saga.pas',
  Elinor.Button in 'Game\Elinor.Button.pas',
  Elinor.Scene.Spellbook in 'Scenes\Elinor.Scene.Spellbook.pas',
  Elinor.MediaPlayer in 'Game\Elinor.MediaPlayer.pas',
  Elinor.PathFind in 'Elinor.PathFind.pas',
  Elinor.Spells in 'Elinor.Spells.pas',
  Elinor.Treasure in 'Elinor.Treasure.pas',
  Elinor.Statistics in 'Game\Elinor.Statistics.pas',
  Elinor.Scene.Frames in 'Scenes\Elinor.Scene.Frames.pas',
  Elinor.MapObject in 'Game\Elinor.MapObject.pas',
  Elinor.Frame in 'Game\Elinor.Frame.pas',
  Elinor.Scene.Difficulty in 'Scenes\Elinor.Scene.Difficulty.pas',
  Elinor.Scene.Menu.Simple in 'Scenes\Elinor.Scene.Menu.Simple.pas',
  Elinor.Scene.Scenario in 'Scenes\Elinor.Scene.Scenario.pas',
  Elinor.Scenario in 'Game\Elinor.Scenario.pas',
  Elinor.Common in 'Game\Elinor.Common.pas',
  Elinor.Scene.Faction in 'Scenes\Elinor.Scene.Faction.pas',
  Elinor.Scene.Leader in 'Scenes\Elinor.Scene.Leader.pas',
  Elinor.Scene.Menu.Wide in 'Scenes\Elinor.Scene.Menu.Wide.pas',
  Elinor.Scene.Temple in 'Scenes\Elinor.Scene.Temple.pas',
  Elinor.Scene.Party2 in 'Scenes\Elinor.Scene.Party2.pas',
  Elinor.Scene.Base.Party in 'Scenes\Elinor.Scene.Base.Party.pas',
  Elinor.Scene.Recruit in 'Scenes\Elinor.Scene.Recruit.pas',
  Elinor.Scene.Barracks in 'Scenes\Elinor.Scene.Barracks.pas',
  Elinor.Spells.Types in 'Elinor.Spells.Types.pas',
  Elinor.Faction in 'Game\Elinor.Faction.pas',
  Elinor.Spellbook in 'Game\Elinor.Spellbook.pas',
  Elinor.Scene.Skills in 'Scenes\Elinor.Scene.Skills.pas',
  Elinor.Scene.Inventory in 'Scenes\Elinor.Scene.Inventory.pas',
  Elinor.Attribute in 'Game\Elinor.Attribute.pas',
  Elinor.Scene.Abilities in 'Scenes\Elinor.Scene.Abilities.pas',
  Elinor.Scene.NewAbility in 'Scenes\Elinor.Scene.NewAbility.pas',
  Elinor.Scene.MageTower in 'Scenes\Elinor.Scene.MageTower.pas',
  Elinor.Ability.Base in 'Game\Elinor.Ability.Base.pas',
  Elinor.Direction in 'Game\Elinor.Direction.pas',
  Elinor.Difficulty in 'Game\Elinor.Difficulty.pas',
  Elinor.Scene.Records in 'Scenes\Elinor.Scene.Records.pas',
  Elinor.Scene.Victory in 'Scenes\Elinor.Scene.Victory.pas',
  Elinor.Scene.Defeat in 'Scenes\Elinor.Scene.Defeat.pas',
  Elinor.Loot in 'Game\Elinor.Loot.pas',
  Elinor.Scene.Loot2 in 'Scenes\Elinor.Scene.Loot2.pas',
  Elinor.Ability in 'Game\Elinor.Ability.pas',
  Elinor.Creature.Types in 'Game\Elinor.Creature.Types.pas',
  Elinor.Records in 'Game\Elinor.Records.pas',
  Elinor.RecordsTable in 'Game\Elinor.RecordsTable.pas',
  Elinor.Names in 'Game\Elinor.Names.pas',
  Elinor.Scene.Name in 'Scenes\Elinor.Scene.Name.pas',
  Elinor.Scene.Intro in 'Scenes\Elinor.Scene.Intro.pas',
  Elinor.Battle.AI in 'Game\Elinor.Battle.AI.pas';

{$R *.res}

begin
  Application.Initialize;
  {$IFNDEF FPC}
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  {$ENDIF}
  Application.Title := 'ELINOR';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
