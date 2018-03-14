//
Run('Clear.pas');
//
for I := 0 to 11 do
begin
  P := 'Pos' + IntToStr(I);
  if (GetInt(P + 'Type') > 0) then
    SetInt(P + 'HP', 9999)
  else
    SetInt(P + 'HP', 0);
end;
