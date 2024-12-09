program Elinor;

{$DEFINE BLT}

uses
  {$IFDEF FPC}
  Forms,
  {$ELSE}
  Vcl.Forms,
  {$ENDIF }
  DisciplesRL.MainForm in 'Forms\DisciplesRL.MainForm.pas' {MainForm},
  DisciplesRL.Map in 'DisciplesRL.Map.pas',
  Elinor.Resources in 'Elinor.Resources.pas',
  DisciplesRL.Creatures in 'DisciplesRL.Creatures.pas',
  DisciplesRL.Items in 'DisciplesRL.Items.pas',
  Elinor.Party in 'Game\Elinor.Party.pas',
  Bass in 'Third-Party\Bass\Bass.pas',
  DisciplesRL.Battle in 'DisciplesRL.Battle.pas',
  DisciplesRL.Scenes in 'Scenes\DisciplesRL.Scenes.pas',
  DisciplesRL.Scene.Map in 'Scenes\DisciplesRL.Scene.Map.pas',
  DisciplesRL.Scene.Menu in 'Scenes\DisciplesRL.Scene.Menu.pas',
  DisciplesRL.Scene.Menu2 in 'Scenes\DisciplesRL.Scene.Menu2.pas',
  Elinor.Scene.Party in 'Scenes\Elinor.Scene.Party.pas',
  Elinor.Scene.Settlement in 'Scenes\Elinor.Scene.Settlement.pas',
  DisciplesRL.Scene.Hire in 'Scenes\DisciplesRL.Scene.Hire.pas',
  DisciplesRL.Scene.Battle2 in 'Scenes\DisciplesRL.Scene.Battle2.pas',
  DisciplesRL.Scene.Battle3 in 'Scenes\DisciplesRL.Scene.Battle3.pas',
  Elinor.Saga in 'Elinor.Saga.pas',
  DisciplesRL.Button in 'DisciplesRL.Button.pas',
  DisciplesRL.Scene.Spellbook in 'Scenes\DisciplesRL.Scene.Spellbook.pas',
  Elinor.MediaPlayer in 'Game\Elinor.MediaPlayer.pas',
  Elinor.PathFind in 'Elinor.PathFind.pas',
  Elinor.Spells in 'Elinor.Spells.pas',
  Elinor.Frame in 'Elinor.Frame.pas',
  Elinor.Treasure in 'Elinor.Treasure.pas',
  Elinor.Statistics in 'Game\Elinor.Statistics.pas',
  Elinor.Scene.Frames in 'Scenes\Elinor.Scene.Frames.pas',
  Elinor.MapObject in 'Game\Elinor.MapObject.pas';

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
