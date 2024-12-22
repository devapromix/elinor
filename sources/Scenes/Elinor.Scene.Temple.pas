unit Elinor.Scene.Temple;

interface

uses
  Elinor.Scene.Frames,
  Elinor.Scene.Menu.Wide,
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneTemple = class(TSceneWideMenu)
  private type
    TButtonEnum = (btHeal, btRevive, btParty, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose, reTextClose,
      reTextClose, reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure Close;
    procedure Heal;
    procedure Revive;
    procedure Party;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

uses
  System.SysUtils;

{ TSceneTemple }

procedure TSceneTemple.Close;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scSettlement);
end;

constructor TSceneTemple.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperSettlement);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Sellected := True;
  end;

end;

destructor TSceneTemple.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneTemple.Heal;
begin

end;

procedure TSceneTemple.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TSceneTemple.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TSceneTemple.Party;
begin

end;

procedure TSceneTemple.Render;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;

  DrawTitle(reTitleSpellbook);

  RenderButtons;
end;

procedure TSceneTemple.Revive;
begin

end;

procedure TSceneTemple.Timer;
begin
  inherited;

end;

procedure TSceneTemple.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      Close;
    K_H:
      Heal;
    K_P:
      Party;
    K_R:
      Revive;
  end;
end;

end.
