// Накладываем СЛЕПОТУ на всю вражескую партию
if (GetInt('ActiveCell') <= 6) then begin A := 7; B := 12; end else begin A := 1; B := 6; end;
// 
for I := A to B do
  // Если атакующий ослеплен
  if (Flag('SlepotaSlot' + GetStr('ActiveCell')) and (Rand(0, 100) <= 75)) then
  begin
    FlagTrue('MissSlot' + IntToStr(I));      
  end else
	if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
    if (Rand(0, 100) <= GetInt('Slot' + GetStr('ActiveCell') + 'TCH'))
      then FlagTrue('SlepotaSlot' + IntToStr(I))
      else FlagTrue('MissSlot' + IntToStr(I));
//
FlagFalse('SlepotaSlot' + GetStr('ActiveCell'));
Run('Battles\SetIni.pas');
Run('Battles\DisplaySlots.pas');
















