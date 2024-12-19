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
  Elinor.Resources in 'Elinor.Resources.pas',
  Elinor.Creatures in 'Game\Elinor.Creatures.pas',
  Elinor.Items in 'Game\Elinor.Items.pas',
  Elinor.Party in 'Game\Elinor.Party.pas',
  Elinor.Battle in 'Game\Elinor.Battle.pas',
  Elinor.Scenes in 'Scenes\Elinor.Scenes.pas',
  DisciplesRL.Scene.Map in 'Scenes\DisciplesRL.Scene.Map.pas',
  DisciplesRL.Scene.Menu in 'Scenes\DisciplesRL.Scene.Menu.pas',
  DisciplesRL.Scene.Menu2 in 'Scenes\DisciplesRL.Scene.Menu2.pas',
  Elinor.Scene.Party in 'Scenes\Elinor.Scene.Party.pas',
  Elinor.Scene.Settlement in 'Scenes\Elinor.Scene.Settlement.pas',
  DisciplesRL.Scene.Hire in 'Scenes\DisciplesRL.Scene.Hire.pas',
  DisciplesRL.Scene.Battle2 in 'Scenes\DisciplesRL.Scene.Battle2.pas',
  DisciplesRL.Scene.Battle3 in 'Scenes\DisciplesRL.Scene.Battle3.pas',
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
  Elinor.Scene.Race in 'Scenes\Elinor.Scene.Race.pas';

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
