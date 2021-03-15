unit DisciplesRL.Items;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

// Предметы в Д1 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=328
// Предметы в Д2 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=223
// Список предм. -- https://www.ign.com/faqs/2005/disciples-ii-rise-of-the-elves-items-listfaq-677342
uses
  DisciplesRL.Resources;

type
  TItemType = (itSpecial, itValuable, itArtifact,
    // Potions
    itTemporaryPotion, itPermanentPotion, itHealingPotion,
    // Equipable
    itWand, itOrb, itTalisman, itBoots, itBanner, itTome);

type
  TItemProp = (ipEquipable, ipConsumable, ipReadable, ipUsable, ipPermanent,
    ipTemporary);

type
  TItemEffect = ();

type
  TItem = record
    ItemName: string;
    ItemType: TItemType;
    ItemProp: set of TItemProp;
  end;

implementation

uses
  SysUtils;

end.
