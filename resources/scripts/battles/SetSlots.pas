// База юнитов
for I := 1 to 12 do
begin
  S := 'Slot' + IntToStr(I);
  // Снимаем эффект СЛЕПОТА со всех юнитов
  FlagFalse('Slepota' + S);
  // Снимаем все промахи
  FlagFalse('Miss' + S);
  //
  if (GetInt(S + 'HP') > 0) then
  case GetInt(S + 'Type') of
  // Защитники Империи
   1: begin // Сквайр (Воин)
        SetStr(S + 'Name',  'Сквайр');
        SetInt(S + 'MHP',   100);
        SetInt(S + 'INI',   50);
        SetInt(S + 'Use',   25);
        SetInt(S + 'TCH',   80);
        SetInt(S + 'Class', 1);
      end;
   2: begin // Ученик (Колдун)
        SetStr(S + 'Name',  'Ученик');
        SetInt(S + 'MHP',   35);
        SetInt(S + 'INI',   40);
        SetInt(S + 'Use',   15);
        SetInt(S + 'TCH',   80);
        SetInt(S + 'Class', 2);
      end;
   3: begin // Послушница (Лечит одного воина)
        SetStr(S + 'Name',  'Послушница');
        SetInt(S + 'MHP',   50);
        SetInt(S + 'INI',   20);
        SetInt(S + 'Use',   25);
        SetInt(S + 'TCH',   100);
        SetInt(S + 'Class', 3);
      end;
   4: begin // Лучник
        SetStr('Slot' + IntToStr(I) + 'Name',  'Лучник');
        SetInt('Slot' + IntToStr(I) + 'MHP',   55);
        SetInt('Slot' + IntToStr(I) + 'INI',   60);
        SetInt('Slot' + IntToStr(I) + 'Use',   15);
        SetInt('Slot' + IntToStr(I) + 'TCH',   80);
        SetInt('Slot' + IntToStr(I) + 'Class', 4);
      end;
   5: begin // Монахиня (Лечит партию)
        SetStr('Slot' + IntToStr(I) + 'Name',  'Монахиня');
        SetInt('Slot' + IntToStr(I) + 'MHP',   60);
        SetInt('Slot' + IntToStr(I) + 'INI',   15);
        SetInt('Slot' + IntToStr(I) + 'Use',   15);
        SetInt('Slot' + IntToStr(I) + 'TCH',   100);
        SetInt('Slot' + IntToStr(I) + 'Class', 5);
      end;
   6: begin // Патриарх (Боевой маг)
        SetStr('Slot' + IntToStr(I) + 'Name',  'Патриарх');
        SetInt('Slot' + IntToStr(I) + 'MHP',   60);
        SetInt('Slot' + IntToStr(I) + 'INI',   55);
        SetInt('Slot' + IntToStr(I) + 'Use',   25);
        SetInt('Slot' + IntToStr(I) + 'TCH',   75);
        SetInt('Slot' + IntToStr(I) + 'Class', 6);
      end;

  // Орды Нежити
  21: begin // Воин Плоти
        SetStr('Slot' + IntToStr(I) + 'Name',  'Воин Плоти');
        SetInt('Slot' + IntToStr(I) + 'MHP',   120);
        SetInt('Slot' + IntToStr(I) + 'INI',   50);
        SetInt('Slot' + IntToStr(I) + 'Use',   25);
        SetInt('Slot' + IntToStr(I) + 'TCH',   80);
        SetInt('Slot' + IntToStr(I) + 'Class', 1);
      end;
  22: begin // Адепт (Колдун)
        SetStr('Slot' + IntToStr(I) + 'Name',  'Адепт');
        SetInt('Slot' + IntToStr(I) + 'MHP',   45);
        SetInt('Slot' + IntToStr(I) + 'INI',   40);
        SetInt('Slot' + IntToStr(I) + 'Use',   15);
        SetInt('Slot' + IntToStr(I) + 'TCH',   80);
        SetInt('Slot' + IntToStr(I) + 'Class', 2);
      end;
  23: begin // Привидение (Накладывает заклинание "Слепота" на одного противника)
        SetStr('Slot' + IntToStr(I) + 'Name',  'Привидение');
        SetInt('Slot' + IntToStr(I) + 'MHP',   45);
        SetInt('Slot' + IntToStr(I) + 'INI',   80);
        SetInt('Slot' + IntToStr(I) + 'Use',   0);
        SetInt('Slot' + IntToStr(I) + 'TCH',   65);
        SetInt('Slot' + IntToStr(I) + 'Class', 8);
      end;
  26: begin // Странствующий Маг (Боевой маг)
        SetStr('Slot' + IntToStr(I) + 'Name',  'Странствующий Маг');
        SetInt('Slot' + IntToStr(I) + 'MHP',   60);
        SetInt('Slot' + IntToStr(I) + 'INI',   55);
        SetInt('Slot' + IntToStr(I) + 'Use',   25);
        SetInt('Slot' + IntToStr(I) + 'TCH',   75);
        SetInt('Slot' + IntToStr(I) + 'Class', 6);
      end;

  // Легионы Проклятых
  42: begin // Сектант (Колдун)
        SetStr('Slot' + IntToStr(I) + 'Name',  'Сектант');
        SetInt('Slot' + IntToStr(I) + 'MHP',   45);
        SetInt('Slot' + IntToStr(I) + 'INI',   40);
        SetInt('Slot' + IntToStr(I) + 'Use',   15);
        SetInt('Slot' + IntToStr(I) + 'TCH',   80);
        SetInt('Slot' + IntToStr(I) + 'Class', 2);
      end;

  // Нейтральные существа
  101: begin // Лесной Паук
        SetStr('Slot' + IntToStr(I) + 'Name',  'Лесной Паук');
        SetInt('Slot' + IntToStr(I) + 'MHP',   140);
        SetInt('Slot' + IntToStr(I) + 'INI',   45);
        SetInt('Slot' + IntToStr(I) + 'Use',   30);
        SetInt('Slot' + IntToStr(I) + 'TCH',   80);
        SetInt('Slot' + IntToStr(I) + 'Class', 1);
       end;
  102: begin // Волк-призрак
        SetStr('Slot' + IntToStr(I) + 'Name',  'Волк-призрак');
        SetInt('Slot' + IntToStr(I) + 'MHP',   180);
        SetInt('Slot' + IntToStr(I) + 'INI',   40);
        SetInt('Slot' + IntToStr(I) + 'Use',   45);
        SetInt('Slot' + IntToStr(I) + 'TCH',   80);
        SetInt('Slot' + IntToStr(I) + 'Class', 1);
       end;

  end;
end;
