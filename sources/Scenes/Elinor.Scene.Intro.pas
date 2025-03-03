unit Elinor.Scene.Intro;

interface

uses
  Vcl.Graphics,
  System.Classes,
  Elinor.Scenes;

type
  TSceneIntro = class(TScene)
  private
    FTimerValue: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Timer; override;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Resources;

{ TSceneIntro }

constructor TSceneIntro.Create;
begin
  inherited Create;
  FTimerValue := 0;
end;

destructor TSceneIntro.Destroy;
begin

  inherited;
end;

procedure TSceneIntro.Render;
begin
  inherited;
  DrawImage((ScreenWidth div 2) - 100, 220, reElinorIntro);
  DrawImage((ScreenWidth div 2) - 170, 470, reTextDarkogStudio);
  DrawImage((ScreenWidth div 2) - 125, 520, reTextPresents);
end;

procedure TSceneIntro.Timer;
begin
  Inc(FTimerValue);
  if FTimerValue > IfThen(Game.Wizard, 1, 7) then
    Game.Show(scMenu);
end;

end.
