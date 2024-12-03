unit Elinor.Scene.Frames;

interface

uses
  Vcl.Graphics,
  Classes,
  DisciplesRL.Button,
  Elinor.Resources,
  DisciplesRL.Scenes;

type
  TSceneFrames = class(TScene)
  private
    FResEnum: TResEnum;
    FSurface: TBitmap;
  public
    constructor Create(const AResEnum: TResEnum);
    destructor Destroy; override;
    procedure Render; override;
    property ResEnum: TResEnum read FResEnum;
  end;

implementation

uses
  Math,
  SysUtils;

{ TSceneFrames }

constructor TSceneFrames.Create(const AResEnum: TResEnum);
var
  I, LLeft, LTop, LMid: Integer;
begin
  inherited Create;
  FResEnum := AResEnum;
  FSurface := TBitmap.Create;
  FSurface.Width := ScreenWidth;
  FSurface.Height := ScreenHeight;
  FSurface.Canvas.StretchDraw(Rect(0, 0, ScreenWidth, ScreenHeight),
    ResImage[FResEnum]);
  LLeft := 10;
  LTop := TScene.SceneTop;
  LMid := ScreenWidth - ((320 * 4) + 26);
  for I := 1 to 12 do
  begin
    FSurface.Canvas.Draw(LLeft, LTop, ResImage[reFrame]);
    Inc(LTop, 120);
    if LTop > TScene.SceneTop + 240 then
    begin
      LTop := TScene.SceneTop;
      Inc(LLeft, 322);
      if (I = 6) then
        Inc(LLeft, LMid);
    end;
  end;
end;

destructor TSceneFrames.Destroy;
begin
  FreeAndNil(FSurface);
  inherited;
end;

procedure TSceneFrames.Render;
begin
  inherited;
  Game.Surface.Canvas.Draw(0, 0, FSurface);
end;

end.
