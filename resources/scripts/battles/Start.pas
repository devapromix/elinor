// Загружаем базу свойств юнитов
// Run('Battles\SetSlots.pas');

A := 0;
for I := 1 to 12 do
  if (GetInt('Slot' + IntToStr(I) + 'Type') > 0) then
    Inc(A);
if A = 0 then
  Exit;

// Определяем опыт сторон
SetInt('FinishExp', 0);
SetInt('Force1Exp', 0);
SetInt('Force2Exp', 0);
for I := 1 to 6 do
  if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
    IncInt('Force1Exp', GetInt('Slot' + IntToStr(I) + 'MHP') div 10);
for I := 7 to 12 do
  if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
    IncInt('Force2Exp', GetInt('Slot' + IntToStr(I) + 'MHP') div 10);

// Очищаем лог битвы
SetStr('Log', '');

//
Run('Battles\StartRound.pas');
Run('Battles\SetIni.pas');
Run('Battles\DisplaySlots.pas');
