// јтака по юнитах противника: в зависимости от класса разное поведение юнитов в бою (простой AI)
case GetInt('Slot' + GetStr('ActiveCell') + 'Class') of

  1: // ”рон по ближайшему одному противнику из партии
    for I := 6 downto 1 do
      if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
      begin
        SetInt('SlotClick', I);
        Run('Battles\SlotClick.pas');
        Break;
      end;

  2: // ”рон по всех противниках из партии
    for I := 1 to 6 do
      if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
      begin
        SetInt('SlotClick', I);
        Run('Battles\SlotClick.pas');
        Break;
      end;

  3: // »сцеление одного дружественного воина
    begin
      A := 0;
      B := 0;
      for I := 12 downto 7 do
        if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
        begin
          // »щем самый слабый юнит
          C := GetInt('Slot' + IntToStr(I) + 'MHP') - GetInt('Slot' + IntToStr(I) + 'HP');
          if (C >= A) then
          begin
            A := C;
            B := I;
          end;
        end;
      if (B > 0) then
      begin
        SetInt('SlotClick', B);
        Run('Battles\SlotClick.pas');
      end;
    end;

  4, 6: // ”рон по любому одному юниту из вражеской партии
    begin
      A := 10000;
      B := 0;
      for I := 6 downto 1 do
        if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
        begin
          // ѕеред атакой ищем самый слабый юнит
          if (GetInt('Slot' + IntToStr(I) + 'HP') < A) then
          begin
            A := GetInt('Slot' + IntToStr(I) + 'HP');
            B := I;
          end;
        end;
      if (B > 0) then
      begin
        SetInt('SlotClick', B);
        Run('Battles\SlotClick.pas');
      end;
    end;

  5: // »сцеление всех партнеров своей партии
    begin
      LetVar('SlotClick', 'ActiveCell');
      Run('Battles\SlotClick.pas');
    end;

  8: // ќслепление одного воина из вражеской партии
    begin
      A := 0;
      B := 0;
      for I := 6 downto 1 do
        if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
        begin
          // »щем самый сильный юнит
          if (GetInt('Slot' + IntToStr(I) + 'HP') > A) and not(Flag('SlepotaSlot' + IntToStr(I))) then
          begin
            A := GetInt('Slot' + IntToStr(I) + 'HP');
            B := I;
          end;
        end;
      if (B > 0) then
      begin
        SetInt('SlotClick', B);
        Run('Battles\SlotClick.pas');
      end
      else
      begin
        // Ќет цели (блок), накладываем заклинание повторно
        for I := 6 downto 1 do
          if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
          begin
            SetInt('SlotClick', I);
            Run('Battles\SlotClick.pas');
          end;
      end;
    end;

  9: // ќслепление всех юнитов из вражеской партии
    for I := 1 to 6 do
      if (GetInt('Slot' + IntToStr(I) + 'HP') > 0) then
      begin
        SetInt('SlotClick', I);
        Run('Battles\SlotClick.pas');
        Break;
      end;

end;
