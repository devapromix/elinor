// јтакуем сущность
if (Flag('SlepotaSlot' + GetStr('ActiveCell')) and (Rand(0, 100) <= 75)) then
  begin
    FlagTrue('MissSlot' + GetStr('SlotTarget'));
  end else
if (GetInt('Slot' + GetStr('SlotTarget') + 'HP') > 0) then
  if (Rand(0, 100) <= GetInt('Slot' + GetStr('ActiveCell') + 'TCH'))
    then begin
      DecInt('Slot' + GetStr('SlotTarget') + 'HP', GetInt('Slot' + GetStr('ActiveCell') + 'Use'));
      SetInt('DisplayDamageSlot' + GetStr('SlotTarget'), GetInt('Slot' + GetStr('ActiveCell') + 'Use'));
    end else FlagTrue('MissSlot' + GetStr('SlotTarget'));

