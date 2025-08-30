unit Elinor.Creatures;

interface

// http://gormel.altervista.org/mastro_gp/Disciples2/
// https://rpgwatch.com/news/disciples--liberation--abilities-cheatsheet-46823.html

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

uses
  Elinor.Faction,
  Elinor.Ability,
  Elinor.Creature.Types,
  Elinor.Attribute,
  Elinor.Resources;

type
  TSubRaceEnum = (reCustom, reAngel, reHuman, reUndead, reHeretic, reDwarf,
    reElf, reGreenSkin, reDarkElf, reVampire, reGargoyle, reAnimal, reBarbarian,
    reDragon, reUndeadDragon, reMarsh, reWater);

type
  TReachEnum = (reAny, reAdj, reAll);

type
  TSourceEnum = (seWeapon, seLife, seMind, seDeath, seAir, seEarth,
    seFire, seWater);

const
  SourceName: array [TSourceEnum] of string = ('Weapon', 'Life', 'Mind',
    'Death', 'Air', 'Earth', 'Fire', 'Water');
  StaffName: array [TSourceEnum] of string = ('Battle Staff', 'Ruby Staff',
    'Mithril Staff', 'Staff of Power', 'Staff of Lightning', 'Elven Staff',
    'Wizard Staff', 'Staff of Ice');

type
  TRaceCharGroup = (cgGuardian, cgLeaders, cgCharacters);

type
  TFactionLeaderKind = (ckWarrior, ckScout, ckMage, ckThief, ckLord, ckTemplar);

const
  FactionLeaderKindName: array [TFactionLeaderKind] of string = ('Warrior',
    'Scout', 'Mage', 'Thief', 'Lord', 'Templar');

type
  TLeaderWarriorActVar = (avRest, avRitual, avWar3);
  TLeaderThiefSpyVar = (svIntroduceSpy, svDuel, svPoison);

const
  ckGuardian = ckMage;

type
  TAttackEnum = (atSlayerSword, atLongSword, atPaladinSword, atBattleAxe,
    atDagger, atBow, atHunterBow, atCrossbow, atDrainLife, atHealing,
    atParalyze, atPoison, atMagic, atClaws, atBites, atSpear, atStones,
    atPoisonousBreath, atDaggerOfShadows, atFlameDagger, atClub, atFireHammer,
    atPhoenixSword, atScythe, atShortSword);

type
  TCreatureSize = (szSmall, szBig);

const
  AttackName: array [TAttackEnum] of string = ('Slayer Sword', 'Long Sword',
    'Paladin Sword', 'Battle Axe', 'Dagger', 'Bow', 'Hunter Bow', 'Crossbow',
    'Drain Life', 'Healing', 'Paralysis', 'Poison', 'Magic', 'Claws', 'Bite',
    'Spear', 'Stones', 'Poisonous Breath', 'Dagger of Shadows', 'Flame Dagger',
    'Club', 'Fire Hammer', 'Phoenix Sword', 'Scythe', 'Short Sword');

const
  AtkSecName: array [TAttackEnum] of string = ('slayer_sword', 'long_sword',
    'paladin_sword', 'battle_axe', 'dagger', 'bow', 'hunter_bow', 'crossbow',
    'drain_life', 'healing', 'paralyze', 'poison', 'magic', 'claws', 'bites',
    'spear', 'stones', 'poisonous_breath', 'dagger_of_shadows', 'flame_dagger',
    'club', 'fire_hammer', 'phoenix_sword', 'scythe', 'short_sword');

const
  Characters: array [faTheEmpire .. faLegionsOfTheDamned] of array
    [TRaceCharGroup] of array [TFactionLeaderKind] of TCreatureEnum = (
    // The Empire Capital Guardian
    ((crNone, crNone, crMyzrael, crNone, crNone, crNone),
    // The Empire Leaders
    (crPaladin, crRanger, crArchmage, crThief, crWarlord, crNone), // ),
    // The Empire Characters
    (crSquire, crArcher, crApprentice, crAcolyte, crNone, crNone)), //
    //
    // Undead Hordes Capital Guardian
    ((crNone, crNone, crAshgan, crNone, crNone, crNone),
    // Undead Hordes Leaders
    (crDeathKnight, crNosferatu, crLichQueen, crThug, crDominator, crNone), //
    // Undead Hordes Characters
    (crFighter, crGhost, crInitiate, crWyvern, crNone, crNone)), //
    //
    // Legions Of The Damned Capital Guardian
    ((crNone, crNone, crAshkael, crNone, crNone, crNone),
    // Legions Of The Damned Leaders
    (crDuke, crCounselor, crArchDevil, crRipper, crChieftain, crNone), //
    // Legions Of The Damned Characters
    (crPossessed, crGargoyle, crCultist, crDevil, crNone, crNone)) //
    //
    );
{$REGION texts}
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
  TCreatureGender = (cgMale, cgFemale);

const
  GenderIdent: array [TCreatureGender] of string = ('male', 'female');
  GenderName: array [TCreatureGender] of string = ('Male', 'Female');

type
  TCreatureBase = record
    Ident: string;
    Faction: TFactionEnum;
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
    AbilityEnum: TAbilityEnum;
    Rating: Word;
  end;

