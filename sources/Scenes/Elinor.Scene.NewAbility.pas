unit Elinor.Scene.NewAbility;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Base.Party,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneNewAbility = class(TSceneBaseParty)
  private type
    TButtonEnum = (btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure CloseScene;
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

{ TSceneNewAbility }

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Scene.Frames,
  Elinor.Scene.Faction,
  Elinor.Scene.Scenario,
  Elinor.Scene.Battle2,
  Elinor.Ability,
  Elinor.Scenario,
  Elinor.Creatures,
  Elinor.Scene.Party;

constructor TSceneNewAbility.Create;
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
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Sellected := True;
  end;
end;

destructor TSceneNewAbility.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

class procedure TSceneNewAbility.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  TSceneBattle2.AfterVictory;
end;

procedure TSceneNewAbility.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btClose].MouseDown then
          CloseScene;
      end;
  end;

end;

procedure TSceneNewAbility.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneNewAbility.CloseScene;
begin
  with TLeaderParty.Leader.Abilities do
    Add(RandomAbilityEnum[ActivePartyPosition]);
  HideScene;
end;

procedure TSceneNewAbility.Render;
var
  I: Integer;

  procedure RenderAbilities;
  var
    LAbilityPosition: TPosition;
    LAbilityEnum: TAbilityEnum;
    LLeft, LTop: Integer;
  begin
    for LAbilityPosition := 0 to 5 do
    begin
      LLeft := TFrame.Col(LAbilityPosition, psLeft);
      LTop := TFrame.Row(LAbilityPosition);
      LAbilityEnum := TLeaderParty.Leader.Abilities.RandomAbilityEnum
        [LAbilityPosition];
      if (LAbilityEnum <> abNone) then
      begin
        DrawAbility(LAbilityEnum, LLeft, LTop);
        DrawText(LLeft + 74, LTop + 6, TAbilities.Ability(LAbilityEnum).Name);
        DrawText(LLeft + 74, LTop + 27,
          Format('Level %d', [TAbilities.Ability(LAbilityEnum).Level]));
      end;
    end;
  end;

  procedure RenderAbilityInfo;
  var
    LAbilityEnum: TAbilityEnum;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    LAbilityEnum := TLeaderParty.Leader.Abilities.RandomAbilityEnum
      [ActivePartyPosition];
    AddTextLine(TAbilities.Ability(LAbilityEnum).Name, True);
    AddTextLine;
    AddTextLine('Level', TAbilities.Ability(LAbilityEnum).Level);
    AddTextLine(TAbilities.Ability(LAbilityEnum).Description[0]);
    AddTextLine(TAbilities.Ability(LAbilityEnum).Description[1]);
  end;

  procedure RenderLeaderAbilitiesList;
  var
    I: Integer;
    LAbilityEnum: TAbilityEnum;
  begin
    TextLeft := TFrame.Col(3) + 12;
    TextTop := TFrame.Row(0) + 6;
    AddTextLine('Leader Abilities', True);
    AddTextLine;
    AddTextLine('Leadership', TLeaderParty.Leader.Leadership);
    for I := 0 to CMaxAbilities - 1 do
    begin
      LAbilityEnum := TLeaderParty.Leader.Abilities.GetEnum(I);
      if (LAbilityEnum <> abNone) and not TAbilities.IsAbilityLeadership
        (LAbilityEnum) then
        AddTextLine(TAbilities.Ability(LAbilityEnum).Name);
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
  DrawTitle(reTitleAbilities);

  RenderAbilities;
  RenderAbilityInfo;
  RenderLeaderAbilitiesList;

  RenderButtons;
end;

class procedure TSceneNewAbility.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scNewAbility);
end;

procedure TSceneNewAbility.Timer;
begin
  inherited;

end;

procedure TSceneNewAbility.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ENTER:
      CloseScene;
  end;
end;

end.
