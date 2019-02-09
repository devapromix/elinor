unit DisciplesRL.Scene.Info;

interface

uses
  System.Classes,
  DisciplesRL.Scenes,
  Vcl.Controls;

type
  TInfoSubSceneEnum = (stDay, stLoot, stStoneTab, stHighScores);

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick(X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Show(const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum);
procedure Free;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs,
  DisciplesRL.Scene.Map,
  DisciplesRL.Game,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Leader,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.GUI.Button,
  DisciplesRL.Scene.Hire;

var
  Button: TButton;
  Dialog: string = '';
  SubScene: TInfoSubSceneEnum = stHighScores;
  BackScene: TSceneEnum = scMenu;
  Lf: Integer = 0;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Back;
var
  F: Boolean;
begin
  case SubScene of
    stStoneTab:
      begin
        if (CurrentScenario = sgAncientKnowledge) then
          if TScenario.StoneTab >= ScenarioStoneTabMax then
          begin
            DisciplesRL.Scene.Hire.Show(stVictory);
            Exit;
          end
          else
          begin
            F := True;
            DisciplesRL.Scenes.CurrentScene := scMap;
            Exit;
          end;
      end;
    stDay:
      IsDay := False;
    stLoot:
      begin
        F := True;
        DisciplesRL.Scenes.CurrentScene := scMap;
        begin
          if (CurrentScenario = sgDarkTower) then
          begin
            case LeaderTile of
              reTower:
                begin
                  DisciplesRL.Scene.Hire.Show(stVictory);
                  Exit;
                end;
            end;
          end;
          if LeaderTile = reNeutralCity then
          begin
            DisciplesRL.Scene.Settlement.Show(stCity);
            Exit;
          end;
          if F then
            NewDay;
        end;
      end;
  end;
  DisciplesRL.Scenes.CurrentScene := BackScene;
end;

procedure Init;
begin
  Button := TButton.Create((Surface.Width div 2) - (ResImage[reButtonDef].Width div 2), DefaultButtonTop, Surface.Canvas, reTextClose);
  Button.Sellected := True;
end;

procedure RenderButtons;
begin
  Button.Render;
end;

procedure Render;
begin
  case SubScene of
    stStoneTab:
      begin
        DrawTitle(reTitleLoot);
        CenterTextOut(300, 'КАМЕННАЯ ТАБЛИЧКА');
        CenterTextOut(350, TScenario.ScenarioAncientKnowledgeState);
      end;
    stDay:
      begin
        DrawTitle(reTitleNewDay);
        CenterTextOut(300, Format('НАСТУПИЛ НОВЫЙ ДЕНЬ (День %d-й)', [Days]));
        CenterTextOut(350, 'ЗОЛОТО +' + IntToStr(GoldMines * GoldFromMinePerDay));
      end;
    stLoot:
      begin
        DrawTitle(reTitleLoot);
        CenterTextOut(300, 'СОКРОВИЩЕ');
        CenterTextOut(350, 'ЗОЛОТО +' + IntToStr(NewGold));
      end;
    stHighScores:
      begin
        DrawTitle(reTitleHighScores);
      end;
  end;
  RenderButtons;
end;

procedure Timer;
begin

end;

procedure MouseClick(X, Y: Integer);
begin
  if Button.MouseDown then
    Back;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  Button.MouseMove(X, Y);
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      Back;
  end;
end;

procedure Show(const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum);
begin
  SubScene := ASubScene;
  BackScene := ABackScene;
  DisciplesRL.Scenes.CurrentScene := scInfo;
end;

procedure Free;
begin
  FreeAndNil(Button);
end;

{ Malavien's Camp	My mercenaries will join your army ... for a price.
  Guther's Camp	My soldiers are the finest in the region.
  Turion's Camp	My soldiers are the most formidable in the land.
  Uther's Camp	Are you in need of recruits?
  Dennar's Camp	We will join your army, for a price.
  Purthen's Camp	My mercenaries will join your army ... for a price.
  Luther's Camp	My soldiers are the finest in the region.
  Richard's Camp	My soldiers are the most formidable in the land.
  Ebbon's Camp	Are you in need of recruits?
  Righon's Camp	We will join your army, for a price.
  Kigger's Camp	My mercenaries will join your army ... for a price.
  Luggen's Camp	My soldiers are the finest in the region.
  Werric's Camp	My soldiers are the most formidable in the land.
  Xennon's Camp	Are you in need of recruits? }
end.
