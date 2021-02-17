program DisciplesRL;

uses
{$IFDEF FPC}
  SysUtils, Classes,
  MapObject in 'Third-Party\MapObject\MapObject.pas',
  BearLibTerminal in 'Third-Party\BearLibTerminal\BearLibTerminal.pas',
  DisciplesRL.Scene in 'DisciplesRL.Scene.pas',
  DisciplesRL.Scene.Menu in 'DisciplesRL.Scene.Menu.pas',
  DisciplesRL.Scene.Map in 'DisciplesRL.Scene.Map.pas',
  DisciplesRL.Resources in 'DisciplesRL.Resources.pas',
  DisciplesRL.Creatures in 'DisciplesRL.Creatures.pas',
  DisciplesRL.Items in 'DisciplesRL.Items.pas',
  DisciplesRL.Saga in 'DisciplesRL.Saga.pas',
  DisciplesRL.Map in 'DisciplesRL.Map.pas';
{$ELSE}
  Vcl.Forms,
  DisciplesRL.MainForm in 'Forms\DisciplesRL.MainForm.pas' {MainForm} ,
  DisciplesRL.ConfirmationForm
    in 'Forms\DisciplesRL.ConfirmationForm.pas' {ConfirmationForm} ,
  DisciplesRL.Scenes in 'DisciplesRL.Scenes.pas',
  DisciplesRL.Scene.Map in 'DisciplesRL.Scene.Map.pas',
  DisciplesRL.Map in 'DisciplesRL.Map.pas',
  DisciplesRL.Resources in 'DisciplesRL.Resources.pas',
  DisciplesRL.Creatures in 'DisciplesRL.Creatures.pas',
  DisciplesRL.Items in 'DisciplesRL.Items.pas',
  DisciplesRL.Party in 'DisciplesRL.Party.pas',
  DisciplesRL.Scene.Menu in 'DisciplesRL.Scene.Menu.pas',
  DisciplesRL.Scene.Battle in 'DisciplesRL.Scene.Battle.pas',
  DisciplesRL.GUI.Button in 'DisciplesRL.GUI.Button.pas',
  DisciplesRL.Scene.Party in 'DisciplesRL.Scene.Party.pas',
  DisciplesRL.Scene.Settlement in 'DisciplesRL.Scene.Settlement.pas',
  DisciplesRL.PascalScript.Battle in 'DisciplesRL.PascalScript.Battle.pas',
  DisciplesRL.PascalScript.Vars in 'DisciplesRL.PascalScript.Vars.pas',
  DisciplesRL.Scene.Hire in 'DisciplesRL.Scene.Hire.pas',
  DisciplesRL.Scene.Battle2 in 'DisciplesRL.Scene.Battle2.pas',
  DisciplesRL.Saga in 'DisciplesRL.Saga.pas',
  PathFind in 'Third-Party\PathFind\PathFind.pas',
  RLLog in 'Third-Party\RLLog\RLLog.pas',
  MapObject in 'Third-Party\MapObject\MapObject.pas',
  Bass in 'Third-Party\Bass\Bass.pas',
  SimplePlayer in 'Third-Party\SimplePlayer\SimplePlayer.pas';

{$R *.res}
{$ENDIF}

begin
  Randomize();
{$IFNDEF FPC}
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DisciplesRL';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfirmationForm, ConfirmationForm);
  Application.Run;
{$ENDIF}

end.
