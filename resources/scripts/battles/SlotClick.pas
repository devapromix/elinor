// MsgBox(GetStr('Slot' + GetStr('SlotClick') + 'HP'));
// Если слот не пустой
//MsgBox(GetStr('Slot' + GetStr('SlotClick') + 'Type'));//Debug
if (GetInt('Slot' + GetStr('SlotClick') + 'HP') > 0) then
begin
  // Активный юнит с левой стороны
  if (GetInt('ActiveCell') <= 6) then
    // Разделяем по классам
    case GetInt('Slot' + GetStr('ActiveCell') + 'Class') of
      1: // Воин атакует одного ближайшего юнита
        begin
          if (GetInt('SlotClick') > 6) then
          begin
            { // В каком ряду активный юнит и есть ли ряд у активной стороны
              if (GetInt('ActiveCell') <= 3) then
              begin
              U := ((GetInt('Slot4HP') > 0) or (GetInt('Slot5HP') > 0) or (GetInt('Slot6HP') > 0));
              if U then
              begin
              FlagFalse('SlepotaSlot' + GetStr('ActiveCell'));
              Run('Battles\SetIni.pas');
              Run('Battles\DisplaySlots.pas');
              Exit;
              end;
              end; }
            // Есть ли внешний ряд у противников?
            U := ((GetInt('Slot7HP') > 0) or (GetInt('Slot8HP') > 0) or
              (GetInt('Slot9HP') > 0));
            if (U and (GetInt('SlotClick') >= 7) and (GetInt('SlotClick') <= 9))
              or (not U and (GetInt('SlotClick') >= 10) and
              (GetInt('SlotClick') <= 12)) then
              Run('Battles\HitUnit.pas');
          end;
        end;
      2: // Маги атакуют всю партию
        begin
          if (GetInt('SlotClick') > 6) then
            Run('Battles\HitUnits.pas');
        end;
      3: // Исцелить воина
        begin
          if (GetInt('SlotClick') <= 6) then
            Run('Battles\HealUnit.pas');
        end;
      4: // Рейнжер атакует одного любого юнита из партии
        begin
          if (GetInt('SlotClick') > 6) then
            Run('Battles\HitUnit.pas');
        end;
      5: // Исцелить всю партию
        begin
          if (GetInt('SlotClick') <= 6) then
            Run('Battles\HealUnits.pas');
        end;
      6: // Боевой маг атакует одного любого юнита из партии
        begin
          if (GetInt('SlotClick') > 6) then
            Run('Battles\HitUnit.pas');
        end;

      8: // СЛЕПОТА на одного любого юнита из партии
        begin
          if (GetInt('SlotClick') > 6) then
            Run('Battles\SlepotaUnit.pas');
        end;
      9: // СЛЕПОТА на всех юнитов партии
        begin
          if (GetInt('SlotClick') > 6) then
            Run('Battles\SlepotaUnits.pas');
        end;

    end
  else // Партия с правой стороны
    case GetInt('Slot' + GetStr('ActiveCell') + 'Class') of
      1: // Воин атакует одного ближайшего юнита
        begin
          if (GetInt('SlotClick') <= 6) then
          begin
            // Есть ли внешний ряд у противников?
            U := ((GetInt('Slot4HP') > 0) or (GetInt('Slot5HP') > 0) or
              (GetInt('Slot6HP') > 0));
            if (U and (GetInt('SlotClick') >= 4) and (GetInt('SlotClick') <= 6))
              or (not U and (GetInt('SlotClick') >= 1) and
              (GetInt('SlotClick') <= 3)) then
              Run('Battles\HitUnit.pas');
          end;
        end;
      2: // Маги атакуют всю партию
        begin
          if (GetInt('SlotClick') <= 6) then
            Run('Battles\HitUnits.pas');
        end;
      3: // Исцелить воина
        begin
          if (GetInt('SlotClick') > 6) then
            Run('Battles\HealUnit.pas');
        end;
      4: // Рейнжер атакует одного любого юнита из партии
        begin
          if (GetInt('SlotClick') <= 6) then
            Run('Battles\HitUnit.pas');
        end;
      5: // Исцелить всю партию
        begin
          if (GetInt('SlotClick') > 6) then
            Run('Battles\HealUnits.pas');
        end;
      6: // Боевой маг атакует одного любого юнита из партии
        begin
          if (GetInt('SlotClick') <= 6) then
            Run('Battles\HitUnit.pas');
        end;

      8: // СЛЕПОТА на одного любого юнита из партии
        begin
          if (GetInt('SlotClick') <= 6) then
            Run('Battles\SlepotaUnit.pas');
        end;
      9: // СЛЕПОТА на всех юнитов партии
        begin
          if (GetInt('SlotClick') <= 6) then
            Run('Battles\SlepotaUnits.pas');
        end;

    end;
  Refresh;
  Render;
end;
