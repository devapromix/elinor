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

{ TSceneLoot }

uses
  Elinor.Saga;

constructor TSceneLoot.Create;
begin
  inherited Create;

end;

destructor TSceneLoot.Destroy;
begin

  inherited;
end;

procedure TSceneLoot.MouseDown(AButton: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

end;

procedure TSceneLoot.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TSceneLoot.Render;
begin
  inherited;

end;

class procedure TSceneLoot.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmLoot);
end;

class procedure TSceneLoot.HideScene;
begin

end;

procedure TSceneLoot.Timer;
begin
  inherited;

end;

procedure TSceneLoot.Update(var Key: Word);
begin
  inherited;

end;

end.
