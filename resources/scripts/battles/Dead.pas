// Юнит побежден
case Rand(1, 7) of
  1:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' ' + 'убит.');
  2:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' ' + 'умирает.');
  3:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' ' + 'погибает.');
  4:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' ' + 'побежден.');
  5:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' ' + 'повержен.');
  6:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' ' + 'мертв.');
  7:
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' ' + 'уничтожен.');
end;
