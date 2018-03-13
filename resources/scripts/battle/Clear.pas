//
for I := 0 to 11 do
begin
  SetInt('DisplayHealPos' + IntToStr(I), 0);
  SetInt('DisplayDamagePos' + IntToStr(I), 0);
  FlagFalse('MissPos' + IntToStr(I));
end;