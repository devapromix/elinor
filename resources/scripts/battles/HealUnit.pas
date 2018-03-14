// Лечение одного воина
if (Flag('SlepotaSlot' + GetStr('ActiveCell')) and (Rand(0, 100) <= 75)) then
  begin
    FlagTrue('MissSlot' + GetStr('SlotClick'));
  end else
if (GetInt('Slot' + GetStr('SlotClick') + 'HP') > 0)
  and (GetInt('Slot' + GetStr('SlotClick') + 'HP') < GetInt('Slot' + GetStr('SlotClick') + 'MHP')) then
begin
  H := GetInt('Slot' + GetStr('ActiveCell') + 'Use');
  if ((GetInt('Slot' + GetStr('SlotClick') + 'HP') + H) > GetInt('Slot' + GetStr('SlotClick') + 'MHP')) then
    H := GetInt('Slot' + GetStr('SlotClick') + 'MHP') - GetInt('Slot' + GetStr('SlotClick') + 'HP');
  SetInt('DisplayHealSlot' + GetStr('SlotClick'), H);
  IncInt('Slot' + GetStr('SlotClick') + 'HP', H);
end;
FlagFalse('SlepotaSlot' + GetStr('ActiveCell'));
Run('Battles\SetIni.pas');
Run('Battles\DisplaySlots.pas');





































