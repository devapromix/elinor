unit Elinor.Scene.Records;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneRecords = class(TSceneFrames)
  private type
    TButtonEnum = (btFaction, btClass, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextFaction, reTextClass,
      reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure FilterByFaction;
    procedure FilterByClass;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Update(var Key: Word); override;
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Scenario,
  Elinor.Frame, Elinor.Creatures;

{ TSceneHighScores }

constructor TSceneRecords.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperLeader, fgLS6, fgRB);
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

destructor TSceneRecords.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneRecords.FilterByClass;
begin

end;

procedure TSceneRecords.FilterByFaction;
begin

end;

class procedure TSceneRecords.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scMenu);
end;

procedure TSceneRecords.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btFaction].MouseDown then
          FilterByFaction
        else if Button[btClass].MouseDown then
          FilterByClass
        else if Button[btClose].MouseDown then
          HideScene
      end;
  end;

end;

procedure TSceneRecords.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneRecords.Render;
var
  LScenarioEnum: TScenarioEnum;

  procedure RenderClass;
  var
    LRaceCharKind: TFactionLeaderKind;
    LLeft, LTop: Integer;
  begin
    for LRaceCharKind := Low(TFactionLeaderKind) to High(TFactionLeaderKind) do
    begin
      LLeft := IfThen(Ord(LRaceCharKind) > 2, TFrame.Col(1), TFrame.Col(0));
      LTop := IfThen(Ord(LRaceCharKind) > 2, TFrame.Row(Ord(LRaceCharKind) - 3),
        TFrame.Row(Ord(LRaceCharKind)));
      with TCreature.Character(Characters[Game.Scenario.Faction][cgLeaders]
        [LRaceCharKind]) do
        if HitPoints > 0 then
        begin
          DrawUnit(ResEnum, LLeft, LTop, bsCharacter);
          DrawUnitInfo(LLeft, LTop, Characters[Game.Scenario.Faction][cgLeaders]
            [LRaceCharKind], False);
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
  DrawTitle(reTitleHighScores);

  RenderClass;

  RenderButtons;
end;

class procedure TSceneRecords.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scHighScores);
end;

procedure TSceneRecords.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
    K_F:
      FilterByFaction;
    K_C:
      FilterByClass;
  end;
end;

end.
