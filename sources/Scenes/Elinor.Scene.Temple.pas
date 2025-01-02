unit Elinor.Scene.Temple;

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
  TSceneTemple = class(TSceneBaseParty)
  private type
    TButtonEnum = (btHeal, btRevive, btParty, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextHeal, reTextRevive,
      reTextParty, reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    ConfirmGold: Integer;
    ConfirmParty: TParty;
    ConfirmPartyPosition: TPosition;
    procedure Heal;
    procedure Revive;
    procedure ShowPartyScene;
    procedure ReviveCreature;
    procedure HealCreature;
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
  Elinor.Creatures;

var
  ShowResources: Boolean;
  CurrentParty: TParty;

  { TSceneTemple }

class procedure TSceneTemple.ShowScene(AParty: TParty);
begin
  CurrentParty := AParty;
  ShowResources := AParty = TLeaderParty.Leader;
  if ShowResources then
  begin
    ActivePartyPosition := TLeaderParty.GetPosition;
  end
  else
    ActivePartyPosition := AParty.GetRandomPosition;
  Game.Show(scTemple);
  Game.MediaPlayer.PlaySound(mmSettlement);
end;

class procedure TSceneTemple.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(scSettlement);
end;

constructor TSceneTemple.Create;
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

destructor TSceneTemple.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneTemple.Heal;
  procedure HealIt(const AParty: TParty; const APosition: Integer);
  begin
    with AParty.Creature[APosition] do
    begin
      if not Active then
      begin
        InformDialog('Выберите не пустой слот!');
        Exit;
      end;
      if HitPoints <= 0 then
      begin
        InformDialog('Сначала нужно воскресить!');
        Exit;
      end;
      if HitPoints = MaxHitPoints then
      begin
        InformDialog('Не нуждается в исцелении!');
        Exit;
      end;
      ConfirmGold := TLeaderParty.Leader.GetGold(MaxHitPoints - HitPoints);
      if (ConfirmGold > Game.Gold.Value) then
      begin
        InformDialog('Нужно больше золота!');
        Exit;
      end;
      ConfirmParty := AParty;
      ConfirmPartyPosition := APosition;
      ConfirmDialog(Format('Исцелить за %d золота?', [ConfirmGold]),
        HealCreature);
    end;
  end;

begin
  Game.MediaPlayer.PlaySound(mmClick);
  HealIt(CurrentParty, ActivePartyPosition);
end;

procedure TSceneTemple.HealCreature;
begin
  Game.Gold.Modify(-ConfirmGold);
  ConfirmParty.Heal(ConfirmPartyPosition);
end;

procedure TSceneTemple.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btHeal].MouseDown then
          Heal
        else if Button[btRevive].MouseDown then
          Revive
        else if Button[btParty].MouseDown then
          ShowPartyScene
        else if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneTemple.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneTemple.ShowPartyScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  TSceneParty2.ShowScene(CurrentParty, scTemple);
end;

procedure TSceneTemple.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
  begin
    if (CurrentParty <> nil) then
      for LPosition := Low(TPosition) to High(TPosition) do
        DrawUnit(LPosition, CurrentParty, TFrame.Col(LPosition, psLeft),
          TFrame.Row(LPosition), False, True);
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

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;

  DrawTitle(reTitleTemple);
  RenderParty;
  RenderCharacterInfo;

  RenderButtons;
end;

procedure TSceneTemple.Revive;

  procedure ReviveIt(const AParty: TParty; const APosition: Integer);
  begin
    with AParty.Creature[APosition] do
    begin
      if not Active then
      begin
        InformDialog('Выберите не пустой слот!');
        Exit;
      end;
      if HitPoints > 0 then
      begin
        InformDialog('Не нуждается в воскрешении!');
        Exit;
      end
      else
      begin
        ConfirmGold := TLeaderParty.Leader.GetGold
          (MaxHitPoints + (Level * ((Ord(TSaga.Difficulty) + 1) *
          TSaga.GoldForRevivePerLevel)));
        if (Game.Gold.Value < ConfirmGold) then
        begin
          InformDialog(Format('Для воскрешения нужно %d золота!',
            [ConfirmGold]));
          Exit;
        end;
        ConfirmParty := AParty;
        ConfirmPartyPosition := APosition;
        ConfirmDialog(Format('Воскресить за %d золота?', [ConfirmGold]),
          ReviveCreature);
      end;
    end;
  end;

begin
  Game.MediaPlayer.PlaySound(mmClick);
  ReviveIt(CurrentParty, ActivePartyPosition);
end;

procedure TSceneTemple.ReviveCreature;
begin
  Game.Gold.Modify(-ConfirmGold);
  ConfirmParty.Revive(ConfirmPartyPosition);
end;

procedure TSceneTemple.Timer;
begin
  inherited;

end;

procedure TSceneTemple.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
    K_H:
      Heal;
    K_P:
      ShowPartyScene;
    K_R:
      Revive;
  end;
end;

end.
