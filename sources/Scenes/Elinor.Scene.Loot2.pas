unit Elinor.Scene.Loot2;

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
  TSceneLoot2 = class(TSceneWideMenu)
  private type
    TButtonEnum = (btPickup, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextCast, reTextClose);
  private
    class var Button: array [TButtonEnum] of TButton;
  private
    procedure PickupItem;
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
  Elinor.Scene.Party,
  Elinor.Creatures,
  DisciplesRL.Scene.Hire,
  Elinor.Frame,
  Elinor.Spells.Types,
  Elinor.Loot,
  Elinor.Items,
  Elinor.Statistics;

{ TSceneLoot2 }

procedure TSceneLoot2.PickupItem;
var
  LLootItem: TLootItem;
  X, Y, LItemIndex: Integer;
begin
  X := TLeaderParty.Leader.X;
  Y := TLeaderParty.Leader.Y;
  LItemIndex := Loot.GetItemIndex(X, Y, CurrentIndex);
  if LItemIndex >= 0 then
  begin
    LLootItem := Loot.GetLootItem(LItemIndex);
    TLeaderParty.Leader.Inventory.Add(LLootItem.ItemEnum);
    Game.Statistics.IncValue(stItemsFound);
    Loot.Clear(LItemIndex);
  end;

end;

class procedure TSceneLoot2.HideScene;
begin
  Game.Show(scMap);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmLoot);
end;

constructor TSceneLoot2.Create;
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

destructor TSceneLoot2.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneLoot2.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btPickup].MouseDown then
          PickupItem
        else if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneLoot2.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneLoot2.Render;

  procedure RenderItems;
  var
    X, Y, I, J, LCount: Integer;
    LLeft, LTop: Integer;
    LLootItem: TLootItem;
  begin
    X := TLeaderParty.Leader.X;
    Y := TLeaderParty.Leader.Y;
    LCount := Loot.Count(X, Y);
    for I := 0 to LCount - 1 do
    begin
      LLeft := IfThen(I > 2, TFrame.Col(1), TFrame.Col(0));
      LTop := IfThen(I > 2, TFrame.Row(I - 3), TFrame.Row(I));
      J := Loot.GetItemIndex(X, Y, I);
      LLootItem := Loot.GetLootItem(J);
      DrawItem(LLootItem.ItemEnum, LLeft, LTop);
      DrawText(LLeft + 74, LTop + 6, TItemBase.Item(LLootItem.ItemEnum).Name);
    end;
  end;

  procedure RenderItemInfo;
  var
    LLootItem: TLootItem;
    X, Y, I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    X := TLeaderParty.Leader.X;
    Y := TLeaderParty.Leader.Y;
    I := Loot.GetItemIndex(X, Y, CurrentIndex);
    if I >= 0 then
    begin
      LLootItem := Loot.GetLootItem(I);
      AddTextLine(TItemBase.Item(LLootItem.ItemEnum).Name, True);
      AddTextLine;
      if LLootItem.Amount > 1 then
        AddTextLine('Amount', LLootItem.Amount);
      AddTextLine('Level', TItemBase.Item(LLootItem.ItemEnum).Level);
    end;
  end;

  procedure RenderInventory;
  var
    I: Integer;
  begin
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Inventory', True);
    AddTextLine;
    for I := 0 to MaxInventoryItems - 1 do
      AddTextLine(TLeaderParty.Leader.Inventory.ItemName(I));
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
  DrawTitle(reTitleLoot);
  RenderItems;
  RenderItemInfo;
  RenderInventory;
  RenderButtons;
end;

class procedure TSceneLoot2.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmLoot);
  Game.Show(scLoot2);
end;

procedure TSceneLoot2.Timer;
begin
  inherited;

end;

procedure TSceneLoot2.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE:
      HideScene;
    K_ENTER:
      PickupItem;
  end;
end;

end.
