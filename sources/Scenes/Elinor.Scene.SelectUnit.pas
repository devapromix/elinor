unit Elinor.Scene.SelectUnit;

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
  TSceneSelectUnit = class(TSceneBaseParty)
  private type
    TButtonEnum = (btSelect, btCancel);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextSelect, reTextCancel);
  private
    Button: array [TButtonEnum] of TButton;
    ConfirmGold: Integer;
    ConfirmParty: TParty;
    ConfirmPartyPosition: TPosition;
    procedure SelectUnit;
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
    class function SelectCurrUnit(AParty: TParty): Boolean;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Scene.Settlement,
  Elinor.Scene.Recruit,
  Elinor.Scene.Party2,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Statistics,
  Elinor.Common,
  Elinor.Items, Elinor.Scene.Battle2;

var
  CurrentParty: TParty;
  LastActivePartyPosition: Integer = 2;

  { TSceneSelectUnit }

class procedure TSceneSelectUnit.ShowScene(AParty: TParty);
begin
  CurrentParty := AParty;
  LastActivePartyPosition := ActivePartyPosition;
  ActivePartyPosition := AParty.GetRandomPosition;
  Game.Show(scSelectUnit);
end;

class procedure TSceneSelectUnit.HideScene;
begin
  ActivePartyPosition := LastActivePartyPosition;
  Game.MediaPlayer.PlaySound(mmClick);
  Game.BackToScene(scBattle);
end;

constructor TSceneSelectUnit.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperScenario);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btSelect) then
      Button[LButtonEnum].Selected := True;
  end;
end;

destructor TSceneSelectUnit.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneSelectUnit.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPosition: TPosition;
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btSelect].MouseDown then
          SelectUnit
        else if Button[btCancel].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneSelectUnit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

class function TSceneSelectUnit.SelectCurrUnit(AParty: TParty): Boolean;
begin
  Result := False;
  ShowScene(AParty);
end;

procedure TSceneSelectUnit.SelectUnit;
var
  LItem: TItem;
begin
  LItem := TLeaderParty.Leader.Equipment.Item(6);
  case LItem.Enum of
    iOrbOfLife:
      begin
        if not CurrentParty.Creature[ActivePartyPosition].Active then
        begin
          InformDialog(CChooseNonEmptySlot);
          Exit;
        end;
        if CurrentParty.Creature[ActivePartyPosition].Alive then
        begin
          InformDialog(CNoRevivalNeeded);
          Exit;
        end;
      end;
    iGoblinOrb:
      begin
        if CurrentParty.Creature[ActivePartyPosition].Active then
        begin
          InformDialog(CChooseEmptySlot);
          Exit;
        end;
      end;
  else
    if not CurrentParty.Creature[ActivePartyPosition].Alive then
    begin
      InformDialog(CSelectLlivingCreature);
      Exit;
    end;
  end;
  case LItem.Enum of
    iTalismanOfNosferat:
      begin
        Game.MediaPlayer.PlaySound(mmUseOrb);
        CurrentParty.TakeDamage(25, ActivePartyPosition);
        TLeaderParty.Leader.UpdateHP(25, TLeaderParty.GetPosition);
        PendingTalismanOrOrbLogString := Format(CYouUsedTheItem,
          [TItemBase.Item(LItem.Enum).Name]) + ' Drains life from enemy.';
      end;
    iTalismanOfFear:
      begin
        Game.MediaPlayer.PlaySound(mmUseOrb);
        CurrentParty.Paralyze(ActivePartyPosition);
        PendingTalismanOrOrbLogString := Format(CYouUsedTheItem,
          [TItemBase.Item(LItem.Enum).Name]) + ' Paralyzes the enemy.';
      end;
    iTalismanOfRage:
      begin
        Game.MediaPlayer.PlaySound(mmUseOrb);
        PendingTalismanOrOrbLogString := Format(CYouUsedTheItem,
          [TItemBase.Item(LItem.Enum).Name]) + ' Gives an extra attack!';
        Game.MediaPlayer.PlaySound(mmClick);
        TSceneBattle2(Game.GetScene(scBattle)).ContinueBattle(False);
        Game.BackToScene(scBattle);
        Exit;
      end;
    iOrbOfHealing:
      begin
        Game.MediaPlayer.PlaySound(mmUseOrb);
        CurrentParty.UpdateHP(50, ActivePartyPosition);
        PendingTalismanOrOrbLogString := Format(CYouUsedTheItem,
          [TItemBase.Item(LItem.Enum).Name]) + ' Healed for 50 hp.';
      end;
    iOrbOfRestoration:
      begin
        Game.MediaPlayer.PlaySound(mmUseOrb);
        CurrentParty.UpdateHP(100, ActivePartyPosition);
        PendingTalismanOrOrbLogString := Format(CYouUsedTheItem,
          [TItemBase.Item(LItem.Enum).Name]) + ' Healed for 100 hp.';
      end;
    iOrbOfLife:
      begin
        Game.MediaPlayer.PlaySound(mmUseOrb);
        Game.MediaPlayer.PlaySound(mmRevive);
        CurrentParty.Revive(ActivePartyPosition);
        PendingTalismanOrOrbLogString := Format(CYouUsedTheItem,
          [TItemBase.Item(LItem.Enum).Name]) + ' Revived.';
      end;
    iGoblinOrb:
      begin
        Game.MediaPlayer.PlaySound(mmUseOrb);
        Game.MediaPlayer.PlaySound(mmGoblinHit);
        CurrentParty.AddCreature(crGoblin, ActivePartyPosition);
        PendingTalismanOrOrbLogString := Format(CYouUsedTheItem,
          [TItemBase.Item(LItem.Enum).Name]) + ' Goblin.';
      end;
  end;
  ActivePartyPosition := LastActivePartyPosition;
  Game.MediaPlayer.PlaySound(mmClick);
  TSceneBattle2(Game.GetScene(scBattle)).ContinueBattle(True);
  Game.BackToScene(scBattle);
end;

procedure TSceneSelectUnit.Render;

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

  DrawTitle(reTitleSelectUnit);

  TSceneParty2.RenderParty(psLeft, CurrentParty, CurrentParty.Count <
    TLeaderParty.Leader.Leadership);
  RenderCharacterInfo;

  if CurrentParty = TLeaderParty.Leader then
    RenderLeaderInfo
  else if CurrentParty = PartyList.Party[TLeaderParty.CapitalPartyIndex] then
    RenderGuardianInfo;

  RenderButtons;
end;

procedure TSceneSelectUnit.Timer;
begin
  inherited;

end;

procedure TSceneSelectUnit.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE:
      HideScene;
    K_ENTER:
      SelectUnit;
  end;
end;

end.
