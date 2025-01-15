unit Elinor.Scene.Barracks;

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
  TSceneBarracks = class(TSceneBaseParty)
  private type
    TButtonEnum = (btRecruit, btDismiss, btParty, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextRecruit, reTextDismiss,
      reTextParty, reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    ConfirmGold: Integer;
    ConfirmParty: TParty;
    ConfirmPartyPosition: TPosition;
    procedure ShowRecruitScene;
    procedure Dismiss;
    procedure ShowPartyScene;
    procedure DismissCreature;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(AParty: TParty);
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Scene.Settlement,
  Elinor.Scene.Party,
  Elinor.Scene.Party2,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Scene.Hire,
  Elinor.Statistics;

var
  ShowResources: Boolean;
  CurrentParty: TParty;

  { TSceneBarracks }

class procedure TSceneBarracks.ShowScene(AParty: TParty);
begin
  CurrentParty := AParty;
  ShowResources := AParty = TLeaderParty.Leader;
  if ShowResources then
  begin
    ActivePartyPosition := TLeaderParty.GetPosition;
  end
  else
    ActivePartyPosition := AParty.GetRandomPosition;
  Game.Show(scBarracks);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

class procedure TSceneBarracks.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(scSettlement);
end;

constructor TSceneBarracks.Create;
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

destructor TSceneBarracks.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneBarracks.ShowRecruitScene;

  procedure RecruitIt(const AParty: TParty; const APosition: Integer);
  begin
    with AParty.Creature[APosition] do
    begin
      if Active then
      begin
        InformDialog('Выберите пустой слот!');
        Exit;
      end;
      if (((AParty = Party[TLeaderParty.LeaderPartyIndex]) and
        (Party[TLeaderParty.LeaderPartyIndex].Count <
        TLeaderParty.Leader.Leadership)) or
        (AParty <> Party[TLeaderParty.LeaderPartyIndex])) then
      begin
        TSceneRecruit.ShowScene(AParty, APosition);
      end
      else
      begin
        if (Party[TLeaderParty.LeaderPartyIndex].Count = TLeaderParty.Leader.
          Leadership) then
          InformDialog('Нужно развить лидерство!')
        else
          InformDialog('Не возможно нанять!');
        Exit;
      end;
    end;
  end;

begin
  Game.MediaPlayer.PlaySound(mmClick);
  RecruitIt(CurrentParty, ActivePartyPosition);
end;

procedure TSceneBarracks.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btRecruit].MouseDown then
          ShowRecruitScene
        else if Button[btDismiss].MouseDown then
          Dismiss
        else if Button[btParty].MouseDown then
          ShowPartyScene
        else if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneBarracks.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneBarracks.ShowPartyScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  TSceneParty2.ShowScene(CurrentParty, scBarracks);
end;

procedure TSceneBarracks.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
    LCanHire: Boolean;
  begin
    LCanHire := True;
    if CurrentParty = Party[TLeaderParty.LeaderPartyIndex] then
      LCanHire := Party[TLeaderParty.LeaderPartyIndex].Count <
        TLeaderParty.Leader.Leadership;
    if (CurrentParty <> nil) then
      for LPosition := Low(TPosition) to High(TPosition) do
        DrawUnit(LPosition, CurrentParty, TFrame.Col(LPosition, psLeft),
          TFrame.Row(LPosition), LCanHire, True);
  end;

  procedure RenderCharacterInfo;
  var
    LCreatureEnum: TCreatureEnum;
  begin
    LCreatureEnum := CurrentParty.Creature[ActivePartyPosition].Enum;
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    if (LCreatureEnum <> crNone) then
      DrawCreatureInfo(CurrentParty.Creature[ActivePartyPosition]);
  end;

  procedure RenderLeaderInfo;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Statistics', True);
    AddTextLine;
    AddTextLine('Battles Won', Game.Statistics.GetValue(stBattlesWon));
    AddTextLine('Killed Creatures',
      Game.Statistics.GetValue(stKilledCreatures));
    AddTextLine('Tiles Moved', Game.Statistics.GetValue(stTilesMoved));
    AddTextLine('Chests Found', Game.Statistics.GetValue(stChestsFound));
    AddTextLine('Items Found', Game.Statistics.GetValue(stItemsFound));
    AddTextLine('Scores', Game.Statistics.GetValue(stScores));
    AddTextLine;
    AddTextLine('Parameters', True);
    AddTextLine;
    AddTextLine(Format('Speed %d/%d', [TLeaderParty.Leader.Speed.GetCurrValue,
      TLeaderParty.Leader.Speed.GetMaxValue]));
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

  DrawTitle(reTitleBarracks);
  RenderParty;
  RenderCharacterInfo;
  RenderLeaderInfo;

  RenderButtons;
end;

procedure TSceneBarracks.Dismiss;

  procedure DismissIt(const AParty: TParty; const APosition: Integer);
  begin
    with AParty.Creature[APosition] do
    begin
      if not Active then
      begin
        InformDialog('Выберите не пустой слот!');
        Exit;
      end;
      if Leadership > 0 then
      begin
        InformDialog('Не возможно уволить!');
        Exit;
      end
      else
      begin
        ConfirmParty := AParty;
        ConfirmPartyPosition := APosition;
        ConfirmDialog('Отпустить воина?', DismissCreature);
      end;
    end;
  end;

begin
  Game.MediaPlayer.PlaySound(mmClick);
  DismissIt(CurrentParty, ActivePartyPosition);
end;

procedure TSceneBarracks.DismissCreature;
begin
  if ConfirmParty.Dismiss(ConfirmPartyPosition) then
    Game.MediaPlayer.PlaySound(mmDismiss);
end;

procedure TSceneBarracks.Timer;
begin
  inherited;

end;

procedure TSceneBarracks.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
    K_R:
      ShowRecruitScene;
    K_P:
      ShowPartyScene;
    K_D:
      Dismiss;
  end;
end;

end.
