unit DisciplesRL.Creatures;

interface

uses
  DisciplesRL.Resources;

type
  TRaceEnum = (reNeutrals, reTheEmpire, reUndeadHordes, reLegionsOfTheDamned, reMountainClans, reElvenAlliance);

const
  RaceName: array [TRaceEnum] of string = ('Нейтралы', 'Защитники Империи', 'Орды Нежити', 'Легионы Проклятых', 'Горные Кланы', 'Эльфийский Союз');

const
  RaceDescription: array [TRaceEnum] of array [0 .. 10] of string = (('', '', '', '', '', '', '', '', '', '', ''),
    // The Empire
    ('Империя пришла в упадок. Больше', 'не радуют глаз возделанные поля и цве-', 'тущие сады. Землю раздирают склоки и',
    'раздоры. Аристократы и разбойничьи', 'атаманы провозгласили собственные', 'королевства. Некогда гордая и единая',
    'Империя, что создавалась тысячи лет,', 'осталась лишь в воспоминаниях…', '', '', ''),
    // Undead Hordes
    ('Поглощенная ненавистью и страданием,', 'Мортис создала армию мертвецов.', 'Где теперь ее возлюбленный Галлеан?',
    'В каком уголке Невендаара бродит его', 'душа? Почему не возвращается к ней?', 'Как его воскресить? И когда духи',
    'открыли ей существование святого', 'отрока, Мортис поклялась, что она', 'воссоединится со своим возлюбленным,',
    'даже если для этого ей придется', 'утопить весь мир в крови…'),
    // Legions Of The Damned
    ('', '', '', '', '', '', '', '', '', '', ''),
    // Mountain Clans
    ('', '', '', '', '', '', '', '', '', '', ''),
    // Elven Alliance
    ('', '', '', '', '', '', '', '', '', '', '')
    //
    );

type
  TCreatureEnum = (crNone,
    // The Empire Capital Guardian
    crMyzrael,
    // The Empire Warrior Leader
    crPegasusKnight,
    // The Empire Scout Leader
    crRanger,
    // The Empire Mage Leader
    crArchmage,
    // The Empire Fighters
    crSquire,
    // The Empire Ranged Attack Units
    crArcher,
    // The Empire Mage Units
    crApprentice,
    // The Empire Support units
    crAcolyte,

    // Undead Hordes Capital Guardian
    crAshgan,
    // Undead Hordes Warrior Leader
    crDeathKnight,
    // Undead Hordes Scout Leader
    crNosferat,
    // Undead Hordes Mage Leader
    crLichQueen,
    // Undead Hordes Fighters
    crFighter,
    // Undead Hordes Ranged Attack Units
    crGhost,
    // Undead Hordes Mage Units
    crInitiate,
    // Undead Hordes Support units
    crWyvern,

    // Legions Of The Damned Capital Guardian
    crAshkael,
    // Legions Of The Damned Warrior Leader
    crDuke,
    // Legions Of The Damned Scout Leader
    crCounselor,
    // Legions Of The Damned Mage Leader
    crArchDevil,
    // Legions Of The Damned Fighters
    crPossessed,
    // Legions Of The Damned Ranged Attack Units
    crGargoyle,
    // Legions Of The Damned Mage Units
    crCultist,
    // Legions Of The Damned Support units
    crDevil,

    // Goblins and Orcs
    crGoblin, crGoblin_Archer, crOrc,
    // Spiders
    crGiantSpider,
    // Wolves
    crWolf
    //
    );

type
  TReachEnum = (reAny, reAdj, reAll);

type
  TSourceEnum = (seWeapon, seLife, seMind, seDeath, seAir, seEarth, seFire, seWater);

const
  SourceName: array [TSourceEnum] of string = ('Оружие', 'Жизнь', 'Разум', 'Смерть', 'Воздух', 'Земля', 'Огонь', 'Вода');