type

  { TCreature }

  TCreature = record
    Active: Boolean;
    Paralyze: Boolean;
    Enum: TCreatureEnum;
    ResEnum: TResEnum;
    Name: array [0 .. 1] of string;
    HitPoints: TCurrMaxAttribute;
    Initiative: TCurrTempAttribute;
    ChancesToHit: TCurrTempAttribute;
    Leadership: Integer;
    Level: Integer;
    Experience: Integer;
    Damage: TCurrTempAttribute;
    Armor: TCurrTempAttribute;
    Heal: Integer;
    SourceEnum: TSourceEnum;
    ReachEnum: TReachEnum;
    AbilityEnum: TAbilityEnum;
    function Alive: Boolean;
    function AliveAndNeedExp: Boolean;
    function IsLeader(): Boolean;
    function IsMaxLevel: Boolean;
    function GenderEnding(VerbForm: Byte = 0): string;
    procedure ClearTempValues;
    class procedure Clear(var ACreature: TCreature); static;
    class function Character(const I: TCreatureEnum): TCreatureBase; static;
    class procedure Assign(var ACreature: TCreature;
      const I: TCreatureEnum); static;
    class function GetRandomEnum(const ALevel, Position: Integer)
      : TCreatureEnum; static;
    class function EquippedWeapon(const AttackEnum: TAttackEnum;
      const ASourceEnum: TSourceEnum): string; static;
    class function StrToCharEnum(const ChName: string): TCreatureEnum; static;
    class function StrToFactionEnum(const AFactionIdent: string)
      : TFactionEnum; static;
    class function FactionEnumToStr(const AFactionEnum: TFactionEnum)
      : string; static;
    class function GetName(): string; static;
  end;

implementation

uses
  System.Math, dialogs,
  System.SysUtils,
  Elinor.Ability.Base,
  Elinor.Party,
  Elinor.Saga,
  Elinor.Scenes;

