unit Elinor.Scene.Frames;

interface

uses
  Vcl.Graphics,
  System.Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Scenes;

type
  TFrameGrid = (fgLS3, fgLS6, fgRS6, fgRM1, fgLM2, fgRM2, fgRB);

type
  TSceneFrames = class(TScene)
  private
    FResEnum: TResEnum;
    FSurface: TBitmap;
  public
    constructor Create(const AResEnum: TResEnum;
      const ALeftFrameGrid, ARightFrameGrid: TFrameGrid);
    destructor Destroy; override;
    procedure Render; override;
    property ResEnum: TResEnum read FResEnum;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Frame;

{ TSceneFrames }

constructor TSceneFrames.Create(const AResEnum: TResEnum;
  const ALeftFrameGrid, ARightFrameGrid: TFrameGrid);
var
  I, LLeft, LTop, LMid, MinFrameCount, MaxFrameCount: Integer;
begin
  inherited Create;
  FResEnum := AResEnum;
  FSurface := TBitmap.Create;
  FSurface.Width := ScreenWidth;
  FSurface.Height := ScreenHeight;
  FSurface.Canvas.StretchDraw(Rect(0, 0, ScreenWidth, ScreenHeight),
    ResImage[FResEnum]);
  LLeft := TScene.SceneLeft;
  LTop := TScene.SceneTop;
  LMid := ScreenWidth - ((320 * 4) + 26);
  MinFrameCount := 1;
  MaxFrameCount := 12;

  if ARightFrameGrid <> fgRS6 then
    MaxFrameCount := 6;
  if ALeftFrameGrid = fgLS3 then
  begin
    MinFrameCount := 4;
    LLeft := TFrame.Col(1);
  end;
  if ALeftFrameGrid = fgLM2 then
  begin
    FSurface.Canvas.Draw(TFrame.Col(0), LTop, ResImage[reInfoFrame]);
    FSurface.Canvas.Draw(TFrame.Col(1), LTop, ResImage[reInfoFrame]);
  end
  else
    for I := MinFrameCount to MaxFrameCount do
    begin
      FSurface.Canvas.Draw(LLeft, LTop, ResImage[reFrameSlot]);
      Inc(LTop, 120);
      if LTop > TScene.SceneTop + 240 then
      begin
        LTop := TScene.SceneTop;
        Inc(LLeft, 322);
        if (I = 6) then
          Inc(LLeft, LMid);
      end;
    end;
  if ARightFrameGrid = fgRB then
    FSurface.Canvas.Draw(TFrame.Col(2), LTop, ResImage[reBigFrame]);
  if ARightFrameGrid = fgRM1 then
    FSurface.Canvas.Draw(TFrame.Col(2), LTop, ResImage[reInfoFrame]);
  if ARightFrameGrid = fgRM2 then
  begin
    FSurface.Canvas.Draw(TFrame.Col(2), LTop, ResImage[reInfoFrame]);
    FSurface.Canvas.Draw(TFrame.Col(3), LTop, ResImage[reInfoFrame]);
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
