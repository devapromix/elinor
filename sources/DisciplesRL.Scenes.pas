unit DisciplesRL.Scenes;

interface

uses
  Vcl.Graphics,
  Vcl.Controls,
  System.Types,
  System.Classes,
  Vcl.Imaging.PNGImage,
  DisciplesRL.Resources,
  DisciplesRL.GUI.Button;

type
  TSceneEnum = (scHire, scMenu, scInfo, scVictory, scDefeat, scMap, scSettlement, scBattle, scBattle2, scItem);

const
  DefaultButtonTop = 600;

var
  Surface: TBitmap;
  CurrentScene: TSceneEnum = scMenu;

procedure CenterTextOut(const AY: Integer; AText: string);
procedure RenderDark;
procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick;
procedure DrawTitle(Res: TResEnum);
procedure DrawImage(X, Y: Integer; Image: TPNGImage); overload;
procedure DrawImage(X, Y: Integer; Res: TResEnum); overload;
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure Free;

const
  K_ESCAPE = 27;
  K_ENTER = 13;
  K_SPACE = 32;
  K_V = ord('V');
  K_D = ord('D');
  K_B = ord('B');
  K_RIGHT = 39;
  K_LEFT = 37;
  K_DOWN = 40;
  K_UP = 38;

implementation

uses
  Vcl.Forms,
  System.SysUtils,
  DisciplesRL.MainForm,
  DisciplesRL.Scene.Map,
  DisciplesRL.Scene.Menu,
  DisciplesRL.Scene.Victory,
  DisciplesRL.Scene.Defeat,
  DisciplesRL.Scene.Battle,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Scene.Item,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Info;

var
  MouseX, MouseY: Integer;

procedure DrawTitle(Res: TResEnum);
begin
  Surface.Canvas.Draw((Surface.Width div 2) - (ResImage[Res].Width div 2), 10, ResImage[Res]);
end;

procedure DrawImage(X, Y: Integer; Image: TPNGImage);
begin
  Surface.Canvas.Draw(X, Y, Image);
end;

procedure DrawImage(X, Y: Integer; Res: TResEnum);
begin
  Surface.Canvas.Draw(X, Y, ResImage[Res]);
end;

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
  Surface.Canvas.StretchDraw(Rect(0, 0, Surface.Width, Surface.Height), ResImage[reDark]);
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
      scHire:
        DisciplesRL.Scene.Hire.Init;
      scInfo:
        DisciplesRL.Scene.Info.Init;
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
      scBattle2:
        DisciplesRL.Scene.Battle2.Init;
      scSettlement:
        DisciplesRL.Scene.Settlement.Init;
      scItem:
        DisciplesRL.Scene.Item.Init;
    end;
end;

procedure Render;
begin
  Surface.Canvas.Brush.Color := clBlack;
  Surface.Canvas.FillRect(Rect(0, 0, Surface.Width, Surface.Height));
  case CurrentScene of
    scHire:
      DisciplesRL.Scene.Hire.Render;
    scInfo:
      DisciplesRL.Scene.Info.Render;
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
    scBattle2:
      DisciplesRL.Scene.Battle2.Render;
    scSettlement:
      DisciplesRL.Scene.Settlement.Render;
    scItem:
      DisciplesRL.Scene.Item.Render;
  end;
  MainForm.Canvas.Draw(0, 0, Surface);
end;

procedure Timer;
begin
  case CurrentScene of
    scHire:
      DisciplesRL.Scene.Hire.Timer;
    scInfo:
      DisciplesRL.Scene.Info.Timer;
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
    scBattle2:
      DisciplesRL.Scene.Battle2.Timer;
    scSettlement:
      DisciplesRL.Scene.Settlement.Timer;
    scItem:
      DisciplesRL.Scene.Item.Timer;
  end;
end;

procedure MouseClick;
begin
  case CurrentScene of
    scHire:
      DisciplesRL.Scene.Hire.MouseClick(MouseX, MouseY);
    scInfo:
      DisciplesRL.Scene.Info.MouseClick(MouseX, MouseY);
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
    scBattle2:
      DisciplesRL.Scene.Battle2.MouseClick;
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseClick;
    scItem:
      DisciplesRL.Scene.Item.MouseClick;
  end;
  DisciplesRL.Scenes.Render;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MouseX := X;
  MouseY := Y;
  case CurrentScene of
    scHire:
      DisciplesRL.Scene.Hire.MouseMove(Shift, X, Y);
    scInfo:
      DisciplesRL.Scene.Info.MouseMove(Shift, X, Y);
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
    scBattle2:
      DisciplesRL.Scene.Battle2.MouseMove(Shift, X, Y);
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseMove(Shift, X, Y);
    scItem:
      DisciplesRL.Scene.Item.MouseMove(Shift, X, Y);
  end;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case CurrentScene of
    scHire:
      DisciplesRL.Scene.Hire.KeyDown(Key, Shift);
    scInfo:
      DisciplesRL.Scene.Info.KeyDown(Key, Shift);
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
    scBattle2:
      DisciplesRL.Scene.Battle2.KeyDown(Key, Shift);
    scSettlement:
      DisciplesRL.Scene.Settlement.KeyDown(Key, Shift);
    scItem:
      DisciplesRL.Scene.Item.KeyDown(Key, Shift);
  end;
  DisciplesRL.Scenes.Render;
end;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case CurrentScene of
    scHire:
      DisciplesRL.Scene.Hire.MouseDown(Button, Shift, X, Y);
    scInfo:
      DisciplesRL.Scene.Info.MouseDown(Button, Shift, X, Y);
    scMenu:
      DisciplesRL.Scene.Menu.MouseDown(Button, Shift, X, Y);
    scVictory:
      DisciplesRL.Scene.Victory.MouseDown(Button, Shift, X, Y);
    scDefeat:
      DisciplesRL.Scene.Defeat.MouseDown(Button, Shift, X, Y);
    scMap:
      DisciplesRL.Scene.Map.MouseDown(Button, Shift, X, Y);
    scBattle:
      DisciplesRL.Scene.Battle.MouseDown(Button, Shift, X, Y);
    scBattle2:
      DisciplesRL.Scene.Battle2.MouseDown(Button, Shift, X, Y);
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseDown(Button, Shift, X, Y);
    scItem:
      DisciplesRL.Scene.Item.MouseDown(Button, Shift, X, Y);
  end;
  DisciplesRL.Scenes.Render;
end;

procedure Free;
var
  I: TSceneEnum;
begin
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    case I of
      scHire:
        DisciplesRL.Scene.Hire.Free;
      scInfo:
        DisciplesRL.Scene.Info.Free;
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
      scBattle2:
        DisciplesRL.Scene.Battle2.Free;
      scSettlement:
        DisciplesRL.Scene.Settlement.Free;
      scItem:
        DisciplesRL.Scene.Item.Free;
    end;
  FreeAndNil(Surface);
end;

end.
