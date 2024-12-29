unit Elinor.Scene.Party2;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Scenes,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scene.Base.Party;

type
  TSceneParty2 = class(TSceneBaseParty)
  private type
    TButtonEnum = (btAbilities, btInventory, btDismiss, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextAbilities,
      reTextInventory, reTextDismiss, reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure Abilities;
    procedure Inventory;
    procedure Dismiss;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(AParty: TParty; const ACloseScene: TSceneEnum);
    class procedure HideScene;
  end;

implementation

uses
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scene.Party,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Statistics,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.Settlement;

var
  ShowResources: Boolean;
  CloseScene: TSceneEnum;
  CurrentParty: TParty;

  { TSceneParty }

procedure TSceneParty2.Abilities;
begin

end;

constructor TSceneParty2.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperLeader);
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

destructor TSceneParty2.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneParty2.Dismiss;
begin

end;

procedure TSceneParty2.Inventory;
begin

end;

procedure TSceneParty2.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  ActivePartyPosition := GetPartyPosition(X, Y);
  case AButton of
    mbLeft:
      begin
        if Button[btAbilities].MouseDown then
          Abilities
        else if Button[btInventory].MouseDown then
          Inventory
        else if Button[btDismiss].MouseDown then
          Dismiss
        else if Button[btClose].MouseDown then
          HideScene
      end;
  end;
end;

procedure TSceneParty2.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneParty2.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
  begin
    if (Party <> nil) then
      for LPosition := Low(TPosition) to High(TPosition) do
        DrawUnit(LPosition, CurrentParty, TFrame.Col(LPosition, psLeft),
          TFrame.Row(LPosition), False, True);
  end;

  procedure RenderInfo;
  var
    LCreatureEnum: TCreatureEnum;
  begin
    LCreatureEnum := CurrentParty.Creature[ActivePartyPosition].Enum;
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    if (LCreatureEnum <> crNone) then
      DrawCreatureInfo(CurrentParty.Creature[ActivePartyPosition]);
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Statistics', True);
    AddTextLine;
    AddTextLine('Wins', Game.Statistics.GetValue(stBattlesWon));
    AddTextLine('Kills', Game.Statistics.GetValue(stKilledCreatures));
    AddTextLine('Scores', Game.Statistics.GetValue(stScore));
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine(Format('Speed %d/%d', [TLeaderParty.Leader.Speed,
      TLeaderParty.Leader.MaxSpeed]));
    AddTextLine(Format('Leadership %d', [TLeaderParty.Leader.Leadership]));
    AddTextLine(Format('Radius %d', [TLeaderParty.Leader.Radius]));
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

  DrawTitle(reTitleParty);

  RenderParty;
  RenderInfo;

  RenderButtons;
end;

class procedure TSceneParty2.ShowScene(AParty: TParty;
  const ACloseScene: TSceneEnum);
begin
  CurrentParty := AParty;
  CloseScene := ACloseScene;
  ShowResources := AParty = TLeaderParty.Leader;
  if ShowResources then
  begin
    ActivePartyPosition := TLeaderParty.GetPosition;
  end
  else
    ActivePartyPosition := AParty.GetRandomPosition;
  Game.Show(scParty);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

class procedure TSceneParty2.HideScene;
begin
  Game.Show(CloseScene);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

procedure TSceneParty2.Timer;
begin
  inherited;

end;

procedure TSceneParty2.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
    K_A:
      Abilities;
    K_I:
      Inventory;
    K_D:
      Dismiss;
  end;
end;

end.
