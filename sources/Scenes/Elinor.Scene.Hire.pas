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
  TSceneHire2 = class(TSceneWideMenu)
  private type
    TButtonEnum = (btHire, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextHire, reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure Hire;
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
  Elinor.Creatures,
  Elinor.Frame;

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;

  { TSceneHire }

constructor TSceneHire2.Create;
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

destructor TSceneHire2.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

class procedure TSceneHire2.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(scSettlement);
end;

procedure TSceneHire2.Hire;
begin

end;

class function TSceneHire2.HireIndex: Integer;
begin
  // Result := CurrentIndex;
end;

procedure TSceneHire2.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btHire].MouseDown then
          Hire
        else if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneHire2.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneHire2.Render;

  procedure RenderParty;
  var
    LRaceCharKind: TRaceCharKind;
    LX, LY, LLeft, LTop: Integer;
  begin
    for LRaceCharKind := Low(TRaceCharKind) to High(TRaceCharKind) do
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

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;
  DrawTitle(reTitleHire);

  RenderParty;

  RenderButtons;
end;

class procedure TSceneHire2.ShowScene(const AParty: TParty;
  const APosition: Integer);
begin
  // CurrentIndex := 0;
  HireParty := AParty;
  HirePosition := APosition;
  Game.Show(scHire2);
end;

procedure TSceneHire2.Timer;
begin
  inherited;

end;

procedure TSceneHire2.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE:
      HideScene;
    K_ENTER:
      Hire;
  end;
end;

end.
