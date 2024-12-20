unit Elinor.Scene.Menu.Wide;

interface

uses
  System.Classes,
  Vcl.Controls,
  Elinor.Resources,
  Elinor.Button,
  Elinor.Scene.Frames;

type
  TSceneWideMenu = class(TSceneFrames)
  private type
    TTwoButtonEnum = (btCancel, btContinue);
  private const
    TwoButtonText: array [TTwoButtonEnum] of TResEnum = (reTextCancel,
      reTextContinue);
  private
    TwoButton: array [TTwoButtonEnum] of TButton;
    FCurrentIndex: Integer;
    procedure RenderButtons;
    public var
  public
    constructor Create(const AResEnum: TResEnum);
    destructor Destroy; override;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Cancel; virtual;
    procedure Continue; virtual;
    property CurrentIndex: Integer read FCurrentIndex write FCurrentIndex;
    procedure Update(var Key: Word); override;
    procedure Basic(AKey: Word);
  end;

implementation

uses
  Math,
  SysUtils,
  Elinor.Frame,
  Elinor.Common,
  Elinor.Scenes;

{ TSceneSimpleMenu }

procedure TSceneWideMenu.Basic(AKey: Word);
begin
  case AKey of
    K_ESCAPE:
      Cancel;
    K_ENTER:
      Continue;
  end;
end;

procedure TSceneWideMenu.Cancel;
begin

end;

procedure TSceneWideMenu.Continue;
begin

end;

constructor TSceneWideMenu.Create(const AResEnum: TResEnum);
var
  LTwoButtonEnum: TTwoButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(AResEnum, fgLS6, fgRM2);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TTwoButtonEnum)) + 1)) div 2);
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
  begin
    TwoButton[LTwoButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      TwoButtonText[LTwoButtonEnum]);
    Inc(LLeft, LWidth);
    if (LTwoButtonEnum = btContinue) then
      TwoButton[LTwoButtonEnum].Sellected := True;
  end;
end;

destructor TSceneWideMenu.Destroy;
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    FreeAndNil(TwoButton[LTwoButtonEnum]);
  inherited;
end;

procedure TSceneWideMenu.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  I: Integer;
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        for I := 0 to 2 do
          if MouseOver(TFrame.Col(1), TFrame.Row(I), X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := I;
            Break;
          end;
        begin
          if TwoButton[btCancel].MouseDown then
            Cancel;
          if TwoButton[btContinue].MouseDown then
            Continue;
        end;
      end;
  end;
end;

procedure TSceneWideMenu.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  inherited;
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    TwoButton[LTwoButtonEnum].MouseMove(X, Y);
end;

procedure TSceneWideMenu.Render;
var
  LX, LY: Integer;
begin
  inherited;

  case CurrentIndex of
    0 .. 2:
      begin
        LX := TFrame.Col(0);
        LY := TFrame.Row(CurrentIndex);
      end;
    3 .. 5:
      begin
        LX := TFrame.Col(1);
        LY := TFrame.Row(CurrentIndex - 3);
      end;
  end;
  DrawImage(LX, LY, reActFrame);

  RenderButtons;
end;

procedure TSceneWideMenu.RenderButtons;
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    TwoButton[LTwoButtonEnum].Render;
end;

procedure TSceneWideMenu.Update(var Key: Word);
var
  FF: Boolean;
begin
  inherited;
  FF := CurrentIndex in [0 .. 4];
  case Key of
    K_ESCAPE:
      Cancel;
    K_ENTER:
      if FF then
        Continue;
    K_UP:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          1, 2, 4, 5:
            CurrentIndex := CurrentIndex - 1;
        end;
      end;
    K_Down:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          0, 1, 3, 4:
            CurrentIndex := CurrentIndex + 1;
        end;
      end;
    K_LEFT:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          3 .. 5:
            CurrentIndex := CurrentIndex - 3;
        end;
      end;
    K_RIGHT:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          0 .. 2:
            CurrentIndex := CurrentIndex + 3;
        end;
      end;
  end;
end;

end.
