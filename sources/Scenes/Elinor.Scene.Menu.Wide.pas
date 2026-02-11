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
    TOneButtonEnum = (btClose);
    TTwoButtonEnum = (btCancel, btContinue);
  private const
    OneButtonText: array [TOneButtonEnum] of TResEnum = (reTextClose);
    TwoButtonText: array [TTwoButtonEnum] of TResEnum = (reTextCancel,
      reTextContinue);
  private
    FIsOneButton: Boolean;
    FIsBlockFrames: Boolean;
    OneButton: array [TOneButtonEnum] of TButton;
    TwoButton: array [TTwoButtonEnum] of TButton;
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
    property IsOneButton: Boolean read FIsOneButton write FIsOneButton;
    property IsBlockFrames: Boolean read FIsBlockFrames write FIsBlockFrames;
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
  LOneButtonEnum: TOneButtonEnum;
  LTwoButtonEnum: TTwoButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(AResEnum, fgLS6, ARightFrameGrid);
  FShowButtons := AShowButtons;
  CurrentIndex := 0;
  IsOneButton := False;
  IsBlockFrames := False;
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - (ResImage[reButtonDef].Width div 2);
  for LOneButtonEnum := Low(TOneButtonEnum) to High(TOneButtonEnum) do
  begin
    OneButton[LOneButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      OneButtonText[LOneButtonEnum]);
    OneButton[LOneButtonEnum].Selected := True;
  end;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TTwoButtonEnum)) + 1)) div 2);
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
  begin
    TwoButton[LTwoButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      TwoButtonText[LTwoButtonEnum]);
    Inc(LLeft, LWidth);
    if (LTwoButtonEnum = btContinue) then
      TwoButton[LTwoButtonEnum].Selected := True;
  end;
end;

destructor TSceneWideMenu.Destroy;
var
  LOneButtonEnum: TOneButtonEnum;
  LTwoButtonEnum: TTwoButtonEnum;
begin
  for LOneButtonEnum := Low(TOneButtonEnum) to High(TOneButtonEnum) do
    FreeAndNil(OneButton[LOneButtonEnum]);
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    FreeAndNil(TwoButton[LTwoButtonEnum]);
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
            if not IsBlockFrames then
            begin
              CurrentIndex := LPartyPosition;
              Game.MediaPlayer.PlaySound(mmClick);
              Exit;
            end;
        end;
        if FShowButtons then
        begin
          if IsOneButton then
          begin
            if OneButton[btClose].MouseDown then
              Cancel;
          end
          else
          begin
            if TwoButton[btCancel].MouseDown then
              Cancel;
            if TwoButton[btContinue].MouseDown then
              Continue;
          end;
        end;
      end;
  end;
end;

procedure TSceneWideMenu.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LOneButtonEnum: TOneButtonEnum;
  LTwoButtonEnum: TTwoButtonEnum;
begin
  inherited;
  if FShowButtons then
  begin
    if IsOneButton then
      for LOneButtonEnum := Low(TOneButtonEnum) to High(TOneButtonEnum) do
        OneButton[LOneButtonEnum].MouseMove(X, Y)
    else
      for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
        TwoButton[LTwoButtonEnum].MouseMove(X, Y);
  end;
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
  LOneButtonEnum: TOneButtonEnum;
  LTwoButtonEnum: TTwoButtonEnum;
begin
  if FShowButtons then
    if IsOneButton then
      for LOneButtonEnum := Low(TOneButtonEnum) to High(TOneButtonEnum) do
        OneButton[LOneButtonEnum].Render
    else
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
