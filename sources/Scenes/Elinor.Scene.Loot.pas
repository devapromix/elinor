unit Elinor.Scene.Loot;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Scenes;

type
  TSceneLoot = class(TScene)
  private type
    TButtonEnum = (btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure DrawItem(ItemRes: array of TResEnum);
    procedure DrawGold;
    procedure DrawMana;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(const ALootRes: TResEnum);
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scene.Victory,
  Elinor.Scene.Settlement,
  Elinor.Scenario,
  Elinor.Items;

var
  GC, MC: Integer;
  LootRes: TResEnum;

  { TSceneLoot }

constructor TSceneLoot.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create;
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

destructor TSceneLoot.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneLoot.DrawGold;
begin
  case GC of
    0:
      DrawItem([reItemGold]);
    1:
      DrawItem([reItemGold, reItemGold]);
    2:
      DrawItem([reItemGold, reItemGold, reItemGold]);
  end;
end;

procedure TSceneLoot.DrawItem(ItemRes: array of TResEnum);
var
  I, X: Integer;
begin
  DrawImage(ScrWidth - 59 - 120, 295, reSmallFrame);
  DrawImage(ScrWidth - 59, 295, reSmallFrame);
  DrawImage(ScrWidth - 59 + 120, 295, reSmallFrame);
  case Length(ItemRes) of
    1:
      if ItemRes[0] <> reNone then
        DrawImage(ScrWidth - 32, 300, ItemRes[0]);
    2, 3:
      begin
        X := -120;
        for I := 0 to Length(ItemRes) - 1 do
        begin
          if ItemRes[I] <> reNone then
            DrawImage(ScrWidth - 32 + X, 300, ItemRes[I]);
          Inc(X, 120);
        end;
      end;
  end;
end;

procedure TSceneLoot.DrawMana;
begin
  case MC of
    0:
      DrawItem([reItemMana]);
    1:
      DrawItem([reItemMana, reItemMana]);
    2:
      DrawItem([reItemMana, reItemMana, reItemMana]);
  end;
end;

procedure TSceneLoot.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btClose].MouseDown then
          HideScene;
      end;
    mbRight:
      begin

      end;
  end;
end;

procedure TSceneLoot.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneLoot.Render;
var
  ItemRes: TResEnum;
  It1, It2, It3: TResEnum;
  Left, X, Y, I: Integer;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;

  It1 := reNone;
  It2 := reNone;
  It3 := reNone;
  DrawImage(reWallpaperLoot);
  DrawTitle(reTitleLoot);
  case LootRes of
    reGold:
      begin
        DrawGold;
        DrawText(450, 'СОКРОВИЩЕ');
        DrawText(470, 'ЗОЛОТО +' + IntToStr(Game.Gold.NewValue));
      end;
    reMana:
      begin
        DrawMana;
        DrawText(450, 'СОКРОВИЩЕ');
        DrawText(470, 'МАНА +' + IntToStr(Game.Mana.NewValue));
      end;
    reBag:
      begin
        Y := 470;
        DrawText(450, 'СОКРОВИЩЕ');
        if Game.Gold.NewValue > 0 then
        begin
          It1 := reItemGold;
          DrawText(Y, 'ЗОЛОТО +' + IntToStr(Game.Gold.NewValue));
          Inc(Y, 20);
        end;
        if Game.Mana.NewValue > 0 then
        begin
          if It1 = reNone then
            It1 := reItemMana
          else
            It2 := reItemMana;
          DrawText(Y, 'МАНА +' + IntToStr(Game.Mana.NewValue));
          Inc(Y, 20);
        end;
        if TSaga.NewItem > 0 then
        begin
          ItemRes := TItemBase.Item(TSaga.NewItem).ItRes;
          if It1 = reNone then
            It1 := ItemRes
          else if It2 = reNone then
            It2 := ItemRes
          else
            It3 := ItemRes;
          DrawText(Y, TItemBase.Item(TSaga.NewItem).Name);
          Inc(Y, 20);
        end;
        DrawItem([It1, It2, It3]);
      end;
  end;
  RenderButtons;
end;

class procedure TSceneLoot.ShowScene(const ALootRes: TResEnum);
begin
  LootRes := ALootRes;
  GC := RandomRange(0, 3);
  MC := RandomRange(0, 3);
  Game.MediaPlayer.PlaySound(mmLoot);
  Game.Show(scLoot);
end;

class procedure TSceneLoot.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmLoot);
  // F := True;
  Game.Show(scMap);
  begin
    if (Game.Scenario.CurrentScenario = sgDarkTower) then
    begin
      case Game.Map.LeaderTile of
        reTower:
          begin
            TSceneVictory.ShowScene;
            Exit;
          end;
      end;
    end;
    if Game.Map.LeaderTile = reNeutralCity then
    begin
      Game.MediaPlayer.PlayMusic(mmGame);
      Game.MediaPlayer.PlaySound(mmSettlement);
      TSceneSettlement.ShowScene(stCity);
      Exit;
    end;
    // if F then
    // Game.NewDay;
  end;
end;

procedure TSceneLoot.Timer;
begin
  inherited;

end;

procedure TSceneLoot.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;

  end;
end;

end.
