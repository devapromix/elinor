unit DisciplesRL.PascalScript.Battle;

interface

uses Vcl.Dialogs, DisciplesRL.PascalScript.Vars, uPSCompiler, uPSRuntime;

procedure Run(Script: string);
procedure ClearMessages;

var
  ATimerScript: string;
  FlagEnabled: Boolean = True;
  UnitMessage: array [0 .. 11] of string;
  UnitMessageColor: array [0 .. 11] of Integer;
  V: TVars;

implementation

uses System.SysUtils, System.Classes, DisciplesRL.Scenes, DisciplesRL.MainForm, DisciplesRL.Utils;

const
  ScriptPath = 'resources\scripts\battle';

procedure ClearMessages;
var
  I: Byte;
begin
  for I := 0 to 11 do
  begin
    UnitMessage[I] := '';
    UnitMessageColor[I] := 15;
  end;
end;

function _GetStr(S: string): string;
begin
  Result := V.GetStr(S);
end;

procedure _SetStr(S, D: string);
begin
  V.SetStr(S, D);
end;

function _GetInt(S: string): Integer;
begin
  Result := V.GetInt(S);
end;

procedure _SetInt(S: string; A: Integer);
begin
  V.SetInt(S, A);
end;

procedure _IncInt(S: string; A: Integer);
begin
  V.Inc(S, A);
end;

procedure _DecInt(S: string; A: Integer);
begin
  V.Dec(S, A);
end;

function _GetBool(S: string): Boolean;
begin
  Result := V.GetBool(S);
end;

procedure _SetBool(S: string; B: Boolean);
begin
  V.SetBool(S, B);
end;

procedure _LetVar(S1, S2: string);
begin
  V.Let(S1, S2);
end;

function _Flag(const S: string): Boolean;
begin
  Result := (V.GetStr('Flag' + S) = '') or (V.GetStr('Flag' + S) = 'TRUE');
end;

procedure _FlagTrue(const S: string);
begin
  V.SetBool('Flag' + S, True);
end;

procedure _FlagFalse(const S: string);
begin
  V.SetBool('Flag' + S, FALSE);
end;

function _Rand(A, B: Integer): Integer;
begin
  Result := Round(Random(B - A + 1) + A);
end;

procedure _MsgBox(S: string);
begin
  ShowMessage(S);
end;

procedure _UseTimer(Interval: Integer; Script: String);
begin
  with MainForm do
  begin
    FlagEnabled := FALSE;
    ATimerScript := Script;
    AutoTimer.Interval := Interval;
    AutoTimer.Enabled := True;
  end;
end;

procedure _DisplayMsg(A, C: Integer; S: string);
begin
  UnitMessage[A] := S;
  UnitMessageColor[A] := C;
end;

procedure _Render;
begin
  DisciplesRL.Scenes.Render;
end;

procedure _Run(Script: String);
begin
  Run(Script);
end;

function ScriptOnUses(Sender: TPSPascalCompiler; const Name: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF}): Boolean;
begin
  if Name = 'SYSTEM' then
  begin
    //
    Sender.AddDelphiFunction('function GetStr(S: string): string;');
    Sender.AddDelphiFunction('procedure SetStr(S, D: string);');
    Sender.AddDelphiFunction('function GetInt(S: string): Integer;');
    Sender.AddDelphiFunction('procedure SetInt(S: string; I: Integer);');
    Sender.AddDelphiFunction('procedure IncInt(S: string; A: Integer);');
    Sender.AddDelphiFunction('procedure DecInt(S: string; A: Integer);');
    Sender.AddDelphiFunction('function GetBool(S: string): Boolean;');
    Sender.AddDelphiFunction('procedure SetBool(S: string; B: Boolean);');
    Sender.AddDelphiFunction('procedure LetVar(S1, S2: string);');
    Sender.AddDelphiFunction('function Flag(const S: string): Boolean;');
    Sender.AddDelphiFunction('procedure FlagTrue(const S: string);');
    Sender.AddDelphiFunction('procedure FlagFalse(const S: string);');
    //
    Sender.AddDelphiFunction('function Rand(A, B: Integer): Integer;');
    Sender.AddDelphiFunction('procedure MsgBox(S: string);');
    Sender.AddDelphiFunction('procedure Run(Script: string);');
    Sender.AddDelphiFunction('procedure DisplayMsg(A, C: Integer; S: string);');
    Sender.AddDelphiFunction('procedure UseTimer(Interval: Integer; Script: string);');
    Sender.AddDelphiFunction('procedure Render;');
    //
    Result := True;
  end
  else
    Result := FALSE;
