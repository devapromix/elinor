unit DisciplesRL.Scene; // Game

interface

uses
  DisciplesRL.Map,
  DisciplesRL.Resources;

type
  TSceneEnum = (scMenu, scMap);

type

  { TScene }

  TScene = class(TObject)
  private
  
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; virtual; abstract;
    procedure Update(var Key: Word); virtual; abstract;
  end;	
  
type

  { TGame }

  TGame = class(TScene)
  private
    FIsDebug: Boolean;
    FKey: Word;
    FCanClose: Boolean;
    FGameName: string;
    FGameVersion: string;
    FMap: TMap;
    FScene: array [TSceneEnum] of TScene;
    FSceneEnum: TSceneEnum;
    FResources: TResources;
    procedure MainLoop;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure SetScene(const SceneEnum: TSceneEnum);
    property GameName: string read FGameName;
    property GameVersion: string read FGameVersion;
    property IsDebug: Boolean read FIsDebug write FIsDebug;
    property CanClose: Boolean read FCanClose write FCanClose;
    property Map: TMap read FMap write FMap;
    property Resources: TResources read FResources;
  end;

var
  Game: TGame;
  
implementation

uses
  Math,
  SysUtils,
  Classes,
  BearLibTerminal,
  DisciplesRL.Scene.Menu,
DisciplesRL.Scene.Map;

{ TScene }

constructor TScene.Create;
begin

end;

destructor TScene.Destroy;
begin
  inherited Destroy;
end;

{ TGame }

constructor TGame.Create;
var
  Debug: string;
begin
  inherited Create;
  FGameName := 'DisciplesRL';
  FGameVersion := 'v.0.8';
  FKey := 0;
  FCanClose := False;
  FIsDebug := (ParamCount > 0) and (Trim(ParamStr(1)) = '-d');
  terminal_open();
  FScene[scMenu] := TSceneMenu.Create;
  FScene[scMap] := TSceneMap.Create;
  SetScene(scMenu);
  Debug := '';
  if FIsDebug then
    Debug := '[DEBUG]';
  terminal_set(Trim(Format('window.title=%s %s %s',
    [FGameName, FGameVersion, Debug])));
  FMap := TMap.Create;
  FMap.Gen;
  terminal_set(Format('window.size=%dx%d', [Map.Width * 4, Map.Height * 2]));
  terminal_set('input.filter={keyboard, mouse+}');
  FResources := TResources.Create;
  terminal_refresh();
end;

procedure TGame.MainLoop;
begin
  repeat
    begin
      terminal_clear;
      Render;
    end;
    FKey := 0;
    if terminal_has_input() then
    begin
      FKey := terminal_read();
      Update(FKey);
      Continue;
    end;
    terminal_refresh();
    terminal_delay(1);
  until FCanClose or (FKey = TK_CLOSE);
end;

destructor TGame.Destroy;
var
  I: TSceneEnum;
begin
  FreeAndNil(FResources);
  FreeAndNil(FMap);
  for I := Low(TSceneEnum) to High(TSceneEnum) do
    FreeAndNil(FScene[I]);
  terminal_close();
  inherited;
end;

procedure TGame.Render;
begin
  if (FScene[FSceneEnum] <> nil) then
    FScene[FSceneEnum].Render;
end;

procedure TGame.Update(var Key: Word);
begin
  if (FScene[FSceneEnum] <> nil) then
    FScene[FSceneEnum].Update(Key);
end;

procedure TGame.SetScene(const SceneEnum: TSceneEnum);
begin
  FSceneEnum := SceneEnum;
end;

initialization
  Game := TGame.Create;
  Game.MainLoop;
  
finalization
  FreeAndNil(Game);

end.

