unit Elinor.Factions;

interface

uses
  Elinor.Spells,
  Elinor.Resources;

type
  TFactionEnum = (faTheEmpire, faUndeadHordes, faLegionsOfTheDamned,
    faMountainClans, faElvenAlliance, faGreenskinTribes, faNeutrals);

type
  TPlayableFactions = faTheEmpire .. faLegionsOfTheDamned;

const
  FactionIdent: array [TFactionEnum] of string = ('the-empire', 'undead-hordes',
    'legions-of-the-damned', 'mountain-clans', 'elven-alliance',
    'greenskin-tribes', 'neutrals');

const
  Factions = [faTheEmpire, faUndeadHordes, faLegionsOfTheDamned];

const
  FactionName: array [TFactionEnum] of string = ('The Empire', 'Undead Hordes',
    'Legions of the Damned', 'Mountain Clans', 'Elven Alliance',
    'Greenskin Tribes', 'Neutrals');

const
  FactionTerrain: array [TFactionEnum] of TResEnum = (reTheEmpireTerrain,
    reUndeadHordesTerrain, reLegionsOfTheDamnedTerrain, reNeutralTerrain,
    reNeutralTerrain, reNeutralTerrain, reNeutralTerrain);

const
  FactionSpellbook: array [TFactionEnum] of array [0 .. 5] of TSpellEnum = (
    // The Empire Spellbook
    (spTrueHealing, spNone, spNone, spNone, spNone, spNone),
    // Undead Hordes Spellbook
    (spPlague, spNone, spNone, spNone, spNone, spNone),
    // Legions Of The Damned Spellbook
    (spConcealment, spNone, spNone, spNone, spNone, spNone),
    // MountainClans Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone),
    // ElvenAlliance Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone),
    // Greenskin Tribes Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone),
    // Neutrals Spellbook
    (spNone, spNone, spNone, spNone, spNone, spNone)
    //
    );

const
  FactionDescription: array [TFactionEnum] of array [0 .. 10] of string = (
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
    'по Невендаару, сея хаос и разруху.',
    'Им осталось провести последний ритуал',
    'и даровать Бетрезену неограниченную',
    'свободу. Десять лет назад они потерпе-',
    'ли поражение и были заперты в Горном', 'Храме… И вот десять лет истекли:',
    'теперь ничто не мешает легионам', 'снова попытаться совершить ритуал,',
    'который освободит Бетрезена раз и', 'навсегда…'),
    // Mountain Clans
    ('', '', '', '', '', '', '', '', '', '', ''),
    // Elven Alliance
    ('', '', '', '', '', '', '', '', '', '', ''),
    // Greenskin Tribes
    ('', '', '', '', '', '', '', '', '', '', ''),
    // Neutrals
    ('', '', '', '', '', '', '', '', '', '', ''));

implementation

end.
