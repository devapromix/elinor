unit DisciplesRL.Scenes;

interface

uses Vcl.Graphics, System.Types, System.Classes;

type
  TSceneEnum = (scMap);

var
  Surface: TBitmap;
  CurrentScene: TSceneEnum = scMap;

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure Free;

implementation

uses System.SysUtils, Vcl.Forms, DisciplesRL.MainForm, DisciplesRL.Scene.Map;

procedure Init;
begin
  Surface := TBitmap.Create;
  Surface.Width := MainForm.ClientWidth;
  Surface.Height := MainForm.ClientHeight;
  case CurrentScene of
    scMap:
      DisciplesRL.Scene.Map.Init;
  end;
end;

procedure Render;
begin
  Surface.Canvas.Brush.Color := clBlack;
  Surface.Canvas.FillRect(Rect(0, 0, Surface.Width, Surface.Height));
  case CurrentScene of
    scMap:
      DisciplesRL.Scene.Map.Render;
  end;
  MainForm.Canvas.Draw(0, 0, Surface);
end;

procedure Timer;
begin
  case CurrentScene of
    scMap:
      DisciplesRL.Scene.Map.Timer;
  end;
end;

procedure MouseClick;
begin
  case CurrentScene of
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
    scMap:
      DisciplesRL.Scene.Map.KeyDown(Key, Shift);
  end;
  DisciplesRL.Scenes.Render;
end;

procedure Free;
begin
  case CurrentScene of
    scMap:
      DisciplesRL.Scene.Map.Free;
  end;
  FreeAndNil(Surface);
end;

end.
