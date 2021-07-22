unit DisciplesRL.Creatures;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

uses
  DisciplesRL.Skills,
  DisciplesRL.Resources;

type
  TRaceEnum = (reNeutrals, reTheEmpire, reUndeadHordes, reLegionsOfTheDamned,
    reMountainClans, reElvenAlliance);

const
  Races = [reTheEmpire, reUndeadHordes, reLegionsOfTheDamned];

const
  RaceName: array [TRaceEnum] of string = ('Нейтралы', 'Защитники Империи',
    'Орды Нежити', 'Легионы Проклятых', 'Горные Кланы', 'Эльфийский Союз');

const
  RaceTerrain: array [TRaceEnum] of TResEnum = (reNeutralTerrain,
    reTheEmpireTerrain, reUndeadHordesTerrain, reLegionsOfTheDamnedTerrain,
    reNeutralTerrain, reNeutralTerrain);

type
  TSubRaceEnum = (reCustom, reHuman, reUndead, reHeretic, reDwarf, reElf,
    reGreenSkin, reDarkElf, reVampire, reGargoyle, reAnimal, reBarbarian,
    reDragon, reUndeadDragon, reMarsh, reWater);

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
    // The Empire Lord Leader
    crWarlord,
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
    // Undead Hordes Thief Leader
    crThug,
    // Undead Hordes Lord Leader
    crDominator,
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
    // Legions Of The Damned Thief Leader
    crRipper,
    // Legions Of The Damned Lord Leader
    crChieftain,
    // Legions Of The Damned Fighters
    crPossessed,
    // Legions Of The Damned Ranged Attack Units
    crGargoyle,
    // Legions Of The Damned Mage Units
    crCultist,
    // Legions Of The Damned Support units
    crDevil,

    // Goblins
    crGoblin, crGoblin_Archer, crGoblin_Elder,
    // Orcs
    crOrc,
    // Ogres
    crOgre,

    // Humans
    crPeasant, crManAtArms,

    // Undeads
    crGhoul, crDarkElfGast,

    // Spiders
    crGiantSpider,
    // Wolves
    crWolf
    //
    );

const
  LeaderWarrior: set of TCreatureEnum = [crPegasusKnight,
    crDeathKnight, crDuke];
  LeaderScout: set of TCreatureEnum = [crRanger, crNosferat, crCounselor];
  LeaderMage: set of TCreatureEnum = [crArchmage, crLichQueen, crArchDevil];
  LeaderThief: set of TCreatureEnum = [crThief, crThug, crRipper];
  LeaderLord: set of TCreatureEnum = [crWarlord, crDominator, crChieftain];

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
  TRaceCharKind = (ckWarrior, ckScout, ckMage, ckThief, ckLord, ck2);

type
  TLeaderWarriorActVar = (avRest, avRitual, avWar3);
  TLeaderThiefSpyVar = (svIntroduceSpy, svDuel, svPoison);

const
  ckGuardian = ckMage;

type
  TAttackEnum = (atLongSword, atBattleAxe, atDagger, atBow, atCrossbow,
    atDrainLife, atHealing, atParalyze, atPoison, atMagic, atClaws, atBites,
    atSpear, atStones, atPoisonousBreath, atDaggerOfShadows,
    atFireDagger, atClub);

type
  TCreatureSize = (szSmall, szBig);

const
  AttackName: array [TAttackEnum] of string = ('Длинный Меч', 'Боевой Топор',
    'Кинжал', 'Лук', 'Арбалет', 'Выпить Жизнь', 'Исцеление', 'Паралич', 'Яд',
    'Магия', 'Когти', 'Укус', 'Копье', 'Камни', 'Ядовитое Дыхание',
    'Кинжал Теней', 'Кинжал Пламени', 'Булава');

