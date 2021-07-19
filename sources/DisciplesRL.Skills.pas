﻿unit DisciplesRL.Skills;

interface

uses
  DisciplesRL.Resources;

type
  TSkillEnum = (skNone, skFly, skSpy, skArtifact, skBanner, skBoots,
    skLeadership, skWand, skAuras, skOri);

type
  TSkill = record
    Enum: TSkillEnum;
    Name: string;
    Description: array [0 .. 1] of string;
  end;

const
  SkillBase: array [TSkillEnum] of TSkill = (
    // None
    (Enum: skNone; Name: ''; Description: ('', '');),
    // Fly
    (Enum: skFly; Name: 'Полет'; Description: ('Умение позволяет предводителю',
    'и его отряду летать над землей.');),
    // Spy
    (Enum: skSpy; Name: 'Тайные Тропы';
    Description: ('Предводитель скрытно проведет отряд',
    'в любой из уголков Невендаара.');),
    // Artifact
    (Enum: skArtifact; Name: 'Знание Артефактов';
    Description: ('Позволяет предводителю носить', 'магические артефакты.');),
    // Banner
    (Enum: skBanner; Name: 'Знаменосец';
    Description: ('Позволяет предводителю носить', 'боевые знамена.');),
    // Boots
    (Enum: skBoots; Name: 'Опыт Странника';
    Description: ('Позволяет предводителю носить', 'магическую обувь.');),
    // Leadership
    (Enum: skLeadership; Name: 'Лидерство';
    Description: ('Позволяет предводителю взять в',
    'отряд еще одного воина.');),
    // Wand
    (Enum: skWand; Name: 'Посохи и Свитки';
    Description: ('Позволяет предводителю использовать',
    'магические посохи и свитки.');),
    // Auras
    (Enum: skAuras; Name: 'Ауры'; Description: ('Магические ауры предводителя',
    'благотворно влияют на весь отряд.');),
    // Ori
    (Enum: skOri; Name: 'Ориентирование';
    Description: ('Увеличивает дистанцию, которую может',
    'пройти отряд предводителя.');)
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
    function Has(const SkillEnum: TSkillEnum): Boolean;
    procedure Add(const SkillEnum: TSkillEnum);
    function Get(const I: Integer): TSkillEnum;
    procedure Clear;
  end;

implementation

uses
  SysUtils;

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