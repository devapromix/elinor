unit DisciplesRL.Scenes;

interface

uses Vcl.Graphics, System.Types, System.Classes, Vcl.Controls;

type
  TSceneEnum = (scMenu, scVictory, scDefeat, scMap, scSettlement, scBattle,
    scItem, scDay, scHighScores);

  // https://opengameart.org/content/ui-button

var
  Surface: TBitmap;
  CurrentScene: TSceneEnum = scMenu;

procedure CenterTextOut(const AY: Integer; AText: string);
procedure RenderDark;
procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure Free;

const
  K_ESCAPE = 27;
  K_ENTER = 13;
  K_V = ord('V');
  K_D = ord('D');

implementation

uses System.SysUtils, Vcl.Forms, DisciplesRL.MainForm, DisciplesRL.Scene.Map,
  DisciplesRL.Scene.Menu, DisciplesRL.Scene.Victory, DisciplesRL.Scene.Defeat,
  DisciplesRL.Scene.Battle, DisciplesRL.Scene.Settlement, DisciplesRL.Resources,
  DisciplesRL.Scene.Item, DisciplesRL.Scene.Day, DisciplesRL.Scene.HighScores;

procedure CenterTextOut(const AY: Integer; AText: string);
var
  S: Integer;
begin
  S := Surface.Canvas.TextWidth(AText);
  Surface.Canvas.TextOut((Surface.Width div 2) - (S div 2), AY, AText);
end;

procedure RenderDark;
begin
  DisciplesRL.Scene.Map.Render;
  Surface.Canvas.StretchDraw(Rect(0, 0, Surface.Width, Surface.Height),
    ResImage[reDark]);
end;

procedure Init;
var
  I: TSceneEnum;
begin
  Surface := TBitmap.Create;
  Surface.Width := MainForm.ClientWidth;
  Surface.Height := MainForm.ClientHeight;
  Surface.Canvas.Font.Size := 12;
  Surface.Canvas.Font.Color := clGreen;
  Surface.Canvas.Brush.Style := bsClear;
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    case I of
      scMenu:
        DisciplesRL.Scene.Menu.Init;
      scVictory:
        DisciplesRL.Scene.Victory.Init;
      scDefeat:
        DisciplesRL.Scene.Defeat.Init;
      scMap:
        DisciplesRL.Scene.Map.Init;
      scBattle:
        DisciplesRL.Scene.Battle.Init;
      scSettlement:
        DisciplesRL.Scene.Settlement.Init;
      scItem:
        DisciplesRL.Scene.Item.Init;
      scDay:
        DisciplesRL.Scene.Day.Init;
      scHighScores:
        DisciplesRL.Scene.HighScores.Init;
    end;
end;

procedure Render;
begin
  Surface.Canvas.Brush.Color := clBlack;
  Surface.Canvas.FillRect(Rect(0, 0, Surface.Width, Surface.Height));
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.Render;
    scVictory:
      DisciplesRL.Scene.Victory.Render;
    scDefeat:
      DisciplesRL.Scene.Defeat.Render;
    scMap:
      DisciplesRL.Scene.Map.Render;
    scBattle:
      DisciplesRL.Scene.Battle.Render;
    scSettlement:
      DisciplesRL.Scene.Settlement.Render;
    scItem:
      DisciplesRL.Scene.Item.Render;
    scDay:
      DisciplesRL.Scene.Day.Render;
    scHighScores:
      DisciplesRL.Scene.HighScores.Render;
  end;
  MainForm.Canvas.Draw(0, 0, Surface);
end;

procedure Timer;
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.Timer;
    scVictory:
      DisciplesRL.Scene.Victory.Timer;
    scDefeat:
      DisciplesRL.Scene.Defeat.Timer;
    scMap:
      DisciplesRL.Scene.Map.Timer;
    scBattle:
      DisciplesRL.Scene.Battle.Timer;
    scSettlement:
      DisciplesRL.Scene.Settlement.Timer;
    scItem:
      DisciplesRL.Scene.Item.Timer;
    scDay:
      DisciplesRL.Scene.Day.Timer;
    scHighScores:
      DisciplesRL.Scene.HighScores.Timer;
  end;
