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
    TButtonEnum = (btCancel, btContinue);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextCancel,
      reTextContinue);
  private
    Button: array [TButtonEnum] of TButton;
    FCurrentIndex: Integer;
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
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(AResEnum, fgLS3, fgRM1);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btContinue) then
      Button[LButtonEnum].Sellected := True;
  end;
end;

destructor TSceneSimpleMenu.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
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
          if MouseOver(TFrame.Col(1), TFrame.Row(I), X, Y) then
          begin
            Game.MediaPlayer.PlaySound(mmClick);
            CurrentIndex := I;
            Break;
          end;
        if Button[btCancel].MouseDown then
          Cancel;
        if Button[btContinue].MouseDown then
          Continue;
      end;
  end;
end;

procedure TSceneSimpleMenu.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneSimpleMenu.Render;
begin
  inherited;
  RenderButtons;
end;

procedure TSceneSimpleMenu.RenderButtons;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].Render;
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
