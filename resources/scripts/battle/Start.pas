//
J := 0;
for I := 0 to 11 do
  if (GetInt('Pos' + IntToStr(I) + 'Type') > 0) then
    Inc(J);
if J = 0 then
  Exit;
//
SetInt('FinishExp', 0);
SetInt('Force1Exp', 0);
SetInt('Force2Exp', 0);
for I := 0 to 11 do
begin
  P := 'Pos' + IntToStr(I);
  case I of
    0 .. 5:
      begin
        if (GetInt(P + 'HP') > 0) then
          IncInt('Force1Exp', GetInt(P + 'MHP') div 10);
      end;
    6 .. 11:
      begin
        if (GetInt(P + 'HP') > 0) then
          IncInt('Force2Exp', GetInt(P + 'MHP') div 10);
      end;
  end;
end;
//
Run('StartRound.pas');
Run('SetIni.pas');
Run('Display.pas');
