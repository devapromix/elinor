unit DisciplesRL.Leader;

interface

uses
  System.Types,
  DisciplesRL.Party,
  DisciplesRL.Creatures,
  MapObject;

type
  TLeader = class(TMapObject)
  private
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  Leader: TLeader;

implementation

uses
  System.Math,
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Places,
  DisciplesRL.Scenes,
  DisciplesRL.Saga,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.PascalScript.Battle,
  DisciplesRL.PascalScript.Vars,
  DisciplesRL.Scene.Battle,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Info;

{ TLeader }

constructor TLeader.Create;
begin
  inherited;
end;

destructor TLeader.Destroy;
begin

  inherited;
end;

initialization

Leader := TLeader.Create;

finalization

FreeAndNil(Leader);

end.
