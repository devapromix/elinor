unit Elinor.Ability.Base;

// https://gamefaqs.gamespot.com/pc/918958-disciples-ii-rise-of-the-elves/faqs
// https://disciples.fandom.com/wiki/Skill_guide_for_Disciples_II:_Dark_Prophecy
// https://www.ign.com/articles/2005/12/19/disciples-ii-rise-of-the-elves-items-listfaq-677342

interface

uses
  Elinor.Ability,
  Elinor.Creature.Types,
  Elinor.Resources;

const
  AbilityBase: array [TAbilityEnum] of TAbility = (
    // None
    (Enum: abNone; Name: ''; Description: ('', ''); Level: 1; Leaders: [];
    ResEnum: arNone;),
    // Flying
    (Enum: abFlying; Name: 'Flying';
    Description: ('The skill allows the leader and',
    'his party to fly above the ground'); Level: 1; Leaders: FlyLeaders;
    ResEnum: arNone;),
    // Strength
    (Enum: abStrength; Name: 'Strength';
    Description: ('Adds 10% damage to the attack', 'of the fighter leader');
    Level: 4; Leaders: FighterLeaders; ResEnum: arNone;),
    // Might
    (Enum: abMight; Name: 'Might';
    Description: ('Adds 15% damage to the attack', 'of the fighter leader');
    Level: 6; Leaders: FighterLeaders; ResEnum: arNone;),
    // Stealth
    (Enum: abStealth; Name: 'Stealth';
    Description: ('The leader will secretly lead the',
    'detachment to any corner of Nevendaar'); Level: 1; Leaders: ThiefLeaders;
    ResEnum: arNone;),
    // Sharp Eye
    (Enum: abSharpEye; Name: 'Sharp Eye';
    Description: ('Allows the leader to see ', 'further'); Level: 1;
    Leaders: ScoutingLeaders; ResEnum: arSharpEye;),
    // Hawk Eye
    (Enum: abHawkEye; Name: 'Hawk Eye';
    Description: ('Allows the leader to see ', 'further'); Level: 3;
    Leaders: ScoutingLeaders; ResEnum: arNone;),
    // Far Sight
    (Enum: abFarSight; Name: 'Far Sight';
    Description: ('Allows the leader to see ', 'further'); Level: 5;
    Leaders: AllLeaders; ResEnum: arNone;),
    // Artifact Lore
    (Enum: abArtifactLore; Name: 'Artifact Lore';
    Description: ('Allows the leader to wear rare', 'magical artifacts');
    Level: 1; Leaders: AllLeaders; ResEnum: arNone;),
    // Banner Bearer
    (Enum: abBannerBearer; Name: 'Banner Bearer';
    Description: ('Allows the leader to carry', 'battle flags'); Level: 1;
    Leaders: AllLeaders; ResEnum: arNone;),
    // Travel Lore
    (Enum: abTravelLore; Name: 'Travel Lore';
    Description: ('Allows the leader to wear magic', 'shoes'); Level: 1;
    Leaders: AllLeaders; ResEnum: arNone;),
    // Leadership #1
    (Enum: abLeadership1; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 1; Leaders: AllLeaders; ResEnum: arNone;),
    // Leadership #2
    (Enum: abLeadership2; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 2; Leaders: AllLeaders; ResEnum: arNone;),
    // Leadership #3
    (Enum: abLeadership3; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 3; Leaders: AllLeaders; ResEnum: arNone;),
    // Leadership #4
    (Enum: abLeadership4; Name: 'Leadership';
    Description: ('Allows the leader to take a warrior', 'into the party');
    Level: 4; Leaders: AllLeaders; ResEnum: arNone;),
    // Use Staffs And Scrolls
    (Enum: abUseStaffsAndScrolls; Name: 'Use Staffs And Scrolls';
    Description: ('Allows the leader to use ', 'magic staffs and scrolls');
    Level: 1; Leaders: MageLeaders; ResEnum: arUseStaffsAndScrolls;),
    // Accuracy
    (Enum: abAccuracy; Name: 'Accuracy';
    Description: ('Increases the leader''s chance to', 'hit the enemy');
    Level: 6; Leaders: AllLeaders; ResEnum: arNone;),
    // Pathfinding
    (Enum: abPathfinding; Name: 'Pathfinding';
    Description: ('Increases the distance that the',
    'leader''s party can travel'); Level: 1; Leaders: AllLeaders;
    ResEnum: arNone;),
    // Advanced Pathfinding
    (Enum: abAdvancedPathfinding; Name: 'Advanced Pathfinding';
    Description: ('Increases the distance that the',
    'leader''s party can travel'); Level: 4; Leaders: ScoutingLeaders;
    ResEnum: arNone;),
    // Dealmaker
    (Enum: abDealmaker; Name: 'Dealmaker';
    Description: ('The owner of this ability',
    'receives a 10% discount from the merchant'); Level: 4; Leaders: AllLeaders;
    ResEnum: arNone;),
    // Haggler
    (Enum: abHaggler; Name: 'Haggler';
    Description: ('The owner of this ability',
    'receives a 15% discount from the merchant'); Level: 5;
    Leaders: LordLeaders; ResEnum: arNone;),
    // Natural Armor
    (Enum: abNaturalArmor; Name: 'Natural Armor';
    Description: ('The leader will absorb 10% of ', 'damage dealt to him');
    Level: 6; Leaders: AllLeaders; ResEnum: arNone;),
    // Arcane Power
    (Enum: abArcanePower; Name: 'Arcane Power';
    Description: ('Allows the leader to put on talismans',
    'and use them in battle'); Level: 1; Leaders: AllLeaders; ResEnum: arNone;),
    // Weapon Master
    (Enum: abWeaponMaster; Name: 'Weapon Master';
    Description: ('All the warriors in the party of the leader',
    'will gain more experience'); Level: 4; Leaders: AllLeaders;
    ResEnum: arNone;),
    // Arcane Knowledge
    (Enum: abArcaneKnowledge; Name: 'Arcane Knowledge';
    Description: ('Allows the leader to read', 'magic books'); Level: 1;
    Leaders: AllLeaders; ResEnum: arNone;),
    // Arcane Lore
    (Enum: abArcaneLore; Name: 'Arcane Lore';
    Description: ('Allows the leader to take in hand',
    'spheres and use them in battle'); Level: 1; Leaders: AllLeaders;
    ResEnum: arArcaneLore;),
    // Sorcery
    (Enum: abSorcery; Name: 'Sorcery';
    Description: ('Allows the leader to cast spells', 'twice a day'); Level: 1;
    Leaders: MageLeaders; ResEnum: arNone;),
    // Templar
    (Enum: abTemplar; Name: 'Templar';
    Description: ('Allows the leader to heal and resurrect',
    'troops at half the cost'); Level: 1; Leaders: LordLeaders;
    ResEnum: arNone;),
    // Mountaineering
    (Enum: abMountaineering; Name: 'Mountaineering';
    Description: ('The ability allows the leader to pave',
    'the way through the mountains'); Level: 3; Leaders: AllLeaders;
    ResEnum: arNone;),
    // Forestry
    (Enum: abForestry; Name: 'Forestry';
    Description: ('The party does not receive penalty when',
    'moving through forested areas'); Level: 2; Leaders: AllLeaders;
    ResEnum: arNone;),
    // Doragor Power
    (Enum: abDoragorPower; Name: 'Doragor Power';
    Description: ('Allows the leader to cast spells', 'at a greater range');
    Level: 4; Leaders: MageLeaders; ResEnum: arNone;),
    // Vampirism
    (Enum: abVampirism; Name: 'Vampirism';
    Description: ('The leader sucks out the life force', 'of his enemies');
    Level: 1; Leaders: [crNosferatu]; ResEnum: arNone;),
    // Natural Healing
    (Enum: abNaturalHealing; Name: 'Natural Healing';
    Description: ('This ability allows the leader',
    'to heal 10% of his life every day'); Level: 3; Leaders: TemplarLeaders;
    ResEnum: arNone;),
    // Logistics
    (Enum: abLogistics; Name: 'Logistics';
    Description: ('The leader''s party can travel',
    'a greater distance in a day'); Level: 5; Leaders: LordLeaders;
    ResEnum: arNone;),
    // Golem Mastery
    (Enum: abGolemMastery; Name: 'Golem Mastery';
    Description: ('The leader can summon', 'golems'); Level: 5;
    Leaders: MageLeaders; ResEnum: arNone;)
    //
    );

implementation

end.
