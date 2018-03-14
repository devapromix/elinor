// Левая Сторона                                    // Правая Сторона
//SetInt('Slot1Type', 0);SetInt('Slot4Type', 0);SetInt('Slot7Type', 0);SetInt('Slot10Type', 0);
//SetInt('Slot2Type', 0);SetInt('Slot5Type', 0);SetInt('Slot8Type', 0);SetInt('Slot11Type', 0);
//SetInt('Slot3Type', 0);SetInt('Slot6Type', 0);SetInt('Slot9Type', 0);SetInt('Slot12Type', 0);

//
Run('Battles\ClearAllSlots.pas');
//
for I := 1 to 12 do
  if (GetInt('Slot' + IntToStr(I) + 'Type') > 0) then
    begin
      SetInt('Slot' + IntToStr(I) + 'HP', 10000);
    end else SetInt('Slot' + IntToStr(I) + 'HP', 0);
















