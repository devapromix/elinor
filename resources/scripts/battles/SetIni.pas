// »щем юнит с самой высокой инициативой
A := 0;
B := 0;
case Rand(1, 2) of
  1: for I := 12 downto 1 do
  if (GetInt('Slot' + IntToStr(I) + 'INI') >= A)
    and Flag('UseSlot' + IntToStr(I)) and (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
  begin
    A := GetInt('Slot' + IntToStr(I) + 'INI');
    SetInt('ActiveCell', I);
    B := I;
  end;
  2: for I := 1 to 12 do
  if (GetInt('Slot' + IntToStr(I) + 'INI') >= A)
    and Flag('UseSlot' + IntToStr(I)) and (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
  begin
    A := GetInt('Slot' + IntToStr(I) + 'INI');
    SetInt('ActiveCell', I);
    B := I;
  end;
end;
//
FlagFalse('UseSlot' + IntToStr(B));
// —ледующий раунд
if (B = 0) then begin
  Run('Battles\StartRound.pas');
  Run('Battles\SetIni.pas');
end;
// јвтоход
if (GetInt('ActiveCell') > 6) then UseTimer(1000, 'Battles\AI\Auto.pas');



















