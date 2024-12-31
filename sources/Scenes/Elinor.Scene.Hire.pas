unit Elinor.Scene.Hire;

interface

uses
  Elinor.Party,
  Elinor.Scene.Menu.Wide;

type
  TSceneHire2 = class(TSceneWideMenu)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    class function HireIndex: Integer;
    class procedure ShowScene(const AParty: TParty; const APosition: Integer);
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenes,
  Elinor.Resources, Elinor.Creatures, Elinor.Frame;

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;

  { TSceneHire }

constructor TSceneHire2.Create;
begin
  inherited Create(reWallpaperSettlement);
end;

destructor TSceneHire2.Destroy;
begin

  inherited;
end;

class function TSceneHire2.HireIndex: Integer;
begin
   //Result := CurrentIndex;
end;

procedure TSceneHire2.Render;
var
  LRaceCharKind: TRaceCharKind;
  LX, LY, LLeft, LTop: Integer;
begin
  inherited;
  DrawTitle(reTitleHire);
  for LRaceCharKind := Low(TRaceCharKind) to High(TRaceCharKind) do
  begin
    LX := IfThen(Ord(LRaceCharKind) > 2, 1, 0);
    LY := IfThen(Ord(LRaceCharKind) > 2, Ord(LRaceCharKind) - 3,
      Ord(LRaceCharKind));
    with TCreature.Character(Characters[TLeaderParty.Leader.Owner][cgCharacters]
      [LRaceCharKind]) do
      if HitPoints > 0 then
      begin
        LLeft := TFrame.Col(LX);
        LTop := TFrame.Row(LY);
        DrawUnit(ResEnum, LLeft, LTop, bsCharacter);
        DrawUnitInfo(LLeft, LTop, Characters[TLeaderParty.Leader.Owner]
          [cgCharacters][LRaceCharKind], False);
      end;
  end;

end;

class procedure TSceneHire2.ShowScene(const AParty: TParty;
  const APosition: Integer);
begin
  // CurrentIndex := 0;
  HireParty := AParty;
  HirePosition := APosition;
  Game.Show(scHire2);
end;

procedure TSceneHire2.Update(var Key: Word);
begin
  inherited;

end;

end.
