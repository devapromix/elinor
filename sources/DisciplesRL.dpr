program DisciplesRL;

uses
  Vcl.Forms,
  DisciplesRL.MainForm in 'DisciplesRL.MainForm.pas' {DisciplesRLMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDisciplesRLMainForm, DisciplesRLMainForm);
  Application.Run;
end.
