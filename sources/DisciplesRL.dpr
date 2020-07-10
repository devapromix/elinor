program DisciplesRL;

uses
  {$IFDEF FPC}
  SysUtils, Classes,
  BearLibTerminal in 'Third-Party\BearLibTerminal\BearLibTerminal.pas',
  DisciplesRL.Scene in 'DisciplesRL.Scene.pas',
  DisciplesRL.Resources in 'DisciplesRL.Resources.pas',
  DisciplesRL.Map in 'DisciplesRL.Map.pas';
  {$ELSE}
  Vcl.Forms,
  DisciplesRL.MainForm in 'DisciplesRL.MainForm.pas' {MainForm},
  DisciplesRL.Scenes in 'DisciplesRL.Scenes.pas',
  DisciplesRL.Scene.Map in 'DisciplesRL.Scene.Map.pas',
  DisciplesRL.Map in 'DisciplesRL.Map.pas',
  DisciplesRL.Resources in 'DisciplesRL.Resources.pas',
  DisciplesRL.Creatures in 'DisciplesRL.Creatures.pas',
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
  DisciplesRL.Scene.Info in 'DisciplesRL.Scene.Info.pas',
  DisciplesRL.ConfirmationForm in 'DisciplesRL.ConfirmationForm.pas' {ConfirmationForm},
  PathFind in 'Third-Party\PathFind\PathFind.pas',
  RLLog in 'Third-Party\RLLog\RLLog.pas',
  MapObject in 'Third-Party\MapObject\MapObject.pas',
  DisciplesRL.Saga in 'DisciplesRL.Saga.pas',
  PhoenixMediaPlayer in 'Third-Party\PhoenixMediaPlayer\PhoenixMediaPlayer.pas';

{$R *.res}

{$ENDIF}

begin
  Randomize();
  {$IFDEF FPC}
{  terminal_open();


  terminal_refresh();
  repeat




    Key := 0;
    if terminal_has_input() then
      Key := terminal_read();
    // Update(Key);
    terminal_refresh();
    terminal_delay(1);
  until (Key = TK_CLOSE);
  terminal_close(); }
  {$ELSE}
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DisciplesRL';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfirmationForm, ConfirmationForm);
  Application.Run;
  {$ENDIF}
end.
