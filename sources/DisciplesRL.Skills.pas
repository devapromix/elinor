unit DisciplesRL.Skills;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

uses
  DisciplesRL.Resources;

type
  TSkillEnum = (skNone, skFly, skSpy, skArtifact, skBanner, skBoots, skLeadership,
    skWand, skAuras, skOri);

type
  TSkill = record
    Enum: TSkillEnum;
    Name: string;
    Description: string;
  end;

const
  SkillBase: array [TSkillEnum] of TSkill = (
    // None
    (Enum: skNone; Name: ''; Description: '';),
    // Fly
    (Enum: skFly; Name: 'Полет';
    Description: 'Умение позволяет предводителю и его отряду летать.';),
    // Spy
    (Enum: skSpy; Name: 'Тайные Тропы';
    Description: 'Предводитель скрытно проведет отряд в любой уголов Невендаара.';),
    // Artifact
    (Enum: skArtifact; Name: 'Знание Артефактов';
    Description: 'Позволяет предводителю носить артефакты.';),
    // Banner
    (Enum: skBanner; Name: 'Знаменосец';
    Description: 'Позволяет предводителю носить знамена.';),
    // Boots
    (Enum: skBoots; Name: 'Опыт Странника';
    Description: 'Позволяет предводителю носить магическую обувь.';),
    // Leadership
    (Enum: skLeadership; Name: 'Лидерство';
    Description: 'Позволяет предводителю взять в отряд еще одного воина.';),
    // Wand
    (Enum: skWand; Name: 'Посохи и Свитки';
    Description: 'Позволяет предводителю использовать посохи и свитки.';),
    // Auras
    (Enum: skAuras; Name: 'Ауры';
    Description: 'Предводитель умеет использовать магические ауры.';),
    // Ori
    (Enum: skOri; Name: 'Ориентирование';
    Description: 'Увеличивает передвижение предводителя.';)
    //
    );

const
  MaxSkills = 12;

type
  TSkills = class(TObject)
  private
    FSkill: array [0 .. MaxSkills - 1] of TSkill;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

implementation

uses
  SysUtils;

{ TSkills }

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

end.
