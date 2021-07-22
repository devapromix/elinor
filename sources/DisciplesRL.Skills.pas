unit DisciplesRL.Skills;

interface

uses
  DisciplesRL.Resources;

type
  TSkillEnum = (skNone, skFly, skStrenght, skSpy, skHawkEye, skArtifact,
    skBanner, skBoots, skLeadership1, skLeadership2, skLeadership3,
    skLeadership4, skLeadership5, skWand, skAccuracy, skOri, skTrader,
    skProtect, skTalisman, skInstructor, skBook, skOrb);

type
  TSkill = record
    Enum: TSkillEnum;
    Name: string;
    Description: array [0 .. 1] of string;
    Level: Byte;
  end;

const
  SkillBase: array [TSkillEnum] of TSkill = (
    // None
    (Enum: skNone; Name: ''; Description: ('', ''); Level: 1;),
    // Fly
    (Enum: skFly; Name: 'Полет'; Description: ('Умение позволяет предводителю',
    'и его отряду летать над землей.'); Level: 1;),
    // Strength
    (Enum: skStrenght; Name: 'Сила';
    Description: ('Добавляет к атаке предводителя', '25% урона.'); Level: 5;),
    // Spy
    (Enum: skSpy; Name: 'Тайные Тропы';
    Description: ('Предводитель скрытно проведет отряд',
    'в любой из уголков Невендаара.'); Level: 1;),
    // Sharp Eye
    (Enum: skHawkEye; Name: 'Зоркость';
    Description: ('Позволяет предводителю видеть', 'дальше на 2 тайла.');
    Level: 1;),
    // Artifact
    (Enum: skArtifact; Name: 'Знание Артефактов';
    Description: ('Позволяет предводителю носить', 'магические артефакты.');
    Level: 1;),
    // Banner
    (Enum: skBanner; Name: 'Знаменосец';
    Description: ('Позволяет предводителю носить', 'боевые знамена.');
    Level: 2;),
    // Boots
    (Enum: skBoots; Name: 'Опыт Странника';
    Description: ('Позволяет предводителю носить', 'магическую обувь.');
    Level: 1;),
    // Leadership #1
    (Enum: skLeadership1; Name: 'Лидерство';
    Description: ('Позволяет предводителю взять в', 'отряд еще одного воина.');
    Level: 2;),
    // Leadership #2
    (Enum: skLeadership2; Name: 'Лидерство';
    Description: ('Позволяет предводителю взять в', 'отряд еще одного воина.');
    Level: 3;),
    // Leadership #3
    (Enum: skLeadership3; Name: 'Лидерство';
    Description: ('Позволяет предводителю взять в', 'отряд еще одного воина.');
    Level: 4;),
    // Leadership #4
    (Enum: skLeadership4; Name: 'Лидерство';
    Description: ('Позволяет предводителю взять в', 'отряд еще одного воина.');
    Level: 5;),
    // Leadership #5
    (Enum: skLeadership5; Name: 'Лидерство';
    Description: ('Позволяет предводителю взять в', 'отряд еще одного воина.');
    Level: 6;),
    // Wand
    (Enum: skWand; Name: 'Посохи и Свитки';
    Description: ('Позволяет предводителю использовать',
    'магические посохи и свитки.'); Level: 1;),
    // Accuracy
    (Enum: skAccuracy; Name: 'Точность';
    Description: ('Увеличивает шанс предводителя', 'попасть по противнику.');
    Level: 7;),
    // Ori
    (Enum: skOri; Name: 'Ориентирование';
    Description: ('Увеличивает дистанцию, которую может',
    'пройти отряд предводителя.'); Level: 1;),
    // Trader
    (Enum: skTrader; Name: 'Торговец';
    Description: ('Обладатель этой способности',
    'получает скидку 20% у торговца.'); Level: 4;),
    // Protect
    (Enum: skProtect; Name: 'Естественная Броня';
    Description: ('Предводитель будет поглощать 20%', 'наносимого ему урона.');
    Level: 6;),
    // Talisman
    (Enum: skTalisman; Name: 'Сила Талисманов';
    Description: ('Позволяет предводителю надевать',
    'талисманы и использовать их в бою.'); Level: 1;),
    // Instructor
    (Enum: skInstructor; Name: 'Инструктор';
    Description: ('Все воины в отряде предводителя',
    'будут получать больше опыта.'); Level: 5;),
    // Book
    (Enum: skBook; Name: 'Тайное Знание';
    Description: ('Позволяет предводителю читать',
    'магические книги и таблички.'); Level: 2;),
    // Orb
    (Enum: skOrb; Name: 'Знание Сфер';
    Description: ('Позволяет предводителю брать в руки',
    'сферы и использовать их в бою.'); Level: 1;)
    //
    );

const
  MaxSkills = 12;

type
  TSkills = class(TObject)
  private
    FSkill: array [0 .. MaxSkills - 1] of TSkill;
  public
    RandomSkillEnum: array [0 .. 2] of TSkillEnum;
    constructor Create;
    destructor Destroy; override;
    function Has(const SkillEnum: TSkillEnum): Boolean;
    procedure Add(const SkillEnum: TSkillEnum);
    function Get(const I: Integer): TSkillEnum;
    procedure Gen;
    procedure Clear;
  end;

implementation

uses
  Math,
  SysUtils,
  DisciplesRL.Party;

{ TSkills }

procedure TSkills.Add(const SkillEnum: TSkillEnum);
var
  I: Integer;
begin
  for I := 0 to MaxSkills - 1 do
    if (FSkill[I].Enum = skNone) then
    begin
      FSkill[I] := SkillBase[SkillEnum];
      Exit;
    end;
end;

procedure TSkills.Clear;
var
  I: Integer;
begin
  for I := 0 to MaxSkills - 1 do
    FSkill[I] := SkillBase[skNone];
end;

constructor TSkills.Create;
begin
  Self.Clear;
end;

destructor TSkills.Destroy;
begin

  inherited;
end;

procedure TSkills.Gen;
var
  J: Integer;
  I, R: TSkillEnum;
begin
  for J := 0 to 2 do
    RandomSkillEnum[J] := skNone;
  for J := 0 to 2 do
  begin
    repeat
      R := TSkillEnum(RandomRange(Ord(Succ(Low(TSkillEnum))),
        Ord(High(TSkillEnum))));
    until not Has(R) and (R <> RandomSkillEnum[0]) and (R <> RandomSkillEnum[1])
      and (R <> RandomSkillEnum[2]) and
      (SkillBase[R].Level <= TLeaderParty.Leader.Level);
    RandomSkillEnum[J] := R;
  end;
end;

function TSkills.Get(const I: Integer): TSkillEnum;
begin
  Result := FSkill[I].Enum;
end;

function TSkills.Has(const SkillEnum: TSkillEnum): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to MaxSkills - 1 do
    if FSkill[I].Enum = SkillEnum then
    begin
      Result := True;
      Exit;
    end;
end;

end.