const
  CreatureBase: array [TCreatureEnum] of TCreatureBase = (
    // None
    (Ident: 'none'; Faction: faNeutrals; SubRace: reCustom; ResEnum: reNone;
    Size: szSmall; Name: ('', ''); Description: ('', '', ''); HitPoints: 0;
    Initiative: 0; ChancesToHit: 0; Leadership: 0; Level: 0; Damage: 0;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale; AttackEnum: atMagic;
    AbilityEnum: abNone; Rating: 0;),
    // The Empire
{$REGION The Empire}
    // Myzrael
    (Ident: 'none'; Faction: faTheEmpire; SubRace: reAngel; ResEnum: reMyzrael;
    Size: szSmall; Name: ('Myzrael', 'Myzrael');
    Description: ('Mizrael was sent to aid the',
    'Human Empire in their holy mission.',
    'He protects the capital from enemies.'); HitPoints: 900; Initiative: 90;
    ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAll; Gold: 0;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale; AttackEnum: atMagic;
    AbilityEnum: abNone; Rating: 0;),
    // Paladin
    (Ident: 'none'; Faction: faTheEmpire; SubRace: reHuman; ResEnum: rePaladin;
    Size: szSmall; Name: ('Paladin', 'Paladin');
    Description: ('The knight who rides a pegasus is a',
    'noble warrior, whose winged steed',
    'carries him over fields and forests.'); HitPoints: 150; Initiative: 50;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atPaladinSword; AbilityEnum: abBannerBearer; Rating: 0;),
    // Ranger
    (Ident: 'none'; Faction: faTheEmpire; SubRace: reHuman; ResEnum: reRanger;
    Size: szSmall; Name: ('Ranger', 'Ranger');
    Description: ('Rangers travel swiftly and are well-',
    'versed in the kingdom, so the king of-',
    'ten sends them on scouting missions.'); HitPoints: 90; Initiative: 60;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 40; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atHunterBow; AbilityEnum: abTravelLore; Rating: 0;),
    // Archmage
    (Ident: 'none'; Faction: faTheEmpire; SubRace: reHuman; ResEnum: reArchmage;
    Size: szSmall; Name: ('Archmage', 'Archmage');
    Description: ('A master of magic, the Archmage is the',
    'only commander in the Empire who can', 'use scrolls and staves.');
    HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seAir; ReachEnum: reAll; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic; AbilityEnum: abUseStaffsAndScrolls; Rating: 0;),
    // Thief
    (Ident: 'none'; Faction: faTheEmpire; SubRace: reHuman; ResEnum: reThief;
    Size: szSmall; Name: ('Thief', 'Thief');
    Description: ('Experienced tricksters and thieves, they',
    'easily sneak behind enemy lines and',
    'serve the Empire by gathering vital intel.'); HitPoints: 100;
    Initiative: 60; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atDagger; AbilityEnum: abStealth; Rating: 0;),
    // Warlord
    (Ident: 'none'; Faction: faTheEmpire; SubRace: reHuman; ResEnum: reWarlord;
    Size: szSmall; Name: ('Warlord', 'Warlord');
    Description: ('The king’s field commander serves the',
    'Empire with loyalty and ruthlessly', 'deals with its enemies.');
    HitPoints: 120; Initiative: 55; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 40; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmAxeAttack); Gender: cgMale;
    AttackEnum: atBattleAxe; AbilityEnum: abTemplar; Rating: 0;),
    // Squire
    (Ident: 'squire'; Faction: faTheEmpire; SubRace: reHuman; ResEnum: reSquire;
    Size: szSmall; Name: ('Squire', 'Squire');
    Description: ('The squire bravely defends in battle',
    'his weaker compatriots, keeping', 'foes at sword’s length.');
    HitPoints: 100; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 25; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 50; Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; AbilityEnum: abNone; Rating: 25;),
    // Archer
    (Ident: 'archer'; Faction: faTheEmpire; SubRace: reHuman; ResEnum: reArcher;
    Size: szSmall; Name: ('Archer', 'Archer');
    Description: ('The archer’s arrows successfully hit',
    'enemies hiding behind the backs', 'of their stronger comrades.');
    HitPoints: 45; Initiative: 60; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 25; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 40; Sound: (mmHumHit, mmHumDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atBow; AbilityEnum: abNone; Rating: 10;),
    // Apprentice
    (Ident: 'apprentice'; Faction: faTheEmpire; SubRace: reHuman;
    ResEnum: reApprentice; Size: szSmall; Name: ('Apprentice', 'Apprentice');
    Description: ('The mage’s apprentice attacks foes',
    'from afar, unleashing lightning', 'upon them.'); HitPoints: 35;
    Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15;
    Armor: 0; Heal: 0; SourceEnum: seAir; ReachEnum: reAll; Gold: 60;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic; AbilityEnum: abNone; Rating: 5;),
    // Acolyte
    (Ident: 'acolyte'; Faction: faTheEmpire; SubRace: reHuman;
    ResEnum: reAcolyte; Size: szSmall; Name: ('Acolyte', 'Acolyte');
    Description: ('Trained in the art of healing, the Acolyte',
    'can tend to wounded allies, treating', 'their injuries one by one.');
    HitPoints: 50; Initiative: 10; ChancesToHit: 100; Leadership: 0; Level: 1;
    Damage: 0; Armor: 0; Heal: 20; SourceEnum: seAir; ReachEnum: reAny;
    Gold: 100; Sound: (mmHit, mmDeath, mmAttack); Gender: cgFemale;
    AttackEnum: atHealing; AbilityEnum: abNone; Rating: 5;),
{$ENDREGION The Empire}
    // Undead Hordes
{$REGION Undead Hordes}
    // Ashgan
    (Ident: 'none'; Faction: faUndeadHordes; SubRace: reUndead;
    ResEnum: reAshgan; Size: szSmall; Name: ('Ashgan', 'Ashgan');
    Description: ('Ashgan, the Plaguebearer, was once',
    'the high priest of Alkmaar.', 'He never leaves the capital unguarded.');
    HitPoints: 900; Initiative: 90; ChancesToHit: 95; Leadership: 5; Level: 1;
    Damage: 250; Armor: 50; Heal: 0; SourceEnum: seLife; ReachEnum: reAll;
    Gold: 0; Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale;
    AttackEnum: atMagic; AbilityEnum: abNone; Rating: 0;),
    // Death Knight
    (Ident: 'none'; Faction: faUndeadHordes; SubRace: reUndead;
    ResEnum: reDeathKnight; Size: szSmall;
    Name: ('Death Knight', 'Death Knight');
    Description: ('The strongest and noblest warriors',
    'of the kingdom of Alkmaar were brought back',
    'from oblivion by Mortis through the Death Knights.'); HitPoints: 150;
    Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atSlayerSword; AbilityEnum: abBannerBearer; Rating: 0;),
    // Nosferat
    (Ident: 'none'; Faction: faUndeadHordes; SubRace: reVampire;
    ResEnum: reNosferat; Size: szSmall; Name: ('Nosferat', 'Nosferat');
    Description: ('The first vampires of Alkmaar, who renounced',
    'the All-Father and swore loyalty to',
    'Mortis in exchange for power over death.'); HitPoints: 90; Initiative: 50;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 10; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmNosferatAttack); Gender: cgMale;
    AttackEnum: atDrainLife; AbilityEnum: abVampirism; Rating: 0;),
    // Lich Queen
    (Ident: 'none'; Faction: faUndeadHordes; SubRace: reUndead;
    ResEnum: reLichQueen; Size: szSmall; Name: ('Lich Queen', 'Lich Queen');
    Description: ('Priestesses of the death cult that once thrived in',
    'Alkmaar, returned by the will of Mortis', 'as merciless Lich Queens.');
    HitPoints: 65; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 30; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmLichQueenAttack); Gender: cgFemale;
    AttackEnum: atMagic; AbilityEnum: abUseStaffsAndScrolls; Rating: 0;),
    // Thug
    (Ident: 'none'; Faction: faUndeadHordes; SubRace: reUndead; ResEnum: reThug;
    Size: szSmall; Name: ('Thug', 'Thug');
    Description: ('Mortis brought back the best of the best to',
    'the world of the living, to act with cun-',
    'ning where strength is not enough.'); HitPoints: 100; Initiative: 60;
    ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atDaggerOfShadows; AbilityEnum: abStealth; Rating: 0;),
    // Dominator
    (Ident: 'none'; Faction: faUndeadHordes; SubRace: reUndead;
    ResEnum: reDominator; Size: szSmall; Name: ('Dominator', 'Dominator');
    Description: ('Fallen generals of the Empire were re-',
    'turned to life by Mortis to sow death', 'and destruction all around.');
    HitPoints: 125; Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 35; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atBattleAxe; AbilityEnum: abTemplar; Rating: 0;),
    // Fighter
    (Ident: 'fighter'; Faction: faUndeadHordes; SubRace: reUndead;
    ResEnum: reFighter; Size: szSmall; Name: ('Fighter', 'Fighter');
    Description: ('Hearing Mortis’s call, the dead warriors',
    'rise without question to join the ranks.',
    'They know neither fear nor mercy.'); HitPoints: 120; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; AbilityEnum: abNone; Rating: 30;),
    // Ghost
    (Ident: 'ghost'; Faction: faUndeadHordes; SubRace: reUndead;
    ResEnum: reGhost; Size: szSmall; Name: ('Ghost', 'Ghost');
    Description: ('Ghosts are dark souls,', 'whose evil has forever bound them',
    'to the world of the living.'); HitPoints: 45; Initiative: 20;
    ChancesToHit: 60; Leadership: 0; Level: 1; Damage: 0; Armor: 0; Heal: 0;
    SourceEnum: seMind; ReachEnum: reAny; Gold: 50;
    Sound: (mmGhostHit, mmGhostDeath, mmGhostAttack); Gender: cgMale;
    AttackEnum: atParalyze; AbilityEnum: abNone; Rating: 10;),
    // Initiate
    (Ident: 'initiate'; Faction: faUndeadHordes; SubRace: reUndead;
    ResEnum: reInitiate; Size: szSmall; Name: ('Initiate', 'Initiate');
    Description: ('Initiates are trained to bring plague and',
    'death to the armies of the living in the name',
    'of their goddess Mortis.'); HitPoints: 45; Initiative: 40;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seDeath; ReachEnum: reAll; Gold: 60;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic; AbilityEnum: abNone; Rating: 10;),
    // Wyvern
    (Ident: 'wyvern'; Faction: faUndeadHordes; SubRace: reUndeadDragon;
    ResEnum: reWyvern; Size: szBig; Name: ('Wyvern', 'Wyvern');
    Description: ('Sorcerers resurrect dead dragons,',
    'thus creating wyverns that fight', 'in the ranks of the undead army.');
    HitPoints: 225; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 25; Armor: 0; Heal: 0; SourceEnum: seDeath; ReachEnum: reAll;
    Gold: 100; Sound: (mmHit, mmDeath, mmAttack); Gender: cgFemale;
    AttackEnum: atPoisonousBreath; AbilityEnum: abNone; Rating: 40;),
{$ENDREGION UndeadHordes}
    // Legions Of The Damned
{$REGION Legions Of The Damned}
    // Ashkael
    (Ident: 'none'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reAshkael; Size: szSmall; Name: ('Ашкаэль', 'Ашкаэля');
    Description: ('Командир 80 адских когорт, Ашкаэль был',
    'избран Бетрезеном для защиты столицы Легионов,',
    'никогда не оставляя её без защиты.'); HitPoints: 900; Initiative: 90;
    ChancesToHit: 95; Leadership: 5; Level: 1; Damage: 250; Armor: 50; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAll; Gold: 0;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale; AttackEnum: atMagic;
    AbilityEnum: abNone; Rating: 0;),
    // Duke
    (Ident: 'none'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reDuke; Size: szSmall; Name: ('Герцог', 'Герцога');
    Description: ('Воинственный герцог ведет демонов',
    'в битву, сжимая меч в окровавленных', 'руках.'); HitPoints: 150;
    Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 50;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atPhoenixSword; AbilityEnum: abFlying; Rating: 0;),
    // Counselor
    (Ident: 'none'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reCounselor; Size: szSmall; Name: ('Советник', 'Советника');
    Description: ('Советник ведёт авангард сил Легионов.',
    'Он путешествует по землям Невендаара', 'с высокой скоростью.');
    HitPoints: 90; Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1;
    Damage: 40; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 0; Sound: (mmHumHit, mmHumDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atCrossbow; AbilityEnum: abTravelLore; Rating: 0;),
    // Arch-Devil
    (Ident: 'none'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reArchdevil; Size: szSmall; Name: ('Архидьявол', 'Архидьявола');
    Description: ('Архидьявол является владыкой магии;',
    'он обладает глубокими знаниями', 'о посохах и свитках.'); HitPoints: 65;
    Initiative: 40; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 30;
    Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic; AbilityEnum: abUseStaffsAndScrolls; Rating: 0;),
    // Ripper
    (Ident: 'none'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reRipper; Size: szSmall; Name: ('Потрошитель', 'Потрошителя');
    Description: ('Талант потрошителя заключается в',
    'медленном и мастерском извлечении', 'правды из его жертв.'); HitPoints: 90;
    Initiative: 60; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 35;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atFlameDagger; AbilityEnum: abStealth; Rating: 0;),
    // Chieftain
    (Ident: 'none'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reChieftain; Size: szSmall; Name: ('Атаман', 'Атамана');
    Description: ('Яростные Атаманы всегда идут впереди',
    'отрядов демонов и ведут адские', 'когорты в бой.'); HitPoints: 110;
    Initiative: 50; ChancesToHit: 80; Leadership: 1; Level: 1; Damage: 45;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 0;
    Sound: (mmHumHit, mmHumDeath, mmClubAttack); Gender: cgMale;
    AttackEnum: atFireHammer; AbilityEnum: abTemplar; Rating: 0;),
    // Possessed
    (Ident: 'possessed'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: rePossessed; Size: szSmall; Name: ('Одержимый', 'Одержимого');
    Description: ('Повелитель демонов поработил этих',
    'сильных телом крестьян для того, что-',
    'бы они сражались в адских сражениях.'); HitPoints: 120; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; AbilityEnum: abNone; Rating: 30;),
    // Gargoyle
    (Ident: 'gargoyle'; Faction: faLegionsOfTheDamned; SubRace: reGargoyle;
    ResEnum: reStoneGargoyle; Size: szBig; Name: ('Горгулья', 'Горгулью');
    Description: ('Каменная кожа гаргулий поглощает',
    'часть получаемого урона, делая', 'из них прекрасных защитных воинов.');
    HitPoints: 75; Initiative: 60; ChancesToHit: 70; Leadership: 0; Level: 1;
    Damage: 25; Armor: 15; Heal: 0; SourceEnum: seEarth; ReachEnum: reAny;
    Gold: 90; Sound: (mmHit, mmDeath, mmAttack); Gender: cgFemale;
    AttackEnum: atStones; AbilityEnum: abNone; Rating: 30;),
    // Cultist
    (Ident: 'cultist'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reCultist; Size: szSmall; Name: ('Культист', 'Культиста');
    Description: ('Еретики Империи, они взывают к',
    'адским силам, дабы призвать огонь', 'на всех своих врагов в битве.');
    HitPoints: 45; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 60; Sound: (mmHumHit, mmHumDeath, mmStaffAttack); Gender: cgMale;
    AttackEnum: atMagic; AbilityEnum: abNone; Rating: 20;),
    // Devil
    (Ident: 'devil'; Faction: faLegionsOfTheDamned; SubRace: reHeretic;
    ResEnum: reDevil; Size: szBig; Name: ('Чёрт', 'Чёрта');
    Description: ('Это нечестивое создание', 'держит земли в страхе во имя его',
    'Тёмного Повелителя Бетрезена.'); HitPoints: 120; Initiative: 35;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 40; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 100;
    Sound: (mmHit, mmDeath, mmAttack); Gender: cgMale; AttackEnum: atClaws;
    AbilityEnum: abNone; Rating: 35;),
{$ENDREGION Legions Of The Damned}
    // Neutral Green Skins
{$REGION Green Skins}
    // Goblin
    (Ident: 'goblin'; Faction: faNeutrals; SubRace: reGreenSkin;
    ResEnum: reGoblin; Size: szSmall; Name: ('Гоблин', 'Гоблина');
    Description: ('Гоблины — это дальние родственники',
    'орков. Они не такие сильные', 'создания, но зато хитрые и ловкие.');
    HitPoints: 50; Initiative: 30; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seLife; ReachEnum: reAdj;
    Gold: 50; Sound: (mmGoblinHit, mmGoblinDeath, mmSpearAttack);
    Gender: cgMale; AttackEnum: atSpear; AbilityEnum: abNone; Rating: 25;),
    // Goblin Rider
    (Ident: 'goblin-rider'; Faction: faNeutrals; SubRace: reGreenSkin;
    ResEnum: reGoblin; Size: szSmall;
    Name: ('Гоблин-наездник', 'Гоблина-наездника');
    Description: ('Некоторые гоблины приручают', 'диких варгов и используют',
    'их в бою как средство передвижения.'); HitPoints: 55; Initiative: 35;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seLife; ReachEnum: reAdj; Gold: 120;
    Sound: (mmGoblinHit, mmGoblinDeath, mmSpearAttack); Gender: cgMale;
    AttackEnum: atSpear; AbilityEnum: abNone; Rating: 30;),
    // Goblin Archer
    (Ident: 'goblin-archer'; Faction: faNeutrals; SubRace: reGreenSkin;
    ResEnum: reGoblinArcher; Size: szSmall;
    Name: ('Гоблин-лучник', 'Гоблина-лучника');
    Description: ('Гоблины-лучники сопровождают своих',
    'собратьев в засадах и нападениях,', 'используя грубые стрелы.');
    HitPoints: 40; Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 15; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 75; Sound: (mmGoblinHit, mmGoblinDeath, mmBowAttack); Gender: cgMale;
    AttackEnum: atBow; AbilityEnum: abNone; Rating: 20;),
    // Goblin Elder
    (Ident: 'goblin-elder'; Faction: faNeutrals; SubRace: reGreenSkin;
    ResEnum: reGoblinElder; Size: szSmall;
    Name: ('Гоблин-старейшина', 'Гоблина-старейшину');
    Description: ('Немногие гоблины настолько умны,',
    'чтобы практиковать искусство магии,', 'но иногда появляются старейшины.');
    HitPoints: 35; Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 10; Armor: 0; Heal: 0; SourceEnum: seFire; ReachEnum: reAll;
    Gold: 100; Sound: (mmGoblinHit, mmGoblinDeath, mmStaffAttack);
    Gender: cgMale; AttackEnum: atMagic; AbilityEnum: abNone; Rating: 10;),
    // Goblin
    (Ident: 'black-goblin'; Faction: faNeutrals; SubRace: reGreenSkin;
    ResEnum: reBlackGoblin; Size: szSmall;
    Name: ('Black Goblin', 'Black Goblin'); Description: ('', '', '');
    HitPoints: 60; Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1;
    Damage: 20; Armor: 0; Heal: 0; SourceEnum: seLife; ReachEnum: reAdj;
    Gold: 55; Sound: (mmGoblinHit, mmGoblinDeath, mmSpearAttack);
    Gender: cgMale; AttackEnum: atShortSword; AbilityEnum: abNone; Rating: 30;),

    // Orc
    (Ident: 'orc'; Faction: faNeutrals; SubRace: reGreenSkin; ResEnum: reOrc;
    Size: szSmall; Name: ('Орк', 'Орка');
    Description: ('Орки в битвах всегда на передних',
    'рядах, так как они обладают крепким', 'телосложением.'); HitPoints: 200;
    Initiative: 40; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 200;
    Sound: (mmOrcHit, mmOrcDeath, mmAxeAttack); Gender: cgMale;
    AttackEnum: atBattleAxe; AbilityEnum: abNone; Rating: 40;),

    // Ogre
    (Ident: 'ogre'; Faction: faNeutrals; SubRace: reGreenSkin; ResEnum: reOrc;
    Size: szBig; Name: ('Огр', 'Огра');
    Description: ('Огры нападают на всех проходящих',
    'мимо, не обращая внимание на', 'тактику и стратегию.'); HitPoints: 300;
    Initiative: 20; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 300;
    Sound: (mmOrcHit, mmOrcDeath, mmClubAttack); Gender: cgMale;
    AttackEnum: atClub; AbilityEnum: abNone; Rating: 50;),
{$ENDREGION Green Skins}
    // Neutral Humans
{$REGION Humans}
    // Peasant
    (Ident: 'peasant'; Faction: faNeutrals; SubRace: reHuman; ResEnum: reGoblin;
    Size: szSmall; Name: ('Крестьянин', 'Крестьянина');
    Description: ('Крестьяне защищают тот', 'маленький кусочек земли, который',
    'они называют своим домом.'); HitPoints: 40; Initiative: 30;
    ChancesToHit: 75; Leadership: 0; Level: 1; Damage: 15; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 50;
    Sound: (mmHumHit, mmHumDeath, mmSpearAttack); Gender: cgMale;
    AttackEnum: atSpear; AbilityEnum: abNone; Rating: 10;),
    // Man at Arms
    (Ident: 'man-at-arms'; Faction: faNeutrals; SubRace: reHuman;
    ResEnum: reGoblin; Size: szSmall; Name: ('Пехотинец', 'Пехотинца');
    Description: ('Наёмники, предоставляющие свои',
    'боевые услуги каждому, кто', 'заплатит золотую монету.'); HitPoints: 95;
    Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 40;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 100;
    Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atLongSword; AbilityEnum: abNone; Rating: 30;),
    // Rogue
    (Ident: 'rogue'; Faction: faNeutrals; SubRace: reHuman; ResEnum: reRogue;
    Size: szSmall; Name: ('Разбойник', 'Разбойника');
    Description: ('Разбойники собираются в банды', 'и нападают на беззащитных',
    'путников.'); HitPoints: 75; Initiative: 65; ChancesToHit: 80;
    Leadership: 0; Level: 1; Damage: 25; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 80;
    Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atDagger; AbilityEnum: abNone; Rating: 20;),
{$ENDREGION Humans}
    // Neutral Undeads
{$REGION Undeads}
    // Ghoul
    (Ident: 'ghoul'; Faction: faNeutrals; SubRace: reUndead; ResEnum: reGhoul;
    Size: szSmall; Name: ('Упырь', 'Упыря');
    Description: ('Упыри - опасные создания-нежить,',
    'способные воздействовать на разум', 'своей жертвы.'); HitPoints: 150;
    Initiative: 50; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 35;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 125;
    Sound: (mmGhoulHit, mmGhoulDeath, mmGhoulAttack); Gender: cgMale;
    AttackEnum: atClaws; AbilityEnum: abNone; Rating: 40;),
    // Dark Elf Gast
    (Ident: 'dark-elf-gast'; Faction: faNeutrals; SubRace: reDarkElf;
    ResEnum: reSquire; Size: szSmall;
    Name: ('Тёмный эльф-гаст', 'Тёмного эльфа-гаста');
    Description: ('Когда-то гасты были благородными',
    'эльфами, пострадавшими от чумы.', 'Смерть передала их в руки Мортис.');
    HitPoints: 110; Initiative: 40; ChancesToHit: 70; Leadership: 0; Level: 1;
    Damage: 40; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAny;
    Gold: 125; Sound: (mmHumHit, mmHumDeath, mmDaggerAttack); Gender: cgMale;
    AttackEnum: atDaggerOfShadows; AbilityEnum: abNone; Rating: 45;),
    // Reaper
    (Ident: 'reaper'; Faction: faNeutrals; SubRace: reUndead; ResEnum: reReaper;
    Size: szSmall; Name: ('Жнец', 'Жнеца');
    Description: ('Жнецы являются воплощением', 'абсолютной Пустоты и способны',
    'воздействовать на разум.'); HitPoints: 250; Initiative: 55;
    ChancesToHit: 80; Leadership: 0; Level: 4; Damage: 75; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 325;
    Sound: (mmGhoulHit, mmGhoulDeath, mmGhoulAttack); Gender: cgMale;
    AttackEnum: atScythe; AbilityEnum: abNone; Rating: 70;),
{$ENDREGION Undeads}
    // Neutral Heretics
{$REGION Heretics}
    // Imp
    (Ident: 'imp'; Faction: faNeutrals; SubRace: reHeretic; ResEnum: reImp;
    Size: szSmall; Name: ('Имп', 'Импа'); Description: ('', '', '');
    HitPoints: 55; Initiative: 35; ChancesToHit: 75; Leadership: 0; Level: 1;
    Damage: 20; Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj;
    Gold: 75; Sound: (mmHumHit, mmHumDeath, mmSwordAttack); Gender: cgMale;
    AttackEnum: atClaws; AbilityEnum: abNone; Rating: 35;),
{$ENDREGION Heretics}
    // Neutral Animals
{$REGION Animals}
    // Spider
    (Ident: 'spider'; Faction: faNeutrals; SubRace: reAnimal;
    ResEnum: reGiantSpider; Size: szBig; Name: ('Giant Spider', 'Giant Spider');
    Description: ('Сильный яд гигантского паука',
    'полностью парализует жертву,', 'не давая ей убежать.'); HitPoints: 420;
    Initiative: 35; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 130;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 400;
    Sound: (mmSpiderHit, mmSpiderDeath, mmSpiderAttack); Gender: cgMale;
    AttackEnum: atBites; AbilityEnum: abNone; Rating: 80;),

    // Wolf
    (Ident: 'wolf'; Faction: faNeutrals; SubRace: reAnimal; ResEnum: reWolf;
    Size: szSmall; Name: ('Wolf', 'Wolf');
    Description: ('Wolves have roamed these lands since ancient times,',
    'always in search of prey. Death awaits',
    'the warriors who cross their path.'); HitPoints: 180; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 55; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 200;
    Sound: (mmWolfHit, mmWolfDeath, mmWolfAttack); Gender: cgMale;
    AttackEnum: atBites; AbilityEnum: abNone; Rating: 70;),
    // Dire Wolf
    (Ident: 'dire-wolf'; Faction: faNeutrals; SubRace: reAnimal;
    ResEnum: reDireWolf; Size: szSmall; Name: ('Dire Wolf', 'Dire Wolf');
    Description: ('Dire wolves are larger and fiercer than common',
    'wolves. They hunt in silence and strike swiftly.',
    'Few survive an encounter with one.'); HitPoints: 200; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 60; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 220;
    Sound: (mmWolfHit, mmWolfDeath, mmWolfAttack); Gender: cgMale;
    AttackEnum: atBites; AbilityEnum: abNone; Rating: 80;),
    // Spirit Wolf
    (Ident: 'spirit-wolf'; Faction: faNeutrals; SubRace: reAnimal;
    ResEnum: reSpiritWolf; Size: szSmall; Name: ('Spirit Wolf', 'Spirit Wolf');
    Description: ('Dire wolves are larger and fiercer than common',
    'wolves. They hunt in silence and strike swiftly.',
    'Few survive an encounter with one.'); HitPoints: 250; Initiative: 50;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 65; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 250;
    Sound: (mmWolfHit, mmWolfDeath, mmWolfAttack); Gender: cgMale;
    AttackEnum: atBites; AbilityEnum: abNone; Rating: 90;),

    // Polar Bear
    (Ident: 'polar-bear'; Faction: faNeutrals; SubRace: reAnimal;
    ResEnum: rePolarBear; Size: szBig; Name: ('Polar Bear', 'Polar Bear');
    Description: ('Polar bears are deadly beasts of the north.',
    'Thick fur and huge claws protect them.',
    'They strike without warning when threatened.'); HitPoints: 320;
    Initiative: 70; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 85;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 700;
    Sound: (mmBearHit, mmBearDeath, mmBearAttack); Gender: cgMale;
    AttackEnum: atBites; AbilityEnum: abNone; Rating: 60;),
    // Brown Bear
    (Ident: 'brown-bear'; Faction: faNeutrals; SubRace: reAnimal;
    ResEnum: reBrownBear; Size: szBig; Name: ('Brown Bear', 'Brown Bear');
    Description: ('Brown bears are strong and territorial creatures.',
    'They roam forests and mountains in search of food.',
    'Disturbing one is often fatal.'); HitPoints: 300; Initiative: 70;
    ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 80; Armor: 0; Heal: 0;
    SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 600;
    Sound: (mmBearHit, mmBearDeath, mmBearAttack); Gender: cgMale;
    AttackEnum: atBites; AbilityEnum: abNone; Rating: 55;),
    // Black Bear
    (Ident: 'black-bear'; Faction: faNeutrals; SubRace: reAnimal;
    ResEnum: reBlackBear; Size: szBig; Name: ('Black Bear', 'Black Bear');
    Description: ('Black bears are smaller but unpredictable.',
    'They can climb trees and move quickly.',
    'A cornered black bear is a fierce opponent.'); HitPoints: 280;
    Initiative: 70; ChancesToHit: 80; Leadership: 0; Level: 1; Damage: 75;
    Armor: 0; Heal: 0; SourceEnum: seWeapon; ReachEnum: reAdj; Gold: 500;
    Sound: (mmBearHit, mmBearDeath, mmBearAttack); Gender: cgMale;
    AttackEnum: atBites; AbilityEnum: abNone; Rating: 50;)
{$ENDREGION Animals}
    //
    );
  // TCreature
{$REGION TCreature}
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
    HitPoints.SetValue(CreatureBase[I].HitPoints);
    Initiative.SetCurrValue(CreatureBase[I].Initiative);
    ChancesToHit.SetCurrValue(CreatureBase[I].ChancesToHit);
    Leadership := CreatureBase[I].Leadership;
    Level := CreatureBase[I].Level;
    Experience := 0;
    Damage.SetCurrValue(CreatureBase[I].Damage);
    Armor.SetCurrValue(CreatureBase[I].Armor);
    Heal := CreatureBase[I].Heal;
    SourceEnum := CreatureBase[I].SourceEnum;
    ReachEnum := CreatureBase[I].ReachEnum;
    AbilityEnum := CreatureBase[I].AbilityEnum;
    ClearTempValues;
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
    HitPoints.Clear;
    Initiative.ClearFull;
    ChancesToHit.ClearFull;
    Leadership := 0;
    Level := 0;
    Experience := 0;
    Damage.ClearFull;
    Armor.ClearFull;
    Heal := 0;
    SourceEnum := seWeapon;
    ReachEnum := reAdj;
    AbilityEnum := abNone;
    ClearTempValues;
  end;
