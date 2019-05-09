unit DisciplesRL.Scene.Info;

interface

uses
  System.Classes,
  DisciplesRL.Scenes,
  Vcl.Controls;

type
  TInfoSubSceneEnum = (stDay, stLoot, stHighScores, stVictory, stDefeat);

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
  DisciplesRL.Scene.Map,
  DisciplesRL.Game,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Player,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.GUI.Button;

var
  Button: TButton;
  SubScene: TInfoSubSceneEnum = stHighScores;
  BackScene: TSceneEnum = scMenu;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Back;
var
  F: Boolean;
begin
  case SubScene of
    stDefeat:
      begin
        IsGame := False;
        DisciplesRL.Scene.Info.Show(stHighScores, scMenu);
        Exit;
      end;
    stVictory:
      begin
        IsGame := False;
        DisciplesRL.Scene.Info.Show(stHighScores, scMenu);
        Exit;
      end;
    stDay:
      IsDay := False;
    stLoot:
      begin
        F := True;
        begin
          DisciplesRL.Scenes.CurrentScene := scMap;
          case PlayerTile of
            reTower:
              begin
                DisciplesRL.Scene.Info.Show(stVictory, scInfo);
                F := False;
              end;
            reTheEmpireCity:
              begin
                DisciplesRL.Scene.Settlement.Show(stCity);
                F := False;
              end;
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

procedure Render;
begin
  case SubScene of
    stDefeat:
      DrawTitle(reTitleDefeat);
    stVictory:
      DrawTitle(reTitleVictory);
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
  Button.Render;
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

end.
