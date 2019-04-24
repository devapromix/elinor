// Aтакуем сущность
if (Flag('SlepotaSlot' + GetStr('ActiveCell')) and (Rand(0, 100) <= 75)) then
begin
  FlagTrue('MissSlot' + GetStr('SlotTarget'));
  SetStr('Log', GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' уклоняется.');
end
else if (GetInt('Slot' + GetStr('SlotTarget') + 'HP') > 0) then
begin
  if (Rand(0, 100) <= GetInt('Slot' + GetStr('ActiveCell') + 'TCH')) then
  begin
    DecInt('Slot' + GetStr('SlotTarget') + 'HP',
      GetInt('Slot' + GetStr('ActiveCell') + 'Use'));
    SetInt('DisplayDamageSlot' + GetStr('SlotTarget'),
      GetInt('Slot' + GetStr('ActiveCell') + 'Use'));
	SetStr('Log', GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' получает урон ' + GetStr('Slot' + GetStr('ActiveCell') + 'Use'));
  end
  else
  begin
    FlagTrue('MissSlot' + GetStr('SlotTarget'));
    SetStr('Log', GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' уклоняется.');
  end;	
  if (GetInt('Slot' + GetStr('SlotTarget') + 'HP') <= 0) then
  begin
	SetInt('Slot' + GetStr('SlotTarget') + 'HP', 0);
    SetStr('Log', GetStr('Log') + ' ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + ' побежден.');
  end;	
end;

Log(GetStr('Slot' + GetStr('ActiveCell') + 'Name') + ' пытается атаковать ' + GetStr('Slot' + GetStr('SlotTarget') + 'Name') + '... ' + GetStr('Log'));

