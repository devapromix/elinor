unit Elinor.Scene.Frames;

interface

uses
  Classes,
  DisciplesRL.Button,
  Elinor.Resources,
  DisciplesRL.Scenes;

type
  TSceneFrames = class(TScene)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
  end;

implementation

uses
  Math,
  SysUtils;

{ TSceneFrames }

constructor TSceneFrames.Create;
begin
  inherited;
end;

destructor TSceneFrames.Destroy;
begin

  inherited;
end;

procedure TSceneFrames.Render;
begin
  inherited;
  DrawImage(reWallpaperSettlement);
  Game.DrawImage(1, 1, reFrame);
end;

end.
