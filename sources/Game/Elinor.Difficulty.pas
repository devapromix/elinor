﻿unit Elinor.Difficulty;

interface

type
  TDifficultyEnum = (dfEasy, dfNormal, dfHard);
  { Expert, Nightmare, Impossible }

const
  DifficultyIdent: array [TDifficultyEnum] of string = ('easy',
    'normal', 'hard');

const
  DifficultyName: array [TDifficultyEnum] of string = ('Apprentice',
    'Adventurer', 'Veteran');

type
  TDifficulty = class(TObject)
  private
    FLevel: TDifficultyEnum;
  public
    constructor Create;
    destructor Destroy; override;
    class function GetDescription(const ADifficultyEnum: TDifficultyEnum;
      const AIndex: Integer): string;
    property Level: TDifficultyEnum read FLevel write FLevel;
  end;

var
  Difficulty: TDifficulty;

implementation

uses
  System.SysUtils,
  Elinor.Resources;

{ TDifficulty }

constructor TDifficulty.Create;
begin
  Self.Level := dfEasy;
end;

destructor TDifficulty.Destroy;
begin

  inherited;
end;

class function TDifficulty.GetDescription(const ADifficultyEnum
  : TDifficultyEnum; const AIndex: Integer): string;
begin
  Result := TResources.IndexValue('difficulty.description',
    DifficultyIdent[ADifficultyEnum], AIndex);
end;

initialization

Difficulty := TDifficulty.Create;

finalization

FreeAndNil(Difficulty);

end.