const
  Characters: array [reTheEmpire .. reLegionsOfTheDamned] of array
    [TRaceCharGroup] of array [TRaceCharKind] of TCreatureEnum = (
    // The Empire Capital Guardian
    ((crNone, crNone, crMyzrael, crNone, crNone, crNone),
    // The Empire Leaders
    (crPegasusKnight, crRanger, crArchmage, crThief, crWarlord, crNone), // ),
    // The Empire Characters
    (crSquire, crArcher, crAcolyte, crApprentice, crNone, crNone)), //
    //
    // Undead Hordes Capital Guardian
    ((crNone, crNone, crAshgan, crNone, crNone, crNone),
    // Undead Hordes Leaders
    (crDeathKnight, crNosferat, crLichQueen, crThug, crDominator, crNone), //
    // Undead Hordes Characters
    (crFighter, crGhost, crInitiate, crWyvern, crNone, crNone)), //
    //
    // Legions Of The Damned Capital Guardian
    ((crNone, crNone, crAshkael, crNone, crNone, crNone),
    // Legions Of The Damned Leaders
    (crDuke, crCounselor, crRipper, crArchDevil, crChieftain, crNone), //
    // Legions Of The Damned Characters
    (crPossessed, crGargoyle, crDevil, crCultist, crNone, crNone)) //
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
  TCreatureGender = (cgMale, cgFemale, cgNeuter, cgPlural);

type
  TCreatureBase = record
    Race: TRaceEnum;
    SubRace: TSubRaceEnum;
    ResEnum: TResEnum;
    Size: TCreatureSize;
    Name: array [0 .. 1] of string;
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
    Gender: TCreatureGender;
    AttackEnum: TAttackEnum;
    SkillEnum: TSkillEnum;
  end;

type

  { TCreature }

  TCreature = record
    Active: Boolean;
    Paralyze: Boolean;
    Enum: TCreatureEnum;
    ResEnum: TResEnum;
    Name: array [0 .. 1] of string;
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
    SkillEnum: TSkillEnum;
    function Alive: Boolean;
    function IsLeader(): Boolean;
    function GenderEnding(VerbForm: Byte = 0): string;
    class procedure Clear(var ACreature: TCreature); static;
    class function Character(const I: TCreatureEnum): TCreatureBase; static;
    class procedure Assign(var ACreature: TCreature;
      const I: TCreatureEnum); static;
    class function GetRandomEnum(const P, Position: Integer)
      : TCreatureEnum; static;
  end;

implementation

uses
  Math,
  DisciplesRL.Saga;

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (Race: reNeutrals; SubRace: reCustom; ResEnum: reNone; Size: szSmall;
    Name: ('', ''); Description: ('', '', ''); HitPoints: 0; Initiative: 0;
    ChancesToHit: 0; Leadership: 0; Level: 0; Damage: 0; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale; AttackEnum: atMagic;),

    // Myzrael
    (Race: reTheEmpire; SubRace: reCustom; ResEnum: reMyzrael; Size: szSmall;
    Name: ('Мизраэль', 'Мизраэля');
    Description: ('Мизраэль был послан, чтобы помочь',
    'Империи людей в их священной мис-', 'сии. Он охраняет столицу от врагов.');
    HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1;
    Damage: 250; Armor: 50; Heal: 0; SourceEnum: seLife; ReachEnum: reAll;
    Gold: 0; Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale;
    AttackEnum: atMagic;),
    // Pegasus Knight
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: rePegasusKnight;
    Size: szSmall; Name: ('Рыцарь на Пегасе', 'Рыцаря на Пегасе');
    Description: ('Оседлавший пегаса рыцарь - это бла-',
    'городный воин, чей крылатый скакун', 'возносит его над полями и лесами.');
    HitPoints: 150; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 50; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; SkillEnum: skFly;),
    // Ranger
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reRanger; Size: szSmall;
    Name: ('Следопыт', 'Следопыта');
    Description: ('Следопыты путешествуют быстро и хо-',
    'рошо знают королевство, поэтому ко-',
    'роль часто посылает их в разведку.'); HitPoints: 90; Initiative: 60;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 40; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atBow; SkillEnum: skBoots;),
    // Archmage
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reArchmage; Size: szSmall;
    Name: ('Архимаг', 'Архимага');
    Description: ('Мастер магии, архимаг - единственный',
    'в Империи полководец, который уме-', 'ет испольовать свитки и посохи.');
    HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seAir; ReachEnum: reAll; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic; SkillEnum: skWand;),
    // Thief
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reArchmage; Size: szSmall;
    Name: ('Вор', 'Вора'); Description: ('Опытные обманщики и воры, легко',
    'пробираются в тыл врага, и служат', 'Империи, добывая важные сведения.');
    HitPoints: 100; Initiative: 60; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atDagger; SkillEnum: skSpy;),
    // Warlord
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reArchmage; Size: szSmall;
    Name: ('Полководец', 'Полководца');
    Description: ('Полевой полководец короля служит',
    'Империи верой и правдой и беспощад-', 'но расправляется с ее врагами.');
    HitPoints: 120; Initiative: 55; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 40; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; SkillEnum: skTalisman;),
    // Squire
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reSquire; Size: szSmall;
    Name: ('Сквайр', 'Сквайра');
    Description: ('Сквайр доблестно защищает в бою',
    'своих более слабых соотечественников,',
    'держа противников на расстоянии меча.'); HitPoints: 100; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword;),
    // Archer
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reArcher; Size: szSmall;
    Name: ('Лучник', 'Лучника');
    Description: ('Стрелы лучника успешно поражают',
    'врагов, которые укрываются за спи-',
    'нами своих более сильных соратников.'); HitPoints: 45; Initiative: 60;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny; Gold: 40;
    Sound: (mmHumHit, mmHumDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atBow),
    // Apprentice
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reApprentice; Size: szSmall;
    Name: ('Ученик', 'Ученика');
    Description: ('Ученик мага атакует противников',
    'с большого расстояния, обрушивая', 'на них молнии.'); HitPoints: 35;
    Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15;
    Armor: 0; Heal: 0; SourceEnum: seAir; ReachEnum: reAll; Gold: 60;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic;),
    // Acolyte
    (Race: reTheEmpire; SubRace: reHuman; ResEnum: reAcolyte; Size: szSmall;
    Name: ('Служка', 'Служку');
    Description: ('Обученная искусству исцеления служка',
    'может лечить раненых соратников,', 'по очереди перевязывая раны каждого.');
    HitPoints: 50; Initiative: 10; ChancesToHit: 100; Leadership: 0; Level: 1;
    Damage: 0; Armor: 0; Heal: 20; SourceEnum: seAir; ReachEnum: reAny;
    Gold: 100; Sound: (mmHit, mmDeath, mmAttack); Gender: cgFemale;
    AttackEnum: atHealing;),

    // Ashgan
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: reAshgan; Size: szSmall;
    Name: ('Ашган', 'Ашгана'); Description: ('Ашган, несущий чуму, был некогда',
    'верховным священником Алкмаара.', 'Он не оставляет столицу без охраны.');
    HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1;
    Damage: 250; Armor: 50; Heal: 0; SourceEnum: seLife; ReachEnum: reAll;
    Gold: 0; Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale;
    AttackEnum: atMagic;),
    // Death Knight
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: rePegasusKnight;
    Size: szSmall; Name: ('Рыцарь Смерти', 'Рыцаря Смерти');
    Description: ('Сильнейшие и благороднейшие воины',
    'королевства Алкмаар были возвращены',
    'Мортис из небытия Рыцарями Смерти.'); HitPoints: 150; Initiative: 50;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; SkillEnum: skFly;),
    // Nosferat
    (Race: reUndeadHordes; SubRace: reVampire; ResEnum: reRanger; Size: szSmall;
    Name: ('Носферату', 'Носферату');
    Description: ('Первые вампиры Алкмаара, отринувшие',
    'Всеотца и поклявшиеся в верности Мор-',
    'тис в обмен на власть над смертью.'); HitPoints: 90; Initiative: 50;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 10; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmNosferatAttack); Gender: cgMale;
    AttackEnum: atDrainLife; SkillEnum: skBoots;),
    // Lich Queen
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: reArchmage;
    Size: szSmall; Name: ('Королева Личей', 'Королеву Личей');
    Description: ('Жрицы культа смерти, процветавшего в',
    'Алкмааре, вернулись по воле Мортис', 'безжалостными Королевами личей.');
    HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmLichQueenAttack); Gender: cgFemale;
    AttackEnum: atMagic; SkillEnum: skWand;),
    // Thug
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: reArchmage;
    Size: szSmall; Name: ('Головорез', 'Головореза');
    Description: ('Мортис вернула лучших из лучших в',
    'мир живых, чтобы те действовали хит-',
    'ростью там, где недостаточно силы.'); HitPoints: 100; Initiative: 60;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atDaggerOfShadows; SkillEnum: skSpy;),
    // Dominator
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: reArchmage;
    Size: szSmall; Name: ('Доминатор', 'Доминатораа');
    Description: ('Погибшие полководцы Империи возвра-',
    'щены Мортис к жизни для того, чтобы', 'сеять вокруг смерть и разрушения.');
    HitPoints: 125; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 35; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; SkillEnum: skTalisman;),
    // Fighter
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: reSquire; Size: szSmall;
    Name: ('Воин', 'Воина'); Description: ('Услышав зов Мортис, безропотно',
    'встают в строй мертвые воины.', 'Они не знают ни страха, ни жалости.');
    HitPoints: 120; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 25; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 50; Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword;),
    // Ghost
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: reArcher; Size: szSmall;
    Name: ('Привидение', 'Привидение');
    Description: ('Привидения - это темные души,',
    ' чье зло навсегда приковало их', 'к миру живых.'); HitPoints: 45;
    Initiative: 20; ChancesToHit: 60; Leadership: 0; Level: 1; Damage: 0;
    Armor: 0; Heal: 0; SourceEnum: seMind; ReachEnum: reAny; Gold: 50;
    Sound: (mmGhostHit, mmGhostDeath, mmGhostAttack); Gender: cgNeuter;
    AttackEnum: atParalyze;),
    // Initiate
    (Race: reUndeadHordes; SubRace: reUndead; ResEnum: reApprentice;
    Size: szSmall; Name: ('Адепт', 'Адепта');
    Description: ('Адепты обучены нести чуму и', 'смерть армиям живых во славу',
    'своей богини Мортис.'); HitPoints: 45; Initiative: 40; ChancesToHit: 80;
    Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0; SourceEnum: seDeath;
    ReachEnum: reAll; Gold: 60; Sound: (mmHumHit, mmHumDeath, mmStaffAttack);
    Gender: cgMale; AttackEnum: atMagic;),
    // Wyvern
    (Race: reUndeadHordes; SubRace: reUndeadDragon; ResEnum: reAcolyte;
    Size: szBig; Name: ('Виверна', 'Виверну');
    Description: ('Чародеи воскрешают мертвых драко-',
    'нов, тем самым создавая виверн, кото-',
    'рые сражаются в рядах армии мертвых.'); HitPoints: 225; Initiative: 35;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAll; Gold: 100;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgFemale;
    AttackEnum: atPoisonousBreath;),

    // Ashkael
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reAshkael;
    Size: szSmall; Name: ('Ашкаэль', 'Ашкаэля');
    Description: ('Командир 80 адских когорт, Ашкаэль был',
    'избран Бетрезеном для защиты столицы Легионов,',
    'никогда не оставляя её без защиты.'); HitPoints: 900; Initiative: 90;
    ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAll; Gold: 0;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale; AttackEnum: atMagic;),
    // Duke
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: rePegasusKnight;
    Size: szSmall; Name: ('Герцог', 'Герцога');
    Description: ('Воинственный герцог ведет демонов',
    'в битву, сжимая меч в окровавленных', 'руках.'); HitPoints: 150;
    Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; SkillEnum: skFly;),
    // Counselor
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reRanger;
    Size: szSmall; Name: ('Советник', 'Советника');
    Description: ('Советник ведёт авангард сил Легионов.',
    'Он путешествует по землям Невендаара', 'с высокой скоростью.');
    HitPoints: 90; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 40; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atCrossbow; SkillEnum: skBoots;),
    // Arch-Devil
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reArchmage;
    Size: szSmall; Name: ('Архидьявол', 'Архидьявола');
    Description: ('Архидьявол является владыкой магии;',
    'он обладает глубокими знаниями', 'о посохах и свитках.'); HitPoints: 65;
    Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30;
    Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic; SkillEnum: skWand;),
    // Ripper
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reArchmage;
    Size: szSmall; Name: ('Потрошитель', 'Потрошителя');
    Description: ('Талант потрошителя заключается в',
    'медленном и мастерском извлечении', 'правды из его жертв.'); HitPoints: 90;
    Initiative: 60; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 35;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atFireDagger; SkillEnum: skSpy;),
    // Chieftain
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reArchmage;
    Size: szSmall; Name: ('Атаман', 'Атамана');
    Description: ('Яростные Атаманы всегда идут впереди',
    'отрядов демонов и ведут адские', 'когорты в бой.'); HitPoints: 110;
    Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 45;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; SkillEnum: skTalisman;),
    // Possessed
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reSquire;
    Size: szSmall; Name: ('Одержимый', 'Одержимого');
    Description: ('Повелитель демонов поработил этих',
    'сильных телом крестьян для того, что-',
    'бы они сражались в адских сражениях.'); HitPoints: 120; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword;),
    // Gargoyle
    (Race: reLegionsOfTheDamned; SubRace: reGargoyle; ResEnum: reArcher;
    Size: szBig; Name: ('Горгулья', 'Горгулью');
    Description: ('Каменная кожа гаргулий поглощает',
    'часть получаемого урона, делая', 'из них прекрасных защитных воинов.');
    HitPoints: 90; Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 40; Armor: 40; Heal: 0; SourceEnum: seEarth; ReachEnum: reAny;
    Gold: 80; Sound: (mmHit, mmDeath, mmAttack); Gender: cgFemale;
    AttackEnum: atStones;),
    // Cultist
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reApprentice;
    Size: szSmall; Name: ('Культист', 'Культиста');
    Description: ('Еретики Империи, они взывают к',
    'адским силам, дабы призвать огонь', 'на всех своих врагов в битве.');
    HitPoints: 45; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 60; Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic;),
    // Devil
    (Race: reLegionsOfTheDamned; SubRace: reHeretic; ResEnum: reAcolyte;
    Size: szBig; Name: ('Чёрт', 'Чёрта');
    Description: ('Это нечестивое создание', 'держит земли в страхе во имя его',
    'Тёмного Повелителя Бетрезена.'); HitPoints: 170; Initiative: 35;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 50; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 100;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale;
    AttackEnum: atLongSword;),

    // Neutral Green Skins
{$REGION Green Skins}
    // Goblin
    (Race: reNeutrals; SubRace: reGreenSkin; ResEnum: reGoblin; Size: szSmall;
    Name: ('Гоблин', 'Гоблина');
    Description: ('Гоблины — это дальние родственники',
    'орков. Они не такие сильные', 'создания, но зато хитрые и ловкие.');
    HitPoints: 50; Initiative: 30; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seLife; ReachEnum: reAdj;
    Gold: 50; Sound: (mmGoblinHit, mmGoblinDeath, mmSpearAttack);
    Gender: cgMale; AttackEnum: atSpear;),
    // Goblin Archer
    (Race: reNeutrals; SubRace: reGreenSkin; ResEnum: reGoblinArcher;
    Size: szSmall; Name: ('Гоблин-лучник', 'Гоблина-лучника');
    Description: ('Гоблины-лучники сопровождают своих',
    'собратьев в засадах и нападениях,', 'используя грубые стрелы.');
    HitPoints: 40; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 75; Sound: (mmGoblinHit, mmGoblinDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atBow),
    // Goblin Elder
    (Race: reNeutrals; SubRace: reGreenSkin; ResEnum: reGoblinElder;
    Size: szSmall; Name: ('Гоблин-старейшина', 'Гоблина-старейшину');
    Description: ('Немногие гоблины настолько умны,',
    'чтобы практиковать искусство магии,', 'но иногда появляются старейшины.');
    HitPoints: 35; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 10; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 100; Sound: (mmGoblinHit, mmGoblinDeath, mmStaffAttack);
    Gender: cgMale; AttackEnum: atMagic;),

    // Orc
    (Race: reNeutrals; SubRace: reGreenSkin; ResEnum: reOrc; Size: szSmall;
    Name: ('Орк', 'Орка'); Description: ('Орки в битвах всегда на передних',
    'рядах, так как они обладают крепким', 'телосложением.'); HitPoints: 200;
    Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 200;
    Sound: (mmOrcHit, mmOrcDeath, mmAxeAttack); Gender: cgMale;
    AttackEnum: atBattleAxe;),

    // Ogre
    (Race: reNeutrals; SubRace: reGreenSkin; ResEnum: reOrc; Size: szBig;
    Name: ('Огр', 'Огра'); Description: ('Огры нападают на всех проходящих',
    'мимо, не обращая внимание на', 'тактику и стратегию.'); HitPoints: 300;
    Initiative: 20; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 300;
    Sound: (mmOrcHit, mmOrcDeath, mmClubAttack); Gender: cgMale;
    AttackEnum: atClub;),
{$ENDREGION Green Skins}
    // Neutral Humans
{$REGION Humans}
    // Peasant
    (Race: reNeutrals; SubRace: reHuman; ResEnum: reGoblin; Size: szSmall;
    Name: ('Крестьянин', 'Крестьянина');
    Description: ('Крестьяне защищают тот', 'маленький кусочек земли, который',
    'они называют своим домом.'); HitPoints: 40; Initiative: 30;
    ChancesToHit: 75; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSpearAttack); Gender: cgMale;
    AttackEnum: atSpear;),
    // Man at Arms
    (Race: reNeutrals; SubRace: reHuman; ResEnum: reGoblin; Size: szSmall;
    Name: ('Пехотинец', 'Пехотинца');
    Description: ('Наёмники, предоставляющие свои',
    'боевые услуги каждому, кто', 'заплатит золотую монету.'); HitPoints: 95;
    Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 40;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 100;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword;),

