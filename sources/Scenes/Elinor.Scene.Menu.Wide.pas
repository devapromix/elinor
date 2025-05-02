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
    FShowButtons: Boolean;
  public
    constructor Create(const AResEnum: TResEnum;
      const AShowButtons: Boolean = True;
      const ARightFrameGrid: TFrameGrid = fgRM2);
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
    property ShowButtons: Boolean read FShowButtons write FShowButtons;
  end;

implementation

uses
  System.Math,
  System.Types,
  System.SysUtils,
  Elinor.Frame,
  Elinor.Common,
  Elinor.Scenes;

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

constructor TSceneWideMenu.Create(const AResEnum: TResEnum;
  const AShowButtons: Boolean = True;
  const ARightFrameGrid: TFrameGrid = fgRM2);
var
  LTwoButtonEnum: TTwoButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(AResEnum, fgLS6, ARightFrameGrid);
  FShowButtons := AShowButtons;
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
        if FShowButtons then
        begin
          if Button[btCancel].MouseDown then
            Cancel;
          if Button[btContinue].MouseDown then
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
  if FShowButtons then
    for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
      Button[LTwoButtonEnum].MouseMove(X, Y);
end;

procedure TSceneWideMenu.Render;
var
  LPos: TPoint;
begin
  inherited;

  LPos := GetCurrentIndexPos(CurrentIndex);
  DrawImage(LPos.X, LPos.Y, reFrameSlotActive);

  RenderButtons;
end;

procedure TSceneWideMenu.RenderButtons;
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  if FShowButtons then
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
      if FShowButtons then
        Cancel;
    K_ENTER:
      if FF and FShowButtons then
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
