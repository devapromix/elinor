unit DisciplesRL.Creatures;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

uses
  DisciplesRL.Resources;

type
  TRaceEnum = (reNeutrals, reTheEmpire, reUndeadHordes, reLegionsOfTheDamned,
    reMountainClans, reElvenAlliance);

const
  Races = [reTheEmpire, reUndeadHordes, reLegionsOfTheDamned];

const
  RaceName: array [TRaceEnum] of string = ('Нейтралы', 'Защитники Империи',
    'Орды Нежити', 'Легионы Проклятых', 'Горные Кланы', 'Эльфийский Союз');
  RaceTerrain: array [TRaceEnum] of TResEnum = (reNeutralTerrain,
    reTheEmpireTerrain, reUndeadHordesTerrain, reLegionsOfTheDamnedTerrain,
    reNeutralTerrain, reNeutralTerrain);

const
  RaceDescription: array [TRaceEnum] of array [0 .. 10] of string =
    (('', '', '', '', '', '', '', '', '', '', ''),
    // The Empire
    ('Империя пришла в упадок. Больше',
    'не радуют глаз возделанные поля и цве-',
    'тущие сады. Землю раздирают склоки и',
    'раздоры. Аристократы и разбойничьи', 'атаманы провозгласили собственные',
    'королевства. Старейшины всматривают-',
    'ся в небеса, взывая к Небесному Отцу.',
    'Но он глух к их просьбам и молитвам.', 'Некогда мирная, гордая и единая',
    'Империя, что создавалась тысячи лет,', 'осталась лишь в воспоминаниях…'),
    // Undead Hordes
    ('Поглощенная ненавистью и страданием,', 'Мортис создала армию мертвецов.',
    'Где теперь ее возлюбленный Галлеан?',
    'В каком уголке Невендаара бродит его',
    'душа? Почему не возвращается к ней?', 'Как его воскресить? И когда духи',
    'открыли ей существование святого', 'отрока, Мортис поклялась, что она',
    'воссоединится со своим возлюбленным,', 'даже если для этого ей придется',
    'утопить весь мир в крови…'),
    // Legions Of The Damned
    ('И снова земные слуги Бетрезена бродят',
    'миром Невендаар, сея хаос и разруху.',
    'Им осталось провести последний ритуал',
    'и даровать Бетрезену неограниченную',
    'свободу. Десять лет назад они потерпе-',
    'ли поражение и были заперты в Горном', 'Храме… И вот десять лет истекли:',
    'теперь ничто не мешает легионам', 'снова попытаться совершить ритуал,',
    'который освободит Бетрезена раз и', 'навсегда…'),
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
    // The Empire Thief Leader
    crThief,
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
  TSourceEnum = (seWeapon, seLife, seMind, seDeath, seAir, seEarth,
    seFire, seWater);

const
  SourceName: array [TSourceEnum] of string = ('Оружие', 'Жизнь', 'Разум',
    'Смерть', 'Воздух', 'Земля', 'Огонь', 'Вода');

type
  TRaceCharGroup = (cgGuardian, cgLeaders, cgCharacters);

type
  TRaceCharKind = (ckWarrior, ckScout, ckMage); // ckSupport, ckThief

const
  ckGuardian = ckMage;

type
  AttackEnum = (atLongSword, atCrossbow, atDrainLife, atHealing, atParalyze,
    atPoison);

const
  AttackName: array [AttackEnum] of string = ('Длинный Меч', 'Арбалет',
    'Выпить Жизнь', 'Исцеление', 'Паралич', 'Яд');

const
  Characters: array [reTheEmpire .. reLegionsOfTheDamned] of array
    [TRaceCharGroup] of array [TRaceCharKind] of TCreatureEnum = (
    // The Empire Capital Guardian
    ((crNone, crNone, crMyzrael),
    // The Empire Leaders
    (crPegasusKnight, crRanger, crThief), // crArchmage),
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
{$REGION texts}
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
{$ENDREGION texts}

type
  TCrSoundEnum = (csHit, csDeath, csAttack);

type
  TCreatureBase = record
    ResEnum: TResEnum;
    Name: string;
    Description: array [0 .. 2] of string;
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
    Gold: Integer;
    Sound: array [TCrSoundEnum] of TMusicEnum;
  end;

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
    Experience: Integer;
    Damage: Integer;
    Armor: Integer;
    Heal: Integer;
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
    function IsLeader(): Boolean;
    class procedure Clear(var ACreature: TCreature); static;
    class function Character(const I: TCreatureEnum): TCreatureBase; static;
    class procedure Assign(var ACreature: TCreature;
      const I: TCreatureEnum); static;
  end;

implementation

uses
{$IFDEF FPC}
  SysUtils;
{$ELSE}
  System.SysUtils;
{$ENDIF}

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (ResEnum: reNone; Name: ''; Description: ('', '', ''); HitPoints: 0;
    Initiative: 0; ChancesToHit: 0; Leadership: 0; Level: 0; Damage: 0;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0),

    // Myzrael
    (ResEnum: reMyzrael; Name: 'Мизраэль';
    Description: ('Мизраэль был послан, чтобы помочь',
    'Империи людей в их священной мис-', 'сии. Он охраняет столицу от врагов.');
    HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1;
    Damage: 250; Armor: 50; Heal: 0; SourceEnum: seLife; ReachEnum: reAll;),
    // Pegasus Knight
    (ResEnum: rePegasusKnight; Name: 'Рыцарь на Пегасе';
    Description: ('Оседлавший пегаса рыцарь - это бла-',
    'городный воин, чей крылатый скакун', 'возносит его над полями и лесами.');
    HitPoints: 150; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 50; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmSwordAttack);),
    // Ranger
    (ResEnum: reRanger; Name: 'Следопыт';
    Description: ('Следопыты путешествуют быстро и хо-',
    'рошо знают королевство, поэтому ко-',
    'роль часто посылает их в разведку.'); HitPoints: 90; Initiative: 60;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 40; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmBowAttack);),
    // Archmage
    (ResEnum: reArchmage; Name: 'Архимаг';
    Description: ('Мастер магии, архимаг - единственный',
    'в Империи полководец, который уме-', 'ет испольовать свитки и посохи.');
    HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seAir; ReachEnum: reAll; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack);),
    // Thief
    (ResEnum: reArchmage; Name: 'Вор';
    Description: ('Опытные обманщики и воры, легко',
    'пробираются в тыл врага, и служат', 'Империи, добывая важные сведения.');
    HitPoints: 100; Initiative: 60; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmDaggerAttack);),
    // Squire
    (ResEnum: reSquire; Name: 'Сквайр';
    Description: ('Сквайр доблестно защищает в бою',
    'своих более слабых соотечественников,',
    'держа противников на расстоянии меча.'); HitPoints: 100; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack);),
    // Archer
    (ResEnum: reArcher; Name: 'Лучник';
    Description: ('Стрелы лучника успешно поражают',
    'врагов, которые укрываются за спинами', 'своих более сильных соратников.');
    HitPoints: 45; Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 25; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 40; Sound: (mmHumHit, mmHumDeath, mmBowAttack);),
    // Apprentice
    (ResEnum: reApprentice; Name: 'Ученик';
    Description: ('Ученик мага атакует противников',
    'с большого расстояния, обрушивая', 'на них молнии.'); HitPoints: 35;
    Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15;
    Armor: 0; Heal: 0; SourceEnum: seAir; ReachEnum: reAll; Gold: 60;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack);),
    // Acolyte
    (ResEnum: reAcolyte; Name: 'Служка';
    Description: ('Обученная искусству исцеления служка',
    'может лечить раненых соратников,', 'по очереди перевязывая раны каждого.');
    HitPoints: 50; Initiative: 10; ChancesToHit: 100; Leadership: 0; Level: 1;
    Damage: 0; Armor: 0; Heal: 20; SourceEnum: seAir; ReachEnum: reAny;
    Gold: 50),

    // Ashgan
    (ResEnum: reAshgan; Name: 'Ашган';
    Description: ('Ашган, несущий чуму, был некогда',
    'верховным священником Алкмаара.', 'Он не оставляет столицу без охраны.');
    HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1;
    Damage: 250; Armor: 50; Heal: 0; SourceEnum: seLife; ReachEnum: reAll;),
    // Death Knight
    (ResEnum: rePegasusKnight; Name: 'Рыцарь Смерти';
    Description: ('Сильнейшие и благороднейшие воины',
    'королевства Алкмаар были возвращены',
    'Мортис из небытия Рыцарями Смерти.'); HitPoints: 150; Initiative: 50;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack);),
    // Nosferat
    (ResEnum: reRanger; Name: 'Носферату';
    Description: ('Первые вампиры Алкмаара, отринувшие',
    'Всеотца и поклявшиеся в верности Мор-',
    'тис в обмен на власть над смертью.'); HitPoints: 90; Initiative: 50;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 10; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmNosferatAttack);),
    // Lich Queen
    (ResEnum: reArchmage; Name: 'Королева Личей';
    Description: ('Жрицы культа смерти, процветавшего в',
    'Алкмааре, вернулись по воле Мортис', 'безжалостными Королевами личей.');
    HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmLichQueenAttack);),
    // туг Своей властью Мортис вернула лучших из лучших в мир живых, чтобы те действовали хитростью там, где недостаточно одной лишь грубой силы.
    // Fighter
    (ResEnum: reSquire; Name: 'Воин';
    Description: ('Услышав зов Мортис, безропотно',
    'встают в строй мертвые воины.', 'Они не знают ни страха, ни жалости.');
    HitPoints: 120; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 25; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 50; Sound: (mmHumHit, mmHumDeath, mmSwordAttack);),
    // Ghost
    (ResEnum: reArcher; Name: 'Привидение';
    Description: ('Привидения - это темные души, чье зло',
    'навсегда приковало их к миру живых.', ''); HitPoints: 45; Initiative: 20;
    ChancesToHit: 65; Leadership: 0; Level: 1; Damage: 20; Armor: 0; Heal: 0;
    SourceEnum: seMind; ReachEnum: reAny; Gold: 50;
    Sound: (mmGhostHit, mmGhostDeath, mmGhostAttack);),
    // Initiate
    (ResEnum: reApprentice; Name: 'Адепт';
    Description: ('Адепты обучены нести чуму и', 'смерть армиям живых во славу',
    'своей богини Мортис.'); HitPoints: 45; Initiative: 40; ChancesToHit: 80;
    Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0; SourceEnum: seDeath;
    ReachEnum: reAll; Gold: 60; Sound: (mmHumHit, mmHumDeath, mmStaffAttack);),
    // Wyvern
    (ResEnum: reAcolyte; Name: 'Виверна';
    Description: ('Чародеи воскрешают мертвых драконов,',
    'тем самым создавая виверн,', 'которые сражаются в рядах армии мертвых.');
    HitPoints: 225; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 25; Armor: 0; Heal: 0; SourceEnum: seDeath; ReachEnum: reAll;
    Gold: 100),

    // Ashkael
    (ResEnum: reAshkael; Name: 'Ашкаэль';
    Description: ('Командир 80 адских когорт, Ашкаэль был',
    'избран Бетрезеном для защиты столицы Легионов,',
    'никогда не оставляя её без защиты.'); HitPoints: 900; Initiative: 90;
    ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAll;),
    // Duke
    (ResEnum: rePegasusKnight; Name: 'Герцог';
    Description: ('Воинственный герцог ведет демонов',
    'в битву, сжимая меч в окровавленных', 'руках.'); HitPoints: 150;
    Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack);),
    // Counselor
    (ResEnum: reRanger; Name: 'Советник';
    Description: ('Советник ведёт авангард сил Легионов.',
    'Он путешествует по землям Невендаара', 'с высокой скоростью.');
    HitPoints: 90; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 40; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Sound: (mmHumHit, mmHumDeath, mmBowAttack);),
    // Arch-Devil
    (ResEnum: reArchmage; Name: 'Архидьявол';
    Description: ('Архидьявол является владыкой магии;',
    'он обладает глубокими знаниями', 'о посохах и свитках.'); HitPoints: 65;
    Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30;
    Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack);),
    ///
    // Possessed
    (ResEnum: reSquire; Name: 'Одержимый';
    Description: ('Повелитель демонов поработил этих',
    'сильных телом крестьян для того,',
    'чтобы они сражались с ним в адских сражениях.'); HitPoints: 120;
    Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack);),
    // Gargoyle
    (ResEnum: reArcher; Name: 'Горгулья';
    Description: ('Каменная кожа гаргулий поглощает',
    'большую часть получаемого урона,',
    'делая из него прекрасного защитного юнита.'); HitPoints: 90;
    Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 40;
    Armor: 40; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny; Gold: 80),
    // Cultist
    (ResEnum: reApprentice; Name: 'Культист';
    Description: ('Еретики Империи, они взывают',
    'к адским силам, дабы призвать', 'огонь на всех своих врагов в битве.');
    HitPoints: 45; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 60; Sound: (mmHumHit, mmHumDeath, mmStaffAttack);),
    // Devil
    (ResEnum: reAcolyte; Name: 'Чёрт';
    Description: ('Это нечестивое создание', 'держит земли в страхе во имя его',
    'Тёмного Повелителя Бетрезена.'); HitPoints: 170; Initiative: 35;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 50; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 100),

    // Goblin
    (ResEnum: reGoblin; Name: 'Гоблин'; Description: ('', '', '');
    HitPoints: 50; Initiative: 30; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seLife; ReachEnum: reAdj;
    Gold: 0; Sound: (mmGoblinHit, mmGoblinDeath, mmDaggerAttack);),
    // Goblin Archer
    (ResEnum: reGoblinArcher; Name: 'Гоблин-лучник'; Description: ('', '', '');
    HitPoints: 40; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 0; Sound: (mmGoblinHit, mmGoblinDeath, mmBowAttack);),
    // Orc
    (ResEnum: reOrc; Name: 'Орк'; Description: ('', '', ''); HitPoints: 200;
    Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmOrcHit, mmOrcDeath, mmAxeAttack);),

    // Spider
    (ResEnum: reGiantSpider; Name: 'Гигантский Паук';
    Description: ('Сильный яд гигантского паука',
    'полностью парализует жертву,', 'не давая ей убежать.'); HitPoints: 420;
    Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmSpiderHit, mmSpiderDeath, mmSpiderAttack);),

    // Wolf
    (ResEnum: reWolf; Name: 'Волк';
    Description: ('Волки испокон веков бродят по этим',
    'землям в поисках добычи. Смерть ждет',
    'воинов, которые столкнутся с ними.'); HitPoints: 180; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmWolfHit, mmWolfDeath, mmWolfAttack);)
    //
    );

  { TCreature }

class procedure TCreature.Assign(var ACreature: TCreature;
  const I: TCreatureEnum);
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
    Experience := 0;
    Damage := CreatureBase[I].Damage;
    Armor := CreatureBase[I].Armor;
    Heal := CreatureBase[I].Heal;
    SourceEnum := CreatureBase[I].SourceEnum;
    ReachEnum := CreatureBase[I].ReachEnum;
  end;
end;

class function TCreature.Character(const I: TCreatureEnum): TCreatureBase;
begin
  Result := CreatureBase[I];
end;

class procedure TCreature.Clear(var ACreature: TCreature);
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
    Experience := 0;
    Damage := 0;
    Armor := 0;
    Heal := 0;
    SourceEnum := seWeapon;
    ReachEnum := reAdj;
  end;
end;

function TCreature.IsLeader(): Boolean;
var
  Race: TRaceEnum;
  CharKind: TRaceCharKind;
begin
  Result := False;
  for Race := Low(Characters) to High(Characters) do
    for CharKind := Low(Characters[Race][cgLeaders])
      to High(Characters[Race][cgLeaders]) do
      if Enum = Characters[Race][cgLeaders][CharKind] then
        Exit(True);
end;

end.
