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
  TSceneEnum = (scHire, scMenu, scInfo, scMap, scParty, scSettlement, scBattle, scBattle2);

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
function ConfirmDialog(const S: string): Boolean;
procedure InformDialog(const S: string);
procedure Free;

const
  K_ESCAPE = 27;
  K_ENTER = 13;
  K_SPACE = 32;

  K_A = ord('A');
  K_B = ord('B');
  K_C = ord('C');
  K_D = ord('D');
  K_E = ord('E');
  K_P = ord('P');
  K_Q = ord('Q');
  K_S = ord('S');
  K_V = ord('V');
  K_W = ord('W');
  K_X = ord('X');
  K_Z = ord('Z');

  K_RIGHT = 39;
  K_LEFT = 37;
  K_DOWN = 40;
  K_UP = 38;

  K_KP_1 = 97;
  K_KP_2 = 98;
  K_KP_3 = 99;
  K_KP_4 = 100;
  K_KP_5 = 101;
  K_KP_6 = 102;
  K_KP_7 = 103;
  K_KP_8 = 104;
  K_KP_9 = 105;

implementation

uses
  Vcl.Forms,
  System.SysUtils,
  DisciplesRL.MainForm,
  DisciplesRL.Scene.Map,
  DisciplesRL.Scene.Menu,
  DisciplesRL.Scene.Battle,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.Scene.Hire,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Info,
  DisciplesRL.ConfirmationForm,
  DisciplesRL.Scene.Party;

var
  MouseX, MouseY: Integer;

function ConfirmDialog(const S: string): Boolean;
begin
  Result := False;
  ConfirmationForm.Msg := S;
  ConfirmationForm.SubScene := stConfirm;
  ConfirmationForm.ShowModal;
  case ConfirmationForm.ModalResult of
    mrOk:
      Result := True;
  end;
end;

procedure InformDialog(const S: string);
begin
  ConfirmationForm.Msg := S;
  ConfirmationForm.SubScene := stInform;
  ConfirmationForm.ShowModal;
end;

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
      scMap:
        DisciplesRL.Scene.Map.Init;
      scParty:
        DisciplesRL.Scene.Party.Init;
      scBattle:
        DisciplesRL.Scene.Battle.Init;
      scBattle2:
        DisciplesRL.Scene.Battle2.Init;
      scSettlement:
        DisciplesRL.Scene.Settlement.Init;
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
    scMap:
      DisciplesRL.Scene.Map.Render;
    scParty:
      DisciplesRL.Scene.Party.Render;
    scBattle:
      DisciplesRL.Scene.Battle.Render;
    scBattle2:
      DisciplesRL.Scene.Battle2.Render;
    scSettlement:
      DisciplesRL.Scene.Settlement.Render;
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
    scMap:
      DisciplesRL.Scene.Map.Timer;
    scParty:
      DisciplesRL.Scene.Party.Timer;
    scBattle:
      DisciplesRL.Scene.Battle.Timer;
    scBattle2:
      DisciplesRL.Scene.Battle2.Timer;
    scSettlement:
      DisciplesRL.Scene.Settlement.Timer;
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
    scMap:
      DisciplesRL.Scene.Map.MouseClick;
    scParty:
      DisciplesRL.Scene.Party.MouseClick;
    scBattle:
      DisciplesRL.Scene.Battle.MouseClick;
    scBattle2:
      DisciplesRL.Scene.Battle2.MouseClick;
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseClick;
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
    scMap:
      DisciplesRL.Scene.Map.MouseMove(Shift, X, Y);
    scParty:
      DisciplesRL.Scene.Party.MouseMove(Shift, X, Y);
    scBattle:
      DisciplesRL.Scene.Battle.MouseMove(Shift, X, Y);
    scBattle2:
      DisciplesRL.Scene.Battle2.MouseMove(Shift, X, Y);
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseMove(Shift, X, Y);
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
    scMap:
      DisciplesRL.Scene.Map.KeyDown(Key, Shift);
    scParty:
      DisciplesRL.Scene.Party.KeyDown(Key, Shift);
    scBattle:
      DisciplesRL.Scene.Battle.KeyDown(Key, Shift);
    scBattle2:
      DisciplesRL.Scene.Battle2.KeyDown(Key, Shift);
    scSettlement:
      DisciplesRL.Scene.Settlement.KeyDown(Key, Shift);
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
    scMap:
      DisciplesRL.Scene.Map.MouseDown(Button, Shift, X, Y);
    scParty:
      DisciplesRL.Scene.Party.MouseDown(Button, Shift, X, Y);
    scBattle:
      DisciplesRL.Scene.Battle.MouseDown(Button, Shift, X, Y);
    scBattle2:
      DisciplesRL.Scene.Battle2.MouseDown(Button, Shift, X, Y);
    scSettlement:
      DisciplesRL.Scene.Settlement.MouseDown(Button, Shift, X, Y);
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
      scMap:
        DisciplesRL.Scene.Map.Free;
      scParty:
        DisciplesRL.Scene.Party.Free;
      scBattle:
        DisciplesRL.Scene.Battle.Free;
      scBattle2:
        DisciplesRL.Scene.Battle2.Free;
      scSettlement:
        DisciplesRL.Scene.Settlement.Free;
    end;
  FreeAndNil(Surface);
end;

end.
