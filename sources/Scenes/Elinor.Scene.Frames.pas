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
    FOnlyLeft: Boolean;
  public
    constructor Create(const AResEnum: TResEnum; AOnlyLeft: Boolean = False);
    destructor Destroy; override;
    procedure Render; override;
    property ResEnum: TResEnum read FResEnum;
    property OnlyLeft: Boolean read FOnlyLeft;
  end;

implementation

uses
  Math,
  SysUtils;

{ TSceneFrames }

constructor TSceneFrames.Create(const AResEnum: TResEnum;
  AOnlyLeft: Boolean = False);
var
  I, LLeft, LTop, LMid, FrameCount: Integer;
begin
  inherited Create;
  FResEnum := AResEnum;
  FOnlyLeft := AOnlyLeft;
  FSurface := TBitmap.Create;
  FSurface.Width := ScreenWidth;
  FSurface.Height := ScreenHeight;
  FSurface.Canvas.StretchDraw(Rect(0, 0, ScreenWidth, ScreenHeight),
    ResImage[FResEnum]);
  LLeft := 10;
  LTop := TScene.SceneTop;
  LMid := ScreenWidth - ((320 * 4) + 26);
  FrameCount := 12;
  if FOnlyLeft then
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