end;

class function TCreature.EquippedWeapon(const AttackEnum: TAttackEnum;
  const ASourceEnum: TSourceEnum): string;
begin
  Result := AttackName[AttackEnum];
  case AttackEnum of
    atMagic:
      Result := StaffName[ASourceEnum];
    atDrainLife:
      Result := 'Посох Затмения';
  end;
end;

function TCreature.GenderEnding(VerbForm: Byte = 0): string;
const
  GenderEndings: array [0 .. 1, TCreatureGender] of string =
  // обычные глаголы
    (('', 'а'),
    // для глаголов типа "нанес"
    ('', 'ла'));
begin
  Assert(VerbForm < Length(GenderEndings));
  Result := GenderEndings[VerbForm, Character(Enum).Gender];
end;

class function TCreature.GetName: string;
begin
  Result := '';
  with TCreature.Character(TLeaderParty.Leader.Enum) do
    if Leadership > 0 then
      Result := TLeaderParty.LeaderName
    else
      Result := Name[0];
end;

class function TCreature.GetRandomEnum(const ALevel, Position: Integer)
  : TCreatureEnum;
var
  N, Rating: Integer;
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
    Rating := CreatureBase[TCreatureEnum(N)].Rating;
  until (Rating > 0) and (Rating >= (ALevel * 10) - 5) and
    (Rating <= (ALevel * 10) + 5) and
    (CreatureBase[TCreatureEnum(N)].ReachEnum = R) and
    (Game.Scenario.Faction <> CreatureBase[TCreatureEnum(N)].Faction);
  Result := TCreatureEnum(N);
