unit Elinor.Panel;

interface

uses
  Elinor.Resources;

type
  TPanelButtonEnum = (pbParty, pbAbilities, pbInventory, pbSpellbook,
    pbScenario, pbEscape);

const
  PanelButtonRes: array [TPanelButtonEnum] of TResEnum = (reButtonParty,
    reButtonAbility, reButtonInv, reButtonSpellbook, reButtonScenario,
    reButtonMenu);

type
  TPanel = class(TObject)
  private
    FButton: array of TPanelButtonEnum;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw();
  end;

var
  Panel: TPanel;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Scenes,
  Elinor.Spells;

{ TPanel }

constructor TPanel.Create;
begin

end;

destructor TPanel.Destroy;
begin

  inherited;
end;

procedure TPanel.Draw;
var
  LPanelButtonEnum: TPanelButtonEnum;
begin
  for LPanelButtonEnum := Low(TPanelButtonEnum) to High(TPanelButtonEnum) do
  begin
    if LPanelButtonEnum = pbEscape then
      if Spells.ActiveSpell.IsSpell() then
      begin
        Game.Surface.Canvas.Draw((ord(LPanelButtonEnum) * 32) + 1, 1,
          ResImage[reButtonCancel]);
        Continue;
      end;
    Game.Surface.Canvas.Draw((ord(LPanelButtonEnum) * 32) + (18 * 32), 1,
      ResImage[PanelButtonRes[LPanelButtonEnum]]);
  end;
end;

initialization

Panel := TPanel.Create;

finalization

FreeAndNil(Panel);

end.
