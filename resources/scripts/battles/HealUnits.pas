// Лечение Партии
if (GetInt('ActiveCell') <= 6) then begin A := 1; B := 6; end else begin A := 7; B := 12; end;
// 
for I := A to B do
  // Если атакующий ослеплен
  if (Flag('SlepotaSlot' + GetStr('ActiveCell')) and (Rand(0, 100) <= 75)) then
  begin
    FlagTrue('MissSlot' + IntToStr(I));
  end else
	if (GetInt('Slot' + IntToStr(I) + 'HP') > 0)
		and (GetInt('Slot' + IntToStr(I) + 'HP') < GetInt('Slot' + IntToStr(I) + 'MHP')) then
	begin
    H := GetInt('Slot' + GetStr('ActiveCell') + 'Use');
    if ((GetInt('Slot' + IntToStr(I) + 'HP') + H) > GetInt('Slot' + IntToStr(I) + 'MHP')) then
      H := GetInt('Slot' + IntToStr(I) + 'MHP') - GetInt('Slot' + IntToStr(I) + 'HP');
    SetInt('DisplayHealSlot' + IntToStr(I), H);
		IncInt('Slot' + IntToStr(I) + 'HP', H);
	end;
// 
FlagFalse('SlepotaSlot' + GetStr('ActiveCell'));
Run('Battles\SetIni.pas');
Run('Battles\DisplaySlots.pas');























