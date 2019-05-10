unit DisciplesRL.Scene.Info;

interface

uses
  System.Classes,
  DisciplesRL.Scenes,
  Vcl.Controls;

type
  TInfoSubSceneEnum = (stDay, stLoot, stHighScores, stVictory, stDefeat, stDialog, stConfirm);

procedure Init;
procedure Render;
procedure Timer;
procedure MouseClick(X, Y: Integer);
procedure MouseMove(Shift: TShiftState; X, Y: Integer);
procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
procedure KeyDown(var Key: Word; Shift: TShiftState);
function Show(const ADialog: string; const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum): Boolean; overload;
procedure Show(const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum); overload;
procedure Show(const ADialog: string; const ABackScene: TSceneEnum); overload;
procedure Free;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs,
  DisciplesRL.Scene.Map,
  DisciplesRL.Game,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.Player,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.GUI.Button;

type
  TButtonEnum = (btOk, btCancel);

const
  ButtonsText: array [TButtonEnum] of TResEnum = (reTextHire, reTextCancel);

var
  Button: TButton;
  Dialog: string = '';
  Buttons: array [TButtonEnum] of TButton;
  SubScene: TInfoSubSceneEnum = stHighScores;
  BackScene: TSceneEnum = scMenu;
  Lf: Integer = 0;

procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Ok;
begin
  DisciplesRL.Scenes.CurrentScene := BackScene;
end;

procedure Cancel;
begin
  DisciplesRL.Scenes.CurrentScene := BackScene;
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
var
  I: TButtonEnum;
  L, W: Integer;
begin
  W := ResImage[reButtonDef].Width + 4;
  L := (Surface.Width div 2) - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  Lf := (Surface.Width div 2) - (ResImage[reFrame].Width) - 2;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Buttons[I] := TButton.Create(L, 600, Surface.Canvas, ButtonsText[I]);
    Inc(L, W);
    if (I = btOk) then
      Buttons[I].Sellected := True;
  end;
  Button := TButton.Create((Surface.Width div 2) - (ResImage[reButtonDef].Width div 2), DefaultButtonTop, Surface.Canvas, reTextClose);
  Button.Sellected := True;
end;

procedure RenderButtons;
var
  I: TButtonEnum;
begin
  case SubScene of
    stConfirm:
      begin
        for I := Low(Buttons) to High(Buttons) do
          Buttons[I].Render;
      end
  else
    Button.Render;
  end;
end;

procedure Render;
begin
  case SubScene of
    stConfirm:
      CenterTextOut(300, Dialog);
    stDialog:
      CenterTextOut(300, Dialog);
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
  RenderButtons;
end;

procedure Timer;
begin

end;

procedure MouseClick(X, Y: Integer);
begin
  case SubScene of
    stConfirm:
      begin
        if Buttons[btOk].MouseDown then
          Ok;
        if Buttons[btCancel].MouseDown then
          Cancel;
      end
  else
    if Button.MouseDown then
      Back;
  end;
end;

procedure MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
begin
  case SubScene of
    stConfirm:
      for I := Low(TButtonEnum) to High(TButtonEnum) do
        Buttons[I].MouseMove(X, Y);
  else
    Button.MouseMove(X, Y);
  end;
  Render;
end;

procedure KeyDown(var Key: Word; Shift: TShiftState);
begin
  case SubScene of
    stConfirm:
      case Key of
        K_ESCAPE:
          Cancel;
        K_ENTER:
          Ok;
      end
  else
    case Key of
      K_ESCAPE, K_ENTER:
        Back;
    end;
  end;
end;

procedure Show(const ADialog: string; const ABackScene: TSceneEnum);
begin
  Dialog := ADialog;
  SubScene := stDialog;
  BackScene := ABackScene;
  DisciplesRL.Scenes.CurrentScene := scInfo;
end;

procedure Show(const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum);
begin
  SubScene := ASubScene;
  BackScene := ABackScene;
  DisciplesRL.Scenes.CurrentScene := scInfo;
end;

function Show(const ADialog: string; const ASubScene: TInfoSubSceneEnum; const ABackScene: TSceneEnum): Boolean;
begin
  Dialog := ADialog;
  SubScene := ASubScene;
  BackScene := ABackScene;
  DisciplesRL.Scenes.CurrentScene := scInfo;

  Result := MessageDlg(ADialog, mtConfirmation, [mbOK, mbCancel], 0) = mrOK;
end;

procedure Free;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Buttons[I]);
  FreeAndNil(Button);
end;

end.
