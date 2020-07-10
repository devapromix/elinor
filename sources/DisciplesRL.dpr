program DisciplesRL;

uses
  {$IFDEF FPC}
  SysUtils, Classes,
  BearLibTerminal in 'Third-Party\BearLibTerminal\BearLibTerminal.pas',
  DisciplesRL.Resources in 'DisciplesRL.Resources.pas',
  DisciplesRL.Map in 'DisciplesRL.Map.pas',
  DisciplesRL.Main in 'DisciplesRL.Main.pas',
  DisciplesRL.Scene in 'DisciplesRL.Scene.pas';
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

{$IFDEF FPC}
var
  I, Key: Word;
  Resources: TStringList;

  X, Y, MX, MY: Integer;
{$ENDIF}

begin
  Randomize();
  {$IFDEF FPC}
{  terminal_open();


  Resources := TStringList.Create;
  try
    writeln('LOADING RESOURCES...');
    Resources.LoadFromFile('resources\resources.txt');
    for I := 0 to Resources.Count - 1 do
      if (Trim(Resources[I]) <> '') then
        begin
          writeln(Resources[I]);
          terminal_set(Resources[I]);
        end;
  finally
    FreeAndNil(Resources);
  end;
  terminal_refresh();
  repeat

    terminal_clear;
    terminal_layer(0);
    for Y := 0 to MapHeight - 1 do
      for X := 0 to MapWidth - 1 do
      begin
        terminal_layer(1);
        terminal_put(X * 4, Y * 2, Map[lrTile][X, Y]);
        terminal_layer(2);
        if (Map[lrObj][X, Y] <> 0) then
          terminal_put(X * 4, Y * 2, Map[lrObj][X, Y]);
      end;
    MX := terminal_state(TK_MOUSE_X) div 4;
    MY := terminal_state(TK_MOUSE_Y) div 2;
    terminal_layer(4);
    terminal_put(MX * 4, MY * 2, $E005);


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