type
  TRaceCharGroup = (cgGuardian, cgLeaders, cgCharacters);

type
  TRaceCharKind = (ckWarrior, ckScout, ckMage); // ckSupport

const
  ckGuardian = ckMage;

type
  AttackEnum = (atLongSword, atCrossbow, atDrainLife, atHealing, atParalyze, atPoison);

const
  AttackName: array [AttackEnum] of string = ('Длинный Меч', 'Арбалет', 'Выпить Жизнь', 'Исцеление', 'Паралич', 'Яд');

const
  Characters: array [reTheEmpire .. reLegionsOfTheDamned] of array [TRaceCharGroup] of array [TRaceCharKind] of TCreatureEnum = (
    // The Empire Capital Guardian
    ((crNone, crNone, crMyzrael),
    // The Empire Leaders
    (crPegasusKnight, crRanger, crArchmage),
    // The Empire Characters
    (crSquire, crArcher, crApprentice)),
    //
    // Undead Hordes Capital Guardian
    ((crNone, crNone, crAshgan),
    // Undead Hordes Leaders
    (crDeathKnight, crNosferat, crLichQueen),
    // Undead Hordes Characters
    (crFighter, crGhost, crInitiate)),
    //
    // Legions Of The Damned Capital Guardian
    ((crNone, crNone, crAshkael),
    // Legions Of The Damned Leaders
    (crDuke, crCounselor, crArchDevil),
    // Legions Of The Damned Characters
    (crPossessed, crGargoyle, crCultist))
    //
    );

  {
    Ардоберт
    Верок
    Винфрид
    Виргилий
    Вольфгар
    Гелдвин
    Герберт
    Гильберт
    Гоар
    Годфруа
    Гюнтер
    Дагар
    Зардомас
    Кловис
    Конрад
    Лотар
    Мерло
    Нигель
    Отон
    Райнон
    Ренар
    Роллон
    Сэйвери
    Тефас
    Туэдон
    Урбан
    Эдвин
    Эмери
    Юрон
    Юстин
  }

  {
    Аликс
    Алкима
    Вера
    Золиан
    Изуэль
    Крона
    Линуаль
    Мантия
    Паула
    Тамара
    Туэрас
    Фара
    Федра
    Цезария
    Ютта
  }

  {
    А? Чего изволите?
    В моей лавке вы можете купить лучший эль и лучшее оружие в округе!
    Взгляни на мой товар. Возможно, тебе что-то будет полезно.
    Во время войны дела всегда идут хорошо.
    Все, что нужно воинам.
    Все, что ты видишь, выставлено на продажу.
    Вы не заставите мне расстаться со своими товарами! Вы заплатите золотом, как и все остальные.
    Да? Конечно, у меня он есть.
    Демоны забрали большую часть наших товаров. Если у вас нет золота, мы скорее умрем, чем расстанемся с остальными.
    Деньги не пахнут.
    Добро пожаловать, взгляните на мои товары.
    Добро пожаловать, путешественник! Не может быть, чтобы ни один из моих товаров не привлек твоего внимания.
    Добрый день, эльфы! Сейчас мы можем предложить вам только самые простые товары. Спасибо за это гномам.
    Думаю, мы сможем договориться.
    Думаю, я могу тебе помочь.
    Здесь вы найдете любые эликсиры по самым низким ценам.
    Здесь есть предметы, которые могут пригодиться воину.
    К каждой покупке прилагается бесплатный череп.
    Карманники и воры будут наказаны!
    Место встречи лучших ремесленников этой земли.
    Мне не важно, на чьей вы стороне, мне важно то, что у вас есть деньги.
    Может, они и похожи на обычные самоцветы, но в битвы вы почувствуете разницу.
    Мои снадобья и свитки могут оказаться тебе полезными.
    Мой товар пригодится тебе в поисках
    Мы жены рыцарей, отправившихся на войну. Покупая у нас, вы помогаете кормить наши семьи.
    Мы не верим чужакам. Покупайте, что хотите, и уходите, пока не зашло солнце.
    Мы не просто какая-то там таверна!
    Мы подберем все ценные предметы после того, как пройдет армия.
    Мы приобрели у таких же путешественников, как вы, несколько интересных вещиц.
    Мы продаем и покупаем за большие деньги, милорд…
    Мы продаем не только корм для животных.
    Не спрашивай меня, где я это достал, просто радуйся, что получаешь так дешево.
    Покупайте то, что вам нужно, сегодня. Завтра, возможно, нас уже не будет здесь.
    Покупайте, что вам нужно, и покиньте эти умирающие земли.
    После того, как мы закончим войну, мое имя войдет в историю. У меня есть товары для ваших воинов.
    Приветствую вас, братья. Чем я могу помочь вам в ваших странствиях?
    Так как ты не интересуешься тем, каким образом мне все это досталось… Покупай все, что тебе хочется!
    Ты можешь купить все, что у меня есть.
    У вас деньги – у меня товар. Нет денег – нет товара! Все очень просто.
    У меня есть кое-что интересное на продажу…
    У меня лучший товар в стране
    У меня нет ничего особенного, зато ваши войска не умрут с голоду.
    У меня продается все… И все имеет свою цену.
    У нас богатый выбор самых разных товаров.
    У нас есть товар на любой вкус!
    У тебя острый глаз. Мы договоримся.
    Чем я могу помочь, странник?
    Что вы ищете?
    Эль закончился, но мы можем продать множество других интересных вещей.
    Эль и все необходимое по разумной цене!
    Эльфы? Покупайте быстрее, они убьют меня, если вас заметят!
    Я вижу, вы умеете отличить редкий товар. Пожалуйста, заходите.
    Я вижу, вы хотите что-то купить, значит, вы пришли по адресу.
    Я еще жив!
    Я могу протянуть вам руку помощи, если вы протянете мне руку с золотом.
    Я не торгуюсь, даже не пытайтесь.
    Я продаю все… За деньги.
    Я продаю эликсиры. Я не моргаю. Я делаю то, что мне говорят. Я поклоняюсь Бетрезену.
    Я специализируюсь на драгоценных камнях и ювелирных изделиях, выбирай то, что тебе хочется.
    Я только отстроил свою лавку после последней войны. Пожалуйста, ничего не разбейте.
  }

  {
    Библиотека магии, стоящая на снегу и льду.
    Вас интересуют заклинания?
    Взгляни на мой товар, возможно, что-то будет тебе полезно.
    Все дело во времени, которое нужно телу, чтобы догнать разум.
    Все заклинания проверены на жертвах!
    Вы вряд ли можете представить, какая сила здесь продается.
    Вы и вправду думаете, что у вас хватит мозгов понять эти идеи? Хорошо, посмотрим.
    Вы хотите пополнить ману? Я научу вас, как это сделать.
    Вы хотите узнать, на что мы потратили годы исследований?
    Да здравствует Небесный Отец!
    Да, я вижу, что ты достоин моей магии.
    Дорогие покупатели! Демоны вынудили меня бежать, но теперь мы открыты. Вызванный мной слуга вас обслужит.
    Если вас интересует темная магия, мы можем обеспечить вас весьма внушительным арсеналом.
    Если вы ищете защитную магию, вы пришли в нужное место.
    Иди сюда и разбей своих врагов!
    Конечно, я обучу вас заклинаниям. Но я не верну денег, если ваш неподготовленный разум не сможет усвоить эти знания.
    Мои заклинания помогут тебе в поисках.
    Моя школа магии обучит вас чарам, дабы вы передвигались по земле незаметно, оставляя преследователей далеко позади.
    Мы еще не открылись, но у меня есть пара заклинаний, который я мог бы продать.
    Мы можем научить вас темным заклинаниям.
    Нассс не волнуют дела сссмертных. Не трогайте нассссс.
    Небесная магия для любого кармана
    Поймать дракончика и взять его в руку – вот что я предлагаю.
    Разве вы не видите, что я работаю?
    Сам воздух подчиняется мне, и я могу научить тебя тому же.
    Сегодня у меня необычный приступ щедрости
    Силами природы можно управлять с помощью простых жестов. Я могу доказать это.
    У меня есть много редких заклинаний, которым я могу обучить вас за разумную плату.
    У меня есть мощные заклинания за разумную цену
    У меня есть новые мощные заклинания, которые могут быть тебе полезны.
    У меня есть различные заклинания, которым я могу вас обучить.
    У меня есть эффективные заклинания по разумным ценам.
    У меня много дьявольской магии.
    У меня самые мощные заклинания в округе
    У нас есть много заклятий, которым вы можете научиться. Они вам обязательно пригодятся.
    Эти заклятья можно приобрести, заплатив золотом и сохранив при этом ману.
    Я думаю, ты что-нибудь найдешь в моей магической библиотеке
    Я могу помочь тебе с изгнанием демонов!
    Я специализируюсь на заклятиях вызова.
  }

  {
    Вам нужны верные наемники?
    Воля моего тролля сломлена. Он будет служить твоей воле.
    Лучше нанять их – иначе они начнут охотиться за тобой!
    Люди гор изучают искусство войны…
    Мои варвары – самые грозные воины на этой земле.
    Мои воины приведут вас к победе!
    Мои кентавры-копейщики во всем мне повинуются
    Мои наемники присоединятся к твоей армии… За плату.
    Мои солдаты – крепкие и закаленные в боях парни.
    Мы заставим их работать на вас! Деньги вперед!
    Мы пойдем с тобой. За плату.
    Мы храним верность деньгам, а не силе.
    Нам неинтересны подробности. Мы хотим денег.
    Не думайте, что я верну вам деньги, если вы погубите их.
    Обучены специально для вас! Полностью в вашем распоряжении, готовы выполнить любое ваше желание – за плату. Мы не возвращаем деньги после покупки.
    Они не красавцы, но хороши в деле. Не смотрите им в глаза!
    Отличные рабы. Интересуешься?
    Пощадите моих людей, и мы присоединимся к вам. Вы останетесь довольны.
    Тебе нужно пополнить армию?
    Только здесь ты получишь столько силы и могущества.
    У меня самые лучшие солдаты в округе.
    Эй! Мои звери всегда готовы к бою.
    Эта свежесть и молодость только для тебя! Они твои, можешь делать с ними все, что хочешь, за деньги, конечно. Купленный товар возврату не подлежит…
    Я могу воскресить мертвых для вашей армии.
    Я могу предложить свирепых тварей, которые будут служить вам.
    Я научил этих зеленых олухов подчиняться моим командам. Они могут подчиняться и вам.
    Я нашел их на дальнем севере. Они дружелюбны, если хорошо им платить.
    Я умею вызывать элементалей воздуха, так что если вам хватит денег, можете нанять моих учеников.
  }

  {
    Все воины-варвары обучались именно здесь.
    Входите, трусы, я сделаю из вас героев!
    Вы и вправду готовы пройти через этот ад?
    Вы станете истинными защитниками королевства.
    Гномы перехитрили вас? Ну, теперь и вы можете получить урок от наставников, которые обучали их военному делу. За плату…
    Грукк сделает из крестьян настоящих мужчин!
    Давайте их сюда! Они вернутся к вам другими людьми.
    Заходи, я сделаю достойных бойцов из твоих слабаков.
    Здесь тренировались лучшие воины страны!
    Краааак! О боже, это не твоя шея только что сломалась?
    Любой может прийти и научиться искусству боя.
    Мы обучим их искусству Севера.
    Пожалеешь розгу, испортишь солдата
    После того, как ваши воины пройдут все мои испытания, они будут готовы сразиться с любым врагом.
    Похоже, вы отличные солдаты. Обучение не должно занять много времени.
    Путешествие их утомило, но я могу поработать с ними.
    Спустя короткое время вам не будет равных на этой земле.
    Хоть по мне этого и не скажешь, я прошел три войны и могу быстро привести вашу армию в порядок.
    Чем больше золота ты мне дашь, тем сильнее станешь.
    Эй, парни! Вам нужно обучение?
    Я обучу твоих воинов за плату.
    Я подготовлю их к сражению в мгновение ока!
    Я превращу ваших солдат в ходячие осадные орудия.
    Я работал и с плохими бойцами, и с хорошими, и все они справлялись с большим успехом.
  }

