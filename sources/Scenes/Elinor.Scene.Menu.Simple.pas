unit Elinor.Scene.Menu.Simple;

interface

uses
  System.Classes,
  Vcl.Controls,
  Elinor.Resources,
  Elinor.Button,
  Elinor.Scene.Frames;

type
  TSceneSimpleMenu = class(TSceneFrames)
  private type
    TOneButtonEnum = (btClose);
    TTwoButtonEnum = (btCancel, btContinue);
  private const
    OneButtonText: array [TOneButtonEnum] of TResEnum = (reTextClose);
    TwoButtonText: array [TTwoButtonEnum] of TResEnum = (reTextCancel,
      reTextContinue);
  private
    OneButton: array [TOneButtonEnum] of TButton;
    TwoButton: array [TTwoButtonEnum] of TButton;
    FCurrentIndex: Integer;
    FIsOneButton: Boolean;
    FIsBlockFrames: Boolean;
    procedure RenderButtons;
  public
    constructor Create(const AResEnum: TResEnum);
    destructor Destroy; override;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure UpdateEnum<N>(AKey: Word);
    procedure Cancel; virtual;
    procedure Continue; virtual;
    property CurrentIndex: Integer read FCurrentIndex write FCurrentIndex;
    property IsOneButton: Boolean read FIsOneButton write FIsOneButton;
    property IsBlockFrames: Boolean read FIsBlockFrames write FIsBlockFrames;
    procedure Update(var Key: Word); override;
    procedure Basic(AKey: Word);
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Frame,
  Elinor.Common,
  Elinor.Scenes;

{ TSceneSimpleMenu }

procedure TSceneSimpleMenu.Basic(AKey: Word);
begin
  case AKey of
    K_ESCAPE:
      Cancel;
    K_ENTER:
      Continue;
  end;
end;

procedure TSceneSimpleMenu.Cancel;
begin

end;

procedure TSceneSimpleMenu.Continue;
begin

end;

constructor TSceneSimpleMenu.Create(const AResEnum: TResEnum);
var
  LOneButtonEnum: TOneButtonEnum;
  LTwoButtonEnum: TTwoButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(AResEnum, fgLS3, fgRM1);
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

destructor TSceneSimpleMenu.Destroy;
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

procedure TSceneSimpleMenu.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  I: Integer;
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        for I := 0 to 2 do
          if MouseOver(TFrame.Col(1), TFrame.Row(I), X, Y) and not IsBlockFrames
          then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := I;
            Break;
          end;
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

procedure TSceneSimpleMenu.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LOneButtonEnum: TOneButtonEnum;
  LTwoButtonEnum: TTwoButtonEnum;
begin
  inherited;
  if IsOneButton then
    for LOneButtonEnum := Low(TOneButtonEnum) to High(TOneButtonEnum) do
      OneButton[LOneButtonEnum].MouseMove(X, Y)
  else
    for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
      TwoButton[LTwoButtonEnum].MouseMove(X, Y);
end;

procedure TSceneSimpleMenu.Render;
begin
  inherited;
  RenderButtons;
end;

procedure TSceneSimpleMenu.RenderButtons;
var
  LOneButtonEnum: TOneButtonEnum;
  LTwoButtonEnum: TTwoButtonEnum;
begin
  if IsOneButton then
    for LOneButtonEnum := Low(TOneButtonEnum) to High(TOneButtonEnum) do
      OneButton[LOneButtonEnum].Render
  else
    for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
      TwoButton[LTwoButtonEnum].Render;
end;

procedure TSceneSimpleMenu.Update(var Key: Word);
begin
  inherited;
end;

procedure TSceneSimpleMenu.UpdateEnum<N>(AKey: Word);
var
  LCycler: TEnumCycler<N>;
begin
  Basic(AKey);
  if not(AKey in [K_UP, K_Down]) then
    Exit;
  Game.MediaPlayer.PlaySound(mmClick);
  LCycler := TEnumCycler<N>.Create(CurrentIndex);
  CurrentIndex := LCycler.Modify(AKey = K_Down);
end;

end.
