unit DisciplesRL.Scene.Info;

interface

uses
  System.Classes,
  DisciplesRL.Resources,
  DisciplesRL.Scenes,
  Vcl.Controls;

type
  TInfoSubSceneEnum = (stDay, stLoot, stStoneTab);

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick(X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Show(const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum;
  const ALootRes: TResEnum = reGold);
procedure Free;

implementation

uses
  System.Math,
  System.SysUtils,
  Vcl.Dialogs,
  DisciplesRL.Scene.Map,
  DisciplesRL.Saga,
  DisciplesRL.Map,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.GUI.Button,
  DisciplesRL.Scene.Hire;

var
  Button: TButton;
  Dialog: string = '';
  SubScene: TInfoSubSceneEnum;
  BackScene: TSceneEnum = scMenu;
  LF: Integer = 0;
  GC: Integer = 0;
  LootRes: TResEnum;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Back;
var
  F: Boolean;
begin
  MediaPlayer.Play(mmClick);
  case SubScene of
    stStoneTab:
      begin
        if (TScenario.CurrentScenario = sgAncientKnowledge) then
          if TScenario.StoneTab >= TScenario.ScenarioStoneTabMax then
          begin
            DisciplesRL.Scene.Hire.Show(stVictory);
            Exit;
          end
          else
          begin
            F := True;
            DisciplesRL.Scene.Map.Show;
            Exit;
          end;
      end;
    stDay:
      begin
        MediaPlayer.Play(mmSettlement);
        TSaga.IsDay := False;
      end;
    stLoot:
      begin
        F := True;
        DisciplesRL.Scene.Map.Show;
        begin
          if (TScenario.CurrentScenario = sgDarkTower) then
          begin
            case TMap.LeaderTile of
              reTower:
                begin
                  DisciplesRL.Scene.Hire.Show(stVictory);
                  Exit;
                end;
            end;
          end;
          if TMap.LeaderTile = reNeutralCity then
          begin
            SetSceneMusic(scSettlement);
            DisciplesRL.Scene.Settlement.Show(stCity);
            Exit;
          end;
          if F then
            TSaga.NewDay;
        end;
      end;
  end;
  SetScene(BackScene);
end;

procedure Init;
begin
  Button := TButton.Create((Surface.Width div 2) -
    (ResImage[reButtonDef].Width div 2), DefaultButtonTop, Surface.Canvas,
    reTextClose);
  Button.Sellected := True;
end;

procedure RenderButtons;
begin
  Button.Render;
end;

procedure DrawItem(ItemRes: array of TResEnum);
var
  I, X: Integer;
begin
  DrawImage((Surface.Width div 2) - 59 - 120, 295, reSmallFrame);
  DrawImage((Surface.Width div 2) - 59, 295, reSmallFrame);
  DrawImage((Surface.Width div 2) - 59 + 120, 295, reSmallFrame);
  case Length(ItemRes) of
    1:
      DrawImage((Surface.Width div 2) - 32, 300, ItemRes[0]);
    2, 3:
      begin
        X := -120;
        for I := 0 to Length(ItemRes) - 1 do
        begin
          DrawImage((Surface.Width div 2) - 32 + X, 300, ItemRes[I]);
          Inc(X, 120);
        end;
      end;
  end;
end;

procedure Render;
var
  Y: Integer;
  ItemRes: TResEnum;
begin
  case SubScene of
    stStoneTab:
      begin
        DrawTitle(reTitleLoot);
        DrawItem([reItemStoneTable]);
        CenterTextOut(450, 'КАМЕННАЯ ТАБЛИЧКА');
        CenterTextOut(470, TScenario.ScenarioAncientKnowledgeState);
      end;
    stDay:
      begin
        DrawTitle(reTitleNewDay);
        CenterTextOut(450, Format('ДЕНЬ %d', [TSaga.Days]));
        if TSaga.GoldMines > 0 then
        begin
          DrawItem([reItemGold, reDay, reItemGold]);
          CenterTextOut(470, 'ЗОЛОТО +' + IntToStr(TSaga.GoldMines *
            TSaga.GoldFromMinePerDay))
        end
        else
          DrawItem([reDay]);
      end;
    stLoot:
      begin
        DrawTitle(reTitleLoot);
        case LootRes of
          reGold:
            begin
              case GC of
                0:
                  DrawItem([reItemGold]);
                1:
                  DrawItem([reItemGold, reItemGold]);
                2:
                  DrawItem([reItemGold, reItemGold, reItemGold]);
              end;
              CenterTextOut(450, 'СОКРОВИЩЕ');
              CenterTextOut(470, 'ЗОЛОТО +' + IntToStr(TSaga.NewGold));
            end;
          reBag:
            begin
              Y := 470;
              CenterTextOut(450, 'СОКРОВИЩЕ');
              if TSaga.NewGold > 0 then
              begin
                DrawItem([reItemGold]);
                CenterTextOut(Y, 'ЗОЛОТО +' + IntToStr(TSaga.NewGold));
                Inc(Y, 20);
              end;
              if TSaga.NewItem > 0 then
              begin
                ItemRes := reAcolyte;
                if TSaga.NewGold > 0 then
                  case GC of
                    0:
                      DrawItem([ItemRes, reItemGold]);
                  else
                    DrawItem([reItemGold, ItemRes]);
                  end
                else
                  DrawItem([ItemRes]);
                CenterTextOut(Y, 'АРТЕФАКТ ' + IntToStr(TSaga.NewItem));
                Inc(Y, 20);
              end;
            end;
        end;
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

procedure Show(const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum;
  const ALootRes: TResEnum);
begin
  SubScene := ASubScene;
  BackScene := ABackScene;
  SetScene(scInfo);
  case SubScene of
    stDay:
      MediaPlayer.Play(mmDay);
    stLoot, stStoneTab:
      MediaPlayer.Play(mmLoot);
  end;
  LootRes := ALootRes;
  GC := RandomRange(0, 3);
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
