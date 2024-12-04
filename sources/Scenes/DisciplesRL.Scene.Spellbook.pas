unit DisciplesRL.Scene.Spellbook;

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  DisciplesRL.Button,
  Elinor.Resources,
  Elinor.Party,
  DisciplesRL.Scenes;

type
  TSceneSpellbook = class(TScene)
  private type
    TButtonEnum = (btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);
  private
  class var
    Button: array [TButtonEnum] of TButton;
    SettlementParty: TParty;
  private
    procedure Close;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure Show;
  end;

implementation

uses
  SysUtils,
  Elinor.Saga,
  DisciplesRL.Map,
  Elinor.Scene.Party,
  DisciplesRL.Creatures,
  DisciplesRL.Scene.Hire;

{ TSceneSpellbook }

procedure TSceneSpellbook.Close;
begin
  Game.Show(scMap);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSpellbook);
end;

constructor TSceneSpellbook.Create;
var
  I: TButtonEnum;
  L, W: Integer;
begin
  inherited;
  W := ResImage[reButtonDef].Width + 4;
  L := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, DefaultButtonTop, ButtonText[I]);
    Inc(L, W);
    if (I = btClose) then
      Button[I].Sellected := True;
  end;
end;

destructor TSceneSpellbook.Destroy;
var
  I: TButtonEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
  inherited;
end;

procedure TSceneSpellbook.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

procedure TSceneSpellbook.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TSceneSpellbook.Render;

  procedure RenderButtons;
  var
    I: TButtonEnum;
  begin
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      Button[I].Render;
  end;

begin
  inherited;
  DrawImage(reWallpaperSettlement);
  DrawTitle(reTitleSpellbook);

  RenderButtons;
end;

class procedure TSceneSpellbook.Show;
begin
  Game.MediaPlayer.PlaySound(mmSpellbook);
  Game.Show(scSpellbook);
end;

procedure TSceneSpellbook.Timer;
begin
  inherited;

end;

procedure TSceneSpellbook.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      Close;
  end;
end;

end.