{$ENDREGION Humans}
    // Neutral Undeads
{$REGION Undeads}
    // Ghoul
    (Race: reNeutrals; SubRace: reUndead; ResEnum: reSquire; Size: szSmall;
    Name: ('Упырь', 'Упыря'); Description: ('Упыри - опасные создания-нежить,',
    'способные воздействовать на разум', 'своей жертвы.'); HitPoints: 150;
    Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 35;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 125;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atClaws;),
    // Dark Elf Gast
    (Race: reNeutrals; SubRace: reDarkElf; ResEnum: reSquire; Size: szSmall;
    Name: ('Тёмный эльф-гаст', 'Тёмного эльфа-гаста');
    Description: ('Когда-то гасты были благородными',
    'эльфами, пострадавшими от чумы.', 'Смерть передала их в руки Мортис.');
    HitPoints: 110; Initiative: 40; ChancesToHit: 70; Leadership: 0; Level: 1;
    Damage: 40; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 125; Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atDaggerOfShadows;),
{$ENDREGION Undeads}
    // Neutral Animals
{$REGION Animals}
    // Spider
    (Race: reNeutrals; SubRace: reAnimal; ResEnum: reGiantSpider; Size: szBig;
    Name: ('Гигантский Паук', 'Гигантского Паука');
    Description: ('Сильный яд гигантского паука',
    'полностью парализует жертву,', 'не давая ей убежать.'); HitPoints: 420;
    Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 400;
    Sound: (mmSpiderHit, mmSpiderDeath, mmSpiderAttack); Gender: cgMale;
    AttackEnum: atBites;),

    // Wolf
    (Race: reNeutrals; SubRace: reAnimal; ResEnum: reWolf; Size: szSmall;
    Name: ('Волк', 'Волка'); Description: ('Волки испокон веков бродят по этим',
    'землям в поисках добычи. Смерть ждет',
    'воинов, которые столкнутся с ними.'); HitPoints: 180; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 200;
    Sound: (mmWolfHit, mmWolfDeath, mmWolfAttack); Gender: cgMale;
    AttackEnum: atBites;)
{$ENDREGION Animals}
    //
    );

  { TCreature }