end;

procedure TCreature.ClearTempValues;
begin
  ChancesToHit.ClearTemp;
  Initiative.ClearTemp;
  Damage.ClearTemp;
  Armor.ClearTemp;
end;

function TCreature.Alive: Boolean;
begin
  Result := Active and not HitPoints.IsMinCurrValue;
end;

function TCreature.AliveAndNeedExp: Boolean;
begin
  Result := Alive and not IsMaxLevel;
end;

function TCreature.IsLeader(): Boolean;
begin
  Result := Leadership > 0;
end;

function TCreature.IsMaxLevel: Boolean;
begin
  Result := Level >= TParty.MaxLevel;
end;

class function TCreature.StrToCharEnum(const ChName: string): TCreatureEnum;
var
  LCreatureEnum: TCreatureEnum;
begin
  Result := crNone;
  for LCreatureEnum := Low(TCreatureEnum) to High(TCreatureEnum) do
    if CreatureBase[LCreatureEnum].Ident = ChName then
    begin
      Result := LCreatureEnum;
      Exit;
    end;
end;

class function TCreature.StrToFactionEnum(const AFactionIdent: string)
  : TFactionEnum;
var
  LRaceEnum: TFactionEnum;
begin
  Result := faNeutrals;
  for LRaceEnum := Low(TFactionEnum) to High(TFactionEnum) do
    if FactionIdent[LRaceEnum] = AFactionIdent then
    begin
      Result := LRaceEnum;
      Exit;
    end;
end;

class function TCreature.FactionEnumToStr(const AFactionEnum
  : TFactionEnum): string;
var
  LRaceEnum: TFactionEnum;
begin
  Result := 'neutrals';
  for LRaceEnum := Low(TFactionEnum) to High(TFactionEnum) do
    if LRaceEnum = AFactionEnum then
    begin
      Result := FactionIdent[LRaceEnum];
      Exit;
    end;
end;

{$ENDREGION TCreature}

end.