end;

procedure MouseClick;
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.MouseClick;
    scVictory:
      DisciplesRL.Scene.Victory.MouseClick;
    scDefeat:
      DisciplesRL.Scene.Defeat.MouseClick;
    scMap:
      DisciplesRL.Scene.Map.MouseClick;
    scBattle:
      DisciplesRL.Scene.Battle.MouseClick;
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseClick;
    scItem:
      DisciplesRL.Scene.Item.MouseClick;
    scDay:
      DisciplesRL.Scene.Day.MouseClick;
    scHighScores:
      DisciplesRL.Scene.HighScores.MouseClick;
  end;
  DisciplesRL.Scenes.Render;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.MouseMove(Shift, X, Y);
    scVictory:
      DisciplesRL.Scene.Victory.MouseMove(Shift, X, Y);
    scDefeat:
      DisciplesRL.Scene.Defeat.MouseMove(Shift, X, Y);
    scMap:
      DisciplesRL.Scene.Map.MouseMove(Shift, X, Y);
    scBattle:
      DisciplesRL.Scene.Battle.MouseMove(Shift, X, Y);
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseMove(Shift, X, Y);
    scItem:
      DisciplesRL.Scene.Item.MouseMove(Shift, X, Y);
    scDay:
      DisciplesRL.Scene.Day.MouseMove(Shift, X, Y);
    scHighScores:
      DisciplesRL.Scene.HighScores.MouseMove(Shift, X, Y);
  end;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.KeyDown(Key, Shift);
    scVictory:
      DisciplesRL.Scene.Victory.KeyDown(Key, Shift);
    scDefeat:
      DisciplesRL.Scene.Defeat.KeyDown(Key, Shift);
    scMap:
      DisciplesRL.Scene.Map.KeyDown(Key, Shift);
    scBattle:
      DisciplesRL.Scene.Battle.KeyDown(Key, Shift);
    scSettlement:
      DisciplesRL.Scene.Settlement.KeyDown(Key, Shift);
    scItem:
      DisciplesRL.Scene.Item.KeyDown(Key, Shift);
    scDay:
      DisciplesRL.Scene.Day.KeyDown(Key, Shift);
    scHighScores:
      DisciplesRL.Scene.HighScores.KeyDown(Key, Shift);
  end;
  DisciplesRL.Scenes.Render;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case CurrentScene of
    { scMenu:
      DisciplesRL.Scene.Menu.KeyDown(Key, Shift);
      scVictory:
      DisciplesRL.Scene.Victory.KeyDown(Key, Shift);
      scDefeat:
      DisciplesRL.Scene.Defeat.KeyDown(Key, Shift);
      scMap:
      DisciplesRL.Scene.Map.KeyDown(Key, Shift); }
    scBattle:
      DisciplesRL.Scene.Battle.MouseDown(Button, Shift, X, Y);
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseDown(Button, Shift, X, Y);
    { scItem:
      DisciplesRL.Scene.Item.MouseDown(Button, Shift, X, Y);
      scDay:
      DisciplesRL.Scene.Day.MouseDown(Button, Shift, X, Y); }
  end;
  DisciplesRL.Scenes.Render;
end;

procedure Free;
var
  I: TSceneEnum;
begin
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    case I of
      scMenu:
        DisciplesRL.Scene.Menu.Free;
      scVictory:
        DisciplesRL.Scene.Victory.Free;
      scDefeat:
        DisciplesRL.Scene.Defeat.Free;
      scMap:
        DisciplesRL.Scene.Map.Free;
      scBattle:
        DisciplesRL.Scene.Battle.Free;
      scSettlement:
        DisciplesRL.Scene.Settlement.Free;
      scItem:
        DisciplesRL.Scene.Item.Free;
      scDay:
        DisciplesRL.Scene.Day.Free;
      scHighScores:
        DisciplesRL.Scene.HighScores.Free;
    end;
  FreeAndNil(Surface);
end;

end.
