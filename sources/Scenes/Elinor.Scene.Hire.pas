unit Elinor.Scene.Hire;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Party,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Scene.Menu.Wide;

type
  TSceneRecruit = class(TSceneWideMenu)
  private type
    TButtonEnum = (btHire, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextRecruit, reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure Recruit;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class function HireIndex: Integer;
    class procedure ShowScene(const AParty: TParty; const APosition: Integer);
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenes,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Frame;

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;

  { TSceneHire }

constructor TSceneRecruit.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperSettlement);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Sellected := True;
  end;
end;

destructor TSceneRecruit.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

class procedure TSceneRecruit.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(scBarracks);
end;

procedure TSceneRecruit.Recruit;
var
  LCreatureEnum: TCreatureEnum;
begin
  LCreatureEnum := Characters[PartyList.Party[TLeaderParty.LeaderPartyIndex].Owner]
    [cgCharacters][TFactionLeaderKind(CurrentIndex)];
  if (LCreatureEnum = crNone) then
    Exit;
  if HireParty.Hire(LCreatureEnum, HirePosition) then
  begin
    Game.MediaPlayer.PlaySound(mmGold);
    Game.Show(scBarracks);
  end
  else
    InformDialog('Не хватает денег!');
end;

class function TSceneRecruit.HireIndex: Integer;
begin
  // Result := CurrentIndex;
end;

procedure TSceneRecruit.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btHire].MouseDown then
          Recruit
        else if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneRecruit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneRecruit.Render;

  procedure RenderCharacters;
  var
    LRaceCharKind: TFactionLeaderKind;
    LX, LY, LLeft, LTop: Integer;
  begin
    for LRaceCharKind := Low(TFactionLeaderKind) to High(TFactionLeaderKind) do
    begin
      LX := IfThen(Ord(LRaceCharKind) > 2, 1, 0);
      LY := IfThen(Ord(LRaceCharKind) > 2, Ord(LRaceCharKind) - 3,
        Ord(LRaceCharKind));
      with TCreature.Character(Characters[TLeaderParty.Leader.Owner]
        [cgCharacters][LRaceCharKind]) do
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

  procedure RenderCharacterInfo;
  var
    LCreatureEnum: TCreatureEnum;
  begin
    LCreatureEnum := Characters[PartyList.Party[TLeaderParty.LeaderPartyIndex].Owner]
      [cgCharacters][TFactionLeaderKind(CurrentIndex)];
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    if (LCreatureEnum <> crNone) then
      DrawCreatureInfo(TCreature.Character(LCreatureEnum));
  end;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;
  DrawTitle(reTitleRecruit);

  RenderCharacters;
  RenderCharacterInfo;

  RenderButtons;
end;

class procedure TSceneRecruit.ShowScene(const AParty: TParty;
  const APosition: Integer);
begin
  HireParty := AParty;
  HirePosition := APosition;
  Game.Show(scHire);
end;

procedure TSceneRecruit.Timer;
begin
  inherited;

end;

procedure TSceneRecruit.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE:
      HideScene;
    K_ENTER, K_R:
      Recruit;
  end;
end;

end.
