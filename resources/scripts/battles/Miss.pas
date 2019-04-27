// Промах
FlagTrue('MissSlot' + GetStr('SlotTarget'));
case Rand(1, 7) of
  1:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' промахивается по ' +
      GetStr('Slot' + GetStr('SlotTarget') + 'Name') + '.');
  2:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' промахивается по ' +
      GetStr('Slot' + GetStr('SlotTarget') + 'Name') + '.');
  3:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' промахивается по ' +
      GetStr('Slot' + GetStr('SlotTarget') + 'Name') + '.');
  4:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' пытается попасть по ' +
      GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ', но промахивается.');
  5:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' уклоняется.');
  6:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' избегает атаки.');
  7:
    SetStr('Log', GetStr('Log') + ' Фортуна улибается ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' и ' +
      GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' промахивается.');
end;
