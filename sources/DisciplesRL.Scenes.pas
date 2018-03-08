unit DisciplesRL.Scenes;

interface

uses Vcl.Graphics, System.Types, System.Classes;

type
  TSceneEnum = (scMenu, scVictory, scDefeat, scMap, scCapital, scBattle, scCity);

  // https://opengameart.org/content/ui-button

var
  Surface: TBitmap;
  CurrentScene: TSceneEnum = scMenu;

procedure RenderDark;
procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

const
  K_ESCAPE = 27;
  K_ENTER = 13;

implementation

uses System.SysUtils, Vcl.Forms, DisciplesRL.MainForm, DisciplesRL.Scene.Map, DisciplesRL.Scene.Menu,
  DisciplesRL.Scene.Victory, DisciplesRL.Scene.Defeat, DisciplesRL.Scene.Battle, DisciplesRL.Scene.Capital,
  DisciplesRL.Scene.City, DisciplesRL.Resources;

procedure RenderDark;
begin
  DisciplesRL.Scene.Map.Render;
  Surface.Canvas.StretchDraw(Rect(0, 0, Surface.Width, Surface.Height), ResImage[reDark]);
end;

procedure Init;
begin
  Surface := TBitmap.Create;
  Surface.Width := MainForm.ClientWidth;
  Surface.Height := MainForm.ClientHeight;
  case CurrentScene of
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
    scCapital:
      DisciplesRL.Scene.Capital.Init;
    scCity:
      DisciplesRL.Scene.City.Init;
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
    scCapital:
      DisciplesRL.Scene.Capital.Render;
    scCity:
      DisciplesRL.Scene.City.Render;
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
    scCapital:
      DisciplesRL.Scene.Capital.Timer;
    scCity:
      DisciplesRL.Scene.City.Timer;
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
    scCapital:
      DisciplesRL.Scene.Capital.MouseClick;
    scCity:
      DisciplesRL.Scene.City.MouseClick;
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
    scCapital:
      DisciplesRL.Scene.Capital.MouseMove(Shift, X, Y);
    scCity:
      DisciplesRL.Scene.City.MouseMove(Shift, X, Y);
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
    scCapital:
      DisciplesRL.Scene.Capital.KeyDown(Key, Shift);
    scCity:
      DisciplesRL.Scene.City.KeyDown(Key, Shift);
  end;
  DisciplesRL.Scenes.Render;
end;

procedure Free;
begin
  case CurrentScene of
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
    scCapital:
      DisciplesRL.Scene.Capital.Free;
    scCity:
      DisciplesRL.Scene.City.Free;
  end;
  FreeAndNil(Surface);
end;

end.
