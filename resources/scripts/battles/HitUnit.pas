// Aтака в ближнем бою на одного юнита
LetVar('SlotTarget', 'SlotClick');
Run('Battles\HitEntity.pas');
FlagFalse('SlepotaSlot' + GetStr('ActiveCell'));
Run('Battles\SetIni.pas');
