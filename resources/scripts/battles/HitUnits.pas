// ”дар по всех юнитах партии
if (GetInt('ActiveCell') <= 6) then
begin
  A := 7;
  B := 12;
end else begin
  A := 1;
  B := 6;
end;
for I := A to B do
begin
  SetInt('SlotTarget', I);
  Run('Battles\HitEntity.pas');
end;
FlagFalse('SlepotaSlot' + GetStr('ActiveCell'));
Run('Battles\SetIni.pas');
Run('Battles\DisplaySlots.pas');

























