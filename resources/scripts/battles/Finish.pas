// Конец сражения

// Проверяем, остался ли кто жив
A := 0;
B := 0;
for I := 1 to 6  do if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then Inc(A);
for I := 7 to 12 do if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then Inc(B);
// Если проиграла сторона А (1)
if (A = 0) then
begin
  // Определяем количество победителей
  A := 0;
  for I := 7 to 12 do if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then Inc(A);
  if A = 0 then Exit;
  B := GetInt('Force1Exp') div A;
  SetInt('FinishExp', B);
  Exit;
end;
if (B = 0) then
begin
  A := 0;
  for I := 1 to 6 do if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then Inc(A);
  if A = 0 then Exit;
  B := GetInt('Force2Exp') div A;
  SetInt('FinishExp', B);
  Exit;
end;


