class procedure TCreature.Assign(var ACreature: TCreature;
  const I: TCreatureEnum);
var
  J: Integer;
begin
  with ACreature do
  begin
    Active := I <> crNone;
    Paralyze := False;
    Enum := I;
    ResEnum := CreatureBase[I].ResEnum;
    for J := 0 to 1 do
      Name[J] := CreatureBase[I].Name[J];
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
    SkillEnum := CreatureBase[I].SkillEnum;
  end;
end;

class function TCreature.Character(const I: TCreatureEnum): TCreatureBase;
begin
  Result := CreatureBase[I];
end;

class procedure TCreature.Clear(var ACreature: TCreature);
var
  J: Integer;
begin
  with ACreature do
  begin
    Active := False;
    Paralyze := False;
    Enum := crNone;
    ResEnum := reNone;
    for J := 0 to 1 do
      Name[J] := '';
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
    SkillEnum := skNone;
  end;
end;

function TCreature.GenderEnding(VerbForm: Byte = 0): string;
const
  GenderEndings: array [0 .. 1, TCreatureGender] of string =
  // обычные глаголы
    (('', 'а', 'о', 'и'),
    // для глаголов типа "нанес"
    ('', 'ла', 'ло', 'ли'));
begin
  Assert(VerbForm < Length(GenderEndings));
  Result := GenderEndings[VerbForm, Character(Enum).Gender];
end;

class function TCreature.GetRandomEnum(const P, Position: Integer)
  : TCreatureEnum;
var
  N, G: Integer;
  R: TReachEnum;
begin
  case Position of
    0, 2, 4:
      R := reAdj;
  else
    case RandomRange(0, 2) of
      0:
        R := reAll;
    else
      R := reAny;
    end;
  end;
  repeat
    N := RandomRange(0, Ord(High(TCreatureEnum))) + 1;
    G := CreatureBase[TCreatureEnum(N)].Gold;
  until (G > 0) and (G >= P - 25) and (G <= P + 25) and
    (CreatureBase[TCreatureEnum(N)].ReachEnum = R) and
    (TSaga.LeaderRace <> CreatureBase[TCreatureEnum(N)].Race);
  Result := TCreatureEnum(N);
end;

function TCreature.Alive: Boolean;
begin
  Result := Active and (HitPoints > 0);
end;

function TCreature.IsLeader(): Boolean;
begin
  Result := Leadership > 0;
end;

end.