type
  TCreature = record
    Active: Boolean;
    Enum: TCreatureEnum;
    ResEnum: TResEnum;
    Name: string;
    MaxHitPoints: Integer;
    HitPoints: Integer;
    Initiative: Integer;
    ChancesToHit: Integer;
    Leadership: Integer;
    Level: Integer;
    Damage: Integer;
    Armor: Integer;
    Heal: Integer;
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
  end;

type
  TCreatureBase = record
    ResEnum: TResEnum;
    Name: string;
    HitPoints: Integer;
    Initiative: Integer;
    ChancesToHit: Integer;
    Leadership: Integer;
    Level: Integer;
    Damage: Integer;
    Armor: Integer;
    Heal: Integer;
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
  end;

procedure ClearCreature(var ACreature: TCreature);
procedure AssignCreature(var ACreature: TCreature; const I: TCreatureEnum);
function GetCharacter(const I: TCreatureEnum): TCreatureBase;

implementation

uses
  System.SysUtils;

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (ResEnum: reNone; Name: ''; HitPoints: 0; Initiative: 0; ChancesToHit: 0; Leadership: 0; Level: 0; Damage: 0; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj;),

    // Myzrael
    (ResEnum: reMyzrael; Name: 'Мизраэль'; HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAll;),
    // Pegasus Knight
    (ResEnum: rePegasusKnight; Name: 'Рыцарь на Пегасе'; HitPoints: 150; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;),
    // Ranger
    (ResEnum: reRanger; Name: 'Следопыт'; HitPoints: 90; Initiative: 60; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 40; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny;),
    // Archmage
    (ResEnum: reArchmage; Name: 'Архимаг'; HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30; Armor: 0; Heal: 0;
    SourceEnum: seAir; ReachEnum: reAll;),
    // Squire
    (ResEnum: reSquire; Name: 'Сквайр'; HitPoints: 100; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj;),
    // Archer
    (ResEnum: reArcher; Name: 'Лучник'; HitPoints: 45; Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny;),
    // Apprentice
    (ResEnum: reApprentice; Name: 'Ученик'; HitPoints: 35; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seAir; ReachEnum: reAll;),
    // Acolyte
    (ResEnum: reAcolyte; Name: 'Служка'; HitPoints: 50; Initiative: 10; ChancesToHit: 100; Leadership: 0; Level: 1; Damage: 0; Armor: 0; Heal: 20;
    SourceEnum: seAir; ReachEnum: reAny;),

    // Ashgan
    (ResEnum: reMyzrael; Name: 'Ашган'; HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAll;),
    // Death Knight
    (ResEnum: rePegasusKnight; Name: 'Рыцарь Смерти'; HitPoints: 150; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50; Armor: 0;
    Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;),
    // Nosferat
    (ResEnum: reRanger; Name: 'Носферату'; HitPoints: 90; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 10; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAny;),
    // Lich Queen
    (ResEnum: reArchmage; Name: 'Королева Личей'; HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30; Armor: 0;
    Heal: 0; SourceEnum: seFire; ReachEnum: reAll;),
    // Fighter
    (ResEnum: reSquire; Name: 'Воин'; HitPoints: 120; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj;),
    // Ghost
    (ResEnum: reArcher; Name: 'Привидение'; HitPoints: 45; Initiative: 20; ChancesToHit: 65; Leadership: 0; Level: 1; Damage: 0; Armor: 0; Heal: 0;
    SourceEnum: seMind; ReachEnum: reAny;),
    // Initiate
    (ResEnum: reApprentice; Name: 'Адепт'; HitPoints: 45; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAll;),
    // Wyvern
    (ResEnum: reAcolyte; Name: 'Виверна'; HitPoints: 225; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAll;),

    // Ashkael
    (ResEnum: reMyzrael; Name: 'Ашкаэль'; HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAll;),
    // Duke
    (ResEnum: rePegasusKnight; Name: 'Герцог'; HitPoints: 150; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50; Armor: 0;
    Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;),
    // Counselor
    (ResEnum: reRanger; Name: 'Советник'; HitPoints: 90; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 40; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny;),
    // Arch-Devil
    (ResEnum: reArchmage; Name: 'Дьявол'; HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30; Armor: 0; Heal: 0;
    SourceEnum: seFire; ReachEnum: reAll;),
    // Possessed
    (ResEnum: reSquire; Name: 'Одержимый'; HitPoints: 120; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj;),
    // Gargoyle
    (ResEnum: reArcher; Name: 'Горгулья'; HitPoints: 90; Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 40; Armor: 40; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny;),
    // Cultist
    (ResEnum: reApprentice; Name: 'Культист'; HitPoints: 45; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seFire; ReachEnum: reAll;),
    // Devil
    (ResEnum: reAcolyte; Name: 'Черт'; HitPoints: 170; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 50; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj;),

    // Goblin
    (ResEnum: reGoblin; Name: 'Гоблин'; HitPoints: 50; Initiative: 30; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAdj;),
    // Goblin Archer
    (ResEnum: reGoblinArcher; Name: 'Гоблин-лучник'; HitPoints: 40; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0;
    Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;),
    // Orc
    (ResEnum: reOrc; Name: 'Орк'; HitPoints: 200; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj;),

    // Spider
    (ResEnum: reGiantSpider; Name: 'Гигантский Паук'; HitPoints: 420; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;),

    // Wolf
    (ResEnum: reWolf; Name: 'Волк'; HitPoints: 180; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj;)
    //
    );

