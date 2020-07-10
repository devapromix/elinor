unit DisciplesRL.Scene; // Game

interface

uses
  DisciplesRL.Map,
  DisciplesRL.Resources;

type
  TSceneEnum = (scMenu, scGame);

type
  TScene = class(TObject)
  private
  
  public
    //constructor Create;
    //destructor Destroy; override;
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
    FResources: TResources;
    procedure MainLoop;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
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
  BearLibTerminal;

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
//  FScene[scMenu] := TSceneMenu.Create;
//  FScene[scGame] := TSceneGame.Create;
//  SceneEnum := scMenu;
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
    Render;
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
//  for I := Low(TSceneEnum) to High(TSceneEnum) do
//    FreeAndNil(FScene[I]);
  terminal_close();
  inherited;
end;

procedure TGame.Render;
var
  X, Y, MX, MY: Integer;
begin
  terminal_clear;
  terminal_layer(0);
  for Y := 0 to FMap.Height - 1 do
    for X := 0 to FMap.Width - 1 do
    begin
      terminal_layer(1);
      terminal_put(X * 4, Y * 2, FMap.GetTile(lrTile, X, Y));
      terminal_layer(2);
      if (FMap.GetTile(lrObj, X, Y) <> 0) then
        terminal_put(X * 4, Y * 2, FMap.GetTile(lrObj, X, Y));
    end;
  MX := terminal_state(TK_MOUSE_X) div 4;
  MY := terminal_state(TK_MOUSE_Y) div 2;
  terminal_layer(7);
  terminal_put(MX * 4, MY * 2, $E005);
  if FIsDebug then
  begin
    terminal_layer(9);
    terminal_print(1, 1, Format('%dx%d', [MX, MY]));
  end;
end;

procedure TGame.Update(var Key: Word);
begin

end;

initialization
  Game := TGame.Create;
  Game.MainLoop;
  
finalization
  FreeAndNil(Game);

end.

