unit Elinor.Scene.Defeat;

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
  TSceneDefeat = class(TSceneBaseParty)
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
  Elinor.Scene.Party,
  Elinor.Scene.Party2,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Creature.Types,
  Elinor.Creatures;

{ TSceneDefeat }

class procedure TSceneDefeat.ShowScene;
begin
  ActivePartyPosition := TLeaderParty.GetPosition;
  Game.Show(scDefeat);
end;

class procedure TSceneDefeat.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlayMusic(mmMenu);
  Game.IsGame := False;
  TSceneHighScores.ShowScene;
end;

constructor TSceneDefeat.Create;
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

destructor TSceneDefeat.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneDefeat.MouseDown(AButton: TMouseButton; Shift: TShiftState;
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

procedure TSceneDefeat.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneDefeat.Render;

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

  DrawTitle(reTitleDefeat);

  RenderParty;
  RenderCharacterInfo;

  RenderLeaderInfo(True);

  RenderButtons;
end;

procedure TSceneDefeat.Timer;
begin
  inherited;

end;

procedure TSceneDefeat.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
  end;
end;

end.
