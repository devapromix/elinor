unit DisciplesRL.Scenes;

interface

uses Vcl.Graphics, System.Types, System.Classes;

type
  TSceneEnum = (scMenu, scMap);

var
  Surface: TBitmap;
  CurrentScene: TSceneEnum = scMenu;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, Vcl.Forms, DisciplesRL.MainForm, DisciplesRL.Scene.Map, DisciplesRL.Scene.Menu;

procedure Init;
begin
  Surface := TBitmap.Create;
  Surface.Width := MainForm.ClientWidth;
  Surface.Height := MainForm.ClientHeight;
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.Init;
    scMap:
      DisciplesRL.Scene.Map.Init;
  end;
end;

procedure Render;
begin
  Surface.Canvas.Brush.Color := clBlack;
  Surface.Canvas.FillRect(Rect(0, 0, Surface.Width, Surface.Height));
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.Render;
    scMap:
      DisciplesRL.Scene.Map.Render;
  end;
  MainForm.Canvas.Draw(0, 0, Surface);
end;

procedure Timer;
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.Timer;
    scMap:
      DisciplesRL.Scene.Map.Timer;
  end;
end;

procedure MouseClick;
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.MouseClick;
    scMap:
      DisciplesRL.Scene.Map.MouseClick;
  end;
  DisciplesRL.Scenes.Render;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  case CurrentScene of
    scMap:
      DisciplesRL.Scene.Map.MouseMove(Shift, X, Y);
  end;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.KeyDown(Key, Shift);
    scMap:
      DisciplesRL.Scene.Map.KeyDown(Key, Shift);
  end;
  DisciplesRL.Scenes.Render;
end;

procedure Free;
begin
  case CurrentScene of
    scMenu:
      DisciplesRL.Scene.Menu.Free;
    scMap:
      DisciplesRL.Scene.Map.Free;
  end;
  FreeAndNil(Surface);
end;

end.
