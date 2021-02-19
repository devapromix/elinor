program DisciplesRL;

uses
  Vcl.Forms,
  DisciplesRL.MainForm in 'Forms\DisciplesRL.MainForm.pas' {MainForm},
  DisciplesRL.ConfirmationForm in 'Forms\DisciplesRL.ConfirmationForm.pas' {ConfirmationForm},
  DisciplesRL.Map in 'DisciplesRL.Map.pas',
  DisciplesRL.Resources in 'DisciplesRL.Resources.pas',
  DisciplesRL.Creatures in 'DisciplesRL.Creatures.pas',
  DisciplesRL.Items in 'DisciplesRL.Items.pas',
  DisciplesRL.Party in 'DisciplesRL.Party.pas',
  DisciplesRL.GUI.Button in 'DisciplesRL.GUI.Button.pas',
  PathFind in 'Third-Party\PathFind\PathFind.pas',
  RLLog in 'Third-Party\RLLog\RLLog.pas',
  MapObject in 'Third-Party\MapObject\MapObject.pas',
  Bass in 'Third-Party\Bass\Bass.pas',
  SimplePlayer in 'Third-Party\SimplePlayer\SimplePlayer.pas',
  DisciplesRL.Scenes in 'Scenes\DisciplesRL.Scenes.pas',
  DisciplesRL.Scene.Map in 'Scenes\DisciplesRL.Scene.Map.pas',
  DisciplesRL.Scene.Menu in 'Scenes\DisciplesRL.Scene.Menu.pas',
  DisciplesRL.Scene.Battle in 'Scenes\DisciplesRL.Scene.Battle.pas',
  DisciplesRL.Scene.Party in 'Scenes\DisciplesRL.Scene.Party.pas',
  DisciplesRL.Scene.Settlement in 'Scenes\DisciplesRL.Scene.Settlement.pas',
  DisciplesRL.PascalScript.Battle in 'DisciplesRL.PascalScript.Battle.pas',
  DisciplesRL.Scene.Hire in 'Scenes\DisciplesRL.Scene.Hire.pas',
  DisciplesRL.Scene.Battle2 in 'Scenes\DisciplesRL.Scene.Battle2.pas',
  DisciplesRL.Saga in 'DisciplesRL.Saga.pas';

{$R *.res}

begin
  Randomize();
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DisciplesRL';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfirmationForm, ConfirmationForm);
  Application.Run;

end.
