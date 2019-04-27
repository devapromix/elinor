// Aтакуем вражеского персонажа
case Rand(1, 7) of
  1:
    SetStr('Log', GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' пытается атаковать.');
  2:
    SetStr('Log', GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' атакует.');
  3:
    SetStr('Log', GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' рвется в бой.');
  4:
    SetStr('Log', GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' атакует.');
  5:
    SetStr('Log', GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' атакует.');
  6:
    SetStr('Log', GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' атакует.');
  7:
    SetStr('Log', GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' атакует.');
end;
//
if (Flag('SlepotaSlot' + GetStr('ActiveCell')) and (Rand(0, 100) <= 75)) then
begin
  Run('Battles\Miss.pas');
end
else if (GetInt('Slot' + GetStr('SlotTarget') + 'HP') > 0) then
begin
  if (Rand(0, 100) <= GetInt('Slot' + GetStr('ActiveCell') + 'TCH')) then
  begin
    DecInt('Slot' + GetStr('SlotTarget') + 'HP', GetInt('Slot' + GetStr('ActiveCell') + 'Use'));
    SetInt('DisplayDamageSlot' + GetStr('SlotTarget'), GetInt('Slot' + GetStr('ActiveCell') + 'Use'));
    case Rand(1, 7) of
      1:
        SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ': -' +
          GetStr('Slot' + GetStr('ActiveCell') + 'Use') + ' ед. здоровья.');
      2:
        SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ': -' +
          GetStr('Slot' + GetStr('ActiveCell') + 'Use') + 'HP.');
      3:
        SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' получает урон ' +
          GetStr('Slot' + GetStr('ActiveCell') + 'Use') + ' ед.');
      4:
        SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' получает урон ' +
          GetStr('Slot' + GetStr('ActiveCell') + 'Use') + ' ед.');
      5:
        SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' теряет ' +
          GetStr('Slot' + GetStr('ActiveCell') + 'Use') + ' ед. здоровья.');
      6:
        SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' потерял ' +
          GetStr('Slot' + GetStr('ActiveCell') + 'Use') + ' ед. здоровья.');
      7:
        SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' теряет ' +
          GetStr('Slot' + GetStr('ActiveCell') + 'Use') + ' ед. здоровья.');
    end;
  end
  else
  begin
    Run('Battles\Miss.pas');
  end;
  if (GetInt('Slot' + GetStr('SlotTarget') + 'HP') < 0) then
    SetInt('Slot' + GetStr('SlotTarget') + 'HP', 0);
end;

if (GetInt('Slot' + GetStr('SlotTarget') + 'HP') = 0) then
  Run('Battles\Dead.pas');
// Показываем лог
Log(GetStr('Log'));
