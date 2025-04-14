unit Elinor.Scene.MageTower;

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
  TSceneMageTower = class(TSceneWideMenu)
  private type
    TButtonEnum = (btLearn, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextLearn, reTextClose);
  private
    class var Button: array [TButtonEnum] of TButton;
  private
    procedure LearnSpell;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Map,
  Elinor.Creatures,
  Elinor.Frame,
  Elinor.Spells.Types,
  Elinor.Spellbook,
  Elinor.Common;

{ TSceneMageTower }

procedure TSceneMageTower.LearnSpell;
var
  LSpellEnum: TSpellEnum;
  LMana: Byte;
begin
  LSpellEnum := FactionSpellbookSpells[TLeaderParty.Leader.Owner][CurrentIndex];
  if (LSpellEnum <> spNone) and not Spells.IsLearned(LSpellEnum) then
  begin
    LMana := Spells.Spell(LSpellEnum).Mana * 2;
    if LMana > Game.Mana.Value then
    begin
      Game.MediaPlayer.PlaySound(mmSpellbook);
      InformDialog(CNotEnoughManaToLearn);
      Exit;
    end;
    Game.MediaPlayer.PlaySound(mmLearn);
    Game.Mana.Modify(-LMana);
    Spells.Learn(LSpellEnum);
    InformDialog(CAddSpellToSpellbook);
  end;
end;

class procedure TSceneMageTower.HideScene;
begin
  Game.MediaPlayer.PlayMusic(mmMap);
  Game.Show(scMap);
  Game.MediaPlayer.PlaySound(mmClick);
end;

constructor TSceneMageTower.Create;
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

destructor TSceneMageTower.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneMageTower.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btLearn].MouseDown then
          LearnSpell
        else if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneMageTower.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneMageTower.Render;

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
      LSpellEnum := FactionSpellbookSpells[Game.Scenario.Faction][LSpellIndex];
      if (LSpellEnum <> spNone) then
      begin
        DrawSpell(LSpellEnum, LLeft, LTop, Spells.IsLearned(LSpellEnum));
        DrawText(LLeft + 74, LTop + 6, TSpells.Spell(LSpellEnum).Name);
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
      AddTextLine(Format('Research cost %d mana',
        [TSpells.Spell(LSpellEnum).Mana * 2]));
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

  DrawTitle(reTitleMageTower);
  RenderSpells;
  RenderSpellInfo;
  RenderStatistics;

  RenderButtons;
end;

class procedure TSceneMageTower.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scMageTower);
end;

procedure TSceneMageTower.Timer;
begin
  inherited;

end;

procedure TSceneMageTower.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE:
      HideScene;
    K_L, K_ENTER:
      LearnSpell;
  end;
end;

end.
