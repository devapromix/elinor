unit Elinor.Scene.Victory;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Scene.Base.Party,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneVictory = class(TSceneBaseParty)
  private type
    TButtonEnum = (btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Scene.Records,
  Elinor.Scene.Party2,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Statistics;

{ TSceneVictory }

class procedure TSceneVictory.ShowScene;
begin
  ActivePartyPosition := TLeaderParty.GetPosition;
  Game.Show(scVictory);
  Game.MediaPlayer.PlayMusic(mmVictory);
end;

class procedure TSceneVictory.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlayMusic(mmMenu);
  Game.IsGame := False;
  Game.LeaderRecordsTable.AddRecord
    (TCreature.Character(TLeaderParty.Leader.Enum).Name[0],
    TLeaderParty.Leader.Owner, TLeaderParty.Leader.LeaderClass,
    Game.Statistics.GetValue(stScores));
  Game.LeaderRecordsTable.SaveToFile;
  TSceneRecords.ShowScene;
end;

constructor TSceneVictory.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperDefeat);
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

destructor TSceneVictory.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneVictory.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneVictory.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneVictory.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
  begin
    for LPosition := Low(TPosition) to High(TPosition) do
      DrawUnit(LPosition, TLeaderParty.Leader, TFrame.Col(LPosition, psLeft),
        TFrame.Row(LPosition), False, True);
  end;

  procedure RenderCharacterInfo;
  var
    LCreatureEnum: TCreatureEnum;
  begin
    LCreatureEnum := TLeaderParty.Leader.Creature[ActivePartyPosition].Enum;
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    if (LCreatureEnum <> crNone) then
      DrawCreatureInfo(TLeaderParty.Leader.Creature[ActivePartyPosition]);
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

  DrawTitle(reTitleVictory);

  RenderParty;
  RenderCharacterInfo;

  RenderLeaderInfo(True);

  RenderButtons;
end;

procedure TSceneVictory.Timer;
begin
  inherited;

end;

procedure TSceneVictory.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
  end;
end;

end.
