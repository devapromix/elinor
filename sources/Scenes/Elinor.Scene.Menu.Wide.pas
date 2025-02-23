unit Elinor.Scene.Menu.Wide;

interface

uses
  System.Classes,
  Vcl.Controls,
  Elinor.Resources,
  Elinor.Button,
  Elinor.Direction,
  Elinor.Scene.Frames;

type
  TSceneWideMenu = class(TSceneFrames)
  private type
    TTwoButtonEnum = (btCancel, btContinue);
  private const
    TwoButtonText: array [TTwoButtonEnum] of TResEnum = (reTextCancel,
      reTextContinue);
  private
    Button: array [TTwoButtonEnum] of TButton;
    FCurrentIndex: Integer;
  public
    constructor Create(const AResEnum: TResEnum);
    destructor Destroy; override;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Cancel; virtual;
    procedure Continue; virtual;
    procedure MoveCursor(const AArrowKeyDirectionEnum: TArrowKeyDirectionEnum);
    property CurrentIndex: Integer read FCurrentIndex write FCurrentIndex;
    procedure Update(var Key: Word); override;
    procedure Basic(AKey: Word);
    procedure RenderButtons;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Frame,
  Elinor.Common,
  Elinor.Scenes;

const
  PositionTransitions: array [TArrowKeyDirectionEnum, 0 .. 5] of Integer = (
    // Left
    (3, 4, 5, 0, 1, 2),
    // Right
    (3, 4, 5, 0, 1, 2),
    // Up
    (2, 0, 1, 5, 3, 4),
    // Down
    (1, 2, 0, 4, 5, 3)
    //
    );

  { TSceneSimpleMenu }

procedure TSceneWideMenu.MoveCursor(const AArrowKeyDirectionEnum
  : TArrowKeyDirectionEnum);
begin
  CurrentIndex := PositionTransitions[AArrowKeyDirectionEnum, CurrentIndex];
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Render;
end;

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
  CurrentIndex := 0;
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TTwoButtonEnum)) + 1)) div 2);
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
  begin
    Button[LTwoButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      TwoButtonText[LTwoButtonEnum]);
    Inc(LLeft, LWidth);
    if (LTwoButtonEnum = btContinue) then
      Button[LTwoButtonEnum].Sellected := True;
  end;
end;

destructor TSceneWideMenu.Destroy;
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    FreeAndNil(Button[LTwoButtonEnum]);
  inherited;
end;

procedure TSceneWideMenu.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPartyPosition: Integer;
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        LPartyPosition := GetFramePosition(X, Y);
        case LPartyPosition of
          0 .. 5:
            begin
              CurrentIndex := LPartyPosition;
              Game.MediaPlayer.PlaySound(mmClick);
              Exit;
            end;
        end;
        if Button[btCancel].MouseDown then
          Cancel;
        if Button[btContinue].MouseDown then
          Continue;
      end;
  end;
end;

procedure TSceneWideMenu.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  inherited;
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    Button[LTwoButtonEnum].MouseMove(X, Y);
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
  DrawImage(LX, LY, reFrameSlotActive);

  RenderButtons;
end;

procedure TSceneWideMenu.RenderButtons;
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    Button[LTwoButtonEnum].Render;
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
    K_LEFT, K_KP_4:
      MoveCursor(kdLeft);
    K_RIGHT, K_KP_6:
      MoveCursor(kdRight);
    K_UP, K_KP_8:
      MoveCursor(kdUp);
    K_DOWN, K_KP_2:
      MoveCursor(kdDown);
  end;
end;

end.
