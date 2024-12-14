unit Elinor.Scene.Frames;

interface

uses
  Vcl.Graphics,
  Classes,
  DisciplesRL.Button,
  Elinor.Resources,
  DisciplesRL.Scenes;

type
  TFrameGrid = (fgS6vS6, fgS6vM2);

type
  TSceneFrames = class(TScene)
  private
    FResEnum: TResEnum;
    FSurface: TBitmap;
    FFrameGrid: TFrameGrid;
  public
    constructor Create(const AResEnum: TResEnum;
      const AFrameGrid: TFrameGrid = fgS6vS6);
    destructor Destroy; override;
    procedure Render; override;
    property ResEnum: TResEnum read FResEnum;
    property FrameGrid: TFrameGrid read FFrameGrid;
  end;

implementation

uses
  Math,
  SysUtils;

{ TSceneFrames }

constructor TSceneFrames.Create(const AResEnum: TResEnum;
  const AFrameGrid: TFrameGrid = fgS6vS6);
var
  I, LLeft, LTop, LMid, FrameCount: Integer;
begin
  inherited Create;
  FResEnum := AResEnum;
  FFrameGrid := AFrameGrid;
  FSurface := TBitmap.Create;
  FSurface.Width := ScreenWidth;
  FSurface.Height := ScreenHeight;
  FSurface.Canvas.StretchDraw(Rect(0, 0, ScreenWidth, ScreenHeight),
    ResImage[FResEnum]);
  LLeft := 10;
  LTop := TScene.SceneTop;
  LMid := ScreenWidth - ((320 * 4) + 26);
  FrameCount := 12;
  if FFrameGrid <> fgS6vS6 then
    FrameCount := 6;
  for I := 1 to FrameCount do
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
  if FFrameGrid = fgS6vM2 then
  begin
    FSurface.Canvas.Draw(LLeft, LTop, ResImage[reInfoFrame]);
    Inc(LLeft, 322);
    FSurface.Canvas.Draw(LLeft, LTop, ResImage[reInfoFrame]);
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
