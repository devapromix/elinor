unit Elinor.Abilities;

// https://gamefaqs.gamespot.com/pc/918958-disciples-ii-rise-of-the-elves/faqs
// https://disciples.fandom.com/wiki/Skill_guide_for_Disciples_II:_Dark_Prophecy
// https://www.ign.com/articles/2005/12/19/disciples-ii-rise-of-the-elves-items-listfaq-677342

interface

uses
  Elinor.Creatures,
  Elinor.Resources;

const
  AbilityBase: array [TAbilityEnum] of TAbility = (
    // None
    (Enum: abNone; Name: ''; Description: ('', ''); Level: 1; Leaders: [];
    ResEnum: reNone;),
    // Flying
    (Enum: abFlying; Name: 'Flying';
    Description: ('The skill allows the leader and',
    'his party to fly above the ground'); Level: 1; Leaders: FlyLeaders;
    ResEnum: reNone;),
    // Strength
    (Enum: abStrength; Name: 'Strength';
    Description: ('Adds 10% damage to the attack', 'of the fighter leader');
    Level: 4; Leaders: FighterLeaders; ResEnum: reNone;),
    // Might
    (Enum: abMight; Name: 'Might';
    Description: ('Adds 15% damage to the attack', 'of the fighter leader');
    Level: 6; Leaders: FighterLeaders; ResEnum: reNone;),
    // Stealth
    (Enum: abStealth; Name: 'Stealth';
    Description: ('The leader will secretly lead the',
    'detachment to any corner of Nevendaar'); Level: 1; Leaders: ThiefLeaders;
    ResEnum: reNone;),
    // Sharp Eye
    (Enum: abSharpEye; Name: 'Sharp Eye';
    Description: ('Allows the leader to see ', 'further'); Level: 1;
    Leaders: ScoutingLeaders; ResEnum: reSharpEye;),
    // Hawk Eye #2
    (Enum: abHawkEye; Name: 'Hawk Eye';
    Description: ('Allows the leader to see ', 'further'); Level: 3;
    Leaders: ScoutingLeaders; ResEnum: reNone;),
    // Far Sight
    (Enum: abFarSight; Name: 'Far Sight';
    Description: ('Allows the leader to see ', 'further'); Level: 5;
    Leaders: AllLeaders; ResEnum: reNone;),
    // Artifact Lore
    (Enum: abArtifactLore; Name: 'Artifact Lore';
    Description: ('Allows the leader to wear rare', 'magical artifacts');
    Level: 1; Leaders: AllLeaders; ResEnum: reNone;),
    // Banner Bearer
    (Enum: abBannerBearer; Name: 'Banner Bearer';
    Description: ('Allows the leader to carry', 'battle flags'); Level: 1;
    Leaders: AllLeaders; ResEnum: reNone;),
    // Travel Lore
    (Enum: abTravelLore; Name: 'Travel Lore';
    Description: ('Allows the leader to wear magic', 'shoes'); Level: 1;
    Leaders: AllLeaders; ResEnum: reNone;),
    // Leadership #1
    (Enum: abLeadership1; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 1; Leaders: AllLeaders; ResEnum: reNone;),
    // Leadership #2
    (Enum: abLeadership2; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 2; Leaders: AllLeaders; ResEnum: reNone;),
    // Leadership #3
    (Enum: abLeadership3; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 3; Leaders: AllLeaders; ResEnum: reNone;),
    // Leadership #4
    (Enum: abLeadership4; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 4; Leaders: AllLeaders; ResEnum: reNone;),
    // Use Staffs And Scrolls
    (Enum: abUseStaffsAndScrolls; Name: 'Use Staffs And Scrolls';
    Description: ('Allows the leader to use ', 'magic staffs and scrolls');
    Level: 1; Leaders: MageLeaders; ResEnum: reNone;),
    // Accuracy
    (Enum: abAccuracy; Name: 'Accuracy';
    Description: ('Increases the leader''s chance to', 'hit the enemy.');
    Level: 6; Leaders: ScoutingLeaders; ResEnum: reNone;),
    // Pathfinding
    (Enum: abPathfinding; Name: 'Pathfinding';
    Description: ('Increases the distance that the',
    'leader''s party can travel'); Level: 1; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Advanced Pathfinding
    (Enum: abAdvancedPathfinding; Name: 'Advanced Pathfinding';
    Description: ('Increases the distance that the',
    'leader''s party can travel'); Level: 4; Leaders: ScoutingLeaders;
    ResEnum: reNone;),
    // Dealmaker
    (Enum: abDealmaker; Name: 'Dealmaker';
    Description: ('The owner of this ability',
    'receives a 10% discount from the merchant'); Level: 4; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Haggler
    (Enum: abHaggler; Name: 'Haggler';
    Description: ('The owner of this ability',
    'receives a 15% discount from the merchant'); Level: 5;
    Leaders: LordLeaders; ResEnum: reNone;),
    // Natural Armor
    (Enum: skProtect; Name: 'Естественная Броня';
    Description: ('Предводитель будет поглощать 10%', 'наносимого ему урона.');
    Level: 6; Leaders: AllLeaders; ResEnum: reNone;),
    // Talisman
    (Enum: skTalisman; Name: 'Сила Талисманов';
    Description: ('Позволяет предводителю надевать',
    'талисманы и использовать их в бою.'); Level: 1; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Instructor
    (Enum: skInstructor; Name: 'Инструктор';
    Description: ('Все воины в отряде предводителя',
    'будут получать больше опыта.'); Level: 4; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Book
    (Enum: skBook; Name: 'Тайное Знание';
    Description: ('Позволяет предводителю читать',
    'магические книги и таблички.'); Level: 1; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Orb
    (Enum: skOrb; Name: 'Знание Сфер';
    Description: ('Позволяет предводителю брать в руки',
    'сферы и использовать их в бою.'); Level: 1; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Sorcery
    (Enum: abSorcery; Name: 'Sorcery';
    Description: ('Allows the leader to cast spells', 'twice a day.'); Level: 1;
    Leaders: MageLeaders; ResEnum: reNone;),
    // Templar
    (Enum: abTemplar; Name: 'Templar';
    Description: ('Allows the leader to heal and resurrect',
    'troops at half the cost'); Level: 1; Leaders: LordLeaders;
    ResEnum: reNone;),
    // Mountaineering
    (Enum: abMountaineering; Name: 'Mountaineering';
    Description: ('The ability allows the leader to pave',
    'the way through the mountains'); Level: 3; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Forestry
    (Enum: abForestry; Name: 'Forestry';
    Description: ('The party does not receive penalty when',
    'moving through forested areas'); Level: 2; Leaders: AllLeaders;
    ResEnum: reNone;),
    // Doragor Power
    (Enum: abDoragorPower; Name: 'Doragor Power';
    Description: ('Allows the leader to cast spells', 'at a greater range');
    Level: 4; Leaders: MageLeaders; ResEnum: reNone;),
    // Vampirism
    (Enum: abVampirism; Name: 'Vampirism';
    Description: ('The leader sucks out the life force', 'of his enemies');
    Level: 1; Leaders: [crNosferat]; ResEnum: reNone;)
    //
    );

implementation

end.
