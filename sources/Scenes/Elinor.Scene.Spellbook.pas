unit Elinor.Scene.Spellbook;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Spells,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scene.Menu.Wide,
  Elinor.Scenes;

type
  TSceneSpellbook = class(TSceneWideMenu)
  private type
    TButtonEnum = (btCast, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextCast, reTextClose);
  private
    class var Button: array [TButtonEnum] of TButton;
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
  Elinor.Frame,
  Elinor.Spells.Types,
  Elinor.Spellbook;

var
  CloseSceneEnum: TSceneEnum;

  { TSceneSpellbook }

procedure TSceneSpellbook.CastSpell;
var
  LSpellEnum: TSpellEnum;
  LMana: Byte;
  L: TStringList;
begin
  LSpellEnum := FactionSpellbookSpells[TLeaderParty.Leader.Owner][CurrentIndex];
  if (LSpellEnum <> spNone) and Spells.IsLearned(LSpellEnum) then
  begin
    LMana := Spells.Spell(LSpellEnum).Mana;
    if LMana > Game.Mana.Value then
    begin
      InformDialog('Not enough mana to cast this spell!');
      Exit;
    end;
    Spells.ActiveSpell.SetActiveSpell(LSpellEnum);
    Game.Mana.Modify(-LMana);
    Game.MediaPlayer.PlaySound(mmSpellbook);
    Game.MediaPlayer.PlaySound(mmPrepareMagic);
    Game.Show(scMap);
  end;
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

  procedure RenderSpells;
  var
    LSpellIndex: Integer;
    LSpellEnum: TSpellEnum;
    LLeft, LTop: Integer;
  begin
    for LSpellIndex := 0 to 5 do
    begin
      LLeft := IfThen(LSpellIndex > 2, TFrame.Col(1), TFrame.Col(0));
      LTop := IfThen(LSpellIndex > 2, TFrame.Row(LSpellIndex - 3),
        TFrame.Row(LSpellIndex));
      LSpellEnum := FactionSpellbookSpells[TSaga.LeaderFaction][LSpellIndex];
      if (LSpellEnum <> spNone) then
      begin
        DrawSpell(LSpellEnum, LLeft, LTop, not Spells.IsLearned(LSpellEnum));
        DrawText(LLeft + 74, LTop + 6, TSpells.Spell(LSpellEnum).Name);
        DrawText(LLeft + 74, LTop + 27,
          Format('Level %d', [TSpells.Spell(LSpellEnum).Level]));
      end;
    end;
  end;

  procedure RenderSpellInfo;
  var
    LSpellEnum: TSpellEnum;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    LSpellEnum := FactionSpellbookSpells[TLeaderParty.Leader.Owner]
      [CurrentIndex];
    if (LSpellEnum <> spNone) then
    begin
      AddTextLine(TSpells.Spell(LSpellEnum).Name, True);
      AddTextLine;
      AddTextLine('Level', TSpells.Spell(LSpellEnum).Level);
      AddTextLine;
      AddTextLine(Format('Casting cost %d mana',
        [TSpells.Spell(LSpellEnum).Mana]));
      AddTextLine;
    end;
  end;

  procedure RenderStatistics;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Statistics', True);
    AddTextLine;
    AddTextLine('Available mana', Game.Mana.Value);
  end;

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
  RenderSpells;
  RenderSpellInfo;
  RenderStatistics;

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
