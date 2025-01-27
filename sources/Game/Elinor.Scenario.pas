unit Elinor.Scenario;

interface

uses
  System.Types;

{
  Сценарии:
  [1] Темная Башня - победить чародея в башне.
  [2] Древние Знания - собрать на карте все каменные таблички с древними знаниями.
  [3] Властитель - захватить все города на карте.
  4  Захватить определенный город.
  5  Добыть определенный артефакт.
  6  Разорить все руины и другие опасные места.
  7  Победить всех врагов на карте.
  8  Что-то выполнить за N дней (лимит времени, возможно опция для каждого сценария).
  9  Драгонхантер - исстребить всех драконов на карте.
}

type
  TScenario = class(TObject)
  public type
    TScenarioEnum = (sgDarkTower, sgOverlord,
      sgAncientKnowledge { , sgDragonhunter } );
  public const
    ScenarioStoneTabMax = 9;
    ScenarioCitiesMax = 7;
    ScenarioTowerIndex = ScenarioCitiesMax + 1;
    ScenarioName: array [TScenarioEnum] of string = ('The Dark Tower',
      'Overlord', 'Ancient Knowledge');
    ScenarioObjective: array [TScenarioEnum] of string =
      ('Destroy the Dark Tower', 'Capture all cities',
      'Find all stone tablets');
  public
    StoneTab: Integer;
    CurrentScenario: TScenarioEnum;
    FStoneTab: array [1 .. ScenarioStoneTabMax] of TPoint;
    StoneCounter: Integer;
    procedure Clear;
    function IsStoneTab(const X, Y: Integer): Boolean;
    procedure AddStoneTab(const X, Y: Integer);
    function ScenarioOverlordState: string;
    function ScenarioAncientKnowledgeState: string;
    class function GetDescription(const AScenarioEnum: TScenarioEnum;
      const AIndex: Integer): string;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Resources,
  Elinor.Map;

{ TScenario }

procedure TScenario.AddStoneTab(const X, Y: Integer);
begin
  Inc(StoneCounter);
  FStoneTab[StoneCounter].X := X;
  FStoneTab[StoneCounter].Y := Y;
end;

procedure TScenario.Clear;
begin
  StoneCounter := 0;
  StoneTab := 0;
end;

class function TScenario.GetDescription(const AScenarioEnum: TScenarioEnum;
  const AIndex: Integer): string;
begin
  Result := TResources.IndexValue('scenario.description', 'dark-tower', AIndex);
end;

function TScenario.IsStoneTab(const X, Y: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ScenarioStoneTabMax do
    if (FStoneTab[I].X = X) and (FStoneTab[I].Y = Y) then
    begin
      Result := True;
      Exit;
    end;
end;

function TScenario.ScenarioAncientKnowledgeState: string;
begin
  Result := Format('Найдено каменных табличек: %d из %d',
    [StoneTab, ScenarioStoneTabMax]);
end;

function TScenario.ScenarioOverlordState: string;
begin
  Result := Format('Захвачено городов: %d из %d',
    [TMapPlace.GetCityCount, ScenarioCitiesMax]);
end;

end.
