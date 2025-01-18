unit Elinor.Scene.NewAbility;

interface

uses
  Elinor.Scene.Menu.Simple,
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneNewAbility = class(TSceneSimpleMenu)
  private
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

{ TSceneNewAbility }

uses
  Math,
  SysUtils,
  Elinor.Saga,
  Elinor.Frame,
  Elinor.Scene.Frames,
  Elinor.Scene.Race,
  Elinor.Scene.Scenario,
  Elinor.Scene.Battle2,
  Elinor.Scenario,
  Elinor.Creatures;

constructor TSceneNewAbility.Create;
begin
  inherited Create(reWallpaperScenario);
  IsOneButton := True;
end;

class procedure TSceneNewAbility.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  TSceneBattle2.AfterVictory;
end;

procedure TSceneNewAbility.Render;
var
  I: Integer;

  procedure RenderAbilityInfo(const I: Integer);
  var
    LAbilityEnum: TAbilityEnum;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    LAbilityEnum := TLeaderParty.Leader.Abilities.RandomAbilityEnum[I];
    AddTextLine(TAbilities.Ability(LAbilityEnum).Name, True);
    AddTextLine;
    AddTextLine(TAbilities.Ability(LAbilityEnum).Description[0]);
    AddTextLine(TAbilities.Ability(LAbilityEnum).Description[1]);
  end;

begin
  inherited;
  DrawTitle(reTitleAbilities);
  for I := 0 to 2 do
  begin
    if I = CurrentIndex then
    begin
      DrawImage(TFrame.Col(1), TFrame.Row(I), reActFrame);
      RenderAbilityInfo(I);
    end;

  end;
end;

class procedure TSceneNewAbility.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scNewAbility);
end;

procedure TSceneNewAbility.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ENTER:
      begin
        with TLeaderParty.Leader.Abilities do
          Add(RandomAbilityEnum[CurrentIndex]);
        HideScene;
      end;
  end;
end;

end.