end;

procedure Run(Script: string);
var
  Compiler: TPSPascalCompiler;
  Exec: TPSExec;
  S: string;
  Data: {$IFDEF UNICODE}AnsiString{$ELSE}string{$ENDIF};
  I: Integer;
  SL: TStringList;

  procedure ShowScriptErrors(const FileName: string);
  var
    I: Integer;
    S: string;
  begin
    S := Format('Ошибки в файле: "%s":', [ExtractFileName(FileName)]) + #10#13;
    for I := 0 to Compiler.MsgCount - 1 do
      S := S + Compiler.Msg[I].MessageToString + ';'#10#13;
    ShowMessage(S + #10#13 + SL.Text);
  end;

  function StrRight(S: string; I: Integer): string;
  var
    Len: Integer;
  begin
    Len := Length(S);
    Result := Copy(S, Len - I + 1, Len);
  end;

begin
  SL := TStringList.Create;
  try
    if (StrRight(Script, 4) = '.pas') then
    begin
      S := GetPath(ScriptPath) + Script;
      if not FileExists(S) then
      begin
        ShowMessage('Файл скрипта "' + ExtractFileName(S) + '" не найден!');
        Exit;
      end;
      SL.LoadFromFile(S, TEncoding.ANSI);
    end;
    SL.Insert(0, 'begin');
    SL.Insert(0, 'I, J: Integer;');
    SL.Insert(0, 'P, S: string;');
    SL.Insert(0, 'B, F: Boolean;');
    SL.Insert(0, 'var');
    SL.Append('end.');
    Compiler := TPSPascalCompiler.Create;
    Compiler.OnUses := ScriptOnUses;
    if not Compiler.Compile(SL.Text) then
    begin
      ShowScriptErrors(S);
      Compiler.Free;
      Exit;
    end;
    Compiler.GetOutput(Data);
    Compiler.Free;
    Exec := TPSExec.Create;
    //
    Exec.RegisterDelphiFunction(@_GetStr, 'GETSTR', cdRegister);
    Exec.RegisterDelphiFunction(@_SetStr, 'SETSTR', cdRegister);
    Exec.RegisterDelphiFunction(@_GetInt, 'GETINT', cdRegister);
    Exec.RegisterDelphiFunction(@_SetInt, 'SETINT', cdRegister);
    Exec.RegisterDelphiFunction(@_IncInt, 'INCINT', cdRegister);
    Exec.RegisterDelphiFunction(@_DecInt, 'DECINT', cdRegister);
    Exec.RegisterDelphiFunction(@_GetBool, 'GETBOOL', cdRegister);
    Exec.RegisterDelphiFunction(@_SetBool, 'SETBOOL', cdRegister);
    Exec.RegisterDelphiFunction(@_LetVar, 'LETVAR', cdRegister);
    Exec.RegisterDelphiFunction(@_Flag, 'FLAG', cdRegister);
    Exec.RegisterDelphiFunction(@_FlagTrue, 'FLAGTRUE', cdRegister);
    Exec.RegisterDelphiFunction(@_FlagFalse, 'FLAGFALSE', cdRegister);
    //
    Exec.RegisterDelphiFunction(@_Rand, 'RAND', cdRegister);
    Exec.RegisterDelphiFunction(@_MsgBox, 'MSGBOX', cdRegister);
    Exec.RegisterDelphiFunction(@_Run, 'RUN', cdRegister);
    Exec.RegisterDelphiFunction(@_UseTimer, 'USETIMER', cdRegister);
    Exec.RegisterDelphiFunction(@_DisplayMsg, 'DISPLAYMSG', cdRegister);
    Exec.RegisterDelphiFunction(@_Render, 'RENDER', cdRegister);
    //
    if not Exec.LoadData(Data) then
    begin
      Exec.Free;
      Exit;
    end;
    Exec.RunScript;
    Exec.Free;
  except
  end;
end;

initialization

V := TVars.Create;

finalization

FreeAndNil(V);

end.
