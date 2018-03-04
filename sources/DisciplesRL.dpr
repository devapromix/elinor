program DisciplesRL;

uses
  Vcl.Forms,
  DisciplesRL.MainForm in 'DisciplesRL.MainForm.pas' {MainForm},
  DisciplesRL.Utils in 'DisciplesRL.Utils.pas',
  DisciplesRL.Scenes in 'DisciplesRL.Scenes.pas',
  DisciplesRL.Scene.Map in 'DisciplesRL.Scene.Map.pas',
  DisciplesRL.Map in 'DisciplesRL.Map.pas',
  DisciplesRL.Resources in 'DisciplesRL.Resources.pas',
  DisciplesRL.Player in 'DisciplesRL.Player.pas',
  DisciplesRL.Creatures in 'DisciplesRL.Creatures.pas',
  DisciplesRL.Party in 'DisciplesRL.Party.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
