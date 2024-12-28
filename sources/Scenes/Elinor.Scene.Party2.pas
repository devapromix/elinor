unit Elinor.Scene.Party2;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scene.Menu.Wide;

type
  TSceneParty2 = class(TSceneWideMenu)
  private type
    TButtonEnum = (btAbilities, btInventory, btDismiss, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextAbilities,
      reTextInventory, reTextDismiss, reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
    procedure Close;
    procedure Abilities;
    procedure Inventory;
    procedure Dismiss;

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
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenes,
  Elinor.Scene.Party,
  Elinor.Frame,
  Elinor.Creatures, Elinor.Statistics, DisciplesRL.Scene.Hire;

{ TSceneParty }

procedure TSceneParty2.Abilities;
begin

end;

procedure TSceneParty2.Close;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scSettlement);
end;

constructor TSceneParty2.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperLeader);
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

destructor TSceneParty2.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneParty2.Dismiss;
begin

end;

procedure TSceneParty2.Inventory;
begin

end;

procedure TSceneParty2.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  ActivePartyPosition := GetPartyPosition(X, Y);
  case AButton of
    mbLeft:
      begin
        if Button[btAbilities].MouseDown then
          Abilities
        else if Button[btInventory].MouseDown then
          Inventory
        else if Button[btDismiss].MouseDown then
          Dismiss
        else if Button[btClose].MouseDown then
          Close
      end;
  end;
end;

procedure TSceneParty2.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneParty2.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
  begin
    for LPosition := Low(TPosition) to High(TPosition) do
      if (TLeaderParty.Leader <> nil) then
        DrawUnit(LPosition, TLeaderParty.Leader, TFrame.Col(LPosition, psLeft),
          TFrame.Row(LPosition), False, True);
  end;

  procedure RenderInfo;
  var
    LCreatureEnum: TCreatureEnum;
  begin
    LCreatureEnum := TLeaderParty.Leader.Creature[ActivePartyPosition].Enum;
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    if (LCreatureEnum <> crNone) then
      DrawCreatureInfo(TLeaderParty.Leader.Creature[ActivePartyPosition]);
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(3) + 12;
    AddTextLine('Статистика', True);
    AddTextLine;
    AddTextLine('Выиграно битв', Game.Statistics.GetValue(stBattlesWon));
    AddTextLine('Убито врагов', Game.Statistics.GetValue(stKilledCreatures));
    AddTextLine('Очки', Game.Statistics.GetValue(stScore));
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine;
    AddTextLine(Format('Скорость передвижения %d/%d',
      [TLeaderParty.Leader.Speed, TLeaderParty.Leader.MaxSpeed]));
    AddTextLine(Format('Лидерство %d', [TLeaderParty.Leader.Leadership]));
    AddTextLine(Format('Радиус обзора %d', [TLeaderParty.Leader.Radius]));
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

  DrawTitle(reTitleParty);

  RenderParty;
  RenderInfo;

  RenderButtons;
end;

procedure TSceneParty2.Timer;
begin
  inherited;

end;

procedure TSceneParty2.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      Close;
    K_A:
      Abilities;
    K_I:
      Inventory;
    K_D:
      Dismiss;
  end;
end;

end.