procedure ClearCreature(var ACreature: TCreature);
begin
  with ACreature do
  begin
    Active := False;
    Enum := crNone;
    ResEnum := reNone;
    Name := '';
    MaxHitPoints := 0;
    HitPoints := 0;
    Initiative := 0;
    ChancesToHit := 0;
    Leadership := 0;
    Level := 0;
    Damage := 0;
    Armor := 0;
    Heal := 0;
    SourceEnum := seWeapon;
    ReachEnum := reAdj;
  end;
end;

procedure AssignCreature(var ACreature: TCreature; const I: TCreatureEnum);
begin
  with ACreature do
  begin
    Active := I <> crNone;
    Enum := I;
    ResEnum := CreatureBase[I].ResEnum;
    Name := CreatureBase[I].Name;
    MaxHitPoints := CreatureBase[I].HitPoints;
    HitPoints := CreatureBase[I].HitPoints;
    Initiative := CreatureBase[I].Initiative;
    ChancesToHit := CreatureBase[I].ChancesToHit;
    Leadership := CreatureBase[I].Leadership;
    Level := CreatureBase[I].Level;
    Damage := CreatureBase[I].Damage;
    Armor := CreatureBase[I].Armor;
    Heal := CreatureBase[I].Heal;
    SourceEnum := CreatureBase[I].SourceEnum;
    ReachEnum := CreatureBase[I].ReachEnum;
  end;
end;

function GetCharacter(const I: TCreatureEnum): TCreatureBase;
begin
  Result := CreatureBase[I];
end;

end.
