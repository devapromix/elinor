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
  DisciplesRL.Party in 'DisciplesRL.Party.pas',
  Bass in 'Third-Party\Bass\Bass.pas',
  DisciplesRL.Battle in 'DisciplesRL.Battle.pas',
  DisciplesRL.Scenes in 'Scenes\DisciplesRL.Scenes.pas',
  DisciplesRL.Scene.Map in 'Scenes\DisciplesRL.Scene.Map.pas',
  DisciplesRL.Scene.Menu in 'Scenes\DisciplesRL.Scene.Menu.pas',
  DisciplesRL.Scene.Menu2 in 'Scenes\DisciplesRL.Scene.Menu2.pas',
  DisciplesRL.Scene.Party in 'Scenes\DisciplesRL.Scene.Party.pas',
  DisciplesRL.Scene.Settlement in 'Scenes\DisciplesRL.Scene.Settlement.pas',
  DisciplesRL.Scene.Hire in 'Scenes\DisciplesRL.Scene.Hire.pas',
  DisciplesRL.Scene.Battle2 in 'Scenes\DisciplesRL.Scene.Battle2.pas',
  DisciplesRL.Scene.Battle3 in 'Scenes\DisciplesRL.Scene.Battle3.pas',
  Elinor.Saga in 'Elinor.Saga.pas',
  DisciplesRL.Button in 'DisciplesRL.Button.pas',
  DisciplesRL.Scene.Spellbook in 'Scenes\DisciplesRL.Scene.Spellbook.pas',
  DisciplesRL.Player in 'DisciplesRL.Player.pas',
  Elinor.PathFind in 'Elinor.PathFind.pas',
  Elinor.Spells in 'Elinor.Spells.pas';

{$R *.res}

begin
  Application.Initialize;
  {$IFNDEF FPC}
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  {$ENDIF}
  Application.Title := 'DisciplesRL';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
