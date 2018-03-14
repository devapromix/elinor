// Накладываем СЛЕПОТУ на одного юнита из вражеской партии
if (Flag('SlepotaSlot' + GetStr('ActiveCell')) and (Rand(0, 100) <= 75)) then
  begin
    FlagTrue('MissSlot' + GetStr('SlotClick'));
  end else
if (GetInt('Slot' + GetStr('SlotClick') + 'HP') > 0) then
  if (Rand(0, 100) <= GetInt('Slot' + GetStr('ActiveCell') + 'TCH'))
    then FlagTrue('SlepotaSlot' + GetStr('SlotClick'))
    else FlagTrue('MissSlot' + GetStr('SlotClick'));
//
FlagFalse('SlepotaSlot' + GetStr('ActiveCell'));
Run('Battles\SetIni.pas');
Run('Battles\DisplaySlots.pas');














