unit Elinor.Scene.Spellbook;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneSpellbook = class(TSceneFrames)
  private type
    TButtonEnum = (btCast, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextCast, reTextClose);
  private
  class var
    Button: array [TButtonEnum] of TButton;
    SettlementParty: TParty;
  private
    procedure CastSpell;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(const ACloseSceneEnum: TSceneEnum);
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Map,
  Elinor.Scene.Party,
  Elinor.Creatures,
  DisciplesRL.Scene.Hire,
  Elinor.Spells;

var
  CloseSceneEnum: TSceneEnum;

  { TSceneSpellbook }

procedure TSceneSpellbook.CastSpell;
begin
  CurrentSpell := spTrueHealing;
  Game.MediaPlayer.PlaySound(mmSpellbook);
  Game.Show(scMap);
end;

class procedure TSceneSpellbook.HideScene;
begin
  Game.Show(CloseSceneEnum);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSpellbook);
end;

constructor TSceneSpellbook.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperSettlement, fgLS6, fgRM1);
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

destructor TSceneSpellbook.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneSpellbook.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btCast].MouseDown then
          CastSpell
        else if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneSpellbook.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneSpellbook.Render;

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

class procedure TSceneSpellbook.ShowScene(const ACloseSceneEnum: TSceneEnum);
begin
  CloseSceneEnum := ACloseSceneEnum;
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
    K_ESCAPE:
      HideScene;
    K_C, K_ENTER:
      CastSpell;
  end;
end;

end.
