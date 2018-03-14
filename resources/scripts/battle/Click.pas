//
// if (GetInt('Pos' + GetStr('PosClick') + 'Type') > 0) then
// MsgBox(GetStr('ActivePos'));
if (GetInt('Pos' + GetStr('PosClick') + 'HP') > 0) then
begin
  // Left
  if (GetInt('ActivePos') < 6) then
    case GetInt('Pos' + GetStr('ActivePos') + 'Class') of
      1: // Воин атакует одного ближайшего юнита
        begin
          if (GetInt('PosClick') >= 6) then
          begin
            // Есть ли внешний ряд у противников?
            B := ((GetInt('Pos7HP') > 0) or (GetInt('Pos8HP') > 0) or (GetInt('Pos9HP') > 0));
            if (B and (GetInt('PosClick') >= 7) and (GetInt('PosClick') <= 9)) or
              (not B and (GetInt('PosClick') >= 10) and (GetInt('PosClick') <= 12)) then
              Run('HitUnit.pas');
          end;
        end;
      2: // Рейнжер атакует одного любого юнита из партии
        begin
          if (GetInt('PosClick') >= 6) then
            Run('HitUnit.pas');
        end;
      3: // Маги атакуют всю партию
        begin
          if (GetInt('PosClick') >= 6) then
            Run('HitUnits.pas');
        end;
      4: // Heal
        begin
          if (GetInt('PosClick') < 6) then
            Run('HealUnit.pas');
        end;
      5: // Heal all
        begin
          if (GetInt('PosClick') < 6) then
            Run('HealUnits.pas');
        end;
    end
  else // Right
    case GetInt('Pos' + GetStr('ActivePos') + 'Class') of
      1: // Воин атакует одного ближайшего юнита
        begin
          if (GetInt('PosClick') < 6) then
          begin
            // Есть ли внешний ряд у противников?
            B := ((GetInt('Pos4HP') > 0) or (GetInt('Pos5HP') > 0) or (GetInt('Pos6HP') > 0));
            if (B and (GetInt('PosClick') >= 4) and (GetInt('PosClick') <= 6)) or
              (not B and (GetInt('PosClick') >= 1) and (GetInt('PosClick') <= 3)) then
              Run('HitUnit.pas');
          end;
        end;
      2: // Рейнжер атакует одного любого юнита из партии
        begin
          if (GetInt('PosClick') < 6) then
            Run('HitUnit.pas');
        end;
      3: // Маги атакуют всю партию
        begin
          if (GetInt('PosClick') < 6) then
            Run('HitUnits.pas');
        end;
      4: // Heal
        begin
          if (GetInt('PosClick') >= 6) then
            Run('HealUnit.pas');
        end;
      5: // Heal all
        begin
          if (GetInt('PosClick') >= 6) then
            Run('HealUnits.pas');
        end;
    end;
  Render;
end;
