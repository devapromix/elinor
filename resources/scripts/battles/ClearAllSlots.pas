// ќчищаем все соосто¤ни¤

for I := 1 to 12 do
begin
  SetInt('FinishExp', 0);
  SetInt('DisplayHealSlot' + IntToStr(I), 0);
  SetInt('DisplayDamageSlot' + IntToStr(I), 0);
  FlagFalse('SlepotaSlot' + IntToStr(I));
  FlagFalse('MissSlot' + IntToStr(I));
end;

